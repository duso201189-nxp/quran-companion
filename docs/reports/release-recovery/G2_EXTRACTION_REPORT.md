# G2 Extraction Report — My Library

Source of truth: `MAIN_RECOVERY_ROADMAP.md`. Read-only analysis. No
branch created, nothing committed, no cherry-pick, no code changed.
Verified against `origin/main` at `17b92e1` and the five G2 commits
(`ecee0b9`, `a963ced`, `2f5c56d`, `dde27b4`, `db34209`) directly.

---

## 1 — Can G2 be extracted into one independent PR?

**Yes**, and the strongest evidence for it: **every file G2 modifies
was checked byte-for-byte between G2's parent commit and current
`main` — all twelve matched exactly.** G2's diff would apply to `main`
right now without conflict, not just "probably" — confirmed per file,
not sampled.

## 2 — Files, insertions, deletions

```
26 files changed, 1,060 insertions(+), 5 deletions(-)
```

| Status | Count | Files |
|---|---|---|
| Added | 7 | `lib/features/library/{domain/library_item.dart, domain/library_kind.dart, presentation/library_controller.dart, presentation/library_screen.dart, presentation/widgets/library_ayah_tile.dart, presentation/widgets/library_tab_view.dart}`, `test/library_screen_test.dart` |
| Modified | 19 | `integration_test/app_e2e_test.dart`, `lib/app/router.dart`, `lib/features/profile/presentation/profile_screen.dart`, `lib/features/quran/data/{quran_repository_impl.dart, user_content_repository_impl.dart}`, `lib/features/quran/domain/repositories/{quran_repository.dart, user_content_repository.dart}`, 7 `lib/l10n/*` files, `test/{audio_controller_test.dart, fixtures/app_harness.dart, reading_screen_test.dart, surah_list_screen_test.dart, user_content_repository_test.dart}` |

## 3 — Verification

| Check | Result |
|---|---|
| **Imports** | Every import in every G2 file read directly. Zero references to any directory outside what already exists pre-G2 (`quran`, `profile`, `app/*`, `core/database/*` — all pre-existing) plus G2's own new `library/` files. No reference to `search`, `stats`, `khatm`, `learning`, `quiz`, `study`, or `learning_session` in G2's own diff. |
| **Schema** | **None touched.** `lib/core/database/tables/content_tables.dart` and `lib/core/database/user/user_tables.dart` do not appear in G2's file list. G2's repository changes are new *read queries* against tables that already exist — confirmed by the commit's own message ("data-layer read queries") and by the absence of any table-definition file in the diff. |
| **Assets** | None touched — no `assets/` path anywhere in the 26-file list. |
| **Localization** | 3 `.arb` files (+10/−1 lines each — hand-authored) plus 4 generated `app_localizations*.dart` files (+54/+27/+27/+27 — Drift-adjacent `gen-l10n` output, not hand-reviewed). The `.arb` diffs are **clean appends at end-of-file**, not insertions between existing keys — the lowest-conflict shape a sequential patch to a shared file can have. |
| **Generated files** | Only the l10n-generated `app_localizations*.dart` files (135 lines total, mechanically regenerated from the `.arb` sources, not hand-written). **Zero Drift-generated (`.g.dart`) files touched** — consistent with "no schema change." |
| **Dependencies** | `pubspec.yaml` not touched. Zero new packages. |

## 4 — Coupling detection with G3 / G4 / G5 / G6 / G7

**None found in the direction that would block extraction** — G2 is
chronologically first and, confirmed by direct import inspection,
references nothing from any of the five. The only relationships that
exist run the other way:

| Group | What it later does to G2's output | Direction |
|---|---|---|
| G3 | Modifies `quran` reading-screen files G2 also touched | G3 depends on G2 (patch-order), not the reverse |
| G4 | Modifies `quran` files further; creates `search`, independent of `library` | No import dependency either direction |
| G5 | **Extends `lib/features/library/` directly — 10 of G5's 54 files land inside the directory G2 creates** | G5 depends on G2 |
| G6 | Extends `library` further (3 files) | G6 depends on G2 (transitively via G5) |
| G7 | No file-path overlap with `library` or `quran` at all | No dependency either direction |

**One candidate coupling investigated and resolved, not just
dismissed.** A blanket grep over G2's touched files for `/stats/` and
`/study/` (directory names associated with G5 and G6) initially hit on
`lib/app/router.dart`. Reading G2's *actual diff* to that file (not
just its full content) shows the `/stats` route already existed before
G2 and is untouched by it; G2 only adds a `library` route, a `read/:id`
route, and their supporting constants. Separately confirmed
`lib/features/study/presentation/study_screen.dart` already exists on
`main` today, predating G6 entirely — the file G6 later modifies
already exists, it isn't something G2 is reaching forward for. Both
hits were pre-existing content incidentally present in files G2
happens to touch, not a real dependency.

**Second candidate checked**: `fts_query.dart`, imported by G2's new
library controller. Confirmed already tracked on current `main`,
untouched by G2's diff — pre-existing Quran full-text-search
infrastructure, not something G4 (Search) introduces.

## 5 — Why the couplings that do exist are not blocking

The only real coupling is **G5 and G6 building on top of the
`library/` directory G2 creates** — expected and desired, since My
Library and Bookmark Collections are the same conceptual feature area
maturing over two sprints. This doesn't constrain G2's own extraction
at all; it constrains G5's and G6's *sequencing*, which
`MAIN_RECOVERY_ROADMAP.md` §6 already places after G2 for exactly this
reason. Extracting G2 alone changes nothing about that downstream
requirement — G5/G6 still need it merged first, whether G2 ships as
its own PR or stayed bundled with something else.

## 6 — Minimal extraction

Not applicable in the sense of trimming — **no file in G2's 26-file
diff needs to be removed or altered to make this independent.** Unlike
`P1`'s reliability-layer extraction (which needed a 21-line test group
removed because it depended on unmerged work) and `P2`'s shared-widget
extraction (which needed one function relocated out of an unavailable
fixture), G2 requires **zero modification** to be a clean standalone
PR. It was already independent at the source.

---

## READY FOR G2 PR
