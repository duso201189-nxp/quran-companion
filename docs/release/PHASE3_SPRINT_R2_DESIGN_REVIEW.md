# Phase 3 — Sprint R2 Design Review: Read Model UI

Design review only. No production code was written or modified; no
commit was created; no new provider was created. Every claim below
was verified by reading the actual current source — `read_model/`,
`smart_learning/`, `learning_journey/`, `ai_tutor/` (data, domain, and
presentation layers), the router, and the existing Read Model test
suite — not inferred from `docs/architecture/` summaries alone.
Companion to [PHASE3_SPRINT_R2_PLAN.md](PHASE3_SPRINT_R2_PLAN.md),
which this review refines on one point (see Refresh Strategy).

Files read in full to produce this review: `read_model/domain/entities/{learning_snapshot,snapshot_section,snapshot_timestamp}.dart`,
`read_model/domain/{learning_snapshot_generator,learning_snapshot_repository}.dart`,
`read_model/data/{learning_snapshot_providers,learning_snapshot_repository_impl}.dart`,
`smart_learning/data/{smart_learning_providers,smart_learning_repository_impl}.dart`,
`smart_learning/domain/entities/smart_learning_session.dart`,
`smart_learning/presentation/smart_learning_screen.dart` + its
`widgets/{smart_learning_header,session_summary_card}.dart`,
`ai_tutor/domain/entities/{tutor_context,tutor_insight}.dart`,
`ai_tutor/presentation/tutor_home_screen.dart` + `widgets/{tutor_header,tutor_insight_card}.dart`,
`learning_journey/domain/entities/daily_learning_plan.dart`,
`lib/app/router.dart` (routing conventions),
`test/learning_snapshot_providers_test.dart`.

---

# Current Architecture

`LearningSnapshot` (`read_model/domain/entities/learning_snapshot.dart`)
is an immutable aggregate of four already-existing domain types —
`TutorContext`, `List<TutorInsight>`, `DailyLearningPlan`,
`SmartLearningSession` — plus a `SnapshotTimestamp`. It invents no new
data shape; it is a read-only projection.

