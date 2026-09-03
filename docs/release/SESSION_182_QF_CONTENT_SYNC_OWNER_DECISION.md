# Session 182 — QF Content Sync: Decision / Reconciliation (Owner Decision Required)

**Baseline:** `origin/main` at `ad947bc9ee40fb935240a1c46ce0627d546815d2`
**Prepared:** 2026-09-03
**Scope:** Audit-only reconciliation of the Quran Foundation ("QF")
primary-source evidence against current repository state. Produces a
decision matrix and owner-facing options. **No code, data, or Git
history is changed by this document or this session.**

> This document draws no legal conclusion, grants no clearance, and
> closes nothing. It is strictly narrower in scope than
> `SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` (still unmerged, PR #64,
> which performed the actual evidence transcription): this document
> reconciles that evidence against the *current* repository tree
> (`origin/main`) and hands the owner a decision matrix. Where this
> session's own findings differ from what PR #64 recorded, that is
> called out explicitly (§3).
>
> **Session 190 (2026-09-03) addendum — merge-status correction.** PR #64
> merged to `origin/main` at commit `c66032d2add144715e5fceac3a788ef1959f8516`
> (2026-09-03T09:21:29Z). "Still unmerged" above reflects this document's
> own 2026-09-03 pre-merge baseline and is preserved as historical text.

---

## 0. Repository State As Actually Found (verified this session, not assumed)

