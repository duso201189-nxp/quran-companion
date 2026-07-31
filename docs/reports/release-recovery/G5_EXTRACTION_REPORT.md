# G5 Extraction Report — Sprint 8 Foundation

Source of truth: `MAIN_RECOVERY_ROADMAP.md`. Read-only analysis. No
branch, commit, cherry-pick, or rebase. Verified against `origin/main`
at `1f0cb1c` (`Merge pull request #7 from .../feat/search-foundation`)
— checked directly first, not taken on faith.

---

## 1 — Every file in G5

One commit: `b41493c` ("feat(sprint8): reading stats, Khatm tracking,
bookmark collections").

```
54 files changed, 7,039 insertions(+), 408 deletions(-)
```

| Area | Files |
|---|---|
| Root docs | `CHANGELOG.md`, `DATABASE.md`, `ROADMAP.md`, `TODO.md` |
| Routing | `lib/app/router.dart` (modified) |
| **Schema** | `lib/core/database/user/{user_database.dart, user_database.g.dart, user_tables.dart}` (all modified) |
| New: Khatm | `lib/features/khatm/{data/khatm_cycle_providers.dart, data/khatm_cycle_repository_impl.dart, domain/entities/khatm_cycle.dart, domain/repositories/khatm_cycle_repository.dart, presentation/active_khatm_card.dart}` |
| New/extended: Library | `lib/features/library/{data/bookmark_collection_providers.dart, data/bookmark_collection_repository_impl.dart, domain/entities/bookmark_collection.dart, domain/repositories/bookmark_collection_repository.dart, presentation/collections/*}` (new) + `presentation/{library_screen.dart, widgets/library_ayah_tile.dart, widgets/library_tab_view.dart}` (modified — extends PR #4) |
| New/extended: Stats | `lib/features/stats/{data/study_session_providers.dart, data/study_session_repository_impl.dart, domain/entities/study_session.dart, domain/repositories/study_session_repository.dart, presentation/widgets/reading_stats_section.dart}` (new) + `presentation/stats_screen.dart` (modified — extends the pre-existing minimal stats screen) |
| Integration | `lib/features/quran/presentation/reading/reading_screen.dart` (modified) |
| Localization | 7× `lib/l10n/*` |
| Tests | 13 new + 4 modified (`app_test.dart`, `fixtures/app_harness.dart`, `reading_screen_test.dart`, `user_content_repository_test.dart`) |

## 2 — Comparison against current `origin/main`

**All 17 non-l10n modified files' parent state matches current `main`
exactly** — checked individually: `router.dart`, all three schema
files, all three touched `library` presentation files, `reading_screen.dart`,
`stats_screen.dart`, all four touched test files, and all four root
docs. All 7 `l10n` files match too. G5's diff — including its schema
migration — would apply to `main` right now without conflict.

## 3 — Verification

### Database schema and Drift migrations — the load-bearing check

**`schemaVersion` bumps 2 → 3.** Current `main` confirmed at `2`
(matches G5's expected starting point exactly). The migration is
well-formed:

```dart
if (from < 3) {
  await m.createTable(studySessions);
  await m.createTable(khatmCycles);
  await m.createTable(bookmarkCollections);
  await m.addColumn(bookmarks, bookmarks.collectionId);
}
```

Three new tables (`StudySessions`, `KhatmCycles`, `BookmarkCollections`)
**and one alteration to an existing, already-shipped table**
(`Bookmarks` gains a nullable `collectionId` column) — read this
precisely rather than treating it as "just new tables": this is the
first group in the backlog analyzed so far that changes a table users'
existing data already lives in, not only adds new ones. The `if (from
< 3)` guard is additive to the existing `if (from < 2)` block for the
prior migration — the v1→v2 path is untouched.

`DATABASE.md` is updated in the same commit (+104/−51 lines),
documenting the new tables and the `collectionId` addition — the
schema change and its documentation land together, not separately.

**Generated vs. hand-written**: `user_database.g.dart` carries
2,710/−334 of the diff's lines (Drift-regenerated, not hand-reviewed).
The actual reviewable schema change is 103 lines
(`user_database.dart` +22/−2, `user_tables.dart` +81/−0).

### Remaining checks

| Check | Result |
|---|---|
| **Imports** | Every import across all 17 new feature files read directly. All resolve to code already on `main`: `app/router.dart`, `core/database/user/*` (modified by this same commit), `quran/data/quran_providers.dart`, `quran/presentation/reading/reading_position_store.dart`, the pre-existing `stats_store.dart`, `l10n`, and G5's own new files. No `core/error`/`core/logging` import anywhere — these three repositories predate the reliability layer and are exactly the files later "adopted" into it (a separate, already-scoped G8 candidate, P4) |
| **Routing** | `router.dart` gains one import, one `AppRoutes.collections` constant, one `GoRoute` for `/collections` — additive, inserted after PR #7's `search` route. No route removed or altered |
| **Localization** | 7 files, append-only (confirmed by parent-state match; not independently re-diffed line-by-line since the hash match already proves no conflict) |
| **Generated files** | `user_database.g.dart` (Drift) + the 4 l10n-generated files. Both mechanical, not hand-authored |
| **Assets** | None touched |
| **pubspec** | Not touched. Zero new dependency |
| **Tests** | 13 new dedicated test files (including `sprint8_navigation_test.dart`, a cross-feature integration test) + 1 new fixture (`fake_bookmark_collection_repository.dart`) + 4 modified existing tests |
| **Build configuration** | Not touched — no `android/`, `ios/`, `.github/` |

## 4 — Dependency detection: G6 / G7 / remaining G8

**None found**, checked by direct search across every `lib/` and
`test/` file G5 touches for `learning`, `quiz`, `study`,
`learning_session`, `flashcards`, `analytics`, `lexicon`,
`read_model`, `ai_tutor`, `smart_learning` — one hit, investigated and
resolved:

| File | Symbol/text | Why it appears | Removable? |
|---|---|---|---|
| `lib/app/router.dart` | `/study/` (substring match) | Pre-existing route to `lib/features/study/presentation/study_screen.dart`, a file confirmed present on `main` since before PR #4 — read G5's *actual diff* to this file (not the full-file content) and confirmed it only adds the `collections` route; the `/study` line is unchanged context | N/A — not a dependency G5 has; nothing to remove |

## 5 — Can G5 merge as a single independent PR?

**Yes.**

## 6 — Not applicable

No split required. Section included for completeness against the
task's own numbering.

---

## Dependency graph

```
G5 ── depends on: G2 (extends lib/features/library/, per
                   MAIN_RECOVERY_ROADMAP.md §2.A — confirmed again
                   here via the byte-for-byte parent-state match)
    ── depends on: nothing from G6, G7, or G8
    ── depended on by: G6 (Sprint 9 extends library/stats/khatm
                   further, per the roadmap) and G8's P3/P4/F1
                   (need StudySessions/KhatmCycles/BookmarkCollections
                   to exist — this is the schema dependency
                   G8_DECOMPOSITION.md traced back to exactly this
                   commit)
```

G5 is the hinge of the whole backlog: the first group whose merge
actually unblocks part of G8 (specifically, half of P3's table
prerequisite — the other half, `SrsCards`/`QuizResults`, is G7).

## Risk assessment

| Factor | Assessment |
|---|---|
| Structural risk (does it merge cleanly) | **Low** — zero conflicts, zero unmet dependencies, confirmed by direct verification throughout |
| Deployment risk (this is a real schema migration) | **Medium** — first group in the backlog to alter a table (`Bookmarks.collectionId`) that already holds user data on any device that's run schema v2. The migration itself is well-formed and additive-only, but schema migrations are exactly the class of change `PROJ-P-002` requires deliberate review for, independent of how cleanly the surrounding code merges |
| Size | Second-largest group in the backlog (54 files, 7,039 insertions) — but 2,710 of those lines are generated, not hand-written |
| Test coverage | 13 new dedicated test files, including a cross-feature navigation integration test |
| Overall | **Medium** — matches `MAIN_RECOVERY_ROADMAP.md` §5's original "Medium-High" rating on the deployment-risk axis; this analysis found no structural reason to raise or lower it, only more precise evidence for exactly why it sits there |

## Recommended merge strategy

Cherry-pick `b41493c` onto current `main` whole — no split, no
trimming, same approach as G2/G3/G4. **Recommend the schema migration
specifically get its own explicit sign-off in review** (not just a
pass/fail from CI), given it's the first table alteration — not
merely addition — in this backlog, per `PROJ-P-002`.

---

## READY FOR G5 PR
