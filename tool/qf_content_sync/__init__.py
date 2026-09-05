"""Quran Foundation ("QF") Content Sync — Phase 1 source adapter (isolated).

Scope, precisely, per `docs/release/SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
§13 Phase 1 and `docs/release/SESSION_185_IMPLEMENTATION_READINESS.md` §5,
sharpened by `docs/release/SESSION_192_PHASE1_CREDENTIAL_INDEPENDENT_SCOPE.md`:

- This package is NOT wired into `tool/build_quran_db.py`.
- This package NEVER calls the real Quran Foundation API in any
  automated test. Every test in `tests/` uses an injected fake
  transport — no `urllib`/`http`/`requests` call happens under test.
- `client.urllib_transport` is the one function in this package that
  performs a real HTTP request. It exists so a human with real QF
  credentials can run the Phase 1 manual smoke test described in the
  requirement contract; no automated code path (test or otherwise)
  invokes it.
- `tool/fetch_transliteration.py` (the legacy Quran.com endpoint) is
  untouched. Nothing in this package deletes, imports, or modifies it.
- No new third-party dependency is introduced (see the package README
  for why the previously-suggested `quran-foundation-api` SDK was
  deliberately not adopted this session).
"""
