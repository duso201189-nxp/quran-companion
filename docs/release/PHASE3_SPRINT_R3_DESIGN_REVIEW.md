# Phase 3 — Sprint R3 Design Review

Read first: `docs/release/PHASE3_SPRINT_R3_PLAN.md` (blocker comparison,
candidate selection, ROI/risk/dependency reasoning for choosing D8).
This document is the technical design for executing it. No code was
modified, no commit was created, to produce this document.

---

## Goal

Eliminate the duplicated soft-delete filter and upsert-toggle pattern
(`UPDATED_TECHNICAL_DEBT.md` D8) across the repository-implementation
layer by extracting two small, shared, pure helpers — one for the
read-side filter, one for the write-side toggle — so that "what counts
as not-deleted" and "how a soft-delete is written" each exist in
exactly one place instead of 23+ independent copies.

## Scope

**In scope:**

- A shared read-side helper expressing `deletedAt.isNull()` once,
  applied at all **23 confirmed call sites** across the 7 files that
  use it: `flashcard_repository_impl.dart` (2), `khatm_cycle_repository_impl.dart`
  (2), `scheduler_repository_impl.dart` (2), `bookmark_collection_repository_impl.dart`
  (6), `quiz_repository_impl.dart` (1), `user_content_repository_impl.dart`
  (6), `study_session_repository_impl.dart` (4).
- A shared write-side helper expressing the upsert-toggle idiom
  (`Value(existing.deletedAt == null ? now : null)`) once, applied
  everywhere that exact idiom appears — confirmed 3× in
  `user_content_repository_impl.dart`; the other 6 files must be read
  line-by-line during implementation to find every instance of this or
  an equivalent inline toggle (the Plan document's grep only searched
  for the one exact variable-naming pattern found in
  `user_content_repository_impl.dart` — other files may express the
  same idea with different local variable names, e.g. `row.deletedAt`
  instead of `existing.deletedAt`; implementation must not assume the
  grep was exhaustive for this half of D8).
- Regression verification: the full existing test suite (799 tests as
  of Sprint R2) passes unmodified, plus new dedicated tests for the two
  extracted helpers themselves (mirroring D7's precedent from S2:
  `buildShuffledOptions()` shipped with its own 4 tests in addition to
  all existing seeded tests passing unchanged).

**Out of scope (explicitly deferred, do not touch):**

- The other 2 repository implementations that don't use this pattern
  (`lexicon_repository_impl.dart` — read-only, no `SyncColumns` table;
  `quran_repository_impl.dart` — reads `AppDatabase`, not
  `UserDatabase`, no soft-delete concept there at all).
- Any composing repository above the base 9
  (`ai_tutor`/`analytics`/`learning_journey`/`smart_learning`/`read_model`)
  — none of them touch `SyncColumns` tables directly; nothing to change.
- D5, D6 remainder, coverage gate, package upgrades, Web platform,
  accessibility/performance audits, Lexicon data, Store/legal — all
  separate blockers, all explicitly out of this sprint per
  `PHASE3_SPRINT_R3_PLAN.md` §3–4.
- Any schema change. `SyncColumns`, its `deletedAt` column, and every
  table definition in `user_tables.dart` stay exactly as they are —
  this is a Dart-expression-level consolidation, not a migration.
- Any change to what gets logged or how — `withFailureLogging`/
  `withFailureLoggingStream` wrapping at each method stays exactly
  where it is; see Architecture Impact.

## Non-goals

- **Not** a general repository-layer refactor — only the two named
  duplicated patterns are touched. Other per-file quirks (naming,
  ordering, unrelated helper methods) are left alone even where they
  look inconsistent, to keep the diff reviewable and the regression
  surface minimal.
