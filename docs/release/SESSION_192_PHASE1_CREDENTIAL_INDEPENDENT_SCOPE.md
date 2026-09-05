# Session 192 — Phase 1 Decomposition & Credential-Independent Implementation

**Prepared:** 2026-09-05
**Scope:** Decompose `SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
§13 Phase 1 ("Source adapter") into sub-items by dependency, audit the
repository for reusable infrastructure, and implement the sub-items
that do not require a real Quran Foundation ("QF") credential to write
or test. **Does not obtain, request, or simulate obtaining any QF
credential. Does not call any live QF endpoint. Does not close, or
move toward closing, `P2-2`. Does not change git history, DB schema,
legacy fetch code, or CI.**

> This document does not re-litigate Sessions 164–185's evidence or
> conclusions. Where it cites a fact, it cites the session that
> established it rather than re-deriving it.

---

## A. Baseline

Verified fresh this session (`git fetch origin`, `gh secret/variable
list`, direct reads) — not assumed from any prior report.

| Item | Value |
|---|---|
| `origin/main` HEAD | `9567748deb2049627b33638b5c3573a4c0f4fefc` (PR #69 merge, "session190-stale-pr-ref-hygiene") |
| Primary worktree | `…/quran_companion`, branch `publish-docs-reconciliation-s14`, HEAD `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe`, 22-line `git status --porcelain`, 0 stashes — **re-verified unchanged before and after this session**, see §L |
| This session's worktree | `worktrees/session192-phase1-credential-independent-scope`, branch of the same name, branched fresh from `origin/main` at `9567748` |
| QF-related secrets/variables | **None.** `gh secret list` → `R2_PUBLISH_ACCESS_KEY_ID`, `R2_PUBLISH_SECRET_ACCESS_KEY`, `R2_READ_ACCESS_KEY_ID`, `R2_READ_SECRET_ACCESS_KEY` (all 2026-07-26). `gh variable list` → `R2_BUCKET`, `R2_S3_ENDPOINT`. No `QF_*` name of any kind exists — re-confirms Session 185 §2/§3, unchanged since. |
| Canonical Phase 1 source | `SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md` §13 Phase 1, sharpened by `SESSION_185_IMPLEMENTATION_READINESS.md` §5 — read in full this session, not summarized from memory. |

---

## B. Pattern Assessment

Per the governing brief, applied only where actually needed:

| Pattern | Needed at Phase 1 scope? | Reasoning |
|---|---|---|
| Evidence-Gated State Machine | **No, not the full §7 machine.** | The 10-state machine (`UNINITIALIZED`→…→`RECOVERY_REQUIRED`) is Session 184's own Phase **2** deliverable ("implement token persistence, the state machine, and corruption detection" — §13). Phase 1 has no persisted state to key a machine off. What Phase 1 *does* need — the bootstrap/incremental ordering invariants (R03/R04) — is enforced directly in `client.py`'s control flow (an exception before any result is constructed), not a separate FSM. Building the full machine now would be Phase 2 work done early, out of this session's scope. |
| Artifact Contract | **Yes, minimally.** | R02's config constants and the raw record shape returned by `fetch_bootstrap`/`fetch_incremental` are exactly artifact-contract concerns (§8 of the requirement contract, artifacts B/C). Captured as typed dataclasses (`BootstrapResult`, `IncrementalResult`) with fields matching QF's documented schema — not a bare dict, not a heavier registry (that's `DR-2026-0011`/`0012`'s job, Phase 5, out of scope). |
| Capability Routing | **No.** | Concerns platform routing (Android/iOS/Web/CI, §9) — Phase 5. Nothing in Phase 1 runs on a client platform. |
| Scoped/Persistent Memory | **No.** | Phase 1 persists nothing. Token/state persistence is Phase 2 (R05, R10). |
| Rollback/Versioning | **Yes, trivially.** | Per R27/§15: new, additive files only; rollback is deletion. No versioning scheme needed — nothing here is published or consumed by anything else yet. |
| Provenance/Evidence | **Yes.** | Every constant and ordering rule in the new code cites its requirement ID and evidence tag (PRIMARY SOURCE FACT / INFERENCE) inline, per R25. The one place this session introduces new INFERENCE (the incremental-request query parameter name and the OAuth2 token-request wire shape) is flagged in-code, not asserted as fact. |

No pattern was applied beyond what a specific Phase 1 sub-item required.

---

## C. Phase 1 Decomposition

Sub-items of `SESSION_184_...` §13 Phase 1 / `SESSION_185_...` §5,
classified into the five buckets requested.

### C1. Credential-independent (implementable and testable now)

| # | Item | Requirement ID(s) | Evidence source | Can implement/test now? | Risk if implemented before credentials exist | Rollback |
|---|---|---|---|---|---|---|
| 1 | Resource identity constants (`resource_group`, `resource_id`, snapshot URL, incremental record type) | R02 | PRIMARY SOURCE FACT, `SESSION_184` §3.1/R02, verbatim | **Yes — done this session.** | None — these are QF-assigned identifiers, not project choices; a wrong value fails the R02 unit test itself before ever reaching a real request. | Delete the file. |
| 2 | Bootstrap fetch with the R03 ordering invariant (every `snapshot_url` applied before a token is usable) | R03 | PRIMARY SOURCE FACT, `SESSION_184` §3.1 | **Yes — done, with a fault-injection test (interrupted bootstrap → no result, no token).** | None against a mocked transport. Risk exists only when *executed* against the real API (see C2). | Delete the file; nothing else references it. |
| 3 | Incremental fetch with the R04 ordering invariant (ascending `sequence`; `next_sync_token` only from the final page) | R04 | PRIMARY SOURCE FACT, `SESSION_184` §3.1 | **Yes — done, with a multi-page fixture test and an out-of-order-rejection test.** | None against a mocked transport. | Delete the file. |
| 4 | Retry/backoff on transient failure classes | R07 | PRIMARY SOURCE FACT (error taxonomy) | **Yes — done**, including a `Retry-After`-respecting test and an attempt-exhaustion test. | None. | Delete the file. |
| 5 | Failure-class → exception mapping (`400/401/403/404/422/429/5xx` → `RequestError`/`AuthError`/`TransientError`, unmapped → `TransientError` never success) | R08 | PRIMARY SOURCE FACT (official error taxonomy) | **Yes — done**, one test per class. | None. | Delete the file. |
| 6 | Credential *plumbing* (env-var names, never-log discipline, never-hardcoded default) | R05 (applied one phase early, structurally) | REPO FACT (`dataset-verification.yml`'s existing read/write-secret-split pattern, reused) + PRIMARY SOURCE FACT (S8 permits nothing about *how* to hold a secret, but "keep client_secret server-side only" is QF's own stated guidance, `SESSION_185` §2) | **Yes — done.** `Credentials.from_env`/`ClientCredentials.from_env` read `QF_CLIENT_ID`/`QF_ACCESS_TOKEN`/`QF_CLIENT_SECRET`/`QF_ENVIRONMENT`; raise a named-variable `RuntimeError` (no value) if absent; `__repr__` is overridden to redact. | None — these variables do not exist anywhere in this repo today (§A), so this path is exercised only by its own unit tests, which set no real secret. | Delete the file. |
| 7 | OAuth2 client_credentials token-exchange request construction | Not itself an `R`-numbered item; part of Phase 1's "Interfaces"/"Security boundary" (`SESSION_185` §5) | Grant type + endpoint: PRIMARY SOURCE FACT (`SESSION_185` §2). Exact request wire shape: **this session's own INFERENCE**, flagged in `token.py`'s docstring — implements RFC 6749 §4.4's standard shape (HTTP Basic client auth), not a QF-specific guess. | **Yes — done**, with tests confirming the secret only ever appears in the Basic-auth header, never the form body. | **Medium, if mistaken for verified.** This is the one piece of new code in this session's scope that could be wrong against QF's real server (the exact request encoding was never verbatim-confirmed). Mitigated by: (a) explicit INFERENCE flag in the docstring and this document, (b) isolated in one small function, (c) the real transport is never invoked by any test, so a wrong assumption here fails loudly at the manual smoke test, not silently in production. | Delete the file; nothing depends on it yet. |
| 8 | `unittest`-based test suite (mirrors `tool/lexicon/tests/` convention, no new dependency) | R24 | REPO FACT (existing convention) | **Yes — done.** 26 tests, 0.002s, zero network calls (verified: grepped for any test importing the two real-transport functions — none do). | None. | Delete the directory. |

**Deliberately not built even though credential-independent:** a
`requirements.txt`/`pyproject.toml` for `tool/`. Session 185 scoped
this as part of Phase 1 *because* it assumed the official
`quran-foundation-api` SDK would be used. This session's Decide step
(§G) found that SDK's exact interface was never independently verified
(marked SECONDARY SOURCE in `SESSION_184` §3.1's own evidence table)
and chose to hand-roll the client against the PRIMARY-SOURCE-verified
REST contract instead — see §G for the full reasoning. With no new
dependency, there is nothing for a dependency-lock file to declare.

### C2. Credential-dependent (blocked until QF credentials exist)

| # | Item | Requirement ID(s) | Precondition | Risk if attempted anyway | Rollback |
|---|---|---|---|---|---|
| 9 | Real OAuth2 token exchange against `prelive-oauth2.quran.foundation` | auth model, §2/§3.1 | A real `client_id`/`client_secret` pair | N/A — cannot be attempted without the credential; this session made no attempt. | N/A |
| 10 | Real bootstrap fetch against `prelive`, reproducing the legacy path's 6,236-ayah coverage (Phase 1's own stated acceptance criterion, `SESSION_184` §13) | R03, R15 | A real access token | Would require a real credential this session does not have and may not obtain (Owner Gate). | N/A |
| 11 | Confirming the incremental request's exact query-parameter name (flagged INFERENCE in `client.py`) against the real API | R04 | Same as #10 | Same. | N/A |
| 12 | Any conclusion about real-world rate limits, token rotation cadence, or "Request Access" turnaround time | open unknowns, `SESSION_184` §18 | QF interaction | Same. | N/A |

### C3. Owner-gated

Unchanged from `SESSION_184` §16 / `SESSION_185` §6 — re-confirmed,
not re-decided, this session:

| # | Item | Why owner-only |
|---|---|---|
| 13 | Obtaining QF `client_id`/`client_secret` | Account-creation action; no Claude session may perform this (this session's own standing tool-use rules, independently arrived at by every session in this chain since 184). |
| 14 | Sending the QF developer-access application | Drafted (`SESSION_185_QF_DEVELOPER_ACCESS_APPLICATION_DRAFT.md`), not sent — external communication requires the owner. |
| 15 | Ratifying `DR-2026-0008`…`0013` (and `0028`) onto `main` | `SESSION_185` §1 — individually owner-approved in content, never committed; landing them touches CI/repository structure and two carry `reversibility: hard`. Not needed for Phase 1 (only for Phase 5/6). Not touched this session. |
| 16 | Beginning implementation timing/resourcing generally | D1, `SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md` — this session treats *this specific credential-independent slice* as already authorized by Session 192's own governing brief ("triển khai các phần... không phụ thuộc QF credentials"), not as a blanket authorization to proceed into Phase 2 or beyond. |

### C4. Counsel/legal-gated

| # | Item | Why |
|---|---|---|
| 17 | Routing the counsel packet (`SESSION_185_QF_COUNSEL_ROUTING_PACKET.md`) | Drafted, not sent — R30/D15/D20. |
| 18 | Any conclusion that the QF email is sufficient legal authorization, or that the dataset is "compliant" | R30 — reserved for counsel/owner across every session in this chain. This document contains no such conclusion (self-check, mirroring `SESSION_184` §17). |
| 19 | `P2-2` closure itself | R29 — requires (a) attribution, (b) raw dataset no longer newly committed, (c) a demonstrated real incremental sync, (d) counsel input sought-or-deferred. None of these four advance in this session. `P2-2` stays **OPEN**. |

### C5. Explicitly blocked (this session will not do these regardless of authorization)

Per the governing brief's own constraints, all confirmed **not done**
this session:

- Contact Quran Foundation, or send any external communication.
- Request, apply for, simulate, or fabricate any QF credential.
- Call any live `apis.quran.foundation` or `oauth2.quran.foundation` endpoint (verified: no test or script in this change does; the two functions capable of it are never invoked).
- Add any `QF_*` secret or variable to this repository's CI configuration.
- Modify `tool/fetch_transliteration.py` (the legacy path) in any way.
- Modify `tool/build_quran_db.py`, any database schema, or `assets/database/quran.sqlite`.
- Add or modify any `.github/workflows/*.yml` file.
- Commit, merge, or ratify any `docs/adr/DR-2026-000*` file.
- Modify `docs/LICENSING.md`, `RELEASE_DASHBOARD.md`, or `V1_STORE_LEGAL_READINESS.md`.
- Declare `P2-2` closed, or declare the QF email legally sufficient.
- Touch the primary worktree (`publish-docs-reconciliation-s14`) in any way — read-only throughout (see §L).
- Rewrite git history.

---

## D. Repo Audit Findings

Evidence-first, no architecture assumed. All read from `origin/main`
unless noted.

- **`tool/` layout.** `tool/build_quran_db.py`, `tool/fetch_transliteration.py`,
  `tool/fetch_morphology.py`, `tool/fetch_surah_names.py` — flat,
  stdlib-only Python scripts. `tool/lexicon/` is the one existing
  *package* under `tool/` (`__init__.py`, module files, `tests/`
  subpackage) — used as the structural template for `tool/qf_content_sync/`.
- **No Python dependency-lock file anywhere** (`requirements.txt`,
  `pyproject.toml`, `Pipfile`) — re-confirms `SESSION_185` §3's
  finding, unchanged.
- **No `pytest` anywhere in the repository.** `tool/lexicon/tests/*.py`
  all use stdlib `unittest`, invoked by inserting `tool/` onto
  `sys.path` and importing the package by name — this session's tests
  follow the identical pattern (`qf_content_sync.client`, not a
  relative script import).
- **Existing HTTP pattern.** `tool/fetch_transliteration.py` hand-rolls
  HTTP with `urllib.request` plus a small retry loop (4 attempts,
  fixed 1.5s×attempt backoff) — no `requests`, no SDK, anywhere in
  `tool/`. This session's `client.py`/`token.py` follow the same
  stdlib-only convention rather than introducing the first third-party
  HTTP/SDK dependency this project has ever had in `tool/`.
  `pubspec.yaml` (Dart side) was not inspected for HTTP packages —
  irrelevant, since Phase 1 is pipeline-side only (R20).
  `fetch_transliteration.py` itself is **unchanged** by this session.
- **CI (`ci.yml`).** Five jobs (`secret-scan`, `quality`, `build-android`,
  `build-web`, `build-ios`), all Flutter/Dart-side; none run any
  Python test today (`tool/lexicon/tests/` is not wired into CI either
  — a pre-existing gap, not something this session introduces or
  fixes, and out of this session's scope). Confirms R20's premise:
  there is no live network dependency in the per-push/PR pipeline to
  protect today, and this session adds none.
- **Existing R2 storage infrastructure (`dataset-verification.yml`).**
  Live, running daily (`cron: '17 5 * * *'`), read-only, against a
  real Cloudflare R2 bucket, using exactly the secret-naming/read-
  write-split pattern (`R2_READ_*` vs `R2_PUBLISH_*`) `SESSION_185` §3
  documented. Re-verified this session (`gh secret/variable list`,
  `gh run list` not re-run — no new evidence needed beyond confirming
  the secret set is unchanged). This is Phase 5's eventual publish
  target, not something Phase 1 touches.
- **Content Sync / QF-related code today: none.** No file under
  `tool/`, `lib/`, or `.github/` references `apis.quran.foundation`,
  `quran.foundation`, or Content Sync before this session's addition.
- **Legacy transliteration path.** `tool/fetch_transliteration.py` →
  `tool/data/transliteration.json` (committed, tracked) →
  `tool/build_quran_db.py` → `assets/database/quran.sqlite` (committed,
  tracked, 3 prior commits). `lib/features/quran/data/transliteration_repository.dart`'s
  `normalize()` is the existing (near-no-op) presentation-layer seam
  R16 would eventually use — read, not touched.
- **Tests already covering this domain:** `test/transliteration_test.dart`,
  `test/transliteration_standard_test.dart`, `test/repository_boundary_test.dart`,
  `test/repository_boundary_completeness_test.dart` — all Dart-side,
  none affected by this session's Python-only, unwired addition.
- **Configuration/secrets pattern to reuse:** GitHub Actions
  `secrets.*`/`vars.*` injected as job `env:`, read by shell/Python via
  `os.environ` — exactly what `Credentials.from_env`/`ClientCredentials.from_env`
  do, so a future Phase 5 CI job needs no new secret-handling idiom,
  only new secret *names* (`QF_CLIENT_ID`, `QF_CLIENT_SECRET`).

---

## E. What Blocks the Rest of Phase 1

Narrowed from `SESSION_185` §8's single blanket blocker: **exactly two
things** block the remainder of Phase 1 (the real bootstrap fetch
against `prelive` reproducing 6,236 ayahs of coverage), and only those
two:

1. QF `client_id`/`client_secret` do not exist (Owner Gate — account
   creation, §C3 #13).
2. Given #1, this session's INFERENCE on the incremental
   query-parameter name (`client.py`) and the token-request wire shape
   (`token.py`) are unverified against the real API — not a new
   blocker, a consequence of #1, resolved automatically once #1 is
   resolved and the manual smoke test runs.

Everything else this audit checked — the ordering invariants, the
error taxonomy, the retry policy, the test strategy, the storage
architecture to eventually publish into (§D) — is already implemented
and passing, not merely specified.

---

## F. Decision (Task C)

**Decision: implement.** The credential-independent sub-items in §C1
exist independently of any credential, do not fabricate a production
integration (every real-network function is dead code, never invoked
by a test, clearly marked), and directly narrow what a future session
needs to do once credentials arrive — from "write and test an entire
client" to "run the existing client with a real token." This satisfies
the governing brief's own decision rule: *"Nếu implementation có thể
tồn tại độc lập và không giả mạo production integration → có thể
làm."*

**What was explicitly rejected, and why:**

- **Adopting the `quran-foundation-api` SDK**, as Session 184/185
  suggested. Rejected because its exact interface was never
  independently verified in this project's evidence chain (SECONDARY
  SOURCE only) — depending on an unverified third-party interface for
  a credential-handling path is a worse trade than ~250 lines of
  stdlib-only code against the PRIMARY-SOURCE-verified REST contract,
  and avoids adding this project's first-ever third-party HTTP/SDK
  dependency under `tool/` for something not yet provably necessary.
- **Building the §7 state machine or any token persistence.** That is
  Phase 2, not Phase 1 (`SESSION_184` §13's own phase boundary). Doing
  it now would be scope creep, not safe-scope diligence — the
  governing brief explicitly warns against over-engineering.
- **Building a placeholder/mock QF server or a "fake production
  success path."** Rejected outright per the governing brief's own
  prohibition — every test in this change uses an in-process fake
  transport function, never a simulated server, and no test or code
  path claims to have verified real QF behavior.

---

## G. Files Changed

All new, all additive, all in this session's isolated worktree —
nothing existing was modified.

```
tool/qf_content_sync/__init__.py
tool/qf_content_sync/README.md
tool/qf_content_sync/constants.py
tool/qf_content_sync/client.py
tool/qf_content_sync/token.py
tool/qf_content_sync/tests/__init__.py
tool/qf_content_sync/tests/test_constants.py
tool/qf_content_sync/tests/test_client.py
tool/qf_content_sync/tests/test_token.py
docs/release/SESSION_192_PHASE1_CREDENTIAL_INDEPENDENT_SCOPE.md   (this file)
```

No existing file was edited. `git diff --stat` against `origin/main`
shows only additions (see §H).

---

## H. Tests / Validation (Task E)

| Check | Result |
|---|---|
| `python -m unittest discover -s qf_content_sync/tests -p "test_*.py"` (from `tool/`) | **26/26 pass, 0.002s.** |
| Any test imports/calls `urllib_transport` or `urllib_token_transport`? | **No** (grepped `tests/` — zero matches). |
| `git diff --check` (whitespace errors) | Clean. |
| Secrets scan (manual grep for `QF_CLIENT`, `client_secret=`, literal token-looking strings) in the new files | None found — only environment-variable *names*, never values. |
| DB/data changes | None — `assets/database/quran.sqlite`, `tool/data/*.json` untouched. |
| Legacy path mutation | None — `tool/fetch_transliteration.py`, `tool/build_quran_db.py` untouched (byte-identical to `origin/main`). |
| Schema change | None — no `.dart`, no migration, no `lib/core/database/*` file touched. |
| CI change | None — `.github/workflows/*` untouched. |
| Governance/legal record change | None — no `docs/adr/*`, `docs/LICENSING.md`, `RELEASE_DASHBOARD.md`, `V1_STORE_LEGAL_READINESS.md` touched. |
| Scope vs. R01–R30 | §C1 table above maps every changed file to the exact requirement ID(s) it implements; nothing implements an R-item outside R02–R08/R24. |
| No legal/governance claim changed | Confirmed — this document makes no compliance claim; `P2-2` is not mentioned as anything but OPEN (§C4 #19). |
| Primary worktree byte-identical | Confirmed, see §L. |

`flutter test`/`flutter analyze` were **not** run — this change
touches no Dart file, so the existing Dart test suite is unaffected by
construction; re-running it would have verified nothing about this
change specifically. (If a reviewer wants the full green-CI
confirmation regardless, that is a one-command check on the PR itself,
not a reason to withhold this document.)

---

## I. PR

A single, isolated, docs+code PR was opened from this session's branch
(`session192-phase1-credential-independent-scope`) against `main`,
containing exactly the files in §G:

- **PR:** [#70](https://github.com/duso201189-nxp/quran-companion/pull/70)
- **Head SHA at open:** `e8a3d054c0d4e34a67435601de611394913adae1`

**Not merged** — left for normal review/CI, per the governing brief
("không merge nếu chưa đạt full merge gate").

---

## J. Governance Invariants Preserved

- `P2-2` remains **OPEN**. Nothing in this document or change narrows,
  closes, or reinterprets that status.
- No DR was created, edited, or ratified.
- No prior session's evidence or conclusion was re-litigated;
  `SESSION_184`/`185`'s Phase 1 definition is followed, not redefined
  — this document only adds a finer-grained dependency breakdown
  within it.
- The Option B (build-time-only) architecture is unchanged and
  unquestioned — this session's code is exactly Option B's Phase 1.
- R30's discipline (no session declares legal sufficiency) is
  maintained throughout this document.

---

## K. Owner Gates — Unchanged

Identical list to `SESSION_185` §6, re-confirmed not re-decided: QF
credential creation; sending the access application; routing the
counsel packet; DR ratification; `P2-2` closure; any git-history
question. This session resolved none of them and did not attempt to.

---

## L. Primary Worktree Safety

| Check | Before this session | After this session |
|---|---|---|
| Path | `…\quran_companion_v0.6.0\quran_companion` | unchanged |
| Branch | `publish-docs-reconciliation-s14` | unchanged |
| HEAD | `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe` | unchanged |
| `git status --porcelain` line count | 22 | 22 (re-verified) |
| Stash count | 0 | 0 |

All work occurred in `worktrees/session192-phase1-credential-independent-scope`,
branched fresh from `origin/main` at `9567748`. The primary worktree
was read only for orientation (`CLAUDE.md`, confirming `PROJ-P-002`)
via the automatically-loaded system context, never via a direct
`Read`/`Edit`/`Write` call against its path this session.

---

## M. Exact Remaining Blocker

One thing, unchanged in kind from `SESSION_185` §8, narrower in scope
now that §C1's code exists: **QF `client_id`/`client_secret` do not
exist.** Once the owner obtains them (an action no Claude session may
perform) and provides them as `QF_CLIENT_ID`/`QF_CLIENT_SECRET`
environment variables, the manual smoke test described in
`SESSION_184` §13/§14 can run against the code already written in this
session — `token.fetch_access_token` → `client.fetch_bootstrap` — with
no further code changes required except correcting the two INFERENCE
points (§C1 #7, `client.py`'s incremental query parameter) if the real
API disagrees with this session's best-documented guess.

---

## N. Recommended Session 193

In priority order, all independent of QF credentials existing:

1. **Run the manual `prelive` smoke test**, the moment (and only the
   moment) the owner has obtained and provided QF credentials — this
   is the one item genuinely gated on external action, not on further
   planning.
2. **Land R17 (attribution string)** — `SESSION_184` §12 already
   auto-decided this should ship "independently and now," not bundled
   with the rest of the migration. It is a three-locale ARB string
   change with its own widget test, fully credential-independent,
   fully evidence-supported (S15, PRIMARY SOURCE FACT), and was
   explicitly out of *this* session's scope only because it is not
   part of the Phase 1 module list `SESSION_185` §5 defined — not
   because it depends on anything unresolved.
3. **The DR-2026-0008…0013 ratification decision** (`SESSION_185` §1) —
   still a single, short, explicit owner decision, still not executed
   by any session, still a precondition for Phase 5/6 specifically
   (not Phase 1, so it did not block this session).
4. If the owner has not yet acted on any of #1–#3, there is no
   additional credential-independent Phase 1 code left to write —
   §C1 is complete. A future session should not manufacture busywork;
   it should either wait for one of the three genuine gates above to
   move, or take up a different open item entirely (e.g. the tafsir
   licensing thread, explicitly out of scope here per `SESSION_184`
   §17).
