# SF1 — Study System Foundation Analysis

**Sprint type:** analysis only. No production code written.

**Constraints honoured:** no schema change proposed, no morphology, no
Lexicon work, no AI implementation, no Reading Engine rewrite.

**Status: Study Foundation milestone closed, 2026-08-04.** The roadmap
this analysis produced (§8) was carried out in full: SF1-V verified the
bijection this document assumed
(`PHASE4_SF1V_IDENTIFIER_MAPPING_VERIFICATION.md`), SF2 shipped the
`AyahOrdinal` conversion module, and SF3 adopted it at
`KhatmCycleRepository` (Tier 1). Two sprints outside this document's
original scope followed directly from that adoption and are part of
the same closed milestone: **Sequential Khatm Progress** (correcting an
implementation gap this analysis did not anticipate — progress was
first wired to "last position read," not to the sequential-completion
model `KhatmCycle.progressPercent` had always assumed) and **Atomic
Khatm Completion** (closing a lifecycle dead-end: `completeCycle()` had
no caller anywhere until this pass, so a cycle that reached the last
āyah stayed "in progress" forever). Identifier-adoption Tiers 2–7
remain deliberately deferred, per this document's own no-consumer
precedent (§3, M3) — not part of this closure, resumed only when a
concrete consumer needs `QuranAddress` at one of those boundaries.

---

## 0. The headline finding, before anything else

**Six of the seven capabilities this sprint is meant to "support in
future" already exist and ship today.** SM-2 is fully implemented behind
a swappable interface. The Review Queue, flashcards, quiz generation and
the AI-tutor suggestion chain are all built, tested and wired.

So the foundation question is **not** "what should we build". It is:

> The study system already works. It just doesn't agree with itself
> about **how to name the thing being studied.**

There are **five different identifier schemes** across the study tables,
and `QuranAddress` — the address type F0 introduced and F1/F2/BM1–BM4
have since built on — is used in **exactly four files, all inside
`features/quran`. Zero adoption anywhere in the study stack.**

That is the actual foundation gap, and `DR-2026-0017` §4.6 predicted it
in writing: *"thirteen subsystems currently imply thirteen opportunities
for identifier mismatch."*

The good news, established by measurement in §5: closing it costs
**zero schema change and zero data migration**.

---

## 1. Current reusable architecture

Verified against the code, not the docs.

| Asset | Status | Reusable by the study system? |
|---|---|---|
| **`QuranAddress`** (F0) | Surah + āyah levels, value equality, document ordering, `2:255` serialisation, `tryParse` | **Yes — the central one.** Already carries exactly the two levels the study tables need (`ayah_id` → āyah level; `QuizResults.surahId` → surah level) |
| **`SurahOpening`** (F2) | `sealed`, three cases, one resolver | Marginal. Study targets āyāt, not openings. Do **not** force a use |
| **`ReadingRows`** (F2/BM2) | Row layout, presentation-only | **No.** Rows are a rendering concern; a study item is not a row |
| **`ReadingPlaylist`** (BM1) | Playlist layout, domain | **No.** Playback order ≠ study order |
| **`ReadingSession`** (`DR-2026-0018`) | **Does not exist** — record is `proposed`, never implemented | Not available. Do not plan against it |
| **`SchedulingAlgorithm`** (Sprint 10) | Pure interface + SM-2 impl; takes `now` as a parameter, reads no clock | **Yes, as-is.** Already FSRS-swappable; needs nothing from this sprint |
| **Repository-boundary reliability layer** (Sprint 19) | `AppFailure` mapping on every repository | **Yes.** Any new conversion belongs at that same boundary |
| **Dual-database split** | `AppDatabase` (content, read-only asset) / `UserDatabase` (user data, Drift) | **Yes**, and it is the reason the identifier problem exists (§3) |

**Note on `ReadingSession`.** The sprint brief lists it as existing
architecture to reuse. It does not exist — `DR-2026-0018` is a design
record with no implementation. Planning SF work against it would be
planning against a document.

---

## 2. What already exists

