# Phase 3 — Sprint R2.3 Report: Read Model Finalization

Built on R2.1 ([PHASE3_SPRINT_R2_1_REPORT.md](PHASE3_SPRINT_R2_1_REPORT.md)) and R2.2
([PHASE3_SPRINT_R2_2_REPORT.md](PHASE3_SPRINT_R2_2_REPORT.md)).
No commit was created; nothing was pushed; no PR was opened.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `lib/features/read_model/presentation/study_summary_screen.dart` | Modified | Refresh wired (objective 1); 4 unnecessary `Builder` wrappers replaced with private helper methods (objective 5/6). See below. |
| `test/study_summary_screen_test.dart` | Modified | 1 existing R2.1 test updated (its assertion was made stale by wiring refresh); 1 new fake; 1 new test group "Sprint R2.3" (3 tests). |

**Not touched**: `lib/features/read_model/data/**` (`learning_snapshot_providers.dart` — no signature/behavior change; only the *screen* now calls `ref.invalidate` on an existing provider, nothing about the provider itself changed), `lib/features/read_model/domain/**`, `lib/features/smart_learning/**`, `lib/features/learning_journey/**`, `lib/features/ai_tutor/**`, `lib/features/analytics/**`, `lib/app/router.dart`, `lib/l10n/**` (no new keys needed — see Localization review), any database file. Confirmed via `git status --short`.

# Refresh implementation

`StudySummaryScreen.build` now wraps the existing `ListView` in a `RefreshIndicator`, and the `error` branch of `SearchErrorState` now has `onRetry` wired — both call the exact same single line:

```dart
onRefresh: () async => ref.invalidate(smartLearningSessionProvider),
...
onRetry: () => ref.invalidate(smartLearningSessionProvider),
```

This is a byte-for-byte match of the pattern already shipping in `SmartLearningScreen` (`lib/features/smart_learning/presentation/smart_learning_screen.dart:53-66`) — no new pattern was invented.

**Why `smartLearningSessionProvider` and never `learningSnapshotProvider`** (objective 1's explicit constraint, and the Design Review's "Refresh Strategy" section): Riverpod invalidation cascades **forward only** — from a dependency to whatever `watch`es it, never backward. `learningSnapshotProvider` is defined as:

```dart
final learningSnapshotProvider = FutureProvider.autoDispose<LearningSnapshot>((ref) async {
  final session = await ref.watch(smartLearningSessionProvider.future);
  return computeLearningSnapshot(session, DateTime.now());
});
```

(`lib/features/read_model/data/learning_snapshot_providers.dart:38-42`, unchanged this sprint). It `watch`es `smartLearningSessionProvider.future` — so it is the **dependent**, and `smartLearningSessionProvider` is the **dependency**. Invalidating the dependent (`learningSnapshotProvider`) would only clear its own cache and immediately re-read `smartLearningSessionProvider`, which is *still cached* — no new `SmartLearningRepository.getSmartLearningSession()` call happens, and the screen would silently keep showing stale data while looking like it refreshed. Invalidating the dependency (`smartLearningSessionProvider`) forces a real new repository call **and** automatically cascades to `learningSnapshotProvider` because it's watching that exact provider's future. One invalidate call, correct end-to-end refresh. The screen's own doc comment (top of the file) now spells this reasoning out in full so the next sprint doesn't have to rediscover it.

