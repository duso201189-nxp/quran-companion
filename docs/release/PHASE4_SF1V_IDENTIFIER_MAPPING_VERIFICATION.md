# SF1-V — `ayah_id` ↔ `QuranAddress` Mapping Verification

**Sprint type:** verification only. No production code, no schema
change, no data migration, no repository modified.

**Method:** every claim below is executed against the shipped
`assets/database/quran.sqlite` or read out of the current source. Where
a claim is an inference rather than a measurement, it says so.

**Status: Study Foundation milestone closed, 2026-08-04.** The adoption
sequence recommended here (§5) began as ordered: Tier 0 (the
`AyahOrdinal` module, Sprint SF2) and Tier 1 (`KhatmCycleRepository`,
Sprint SF3) are both shipped, gated, and committed. Tiers 2–7 remain in
the order specified here, resumed only when a concrete consumer needs
`QuranAddress` at one of those boundaries — not on a fixed schedule.
Two further sprints closed the Khatm feature's own lifecycle on top of
that adoption — Sequential Khatm Progress and Atomic Khatm Completion —
neither of which required revisiting anything in this document: the
mapping proved here did not change.

---

## 1. Mapping proof

### 1.1 Preconditions — all measured, all hold

| # | Property | Result |
|---|---|---|
| P1 | Total āyāt | **6236** |
| P2 | `MIN(id)`, `MAX(id)` | **1, 6236** |
| P3 | Distinct ids | **6236** (no duplicates) |
| P4 | Ids outside 1…6236 | **0** (dense, no gaps) |
| P5 | `id == ROW_NUMBER() OVER (ORDER BY surah_id, ayah_number)` | **true** |
| P6 | Distinct `(surah_id, ayah_number)` pairs | **6236** |
| P7 | `ayah_number` contiguous 1…n within every surah | **true** |
| P8 | `surahs.ayah_count == COUNT(ayahs)` for all 114 | **true** |
| P9 | Surah ids contiguous 1…114 | **true** |

P3 + P4 + P6 together establish that both sides of the mapping are sets
of exactly 6236 distinct elements with no holes — the necessary
condition for a bijection.

### 1.2 The bijection — constructed and checked exhaustively

The mapping was implemented from **only** the cumulative offsets of
`surahs.ayah_count`, then checked against every row of `ayahs` as ground
truth:

```
offset[s] = Σ ayah_count[1..s-1]
id  → addr :  s = min{ s : offset[s] ≥ id },  ayah = id − offset[s−1]
addr → id  :  id = offset[s−1] + ayah
```

| # | Check | Result |
|---|---|---|
| B1 | forward `id → (surah, ayah)` mismatches vs DB, over all 6236 | **0** |
| B2 | reverse `(surah, ayah) → id` mismatches vs DB, over all 6236 | **0** |
| B3 | round-trip `addr_to_id(id_to_addr(i)) == i` failures, i ∈ 1…6236 | **0** |
| B4 | image is all 6236 distinct addresses (surjective) | **true** |
| B5 | mapping requires **only** `surahs.ayah_count` — the `ayahs` table is not consulted | **true** |

**Objectives 1 and 2 are proven.** The mapping is total, injective,
surjective and reversible over the entire address space, with zero
exceptions.

### 1.3 B5 is the architecturally significant one

The map needs **114 integers**, not a 6236-row lookup. A conversion can
therefore be a *pure, synchronous* Dart function — no database handle,
no `async`, nothing dragged into the domain layer. Had the mapping
required the `ayahs` table, every study repository would have needed a
content-database dependency to name its own data.

### 1.4 Ordering is preserved

| # | Check | Result |
|---|---|---|
| O1 | `ORDER BY ayah_id` == `ORDER BY (surah_id, ayah_number)` | **true** |

This matters because `quran_repository_impl.dart:156` sorts FTS search
results with `ORDER BY ayah_id LIMIT ?`. F0's `QuranAddress.compareTo`
sorts surah-then-āyah, so **replacing the identifier does not reorder
search results.** Follows from P5, confirmed independently.

---

## 2. Repository-by-repository compatibility

Every site referencing `ayahId`/`ayah_id` in `lib/` was enumerated
(excluding generated `.g.dart` and l10n).

