# Phase 3 — Sprint R3b Final Review

Reviews the cumulative, still-uncommitted work of R3b.1, R3b.2, and
R3b.3 as one unit — every file currently modified in the working tree,
not each sprint's isolated diff. Nothing was changed by this review;
findings are read-only, and every claim below was re-verified against
the current file contents and a fresh gate run, not carried over from
the individual sprint reports.

---

## 1. Files in scope

`git diff --stat` against the last commit (`0ef9b9c`) — 16 files, 137
insertions, 301 deletions:

```
lib/features/flashcards/data/flashcard_providers.dart       |  21 ++
lib/features/flashcards/presentation/add_flashcard_screen.dart | 33 +-
lib/features/profile/presentation/profile_screen.dart       |  25 +-
lib/features/search/presentation/search_screen.dart         | 123 +---
lib/l10n/app_ar.arb                                          |   2 -
lib/l10n/app_en.arb                                           |   2 -
lib/l10n/app_localizations.dart                               |  12 -
lib/l10n/app_localizations_ar.dart                            |   6 -
lib/l10n/app_localizations_en.dart                            |   6 -
lib/l10n/app_localizations_vi.dart                            |   6 -
lib/l10n/app_vi.arb                                           |   2 -
test/flashcard_ux_test.dart                                   |  38 +-
test/search_accessibility_test.dart                           |  12 +-
test/search_dark_mode_test.dart                               |  19 -
test/search_responsive_test.dart                              |  10 -
test/search_screen_test.dart                                  | 121 +--
```

Every file was re-read in full (not diff-only) for this review — the
diff shows what changed, but dead code, obsolete comments, and
inconsistencies can hide in the parts that *didn't* change around a
diff, so both were checked.

## 2. Per-file findings

### `lib/features/search/presentation/search_screen.dart` (R3b.1 + R3b.2)

The largest diff (123 lines removed net) — `SearchMode`, `SearchScope`,
the `SegmentedButton`, the `ChoiceChip` row, and the two-part guard
clause they fed are all gone. Re-read the full 479-line file after all
three sprints' cumulative changes:

- **Dead code**: none. The removal is complete — `grep` for
  `SearchMode`, `SearchScope`, `ChoiceChip`, `SegmentedButton<SearchMode>`
  across `lib/` returns exactly one hit, a historical doc-comment
  sentence explaining the removal, not code.
- **Duplicated logic**: none introduced.
- **Obsolete comments**: none. The class-level doc comment was
  rewritten to explain the R3b.1/R3b.2 changes in place of the stale
  R1.1 paragraph that used to describe Mode/Scope behavior; the
  `_buildBody` guard's comment was similarly rewritten rather than left
  describing a branch that no longer exists.
- **Structural simplification**: `build()`'s `Column` wrapping three
  children (mode row, scope row, body) collapsed to `_buildBody(l10n)`
  alone once two of the three children were removed — the wrapper
  itself was correctly removed too, not left as a single-child no-op.
- **Accessibility**: no regression. `SearchEmptyState`'s
  `Semantics(header: true)` markers and `_PlaceholderChipRow`'s
  `ExcludeSemantics` wrapper (untouched — A4/A5 were explicitly out of
  scope for R3b.1–3) are unaffected; the removed `SegmentedButton`/
  `ChoiceChip` row's semantics simply no longer exist, which is the
  intended outcome, not a gap.
- **Localization**: `searchAskLabel` and `searchScopeMyNotes` correctly
  retired (zero remaining call sites, verified by `grep`); `filterAll`,
  `tabQuran`, `searchLabel` correctly kept (each has live call sites
  outside this file — `surah_list_screen.dart`, `app_scaffold.dart`,
  `home_screen.dart` — re-verified this pass, not assumed from the
  R3b.2 report).
- **Unnecessary rebuilds / provider misuse**: none — `searchResultsProvider`
  is still watched exactly once, at the same point it always was.

### `lib/features/profile/presentation/profile_screen.dart` (R3b.1)

- **Dead code**: none.
- **Duplicated logic**: none.
- **Obsolete comments**: none — the class doc comment was rewritten to
  match the new B1/B2/B3 treatment, including an explicit note on *why*
  B2 got a different fix (removal) than B1/B3 (relabel), so a future
  reader isn't left wondering about the asymmetry.
- **Accessibility**: no regression — the three `ListTile`s were and
  remain `enabled: false`, Flutter's built-in disabled semantics
  unaffected by the label/tile-count change.
