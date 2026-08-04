# Basmalah 2.0 — Sprint BM1 (Audio Foundation) — Report

**Status:** implemented, all four gates green, **not committed** —
awaiting review.

**Naming note:** this sprint is the audio layer, which the approved plan
listed as **BM3**; the plan's BM1 was the accessibility label. Renumbering
is fine, but the plan's ordering assumed the opening became a *row*
first. It has not, so the opening is currently **audible but not
visible as an element** — see §6.

---

## 1. Architecture decisions

### D1 — The opening's address is `QuranAddress.surah(N)`, not a new type

The blocker for treating the Basmalah as an element is that its extent
inside āyah 1 cannot be expressed without Word Address. That is avoided
by addressing its **role** rather than its **text**: the Basmalah of
surah N is *what opens surah N*, and F0 already ships that address.

Three F0 properties carry the design, all now locked by tests:

| Property | Why BM1 depends on it |
|---|---|
| `QuranAddress.surah(2) != QuranAddress.ayah(2, 1)` | `AyahCard`'s equality highlight cannot mis-fire onto āyah 1 while the Basmalah plays |
| `zeroBasedAyahIndex` is `null` at surah level | The exact discriminator auto-scroll needs for "not at an āyah yet" |
| surah level sorts **before** its āyāt | Playlist order matches reading order with no rule written |

**No new address level. No Word Address. No schema.**

### D2 — `AudioState.currentAddress` becomes a stored field, not a computed getter

F0 derived it as `fromZeroBasedAyahIndex(surahId, currentIndex)`. That
is now **wrong by construction**: once the playlist has a leading item,
`currentIndex` cannot yield an āyah.

The playlist item already carries its own address (B1). So the address
is read from the item rather than recomputed — the item is the source,
recomputation is a guess. This removes the ambiguity instead of adding
a second conversion beside it.

Index and address are written in **one** `copyWith`, deliberately: if
they were set separately, the audio bar and the highlight could disagree
for a frame.

### D3 — `ReadingPlaylist` mirrors `ReadingRows`, and both read one `SurahOpening`

Rows and playlist now have *different* leading counts — a row always has
the header (+1), a playlist item has the opening only for 112 surahs.
Nothing forces them to stay consistent except that both derive from the
same `resolveSurahOpening` value. That relationship is asserted directly
in a test across all 114 surahs.

`ReadingPlaylist` lives in `domain/` while `ReadingRows` lives in
`presentation/`, and the split is deliberate: playlist order is a fact
about **content** — a reciter recites the opening, then āyah 1 — whereas
rows are a rendering decision.

### D4 — Al-Fātiḥah and At-Tawbah are guarded by the sealed type, not an `if`

`leadingItemsFor` returns 1 only for `OpeningPrefixesFirstAyah`.
Al-Fātiḥah is `OpeningIsFirstAyah` (its āyah 1 *is* the Basmalah, already
in the playlist — adding an item would play it twice) and At-Tawbah is
`NoOpening`. **No `if (surahId != 1 && surahId != 9)` was written
anywhere in this sprint** — F2's declaration is doing the work.

### D5 — Starting mid-surah does not insert the Basmalah

`startItemForAyahIndex` differs from `itemForAyahIndex` in exactly one
case, and it is a product rule rather than arithmetic: starting at āyah 1
means *"recite this surah from the beginning"*, so the opening plays;
tapping āyah 5 means the user pointed at āyah 5, and prefixing a
Basmalah there would contradict them.

---

## 2. `ReadingPlaylist` design

`lib/features/quran/domain/reading_playlist.dart` — pure, no Flutter, no
I/O. Four functions, each with a live consumer; nothing speculative.

| Function | Returns | Used by |
|---|---|---|
| `leadingItemsFor(opening)` | 0 or 1 | `playSurah` (whether to prepend) |
| `itemForAyahIndex({opening, ayahIndex})` | playlist index | round-trip, tests |
| `ayahIndexForItem({opening, item})` | āyah index or **`null`** | the "this is not an āyah" signal |
| `startItemForAyahIndex({opening, ayahIndex})` | playlist index | `playSurah` start conversion (D5) |

