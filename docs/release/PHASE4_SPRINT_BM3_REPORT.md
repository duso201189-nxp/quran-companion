# Basmalah 2.0 — Sprint BM3 (Interactive Basmalah) — Report

**Status:** implemented, all four gates green, **not committed** —
awaiting review.

**Base:** BM1 + BM2, both uncommitted, same working tree.

---

## 1. Architecture decisions

### D1 — Intent is carried by the address **level**, not inferred from an index

This is the sprint's central change, and it fixes a defect BM1 shipped.

BM1's `startItemForAyahIndex` took an āyah index and *guessed* intent
from `ayahIndex == 0`: index 0 meant "read the surah from the start", so
it began at the opening. That was serviceable while the Basmalah had no
button of its own — but it meant **pressing play on āyah 1's card played
the Basmalah**, which is not what that button's label promises.

BM2 gave the opening a row; BM3 gives it a button. With two affordances,
the two intents no longer need to share one number:

```dart
playSurah({required List<Ayah> ayahs, required QuranAddress from})
```

| Caller | `from` | Result |
|---|---|---|
| Opening row's play button | `QuranAddress.surah(N)` | starts at the Basmalah |
| Āyah card's play button | `QuranAddress.ayah(N, n)` | starts at that āyah |
| Keyboard shortcut / resume | `fromZeroBasedAyahIndex(N, saved)` | resumes at the saved āyah |

`ReadingPlaylist.startItemForAyahIndex` is **deleted** and replaced by
`itemForAddress`, whose whole body is:

```dart
final ayahIndex = from.zeroBasedAyahIndex;   // null at surah level
return ayahIndex == null ? 0 : itemForAyahIndex(…);
```

The discriminator is F0's own `zeroBasedAyahIndex` returning `null` at
surah level — the same property BM1 used for auto-scroll and BM2 used
for row mapping. **Three consumers, one property, no new concept.**

### D2 — `surahId` removed from `playSurah`; it comes from the address

Passing both a `surahId` and a start position was two sources for one
fact. `from.surah` is now the only one, so a caller cannot pass a
mismatched pair.

### D3 — The opening row reuses `_ActionIcon`, not a new control

Same widget, same `playFromHere` tooltip, same icon swap to
`graphic_eq_rounded` while it is the item playing. The opening behaves
like a reading element rather than a decorated special case — which is
the whole point of the Basmalah 2.0 arc.

No new l10n string was needed: `playFromHere` already says the right
thing.

### D4 — Nothing else changed

`ReadingRows`, `ReadingPositionStore`, `study_sessions`, the decoration
layer and the queue are untouched. BM3 is a signature change plus one
button.

---

## 2. Interaction model

| Element | Affordance | Address | Effect |
|---|---|---|---|
| **Opening row** | play button (right-aligned above the Basmalah) | `surah(N)` | plays Basmalah, then āyah 1, 2, … |
| **Āyah card** | play button (existing action row) | `ayah(N, n)` | plays that āyah onward |
| Opening row | — | — | no bookmark, note, or share (out of scope) |

While the opening is the playing item, its button shows
`graphic_eq_rounded` and its row carries the playing decoration from
BM2 — identical treatment to an āyah card.

**Deliberate behaviour change vs BM1:** pressing play on āyah 1 no
longer plays the Basmalah first. That was BM1's guess standing in for a
missing affordance; now the affordance exists, so each button does
exactly what it says. Both behaviours are pinned by tests.

---

## 3. Navigation behaviour

| From | Action | To |
|---|---|---|
| Āyah 1 | previous | **Opening** |
| Opening | next | Āyah 1 |
| Opening | previous | stays (start of playlist) |
| Any āyah | play button | that āyah |
| Anywhere | opening row's play | Opening |

Stepping between the Basmalah and āyah 1 is a single move in either
direction — it is simply the first item of the playlist, so BM1's
existing bounds already handle it. Nothing was added for this; it is
asserted by test rather than assumed.

Auto-scroll (BM2) already targets the opening row when the opening
plays, so pressing previous from āyah 1 scrolls to the Basmalah and
highlights it.

---

## 4. Playback behaviour

```
tap opening row play
        │  from = QuranAddress.surah(N)
        ▼
ReadingPlaylist.itemForAddress → 0
        ▼
setPlaylist(_items, initialIndex: 0)
        │
        ├─ item 0  Basmalah   address surah(N)   ← plays
        ├─ item 1  āyah 1     address N:1
        └─ …
```

```
tap āyah 1 play
        │  from = QuranAddress.ayah(N, 1)
        ▼
itemForAddress → 1        (skips the opening)
```

For Al-Fātiḥah and At-Tawbah the two levels collapse to the same item 0,
because `leadingItemsFor` is 0 for both — Al-Fātiḥah's āyah 1 *is* the
Basmalah, and At-Tawbah has none. Still no surah-number check anywhere:
the sealed type decides.

---

## 5. Persistence verification

**No schema change. No migration. Nothing new writes to disk.**

BM3 changes only *which playlist item playback starts at*. It touches
neither of the two on-disk sinks:

