---
id: DR-2026-0017
scope: project
owner_role: constitution-owner
date: 2026-08-03
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: hard
threshold_reason: [materially-different-approaches, constrains-future-architecture, cross-cutting-invariant]
links:
  task: "Phase 4 — Universal Qur'an Address design"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0017 — The Universal Qur'an Address

**Status of this record: proposed, not accepted.** No production code
was written; no schema, asset, test, or CI file was changed. Same
posture as `DR-2026-0014`, `DR-2026-0015` and `DR-2026-0016`.

`owner_role` is **constitution-owner** because this record establishes a
project-wide invariant that every subsystem is required to obey — the
kind of cross-cutting constraint `PROJECT_CONSTITUTION.md` governs,
rather than a decision local to one feature. Note that milestones M0–M2
require **no schema change** and therefore do not engage `PROJ-P-002`;
M4 does, and is gated accordingly (§15).

`reversibility: hard` — once thirteen subsystems name locations the same
way, changing that naming is a coordinated migration across all of them.
M0–M2 are individually soft; the hardness begins when the address
appears in stored data (§7).

---

## Relationship to existing records

- **`ADR-0008-word-addressable-architecture.md` (draft, uncommitted,
  unaccepted)** — that draft bundled two separable decisions: *how
  locations are named* (this record) and *how word-level content and
  its licensed attachments are stored* (a distinct, dependent concern).
  This record takes the first and is deliberately narrower. **Recommendation:
  withdraw the ADR-0008 draft file** rather than file two overlapping
  records — it is uncommitted and unreferenced, so withdrawal costs
  nothing, and the project's known governance weakness is precisely
  duplicate and dangling decision identifiers
  (`PRODUCT_READINESS_REVIEW.md` §5). The word-content-architecture
  half should be re-proposed later, as a record that *depends on* this
  one.
  - One substantive correction carried forward: that draft claimed
    istiʿādhah could be modelled "for free" as another declared range.
    **That was wrong.** §10.4 explains why, and treats it as a boundary
    of this model rather than papering over it.
- **`DR-2026-0002`** (Search architecture, missing) — item 9 established
  `openAyahInReadingScreen()` as the single shared navigation contract.
  This record **preserves it unchanged** (§8, I6).
- **`DR-2026-0016`** (Lexicon morphology data source, proposed) — this
  record is **independent of its outcome by construction** (§3.5). It
  neither depends on nor supersedes it.
- **`DR-2026-0008`** (content distribution, referenced but never
  written) — unrelated in subject; noted only because the `0008`
  identifier is already in active use, which is why this record is
  `0017`.
- No existing record covers content addressing. This supersedes nothing.

---

## 1. Design goals

| # | Goal | Why it matters |
|---|---|---|
| G1 | **One naming system for every subsystem.** Reading, bookmarks, highlights, reflection, audio, word sync, Basmalah, vocabulary, flashcards, AI tutor, search, study progress, and analytics all name locations the same way. | Thirteen subsystems currently imply thirteen opportunities for identifier mismatch. §4.6 shows what each needs. |
| G2 | **Identity separate from storage.** The address is what a location *is*; a database row id is where it happens to be kept. | Lets storage evolve without touching meaning, and lets meaning cross process boundaries (sync, export, sharing, AI citation). |
| G3 | **Total, data-free operations.** Containment, comparison, parsing and serialization must be decidable without consulting any corpus, database, or network. | This is what makes the model independent of SQLite, Flutter, the backend, and every licensed dataset (§2, §3.5). |
| G4 | **Human-readable and human-writable.** `2:255` must mean what a reader already thinks it means. | Deep links, sharing, citations, and support conversations all depend on it. It is also the difference between a debuggable and an undebuggable system. |
| G5 | **Special cases become data.** Anything currently expressed as a branch on a surah number should become a declaration. | The Basmalah is the immediate case (§10); the general principle is what keeps this maintainable for a decade. |
| G6 | **Reserve room without building it.** Editions, counting traditions, and finer levels must be expressible later without re-modelling anything stored today. | Retrofitting a dimension into an identifier already present in user data is the most expensive class of migration there is. |
| G7 | **Degradation along the hierarchy, not by conditional.** When fine-grained data is missing, the system widens the address rather than branching. | §11 — graceful audio degradation becomes structural instead of a special case per missing dataset. |

## 2. Non-goals

Stated explicitly, because a model that tries to do these becomes
undesignable:

- **Not a content model.** An address names a location; it does not
  carry text, translation, meaning, timing, or audio.
