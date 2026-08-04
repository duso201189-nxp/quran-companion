# Basmalah 2.0 — Sprint BM4 (Final Verification & Polish) — Report

**Status:** verification executed, **one production defect found and
fixed**, all four gates green, **not committed** — awaiting review.

**Scope of verification:** BM1 + BM2 + BM3 together, all still
uncommitted in one working tree.

---

## 0. How this was verified

Three independent levels, because each catches what the others cannot:

| Level | Method | Catches |
|---|---|---|
| **Pure** | Unit tests over `SurahOpening`, `ReadingRows`, `ReadingPlaylist` | Logic errors |
| **Real data** | **New** — `basmalah_real_data_test.dart` opens the shipped `assets/database/quran.sqlite` and runs the production functions over **all 114 surahs** | Wrong assumptions about the data |
| **Device** | Pixel 8 emulator, Android 17 / API 37, `adb dumpsys` | Wrong assumptions about the platform |

The defect found in this sprint was invisible to the first two levels
and only appeared on the device — which is the argument for BM4
existing.

---

## 1. Verification matrix

### Reading

| # | Check | Result | Evidence |
|---|---|---|---|
| R1 | Every surah displays exactly one Basmalah | ✅ | Real-data test: for all 114, opening row + āyah 1 display text contain the Basmalah exactly once (At-Tawbah: zero) |
| R2 | Basmalah never rendered twice | ✅ | Same test asserts āyah 1's display text never contains the opening row's text |
| R3 | Al-Fātiḥah: Basmalah **is** āyah 1, no opening row | ✅ | Real-data test + `openingRowFor` is `null` + widget test |
| R4 | At-Tawbah: no Basmalah anywhere | ✅ | Real-data test: `NoOpening`, no row, no playlist item, āyah 1 text unmodified |
| R5 | **An-Naml 27:30 unaffected** | ✅ | Real-data test: `ayahDisplayText(27, 30, …)` returns the text byte-for-byte; the Basmalah there is revelation, not an opening |
| R6 | `ReadingRows` correctness | ✅ | Real-data test over 114 surahs: `rowCountFor == ayahCount + (1 or 2)`, last row maps to last āyah |
| R7 | On-device rendering | ✅ | Al-Kahf screenshot: header has no Basmalah; Basmalah is its own row; āyah 1 starts at ٱلْحَمْدُ لِلَّهِ |

### Audio

| # | Check | Result | Evidence |
|---|---|---|---|
| A1 | Opening row playback | ✅ | Device: `active item id=0`, `description=Bismillah` |
| A2 | Āyah 1 playback does **not** play the Basmalah | ✅ | Widget test (`currentAddress == ayah(2,1)`, item 1); device: tapping āyah 10 → `active item id=10` |
| A3 | Queue length | ✅ | Device: Al-Kahf `queue size=111` (110 āyāt + 1 opening) |
| A4 | Queue order | ✅ | Device: item 0 = `Bismillah`, item 10 = `Ayah 10` |
| A5 | Resume behaviour | ✅ | Resumes at the saved **āyah** (by design, BM3 §2); device position survived restarts |
| A6 | Previous / Next | ✅ | Device: previous from āyah walks back to item 0 and stops; widget test covers opening↔āyah 1 both ways |
| A7 | Al-Fātiḥah has no phantom opening item | ✅ | Real-data test: queue for surah 1 is exactly 7 |

### Highlight

| # | Check | Result | Evidence |
|---|---|---|---|
| H1 | Opening highlight | ✅ | BM2 widget test asserts the rendered colour; transparent when idle, `primaryContainer@0.35` when playing |
| H2 | Āyah highlight | ✅ | F1 widget tests; device screenshot: āyah 2 card green with `graphic_eq` icon |
| H3 | No simultaneous highlight | ✅ | BM1 widget test: while the Basmalah plays **no** āyah card is highlighted. Guaranteed structurally by `surah(N) != ayah(N,1)` (F0) |

### Persistence