The class-level doc comment on `StudySummaryScreen` was updated to describe this (replacing the R2.2-era "chưa có pull-to-refresh, khi thêm phải..." placeholder note, which is no longer accurate now that it's implemented).

# Accessibility review

- **Semantics / screen readers** — no regressions found in the existing per-widget semantics (`LoadingState`/`EmptyStateBanner`/`SearchErrorState` all already carry `Semantics(liveRegion: true, label: ...)`, confirmed by re-reading each widget's source this sprint; `SectionHeader`'s `isHeader` flag is still asserted by the pre-existing R2.2 test, still green). Wrapping the `ListView` in `RefreshIndicator` does not insert or remove any `Semantics` node of its own into that subtree — verified by reading `RefreshIndicator`'s source (`packages/flutter/lib/src/material/refresh_indicator.dart` in the Flutter SDK): it renders its spinner via an `Overlay`-adjacent `Positioned`/`ScaleTransition`, not a wrapping `Semantics` region around the child.
- **Focus order** — unchanged: still a single top-to-bottom `Column` inside a `ListView`, no `Stack`/`Positioned` reordering was introduced.
- **Live regions** — the error message's live region (`SearchErrorState`) already existed; the "Thử lại" button it now shows is a plain `FilledButton.icon`, which gets standard button semantics automatically — no extra wiring needed.
- **Known, pre-existing limitation — not introduced by this sprint, not fixed by this sprint**: Flutter's `RefreshIndicator` has no built-in accessibility affordance. It is purely gesture/overscroll-driven; there is no semantic action or tappable target a screen-reader user (TalkBack/VoiceOver) can trigger to invoke `onRefresh` on the *data* state (only the *error* state has a real tap target, via `SearchErrorState`'s retry button). This confirmed by reading the `RefreshIndicator` SDK source — it defines no `CustomSemanticsAction`, no `onTap`, nothing beyond an optional `semanticsLabel`/`semanticsValue` for the spinner's own progress announcement (which this screen, like `SmartLearningScreen`, does not set). This is identical, unmodified behavior inherited from the exact pattern this sprint was told to replicate — fixing it would mean adding a new always-visible "refresh" button on the data state, which is a **new feature** and would deviate from `SmartLearningScreen`'s own shipped design, both explicitly out of scope for this sprint ("Do NOT add new features", "Do NOT redesign UI"). Recorded under Remaining follow-up items below, framed as a cross-cutting concern (it equally affects `SmartLearningScreen`, `LearningJourneyScreen`, and now this screen), not something specific to Read Model.

# Localization review