| Repository | Tables / source | Scheme | Sites | Adoptable? | Additional work |
|---|---|---|---|:--:|---|
| **`UserContentRepository`** | `Bookmarks`, `Highlights`, `Notes`, `Favorites`, `AyahStatuses` | **A** — global ordinal | 38 impl + 11 iface | ✅ | None technically. **Largest blast radius** — 5 tables, heavy UI coupling |
| **`BookmarkCollectionRepository`** | `Bookmarks`, `BookmarkCollections` | **A** | 6 impl + 2 iface | ✅ | None |
| **`QuranRepository`** (search) | `search_index.ayah_id`, `getAyahsByIds` | **A** | 6 | ✅ | Convert **after** the FTS query; the join key stays `ayah_id`. Ordering safe per O1 |
| **`SchedulerRepository`** | `SrsCards(item_type, item_id)` | **E → A** when `item_type='ayah'` | `List<int>` at one boundary | ⚠️ **partial** | Only the āyah arm converts. The `lemma` arm has no address. Resolve by typing the existing `syncWithReviewQueue` to addresses and leaving the generic `syncItemsForType` on ints — **no new `StudyItem` type needed** |
| **`KhatmCycleRepository`** | `KhatmCycles.current_ayah_id` | **A** | 1 field, non-null, `withDefault(1)` | ✅ | None. Smallest surface in the set |
| **`StudySessionRepository`** | `StudySessions.surah_id + ayah_from/ayah_to` | **B** — 0-based *within surah* | 1 write path, several read paths | ⚠️ **different work** | Does **not** need the ordinal map — F0's `fromZeroBasedAyahIndex` already covers it. But a session is a **range**, and F0 has no `Range` (deliberately excluded). See §4 E5 |
| **`QuizRepository`** | `QuizResults.surah_id` (nullable) | **C** — surah level, no āyah | 2 | ✅ | Maps to `QuranAddress.surah(N)`, which F0 already has. Nullability must survive |
| **`FlashcardRepository`** | `Flashcards.lexicon_entry_type/id` | **D** | — | ❌ **not applicable** | Not āyah-addressed by design. Nothing to convert |
| **`LexiconRepository`** | `word_instances.ayah_id` | **A** | 1 | ⏸ **blocked** | Scheme is compatible, but the Lexicon tables hold 0 rows pending the QAC licence |

**Objective 3 complete: nine repositories examined.**

**Objective 4 — repositories that cannot adopt without additional
work:** `SchedulerRepository` (polymorphic, only one arm addressable),
`StudySessionRepository` (different scheme + range semantics),
`FlashcardRepository` (not āyah-addressed at all),
`LexiconRepository` (content-blocked). The remaining five are
mechanical.

---

## 3. Risks

| # | Risk | Severity | Evidence |
|---|---|---|---|
| **R1** | **`ayah_id` is edition-scoped.** It encodes *this build's* Kufi āyah counting. A second edition with different counts silently shifts every stored id. Adopting `QuranAddress` does **not** fix this — an address is edition-scoped too | **High, dormant** | No `edition` column exists in either database. `DR-2026-0017` §3.1 named the axis; F0 excluded it for lack of a consumer |
| **R2** | **No referential integrity on `ayah_id`.** Verified: no FK, no CHECK constraint anywhere in `user_tables.dart`. The user DB is a separate SQLite file, so a cross-database FK is impossible in principle | **Medium** | Nothing prevents an orphan or out-of-range id being stored today |
| **R3** | **`QuranAddress.ayah()` throws** (`_requirePositive` → `ArgumentError`). Feeding it an unvalidated stored id would convert a silent bad row into a crash | **Medium** | Read from `quran_address.dart:68,176`. Mitigation in §4 E1 |
| **R4** | `study_sessions` two-base problem — 0-based columns with no column recording their base, and statistics derived on read | **Medium** | Already documented at the column and in `quran_index_conventions.md`. Adoption reduces exposure but does not remove the stored ambiguity |
| **R5** | `UserContentRepository`'s 38 call sites make a single-pass conversion tempting | **Medium** | A big-bang edit here is the most likely way this programme introduces a regression. Mitigated by ordering (§5) |
| **R6** | Offset table duplicates `surahs.ayah_count` in code | **Low** | Necessary for B5's purity. Must be guarded by a test asserting the constant matches the shipped DB — the `basmalah_real_data_test.dart` pattern |

---

## 4. Edge cases

All probed against the constructed mapping; none throws.

| # | Input | Result | Consequence for adoption |
|---|---|---|---|
| **E1** | `id = 0`, `id = −1`, `id = 6237` | `null` | The conversion **must return null, not throw** — `QuranAddress.ayah()` throws, so the entry point has to be a `tryFrom…` in the spirit of F0's own `tryParse`. This is not optional: R2 means unvalidated ids can exist |
| **E2** | `1:8` (Al-Fātiḥah has 7) | `null` | Reverse direction validates against the real āyah count, not a fixed maximum |
| **E3** | `2:287` (Al-Baqarah has 286) | `null` | Same |
| **E4** | `115:1` | `null` | Surah bound enforced |
| **E5** | `study_sessions` row spanning āyāt | — | A session is **two** addresses (`from`, `to`), not one. Expose a pair; do **not** introduce `Range` — F0 excluded it for want of a consumer, and one consumer that can be served by a pair is not that consumer |
| **E6** | `QuizResults.surah_id = NULL` | — | Means "not surah-scoped". Maps to `QuranAddress?`, absent — not to a sentinel |
| **E7** | `SrsCards` with `item_type = 'lemma'` | — | `item_id` is a lemma id, **not** an `ayah_id`. Converting it would be a category error. The type discriminator must be honoured before any conversion |
| **E8** | `KhatmCycles.current_ayah_id` default `1` | `1:1` | Valid; the default is Al-Fātiḥah 1, not a null sentinel |
| **E9** | Orphan id stored by a future edition change | `null` or **wrong address** | If counts change, an in-range id maps *silently to the wrong āyah* — worse than null. This is R1's failure mode and no conversion can detect it |

