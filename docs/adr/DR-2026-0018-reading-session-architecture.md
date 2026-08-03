---
id: DR-2026-0018
scope: project
owner_role: constitution-owner
date: 2026-08-03
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [materially-different-approaches, constrains-future-architecture, cross-cutting-invariant]
links:
  task: "Phase 4 — Reading Session architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0018 — Reading Session architecture

**Status of this record: proposed, not accepted.** No production code
was written; no change to `lib/`, `test/`, `assets/`, database schema,
or CI.

`owner_role` is **constitution-owner** because this record establishes
a layering rule every future feature must obey — a cross-cutting
invariant rather than a decision local to one screen.

`reversibility: soft`, and stated accurately rather than copied from
`DR-2026-0017`: this record proposes **no schema change and no new
stored format**. Sessions persist to the existing `study_sessions`
table; context persists to the existing preference store. It is code
structure, revertible by refactoring, with no data migration. The
hardness in `DR-2026-0017` came from addresses appearing in stored
data; nothing here adds that.

---

## Relationship to existing records

- **`DR-2026-0017`** (Universal Qur'an Address, proposed) — this record
  **depends on it entirely** and adds nothing to it. Every position,
  target, anchor, and citation below is an `Address` or `Range` as
  defined there. If 0017 is not accepted, this record has no
  foundation and should be withdrawn with it. Milestone dependencies
  are made explicit in §12.
- **`DR-2026-0002`** (Search architecture, missing) — item 9's shared
  navigation contract `openAyahInReadingScreen()` is preserved
  unchanged; §12 S1 re-homes it as a Context operation without altering
  its signature.
- **`DR-2026-0005`** (Learning Engine) — the SRS scheduler is a
  *consumer* of this layer, not a participant in it. §9 shows how study
  attaches without the session knowing about SM-2.
- **`ADR-0008` draft** — recommended for withdrawal in `DR-2026-0017`;
  unaffected by this record either way.
- No existing record covers interaction state. This supersedes nothing.

---

## 1. Motivation

### 1.1 There is no session today — there are seven places state hides

"What the user is currently doing" is not represented anywhere in the
application. It is inferred, at render time, from state scattered across
seven mechanisms with four different lifetimes:

| Where | What it holds | Lifetime |
|---|---|---|
| `_ReadingScreenState._focusMode` | Chrome visibility | Widget |
| `_itemScrollController` | Scroll offset | Widget |
| `readingSettingsProvider` | Mode, Arabic scale, translation layers | Process + prefs |
| `ReadingPositionStore` | `reading.pos.$surahId` → int; last surah; recent 6 | Prefs |
| `audioControllerProvider` | `surahId` + 0-based `currentIndex`, playing, speed, repeat | Process |
| `ayahAnnotationsProvider(surahId)` | Bookmarks/highlights/notes/status | Database |
| `StudySessionRepository.logSession()` | Duration + range, on screen exit ≥ 5s | Database |

Consequences that follow directly from this scattering:

- **Position is expressed three incompatible ways.** An `int` per surah
  in preferences, a 0-based `currentIndex` in audio, and a 1-based
  `ayahNumber` in content — reconciled by the literal expression
  `s.currentIndex == content.ayah.ayahNumber - 1`.
- **Audio position and reading position are the same value**, which is
  why the screen drags a reader back to the recited āyah when they read
  ahead to check a translation.
- **A session's boundary is "leaving a screen."** Not attention, not
  activity — screen lifecycle, which is a poor proxy for either.
- **There is nowhere to put the next eight features.** Selection,
  reflection anchoring, word-level playback, vocabulary capture, and AI
  citation each need "the thing the user is currently acting on," and
  each would invent its own.

### 1.2 The real risk this record exists to prevent

The predictable failure mode is not that the app breaks. It is that
`ReadingScreen` and `AudioState` accumulate one field per feature until
they are god-objects that nobody can change safely — the exact shape of
decay that `PRODUCT_READINESS_REVIEW.md` found in the *surface* layer
and Sprint R3b spent four sub-sprints removing.

This record's primary output is therefore not a set of types. It is a
**rule for where new state is allowed to go** (§4, §10), and a
**mechanical test for whether a feature is being modelled correctly**
(§10.1).

## 2. Design goals

| # | Goal |
|---|---|
| G1 | **One representation of "what the user is doing."** Not seven. |
| G2 | **Strict one-directional layering** — Presentation → Interaction → Content, never upward, never skipping. |
| G3 | **Every position, anchor and target is an Address or Range** (`DR-2026-0017`). No surrogate storage keys above the Content Layer. |
| G4 | **State classified by consequence of loss**, not by where it happens to be convenient to store. |
| G5 | **New features add no fields to core session types** — they add roles, levels, annotation kinds, or projections (§10.1). |
| G6 | **Recovery is total.** No stored state may fail to restore. |
| G7 | **Offline is the only path.** No session operation may require the network — including AI. |

## 3. Non-goals

- **Not a UI specification.** Nothing here decides what anything looks
  like or how it animates.
- **Not a storage design.** Persistence targets that already exist
  (§8); no schema is proposed.
- **Not a sync implementation.** §11 states the *semantics* sync must
  respect. It builds nothing.
- **Not a replacement for the Learning Engine.** SRS remains
  `DR-2026-0005`'s; §9 shows the attachment point only.
- **Not a rewrite of `ReadingScreen`.** §12 is deliberately incremental
  and behaviour-preserving.

## 4. The three layers

### 4.1 Content Layer — *what is true*

Two stores with different ownership, one shared access idiom.

| Store | Contents | Mutability | Ownership |
|---|---|---|---|
| **Corpus** | Text, translations, timing, page/juz metadata | Immutable; versioned by `data_version` | Licensed, shipped |
| **Annotations** | Bookmarks, highlights, notes, reflections, status | Mutable | The user's, entirely |

Both are **addressed**: everything is retrieved by `Address` or `Range`.
The distinction between licensed corpus and user annotation matters for
licensing, export, and sync — and is **invisible to the layer above**,
which asks only "what is at this address."

- **Knows**: Addresses, Ranges, storage.
- **Must not know**: sessions, selections, focus, playback, widgets.
- **Owns the only translation** between an Address and a storage key
  (`DR-2026-0017` Rule 2). Surrogate ids exist here and nowhere else.

### 4.2 Interaction Layer — *what is happening*

Owns `ReadingSession`, `ReadingContext`, `Selection`, `Focus`,
`Playback`, and navigation `History`. This layer *is* the product's
behaviour.

- **Knows**: Addresses, Ranges, and the Content Layer's query surface.
- **Must not know**: widgets, pixels, scroll offsets, `BuildContext`,
  animation, or any surrogate identifier.
- **Testable with no Flutter and no database**, by construction — the
  same criterion `DR-2026-0017` §3.5 sets for the address model, and
  the same one `smart_deck_selector.dart` already meets today.

### 4.3 Presentation Layer — *what is shown*

Owns rendering, scroll offsets, gestures, animation, text scaling, and
chrome visibility — including today's "focus mode," which is a chrome
concern and **not** the `Focus` of §6.3.

- **Knows**: Interaction Layer state, and Content only through
  projections the Interaction Layer defines (§4.4).
- **Must not know**: storage, or how an address becomes a row.
- **Fully derivable and disposable.** Losing this layer entirely loses
  no user data and no user intent.

### 4.4 The dependency rule

```
   Presentation  ──▶  Interaction  ──▶  Content
        │                                  ▲
        └──── projections (read-only) ─────┘
```

Downward only. Presentation never queries Content directly; it consumes
**projections** — read-only, derived views over an address range that
the Interaction Layer defines and never stores. This is what keeps
scroll position out of the session and session state out of widgets.

**A projection is derived, never cached as truth.** There is no
projection invalidation problem because there is no projection state.

## 5. ReadingContext and ReadingSession — why both

These two are frequently conflated, and conflating them is what makes
resume, analytics, and sync all awkward at once.

|  | **ReadingContext** | **ReadingSession** |
|---|---|---|
| **Is** | A *point* — where and how the user is reading | An *interval* — a bounded episode of activity |
| **Cardinality** | Exactly one, always | Many, over time |
| **Lifetime** | Continuous; survives forever | Starts, ends, becomes history |
| **Answers** | "Where do I resume?" | "What did I do, and for how long?" |
| **Durability** | Resumable (§8) | Durable (§8) |
| **Feeds** | Recovery, "continue reading" | Streaks, analytics, study logs |

**ReadingContext** — the resumable frame:

```
position   : Address        — where; any level (DR-2026-0017 §4.2)
mode       : ReadingMode    — flow | mushaf | focus
layers     : TextLayers     — which translation/transliteration layers are on
reciter    : ReciterRef?    — preference, not playback state
intent     : Intent         — reading | listening | memorizing | studying
```

**ReadingSession** — the episode:

```
startedAt    : Instant
endedAt      : Instant?
contextStart : ReadingContext      — snapshot
contextEnd   : ReadingContext?     — snapshot
coverage     : RangeSet            — what was actually covered
endedBy      : timeout | explicit | recovered
```

`intent` sitting in Context rather than Session is deliberate: intent
changes *during* an episode (you start reading, then begin memorizing)
and the session should record that it happened rather than force an
artificial boundary.

`coverage` as a **RangeSet** rather than a start/end pair is also
deliberate: real reading is not contiguous. A user who reads 2:1–2:20,
jumps to 2:255, then returns has covered two ranges, and recording it as
"2:1–2:255" would be a fiction that inflates every statistic derived
from it.

## 6. The interaction primitives

### 6.1 Selection — the input to every creative action

```
Selection = Range?      — transient, never persisted
```

**One selection concept serves every action that creates something**:
highlight it, note it, reflect on it, add it to vocabulary, loop it in
audio, ask the tutor about it, share it.

This is the single largest simplification in this record. Without it,
each of those seven features carries its own "which āyah is this
about?" state, and they drift. With it, an action is a function of the
current Selection, and Selection is a `Range` — which is level-agnostic
(`DR-2026-0017` I5), so the same selection concept works at word level
the day word data exists, with no new type.

### 6.2 Three independent positions

`DR-2026-0017` §11.4 identified that audio position, reading position,
and selection are three different things represented today by one
integer. This layer gives each a home:

| Position | Owner | Meaning |
|---|---|---|
| `Playback.position` | Playback | What is being recited |
| `Focus` | Focus | Where the user's attention is |
| `Selection` | Selection | What has been deliberately picked out |

They are independent values because they are independent facts. A user
listening to 2:10 while reading 2:12 and having selected 2:8:3–2:8:6 is
a normal, currently unrepresentable state.

**Auto-scroll becomes advisory rather than coercive**: when
`Playback.position` and `Focus` diverge because the user moved, the app
offers to re-sync instead of forcing it. That behaviour is a *policy over
two values*, which is only expressible once there are two values.

### 6.3 Focus — attention, not chrome

```
Focus = Address         — transient
```

The current `_focusMode` boolean is **not** this. That is chrome
visibility and belongs to Presentation (§4.3). `Focus` here is the
attention target that keyboard navigation, screen-reader traversal, and
"jump to playing" all act on.

Separating them resolves a genuine ambiguity in the current code, where
one word names two unrelated things.

### 6.4 Playback

```
position : Address       — Segment ▸ Word ▸ Āyah, finest available
playing  : bool
reciter  : ReciterRef
speed    : Rate
repeat   : RepeatMode
loop     : Range?        — A–B loop; a Range, so any level
```

Position degrades **by widening** (`DR-2026-0017` §4.2), which is total —
so there is no "if word timing exists" branch in any consumer. The
`loop` being a `Range` is what makes "repeat this āyah" and "repeat this
phrase" the same feature at two levels.

### 6.5 Annotations — Highlight, Note, Reflection, Bookmark

All four are **Range-anchored durable annotations** in the Content
Layer. They are listed separately in the requirements and are *not* four
subsystems:

| Kind | Anchor | Payload | Note |
|---|---|---|---|
| **Bookmark** | Address (**Āyah or coarser**) | Collection ref? | Durability rule, §8 |
| **Highlight** | Range | Colour | Gains sub-āyah precision as data, not redesign |
| **Note** | Range | Text | The neutral container |
| **Reflection** | Range | Text + prompt + review schedule | **A Note with `role: reflection`** |

**Reflection is a role on Note, not a parallel system.** Building them
as two stores is the classic mistake that produces two search paths, two
export paths, two sync paths, and two sets of drift. One store,
discriminated by role.

Bookmarks anchor at Āyah or coarser per `DR-2026-0017`'s durability
rule (I3/I7): āyah numbers are canonical and permanent, word indices are
derived. Highlights and notes may anchor at word level once word data
exists, because they carry the surface-form repair key that rule
prescribes.

### 6.6 History — two different things

| Kind | Contents | Lifetime | Powers |
|---|---|---|---|
| **Navigation history** | Stack of Addresses | Session-scoped, ephemeral | Back/forward |
| **Session history** | Completed Sessions | Durable | Streaks, analytics, "continue reading", recent surahs |

Today's `reading.recent_surahs` (a preferences list, max 6) is a
degenerate, hand-maintained session history. It should be **derived**
from session history rather than separately stored — one fewer source of
truth to drift (§12 S5).

## 7. Session lifecycle

```
        ┌────────── engage ──────────┐
        ▼                            │
     ACTIVE ──── inactivity ────▶ ENDED ──▶ history
        │            timeout         ▲
        │                            │
        └──── explicit stop ─────────┘

   (app background does NOT end a session — see below)
```

**A session is bounded by attention, not by app lifecycle.** This is the
central lifecycle decision, and it corrects the current model:

- Backgrounding to answer a message must not end a session.
- Putting the phone down for two hours must.
- **Playback extends a session while backgrounded** — listening is
  activity. Once background audio ships (Phase 4), a session that ends
  because the screen turned off would be simply wrong.
- Passive listening is recorded as a session with `intent: listening`,
  distinguishable in analytics. That is more honest than either counting
  it as reading or discarding it.

A session **starts on engagement, not on render.** Cold-launching to a
restored context is not a session; scrolling, playing, or selecting is.
Otherwise every app open inflates the streak.

The existing `logSession()` ≥ 5-second threshold survives as a
**minimum-duration filter on session close**, not as a trigger. Sessions
below it are discarded rather than recorded.

## 8. Persistence — classified by consequence of loss

The classification rule, stated so it can be applied to future state
without re-deciding: **classify by what the user loses, not by what is
convenient to store.**

| Class | What | Persisted | Loss costs the user |
|---|---|---|---|
| **Ephemeral** | Selection, Focus, navigation stack, scroll offset, projections | **Never** | A re-selection. Trivial. |
| **Resumable** | `ReadingContext` | Eagerly, debounced, written whole | A re-navigation. Annoying. |
| **Durable** | Annotations; completed Sessions | Immediately on creation | **Their own work. Unacceptable.** |

Two rules follow:

- **Resumable state is written whole, never partially.** A context is a
  value; a half-written context is a corrupt one. This makes recovery
  total (§8.1) rather than defensive.
- **Durable writes are never batched behind a session boundary.** A note
  is safe the moment it is written, not when the session ends.

Both classes persist to mechanisms that **already exist**:
`ReadingContext` to the preference store that holds
`ReadingPositionStore` today; Sessions to the existing `study_sessions`
table, whose (date, surah, āyah range, duration) shape a Session already
satisfies. **No schema change is proposed.**

### 8.1 Recovery is total — and reuses `widen()`

> There must be no stored state that fails to restore.

The interesting case is a stored `Address` that no longer resolves —
after a `data_version` change, or eventually an edition change. The
resolution is **widening** (`DR-2026-0017` §4.2), which is a *total*
operation:

```
Word(2,255,4)  →  Ayah(2,255)  →  Surah(2)  →  (no position)
```

Widen until it resolves. Worst case, the user lands at the start of the
surah they were in; never an error, never an empty screen, never a crash.

This is the same mechanism §6.4 uses for audio degradation. **Two
unrelated problems — missing timing data and unresolvable stored state —
solved by one total operation.** That reuse is evidence the address
model underneath is the right shape; a model that needed two different
fallback mechanisms here would be suspect.

### 8.2 Crash recovery of an in-flight session

A session with a start and no end, found at launch, is **closed at the
last persisted context timestamp** and marked `endedBy: recovered`.

Not discarded — that loses real activity. Not closed at launch time —
that credits hours the user was asleep. The last known context write is
the most defensible estimate available, and the marker makes it
auditable rather than silently mixed into statistics.

## 9. How eight future features attach without changing the core

This is the requirement's central test. Each row states **what changes**
and confirms **what does not**.

| Feature | What it adds | Core model change |
|---|---|---|
| **Basmalah 2.0** | A declared opening `Range` (`DR-2026-0017` §10), rendered by Presentation; excluded from `coverage` because a Word-level range contains no complete āyah | **None** — `Range` is already level-agnostic |
| **Word Audio** | `Playback.position` resolves at Segment/Word instead of Āyah | **None** — position is already an Address; widening already total |
| **Word Highlight** | Highlight anchors at a Word-level `Range` | **None** — annotations already Range-anchored |
| **Word Translation** | A new *projection* at Word level | **None** — projections are already derived over addresses |
| **Reflection** | `role: reflection` on Note + a review schedule | **None** — Note already Range-anchored (§6.5) |
| **Study** | `intent: studying` on Context; SRS reads annotations by address | **None** — intent already in Context |
| **AI Tutor** | Consumes `Selection`, emits `Range` citations | **None** — Address is already the citation type (`DR-2026-0017` §12) |
| **Vocabulary** | `Selection` at Word level → capture with surface-form repair key | **None** — Selection is already a `Range` |

**Every one is a change of *level* or *role*, never a change of *type*.**
That is what "without changing the core model" means, and it is
demonstrated here rather than asserted.

Note in particular that the **AI Tutor and SRS are consumers, not
participants.** The session does not know what SM-2 is, and does not
know a language model exists. It offers `Selection` and annotations
addressed by `Range`; what reads them is not its concern. That is the
boundary that keeps `DR-2026-0005`'s learning engine and any future
assisted-study feature from leaking into the reading layer.

## 10. Maintainability

### 10.1 The Closure Test

> **A new feature that requires a new field on `ReadingSession` or
> `ReadingContext` has been modelled at the wrong level.**

It should instead be expressible as:

1. a new **role** on an existing annotation kind, or
2. a new **level** of an existing Address/Range, or
3. a new **annotation kind** in the Content Layer, or
4. a new **projection** in the Presentation boundary.

All eight features in §9 pass. This is the mechanical guard against the
god-object decay described in §1.2, and it is cheap to apply: it is a
question asked at design review, answerable in one sentence.

A feature that genuinely fails the test is not forbidden — it is a
signal that this record needs amending, which is a decision-record
event rather than a quiet field addition.

### 10.2 Invariants

- **J1** — Dependencies run Presentation → Interaction → Content only.
  Never upward, never skipping (§4.4).
- **J2** — No surrogate storage key appears above the Content Layer.
  *(Canonical position numbers inside an Address are not surrogate keys
  — see §10.3.)*
- **J3** — Every position, anchor, and target is an `Address` or
  `Range`.
- **J4** — The Interaction Layer is testable with no Flutter, no
  database, no network.
- **J5** — State is classified by consequence of loss (§8), and every
  new piece of state must be placed in one of the three classes
  explicitly.
- **J6** — Recovery is total; unresolvable addresses widen (§8.1).
- **J7** — No session operation requires the network (§11.3).
- **J8** — Projections are derived, never stored as truth (§4.4).

### 10.3 What "never reference SQLite IDs" precisely forbids

The prohibition is on **surrogate storage keys**, not on canonical
position numbers.

- **Forbidden above the Content Layer**: `ayahs.id` (1…6,236),
  `bookmarks.id`, any row identifier.
- **Not forbidden**: the integers *inside* an Address — `Address(2, 255)`
  contains the surah and āyah numbers, which are canonical, permanent,
  and part of the domain's own vocabulary. They are not database keys
  that happen to be visible; they are the names of the locations.

Stating this distinction matters because the rule is otherwise easy to
misapply into "no integers anywhere," which would be both impossible and
pointless.

## 11. Sync and offline

### 11.1 The three classes have three different sync semantics

Applying one strategy to all state is the standard way sync loses data.

| Class | Strategy | Rationale |
|---|---|---|
| **Ephemeral** | **Never syncs** | A selection on another device is meaningless |
| **Resumable** (Context) | **Last-writer-wins, and advisory** | You want your newest position; a "conflict" between two devices is not a conflict, it is a sequence |
| **Durable — annotations** | **Merge, never overwrite** | Losing a note because another device wrote later is data loss, not conflict resolution |
| **Durable — sessions** | **Append-only; cannot conflict** | Two devices produce two records. There is nothing to merge. |

Sessions being append-only immutable records is worth stating
explicitly: it is the easiest possible sync case, and recognising it
avoids inventing a merge strategy for something that never needs one.

The existing `SyncColumns` mixin (`id`/`userId`/`updatedAt`/`deletedAt`/
`isDirty`) already supports the annotation case. Context needs different
handling — a single last-writer-wins value, not a merged collection.

### 11.2 Context sync must be advisory, never coercive

A device that silently adopts another device's position **can move a
reader mid-āyah.** Correct behaviour is to *offer*: "continue from where
you left off on your phone?" — a prompt, not a jump.

This is a small design decision with an outsized effect on whether sync
feels like a service or a hazard.

### 11.3 Offline is the only path

**Local is authoritative, always.** Sync is eventual reconciliation and
is never on a read path or a write path. No session operation may block
on the network (J7) — including the AI tutor, which must degrade to
*unavailable* rather than to *waiting*.

This preserves the product's stated position (`QURAN_COMPANION_PRODUCT_VISION.md`
§3): the privacy claim is structurally true because there is nowhere for
data to go, and that remains true only if no code path assumes there is.

