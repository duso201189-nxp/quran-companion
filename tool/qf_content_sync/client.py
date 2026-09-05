"""Content Sync bootstrap/incremental client — R03, R04, R07, R08.

Implements the two ordering invariants the official Content Sync
protocol documents (`SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
§3.1, PRIMARY SOURCE FACT):

- Bootstrap (R03): fetch and apply *every* `snapshot_url` from the
  bootstrap response before the caller ever sees a usable sync token.
  A failure partway through must never yield a result the caller could
  mistake for "fully applied."
- Incremental (R04): apply pages in ascending `sequence` order; the
  `next_sync_token` a caller should persist is the one from the final
  page (`has_more == False`) only — never an intermediate page's token.

Deliberate scope boundary (Phase 1 only, see the package `__init__.py`
and `docs/release/SESSION_192_PHASE1_CREDENTIAL_INDEPENDENT_SCOPE.md`):
this module does not persist a token anywhere, does not touch a
database, and does not run under any automated test against a real
network. `urllib_transport` is the sole function here that performs a
real HTTP call — no test in `tests/` imports or exercises it.

Evidence note on the incremental request shape (R25 discipline): the
bootstrap query string (`bootstrap=true&resources=<group>:<id>`) is
PRIMARY SOURCE FACT, quoted verbatim in the contract. The exact query
*parameter name* QF expects for a stored incremental token is not
verbatim-quoted anywhere in this project's evidence chain — S3.1
describes the *behavior* ("send the stored token") but not the literal
parameter. `_incremental_query` below is therefore marked INFERENCE and
isolated in one place so the Phase 1 manual smoke test (credential-
gated, not part of this module) can correct it against the real
`prelive` API without touching the ordering logic this module actually
guarantees.
"""
from __future__ import annotations

import os
import time
from dataclasses import dataclass, field
from typing import Any, Callable, Optional

from . import constants


# ---------------------------------------------------------------------
# Credentials — read from environment only (R05's "never a build-time
# constant" principle, applied one phase early since Phase 1 already
# needs to authenticate). Never logged: __repr__ is overridden so an
# accidental `print(credentials)` or test-failure traceback cannot leak
# a secret value.
#
# Deliberately holds an already-obtained OAuth2 *access token*, not the
# `client_secret` itself. Per SESSION_185 §2 (PRIMARY SOURCE FACT):
# "x-auth-token (an OAuth2 access token)" — the Content API headers
# take a short-lived access token, never the long-lived client secret.
# Exchanging `client_id`/`client_secret` for that access token is a
# separate concern with a different (POST, form-body) transport shape;
# see `token.py`. Conflating the two in one struct here previously
# would have produced code that looks plausible but sends the wrong
# credential type in the header (R08's concern about defaulting to a
# wrong-but-confident behavior, applied to auth rather than errors).
# ---------------------------------------------------------------------
@dataclass(frozen=True)
class Credentials:
    client_id: str
    access_token: str
    environment: str = "prelive"

    def __repr__(self) -> str:  # pragma: no cover - defensive, trivial
        return f"Credentials(client_id=<redacted>, access_token=<redacted>, environment={self.environment!r})"

    @classmethod
    def from_env(cls) -> "Credentials":
        """Read QF_CLIENT_ID / QF_ACCESS_TOKEN / QF_ENVIRONMENT.

        `QF_ACCESS_TOKEN` is expected to already be a valid, unexpired
        OAuth2 access token (see `token.fetch_access_token`) — this
        classmethod does not itself perform the OAuth2 exchange.

        Raises RuntimeError with no secret value in the message if a
        required variable is missing — mirrors the existing
        `dataset-verification.yml` pattern of naming which variable is
        absent, never what any present value contains.
        """
        client_id = os.environ.get("QF_CLIENT_ID")
        access_token = os.environ.get("QF_ACCESS_TOKEN")
        environment = os.environ.get("QF_ENVIRONMENT", "prelive")
        missing = [
            name
            for name, value in (("QF_CLIENT_ID", client_id), ("QF_ACCESS_TOKEN", access_token))
            if not value
        ]
        if missing:
            raise RuntimeError(
                "Missing required environment variable(s): "
                + ", ".join(missing)
                + ". QF Content Sync credentials are never read from a "
                "file or a hardcoded default (R05)."
            )
        return cls(client_id=client_id, access_token=access_token, environment=environment)

    def auth_headers(self) -> dict[str, str]:
        return {
            constants.AUTH_TOKEN_HEADER: self.access_token,
            constants.CLIENT_ID_HEADER: self.client_id,
        }