**E9 is the one edge case the mapping cannot defend against**, and it is
worth stating plainly: within a single edition the mapping is provably
total and lossless; across editions it is silently wrong. That is a
property of the stored identifier, not of the conversion.

---

## 5. Adoption roadmap — ordered by implementation risk

Risk here means *blast radius × difficulty of detecting a regression*,
not effort.

| Tier | Step | Why this position | Gate |
|:--:|---|---|---|
| **0** | **Add the conversion module + offset table.** Pure Dart, `tryFrom…` returning nullable (E1), zero consumers | Cannot regress anything — nothing calls it yet | Round-trip over all 6236 against the shipped DB; all E1–E4 return null; offset constant matches `surahs.ayah_count` (R6) |
| **1** | **`KhatmCycleRepository`** — 1 non-null field | Smallest surface in the codebase; a regression is immediately visible as a wrong resume point | Stored `current_ayah_id` byte-identical before/after |
| **2** | **`QuizRepository`** — 1 nullable surah field | Surah level only; F0 already has that level; nullable is the only subtlety (E6) | Null stays null, never a sentinel |
| **3** | **`QuranRepository` search results** — post-query conversion | Join key untouched; ordering proven safe (O1) | Result order and count unchanged for a fixed query |
| **4** | **`SchedulerRepository`, āyah arm only** — `syncWithReviewQueue` | One boundary, one list; the lemma arm stays on ints (E7) | SRS card rows byte-identical; lemma path untouched |
| **5** | **`BookmarkCollectionRepository`** — 6 sites | Moderate surface, self-contained | Assignments unchanged |
| **6** | **`UserContentRepository`** — 38 sites, 5 tables | Largest blast radius and heaviest UI coupling (R5). Do it **last among the mechanical ones**, one table at a time, never in a single pass | Per table: stored rows byte-identical; annotation UI unchanged |
| **7** | **`StudySessionRepository`** — scheme B + range | Different scheme, needs a pair not an address (E5), and sits on the one documented **unrecoverable-corruption** hazard (R4). Do it only once the pattern is established everywhere else | `ayah_from`/`ayah_to` byte-identical on disk; streak and study-time figures unchanged for a fixed dataset |
| — | `FlashcardRepository`, `LexiconRepository` | Not applicable / content-blocked | Not scheduled |

**The persistence gate is the same one BM1 used and it should be
mandatory at every tier: drive the repository, then assert the values
written to disk are byte-identical to before.** Adoption is a domain-layer
change; the moment a stored value differs, the change is wrong.

---

## 6. Final recommendation

**The mapping is proven. Proceed with Tier 0, then adopt in the order
above — and treat the ordering as the deliverable, not a suggestion.**

Three things the review should take from this:

1. **Objectives 1 and 2 are settled by measurement, not argument.**
   Zero mismatches forward, zero reverse, zero round-trip failures over
   all 6236 āyāt, surjective, order-preserving. The mapping needs 114
   integers and no database handle, so the conversion can be pure and
   synchronous — which is what makes Tier 0 risk-free.

2. **Two findings change how the work must be written, not whether.**
   `QuranAddress.ayah()` **throws**, and stored `ayah_id` values have
   **no referential integrity** (verified: no FK, no CHECK, and none is
   possible across two SQLite files). So the entry point must be a
   nullable `tryFrom…`, following F0's own `tryParse` precedent. Writing
   it the obvious way would convert today's silent bad rows into
   crashes.

3. **Do not let this become a `Range` or a `StudyItem` sprint.**
   `study_sessions` is a range and `SrsCards` is polymorphic, and both
   are adoptable without inventing either abstraction — a pair of
   addresses for the first, an honoured type discriminator for the
   second. SF1 recommended deferring both; this verification confirms
   nothing here forces the issue.

**One item still deserves a Decision Record, unchanged from SF1: R1 /
E9.** Within this edition the mapping is provably lossless. Across
editions, an in-range `ayah_id` maps *silently to the wrong āyah* —
which is worse than failing, and which adopting `QuranAddress` does not
fix, because an address is edition-scoped too. It is dormant while one
edition ships. It should be written down before a second one is ever
considered.