| Sink | Written by | Changed by BM3? |
|---|---|---|
| `ReadingPositionStore` | `_onPositionsChanged` (row-derived), `openAyahInReadingScreen` | **no** |
| `study_sessions.ayah_from/to` | `_initialAyahIndex` / `_lastSavedIndex` | **no** |

`AudioState.currentIndex` remains playlist-space and still has no path
to disk. BM1's two persistence guards pass unchanged, including the one
that plays Al-Baqarah from the Basmalah and asserts `study_sessions`
receives an āyah index inside the surah's āyah count.

---

## 6. Risks

| # | Risk | Severity | Status |
|---|---|---|---|
| **R1** | Users who learned BM1's behaviour find āyah 1's button changed | Low | Intended (§2). BM1 is unreleased, so no shipped behaviour changes |
| **R2** | `playSurah` signature change missing a caller | Low | **Mitigated** — required named parameter; the compiler found all three call sites |
| **R3** | Opening row's button changes its visual weight | Low | Right-aligned above the text, same `_ActionIcon` as āyah cards |
| **R4** | Screen-reader traversal now includes a button inside the opening | Low | Correct — it is genuinely actionable. The container label still announces the element first |
| **R5** | Resume-from-position never replays the Basmalah | Low–Med | By design: resuming mid-surah is not "read from the start". A user wanting the Basmalah taps its row. Worth a beta look |
| **R6** | Not verified on a device | **Medium** | **Now the main gap** — BM1/BM2/BM3 have all changed playback and layout, and none has been on hardware |

---

## 7. Deferred work

| Item | Why |
|---|---|
| Bookmark / note on the opening | Needs an `ayahs` row → schema. Explicitly out of scope |
| Copy / share the Basmalah | Not in scope; would be a small follow-up |
| Mushaf and Focus mode | Still render the Basmalah inline (plan G6, intentional) |
| Search de-noise (plan BM5) | Untouched — Basmalah still returns 113 āyah-1 hits |
| Home "continue reading" entry point | Uses saved position → resumes at an āyah, never the opening (R5) |
| **Device verification** | See §10 |

---

## 8. Test delta

**920 tests**, up from 915 (**+5**).

| File | Δ | What |
|---|---|---|
| `reading_screen_test.dart` | **+4** | Opening row has its own play button; tapping it yields `currentAddress == surah(2)` at item 0; tapping **āyah 1's** button yields `ayah(2,1)` at item 1 (the BM1 defect, pinned); previous/next steps between opening and āyah 1 |
| `reading_playlist_test.dart` | 4 **replaced** | `startItemForAyahIndex` group deleted with the function; `itemForAddress` group asserts surah-level → opening, āyah-1-level → āyah 1, mid-surah → that āyah, and that both levels collapse for surahs 1 and 9 |
| `audio_controller_test.dart` | 5 call sites migrated | Each now states intent by address level rather than passing an index |

The deleted test group was not wrong — it correctly asserted BM1's
behaviour. It locked in an ambiguity that BM2/BM3 removed, so it was
replaced rather than relaxed.

## 9. Coverage delta

| | BM2 | BM3 | Δ |
|---|---|---|---|
| Filtered (CI policy, gate 80) | 81.98% | **82.04%** | +0.06 pp |
| Raw | 52.56% | 52.62% | +0.06 pp |

| Gate | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 368 files, **0 changed** |
| `flutter analyze --fatal-infos` | **No issues found** |
| `flutter test` | **920 passed** |
| `flutter test --coverage` | **82.04%** |

**Files changed:** `reading_playlist.dart`, `audio_controller.dart`,
`reading_screen.dart`, and three test files. No new files, no l10n
change.

---

## 10. Recommendation

**Accept, then verify on hardware before anything else.**

Basmalah 2.0's user goal — *"every Surah should present Basmalah
correctly, with audio, highlight and navigation behaving naturally"* —
now reads as met on all three counts:

- **Audio** (BM1): recited before āyah 1 for 112 surahs, in the user's
  reciter, no new assets.
- **Highlight** (BM2): its own row, decorated by the F1 layer, labelled
  for screen readers.
- **Navigation** (BM3): its own play button; one step to and from āyah 1;
  and each play button now does what its label promises.

The arc also closed a defect it created: BM1's index-guessing made
āyah 1's button play the Basmalah, and BM3 removed the guess rather than
documenting it.

Two things:

1. **R6 is now the largest gap.** Three sprints have changed the
   playlist, the row layout and the playback entry points, and none has
   run on a device. The B3 emulator harness works and the queue shape
   has finally settled — one session should now check: opening row
   visible and announced; its play button starts at the Basmalah; āyah 1's
   button does not; queue length is `ayahCount + 1`; Al-Fātiḥah shows
   exactly one Basmalah and a queue of exactly 7.
2. **Commit BM1 + BM2 + BM3 as one change.** They are three steps of a
   single migration — BM3 deletes a function BM1 introduced, and BM2's
   row is what makes BM3's button meaningful. Splitting them would put
   two intermediate states in history, one of which has the āyah-1
   defect.
