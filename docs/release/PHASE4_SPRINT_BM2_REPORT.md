# Basmalah 2.0 — Sprint BM2 (Opening Row) — Report

**Status:** implemented, all four gates green, **not committed** —
awaiting review.

**Base:** BM1 (uncommitted, in the same working tree).

---

## 1. Architecture decisions

### D1 — One predicate decides "does a separate opening element exist"

BM1 gave the playlist a leading item; BM2 gives the list a leading row.
Two different modules, two different counts (a row always has the header
too) — and nothing structural forces them to agree about *which surahs*
have an opening.

So the question now has exactly one answer, in the declaration module:

```dart
// basmalah.dart
bool hasSeparateOpening(SurahOpening opening) =>
    opening is OpeningPrefixesFirstAyah;
```

`ReadingPlaylist.leadingItemsFor` and `ReadingRows.leadingRowsFor` both
call it. A test asserts the relationship across all 114 surahs, so if
someone ever forks the definition the suite goes red.

### D2 — The Basmalah **moves** out of the header rather than being duplicated

The plan (§5.1 Q1) flagged this as a decision needed before BM2. Keeping
the header copy *and* adding a row renders the Basmalah twice, so the row
replaces it. `_SurahHeader` now carries only name, revelation place and
āyah count; its `basmalah` parameter is gone.

Only as its own row can the Basmalah carry a decoration and a semantics
label of its own — which is the point of the sprint.

### D3 — The row reuses F1's decoration type with **no new branch**

The opening is highlighted by calling F1's existing resolver:

```dart
resolveAyahDecoration(isPlaying: …, highlightColors: const {})
```

The empty colour set is not a placeholder — the opening genuinely cannot
be user-highlighted, because annotations are keyed on `ayahs.id` and the
opening has no such row. Adding a fourth `AyahDecoration` case would have
been the speculative abstraction; the precedence rule is unchanged.

### D4 — The row's identity is `QuranAddress.surah(N)` — the same value BM1 gave the playlist item

The row lights up when `currentAddress == QuranAddress.surah(surahId)` —
the identical comparison `AyahCard` makes, one address level up. No
lookup table, no bridging state: the thing being played and the thing
being drawn are named by the same value.

F0's guarantee that `surah(N) != ayah(N, 1)` is what keeps āyah 1's card
dark while the Basmalah plays, and vice versa. That property is now
asserted from both sides.

### D5 — No magic constants

`openingRowFor` returns `headerRows` rather than a literal `1`, and the
header count is a named constant. Nothing in `ReadingScreen` writes a
bare `+1` or `-1` any more.

### D6 — The opening is resolved **once per frame** and held

`ReadingScreen` resolves `SurahOpening` in `build` and stores it, because
three consumers outside `build` need it: `_onPositionsChanged`, the audio
scroll listener, and the list builder. Resolving separately in each is
three chances to disagree.

When it is `null` (data not loaded), `_onPositionsChanged` **returns
early** rather than assuming "no opening" — guessing wrong there writes a
position one āyah off to disk.

---

## 2. `ReadingRows` changes

| Before (F2) | After (BM2) |
|---|---|
| `const int leadingRows = 1` | `int leadingRowsFor(SurahOpening)` → 1 or 2 |
| — | `int? openingRowFor(SurahOpening)` → the row, or null |
| — | `const int headerRows = 1` (always present) |
| `rowCountFor(int ayahCount)` | `rowCountFor({opening, ayahCount})` |
| `lastRowFor(int)` | `lastRowFor({opening, ayahCount})` |
| `isLeading(int row)` | `isLeading({opening, row})` |
| `rowForAyahIndex(int)` | `rowForAyahIndex({opening, ayahIndex})` |
| `ayahIndexForRow(int)` | `ayahIndexForRow({opening, row})` |

Layout:

```
row 0        surah header
row 1        opening  ← only when hasSeparateOpening
row 2…       āyāt
```

All five call sites F2 gathered were updated in one pass. **This is F2
paying off exactly as it predicted**: a signature change in one module,
not a hunt through a 1,300-line widget.

---

## 3. Rendering behaviour

| Surah | Header | Opening row | Āyah 1 card |
|---|---|---|---|
| 2–8, 10–114 (112) | name/place/count | **Basmalah** | text without Basmalah (F2) |
| Al-Fātiḥah (1) | name/place/count | *none* | full Basmalah — it *is* āyah 1 |
| At-Tawbah (9) | name/place/count | *none* | its own opening words |

`_OpeningRow` contains no `if` about surah numbers; `openingRowFor`
returns `null` for 1 and 9, so the row is never built for them.

**Focus mode** returns `SizedBox.shrink()` for the opening row, matching
what it already did for the header. Focus and Mushaf keep rendering
āyah 1's text intact, Basmalah included — the deliberate difference
recorded as G6 in the plan.

**Playing state:** the row's background blends `primaryContainer` at
0.35 over `surfaceContainerLow` — the same formula `AyahCard` uses — and
is transparent otherwise, so a non-playing opening looks exactly as the
header's Basmalah did.

---

## 4. Accessibility behaviour

Before BM2 the Basmalah was a bare `Text`: a screen reader read raw
Arabic with no indication of what it was or that it was a distinct
element.

It is now `Semantics(container: true, label: …)`, producing **one node**
whose label is the localised name followed by the Basmalah itself:

```
"Lời mở đầu Surah — Bismillah\n‫بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ‬"
```

That is the same shape `AyahCard` produces (`"Ayah 1\n1\n<Arabic>\n<translation>"`),
so traversal stays consistent: one stop per reading element, each
announcing what it is before what it says.

`container: true` is load-bearing — without it the label is an
annotation that can merge into a neighbouring node instead of forming
its own stop.

