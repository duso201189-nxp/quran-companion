# G4 Extraction Report — Search Foundation

Source of truth: `MAIN_RECOVERY_ROADMAP.md`. Read-only analysis. No
branch, commit, cherry-pick, or rebase. Verified against `origin/main`
at `3548e30` (`Merge pull request #6 from .../feat/reading-polish`) —
checked directly before anything else, not taken on faith from the
task's status summary.

---

## 1 — Every file in G4

One commit: `3facae1` ("feat(search): complete Sprint 7.1 Search
Foundation").

```
27 files changed, 2769 insertions(+), 5 deletions(-)
```

| Status | File |
|---|---|
| Modified | `CHANGELOG.md`, `ROADMAP.md`, `TODO.md` |
| Modified | `lib/app/router.dart` |
| Modified | `lib/features/home/presentation/home_screen.dart` |
| Added | `lib/features/quran/presentation/reading/reading_navigation.dart` |
| Modified | `lib/features/quran/presentation/surah_list_screen.dart` |
| Added | `lib/features/search/presentation/search_screen.dart` |
| Added | `lib/features/search/presentation/widgets/{result_card,search_error_state,search_result_section}.dart` |
| Modified | 7× `lib/l10n/*` |
| Added | `test/fixtures/search_test_harness.dart` |
| Added | `test/{result_card,search_accessibility,search_dark_mode,search_error_state,search_responsive,search_result_section,search_screen}_test.dart` |
| Modified | `test/surah_list_screen_test.dart` |

## 2 — Comparison against current `origin/main`

**Every modified file's parent state matches current `main` exactly**
— checked individually, not sampled: `router.dart`, `home_screen.dart`,
`surah_list_screen.dart`, `surah_list_screen_test.dart`,
`CHANGELOG.md`, `ROADMAP.md`, `TODO.md`, and all 7 `l10n` files all
hash identical between `3facae1~1` and `origin/main`. G4's diff would
apply to `main` right now without conflict — including its router.dart
and `.arb` changes, which land in exactly the context PR #4 (My
Library) already established there.

## 3 — Verification

| Check | Result |
|---|---|
| **Imports** | Every import in all 13 new/modified feature and test files read directly. All resolve to code already on `main`: `app/router.dart`, `app/theme`, `app/locale`, `shared/utils/highlight.dart` (pre-existing), `shared/widgets/app_scaffold.dart` (pre-existing), `quran` entities/screens, `l10n`, and G4's own new files. |
| **Routing** | `lib/app/router.dart` gains one import, one `AppRoutes.search` constant, one `GoRoute` — inserted immediately after PR #4's `library` route, in the same additive shape. No route removed or altered. |
| **Localization** | 7 files, clean append — 10 new `search*` keys added after the file's existing last entry. No existing key touched. |
| **Generated files** | Only the 4 l10n-generated `app_localizations*.dart` files (mechanical `gen-l10n` output). No Drift `.g.dart`. |
| **Assets** | None touched. |
| **pubspec** | Not touched. Zero new dependency. |
| **Tests** | 7 new dedicated test files + `test/fixtures/search_test_harness.dart` (a shared test harness — see §4 for a cross-reference worth knowing about) + 1 modified existing test file. |
| **Database schema** | Not touched — no `content_tables.dart`, `user_tables.dart`, or `.g.dart` in the diff. |
| **Build configuration** | Not touched — no `android/`, `ios/`, `.github/` path. |

## 4 — Dependency detection: G5 / G6 / G7 / remaining G8

**None found** — comprehensive search across all 13 feature/test files
for `khatm`, `learning`, `quiz`, `study`, `learning_session`,
`flashcards`, `analytics`, `lexicon`, `read_model`, `ai_tutor`,
`smart_learning`: zero matches.

**One real dependency exists, but on G2 — already merged, not on
anything still pending:**

| File | Symbol | Why it exists | Removable? |
|---|---|---|---|
| `lib/features/quran/presentation/reading/reading_navigation.dart` | `AppRoutes.read` (defined in `lib/app/router.dart`, added by PR #4) | This file generalizes the exact two-step navigation pattern PR #4's `LibraryScreen._open` established (named explicitly in its own doc comment) into a shared helper any "jump to an ayah from outside the tab shell" feature can reuse — Search is its first caller | **N/A — already satisfied.** `AppRoutes.read` is confirmed present in `main`'s current `router.dart` (PR #4 merged). Not a pending dependency; recorded here because objective 4 asks for every dependency detected, not only the unmet ones. |

**A cross-reference worth recording, not a blocker.**
`test/fixtures/search_test_harness.dart` — which
`P2_IMPLEMENTATION_REPORT.md` found absent when the Shared
Accessibility Widgets branch (PR #5) needed one function from it, and
worked around by inlining `localizedTestApp()` locally instead — is
exactly the file G4 creates. Once G4 merges, two copies of that
function will exist in the codebase (PR #5's inlined one and this
one). Doesn't block G4 or affect anything already merged; flagged as a
housekeeping item for whoever picks it up, matching the note already
left in `P2_IMPLEMENTATION_REPORT.md` §6.

## 5 — Independently mergeable

**Yes.**

| | |
|---|---|
| Files | 27 |
| Insertions | 2,769 |
| Deletions | 5 |
| Recommended PR scope | The single original commit, `3facae1`, cherry-picked whole — no split, no trimming. Same approach as G2 and G3. |

## 6 — Not applicable

G4 does not require a split. Section included for completeness against
the task's own numbering.

---

## Dependency graph

```
G4 ── depends on: G2 (AppRoutes.read + the navigation pattern it
                   generalizes) — already merged (PR #4)
    ── depends on: nothing from G5, G6, G7, or G8
    ── depended on by: nothing found in this backlog
       (MAIN_RECOVERY_ROADMAP.md §6 already noted G4 and G3 have
       no dependency on each other; this analysis adds that nothing
       later depends on G4 either)
```

## Risk assessment

| Factor | Assessment |
|---|---|
| Size | Largest single-commit group analyzed so far after G2 (27 files, 2,769 insertions) — no internal bundling of unrelated concerns, unlike G8's mega-commit; every file serves the one feature |
| Schema | None |
| Shared-file contention | `router.dart` and `l10n` — both confirmed to apply cleanly against `main`'s current (post-PR#4) state |
| Test coverage | 7 dedicated new test files, covering accessibility, dark mode, responsiveness, and error states explicitly by name |
| Overall | **Low risk.** Comparable to G2 in cleanliness; larger in size than G3 but with no schema or build-config exposure to raise it above Low |

## Recommended merge strategy

Cherry-pick `3facae1` onto current `main`, whole, in one PR — no
splitting needed. May merge independently of any ordering concern with
G5, G6, or G7 (none depend on it, and it depends on nothing from
them); its only real prerequisite, G2, is already on `main`.

---

## READY FOR G4 PR