No new l10n keys were needed this sprint. The retry button rendered by `SearchErrorState` already uses the existing `l10n.retry` key (`"Thử lại"`/`"Retry"`/`"إعادة المحاولة"`, present in all three `lib/l10n/app_{vi,en,ar}.arb` files — confirmed by direct grep — and already exercised by `SmartLearningScreen`/`LearningJourneyScreen`/`TutorHomeScreen`'s own use of the same widget). No hardcoded strings were introduced by the refresh wiring or by the `Builder`-removal refactor (the 4 new private helper methods take an already-resolved `AppLocalizations l10n` parameter and call the same existing presentation functions R2.2 already used — no new string, no new call site for a missing key). `flutter gen-l10n` was not re-run because no `.arb` file changed.

# Performance review ("no unnecessary rebuilds")

- **Provider watch surface unchanged**: still exactly one `ref.watch(learningSnapshotProvider)` at the top of `StudySummaryScreen.build` — the same single-watch-point pattern already established by `SmartLearningScreen`/`LearningJourneyScreen`. This sprint did not add any new `ref.watch` calls anywhere in the widget subtree, so it doesn't introduce any new fine-grained rebuild source.
- **Refresh itself does not cause a "flash" through the loading state**: `AsyncValue.when()` (Riverpod ^2.6.1, the version pinned in `pubspec.yaml`) defaults to `skipLoadingOnRefresh: true`. Because `ref.invalidate(smartLearningSessionProvider)` is a *refresh* of an already-resolved provider (not a first load), `.when()` keeps calling `data`/`error` with the **previous** value while the new future is in flight, and only rebuilds once more when the new value/error lands. So a pull-to-refresh or retry tap produces exactly one extra rebuild of `_StudySummaryContent`/`SearchErrorState` (when the new result arrives) — never a spurious rebuild through `LoadingState` first. This was verified against the actual Riverpod behavior, not assumed, and is the same behavior `SmartLearningScreen` already relies on unmodified.
- **Duplication/complexity removed (objective 5, directly relevant to objective 6 too)**: R2.2 wrapped each of the 4 card-mapping call sites in `_StudySummaryContent` with `Builder(builder: (context) { ... })`. None of those closures read the injected `context` — they only use `l10n` (already resolved once at the top of `build`) and a domain object. A `Builder` exists specifically to obtain a *new* `BuildContext` scoped below something just inserted above it (e.g. a fresh `InheritedWidget`); using it here bought nothing and cost one extra `Element` per card, per rebuild, for no reason. Replaced all 4 with plain private methods (`_buildInsightCard`, `_buildStepCard`, `_buildSessionSummaryCard`, `_buildRecommendationCard`) that take `l10n` + the domain object and return the widget directly — same output, one fewer `Element` per card, and the same small mapping pattern is now named instead of repeated inline four times.
- Nothing else was found worth changing: the two `LayoutBuilder`s (outer for horizontal padding, inner for the insights grid column count) only rebuild in response to actual constraint changes, which is their job, not waste — redesigning that would be an architectural change outside this sprint's scope.

# Tests added

`test/study_summary_screen_test.dart`:
- **Updated** — the R2.1 error-state test asserted `find.byType(FilledButton), findsNothing` (true when there was no retry wiring). Now that `onRetry` is wired, a retry button legitimately appears, so the assertion was flipped to `findsOneWidget` and the test description updated to stop claiming "chưa làm refresh" (no longer true) and point at the new group below.
- **New fake** — `_SwappableSmartLearningRepository`: counts real calls to `getSmartLearningSession()`, lets a test swap in a different session for the *next* call (`setNextSession`), and can be told to fail the first N calls before succeeding. Built specifically to prove refresh triggers a genuinely new repository call with new data, not just a cache re-read.
- **New group — "Sprint R2.3 — làm mới (refresh)"** (3 tests):
  - Pull-to-refresh (simulated via `tester.fling` on the `ListView`, the standard Flutter technique for driving a `RefreshIndicator` in widget tests) causes a second real repository call and the newly-set session's content (`SessionSummaryCard`) to appear, replacing what was shown before.
  - Pull-to-refresh where the *new* data is fully empty correctly transitions to the whole-screen `EmptyStateBanner` — the "empty ... after refresh" transition objective 2 asked to be verified.
  - Tapping the "Thử lại" button after an initial failure (`failFirstCalls: 1`) triggers a second real call; when that second call succeeds, the error state is replaced by real content (`SessionSummaryCard`) — proves the retry path uses the same correct invalidation target as pull-to-refresh.
- The provider-level proof that invalidating the *dependent* (`learningSnapshotProvider`) alone does **not** trigger a new repository call already exists (`test/learning_snapshot_providers_test.dart`, third test, Sprint 18 Phase 2) — not duplicated here; this sprint's widget-level tests instead prove the positive, end-to-end case (invalidating the *dependency* does trigger a new call and the UI reflects it), which is what's new and untested until now.

# Analyze result

```
flutter analyze
...
No issues found! (ran in 8.5s)
```

# Test result

```
flutter test test/study_summary_screen_test.dart
...
00:01 +13: All tests passed!
```
```
flutter test
...
00:54 +799: All tests passed!
```
799/799 passing (796 inherited from R2.2 + 3 new this sprint). Zero regressions anywhere else in the suite.

# Remaining follow-up items (if any)

- **`RefreshIndicator` has no screen-reader-accessible trigger on the data state** — a real, pre-existing Flutter/Material limitation shared identically by `SmartLearningScreen` and `LearningJourneyScreen`, not introduced by this sprint (see Accessibility review). Worth a dedicated, cross-screen accessibility sprint later (e.g. an explicit "Refresh" action button, or a `Semantics(customSemanticsActions: {...})` wrapper) rather than a Read-Model-only fix, since fixing it only here would make this screen inconsistent with its two siblings.
- **Still no entry point from `SmartLearningScreen`.** Unchanged from R2.1/R2.2 — the route (`AppRoutes.studySummary`) still has no CTA pointing to it anywhere in the running app. Out of this sprint's scope ("Do NOT redesign navigation" was never lifted).
- **Still no action wiring on `JourneyStepCard`.** Unchanged from R2.2 — deliberately deferred again; "Do NOT add new features" this sprint reaffirms that deferral rather than lifting it.
- **`learning_snapshot_providers.dart`'s doc comment is now slightly stale**: it still says "Chưa có UI nào watch/refresh provider này ... nên không có rủi ro 'kéo làm mới trả dữ liệu cũ'" — no longer true, since this sprint is exactly that UI. Left untouched deliberately: none of R2.3's 8 objectives name this file, and it's outside the explicitly-scoped "Read Model screen + tests" — flagging it here rather than editing it unprompted, consistent with this sprint's own scope discipline.

---

READY FOR R2 FINAL REVIEW