| # | Capability | Status | Where |
|---|---|---|---|
| 1 | **Reading Progress** | **Ships** | `ReadingPositionStore` (per-surah 0-based āyah index, SharedPreferences), `study_sessions` table, `KhatmCycles.currentAyahId`, `StatsStore`, `learning_statistics_calculator` |
| 2 | **Review Queue** | **Ships** | `AyahStatuses` (`AyahStatus.review`), `revision_queue_screen.dart`, fed to the scheduler via `syncWithReviewQueue(List<int> ayahIds)` |
| 3 | **SM-2 scheduling** | **Ships, complete** | `SchedulingAlgorithm` interface + SM-2 implementation, `SrsCards` table (ease/interval/repetitions/due/state), `ReviewGrade{again,hard,good,easy}` |
| 4 | **Flashcards** | **Built, content-blocked** | `Flashcards`/`FlashcardDecks` tables, repository, smart-deck selector. Keyed on `lexicon_entry_type`/`lexicon_entry_id` — and the Lexicon tables hold **0 rows** pending the QAC licence answer |
| 5 | **Quiz generation** | **Ships** | `QuestionGenerator` interface, `QuizQuestionFactory`, generator set, `QuizResults` table |
| 6 | **AI Tutor** | **Ships** (heuristic, non-LLM) | `tutor_suggestion_generator`, `tutor_insight_generator`, `TutorContext`, `TutorAction`, `TutorInsight` |
| 7 | **Reflection** | **Absent — zero occurrences** | Nothing. `grep -rniE "reflect" lib/` returns nothing outside l10n |

**Six of seven ship.** The seventh does not exist in any form.

### 2.1 The five identifier schemes

This is the finding that matters. Read from `user_tables.dart`:

| Scheme | Shape | Tables |
|---|---|---|
| **A** | `ayah_id` — global mushaf ordinal, **1-based, 1…6236** | `Bookmarks`, `Highlights`, `Notes`, `Favorites`, `AyahStatuses`, `KhatmCycles.currentAyahId`, `SrsCards.itemId` (when `itemType = ayah`) |
| **B** | `surah_id` + `ayah_from`/`ayah_to` — **0-based index within surah** | `StudySessions` |
| **C** | `surah_id` only, nullable, no āyah | `QuizResults` |
| **D** | `lexicon_entry_type` + `lexicon_entry_id` | `Flashcards` |
| **E** | `item_type` + `item_id` — untyped polymorphic pair | `SrsCards` |

**A and B are both "an āyah", expressed two incompatible ways, in the
same database.** Scheme B is the hazard already recorded at the column
and in `docs/knowledge/quran_index_conventions.md`: those columns are
0-based, **no column records their own base**, and streak/study-time are
derived *on read* — so a writer that silently switched base would
corrupt every statistic unrecoverably.

### 2.2 `ayah_id` is an ordinal, and that is decisive

Measured directly against the shipped `quran.sqlite`:

```
ayahs DDL:  id INTEGER NOT NULL PRIMARY KEY
1:1 → id=1     1:7 → id=7     2:1 → id=8     114:6 → id=6236
id == ROW_NUMBER() OVER (ORDER BY surah_id, ayah_number)  →  true
```

`ayah_id` is **not** an opaque surrogate key. It is the running mushaf
ordinal, deterministic from `(surah_id, ayah_number)`.

**Therefore `ayah_id ↔ QuranAddress` is a total bijection**, computable
in both directions from the surah āyah-count table alone. That single
fact is what makes the whole unification free (§5).

---

## 3. Missing domain concepts

Only three, and one of them should not be built yet.

### M1 — A named home for `ayah_id ↔ QuranAddress` (**real, needed**)

Today every study repository speaks raw `int ayahId`. Nothing converts,
because nothing above it uses addresses. The moment any study surface
wants to say "the āyah you are reviewing is 2:255", it will hand-roll
the conversion — and hand-rolled conversions between numbering systems
is precisely the defect class F0 was created to end.

This is F0's own rule applied one layer out: *storage keeps its format,
the repository boundary converts, and the conversion has a name and a
test.*

### M2 — `Reflection` (**real, but blocked on product, not engineering**)

Genuinely absent. But the honest engineering position is that
**"reflection" is not yet defined as distinct from a note.** A `Notes`
table already exists with exactly the shape a reflection would need
(`ayah_id` + `content` + timestamps + sync columns).

If reflection is *"a note with a prompt and a journaling surface"*, it
needs **no new table** — it needs a product definition and a screen. If
it is *"a separate stream with its own lifecycle"*, it needs a column or
a table, i.e. `PROJ-P-002` sign-off.