# ---------------------------------------------------------------------
# Transport abstraction — the seam every test in this package uses
# instead of a real network call.
# ---------------------------------------------------------------------
@dataclass(frozen=True)
class TransportResponse:
    status: int
    json: Optional[dict[str, Any]] = None
    headers: dict[str, str] = field(default_factory=dict)


Transport = Callable[[str, dict[str, str]], TransportResponse]


# ---------------------------------------------------------------------
# Error taxonomy — R08. An unmapped status defaults to TransientError
# (retry-eligible), never to an implicit success, per R08's own stated
# failure mode ("an unmapped error class must default conservatively
# to SYNC_FAILED, never to an implicit SYNCED").
# ---------------------------------------------------------------------
class ContentSyncError(Exception):
    """Base class for every documented Content Sync failure (§3.1)."""


class AuthError(ContentSyncError):
    """401/403 — "expired token or insufficient permissions."

    Corresponds to the state machine's TOKEN_INVALID transition (§7);
    this module does not itself drive that state machine (Phase 2), it
    only classifies the failure so a future caller can.
    """


class RequestError(ContentSyncError):
    """400/404/422 — malformed request or unavailable/unsupported resource."""


class TransientError(ContentSyncError):
    """Network error, 429, or 5xx — retry-eligible (R07)."""

    def __init__(self, message: str, retry_after: Optional[float] = None):
        super().__init__(message)
        self.retry_after = retry_after


def raise_for_status(response: TransportResponse) -> None:
    """Classify a response's status per R08's documented taxonomy."""
    status = response.status
    if 200 <= status < 300:
        return
    if status in constants.AUTH_FAILURE_STATUSES:
        raise AuthError(f"QF Content Sync returned {status} (expired token or insufficient permissions)")
    if status in constants.CLIENT_REQUEST_ERROR_STATUSES:
        raise RequestError(f"QF Content Sync returned {status}")
    if status == constants.RATE_LIMIT_STATUS:
        retry_after = response.headers.get("Retry-After")
        raise TransientError(
            "QF Content Sync rate limit exceeded (429)",
            retry_after=float(retry_after) if retry_after else None,
        )
    if 500 <= status < 600:
        raise TransientError(f"QF Content Sync server error ({status})")
    # Unmapped status: conservative default per R08, never treated as success.
    raise TransientError(f"QF Content Sync returned an unmapped status ({status})")


# ---------------------------------------------------------------------
# Retry/backoff — R07.
# ---------------------------------------------------------------------
def retry_with_backoff(
    call: Callable[[], "TransportResponse"],
    *,
    max_attempts: int = 5,
    base_delay: float = 1.0,
    sleep: Callable[[float], None] = time.sleep,
) -> TransportResponse:
    """Call `call()`, retrying on TransientError with exponential backoff.

    Respects a TransientError's `retry_after` when the server provided
    one (429's `Retry-After`, R07). Raises the final TransientError
    once `max_attempts` is exhausted rather than retrying forever —
    R07's own stated failure mode is "unbounded retry risks rate-
    limiting the project's own credentials."
    """
    last_error: Optional[TransientError] = None
    for attempt in range(max_attempts):
        try:
            response = call()
            raise_for_status(response)
            return response
        except TransientError as exc:
            last_error = exc
            if attempt == max_attempts - 1:
                break
            delay = exc.retry_after if exc.retry_after is not None else base_delay * (2**attempt)
            sleep(delay)
    assert last_error is not None
    raise last_error


# ---------------------------------------------------------------------
# Bootstrap — R03.
# ---------------------------------------------------------------------
@dataclass(frozen=True)
class BootstrapResult:
    records: list[dict[str, Any]]
    sync_token: str


def _bootstrap_query() -> str:
    """PRIMARY SOURCE FACT, verbatim (§3.1): `bootstrap=true&resources=<group>:<id>`."""
    return f"{constants.SYNC_ENDPOINT}?bootstrap=true&resources={constants.RESOURCE_GROUP}:{constants.RESOURCE_ID}"


def fetch_bootstrap(
    transport: Transport,
    credentials: Credentials,
    *,
    sleep: Callable[[float], None] = time.sleep,
) -> BootstrapResult:
    """Perform a full bootstrap. Raises before returning anything if any
    snapshot_url fails — a caller can never observe a partial result as
    if it were complete (R03's ordering invariant: "never persist a
    sync token until that full set is applied").
    """
    headers = credentials.auth_headers()

    def _issue_bootstrap() -> TransportResponse:
        return transport(_bootstrap_query(), headers)

    response = retry_with_backoff(_issue_bootstrap, sleep=sleep)
    body = response.json or {}
    changes = body.get("changes", [])
    sync_token = body.get("sync_token")
    if not sync_token:
        raise ContentSyncError("Bootstrap response carried no sync_token")

    records: list[dict[str, Any]] = []
    for change in changes:
        snapshot_url = change.get("snapshot_url")
        if not snapshot_url:
            continue

        def _issue_snapshot(url: str = snapshot_url) -> TransportResponse:
            return transport(url, headers)

        snapshot_response = retry_with_backoff(_issue_snapshot, sleep=sleep)
        snapshot_body = snapshot_response.json or {}
        records.extend(snapshot_body.get("records", []))

    # Only reachable once every snapshot_url above succeeded — this is
    # the one place a sync token becomes usable, by construction, not
    # by a separate flag.
    return BootstrapResult(records=records, sync_token=sync_token)