`computeLearningSnapshot(session, generatedAt)`
(`learning_snapshot_generator.dart`) is a pure function that does **no
computation at all** — it just reads `session.journey.context`,
`session.journey.insights`, `session.journey.todayPlan`, and `session`
itself. This only works because `SmartLearningSession` (`smart_learning/domain/entities/smart_learning_session.dart`)
carries a `journey: LearningJourney` field, added specifically in
Sprint 18 Phase 1 so Read Model could get everything it needs from
**one** `SmartLearningRepository.getSmartLearningSession()` call
without ever touching `LearningJourneyRepository`/`AITutorRepository`/
`AnalyticsRepository` directly — the layering rule ("Compose ONLY:
SmartLearningRepository") is enforced by this field's existence, not
just by convention.

Two ways to obtain a `LearningSnapshot` exist today, both already
built and tested, neither used by any UI yet:

1. **`LearningSnapshotRepositoryImpl.getSnapshot()`** — calls
   `SmartLearningRepository.getSmartLearningSession()` as a direct
   method call (not through Riverpod). Per its own doc comment and
   `SmartLearningRepositoryImpl`'s, **no tier in this chain caches
   anything** — every call recomputes fully, cascading
   `SmartLearning → LearningJourney → AITutor → Analytics` fresh, every
   time. This is a deliberate, explicitly documented invariant
   ("optimizing *within* one call is allowed, optimizing *across*
   calls is not, risk of stale data" — established Sprint 14 Phase 3,
   restated identically at all five tiers), not an oversight.
2. **`learningSnapshotProvider`** (`FutureProvider.autoDispose`) — a
   Riverpod-layer bypass: `ref.watch(smartLearningSessionProvider.future)`
   then `computeLearningSnapshot`. If `smartLearningSessionProvider`
   is already alive (kept warm by some other watcher — today, only
   `SmartLearningScreen`), this costs **zero** additional repository
   calls; it is a pure cache read. This is not a claim — `test/learning_snapshot_providers_test.dart`'s
   third test proves it directly: it simulates `SmartLearningScreen`
   being mounted (`container.listen(smartLearningSessionProvider, ...)`),
   then reads `learningSnapshotProvider`, and asserts the underlying
   fake repository's call count stays at 1, not 2.

`smartLearningSessionProvider` itself has exactly one live-code
watcher today: `SmartLearningScreen`, whose own `RefreshIndicator`
calls `ref.invalidate(smartLearningSessionProvider)` — this is the
established, single refresh mechanism for the entire chain beneath
Read Model. No automatic invalidation exists anywhere (no listener
fires on underlying data changes); every tier's freshness is either
"first computation" or "someone explicitly pulled to refresh."

`lib/features/read_model/` has no `presentation/` directory and no
route in `lib/app/router.dart` — confirmed directly, not assumed.

---

# Desired Architecture

Add exactly one new consumer to the top of the existing chain — no
new tier, no new repository method, no new provider:

```
AnalyticsRepository → AITutorRepository → LearningJourneyRepository
  → SmartLearningRepository → LearningSnapshotRepository
                                  ↑
                    (existing) learningSnapshotProvider
                                  ↑
                    (NEW) StudySummaryScreen  ← pushed from SmartLearningScreen
```

The new screen watches the **existing** `learningSnapshotProvider`
directly. No new provider file, no new provider declaration anywhere —
confirmed sufficient by inspection (see Provider Flow) and required
by this task's own constraint ("Do NOT create any new provider").

---

# Provider Flow

```
StudySummaryScreen (NEW)
  -> ref.watch(learningSnapshotProvider)              [EXISTING, unmodified]
       -> ref.watch(smartLearningSessionProvider.future)   [EXISTING, unmodified]
            -> ALIVE (SmartLearningScreen still mounted underneath,
               since navigation is a push, not a replace):
                 Riverpod returns the cached SmartLearningSession —
                 ZERO repository calls. Proven today by
                 test/learning_snapshot_providers_test.dart's third
                 test (same mechanism, different watcher).
            -> NOT ALIVE (deep link, or reached after SmartLearningScreen
               was popped/disposed):
                 rebuilds smartLearningSessionProvider fresh ->
                 smartLearningRepositoryProvider.getSmartLearningSession()
                 -> full fan-out down through LearningJourney -> AITutor
                 -> Analytics (up to ~12 calls, per PROVIDER_MAP.md §2.2)
       -> computeLearningSnapshot(session, DateTime.now())   [pure, unmodified]
  -> LearningSnapshot -> rendered
```

**Refresh** (pull-to-refresh on the new screen):

```
onRefresh: () async => ref.invalidate(smartLearningSessionProvider)
```

**Not** `ref.invalidate(learningSnapshotProvider)` — see Refresh
Strategy below for why this distinction is the single most important
correctness decision in this design.

---

# Repository Flow

```
LearningSnapshotRepositoryImpl.getSnapshot()   [EXISTING, unmodified —
                                                  used by tests and any
                                                  future non-Riverpod
                                                  caller, per its own
                                                  doc comment; NOT the
                                                  UI's primary path]
  -> SmartLearningRepositoryImpl.getSmartLearningSession()
       -> LearningJourneyRepositoryImpl.getLearningJourney()
            -> AITutorRepositoryImpl (up to 3 calls: context/suggestions/insights)
                 -> AnalyticsRepositoryImpl (up to 4 calls each)
  -> computeLearningSnapshot(session, now())
```

This path is not touched by this sprint and is not the new screen's
primary read (see Performance Considerations, question 2).

---

# Data Flow

No new query, no new join, no new database read. `LearningSnapshot`'s
four fields are all already materialized in memory by the time a
`SmartLearningSession` object exists — `context`/`insights`/`dailyPlan`
come from `session.journey`, itself already fully computed as part of
`SmartLearningRepositoryImpl.getSmartLearningSession()`'s existing
call to `LearningJourneyRepository`. This sprint adds a *consumer* of
already-flowing data, not a new data path.

---

# UI Flow

1. User on `SmartLearningScreen` taps a new "View study summary" CTA —
   a small additive widget, same shape as `TutorHomeScreen`'s existing
   `_JourneyEntryCard` (a `Material`/`InkWell` banner, no provider read
   of its own, just `context.push(...)`).
2. `context.push(AppRoutes.studySummary)` (exact route name an
   implementation detail; `push`, not `go`/`replace` — this matters,
   see Refresh Strategy).
3. `StudySummaryScreen` mounts. `SmartLearningScreen` remains mounted
   underneath in the Navigator stack (a push, not a replace), so
   `smartLearningSessionProvider` stays alive — the common case is an
   instant, cache-hit render with no visible loading state.
4. Screen renders four sections matching `LearningSnapshot`'s four
   fields, reusing existing presentation widgets (see UI reuse
   inventory below) — no new visual design, per this app's principle
   5 ("reuse existing widgets/logic before inventing new ones").
5. Pull-to-refresh invalidates `smartLearningSessionProvider` —
   both this screen and `SmartLearningScreen` (if revisited) reflect
   the fresh value, since both watch the same underlying provider.
6. Back navigation is a standard pop — Read Model has no write path,
   nothing to confirm or persist.

**UI reuse inventory** (all confirmed to exist, already built and
tested, reusable as-is):

| `LearningSnapshot` field | Existing widget(s) to reuse | Existing pure presentation-mapping helper |
|---|---|---|
| `context` (`TutorContext`) | `TutorHeader` (stats row) | none needed — `TutorHomeScreen`'s own inline mapping is the precedent |
| `insights` (`List<TutorInsight>`) | `TutorInsightCard` (thin wrapper over shared `StatCard`) in a grid, per `TutorHomeScreen`'s own layout | `insightPresentation` (`ai_tutor/presentation/tutor_presentation.dart`) |
| `dailyPlan` (`DailyLearningPlan`) | `JourneyStepCard`/`JourneyProgressCard` (`learning_journey/presentation/widgets/`) — same widgets `LearningJourneyScreen` already uses for the same entity | existing `LearningJourneyScreen` mapping, to confirm reuse-safety at implementation time |
| `smartSession` (`SmartLearningSession`) | `SmartLearningHeader`, `SessionSummaryCard`, `RecommendationCard` — same widgets `SmartLearningScreen` already uses for the same entity | `sessionStrategyPresentation` (`smart_learning/presentation/session_strategy_presentation.dart`) |
| section titles | `SectionHeader` (shared) | — |

---

# Refresh Strategy

**This is the one place this review corrects the R2 plan's more
cautious, pre-code-reading recommendation.** The plan speculated the
bypass provider might need avoiding entirely; reading the actual
provider code shows the real fix is narrower and cheaper.

Riverpod's invalidation direction only flows **forward, to
dependents** — `ref.invalidate(providerA)` rebuilds `A` and, because
that changes what `A` produces, also rebuilds anything that
`ref.watch`es `A`. It does **not** flow backward to what `A` itself
depends on.

- `learningSnapshotProvider` **depends on** `smartLearningSessionProvider`
  (via `ref.watch(smartLearningSessionProvider.future)`).
- Therefore `ref.invalidate(smartLearningSessionProvider)` correctly
  cascades forward and forces `learningSnapshotProvider` to recompute
  too.
- But `ref.invalidate(learningSnapshotProvider)` would **not**
  cascade backward — it would just re-run `computeLearningSnapshot`
  against whatever `smartLearningSessionProvider`'s value already is,
  which may still be the old, stale one if nothing else touched it.

**Conclusion**: the new screen's `RefreshIndicator` must invalidate
`smartLearningSessionProvider`, exactly matching what `SmartLearningScreen`
already does today. This is not a new pattern to invent — it's using
the identical, already-established invalidation target, which has the
pleasant side effect of keeping both screens' data in sync with a
single refresh action wherever it's triggered from.

**Answering the plan's three explicit questions:**

- **Should `learningSnapshotProvider` be bypassed or retired?**
  Neither. Keep using it as the screen's primary read. Retiring it (or
  avoiding it "to be safe") would forgo a real, tested, zero-cost
  optimization for the common navigation path (pushed from
  `SmartLearningScreen`, where the data is already warm one frame
  away) for no correctness benefit, once the refresh-target point
  above is handled correctly.