- **Not** an opportunity to also fix D5/D6/D10–D14 "while we're in the
  file" — each of those is a separate, independently-scoped item;
  bundling them was explicitly rejected by this project's own prior
  planning (`RELEASE_PLAN_V1.md`: "its own dedicated sprint... not
  bundled with smaller cleanups").
- **Not** a performance optimization. The generated SQL is expected to
  be identical before and after — this is a source-level
  de-duplication, not a query-plan change.
- **Not** a step toward soft-delete becoming e.g. a generic repository
  base class or code-generation macro. Two small functions are the
  right size for 23 call sites; a heavier abstraction (base class,
  mixin requiring inheritance changes, build_runner generator) would
  be over-engineering for the actual duplication size and would touch
  every repository's class declaration, increasing risk for no
  corresponding benefit.

## Architecture impact

**None at the provider or UI layer — this is entirely internal to the
repository-implementation layer.** Specifically:

- New file: a small helper module living next to `SyncColumns` itself
  (`lib/core/database/user/user_tables.dart`), following the same
  "one small file per shared concern" convention already established
  by `lib/core/logging/repository_boundary_logging.dart` sitting next
  to `lib/core/logging/logger.dart`. Proposed shape (illustrative, not
  final — implementation may refine names):

  ```dart
  extension SyncColumnsQuery on SyncColumns {
    Expression<bool> get isAlive => deletedAt.isNull();
  }

  Value<DateTime?> toggledDeletedAt(DateTime? current, DateTime now) =>
      Value(current == null ? now : null);
  ```

  Both are pure — no `Logger`, no `Ref`, no I/O, no state. This matters
  architecturally: they can be unit-tested with zero fakes/mocks, and
  they cannot themselves introduce a reliability-layer gap because
  they never do anything failable.

- **Must compose with, not replace, the Sprint 19 reliability layer.**
  Every method in the 7 target files is already wrapped in
  `withFailureLogging(_logger, 'methodName', () async { ... })`
  (`core/logging/repository_boundary_logging.dart`). The refactor
  extracts only the query-building *expression* inside each closure —
  the `withFailureLogging(...)` call itself, at every site, is
  untouched. Concretely: `..where((t) => t.deletedAt.isNull())`
  becomes `..where((t) => t.isAlive)` *inside* the existing wrapped
  closure, not a restructuring of the closure or the wrapping around
  it.
- **No provider signature changes.** Every `*RepositoryImpl`
  constructor, every public method signature, every return type is
  unchanged — this is invisible above the repository-implementation
  layer. `*_providers.dart` files across all 7 features are not
  expected to need any edit.
- **No change to the composition chain.** The 5-layer AI-adjacent
  chain (`AnalyticsRepository → AITutorRepository →
  LearningJourneyRepository → SmartLearningRepository →
  LearningSnapshotRepository`) and its "optimize within one call, not
  across calls" invariant are untouched — none of those 5 repositories
  are among the 7 files in scope.

## Files expected to change

| File | Change |
|---|---|
| `lib/core/database/user/user_tables.dart` (or a new sibling file, e.g. `lib/core/database/user/sync_columns_query.dart` — final placement is an implementation-time call, not a planning-time one) | **New**: the `isAlive` extension getter and `toggledDeletedAt` helper. |
| `lib/features/flashcards/data/flashcard_repository_impl.dart` | 2 filter sites updated to `t.isAlive`; upsert-toggle sites (if any beyond what's already enumerated) updated to `toggledDeletedAt(...)`. |
| `lib/features/khatm/data/khatm_cycle_repository_impl.dart` | 2 filter sites updated. |
| `lib/features/learning/data/scheduler_repository_impl.dart` | 2 filter sites updated. |
| `lib/features/library/data/bookmark_collection_repository_impl.dart` | 6 filter sites updated. |
| `lib/features/quiz/data/quiz_repository_impl.dart` | 1 filter site updated. |
| `lib/features/quran/data/user_content_repository_impl.dart` | 6 filter sites + 3 confirmed upsert-toggle sites updated. |
| `lib/features/stats/data/study_session_repository_impl.dart` | 4 filter sites updated. |
| New test file, e.g. `test/core/sync_columns_query_test.dart` | Unit tests for both extracted helpers. |
| No test file for any of the 7 repositories should need behavioral changes — their existing tests assert repository *behavior* (what rows come back), which does not change. If any repository test currently asserts on the literal query-expression shape rather than behavior, that would be a pre-existing test-design issue this sprint would surface, not one it should paper over. |

**Not expected to change**: anything under `lib/features/*/presentation/`,
`lib/features/*/domain/`, any `*_providers.dart`, any `.arb`/generated
l10n file, `lib/app/router.dart`, any database schema/migration file.

## Risks

- **Missed call sites.** The upsert-toggle half of D8 was only grep-verified
  for one exact variable-naming pattern; other files may express the
  same idea differently. Mitigation: implementation must read all 7
  files in full (not just grep-and-replace), and the acceptance
  criteria below require an explicit "re-grepped after, zero remaining
  literal `deletedAt.isNull()` outside the new helper" check, not just
  "tests still pass" (tests passing doesn't prove every site was
  migrated — a missed site is not a test failure, it's just
  unconsolidated debt that silently survives the sprint).
- **Subtle behavioral drift in the helper itself.** If `isAlive` is
  defined even slightly differently from the original expression at
  every site (unlikely here, since all 23 confirmed sites are
  character-for-character identical, but worth stating), every call
  site would silently inherit the same bug at once — the opposite of
  today's failure mode (one wrong site) but a real one. Mitigation: the
  helper's own unit test asserts its generated SQL/behavior against a
  known fixture *before* any call site is migrated, not after.
  Migrating a call site is a mechanical, reviewable diff against a
  pre-verified helper.
- **`&`-combined conditions.** Several sites (e.g.
  `t.id.equals(collectionId) & t.deletedAt.isNull()`) combine the
  filter with another condition. The extension getter approach
  (`t.id.equals(collectionId) & t.isAlive`) preserves this cleanly, but
  each such site should be diffed individually, not assumed safe by
  pattern-matching alone.
- **Regression surface is real but well-mitigated.** 7 files, 23+ call
  sites is meaningful surface area — but every one of these 7
  repositories already has an existing test file exercising real
  behavior (confirmed by this project's own test suite history: S2's
  D9 fix specifically added coverage for adjacent gaps in this exact
  layer). The full suite must run green with zero skipped/modified
  assertions in any of the 7 repositories' own test files — a test
  needing to change to keep passing would itself be a signal something
  behavioral shifted, not just cosmetic.
- **Scope creep temptation.** Once inside these 7 files, other
  small-looking cleanups will be visible (this is explicitly called
  out in Non-goals). The discipline risk is real specifically because
  this sprint has zero UI-facing verification (no screen to look at
  and confirm "looks right") — the only guardrail is the test suite
  and a disciplined diff, so scope discipline matters more here than
  in a UI-facing sprint where a visual check would catch an accidental
  over-reach.

## Test strategy

1. **New unit tests for the two extracted helpers**, in isolation, no
   repository involved: `isAlive` against a fixture row with
   `deletedAt: null` (alive) and one with a real timestamp (not
   alive); `toggledDeletedAt` against both directions (`null` → `now`,
   and `now` → `null`), matching the exact toggle semantics already
   used inline at the 3 confirmed sites today.
2. **Zero changes to existing repository test assertions.** Run the
   full suite (baseline: 799 passing as of Sprint R2) before touching
   any repository file, to have a clean baseline diff; run it again
   after each file's migration, not just once at the end — this
   isolates which file a regression came from immediately, rather than
   needing to bisect across 7 simultaneous changes.
3. **Post-migration verification pass**: grep every `*_repository_impl.dart`
   for the literal string `deletedAt.isNull()` and for the literal
   upsert-toggle expression — both should return **zero matches**
   outside the new helper file itself. This is the check that catches
   what "tests pass" alone cannot (see Risks).
4. **Gates**: `dart format lib test`, `flutter analyze --fatal-infos`,
   `flutter test` all clean — same standing gate as every prior sprint
   in this engagement, no exception for this being "just a refactor."

## Accessibility considerations

**None.** This sprint has zero UI surface — no widget, no screen, no
semantics tree is touched by any file in scope. This is not a section
being skipped; it is a genuine, verified "not applicable," and one of
the reasons D8 was selected over every other remaining candidate (see
`PHASE3_SPRINT_R3_PLAN.md` §4) — a sprint with an honestly-empty
Accessibility section is a lower-risk sprint than one that has to fill
it in.

## Localization considerations

**None.** No user-facing string is added, removed, or changed by this
sprint — the change is entirely inside Dart query-expression code, not
user-visible text. No `.arb` file is expected to change; if `flutter gen-l10n`
were somehow run as part of this sprint's own verification, it should
produce a zero-diff, since nothing translatable moved.

## Performance considerations

**Expected to be a no-op at the SQL level.** `t.isAlive` compiles to
the exact same Drift `Expression<bool>` that `t.deletedAt.isNull()`
already compiles to — this is a source-level rename/extraction, not a
new code path, so the generated SQL for every migrated query site
should be byte-for-byte identical before and after. If it is not
(e.g., if the extension method introduces any wrapping that changes
Drift's expression tree), that itself would be a bug this sprint must
catch, not a performance trade-off to accept. No new object allocation
of consequence — `toggledDeletedAt` allocates one `Value<DateTime?>`,
exactly as the inline version already does today; nothing changes in
allocation shape, only in where the allocating expression is written.

## Rollback strategy

Lowest-risk rollback of anything this whole engagement has produced so
far, precisely because of the zero-UI, zero-schema, zero-provider
surface area:

- Each of the 7 file migrations is independent and can be reverted
  file-by-file without affecting the others (no file depends on
  another file's migration being done first).
- The new helper file can be deleted and every call site reverted to
  its original inline expression via a straightforward `git revert` of
  the sprint's commit(s) — there is no data migration, no schema
  change, and no persisted state whose shape depends on this sprint,
  so a revert has no follow-on cleanup required (unlike, say, a schema
  change that would need its own down-migration).
- Recommended sequencing to make rollback even cheaper if needed:
  land the shared helper + its tests as one commit, then migrate the 7
  files as either one combined commit or up to 7 individual commits —
  final grouping is an implementation-time call, but even one combined
  commit is trivially revertible given the total independence from
  every other subsystem.

## Acceptance criteria

1. `lib/core/database/user/user_tables.dart` (or an explicitly-named
   sibling file) contains the `isAlive` extension getter and
   `toggledDeletedAt` helper, each with its own dedicated unit test.
2. All 23 currently-confirmed `deletedAt.isNull()` filter call sites
   across the 7 named files use the new helper; a post-migration grep
   for the literal expression outside the helper file returns zero
   matches.
3. Every upsert-toggle site using the `existing.deletedAt == null ?
   now : null` idiom (or an equivalent found during the required
   full read of each file) uses `toggledDeletedAt`; same zero-literal-matches
   check applies.
4. `dart format lib test`, `flutter analyze --fatal-infos`, and
   `flutter test` are all clean, with the full suite at 799 tests
   passing plus whatever new tests this sprint adds (net increase, no
   test deleted or weakened to make this pass).
5. Zero files outside the list in "Files expected to change" are
   modified — specifically zero `presentation/`, zero `domain/`, zero
   `*_providers.dart`, zero `.arb`/l10n, zero schema/migration file.
6. `docs/release/UPDATED_TECHNICAL_DEBT.md`'s D8 entry is ready to be
   updated to "FIXED" once this sprint's own report is written
   (the actual doc edit happens in the sprint's own close-out task,
   matching how D3 was handled in Sprint R2 — not part of this design
   review or of implementation itself).

---

Do NOT implement. Do NOT refactor. Do NOT create any commit.

READY FOR R3 IMPLEMENTATION