- **Not a validity oracle.** The type guarantees *well-formedness*, not
  *existence* — see §3.4. `2:300` is a well-formed address and is not a
  location in the Ḥafṣ mushaf. Deciding that requires the corpus and is
  a resolution concern.
- **Not a storage schema.** §8 shows the current database already stores
  addresses under a different name; this record proposes no schema
  change to adopt them.
- **Not a query language.** Ranges express intervals, not predicates.
  "Every āyah mentioning mercy" is a search result *expressed as*
  addresses, not an address.
- **Not a linguistic model.** Nothing here knows what a root, lemma,
  or part of speech is. That independence is a requirement (§3.5), not
  an omission.
- **Not an interoperability standard.** §14 A7 explains why adopting an
  external URI scheme now would be premature.
- **Not a replacement for existing user-data keys.** §7 forbids
  migrating stored user references, deliberately.

## 3. The address model

### 3.1 Address space

An address is interpreted within an **address space**, identified by
the pair:

```
(riwāyah/edition, counting tradition)
```

Today there is exactly one: **Ḥafṣ ʿan ʿĀṣim, Kufi āyah counting,
Madani mushaf layout** — which is what `assets/database/quran.sqlite`
ships (6,236 āyāt, the Kufi count).

This is reserved and single-valued today. It is *not* speculative
generality, and §10.2 shows why it is load-bearing rather than
decorative: **which āyah the Basmalah is — or whether it is one at all —
is a property of the counting tradition, not a fact about the Qur'an.**
An addressing model that cannot say which tradition it means has
silently hard-coded one.

### 3.2 Levels

Within an address space, four levels form a strict containment chain:

```
Surah      1 … 114
 └── Ayah      1 … n     (within surah)
      └── Word      1 … n     (within āyah)
           └── Segment    1 … n     (within word)
```

**All indices are 1-based**, without exception, matching the domain's
own convention (surah 1, āyah 1).

This is not cosmetic. The current codebase mixes bases: `AudioController.currentIndex`
is a 0-based āyah index while `Ayah.ayahNumber` is 1-based, and the
highlight comparison in `reading_screen.dart` is literally
`s.currentIndex == content.ayah.ayahNumber - 1`. That `- 1` is
load-bearing in production and is the exact shape of an off-by-one
defect waiting to happen. Uniform 1-based addressing eliminates the
class by removing the conversion.

### 3.3 Identity

An address is a **value**, not an entity. Two addresses with equal
components in the same address space *are* the same address — there is
no separate notion of identity, no surrogate, no allocation, no
registry.

Consequences worth stating:

- Addresses can be constructed anywhere, including offline, including
  in a test, including by a user typing into a box.
- Equality is structural. Hashing is structural. Neither requires data.
- An address is meaningful outside the process that made it — which is
  what makes it usable for sharing, sync, export, and AI citation (§12).

### 3.4 Well-formedness vs. existence — a deliberate separation

> **The address type guarantees well-formedness. It does not guarantee
> existence.**

- **Well-formed** — correct arity, all components ≥ 1. Decidable from
  the value alone.
- **Exists** — names a real location in a given corpus. Requires the
  corpus.

`115:1` and `2:300` are well-formed and do not exist. This separation is
what preserves G3: parsing, comparing, and containment-testing never
touch data. Resolution — turning an address into content — is where the
corpus enters, and it is the only place it does.

A resolver returns an explicit "not found", exactly as any other lookup
does. This is not a weakness of the model; folding existence into the
type is the alternative rejected in §14 A8, and it would destroy the
independence the whole design rests on.

### 3.5 Independence — how it is guaranteed rather than intended

An address is: **a small tuple of positive integers plus an optional
edition identifier.** That is the whole payload. It carries no text, no
meaning, no timing, no licence.

Therefore it depends on none of:

| Must be independent from | Why it is |
|---|---|
| Lexicon, Morphology, QAC, MASAQ | An address names a *position*. Whether anything is known about the word at that position is an unrelated question, answered elsewhere. |
| Licensing | Positions are not copyrightable subject matter and carry no licensed payload. An address may be freely stored, exported, shared, and cited. |
| Database implementation, SQLite | No operation performs a lookup. Storage translates at its own boundary (§8). |
| Flutter | No widget, no `BuildContext`, no rendering concept appears in the model. |
| Backend | Addresses are computed locally and mean the same thing everywhere. |

**Acceptance criterion, stated so it can be checked mechanically:**

> The complete Address and Range model — construction, containment,
> comparison, ordering, widening, parsing, and serialization — must be
> implementable and fully testable **with no database, no asset file, no
> Flutter dependency, and no network access.**