- **Should the UI read directly from `learningSnapshotRepositoryProvider`?**
  No. Reserve it for tests and non-UI callers, exactly as its own doc
  comment already states. Reading it directly from the UI means always
  paying the full ~12-call fan-out, even in the common case where
  `SmartLearningScreen` already has everything computed one navigation
  frame away.
- **Should caching happen in the repository or provider layer?**
  Provider layer — exactly where it already happens throughout this
  app. The repository layer's "no caching policy yet" is a deliberate,
  explicitly documented invariant restated identically at all five
  tiers since Sprint 14 Phase 3; this sprint should not be the one to
  quietly break it. Riverpod's own `FutureProvider` memoization is the
  established and only caching mechanism in this architecture — this
  sprint's job is to consume it correctly (right invalidation target),
  not add a new caching layer anywhere.

---

# Loading State

Reuse `LoadingState` (shared widget), exactly the pattern already used
by `TutorHomeScreen`/`LearningJourneyScreen`/`SmartLearningScreen` for
their own single-provider `AsyncValue.loading()` branch:
`learningSnapshotAsync.when(loading: () => LoadingState(semanticsLabel: l10n.studySummaryLoading), ...)`.
Given the cache-hit case is the expected common path, this state will
often be effectively unseen in practice — it must still be implemented
correctly for the cold-path (deep link, or reached after
`SmartLearningScreen` was disposed).

