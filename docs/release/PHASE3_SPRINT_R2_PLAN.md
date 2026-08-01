# Phase 3 — Sprint R2 Plan

Planning only. No code was written or modified to produce this
document; no commit was created. Synthesized from a fresh read of
`RELEASE_DASHBOARD.md`, `docs/release/RELEASE_PLAN_V1.md`,
`docs/release/PRODUCT_ROADMAP.md`, `docs/architecture/MASTER_ARCHITECTURE.md`,
`docs/architecture/MODULE_CATALOG.md`, `docs/architecture/PROVIDER_MAP.md`,
`docs/testing/TESTING_GUIDE.md`, plus direct verification against the
current repository (git log, git status, a read-only query against the
shipped `assets/database/quran.sqlite` asset, and a directory/router
check for the Read Model feature) — not assumed from the documents
alone.

---

# Sprint Goal

Give the Read Model (`LearningSnapshotRepository`, F7) a real,
minimal UI — a "Study Summary" screen reachable from
`SmartLearningScreen` — closing technical-debt item **D3**, the one
High-priority blocker in `RELEASE_DASHBOARD.md`/`RELEASE_PLAN_V1.md`
that is both still open and fully actionable by engineering alone,
with no external dependency (unlike Lexicon's licensing block) and no
scope-decision prerequisite beyond the one this sprint itself resolves.

---

# Why this blocker is next

`RELEASE_PLAN_V1.md` §4's own recommended sequencing lists, in order:
(1) documentation reconciliation — done, Phase 2.1; (2) rebuild the
Lexicon content database asset; (3) finish FTS5 search wiring — **done,
Sprint R1**; (4) **resolve D3 (Read Model UI decision)**; (5)
remeasure coverage; (6) real-device passes; (7) platform scope
decision (Web); (8) dependency upgrades. With step 3 now closed, step
4 is next in the document's own sequence — this sprint follows that
order rather than reordering it.

Step 2 (Lexicon) is skipped again, for the same reason R1 skipped it
ahead of Search: it is not an engineering task waiting to be picked
up. Verified directly this session — `assets/database/quran.sqlite`'s
8 Lexicon tables are still all at 0 rows — and `tool/fetch_morphology.py`'s
own doc comment (unchanged since R1's investigation) documents a real,
unresolved licensing conflict between the Quranic Arabic Corpus data's
terms ("changing it is not allowed") and the transform step the
pipeline requires, plus a manual-only, email-gated download with no
automatable fetch. That is still a product/legal decision outside any
sprint's engineering scope, not a coding gap.

D3, by contrast, is a decision this document can make a concrete,
actionable recommendation on, and `PRODUCT_ROADMAP.md`'s own v1.1
section already frames the follow-through as "presentation-layer
effort only" — the data-aggregation work (`LearningSnapshotRepository`,
`computeLearningSnapshot`, the entire 5-tier chain beneath it) is
already built, tested, and merged. This is the same pattern that made
Search the right R1 choice: real, high-priority, and closeable without
waiting on anyone else.

Web platform (also High priority, also actionable) was considered as
an alternative. It was set aside for this sprint because, unlike D3,
it requires a scope decision (ship Web for v1.0 at all?) that
`RELEASE_PLAN_V1.md` §2 explicitly frames as still open and
undecided — resolving D3 first, and reassessing Web platform as an R3
candidate once that decision is made, keeps this sprint's scope to a
single, well-bounded question.

---

# Current implementation status

Verified directly against the repository, not assumed from documents:

- **Search (R1)** — confirmed complete: `git log` shows
  `0f3f751 feat(search): integrate FTS5 search...` and
  `a4d349f style: apply dart formatter`, both merged into `origin/main`;
  local `main` is synchronized with `origin/main` (`git status` clean
  of any diff between them).
- **Lexicon** — confirmed still empty: direct query against
  `assets/database/quran.sqlite` shows all 8 tables (`roots`, `lemmas`,
  `lexemes`, `word_instances`, `grammar_features`, `phrases`,
  `phrase_word_instances`, `lexicon_relations`) at 0 rows. Unchanged
  since `RELEASE_PLAN_V1.md` was written.
- **Read Model (D3)** — confirmed still unresolved: `lib/features/read_model/`
  has only `data/` and `domain/` directories, no `presentation/`;
  `lib/app/router.dart` contains no reference to Read Model or
  `LearningSnapshot`. Exactly as `MODULE_CATALOG.md` describes: "Read
  Model chưa có màn hình" (no screen), not reachable from any route.
- **CI/gates** — `flutter analyze` and `flutter test` both confirmed
  clean as of the last push (`a4d349f`); no outstanding gate failures
  to inherit into this sprint.

---

# Scope

- A new, minimal read-only screen (working name: "Study Summary")
  that renders the existing `LearningSnapshot` entity — `TutorContext`,
  `TutorInsights`, `DailyLearningPlan`, `SmartLearningSession` already
  aggregated into one object by `LearningSnapshotRepository.getSnapshot()`
  (or the pure function `computeLearningSnapshot`, see Providers
  affected).
- A new entry point: a "View study summary" affordance on
  `SmartLearningScreen`, matching this app's established pattern where
  each tier of the 5-tier chain (`TutorHomeScreen` → `LearningJourneyScreen`
  → `SmartLearningScreen`) pushes to the next tier's screen.
- A new route (`AppRoutes`) for the new screen, following existing
  conventions for a pushed, non-tab screen.
- New l10n strings in all three `lib/l10n/app_{vi,en,ar}.arb` files
  for the new screen's content.
- Closing D3 in `docs/release/UPDATED_TECHNICAL_DEBT.md` once shipped
  (documentation follow-up, not part of the code sprint itself).

# Out of Scope

- **Any change to the 5-tier composition chain's logic** — `AnalyticsRepository`
  through `LearningSnapshotRepositoryImpl` are reused exactly as they
  are; this sprint adds a consumer, not new aggregation logic.
- **The Lexicon licensing decision** — unrelated, explicitly deferred
  again this sprint (see "Why this blocker is next").
- **The Web platform scope decision** — a separate, still-open
  decision; not resolved here.
- **Any redesign of `TutorHomeScreen`, `LearningJourneyScreen`, or
  `SmartLearningScreen`** — only an additive entry-point affordance is
  added to `SmartLearningScreen`; their existing layout, providers, and
  behavior are untouched.
- **Real-time refresh/streaming of the snapshot.** `LearningSnapshotRepository`'s
  own doc comment states "no caching policy yet" and recomputes fresh
  on every call — this sprint's screen is a simple pull-to-refresh (or
  static-per-visit) read, not a live-updating dashboard.
