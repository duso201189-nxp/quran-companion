"""Resource identity and protocol constants — R02.

Every value below is a PRIMARY SOURCE FACT, verbatim, from
`docs/release/SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md` R02
and §3.1 (independently confirmed there against QF's own official
documentation at api-docs.quran.foundation). None of these are chosen
by this project; a typo here silently fetches the wrong resource or
nothing (R02's own stated failure mode), which is why R02 requires
them to live in exactly one place, asserted by a unit test
(`tests/test_constants.py`).
"""
from __future__ import annotations

# --- Resource identity (R02) -------------------------------------------
RESOURCE_GROUP = "word_by_word_transliterations"
RESOURCE_ID = 60
INCREMENTAL_RECORD_TYPE = "word_transliteration"

# --- Endpoints (R02, §3.1) ----------------------------------------------
API_BASE = "https://apis.quran.foundation/content/api/v4"
SNAPSHOT_URL = f"{API_BASE}/resources/snapshots/{RESOURCE_GROUP}/{RESOURCE_ID}"
SYNC_ENDPOINT = f"{API_BASE}/resources/sync"

# --- Auth (§3.1: OAuth2 client_credentials, "content" scope) -----------
# Header names only — never a header *value* — are constants. Actual
# credential values are read at call time from environment variables
# by `client.Credentials.from_env`, never hardcoded, never logged,
# never written under `tool/data/` (git-tracked).
AUTH_TOKEN_HEADER = "x-auth-token"
CLIENT_ID_HEADER = "x-client-id"
OAUTH_SCOPE = "content"

# --- Environment/host separation (SESSION_185 §2, verbatim from QF docs)
# "New apps begin in pre-live... move to production only after
# production permissions are approved." Phase 1's own acceptance
# criterion targets `prelive` only.
PRELIVE_OAUTH_HOST = "prelive-oauth2.quran.foundation"
PRODUCTION_OAUTH_HOST = "oauth2.quran.foundation"

# --- Documented error taxonomy (§3.1) -----------------------------------
# Status codes QF's own API reference documents. Used by client.py to
# classify a response into TransientError / AuthError / RequestError
# (R08) — an unmapped status must default to TransientError (retry),
# never to an implicit success, per R08's own stated failure mode.
AUTH_FAILURE_STATUSES = frozenset({401, 403})
CLIENT_REQUEST_ERROR_STATUSES = frozenset({400, 404, 422})
RATE_LIMIT_STATUS = 429

# --- Coverage cross-check (shared with the legacy pipeline; REPO FACT,
# `tool/fetch_transliteration.py`) — Phase 1's real-credential smoke
# test compares its bootstrap coverage against this same figure.
EXPECTED_AYAHS = 6236