# Error State

Reuse `SearchErrorState` — confirmed genuinely general-purpose despite
its package location (already used identically by `TutorHomeScreen`,
`LearningJourneyScreen`, `SmartLearningScreen`, and `SearchScreen`),
with `onRetry: () => ref.invalidate(smartLearningSessionProvider)` —
the same invalidation target as refresh, for consistency (retry and
pull-to-refresh should behave identically here, matching every sibling
tier screen's own pattern).

# Empty State

`LearningSnapshot` itself is never "empty" — `getSnapshot()`/the
bypass never return null and never throw for "no data," they always
return a fully-formed aggregate (that's the point of an aggregation
layer with no filtering logic of its own). **Emptiness is per-section,
not whole-screen**: `insights` can be `[]`, `dailyPlan.steps` can be
`[]`, `smartSession.recommendations` can be `[]`, independently of
each other. Each section should show its own `EmptyStateBanner`,
exactly matching how `SmartLearningScreen` already handles
`recommendations.isEmpty` and `TutorHomeScreen` already handles
`suggestions.isEmpty` today — not a new "whole screen empty" concept
invented for this sprint.

---

# Performance Considerations

- **Cold-path fan-out cost is real and unmeasured.** Up to ~12
  Analytics-repository calls per `PROVIDER_MAP.md` §2.2's own
  accounting — this sprint is the first time that cost is ever paid
  from an actual rendered screen rather than a test or a hypothetical.
  Worth watching at implementation/manual-testing time, not assumed
  fine.
- **The cache-hit path's zero-cost guarantee is navigation-shape
  dependent.** It holds only when `StudySummaryScreen` is reached via
  `context.push` from a still-mounted `SmartLearningScreen`. Any
  future alternate entry point (a deep link, a different push origin,
  or reaching it after `SmartLearningScreen` was popped) pays the full
  cold-path cost every time — an accepted, understood characteristic
  of the design, not a defect, but worth documenting so a future
  entry-point addition doesn't silently assume the free path always
  applies.
- No new database I/O, no new network I/O (there is none in this
  chain — everything is rule-based, local aggregation), no new
  persisted state.

---

# Files expected to change

| File | Change |
|---|---|
| `lib/features/read_model/presentation/study_summary_screen.dart` | **New.** The screen itself. |
| `lib/features/smart_learning/presentation/smart_learning_screen.dart` | Additive: one new small entry-point widget (matching `TutorHomeScreen`'s `_JourneyEntryCard` shape) + wiring it into the existing `ListView`. No rewrite of existing content. |
| `lib/app/router.dart` | New `AppRoutes` constant + one new `GoRoute`, following the exact existing pattern for `aiTutor`/`learningJourney`/`smartLearning`. |
| `lib/l10n/app_vi.arb`, `app_en.arb`, `app_ar.arb` (+ generated `app_localizations*.dart`) | New screen title, section labels, loading label, per-section empty-state strings. |
| `test/study_summary_screen_test.dart` | **New.** |
| `test/smart_learning_screen_test.dart` | Extended: one new test for the new entry-point navigation, matching the existing tier-to-tier navigation test pattern. |

# Files that MUST NOT change

- `lib/features/read_model/data/learning_snapshot_providers.dart` —
  both existing providers (`learningSnapshotRepositoryProvider`,
  `learningSnapshotProvider`) are read, not modified; **no new
  provider is added here or anywhere**, per this task's explicit
  constraint and this review's own finding that none is needed.
- `lib/features/read_model/domain/**` — `LearningSnapshot`,
  `computeLearningSnapshot`, `LearningSnapshotRepository`, `SnapshotSection`,
  `SnapshotTimestamp` all unmodified.
- `lib/features/read_model/data/learning_snapshot_repository_impl.dart` —
  unmodified.
- `lib/features/smart_learning/**`, `lib/features/learning_journey/**`,
  `lib/features/ai_tutor/**`, `lib/features/analytics/**` — the entire
  chain beneath Read Model, excluding the one additive entry-point
  widget in `smart_learning_screen.dart`, stays untouched. This sprint
  adds a consumer; it does not touch composition logic anywhere.
- Any database table, migration, or `schemaVersion` — confirmed zero
  database impact.
- Any repository interface or implementation anywhere in the 5-tier
  chain.

---

# Risks

1. **The refresh-target mistake is the single most likely
   implementation error.** Invalidating `learningSnapshotProvider`
   instead of `smartLearningSessionProvider` would compile, run, and
   show a working-looking spinner — but silently return stale data,
   passing casual manual testing (the cached value is often still
   correct) while failing the exact scenario a dedicated test needs to
   catch (see Testing Strategy).
2. **Unmeasured cold-path cost**, as above — first real-screen
   exercise of the full ~12-call fan-out.
3. **Navigation-shape dependency** for the free cache-hit path, as
   above — an accepted characteristic, but one that could silently
   regress if a future change alters how `StudySummaryScreen` is
   reached (e.g., someone adds a second entry point that uses `go`
   instead of `push`).
4. **Cross-feature presentation-helper reuse** (`insightPresentation`,
   `sessionStrategyPresentation`, `JourneyStepCard`, etc.) needs
   verifying at implementation time that these functions/widgets don't
   assume something only true within their own feature's screen
   context (e.g., an implicit provider dependency) — not verified line
   by line in this review, only confirmed to exist and match the
   general "presentation-mapping helper, no provider reads" pattern
   already established.
5. **Scope creep**: `LearningSnapshot` aggregates four rich
   sub-objects; the temptation to build a large, novel dashboard layout
   (rather than four minimal, reused sections) could turn
   "presentation-layer effort only" (per `PRODUCT_ROADMAP.md`) into a
   much larger design effort than intended.
6. **`SnapshotSection` enum should stay unused.** Its own doc comment
   states plainly it exists for a future selective-read API, not this
   phase — no implementation should invent a use for it just because
   it's there.

# Rollback Strategy

Everything in this design is additive: one new screen file, one new
route, one small additive widget in an existing screen, new l10n
entries, new tests. No schema, no repository change, no modification
to any of the four tiers beneath Read Model. A plain `git revert` of
this sprint's commit(s) is clean with nothing to unwind elsewhere.

Recommended commit granularity, matching this project's established
one-logical-change-per-commit convention: (1) the new screen + route,
(2) the `SmartLearningScreen` entry-point addition, (3) l10n, (4)
tests. Each is independently revertable — e.g., the entry-point widget
could be reverted alone (leaving the screen reachable only by direct
route, for QA) if it proves visually wrong, without touching the
screen itself or any provider.

# Testing Strategy

- **New widget tests** for `StudySummaryScreen`, following the shape
  already used for sibling tier screens — `testWidgets()` + isolated
  `GoRouter` + `ProviderScope` overriding `smartLearningRepositoryProvider`
  (the same override seam `test/learning_snapshot_providers_test.dart`
  already uses) — **not** overriding `learningSnapshotProvider`
  directly, since it's a thin wrapper, not the actual data source.
- **A dedicated regression test for the refresh-target mechanism**,
  reusing the existing `_CountingSmartLearningRepository` pattern from
  `test/learning_snapshot_providers_test.dart`: after
  `ref.invalidate(smartLearningSessionProvider)`, a subsequent read
  must show the call count incremented (proves the correct fix works);
  as a negative control, invalidating `learningSnapshotProvider` alone
  while `smartLearningSessionProvider` stays alive must **not**
  increment the call count (proves the mistake this design explicitly
  warns against would be caught, not just described).
- **Loading/error/per-section-empty coverage**, matching how every
  sibling tier screen already tests its own `AsyncValue.when()` states
  and per-section `EmptyStateBanner` branches — no new pattern needed.
- **New entry-point test**, extending `test/smart_learning_screen_test.dart`:
  tapping the new affordance navigates to `StudySummaryScreen`,
  matching the existing `TutorHomeScreen → LearningJourneyScreen`/
  `LearningJourneyScreen → SmartLearningScreen` navigation test
  pattern already in this suite.
- **Regression guard**: re-run every existing Read Model test file
  (`test/learning_snapshot_repository_impl_test.dart`,
  `test/learning_snapshot_providers_test.dart`,
  `test/learning_snapshot_generator_test.dart`) and
  `test/smart_learning_screen_test.dart` unmodified in their existing
  assertions — must show zero diff outside the one new entry-point
  test.
- Vietnamese test descriptions and a `'Sprint R2'` traceability tag on
  new tests, per `TESTING_GUIDE.md` §3.6/§3.7 convention.

---

READY FOR R2 IMPLEMENTATION
