# Phase 3 — Sprint R2.2 Report: Read Model Journey Rendering

Built on R2.1 ([PHASE3_SPRINT_R2_1_REPORT.md](PHASE3_SPRINT_R2_1_REPORT.md)).
No commit was created; nothing was pushed; no PR was opened.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `lib/features/read_model/presentation/study_summary_screen.dart` | Modified | `_buildBody`'s `data:` branch now renders `_StudySummaryContent` (new private widget) instead of `SizedBox.shrink()`. Body wrapper changed from a plain `Padding` to `LayoutBuilder` + `ListView` (matching every sibling tier screen's own scrollable-content pattern, needed now that there's real content to scroll). |
| `lib/l10n/app_vi.arb`, `app_en.arb`, `app_ar.arb` (+ generated `app_localizations*.dart`) | Modified | 4 new keys this sprint: `studySummaryContextTitle`, `studySummaryInsightsTitle`, `studySummaryPlanTitle`, `studySummarySessionTitle`. (The diffstat below shows 7 keys per file total — 3 are R2.1's `studySummaryTitle`/`Loading`/`Empty`, still uncommitted from the prior sprint; only the 4 section titles are new this sprint.) |
| `test/study_summary_screen_test.dart` | Modified | New "Sprint R2.2" test group (5 tests) + new sample-data builders + one stale R2.1 test description corrected (see Tests). |

**Not touched**: `lib/features/read_model/data/**`, `lib/features/read_model/domain/**` (no new provider, no repository change, no new statistics computed), `lib/features/smart_learning/**`, `lib/features/learning_journey/**`, `lib/features/ai_tutor/**`, `lib/features/analytics/**`, `lib/app/router.dart` (unchanged this sprint — the route already existed from R2.1), any database file. Confirmed via `git status`/`git diff`.

# UI rendered

`_StudySummaryContent` renders all four `LearningSnapshot` fields, in the order they're declared on the entity (`context → insights → dailyPlan → smartSession`), each as one section:

1. **Context** — `TutorHeader` showing the same 3 stats `TutorHomeScreen` shows (cards studied, accuracy, reading streak), read from `snapshot.context.statistics`. No section-empty case — `TutorContext`'s numeric fields are never "empty" in a list sense, matching `TutorHomeScreen`'s own precedent of never showing an empty state for this section.
2. **Insights** — `SectionHeader` + a responsive grid of `TutorInsightCard`s for `snapshot.insights`. No dedicated empty-state check here either — `TutorHomeScreen`'s own `_TutorInsightsSection` doesn't have one (an empty grid is the accepted behavior), so this screen matches that precedent rather than inventing a new one.
3. **Today's plan** — `SectionHeader` + one `JourneyStepCard` per `snapshot.dailyPlan.steps` entry, or `EmptyStateBanner` (reusing the exact existing `learningJourneyEmpty` string) if that list is empty.
4. **Recommended session** — `SectionHeader` + `SessionSummaryCard` for the top recommendation and `RecommendationCard` for the rest, or `EmptyStateBanner` (reusing the exact existing `smartLearningEmpty` string) if `snapshot.smartSession.recommendations` is empty.

Per objective 3/4, nothing here is computed — every value shown is read directly off the snapshot and formatted through an existing pure presentation function. Per objective 7 (deferred from the design review, honored again this sprint), no `JourneyStepCard` has an action button wired — `actionLabel`/`onAction` are both left `null`, even though the underlying `TutorSuggestion` domain object could carry a real `TutorAction`. This keeps the screen purely a display surface, consistent with `SessionSummaryCard`/`RecommendationCard`'s own existing lack of any tap action.

The screen-level empty check from R2.1 is unchanged (all three list fields empty → single `EmptyStateBanner`); within `_StudySummaryContent` (reached only when *not* everything is empty), each of the three list-backed sections now independently shows its own empty state if *that* section happens to be empty while the others aren't — the per-section emptiness the design review recommended, now implemented because there's finally real per-section content to have an empty version of.

# Shared widgets reused

No new widget was created. Everything below is an existing widget or pure function, used exactly as its owning screen already uses it:

| Reused from | Item |
|---|---|
| `shared/widgets/` | `SectionHeader`, `EmptyStateBanner`, `LoadingState` |
| `search/presentation/widgets/` | `SearchErrorState` (unchanged from R2.1) |
| `ai_tutor/presentation/` | `TutorHeader`, `TutorInsightCard`, `insightPresentation`, `suggestionPresentation`, `suggestionPriorityLabel` |
| `learning_journey/presentation/widgets/` | `JourneyStepCard` |
| `smart_learning/presentation/` | `SessionSummaryCard`, `RecommendationCard`, `sessionStrategyPresentation` |

Deliberately **not** reused: `JourneyHeader`, `JourneyProgressCard`, `SmartLearningHeader` — each is a decorative/summary block that would have duplicated either this screen's own `SectionHeader` or the insights grid already shown in section 2 (`JourneyProgressCard` restates the same `TutorInsight` values `JourneyHeader`'s screen already shows via a different layout). Skipping them avoids the exact kind of duplication objective 4 warns against, even though the duplication would have been visual/presentational rather than computational.