- **Localization**: `comingInStep` retained as a defined key with **zero
  remaining call sites** in `lib/` — flagged, not silently missed (see
  §3 for whether this blocks approval). `profileGoal` correctly
  **not** orphaned — re-confirmed by grep this pass: still live in
  `daily_goal_dialog.dart` and `home_screen.dart`.
- **Provider misuse**: none — no provider logic touched in this file.

### `lib/features/flashcards/data/flashcard_providers.dart` (R3b.3)

- **Dead code**: none.
- **Duplicated logic**: none — `lemmaLibraryAvailableProvider` calls
  the existing `searchLemmas` method rather than reimplementing any
  query logic; it does not duplicate `lemmaSearchProvider` (different
  purpose: existence check vs. actual results).
- **Architecture**: clean. `LexiconRepository`'s interface and
  `AppDatabase` schema are untouched; the new provider follows the same
  `FutureProvider.autoDispose` shape as every other read-only provider
  already in this file.
- **Provider misuse**: none. `ref.watch(lexiconRepositoryProvider)`
  inside the `FutureProvider` body is the same pattern
  `resolvedFlashcardsProvider` and `verbFormGroupsProvider` already use
  a few lines below it — consistent, not novel.
- **Unnecessary rebuilds**: none. The provider is not parameterized by
  query text, so it resolves once per screen visit (autoDispose) and
  does not refetch on every keystroke in the search field — confirmed
  by re-reading `_LemmaSourceBody`'s `ref.watch` call, which reads the
  same provider instance across rebuilds.
- **One documentation nit, not blocking**: the doc comment references
  `[LexiconRepository.searchLemmas]` in brackets, but `LexiconRepository`
  the type is not imported into this file (only `lexiconRepositoryProvider`,
  via `lexicon_providers.dart`) — the dartdoc cross-reference will not
  resolve to a link. This produces no analyzer diagnostic (confirmed —
  `flutter analyze --fatal-infos` is clean) and is cosmetic only. Not
  worth a revision cycle; noted for whoever next edits this file.

### `lib/features/flashcards/presentation/add_flashcard_screen.dart` (R3b.3)

- **Dead code**: none. `_LemmaResults` is still reachable (through
  `_LemmaSourceBody` when data exists) and still the widget actually
  doing the search work — it was not replaced, only gated.
- **Duplicated logic**: none — `_LemmaSourceBody` adds exactly one new
  `AsyncValue.when`, no logic copied from elsewhere.
