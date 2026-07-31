# G5 Implementation Report — Sprint 8 Foundation

Source of truth: `G5_EXTRACTION_REPORT.md`. Branch: `feat/sprint8-foundation`,
cut from `origin/main` at `1f0cb1c` (PR #2–#7 merged). **1 commit
cherry-picked, original history preserved.** **Not pushed, no PR
opened.**

---

## 1 — Branch

`feat/sprint8-foundation`, created from `origin/main` directly.

## 2 — Cherry-pick

| Commit | Message | Result |
|---|---|---|
| `b41493c` → `55bdf80` | feat(sprint8): reading stats, Khatm tracking, bookmark collections | Applied clean — 54 files, 7,039 insertions(+), 408 deletions(-) |

**Zero conflicts** — exactly what `G5_EXTRACTION_REPORT.md` §2
predicted from the byte-for-byte parent check across all 24 modified
files (schema, routing, l10n, and docs included), confirmed here.

## 3 — Scope preserved exactly

`git diff --name-status origin/main` lists the same 54 paths
`G5_EXTRACTION_REPORT.md` §1 enumerated — schema files, new
`khatm`/`stats` directories, extended `library` files, all 7 `l10n`
files, 4 root docs, and 17 test files. Identical set, identical
statuses.

## 4 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 168 files (0 changed)` |
| `flutter analyze --fatal-infos` | `No issues found!` |
| `flutter test` (full suite) | **344/344 pass** — 283 pre-existing (post PR #7) + 61 new, **zero regressions** |

## 5 — `git diff origin/main` verification

```
54 files changed, 7039 insertions(+), 408 deletions(-)
```

Identical to `G5_EXTRACTION_REPORT.md` §1's figures.

**Changed file count: 54. Insertions: 7,039. Deletions: 408.**

## 6 — Migration audit

Every item checked empirically, not by re-reading the diff a second
time:

| Item | Method | Result |
|---|---|---|
| **`schemaVersion` increments correctly** | Read directly from `lib/core/database/user/user_database.dart` on this branch | `schemaVersion => 3` — confirmed |
| **Migration path 2 → 3 executes** | Ran the actual test suite, then isolated the schema group specifically: `flutter test test/user_content_repository_test.dart --plain-name "schema"` | **4/4 pass**, including a test explicitly named `onUpgrade v2 -> v3: bảng cũ + dữ liệu mẫu còn nguyên, thêm study_sessions/khatm_cycles/bookmark_collections + cột collection_id trên bookmarks` — this test seeds a database at the pre-v1 shape, lets Drift run the real upgrade chain, and asserts the end state lands at `schemaVersion 3` with all 8 tables present and the original 4 tables' data untouched. Not inspected — **executed and observed passing.** |
| **No existing migration block modified** | `git diff b41493c~1 HEAD -- lib/core/database/user/user_database.dart` | The `if (from < 2) { await m.createTable(favorites); }` block is unchanged context in the diff — only a new `if (from < 3) { ... }` block was added after it |
| **Generated Drift files match handwritten schema** | Ran `dart run build_runner build` on this branch to regenerate `user_database.g.dart` and `app_database.g.dart` from the current source, then diffed the regenerated output against the committed file | Raw `diff` initially showed every line as changed — investigated before concluding anything: normalizing line endings (`tr -d '\r'`) on both files and re-diffing produced **zero differences**. The apparent mismatch was Windows CRLF on the freshly-generated file versus the committed file's line endings, not a content difference. **The committed generated code is a byte-for-byte match (content-wise) to what the current handwritten schema actually produces.** Working tree restored to the exact cherry-picked state afterward (`git checkout -- .`), confirmed via `git status` and a repeat `git diff --shortstat origin/main` showing the same 54/7039/408 figures. |

## 7 — State

| | |
|---|---|
| Branch | `feat/sprint8-foundation` |
| HEAD | `55bdf80` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean — matches the cherry-picked commit exactly, no residue from the migration audit's regeneration step |
| Pushed? | No |
| PR opened? | No |

---

READY FOR G5 PR
