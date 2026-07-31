# Technical Debt Register — Updated after Sprint S2

Supersedes the priority/status columns of
[TECHNICAL_DEBT.md](../reports/release-recovery/TECHNICAL_DEBT.md)
(Sprint S1, now archived). Item IDs (D1–D14) are unchanged so the two
documents stay cross-referenceable; only status changed here. Full
original rationale for each item lives in that archived document and
isn't repeated in full.

---

## P0 — Correctness / reliability

### D1. `learning_session` has no error handling — **FIXED (S2)**

Commit `9db6d8a`. `LearningSessionController` now catches and
surfaces failures via a new `failed` status + `retry()`; UI renders
the same `LoadingState`/`SearchErrorState` widgets every sibling
screen uses. `learning_summary_screen.dart`'s missing `Semantics`/
`SectionHeader` conventions were closed in the same commit. 6 new
tests (5 controller, 1 widget), all passing.

### D2. Reliability layer's crash-reporting half is fully dead — **FIXED (S2)**

Commit `21c1008`. `CrashReporter` is now wired into `ConsoleLogger`,
reaching every repository failure through the existing single choke
point (`withFailureLogging`/`withFailureLoggingStream` → `Logger.error()`).
Still a no-op by default (`NoopCrashReporter`) — zero behavior change
until a real implementation overrides `crashReporterProvider`, exactly
as designed. 5 new tests, all passing.

---

## P1 — Real, evidenced debt

### D3. `LearningSnapshotRepository` (F7, Read Model) is fully unreachable — **RESOLVED (Phase 3 Sprint R2)**

The product decision was made and implemented: `StudySummaryScreen`
(`lib/features/read_model/presentation/study_summary_screen.dart`,
route `/study-summary`) now consumes `learningSnapshotProvider` and
renders all four `LearningSnapshot` sections, with pull-to-refresh/
retry wired to `smartLearningSessionProvider`. Details across
`docs/release/PHASE3_SPRINT_R2_PLAN.md`,
`PHASE3_SPRINT_R2_DESIGN_REVIEW.md`, and the R2.1–R2.3 reports. Not
fully closed as a *product* surface — no CTA yet links to the route
from `SmartLearningScreen` — but the debt item itself (repository
built with no consumer, no decision made) is resolved.

### D4. Unused providers — **PARTIALLY FIXED (S2)**

Commit `0653295`. `statsRefreshProvider` removed (was fully dead, zero
usages anywhere). `learningSnapshotRepositoryProvider` and
`learningSnapshotProvider` deliberately left alone at the time — both
were downstream of D3's then-unresolved product decision, so removing
them would have presupposed that decision. D3 is now resolved (see
above): both providers are the real, actively-consumed read path for
`StudySummaryScreen`, so this reasoning no longer applies — they were
never dead code to begin with, just correctly left untouched pending a
decision that has since landed. No further action taken here as part
of Sprint R2; still recorded as "partially fixed" since the original
`statsRefreshProvider` removal is the only concrete fix in this item.

### D5. Dead files — **NOT ACTIONED, unchanged**

`core/env/app_env.dart`, `read_model/domain/entities/snapshot_section.dart`,
`shared/utils/simple_markdown.dart`, `core/cache/io_cache_manager.dart`
+ `cache_manager.dart`. Evaluated in S2 and explicitly deferred: each
needs either "wire it in" (would be new-feature-shaped work, out of
this sprint's scope) or "delete it" (risks removing something with a
near-term plan — `io_cache_manager.dart` matches a live `TODO.md`
item). No safe, unambiguous single action existed within this sprint's
"preserve behavior, no new features" constraint.

### D6. Duplicate empty-state and stat-card widgets — **PARTIALLY FIXED (S2)**

Commit `6d1d1a2`. `stats_screen.dart`'s `_MetricCard`/`_EmptyHint`
(the two duplicates both shared widgets' own doc comments already
named as the known gap) now delegate to `StatCard`/`EmptyStateBanner`
— confirmed line-by-line tree equivalence before switching, so this is
a zero-visual-change swap. Still open: the second, undocumented
empty-state shape duplicated 5 times (`SearchEmptyState` and 4
others), and the `_JourneyEntryCard`/`_SmartLearningEntryCard` pair —
both larger surface area, deliberately deferred pending visual-
regression tooling this environment doesn't have (see
`ROADMAP_RECOMMENDATION.md` S5).

### D7. Duplicated quiz question-option assembly — **FIXED (S2)**

Commit `ecbd229`. Extracted `buildShuffledOptions()`; all 4 generators
now share it, decoy-selection logic (the genuinely per-question-type
part) untouched. Verified same `Random` call count/order as before —
existing seeded tests pass unmodified. 4 new dedicated tests added.

### D8. Duplicated soft-delete filter and upsert pattern in repositories — **NOT ACTIONED, unchanged**

Still true (20+ sites for the filter, ~5 for the upsert recipe, across
9 repository files). `ROADMAP_RECOMMENDATION.md` itself recommended
this get "its own dedicated sprint with full regression-test re-runs,
not bundled with D6/D7" given the surface area — S2 respected that and
did not attempt it.

### D9. Test coverage gaps beyond the known F3 gap — **FIXED (S2)**

Commit `8d85fc5`. `session_strategy_rules.dart` (11 tests),
`daily_goal_store.dart` (4 tests), `daily_goal_providers.dart` (4
tests), `flashcardRepositoryProvider`/`lexiconRepositoryProvider`
wiring (2 tests) — all now covered. The separately-tracked F3 gap
(5 missing Analytics test files) has its own complete, already-gated
fix waiting on `feat/f3-test-completion` (commit `55b8de3`), unrelated
to and unaffected by this sprint.

---

## P2 — Minor / cosmetic — unchanged, out of scope for S2

D10 (feature-coupling smells), D11 (minor perf nits), D12 (unused
route-constant identifiers), D13 (eager audio-player construction),
D14 (type-level layer-skipping in entity imports) — none evaluated in
S2 per this sprint's explicit "Critical and High only" scope. Still
valid, still low priority, still opportunistic.

---

## Summary

| Priority | Total | Fixed | Partially fixed | Not actioned (reasoned) |
|---|--:|--:|--:|--:|
| P0 | 2 | 2 | 0 | 0 |
| P1 | 7 | 3 | 2 | 2 |
| P2 | 5 | 0 | 0 | 5 (out of scope) |

(Corrected P1 total from a pre-existing "6" to "7" — D3/D4/D5/D6/D7/D8/D9
is seven items; the previous version of this table undercounted by
one, missing D5 from its tally. Not introduced by this update, fixed
in passing while updating D3's status.)

Every P0 item is closed. Of the 7 P1 items, 3 are fully closed (D7/D9
from S2, D3 from Phase 3 Sprint R2), 2 are partially closed with the
remainder explicitly reasoned and deferred (not silently dropped), and
2 (D5, D8) were evaluated and correctly left alone — D5 because no
single action ("wire in" vs "delete") was safe and unambiguous within
S2's constraints; D8 because this engagement's own roadmap already
called for isolating it into its own sprint given its size. See
`ROADMAP_RECOMMENDATION.md` for suggested S3+ sequencing of everything
still open — note it predates D3's resolution and should be read with
that in mind.
