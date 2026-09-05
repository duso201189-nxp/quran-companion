# `tool/qf_content_sync` — Phase 1 source adapter (credential-independent sub-scope)

Implements the part of `SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
§13 Phase 1 / `SESSION_185_IMPLEMENTATION_READINESS.md` §5 that does
**not** require a real Quran Foundation (QF) credential to write or
test. See `docs/release/SESSION_192_PHASE1_CREDENTIAL_INDEPENDENT_SCOPE.md`
for the full decomposition, repo audit, and decision record this
package is the output of.

## What exists here

| File | Requirement(s) | What it does |
|---|---|---|
| `constants.py` | R02 | Resource identity, endpoints, header names, documented error-status taxonomy — every value a PRIMARY SOURCE FACT quoted verbatim in the contract. |
| `client.py` | R03, R04, R07, R08 | Bootstrap fetch (fetch every `snapshot_url` before a token is usable) and incremental fetch (apply pages in ascending `sequence`; persist `next_sync_token` only from the final page), retry/backoff, error classification. Every I/O call goes through an injected `Transport` callable — no test exercises real HTTP. |
| `token.py` | auth model (§3.1/§2) | OAuth2 `client_credentials` token exchange. The grant type and endpoint are PRIMARY SOURCE FACT; the exact request wire-shape (HTTP Basic auth) is this session's RFC-6749-standard implementation, flagged INFERENCE — see the module docstring. |
| `tests/` | R24 | `unittest`-based, mirrors the existing `tool/lexicon/tests/` convention (no pytest, no new dependency). 26 tests, all using a fake transport, 0.002s wall time, zero network calls. |

Run them from `tool/`:

```
python -m unittest discover -s qf_content_sync/tests -p "test_*.py"
```

## What is deliberately NOT here (and why)

- **No real network call in any test, ever.** `client.urllib_transport`
  and `token.urllib_token_transport` are the only two functions that
  perform real HTTP requests; nothing in `tests/` imports either one.
  They exist for a human, with real credentials, to run a manual
  `prelive` smoke test — not for CI, not for this session.
- **No new third-party dependency.** Session 184/185 suggested the
  official `quran-foundation-api` PyPI SDK. This session did not adopt
  it: its exact function surface was marked SECONDARY SOURCE (a
  `WebSearch` synthesis, not independently verified) in Session 184's
  own evidence table, and depending on an unverified interface for a
  security-sensitive credential-handling path was judged a worse
  trade than hand-rolling ~250 lines against the PRIMARY-SOURCE-verified
  REST contract, using the same `urllib`-only style the existing
  `tool/fetch_transliteration.py` already uses. No `requirements.txt`
  was added because there is nothing to declare.
- **No wiring into `tool/build_quran_db.py`.** Untouched, unimported.
- **No change to `tool/fetch_transliteration.py`** (the legacy path) —
  untouched, remains the rollback margin per the contract's migration
  sequencing (§10).
- **No sync-state/token persistence, no state machine (§7), no
  corruption recovery (R10).** That is Phase 2's scope
  (`SESSION_184_...` §13), not Phase 1's. Building it now would have
  been scope creep beyond what Session 185 itself defined as Phase 1.
- **No CI workflow change.** Nothing here runs in `.github/workflows/`.
  Phase 5, not Phase 1, is where a scheduled workflow is introduced —
  and per R20, it must never join the existing per-push/PR pipeline.
- **No real credential, anywhere.** `Credentials.from_env` /
  `ClientCredentials.from_env` read `QF_CLIENT_ID` / `QF_ACCESS_TOKEN`
  / `QF_CLIENT_SECRET` / `QF_ENVIRONMENT`; none of those variables are
  set anywhere in this repository today (verified: `gh secret list`,
  `gh variable list`, Session 192).

## What remains blocked, and by what

Only real end-to-end execution is blocked, and only by one thing: QF
`client_id`/`client_secret` do not exist yet (an account-creation
action no Claude session may perform — see `SESSION_185_...` §6, Owner
Gate 1). Once the owner obtains them and provides them as environment
variables (locally or as a CI secret), the manual smoke test described
in the contract (§13 Phase 1 acceptance: a real bootstrap against
`prelive` reproducing 6,236 ayahs' worth of coverage) can run using
exactly the functions in this package — nothing here needs to be
rewritten to use real credentials, only exercised with them.
