# Technical Debt Register — Sprint S1 Audit

Every item below traces to a specific finding in `PROJECT_AUDIT_REPORT.md`
(section referenced in parentheses). Nothing in this register has been
fixed as part of this audit — this sprint was scoped as read-only
(no new features, no UX changes, no refactors) except for a real bug
with a safe, contained, non-UX-changing fix, and no finding here cleared
that bar cleanly enough to act on without a design decision. See the
note at the end of each P0 item for why.

Priority key: **P0** = correctness/reliability risk, fix soon. **P1** =
real, evidenced debt worth a small dedicated PR. **P2** = minor/cosmetic,
opportunistic.

---

## P0 — Correctness / reliability

### D1. `learning_session` has no error handling (audit §11)

`LearningSessionController` (`lib/features/learning_session/presentation/learning_session_controller.dart:23`)
is a plain `Notifier<LearningSessionState>` with **zero `try`/`catch`
blocks in the file** (confirmed by direct grep, not agent report). Its
`start()`/`completeCurrentActivity()` methods await repository calls
that can throw, with nothing downstream to catch a failure.
`_LearningSessionLoading` renders a bare `CircularProgressIndicator`
with no `Semantics`/`liveRegion`, so even a successful-but-slow load
gives screen-reader users no feedback. This is the same class of bug as
a previously-fixed Home-screen issue (silent loading/error), reintroduced
in the newest feature (F8).

**Why not fixed in this audit**: a correct fix requires either
converting the controller to surface errors via `AsyncValue`-shaped
state or adding a local error-state field, plus new user-visible error
UI (text, possibly a retry action) and new l10n strings — this is a UX
change, which this sprint's own scope explicitly excludes ("DO NOT
change UX"). Recommend a small, dedicated S2 task scoped exactly to
this file plus its screen/summary counterpart, with the fix reviewed
against the `LoadingState`/`SearchErrorState` pattern the other
F4–F7 features already use.

### D2. Reliability layer's crash-reporting half is fully dead (audit §1, §3)

`crashReporterProvider` (`core/logging/logging_providers.dart:25`) is
never called by `withFailureLogging` and never consumed anywhere —
independently confirmed by two separate audit passes. `Logger` (the
other half) is correctly wired into 9 of 14 repositories. This means
production crashes/failures are logged (where `Logger` is used) but
never routed to a crash-reporting sink, even though the interface and
a no-op implementation both already exist.

**Why not fixed here**: wiring `CrashReporter` calls into
`withFailureLogging` is a small, mechanical change in principle, but it
touches a shared helper used by 9 repository files — outside this
sprint's "no refactor" scope without a dedicated review. Recommend as
a standalone S2 task: extend `withFailureLogging`/`withFailureLoggingStream`
to call both `Logger.error` and `CrashReporter.recordFailure`.

---

## P1 — Real, evidenced debt

### D3. `LearningSnapshotRepository` (F7, Read Model) is fully unreachable (audit §4)

Independently re-verified: no route, screen, or controller imports
anything from `lib/features/read_model/`. This was already known and
disclosed in F7's own PR description at merge time — the audit confirms
it's still true, not a new problem. Not urgent (it's inert, not
broken), but it's real: an entire merged feature with zero live
callers. Track as a known gap until a UI consumer is built, or
explicitly deprioritize Read Model's UI in the roadmap if it's no
longer planned.

### D4. Unused providers (audit §3/§5)

`statsRefreshProvider` (`stats/data/stats_store.dart:150`, fully dead
including in tests), plus `learningSnapshotRepositoryProvider` and
`learningSnapshotProvider` (both tied to D3). Low risk to remove, but
removal is cleanup/refactoring, which this sprint's scope excludes —
flagged for an S2 "dead code sweep" task rather than acted on here.

### D5. Dead files (audit §2)