If any of those becomes necessary, the design has been violated. This
project has direct precedent for pure-domain modules of exactly this
shape: `lib/features/quran/domain/basmalah.dart` and
`lib/features/flashcards/domain/smart_deck_selector.dart` are both
already pure, dependency-free, and tested without a container.

## 4. Hierarchy

### 4.1 Containment is prefix comparison

> `A` contains `B` **iff** they share an address space and `A`'s
> components are a prefix of `B`'s.

```
Surah(2)          contains  Ayah(2,255)        ✔ prefix
Ayah(2,255)       contains  Word(2,255,4)      ✔ prefix
Surah(2)          contains  Word(2,255,4)      ✔ prefix (transitive, and direct)
Ayah(2,255)       contains  Ayah(2,256)        ✘ not a prefix
Surah(2)          contains  Surah(2)           ✔ (containment is reflexive)
```

This is the property most of the model's value derives from. It means
"is this word inside the passage I am highlighting?" and "which āyah
does this segment belong to?" are **arithmetic on a tuple**, not
queries. The relationship can never drift out of sync with the data,
because it *is* the data.

It also means analytics aggregation (§4.6) is a prefix operation rather
than a join — "how much of Juz 30 have I read" needs no schema support
at all.

### 4.2 Widening and narrowing

- **Widen** — drop the last component. `Word(2,255,4).widen() = Ayah(2,255)`.
  **Total on every level below Surah**, and total means no conditional.
- **Narrow** — append a component. Partial: requires knowing the child
  index, which may require data.

Widening being total is what makes §11's audio degradation structural.

### 4.3 Ordering

Document order is **lexicographic on components, with the shorter
(coarser) address sorting first** when one is a prefix of the other:

```
Surah(2) < Ayah(2,1) < Word(2,1,1) < Segment(2,1,1,1) < Word(2,1,2) < Ayah(2,2)
```

This is a total order, decidable without data, and it is the order a
reader reads in. Sorting a mixed-level collection of addresses is
therefore well-defined and needs no normalization step.

### 4.4 What is deliberately **not** a level

**Juz, ḥizb, page, rukūʿ, manzil, and sajdah are not levels.** They are
Ranges (§5) — or, for sajdah, a point.

This matters more than it first appears. The `ayahs` table already
carries `juz`, `hizb`, `page`, and `sajdah` columns, which look like a
parallel hierarchy competing with surah/āyah. They are not: they are
*groupings over the same addresses*, and a grouping is an interval.

```
Juz 30    = Range(78:1  –  114:6)
Page 1    = Range(1:1   –  1:7)
Rukūʿ     = Range(…)
Sajdah    = Ayah(32:15)          — a point, not a range
```

One consequence: a mushaf **line** is also a Range (at Word level), so
line-faithful rendering needs no parallel layout model — only line
boundary data. Another: the model absorbs every existing division
without a single new concept.

### 4.5 Invariants

Numbered so a future change can be checked against them. Breaking one
is a new decision record, not a refactor.

- **I1** — Containment is prefix comparison. Never a lookup.
- **I2** — All operations are total functions on the value. They never
  consult a corpus, database, or network.
- **I3** — Indices are 1-based at every level, without exception.
- **I4** — The type guarantees well-formedness, never existence.
- **I5** — `Range` is **level-agnostic**: both endpoints share a level,
  but that level may be any level. *(This is the invariant that makes
  §10 work; see §5.2.)*
- **I6** — Existing Āyah-level APIs remain valid unchanged.
  `openAyahInReadingScreen(surahId:, ayahNumber:)` keeps working
  forever.
- **I7** — Durable stored user data is **not** migrated to addresses
  (§7). Address is the domain identity; the existing surrogate remains
  the storage key.
- **I8** — One address space today; the model reserves the dimension and
  builds no multi-edition storage.

### 4.6 One address system, thirteen subsystems

The requirement is that none of these needs its own identifier scheme.
Each row states the address level it operates at.

| Subsystem | What it names | Level |
|---|---|---|
| **Reading** | Current position; visible extent | Any level; viewport is a Range |
| **Bookmarks** | The bookmarked verse | **Āyah** (durable — §7) |
| **Highlights** | The highlighted text | Range — Āyah today, **Word later**, with no redesign |
| **Reflection** | What the note is about | Range, often spanning āyāt |
| **Audio** | Playback position; what to play | Segment ▸ Word ▸ Āyah (§11); playlist is a list of Ranges |
| **Word Sync** | Currently recited word | **Word** or **Segment** |
| **Basmalah** | The opening formula | Range — level varies by surah (§10) |
| **Vocabulary** | A word being studied | **Word** + surface form as repair key |
| **Flashcards** | The item on the card | Any level — a word, an āyah, or a Range |
| **AI Tutor** | Every citation and retrieval result | Any level; **mandatory** (§12) |
| **Search** | Hits; query scope | Āyah today, **Word later**; scope is a Range |
| **Study Progress** | What has been covered | Set of Ranges |
| **Analytics** | What an event was about | Any level; aggregation by prefix (§4.1) |