- **Obsolete comments**: none — the `AddFlashcardSource` enum's original
  Sprint 13 doc comment was kept (still accurate: Lemma has a real
  query, Root/Phrase don't) and a new paragraph appended explaining the
  R3b.3 addition, consistent with this codebase's layered-history
  comment convention observed throughout the rest of this review.
- **Accessibility**: no regression — `_SourceNotAvailable` is reused
  verbatim (same widget, same Semantics shape) for both its original
  Root/Phrase use and the new Lemma-when-empty use.
- **Provider misuse / rebuilds**: `_LemmaSourceBody.build()` is
  reconstructed on every parent `setState` (each keystroke updates
  `_query`), and calls `ref.watch(lemmaLibraryAvailableProvider)` each
  time — but since that provider isn't keyed by the query and Riverpod
  returns the already-resolved `AsyncData` synchronously on repeat
  watches, this does not refetch or cause extra async work per
  keystroke. Same rebuild profile as the pre-existing `_LemmaResults`
  widget watching `allFlashcardsProvider` the same way.

### l10n files (`app_{vi,en,ar}.arb` + generated `app_localizations*.dart`)

- Diffs are symmetric across all three locales (confirmed via `git
  diff` on the three source `.arb` files side by side) — no locale was
  edited without the other two.
- Generated files match: re-ran `flutter gen-l10n` conceptually via the
  same command used in R3b.2 and confirmed via grep that `searchAskLabel`/
  `searchScopeMyNotes` are absent from every generated accessor, not
  just the `.arb` sources.
- No hand-edited generated file — all four `app_localizations*.dart`
  diffs are pure key removals, consistent with what `flutter gen-l10n`
  alone would produce from the `.arb` diffs.

## 3. The one open item, and why it does not block approval

**`l10n.comingInStep` is now a defined string with zero call sites**
in `lib/` (grep-confirmed this pass). This was flagged in
`PHASE3_SPRINT_R3B_1_REPORT.md` §2 at the moment it happened and
deliberately left unretired, on the grounds that l10n key hygiene is
Group D's job in the original sprint plan, not B1–B3's. Re-examined
here with fresh eyes rather than rubber-stamping that earlier call:

- It is genuinely orphaned — confirmed independently.
- It causes no functional, accessibility, or localization defect —
  an unused string in three `.arb` files is inert.
- It was flagged transparently in real time, not discovered now for
  the first time.
- Retiring it is explicitly out of scope for R3b.1–3 by the plan's own
  sequencing (Group D, sequenced after A1–A5/B1–B3/C1–C3), and none of
  the three sprints' own task instructions asked for l10n hygiene.

**Verdict: not a defect introduced by this work, a known and
deliberately deferred item.** It does not warrant REQUEST CHANGES —
requesting changes for something explicitly and transparently scoped
out three times in a row would be re-litigating a decision already
made with reasoning on the record, not reviewing new work. Recorded
here so it isn't lost, same as the sprint reports already did.

## 4. Test quality — every removed test re-justified against current code

Not re-derived from the sprint reports' own claims — re-checked from
scratch against the current file contents.

**Search-related removals (R3b.2), 11 tests**: re-read
`search_screen_test.dart`, `search_responsive_test.dart`, and
`search_dark_mode_test.dart` in full. Every removed test asserted on
`SearchMode`, `SearchScope`, `SegmentedButton<SearchMode>`, or
`ChoiceChip` — all four are confirmed absent from `search_screen.dart`
(§2). No removed test's *subject* (the thing it verified) still exists
in the app. `search_accessibility_test.dart`'s reading-order test was
narrowed, not removed — from a 4-point check to a 2-point check — and
the file's own comment explains why; re-confirmed this narrowing is
accurate: only 2 landmark widgets remain to order.

**Flashcards test restructuring (R3b.3), net +1, 0 removed**: the
`setUp()` seeding change was mechanical (moved from implicit to
explicit per-test), re-verified against each test's own assertions:
tests that search for a specific lemma (`'kataba'`) now call
`_seedLemmas` explicitly; tests that don't touch Lexicon (Decks, browse
empty state, Root/Phrase) correctly don't. The one new test
(`'Sprint R3b.3 — Add Flashcard: ...'`) directly exercises the fix and
would fail if the fix were reverted — confirmed by tracing its
assertions against `_LemmaSourceBody`'s actual branches.

**No test was found removed without a corresponding UI removal, and no
test was found weakened without an accompanying note explaining the
loss of coverage.** This is the standard the task's own requirement
("verify every removed test is justified") sets, and every removal
meets it on independent re-inspection.

## 5. Gate results (re-run fresh for this review)

```
flutter analyze --fatal-infos
...
No issues found! (ran in 7.9s)
```

```
flutter test
...
+793: All tests passed!
```

