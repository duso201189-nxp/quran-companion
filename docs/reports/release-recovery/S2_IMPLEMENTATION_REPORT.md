# Sprint S2 Implementation Report — Quality & Polish

Source of truth: `PROJECT_AUDIT_REPORT.md`, `PROJECT_HEALTH_SCORE.md`,
`TECHNICAL_DEBT.md`, `ROADMAP_RECOMMENDATION.md` (Sprint S1's audit
deliverables). Branch: `sprint-s2-quality-polish`, cut from
`origin/main` (`bb9eea0`, all of P1–P4/F1–F8 merged). **Six commits,
each independently reviewable. Not pushed, no PR opened** (not
instructed to).

Scope discipline per this sprint's explicit constraints: **only**
Critical (P0) and High (P1) priority items from `TECHNICAL_DEBT.md`
were touched; no new product features; existing behavior preserved
except where a documented issue required a change; the one genuine
UX change (D1) was implemented consistently with the rest of the app
and is documented below; every logical improvement is its own commit.

---

## Priority mapping

`TECHNICAL_DEBT.md` used P0/P1/P2 labels; this task's instructions
said "Critical and High." Mapped as: **P0 → Critical, P1 → High, P2 →
Low (out of scope for S2)**. All P0 items (2) and all P1 items (6)
were evaluated; not all P1 items resulted in a code change — see §3
for the two that were deliberately deferred with reasoning, not
silently skipped.

## 1. D1 — `learning_session` error handling + accessibility (Critical)

**The centerpiece fix.** `LearningSessionController` was a plain
`Notifier<LearningSessionState>` with zero `try`/`catch` anywhere in
the file (confirmed directly, not just cited from the audit) — any
exception from its awaited repository reads propagated unhandled,
leaving the screen on an unlabeled spinner forever.

