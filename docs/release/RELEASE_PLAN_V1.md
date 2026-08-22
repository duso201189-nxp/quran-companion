# Release Plan — v1.0

Written after PR #19 (Sprint S2 — Quality & Polish), the final merge
of a long feature-recovery engagement (P1–P4 infrastructure, F1–F8
feature verticals: Lexicon, Flashcards, Analytics, AI Tutor, Learning
Journey, Smart Learning, Read Model, Learning Session wiring). This
document evaluates release readiness against the **actual current
code**, not against `ROADMAP.md`/`TODO.md`/`CHANGELOG.md`/`pubspec.yaml`
— see §0 for why those specifically should not be trusted as the
current source of truth right now.

---

## 0. A documentation-debt finding that affects this whole plan

`pubspec.yaml` still declares `version: 0.8.1+7`. `CHANGELOG.md`'s
`[Unreleased]` section stops at "Sprint 10: Learning Engine" — it has
no entry for any of P1–P4, F1–F8, or Sprint S2. `ROADMAP.md`'s 12-step
table still shows step 9 ("Flashcard SM-2 + Quiz + Thống kê") as
partially done with "Flashcard hoãn lại có chủ đích" (Flashcards
deliberately deferred) — but Flashcards (F2) is fully built and merged.
`TODO.md` has the same gap. `CLAUDE.md` states "Currently mid Step 8 of
12 (v0.8.1)."

**None of this reflects the current repository.** The feature work in
this repo has substantially overshot what these four files describe —
Lexicon, Flashcards, Analytics, AI Tutor, Learning Journey, Smart
Learning, and Learning Session wiring are all merged and gated, and
Read Model has had a shipped UI since Phase 3 Sprint R2 (§1) — **this
parenthetical previously said Read Model had no UI yet; corrected in
this pass**, since that was true only until 2026-07-31. This appears to
be a side effect of
how this engagement's mega-commit decomposition happened outside the
normal per-sprint versioning/changelog workflow. **Reconciling these
four files (version bump, CHANGELOG backfill, ROADMAP/TODO status
update) should be its own small, first task before anything else in
this plan** — otherwise every subsequent release-prep step is working
from a map that doesn't match the territory.

## 1. What "done" actually looks like right now

Confirmed via direct code inspection
([MODULE_CATALOG.md](../architecture/MODULE_CATALOG.md) has the full
per-feature detail):

| Area | Status |
|---|---|
| Reading (Surah list, reading screen, audio, bookmarks/highlights/notes) | Built, shipped in earlier releases, unaffected by this engagement |
| Search | Built **and** wired to the real FTS5 engine — **stale since 2026-07-31, corrected in this pass**: this row previously said engine wiring was "a separate, still-open item," which §4 item 3 already marked done (Phase 3 Sprint R1, commit `0f3f751`, `search_index_content` holds 43,652 real rows). No placeholder path remains. |
| Stats/Dashboard, Khatm, Daily Goal, Revision Queue | Built (Sprint 8–9) |
| Learning Engine (SRS scheduler, Review Session, Quiz) | Built (Sprint 10 / G7) |
| Lexicon, Flashcards, Analytics, AI Tutor, Learning Journey, Smart Learning | Built and merged (F1–F6) |
| Read Model | Built and merged (F7); **has a shipped UI** — **stale since 2026-07-31, corrected in this pass**: this row previously said "no UI consumes it yet, infrastructure-only," which §4 item 4 already marked done (`StudySummaryScreen`, Phase 3 Sprint R2, reachable via a CTA from `SmartLearningScreen` as of Sprint R3.1). |
| Learning Session wiring (unifies Review/Quiz/Flashcard into one session) | Built and merged (F8) |
| Reliability layer (structured failures, Logger, CrashReporter) | Built, and as of Sprint S2, actually wired end-to-end (was previously half-dead) |

This is, in substance, most of what `ROADMAP.md` calls "v1.5" scope
(vocabulary, flashcards, quiz, stats, khatm), already built under a
`v0.8.1` version string. The version number and the feature set have
diverged — see §0.

## 2. Remaining blockers for a real v1.0 release

Blockers = things that must be true before this ships to an app store,
not "nice to have." Sourced from `RELEASE_CHECKLIST.md`'s own
still-open items (independently verified there, not re-derived here)
plus this engagement's `UPDATED_TECHNICAL_DEBT.md`.