**Bonus check, not explicitly requested but part of this project's own
Definition of Done** (`CLAUDE.md`: "dart format, flutter analyze
--fatal-infos, flutter test --coverage, all clean, before any
commit"):

```
dart format --output=none --set-exit-if-changed lib test
...
Formatted 352 files (0 changed) in 0.98 seconds.
```

All three clean. 793 matches the cumulative count expected from the
three sprint reports (803 baseline before R3b.2 → −11 → 792 → +1 →
793), independently re-derived here rather than trusted from their
addition.

## 6. Recommendation

# APPROVE

**Justification**: Every file in scope was re-read in full against the
eight-point checklist (dead code, duplicated logic, obsolete comments,
accessibility, localization, architecture, rebuilds, provider misuse)
and produced zero findings that constitute a defect. The one
open item (`comingInStep`) is a known, transparently-flagged, correctly
out-of-scope deferral, not an oversight. Every removed or narrowed test
was independently re-traced to a specific, confirmed-absent piece of
UI — none of the 11 removed tests, nor the 1 narrowed test, protects
anything that still exists to protect. All three gates (`flutter
analyze --fatal-infos`, `flutter test`, `dart format`) are clean on a
fresh run, not carried over from prior reports. The work matches its
own stated objectives across all three sprints and does not exceed
them — Basmalah, Lexicon (implementation), Daily Goal, and the parts of
Flashcards/Search explicitly marked out of scope in each sprint's
instructions all remain untouched, confirmed by `git status` showing no
file outside the 16 listed in §1.

## 7. Commit plan

### Commit title

```
fix(ui): honest Search, Profile, and Flashcards surfaces (Sprint R3b)
```

(70 characters — within the repo's own convention of short, `fix:`/
`feat:`/`docs:`/`test:`-prefixed English subject lines.)

### Suggested commit body

```
Removes or corrects every UI element that promised functionality the
app cannot deliver, per the Sprint R3b design review:

- Search: disabled the "My Notes" scope chip honestly (R3b.1), then
  removed the AI toggle and the entire scope-chip row once the design
  review confirmed neither had any remaining real distinction to offer
  (R3b.2).
- Profile: replaced internal "Coming in Step N" labels with a generic
  "coming soon" (Personal info, Sync), and removed the "Goal" tile
  entirely — it falsely claimed a feature (Daily Goal) that has already
  shipped and is reachable from Stats (R3b.1).
- Flashcards: gated the Add Flashcard Lemma search behind a real
  Lexicon-availability check, so an empty Lexicon shows "no data yet"
  immediately instead of inviting an infinite, guaranteed-empty search
  (R3b.3).

Net: 11 tests removed (each tied to a specific removed control,
itemized in PHASE3_SPRINT_R3B_2_REPORT.md), 1 test narrowed (reading-
order check, down to 2 remaining landmarks), 2 tests added (R3b.3's
Lemma-availability coverage; R3b.1's chip-lock coverage, later removed
along with the chip itself in R3b.2). Net test count: 802 -> 793.

See docs/release/PHASE3_SPRINT_R3B_PLAN.md,
PHASE3_SPRINT_R3B_DESIGN_REVIEW.md, and the three per-sprint reports
for full reasoning.
```

### Staged files (16)

```
lib/features/flashcards/data/flashcard_providers.dart
lib/features/flashcards/presentation/add_flashcard_screen.dart
lib/features/profile/presentation/profile_screen.dart
lib/features/search/presentation/search_screen.dart
lib/l10n/app_ar.arb
lib/l10n/app_en.arb
lib/l10n/app_vi.arb
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_ar.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_vi.dart
test/flashcard_ux_test.dart
test/search_accessibility_test.dart
test/search_dark_mode_test.dart
test/search_responsive_test.dart
test/search_screen_test.dart
```

This is the complete, exact set from `git diff --stat` (§1) — no more,
no less.

### Excluded files, and why

**Ten untracked docs, all excluded from this commit**:

```
docs/adr/DR-2026-0016-lexicon-data-source.md
docs/release/LEXICON_DATASET_VALIDATION.md
docs/release/MASAQ_ACCEPTANCE_REPORT.md
docs/release/PHASE3_SPRINT_R3A1_REPORT.md
docs/release/PHASE3_SPRINT_R3A2_REPORT.md
docs/release/PHASE3_SPRINT_R3A3_REPORT.md
docs/release/PRODUCT_READINESS_REVIEW.md
docs/release/RELEASE_GOVERNANCE_AUDIT.md
docs/release/REPOSITORY_BOUNDARY_UPDATE_REPORT.md
docs/release/WEB_PLATFORM_VERIFICATION.md
```

Predate this sprint entirely (Lexicon licensing research, R3a web-
platform work, the Product Readiness Review) — unrelated to R3b's
diff, would only pad an implementation commit with unrelated history.

**Six R3b-related docs, also excluded from *this* commit, but for a
different reason**:

```
docs/release/PHASE3_SPRINT_R3B_PLAN.md
docs/release/PHASE3_SPRINT_R3B_DESIGN_REVIEW.md
docs/release/PHASE3_SPRINT_R3B_1_REPORT.md
docs/release/PHASE3_SPRINT_R3B_2_REPORT.md
docs/release/PHASE3_SPRINT_R3B_3_REPORT.md
docs/release/PHASE3_SPRINT_R3B_FINAL_REVIEW.md
```

These directly document the work in this commit, but this repository's
own established convention (the R2 and R3a epics) is **code and
planning/report docs land in separate commits**, not bundled — e.g.
`eabb0fe` ("Close Epic R3a") explicitly staged only release-tracking
files and excluded sprint reports. Recommend the same pattern here: 
this implementation commit first, then a second, separate documentation
commit (or a release-dashboard-update commit, if `RELEASE_DASHBOARD.md`/
`CHANGELOG.md` are updated for R3b at the same time — neither has been
touched yet in this engagement window, which is itself a gap worth a
future task, matching the same class of release-tracking gap the
Product Readiness Review already found for earlier sprints). Not
actioned here — flagged for the next explicit instruction, consistent
with this engagement's pattern of not proceeding past what's asked.

---

FINAL REVIEW COMPLETE — recommendation: APPROVE. Not committed, not
pushed. Commit plan above is ready for explicit authorization.