| # | Check | Result | Evidence |
|---|---|---|---|
| P1 | `ReadingPositionStore` | ✅ | **Device**: `run-as … cat shared_prefs` → `flutter.reading.pos.18 = 3`, an āyah index well inside 110 |
| P2 | `study_sessions` | ✅ | BM1 widget test: after playing from the Basmalah, `ayahFrom`/`ayahTo` are āyah indices inside the surah's āyah count |
| P3 | Resume | ✅ | Position survives app restart; restored scroll matched the saved āyah |
| P4 | Statistics | ✅ | No write path changed; `study_sessions` schema and values untouched |
| P5 | No schema change / migration | ✅ | Zero DB changes across BM1–BM4 |

### Accessibility

| # | Check | Result | Evidence |
|---|---|---|---|
| X1 | Screen-reader output | ✅ | BM2 widget test on the real semantics tree: node label `"Lời mở đầu Surah — Bismillah\n‫بِسْمِ…‬"` |
| X2 | Semantics tree | ✅ | `container: true` produces **one** node, matching `AyahCard`'s shape |
| X3 | Focus order | ✅ | Header → opening → āyah 1 → …, i.e. reading order. The opening's play button is a child node of the labelled container |

### Regression

| # | Check | Result | Evidence |
|---|---|---|---|
| G1 | Search | ✅ | Untouched. Real-data test confirms 27:30 intact, so the one genuine mid-surah Basmalah is still findable |
| G2 | Share / copy | ✅ | `ayahDisplayText` unchanged; share text still excludes the opening, matching what is on screen |
| G3 | Navigation | ✅ | `openAyahInReadingScreen` untouched (`ayahNumber - 1`, never row/playlist space) |
| G4 | Reading Mode (Mushaf / Focus) | ✅ | Both still render āyah 1 inline with its Basmalah; opening row collapses in Focus. Existing Mushaf/Focus tests pass |
| G5 | Audio notification | ✅ | Device: `MediaStyle`, channel `com.duso.qurancompanion.audio`, actions Previous/Pause/Next, correct title after the fix |
| G6 | Whole suite | ✅ | **930 tests pass** |

---

## 2. Bugs found

### BUG-BM4-1 — The lock screen showed **“Ayah null”** while the Basmalah played

**Severity: High** (user-visible on every surah with an opening, i.e. 112
of 114, every time playback starts from the beginning).

**Reproduction (observed, not hypothetical):**

1. Open Al-Kahf (18).
2. Tap the **opening row's** play button.
3. While the Basmalah is still playing, run
   `adb shell dumpsys media_session`.

**Observed before fix:**

```
active item id=0
metadata: size=5, description=Ayah null, Mishary Rashid Alafasy, Al-Kahf
```

The notification and lock screen literally read **“Ayah null”**.

**Root cause.** `mediaItemFor` (Sprint B1) built its title as
`'Ayah ${item.address.ayah}'`. Every playlist item was āyah-level when
B1 was written, so `.ayah` was never null. BM1 introduced a **surah-level**
item for the opening, where `.ayah` *is* null — and string interpolation
turns that into the text `"null"` rather than failing.

**Why the existing tests missed it.** B1's `mediaItemFor` tests only ever
constructed āyah-level items, and BM1 added playlist tests but no
`mediaItemFor` test for the new item type. A `grep` for `.address.ayah`
confirms `mediaItemFor` was the *only* consumer making that assumption —
`AudioBar` (BM1) and `AyahCard` (F1) both handle the surah level
correctly.

### Observation — OBS-BM4-2 (not fixed)

The opening row's play button sits at the far right with noticeable
space above the centred Basmalah, which reads slightly detached compared
with an āyah card's dense action row. It is functional, consistent in
placement with `AyahCard`, and correct. Purely cosmetic, so **not
changed** — the sprint forbids speculative improvement. Recorded for a
future design pass.

---

## 3. Minimal fix

One `switch` in the pure function, plus two tests. No architecture
change, no new concept, no l10n change.

```dart
title: switch (item.address.ayah) {
  final ayahNumber? => 'Ayah $ayahNumber',
  null              => 'Bismillah',
},
```

The label stays untranslated Latin deliberately, matching the existing
`title` (`'Ayah N'`) and `album` (Latin surah name): OS media
notifications do not carry the app's UI locale, and *Bismillah* is the
form a Qur'an listener recognises regardless of which translation they
read.