Three of these become *better*, not merely expressible: highlights gain
sub-āyah precision as a data change rather than a redesign; analytics
aggregation becomes prefix arithmetic instead of a join; and AI
citations become structurally verifiable (§12).

## 5. Range model

### 5.1 Definition

```
Range := (from: Address, to: Address)   — closed interval, inclusive
```

Both endpoints must share an address space **and a level**. A mixed-level
range (`2:255` → `3`) is rejected at construction rather than silently
normalized — implicit widening is the kind of magic that produces
defects nobody can trace.

A range may span parents freely at its own level: `2:255:5 – 2:256:3` is
a valid Word-level range crossing an āyah boundary, which is what a
reflection spanning two verses needs.

### 5.2 Level-agnostic — the load-bearing property

**I5 is the single most important design decision in this record after
prefix containment.**

`Range` is one type parameterized by nothing. An Āyah-level range and a
Word-level range have the same type. The alternative — `AyahRange` and
`WordRange` as distinct types (§14 A5) — looks tidier and is what
forces every consumer back into branching on which kind it received.

§10 is the proof: the Basmalah requires exactly one Range type that can
be Āyah-level in one surah and Word-level in another, and a renderer
that never asks which.

### 5.3 Operations

All decidable without data:

- `contains(Address)` — via ordering (§4.3)
- `overlaps(Range)`, `union`, `intersection` — interval arithmetic
- `ayahCount` — how many *complete* āyāt the range spans. Note this
  falls out of the range's level and extent; §10.3 shows it removes the
  need for a progress-counting flag entirely.

### 5.4 What a Range is not

A Range is an **interval**, not a set and not a predicate. "The 47 āyāt
I bookmarked" is a *collection of addresses*, not a range. Conflating
them would push query semantics into an identity model — §2.

## 6. Serialization

### 6.1 Grammar

```ebnf
address  ::= [ space ] surah [ ":" ayah [ ":" word [ ":" segment ] ] ]
range    ::= address "-" address
space    ::= "@" ident "/"
surah    ::= digit+          (* 1-based *)
ayah     ::= digit+          (* 1-based *)
word     ::= digit+          (* 1-based *)
segment  ::= digit+          (* 1-based *)
```

**Arity determines level.** One component is a Surah, two an Āyah, three
a Word, four a Segment. No sigil per level is needed, and none is used.

### 6.2 Examples

| Serialized | Denotes |
|---|---|
| `2` | Sūrat al-Baqarah, entire |
| `2:255` | Āyat al-Kursī |
| `2:255:4` | The 4th word of 2:255 |
| `2:255:4:2` | The 2nd timing segment of that word |
| `2:255-2:257` | Āyāt 255–257 |
| `2:255:5-2:256:3` | A Word-level range crossing an āyah boundary |
| `1:1` | Al-Fātiḥah's Basmalah (§10.2) |
| `9` | At-Tawbah — which declares no opening range at all |
| `@hafs/2:255` | Explicitly qualified; identical to `2:255` today |
| `@warsh/2:255` | A different address space — reserved, not built |

### 6.3 Design notes

- **The familiar form is the default form.** `2:255` is exactly what a
  reader already writes, and what the app should show. The edition
  prefix is optional and absent by default, so reserving that dimension
  (G6) costs today's users and today's data nothing.
- **Colon-separated word references match `corpus.quran.com`'s own
  `(2:255:4)` convention** — free interoperability with the most
  widely-cited Qur'anic reference tool, at zero design cost.
- **URL-safe as written.** Deep links, share sheets, and web routes need
  no escaping.
- **Not zero-padded, deliberately.** Padding would make text sorting
  match document order, at the cost of readability in the form users
  see most. Sort on the parsed value; keep the readable form readable.
- **Parse leniently, emit strictly.** Accept `2.255`, `2:255`, and
  surrounding whitespace on input; emit exactly one canonical form. This
  is what allows the grammar to evolve without breaking stored data.
- **Round-trip is exact and total** for every well-formed address.

## 7. Migration strategy

**Additive, staged, and reversible until stored data references
addresses.** Milestones are in §15; this section states the rules that
govern them.

**Rule 1 — Address is the domain identity; the existing surrogate stays
the storage key.** (I7)

