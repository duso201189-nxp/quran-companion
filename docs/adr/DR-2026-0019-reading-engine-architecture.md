---
id: DR-2026-0019
scope: project
owner_role: constitution-owner
date: 2026-08-03
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [materially-different-approaches, constrains-future-architecture]
links:
  task: "Phase 4 — Reading Engine architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0019 — Reading Engine architecture

**Status of this record: proposed, not accepted.** No production code
was written; no change to `lib/`, `test/`, `assets/`, schema, or CI.

`owner_role` is inherited from `DR-2026-0018` rather than independently
escalated: this record is an elaboration of that record's
Presentation ↔ Interaction boundary, and the same person should own
both. It engages no `PROJ-P-002` — no schema change is proposed here or
implied by anything before E6.

`reversibility: soft` — code structure only, no stored format, no
schema. Revertible by refactoring.

---

## Relationship to existing records

This is the third and last of the Phase 4 foundation records, and the
only one that does not introduce a new vocabulary — it composes the two
below it.

- **`DR-2026-0017`** (Universal Qur'an Address) — supplies `Address`,
  `Range`, prefix containment, and total `widen()`. §8 and §11 both
  reduce to `widen()`.
- **`DR-2026-0018`** (Reading Session) — supplies `ReadingContext`,
  `ReadingSession`, `Selection`, `Focus`, `Playback`, the three-layer
  rule, and the Closure Test. This record occupies the Presentation side
  of that boundary and adds the machinery §4.4 there left as
  "projections."
- **Neither is amended.** If either is rejected, this record falls with
  it; if either is deferred, §12's migration stalls at a stated point
  rather than partially applying.
- **`DR-2026-0005`** (Learning Engine) — remains a consumer, never a
  participant (§10).

---

## 1. Motivation

### 1.1 The engine exists; it is spread across two widgets

`DR-2026-0018` §1.1 documented that interaction *state* hides in seven
places. The *machinery* that acts on it is in two: `ReadingScreen` and
`AyahCard` between them perform rendering, decoration, audio
synchronisation, scroll synchronisation, selection, and Basmalah
composition — inline, interleaved, and mutually aware.

Concretely, `AyahCard.build()` currently:

- resolves display text through Basmalah-aware special-casing,
- reads audio state to decide whether it is the playing āyah,
- reads annotations to decide background colour,
- composes those two decorations by precedence in the same expression,
- and lays out translations by settings — all in one method.

None of that is wrong. All of it is unextendable: word-level highlight,
word audio, selection decoration, and AI citation markers each need to
enter that same expression, and each would.

### 1.2 The feedback loop that is already being suppressed

`ReadingScreen` contains this guard:

```dart
final sameAyah = prev?.currentIndex == next.currentIndex &&
                 prev?.surahId    == next.surahId;
if (!next.active || next.surahId != widget.surahId ||
    sameAyah || settings.mode != ReadingMode.list ||
    !_itemScrollController.isAttached) {
  return;
}
_itemScrollController.scrollTo(index: next.currentIndex + 1, …);
```

That guard exists because **scroll and audio are each simultaneously a
producer and a consumer of position.** Audio produces a position; scroll
consumes it to move; scrolling produces a reading position; something
observes it. Without the guard, the components feed each other.

The guard works. It is also a symptom: the loop is broken by a
condition rather than by structure, and every future position source
(word-level audio, selection, AI citation jump, recovery) must
re-discover and re-implement the same defence.

**§7 breaks the loop structurally instead.** That is the single most
valuable thing in this record.

### 1.3 What must not happen

Eight pipelines that each hold a reference to `ReadingSession` would
make the session a hub: every pipeline couples to it, and through it, to
each other. Changing one field would fan out to eight consumers, which
is the same god-object decay `DR-2026-0018` §1.2 exists to prevent —
relocated one layer down and no better.

The requirement *"consume Address and Session without introducing direct
dependencies"* is therefore the design's central constraint, and §5 is
the answer to it.

## 2. Design goals

| # | Goal |
|---|---|
| G1 | **No pipeline depends on `ReadingSession`, or on another pipeline.** §5. |
| G2 | **Pipelines are pure transformations**, testable with no Flutter, no database, no clock, no network. |
| G3 | **Structure and decoration are separate.** Rendering emits addressed units; anything that marks them is composed on top (§6.3). |
| G4 | **Position feedback loops are impossible by construction**, not suppressed by guards (§7). |
| G5 | **Absence degrades; only failure errors** (§11). |
| G6 | **New visual behaviour is added by registering a source, never by editing rendering** (§10). |
| G7 | Recovery, audio degradation, and content-miss all reduce to one operation: `widen()`. |

## 3. Non-goals

- **No visual design.** Nothing here decides typography, colour, spacing
  or animation.
- **No widget tree.** "Presentation composes" is deliberately as far as
  this record goes.
- **No scheduling policy.** When a reflection resurfaces is
  `DR-2026-0005`'s.
- **No new state.** Every value consumed here is defined in
  `DR-2026-0017` or `DR-2026-0018`.
- **No performance targets.** §13 R2 names the risk; measurement is a
  milestone, not a claim.

## 4. The Reading Engine

> **The Reading Engine is not an object.** It is the composition of
> nine pure pipelines around the session state defined in
> `DR-2026-0018`, plus one policy layer (§7.3).

There is deliberately no `ReadingEngine` class. A class would be the hub
§1.3 forbids, and every pipeline would acquire a dependency on it. The
engine is a *composition*, and composition happens at the Presentation
boundary where the framework already provides it.

### 4.1 Locators and Resolvers — the shape everything shares

Every pipeline is one of two kinds, distinguished by which way it moves
relative to an Address:

| Kind | Signature | Members |
|---|---|---|
| **Locator** | `input → Address` | Selection, Recovery, AudioPosition, ScrollPosition |
| **Resolver** | `Address\|Range → output` | Render, Word, Basmalah, Highlight, AudioSegment, ScrollTarget |

```
   ┌──────────────┐        ┌───────────────┐        ┌──────────────┐
   │   LOCATORS   │        │ SESSION STATE │        │  RESOLVERS   │
   │              │ write  │  (DR-0018)    │  read  │              │
   │ gesture   ──▶│───────▶│  Context      │───────▶│──▶ units     │
   │ clock     ──▶│        │  Selection    │        │──▶ decoration│
   │ offset    ──▶│        │  Focus        │        │──▶ segments  │
   │ persisted ──▶│        │  Playback     │        │──▶ offsets   │
   └──────────────┘        └───────────────┘        └──────────────┘
          ▲                                                 │
          └──────────── never directly ─────────────────────┘
                    (only via §7.3 policies)
```

**Two pipelines are bidirectional and must be split in half.** Audio and
Scroll each *produce* a position and *consume* one. Implemented as a
single component — which is how both exist today — they observe the
state they also write, which is precisely §1.2's loop.

| Today | Split into |
|---|---|
| `AudioController` (position + playback) | `AudioPositionLocator` (clock → Address) **and** `AudioSegmentResolver` (Range → playable segments) |
| `ScrollablePositionedList` wiring | `ScrollPositionLocator` (offset → Address) **and** `ScrollTargetResolver` (Address → offset) |

Recognising that these two subsystems — the two that cause the most
trouble today — are the two bidirectional ones is not a coincidence.
It is the diagnosis.

### 4.2 The nine pipelines

| # | Pipeline | Kind | Input (its **frame**) | Output |
|---|---|---|---|---|
| P1 | **Render** | Resolver | `(Range, mode, layers)` | `RenderUnit[]`, each carrying an Address |
| P2 | **Word** | Resolver | `(Āyah address)` | `WordUnit[]`; empty when word data absent |
| P3 | **Basmalah** | Resolver | `(Surah)` | `Range?` — zero or one opening range |
| P4 | **Highlight** | Resolver | `(visible Range, decoration sources)` | `Map<Address, Decoration>` |
| P5 | **Selection** | Locator | `(target Address, gesture)` | `Range?` |
| P6 | **AudioSegment** | Resolver | `(Range, reciter)` | `PlayableSegment[]` |
| P7 | **AudioPosition** | Locator | `(clock, segment table)` | `Address` |
| P8 | **Scroll** | Both | `offset → Address` / `Address → offset` | — |
| P9 | **Recovery** | Locator | `(persisted value, resolvability probe)` | `Address` |

## 5. How eight pipelines consume Address and Session with no direct dependency

This is the record's central requirement. Three mechanisms, in order of
importance.

### 5.1 Narrow input types — a pipeline never names `ReadingSession`

Each pipeline declares its input as a **frame**: a small immutable value
containing exactly what it needs and nothing more.

- P1's frame is `(Range, ReadingMode, TextLayers)`. It contains no
  Selection, no Playback, no Focus, no annotations. **The Render
  pipeline cannot be affected by an audio change**, because audio state
  is not in its input.
- P3's frame is `(Surah)`. Not a session, not a context — a surah.
- P4's frame is `(visible Range, decoration sources)`. It does not know
  what a `Playback` is; it receives sources.

A pipeline therefore depends on its own frame type and on
`DR-2026-0017`'s address vocabulary. **It never imports
`ReadingSession`.** Changing a session field cannot fan out to eight
pipelines, because none of them names it.

### 5.2 One frame builder — the only place that knows both sides

A single **frame builder** at the Presentation boundary maps session
state to each pipeline's frame:

```
ReadingSession state  ──▶  FrameBuilder  ──▶  P1 frame
                                          ──▶  P3 frame
                                          ──▶  P4 frame
                                          ──▶  …
```

- The frame builder depends on `ReadingSession` (it must).
- It depends on every frame type (it must).
- **No pipeline depends on it.** The dependency is one-directional and
  terminates.

One component knows both vocabularies. Nine do not. When session state
changes shape, one file changes.

### 5.3 Selection is narrowed at the source, not filtered downstream

The framework mechanism is `select` — and the project already uses it
for exactly this purpose. `AyahCard` today contains:

```dart
final isPlayingThis = ref.watch(
  audioControllerProvider.select((s) => s.active && … ),
);
// select(): thẻ CHỈ rebuild khi kết quả bool đổi — các tick
// position/duration của trình phát không đụng tới danh sách.
```

The comment is the principle already understood and already applied: a
consumer subscribes to a *derived value*, not to the state object, so
unrelated changes cannot reach it. This record generalises that from one
call site to the architecture, rather than introducing a foreign idea.

### 5.4 Pipelines never call each other

**No pipeline invokes another.** Where an output feeds an input, the
frame builder does the wiring:

- P7 (AudioPosition) produces an Address → written to `Playback` →
  frame builder puts it into P4's decoration sources.
- P5 (Selection) produces a Range → written to `Selection` → frame
  builder puts it into P4's decoration sources.

P4 does not know either exists. It receives a list of sources.

**Verification, statable as a test:** the dependency graph among P1–P9
must be **empty**. If any pipeline imports another, the design has been
violated, and the violation is detectable by static inspection rather
than by review judgement.

## 6. Render flow

### 6.1 The pipeline

```
  Context.position ─┐
                    ├─▶ visible Range ─▶ ┌────────────┐
  viewport extent ──┘                    │ P1 RENDER  │─▶ RenderUnit[]
                                         │  (Range,   │    · address
  mode, layers ─────────────────────────▶│   mode,    │    · text layers
                                         │   layers)  │    · structural role
                                         └────────────┘
                                               │
                     ┌─────────────────────────┼──────────────────────┐
                     ▼                         ▼                      ▼
              ┌────────────┐           ┌────────────┐         ┌────────────┐
              │ P3 BASMALAH│           │  P2 WORD   │         │ P4 HIGHLIGHT│
              │  (Surah)   │           │  (Āyah)    │         │ (Range,     │
              │  → Range?  │           │  → Word[]  │         │  sources)   │
              └────────────┘           └────────────┘         │ → Map<Addr, │
                     │                        │               │    Decoration>│
                     └────────────┬───────────┴───────────────┴──────┬──────┘
                                  ▼                                  ▼
                        ┌──────────────────────────────────────────────┐
                        │        PRESENTATION composes                 │
                        │  units × decorations → widgets               │
                        └──────────────────────────────────────────────┘
```

### 6.2 Only the visible range is resolved

P1's input is the **visible** Range, not the surah. Rendering cost is
bounded by viewport, not by content size — which is what makes the same
pipeline viable for a 286-āyah surah and for a word-level render of one
āyah.

### 6.3 Structure and decoration are separate — the extension point

> **P1 emits *what is there*. P4 emits *what is marked*. Presentation
> composes them.**

This is G3, and it is what makes §10's table true. Today, an
`AyahCard`'s background colour is computed inside the card from audio
state and annotation state, by precedence, in one expression. Under this
split:

- P1 does not know highlights exist.
- P4 does not know what a widget is.
- Adding word-level highlight changes the **key level of P4's map**, not
  P1 and not the widget.
- Adding AI citation markers registers **one more decoration source**,
  and touches neither.

`Decoration` is deliberately abstract: a marker addressed by `Address`,
resolved to appearance by Presentation. The engine never names a colour.

### 6.4 Basmalah composition

P3 returns zero or one `Range` (`DR-2026-0017` §10). Presentation
renders whatever it returns — including nothing.

The point worth restating in engine terms: **P3's output is the same
type regardless of surah.** Al-Fātiḥah yields an Āyah-level Range,
sūrat al-Baqarah a Word-level Range, At-Tawbah nothing. The composition
step does not branch, because a Range is level-agnostic
(`DR-2026-0017` I5) and "nothing" is an empty result rather than a
special case.

### 6.5 Word rendering activates by data, not by flag

P2 returns an empty list when word data is absent, and Presentation
renders the āyah as a single unit. When word data exists, P2 returns
units and the same āyah renders as words.

**No feature flag, no conditional in the render path, no code change
when word data lands.** The behaviour follows the data — which is the
R3b honesty line expressed as a pipeline contract: absent data yields an
absent affordance, never a broken one.

## 7. Audio synchronisation

### 7.1 The split

```
                         ┌─────────────────────┐
   clock tick ──────────▶│ P7 AUDIOPOSITION    │──▶ Address
   segment table ───────▶│      (Locator)      │    (Segment ▸ Word ▸ Āyah)
                         └─────────────────────┘
                                    │ writes
                                    ▼
                          ┌───────────────────┐
                          │ Playback.position │   (DR-0018 §6.4)
                          └───────────────────┘
                                    │ read by
                    ┌───────────────┴───────────────┐
                    ▼                               ▼
            P4 HIGHLIGHT                    §7.3 SYNC POLICY
         (as a decoration source)          (may request a scroll)

   Range + reciter ─────▶┌─────────────────────┐
                         │ P6 AUDIOSEGMENT     │──▶ PlayableSegment[]
                         │     (Resolver)      │
                         └─────────────────────┘
```

P7 emits the finest Address for which timing data exists and **widens**
when it does not (`DR-2026-0017` §4.2). Because widening is total, no
consumer contains an "if word timing exists" branch — word audio
changes what P7 emits, and nothing downstream.

### 7.2 What replaces `currentIndex == ayahNumber - 1`

Both sides become Addresses, and the test becomes containment
(`DR-2026-0017` §4.1): *does `Playback.position` fall within this unit's
Address?* Prefix comparison, no arithmetic, no base mismatch. The defect
class in §1.2's snippet disappears rather than being guarded.

### 7.3 Sync policies — the only place cross-position coupling lives

Audio position and reading position are independent values
(`DR-2026-0018` §6.2). Sometimes one should influence the other. That
influence is a **policy**: a named, isolated rule, never an observation
embedded in a component.

```
   Playback.position ─┐
                      ├─▶ ┌──────────────┐ ─▶ ScrollIntent (an offer)
   Focus ─────────────┤   │  SYNC POLICY │
   user-scrolled-at ──┘   └──────────────┘ ─▶ or nothing
```

*Example policy, stated as behaviour rather than code:* when playback
leaves the visible range **and** the user has not scrolled manually
within a recent window, emit a scroll **intent**. Otherwise emit
nothing, and let Presentation offer "jump to what's playing."

Three properties follow, and all three are improvements on the guard in
§1.2:

- **The loop cannot form.** A policy emits an *intent*; it never writes
  the position it read. Producer and consumer are structurally separate.
- **It is testable in isolation** — a pure function of two Addresses and
  a timestamp, with no widget, no scroll controller, no audio engine.
- **It is tunable without touching audio or scroll**, and its behaviour
  is legible in one place rather than distributed across a boolean
  guard.

`sameAyah` and its four conjunctions are deleted, not relocated.

## 8. Scroll synchronisation

The same split, for the same reason:

| Direction | Pipeline | Input → Output |
|---|---|---|
| **Produce** | `ScrollPositionLocator` | viewport offset → `Address` → written to `Focus` |
| **Consume** | `ScrollTargetResolver` | `Address` → offset, executed only on an explicit intent |

**The consume direction never observes `Focus`.** It acts only on an
intent — from a policy (§7.3), from navigation
(`openAyahInReadingScreen`, `DR-2026-0002` item 9), from search, or from
recovery. That is the structural loop break: the component that writes
`Focus` and the component that reads a scroll target are different, and
the second is never triggered by the first.

Mode-dependent layout (flow, mushaf, focus) is a Presentation concern.
The resolver's contract is `Address → offset`; how the offset is
computed is the layout's business, which is why mushaf line fidelity
(`DR-2026-0017` §4.4 — a line is a Range) needs no engine change.

## 9. Selection flow

```
  pointer/keyboard ─▶ Presentation ─▶ target Address
                                          │
                                          ▼
                                  ┌───────────────┐
                                  │ P5 SELECTION  │ ─▶ Range?
                                  │   (Locator)   │
                                  └───────────────┘
                                          │ writes
                                          ▼
                                    Selection (DR-0018 §6.1)
                                          │
              ┌───────────┬───────────────┼───────────────┬─────────────┐
              ▼           ▼               ▼               ▼             ▼
          Highlight     Note         Reflection      Vocabulary     AI Tutor
                                          │                             │
                                          └──────────┬──────────────────┘
                                                     ▼
                                        P4, as a decoration source
```

**One selection, seven consumers, no consumer known to the engine.**
`Selection` is a `Range`, so it is already level-agnostic: selecting a
word rather than an āyah is a different level of the same value, and P5
gains a granularity rather than a branch.

The five consumers on the right are *outside* the engine. They read
`Selection` from session state; the engine neither imports nor knows
them. Adding a sixth requires no engine change — which is §10's claim,
demonstrated structurally rather than promised.

## 10. Twelve capabilities, no core change

| Capability | What changes | Engine change |
|---|---|---|
| **Āyah rendering** | — | Baseline |
| **Word rendering** | P2 returns units instead of empty (§6.5) | **None** — data-driven |
| **Basmalah** | P3 returns a Range (§6.4) | **None** — same type every surah |
| **Audio** | — | Baseline |
| **Word Audio** | P7 emits a finer Address; widening absorbs it | **None** |
| **Highlight** | — | Baseline |
| **Word Highlight** | P4's map is keyed at word level | **None** — P1 untouched |
| **Scrolling** | — | Baseline |
| **Focus Mode** | `mode` in P1's frame | **None** — chrome is Presentation (`DR-2026-0018` §6.3) |
| **Reflection** | A Selection consumer **+** a decoration source | **None** |
| **Vocabulary** *(future)* | A Selection consumer | **None** |
| **AI Tutor** *(future)* | A Selection consumer **+** a citation decoration source | **None** |

**Every extension is one of exactly two moves**: a pipeline emits a
finer Address, or a feature registers as a decoration source and/or a
Selection consumer. Neither is a change to the engine.

This is `DR-2026-0018` §10.1's Closure Test applied one layer down, and
it holds for all twelve.

## 11. Error handling — absence degrades, failure surfaces

The governing distinction, and the one today's code sometimes loses:

> **Absence of optional data is a normal state that degrades. Failure of
> a required operation is an error that surfaces.**

An empty list must not be able to mean both "nothing matched" and "the
query failed" — the ambiguity that `SearchNoResultsState` was introduced
in Sprint R1.2 to resolve at the UI level, applied here at the pipeline
level.

### 11.1 Degradation ladders

Each pipeline declares what it does when an input is absent. **No rung
on any ladder is an error state.**

| Pipeline | Absent input | Degrades to |
|---|---|---|
| P1 Render | A translation layer missing | Render remaining layers |
| P2 Word | No word data | Empty → āyah renders as one unit |
| P3 Basmalah | No declaration | Empty → nothing rendered |
| P4 Highlight | A decoration source empty | Fewer decorations |
| P6 AudioSegment | No word timing | Āyah-level segments |
| P7 AudioPosition | No segment timing | `widen()` to Āyah |
| P8 Scroll | Address not laid out | Nearest laid-out ancestor via `widen()` |
| P9 Recovery | Address unresolvable | `widen()` until it resolves (§12) |

Four of the eight reduce to `widen()`. That is G7, and it is the third
distinct problem — after audio degradation and state recovery — that one
total operation from `DR-2026-0017` solves.

### 11.2 What genuinely errors

| Failure | Handling |
|---|---|
| Audio decode / network | Real error → surfaced with retry. Preserves today's `errorStream` → `errorMessage` → `SearchErrorState`-style behaviour |
| Storage read/write failure | The reliability layer (`withFailureLogging`) — unchanged, and this record adds no new boundary |
| Malformed Range (`from > to`, mixed levels) | **Programmer error.** Fail fast in debug; it is unreachable from user input because P5 constructs ranges |

### 11.3 One rule for the whole engine

> **A pipeline never throws to signal absence, and never returns empty
> to signal failure.**

Checkable at review, and it is the pipeline-level statement of the R3b
honesty line.

## 12. Recovery flow

```
  persisted Context ─▶ ┌──────────────┐
                       │ P9 RECOVERY  │
  resolvability probe ▶│  (Locator)   │
                       └──────┬───────┘
                              │
                   resolves?  ├── yes ──▶ Address (restored)
                              │
                              └── no ───▶ widen() ──┐
                                             ▲      │
                                             └──────┘
                                        Word ▸ Āyah ▸ Surah ▸ none
```

Recovery is a **locator like any other** — it produces an Address from
an input. It is not a special mode, and there is no separate "recovery
path" through the engine: once P9 emits an Address, every downstream
pipeline behaves exactly as in normal operation.

That is why recovery needs no separate testing surface, and why a
recovered session cannot reach a state normal operation could not.

The widening ladder terminates at "no position," which is a valid state
(the surah list). **There is no unrecoverable stored value**
(`DR-2026-0018` J6/G6).

## 13. Risks

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| **R1** | **Over-abstraction.** Nine pipelines plus a frame builder plus policies, for one screen. | **High** | E0–E3 (§14) each remove a live defect; nothing past E5 ships without a consumer. If Beta capacity binds, stopping at E3 is coherent and keeps the loop fix. |
| **R2** | **Performance regression.** Pure recomputation could be worse than today's targeted `select()` rebuilds. | **High** | Frames are narrow, so they change rarely; pipelines are pure and memoizable. **But this must be measured, not asserted** — the project has precedent (`docs/knowledge/provider_read_flow.md`, the provider-reuse performance tests). E5 carries a measurement gate. |
| **R3** | **Purity meets an imperative scroll API.** `ScrollablePositionedList` is stateful and imperative; `Address → offset` may not be knowable without layout. | Medium | P8's consume side is explicitly allowed to be a thin imperative adapter; the *decision* to scroll stays pure (§7.3). Purity is required of policy, not of the adapter. |
| **R4** | **The policy layer becomes a dumping ground** for every cross-cutting behaviour. | Medium | Policies are pure functions of Addresses and timestamps only. Anything needing more is not a policy. |
| **R5** | **Three ADRs of vocabulary for one maintainer.** | Medium | This record adds no nouns — Address, Range, Context, Selection, Focus, Playback are all inherited. Only Frame, Locator, Resolver, Policy, Decoration are new, and each is defined by its signature. |
| **R6** | **Frame builder becomes the new god-object.** | Medium | It is the *only* component permitted to know both vocabularies, and it contains no logic — only projection. If it grows behaviour, that behaviour belongs in a pipeline. |

## 14. Migration

Additive, behaviour-preserving, each step independently shippable.
Dependencies on `DR-2026-0017` (M) and `DR-2026-0018` (S) are explicit.

| # | Step | Depends on | Schema | Gate |
|---|---|---|---|---|
| **E0** | Pipeline contracts and frame types as pure declarations. **Zero consumers.** | 0017 M0, 0018 S0 | None | Must be testable with no Flutter, no DB, no clock |
| **E1** | Extract **P4 Highlight** — decoration map lifted out of `AyahCard`; card consumes a map instead of computing precedence inline. | E0 | None | Golden: rendered output byte-identical |
| **E2** | **P3 Basmalah** replaces the hardcoded logic. *This is `DR-2026-0017` M2 — the same step, not a duplicate.* | 0017 M2 | None | **Golden: all 114 surahs byte-identical** |
| **E3** | Split audio into **P7 + P6**; introduce the §7.3 sync policy; **delete `sameAyah`**. | 0017 M3, 0018 S2 | None | Audio + scroll regression; the loop-break is the point |
| **E4** | Split scroll into **P8** produce/consume halves. | E3 | None | Scroll regression |
| **E5** | **P1 Render** formalised; frame builder introduced. | E1–E4 | None | Golden + **performance measurement** (R2) |
| **E6** | **P2 Word** activates; P4 keys at word level. | **0017 M4/M5**, 0018 S6 | Yes (0017's) | `PROJ-P-002`, per 0017 |

**E0–E5 change no schema and no stored format.** E6 inherits
`DR-2026-0017`'s gate; nothing here adds one.

**E1–E3 are the value.** E1 unblocks every future decoration; E2 removes
the Basmalah special-casing; E3 deletes the feedback-loop guard and the
index/number mismatch together. If Phase 4 stops after E3, the two
defect classes that motivated this record are gone and the remaining
steps are optional structure.

## 15. Alternatives rejected

**A1 — Keep rendering and synchronisation inside the widgets.**
*Pro*: zero work; it functions today. *Con*: `AyahCard.build()` is
already composing four concerns in one expression, and each of the six
future capabilities in §10 adds a fifth. **Rejected** — it is the
trajectory, not a stable state.

**A2 — One `ReadingEngine` service that owns everything.**
*Pro*: one obvious place; easy to find. *Con*: every pipeline couples to
it and, through it, to each other; it becomes the hub §1.3 forbids.
**Rejected** — this is the god-object failure mode relocated one layer
down.

**A3 — Pipelines as stateful services holding a `ReadingSession`
reference.**
*Pro*: direct, conventional, less plumbing than frames. *Con*: **exactly
the direct dependency the requirement forbids.** Eight consumers of one
type; a session field change fans out to all eight. **Rejected** — §5.1
exists because of this alternative.

**A4 — An event bus between pipelines.**
*Pro*: decouples pipelines from each other without frames. *Con*: trades
a traceable dependency graph for an untraceable one — "what happens when
audio advances" stops being answerable by reading code. Also permits
cycles, which is the specific thing §7 removes. **Rejected**; §5.4's
"empty dependency graph" is verifiable, an event bus's is not.

**A5 — Entity-Component-System.**
*Pro*: genuinely solves the decoration-composition problem, and solves
it generally. *Con*: alien to Flutter and to every other subsystem in
this codebase; imposes a paradigm on one screen that the rest of the app
does not share. **Rejected** — §6.3's addressed decoration map gets the
needed 20% without the paradigm.

**A6 — Each pipeline owns its own state; no shared session.**
*Pro*: maximal isolation, no shared mutable state at all. *Con*:
position would exist in four places again — which is `DR-2026-0018`
§1.1's disease, reintroduced as a cure. **Rejected.**

**A7 — Keep audio and scroll unified; strengthen the guard.**
*Pro*: smallest possible change; the guard works today. *Con*: every new
position source must rediscover it, and the guard is invisible to anyone
who does not already know the loop exists. **Rejected** — §7.3 replaces
a condition with a structure.

**A8 — Defer until after Public Beta.**
*Pro*: none of this is user-visible, and capacity is the binding
constraint. *Con*: E3 removes an active defect class, and every feature
added to `AyahCard` before the split makes the split more expensive.
**Rejected as a whole, partially adopted**: §14 sequences E0–E3 as the
valuable minimum and §16 explicitly permits stopping there.

## 16. Consequences and recommendation

### Positive

- The feedback loop between audio and scroll becomes **structurally
  impossible** rather than conditionally suppressed (§7.3); `sameAyah`
  is deleted.
- `currentIndex == ayahNumber - 1` disappears with it (§7.2).
- Twelve capabilities attach with no engine change (§10), verified by
  construction.
- Decoration becomes pluggable — the extension point for reflection,
  vocabulary, and AI citation markers, none of which touch rendering.
- Four degradation paths and recovery reduce to one operation (§11.1).
- Pipelines are testable without Flutter, a database, a clock, or a
  network.

### Negative — stated plainly

- **Nine pipelines is a lot of machinery for one screen** (R1), and the
  honest answer is that E0–E3 justify themselves while E4–E5 are
  structure whose payoff is future.
- **Performance is a real, unmeasured risk** (R2). This record asserts
  no target and carries a measurement gate rather than a claim.
- **More indirection between a gesture and a pixel.** Legibility of any
  single interaction goes down; legibility of the system goes up. That
  trade is worth stating rather than assuming.
- **The frame builder must stay behaviourless** (R6), which is a
  discipline, not a guarantee.

### Recommendation

**Accept the model; authorize E0–E3.**

Those four steps change no schema, are individually reversible, and
between them delete both defect classes that motivated this record — the
suppressed feedback loop and the index/number mismatch — while
extracting the decoration map that every future visual feature needs.
E4–E5 are structure; E6 is gated behind `DR-2026-0017` anyway.

The `owner_role` is asked to:

1. **Accept** the locator/resolver split (§4.1), frames (§5.1), and the
   no-inter-pipeline-dependency rule (§5.4).
2. **Adopt §11.3** — *never throw for absence, never return empty for
   failure* — as a review rule alongside `DR-2026-0018`'s Closure Test.
3. **Authorize E0–E3.**
4. **Hold E5** until its performance gate is defined (R2).
5. **Hold E6** behind `DR-2026-0017`'s `PROJ-P-002` gate.

**Deferral remains legitimate.** If Beta capacity binds, accepting the
model and authorizing only **E3** — the audio/scroll split and the
policy — captures the defect fixes and leaves everything else for when
the reading engine is next opened.

---

DR-2026-0019 — proposed, not accepted. No production code written; no
change to `lib/`, `test/`, `assets/`, database schema, or CI.