New string `openingSemanticLabel` added to all three `.arb` files
(vi/en/ar) per CLAUDE.md; nothing hardcoded.

---

## 5. Persistence verification

**No schema change. No migration. Both on-disk stores remain purely
āyah-based** — unchanged from BM1.

The row shift is the risk: rows moved by +1 for 112 surahs, and
`_onPositionsChanged` derives the saved reading position from a row.

| Sink | Value | Path | Opening-aware? |
|---|---|---|---|
| `ReadingPositionStore` | 0-based āyah index | `ReadingRows.ayahIndexForRow(opening:, row:)` | **yes** — via the shared predicate |
| `ReadingPositionStore` | 0-based āyah index | `openAyahInReadingScreen` (`ayahNumber - 1`) | n/a — never row-based |
| `study_sessions.ayah_from/to` | 0-based āyah index | `_initialAyahIndex` / `_lastSavedIndex` | inherits the above |

Scrolled to either leading row (header **or** opening), `ayahIndexForRow`
returns `null` and the screen records āyah 0 — the same answer it gave
for the header alone before BM2.

BM1's two persistence guards still pass unchanged, including the one
that plays Al-Baqarah from the Basmalah and asserts `study_sessions`
receives an āyah index inside the surah's āyah count.

---

## 6. Risks

| # | Risk | Severity | Status |
|---|---|---|---|
| **R1** | Row/playlist disagreeing about which surahs have an opening | High | **Mitigated** — one predicate, asserted across 114 surahs from both modules |
| **R2** | Row shift corrupting saved position | High | **Mitigated** — all conversions go through `ReadingRows`; BM1's guards still green |
| **R3** | `_opening` null during early frames | Medium | **Mitigated** — `_onPositionsChanged` returns early rather than guessing |
| **R4** | Double Basmalah (header + row) | Medium | **Removed** — header no longer renders it; test asserts exactly one occurrence |
| **R5** | Screen-reader traversal order changed | Low | The opening is a new stop between header and āyah 1 — the correct reading order |
| **R6** | Opening row has **no actions** (no play, no share) | Medium | **Open** — see §7. It is visible, audible, highlighted, labelled, but not interactive |
| **R7** | Not verified on a device | Medium | B3 emulator harness exists; not re-run. Queue shape and row layout both changed since |

---

## 7. Deferred work

| Item | Why |
|---|---|
| **Actions on the opening row** (play-from-here, copy, share) | Not in scope. Consequence (R6): you cannot start playback *at* the Basmalah by tapping it — only by playing the surah from the start, or pressing previous from āyah 1. This is the most visible remaining gap |
| Bookmark / note on the opening | Would need an `ayahs` row → schema change. Explicitly out of scope |
| Mushaf and Focus mode | Keep rendering the Basmalah inline (plan G6, intentional) |
| Search de-noise (plan BM5) | Untouched — the Basmalah still returns 113 āyah-1 hits |
| Device verification | Should now cover: opening row visible, highlighted while playing, announced by TalkBack, and Al-Fātiḥah showing exactly one Basmalah |

---

## 8. Test delta

**915 tests**, up from 904 (**+11**).

| File | Δ | What |
|---|---|---|
| `reading_rows_test.dart` | **rewritten**, ~+9 net | Every case now runs across all three opening shapes. New: leading count 2 vs 1; `openingRowFor`; both leading rows returning `null`; and two invariants tying rows to `ReadingPlaylist` across 114 surahs |
| `reading_screen_test.dart` | **+4** | Basmalah rendered exactly once; Al-Fātiḥah has no opening row; the semantics node's label and content; the row highlighting when the Basmalah plays |
| `reading_playlist_test.dart` | 1 updated | The rows-vs-playlist offset assertion now states the real relationship: rows lead playlist by exactly `headerRows`, the one element that exists only in the UI |

## 9. Coverage delta

| | BM1 | BM2 | Δ |
|---|---|---|---|
| Filtered (CI policy, gate 80) | 81.89% | **81.98%** | +0.09 pp |
| Raw | 52.45% | 52.56% | +0.11 pp |

| Gate | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 368 files, **0 changed** |
| `flutter analyze --fatal-infos` | **No issues found** |
| `flutter test` | **915 passed** |
| `flutter test --coverage` | **81.98%** |

**Files changed:** `basmalah.dart`, `reading_playlist.dart`,
`reading_rows.dart`, `reading_screen.dart`, three `.arb` files +
generated l10n, and the three test files.

---

## 10. Recommendation

**Accept.** The visual model Basmalah 2.0 needed is in place: for 112
surahs the opening is a real reading row — rendered once, highlighted
while it plays by the F1 decoration layer, announced by name to screen
readers, and addressed by the same `QuranAddress.surah(N)` that BM1 gave
its audio. Al-Fātiḥah and At-Tawbah are excluded by the sealed type, not
by surah-number checks.

Two things worth your attention:

1. **R6 — the row is not interactive.** You can see it, hear it, and
   watch it highlight, but you cannot tap it to play from there. Given
   the plan's user goal is *"audio, highlight and navigation behaving
   naturally"*, I read **audio and highlight as now met, navigation as
   partially met**: previous-from-āyah-1 reaches it, tapping does not.
   A small BM3 (play-from-here on the opening) would close it without
   touching schema.
2. **Re-run the B3 device harness now, not later.** In BM1 I advised
   waiting because the row would change the queue shape again. It has,
   and both layers have now settled — so this is the moment where one
   emulator session validates the whole feature.

Commit BM1 and BM2 together. BM2 changes `ReadingRows`' signature in a
way that only makes sense alongside BM1's playlist, and neither has
shipped.
