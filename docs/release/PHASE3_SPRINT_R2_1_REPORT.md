# Phase 3 — Sprint R2.1 Report: Read Model UI Foundation

Implemented following [PHASE3_SPRINT_R2_PLAN.md](PHASE3_SPRINT_R2_PLAN.md)
and [PHASE3_SPRINT_R2_DESIGN_REVIEW.md](PHASE3_SPRINT_R2_DESIGN_REVIEW.md).
No commit was created; nothing was pushed; no PR was opened.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `lib/features/read_model/presentation/study_summary_screen.dart` | **New** | The screen itself — `StudySummaryScreen`, a `ConsumerWidget` watching the existing `learningSnapshotProvider` and rendering Loading/Error/Empty states only. |
| `lib/app/router.dart` | Modified | New `AppRoutes.studySummary = '/study-summary'` constant + one `GoRoute` entry, following the exact existing pattern for `aiTutor`/`learningJourney`/`smartLearning`. No entry-point CTA added anywhere yet — the route exists but nothing currently links to it. |
| `lib/l10n/app_vi.arb`, `app_en.arb`, `app_ar.arb` (+ generated `app_localizations*.dart`) | Modified | Three new keys: `studySummaryTitle`, `studySummaryLoading`, `studySummaryEmpty`. |
| `test/study_summary_screen_test.dart` | **New** | 5 widget tests covering loading, error, empty, non-empty (no-crash), and route registration. |

**Not touched**: `lib/features/read_model/data/**`, `lib/features/read_model/domain/**`, `lib/features/smart_learning/**`, `lib/features/learning_journey/**`, `lib/features/ai_tutor/**`, `lib/features/analytics/**`, any database file. Confirmed via `git status`/`git diff` — zero changes outside the four files above.

# Architecture decisions

1. **Read `learningSnapshotProvider` directly — no new provider.** Per the design review's finding that this existing `FutureProvider.autoDispose` is the only Riverpod-reactive access point to `LearningSnapshot` today, and objective 4 explicitly forbids creating one. `learningSnapshotRepositoryProvider` (the non-reactive `Provider<LearningSnapshotRepository>`) was left untouched, exactly as designed — it's not a widget-consumable async source.
2. **"Do NOT bypass SmartLearningSession" interpreted as: don't route around it, not "don't use `learningSnapshotProvider`."** Both existing providers derive their result from a real `SmartLearningSession` (via `computeLearningSnapshot`); neither one skips it. The screen's own doc comment states this explicitly, since the instruction's wording could otherwise be misread as prohibiting the provider the approved design review recommends. Given the design review's own "Desired Architecture" diagram names `learningSnapshotProvider` as the intended read path, and no other legal path exists without violating objective 4, this was the only consistent reading.
3. **New route added, no entry-point CTA added.** Objective 1 ("create the screen") and objective 2 ("wire it to the existing architecture") require *some* route for the screen to be reachable at all — adding one `GoRoute` following the established convention is infrastructure, not a navigation redesign. Adding a tappable affordance to `SmartLearningScreen` (an *existing* screen's layout) was treated as further than this sprint's stated scope requires and closer to what objective 9 ("do not redesign navigation") guards against — deferred to a later sub-sprint, matching the design review's own separation of "entry point" as its own line item.
4. **`data:` branch renders no journey content.** Per objective 7, the success branch only distinguishes "nothing to show" (all of `insights`, `dailyPlan.steps`, and `smartSession.recommendations` empty → `EmptyStateBanner`) from "has content" (→ `SizedBox.shrink()`, deliberately, not a placeholder claiming to be real content). This mirrors the exact precedent this codebase already used for "provider exists, content doesn't yet" in Search's Sprint 7.1 and R1.1's scope-gated branches — not a new pattern invented for this sprint.
5. **No refresh wiring.** `SearchErrorState()` is used with no `onRetry` (the widget's own established convention for "no retry capability yet" — omitting it hides the button rather than wiring a no-op). Per the design review's Refresh Strategy, when refresh *is* added, it must invalidate `smartLearningSessionProvider`, not `learningSnapshotProvider` — noted directly in the screen's own doc comment so this isn't lost before the next sub-sprint.
6. **Reused shared widgets only**: `LoadingState`, `EmptyStateBanner`, `SearchErrorState` — the same three used by every sibling tier screen (`TutorHomeScreen`, `LearningJourneyScreen`, `SmartLearningScreen`) for their own single-provider `AsyncValue.when()` branches. No new widget was built.

# Tests added

All 5 in `test/study_summary_screen_test.dart`, using the same override seam (`smartLearningRepositoryProvider`) that `test/learning_snapshot_providers_test.dart` already established — not overriding `learningSnapshotProvider` itself, since it's a thin wrapper, not the actual data source:

- **Loading** — a `Completer`-backed fake repository (never resolves within the test) confirms `CircularProgressIndicator` renders with the correct semantics label (`studySummaryLoading`). A plain immediately-resolving fake was tried first and proved too fast for a bare `pump()` to observe — same class of timing lesson as Search's debounce testing, solved the same established way (`TESTING_GUIDE.md` §1.3's `Completer` technique).
- **Error** — a throwing fake confirms `SearchErrorState`'s icon renders and no retry button appears (confirms objective 8 — no refresh wiring yet — is honestly reflected in the UI, not just the code).
- **Empty** — a `SmartLearningSession` with empty `insights`/`dailyPlan.steps`/`recommendations` confirms the `studySummaryEmpty` text renders.
- **Non-empty, no crash** — a session with one real recommendation confirms the empty-state text does *not* appear and nothing throws, without asserting on any journey content (there isn't any yet, per objective 7).
- **Route registration** — confirms `AppRoutes.studySummary` (`/study-summary`) resolves to `StudySummaryScreen`.

Per objective 9/the deferred entry point, no navigation test through `SmartLearningScreen` was added — there's no CTA yet to click through. The route is exercised directly via the test's own isolated `GoRouter`, matching the established isolated-router widget-test pattern used elsewhere in this suite (e.g. `search_screen_test.dart`'s `_wrapSearchScreen`).

# Analyze result

```
flutter analyze
...
No issues found! (ran in 8.2s)
```

# Test result

```
flutter test
...
00:55 +791: All tests passed!
```
791/791 passing (786 inherited + 5 new). Zero regressions in any existing Read Model, Smart Learning, or router test.

# Risks

- **"Do NOT bypass SmartLearningSession" required interpretation** (architecture decision 2) — the reading adopted is internally consistent with the rest of the objectives and the approved design review, but it's a judgment call, not a restatement of unambiguous instruction text. Flagging explicitly for review rather than treating it as self-evidently correct.
- **The route is currently unreachable from the running app's UI.** `AppRoutes.studySummary` exists and is exercised by tests, but no button, card, or link anywhere in the app points to it yet — this is intentional (deferred per architecture decision 3), not an oversight, but it means this sprint's work is not yet visible to an actual user, only to tests and direct navigation.
- **The `data:` branch's `SizedBox.shrink()` for non-empty snapshots is a deliberate, temporary placeholder.** If a later sprint's scope discussion assumes "the screen already shows something for real data," that's incorrect — it currently shows nothing, by design, until R2.2 renders the four `LearningSnapshot` sections.
- **The empty-check (`insights` + `dailyPlan.steps` + `recommendations` all empty)** is the same coarse, whole-object check proposed in the design review, not yet the more granular per-section emptiness that design review also described as the eventual correct behavior once real content rendering exists — acceptable for a foundation sprint where no per-section UI exists yet to independently show/hide.

---

READY FOR R2.1 REVIEW
