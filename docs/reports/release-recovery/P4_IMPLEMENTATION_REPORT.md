# P4 Implementation Report — Reliability Retrofit into Existing Repositories

Source of truth: `G8_FEATURE_MATRIX.md` §"P4 — Reliability retrofit
into existing repositories", `G8_FINAL_VERIFICATION.md`. Branch:
`feat/p4-reliability-retrofit`, cut from `origin/main` at `357c7de`
(PR #2–#11 merged, including P3/PR #11). **1 commit, content extracted
from the G8 mega-commit `d4976b0` with one file rebuilt by hand after
`flutter analyze` caught real contamination. Not pushed, no PR
opened.**

---

## 1 — Branch created cleanly from current `origin/main`

```
git fetch origin --quiet
git log origin/main --oneline -3
357c7de Merge pull request #11 from duso201189-nxp/feat/p3-schema-migration
733a07b feat(db): add schema for Lexicon/Flashcards/Analytics (P3)
e0b20c4 Merge pull request #10 from duso201189-nxp/feat/sprint10-learning-engine

git checkout -b feat/p4-reliability-retrofit origin/main
```

Independently confirmed PR #11 (P3) merged before starting:
`git merge-base --is-ancestor 733a07b origin/main` → yes.

## 2 — Extraction methodology

Same precedent as P1 (PR #3) and P3 (PR #11): P4 is not its own commit
anywhere in history — it's a named slice inside `d4976b0`. Content was
extracted via `git diff origin/main d4976b0 -- <file>` per file, then
applied as a patch and committed fresh.

## 3 — Scope discovery: 27 files, not 14

`G8_FEATURE_MATRIX.md`'s own estimate ("7 files ... 7 paired test
files") undercounts two ways, both corrected by direct verification
rather than trusted:

**A. The source-file count is 14, not 7** — the estimate treated
`quran` as one repository; it's actually two independent ones
(`QuranRepositoryImpl` for Group A content, `UserContentRepositoryImpl`
for Group B user data), each with its own `*_providers.dart`:

```
lib/features/khatm/data/{khatm_cycle_providers,khatm_cycle_repository_impl}.dart
lib/features/learning/data/{scheduler_providers,scheduler_repository_impl}.dart
lib/features/library/data/{bookmark_collection_providers,bookmark_collection_repository_impl}.dart
lib/features/quiz/data/{quiz_providers,quiz_repository_impl}.dart
lib/features/quran/data/{quran_providers,quran_repository_impl}.dart
lib/features/quran/data/{user_content_providers,user_content_repository_impl}.dart
lib/features/stats/data/{study_session_providers,study_session_repository_impl}.dart
```

Confirmed as the correct and complete set by checking every import of
`core/error`/`core/logging` across the whole `main`-vs-`d4976b0` diff,
then filtering to directories that exist on `main` (excluding
`lexicon`/`flashcards`, F1/F2 scope, still 0 files).

**B. The test-file count is 13, not 7.** Beyond the 7 dedicated
repository test files (one per repo above), 6 more test files needed
the identical 1-2 line Logger-wiring update because their own harnesses
construct one of the 7 retrofitted repositories directly:

| Test file | Why it needed the update |
|---|---|
| `test/content_database_smoke_test.dart` | Constructs `QuranRepositoryImpl(db)` directly |
| `test/library_screen_test.dart` (G2) | Constructs `UserContentRepositoryImpl(db)` in 2 places |
| `test/search_test.dart` (G4) | Constructs `QuranRepositoryImpl(db)` directly |
| `test/surah_names_test.dart` | Constructs `QuranRepositoryImpl(db)` directly |
| `test/transliteration_standard_test.dart` | Constructs `QuranRepositoryImpl(db)` directly |
| `test/user_content_repository_test.dart` | Schema content already merged via P3; this PR adds back only the `ConsoleLogger` import + constructor argument P3's extraction deliberately deferred (confirmed: this file's remaining `main`-vs-`d4976b0` diff is now exactly those 2 lines) |
| `test/repository_boundary_logging_test.dart` | Restores the "Repository thật — end-to-end" group P1's extraction left as an explicit placeholder comment: *"Restore it verbatim from d4976b0 when P4 merges"* |

**Explicitly excluded**, checked and confirmed by content before
excluding, not assumed by directory name alone:

| File | Why excluded |
|---|---|
| `lib/features/flashcards/data/{flashcard_providers,flashcard_repository_impl}.dart` | F2 scope — `lib/features/flashcards/` is 0 files on `main` |
| `lib/features/lexicon/data/{lexicon_providers,lexicon_repository_impl}.dart` | F1 scope — `lib/features/lexicon/` is 0 files on `main` |
| `test/flashcard_repository_test.dart`, `test/lexicon_repository_impl_test.dart`, `test/analytics_repository_impl_test.dart` | F2/F1/F3 scope |
| `test/tutor_home_screen_test.dart` | F4 scope — a brand-new 390-line file (`Added`, not `Modified`) that imports `flashcards`/`learning`/`lexicon`/`stats` together to build its own harness |
| `test/repository_boundary_completeness_test.dart`, `test/repository_boundary_test.dart` | Not part of G8's lineage at all — these are this recovery engagement's own CI-gate scaffolding (PR #2), absent from `d4976b0`'s original `sprint1-my-library` tree entirely |

## 4 — Real contamination found and fixed: `scheduler_repository_impl.dart`

The first `git apply` (all 27 files) succeeded, but `flutter analyze
--fatal-infos` immediately surfaced 16 issues, all traced to one file:
`undefined_named_parameter` (`updatedAtMs`), `override_on_non_
overriding_member`, and 13× `undefined_enum_constant` (`LearningItemType.lemma`).

Investigated rather than patched around: `d4976b0`'s diff to
`scheduler_repository_impl.dart` bundles P4's Logger retrofit together
with an **unrelated later generalization** — `syncWithReviewQueue`
rewritten to delegate to a new `syncItemsForType(itemType, ids)`
method, adding `LearningItemType.lemma` support for Flashcards'
smart-deck scheduling. The file's own new doc comment self-labels this
*"Sprint 13 Phase 2 — tổng quát hoá cho Flashcard"*. Confirmed this
isn't P4's scope by checking the interface file too:
`lib/features/learning/domain/repositories/scheduler_repository.dart`
is **also** modified by `d4976b0` (adding the `syncItemsForType`
abstract method) but was never in P4's file list — and
`srs_card.dart`'s entity is modified as well (the `updatedAtMs`
field). Neither file was included in this PR, so the whole-file
version of `scheduler_repository_impl.dart` didn't compile against
them.

**Fixed by hand**, not by including the extra files: rebuilt
`scheduler_repository_impl.dart` from this branch's pre-P4 version,
applying only the Logger retrofit (import, constructor parameter,
`withFailureLogging`/`withFailureLoggingStream` wrapping) while keeping
`syncWithReviewQueue`'s original ayah-only signature and logic
unchanged — matching the exact pattern verified clean in the other 6
repository files. `test/scheduler_repository_test.dart` was trimmed
the same way: kept its 2-line Logger-wiring addition, removed the
self-labeled `syncItemsForType (Sprint 13 Phase 2)` test group (4
tests, 58 lines) in full. Re-ran `flutter analyze` after the fix: `No
issues found!`.

This is exactly the class of error the task's "verify every touched
import" and "verify every modified file belongs only to P4"
requirements are designed to catch — a whole-file extraction would
have silently smuggled in unbuilt F2 groundwork.

## 5 — Every touched import verified

All 14 source files add exactly one of two imports, confirmed via
`git diff | grep "^+import"` on every file individually:

- All 7 `*_repository_impl.dart`: `core/logging/logger.dart` +
  `core/logging/repository_boundary_logging.dart`
- All 7 `*_providers.dart`: `core/logging/logging_providers.dart`

Zero cross-feature imports. A full sweep of every added import line
across all 27 files for `flashcard`/`lexicon`/`analytics`/`ai_tutor`/
`smart_learning`/`read_model` returned nothing.

## 6 — Every modified file confirmed to belong to P4 only

`git status --porcelain` after the commit shows exactly 27 files —
matching §3's fully-verified scope. No 28th file. `scheduler_
repository.dart` (interface) and `srs_card.dart` (entity) — both
touched by `d4976b0` but correctly identified as F2-adjacent scope in
§4 — remain unchanged from `origin/main` on this branch.

## 7 — Dependency verification

| Dependency | Status |
|---|---|
| P1 (Reliability layer, `core/error`/`core/logging`) | **Satisfied** — merged PR #3, this PR's only real dependency |
| Existence of the 7 target repositories (khatm, learning, library, quiz, quran×2, stats) | **Satisfied** — all merged via PR #4/#7/#8/#10 |
| F1 (Lexicon), F2 (Flashcards) | **Not required and not touched** — their repository files were excluded per §3, confirmed by directory absence |
| Downstream: nothing in this backlog depends on P4 | Confirmed — no group's file list in `G8_DECOMPOSITION.md` references any of P4's 7 repositories' `Logger` parameter |

Behavior is unchanged by this PR — every wrapped method's existing
logic is preserved verbatim; only diagnostics improve, consistent with
P1's own doc comment convention repeated in every retrofitted file.

## 8 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 212 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` (after the fix in §4 — the first pass surfaced and required the `scheduler_repository_impl.dart` correction) |
| `flutter test test` (full suite) | **462/462 pass** — up from the 461 baseline (P3). Net +1: P1's restored "Repository thật — end-to-end" group in `repository_boundary_logging_test.dart`, the only new-test contributor once the excluded lemma-test group is accounted for |

## 9 — Confirmation P4 is isolated from F1–F8

- Zero files under `lib/features/lexicon/` or `lib/features/flashcards/` touched — both remain 0 files on this branch, identical to `origin/main`.
- Zero files under `lib/features/analytics/`, `ai_tutor/`, `smart_learning/`, `read_model/` touched.
- Zero import of any F1–F8 module across all 27 touched files (§5).
- The one real contamination risk (scheduler's `lemma`/`syncItemsForType` generalization, §4) was caught and removed before commit, not left in.
- `test/tutor_home_screen_test.dart` (F4) and the 3 F1/F2/F3-specific repository test files were identified and excluded in full.

## 10 — `git diff origin/main` verification

```
27 files changed, 838 insertions(+), 610 deletions(-)
```

## 11 — State

| | |
|---|---|
| Branch | `feat/p4-reliability-retrofit` |
| HEAD | `69f5c9b` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 12 — Remaining G8 work after P4

Per `G8_FINAL_VERIFICATION.md`'s recommended order:

```
F1   Lexicon                        ← needs P3 (merged)
F2   Flashcards                     ← needs F1, P3 (merged); will
                                        reintroduce the syncItemsForType
                                        generalization excluded here,
                                        as its own PR's own scope
F8   Learning Session (wiring)      ← needs F2
F3   Analytics                      ← needs F1, F2
F4   AI Tutor                       ← needs F2, F3
F5   Learning Journey               ← needs F4
F6   Smart Learning                 ← needs F4, F5
F7   Read Model                     ← needs F4, F5, F6
```

**8 pull requests remain** after this one to fully replace the
original `d4976b0` mega-commit. The `syncItemsForType`/`lemma`
generalization excluded from this PR (§4) will need to land as part of
F2's own extraction — worth flagging explicitly for that phase's
extraction analysis, since it spans 3 files
(`scheduler_repository.dart`, `srs_card.dart`,
`scheduler_repository_impl.dart`) not all inside F2's own directory.

---

READY FOR P4 PR
