# P3 Implementation Report — Database Schema Migration (Lexicon / Flashcards / Analytics tables)

Source of truth: `G8_DECOMPOSITION.md` §"P3 — Database schema
migration", `G8_FINAL_VERIFICATION.md` (READY FOR P3). Branch:
`feat/p3-schema-migration`, cut from `origin/main` at `e0b20c4` (PR
#2–#10 merged). **1 new commit, content extracted verbatim from the
G8 mega-commit `d4976b0` (no dedicated sub-commit exists for P3 in any
history — `d4976b0` is a single squashed commit). Not pushed, no PR
opened.**

---

## 1 — Branch created cleanly from current `origin/main`

```
git fetch origin --quiet
git log origin/main --oneline -1
e0b20c4 Merge pull request #10 from duso201189-nxp/feat/sprint10-learning-engine

git checkout -b feat/p3-schema-migration origin/main
```

## 2 — Extraction, not cherry-pick — and why

`P3` was never its own commit in any branch's history; it is one named
slice inside `d4976b0`, the same situation P1 (Reliability layer, PR
#3) and P2 (Shared widgets, PR #5) were in. Following the precedent
those two PRs established (`git log 8d88155 -1` shows P1's commit
message states *"Extracted verbatim from d4976b0"*), P3's scope was
extracted the same way: each file's exact content pulled via
`git show d4976b0:<path>`, written into the branch, then committed as
one new commit — preserving the **content** exactly as `d4976b0`
shipped it (this *is* "preserving original history" in the only sense
possible when no finer-grained commit exists to cherry-pick).

## 3 — Scope: exactly P3, nothing else

`G8_DECOMPOSITION.md`'s own P3 file list was the starting point — 6
files, confirmed by diffing `d4976b0~1` against `d4976b0` for
everything under `lib/core/database/`:

```
git diff --name-status d4976b0~1 d4976b0 -- 'lib/core/database/*'
M  lib/core/database/app_database.dart
M  lib/core/database/app_database.g.dart
M  lib/core/database/tables/content_tables.dart
M  lib/core/database/user/user_database.dart
M  lib/core/database/user/user_database.g.dart
M  lib/core/database/user/user_tables.dart
```

**A 7th file required manual splitting — the one piece of this phase
that wasn't a clean copy.** `d4976b0`'s diff to
`test/user_content_repository_test.dart` bundles two unrelated
changes:

1. Schema/migration assertions (schemaVersion 5→6, table count 10→12,
   a new `onUpgrade v5 -> v6` test) — **genuinely P3's scope**, since
   this is the test that exercises P3's own migration.
2. An `import 'package:quran_companion/core/logging/console_logger.dart'`
   plus a `const ConsoleLogger()` argument added to the
   `UserContentRepositoryImpl(...)` constructor call — **P4's scope**
   (the reliability retrofit), not P3's. Confirmed directly:
   `UserContentRepositoryImpl`'s constructor on current `origin/main`
   still takes no `Logger` parameter (`lib/features/quran/data/
   user_content_repository_impl.dart` is untouched by P3 — it isn't in
   P3's file list above), so a test calling it with a `Logger` argument
   would not compile against this branch's actual repository.

**Both P4-only lines were identified and removed** — the import
(line 5) and the constructor argument (line 21) — restoring the exact
call shape `UserContentRepositoryImpl(db, newId: ..., nowMs: ...)`
that matches the constructor currently on `main`. Every other line of
the test file's diff (the schema/migration content) was kept in full.
This is precisely the kind of contamination the task's "verify every
modified file belongs to P3 only" requirement was designed to catch —
without this check, the branch would have silently smuggled in a
1-line slice of P4.

## 4 — Every touched import verified

| File | Imports | Verdict |
|---|---|---|
| `lib/core/database/app_database.dart` | `package:drift/drift.dart`, `tables/content_tables.dart` | Clean — no cross-feature import |
| `lib/core/database/tables/content_tables.dart` | `package:drift/drift.dart` | Clean |
| `lib/core/database/user/user_database.dart` | `package:drift/drift.dart`, `user_tables.dart` | Clean |
| `lib/core/database/user/user_tables.dart` | `package:drift/drift.dart` | Clean |
| `lib/core/database/app_database.g.dart` | `part of 'app_database.dart'` (generated) | Mechanical |
| `lib/core/database/user/user_database.g.dart` | `part of 'user_database.dart'` (generated) | Mechanical |
| `test/user_content_repository_test.dart` | `drift/native.dart`, `flutter_test`, `user_database.dart`, `user_content_repository_impl.dart`, `ayah_annotation.dart` — **`console_logger.dart` removed** | Clean after the P4 strip in §3 |

Every schema file imports only `drift` and its own sibling file —
zero dependency on any `lib/features/*` directory, consistent with
`G8_DECOMPOSITION.md`'s characterization of P3 as pure schema.

## 5 — Every modified file confirmed to belong to P3 only

`git status --porcelain` after the commit shows exactly 7 files
changed, matching §3's scope precisely — no 8th file, no accidental
inclusion. Cross-checked against `G8_DECOMPOSITION.md`'s and
`MAIN_RECOVERY_ROADMAP.md`'s P4/F1–F8 file lists: none of P3's 7 files
appear in any other group's scope except as noted for the test file
(handled by the split in §3).

## 6 — Schema verification

| Database | Before | After | New tables |
|---|---|---|---|
| `AppDatabase` (Group A, content) | 6 tables (`Surahs`, `Ayahs`, `TranslationSources`, `Translations`, `Reciters`, `MetaEntries`) | 14 tables | `Roots`, `Lemmas`, `Lexemes`, `WordInstances`, `GrammarFeatures`, `Phrases`, `PhraseWordInstances`, `LexiconRelations` — back Lexicon (F1) |
| `UserDatabase` (Group B, user data) | 10 tables, `schemaVersion` 5 | 12 tables, `schemaVersion` **6** | `FlashcardDecks`, `Flashcards` — back Flashcards (F2) |

`AppDatabase.schemaVersion` **stays `1`**, not a gap — confirmed by
reading the file's own doc comment: this database is a pre-built
SQLite asset regenerated by `tool/build_quran_db.py` and shipped in
`assets/`, not migrated in place on-device. The comment states
explicitly that `assets/database/quran.sqlite` does **not** yet
contain these tables — the Dart-side table declarations are added
ahead of the data, the same established pattern `DATABASE.md` already
documents for `lemmas`/`word_instances`. No binary asset file is
touched by this commit — confirmed via `git status`.

## 7 — Migration verification

`UserDatabase`'s `MigrationStrategy` gains one new guarded step,
purely additive, appended after the existing v4→v5 block (which is
byte-for-byte unchanged):

```dart
if (from < 6) {
  await m.createTable(flashcardDecks);
  await m.createTable(flashcards);
}
```

Verified empirically, not just read:

| Check | Result |
|---|---|
| `schemaVersion` reads `6` | Confirmed directly in `user_database.dart` |
| Isolated migration test run (`flutter test test/user_content_repository_test.dart --plain-name "schema"`) | **7/7 pass**, including every step of the chain: `schemaVersion 6 tạo đủ 12 bảng user`, `onUpgrade v1->v2`, `v2->v3`, `v3->v4`, `v4->v5`, and the new **`onUpgrade v5 -> v6: ... thêm flashcard_decks/flashcards`** |
| Full chain integrity | The `schemaVersion 6` test seeds a fresh v1 database and lets Drift run the real `1→2→3→4→5→6` sequence, confirmed landing at 12 tables with none of the prior 10 disturbed |
| Generated file correctness | `dart run build_runner build` run on the branch (840 inputs, 200 outputs written); regenerated `app_database.g.dart` and `user_database.g.dart` compared (CRLF-normalized) against the versions extracted verbatim from `d4976b0` — **both MATCH exactly**, confirming the committed generated files are the real, mechanical output of the hand-written schema, not hand-edited |

## 8 — Dependency verification

| Dependency | Status |
|---|---|
| P1 (Reliability layer) | Not required by P3's own scope — P3 touches no repository or logging code |
| Feature directories (`lexicon`, `flashcards`) | **Confirmed absent on `main`** (`lib/features/lexicon/` = 0 files, `lib/features/flashcards/` = 0 files) — expected and correct: P3's job is to lay the schema *ahead of* F1/F2, not to build them |
| Downstream: F1 (Lexicon) | Will depend on the 8 Group A tables this PR adds — confirmed via `d4976b0`'s `lexicon_repository_impl.dart` directly referencing `AppDatabase` |
| Downstream: F2 (Flashcards) | Will depend on `FlashcardDecks`/`Flashcards` this PR adds |
| Downstream: F3 (Analytics) | Depends on F1/F2, not directly on P3's schema |
| P4 (Reliability retrofit) | **Explicitly not touched** — confirmed by the test-file split in §3; `UserContentRepositoryImpl`'s constructor is unchanged by this PR |

No dependency on anything not already on `main`. This PR is the root
of the remaining G8 dependency graph — nothing it needs is missing.

## 9 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 212 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` |
| `flutter test test` (full suite) | **461/461 pass** — up from the 460 baseline (PR #10), the +1 being the new `onUpgrade v5 -> v6` test this PR adds. Zero regressions |

## 10 — `git diff origin/main` verification

```
7 files changed, 9100 insertions(+), 1908 deletions(-)
```

| File | Insertions | Deletions |
|---|---|---|
| `lib/core/database/app_database.dart` | 15 | 0 |
| `lib/core/database/app_database.g.dart` | 7,393 | (net, generated) |
| `lib/core/database/tables/content_tables.dart` | 172 | 0 |
| `lib/core/database/user/user_database.dart` | 13 | (net) |
| `lib/core/database/user/user_database.g.dart` | 3,119 | (net, generated) |
| `lib/core/database/user/user_tables.dart` | 68 | (net) |
| `test/user_content_repository_test.dart` | 228 | (net, minus the 2 stripped P4 lines) |

**~99% of the raw line count (10,512 of 9,100 net insertions across
the two `.g.dart` files) is Drift-generated code**, not hand-written —
the actual hand-reviewable surface is the 4 non-generated `lib/`
files (268 lines) plus the test file's schema assertions, consistent
with `G8_FEATURE_MATRIX.md`'s original observation that P3's real
diff is small relative to its generated-code footprint.

## 11 — State

| | |
|---|---|
| Branch | `feat/p3-schema-migration` |
| HEAD | `733a07b` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 12 — Remaining work after P3

Per `G8_FINAL_VERIFICATION.md`'s recommended order, once P3 merges:

```
P4   Reliability retrofit           ← needs only P1 (already merged);
                                        independent of P3, may run
                                        before/parallel/after
F1   Lexicon                        ← needs P3 (this PR)
F2   Flashcards                     ← needs F1, P3 (this PR)
F8   Learning Session (wiring)      ← needs F2
F3   Analytics                      ← needs F1, F2
F4   AI Tutor                       ← needs F2, F3
F5   Learning Journey               ← needs F4
F6   Smart Learning                 ← needs F4, F5
F7   Read Model                     ← needs F4, F5, F6
```

**9 pull requests remain** after this one to fully replace the
original `d4976b0` mega-commit.

---

READY FOR P3 PR