### Store & legal (from `RELEASE_CHECKLIST.md`, still open)
- App icon (1024×1024, adaptive Android + iOS set), splash screen,
  store screenshots (iPhone 6.7"/5.5", iPad 12.9", Android
  phone/tablet).
- Privacy Policy URL, Terms of Use, Apple Privacy Manifest
  (`PrivacyInfo.xcprivacy`) + App Privacy labels, Google Play Data
  Safety form.
- Confirm Tanzil's non-commercial translation license terms are
  compatible with the intended release model (free app) — not yet
  formally confirmed.
- Android `applicationId` (`com.duso.qurancompanion`) registered on
  Play Console to match; iOS Apple Developer Program enrollment,
  certificate + profile, TestFlight; Google Play Console internal
  testing track set up.

### Platform completeness (from `RELEASE_CHECKLIST.md`, still open)
- ~~**Web platform is currently broken**~~ — **closed** (Phase 3 Sprint
  R3a, 2026-08-03). `web/sqlite3.wasm` and `web/drift_worker.js` are
  vendored (version-matched to `pubspec.lock` — `sqlite3-3.3.4`,
  `drift-2.34.0`) and verified working in a real browser: both
  databases open, Surah list renders, FTS5 Search returns real results,
  a bookmark write persisted across a full reload, zero console errors.
  A CI guard now fails `build-web` if either file is later removed. See
  `RELEASE_DASHBOARD.md` §2 "Sprint R3a" and
  `docs/release/PHASE3_SPRINT_R3A1_REPORT.md` through `_R3A3_REPORT.md`.
  **Still open**: no hosting target has been chosen, so the fastest
  storage tier (OPFS, needs COOP/COEP headers) is unverified in
  practice — the verified IndexedDB tier is fully functional, so this
  is a performance question, not a "ship or defer" one anymore.
- Background audio playback (`audio_service` + platform manifest
  entries) not implemented — `AudioController` currently only plays in
  foreground.
- Audio cache management UI in Settings not built (the underlying
  `IoCacheManager` engine exists but is never wired in — this is also
  `UPDATED_TECHNICAL_DEBT.md` D5).

### Verification gaps (from `RELEASE_CHECKLIST.md`, still open)
- No real screen-reader (TalkBack/VoiceOver) accessibility audit has
  been run on a device — only functional manual testing and code-level
  review so far.
- `PERFORMANCE.md`'s "Android mid-range device" column is still
  unmeasured — only a Windows-desktop dev-machine number exists
  (161.6ms time-to-first-frame), explicitly flagged in that document as
  not a substitute.
- 16 outdated packages, including 2 major-version gaps
  (`flutter_riverpod` 2→3, `go_router` 14→17) and `sqlite3_flutter_libs`
  marked `+eol` upstream — none upgraded yet; each needs its own
  regression pass before bumping per `README.md`'s dependency-update
  process.
- ~~CI coverage gate is at 70%, not the 80% target~~ — **closed**
  (Phase 3 Sprint R3.2, `DR-2026-0015`). Re-measured at 81.54% on
  hand-written code (generated sources excluded); gate raised to 80.
  All four measured figures and the full rationale are disclosed in
  `RELEASE_DASHBOARD.md` §2.
- **Arabic / RTL is barely exercised by the test suite.** Surfaced by
  the R3.2 coverage measurement: the generated Arabic string table was
  4.3% covered against 69.3% for English — the same file structure,
  differing only in which locale tests set. `DR-2026-0015` excludes
  those generated files from the coverage metric (they are not the
  right instrument for this), so this gap is recorded here instead of
  being lost with them. It is **not** closed. Related to, but distinct
  from, the screen-reader audit above: this one is about RTL layout,
  text overflow, and locale-specific formatting under `ar`.

### Known engineering gaps from this engagement's own audits
- ~~**D3**~~ (`UPDATED_TECHNICAL_DEBT.md`) — **resolved, Phase 3 Sprint
  R2 (2026-07-31)**. Previously: Read Model (F7) had zero UI consumers,
  and this document asked for an explicit product decision — ship a
  screen or scope it out. The decision made was to ship one:
  `StudySummaryScreen` (route `/study-summary`), reachable via a CTA
  from `SmartLearningScreen` as of Sprint R3.1. See
  `RELEASE_DASHBOARD.md` §2 "Sprint R2." **This entry was left
  describing D3 as open through Sprints R3.2, R3a, and R3b** despite
  being closed at R2 — corrected in this release-tracking pass, not at
  the time it actually closed; flagged as its own finding in
  `docs/release/PHASE3_RELEASE_TRACKING_FINAL_REPORT.md`.