| Item | Value | How verified |
|---|---|---|
| `origin/main` HEAD | `ad947bc9ee40fb935240a1c46ce0627d546815d2` ("Merge pull request #61 from …session172-tafsir-licensing-audit") | `git ls-remote origin refs/heads/main`, `git log --oneline -1 origin/main` |
| Primary worktree (`…/quran_companion`) | branch `publish-docs-reconciliation-s14`, HEAD `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe`, 22 lines of uncommitted changes (pre-existing, not from this session) | `git status --porcelain`, `git rev-parse HEAD` — captured before and after this session, see §8 |
| **PR #64** — `docs: Session 182 QF primary-source evidence capture` | **OPEN**, not merged, CI green (5/5 checks pass) | `gh pr view 64`, `gh pr checks 64`, `git merge-base --is-ancestor origin/session182-qf-primary-source-evidence origin/main` → not an ancestor |
| **PR #63** — `docs: Session 180 QF response reconciliation (evidence not available)` | **OPEN**, not merged, CI green (5/5 checks pass) | same method |
| `docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` | Exists **only** on branch `origin/session182-qf-primary-source-evidence` (PR #64). **Does not exist on `origin/main`.** | `git ls-tree -r origin/main --name-only` — no match; `git show origin/session182-qf-primary-source-evidence:docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` — 769 lines, present |
| `docs/release/SESSION_180_QF_RESPONSE_RECONCILIATION.md` | Exists **only** on branch `origin/session180-qf-response-reconciliation` (PR #63). **Does not exist on `origin/main`.** | same method |
| The original `.eml` file (`Terms applying to word-by-word transliteration from api.qurancdn.com.eml`) | **Not present anywhere in the repository, any branch, or any PR.** Only its transcription (PR #64 §5) is committed. | `git grep`/`git ls-tree` across `origin/main` and both open PR branches — no `.eml` file tracked; PR #64 §2 itself states the source file "remains outside this repository" |
| `assets/database/quran.sqlite` on `origin/main` | Present, committed, 19,955,712 bytes | `git cat-file -s $(git rev-parse origin/main:assets/database/quran.sqlite)` |
| Content Sync client / sync-token storage / resync scheduler | **Does not exist anywhere in `lib/` or `tool/` on `origin/main`.** | `git grep -i "content.sync\|sync.token\|resource.*60\|apis.quran.foundation"` across `origin/main` — zero hits outside two evidence-packet docs (Session 164, 172) that only *quote* QF's Developer Terms language, and one unrelated Xcode project-file coincidence |
| `tool/fetch_transliteration.py` on `origin/main` | Still calls the **legacy** endpoint `https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` (line 30), not the Content Sync snapshot endpoint. Normalization (`ALLAH_MAP`, `normalize_words`) runs at fetch/build time, before storage — not as a separate presentation layer. | direct read of the file at `origin/main` |
| `docs/LICENSING.md` P2-2 (item 2, "Phiên âm Latin") | **CHƯA XÁC ĐỊNH / UNKNOWN** — repo does not establish upstream licence/permission | direct read, line 58 |
| `docs/release/V1_STORE_LEGAL_READINESS.md` P2-2 | **OPEN** — "Transliteration source (Quran.com QDC) is not individually named in the in-app attribution string… which licence or permission governs the dataset remains CHƯA XÁC ĐỊNH / UNKNOWN" | direct read, ~line 610 |
| `RELEASE_DASHBOARD.md` | Tracks `P2-2` as **OPEN**, "UNKNOWN — COUNSEL REQUIRED" | direct read, lines 720, 1108, 1176 |
| Target document (`SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md`) | **Did not exist** anywhere (no commit, no branch, no PR) before this session | `git log --all --oneline -- "*SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION*"` — empty; `gh pr list --search` — empty |

**Discrepancy note:** the session brief refers to the QF evidence file as
already "existing in the repository." As found, it exists only on an
**unmerged** PR branch (#64), not on `origin/main`. This document treats
that as the actual state and proceeds by reading the PR branch content
directly (`git show <ref>:<path>`, a read-only operation), rather than
assuming it is merged.

> **Session 190 (2026-09-03) addendum — merge-status correction.** The
> table above (rows for PR #64 and PR #63) and the discrepancy note both
> describe a since-changed state: PR #64 merged at
> `c66032d2add144715e5fceac3a788ef1959f8516` (2026-09-03T09:21:29Z) and
> PR #63 merged at `bf87aca6c5d40f7fa57c099e84ca94f9c125a0e0`
> (2026-09-03T09:23:45Z). Both `SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`
> and `SESSION_180_QF_RESPONSE_RECONCILIATION.md` are now present on
> `origin/main`. The "OPEN" / "does not exist on `origin/main`" statuses
> above are preserved unedited as this document's own 2026-09-03
> pre-merge baseline, not current state.

---

## 1. Evidence Chain — What Was Actually Read

1. **`docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`** (PR #64,
   commit `0214db3`) — 769 lines, read in full. Transcribes a complete
   `.eml` export of a reply from **Basit Minhas (`basit@quran.com`)**,
   signed "Quran Foundation," dated 2026-08-30, replying to the Q1–Q12
   enquiry Session 166/167 recorded as sent 2026-08-29. Contains 15
   quoted clauses (§6 of that document, "S1"–"S15"), a requirement
   matrix, a 12-question answer table, a Session 164–181 reconciliation,
   a 20-question red-team table, and an explicit non-conclusions list.
2. **`docs/release/SESSION_180_QF_RESPONSE_RECONCILIATION.md`** (PR #63,
   commit `8dd1795`) — read in full. Records that *at the time it was
   written*, no QF response text was available to that session, and
   that Sessions 174/175/176/179 left no committed evidence. Superseded
   in fact-finding terms by PR #64, which supplies the actual email PR
   #63 could not access — but PR #63 remains open and unmerged in its
   own right, and its methodology notes (e.g., on Git-history questions,
   §9 of that document) still stand.

   > **Session 190 (2026-09-03) addendum — merge-status correction.** PR
   > #63 merged to `origin/main` at commit
   > `bf87aca6c5d40f7fa57c099e84ca94f9c125a0e0` (2026-09-03T09:23:45Z). The
   > "remains open and unmerged" description above is preserved as
   > historical text from this document's 2026-09-03 pre-merge baseline.
3. **Current `origin/main` tree** — read directly (not from either PR)
   for: `tool/fetch_transliteration.py`, `tool/data/transliteration.json`
   (existence only, not diffed line-by-line — not necessary for this
   audit's scope), `assets/database/quran.sqlite` (existence + size),
   `docs/LICENSING.md`, `docs/DATA_PIPELINE.md`,
   `docs/release/V1_STORE_LEGAL_READINESS.md`, `RELEASE_DASHBOARD.md`.

No other source was consulted. No external website, email, or contact
was made by this session.

---

## 2. FACT / INFERENCE / UNKNOWN

### FACT (directly stated in the PR #64 transcription, or directly observed in the repository)

- QF (via Basit Minhas, `basit@quran.com`, Cc `developers@quran.com`,
  2026-08-30) replied to the project's 2026-08-29 enquiry regarding the
  word-by-word Latin transliteration dataset fetched from
  `api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` on 2026-07-06.
- Google's mail-authentication check on receipt reported `dkim=pass`,
  `spf=pass`, `dmarc=pass` for the `quran.com` sending domain — a
  technical mail-authenticity signal, not a legal determination of
  authority to bind Quran Foundation.
- **Resource identification:** resource group
  `word_by_word_transliterations`, production resource ID `60`, snapshot
  endpoint
  `https://apis.quran.foundation/content/api/v4/resources/snapshots/word_by_word_transliterations/60`,
  incremental record type `word_transliteration`. Explicitly
  distinguished from a different, unused resource
  `word_by_word_translations`.
- **Sync requirement:** migrate to Content Sync; retain a sync token;
  perform incremental sync "at least once every 7 days" and "apply all
  available changes"; "Quran Foundation must remain the source of
  truth." The email does **not** state how a sync token is issued,
  authenticated, or rotated.
- **Attribution:** exact string `"Quran data provided by Quran
  Foundation."`, with "Quran Foundation" linked to
  `https://quran.foundation/`, placed in "a reasonably visible About,
  Credits, or data-source area of the app."
- **App-store/commercial permission:** an application **containing**
  the content may be distributed via Google Play or the Apple App
  Store, free or commercial, "as long as the content is part of the
  application's end-user experience." Standalone redistribution (as a
  separate dataset, feed, API, or content package) requires "a written
  commercial license" — terms, price, and process not given.
- **Raw SQLite / public repository:** "Because the SQLite file is
  currently present in the public source repository, please remove the
  raw dataset from the repository before release; the application code
  itself may remain public." This is stated as a pre-release condition,
  not a statement about Git history.
- **Normalization / presentation-layer rule:** normalization is
  permitted **only** "purely for display," kept as "a separate
  presentation layer," and must never be "represent[ed]… as the
  original QF source." The email says the *currently shipped, already
  normalized-at-build-time* dataset should be **replaced** with Content
  Sync values — it does not say the current implementation is
  acceptable as-is.
- **Derivative dataset rule:** "Please contact us before distributing
  any altered derivative dataset" — a standing, forward-looking
  condition not satisfied by the email itself.
- **What the email does NOT confirm** (explicit in PR #64 §16/§18/§19):
  it is not a signed commercial licence; it does not address either of
  the two tafsir datasets (Session 172); it does not resolve authorship
  or upstream ownership of the transliteration text (Session 165 Q11);
  it does not state a position on the period between the 2026-07-06
  retrieval and now (no retroactive statement either way); it does not
  say the sender has organizational authority to bind Quran Foundation;
  it does not say the currently-shipped, currently-committed dataset is,
  today, compliant with anything.
- **Repository fact (independently verified this session, not merely
  cited from PR #64):** no Content Sync client, sync-token storage, or
  resync scheduler exists in `lib/` or `tool/` on `origin/main`. The
  fetch script still targets the legacy endpoint. The raw SQLite file is
  still committed and present in the public repository. `P2-2` is
  recorded as OPEN in all three governance documents that track it.

### INFERENCE (a reasonable reading, not itself authorization or legal clearance)

- The email is plausibly the genuine reply to the genuine enquiry
  (consistent Cc, threading, subject, one-day gap, passing mail
  authentication) — but "plausibly genuine and on-topic" is a factual/
  authenticity inference, not a legal determination that its contents
  bind Quran Foundation or satisfy any "written" requirement elsewhere
  in QF's own terms.
- Read narrowly, the email implies that **completing** the described
  Content Sync migration and remediation steps would bring this
  specific dataset into a position QF describes as acceptable going
  forward. This is an inference about a **future state after
  remediation**, not a statement that the dataset is acceptable now, and
  not a substitute for the counsel review PR #64 itself calls for (§17).
- The absence of any mention of retroactive authorization can be read
  either way (silence is not itself permission or prohibition) — this
  document treats it as UNKNOWN, per the safety rules governing this
  session, not as an inferred "no objection."

### UNKNOWN / COUNSEL REQUIRED

- Whether an email from a named individual, Cc'd to a shared alias,
  legally satisfies whatever standard is needed to close `P2-2` — for
  the pre-remediation period, the post-remediation period, or both.
- Whether Basit Minhas has organizational authority to bind Quran
  Foundation to the statements made.
- Authorship/upstream ownership of the transliteration text (Session
  165 Q11) — unaddressed by the email.
- Applicability of the Quran.com site Terms and Conditions (as opposed
  to the Developer Terms, which the email invokes by name) to this
  dataset.
- Which version of QF's terms was operative for the 2026-07-06
  retrieval specifically.
- Terms, cost, and process for the "written commercial license"
  mentioned for standalone redistribution (not applicable to this
  project's current embedded-in-app distribution model, per the email's
  own distinction, but relevant if that model ever changes).
- Whether the tafsir datasets (Session 172, Decision C) are affected —
  they are not; this stays a fully separate, unresolved question.
- Whether removing the raw file from a **future commit** (leaving it
  recoverable from Git history) satisfies "remove the raw dataset from
  the repository," or whether history rewriting would be expected —
  **the email does not say**, and no prior session (164, 165, 172, 180,
  182) raises Git-history rewriting as a requirement anywhere. This
  document does not resolve that gap; it flags it as owner/counsel
  territory (D16 below).

---

## 3. Where This Session's Findings Differ From PR #64's Framing

None materially. This session independently re-verified (rather than
merely re-citing) the repository-fact claims PR #64 made about
`tool/fetch_transliteration.py`, `assets/database/quran.sqlite`, and the
absence of any Content Sync implementation, and found them accurate as
of the current `origin/main` tip. No contradiction was found. The one
addition this document makes is procedural, not factual: PR #64 itself
is **still unmerged**, so anything built "on top of" it (this document
included) is built on an evidence base that has not yet landed on
`main` — a fact this document surfaces explicitly rather than assuming
away.

> **Session 190 (2026-09-03) addendum — merge-status correction.** PR #64
> merged to `origin/main` at commit `c66032d2add144715e5fceac3a788ef1959f8516`
> (2026-09-03T09:21:29Z). The "still unmerged" statement above is
> preserved as historical text from this document's 2026-09-03 pre-merge
> baseline; the evidence base has since landed on `main`.

---

## 4. Decision Matrix

Every row: **Current state**, **Evidence**, **Risk**, **Required
action**, **Owner gate**.

### D1 — Content Sync migration (overall)
- **Current state:** Not started. No design, no code, no dependency added.
- **Evidence:** PR #64 §8 (migration steps); repo grep confirms zero implementation.
- **Risk:** Continuing to ship the legacy-endpoint dataset indefinitely leaves the gap QF flagged (S6) unresolved.
- **Required action:** Owner decides whether to pursue, defer, or seek counsel first (see §5 options).
- **Owner gate:** **YES**

### D2 — Resource 60 (`word_by_word_transliterations`)
- **Current state:** Identified by QF, not yet integrated anywhere in code.
- **Evidence:** PR #64 §6 S3, §7.
- **Risk:** None from identification alone; risk is in D1 (whether/when to act on it).
- **Required action:** No action needed to merely record the identifier; implementation is a separate, larger decision (D1).
- **Owner gate:** NO (informational; folds into D1)

### D3 — Snapshot / incremental sync mechanism
- **Current state:** Endpoint named (`…/resources/snapshots/word_by_word_transliterations/60`); mechanics (auth, pagination, response shape) not fetched or documented by any session.
- **Evidence:** PR #64 §7–§8, §19.
- **Risk:** Any implementation estimate made without reading the linked tutorial/reference docs would be speculative.
- **Required action:** If D1 proceeds, a future session must read `https://api-docs.quran.foundation/docs/tutorials/content-sync/getting-started/` and the snapshot reference before scoping engineering work — explicitly **not done** in this session (reading external docs is implementation research, outside this audit's scope).
- **Owner gate:** NO (technical scoping, gated by D1's YES)

### D4 — Sync token lifecycle
- **Current state:** Requirement to retain a token is explicit; issuance/rotation/format is not stated anywhere in the evidence.
- **Evidence:** PR #64 §7 row "Sync token," §19.
- **Risk:** Unknown secret-handling requirements could affect where/how a token is stored (e.g., whether it needs secret-safe storage vs. a plain local file).
- **Required action:** UNKNOWN pending external doc review (see D3). No action possible yet.
- **Owner gate:** NO (blocked on D3)

### D5 — 7-day sync requirement
- **Current state:** Explicit, standalone requirement ("at least once every 7 days," "apply all available changes") — not an inference from a caching-ceiling clause (PR #64 §14 explicitly notes this refines/confirms a caution raised in Session 180).
- **Evidence:** PR #64 §6 S7, §7.
- **Risk:** If migration proceeds without an ongoing resync mechanism, the app would fall out of the described pathway shortly after any one-time sync.
- **Required action:** If D1 is authorized, this becomes a hard functional requirement for whatever sync mechanism is built (D11/D12).
- **Owner gate:** NO (folds into D1/D12)

### D6 — Raw QF transliteration values
- **Current state:** Repository stores values already normalized at fetch/build time (`ALLAH_MAP`, `normalize_words` in `tool/fetch_transliteration.py`), not raw QF values with normalization applied at presentation time.
- **Evidence:** PR #64 §11; independently confirmed this session by reading `tool/fetch_transliteration.py` on `origin/main`.
- **Risk:** This is a **gap** between current implementation and the pathway QF describes (S12–S13) — not, by itself, a compliance verdict (PR #64 §18 explicitly declines to make that verdict, and this document does not make it either).
- **Required action:** If D1 proceeds, this gap is one of the things a migration would need to close (fetch raw Content Sync values, defer normalization to presentation layer).
- **Owner gate:** NO (folds into D1/D7)

### D7 — Normalized presentation layer
- **Current state:** Does not exist as a separate layer; normalization is baked into the stored dataset.
- **Evidence:** same as D6.
- **Risk:** Same as D6.
- **Required action:** Architectural change (build-time normalization → presentation-time normalization) if D1 proceeds. Non-trivial: touches `tool/fetch_transliteration.py`, `tool/build_quran_db.py` (referenced, not independently re-read this session), and any UI code that currently reads the pre-normalized column.
- **Owner gate:** NO (folds into D1; but the *architecture decision* itself, once scoped, likely needs its own ADR/DR per this repo's established governance pattern — not decided here)

### D8 — Attribution
- **Current state:** Current in-app attribution string (`aboutSourcesDetail`, `lib/l10n/app_en.arb`/`app_vi.arb`, line 222 per PR #64 §9) does not name Quran Foundation, Quran.com, or QDC at all.
- **Evidence:** PR #64 §9, quoting the current string; exact required string/link/placement given by QF (S15).
- **Risk:** Low technical risk, but the *decision* to add wording implying a compliance relationship with QF before the underlying dataset/sync question (D1) is resolved could be read as representing a compliance posture the app has not yet achieved.
- **Required action:** Owner decision: add attribution now (independently, low-risk, reversible — as Sessions 164/165/180/182 all note as available) vs. bundle it with the full D1 migration so attribution and actual compliance land together.
- **Owner gate:** **YES** (small, but explicitly a choice — see §5 Option set for D8)

### D9 — Raw SQLite removal from public repository
- **Current state:** `assets/database/quran.sqlite` (19,955,712 bytes) is committed and present on `origin/main` today.
- **Evidence:** QF: "please remove the raw dataset from the repository before release; the application code itself may remain public" (S11). Verified this session that the file is in fact committed and present.
- **Risk:** This is the single most concrete, unambiguous, pre-release condition QF stated. It is also the one most likely to be conflated with Git-history rewriting (D16) if acted on carelessly.
- **Required action:** **No action taken by this session** (explicitly out of scope — "Không sửa data"). Owner must decide the removal approach (see §5 Option set for D9/D16) before any implementation session touches this file.
- **Owner gate:** **YES**

### D10 — DB rebuild
- **Current state:** Not performed. `assets/database/quran.sqlite` on `origin/main` still reflects the 2026-07-06 legacy-endpoint fetch (per DATA_PIPELINE.md's own history notes — Session 161 corrected source metadata but a full rebuild status is tracked separately in that document, not re-verified byte-for-byte in this session).
- **Evidence:** `docs/DATA_PIPELINE.md` history block; PR #64 §8.
- **Risk:** A rebuild is only meaningful once D1 (migration source) and D6/D7 (raw-vs-normalized storage) are decided — rebuilding against the legacy endpoint again would not close any gap QF identified.
- **Required action:** Do not rebuild until D1/D6/D7 are decided; rebuilding now would reproduce the same gap.
- **Owner gate:** NO (blocked on D1)

### D11 — Offline-first behavior
- **Current state:** App currently ships a static, bundled SQLite dataset with no network dependency for transliteration at runtime.
- **Evidence:** PR #64 §8 repository-fact note; QF permits offline/local storage but **conditions** it on Content Sync migration (S2, S8).
- **Risk:** If D1 is authorized, introducing a periodic sync requirement changes the app's runtime network/connectivity assumptions for this feature — a product-behavior change, not just a data-pipeline change.
- **Required action:** Product/UX decision (does the app need network access periodically to stay compliant, and what happens offline for extended periods?) — not decided here.
- **Owner gate:** NO (folds into D1, but flagged as having product-level, not just data-pipeline, implications)

### D12 — Scheduler / background sync
- **Current state:** No scheduler, background task, or periodic job exists for this purpose anywhere in `lib/`.
- **Evidence:** repo grep, this session; PR #64 §8.
- **Risk:** Implementing a 7-day background resync is new infrastructure (platform-specific background execution, retry/backoff, failure handling) — non-trivial engineering scope, not estimated by any session to date.
- **Required action:** Requirement-contract/scoping session, per PR #64 §20 step 2 — explicitly **not done** here.
- **Owner gate:** NO (blocked on D1)

### D13 — Dependency / runtime implications
- **Current state:** No Content Sync SDK or client dependency has been added to `pubspec.yaml` or elsewhere. QF's email mentions a Python package (`quran-foundation-api==0.3.0`) with a "Content Sync helper" — this is a Python tool, not a Flutter/Dart runtime dependency, and the project's `tool/` scripts are Python while the shipped app is Flutter/Dart.
- **Evidence:** PR #64 §5 (email body, final paragraph); this session's own read confirming `tool/fetch_transliteration.py` is Python, invoked at build/data-pipeline time, not at app runtime.
- **Risk:** Confusing "a build-time Python fetch tool can use this SDK" with "the shipped Flutter app needs a new runtime dependency" would misscope the work. The email's own architecture (fetch → local SQLite → ship) suggests migration could remain build-time-only (re-run the fetch/sync step, rebuild the DB, ship the updated file) rather than requiring an in-app network client — but this is not stated by QF and is an implementation-architecture choice, not a legal one.
- **Required action:** Scoping session must decide build-time-only vs. runtime-sync architecture before estimating dependencies.
- **Owner gate:** NO (technical scoping, blocked on D1)

### D14 — Derivative dataset handling
- **Current state:** No altered derivative of the transliteration dataset has been distributed outside this repository's own shipped app, to this session's knowledge.
- **Evidence:** PR #64 §11, S14 ("Please contact us before distributing any altered derivative dataset").
- **Risk:** Low today (no such distribution has occurred); relevant only if the project ever ships the dataset itself as a separate artifact (e.g., a public API, a downloadable file, a second app) rather than embedded in this one app.
- **Required action:** No action needed now; record as a standing constraint for any future distribution decision.
- **Owner gate:** NO (no current trigger)

### D15 — Legal / counsel dependency
- **Current state:** No counsel review of the QF email has occurred (explicit in PR #64 §16, §17).
- **Evidence:** PR #64 §17, §18.
- **Risk:** Proceeding with implementation (D1) or declaring `P2-2` closed without counsel input risks acting on a self-made legal conclusion — exactly what this session and PR #64 are both structured to avoid.
- **Required action:** Owner decides whether to route this to counsel before, during, or independent of the D1 implementation decision (§5).
- **Owner gate:** **YES**

### D16 — Git history question
- **Current state:** No session (164, 165, 172, 180, 182, or this one) has found any QF statement, or any other basis, requiring Git history to be rewritten/purged. The QF email's own wording ("remove the raw dataset from the repository before release") is about the dataset's presence going forward, not explicitly about history.
- **Evidence:** PR #64 §18 ("removing `assets/database/quran.sqlite` from Git, or rewriting Git history, is [not] authorized, recommended, decided, or under active implementation by this document"); PR #63 §9 (Session 180) independently flags this as "not established by any evidence, anywhere… a novel, unsupported, and irreversible step."
- **Risk:** Git history rewriting is irreversible for any existing clone/fork and would need explicit, informed owner authorization — never inferred from "remove the raw dataset."
- **Required action:** **None from this session.** This document explicitly does not recommend, decide, or imply history rewriting. If the owner ever wants this evaluated, it needs its own dedicated decision session with its own risk analysis (force-push implications, existing forks/clones, CI/tag history, etc.) — not folded into a data-removal decision.
- **Owner gate:** **YES** (if ever raised — not raised by this document)

### D17 — Current release compliance
- **Current state:** The app has not been released to a commercial app store yet (per `docs/release/V1_STORE_LEGAL_READINESS.md` tracking `P2-2` as an open pre-release item). As shipped/committed today, the dataset does not meet the pathway QF describes (legacy endpoint, no Content Sync, no attribution naming QF, raw file public).
- **Evidence:** PR #64 §16, §18; `V1_STORE_LEGAL_READINESS.md` P2-2 entry.
- **Risk:** Releasing before remediation would run counter to QF's own "before releasing the app, please…" framing throughout the email.
- **Required action:** Treat `P2-2` as a release blocker until the owner decides D1/D8/D9 (at minimum) and any counsel input is obtained.
- **Owner gate:** **YES** (this is the release-gate decision)

### D18 — Rollback strategy
- **Current state:** Not applicable yet — nothing has been implemented to roll back. Relevant only once D1 begins.
- **Evidence:** N/A (no implementation exists).
- **Risk:** None currently.
- **Required action:** Any future implementation session for D1 should define a rollback path (e.g., ability to revert to the current static dataset) as part of its own plan — not specified here.
- **Owner gate:** NO (premature; revisit when D1 is scoped)

### D19 — Test / evidence requirements
- **Current state:** This document itself has been validated for encoding/line-ending/secret-scan hygiene consistent with this repository's established pattern (see §8). No code tests apply, since no code changed.
- **Evidence:** §8 below.
- **Risk:** None.
- **Required action:** None beyond what §8 records.
- **Owner gate:** NO

### D20 — Owner decision required
- **Current state:** Summarized in §5.
- **Evidence:** All of the above.
- **Risk:** Proceeding on any of D1/D8/D9/D15/D17 without an explicit owner choice would exceed this session's mandate.
- **Required action:** See §5.
- **Owner gate:** **YES**

---

## 5. Owner Decision Options

### For D1 (Content Sync migration path) / D17 (release gate)

- **Option A — Pursue migration now.** Authorize a dedicated
  requirement-contract/scoping session (reads the QF tutorial/reference
  docs, scopes sync client + token storage + scheduler + presentation-
  layer refactor + raw-file removal + attribution, produces an ADR/DR
  per this repo's governance pattern) **before** any implementation
  touches `lib/`, `tool/`, or `assets/database/`.
- **Option B — Defer migration, keep `P2-2` open as a release blocker.**
  Do not release to app stores until D1 is resolved; no new work
  authorized this cycle.
- **Option C — Seek counsel review first, then decide.** Send this
  document and PR #64's evidence to counsel before authorizing any
  scoping or implementation work, since D15 (counsel dependency) is
  unresolved regardless of which technical path is chosen.

### For D8 (attribution string)

- **Option A — Add now, independently.** Small, low-risk, reversible;
  does not require D1 to be resolved first (Sessions 164/165/180/182 all
  note this as available on its own schedule).
- **Option B — Bundle with D1.** Land attribution together with the
  full migration so the app's stated data-source claims and its actual
  data pipeline change together.

### For D9 (raw SQLite in public repo) / D16 (Git history)

- **Option A — Remove in a future commit only (history untouched).**
  Satisfies the literal wording "remove the raw dataset from the
  repository" for the current/future state; the file remains
  retrievable from Git history by anyone who clones the repo.
- **Option B — Remove and rewrite history (e.g., `git filter-repo`).**
  Removes retrievability from history entirely; irreversible, affects
  all existing clones/forks, requires its own dedicated risk-assessment
  session — not evaluated by this document.
- **Option C — Defer the removal decision until D1 is scoped**, since
  removing the raw file only makes sense once a replacement
  (Content-Sync-sourced, or otherwise) data path exists — removing it
  with no replacement would break the app's current offline dataset
  entirely.

### For D15 (counsel routing)

- **Option A — Route now**, independent of the technical decision (D1),
  since counsel input does not require the technical path to be chosen
  first.
- **Option B — Route after technical scoping (Option A of D1)**, so
  counsel reviews a concrete plan rather than raw evidence alone.
- **Option C — Do not route to counsel at this time**; accept `P2-2` as
  open indefinitely and treat it purely as a release blocker (D17)
  without seeking external legal input.

---

## 6. Explicit Non-Conclusions (this document)

This document does **not** conclude, state, or imply:

- That `P2-2` is closed, closable, or trending toward closure.
- That the QF email constitutes retroactive authorization for the
  2026-07-06 retrieval or for any period before remediation.
- That the QF email is an unrestricted dataset-redistribution licence.
- That the QF email authorizes keeping the raw SQLite file public,
  in the repository or in Git history.
- That the current build-time normalization is, as implemented,
  compliant with the presentation-layer rule QF described.
- That the tafsir datasets (Session 172) are addressed in any way.
- That Git history should, or should not, be rewritten.
- That the current release (as shipped/committed) is compliant with
  anything QF has stated.
- That any code, data, database, or Git history has been changed by
  this session — none has (§8).

---

## 7. References

**Repository — read, not modified, by this session:**

- `docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` (unmerged, [PR #64](https://github.com/duso201189-nxp/quran-companion/pull/64))
- `docs/release/SESSION_180_QF_RESPONSE_RECONCILIATION.md` (unmerged, [PR #63](https://github.com/duso201189-nxp/quran-companion/pull/63))
  - _Session 190 (2026-09-03) addendum: both PRs merged to `origin/main`
    — PR #64 at `c66032d2add144715e5fceac3a788ef1959f8516`
    (2026-09-03T09:21:29Z), PR #63 at
    `bf87aca6c5d40f7fa57c099e84ca94f9c125a0e0` (2026-09-03T09:23:45Z)._
- `docs/release/SESSION_164_QDC_LICENSING_EVIDENCE_PACKET.md`
- `docs/release/SESSION_165_QDC_OWNER_DECISION_BRIEF.md`
- `docs/release/SESSION_172_TAFSIR_LICENSING_EVIDENCE_PACKET.md`
- `docs/LICENSING.md`
- `docs/DATA_PIPELINE.md`
- `docs/release/V1_STORE_LEGAL_READINESS.md`
- `RELEASE_DASHBOARD.md`
- `tool/fetch_transliteration.py`
- `assets/database/quran.sqlite` (existence/size only)

**External:** none consulted this session (no email sent, no website
fetched, no contact made — out of scope per the governing instructions).

---

## 8. Primary Worktree Safety

| Check | Before this session | After this session |
|---|---|---|
| Primary worktree path | `C:\Users\Admin\Desktop\quran_companion_v0.6.0\quran_companion` | unchanged |
| Branch | `publish-docs-reconciliation-s14` | unchanged |
| HEAD | `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe` | unchanged — not checked out, reset, stashed, cleaned, pulled, rebased, edited, or committed by this session |
| `git status --porcelain` line count | 22 | unchanged (re-verified after this session — see final report) |
| Stash count | 0 | unchanged |

All work in this session occurred exclusively in a fresh worktree,
`worktrees/session182-qf-content-sync-owner-decision`, branched from
`origin/main` at `ad947bc9ee40fb935240a1c46ce0627d546815d2`. No `git
push`, no PR creation, and no merge was performed by this session.