### Fix verified on device — same reproduction re-run

| | Before | After |
|---|---|---|
| Metadata at item 0 | `description=Ayah null` | **`description=Bismillah`** |
| `active item id` | 0 | 0 |
| Queue size | 111 | 111 |
| Āyah items | `Ayah 10` | `Ayah 10` (unchanged) |

**Tests added (2):** surah-level address → `'Bismillah'`, never contains
`null`, album/artist/id intact; and āyah-level unchanged at `'Ayah 255'`.

---

## 4. Remaining risks

| # | Risk | Severity | Note |
|---|---|---|---|
| **R1** | **iOS entirely unverified** | **High** | Unchanged from B3. Every device result here is Android. Basmalah 2.0 adds no iOS-specific code, so the risk is inherited, not new — but it is still open |
| **R2** | Emulator ≠ hardware | Medium | No Doze, no vendor battery management, no real Bluetooth. Same caveat as B3 |
| **R3** | Notification title not localised | Low | Pre-existing (`'Ayah N'` was already untranslated). BM4 keeps the register consistent rather than introducing a second convention |
| **R4** | Resume never replays the Basmalah | Low–Med | By design (BM3 §2). Resuming mid-surah is not "read from the start". Worth watching in beta |
| **R5** | Opening row has no bookmark/note/share | Low | Deliberate — would need an `ayahs` row, i.e. schema |
| **R6** | Only Al-Kahf and Al-Fātiḥah exercised on device | Low | The 114-surah coverage is at the real-data level; the device run spot-checked one surah of each shape |
| **R7** | OBS-BM4-2 cosmetic spacing | Very low | Recorded, not changed |

---

## 5. Test & coverage delta

| | BM3 | BM4 | Δ |
|---|---|---|---|
| Tests | 920 | **930** | **+10** |
| Coverage (filtered, gate 80) | 82.04% | **82.04%** | 0.00 pp |
| Coverage (raw) | 52.62% | 52.62% | 0.00 pp |

- `basmalah_real_data_test.dart` (**new**, +8): 114-surah classification;
  exactly-one-Basmalah; Al-Fātiḥah; At-Tawbah; **An-Naml 27:30
  untouched**; `ReadingRows` over real āyah counts; playlist length over
  real āyah counts; Al-Fātiḥah queue = 7.
- `quran_audio_handler_test.dart` (**+2**): the BUG-BM4-1 regression pair.

Coverage is flat because the new tests exercise already-covered lines
through real data rather than adding new production code — which is
exactly what a verification sprint should look like.

| Gate | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 369 files, **0 changed** |
| `flutter analyze --fatal-infos` | **No issues found** |
| `flutter test` | **930 passed** |
| `flutter test --coverage` | **82.04%** |

---

## 6. Recommendation

**A production defect was found, so the "no defect" branch does not
apply — but it is fixed, re-verified against its own reproduction, and
covered by tests. Recommend committing BM1 + BM2 + BM3 + the BM4 fix
together, with this report.**

Rationale for one commit:

- BM3 deletes a function BM1 introduced; BM2's row is what makes BM3's
  button meaningful. The intermediate states are not independently
  sound.
- The BM4 fix repairs a defect BM1 introduced into a B1 function.
  Committing it separately would place a commit in history whose lock
  screen reads "Ayah null".
- All four sprints share one migration of the index space; splitting
  them would put two half-migrated states in history.

Suggested message: `feat(reading): Basmalah 2.0 — opening as a
first-class reading element`.

**Basmalah 2.0's user goal is met**, and now verified rather than
asserted:

- **Displayed** correctly for all 114 surahs, checked against the
  shipped database, with At-Tawbah and Al-Fātiḥah correct for opposite
  reasons and An-Naml 27:30 untouched.
- **Heard** — 112 surahs recite it, in the user's reciter, with no new
  assets.
- **Highlighted** — its own row, its own decoration, never simultaneous
  with an āyah.
- **Navigable** — its own button; one step to and from āyah 1; each
  play button does what its label promises.

**Before any beta build:** run the iOS half (R1). It remains the largest
untested surface in the audio feature, and no amount of Android
verification substitutes for it.