## 12. Migration

Additive, behaviour-preserving, and each step independently shippable.
Dependencies on `DR-2026-0017` milestones are explicit; steps with no
dependency can proceed even if 0017 stalls at M0.

| # | Step | Depends on | Schema | Gate |
|---|---|---|---|---|
| **S0** | Define `ReadingContext`, `ReadingSession`, `Selection`, `Focus`, `Playback` as pure types. **Zero consumers.** | 0017 M0 | None | Must meet J4 (no Flutter, no DB, no network) |
| **S1** | `ReadingContext` becomes the single home for position + mode + layers. `ReadingPositionStore` is demoted to its persistence adapter. `openAyahInReadingScreen()` keeps its signature and becomes a Context operation. | 0017 M1 | None | Existing tests pass unmodified |
| **S2** | `Playback.position` becomes an Address; the `currentIndex == ayahNumber - 1` comparison is deleted. | 0017 M3 | None | Audio regression suite |
| **S3** | `Selection` and `Focus` formalised. Highlight/note/bookmark creation flows through `Selection`. `_focusMode` re-homed to Presentation as chrome. | S0 | None | Behaviour-identical |
| **S4** | Session lifecycle (§7) formalised. `logSession()` becomes `Session.end()`, writing the same rows to `study_sessions`. | S1 | None | **Golden test: session records for a scripted read are identical before and after** |
| **S5** | Session history derived; the duplicate `reading.recent_surahs` preference removed. | S4 | None | Home screen "recent" unchanged |
| **S6+** | Word-level selection, highlight, playback, vocabulary capture. | **0017 M4/M5** | Yes (0017's) | `PROJ-P-002`, per 0017 |

**S0–S5 change no schema and no stored format.** S6 is gated behind
`DR-2026-0017`'s own schema milestone and inherits its `PROJ-P-002`
requirement; nothing in this record adds one.

**S4's golden test is the critical acceptance criterion**, for the same
reason `DR-2026-0017` M2's is: it is the only mechanical proof that
replacing a session boundary preserved the analytics history it feeds.
Streaks and study statistics are user-visible and silently
corruptible — a change here that is merely "probably fine" is not
acceptable.

## 13. Alternatives rejected

**A1 — Leave state where it is; add a session object beside it.**
*Pro*: no migration. *Con*: eight places instead of seven, and the
scattering that caused §1.1 remains. **Rejected** — a session that is
not the single home for interaction state is a ninth place to look.

**A2 — One god-object: put everything in `ReadingSession`.**
*Pro*: one place, trivially findable. *Con*: no distinction between what
survives a crash and what does not; every feature adds a field; it fails
the Closure Test on the first addition. **Rejected** — this is precisely
the decay §1.2 exists to prevent.

**A3 — Merge Context into Session** (no separate resumable state).
*Pro*: one concept instead of two. *Con*: resume then requires
resurrecting a *closed episode*, which is semantically wrong and forces
sessions to never truly end. Analytics and recovery pull in opposite
directions on the same object. **Rejected** — §5's table is the
argument.

**A4 — Model sessions on app lifecycle** (foreground/background).
*Pro*: trivial to implement; matches current behaviour. *Con*:
backgrounding to answer a message would end a session, and background
audio playback would be invisible. Once Phase 4 ships background audio,
this becomes actively wrong. **Rejected** (§7).

**A5 — Keep audio position as a playlist index.**
*Pro*: no change; it works. *Con*: preserves the 0-/1-based mismatch,
keeps audio and reading position fused, and blocks word-level sync
entirely. **Rejected** — but note S2 is separable, so this can be
deferred without blocking the rest.

**A6 — Separate stores for Notes and Reflections.**
*Pro*: each schema fits its purpose exactly. *Con*: two search paths,
two export paths, two sync paths, two sets of drift, and an arbitrary
line between "a thought" and "a reflection" that users will not respect.
**Rejected** — one store, discriminated by role (§6.5).

**A7 — Let Presentation query the Content Layer directly** for reads.
*Pro*: fewer indirections; less plumbing for simple text display. *Con*:
reintroduces exactly the coupling §1.1 documents, and makes the
Interaction Layer optional — which means it will be bypassed under
schedule pressure and decay. **Rejected**, with a concession:
projections (§4.4) exist so this is ergonomic rather than punitive.

**A8 — Defer all of this until after Public Beta.**
*Pro*: capacity is the binding constraint and none of this is
user-visible. *Con*: S2 and S4 remove active defect classes, and every
sprint that adds a feature to `ReadingScreen` without this makes the
eventual separation more expensive. **Rejected as a whole, partially
adopted**: S0–S1 are small and self-contained, and §15 explicitly
permits stopping there.

## 14. Consequences

### Positive

- One representation of interaction state; seven hiding places collapse
  to one layer (§1.1).
- Audio, reading, and selection positions become independently
  expressible — which is what fixes the auto-scroll-fights-the-reader
  behaviour, not as a workaround but as a consequence.
- The `currentIndex == ayahNumber - 1` defect class disappears (S2).
- Eight future features attach with no core change (§9), verified rather
  than hoped.
- Recovery becomes total and reuses one existing mechanism (§8.1).
- Sync semantics become derivable from the durability class rather than
  decided per-feature (§11.1).
- Session boundaries stop lying: background listening counts, cold
  launches do not.

### Negative — stated plainly

- **More layers to hold in one head.** Three layers plus six primitives
  is real conceptual load for a solo maintainer. Mitigated by the
  Closure Test being the only rule that must be remembered day-to-day.
- **Indirection cost for simple reads.** A text display now goes through
  a projection. Mitigated by projections being thin and derived, but it
  is real friction.
- **Session boundary is a policy, and policies are arguable.** Any
  timeout value is defensible and none is correct. §7 makes the policy
  explicit so it can be tuned rather than reverse-engineered.
- **Three visible positions may confuse users**, not just implementers.
  This is a UX risk, not only an architectural one, and belongs in the
  Phase 5 design work rather than being waved away here.
- **Migration touches the most-used screen in the app.** S4's golden
  test exists because of this.

### Neutral

- No user-visible change through S5.
- No schema change through S5.
- Existing tests pass unmodified through S3 by construction.

## 15. Future work

**Design now, build later** — the model reserves room; nothing is built:

- **Session intent transitions** — recording that a session moved from
  reading to memorizing, rather than forcing a boundary.
- **Multi-context** — a user with a Qur'an context and a study context
  open simultaneously. The model permits it (Context is a value, not a
  singleton by nature); nothing needs it yet.
- **Session-scoped goals** — "read to the end of this rukūʿ" as a Range
  the session carries. Falls out of `coverage` and `Range` with no new
  type.

**Build when a consumer exists:**

- Cross-device context handoff (§11.2) — needs auth, `DR-2026-0017` M1,
  and a sync layer that does not exist.
- Reflection resurfacing — needs the SRS attachment (§9) and a
  scheduling policy that is `DR-2026-0005`'s to define.
- Word-level everything — gated behind `DR-2026-0017` M4/M5.

**Explicitly not designed for**: NurVerse, external API consumers, or
any second product. Per `DATA_OS_ARCHITECTURE.md` §9, their requirements
are unknown and designing for them produces abstractions that fit
nothing.

## 16. Decision recommendation

**Recommended: accept, and authorize S0–S1 only.**

The reasoning: the application already has a reading session — it is
simply distributed across seven mechanisms with four lifetimes and three
incompatible representations of position. This record does not invent a
concept; it names one that exists and gives it a single home. S0–S1
change no schema, no stored format, and no behaviour, and they are the
prerequisite for every Phase 4 and Phase 5 reading feature.

The `owner_role` is asked to:

1. **Accept the layering** (§4) and the eight invariants (§10.2).
2. **Adopt the Closure Test** (§10.1) as a design-review gate — it is
   the single highest-value output of this record.
3. **Authorize S0–S1** — pure types, then Context as the single home for
   position and mode. No schema, no behaviour change.
4. **Hold S2 and S4** until `DR-2026-0017` M3 lands and the golden tests
   are written; both touch defect-prone, user-visible behaviour.
5. **Hold S6** behind `DR-2026-0017`'s `PROJ-P-002` gate.

**Deferral remains legitimate.** If Public Beta capacity is the binding
constraint, accepting the layering and the Closure Test while
authorizing only S0 costs almost nothing and prevents the next feature
from adding a ninth hiding place — which is most of the value on offer
here.

---

DR-2026-0018 — proposed, not accepted. No production code written; no
change to `lib/`, `test/`, `assets/`, database schema, or CI.