# Tests

- **New — "Sprint R2.2" group in `test/study_summary_screen_test.dart`** (5 tests):
  - Full snapshot renders all four sections' widgets (`TutorHeader`, `TutorInsightCard`, `JourneyStepCard`, `SessionSummaryCard`, `RecommendationCard`) and all four section titles.
  - `JourneyStepCard.actionLabel`/`.onAction` are both `null` — a direct regression guard for the "no interactivity yet" decision, not just a visual check.
  - Today's-plan section empty (others populated) → shows `learningJourneyEmpty` text; other sections still render real widgets.
  - Recommended-session section empty (others populated) → shows `smartLearningEmpty` text; other sections still render real widgets.
  - Section title carries `isHeader` semantics (matches `SectionHeader`'s established convention, re-verified in this new usage context).
- **Updated**: one R2.1 test's description was stale ("Sprint R2.1 chưa vẽ nội dung thật" — no longer true) — corrected to point at the new R2.2 group instead of rewriting its still-valid assertions.
- **New sample-data builders**: `_fullSession` (all four fields populated), `_sessionMissingPlan`, `_sessionMissingRecommendations` (one list empty, others populated) — added alongside R2.1's existing `_emptySession`/`_sessionWithContent`, not replacing them.
- Every existing R2.1 test in this file re-run unmodified in its assertions and still passes.

# Analyze

```
flutter analyze
...
No issues found! (ran in 8.1s)
```

# Test

```
flutter test
...
00:55 +796: All tests passed!
```
796/796 passing (791 inherited from R2.1 + 5 new this sprint). Zero regressions anywhere else in the suite.

# Remaining work for R2.3

- **No pull-to-refresh.** Objective 7 deferred this again. When added, it must invalidate `smartLearningSessionProvider` — not `learningSnapshotProvider` — per the design review's Refresh Strategy; this is already noted directly in the screen's own doc comment so it isn't lost.
- **No entry point from `SmartLearningScreen`.** The route (`AppRoutes.studySummary`) still has nothing in the running app linking to it — deferred again, per objective 8/"do not redesign navigation," matching R2.1's own deferral for the same reason.
- **No action wiring on `JourneyStepCard`.** Deliberately deferred this sprint (see UI rendered, above) — a future sprint could wire `executeTutorAction` the same way `LearningJourneyScreen` already does, once the screen is meant to be interactive rather than purely a summary view.
- **Insights section has no empty-state message**, matching `TutorHomeScreen`'s own current gap rather than fixing it here — out of this screen's scope to lead on, since it would mean introducing a treatment `TutorHomeScreen` itself doesn't have yet.
- **Responsive/accessibility deep-dive not yet done for this specific screen** — the individual widgets reused here already have their own accessibility coverage (tested in their own feature's test files), but this screen hasn't had the kind of dedicated RTL/text-scale/touch-target pass Search got in its own R1.3 — worth considering once the screen is actually reachable from the app (post entry-point wiring).

---

READY FOR R2.2 REVIEW