The `ayahs` table carries both a surrogate `id` (1…6,236) and the
natural key `(surah_id, ayah_number)`. User tables reference the
surrogate. **Do not migrate them.** The surrogate is stable within a
`data_version`, the mapping is total and already implemented, and
rewriting durable user data for a representational preference is risk
with no user-visible benefit. Translate at the repository boundary and
nowhere else.

**Rule 2 — Translation happens at exactly one layer.** Repositories
accept and return addresses; storage keys never leak upward; addresses
never leak into schema. One boundary, testable in isolation.

**Rule 3 — The reversibility boundary is the first stored address.**
Through the point where addresses exist only in memory, any milestone
reverts by deleting code. Once a stored row contains an address —
vocabulary entries at Word level are the first (§15 M5) — the scheme
becomes a migration concern. This is why the frontmatter records
`reversibility: hard` and why §13 R3 exists.

**Rule 4 — Word-level references carry a repair key.** Word addresses
are *derived* from segmentation, not canonical like āyah numbers. Any
durable word-level reference stores the surface form alongside the
address: the address is authoritative, and if segmentation is ever
revised, the surface form re-anchors it. One string per vocabulary
entry, in exchange for immunity to a whole class of data loss.

## 8. Compatibility with the current database

**The current schema already stores addresses. It just does not name
them.**

| Existing | Under this record |
|---|---|
| `ayahs(surah_id, ayah_number)` | **Is an Āyah address.** No change. |
| `ayahs.id` surrogate | Remains the storage key (I7). Demoted from *identity* to *index* — a conceptual change only. |
| `bookmarks.ayah_id`, `highlights.ayah_id`, `notes.ayah_id`, `ayah_statuses.ayah_id` | Unchanged. Never migrated (Rule 1). |
| `ayahs.juz` / `hizb` / `page` / `sajdah` | Reinterpreted as **Range** boundaries and a point (§4.4). No schema change; the columns become the source data for derived ranges. |
| `search_index` (FTS5, per-āyah) | Unchanged. Results are Āyah addresses; word precision is additive later. |
| `translations` (per-āyah) | Unchanged. Keyed by an Āyah address. |
| `word_instances` (0 rows, `lexeme_id` FK) | **Not used by this model.** It is a morphology table; using it as addressing structure would couple positions to the QAC licence. Addressing is derived from text (§3.5). |
| `openAyahInReadingScreen(surahId:, ayahNumber:)` | Unchanged signature (I6). Becomes sugar over an Āyah address. |
| `AudioController` `List<Uri>`, 0-based `currentIndex` | Behaviourally unchanged; §11 replaces the index with an address, removing the `- 1`. |
| `ReadingPositionStore` (`int` per surah) | Unchanged; widens additively later. |

**Therefore: adopting this model at Surah and Āyah level requires no
schema change at all** — which is why M0–M2 do not engage `PROJ-P-002`.
Word and Segment levels need new data, additively, at M4.

## 9. Compatibility with a future Word architecture

This record deliberately stops at *naming*. A future record covering
word-level content storage and its licensed attachments must satisfy:

- **Positions are derived from the shipped Uthmani text**, never from a
  licensed dataset. Word segmentation is `split on whitespace` over text
  already licensed for verbatim distribution — the same operation
  `basmalah.dart` already performs. (Measured: 77,881 space-separated
  tokens across 6,236 āyāt.)
- **Anything semantic hangs off an address as an optional attachment** —
  transliteration, translation, timing, tajwīd, morphology. Absence is a
  normal state, never an error, and (per the R3b honesty line) an absent
  attachment yields an absent affordance rather than a broken one.
- **No attachment may become a construction-time requirement of an
  address.** This is what keeps word-level interaction independent of
  `DR-2026-0016`'s outcome: if morphology is never licensed, one
  attachment stays empty and nothing else changes.

Nothing in that list is decided here. It is stated so the boundary
between the two records is unambiguous.

## 10. Basmalah integration

### 10.1 What is wrong today

`lib/features/quran/domain/basmalah.dart` encodes three constants and
two conditionals, consulted by every rendering path:

```
surahHasLeadingBasmalah(id) => id != 1 && id != 9    // two hardcoded exceptions
_basmalahWordCount = 4                                // magic number
splitLeadingBasmalah(text)                            // cut at the 4th space
ayahDisplayText(...)                                  // conditional on ayahNumber == 1
```

Every one of `1`, `9`, and `4` is a fact about the *edition* that has
been compiled into *logic*.

### 10.2 Why "Al-Fātiḥah is special" is not a Qur'anic fact

