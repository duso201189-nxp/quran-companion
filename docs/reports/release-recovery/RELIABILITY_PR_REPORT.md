# Reliability Layer — Standalone PR Report

Sprint: Release Recovery Phase 7. Branch: `core/reliability-layer`,
cut from `origin/main` at `6ab2959` (post CI-gate merge). **Committed
locally only — not pushed, not merged**, per objectives 8's explicit
hold.

---

## Changed files

| File | Status | Lines |
|---|---|---|
| `lib/core/error/app_failure.dart` | New, verbatim from `d4976b0` | 42 |
| `lib/core/error/failure_category.dart` | New, verbatim | 18 |
| `lib/core/error/failure_mapper.dart` | New, verbatim | 60 |
| `lib/core/error/failure_severity.dart` | New, verbatim | 22 |
| `lib/core/logging/console_logger.dart` | New, verbatim | 67 |
| `lib/core/logging/crash_reporter.dart` | New, verbatim | 16 |
| `lib/core/logging/logger.dart` | New, verbatim | 22 |
| `lib/core/logging/logging_providers.dart` | New, verbatim | 26 |
| `lib/core/logging/noop_crash_reporter.dart` | New, verbatim | 18 |
| `lib/core/logging/repository_boundary_logging.dart` | New, verbatim | 56 |
| `docs/knowledge/reliability_architecture.md` | New, verbatim | 209 |
| `test/app_failure_test.dart` | New, verbatim | 49 |
| `test/console_logger_test.dart` | New, verbatim | 58 |
| `test/failure_mapper_test.dart` | New, verbatim | 87 |
| `test/logging_providers_test.dart` | New, verbatim | 69 |
| `test/noop_crash_reporter_test.dart` | New, verbatim | 26 |
| `test/repository_boundary_logging_test.dart` | New, **trimmed** — see below | 124 |

**17 files, 969 insertions(+), 0 deletions(-).** Nothing existing was
modified — `git status` before staging showed no `M` or `D` lines, only
new files. Commit: `8d88155`.

## The one deliberate deviation from "verbatim"

`test/repository_boundary_logging_test.dart` at `d4976b0` was 145
lines and imported
`package:quran_companion/features/library/data/bookmark_collection_repository_impl.dart`
plus `package:quran_companion/core/database/user/user_database.dart`.
Reading its content found three test groups: two pure unit tests of
`withFailureLogging`/`withFailureLoggingStream` (self-contained, zero
external dependency), and a third — *"Repository thật — end-to-end
(Sprint 19 Phase 2 adoption)"* — that constructs a real
`BookmarkCollectionRepositoryImpl(db, logger)` to prove the retrofitted
repository logs correctly.

That third group requires `BookmarkCollectionRepositoryImpl`'s
constructor to already accept a `Logger`. On `main` today it does not
— that retrofit is G8 candidate **P4**, a later PR in the sequence
established in `G8_RELEASE_SEQUENCE.md`, not this one. Including it
here would either fail to compile or silently smuggle a P4-scoped
change into a P1-scoped PR, violating objective 2.

**Resolution:** the third group and its two now-unused imports were
removed (145 → 124 lines), replaced with a six-line comment naming
exactly where the removed group is, why, and where it should be
restored — verbatim, from `d4976b0` — when P4 lands. The two groups
that actually test the reliability layer itself are untouched and
still pass.

## Scope verification — no unrelated feature included

Checked directly, not assumed:

- **File list**: `git ls-tree -r d4976b0 -- lib/core/error
  lib/core/logging docs/knowledge/reliability_architecture.md`
  confirmed exactly these 10 source files + 1 doc, all `Added` at that
  commit — matching `G8_FEATURE_MATRIX.md`'s P1 inventory exactly.
- **History check**: `git log d4976b0..origin/sprint1-my-library --
  lib/core/error lib/core/logging docs/knowledge/reliability_architecture.md`
  returned empty — these files were never touched again after
  `d4976b0` on any later commit, so there is no "which version" question
  to resolve; the commit's version is the only version.
- **`pubspec.yaml`**: not modified by `d4976b0` at all (confirmed in
  `RELEASE_INVENTORY.md`'s earlier commit-by-commit scan) — this layer
  introduces no new dependency.

## Dependency verification

Every `import` line across all 10 source files and all 6 test files
was extracted and read individually (`git show d4976b0:<path> | grep
'^import'`), not sampled:

| Source | Imports found |
|---|---|
| All 10 `lib/` files | Each other, `dart:developer`, `dart:io`, `package:drift/drift.dart`, `package:flutter_riverpod/flutter_riverpod.dart` — nothing outside this layer |
| 5 of 6 test files | Only this layer's own files plus `flutter_test`/`flutter_riverpod` | 
| `repository_boundary_logging_test.dart` (as shipped here) | Only `flutter_test`, `logger.dart`, `repository_boundary_logging.dart` — the two feature-coupled imports were removed along with the group that needed them |

**Zero remaining references to any other feature, any other G8
candidate, or the database layer.**

## Compilation verification

```
flutter pub get         → resolved cleanly against main's existing lockfile
dart format --set-exit-if-changed  → 16 files, 0 changed
flutter analyze --fatal-infos      → No issues found!
```

## Test results

| Run | Result |
|---|---|
| The 6 reliability-layer test files, targeted | **22/22 pass** |
| Full suite (`flutter test`) | **168/168 pass** — 146 pre-existing (post CI-gate merge) + 22 new, **zero regressions** |

## Remaining risks

1. **The trimmed test group is not tracked by anything automatic.**
   Restoring it is a manual step for whoever implements P4 — flagged
   here, in the commit message, and in the file's own comment, but
   nothing fails if it's forgotten (it would just mean P4 ships with
   slightly less end-to-end coverage than `d4976b0` originally had).
2. **No live CI run.** Same limitation as every prior PR in this
   engagement — validated locally (format, analyze, targeted tests,
   full suite), not against a hosted Actions run, since this session
   has no GitHub API/CLI access.
3. **This layer is inert until adopted.** Nothing in the current tree
   references `AppFailure`, `Logger`, or `CrashReporter` yet — that's
   correct and intentional for P1 (matches `G8_FEATURE_MATRIX.md`'s own
   description: "purely additive... unused until a feature adopts one"),
   but it means this PR's tests are the only proof the layer works
   until P4 wires it into something real.
4. **Not committed against a moving target.** `main` was re-fetched
   immediately before branching, so this sits on top of the already-
   merged CI gate — but if further PRs land on `main` before this one
   opens, a rebase (not performed here, per "do not merge") will be
   needed before it can go up cleanly.

---

READY TO OPEN PULL REQUEST