**Recommendation: do not design storage for this until the product says
what it is.** Designing it now is guessing, and the guess is what would
force the schema change this sprint is meant to avoid.

### M3 — `StudyItem` sealed type (**do NOT build yet**)

`SrsCards` carries an untyped `(item_type, item_id)` pair. A `sealed
StudyItem` over `QuranAddress` | lemma-id would type it.

It is tempting, and it is the wrong call today. `SrsCards` is the
**only** polymorphic consumer, it works, and its second arm (lemma) is
blocked behind the Lexicon licence. Introducing the abstraction now
would violate this project's own `DR-2026-0006` D4 / `DR-2026-0007` D5
precedent — *"a provider without a consumer is speculation"* — the same
rule that correctly stopped F0 from shipping `Range` and Word levels.

**Build it when a second consumer exists.** Note it, do not create it.

---

## 4. Dependency graph

```
                         QuranAddress  (F0 — shipped)
                               │
                               ▼
                    ┌──────────────────────┐
                    │  M1  ayahId ↔ Address │   ← the only new
                    │      conversion       │      foundation piece
                    └──────────┬───────────┘
                               │
        ┌──────────────┬───────┴───────┬───────────────┐
        ▼              ▼               ▼               ▼
  Review Queue    SRS / SM-2      Reading         Quiz results
  (ayah_statuses) (srs_cards)     Progress        (surah level —
   ships          ships           ships           already fits
        │              │          (2 schemes!)     surah(N))
        └──────────────┴───────┬───────┘
                               ▼
                    address-addressed study surfaces
                    (any surface that must *name* what
                     is being studied, e.g. AI Tutor
                     citations, cross-feature links)

  Blocked / deferred, NOT on this critical path:
     Flashcards ──── Lexicon content ──── QAC licence (external)
     Reflection ──── product definition  (not engineering)
     StudyItem  ──── a second consumer   (does not exist yet)
```

**Critical path is one node wide.** Everything downstream already
exists; M1 is the only thing missing, and nothing else blocks on
anything an engineer can do this month.

---

## 5. Migration cost

Measured, not estimated.

| Move | Schema change | Data migration | Cost |
|---|---|---|---|
| `ayah_id` → `QuranAddress` at the domain layer | **None** | **None** — bijective (§2.2); convert at the repository boundary | **Zero** |
| `QuizResults.surahId` → `QuranAddress.surah(N)` | **None** | **None** — F0 already has a surah level | **Zero** |
| `study_sessions` 0-based → address at the boundary | **None** | **None** — storage keeps 0-based, exactly as `quran_index_conventions.md` rule 2 requires | **Zero** |
| `SrsCards.itemId` (ayah arm) → address | **None** | **None** — `itemId` already holds `ayah_id` | **Zero** |
| Flashcards → address | n/a | n/a | Blocked on Lexicon, not on addressing |
| Reflection storage | **Unknown** | **Unknown** | Undefined until the product defines it (§M2) |

**Total migration cost for the recommended foundation: zero.** This is
not optimism — it follows from `ayah_id` being an ordinal rather than a
surrogate, which was verified against the shipped database.

---

## 6. Risks

| # | Risk | Severity | Note |
|---|---|---|---|
| **R1** | **`ayah_id` is edition-scoped.** It encodes *this build's* Kufi āyah counting. A different counting tradition shifts every stored id after the divergence point — silently, across bookmarks, notes, highlights, SRS cards and khatm position | **High but dormant** | No `edition` column exists anywhere. `DR-2026-0017` §3.1 named the edition axis; F0 deliberately excluded it for lack of a consumer. **Not urgent — but this is the deepest latent risk in the study system**, and adopting `QuranAddress` does not fix it (an address is edition-scoped too). Worth a Decision Record before any second edition is ever shipped |
| **R2** | `study_sessions` two-base problem | **Medium** | Documented but not closed. Derived-on-read statistics mean a base error is unrecoverable. M1 reduces exposure by removing the reason anyone would hand-convert |
| **R3** | Flashcards non-functional on a real install | **Medium** | External: QAC licence, deadline 2026-08-24. No engineering sprint should be scheduled against it |
| **R4** | Reflection designed before it is defined | **Medium** | The single most likely way this sprint's successor introduces an unnecessary schema change. Guard: refuse to design storage before the product statement |
| **R5** | Building `StudyItem` speculatively | **Medium** | Would break the project's own no-consumer precedent, and its second arm is Lexicon-blocked anyway |
| **R6** | "Foundation" work rebuilding what ships | **High, and this sprint's main hazard** | Six of seven capabilities exist. Any roadmap that reads as "build the study system" is wrong by construction |