- **D8**: a soft-delete filter and an upsert pattern are duplicated
  across 9+ repository files. Not a correctness bug (tests pass,
  behavior is consistent), but real duplication debt — recommended as
  its own dedicated, carefully-regression-tested sprint before v1.0 if
  time allows, not required to ship.
- The 8 Lexicon tables declared in the Drift schema **are now present
  in the shipped `assets/database/quran.sqlite` asset — verified by
  opening the actual asset directly, not just from code comments —
  but every one of them is completely empty (0 rows)**. Code comments
  in three places (`content_tables.dart`, `app_database.dart`,
  `lexicon_repository_impl.dart`) still claim the tables are entirely
  absent and queries would throw "no such table" — that specific
  claim is now stale and should be corrected, since queries will
  actually succeed and just return empty results. The practical
  consequence is unchanged either way: **there is no real Lexicon
  content shipped yet**, so Lexicon/Flashcards (which depends on
  Lexicon) will appear functionally empty on a real install. See
  [DATABASE_REFERENCE.md](../architecture/DATABASE_REFERENCE.md) §1.1
  for the full verification.

  **Reclassified 2026-08-03 — `WAITING_EXTERNAL_DECISION`.** This is
  **no longer an engineering task** and has been removed from the
  active critical path.

  | Field | Value |
  |---|---|
  | Status | `WAITING_EXTERNAL_DECISION` |
  | Owner | **Product Owner** (not engineering) |
  | Dependency | QAC permission response (corpus.quran.com) |
  | Deadline | **2026-08-24** (21 days) |

  The original framing above — "needs the content pipeline re-run",
  "effort depends on where the data comes from" — was **wrong**. The
  pipeline exists and is unit-tested (`tool/lexicon/`, 2,140 lines);
  the source is identified. The gate is a licence question, analysed in
  full in `RELEASE_GOVERNANCE_AUDIT.md` §3 and the Phase 3 Legal
  Decision Review. MASAQ was evaluated as a replacement and **rejected**
  (`MASAQ_ACCEPTANCE_REPORT.md` — no root/lemma columns).
  On deadline expiry with no clear grant: defer Lexicon and Flashcards
  from v1.0 under a Decision Record. Do not renegotiate the date.

  **Governance update (2026-08-22).** `DR-2026-0029` ("QAC/Lexicon
  licensing," accepted, governing) adds a second, independent
  rejection ground for MASAQ beyond the structural one above: the
  currently published MASAQ v6 is **CC BY-NC 3.0**, not the CC BY 4.0
  the MASAQ proposal assumed. No repository evidence establishes that
  a QAC permission request was ever sent or answered. `DR-2026-0030`
  ("Formal deferral of Lexicon and Flashcards from v1.0," accepted,
  governing) formally defers Lexicon and Flashcards from v1.0 scope,
  exercised **proactively on 2026-08-22** — approximately two days
  ahead of the 2026-08-24 deadline above — under explicit
  release-owner authorization. This is **not** the automatic firing of
  the deadline-expiry contingency stated above: the deadline had not
  passed, and nothing here claims it had. The deadline itself
  (2026-08-24) is unchanged, unextended, and not renegotiated. `D6`
  (the Word foundation epic in `PHASE4_IMPLEMENTATION_MASTER_PLAN.md`
  — distinct from this document's own technical-debt item D6, below)
  is deferred as a direct consequence.

## 3. Nice-to-have (does not block v1.0)

- Consolidating the remaining duplicate widgets flagged in
  `UPDATED_TECHNICAL_DEBT.md` D6 (a second empty-state shape
  duplicated 5×, the `_JourneyEntryCard`/`_SmartLearningEntryCard`
  pair) — cosmetic/maintainability, zero user-facing risk either way.
  D10–D14 (minor coupling smells, small perf nits, unused route-constant
  identifiers, eager audio-player construction, type-level
  layer-skipping) — same category.
- `docs/adr/DR-2026-0002-*.md` (Search, Sprint 7.1) is referenced from
  6 places in `lib/` and `CHANGELOG.md` but the file doesn't exist —
  a documentation-completeness gap, not a functional one.
- Recent Searches, Suggestions, Filters in Search — UI scaffolding
  exists (empty-state placeholders) but nothing is wired to real logic
  yet. **Stale claim corrected 2026-08-03**: this bullet previously
  also named a "locked 'Ask AI' mode button" as existing scaffolding —
  that control was removed outright in Phase 3 Sprint R3b, not merely
  wired up, after a design review found no remaining product signal in
  keeping a permanently-locked toggle on the primary Search surface
  (see `RELEASE_DASHBOARD.md` §2 "Sprint R3b"). Re-adding an AI mode is
  now a build-from-scratch decision for whenever real AI search exists
  (v2.0), not a matter of wiring up scaffolding already in place.
- The "Nhật ký" (journal) feature named in early roadmap notes was
  never concretely specified beyond a name — treat as a v2.0 candidate,
  not v1.0 scope creep. **Stale claim corrected 2026-08-14**: this
  bullet previously grouped Hifz mode with it under the same
  never-specified/v2.0 framing. Hifz was subsequently specified and
  built as Milestone 7 Sprint 7.7
  (`docs/release/MILESTONE_7_STUDY_ROADMAP.md`), and is now part of the
  v1.0 product surface, reachable from the Study tab. Shipped scope:
  plan management (create, range selection, active/paused/completed
  lifecycle, soft delete), a Hifz-specific scheduling algorithm, and
  SRS-backed review with grading. **Stale claim corrected 2026-08-18**:
  this bullet went on to say Hifz-specific progress/history reporting
  was **not** implemented. Both have since shipped. Progress: a
  per-plan snapshot screen (Sprint 7.7c-A) and an all-active-plans
  overview on the plans list (Sprint D6.4), each derived from
  `srs_cards`. History: a review-history section on the per-plan
  progress screen (Sprint D6.11,
  `docs/adr/DR-2026-0026-hifz-historical-review-count-and-pace.md`,
  accepted) derived from the `review_events` table added at schema v8 —
  a total review count plus a seven-day per-day distribution, computed
  over the ayah set of a plan's range. That is *scope*, not
  attribution: overlapping plans share a single card per ayah, so no
  fact exists about which plan "caused" a review, the same event can
  legitimately appear under more than one plan, and the numbers do not
  sum across plans. Deliberately still absent, therefore: any
  cross-plan or aggregate Hifz review-history total — no provider
  combines them.

## 4. Recommended release checklist (sequenced)

1. **Documentation reconciliation** (§0) — bump `pubspec.yaml`,
   backfill `CHANGELOG.md` for P1–P4/F1–F8/S2, update `ROADMAP.md`/
   `TODO.md`/`CLAUDE.md` to reflect actual current status. Cheap, and
   every later step benefits from working docs.
2. ~~**Rebuild the content database asset**~~ — **removed from the
   engineering sequence 2026-08-03.** Now an external dependency owned
   by the Product Owner (§2). Engineering schedules nothing against it
   until the QAC answer arrives or the deadline passes.
3. ~~**Finish the FTS5 search engine wiring**~~ — **done**, Phase 3
   Sprint R1 (commit `0f3f751`).
4. ~~**Resolve D3** (Read Model UI decision)~~ — **done**, Phase 3
   Sprints R2 and R3.1: `StudySummaryScreen` shipped and reachable via
   a CTA from `SmartLearningScreen`.
5. ~~**Remeasure test coverage**~~ — **done**, Phase 3 Sprint R3.2
   (`DR-2026-0015`): measured 81.54% on hand-written code, gate raised
   70 → 80.

   ~~**→ Next engineering sprint: Web Platform Completion.**~~ —
   **done**, Phase 3 Sprint R3a (2026-08-03): `sqlite3.wasm` and
   `drift_worker.js` vendored and verified working in a real browser;
   CI now guards against either going missing again. See
   `RELEASE_DASHBOARD.md` §4 "R3a" and §2 "Sprint R3a".
6. **Real-device passes**: accessibility (TalkBack/VoiceOver),
   performance (Android mid-range), and the full store/legal checklist
   in §2 — these are the genuinely time-consuming, non-engineering
   items and should be scheduled with that in mind.
7. **Platform scope decision**: ship Web for v1.0 (requires the
   `sqlite3.wasm`/`drift_worker.js` fix) or explicitly defer Web to a
   later release and say so in store listings.
8. **Dependency upgrade pass** (16 outdated packages, 2 major
   versions) — do this deliberately, with its own regression cycle, not
   folded into a feature release.
9. Everything in §3 — pick up opportunistically, none of it gates
   ship.

This sequencing front-loads the cheap, high-leverage items (docs,
Lexicon DB asset, search wiring, the D3 decision) before the expensive,
manual, device-dependent verification work in step 6 — so that manual
testing happens against a build that's actually feature-complete, not
one that needs another round after.