- **Database schema changes.** None needed — Read Model touches no
  database directly (composes `SmartLearningRepository`, which
  composes down to repositories that already exist).

---

# Architecture impact

Per `MASTER_ARCHITECTURE.md` §4.1 and `PROVIDER_MAP.md` §2.2/§2.3,
this sprint adds the **first UI consumer** to the top of the 5-tier
chain:

```
AnalyticsRepository
  → AITutorRepository
  → LearningJourneyRepository
  → SmartLearningRepository
  → LearningSnapshotRepository   (read_model — NEW: gets a screen)
```

This is additive at the presentation layer only — no tier's
composition rule ("each tier composes exactly the one directly below
it") changes. It does, however, activate a documented but currently
dormant architectural caveat:

**The bypass-provider hazard, now real for the first time.**
`PROVIDER_MAP.md` §2.3 documents that `learningSnapshotProvider`
(a `FutureProvider.autoDispose` that reuses `smartLearningSessionProvider.future`
and applies `computeLearningSnapshot` locally, skipping
`LearningSnapshotRepositoryImpl.getSnapshot()` entirely) is safe
**only because no UI currently watches or refreshes it** — the doc
comment explicitly flags this needs revisiting once a screen exists.
That is now this sprint. If the new screen's pull-to-refresh
invalidates only `learningSnapshotProvider`, it would silently return
`smartLearningSessionProvider`'s stale cached value instead of a fresh
computation — a real correctness bug, not a performance nuance (the
same class of hazard `learningJourneyProvider` was deliberately built
*without* the bypass optimization to avoid, per the same section).
**Recommendation**: the new screen should watch
`learningSnapshotRepositoryProvider.getSnapshot()` directly (the
"real," non-bypassed path) rather than the `learningSnapshotProvider`
shortcut. This accepts the fan-out cost `PROVIDER_MAP.md` §2.2
describes (up to ~12 Analytics-repository calls per read) in exchange
for correctness by construction, with zero risk of stale-refresh bugs
and zero changes to the existing bypass provider or its optimization
for whatever non-UI purpose it currently serves. Revisiting this
trade-off (e.g., adding a *correct* invalidation chain to safely reuse
the bypass) is a legitimate follow-up once the screen's real-world
performance is measured, not a first-cut requirement.

No other architectural rule from `MASTER_ARCHITECTURE.md` §5 is
implicated: the new screen still only consumes its own feature's
provider (principle 2), still composes nothing new (principle 3), and
introduces no new persisted duplication (principle 4).

# Providers affected

- **Read, not modified**: `learningSnapshotRepositoryProvider`
  (`read_model/data/learning_snapshot_providers.dart`) — the new
  screen's primary data source, per the recommendation above.
- **Not used** (deliberately, per the bypass hazard): `learningSnapshotProvider` —
  left exactly as it is, for whatever purpose it currently exists
  outside the UI (kept as the standard DI access point, per its own
  doc comment).
- **New** (exact naming an implementation decision): a thin
  presentation-layer provider or controller if the screen needs
  pull-to-refresh state beyond what directly watching
  `learningSnapshotRepositoryProvider` gives for free via
  `FutureProvider`'s own `AsyncValue` — likely unnecessary; a direct
  `ref.watch`/`ref.refresh` on the repository-backed provider (matching
  the pattern already used elsewhere in this app, e.g.
  `ProgressDashboardScreen`) is probably sufficient and should be
  tried first before adding a new provider.
- **Not touched**: every provider in `analytics/`, `ai_tutor/`,
  `learning_journey/`, `smart_learning/` — all read transitively
  through the existing chain, none modified.

# Database impact

**None.** `LearningSnapshotRepository` and everything it composes
touch no database directly — confirmed in `MASTER_ARCHITECTURE.md`
§2.1's repository table (Read Model composition-tier repositories are
explicitly listed as touching **neither** database). No schema
change, no migration, no `schemaVersion` bump on `AppDatabase` or
`UserDatabase`.