# ---------------------------------------------------------------------
# Incremental — R04.
# ---------------------------------------------------------------------
@dataclass(frozen=True)
class IncrementalResult:
    records: list[dict[str, Any]]
    next_sync_token: str


def _incremental_query(sync_token: str) -> str:
    """INFERENCE, not PRIMARY SOURCE FACT (see module docstring) — the
    literal query parameter name QF expects for a stored token is not
    verbatim-quoted in this project's evidence chain. `sync_token` is
    this session's best-documented guess (it matches the response
    field's own name); verify against real `prelive` before relying on
    it (Phase 1's credential-gated manual smoke test) and correct this
    one function if QF's real API expects something else.
    """
    return f"{constants.SYNC_ENDPOINT}?sync_token={sync_token}&resources={constants.RESOURCE_GROUP}:{constants.RESOURCE_ID}"


def fetch_incremental(
    transport: Transport,
    credentials: Credentials,
    sync_token: str,
    *,
    sleep: Callable[[float], None] = time.sleep,
) -> IncrementalResult:
    """Apply all pages in ascending `sequence` order; return the
    `next_sync_token` from the final page (`has_more == False`) only —
    R04's "store `next_sync_token` only from the final page."

    Raises ContentSyncError if a page's records are not in ascending
    `sequence` order relative to the previous page — R04's own stated
    failure mode is early/out-of-order token persistence silently
    skipping unapplied changes; this function refuses to produce a
    result in that case rather than silently accepting it.
    """
    headers = credentials.auth_headers()
    records: list[dict[str, Any]] = []
    last_sequence: Optional[int] = None
    url = _incremental_query(sync_token)
    next_token: Optional[str] = None

    while True:

        def _issue_page(page_url: str = url) -> TransportResponse:
            return transport(page_url, headers)

        response = retry_with_backoff(_issue_page, sleep=sleep)
        body = response.json or {}
        page_records = body.get("changes", [])
        for record in page_records:
            sequence = record.get("sequence")
            if sequence is not None and last_sequence is not None and sequence < last_sequence:
                raise ContentSyncError(
                    f"Out-of-order sequence: {sequence} after {last_sequence} "
                    "(R04 requires ascending application order)"
                )
            if sequence is not None:
                last_sequence = sequence
            records.append(record)

        has_more = bool(body.get("has_more", False))
        page_token = body.get("next_sync_token")
        if not has_more:
            # Final page — this is the only token a caller may persist.
            if not page_token:
                raise ContentSyncError("Final incremental page carried no next_sync_token")
            next_token = page_token
            break

        next_page_url = body.get("next_page_url")
        if not next_page_url:
            raise ContentSyncError("has_more=true but no next_page_url provided")
        url = next_page_url

    assert next_token is not None
    return IncrementalResult(records=records, next_sync_token=next_token)


# ---------------------------------------------------------------------
# Real transport — never invoked by any test in this package.
# ---------------------------------------------------------------------
def urllib_transport(url: str, headers: dict[str, str]) -> TransportResponse:  # pragma: no cover
    """The one function in this package that performs a real HTTP
    request. Exists solely for the credential-gated manual smoke test
    described in the requirement contract (§13 Phase 1) — no
    automated test, and no other function in this package, calls it.
    """
    import json
    import urllib.error
    import urllib.request

    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=60) as resp:
            status = resp.status
            raw = resp.read()
            body = json.loads(raw) if raw else None
            return TransportResponse(status=status, json=body, headers=dict(resp.headers))
    except urllib.error.HTTPError as exc:
        # urllib raises rather than returning a non-2xx response; convert
        # back into a TransportResponse so raise_for_status (R08) still
        # does the classification, instead of an uncaught HTTPError
        # bypassing it.
        raw = exc.read()
        body = json.loads(raw) if raw else None
        return TransportResponse(status=exc.code, json=body, headers=dict(exc.headers or {}))
    except urllib.error.URLError as exc:
        raise TransientError(f"Network error contacting QF Content Sync: {exc.reason}")
