# G3 Extraction Report — Reading Screen Polish

Source of truth: `MAIN_RECOVERY_ROADMAP.md`. Read-only analysis. No
branch, no commit, no cherry-pick, no rebase, no code changed.
Verified against `origin/main` at `2a232ea` (`Merge pull request #5
from .../ui/shared-accessibility-widgets`) — checked directly before
anything else, not taken from the task's status summary on faith.

---

## 1 — Every file in G3

Two commits: `a88753c` (Mushaf reading-screen refactor), `169700f`
(Basmalah double-render fix).

```
5 files changed, 502 insertions(+), 58 deletions(-)
```

| Status | File |
|---|---|
| Added | `lib/features/quran/domain/basmalah.dart` |
| Added | `test/basmalah_test.dart` |
| Added | `test/reading_basmalah_test.dart` |
| Modified | `lib/features/quran/presentation/reading/reading_screen.dart` |
| Modified | `test/reading_screen_test.dart` |

## 2 — Comparison against current `origin/main`

Both modified files' **parent state** (before G3 was originally
applied) hashed identical to their **current `main` state** — checked
directly, not assumed:

```
MATCH: lib/features/quran/presentation/reading/reading_screen.dart
MATCH: test/reading_screen_test.dart
```

Neither PR #4 (My Library) nor PR #5 (Shared Accessibility Widgets)
touched either file. G3's diff would apply to `main` right now without
conflict.

## 3 — Verification

| Check | Result |
|---|---|
| **Imports** | Every import in all 5 files read directly. `reading_screen.dart` imports `../../../stats/data/stats_store.dart` — investigated, not waved through: this line is unchanged context in G3's diff (confirmed via the actual unified diff, not just the full-file import list), predates G3 entirely, and points at a file that already exists on `main` today. Not a forward dependency G3 introduces. |
| **Routing** | `lib/app/router.dart` not in the file list. Zero route changes. |
| **Localization** | No `lib/l10n/*` file touched — the cleanest of any group analyzed so far (G2 touched all 7). |
| **Generated files** | None — no `.g.dart`, no `app_localizations*.dart`. |
| **Assets** | None touched. |
| **pubspec** | Not touched. Zero new dependency. |
| **Tests** | 2 new files (`basmalah_test.dart`, `reading_basmalah_test.dart`) + 1 modified (`reading_screen_test.dart`). All infra they import — `core/audio/ayah_audio_player.dart`, `core/database/user/user_database_providers.dart`, `core/storage/prefs_provider.dart`, `quran_providers.dart`, `quran_repository.dart`, `test/fixtures/fake_audio_player.dart` — confirmed present on current `main`, and `fake_audio_player.dart`'s content confirmed unchanged since G3's own time (parent-state hash match). |
| **Database schema** | Not touched — no `content_tables.dart`, `user_tables.dart`, or any `.g.dart` in the diff. |
| **Build configuration** | Not touched — no `android/`, `ios/`, or `.github/` path in the diff. |

## 4 — Dependency detection: G4 / G5 / G6 / G7 / remaining G8

**None found**, checked by direct search across all 5 files' full
content (not just G3's diff lines) for any reference to `search`,
`khatm`, `learning`, `quiz`, `study`, `learning_session`,
`flashcards`, `analytics`, `lexicon`, `read_model`, `ai_tutor`, or
`smart_learning` — zero matches, in either direction.

## 5 — Detected dependencies, stated per the required format

**None to state.** No file, no symbol, in G3 requires anything from
G4, G5, G6, G7, or G8. The one candidate worth naming explicitly, to
show it was checked rather than missed:

| File | Symbol | Why it appears in G3's diff | Removable? |
|---|---|---|---|
| `lib/features/quran/presentation/reading/reading_screen.dart` | `import '../../../stats/data/stats_store.dart'` | Pre-existing import, unchanged by G3 — not a dependency G3 has on anything, since the file and the line both predate this group entirely | N/A — nothing to remove; G3 doesn't own this line |

## 6 — Minimal extraction

Not applicable — no trimming needed. G3 requires zero modification to
stand as an independent PR, same conclusion as G2
(`G2_EXTRACTION_REPORT.md` §6), and for the same underlying reason:
both groups were authored before the features that would later create
real coupling (G5 onward) existed at all.

---

## Dependency graph

```
G3 ── depends on: nothing (G2, G4-G8)
    ── depended on by: nothing found — no later group's files
       overlap with basmalah.dart or reading_screen.dart
       in MAIN_RECOVERY_ROADMAP.md's own dependency notes
```

G3 sits off to the side of the roadmap's dependency chain entirely —
narrower even than G2, which at least anchors the `library`/`quran`
patch-order chain other groups build on.

## Risk assessment

| Factor | Assessment |
|---|---|
| Size | Smallest of the six pre-G8 groups (5 files, 502/−58) |
| Schema | None |
| Shared-file contention | None — no `l10n`, `router`, or database file touched, unlike every other group in this backlog |
| Test coverage | 2 new dedicated test files plus updates to the existing reading-screen suite |
| Overall | **Lowest risk in `MAIN_RECOVERY_ROADMAP.md`'s entire six-group backlog**, consistent with that document's §5 ranking |

## Recommended merge strategy

Cherry-pick both commits (`a88753c`, `169700f`) onto current `main` in
original order, exactly as done for G2 — no trimming, no
recomposition. Given zero shared-file contention with any other group,
this PR's merge timing relative to G4 is genuinely free (no evidence
either way requires an order between them, per
`MAIN_RECOVERY_ROADMAP.md` §6 point 2) — it does not need to wait on
anything beyond G2, which has already merged.

---

## READY FOR G3 PR
