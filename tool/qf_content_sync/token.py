"""OAuth2 client_credentials access-token acquisition.

PRIMARY SOURCE FACT (`SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
§3.1, `SESSION_185_IMPLEMENTATION_READINESS.md` §2, both independently
re-fetched from `api-docs.quran.foundation` in those sessions):

- The grant type is OAuth2 `client_credentials`, scope `content`.
- The token endpoint is `/oauth2/token` off `prelive-oauth2.quran.foundation`
  (pre-live) or `oauth2.quran.foundation` (production).
- The resulting access token is short-lived (3600 seconds) with no
  refresh token — it must be re-requested before expiry.
- `client_secret` must stay server-side only ("Keep client_secret on
  the server only").

INFERENCE beyond those facts (flagged per R25's evidence discipline):
the exact wire shape of the token request itself — HTTP Basic
client-authentication vs. `client_id`/`client_secret` in the POST
body — is not verbatim-quoted anywhere in this project's evidence
chain. This module implements the request the way RFC 6749 §4.4 (the
`client_credentials` grant) itself defines and recommends: HTTP Basic
auth carrying `client_id`/`client_secret`, with `grant_type` and
`scope` as a form-encoded body. That is the open standard this grant
type is built on, not a project-specific guess — but it has not been
exercised against QF's real token endpoint, because no credentials
exist to do so (Owner Gate, see the package README). Confirm this
against real `prelive` in the Phase 1 manual smoke test before relying
on it for anything beyond this module's own mocked tests.
"""
from __future__ import annotations

import base64
import os
import time
from dataclasses import dataclass
from typing import Callable

from . import constants
from .client import ContentSyncError, TransportResponse, raise_for_status, retry_with_backoff


@dataclass(frozen=True)
class ClientCredentials:
    """The long-lived pair QF issues via its Developer Console.

    Used only to obtain an access token (below) — never sent directly
    to a Content API request (that takes the access token, via
    `client.Credentials`, not this struct).
    """

    client_id: str
    client_secret: str
    environment: str = "prelive"

    def __repr__(self) -> str:  # pragma: no cover - defensive, trivial
        return f"ClientCredentials(client_id=<redacted>, client_secret=<redacted>, environment={self.environment!r})"

    @classmethod
    def from_env(cls) -> "ClientCredentials":
        client_id = os.environ.get("QF_CLIENT_ID")
        client_secret = os.environ.get("QF_CLIENT_SECRET")
        environment = os.environ.get("QF_ENVIRONMENT", "prelive")
        missing = [
            name
            for name, value in (("QF_CLIENT_ID", client_id), ("QF_CLIENT_SECRET", client_secret))
            if not value
        ]
        if missing:
            raise RuntimeError(
                "Missing required environment variable(s): "
                + ", ".join(missing)
                + ". QF Content Sync credentials are never read from a "
                "file or a hardcoded default (R05)."
            )
        return cls(client_id=client_id, client_secret=client_secret, environment=environment)


@dataclass(frozen=True)
class AccessToken:
    token: str
    expires_in: int
    token_type: str = "Bearer"


# (url, headers, form_body) -> TransportResponse. Deliberately a
# different shape from `client.Transport` (which is GET-only,
# no body) — token acquisition is a POST-with-body concern.
TokenTransport = Callable[[str, dict[str, str], dict[str, str]], TransportResponse]


def token_endpoint(environment: str) -> str:
    host = constants.PRELIVE_OAUTH_HOST if environment == "prelive" else constants.PRODUCTION_OAUTH_HOST
    return f"https://{host}/oauth2/token"


def _basic_auth_header(client_id: str, client_secret: str) -> str:
    raw = f"{client_id}:{client_secret}".encode("utf-8")
    return "Basic " + base64.b64encode(raw).decode("ascii")


def fetch_access_token(
    transport: TokenTransport,
    credentials: ClientCredentials,
    *,
    scope: str = constants.OAUTH_SCOPE,
    sleep: Callable[[float], None] = time.sleep,
) -> AccessToken:
    """Exchange `client_id`/`client_secret` for a short-lived access token.

    Reuses `client.raise_for_status`/`retry_with_backoff` so the same
    R07/R08 retry and error-classification rules apply to the token
    endpoint as to the content endpoints — one taxonomy, not two.
    """
    url = token_endpoint(credentials.environment)
    headers = {
        "Authorization": _basic_auth_header(credentials.client_id, credentials.client_secret),
        "Content-Type": "application/x-www-form-urlencoded",
    }
    form_body = {"grant_type": "client_credentials", "scope": scope}

    def _issue() -> TransportResponse:
        return transport(url, headers, form_body)

    response = retry_with_backoff(_issue, sleep=sleep)
    body = response.json or {}
    token = body.get("access_token")
    if not token:
        raise ContentSyncError("Token endpoint response carried no access_token")
    return AccessToken(
        token=token,
        expires_in=int(body.get("expires_in", 3600)),
        token_type=body.get("token_type", "Bearer"),
    )


def urllib_token_transport(url: str, headers: dict[str, str], form_body: dict[str, str]) -> TransportResponse:  # pragma: no cover
    """The one function in this module that performs a real HTTP
    request. Never invoked by any automated test — exists solely for
    the credential-gated manual smoke test (see the package README).
    """
    import json
    import urllib.error
    import urllib.parse
    import urllib.request

    data = urllib.parse.urlencode(form_body).encode("ascii")
    request = urllib.request.Request(url, data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=60) as resp:
            raw = resp.read()
            body = json.loads(raw) if raw else None
            return TransportResponse(status=resp.status, json=body, headers=dict(resp.headers))
    except urllib.error.HTTPError as exc:
        raw = exc.read()
        body = json.loads(raw) if raw else None
        return TransportResponse(status=exc.code, json=body, headers=dict(exc.headers or {}))
    except urllib.error.URLError as exc:
        from .client import TransientError

        raise TransientError(f"Network error contacting QF token endpoint: {exc.reason}")
