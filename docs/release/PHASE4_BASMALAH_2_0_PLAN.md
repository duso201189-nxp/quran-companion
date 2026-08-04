# Basmalah 2.0 — Architecture Review & Implementation Plan

**Sprint type:** architecture-first. No production code written.

**Governing records:** `DR-2026-0017` (Universal Address), `DR-2026-0018`
(Reading Session), `DR-2026-0019` (Reading Engine).

**Constraints honoured:** no Word Address, no Reading Engine redesign,
**no schema change** (§4.6 shows none is needed).

**User goal:** *"Every Surah should present Basmalah correctly, with
audio, highlight and navigation behaving naturally."*

---

## 1. Architecture analysis

### 1.1 The Basmalah exists in three layers that currently disagree

Everything below was measured against the shipped artifacts, not read
from doc comments.

| Layer | What it says the Basmalah is | Evidence |
|---|---|---|
| **Content** (`quran.sqlite`) | The first 4 tokens of āyah 1's text for 112 surahs; **is** āyah 1 for surah 1; absent for surah 9 | 111 āyāt' text starts with the byte-identical Basmalah; 2 spelling variants (95, 97); F2 verified |
| **Presentation** (`ReadingScreen`) | A decorative header string, split off āyah 1 — **List mode only**. Mushaf and Focus render it inline | `_SurahHeader(basmalah:)`; `mushaf_builder.dart` has no Basmalah concept |
| **Audio** (everyayah.com) | **Nothing.** The per-āyah files do not contain it | Measured below |

### 1.2 The audio finding — the Basmalah is never heard

`HEAD` requests against the shipped reciter URL scheme, at 128/192 kbps:

| File | Bytes | ≈ duration | Contains Basmalah? |
|---|---|---|---|
| `001001.mp3` (Al-Fātiḥah 1:1 = *the Basmalah*) | 146,830 | ~9.2 s | it **is** the Basmalah |
| `002001.mp3` (Al-Baqarah 2:1, "Alif Lām Mīm") | 123,007 | ~7.7 s | **no** |
| `112001.mp3` (Al-Ikhlāṣ 112:1, 4 words) | 48,192 | ~3.0 s | **no** — cannot hold a 9 s Basmalah |

**Conclusion: for 112 of 114 surahs the user sees the Basmalah and never
hears it.** When āyah 1 then plays, the highlight lands on a card whose
text *deliberately excludes* the Basmalah the user is not hearing. That
is the defect at the centre of this sprint, and it is a **content/audio
mismatch**, not a rendering preference.

### 1.3 The enabling discovery — the audio already exists, free

Al-Fātiḥah's āyah 1 **is** the Basmalah. Therefore `001001.mp3` is a
Basmalah recording for every reciter, in the same voice, at the same
bitrate, from the same CDN. Verified for all five shipped reciters:

| Reciter | `001001.mp3` | Bytes |
|---|---|---|
| Alafasy | HTTP 200 | 146,830 |
| Abdul Basit | HTTP 200 | 104,827 |
| Minshawi | HTTP 200 | 79,540 |
| Husary | HTTP 200 | 82,164 |
| Sudais | HTTP 200 | 75,786 |

**No new assets. No new licensing. No schema. No pipeline.** Basmalah
audio is an addressing problem, not a content problem.

### 1.4 The addressing insight — `QuranAddress.surah(N)` already *is* the Basmalah's address

The obvious objection to Basmalah-as-a-first-class-element is that its
extent inside āyah 1 cannot be expressed without Word Address, which
this sprint forbids.

That objection dissolves once you stop trying to address the Basmalah's
**text** and address its **role** instead. The Basmalah of surah N is
*the thing that opens surah N* — and F0 already ships an address for
exactly that: `QuranAddress.surah(N)`.

Three properties of F0 make this work with **no new type**:

1. **`QuranAddress.surah(2) != QuranAddress.ayah(2, 1)`** — F0 tests
   this explicitly. So `AyahCard`'s equality-based highlight can never
   accidentally match the opening, and vice versa.
2. **`compareTo` already sorts surah-level *before* every āyah of that
   surah** — F0's document-ordering test. The Basmalah sorts first
   without a rule being written.
3. **Well-formedness ≠ existence** — surah 9 simply has no opening
   element; nothing needs to represent "absent" specially.

The exact word extent remains unexpressed. That is *correct*: it is
`DR-2026-0017` M4/M5 work, gated on `PROJ-P-002`, and Basmalah 2.0 does
not need it to reach the user goal.

### 1.5 The 27:30 constraint — Basmalah is positional, never textual