`ayahIndexForItem` returns `null` rather than clamping to 0 for the
opening. Clamping would silently mean "āyah 1", and if that number ever
reached `ReadingPositionStore` the saved position would be one āyah off
with nothing failing loudly.

---

## 3. Audio flow

```
user taps play on āyah i        (i = āyah index, 0-based)
        │
        ▼
AudioController.playSurah(surahId, ayahs, startIndex: i)
        │
        ├─ resolveSurahOpening(surahId, ayahs.first.textUthmani)   ← F2
        │
        ├─ build _items:
        │     [opening?]  address = QuranAddress.surah(N)          ← F0
        │                 source  = <reciter>/001001.mp3
        │     [āyah 1]    address = N:1
        │     [āyah 2]    address = N:2   …
        │
        ├─ startItem = ReadingPlaylist.startItemForAyahIndex(…)
        │
        ▼
player.setPlaylist(_items, initialIndex: startItem)
        │
        ▼  currentIndexStream (playlist index)
AudioController → state{ currentIndex, currentAddress = _items[i].address }
        │
        ├──────────────► AyahCard:   currentAddress == thisAyah
        │                            surah-level matches nothing → no card lit
        │
        ├──────────────► AudioBar:   āyah level → "2:255"
        │                            surah level → l10n "Opening"
        │
        └──────────────► auto-scroll: currentAddress.zeroBasedAyahIndex
                                      null → row 0 (header, where the
                                      Basmalah is displayed today)
```

**The audio source.** Al-Fātiḥah's āyah 1 *is* the Basmalah, so
`001001.mp3` is a Basmalah recording in each reciter's own voice, on the
same CDN. Verified HTTP 200 for all five shipped reciters during the
plan sprint. **No new assets, no downloads, no licensing** — the sprint's
"no new assets" rule is satisfied because nothing new exists.

---

## 4. Persistence verification

**Zero schema change. Zero migration. Both on-disk stores remain purely
āyah-based.**

Every write path was traced, and none carries a playlist index:

| Sink | Value written | Source | Playlist-aware? |
|---|---|---|---|
| `ReadingPositionStore` | 0-based āyah index | `ReadingRows.ayahIndexForRow(minItemIndex)` (scroll) | no — row-based |
| `ReadingPositionStore` | 0-based āyah index | `openAyahInReadingScreen` (`ayahNumber - 1`) | no |
| `study_sessions.ayah_from/to` | 0-based āyah index | `_initialAyahIndex` / `_lastSavedIndex` | no |

`AudioState.currentIndex` has **no path to disk**. Its doc comment now
says so explicitly, since the compiler cannot enforce it.

Guarded by two new widget tests on Al-Baqarah — a surah that *has* an
opening, which the pre-existing Al-Fātiḥah fixture could never exercise:

1. Play from the start (so playlist item 0 is the Basmalah), end the
   session, assert `study_sessions` receives an **āyah** index within
   the surah's āyah count.
2. While the Basmalah plays, assert **no āyah card is highlighted** —
   the surah-level address matches nothing, including āyah 1.

---

## 5. Risks

| # | Risk | Severity | Status |
|---|---|---|---|
| **R1** | Playlist index leaking into persistence | **High** | **Mitigated** — `ReadingPlaylist` + two persistence tests + `currentIndex` doc warning. No write path exists |
| **R2** | Rows and playlist drifting apart | Medium | Mitigated — both derive from one `SurahOpening`; asserted across 114 surahs |
| **R3** | Generic Basmalah tone vs surah-specific | Medium | **Accepted** (plan R2). Same reciter's voice; alternative is a 114×5 bespoke asset set |
| **R4** | Double Basmalah on Al-Fātiḥah | Medium | **Mitigated structurally** — sealed type, tested |
| **R5** | Opening is audible but has **no visible element** | **Medium** | **Open** — see §6. The header still shows the Basmalah, and auto-scroll goes there, so it is not invisible; but it cannot be highlighted |
| **R6** | One extra network fetch per surah | Low | Accepted; same CDN and cache path |
| **R7** | Not verified on a device | Medium | Emulator harness from B3 exists but was not re-run this sprint |