**Design decision (documented per constraint 4):** rather than
converting to `AsyncNotifier` (which would change the state shape
`LearningSummaryScreen` and the F8 build already depend on, and which
Phase 2's own doc comments explicitly warn against — "KHÔNG sở hữu
state của Review/Quiz/Flashcard... giữ nguyên"), added a `failed`
`LearningSessionStatus` value and an `error` field to the existing
state record. `start()`/`completeCurrentActivity()` now catch and
transition to `failed` instead of throwing; a new `retry()` method
re-attempts whichever operation failed (`start()` if no activity was
ever reached, `completeCurrentActivity()` otherwise — safe because
neither method mutates `state` until its try-block fully succeeds, so
the pre-failure state is always intact to retry from).

**UI**: the bare `CircularProgressIndicator` is now `LoadingState`
(same shared widget every other F4–F7 screen uses); a new `failed`
branch renders `SearchErrorState` with a retry callback — **the same
two shared widgets used everywhere else in the app**, not a new,
one-off error UI. `learning_summary_screen.dart`'s stat/activity rows
also picked up the `Semantics` merging and `SectionHeader` usage every
sibling screen already had, closing the accessibility gap the audit
found in the same feature.

**l10n**: exactly one new key, `learningSessionLoading` (all 3
locales). The error path reuses the existing generic `errorLoadData`
string — `SearchErrorState`'s own doc comment explicitly encourages
this ("mặc định dùng lại chuỗi đã có, không bịa chuỗi mới").

**Tests**: 4 new tests in `learning_session_controller_test.dart`
(start failure, completeCurrentActivity failure preserving progress,
retry's dispatch logic in both directions), 1 new widget test in
`learning_session_screen_test.dart` (SearchErrorState + Retry actually
render, no leftover spinner). 35/35 pass in this feature's own suite.

## 2. D2 — wire CrashReporter into the reliability layer (Critical)

`CrashReporter.recordFailure()` had zero call sites anywhere in
`lib/` — independently confirmed via `grep`, matching two separate
audit passes' findings. `Logger.error()` is *only* ever called from
`withFailureLogging`/`withFailureLoggingStream` (2 call sites total,
both in `repository_boundary_logging.dart`) — confirmed directly, not
assumed.

**Design decision**: rather than threading a `CrashReporter` parameter
through the 61 existing `withFailureLogging` call sites across 9
repository files (which would also require updating 9 repository
constructors, 9 provider files, and 17 test files that construct those
repositories directly), wired it into `ConsoleLogger` itself —
`Logger.error()`'s own doc comment already anticipated exactly this
("implementation thật... có thể đồng thời gửi cho CrashReporter").
`ConsoleLogger.error()` now calls `crashReporter.recordFailure(mapToAppFailure(error, stackTrace))`
when an error object is present, forwarding to whatever
`crashReporterProvider` currently resolves to (still `NoopCrashReporter`
by default — zero behavior change until a real implementation is
wired in). This reaches every repository's failures with a 2-file diff
and zero risk to the 61 existing call sites.

**Tests**: 4 new tests in `console_logger_test.dart`, 1 new integration
test in `logging_providers_test.dart` confirming the full DI chain
(`loggerProvider` → `ConsoleLogger` → injected `CrashReporter`) works
end-to-end. 18/18 pass across the 4 logging test files.

## 3. D4 (partial) — remove `statsRefreshProvider` (High)

Confirmed zero usages anywhere (including tests) before removing.
**`learningSnapshotRepositoryProvider`/`learningSnapshotProvider`**
(the other two unused providers the audit found) were deliberately
**not** touched — both are tied to whether Read Model (F7) ever gets a
UI, which `ROADMAP_RECOMMENDATION.md` correctly identified as a
product decision, not an engineering task. Removing them now would
presuppose that decision.

## 4. D6 (partial) — migrate `_MetricCard`/`_EmptyHint` to shared widgets (High)

Both `StatCard` and `EmptyStateBanner`'s own doc comments already
named `stats_screen.dart`'s private widgets as the known, unmigrated
duplicate (Sprint 15/20). Compared both widget trees line-by-line
before touching anything: identical padding, colors, border radius,
icon sizes, and text styles — the only difference is the shared
widgets already have `Semantics` wrapping the private ones lacked.
Swapped both call sites and deleted the now-dead private classes.
**Zero visual change intended**, confirmed by the tree comparison
(no `StatsScreen` widget test exists to assert this mechanically —
noted as a residual verification gap, mitigated by the fact that this
is the exact migration `TutorInsightCard` already made safely for the
identical `StatCard` case).

**Deliberately deferred** (not part of this commit): the second,
undocumented empty-state shape duplicated 5 times, and the
`_JourneyEntryCard`/`_SmartLearningEntryCard` pair — both have larger
surface area and no visual-regression tooling was available here to
verify a bigger consolidation stays pixel-identical, exactly as
`ROADMAP_RECOMMENDATION.md` S5 already flagged.

## 5. D7 — extract `buildShuffledOptions` for the 4 quiz generators (High)

All four `QuestionGenerator` implementations reimplemented the same
tail: assemble correct + decoys into an options list, shuffle, find
the correct index. Extracted the identical 2-line pattern into
`shuffled_options.dart`; each generator's own decoy-*selection* logic
(genuinely different per question type) is untouched. The extracted
helper calls `Random` exactly once (`..shuffle(random)`), the same
single call the code it replaced made — **same number and order of
`Random` calls as before**, so the existing seeded/deterministic tests
assert byte-identical output without modification.

**Tests**: new `shuffled_options_test.dart` (4 tests) plus the
existing 30 quiz-related tests re-run unmodified and still pass.

## 6. D9 — test coverage for 4 novel gaps (High)

- `session_strategy_rules.dart` (pure functions, zero prior test
  references) — 12 new tests, exhaustive over both enums.
- `daily_goal_store.dart` (untested despite the sibling
  `ReadingPositionStore`, same architecture, having its own test) — 4
  new tests mirroring that sibling's pattern.
- `daily_goal_providers.dart` (`dailyGoalProgressProvider`'s
  combining logic was never exercised) — 4 new tests. Hit a real
  `.autoDispose` test-isolation issue (reading an autoDispose provider
  without a listener can silently re-run its whole dependency chain
  from scratch instead of reflecting an already-resolved future) —
  fixed by keeping the chain alive via `container.listen(...)` before
  awaiting, the standard Riverpod test idiom for this exact case.
- `flashcardRepositoryProvider`/`lexiconRepositoryProvider` (the DI
  wiring itself was never exercised — only the underlying
  `*RepositoryImpl` classes, via direct constructor calls bypassing
  the provider layer) — 2 new tests reading each provider against a
  real in-memory database and performing one real read operation.

Pure test additions across all four — zero production code changed.

---

## What was evaluated and explicitly not changed

| Item | Priority | Why not touched |
|---|---|---|
| D3 — Read Model unreachable | High | Requires a product decision (build a UI, or accept it stays infrastructure-only) — not an engineering fix; `ROADMAP_RECOMMENDATION.md` S4 |
| D5 — 5 dead files | High | Each needs either "wire it in" (scope creep toward a new feature) or "delete it" (presumptuous without confirming nothing depends on it soon, e.g. `io_cache_manager.dart` matches a live `TODO.md` item) — no safe unambiguous action within "preserve behavior, no new features" |
| D8 — duplicated soft-delete filter / upsert pattern (9+ files) | High | This engagement's own `ROADMAP_RECOMMENDATION.md` explicitly recommended isolating this into its own dedicated sprint with full regression focus, given the surface area — not bundled here |

None of these were silently skipped — each has a stated reason above
and remains tracked in `UPDATED_TECHNICAL_DEBT.md`.

---

## Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 347 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` |
| `flutter test test` (full suite) | **767/767 pass** (731 baseline + 36 new: 5 D1 + 5 D2 + 4 D7 + 22 D9) |

## Commit ledger

| Commit | Scope |
|---|---|
| `9db6d8a` | D1 — learning_session error handling + accessibility |
| `21c1008` | D2 — wire CrashReporter into ConsoleLogger |
| `0653295` | D4 (partial) — remove dead statsRefreshProvider |
| `6d1d1a2` | D6 (partial) — stats_screen shared-widget migration |
| `ecbd229` | D7 — quiz generator option-shuffling helper |
| `8d85fc5` | D9 — 4 novel test-coverage gaps |