Searching the Basmalah phrase across `arabic_plain` returns **114 hits**:
113 are āyah 1, and one is **27:30** (An-Naml — the Basmalah inside
Sulaymān's letter), where it is genuine mid-surah revelation, not an
opening.

This single verse is the decisive argument against any implementation
that identifies the Basmalah by matching text. **The Basmalah is a
structural role, not a string.** F2's `SurahOpening` already encodes it
that way; any Basmalah 2.0 work must stay on that side of the line.

### 1.6 What F0–F2 and B1–B3 already contributed

| Sprint | Asset | Role in Basmalah 2.0 |
|---|---|---|
| **F0** | `QuranAddress`, surah/āyah levels, ordering, value equality | The opening's identity (§1.4) |
| **F1** | `sealed AyahDecoration` + `resolveAyahDecoration` | Highlighting the opening = one new branch |
| **F2** | `sealed SurahOpening` + `resolveSurahOpening` | The declaration. Surah 1/9 knowledge lives in exactly one function |
| **F2** | `ReadingRows.leadingRows` | **The insertion seam.** Designed for precisely this |
| **B1** | `AyahAudioItem` carries `QuranAddress`, not a URL | The opening becomes a playlist item with an identity |
| **B2** | Queue population, bounded `skipToNext` | The opening enters the OS queue for free |
| **B3** | `playbackStateFor` completion fix | Prevents a stuck notification at surah end |

**Basmalah 2.0 is largely the cash-in of F0–F2.** That is the strongest
evidence those sprints chose the right foundations.

---

## 2. Gap analysis

Every way the Basmalah currently differs from a normal reading element,
classified as **intentional** or **architectural debt**.

| # | Difference from a normal āyah | Verdict | Severity |
|---|---|---|---|
| **G1** | **Never audible** for 112 surahs (§1.2) | **Debt** | **High** — the user goal |
| **G2** | Has no address, so nothing can refer to it | **Debt** | High — blocks G3, G4 |
| **G3** | Cannot be highlighted while playing | **Debt** | High |
| **G4** | Not a list row → no long-press, no bookmark, no share, no copy, no decoration | **Debt** | Medium |
| **G5** | Header `Text` has **no `Semantics`** — screen readers read raw Arabic with no role or label, and it is not focusable | **Debt** | Medium — accessibility, and trivially cheap |
| **G6** | Rendered inline in Mushaf and Focus, split out in List | **Intentional** — Mushaf fidelity is the point; `basmalah.dart` documents it | — |
| **G7** | Basmalah search returns 113 āyah-1 hits (§1.5) | **Debt** | Low |
| **G8** | `arabic` search source includes the Basmalah; `translit_latin` does **not** (`2:1` indexes as `alif-lam-meem`) — two sources, two answers | **Debt** (data) | Low |
| **G9** | Contributes nothing to progress/statistics | **Intentional** — `DR-2026-0017` §10.3: the count falls out of the level. A surah-level opening completes 0 āyāt | — |
| **G10** | Not a reading position | **Intentional** — position is āyah-based and persisted 0-based; changing it is the `study_sessions` hazard | — |
| **G11** | Excluded from share/copy text (`ayahDisplayText`) | **Intentional** — matches what is on screen | — |
| **G12** | Playlist index and āyah index are currently identical; adding an opening breaks that | **Debt created by the fix** | **High** — see R1 |

**Read-out:** four intentional differences, seven debts. Only **G1–G3**
stand between today and the user goal. G4/G5 are cheap and adjacent;
G7/G8 are polish.

---

## 3. Dependency graph

```
                        F2  SurahOpening  (shipped)
                                │
             ┌──────────────────┼──────────────────┐
             │                  │                  │
             ▼                  ▼                  ▼
      BM1 Semantics      BM2 opening row      BM3 Basmalah audio
      on header          (ReadingRows          (playlist item,
      (independent)       .leadingRows)         address = surah(N))
             │                  │                  │
             │                  └────────┬─────────┘
             │                           ▼
             │                  BM4 opening decoration
             │                  (F1 AyahDecoration + F0 address equality)
             │                           │
             ▼                           ▼
        ── user goal reached: seen, heard, highlighted ──
                                         │
                                         ▼
                              BM5 search de-noise (optional)

  Independent of all of the above, and deliberately excluded:
      Word Address (DR-0017 M4/M5) ── exact word extent ── PROJ-P-002
      Reading Engine E3/E5        ── pipeline extraction
      DR-0018 Session             ── no consumer yet
```

**Critical path to the user goal: F2 → BM2 → BM3 → BM4.** BM1 is
parallel and needs nothing. BM5 is optional.

**Nothing depends on Word Address.** That is the design's main claim,
and §1.4 is its justification.

---

## 4. Risk assessment

### R1 — Playlist index stops equalling āyah index (**High**, the central risk)

Adding an opening item at playlist position 0 means
`AudioState.currentIndex` is no longer the 0-based āyah index for those
surahs. That is **system B splitting in two** — precisely the class of
ambiguity F0 existed to remove, reappearing in a new place.

Blast radius, all currently assuming the identity:

| Site | Today | Breaks how |
|---|---|---|
| `ReadingScreen` auto-scroll | `ReadingRows.rowForAyahIndex(next.currentIndex)` | Scrolls one āyah off |
| `AudioController.playSurah(startIndex:)` | āyah index | Plays the wrong āyah |
| `_shortcutPlayPause` | `_lastSavedIndex` | Resumes one off |
| `ReadingPositionStore` | saved 0-based āyah index | Silently drifts |
| `study_sessions.ayah_from/to` | 0-based, **on disk, unrecoverable** | Corrupts statistics |

**Mitigation — mandatory, and it is the whole point of BM2's design:**
introduce `ReadingPlaylist` as the exact mirror of F2's `ReadingRows` —
one pure module owning `leadingItems(opening)`,
`playlistIndexForAyahIndex`, `ayahIndexForPlaylistIndex`. **Both**
`ReadingRows.leadingRows` and `ReadingPlaylist.leadingItems` derive from
the *same* `SurahOpening` value, so rows and playlist cannot disagree.
No raw `+1`/`-1` anywhere.

`ReadingPositionStore` and `study_sessions` **stay āyah-based and
untouched** — the opening maps to āyah index 0, exactly as the header
row does today. **This is why no schema change is required.**

### R2 — Reciter Basmalah differs in tone from the surah recitation (**Medium**)

`001001.mp3` is recorded as Al-Fātiḥah's opening. Reciters often pitch
the Basmalah to lead into the specific surah; a generic one may sound
slightly detached. **Accepted**: it is the same reciter's voice, it is
what several established apps do, and the alternative is a bespoke
114×5 asset set with its own licensing and pipeline. Revisit only if
beta testers raise it.

### R3 — Extra network request per surah (**Low**)

One additional ~80–150 KB fetch when playback starts. Same CDN, same
cache path as every other āyah. Negligible.

### R4 — Surah 1 must not get a second Basmalah (**Medium**, correctness)

Al-Fātiḥah's āyah 1 *is* the Basmalah. Adding an opening element there
would play and render it twice. F2's type prevents this structurally:
only `OpeningPrefixesFirstAyah` yields an opening row/item;
`OpeningIsFirstAyah` and `NoOpening` yield none. **The guard is the
sealed switch, not an `if (surahId != 1)`.**

### R5 — Mushaf/Focus divergence widens (**Low**)

BM2–BM4 touch List mode only. Mushaf and Focus keep rendering inline
(G6, intentional). Acceptable, but it must be *stated* in the code, or a
later reader will "fix" the inconsistency.

### R6 — Accessibility regression risk when the header becomes a row (**Low**)

Making the opening focusable changes screen-reader traversal order. BM1
(labelling it) should land **before** BM2 so the element is already
correctly described when it becomes reachable.

### R7 — `leadingRows` becoming surah-dependent touches five call sites (**Low**)

F2 already routed all five through `ReadingRows`, so this is a
signature change in one module, not a hunt. **This is F2 paying off
exactly as predicted.**

---

## 5. Incremental implementation plan

Each step is independently shippable, behaviour-preserving except where
stated, and gated.

| # | Step | Scope | Schema | Depends | Gate |
|---|---|---|---|---|---|
| **BM1** | **Label the Basmalah for screen readers.** Wrap the header `Text` in `Semantics` with a proper label from l10n (3 `.arb` files). | XS | None | — | Widget test asserts the semantics label; a11y checklist |
| **BM2** | **Make the opening a reading row.** `ReadingRows.leadingRows` → a function of `SurahOpening`. Row 1 renders the opening when `OpeningPrefixesFirstAyah`, header keeps its decorative copy for Mushaf-fidelity **or** moves — decide in review. | **M** | None | F2 | Golden: all 114 surahs render identically **except** the intended new row; position round-trip unchanged |
| **BM3** | **Basmalah audio.** `ReadingPlaylist` (mirror of `ReadingRows`, per R1). Opening item = `AyahAudioItem(address: QuranAddress.surah(N), source: <reciter>/001001.mp3)`. All index conversions through the new module. | **M/L** | None | BM2 | Playlist index ↔ āyah index round-trip tests; `ReadingPositionStore` and `study_sessions` byte-identical before/after |
| **BM4** | **Highlight the opening.** One new branch in F1's `sealed AyahDecoration`; opening row matches on `currentAddress == QuranAddress.surah(N)`. | **S** | None | BM3 | Rendered-colour tests as in F1; precedence unchanged |
| **BM5** | *(Optional)* **Search de-noise.** Collapse the 113 āyah-1 Basmalah hits, **preserving 27:30**. | S | None | — | Query returns 27:30; āyah-1 hits grouped, not deleted |

**Smallest path to the stated user goal: BM1 → BM2 → BM3 → BM4.**
BM5 is polish and should be cut if capacity slips.

### 5.1 Two decisions needed from review before BM2 starts

1. **Does the decorative header Basmalah stay, move, or both?** If the
   opening becomes a row, keeping the header copy shows it twice.
   Recommendation: **move it** — the row replaces the header's Basmalah;
   the header keeps name/place/count. Mushaf and Focus are untouched.
2. **Does the opening row get the full āyah action set** (bookmark,
   note, highlight, share) or playback only? Recommendation:
   **playback + copy/share only** for now. Bookmarks and notes are keyed
   on `ayahs.id`; the opening has no row in `ayahs`, and inventing one
   *would* be a schema change. Deliberately deferred (G4 partial).

### 5.2 Explicitly out of scope

Word Address / exact word extent (`DR-0017` M4/M5, `PROJ-P-002`);
Reading Engine E3/E5; `DR-0018` Session; per-surah bespoke Basmalah
audio; Mushaf/Focus changes; bookmarking or annotating the opening.

---

## 6. Test strategy

**Layer 1 — pure (no widget, no DB), the F0/F1/F2 pattern**

- `SurahOpening` → row count and playlist length for all 114 surahs;
  assert exactly 112 gain an opening, and surahs 1 and 9 gain none (R4).
- `ReadingPlaylist` ↔ `ReadingRows` agreement: for every surah, both
  derive their leading count from the same `SurahOpening`.
- Index round-trips: `ayahIndexForPlaylistIndex(playlistIndexForAyahIndex(i)) == i`
  for all i, both with and without an opening (R1).
- Address identity: `QuranAddress.surah(N) != QuranAddress.ayah(N, 1)`
  and sorts before it (guards §1.4's two load-bearing properties).

**Layer 2 — widget**

- Rendered card/row colour in all decoration states, including the new
  opening state (extends F1's four tests).
- Semantics label present on the opening (BM1), and traversal order
  sane once it becomes a row (R6).
- Al-Fātiḥah renders **exactly one** Basmalah; At-Tawbah renders none
  (R4) — this test should exist before BM2 lands.

**Layer 3 — regression / equivalence**

- **The persistence invariant, and the most important test in the plan:**
  drive a reading session over a surah *with* an opening and assert the
  values written to `ReadingPositionStore` and `study_sessions` are
  byte-identical to the pre-BM3 values. This is the R1 corruption guard.
- Golden-style: for all 114 surahs, assert display text is unchanged
  from F2's oracle (the Basmalah must not reappear inside āyah 1's card).

**Layer 4 — device (extends the B3 harness, which already works)**

- Play a surah with an opening: the queue is `ayahCount + 1`; the
  notification shows the Basmalah as item 1; `skipToPrevious` from āyah 1
  reaches the opening, and one more press stays there.
- Al-Fātiḥah: queue is exactly 7 — no phantom opening item (R4).
- At-Tawbah: queue equals its āyah count, no opening.

---

## 7. Recommendation

**Proceed, and treat this as the payoff sprint for F0–F2 rather than as
new architecture.** Almost nothing here is invention: F2 declared the
opening, F2 built the row seam, F0 supplied the address and its
ordering, F1 supplied the decoration type, B1 made playlist items
addressable. Basmalah 2.0 mostly connects parts that were built for it.

**Three findings that should drive the review:**

1. **The real defect is audio, not rendering.** For 112 surahs the
   Basmalah is displayed and never heard — measured, not inferred. Any
   plan that only adjusts layout misses the user goal entirely.
2. **The audio is free.** `001001.mp3` is a Basmalah in every shipped
   reciter's own voice, verified HTTP 200 across all five. No assets, no
   licensing, no schema — which is why this is a small sprint rather
   than a content programme.
3. **27:30 proves the Basmalah is positional, not textual.** Any
   text-matching shortcut is wrong, and would corrupt a genuine verse.

**The one thing to get right is R1.** Adding a playlist item splits the
0-based index space in two, and two of the affected sinks —
`ReadingPositionStore` and `study_sessions` — are **on disk**, with
`study_sessions` documented as silently and unrecoverably corruptible.
`ReadingPlaylist` mirroring `ReadingRows`, both derived from one
`SurahOpening`, is not optional polish; it is the mitigation. The
persistence-invariant test in §6 Layer 3 should be written **before**
BM3, not after.

**Sequence:** BM1 immediately (XS, independent, closes an accessibility
gap). Then BM2 → BM3 → BM4 as one connected change with the persistence
test as its gate. Hold BM5.

**Before BM2 begins, review must answer the two questions in §5.1** —
whether the header keeps its Basmalah, and whether the opening row gets
the full action set. Both change BM2's shape, and the second one is what
keeps this sprint free of schema change.
