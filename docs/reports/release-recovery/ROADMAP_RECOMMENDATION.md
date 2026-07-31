# Roadmap Recommendation — Post Sprint S1

Recommendations for sequencing the `TECHNICAL_DEBT.md` register into
future sprints. This is advisory only — no code was changed in Sprint
S1, and none of this is authorized to start until explicitly
requested. Sequencing logic: fix real risk first, then take the
cheapest wins, then batch the larger cleanups so they're reviewable as
single, coherent, low-risk PRs (consistent with how P1–P4/F1–F8 were
each kept scoped to one concern).

---

## S2 — Reliability (highest priority, smallest scope)

**Single focus: close D1, the `learning_session` error-handling gap.**

This is the only finding from Sprint S1 with genuine crash/reliability
risk rather than tidiness risk — `LearningSessionController` has no
error handling at all for a set of awaited calls that can legitimately
throw. Recommended scope:
- Convert error surfacing to match the `LoadingState`/`SearchErrorState`
  pattern already used by `ai_tutor`/`learning_journey`/`smart_learning`/
  `analytics` (§11, §12 of the audit) — this is a UX change, so it needs
  its own explicit sprint rather than folding into an audit.
- Add `Semantics`/`liveRegion` to the loading state.
- Add `SectionHeader` to the summary screen for consistency with its
  siblings.
- New l10n strings (all 3 locales) for any new error copy, following
  this codebase's established pattern.

**Optional, same sprint if scope allows**: D2 (wire `CrashReporter` into
`withFailureLogging`) — small, mechanical, touches the same reliability
layer conceptually, but is a separate file/helper from D1, so it can be
split into its own PR within S2 rather than merged into D1's diff.

## S3 — Cheap, additive-only wins (no behavior change, low review risk)

Bundle these together since each is small and none touches UX:

- **Merge `feat/f3-test-completion`** (already built, gated, 720/720
  passing as of its own report) — the lowest-effort item on this whole
  list, since the work is already done and waiting.
- **D9** — add tests for `session_strategy_rules.dart`,
  `daily_goal_store.dart`/`daily_goal_providers.dart`,
  `flashcard_providers.dart`/`lexicon_providers.dart`. Same shape as the
  F3 follow-up: pure test-file additions, zero production-code risk.
- **D5** — resolve the 5 dead files: either wire
  `simple_markdown.dart` into the two card widgets it was clearly built
  for, or remove it if it's no longer wanted; same decision for
  `io_cache_manager.dart` (matches the existing `TODO.md` item to wire
  it into `AudioController` — worth checking whether that's still
  planned before deciding to wire vs. remove); remove
  `snapshot_section.dart` if Read Model's own roadmap doesn't need it
  soon.
- **D4** — remove the 3 unused providers not already covered by D3's
  broader question (`statsRefreshProvider` plus the two `learning_snapshot`
  providers, contingent on the S4 decision below).

## S4 — A product decision, not an engineering task

**D3: decide Read Model's fate.** `LearningSnapshotRepository` is fully
built, fully tested, and has zero UI consumers. Before spending any more
engineering time on it, this needs a product-level answer: is a Read
Model screen/UI still planned, or was F7 infrastructure-only by design
and should stay that way indefinitely? Either answer is fine, but it
changes what "done" looks like for D3, D4 (the two orphaned
`learningSnapshot*` providers), and D5's `snapshot_section.dart` — worth
resolving before touching any of those files, so S3's cleanup doesn't
delete something that turns out to be wanted next sprint.

## S5 — Larger, structural cleanup (batch into one reviewable pass)

These are all real but genuinely optional — the codebase functions
correctly without them, and each is a refactor, which is exactly the
category this project has been disciplined about keeping separate from
feature work:

- **D6** — extract a shared `EmptyStatePlaceholder` widget for the
  5-way-duplicated full-page empty state, migrate `_MetricCard`/
  `_EmptyHint` in `stats_screen.dart` to delegate to `StatCard`/
  `EmptyStateBanner` (matching how `TutorInsightCard` was already
  migrated), and extract a shared `CrossFeatureEntryCard` for the
  `_JourneyEntryCard`/`_SmartLearningEntryCard` pair. All additive/
  behavior-preserving if done carefully — recommend a visual diff check
  (screenshots before/after) given "no UX change" is a hard constraint
  even for a refactor-only PR.
- **D7** — extract `buildShuffledOptions<T>()` for the 4 quiz
  generators.
- **D8** — add a `SyncColumns` Drift extension for the repeated
  `deletedAt.isNull()` filter, and a shared `upsertSoftDeletable()`
  helper for the revive-or-insert pattern. Higher care needed here
  since it touches 9+ repository files — recommend doing this as its
  own dedicated sprint with full regression-test re-runs, not bundled
  with D6/D7.
- **D10, D11, D12, D13, D14** — minor items, fold into whichever of the
  above PRs touches the same file, rather than opening dedicated PRs
  for each.

## Suggested order

```
S2  Reliability fix (D1, optionally D2)              <- do first, real risk
S3  Cheap wins (F3 test-completion merge, D9, D5, D4) <- fast, safe, low review cost
S4  Product decision on Read Model (D3)                <- unblocks S3's tail and S5's D6 scope
S5  Structural cleanup (D6, D7, D8, minor items)        <- batch, careful review, screenshot diffs
```

Nothing here is scoped as "start immediately" — this is a backlog, not
a commitment. Re-prioritize freely based on what's actually next on the
product roadmap (`ROADMAP.md`'s 12-step plan takes precedence over any
of this if they conflict for attention).