# UI impact

- **New screen**: renders `LearningSnapshot`'s four sections
  (`TutorContext`, `TutorInsights`, `DailyLearningPlan`,
  `SmartLearningSession`) — likely as a scrollable summary of cards or
  sections, reusing existing presentation-mapping helpers already
  built for the tiers below it (`tutor_presentation.dart`,
  `session_strategy_presentation.dart`) rather than inventing new
  icon/label logic, per this app's principle 5 ("reuse existing
  widgets/logic before inventing new ones").
- **New entry point** on `SmartLearningScreen`: one additive
  affordance (e.g. a button/card), not a layout change to that
  screen's existing content.
- **New route**, added to `lib/app/router.dart` as a pushed screen
  (matching the pattern of `LearningJourneyScreen`/`SmartLearningScreen`
  themselves — pushed from the tier below, not a tab).
- **Loading/error/empty states**: should reuse this app's established
  shared widgets (`LoadingState`, error-state patterns already used
  across `analytics/`, `ai_tutor/`, `learning_journey/` screens) rather
  than building new ones — consistent with how Search's states were
  built from existing widgets in R1.

---

# Risks

1. **The bypass-provider hazard is real, not hypothetical**, per
   Architecture impact above — if implementation reaches for
   `learningSnapshotProvider` instead of the repository-backed
   provider "because it's already there and looks like the right
   name," it will ship a stale-refresh bug that passes casual manual
   testing (the cached value is often correct) and only surfaces when
   an underlying tier's data changes between visits. This is the
   single most important risk to get right at implementation time.