The reason Al-Fātiḥah's Basmalah is āyah 1 in this app is that the app
ships **Kufi āyah counting** (Ḥafṣ). Under other recognized counting
traditions it is not counted as a separate āyah and Al-Fātiḥah's seven
āyāt are divided differently.

So `id != 1` is not encoding a property of the Qur'an. It is encoding
*"this build ships Kufi counting"* — an address-space property (§3.1) —
as an inline integer comparison in a rendering helper.

That is the real defect, and it is why the fix is not "move the constant
somewhere nicer" but "let the address space declare it."

### 10.3 The representation

A surah declares its **opening range**: zero or one Range with
`role: basmalah`. The renderer requests it and renders whatever it
receives.

| Surah | Declared opening range | Level | Renders | Complete āyāt in range |
|---|---|---|---|---|
| **Al-Fātiḥah (1)** | `Range(1:1 – 1:1)` | **Āyah** | Yes — it *is* āyah 1 | **1** |
| **2–8, 10–114** | `Range(s:1:1 – s:1:4)` | **Word** | Yes — a distinct opening element | **0** |
| **At-Tawbah (9)** | *(none — empty)* | — | Nothing | 0 |

**No branch on surah number. No magic `4`. No `!= 1 && != 9`.** The
renderer's entire logic is: *render the declared opening ranges, of
which there are zero or one.*

**Why this works is I5.** The Al-Fātiḥah case is an Āyah-level range and
every other case is a Word-level range — and both are the same type,
because `Range` is level-agnostic. Had ranges been typed by level
(§14 A5), the renderer would need to know which kind it got, and the
special case would have survived under a new name.

**Progress counting needs no flag.** In the ADR-0008 draft I proposed a
`countsTowardProgress` property. It is unnecessary: the correct count
falls out of the range's own level and extent (§5.3). Reciting
Al-Fātiḥah's Basmalah completes one āyah because the range *is* an āyah;
reciting sūrat al-Baqarah's Basmalah completes none because a
four-word range contains no complete āyah. When a model is right,
special cases stop needing special properties — that this flag became
unnecessary is evidence the model is right, and it is worth keeping as a
review heuristic.

### 10.4 An honest boundary — istiʿādhah does **not** fit, and should not be forced to

The ADR-0008 draft claimed istiʿādhah (*aʿūdhu billāhi min ash-shayṭān
ir-rajīm*) would come "for free" as another declared range. **That was
wrong, and the correction is worth recording.**

The istiʿādhah is **not Qur'anic text.** It is said before recitation
but is not part of the revelation. It therefore has **no address** —
there is no position in the Qur'an it names, and no Range can denote it.

Forcing it into this model would mean inventing addresses for text
outside the corpus, which corrupts the one thing an address means. The
correct treatment is a **non-textual audio/ritual element**, handled by
the playback layer, with no address at all.

Stating this is not a gap in the model — it is the model having a
boundary and the boundary being drawn honestly. A design that appears to
accommodate everything usually means the concepts have gone soft.

## 11. Audio synchronization

### 11.1 Position is an address, at whatever precision exists

```
Segment  ▸  Word  ▸  Āyah
  finest        available      always
```

Because **widening is total** (§4.2), degradation is structural rather
than conditional: the player publishes the finest address for which it
has data, and consumers widen as needed. If a reciter has no word
timing, the position is simply an Āyah address, and every consumer
continues to work — including the highlight, which today already works
at that granularity.

There is no "if timing data exists" branch anywhere in the consuming
code. That is G7.

### 11.2 What replaces the current index

The current comparison —

```
s.currentIndex == content.ayah.ayahNumber - 1
```

— compares a 0-based playlist index against a 1-based āyah number. It is
correct today and is a defect waiting for its first off-by-one.

Under this record it becomes a containment test between two addresses:
*does the currently-playing address fall within this āyah?* Both sides
are addresses; the arithmetic and the base mismatch both disappear
(I3, §4.1).

### 11.3 Playlists are Ranges, not URIs

A playlist becomes an ordered list of Ranges. Resolving a Range to bytes
is the audio layer's job and depends on the reciter. The current
`List<Uri>` is the degenerate case: one Āyah-level Range per entry,
resolved to one file each.

This is what makes the memorization primitives expressible without new
concepts — an A–B loop is a Range; "repeat this phrase" is a Word-level
Range; "repeat this āyah" is an Āyah-level Range. One mechanism.

### 11.4 Three positions, not one

Audio position, reading position, and study position become **three
independent addresses** rather than one shared index.

