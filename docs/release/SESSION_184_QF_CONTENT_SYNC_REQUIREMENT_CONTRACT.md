# Session 184 — QF Content Sync: Requirement Contract & Architecture/Implementation Plan

**Baseline:** `origin/main` at `4cd08a1fb7002e6d14f8f8caddf333fb10b77390`
("Merge pull request #65 from …session182-qf-content-sync-owner-decision")
**Prepared:** 2026-09-03
**Scope:** **Planning only.** Produces a Requirement Contract and
Architecture/Implementation Plan for remediating `P2-2` (the Latin
word-by-word transliteration licensing gap) via a Quran Foundation
("QF") Content Sync migration. **No code, data, database, ADR/DR,
`docs/LICENSING.md` entry, or governance record is changed by this
document. No implementation happens in this session.**

> This document draws no legal conclusion, grants no clearance, closes
> nothing, and does not merge PR #63 or PR #64. It builds on — and does
> not re-litigate — the evidence and decision matrix already produced
> by Sessions 164–182 and merged to `main` via PR #65
> (`SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md`). Where this
> document's own findings sharpen, extend, or correct something in that
> chain, it says so explicitly rather than silently.

---

## 1. Executive Decision

This session does **not** decide whether to implement the Content Sync
migration — that authorization already sits with the owner as **D1** in
the merged `SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md`. What this
session *does* decide, using the technical-direction authority the
owner has delegated (see the governing brief's Part 10 preamble), is
**what the migration would look like if authorized** — a complete
requirement contract, target architecture, and phased implementation
plan, so that a future "go" decision does not have to start from zero.

**Headline technical recommendation (auto-decided, not owner-gated):**
**Option B — build-time-only Content Sync acquisition**, reusing the
already-designed (but unmerged) `DR-2026-0008`…`DR-2026-0012` private-
storage / tiered-CI / artifact-versioning architecture, with the app
itself never talking to `apis.quran.foundation` at runtime. Full
rationale in §11–§12. This is a technical judgment call within the
owner's standing delegation, not a request for a new decision.

**What remains genuinely owner-gated** (§16): starting implementation
at all (resourcing/timing); personally obtaining Quran Foundation API
developer credentials (this is an **account-creation action** that
falls under this session's own standing tool-use safety rules — no
Claude session may do this on the owner's behalf); routing this
evidence to counsel; the Git-history question (explicitly **not**
raised by this document, consistent with every prior session); and
formally ratifying `DR-2026-0008`…`DR-2026-0013` onto `main` (they are
individually marked `status: accepted` by the owner already, but were
never committed anywhere — see §2 discrepancy D3).

`P2-2` remains **OPEN**. This document does not change that.

---

## 2. Verified Baseline

Verified fresh this session (`git fetch origin`, `gh pr list/view`,
direct reads), not assumed from prior session reports.

| Item | Value |
|---|---|
| `origin/main` HEAD | `4cd08a1fb7002e6d14f8f8caddf333fb10b77390` — the PR #65 merge commit |
| Prior baseline (Session 182, PR #65's own record) | `ad947bc9ee40fb935240a1c46ce0627d546815d2` — i.e. `main` has moved exactly one merge (#65) since Session 182 |
| **PR #65** | **MERGED** 2026-09-03T03:02:10Z. Adds `docs/release/SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md` (466 lines). All 5 CI checks pass. |
| **PR #64** | **OPEN**, unmerged. Adds `docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` (769 lines, the actual QF email transcription, S1–S15). Not an ancestor of `origin/main`. |
| **PR #63** | **OPEN**, unmerged. Adds `docs/release/SESSION_180_QF_RESPONSE_RECONCILIATION.md` (superseded in fact-finding terms by PR #64, but still open in its own right). |
| New commits/PRs since Session 183 | None found beyond PR #65's merge itself (`gh pr list --search "session183"` → empty; no session183 worktree exists on disk). This session could not independently verify what, if anything, "Session 183" did — see discrepancy D1 below. |
| Primary worktree (`…/quran_companion`) | Branch `publish-docs-reconciliation-s14`, HEAD `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe`, 22 lines of pre-existing uncommitted changes, 0 stashes — **re-verified unchanged both before and after this session's work** (§"Primary Worktree Safety" at the end of this document). |
| This session's worktree | `worktrees/session184-qf-content-sync-requirement-contract`, branch `session184-qf-content-sync-requirement-contract`, created fresh from `origin/main` at `4cd08a1f`. |

### Discrepancies found (recorded, not corrected — per this session's governing rules)

**D1 — "Session 183" is not independently verifiable.** The governing
brief states Session 183 "đã hoàn tất trước session này." This session
found no commit, branch, worktree, or PR attributable to a "Session
183" anywhere in the repository or on GitHub. `origin/main`'s only
change since the Session 182 baseline is the PR #65 merge itself
(authored by "Session 182" per its own commit message). This is
recorded as a gap, not silently assumed away: whatever Session 183 was,
it left no artifact this session could locate or verify.

**D2 — the evidence is not "in `main`" the way the brief assumes.**
The brief frames this session's task as building on "bằng chứng QF đã
được SESSION 182 đưa vào main qua PR #65." As found: **PR #65 is the
decision/reconciliation document, not the evidence document.** The
primary-source evidence itself (`SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`,
the S1–S15 quoted clauses) lives only on the **still-open, unmerged**
PR #64. PR #65 extensively quotes and independently re-verifies PR
#64's repository-fact claims, and is itself merged — so the evidence
*is* available and *is* trustworthy (this session re-read PR #64
directly via `git show origin/session182-qf-primary-source-evidence:…`,
a read-only operation, and cross-checked its repository-fact claims
independently — see §3) — but it is not, today, part of `main`'s
committed history. This document treats PR #64's content as read
evidence, exactly as PR #65 did, and flags this distinction rather than
overstating what is "on `main`."

**D3 — the CI gate's own cited governance does not exist on `main`.**
`test/repository_boundary_test.dart` (which **is** on `main`) opens
with "CỔNG RANH GIỚI KHO MÃ — `DR-2026-0013` giai đoạn B1/B2" and
grandfathers `assets/database/quran.sqlite` with the note "thôi theo
dõi ở giai đoạn D1 — DR-2026-0008 nước đi B." **`DR-2026-0008` through
`DR-2026-0013` do not exist anywhere in `origin/main`'s git history**
(`git ls-tree -r origin/main -- docs/adr/` — confirmed absent). They
exist only as **uncommitted files** in the primary worktree (visible in
its `git status --porcelain` as `?? docs/adr/DR-2026-0008-…md` etc.),
each individually marked `status: accepted`, `deciders: [duso]`,
dated 2026-07-26. This session read them directly (read-only, no edit)
because they turned out to be directly relevant to this contract's
target architecture (§4, §7, §10) — but their status is: **owner-
decided in content, never committed, never merged, never ratified onto
`main`.** This is a real governance gap, independent of QF/P2-2, and is
flagged as an Owner Gate item (§16), not fixed here.

**D4 — `docs/DATA_PIPELINE.md` misstates the current repository state.**
Line 6 reads: "File `assets/database/quran.sqlite` là SẢN PHẨM BUILD
(không commit vào git; CI tự build và cache)" — i.e., the document
claims the database is *not* committed to git. Verified this session:
it **is** committed and tracked (`git ls-files assets/database/` →
`assets/database/quran.sqlite`; `git log --oneline -- assets/database/quran.sqlite`
→ 3 commits; size 19,955,712 bytes on disk). This is a stale claim —
almost certainly describing the *target* state `DR-2026-0009` (D3
above) designs, not the actual current state — left uncorrected here
per this session's "record, don't fix" rule.

No other discrepancies of this magnitude were found. `RELEASE_DASHBOARD.md`
and `docs/release/V1_STORE_LEGAL_READINESS.md` both consistently track
`P2-2` **OPEN**, matching PR #65.

---

## 3. Evidence Classification

Every factual claim used in this document is tagged. The tags carry
through §4–§13; this section defines them once.

| Tag | Meaning | Sources used this session |
|---|---|---|
| **PRIMARY SOURCE FACT** | A direct quotation of, or an unambiguous technical fact stated by, the QF email (PR #64 §5–§6, "S1"–"S15") or Quran Foundation's own official documentation at `api-docs.quran.foundation` | QF email (via PR #64); `api-docs.quran.foundation/docs/tutorials/content-sync/getting-started/`; `.../content_apis_versioned/4.0.0/resources-snapshot/`; `.../legal/developer-terms/` |
| **SECONDARY SOURCE** | A search-engine-synthesized summary of official documentation, not independently re-fetched and verbatim-quoted this session | `WebSearch` result on OAuth2/client-credentials flow, cross-referencing `api-docs.quran.foundation/docs/quickstart/` and related pages (titles resolved, content not independently re-fetched page-by-page) |
| **INFERENCE** | A reasonable reading not itself stated by any source | Explicitly marked inline every time it is used |
| **REPO FACT** | Independently verified this session by reading code, tests, or documents in this repository (including the unmerged `DR-2026-0008`…`0013` in the primary worktree, and PR #64/#63's unmerged branches) | direct `Read`/`Grep`/`git show` this session |
| **UNKNOWN** | Not established by anything found this session | Explicitly marked inline every time it is used |

**This document does not treat technical documentation as a legal
conclusion anywhere.** Where QF's Developer Terms or Content Sync docs
use words like "permitted," "must," or "required," §6 and §4 report
what the source says — never this document's own legal verdict on
whether that satisfies `P2-2`.

### 3.1 Primary-source facts newly gathered this session (beyond PR #64)

Fetched directly from `api-docs.quran.foundation` this session
(PRIMARY SOURCE FACT unless marked otherwise) — these **materially
narrow** several items PR #64 §19 left "STILL UNKNOWN":

- **Bootstrap flow.** `GET /resources/sync?bootstrap=true&resources=<group>:<id>` returns `RESOURCE_CREATE` changes, each carrying a `snapshot_url`. The client must fetch and apply **every** `snapshot_url` before storing the returned `sync_token`. ("Apps must fetch all snapshot URLs and replace local rows before storing the sync token.")
- **Incremental flow.** Subsequent calls send the stored `sync_token`; the API returns only changes with a higher sequence number than the token represents. Response carries `next_sync_token`, `has_more`, `next_page_url`, `sync_until_sequence`. **"Store `next_sync_token` only from the final page."** Mutations must be applied in ascending `sequence` order.
- **Authentication.** Every Content API request requires two headers: `x-auth-token` (an OAuth2 access token) and `x-client-id`. Tokens are obtained via an OAuth2 **client_credentials** grant (`content` scope) against a token endpoint (`prelive-oauth2.quran.foundation` or the production equivalent), using a `client_id`/`client_secret` pair issued after a **"Request Access"** application — SECONDARY SOURCE for the exact application/approval process, but PRIMARY SOURCE FACT that the flow is client-credentials, not a per-user OAuth flow, and that **"Keep client_secret on the server only"** is the documentation's own guidance (SECONDARY SOURCE, `WebSearch` synthesis of the quickstart page).
- **Snapshot endpoint specifics.** `GET /resources/snapshots/{resource_group}/{resource_id}` — confirmed to match exactly the URL S3 quotes for resource 60. Returns the *complete* current record set for that resource (no pagination). Response is explicitly **`Cache-Control: no-store`** — not cacheable. `sync_sequence` in a snapshot response is a point-in-time marker, "not tied to a specific sync sequence" for resuming incremental sync — i.e., **the `sync_token`, not the snapshot response, is what must be retained to resume incrementally** (confirms and sharpens S7's "retain the sync token").
- **Documented error taxonomy.** `400` invalid request; `401` unauthorized; `403` forbidden ("expired token or insufficient permissions"); `404` "resource snapshot is unavailable or not public"; `422` unsupported resource group; `429` rate limit exceeded; `5xx` server errors. None of this appears in the QF email itself — it comes only from the official API reference.
- **Developer Terms, independently re-confirmed (not just quoted secondhand from the email):** the 1-week cache/store ceiling and its Content Sync exception both exist as **standing, general terms**, not something invented for this project's email reply — cross-confirms PR #64 §14's finding that S7 is a real, independent requirement rather than an inference from the caching clause.
- **Official Python SDK.** `quran-foundation-api` on PyPI (the email cites `0.3.0`; this session found `0.3.1` current — ordinary version drift, not a discrepancy worth flagging further) ships a `sync_resources()` helper implementing the bootstrap/incremental flow — SECONDARY SOURCE (WebSearch synthesis), but directly relevant to Implementation Phase 1 (§13): the pipeline does not need to hand-roll the sync protocol.

**What is still genuinely UNKNOWN after this session's research**
(carried forward, not resolved): numeric rate-limit thresholds behind
the `429` class; the "Request Access" approval turnaround time;
whether `prelive` access is a mandatory precursor to `production`
access; token expiry/rotation cadence for the access token itself (as
opposed to the sync token). All flagged again in §18.

---

## 4. Assumption Challenge

Ten assumptions named in the governing brief, each verdict-first.

### A. "Chỉ cần thay endpoint cũ bằng Content Sync là đủ."
**FALSE.** Evidence: S7 alone bundles at least four independent
obligations (replace snapshot, retain token, resync ≥7 days, QF remains
source of truth); S11 (remove raw file from public repo), S12–S13
(presentation-layer boundary), S15 (attribution), S14 (contact before
derivative distribution) are each *separate* conditions an endpoint
swap does nothing to satisfy. **Consequence:** scope spans data
pipeline, storage architecture, secret management, scheduling, UI
localization, and repository hygiene — not a single-file change.

### B. "Có thể tiếp tục build một SQLite hoàn chỉnh và commit raw transliteration dataset vào public repository."
**FALSE**, on two independent grounds. QF: S11 explicitly instructs
removal before release. Independently, and predating QF's own
request: `DR-2026-0008` (REPO FACT, §2 D3) already reached the
identical conclusion for general copyright reasons ("No third-party
licensed content is committed to a public repository"). **Architectural
implication:** the target architecture should reuse the already-
designed private-storage pattern rather than build a second, competing
one (§7, §10).

### C. "Offline-first hiện tại có thể giữ nguyên mà không cần thay đổi data lifecycle."
**PARTIALLY TRUE.** Offline-first as a *reading UX* survives intact —
QF explicitly permits "a local database used internally by the
installed application" (S8), and this document's R13 makes offline
reading a hard requirement regardless of sync state. What does **not**
survive is offline-first as *"fetch once at build time, never revisit"*
— QF conditions indefinite local storage on an *ongoing* sync
obligation (S2, S6, S7). **Implication:** UX is unaffected; the data
*lifecycle* behind it gains states it never had (§6).

### D. "Normalization hiện tại có thể tiếp tục nằm trong canonical/original dataset."
**FALSE.** S12–S13 explicitly require normalization to be a *separate
presentation layer*, never represented as original QF content. REPO
FACT: `tool/fetch_transliteration.py`'s `ALLAH_MAP`, `standardize_token`,
`normalize_words` (lines 64–183) all run **before** the single value is
written to `tool/data/transliteration.json` — there is no raw layer
left afterward. This is a structural gap independent of any legal
conclusion. **Implication:** a two-layer data model is required (§4.4,
R15/R16).

### E. "Có thể scheduler sync mỗi 7 ngày bằng app runtime mà không ảnh hưởng release architecture."
**FALSE — the single most consequential correction in this document.**
Two independent, newly-gathered technical facts drive this: (1) Content
Sync auth is OAuth2 client-credentials with a `client_secret` that
official guidance says to keep server-side only (§3.1) — embedding it
in a shipped Android/iOS/Web client is a secret-extraction risk with no
safe mitigation short of a server-side proxy; (2) reliable ≤7-day
*background* execution is not guaranteed on any of the app's three
client platforms (iOS `BGTaskScheduler` is opportunistic/OS-throttled;
Web has no background execution without Service-Worker+Push
infrastructure this app does not have; Android's story is unverified —
UNKNOWN, §18 — but not something to assume works either). **A naive
in-app timer would both leak a secret and be unreliable.** This finding
drives the Option B recommendation in §11.

### F. "Có thể giữ nguyên database artifact hiện tại rồi chỉ thêm sync phía trên."
**FALSE.** REPO FACT: `tool/data/transliteration.json`'s schema is
`{"ayahs": {key: <single normalized string>}}` — one value, no raw
layer, no provenance/sequence/token field. Bolting a sync mechanism on
top without a schema change gives S12–S13's raw/normalized separation
nowhere to live and gives the sync token nowhere to persist (R05, R11).

### G. "Gỡ quran.sqlite khỏi repository trong commit tương lai là đủ cho mọi requirement."
**FALSE.** Removing the tracked file in a future commit (history
untouched) satisfies only the literal, forward-looking reading of S11
— it does nothing for R01–R09 (the sync mechanism itself), R16
(presentation boundary), or R17 (attribution). It is one necessary
component of a much larger set, not a substitute for it — and even
that one component leaves the git-history-retrievability question
explicitly unresolved (D16 in the merged owner-decision document;
untouched here too, §16).

### H. "Content Sync migration không ảnh hưởng tests/reproducibility/CI."
**FALSE.** REPO FACT: `test/repository_boundary_test.dart`'s
`_grandfathered` exemption map names `assets/database/quran.sqlite` and
both `transliteration*.json` paths by exact path; its own design
("danh sách tự co lại" — the list is meant to shrink) requires those
entries to be deleted in the *same* change that stops tracking the
files, or a companion test (`'mọi mục miễn trừ đều CÒN được theo dõi'`)
goes red by design. Separately, wiring a live Content Sync call into
the app's regular per-push CI build (rather than a separate, deliberate
data pipeline) would reintroduce exactly the build non-determinism
`DR-2026-0009` already diagnosed and rejected for the *existing* live
upstream fetches (§4.3.3, R20).

### I. "Có thể ship app store mà không cần xác định rõ lifecycle của locally cached QF content."
**FALSE.** D17 (merged, PR #65) already treats `P2-2` as a release
blocker; the QF email itself is framed entirely as "before releasing
the app, please…" (S7, S11). Undefined lifecycle = shipping in the
state QF's own email describes as not-yet-compliant.

### J. "Resource 60 snapshot và incremental record có thể được xử lý mà không cần explicit state machine."
**FALSE**, and now independently confirmed by the official API's own
design (§3.1), not just architectural best practice: the bootstrap flow
is itself a two-phase protocol with a hard ordering invariant (apply
every `snapshot_url`, *then* persist the token — never the reverse),
and incremental sync requires strict ascending-sequence application
with "store `next_sync_token` only from the final page." Handling this
ad hoc, without explicit states, is exactly how a crash mid-pagination
either silently drops changes or corrupts the token. §6 designs the
state machine this finding requires.

---

## 5. Target Architecture

Requirement-level only — no code. Nine boundaries, as specified.

### 5.1 Source of truth
QF resource group `word_by_word_transliterations`, production resource
ID `60` (PRIMARY SOURCE FACT, S3). The legacy `api.qurancdn.com/api/qdc`
endpoint is retired **for this dataset** once migration completes (R01).

### 5.2 Remote acquisition
A single component (§5.6 names where it runs) responsible for: initial
bootstrap (`bootstrap=true`, apply every `snapshot_url`, then persist
token — §3.1), incremental sync (send stored token, apply pages in
ascending sequence, persist `next_sync_token` only from the final
page), retry/backoff on transient failure classes (`429`/`5xx`/network),
and explicit handling of the documented failure classes (`400/401/403/404/422`)
— detailed as R03–R08 and the state machine in §6.

### 5.3 Local storage
Three logically distinct stores (detailed as artifacts D/E/F in §7):
**(a)** sync state (token, last-applied sequence, resource identity,
timestamp) — small, mutable, private; **(b)** raw/canonical QF values
— the untouched output of applying snapshot+incremental records;
**(c)** normalized presentation values — derived, regenerable,
never the thing that overwrites (b). None of (a)–(c) may re-enter the
public git repository (R18, reusing the `DR-2026-0008` conclusion).

### 5.4 Presentation layer
Normalization (today's `ALLAH_MAP`/`standardize_token`/`normalize_words`)
is permitted **only** as a deterministic, regenerable function of the
raw layer (5.3b) into the presentation layer (5.3c) — never applied
in place, never the thing stored as "the" value. REPO FACT: a partial
seam for exactly this already exists —
`lib/features/quran/data/transliteration_repository.dart`'s
`normalize()` — currently a near-no-op safety net for legacy-format
data; this is the natural Dart-side landing point (R16), though this
session recommends computing the presentation layer at build time
(§7 artifact F) rather than per-render, for pragmatic performance
reasons — an implementation detail, not a hard requirement of the
evidence.

### 5.5 Database
`assets/database/quran.sqlite` **keeps its current runtime role**
(the on-device artifact the Flutter app reads — S8 explicitly permits
this). What changes is **how it comes to exist**: build-time generation
by a dedicated data pipeline (reusing the already-designed, unmerged
`DR-2026-0009`/`0011`/`0012` chain — versioned, checksum-verified,
privately stored, consumed by pin), not a file hand-built once and
committed forever. It **stops being newly committed to the public
repository** going forward (R18/R19) — migration sequencing in §10,
execution explicitly deferred to a future session.

### 5.6 Offline-first
See the state-by-state table in §6.9 and R12–R14. Summary invariant:
**the reading experience never depends on live sync success** (R13) —
sync state only ever affects *freshness*, never *availability*.

### 5.7 Scheduling
**Recommended (§11–§12): CI/build-time scheduling only** (a GitHub
Actions `schedule:` cron on an interval strictly under 7 days, e.g.
daily or every 3 days, to absorb a missed run without breaching the
SLA) — **not** app-open sync, **not** OS-level background execution,
for the reasons in Assumption E (§4). This is the one capability row
(§9) where every platform except CI/Build is unreliable-by-design; the
architecture is deliberately built around the row that *is* reliable.
Server-side sync (a dedicated always-on service) was considered and
rejected as unnecessary overhead — a scheduled CI job already provides
the needed cadence with no new infrastructure (§11 Option analysis).

### 5.8 Release
App-store artifact: unchanged mechanism — `pubspec.yaml` still names
one asset path; Dart cannot observe whether the file was committed,
downloaded by CI, or hand-built (REPO FACT/consequence already
documented in `DR-2026-0008`). Repository artifact: stops being the
raw dataset (R18); starts being a pinned reference to a privately-
stored, versioned build. Runtime dependency: **none** — the shipped
app makes no direct calls to `apis.quran.foundation` under the
recommended architecture. First-launch/update behavior: rides the
*existing*, already-proven `DATA_VERSION`-triggered atomic-swap
mechanism (REPO FACT) — no new upgrade code needed. Rollback: pin a
previous artifact version (`DR-2026-0011`'s immutability rule) — no
rebuild required.

### 5.9 Attribution
Exact string `Quran data provided by Quran Foundation.`, "Quran
Foundation" hyperlinked to `https://quran.foundation/` (S15,
PRIMARY SOURCE FACT). Placement: the existing `aboutSourcesDetail`
ARB entries (`lib/l10n/app_{vi,en,ar}.arb`, REPO FACT — same location
as the current Tanzil/QuranEnc/EveryAyah/KFGQPC attributions),
extended to include QF, in all three locales, as a real tappable
hyperlink (not plain text — the same defect class already flagged
for the Tanzil link in `V1_STORE_LEGAL_READINESS.md` P1-4 must not
recur here). Technical ownership: this project (R17) — the string
is source code/localization data, not licensed third-party content,
and **may** enter git (unlike 5.3's artifacts).

---

## 6. Requirement Contract

Thirty requirements, each with the ten fields requested. `MUST` /
`SHOULD` / `MAY` per RFC-2119-style convention.

### R01 — Source identity
- **MUST.** QF is the sole upstream source of truth for this dataset; the legacy `api.qurancdn.com/api/qdc` endpoint is retired for it.
- **Rationale:** S1, S6 — QF explicitly says the old one-time copy "does not qualify for indefinite offline storage."
- **Evidence:** PRIMARY SOURCE FACT (S1, S6).
- **Acceptance:** zero references to `api.qurancdn.com/api/qdc` remain in the transliteration fetch path once migration completes.
- **Validation:** grep-based CI check (extends `repository_boundary_test.dart`'s pattern-matching approach) + code review.
- **Failure mode:** a silent fallback to the legacy endpoint on error would mask non-compliance.
- **Rollback implication:** revert to the legacy fetch script; dataset stays static pending re-decision.
- **Owner gate:** NO.

### R02 — Resource ID
- **MUST.** Use exactly `resource_group=word_by_word_transliterations`, `resource_id=60`, snapshot URL `https://apis.quran.foundation/content/api/v4/resources/snapshots/word_by_word_transliterations/60`, incremental record type `word_transliteration`.
- **Rationale:** these are QF-assigned identifiers, not chosen by this project.
- **Evidence:** PRIMARY SOURCE FACT (S3; independently confirmed against the official snapshot API reference, §3.1).
- **Acceptance:** a config/constants module names these values verbatim; a unit test asserts them.
- **Validation:** unit test + one manual smoke call against `prelive`.
- **Failure mode:** a typo silently fetches the wrong resource or nothing.
- **Rollback implication:** config-only change, no data loss.
- **Owner gate:** NO.

### R03 — Initial snapshot
- **MUST.** Perform a one-time full bootstrap (`bootstrap=true`) before any incremental sync; fetch and apply **every** `snapshot_url` returned; **never** persist a sync token until that full set is applied.
- **Rationale:** official docs' own ordering invariant (§3.1) — persisting early on a partial bootstrap silently produces missing content.
- **Evidence:** PRIMARY SOURCE FACT (official Content Sync tutorial).
- **Acceptance:** a fault-injection test simulating an interrupted bootstrap asserts no token is persisted and state remains `SYNCING_SNAPSHOT`, not `SYNCED`.
- **Validation:** automated test + manual replay against `prelive`.
- **Failure mode:** partial bootstrap treated as complete → silently missing words/ayahs.
- **Rollback implication:** re-run bootstrap from scratch — idempotent, no user-data loss (content-tier, not user-tier data).
- **Owner gate:** NO.

### R04 — Incremental sync
- **MUST.** Send the stored token to `GET /resources/sync` (never to the snapshot endpoint); apply all pages in ascending `sequence` order; persist `next_sync_token` **only** after the final page of a run is fully applied.
- **Rationale:** S7 + official docs' explicit "store `next_sync_token` only from the final page."
- **Evidence:** PRIMARY SOURCE FACT.
- **Acceptance:** a multi-page fixture test verifies the token is persisted only after the last page; out-of-order application is rejected.
- **Validation:** automated test with mocked paginated responses.
- **Failure mode:** early token persistence → subsequent syncs silently skip unapplied changes.
- **Rollback implication:** token is itself versioned/recoverable (R10) — a bad persist can be rolled back to the previous known-good token.
- **Owner gate:** NO.

### R05 — Sync token persistence
- **MUST.** Persist the token durably, associated 1:1 with resource identity, surviving restarts; distinguish "never synced" from every other state. **MUST NOT** enter the public git repository or ship as a build-time constant. **SHOULD NOT** require the same secret-grade protection as `client_secret`, but **SHOULD** avoid trivially world-readable storage.
- **Rationale:** S7 ("retain the sync token") + this is per-install/per-pipeline runtime state, not source.
- **Evidence:** PRIMARY SOURCE FACT (S7) + REPO FACT (no secure-storage dependency exists in `pubspec.yaml` today — only `shared_preferences`).
- **Acceptance:** documented storage location; fresh installs *and* upgrades from a pre-migration install both start at `UNINITIALIZED` cleanly (no crash, no assumed-prior-token).
- **Validation:** integration test across install/upgrade paths.
- **Failure mode:** token loss (e.g., app data cleared) — **not an error**, must self-heal via re-bootstrap (R03).
- **Rollback implication:** none needed — loss is self-healing by design.
- **Owner gate:** NO.

### R06 — Sync frequency ≤ 7 days
- **MUST.** No more than 7 days may elapse between successful incremental syncs while the sync-owning component is able to run.
- **Rationale:** S7 EXPLICIT, independently re-confirmed as a standing Developer Terms clause (§3.1), not an inference.
- **Evidence:** PRIMARY SOURCE FACT (S7 + official Developer Terms extract).
- **Acceptance:** the recommended architecture's scheduled job runs on an interval strictly under 7 days (e.g. daily/every-3-days) so one missed run doesn't breach the SLA.
- **Validation:** CI schedule config review + an observability check for "days since last successful sync" (R26).
- **Failure mode:** a missed scheduled run silently breaches the SLA — mitigated by buffer + alerting, not by this requirement alone.
- **Rollback implication:** N/A — a scheduling parameter, instantly reversible.
- **Owner gate:** NO.

### R07 — Retry/backoff
- **SHOULD.** Retry transient failures (network errors, `5xx`, `429`) with exponential backoff and a bounded attempt count; respect `Retry-After` on `429` if present.
- **Rationale:** official docs document `429`/`5xx` as real failure classes; the QF email itself is silent on retry policy.
- **Evidence:** PRIMARY SOURCE FACT (error taxonomy) for the classes; UNKNOWN for QF's own expected retry policy.
- **Acceptance:** a unit test simulating `429`/`500`/`503` verifies backoff and an eventual transition to `SYNC_FAILED` rather than an infinite loop.
- **Validation:** unit test.
- **Failure mode:** unbounded retry risks rate-limiting the project's own credentials; unbounded silence leaves data stale indefinitely.
- **Rollback implication:** N/A — pure client logic.
- **Owner gate:** NO.

### R08 — Failure handling
- **MUST.** Every failure mode (network unreachable, `401/403`, `404`, `400/422`, `5xx`, `429`, malformed response) maps to a defined state transition (`SYNC_FAILED` or `TOKEN_INVALID`, §6.9); local data must never be left partially-applied and unlabeled.
- **Rationale:** the official error taxonomy (§3.1) plus this document's own state-machine design (§6.9).
- **Evidence:** PRIMARY SOURCE FACT (error classes) + REPO-derived design.
- **Acceptance:** an explicit table maps each error class to a target state; test coverage per class.
- **Validation:** unit tests per failure class.
- **Failure mode:** an unmapped error class must default conservatively to `SYNC_FAILED`, never to an implicit `SYNCED`.
- **Rollback implication:** the pre-attempt dataset remains authoritative until success is confirmed (R09).
- **Owner gate:** NO.

### R09 — Atomicity
- **MUST.** A sync (bootstrap or incremental) applies as an all-or-nothing unit; readers must never observe a half-applied dataset.
- **Rationale:** this project's existing `DATA_VERSION`-triggered database replacement is already described (REPO FACT, `DR-2026-0011` context) as "wholesale and atomic" — the same guarantee extends naturally here.
- **Evidence:** REPO FACT (existing atomic-swap pattern).
- **Acceptance:** implementation uses write-to-staging + atomic swap, not visible in-place row mutation mid-sync.
- **Validation:** a concurrent-read-during-slow-sync integration test asserts only fully-old or fully-new results are ever observed.
- **Failure mode:** partial visibility during a crash mid-sync.
- **Rollback implication:** staging area discarded; previous atomic state untouched.
- **Owner gate:** NO.

### R10 — Corruption recovery
- **MUST.** Detect corrupted/inconsistent local sync state (token present but dataset missing, checksum mismatch) deterministically and transition to `RECOVERY_REQUIRED` rather than trusting it.
- **Rationale:** the governing brief's own explicit warning against a state machine relying only on "last successful sync" with no audit provenance; `DR-2026-0012`'s existing principle that "a truncated download and a tampered file are the same defect; both must fail loudly" (REPO FACT).
- **Evidence:** REPO FACT (existing project principle, directly reusable).
- **Acceptance:** a structural/checksum validity check runs before trusting cached sync state on startup; corruption triggers full re-bootstrap (R03), not a crash or silent stale serve.
- **Validation:** fault-injection test (corrupt local state, assert recovery path).
- **Failure mode:** undetected corruption masquerading as `SYNCED` is the exact worst case this requirement prevents.
- **Rollback implication:** re-bootstrap *is* the recovery.
- **Owner gate:** NO.

### R11 — Versioning
- **MUST.** Reuse the already-designed (unmerged) three-axis version model — schema / artifact / dataset — from `DR-2026-0011`, rather than a parallel scheme; record `resource_group`, `resource_id`, `sync_sequence`, `schema_version` per artifact.
- **Rationale:** `DR-2026-0011`'s own three-axis model (REPO FACT, status: accepted) maps cleanly onto the official snapshot response's own `sync_sequence`/`schema_version` fields (PRIMARY SOURCE FACT, §3.1).
- **Evidence:** REPO FACT + PRIMARY SOURCE FACT.
- **Acceptance:** the metadata schema records these fields, not just a single `fetched_at` date as today.
- **Validation:** schema review + smoke test.
- **Failure mode:** version-axis conflation (today's single `DATA_VERSION` problem, per `DR-2026-0011`'s own diagnosis) recurs for sync data specifically.
- **Rollback implication:** additive schema fields, backward compatible.
- **Owner gate:** NO.

### R12 — Local cache lifecycle
- **MUST.** Define a tested app behavior for each lifecycle state: never-synced, first-sync-success, steady-state, stale (>7 days), corrupted/abandoned (§6.9).
- **Rationale:** S2/S8's conditioning of offline storage on ongoing sync, plus Assumption C's finding (offline UX ≠ offline data lifecycle, §4).
- **Evidence:** PRIMARY SOURCE FACT + this session's own analysis.
- **Acceptance:** every §6.9 state has a corresponding tested behavior.
- **Validation:** tests per state.
- **Failure mode:** an undefined state (e.g., silently stale with no internal visibility) is a governance risk even without a required user-facing warning.
- **Rollback implication:** N/A — defines behavior, not code.
- **Owner gate:** NO.

### R13 — Offline behavior
- **MUST.** The reading experience keeps working fully offline from the last successfully-synced copy, regardless of current network or sync status.
- **Rationale:** S8 permits local storage; REPO FACT — the app has always been offline-first.
- **Evidence:** PRIMARY SOURCE FACT + REPO FACT.
- **Acceptance:** airplane-mode integration test still renders transliteration correctly.
- **Validation:** automated offline test.
- **Failure mode:** coupling the reading UI to sync success would be a regression QF does not require.
- **Rollback implication:** N/A.
- **Owner gate:** NO.

### R14 — Staleness behavior
- **SHOULD.** When local data exceeds the 7-day window (`STALE`), record/expose this internally (logs, observability — R26) even though no evidence requires a user-facing warning. **MAY** surface a non-blocking end-user indicator, purely a product choice.
- **Rationale:** S7's obligation reads as operator-facing, not end-user-facing (INFERENCE).
- **Evidence:** INFERENCE, clearly marked as such.
- **Acceptance:** `STALE` is queryable/loggable.
- **Validation:** unit test on transition timing.
- **Failure mode:** indefinite silent staleness is the exact risk R06 exists to prevent; R14 is the observability backstop for when R06's mechanism itself fails.
- **Rollback implication:** N/A.
- **Owner gate:** NO.

### R15 — Original/raw data boundary
- **MUST.** The value Content Sync returns per word/ayah must remain stored and retrievable unaltered by any local editorial transform.
- **Rationale:** S12 EXPLICIT — "Do not overwrite or redistribute altered source values as Quran Foundation content."
- **Evidence:** PRIMARY SOURCE FACT.
- **Acceptance:** a `raw_value` field distinct from any derived value; no code path mutates it in place.
- **Validation:** a round-trip unit test — raw value survives a full sync+normalize+render cycle unchanged.
- **Failure mode:** the current pipeline already violates this (Assumption D, §4) — this requirement is the fix.
- **Rollback implication:** N/A, additive.
- **Owner gate:** NO.

### R16 — Normalization boundary
- **MUST.** Editorial normalization (today's `ALLAH_MAP`/`standardize_token`/`normalize_words`) applies only from the raw layer (R15) into a separate presentation layer, never in place, and is never labeled as verbatim QF/"original source" content.
- **Rationale:** S13 EXPLICIT.
- **Evidence:** PRIMARY SOURCE FACT + REPO FACT — the seam already partially exists (`TransliterationRepository.normalize()`).
- **Acceptance:** the normalization logic's call site moves downstream of storage; storage of the raw layer is proven never overwritten (R15's test doubles as this one's precondition).
- **Validation:** code review + the R15 round-trip test.
- **Failure mode:** without this, the exact structural gap already identified (D6/D7 in the merged owner-decision document) persists.
- **Rollback implication:** a pure refactor (function relocation), low-risk, reversible — unlike a pipeline rewrite.
- **Owner gate:** NO.

### R17 — Attribution
- **MUST.** Display `Quran data provided by Quran Foundation.` with "Quran Foundation" hyperlinked to `https://quran.foundation/`, in a reasonably visible About/Credits/data-source area, in all three shipped locales.
- **Rationale:** S15 EXPLICIT, exact wording/link/placement.
- **Evidence:** PRIMARY SOURCE FACT.
- **Acceptance:** the string is present verbatim (surrounding sentence may be translated) with a real tappable hyperlink in `app_vi.arb`/`app_en.arb`/`app_ar.arb`.
- **Validation:** a widget test per locale.
- **Failure mode:** a non-hyperlinked mention, or a missing locale, are both non-compliant with S15's literal terms — the same defect class already flagged for the Tanzil link (`V1_STORE_LEGAL_READINESS.md` P1-4).
- **Rollback implication:** `git revert`, fully reversible.
- **Owner gate:** NO — this session recommends (§12) adding this **independently and now**, not bundled with the full migration, as a low-risk technical sequencing call within the owner's standing delegation.

### R18 — Public repository boundary
- **MUST.** No raw QF-sourced content (or the current stand-in normalized dataset) may remain newly committed to the public repository once a replacement pipeline exists. **Explicitly excludes** any conclusion about Git *history* rewriting (kept a fully separate question, §16).
- **Rationale:** S11 EXPLICIT + independently, `DR-2026-0008` (REPO FACT, unmerged, "accepted") reached the identical conclusion pre-dating QF's request.
- **Evidence:** PRIMARY SOURCE FACT + REPO FACT (two converging, independent lines of reasoning).
- **Acceptance:** `repository_boundary_test.dart`'s `_grandfathered` map is empty for these paths once migration completes — the test's own "self-shrinking list" design already anticipates this end-state.
- **Validation:** the existing CI gate test suite, extended.
- **Failure mode:** conflating this with git-history rewriting (D16) — explicitly not required by anything found.
- **Rollback implication:** `git revert` restores tracking (already documented in `IMPLEMENTATION_PROGRAM.md`, REPO FACT).
- **Owner gate:** NO for the forward-looking removal itself; **YES**, separately, for git-history rewriting if that is ever raised (it is not raised here).

### R19 — SQLite handling
- **MUST.** `assets/database/quran.sqlite` keeps its current on-device runtime role (S8 permits this); its *acquisition path* changes from "one committed file forever" to a build-pipeline output, reusing the already-designed `DR-2026-0009` pattern rather than inventing a parallel one.
- **Rationale:** REPO FACT (`DR-2026-0009`/`0011`/`0012`, unmerged, accepted) + S2/S8.
- **Evidence:** REPO FACT + PRIMARY SOURCE FACT.
- **Acceptance:** see §10 Migration Architecture and §13 Implementation Phases.
- **Validation:** N/A at planning stage.
- **Failure mode:** re-designing this from scratch when a compatible, owner-accepted design already exists would be wasted effort.
- **Rollback implication:** N/A at planning stage.
- **Owner gate:** NO for the technical direction; formally landing `DR-2026-0009` itself onto `main` is a separate governance item (§16).

### R20 — Build/CI reproducibility
- **MUST.** Any Content-Sync-calling CI job must be deterministic given a pinned sync state/artifact version; the app's regular per-push/per-PR CI must **not** gain a live dependency on `apis.quran.foundation`.
- **Rationale:** `DR-2026-0009`'s own diagnosis — "App builds are non-deterministic… live fetch… two builds of the same commit can differ" (REPO FACT) — applies identically to a Content Sync call made at app-build time.
- **Evidence:** REPO FACT.
- **Acceptance:** only the dedicated, scheduled data pipeline (§5.7) calls Content Sync; the existing 5-job app-build CI workflow does not.
- **Validation:** CI workflow review.
- **Failure mode:** wiring Content Sync into everyday CI reintroduces the exact non-determinism `DR-2026-0009` already rejected.
- **Rollback implication:** N/A, design-level.
- **Owner gate:** NO.

### R21 — Android behavior
- **MUST:** offline reading identical to today (R13). **SHOULD** (only if any runtime resync is ever added, §11 Option C): use `WorkManager`-class deferred execution, not a naive in-app timer.
- **Rationale:** Android increasingly restricts arbitrary background execution (Doze/App Standby) — SECONDARY SOURCE, general platform knowledge, not independently verified against this app's manifest this session.
- **Evidence:** REPO FACT — no such plugin exists in `pubspec.yaml` today (neither present nor ruled out).
- **Acceptance / Validation / Failure / Rollback:** deferred to a future scoping session per §8 (marked UNKNOWN, §18) — not needed under the recommended build-time-only architecture (§11).
- **Owner gate:** NO.

### R22 — iOS behavior
- **MUST:** offline reading unaffected. **Material finding:** `BGTaskScheduler` is opportunistic and OS-throttled — Apple does not guarantee a background task fires on any schedule, which is a direct risk to R06 if the architecture ever depended on it.
- **Rationale:** SECONDARY SOURCE (general iOS platform behavior) — this session did not verify current entitlements (UNKNOWN, §18).
- **Evidence:** SECONDARY SOURCE.
- **Acceptance:** N/A — this finding is precisely why §11 recommends against relying on iOS background execution for R06 at all.
- **Owner gate:** NO.

### R23 — Web behavior
- **MUST:** offline reading continues via the existing, verified-working IndexedDB/Drift-WASM stack (REPO FACT, `DATA_PIPELINE.md` "Web runtime," confirmed in a real browser per Phase 3 Sprint R3a.2).
- **Rationale:** Web has no reliable background execution without Service-Worker+Push infrastructure this app does not currently have (not found this session — treated as absent, not exhaustively ruled out).
- **Evidence:** REPO FACT (offline stack) + UNKNOWN (service-worker absence, not exhaustively verified).
- **Acceptance:** Web, like Android/iOS, only ever *consumes* a pinned artifact under the recommended architecture — no Web-specific sync code needed.
- **Owner gate:** NO.

### R24 — Test requirements
- **MUST.** Every new behavior ships tests in the same change, per this repo's established discipline (`CLAUDE.md` "Definition of done"): state-machine transition tests (§6.9, one per transition + failure edges), the R15/R16 raw/normalized round-trip test, the R18 grandfather-list-shrink test, the R03/R04 token-ordering test.
- **Rationale:** `CLAUDE.md` (REPO FACT) + this project's demonstrated "prove every gate by deliberately breaking it" pattern (`DR-2026-0013`, REPO FACT).
- **Evidence:** REPO FACT.
- **Acceptance:** `flutter test --coverage` and the Python-side pipeline tests both green.
- **Validation:** CI.
- **Failure mode:** skipping this repeats the exact failure `DR-2026-0009`/`0012` were designed to prevent ("a pipeline exercised only in a crisis is not a pipeline").
- **Rollback implication:** N/A.
- **Owner gate:** NO.

### R25 — Evidence/provenance
- **MUST.** Any follow-on implementation session maintains the FACT/INFERENCE/UNKNOWN discipline this document (and Sessions 164–182) used, citing exact evidence rather than re-deriving legal conclusions from silence.
- **Rationale:** this session's own governing brief + the demonstrated pattern across ~20 prior QF/QDC sessions.
- **Evidence:** REPO FACT (session history).
- **Acceptance:** any follow-on document includes an evidence table in this style.
- **Validation:** manual review continuity.
- **Failure mode:** evidence discipline erosion is exactly how a stale attribution string persisted uncorrected across multiple sprints (Session 147/159A history, REPO FACT).
- **Rollback implication:** N/A.
- **Owner gate:** NO.

### R26 — Observability/debugging
- **SHOULD.** Current state, last-successful-sync timestamp, last error class, and current `sync_sequence` should be inspectable (debug log, diagnostics screen, or pipeline CLI output).
- **Rationale:** INFERENCE — no explicit QF requirement, but operationally necessary to make R06/R14 debuggable.
- **Evidence:** INFERENCE.
- **Acceptance:** a documented way to answer "when did this last successfully sync, and why not since."
- **Validation:** manual.
- **Failure mode:** without this, a silent R06 breach (missed scheduled run) could go unnoticed indefinitely.
- **Rollback implication:** N/A.
- **Owner gate:** NO.

### R27 — Rollback
- **MUST.** Every implementation phase (§13) states a defined, low-risk rollback; data-untracking phases reuse the already-documented rollback pattern ("`git revert` restores tracking; the file is unchanged in history" — REPO FACT, `IMPLEMENTATION_PROGRAM.md`).
- **Rationale:** this document's own Part 6 requirement + existing precedent.
- **Evidence:** REPO FACT.
- **Acceptance:** §15 states one rollback path per phase.
- **Validation:** N/A at planning stage.
- **Failure mode:** a phase with no stated rollback is not ready to implement.
- **Rollback implication:** self-referential — this requirement *is* the rollback discipline.
- **Owner gate:** NO.

### R28 — Migration from current data
- **MUST.** The transition from today's build-time-normalized, committed dataset to the Content-Sync-sourced, raw/normalized-separated one must not silently drop content, must not require an all-or-nothing cutover with no rollback, and must preserve the existing atomic-swap user-data-safety guarantee.
- **Rationale:** REPO FACT (existing swap mechanism) + Assumption F/G findings (§4).
- **Evidence:** REPO FACT.
- **Acceptance:** §10's sequenced migration plan.
- **Validation:** N/A at planning stage.
- **Failure mode:** see Assumption F/G.
- **Rollback implication:** see §15.
- **Owner gate:** NO.

### R29 — Release gate
- **MUST.** `P2-2` stays tracked as an open v1.0 release blocker until, at minimum: (a) attribution added (R17); (b) raw dataset no longer newly committed (R18/R19); (c) an ongoing R06-compliant sync mechanism exists and has demonstrated ≥1 real incremental sync; (d) counsel input sought or explicitly, knowingly deferred by the owner (R30).
- **Rationale:** D17 (merged, PR #65) + this document's synthesis.
- **Evidence:** PRIMARY DOCUMENT (D17, already merged).
- **Acceptance:** `RELEASE_DASHBOARD.md`/`V1_STORE_LEGAL_READINESS.md` P2-2 entries updated to closed **only** in a session explicitly authorized to edit those files (REPO FACT — PR #64 §20 step 4's own instruction), never automatically.
- **Validation:** manual owner/counsel sign-off.
- **Failure mode:** releasing before all four sub-conditions ships in a state QF's own email frames as not-yet-compliant.
- **Rollback implication:** N/A — this is a gate, not a code change.
- **Owner gate:** **YES** — this is the release/go-live decision itself.

### R30 — Legal/counsel gate
- **MUST.** No session — including this one — may declare `P2-2` legally closed, declare the QF email sufficient legal authorization, or declare the dataset "compliant." Reserved for counsel/owner, as every session in this chain (164, 165, 172, 180, 182, 184) has held.
- **Rationale:** this session's own governing instruction + D15/D20 (merged) + PR #64 §17/§18.
- **Evidence:** PRIMARY DOCUMENT + this session's own governing brief.
- **Acceptance:** this document contains no such conclusion (self-check, §17).
- **Validation:** manual review.
- **Failure mode:** the single failure mode every session in this chain is structured to avoid.
- **Rollback implication:** N/A.
- **Owner gate:** **YES** — the counsel-routing decision itself (§16).

---

## 7. Evidence-Gated Sync State Machine

Applies to whatever component owns the sync relationship with QF —
under the recommended architecture (§11–§12) that is the **data
pipeline**, not the shipped app. Designed to avoid the brief's own
named failure mode: a state machine keyed only on "last successful
sync," with insufficient provenance to audit.

| State | Entry condition | Allowed transitions | Evidence required to transition | Failure transition | Recovery | Release implication |
|---|---|---|---|---|---|---|
| **UNINITIALIZED** | first run; no persisted token found | → `SNAPSHOT_REQUIRED` | none (default state) | — | — | never itself shippable |
| **SNAPSHOT_REQUIRED** | fresh install, or after `TOKEN_INVALID`/`RECOVERY_REQUIRED` | → `SYNCING_SNAPSHOT` | bootstrap call issued | — | — | never itself shippable |
| **SYNCING_SNAPSHOT** | bootstrap request in flight | → `SNAPSHOT_READY` on full success; → `SYNC_FAILED` on transient error | every `snapshot_url` in the bootstrap response fetched **and** applied (R03) | network/`5xx`/`429`/timeout → `SYNC_FAILED`; no partial writes committed (R09) | retry per R07, returns to `SNAPSHOT_REQUIRED` | never itself shippable |
| **SNAPSHOT_READY** | all snapshots applied, token **not yet** persisted | → `SYNCED` | sync token from the bootstrap response persisted (R03's ordering gate — this is the *only* place a token may first be written) | — | — | never itself shippable |
| **INCREMENTAL_SYNC_REQUIRED** | a scheduled resync is due (R06) from `SYNCED` or `STALE` | → `SYNCING_INCREMENTAL` | sync call issued with the stored token | — | — | not a new run; the *previously* published artifact remains shippable |
| **SYNCING_INCREMENTAL** | incremental request(s) in flight | → `SYNCED` on full success; → `TOKEN_INVALID` on auth failure; → `SYNC_FAILED` on transient error | all pages applied in ascending `sequence` order (R04); `next_sync_token` persisted only from the final page | `401`/`403` ("expired token or insufficient permissions") → `TOKEN_INVALID`; network/`5xx`/`429` → `SYNC_FAILED` | `SYNC_FAILED` retries per R07; `TOKEN_INVALID` cannot be repaired, only replaced | — |
| **SYNCED** | last sync (bootstrap or incremental) fully applied within the last 7 days | → `INCREMENTAL_SYNC_REQUIRED` when next resync is due; → `STALE` if 7 days elapse with no successful resync; → `RECOVERY_REQUIRED` on detected corruption (R10) | successful completion recorded with timestamp + sequence | — | — | **the only steady-state a published artifact may be built from** |
| **STALE** | >7 days since last successful sync, regardless of *why* (missed schedule, repeated failure, or first-ever sync never completed in time) | → `INCREMENTAL_SYNC_REQUIRED` (retry the normal path first — do **not** assume a full re-bootstrap is needed on staleness alone) | time-based, independent of any single failed attempt (R06/R14) | — | normal incremental retry | data continues to be **served** (R13); **not** re-published without a fresh successful sync (R29c) |
| **SYNC_FAILED** | a bootstrap or incremental attempt exhausted its retry budget (R07) | → prior requesting state (`SNAPSHOT_REQUIRED` or `INCREMENTAL_SYNC_REQUIRED`) on next scheduled attempt; → `STALE` if a prior `SYNCED` state exists and 7 days elapse | retry budget exhausted, logged (R26) | — | scheduled retry | previous successfully-published artifact remains the shipped one (R27) |
| **TOKEN_INVALID** | `401`/`403` on an incremental call | → `SNAPSHOT_REQUIRED` (discard token; a token cannot be repaired, only replaced by a fresh bootstrap, per the official docs' description of tokens as private checkpoints belonging to the sync endpoint) | none — this is a forced transition | — | full re-bootstrap | previous artifact remains shipped until a new bootstrap succeeds |
| **RECOVERY_REQUIRED** | corruption detected (R10) — token present but dataset missing, checksum mismatch, structurally inconsistent state | → `SNAPSHOT_REQUIRED` (local sync state wiped) | corruption check result | — | wipe + full re-bootstrap — treated like `TOKEN_INVALID` mechanically, distinct in cause for R26 observability | previous artifact remains shipped |

**Provenance discipline (per the brief's own caution):** every
`SYNCED`/`STALE` transition carries, at minimum, the resource identity,
`sync_sequence`, the token itself, and a timestamp (R11) — never just a
boolean "last sync succeeded." This is what makes `RECOVERY_REQUIRED`
detectable at all (R10): a state machine keyed only on a success flag
cannot distinguish "genuinely synced" from "flag set, data missing."

---

## 8. Artifact Contract

Nine artifacts, each against the ten requested properties.

### A. Remote source metadata
Owner: QF (external). Source of truth: QF's live Content Sync API
responses. Format: JSON/HTTPS. Lifecycle: ephemeral per-request, not
stored verbatim. Mutable/immutable: QF's own mutable live data (the
premise of "sync"). Public/private: QF's authenticated API surface.
Git: **no**. App bundle: **no**. Transformable: parsed into local
structures only, never edited. Validation: HTTP-level (status/schema
shape). Rollback: N/A — external; our *consumption* of it is what we
version (E/G below).

### B. Snapshot
Owner: this project's data pipeline (consumer). Source of truth: the
specific bootstrap response at a point in time. Format: JSON per the
official schema (`resource_group`, `resource_id`, `resource_content_id`,
`schema_version`, `sync_sequence`, `records[]`). Lifecycle: fetched
once per bootstrap event; **should** be archived raw in private storage
for provenance ("archive on acquisition, not on need" — reusing
`DR-2026-0009`'s own stated principle, REPO FACT). Mutable/immutable:
immutable once archived. Public/private: private — not itself cleared
for standalone redistribution (S10). Git: **no**. App bundle: **no**
directly (only via G). Transformable: parsed into E, never re-edited
after capture. Validation: structural coverage check (114/6236, reusing
`build_quran_db.py`'s existing checks) + provenance match. Rollback:
re-fetch (idempotent) or restore an archived copy.

### C. Incremental records
Owner: pipeline. Source of truth: `GET /resources/sync` responses.
Format: JSON, paginated. Lifecycle: applied then superseded; **should**
be logged (sequence + type + summary) for audit (R26). Mutable/
immutable: immutable historical fact, even though what it describes is
mutable. Public/private: private. Git: **no**. App bundle: **no**.
Transformable: applied as upsert/delete mutations onto E. Validation:
sequence-ordering (R04) + schema shape. Rollback: replay from an
archived snapshot (B) plus the incremental log (C) is the disaster-
recovery path.

### D. Sync token/state
Owner: the sync-owning component (pipeline under the recommended
architecture). Source of truth: **this project's own persisted
record** — QF is authoritative on whether a token is still valid, not
on what value we currently hold. Format: small JSON/key-value record.
Lifecycle: updated only after full successful application (R03/R04's
ordering invariant) — living state, not versioned per delta, though
recoverable (R10). Mutable/immutable: **the one genuinely mutable
artifact in this contract, by necessity.** Public/private: private
(CI-side, secret-adjacent storage under the recommended architecture).
Git: **no**. App bundle: **no** under Option B; opaque local runtime
state only, never a bundled asset, under Option A/C. Transformable: no
— treat as an opaque blob. Validation: R10 corruption checks. Rollback:
**discard and re-bootstrap** — the only artifact whose rollback is
deletion, precisely because everything else can be rebuilt from a
fresh bootstrap.

### E. Local canonical/raw representation
Owner: pipeline. Source of truth: this project's stored copy of QF's
raw returned values, post-application, pre-normalization. Format:
today's `tool/data/transliteration.json` "ayahs" map, restructured
(per R15/R16) so raw and normalized are no longer the same field.
Lifecycle: replaced wholesale and atomically (R09) on each successful
sync; the *published version* becomes immutable once part of a shipped
artifact (G), per `DR-2026-0011`. Public/private: private (S11 +
`DR-2026-0008`, REPO FACT). Git: **no** — this is precisely the file
`DR-2026-0008`/D9 already decided must leave the public repository.
App bundle: only baked into G, never as a loose JSON. Transformable:
yes — the designated *input* to R16's normalization, but the transform
must never overwrite E itself. Validation: existing `build_quran_db.py`
integrity checks. Rollback: a previous pipeline run's version, restorable
per `DR-2026-0011`'s "retain every version ever shipped."

### F. Normalized presentation representation
Owner: pipeline (computed at build time, this session's recommended
choice — an implementation detail, not a hard requirement) or,
alternatively, app runtime (computed at render time — the stricter
reading of S13). Source of truth: a deterministic function of E plus
the existing editorial rules. Format: same shape as E, post-transform.
Lifecycle: regenerated whenever E changes. Mutable/immutable: fully
derived/regenerable — "immutability" is not a meaningful constraint
here, unlike E. Public/private: private, for the same S11-adjacent
reasons as E, unless a separate public-profile redistribution decision
is made (out of scope here). Git: **no**. App bundle: **yes** — this is
what actually ships and renders, provably derived from, and never
overwriting, E. Transformable: it *is* the transform's output.
Validation: a round-trip test proving F is always reproducible from E —
the concrete test that operationalizes S13. Rollback: regenerate from
E; F is never itself the source of truth.

### G. Database artifact (`quran.sqlite`)
Owner: pipeline (reusing `DR-2026-0009`/`0011`/`0012`'s existing,
unmerged model). Source of truth: itself, once built and published —
immutable, pinned by `(artifact-id, version, sha256)` per `DR-2026-0012`.
Format: SQLite file. Lifecycle: built on the pipeline's own cadence
(R06/R20), published to private/versioned storage, consumed by pin at
app-build time. Mutable/immutable: immutable once published — a
correction produces a new version. Public/private: private storage,
tiered CI access (`DR-2026-0009` tiers 0/1/2, reused not reinvented).
Git: **no**, going forward (R18/R19). App bundle: **yes** — the one
artifact in this contract explicitly meant to ship inside the app,
exactly as today, just sourced differently. Transformable: no, ships
as-built. Validation: `DR-2026-0012`'s four verification classes
(structural/semantic/provenance/licence), reused as designed. Rollback:
pin a previous version — no rebuild needed.

### H. Attribution metadata
Owner: this project (product/localization). Source of truth: the
fixed, QF-specified string+link (S15) — not itself synced from QF's
API. Format: ARB localization entries. Lifecycle: static until QF
changes its own requirement (periodic re-verification, analogous to
`DR-2026-0010`'s `review_by` pattern). Mutable/immutable: changed only
via a reviewed PR, like any source string. Public/private: public — it
is UI text, meant to be seen. Git: **yes** — the opposite disposition
from E/F/G; this is source code, not licensed third-party content. App
bundle: **yes**. Transformable: only the surrounding sentence may be
localized; "Quran Foundation" and its URL may not be altered.
Validation: the R17 widget test. Rollback: `git revert`.

### I. Provenance/evidence metadata
Owner: this project (governance/documentation layer). Source of truth:
this document + PR #64/#65 + official-docs citations + future
sessions' own evidence tables. Format: markdown under `docs/release/`,
this repo's established pattern. Lifecycle: append-only historical
record — corrections are new dated addenda, never silent edits (REPO
FACT, `docs/LICENSING.md`'s own "Đính chính" convention, observed
throughout Sessions 147/159A/162/173). Mutable/immutable: immutable
once merged. Public/private: public — a distinct category from E/F/G
(governance documentation, not licensed content). Git: **yes**. App
bundle: **no** — not shipped. Transformable: no, append-only.
Validation: this session's own evidence-classification discipline
(§3). Rollback: `git revert`, though this project's own convention is
to append a correction rather than revert history.

---

## 9. Capability Routing

No single mechanism is assumed across platforms. `?` resolved by
evidence or marked UNKNOWN, per the governing brief.

| Capability | Android | iOS | Web | CI/Build |
|---|---|---|---|---|
| Network fetch | YES (REPO FACT — app already streams audio at runtime) | YES (REPO FACT — same, cross-platform Flutter) | YES (REPO FACT — browser fetch already used, confirmed working) | YES (REPO FACT — pipeline already fetches Tanzil/QuranEnc/Saheeh live at build time today) |
| Background sync | **UNKNOWN** — no background-execution plugin found in `pubspec.yaml` today (REPO FACT: absent, not ruled out as a platform capability) | **unreliable-by-design** — `BGTaskScheduler` is opportunistic/OS-throttled (SECONDARY SOURCE); cannot guarantee ≤7-day cadence regardless of implementation effort | **NO** reliable mechanism without Service-Worker+Push infrastructure not currently present (REPO FACT: none found in `web/`) | **YES** — a scheduled workflow trigger (REPO FACT: CI already runs 5 jobs on a defined trigger model; a `schedule:` cron is a config-only extension) |
| Persistent storage | YES (REPO FACT — existing local SQLite) | YES (REPO FACT — same) | YES (REPO FACT — IndexedDB, confirmed working) | YES (REPO FACT — workflow artifacts / private storage per `DR-2026-0009`, unmerged but designed) |
| SQLite/WASM | YES (REPO FACT — native sqlite3, existing app) | YES (REPO FACT — same) | YES (REPO FACT — `sqlite3.wasm`/`drift_worker.js` vendored, verified working) | YES (REPO FACT — `build_quran_db.py` already produces the file) |
| Scheduled execution | **UNKNOWN** (same caveat as background sync — this is effectively the same capability) | **unreliable-by-design** (same caveat) | **NO** | **YES** (REPO FACT — same as background sync row) |

**Synthesis.** CI/Build is the only row with a clean YES across every
capability the architecture actually needs. This is not a coincidence
this document is built around — it is the direct consequence of
Assumption E's finding (§4): mobile/web background execution cannot be
made to reliably satisfy R06 no matter how it's implemented, while a
scheduled CI job already can, with no new infrastructure.

**Shared domain contract vs. platform adapters**, per the brief's
requirement: the shared contract is §6 (state machine) + §8 (artifact
contract) — platform-independent by construction. Under the
recommended architecture (§11), Android/iOS/Web need **no
platform-specific sync adapter at all** — each is simply "consume the
pinned artifact G, render offline" (R13), identical in shape to what
each already does today. The only platform-specific adapter that is
new is the **CI/Build adapter** (a scheduled workflow). If a future
Option C opportunistic-refresh layer is added, its adapters are
lightweight "check-on-foreground-open + download a versioned artifact"
— not background-execution adapters — sidestepping this entire table's
unreliable rows by design (§11).

---

## 10. Migration Architecture

CURRENT → transitional → target, addressing all ten required items.
**No removal, rebuild, or code change happens in this session** — this
is the plan a future implementation session would execute.

1. **Current `quran.sqlite`.** Stays committed through the transitional
   state (nothing removed yet). Target: pipeline-built, privately
   stored, pinned by version — reusing (and independently re-verifying,
   not blindly trusting) `IMPLEMENTATION_PROGRAM.md`'s existing "D1"
   phase (REPO FACT — note this D1 label is unrelated to this
   document's own D1–D20 numbering inherited from the merged
   owner-decision document; both are kept distinct in §16).
2. **Tracked raw data (`tool/data/transliteration*.json`).** Same
   pattern, reusing the existing "D2" phase.
3. **Current fetch pipeline (`tool/fetch_transliteration.py`).**
   Transitional: add a Content-Sync-based fetch path (via the official
   `quran-foundation-api` SDK, §3.1) **alongside** the legacy path;
   do **not** delete the legacy path until the new path has a proven
   successful bootstrap + first incremental cycle — a real rollback
   margin. Target: legacy-endpoint code removed once proven.
4. **Current normalization.** Transitional: keep the existing
   transform functions unchanged in *logic*; relocate their call site
   so they produce F from E (R16) instead of overwriting the only
   stored value — a refactor, not a rewrite.
5. **Existing tests.** Transitional: extend, don't replace,
   `transliteration_test.dart`/`transliteration_standard_test.dart`/
   `repository_boundary_test.dart`/`repository_boundary_completeness_test.dart`
   (REPO FACT — all four exist today); new tests (R24) added alongside.
6. **CI.** Transitional: add the new scheduled data-pipeline workflow
   (reusing `DR-2026-0009` Stream C's already-scoped "short-lived,
   least-privilege, environment-gated credentials" design, REPO FACT)
   without touching the existing 5 per-push/per-PR jobs (R20).
7. **App bundle.** Unaffected throughout — `pubspec.yaml` still names
   one asset path (REPO FACT, `DR-2026-0009`'s own stated consequence:
   "no application code changes").
8. **Offline behavior.** Unaffected throughout (R13) — a deliberate
   invariant of the entire migration, not a side effect.
9. **User upgrade from existing version.** Rides the *existing, already
   proven* `DATA_VERSION`-triggered atomic-swap mechanism (REPO FACT) —
   zero new upgrade code required. This is a major reason Option B is
   preferred (§11): it reuses a mechanism already in production rather
   than inventing a new one for existing installs.
10. **Rollback if migration fails.** Pipeline/build level: the existing
    per-phase rollback story in `IMPLEMENTATION_PROGRAM.md` already
    covers this (`git revert` restores tracking; pin a previous
    artifact version). App level: app-code changes are minimal (R16's
    refactor + R17's ARB strings) — a normal `git revert` of those
    specific commits, independent of the data-pipeline rollback.

**Explicitly not decided or executed here:** exact untracking commit
sequencing, exact CI workflow YAML, exact schema migration DDL. These
belong to Implementation Phases 1–6 (§13).

---

## 11. Option Analysis

Three architectures, scored across eleven criteria. Auto-decided per
the owner's standing technical-direction delegation — not an owner
gate.

### OPTION A — Full runtime Content Sync
The Flutter app itself performs bootstrap/incremental sync at runtime,
holding OAuth2 credentials (or a proxy token) on-device.

### OPTION B — Build-time-only acquisition
A dedicated, scheduled data pipeline (extending today's Python
tooling) performs all Content Sync interaction; the shipped app never
talks to `apis.quran.foundation` directly, exactly as it never talks to
Tanzil/QuranEnc/EveryAyah directly today.

### OPTION C — Hybrid (build-time-primary + opportunistic client refresh)
Option B, plus a lightweight, foreground-only, credential-free
"check for a newer pinned artifact and download it" step in the app —
never a QF API call, only a check against this project's own already-
published, versioned artifact (reusing `DR-2026-0012`'s artifact
registry concept).

| Criterion | A — Runtime | B — Build-time | C — Hybrid |
|---|---|---|---|
| Compliance fit | Medium-High if executed correctly | High | Highest |
| Technical complexity | High (new HTTP client, per-platform secret handling, per-platform scheduling) | Medium (extends existing Python tooling + official SDK) | Medium-High (B + a small artifact-freshness check) |
| Offline UX | Good | Preserved, unaffected | Best of both |
| Reliability | Medium-Low (depends on unreliable platform background execution, §9) | High (CI cron is a mature, well-understood pattern) | High (falls back to B's guarantee if the opportunistic check fails) |
| Reproducibility | Poor (live-network dependency risks entering app builds) | Excellent (matches `DR-2026-0009`'s design goal directly) | Excellent (same as B; the client-side check is a runtime, not build-time, concern) |
| Platform compatibility | Poor-Medium (3 different, unequal background-execution models) | Excellent (platform-agnostic by construction, §9) | Good (no OAuth secrets or background execution needed client-side) |
| CI complexity | Low direct, but doesn't reuse existing `DR-2026-0009` work | Medium (new scheduled workflow, reuses Stream C's scoped design) | Same as B, plus a lightweight distribution point |
| Maintenance | Medium-High (client-side sync client to maintain; a shipped secret is effectively unrotatable without an app release) | Low-Medium (one pipeline, existing tooling) | Medium |
| Rollback | Medium (compromised on-device secret has a poor rollback story) | Excellent (pin a previous artifact, no app change) | Good (both halves independently revertible) |
| Legal risk | Low-Medium (a compromised on-device secret could affect QF's own systems, not just this project) | Low | Lowest (client never touches QF endpoints/credentials at all) |
| Operational risk | High (secret compromise + unreliable background execution can silently breach R06) | Low-Medium (single point of failure is the scheduled job, mitigated by R26) | Low |

**Note on a fourth possibility considered and rejected:** a dedicated
always-on server-side sync service (as opposed to a scheduled CI job)
was considered and rejected as unnecessary infrastructure — a scheduled
GitHub Actions workflow already provides the needed ≤7-day cadence with
no new service to operate, keeping the option set at three as the
research suggested rather than inventing a fourth for its own sake.

---

## 12. Recommended Architecture

**Option B now; Option C explicitly not foreclosed.** Ship the
build-time-only pipeline first — it alone satisfies R01–R20 and R29's
compliance bar. Design the artifact contract (§8) and the CI-published,
versioned artifact (G, reusing `DR-2026-0012`) so that Option C's
opportunistic client-side refresh can be layered on later **without
re-architecture** — a possible post-v1.0 enhancement, not a blocking
requirement.

**Auto-decided sequencing recommendation:** add the attribution string
(R17, artifact H) **independently and immediately** once implementation
begins — it is low-risk, fully reversible, and does not depend on any
other phase completing. This is a technical sequencing call within the
owner's delegation, not a new owner decision (contrast with how the
merged owner-decision document left this as an open D8 choice between
sessions — this document resolves it).

**Explicitly deferred, not decided:** whether to formally land
`DR-2026-0008`…`DR-2026-0013` onto `main` before or alongside this
work. This document *recommends* doing so (§16) because Option B's
Phase 6 depends on that architecture, but ratifying someone else's
already-accepted-but-uncommitted decision records is flagged as an
owner housekeeping item, not something this session executes.

---

## 13. Implementation Phases

Ten phases (0–9), as specified. **None executed this session.**

### Phase 0 — Evidence/contract
- **Objective:** establish the requirement contract before any code (this document, plus its Session 164–182 predecessors).
- **Files:** `docs/release/SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`.
- **Dependencies:** none.
- **Acceptance:** this document merged to `main`.
- **Rollback:** `git revert` (docs only).
- **Risk:** none — the safest phase by construction.

### Phase 1 — Source adapter
- **Objective:** build the Content-Sync-aware fetch capability in isolation (a new file, not yet wired into `build_quran_db.py`), using the official `quran-foundation-api` SDK (§3.1) rather than hand-rolling the protocol.
- **Files:** `tool/fetch_transliteration.py` or a new `tool/fetch_transliteration_contentsync.py`; a Python dependency declaration (this session did not verify whether one exists — flag for Phase 1 itself to check).
- **Dependencies:** Phase 0; **the owner personally obtaining QF API credentials** (`client_id`/`client_secret` via QF's "Request Access" process — a form of account creation this session's own standing tool-use rules forbid any Claude session from doing on the owner's behalf, §16).
- **Acceptance:** a successful bootstrap fetch against `prelive` (or production) reproduces the legacy path's 6,236-ayah coverage, output raw/unnormalized (R15).
- **Rollback:** new file, purely additive, zero risk to the existing pipeline.
- **Risk:** Medium — external dependency on QF granting credentials; turnaround time UNKNOWN (§18).

### Phase 2 — Sync state/token
- **Objective:** implement token persistence (R05), the state machine (§7), and corruption detection (R10) as pipeline-side code.
- **Files:** a new `tool/` module (e.g. `tool/sync_state.py`) + a persisted state location in private storage (**not** `tool/data/`, which is git-tracked).
- **Dependencies:** Phase 1.
- **Acceptance:** the R03/R04 fault-injection tests (interrupted bootstrap, premature token persistence) pass.
- **Rollback:** additive, no existing code touched.
- **Risk:** Medium — the most novel logic in the plan; most likely place for a subtle ordering bug.

### Phase 3 — Storage
- **Objective:** implement the raw/normalized separation (artifacts E/F) in `build_quran_db.py`'s schema, keeping the `DR-2026-0011` versioning discipline.
- **Files:** `tool/build_quran_db.py`; `lib/core/database/database_constants.dart` (schema/artifact version constants); a schema migration.
- **Dependencies:** Phases 1–2.
- **Acceptance:** existing integrity checks (114 surahs/6,236 ayahs, non-empty, FK) pass against Content-Sync-sourced data; new checks confirm E and F are both populated and distinct.
- **Rollback:** schema change — per `CLAUDE.md`'s standing "stop and ask before any schema change" rule (`PROJ-P-002`), this is a **hard stop-and-ask point inherited from existing project governance**, independent of any QF-specific gate.
- **Risk:** Medium-High.

### Phase 4 — Presentation/normalization boundary
- **Objective:** relocate (or duplicate into a build-time-computed column, this session's auto-decided choice, §8 artifact F) the existing normalization logic so it operates strictly downstream of E, never mutating it.
- **Files:** `tool/fetch_transliteration.py` / `tool/build_quran_db.py` (call-site move); `lib/features/quran/data/transliteration_repository.dart` (the existing seam, kept as the documented boundary).
- **Dependencies:** Phase 3.
- **Acceptance:** the R16 round-trip test.
- **Rollback:** pure refactor, `git revert`.
- **Risk:** Low — the transform logic itself is unchanged and already tested (`transliteration_standard_test.dart`, REPO FACT); only its call site moves.

### Phase 5 — Platform routing
- **Objective:** implement §9's finding — no new Android/iOS/Web code; the new scheduled CI workflow is the only genuinely new platform-specific work.
- **Files:** a new `.github/workflows/` scheduled data-pipeline workflow, reusing `DR-2026-0009` Stream C's credential-gating design.
- **Dependencies:** Phases 1–4.
- **Acceptance:** the scheduled workflow runs successfully at least twice on its own cadence, unattended, each producing a new pinned artifact.
- **Rollback:** workflow-file revert; does not affect any already-published artifact.
- **Risk:** Medium — new operational surface (credential provisioning/rotation), per `DR-2026-0009`'s own acknowledged consequence ("one more system to keep alive").

### Phase 6 — Migration
- **Objective:** execute the actual git-untracking of `quran.sqlite`/`transliteration*.json` (reusing the existing "D1"/"D2"/"D3" phases in `IMPLEMENTATION_PROGRAM.md`), **only** after Phases 1–5 have produced ≥1 verified, working, end-to-end artifact — so there is never a window with neither the old file nor a working replacement.
- **Files:** `.gitignore`, `test/repository_boundary_test.dart` (`_grandfathered` map shrink), `git rm --cached` targets.
- **Dependencies:** Phases 1–5, fully proven.
- **Acceptance:** the existing, already-written acceptance criteria in `IMPLEMENTATION_PROGRAM.md` (REPO FACT, reusable verbatim): untracked; CI green; a release build produces an artifact; a clean clone without credentials builds the public profile.
- **Rollback:** `git revert` restores tracking (already documented, REPO FACT).
- **Risk:** High — `IMPLEMENTATION_PROGRAM.md` itself already flags this exact phase as "the first phase where a mistake breaks the release build," an inherited risk assessment, not newly invented here.

### Phase 7 — Tests
- **Objective:** state the aggregate acceptance bar — tests ship incrementally *with* each phase above (R24), not deferred to the end.
- **Files:** N/A (spans all phases).
- **Dependencies:** Phases 1–6.
- **Acceptance:** full `flutter test --coverage` + the Python-side pipeline tests green; every fault-injection/round-trip/ordering test from R03/R04/R10/R16 present.
- **Rollback:** N/A — tests only strengthen, never block, rollback of the code they cover.
- **Risk:** Low.

### Phase 8 — CI/reproducibility
- **Objective:** verify R20 holds — the existing 5-job per-push/per-PR workflow gains zero new live dependency on `apis.quran.foundation`.
- **Files:** `.github/workflows/ci.yml` (verify unchanged in this respect); the new scheduled workflow (Phase 5).
- **Dependencies:** Phase 5.
- **Acceptance:** a fork-originated CI run (no credentials) still builds/tests successfully against the last-pinned artifact, per `DR-2026-0009`'s own tier-0 design goal.
- **Rollback:** N/A — verification, not new construction.
- **Risk:** Low.

### Phase 9 — Release validation
- **Objective:** re-run the D17/R29 release-gate checklist against the now-implemented state; report R29's four sub-conditions individually, true/false, with evidence — **does not itself authorize closing `P2-2`**.
- **Files:** none changed by this phase's own logic; `RELEASE_DASHBOARD.md`/`V1_STORE_LEGAL_READINESS.md` updated only in a separately-authorized session (R29 acceptance criterion).
- **Dependencies:** Phases 1–8 + R30's counsel-routing track (independent, §16).
- **Acceptance:** R29's four sub-conditions each individually verified with evidence.
- **Rollback:** N/A — a gate-check, not a code change.
- **Risk:** Low technically, but this is the phase where R30's legal gate becomes load-bearing — an explicit Owner Gate (§16).

---

## 14. Validation Strategy

Synthesized from R24 and each phase's own acceptance criteria, not
repeated in full here. Three layers: **(1)** per-requirement automated
tests (state-machine transitions §7, raw/normalized round-trip R15/R16,
token-ordering R03/R04, repository-boundary shrink R18) — all specified
inline in §6/§13, ship with their owning phase, not batched at the end.
**(2)** the existing CI gate suite (`repository_boundary_test.dart`,
`repository_boundary_completeness_test.dart`, `transliteration_test.dart`,
`transliteration_standard_test.dart`) extended, never bypassed. **(3)**
manual validation for the two things automated tests cannot cover: a
real `prelive`/production smoke call (Phase 1) and the owner's own
review of R29's release-gate report (Phase 9). No phase is considered
complete without its own stated acceptance criterion (§13) passing —
this document does not define a separate, redundant validation regime.

---

## 15. Rollback Strategy

Synthesized from R27 and each phase's own rollback column (§13) — not
repeated field-by-field here. Three tiers, by blast radius: **(1)
code/config phases** (0–5, 7–9) — plain `git revert`, low risk, already
stated per-phase. **(2) the schema change (Phase 3)** — the one phase
this document flags as requiring the project's own standing
"stop-and-ask-before-any-schema-change" governance (`PROJ-P-002`,
`CLAUDE.md`), independent of any QF-specific gate; its rollback is
still `git revert` plus, per `DR-2026-0011`'s own design intent, a
schema check built to *tolerate* a missing new field so rollback needs
no forced rebuild. **(3) the data-untracking phase (Phase 6)** — the
highest-risk phase (§13), whose rollback (`git revert` restores
tracking, file unchanged in history) is not invented here but reused
verbatim from `IMPLEMENTATION_PROGRAM.md`'s own pre-existing, owner-
accepted design. At no tier does rollback require a force-push, a
history rewrite, or any destructive git operation — consistent with
this session's own standing constraint against exactly that.

---

## 16. Owner Gates

Kept deliberately short, per the governing instruction not to turn
every technical choice into a gate.

### Real owner gates

1. **Authorization to begin implementation** (Phase 1 onward) — timing/resourcing, unchanged from D1 in the merged owner-decision document.
2. **Personally obtaining QF API developer credentials** (`client_id`/`client_secret`, Phase 1's actual dependency) — this is **not just an owner-gate for planning purposes**: it is a form of external account creation that falls squarely under this session's own standing tool-use safety rules ("Creating accounts… entering passwords to authenticate" is prohibited for any Claude session to perform on the user's behalf). No future session should attempt this even with general permission to proceed technically.
3. **Counsel-routing decision** (R30/D15/D20) — whether/when to send this document plus PR #64's evidence to counsel. Unresolved across six prior sessions (164, 165, 172, 180, 182, now 184); not resolved here either.
4. **The Git-history question** (R18's carve-out, D16 in the merged document) — explicitly **not** raised or recommended by this document, consistent with every prior session. Remains owner+counsel territory only if the owner ever raises it independently.
5. **Formal ratification of `DR-2026-0008`…`DR-2026-0013` onto `main`** — each is individually marked `status: accepted`, `deciders: [duso]` (i.e., the owner already decided the *content*), but none was ever committed anywhere (§2 D3). Landing them is mechanically simple but touches CI/repository structure and carries `reversibility: hard` tags on two of them (`DR-2026-0008`, `DR-2026-0011`) — flagged for explicit owner blessing before a future session commits files this session only read (read-only was this session's mandate for the primary worktree).
6. **`P2-2` closure itself** (R29) — the actual release-gate sign-off; inherently owner+counsel, not a Claude-session decision under any circumstances.

### Auto-decided (technical, within the owner's standing delegation — not re-litigated)

- **Option B** over A/C as the starting architecture (§11–§12).
- **Reuse, don't replace,** `DR-2026-0008`…`0012`'s already-designed storage/versioning/tiered-access architecture for the QF-specific problem.
- **Presentation layer computed at build time** into a separate column (artifact F), not live per-render — revisit only if a concrete reason emerges.
- **Attribution (R17) sequenced independently and now**, not bundled with the full migration — resolves the open D8 choice the merged owner-decision document left pending.
- Exact physical schema layout for the raw/normalized boundary (two columns vs. two tables) — left to the Phase 3 implementation session as a normal engineering detail.

---

## 17. Explicit Non-Goals

This document does **not**:

- Close, or move toward automatically closing, `P2-2`.
- Conclude that the QF email is legally sufficient authorization, retroactively or otherwise.
- Authorize, recommend, or imply Git history rewriting.
- Touch, address, or make any claim about either tafsir dataset (Session 172's scope stays entirely separate).
- Change any code, data, database, ADR/DR, `docs/LICENSING.md` entry, or governance record.
- Rebuild, remove, or modify `assets/database/quran.sqlite`.
- Merge PR #63 or PR #64.
- Commit, merge, or otherwise land `DR-2026-0008` through `DR-2026-0013` onto `main` (read only, this session).
- Request, apply for, or obtain any QF API credential.
- Contact Quran Foundation or send any external communication.
- Declare any technical documentation fetched this session (§3.1) to be a legal conclusion.
- Modify the primary worktree (`publish-docs-reconciliation-s14`) in any way.

---

## 18. Open Unknowns

Carried forward, not resolved:

- Numeric rate-limit thresholds behind the documented `429` class.
- The QF "Request Access" application/approval turnaround time.
- Whether `prelive` access is a mandatory precursor to `production` access.
- Access-token expiry/rotation cadence (distinct from the sync token itself, which §3.1/R05 already address).
- Current Android background-execution capability for *this specific app* — no plugin found today, but that reflects absence-of-addition, not a verified platform ceiling (§9).
- Current iOS background-mode entitlements for this app — not verified this session.
- Whether a Service Worker exists or is planned for the Web build — not found this session, treated as absent, not exhaustively ruled out.
- Whether existing Python tooling (`tool/`) has a dependency-lock mechanism (`requirements.txt` or equivalent) suitable for adding `quran-foundation-api` — not checked this session, flagged for Phase 1.
- Counsel-review turnaround time — entirely owner-dependent.
- Whether QF's "written commercial license" pathway (S10) is even relevant to this project's embed-in-app distribution model — likely **not** triggered, but recorded as UNKNOWN/not-yet-confirmed rather than asserted.
- What, if anything, "Session 183" (referenced in this session's own governing brief) actually did (§2 D1) — this session could not locate any trace of it.

---

## 19. SESSION 185 Recommendation

Given the real owner gates in §16 — particularly that QF credential
acquisition is an account-creation action no Claude session may
perform — **SESSION 185 should not default to starting Phase 1
implementation** unless the owner has, by then, both (a) confirmed
proceeding and (b) personally completed the QF developer-access
request. Absent that, the most productive scope for SESSION 185 is:

1. **Draft (do not send)** the QF developer-access application content
   for the owner's own review and submission — a Category B artifact
   (Claude drafts, owner acts), consistent with this project's
   established pattern for external-facing material.
2. **Draft the counsel-routing packet** — consolidating this document,
   PR #64, and PR #65 into a single owner-forwardable brief, addressing
   the R30/§16 gate without itself routing anything externally.
3. **Raise, explicitly, the `DR-2026-0008`…`0013` ratification question**
   (§16 item 5) as its own short owner decision, separately from the
   QF-specific implementation timeline, since Phase 6 (§13) depends on
   that architecture landing at some point before migration executes.
4. **Only if** the owner has independently obtained QF API credentials
   by the time SESSION 185 begins: start **Phase 1 (source adapter)**
   in isolation, exactly as scoped in §13 — the lowest-risk,
   independently-testable starting point, with no other phase's
   dependencies yet in play.

`P2-2` stays OPEN. This document does not, and could not, change that.

---

## Primary Worktree Safety

| Check | Before this session | After this session |
|---|---|---|
| Primary worktree path | `C:\Users\Admin\Desktop\quran_companion_v0.6.0\quran_companion` | unchanged |
| Branch | `publish-docs-reconciliation-s14` | unchanged |
| HEAD | `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe` | unchanged — not checked out, reset, stashed, cleaned, pulled, rebased, edited, or committed by this session |
| `git status --porcelain` line count | 22 | 22 (re-verified) |
| Stash count | 0 | 0 |

All work this session occurred in
`worktrees/session184-qf-content-sync-requirement-contract`, a fresh
worktree branched from `origin/main` at `4cd08a1f…`. `DR-2026-0008`
through `DR-2026-0013` and `docs/adr/DR-2026-0028`…`0030` were **read
only** from the primary worktree (`Read` tool, no `Write`/`Edit`
calls against that path, ever, this session) — the same read-only
discipline the merged owner-decision document (PR #65) used for PR
#64's unmerged branch. No `git push`, PR creation, or merge was
performed.

---

## References

**Repository — read, not modified, by this session:**

- `docs/release/SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md` (merged, [PR #65](https://github.com/duso201189-nxp/quran-companion/pull/65))
- `docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` (unmerged, [PR #64](https://github.com/duso201189-nxp/quran-companion/pull/64), read via `git show`)
- `docs/release/SESSION_180_QF_RESPONSE_RECONCILIATION.md` (unmerged, [PR #63](https://github.com/duso201189-nxp/quran-companion/pull/63))
- `docs/LICENSING.md`, `docs/DATA_PIPELINE.md`, `docs/release/V1_STORE_LEGAL_READINESS.md`, `RELEASE_DASHBOARD.md`
- `tool/fetch_transliteration.py`, `tool/data/transliteration.json` (structure), `assets/database/quran.sqlite` (existence/size)
- `test/repository_boundary_test.dart`
- `lib/features/quran/data/transliteration_repository.dart`
- `docs/adr/DR-2026-0008` through `DR-2026-0013` (primary worktree, uncommitted, read-only)
- `docs/reports/release-recovery/IMPLEMENTATION_PROGRAM.md`, `ARCHITECTURE_FREEZE_REPORT.md`, `CI_GATE_SPLIT_PLAN.md`, `DATA_SUPPLY_CHAIN.md` (on `main`)

**External — fetched this session:**

- `https://api-docs.quran.foundation/docs/tutorials/content-sync/getting-started/`
- `https://api-docs.quran.foundation/docs/content_apis_versioned/4.0.0/resources-snapshot/`
- `https://api-docs.quran.foundation/legal/developer-terms/`
- OAuth2/client-credentials flow (WebSearch synthesis of `api-docs.quran.foundation/docs/quickstart/` and related pages)
- `quran-foundation-api` PyPI package (WebSearch synthesis)