2. **Fan-out cost is real and unmeasured.** Watching the real,
   non-bypassed path costs up to ~12 Analytics-repository calls per
   screen open, per `PROVIDER_MAP.md` §2.2's own accounting. This has
   never been measured against a real device or a large dataset — if
   it proves slow, the correct fix is a real invalidation-aware cache,
   not silently switching back to the unsafe bypass.
3. **No existing test exercises `LearningSnapshotRepositoryImpl.getSnapshot()`
   from a widget context** — `test/learning_snapshot_repository_impl_test.dart`,
   `test/learning_snapshot_providers_test.dart`, and
   `test/learning_snapshot_generator_test.dart` all exist and pass
   (per `TESTING_GUIDE.md` §2.5, confirming this layer is well-tested
   even though unreachable from the UI) — but none of them exercise it
   through a rendered screen, so a widget-level regression here would
   be genuinely new ground, not a re-check of existing coverage.
4. **Reusing presentation-mapping helpers from other tiers**
   (`tutor_presentation.dart`, etc.) risks import-direction surprises
   if those files assume they're only ever used within their own
   feature directory — needs verifying at implementation time, not
   assumed safe just because principle 5 recommends reuse generally.
5. **Scope creep risk**: `LearningSnapshot` aggregates four already
   rich sub-objects; the temptation to build a large, novel dashboard
   layout (rather than a minimal summary) could turn a "presentation-layer
   effort only" item (per `PRODUCT_ROADMAP.md`) into a much larger
   design effort. This plan explicitly scopes the first version as
   minimal.

# Testing strategy

Per `TESTING_GUIDE.md`'s established conventions:

- **New widget tests** for the new screen, following the shape used
  for sibling tier screens (`test/smart_learning_screen_test.dart`,
  `test/learning_journey_screen_test.dart`) — `testWidgets()` +
  isolated `GoRouter` + `ProviderScope` overrides, hand-written fakes
  for whichever repository-backed provider the screen ends up
  watching, per §3.5's fake convention (`implements`, untested methods
  `throw UnimplementedError()`).
- **Loading/error/empty coverage**, matching how every other tier
  screen in this app already tests its own `AsyncValue.when()` states
  — no new pattern needed.
- **A dedicated regression test for the bypass hazard**: verify that
  the new screen's provider is `learningSnapshotRepositoryProvider`
  (or an equivalent that calls `getSnapshot()`), not
  `learningSnapshotProvider` — either by asserting on which provider
  the widget watches (via `ProviderContainer` override presence) or by
  a test that changes an upstream value and confirms the screen's
  displayed data updates on refresh, which the bypass provider would
  fail.
- **New entry-point test** on `test/smart_learning_screen_test.dart`
  (extended, not rewritten): tapping the new affordance navigates to
  the new screen, following the existing tier-to-tier navigation test
  pattern already used for `TutorHomeScreen` → `LearningJourneyScreen`
  → `SmartLearningScreen`.
- **Regression guard**: re-run `test/smart_learning_screen_test.dart`
  and every existing Read Model test file unmodified — must show zero
  diff outside the new entry-point addition.
- Vietnamese test descriptions and a `'Sprint R2'` traceability tag on
  new tests, per §3.6/§3.7 convention.

# Acceptance Criteria

1. A real screen renders `LearningSnapshot`'s aggregated content —
   not placeholder data.
2. The screen is reachable from `SmartLearningScreen` via a real,
   working navigation affordance.
3. The screen reads through `learningSnapshotRepositoryProvider`'s
   real `getSnapshot()` path — not the `learningSnapshotProvider`
   bypass — confirmed by a dedicated test, not just code review.