That separation is what fixes the behaviour where auto-scroll drags a
reader back to the recited āyah while they are reading ahead. They are
different values because they are different things; today they are the
same integer because there was only one way to say where anything was.

## 12. Future AI integration

The address is what makes a grounded AI feature *architecturally*
safe rather than safe by prompt discipline.

**Every AI-produced claim must carry an Address or Range.** That single
constraint gives:

- **Verifiability** — a citation resolves to text the user can read, or
  it does not resolve, and the failure is mechanical rather than
  subtle.
- **Falsifiability** — an ungrounded assertion is detectable, because it
  has no address.
- **The retrieval boundary** — retrieval returns addresses; presentation
  resolves them. A model that cannot produce an address for a claim has
  no grounding, and the type system says so.

`QURAN_COMPANION_PRODUCT_VISION.md` §5 states the constraint that any
assisted-study feature must be *retrieval with mandatory attribution,
never composition* — because a model that paraphrases scripture or
answers "what does this āyah mean" is generating tafsīr. Without an
address type, that is a policy someone must remember. With one, the
citation has a type, and an uncited claim is a type error rather than an
oversight.

Scope note: nothing about AI is decided here. This section exists
because the addressing decision has to be made *before* the AI feature,
not after — retrofitting citability is far harder than designing for it.

## 13. Risks

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| **R1** | **Over-modelling.** Four levels plus ranges is real conceptual machinery for a product whose most-felt defect is that audio stops when backgrounded. | **High** | M0–M2 are pure refactors with immediate payoff (Basmalah, the audio index). Nothing past M3 ships before a surface needs it. If beta feedback redirects priorities, this stops at M2 and loses nothing. |
| **R2** | **The counting tradition is baked in anyway** — reserving the dimension does not populate it, and an implementer may still assume Kufi. | Medium | §3.1 makes the assumption explicit and named. An assumption that is written down is a different risk from one that is not. |
| **R3** | **Segmentation instability** — word addresses are derived, so a corrected segmenter invalidates stored word references. | Medium | Durable data anchors at Āyah (Rule 1); word-level references carry a surface-form repair key (Rule 4). |
| **R4** | **Serialization lock-in** — the text form appears in deep links and shared citations, which are outside our control once emitted. | Medium | Grammar is fixed and minimal; parse leniently, emit strictly (§6.3); the edition prefix is the designed extension point. |
| **R5** | **Solo maintainer, conceptual overhead** — this vocabulary must be held by one person across years. | Medium | Invariants are numbered and checkable (§4.5); §10.3's flag-removal is recorded as a review heuristic. |
| **R6** | **Temptation to migrate stored user data to addresses** for consistency's sake. | **High** | Forbidden by I7 and Rule 1, with the reasoning recorded so it does not have to be re-litigated. |
| **R7** | **A future need for a level below Segment** (letter-level tajwīd rules). | Low | The arity-based grammar (§6.1) extends by one component without changing anything already emitted. |

## 14. Alternatives rejected

**A1 — Keep surrogate integer ids everywhere (status quo).**
*Pro*: zero work. *Con*: no hierarchy, no containment, no ranges, not
human-readable, not portable across processes, and edition-dependent
without saying so. **Rejected** — it cannot express the majority of §4.6.

**A2 — Opaque string ids or UUIDs per node.**
*Pro*: stable and unambiguous. *Con*: no order, no containment, no
readability; `2:255` becomes something no human can write or verify.
**Rejected** — sacrifices G4 and G1 for a stability the tuple already
has.

**A3 — Byte or character offsets into the text.**
*Pro*: maximal precision. *Con*: breaks on any text revision, any
normalization change, any encoding change; unreadable; and it couples
identity to a specific rendering of the text. **Rejected.**

**A4 — Level-typed addresses** (`SurahRef`, `AyahRef`, `WordRef` with no
common supertype).
*Pro*: the compiler prevents mixing levels. *Con*: every consumer must
branch on which type it received; ordering across levels becomes
undefined; §4.6's "any level" rows become impossible. **Rejected** —
it trades one class of error for pervasive branching.

**A5 — Level-typed ranges** (`AyahRange` vs `WordRange`).
*Pro*: same appeal as A4. *Con*: **directly destroys §10.** The Basmalah
requires one range type that is Āyah-level in one surah and Word-level
in another, with a renderer that never asks which. **Rejected** — this
is the alternative whose rejection I5 exists to record.

**A6 — Make Segment a level *above* Word, meaning "a span of words."**
*Pro*: matches the intuition that phrases feel like a level. *Con*:
conflates composition with selection. A word would belong to a phrase
*and* a line *and* a rukūʿ at once — no longer a containment tree, and
I1 is lost. **Rejected** in favour of Segment as the finest slice plus
Range as an orthogonal selection concept, which delivers what A6 wanted
without breaking the tree (§4.4).