---

## 7. Capability matrix

| Capability | Exists | Addressed by | Needs M1? | Blocked by |
|---|:--:|---|:--:|---|
| Reading Progress | ✅ | `ayah_id` **and** 0-based `(surah, index)` | ✅ yes | — |
| Review Queue | ✅ | `ayah_id` | ✅ yes | — |
| SM-2 scheduling | ✅ | `(item_type, item_id)` → `ayah_id` | ✅ yes | — |
| Flashcards | ⚠️ built | `lexicon_entry_id` | ✗ no | **Lexicon licence** |
| Quiz generation | ✅ | `surah_id` (nullable) | ✅ yes (surah level) | — |
| Reflection | ❌ absent | — | would | **Product definition** |
| AI Tutor | ✅ heuristic | mixed / implicit | ✅ yes | LLM work out of scope |

**Read-out:** M1 serves five of seven. The two it does not serve are
blocked on things engineering cannot resolve.

---

## 8. Minimal roadmap

| # | Step | Scope | Schema | Gate |
|---|---|---|---|---|
| **SF2** | **`ayahId ↔ QuranAddress` conversion, with a name and tests.** One pure module; total bijection over 1…6236; round-trip asserted against the shipped database (the `basmalah_real_data_test.dart` pattern) | **S** | None | Round-trip for all 6236 āyāt; boundary cases (1, 6236, out-of-range → null, not throw) |
| **SF3** | **Adopt it at the study repository boundary**, one repository at a time, domain entities exposing `QuranAddress` instead of `int ayahId`. Storage untouched | **M** | None | Byte-identical persisted values before/after, per repository — the BM1 persistence-invariant pattern |
| **SF4** | *(Only if SF3 surfaces a real need)* `study_sessions` reads exposed as addresses, closing R2's exposure at the boundary | **S** | None | `ayah_from`/`ayah_to` unchanged on disk |
| — | **Reflection** | — | — | **Blocked on a product statement. Not scheduled.** |
| — | **`StudyItem`** | — | — | **Blocked on a second consumer. Not scheduled.** |
| — | **Flashcards** | — | — | **Blocked on the QAC answer. Not scheduled.** |

**Smallest production-ready foundation = SF2 + SF3.** Both are pure
refactors with zero migration; neither adds a capability, because the
capabilities are already there.

---

## 9. Recommendation

**Do SF2. Then do SF3 incrementally. Schedule nothing else.**

Three things the review should weigh:

1. **This sprint's premise needs correcting, and that is the most
   valuable output here.** The brief reads as though the study system
   must be designed. It is built and shipping — SM-2, review queue,
   quiz, tutor, flashcards. Treating SF as greenfield would rebuild
   working code. The real gap is one layer down and much narrower: five
   ways of naming an āyah, none of them the address type the rest of
   Phase 4 standardised on.

2. **The unification is free, and that is a measured claim.**
   `ayahs.id` is the running mushaf ordinal, not a surrogate — verified
   against the shipped database. So `ayah_id ↔ QuranAddress` is
   bijective and the whole adoption is a repository-boundary refactor
   with zero schema change and zero migration. This is the same shape as
   F0, and it succeeded there.

3. **Two of the three "missing" concepts should stay unbuilt.**
   `StudyItem` has one consumer and a Lexicon-blocked second arm.
   Reflection has no product definition, and inventing one is the single
   most likely path to an unnecessary schema change. The project already
   has precedent for refusing exactly this (`DR-2026-0006` D4 /
   `DR-2026-0007` D5), and F0 applied it correctly by shipping neither
   `Range` nor Word levels.

**One item deserves a Decision Record independent of this roadmap:
R1, the edition-scoped identifier.** Every stored `ayah_id` — bookmarks,
notes, highlights, SRS cards, khatm position — silently assumes this
build's Kufi āyah counting. Adopting `QuranAddress` does **not** fix it,
because an address is edition-scoped too. It is dormant while one
edition ships, and it becomes unrecoverable the day a second one does.
That is worth writing down before it is worth acting on.
