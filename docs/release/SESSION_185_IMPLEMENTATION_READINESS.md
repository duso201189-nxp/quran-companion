# Session 185 — Governance / Access Readiness / Architecture Ratification

**Baseline verified fresh this session (2026-09-03), not assumed from
any prior report:**

| Item | Value |
|---|---|
| `origin/main` | `63483fba8bfd8cca4c9fa2294cb6e0785b1a33eb` (PR #66 merge) |
| PR #63 | **OPEN** — `session180-qf-response-reconciliation`, head `8dd17954e86e43a6f2af28aab86ecc90d71ffa7b` |
| PR #64 | **OPEN** — `session182-qf-primary-source-evidence`, head `0214db3ec56844d43e44d95a803587e075800208` |
| PR #66 | **MERGED** 2026-09-03T03:46:39Z |
| Open PRs (full list) | Exactly #63, #64. No other open PRs found. |
| Primary worktree | `publish-docs-reconciliation-s14`, HEAD `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe`, 22-line `git status --porcelain`, 0 stashes — **re-verified unchanged before and after this session**, see final section |
| This session's worktree | `worktrees/session185-governance-access-readiness`, branched fresh from `origin/main` |

No commits, PRs, or other GitHub-visible activity attributable to a
"Session 183" or any session between 184 and 185 were found — same gap
Session 184 recorded and could not independently resolve.

---

## 1. DR-2026-0008…0013 Ratification Audit

### 1.1 Where they are

**Confirmed: `docs/adr/DR-2026-0008` through `DR-2026-0013` do not
exist anywhere in `origin/main`'s history**
(`git ls-tree -r origin/main -- docs/adr/` lists `0001`, `0003`–`0005`,
`0014`–`0030`, skipping `0002` and `0006`–`0013` entirely — a real gap
in the sequence, not a numbering artifact).

They exist **only** as uncommitted, untracked files in the primary
worktree (`?? docs/adr/DR-2026-0008-…md` … `0013-…md` in its
`git status --porcelain`), read this session with `Read` only — no
`Write`/`Edit` call was made against the primary worktree at any point,
consistent with every prior session in this chain. They are not on any
open PR (#63 and #64 concern QF evidence documents, not these DRs).
`docs/adr/README.md`, also uncommitted in the primary worktree,
already contains a fully-drafted historical-recovery narrative
explaining where these six files came from (byte-identical restorations
of blobs from commits on the never-merged `sprint1-my-library` branch)
and a table showing each one's actual implementation status on `main`
diverges from what the record itself decided. That narrative is **not
this session's own analysis** — it predates this session and was found,
not written, here.

### 1.2 Per-record findings

| DR | Title | Reversibility | Owner-approval evidence | Dependencies | Conflicts with Session 184 contract? | Classification |
|---|---|---|---|---|---|---|
| `DR-2026-0008` | Content distribution strategy | **hard** | `status: accepted`, `deciders: [duso]`, dated 2026-07-26. No `verification_records` entry (empty array in frontmatter) — never passed through this project's own EIS verification process. | Root of the series; `0009`–`0013` implement it | No — Session 184 §4(B), §5.1, R18 explicitly reuse this record's conclusion as a second, independent line of reasoning alongside QF's own request | **OWNER GATE** |
| `DR-2026-0009` | Data supply chain (data build ≠ app build) | soft | Same as above | Depends on `0008` | No — Session 184 R19–R20 explicitly reuse it | **OWNER GATE** (implements a hard-reversibility root; landing it alone, out of numeric sequence, would assert an architecture whose root decision is not itself ratified) |
| `DR-2026-0010` | Licence registry (three-valued grants) | soft | Same as above | Depends on `0008`/`0009` | No — not directly cited by Session 184's requirement set, but not contradicted either | **OWNER GATE** (same reasoning) |
| `DR-2026-0011` | Artifact versioning (three axes) | **hard** | Same as above | Depends on `0009` | No — Session 184 R11 explicitly reuses it | **OWNER GATE** |
| `DR-2026-0012` | Artifact registry (consumable-by-pin) | soft | Same as above | Depends on `0009`/`0011` | No — Session 184 R11, artifact G explicitly reuse it | **OWNER GATE** |
| `DR-2026-0013` | CI licence gate (unbypassable enforcement) | soft | Same as above | Depends on `0008`–`0012` | No — Session 184 does not need it directly, but `main`'s own `test/repository_boundary_test.dart` already cites it by name and number today | **OWNER GATE** |

None are **OBSOLETE** (all six are actively cited as live architecture
by Session 184's merged contract) or **SUPERSEDED** (nothing on `main`
proposes a replacement design for the same problem) or **UNKNOWN**
(each file is fully legible, internally consistent, and its
implementation-vs-decision gap on `main` is already documented). All
six are classified identically: **OWNER GATE.**

### 1.3 Why OWNER GATE, not AUTO-RATIFIABLE, despite clear individual
approval evidence

This session's governing brief permits proposing/preparing a ratification
PR when landing a DR "chỉ là governance/documentation ratification"
**and** owner-approval evidence is clear. The approval evidence *is*
clear (`status: accepted`, `deciders: [duso]` on every record). What
tips this to OWNER GATE anyway:

1. **Session 184 already asked this exact question and declined to
   answer it**, explicitly flagging formal ratification "for explicit
   owner blessing before a future session commits files this session
   only read" (§16 item 5 of the merged contract) — a prior, careful
   session's considered judgment, not a default this session should
   silently override.
2. **Two of six carry `reversibility: hard`** (`DR-2026-0008`,
   `DR-2026-0011`), and `DR-2026-0008` is the root the other five
   implement — landing "just the docs" is not actually low-stakes when
   the docs in question assert a hard-to-reverse architecture as this
   project's decided direction.
3. **`DR-2026-0028` (also uncommitted, also in the primary worktree)
   already answers the jurisdiction question this project asked
   itself**: a Decision Record governs `main` if and only if it is
   present on `origin/main` — "not acceptance on another branch, not
   presence in a working tree… Implementation citations are evidence
   that someone referenced a record, never evidence of its authority."
   Landing `0008`–`0013` is therefore not paperwork; it is the specific
   act `DR-2026-0028` defines as conferring authority over `main`.
4. This session's own governing brief says explicitly: **"Không tự
   commit/merge các DR chỉ vì chúng đã từng được owner chấp thuận
   trong working context"** — do not self-commit/merge DRs merely
   because they were once approved in a working context. That is
   precisely this situation.
5. **No `verification_records` exist for any of the six** (empty array
   in every frontmatter) — this project's own EIS process was never
   run against them, a procedural gap independent of the content being
   sound.

**What this session did NOT do:** open a PR containing these six files,
`docs/adr/README.md`'s pending changes, `RELEASE_CHECKLIST.md`'s
pending changes, or any other primary-worktree-only content. All of
that stays exactly where it is — uncommitted, in the primary worktree,
untouched by this session.

### 1.4 What ratification would look like, if/when approved

So a future session does not have to re-derive this: the primary
worktree already holds a coherent, ready-to-commit change —
`docs/adr/DR-2026-0006` through `0013`, the already-updated
`docs/adr/README.md` (which documents provenance and the `main`
divergence honestly, including the `DR-2026-0028` authority framing),
and `docs/adr/DR-2026-0028`–`0030`. A ratification PR would most
naturally commit that set together (it is one coherent governance
change, not six independent ones — `0028` is what makes the other
records' status on `main` legible at all) with a message that states
plainly these are historical records restored byte-for-byte, accepted
in the past on a branch never merged, not decisions made or re-approved
today. **This session recommends the owner make that one decision —
"yes, land the restored DR series onto `main`" — as a single,
short, explicit confirmation**, separately from any QF-specific
timeline, because `SESSION_184_...REQUIREMENT_CONTRACT.md` Phase 6
already depends on `DR-2026-0009`'s architecture existing on `main`
before that phase can execute.

---

## 2. QF Access Readiness

Independently re-verified this session against QF's own published
documentation (not merely re-quoted from Session 184):

| Item | Value | Source |
|---|---|---|
| Resource | `word_by_word_transliterations`, ID `60` | Primary source (QF email S3) + official snapshot endpoint, both confirm |
| Credential model | OAuth2 `client_credentials` grant, scope `content` | `api-docs.quran.foundation/docs/quickstart` (fetched this session) |
| Token endpoint | `/oauth2/token` off `prelive-oauth2.quran.foundation` (pre-live) or `oauth2.quran.foundation` (production) | Same |
| Access token lifetime | 3600 seconds; no refresh tokens — must be re-requested before expiry | Same |
| Client type | **"Backend/server app"** only; "Keep `client_secret` on the server only" | Same, verbatim |
| Environment separation | Pre-live and production are fully separate auth hosts and API hosts; **"New apps begin in pre-live… move to production only after production permissions are approved"** | Same, verbatim |
| Credential/account creation | Via QF's **Developer Console**, `https://dev-console.quran.foundation/projects` — "Create and manage credentials, environments, and permission requests" there | Same |
| Rotation | Not documented by QF for API credentials specifically (access tokens self-expire hourly by design; `client_id`/`client_secret` rotation cadence not stated — carried forward as UNKNOWN, matching Session 184 §18) | — |
| CI usage | Consistent with a scheduled, credential-holding pipeline job (§6 of this document) | — |
| Local development | Same pre-live credentials as CI, scoped separately if the owner chooses (QF does not require a distinct "local" credential class) | — |
| Production/release usage | Requires a separate, later "production permissions" approval step per QF's own stated flow | `api-docs.quran.foundation/docs/quickstart`, verbatim |
| Caching ceiling | 1 week generally; Content Sync users may retain indefinitely provided a sync runs at least every 7 days | `api-docs.quran.foundation/legal/developer-terms/`, verbatim (independently re-fetched this session) |
| Redistribution restriction | QF Content and raw API data "are not sold, sublicensed, or redistributed" without a separate signed commercial license | Same, verbatim |

**Confirmed NOT done, and not attempted, this session:** no account
created, no credential requested, no application submitted, no email
sent, no secret committed anywhere. `gh secret list` / `gh variable
list` on this repository (checked this session, read-only) show no
QF-related secret or variable of any kind — only the pre-existing,
unrelated R2 private-storage credentials (§4 below).

## 3. Existing infrastructure this project already has that Phase 1/5
would reuse (found this session — corrects a stale claim)

`docs/adr/README.md`'s own (uncommitted) recovery narrative states
`DR-2026-0009`'s implementation on `main` is "Absent… No private
storage, no content credentials." **That claim is now stale.**
Verified this session:

- Commit `284fc7a` ("ci: add read-only dataset storage verification
  workflow"), merged to `main` 2026-08-21 — **before** Session 184's
  own baseline — added `.github/workflows/dataset-verification.yml`,
  a **scheduled** (daily, `cron: '17 5 * * *'`), read-only workflow
  that authenticates to a live Cloudflare R2 bucket.
- `gh secret list` (this session, read-only) confirms **four** live
  GitHub secrets: `R2_READ_ACCESS_KEY_ID`, `R2_READ_SECRET_ACCESS_KEY`,
  `R2_PUBLISH_ACCESS_KEY_ID`, `R2_PUBLISH_SECRET_ACCESS_KEY` — all
  created 2026-07-26, the same date as the DR-2026-0008…0013 series.
  `gh variable list` confirms `R2_BUCKET=quran-companion-data` and a
  live `R2_S3_ENDPOINT`.
- `gh run list` confirms this workflow has run successfully, daily,
  every day from at least 2026-08-29 through 2026-09-02 (the days
  checked) — a live, working, unattended system, not a stub.
- The workflow's own comments confirm the **write-capable** credential
  (`R2_PUBLISH_*`) is provisioned but **deliberately unused**: "no
  Publisher write has occurred yet — `DR-2026-0014` remains Proposed
  and the Publisher credential is documented as stored but unused."
- `docs/PRIVATE_STORAGE.md` (on `main`) — the provisioning runbook
  this bucket followed — separates read (`qc-ci-read`) and
  write (`qc-publisher`) tokens by design, matching `DR-2026-0009`
  decision D ("two secret classes, never mixed") even though that
  record itself is not on `main`.
- `.github/workflows/ci.yml` (the regular per-push/PR pipeline) still
  builds `assets/database/quran.sqlite` in-place via
  `python3 tool/build_quran_db.py` when the committed file (or its
  cache) is absent — it does **not** yet fetch anything from R2. This
  is `IMPLEMENTATION_PROGRAM.md`'s Stream C3 ("CI fetch step,
  additive") — **not started**.
- No Python dependency-lock file (`requirements.txt`, `pyproject.toml`,
  `Pipfile`) exists anywhere in `tool/` or the repository root —
  resolves one of Session 184's §18 open unknowns from "not checked"
  to "confirmed absent."

**Why this matters for Phase 1/5:** the hardest part of
`SESSION_184_...REQUIREMENT_CONTRACT.md`'s recommended architecture —
a private, credentialed, scheduled artifact-storage system with a
read/write credential split — is **already built, provisioned, and
running in production** on `main`, for a *different* purpose today
(generic dataset/artifact storage verification), but directly reusable
for QF's word-by-word transliteration artifact without inventing new
storage infrastructure. What remains net-new for the QF-specific path
is: (a) QF's own OAuth credentials (Owner Gate, distinct from the R2
credentials above), (b) the Content-Sync-aware fetch code itself
(Phase 1), and (c) wiring a publish step into this existing bucket
(Phase 5) — not a new storage system.

---

## 4. Implementation Readiness Audit

`PASS` = verified working/present this session. `BLOCKED` = a specific,
named external dependency stands in the way. `UNKNOWN` = not
established by anything found; carried forward rather than guessed.

### SOURCE
- [x] **PASS** — resource 60 confirmed (`word_by_word_transliterations`, PRIMARY SOURCE FACT, cross-confirmed against QF's snapshot endpoint reference)
- [x] **PASS** — official endpoint documented (`GET /resources/sync`, `GET /resources/snapshots/word_by_word_transliterations/60`, independently re-fetched this session)
- [x] **PASS** — auth model documented (OAuth2 client_credentials, `content` scope, backend-only, independently re-fetched this session)
- [ ] **BLOCKED** — credential ownership defined *in principle* (must be the owner, per QF's own backend-only requirement and this project's own tool-use rules) but *not yet created* — blocked on owner action (§6)

### SECURITY
- [x] **PASS** — secret-never-enters-git discipline already proven in production for a structurally identical case (R2 tokens, §3) — the same pattern applies directly to QF's `client_secret`
- [x] **PASS** — CI secret strategy defined and operating (`docs/PRIVATE_STORAGE.md` §5–7; GitHub environment secrets; read/write split) — QF credentials would follow the same pattern as a new secret pair, not a new strategy
- [ ] **UNKNOWN** — rotation strategy defined *for QF credentials specifically*: R2's is documented ("rotated annually"); QF's own documentation states nothing about `client_id`/`client_secret` rotation cadence (§2) — carried forward, not resolved
- [x] **PASS** — environment separation defined: QF's own pre-live/production split is a stricter, QF-mandated version of the same discipline this project already applies to R2 read/write credentials

### SYNC
- [x] **PASS** — snapshot contract fully specified (§3.1 of the Session 184 contract; independently re-confirmed this session)
- [x] **PASS** — incremental contract fully specified, including the exact "persist `next_sync_token` only from the final page" ordering rule
- [x] **PASS** — sync token handling requirement fully specified (R05)
- [x] **PASS** — retry contract specified (R07) against QF's documented error taxonomy (400/401/403/404/422/429/5xx)
- [x] **PASS** — atomicity requirement specified (R09), reusing this project's existing, already-proven `DATA_VERSION` atomic-swap mechanism
- [x] **PASS** — stale-state handling specified (R12/R14, full state machine in the Session 184 contract §7)
- [x] **PASS** — corruption-recovery requirement specified (R10), reusing this project's existing "truncated and tampered are the same defect" principle
- **None of SYNC is implemented in code yet** — all items above are PASS at the *specification* level (a contract exists and is sound), not the *code* level. No SYNC item is BLOCKED; nothing here depends on anything not already available except QF credentials to test against.

### STORAGE
- [x] **PASS** — raw/original boundary specified (R15) — not yet implemented in `tool/build_quran_db.py`'s schema
- [x] **PASS** — normalized presentation boundary specified (R16), with an existing partial code seam already identified (`TransliterationRepository.normalize()`)
- [x] **PASS** — local (on-device) storage requirement unchanged from today's proven pattern (R13)
- [ ] **BLOCKED** — DB migration (the raw/normalized schema split, Phase 3) is explicitly gated by this project's own standing rule (`CLAUDE.md`, `PROJ-P-002`): "stop and ask before any schema change" — this is a **pre-existing project governance gate**, independent of QF, and applies the moment Phase 3 begins
- [x] **PASS** — public-repository boundary: infrastructure to keep new artifacts out of git already exists and runs today (§3); only the QF-specific artifact itself doesn't flow through it yet

### PLATFORM
- [x] **PASS** — Android: no new platform code needed under the recommended (Option B, build-time-only) architecture; offline reading path unchanged
- [x] **PASS** — iOS: same; additionally, `BGTaskScheduler`'s unreliability is exactly why Option B avoids depending on iOS background execution at all
- [x] **PASS** — Web: same; existing IndexedDB/Drift-WASM offline stack unaffected
- [ ] **BLOCKED** — CI: the *scheduled data-pipeline workflow* itself (Phase 5) does not exist yet; blocked on Phase 1–4 completing first (internal sequencing, not an external blocker) and, before Phase 1 can produce real output, on QF credentials existing (external, Owner Gate)

### VALIDATION
- [x] **PASS** — fixture/test strategy specified (R24), reusing this project's existing four-test suite for this domain (`transliteration_test.dart`, `transliteration_standard_test.dart`, `repository_boundary_test.dart`, `repository_boundary_completeness_test.dart`)
- [x] **PASS** — deterministic-test requirement specified (R20) — no live QF dependency in per-push/PR CI under the recommended architecture
- [x] **PASS** — provenance requirement specified (artifact records, reusing `DR-2026-0011`/`0012`'s design — noting §1's Owner Gate on formally landing those records)
- [x] **PASS** — release-verification requirement specified (R29, four sub-conditions, explicitly not self-closing)
- [x] **PASS** — rollback specified per phase (R27, §15 of the Session 184 contract) — no tier requires a force-push or history rewrite

### GOVERNANCE
- [x] **PASS** — attribution requirement fully specified, exact string/link/placement known (R17, §8 of this document)
- [ ] **BLOCKED** — counsel review: packet is drafted (`SESSION_185_QF_COUNSEL_ROUTING_PACKET.md`) but not sent — Owner Gate
- [ ] **BLOCKED** — owner gates generally: see §5 below — several distinct items, all genuinely owner-only
- [ ] **BLOCKED** — DR ratification: see §1 — classified OWNER GATE, not executed this session

---

## 5. Phase 1 — Exact Scope

**Phase 1 only. Not Phase 2 onward. Not a full app migration.**
Reusing and not re-deriving Session 184's own Phase 1 definition
(`SESSION_184_...REQUIREMENT_CONTRACT.md` §13), sharpened where this
session found more precise infrastructure:

**Name:** Source Adapter — Controlled Content Sync Acquisition (isolated).

**Input:** QF `client_id`/`client_secret` (pre-live), provided by the
owner via a CI environment secret — **Phase 1 cannot begin without
this; it is the phase's sole hard external dependency.**

**Output:** A working, isolated fetch capability that performs one full
bootstrap against `word_by_word_transliterations:60` on QF's `prelive`
environment and reproduces the legacy path's known-good coverage
(6,236 ayahs), writing its result to a **raw, unnormalized** local file
— explicitly not yet wired into `build_quran_db.py`, not yet touching
the committed database, not yet touching any schema.

**Modules:**
- New: `tool/fetch_transliteration_contentsync.py` (or equivalent),
  using the official `quran-foundation-api` PyPI SDK rather than
  hand-rolling the bootstrap/incremental protocol (per Session 184
  §3.1's finding that this SDK exists and ships a `sync_resources()`
  helper).
- New: a `requirements.txt` (or `pyproject.toml`) for `tool/`, since
  none exists today (§3) — a small, additive, in-scope prerequisite of
  adding any new Python dependency at all, not a separate phase.
- Unchanged: `tool/build_quran_db.py`, `tool/fetch_transliteration.py`
  (legacy path kept, untouched, as the rollback margin, per Session
  184's migration sequencing — deleted only after Phase 1's output is
  proven).

**Interfaces:** One function/script boundary: given credentials (read
from environment, never from a file committed to git) and the fixed
resource identity (`word_by_word_transliterations`, `60`), produce a
raw JSON structure distinct in shape from today's normalized
`transliteration.json` (carries `word_id`, `language_id`, `text`,
`updated_at` per QF's own snapshot schema, not just a bare string).

**Security boundary:** credentials read from environment variables
only; never logged; never written to any file under `tool/data/`
(which is git-tracked). Phase 1's own test run happens locally/in a
throwaway CI job with a scoped pre-live-only secret — reusing the
credential-hygiene pattern already proven for R2 (§3), not inventing a
new one.

**Test boundary:** a unit/integration test that mocks QF's HTTP
responses to verify bootstrap-ordering (R03: every `snapshot_url`
fetched and applied before any token is considered "ready"); a
separate, manual, credential-gated smoke test against real `prelive`
(not part of the automated suite, since it needs a real secret) that
confirms real-world coverage matches the legacy path's 6,236 ayahs.

**CI boundary:** **none of Phase 1 touches the existing 5-job
per-push/PR pipeline** (R20) — Phase 1's own verification is a new,
separate, manually-triggered or narrowly-scoped job, not an addition
to `ci.yml`'s existing jobs. Phase 5, not Phase 1, is where a
*scheduled* workflow is introduced.

**Artifacts:** one new raw JSON file, written to a local/CI working
directory, **not committed to git**, not yet published to the existing
R2 bucket (that publish step is Phase 5, once Phase 1–4 are proven
end-to-end).

**Acceptance criteria:** a successful bootstrap fetch against `prelive`
reproduces 6,236 ayahs' worth of coverage; the raw output is
demonstrably unnormalized (no `ALLAH_MAP`/`standardize_token` applied);
no credential appears in any committed file, log, or test fixture.

**Rollback:** delete the new file(s); zero risk to the existing,
untouched legacy pipeline.

**What Phase 1 explicitly does NOT do:** touch the database schema
(Phase 3, itself gated by `PROJ-P-002`); touch `build_quran_db.py`'s
call graph; add any scheduled CI workflow; remove the legacy fetch
path; touch any Android/iOS/Web code; touch attribution strings
(R17 is recommended to land independently and in parallel, per Session
184 §12, but is not itself part of Phase 1's own dependency chain);
require any DR to be ratified onto `main` first (Phase 1 needs only
the QF credential, not the storage architecture — Phase 5 is where the
`DR-2026-0009`/`0011`/`0012` ratification question in §1 becomes
load-bearing).

---

## 6. Owner Gates — the real ones

Consolidated from this document's own findings and Session 184's §16,
re-confirmed rather than merely repeated:

1. **QF developer account + `client_id`/`client_secret` creation**
   (§2, §5's hard input dependency) — an account-creation action no
   Claude session may perform, per this session's own standing
   tool-use rules.
2. **Sending the QF access application** (§ of
   `SESSION_185_QF_DEVELOPER_ACCESS_APPLICATION_DRAFT.md`) — drafted,
   not submitted.
3. **Routing the counsel packet** (§ of
   `SESSION_185_QF_COUNSEL_ROUTING_PACKET.md`) — drafted, not sent.
4. **Ratifying `DR-2026-0008`…`0013` (and `0028`) onto `main`** — §1
   above; a single explicit "yes, land the restored series" decision
   would unblock this without re-litigating each record individually.
5. **Beginning Phase 1 implementation itself** (timing/resourcing) —
   separate from, and downstream of, gate 1.
6. **`P2-2` closure** — release-gate sign-off; owner + counsel only,
   never a session decision.
7. **Any Git-history question** — not raised by this document, exactly
   as no prior session in this chain has raised it either (§L of the
   counsel packet).

## 7. Technical decisions this session made unilaterally (within
standing delegation, not re-litigated as owner questions)

- **Confirmed, not re-decided:** Session 184's Option B (build-time-
  only acquisition) recommendation stands; this session found
  additional supporting evidence (the already-running R2 storage
  infrastructure, §3) that *strengthens* Option B's case (a working
  private-storage system already exists to build on) rather than
  weakening it.
- **New this session:** the DR ratification question (§1) is answered
  as **one bundled decision** (land `0006`–`0013` and `0028`–`0030`
  together, since `0028` is what makes the others' status legible),
  not six separate approvals — this session judged that splitting it
  would create more governance overhead than the actual risk
  (individually reviewed, internally consistent records, none in
  tension with each other) justifies. The owner can still decline this
  bundling and ask for a narrower first landing (e.g., `0008`+`0028`
  only) — that is the owner's call, not pre-empted here.
- **New this session:** Phase 1's dependency-lock gap (`requirements.txt`
  absence) is scoped as part of Phase 1 itself rather than a
  prerequisite phase of its own — it is a few lines of config, not
  architecture.
- **New this session:** the existing R2 dataset-verification
  infrastructure (§3) is recommended for direct reuse by Phase 5,
  rather than provisioning a second, QF-specific storage system — same
  bucket, a new prefix/manifest entry, following `DR-2026-0012`'s
  existing "one registry, possibly several artifacts" design.

---

## 8. What exactly blocks Phase 1

**One thing, and only one thing, blocks Phase 1 from starting today:**
QF `client_id`/`client_secret` do not exist yet, and creating them is
an action no Claude session may take. Every other precondition this
audit checked — the technical contract, the SDK choice, the storage
architecture to eventually publish into, the CI hygiene pattern to
follow, the test strategy — is already specified, verified, or (in the
case of storage) already running in production. Once the owner
completes gate 1 (§6) and provides a pre-live credential pair via a CI
secret, Phase 1 as scoped in §5 has no other known blocker.

---

## Primary Worktree Safety

| Check | Before this session | After this session |
|---|---|---|
| Path | `C:\Users\Admin\Desktop\quran_companion_v0.6.0\quran_companion` | unchanged |
| Branch | `publish-docs-reconciliation-s14` | unchanged |
| HEAD | `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe` | unchanged |
| `git status --porcelain` | 22 lines | 22 lines (byte-identical, `diff`-checked) |
| Stash count | 0 | 0 |

All work this session occurred in
`worktrees/session185-governance-access-readiness`, branched fresh from
`origin/main`. `DR-2026-0008`…`DR-2026-0013`, `docs/adr/README.md`,
`docs/adr/DR-2026-0028`, `IMPLEMENTATION_PROGRAM.md`,
`docs/PRIVATE_STORAGE.md`, and `.github/workflows/dataset-verification.yml`
were **read only** (`Read`/`Grep`/`Bash git show` — no `Edit`/`Write`
against the primary worktree, ever, this session). `gh secret list`
and `gh variable list` were read-only inspections of already-existing
CI configuration, not modifications.