4. Loading, error, and empty states are handled using existing shared
   patterns, not ad hoc new ones.
5. Zero changes to `analytics/`, `ai_tutor/`, `learning_journey/`,
   `smart_learning/` provider or repository logic.
6. Zero database schema change.
7. New l10n strings present in all three `.arb` files.
8. `dart format`, `flutter analyze --fatal-infos`, `flutter test
   --coverage` all run clean.

# Definition of Done

- All Acceptance Criteria met.
- `docs/release/UPDATED_TECHNICAL_DEBT.md`'s D3 entry updated from
  "NOT ACTIONED" to "FIXED (R2)" with the real detail, in a follow-up
  documentation commit once code lands — not part of the code sprint
  itself.
- `RELEASE_DASHBOARD.md`'s Read Model blocker entry updated to reflect
  the closed decision (moved out of "High" once shipped).
- Full test suite green, no regression in any of the 786 tests
  inherited from Sprint R1 or earlier.
- One logical change per commit, per `CONTRIBUTING.md`'s established
  convention for this project (matching how R1.1/R1.2/R1.3 were each
  their own commit).

# Estimated implementation order

1. **Decide the exact provider access pattern first** (a real design
   decision, not a coding step): confirm
   `learningSnapshotRepositoryProvider.getSnapshot()` is callable
   directly from a new `FutureProvider.autoDispose` in a new
   `read_model/presentation/` provider file, or whether the screen can
   `ref.watch` a thin wrapper — resolve before writing the screen, to
   avoid discovering the bypass hazard mid-implementation.
2. Add the new route to `lib/app/router.dart`, following the existing
   pushed-screen pattern.
3. Build the minimal Study Summary screen, rendering the four
   `LearningSnapshot` sections, reusing existing presentation-mapping
   helpers where they fit.
4. Add the entry-point affordance to `SmartLearningScreen`.
5. Add l10n keys to all three `.arb` files.
6. Write the new screen's widget tests, including the bypass-hazard
   regression test (Testing strategy, item 3).
7. Extend `test/smart_learning_screen_test.dart` for the new
   navigation entry point.
8. Run full gates (`dart format`, `flutter analyze --fatal-infos`,
   `flutter test --coverage`); confirm zero diff in every pre-existing
   Read Model and Smart Learning test file's assertions.
9. Update `UPDATED_TECHNICAL_DEBT.md` (D3) and `RELEASE_DASHBOARD.md`
   in a separate, final commit.

# Follow-up Sprint

Candidates for R3, in the order `RELEASE_PLAN_V1.md` §4 and
`RELEASE_DASHBOARD.md`'s own sprint plan imply, adjusted for what R1
and R2 will have closed:

- **Web platform scope decision** — ship (fix `sqlite3.wasm`/
  `drift_worker.js`) or explicitly defer; the other still-open,
  purely-engineering-actionable High-priority item this sprint set
  aside.
- **Coverage remeasurement** — `flutter test --coverage` has not been
  regenerated fresh since before F1–F8 landed; decide whether to raise
  the CI gate from 70% toward the stated 80% target now that R1/R2
  have both added their own test coverage.
- **Bypass-provider performance follow-up**: if R2's real-path
  fan-out (~12 Analytics calls) proves slow in practice, design a
  correct, invalidation-aware caching strategy rather than reverting
  to the unsafe bypass.
- **Lexicon licensing decision** — still not an engineering sprint;
  carried forward again, unresolved, exactly as R1 and this plan both
  found it.
- **16 outdated packages / dependency upgrade pass** — deliberately
  not folded into this sprint or R1; needs its own dedicated
  regression cycle per `CLAUDE.md`'s "stop and ask before" list.
- **Real-device accessibility/performance passes** — blocked on
  physical device access, not on any code decision; revisit once
  device access is confirmed available.

---

READY FOR R2 DESIGN REVIEW