---

## 6. Deferred work

| Item | Why |
|---|---|
| **Opening as a reading row** (plan BM2) | Not in this sprint's scope. Consequence: the Basmalah is now *heard* but cannot be *highlighted*, because there is no row to decorate (R5). This is the natural next sprint |
| **Opening decoration** (plan BM4) | Depends on the row |
| **Accessibility label on the header Basmalah** (plan BM1) | Still absent; the header `Text` has no `Semantics` |
| Header vs row duplication decision (plan §5.1 Q1) | Unanswered — becomes live when the row lands |
| Full action set on the opening (plan §5.1 Q2) | Deferred; would need an `ayahs` row, i.e. schema |
| Search de-noise (plan BM5) | Untouched |
| Device verification of the new playlist | Should extend the B3 checklist: queue = ayahCount + 1, opening as item 1, `skipToPrevious` from āyah 1 reaches it |

---

## 7. Test delta

**904 tests**, up from 887 (**+17**).

| Area | Δ | What |
|---|---|---|
| `reading_playlist_test.dart` (new) | **+15** | Leading counts across 114 surahs; Al-Fātiḥah and At-Tawbah both 0; index round-trip on all 114; `null` for the opening; the start-item product rule; rows-vs-playlist offset invariant; the three F0 properties BM1 leans on |
| `reading_screen_test.dart` | **+2** | The two persistence guards (§4) |
| `audio_controller_test.dart` | 4 **updated** | They encoded playlist-index == āyah-index, which BM1 deliberately breaks. Now assert the opening item, its `001001` source, its surah-level address, and that `startIndex` is an āyah index converted to a playlist item |

The four updated tests were failing for the right reason — the feature
working — so they were rewritten to assert the new contract rather than
relaxed.

## 8. Coverage delta

| | B3 | BM1 | Δ |
|---|---|---|---|
| Filtered (CI policy, gate 80) | 81.86% | **81.89%** | +0.03 pp |
| Raw | 52.40% | 52.45% | +0.05 pp |

| Gate | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 368 files, **0 changed** |
| `flutter analyze --fatal-infos` | **No issues found** |
| `flutter test` | **904 passed** |
| `flutter test --coverage` | **81.89%** |

**Files changed:** `lib/features/quran/domain/reading_playlist.dart`
(new), `audio_controller.dart`, `audio_bar.dart`, `reading_screen.dart`,
three `.arb` files + generated l10n, plus the three test files.

---

## 9. Recommendation

**Accept, and schedule the opening row next.**

The sprint delivers what it set out to: for 112 surahs the Basmalah is
now recited before āyah 1, in the user's chosen reciter, with no new
assets, no schema change and no migration. The highest risk — the
0-based index space splitting in two with two on-disk consumers — is
mitigated structurally rather than by care, and is covered by tests that
run on a surah which actually has an opening.

Two things worth your attention:

1. **R5 is a real half-state.** The Basmalah is audible and the screen
   scrolls to the header while it plays, but it cannot be highlighted
   because it is not a row. That is coherent, not broken — but the plan's
   user goal ("audio, highlight and navigation behaving naturally") is
   **not yet fully met**, and I would not describe Basmalah 2.0 as done
   until the row lands.
2. **Re-run the B3 device harness after the row sprint**, not now.
   Verifying twice costs an emulator session each time, and the queue
   shape changes again when the row arrives.

Commit BM1 on its own — it is self-contained and independently
revertible, which the row sprint will not be.