`core/env/app_env.dart` (intentional forward scaffolding — not really
debt, just noting it's currently 0% used), `read_model/domain/entities/
snapshot_section.dart` (unused enum, self-documented), `shared/utils/
simple_markdown.dart` (built + tested, never called by any widget —
either wire it into `TutorSuggestionCard`/`TutorInsightCard` or remove
it), `core/cache/io_cache_manager.dart` + `cache_manager.dart` (a
complete offline-audio-cache subsystem, never constructed — matches an
existing `TODO.md` item to wire it into `AudioController`).

### D6. Duplicate empty-state and stat-card widgets (audit §7)

`_MetricCard`/`_EmptyHint` in `stats_screen.dart` duplicate
`StatCard`/`EmptyStateBanner` outright. A second, wholly unclaimed
empty-state shape is copy-pasted 5 times (`SearchEmptyState`,
two `_EmptyState` widgets, `_NoFlashcardsEmptyState`, `_QuizEmpty`).
`_JourneyEntryCard`/`_SmartLearningEntryCard` are near-identical,
explicitly-acknowledged copy-pasted cross-feature nav cards with no
shared `CrossFeatureEntryCard` ever extracted. A small, additive,
UI-invisible consolidation PR (new shared widget + call-site swaps,
zero visual change) would resolve all of these — but only worth doing
as its own explicitly-scoped task given "no refactor" is this sprint's
default.

### D7. Duplicated quiz question-option assembly (audit §8)

The four `QuestionGenerator` implementations each reimplement the same
~6-10 line "shuffle, take 3 decoys, compute correct index" tail.
Extractable into one `buildShuffledOptions<T>()` helper.

### D8. Duplicated soft-delete filter and upsert pattern in repositories (audit §9)

`t.deletedAt.isNull()` repeated 20+ times across 9 files despite a
shared `SyncColumns` mixin; a "revive-or-insert" upsert recipe
independently reimplemented ~5 times, with comments in two of the
sites explicitly acknowledging it's a copied pattern. Both are clean
extraction candidates (a Drift extension for the filter, a shared
`upsertSoftDeletable()` helper) with zero behavior change if done
carefully — again, scoped as its own task rather than folded into this
audit.

### D9. Test coverage gaps beyond the known F3 gap (audit §20)

`smart_learning/domain/session_strategy_rules.dart` (pure functions,
zero coverage), `stats/data/daily_goal_store.dart` +
`daily_goal_providers.dart` (untested, inconsistent with the sibling
`ReadingPositionStore` pattern which is tested), `flashcards/data/
flashcard_providers.dart` + `lexicon/data/lexicon_providers.dart`
(provider-wiring layer untested, though the repository impls
underneath are). Low effort, additive-only, similar in shape to the
already-completed F3 test-completion follow-up.

---

## P2 — Minor / cosmetic

### D10. Feature-coupling smells (audit §18)

`search_error_state.dart` is imported by 4 unrelated features for a
generic widget that has nothing to do with search — should move to
`lib/shared/widgets/`. `stats/data/stats_store.dart` (data layer)
imports a `quran` **presentation**-layer file just for a
`SharedPreferences` key-naming helper — a layering inversion, though
shallow.

### D11. Minor performance nits (audit §12)

`flashcard_browse_screen.dart` filters its full list synchronously in
`build()` on every keystroke, no debounce/memoization.
`smart_deck_screen.dart` uses a plain `ListView` instead of `.builder`
for a small, bounded list. Both low-impact given realistic data sizes.

### D12. Unused route-constant identifiers (audit §6)

`AppRoutes.home`/`.quran`/`.stats`/`.profile` are never referenced by
name outside `router.dart` (tabs navigate by index). The routes
themselves are live; only the identifiers are unused. Cosmetic.

### D13. Eager audio-player construction on startup (audit §13)

`JustAudioAyahPlayer()` is constructed before `runApp` rather than
lazily. Low risk (`just_audio`'s constructor is non-blocking), but it's
the one non-lazy thing on an otherwise fully-lazy startup path.

### D14. Type-level layer-skipping in entity imports (audit §1)

`session_strategy_rules.dart` and `learning_snapshot.dart` import
entity types from non-adjacent tiers of the 5-layer chain, even though
their repository *calls* stay correctly layered. Tightening this would
mean introducing thin re-exports or moving shared DTOs — a design
choice, not a bug fix.

---

## Summary count

| Priority | Count |
|---|---|
| P0 | 2 |
| P1 | 6 |
| P2 | 5 |

No item in this register was acted on during Sprint S1. See
`ROADMAP_RECOMMENDATION.md` for suggested sequencing into S2+.