**A7 — Adopt an external Qur'anic URI standard now.**
*Pro*: interoperability. *Con*: no standard has meaningful adoption, and
per `DATA_OS_ARCHITECTURE.md` §9, designing for an unspecified external
consumer produces abstractions that fit nothing. **Deferred with a
hedge** — §6 is already URI-shaped and colon-compatible with
`corpus.quran.com`, so adopting a standard later is a formatting change
rather than a re-modelling.

**A8 — Fold existence checking into the address type** (make
construction fail for `2:300`).
*Pro*: illegal states unrepresentable. *Con*: construction now requires
the corpus, which destroys G3 and every independence guarantee in §3.5 —
no parsing without a database, no tests without an asset, no addresses
in a backend that has no corpus. **Rejected**; well-formedness and
existence are separated instead (§3.4).

**A9 — Defer all of this until after Public Beta.**
*Pro*: focuses scarce capacity on shipping. *Con*: three subsystems
(audio position, highlight sync, reading position) are actively
accumulating index-based assumptions that get more expensive to unwind
each sprint, and §12 shows citability cannot be retrofitted cheaply.
**Rejected as a whole, partially adopted**: §15 sequences M0–M2 as small
and immediately useful, and explicitly permits stopping there until
after beta.

## 15. Milestones

| # | Milestone | Schema change | Reversible | Gate |
|---|---|---|---|---|
| **M0** | `Address` + `Range` as pure domain values: construction, containment, ordering, widening, parse, serialize. **Zero consumers.** | No | Yes | Unit tests only; must pass §3.5's no-database/no-Flutter criterion |
| **M1** | Repository boundary translates surrogate ↔ Address (Rule 2). Internal only; no behaviour change. | No | Yes | Existing tests pass unmodified |
| **M2** | **Basmalah declaration replaces the hardcoded logic** (§10). Behaviour-identical. | No | Yes | **Golden test: render all 114 surahs before and after; assert byte-identical output.** Non-negotiable. |
| **M3** | Audio position becomes Address-typed; the 0-/1-based mismatch is removed (§11.2). | No | Yes | Audio regression suite |
| **M4** | Word segmentation data; Word/Segment addresses resolvable. | **Yes** | Migration | **`PROJ-P-002` sign-off required** |
| **M5** | Word-level addressing in UI and vocabulary storage. **First stored word address** — reversibility boundary (Rule 3). | Yes | Migration | R3b honesty line: no affordance without data |
| **M6** | AI citation type (§12) — only when an assisted-study surface exists. | No | Yes | — |

**M0–M2 are the recommended immediate scope.** They require no schema
change, are individually reversible, and deliver the Basmalah cleanup
and the audio-index correction — both of which are real defect-class
removals rather than speculative groundwork.

**M2's golden test is the single most important acceptance criterion
here.** It is the only mechanical proof that a change touching every
reading surface preserved behaviour exactly — the same discipline Sprint
R3b applied when it required every removed test to be traced to a
removed control.

## 16. Decision recommendation

**Recommended: accept.**

The reasoning in one paragraph: the application already has an
addressing model — it is simply implicit, inconsistent, and duplicated
across three subsystems with two different index bases and three
hardcoded surah numbers. This record does not add a concept; it names
one that exists, makes it uniform, and removes the special cases that
exist only because it was never named. The immediate scope (M0–M2)
changes no schema, is fully reversible, and pays for itself by deleting
the Basmalah branching and the 0-/1-based mismatch.

Specifically, the `owner_role` is asked to:

1. **Accept the model** (§3–§6) and the eight invariants (§4.5).
2. **Authorize M0–M2** — no schema change, no `PROJ-P-002` engagement,
   immediate payoff.
3. **Hold M4 and M5** pending explicit `PROJ-P-002` sign-off, per the
   gate in §15.
4. **Withdraw the uncommitted `ADR-0008` draft** rather than file two
   overlapping records, and re-propose its word-content-architecture
   half later as a record depending on this one.
5. **Note the §10.4 correction** — istiʿādhah is not representable in
   this model and should not be forced into it.

**Deferral is a legitimate outcome.** If Public Beta capacity is the
binding constraint, accepting the model while authorizing only M0 —
pure domain types, no consumers — preserves every option at almost no
cost, and M1–M2 can follow whenever the reading engine is next touched.

---

DR-2026-0017 — proposed, not accepted. No production code written; no
change to `lib/`, `test/`, `assets/`, database schema, or CI.
