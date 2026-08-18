---
id: DR-2026-0027
scope: project
owner_role: data-owner
date: 2026-08-18
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-18
reversibility: soft
threshold_reason: [constrains-future-architecture, materially-different-approaches]
links:
  task: "D7.8 — retention observation instrument (Session 1 discovery, Session 2 architecture, Session 3 decision record)"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0027 — Retention observation instrument (read-only boundary)

**Status of this record: accepted.** It is a governance decision only.
Acceptance settles the architectural direction and authorizes nothing
further.

Acceptance authorizes **no code**: no repository,
no entity, no provider, no calculator, no test, no schema change, no
migration, no index, no UI, and no Analytics integration. It
authorizes an *architectural direction* and nothing else. This mirrors
the discipline this project has already used for `review_events` —
`DR-2026-0024` (architecture) → implementation plan → `PROJ-P-002`
approval → implementation → audit → commit, and `DR-2026-0026`
(architecture) → D6.11 plan → approval → implementation — never
architecture-acceptance-as-code-authorization. See §Governance
boundaries.

## The question this record answers

> Qur'an Companion now stores committed SRS review history
> (`review_events`, schema v8), and the Study Architecture
> Constitution §8 names long-term retention as the objective of the
> entire Study module while stating plainly that **no
> retention-measurement instrument exists in the product today**.
> What is the architecturally correct shape of the *first* such
> instrument, and where does it live?

It answers that one question. It does not answer who consumes the
instrument, when it is built, or what any of it looks like on screen —
those are separate, later, separately gated decisions.

## Relationship to existing records

`DR-2026-0024` (SRS review event storage, accepted) created
`review_events` as an append-only, immutable log of committed SRS
state transitions for `item_type` `ayah`/`hifz`. This record does not
alter that table, its emission policy, its immutability guarantee, or
any of its fifteen decisions. It is a **reader**, and only a reader.
In particular, Decision 5 (no `plan_id`), Decision 6 (`card_id` is not
a learning-cycle identity), Decision 7 (immutability), Decision 10 (no
backfill), Decision 14 (analytics boundary) and Decision 15 (no UI)
are all inherited here without modification or reinterpretation.

`DR-2026-0025` (Analytics review-event consumption boundary, accepted)
settled that Analytics *may in principle* one day consume
`review_events`, but only via its own future record satisfying a
five-element gate. **This record is not that record, and does not
invoke that gate** — see §Analytics boundary. It neither weakens nor
consumes `DR-2026-0025`'s allowance.

`DR-2026-0026` (Hifz historical review count and pace, accepted)
authorized the *first* narrow `review_events` consumer, and D6.11
implemented it. That record is the direct precedent for this one in
**shape** — a feature-scoped, read-only boundary rather than a generic
history repository — and the direct obstacle to reuse in **substance**,
because its §"Data sufficiency" explicitly forbids the very fields
this instrument requires. §Field-exposure decision below is the whole
reason this record must exist separately rather than being folded into
D6.11's boundary.

`DR-2026-0005` (Learning Engine architecture — Scheduler/SM-2) defined
`SchedulerRepository` and `srs_cards` as *scheduling state*. This
record does not change that, does not add a method to
`SchedulerRepository`, and does not read `srs_cards` at all.

`DR-2026-0021` (Automatic Retention Seeding) established that the
Scheduler is deliberately provenance-blind — it receives an opaque
`List<int>` and cannot distinguish how an item became eligible. This
record preserves that absolutely: a retention observation records what
happened between two reviews, **never why the item was queued**. See
§What the instrument does not measure.

## Context

### The Constitution names the gap and names it as a gap

`docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md` §8 ("Role of
Retention") is unusually explicit, and its exact framing is the
authority for this record:

- Retention is "the objective of the entire Study module, not an
  activity within it" — "the durable, long-term recall of what has
  been read, revised, or memorized."
- It "is measured over time (recall weeks or months after first
  engagement), **not** measured by session count, streak length, or
  quiz score."
- "**No retention-measurement instrument exists in the product
  today.** That absence does not weaken the objective — it identifies
  the standard future work must build toward, not a capability already
  assumed available."
- "Any future metric proposed for this module's success must be a
  retention metric, not an engagement metric, even before a retention
  instrument exists to measure it precisely."

§15 ("Architecture Principles") restates the same obligation twice
more: **Long-Term Retention** ("Every future decision affecting this
module must be evaluated against durable recall, not session count,
engagement metrics, or feature volume, even in the absence of a
retention-measurement instrument today") and **Minimal Sufficient
Change** ("reuse existing engines ... rather than introducing new
systems"). §14 ("Long-Term Vision") supplies the standard this
instrument is built to serve: "Its success is measured in what the
user still remembers months later, not in how many sessions they
opened this week."

The Constitution therefore does two things at once: it declares
retention the objective, and it declares the measuring instrument
absent. This record proposes the architecture of that absent
instrument, and nothing more.

### The roadmap gap is still open

`docs/release/MILESTONE_7_STUDY_ROADMAP.md` lists **Sprint 7.8 —
Learning Analytics Foundation** as the eighth and only unshipped
sprint: *"Logging first; reporting deferred until there's enough data
to warrant it."* Its status line is unambiguous and remains accurate
against the repository:

> **Status:** Not started. Still planned; awaiting its own explicit
> scope/authorization before work begins. The Hifz-specific
> `review_events` infrastructure (D6.6, `DR-2026-0024`) is a separate,
> independently governed capability — scoped to `ayah`/`hifz` review
> history only — and does not, by itself, constitute or satisfy this
> sprint's general "Learning Analytics Foundation" scope.

Its Worship First checkpoint is the binding constraint on everything
below: *"Confirm metrics remain internal and diagnostic, and are never
surfaced back to the user as a score."*

### D6.6 and D6.11 do not satisfy the D7.8 scope

Both are real, shipped, and governed — and neither is a retention
instrument:

- **D6.6 (`DR-2026-0024`)** built *storage*. It is a write path and a
  table. The roadmap entry above says in its own words that it "does
  not, by itself, constitute or satisfy" Sprint 7.8. Storing evidence
  is not measuring anything.
- **D6.11 (`DR-2026-0026`)** built a *count and a 7-day activity
  distribution*, Hifz-only, over the same table. Its own entity doc
  comment states the metric is the number of review attempts
  performed — not mastery, accuracy, correctness rate or a score
  (`lib/features/hifz/domain/entities/hifz_review_history.dart`), and
  `DR-2026-0026`'s Decision 1 says the same: "it counts *attempts*,
  not correctness or retention." A count of attempts is by
  construction an activity measure, which Constitution §8 rules out as
  a retention measure in the same sentence in which it rules out
  session count. D6.11's read boundary also returns **only**
  `reviewedAt` timestamps (`Future<List<int>>
  reviewedAtMsForAyahs(Set<int>)`), deliberately discarding grade,
  state, and interval — it structurally cannot see whether anything
  was recalled.

Neither answers the §8 question — *does the user still remember this,
weeks or months later?* — and neither was ever claimed to.

### `review_events` exists at schema v8, verified

Verified directly against the repository at `f2df50b`:

- `lib/core/database/user/user_database.dart` — `int get
  schemaVersion => 8;`
- `lib/core/database/user/user_database.dart` (v8 `onUpgrade` branch) —
  creates `reviewEvents` plus `idxReviewEventsItem` and
  `idxReviewEventsReviewedAt`, additive only.
- `lib/core/database/user/user_tables.dart` — `class ReviewEvents
  extends Table with SyncColumns`, `tableName => 'review_events'`,
  no `uniqueKeys` (multiple rows per `(item_type, item_id)` is the
  point), carrying `card_id`, `item_type`, `item_id`, `reviewed_at`,
  `grade`, `algorithm_id`, and the full `before_*`/`after_*` pairs
  (`state`, `repetitions`, `interval_days`, `ease_factor`,
  `due_date`).
- `lib/features/learning/data/scheduler_repository_impl.dart` —
  `applyReview` writes the `srs_cards` UPDATE and the
  `ReviewEventsCompanion.insert` inside one `_db.transaction(...)`,
  gated to `LearningItemType.ayah`/`hifz`, satisfying
  `DR-2026-0024` Decisions 3 and 8.

### `ReviewEvent` exists and has no consumer at all

`lib/features/learning/domain/entities/review_event.dart` defines the
pure-domain `ReviewEvent` class with all seventeen fields.
Repository-wide search at `f2df50b` finds **zero references to it
anywhere in `lib/` or `test/`, and zero imports of the file.** This is
stronger than "no legitimate consumer," and the precision matters:

- the *write* path does not use it — `applyReview` constructs the
  Drift-generated `ReviewEventsCompanion` directly;
- the *read* path does not use it — D6.11's
  `HifzReviewHistoryRepositoryImpl` projects rows to `List<int>` of
  timestamps and never materialises the entity.

`ReviewEvent` is therefore, today, unreferenced domain code: a fully
specified description of a durable fact that nothing in the product
reads. That is not an argument for inventing a consumer to justify it
(see §Dormant-consumer property for why that reasoning is
inadmissible), but it does establish that the domain vocabulary this
record builds on already exists, is already governed, and requires no
new invention.

### What this instrument is for

An internal diagnostic foundation for the one thing the Constitution
says the whole module exists to serve: evidence of durable recall.
`review_events` accumulates, per committed review, the elapsed
interval a card survived and the grade recorded at the end of it.
That is the raw material of a retention measurement and the only such
material this product has ever had. This record proposes the boundary
that reads it truthfully — and stops there.

## Retention definition

**Adopted definition.** A **retention observation** is an ordered,
provably-continuous pair of committed review events for the same
`(item_type, item_id)`, measuring the elapsed wall-clock interval
between the two events and the recall outcome recorded at the end of
that interval.

Repository evidence supports this definition without amendment; it is
adopted as stated. Its terms, each with its concrete grounding:

- **Prior event** (the *predecessor*). The earlier `ReviewEvent` of
  the pair. It establishes the moment at which the item was last
  exercised and the scheduling state the card was left in. It is not
  "the first review" and not "the start of a plan" — merely the
  immediately preceding committed event for that item under the
  ordering rules in §Determinism and verification.
- **Successor event.** The next committed `ReviewEvent` for the same
  item. Its `grade` is the observation's outcome, because it is the
  first recorded evidence about the item's recallability *after* the
  interval elapsed.
- **Elapsed interval.** `successor.reviewedAt -
  predecessor.reviewedAt`, in epoch milliseconds UTC. This is
  wall-clock time actually survived, not scheduled time, not planned
  time, not algorithm-predicted time. See §Algorithm agnosticism —
  this distinction is the single most important technical constraint
  in this record.
- **Recall outcome.** The successor's raw `grade` —
  `again`/`hard`/`good`/`easy` (`ReviewGrade`,
  `lib/features/learning/domain/scheduling_algorithm.dart`). Raw, and
  raw only: not mapped to correct/incorrect, not weighted, not
  averaged, not converted to a percentage. The four-value vocabulary
  is the honest resolution of the underlying evidence, and collapsing
  it would destroy information the instrument exists to preserve.
- **State transition.** The `before_state` → `after_state` pair of the
  successor (`SrsCardState`: `newCard`/`learning`/`review`/`lapsed`,
  `lib/features/learning/domain/entities/srs_card.dart`). A transition
  into `lapsed` is the scheduler's own recorded judgement that the
  item was not retained; a transition sustained in `review` is its
  judgement that it was. This is evidence, not verdict — the
  instrument reports the transition, it does not grade it.
- **Continuity proof.** The requirement that the two events describe
  one uninterrupted lifecycle of the same card, demonstrated by the
  predicate in §Continuity and reset semantics — not assumed from
  adjacency in time, and not assumed from a shared `card_id`. Without
  a continuity proof there is no observation, because the elapsed
  interval would not correspond to a period during which the item was
  actually being retained.

The definition is deliberately **pairwise**. It does not define
"retention" as a property of an item, a plan, a day, or a user; it
defines a single observation about a single interval. Any aggregation
over observations is a separate question this record does not answer
and does not authorize.

## What the instrument measures

Authorized evidence — each item derivable, without inference, from
fields already present in `review_events`:

1. **Elapsed retention interval** — `successor.reviewedAt -
   predecessor.reviewedAt`, wall-clock, per observation.
2. **Raw recall grade** — the successor's `ReviewGrade`, unmapped and
   unweighted.
3. **Review state transition** — `before_state` → `after_state` of the
   successor, and the predecessor's `after_state` that must match it
   under §Continuity and reset semantics.
4. **Scheduled interval / due-date / lateness provenance** — the
   predecessor's `after_interval_days` and `after_due_date` (what the
   scheduler asked for) alongside the successor's `reviewedAt` (what
   actually happened). The difference between them is *lateness*, an
   observable fact of provenance: it records that a review scheduled
   for one moment occurred at another. It is recorded so an
   observation can be read in context — a 60-day interval on a card
   scheduled for 10 days is a different piece of evidence than a
   60-day interval on a card scheduled for 60 — never so that
   lateness can be scored, flagged, or reported back to the user.
5. **Algorithm provenance** — `algorithm_id` of both events
   (`'sm2-v1'`, `'hifz-sm2-capped-v1'`;
   `SchedulingAlgorithm.algorithmId`, deliberately not derived from
   `runtimeType`, per `DR-2026-0024` Decision 4). Carried so that an
   observation spanning an algorithm change remains interpretable, and
   so that a future FSRS migration does not silently reinterpret old
   evidence.
6. **Continuity / discontinuity evidence** — whether a candidate pair
   satisfied the continuity predicate, and, where it did not, that a
   break occurred between two events. A discontinuity is itself
   evidence and is reported as such, not silently dropped.
7. **Derivation counters** — truthful counts describing what the
   derivation actually did: how many events were considered, how many
   observations were emitted, how many pairs were rejected for
   discontinuity, how many events were excluded as ineligible. These
   exist so a caller can distinguish "no retention evidence exists"
   from "evidence exists but was rejected" from "the query was
   mis-scoped" — three conditions that are indistinguishable from an
   empty list alone.

**None of the above may be turned into a score or a verdict.** The
instrument's output is a set of observations plus counters describing
their derivation. It emits no rating, no grade of the user, no
"retained / not retained" boolean over an item, no percentage, and no
single number of any kind. Where a reader wants a judgement, the
instrument's correct behavior is to hand back the evidence and decline
to judge.

## What the instrument does not measure

Explicitly excluded, each for a stated reason:

- **Streaks** — Constitution §15 "Worship First" and the Sprint 7.7
  and 7.8 checkpoints rule out streak framing; §8 names streak length
  specifically as *not* a retention measure. `DR-2026-0026` reached the
  same conclusion for D6.11.
- **Session counts** — §8 names session count specifically as not a
  retention measure; §14 contrasts "what the user still remembers
  months later" against "how many sessions they opened this week."
- **Quiz scores** — §8 names quiz score specifically; Quiz occupies
  the Assessment role (§11), which is explicitly peripheral and never
  a gate.
- **Engagement scores** — §15 "Long-Term Retention": a proposal that
  increases engagement without serving retention is unsupported by the
  Constitution.
- **Achievements** — `DR-2026-0024` §"Explicit non-goals" already
  forbids gamification; `achievement.dart` already records why a
  review-count achievement does not exist.
- **Mastery** — forbidden by `DR-2026-0024` §"Explicit non-goals" and
  `DR-2026-0026` Decision 1, and constitutionally disfavoured under
  §10.
- **Accuracy percentage** — collapsing four raw grades into a ratio
  destroys the distinction the grades exist to record and manufactures
  a score. `LearningStatistics` already discloses its own `accuracy`
  as an approximation; this record does not replace, correct, or
  compete with it (see §Analytics boundary).
- **Aggregate single-number retention score** — the instrument emits
  observations, never a collapsed figure. `HifzReviewHistory`
  established the local precedent by deliberately omitting any field
  that sums its seven buckets, on the stated grounds that such a
  number invites target-setting.
- **Plan attribution** — `DR-2026-0024` Decision 5 is binding: Hifz
  plans may overlap and `srs_cards`' `UNIQUE(item_type, item_id)`
  guarantees one card per Ayah, so no fact exists about which plan
  "caused" a review. No `plan_id`, and no retroactive derivation from
  current plan ranges.
- **Cycle attribution** — `DR-2026-0024` Decision 6: no `cycle_id`, no
  learning-cycle table, no lifecycle model. Resets are *detected*
  (§Continuity and reset semantics), never *named* as cycles.
- **Lemma** — `review_events` structurally contains zero `lemma` rows
  (`DR-2026-0024` Decision 3, enforced at
  `scheduler_repository_impl.dart`). This is data absence, not data
  scarcity. Scope is `ayah` + `hifz` only.
- **Pre-v8 historical reconstruction** — `DR-2026-0024` Decision 10:
  every review before the table existed is permanently unavailable and
  no reconstruction will be invented.
- **Scheduler intent — why an item was queued** — `DR-2026-0021`
  established the Scheduler as deliberately provenance-blind, and
  `DR-2026-0024` restated it: an event records what the scheduler did,
  never why the item was in the queue. The instrument inherits this
  and must not attempt to infer eligibility provenance.
- **Comparison against other users** — no such data exists, and §15
  "Worship First" forbids competitive framing outright.
- **Comparison against targets** — no target, goal, benchmark, or
  "recommended" interval is defined here or may be defined by a
  consumer of this instrument without its own governance.
- **UI presentation** — none, of any kind (see §Governance
  boundaries).
- **User-facing scoring** — the Sprint 7.8 Worship First checkpoint
  requires metrics remain internal and diagnostic and are "never
  surfaced back to the user as a score."

## Options considered

**A. Place the instrument in `analytics/` (or another analytics
tier).** Rejected on two independent grounds. First, governance:
`DR-2026-0024` Decision 14 forbids connecting `review_events` to the
five-tier chain, `DR-2026-0025` restated that prohibition and gated
any future exception behind a five-element requirement, and D6.2
remains in force — routing D7.8 through Analytics would invoke that
gate for a capability that is not an Analytics concern. Second,
substance: `AnalyticsRepository` is defined by its own doc comment as
owning no storage and composing current-state snapshots (`SrsCard`,
`StudySession`); a retention instrument is neither a snapshot nor a
composition of snapshots, and inserting historical, pairwise,
evidence-derived output into that tier would misrepresent what
Analytics is. `DR-2026-0026` rejected the same option, for the same
reasons, for the narrower D6.11 case.

**B. Extend `SchedulerRepository`.** Rejected. `SchedulerRepository`
is the *scheduling-state* interface defined by `DR-2026-0005`, and
`SchedulerRepositoryImpl` is one class instantiated twice (SM-2 and
Hifz variants) serving `ayah`, `hifz` *and* `lemma`. A historical-read
method there would be reachable by every item type — including
`lemma`, which has no events at all — creating generic capability
ahead of evidence and making D7.8's `ayah`+`hifz` scope
unenforceable in practice. `DR-2026-0026` rejected this option
explicitly (its Option B) and its record states the rule this decision
must not break: no new public method on `SchedulerRepository` that a
caller outside the intended scope could reach. It would additionally
place read-only history on the one interface that owns the sole write
path, blurring the append-only boundary `DR-2026-0024` Decision 7
depends on.

**C. Extend `HifzReviewHistoryRepository` (the D6.11 boundary).**
Rejected, and this is the load-bearing rejection. Three reasons, each
sufficient alone:

  1. *Scope.* That boundary is Hifz-only by explicit governance
     (`DR-2026-0026` §"Strict scope"; its interface doc comment
     forbids a generic equivalent). D7.8 covers `ayah` **and** `hifz`.
     Widening D6.11's boundary to `ayah` would silently amend an
     accepted record.
  2. *Shape.* Its single method is `Future<List<int>>
     reviewedAtMsForAyahs(Set<int> ayahOrdinals)` — timestamps only.
     Retention observation needs grade, state, interval, due date and
     algorithm id. Nothing about that method can be extended toward
     retention without redefining it.
  3. *Field governance.* `DR-2026-0026` §"Data sufficiency" states
     that the before/after and `algorithm_id` fields "are **not
     needed** for either metric as defined and **must not be exposed**
     by whatever narrow read boundary a future implementation plan
     designs." Reusing D6.11's boundary for D7.8 would require
     violating that sentence inside the very record that wrote it.
     See §Field-exposure decision.

**D. A new generic review-history repository.** Rejected as premature
and as a re-run of an argument already settled. `DR-2026-0026` Option
D rejected exactly this: "a repository-level abstraction for 'review
history' in general has no evidenced consumer beyond this one Hifz use
case today, and building it now would be exactly the kind of work
D6.9/D6.10 warned against: manufacturing infrastructure because the
data now exists, not because a concrete need does." That reasoning is
unchanged by D7.8. A generic history repository would also make the
`ayah`+`hifz` scope, the field restrictions, and the no-lemma boundary
matters of caller discipline rather than interface shape — the
opposite of what this record is trying to achieve.

**E. A retention-specific, read-only boundary inside
`lib/features/learning/`. Selected.**

Chosen because it is the *narrowest* placement that can express the
capability truthfully, not because it is the most capable:

- **It is where the concept already lives.** `review_events` is owned
  by the `learning` feature — `DR-2026-0024` Decision 2 placed the
  table there precisely because the authoritative write path is
  `SchedulerRepositoryImpl.applyReview`, and `ReviewEvent`,
  `SrsCardState`, `ReviewGrade` and `SchedulingAlgorithm.algorithmId`
  are all already `learning/` domain vocabulary. No new home is
  invented, and no cross-feature dependency is created to read a table
  the feature already owns.
- **It is scoped by shape, not by discipline.** A retention-named
  interface returning retention observations cannot be quietly reused
  as a general history API, the way a generic method on
  `SchedulerRepository` (Option B) or a generic history repository
  (Option D) could be.
- **It follows the precedent D6.11 set** — repository reads raw rows;
  a pure function computes; providers wire the two together
  (`hifz_review_history_repository_impl.dart` →
  `hifz_review_history_calculator.dart` →
  `hifz_review_history_providers.dart`). `DR-2026-0026` §Consequences
  explicitly anticipated that its Option C shape would be referenced
  by later feature-scoped consumers. This is that reference, adapted
  in placement (`learning/`, not `hifz/`) because the scope is
  `ayah`+`hifz`, not Hifz alone.
- **It satisfies Constitution §15 "Minimal Sufficient Change"** — it
  adds a boundary over an existing engine and an existing table,
  rather than introducing a new system.
- **It keeps `DR-2026-0025` uninvoked.** Nothing in `analytics/`,
  `ai_tutor/`, `learning_journey/`, `smart_learning/` or `read_model/`
  is touched, so the five-element Analytics gate does not apply — see
  §Analytics boundary.

## Decision

**A retention-specific, read-only observation boundary inside
`lib/features/learning/` is the architecturally correct home for the
first retention-measurement instrument**, scoped to `item_type`
`ayah` and `hifz`, deriving retention observations as defined above
from the existing `review_events` table without schema change.

The conceptual structure authorized — file paths recorded as the
*intended shape*, subject to refinement by the implementation plan
that this record does not authorize:

```
lib/features/learning/
  domain/entities/retention_observation.dart
      the pairwise observation entity, plus the derivation-evidence
      type carrying counters and discontinuities (§What the
      instrument measures, item 7)
  domain/repositories/retention_event_source_repository.dart
      read-only interface; returns ordered raw event rows for a
      scoped item set; no write/update/delete method, ever
  domain/retention_instrument.dart
      the pure derivation — pairing, continuity checking, interval
      computation; no Drift, no Riverpod, no clock read, explicit
      asOfMs (§Determinism and verification)
  data/retention_event_source_repository_impl.dart
      the Drift implementation; read-only; no insert/update/delete
      statement in the file, now or later
  data/retention_instrument_providers.dart
      provider wiring, in its own file — matching the deliberate
      separation D6.11 used between snapshot and history providers
```

The domain/data split, the pure-calculator boundary, and the separate
providers file follow `hifz_review_history_*`'s established pattern
directly. Exact class names, method signatures, parameter shapes and
file names remain implementation-plan questions (§Open decisions).

**This ADR authorizes the ARCHITECTURAL DIRECTION only. It does not
authorize implementation.** A separate implementation plan and
explicit human approval are still required before any file above is
created. See §Governance boundaries.

## Field-exposure decision

This section is the reason this record exists as its own decision
rather than as an amendment to `DR-2026-0026`.

### What `DR-2026-0026` restricted

`DR-2026-0026` §"Data sufficiency" verified that `card_id`,
`item_type`, `item_id`, `reviewed_at` and `grade` suffice for D6.11's
count and pace metrics, and then restricted the boundary in binding
language: `before_state`, `after_state`, `before_repetitions`,
`after_repetitions`, `before_interval_days`, `after_interval_days`,
`before_ease_factor`, `after_ease_factor`, `before_due_date`,
`after_due_date` and `algorithm_id` "are **not needed** for either
metric as defined and **must not be exposed** by whatever narrow read
boundary a future implementation plan designs — exposing unused fields
would widen the boundary past what this record justifies."

D6.11's implementation honored this exactly:
`HifzReviewHistoryRepository.reviewedAtMsForAyahs` returns
`Future<List<int>>` — timestamps, nothing else. The restriction is
live in code, not merely on paper.

### Why D7.8 cannot reuse the D6.11 boundary

Because retention *is* a before/after question and D6.11's metric is
not. D6.11 counts occurrences; occurrences need a timestamp. D7.8
measures whether an item survived an interval; that needs to know the
interval was continuous, what state the card was in at each end, and
which algorithm produced the schedule. The restricted fields are not
decoration on D7.8's metric — they are its evidence and its proof of
validity. There is no version of a retention observation that can be
computed from timestamps alone.

Three further reasons make reuse improper even setting sufficiency
aside: D6.11 is Hifz-only and D7.8 is `ayah`+`hifz`; D6.11's method
signature cannot carry the required data without being redefined; and
extending an accepted record's boundary by implementation choice is
precisely the "documentation drift" risk `DR-2026-0025` named.

### Why this is a new governance decision

`DR-2026-0026`'s restriction was correct *for the boundary it
governed* and remains in force there: nothing in this record permits
D6.11's boundary to widen, and its restriction on the
`hifz_review_history_*` surface is untouched. What this record does is
create a **separate boundary with a separate, independently justified
field list**, governed by its own justification rather than by
inheritance.

That distinction is essential and is stated plainly so it cannot be
misread later: **this is not an exception granted to D6.11's rule; it
is a different boundary that D6.11's rule does not govern.** The
governing principle both records share — *a read boundary exposes
exactly the fields its metric requires and no more* — is upheld by
both, and produces different field lists because the metrics differ.

### Why the fields are necessary and minimally sufficient

Field-by-field necessity, with no field admitted for convenience:

| Field | Why D7.8 requires it |
|---|---|
| `card_id` | Continuity predicate term; distinguishes same-item events across card identities |
| `item_type`, `item_id` | Observation identity; scope filter; index prefix |
| `reviewed_at` | The elapsed interval itself — the measurement (§Algorithm agnosticism) |
| `grade` | The recall outcome at interval end — the observed evidence |
| `before_state` / `after_state` | State transition evidence; continuity proof (predecessor `after_state` must equal successor `before_state`) |
| `before_repetitions` / `after_repetitions` | Continuity proof; detects the reset that `syncItemsForType` performs |
| `before_interval_days` / `after_interval_days` | Continuity proof; scheduled-interval provenance |
| `before_due_date` / `after_due_date` | Continuity proof; due-date and lateness provenance |
| `algorithm_id` | Algorithm provenance; keeps observations interpretable across an SM-2 → FSRS change |

**Minimally sufficient, demonstrated by exclusion.**
`before_ease_factor` and `after_ease_factor` — restricted by
`DR-2026-0026` and *also excluded here* — are **not** authorized by
this record. They are SM-2-specific tuning parameters, they appear in
no term of the continuity predicate (§Continuity and reset semantics),
they are not required for the elapsed interval or the recall outcome,
and admitting them would additionally invite floating-point equality
comparison in a correctness-critical predicate. Excluding them also
reinforces §Algorithm agnosticism: an FSRS-era event has no meaningful
ease factor, and an instrument that depended on one would not survive
the change `scheduling_algorithm.dart` already anticipates.

The field list is therefore not "everything D6.11 refused" — it is
"everything the retention observation and its continuity proof
require," which happens to be nine of D6.11's eleven restricted
fields, and demonstrably not the other two.

### The boundary remains read-only

Absolutely and permanently:

- The interface exposes **query only** — no append, no update, no
  delete, no soft-delete, no correction. `DR-2026-0024` Decision 7
  (immutability) and Decision 2 (single write path via
  `applyReview`) are preserved without qualification.
- The implementation file must contain no insert/update/delete
  statement, now or in any later edit — the same standing constraint
  D6.11's implementation states in its own doc comment.
- Reading richer fields grants **no** authority to write them, and no
  authority to write anything else.

### This does not authorize generic historical access

Exposing these fields to *this* boundary authorizes nothing beyond it:

- No generic review-history repository (Option D remains rejected).
- No new method on `SchedulerRepository` (Option B remains rejected).
- No widening of D6.11's Hifz boundary (its restriction stands).
- No `lemma` access, at any field level.
- No access from any of the five Analytics-chain features
  (§Analytics boundary).
- No general "read `review_events`" capability for future callers; a
  future consumer wanting different fields, a different scope, or a
  different metric requires its own decision record, exactly as this
  one did.

## Data sufficiency

Verified against the repository at `f2df50b`:

- **`schemaVersion` remains 8.** No change proposed
  (`lib/core/database/user/user_database.dart`).
- **No schema migration.** Nothing is added to the v8 `onUpgrade`
  branch or to any table.
- **No new column.** Every field in §Field-exposure decision already
  exists in `ReviewEvents` (`lib/core/database/user/user_tables.dart`).
- **No new index.** `@TableIndex(name: 'idx_review_events_item',
  columns: {#itemType, #itemId, #reviewedAt})` is exactly the
  item/type/time ordering this instrument requires: the `(item_type,
  item_id)` prefix serves the scope filter and the trailing
  `reviewed_at` serves the chronological ordering that pairing
  depends on. D6.11's implementation already relies on this same
  prefix and records in its own comment that no additional index was
  needed. `idx_review_events_reviewed_at` remains available for
  time-range scoping. No speculative index is proposed.
- **No backfill.** `DR-2026-0024` Decision 10 is binding and
  restated: reviews performed before the table existed are
  permanently unavailable, and no reconstruction will be invented.
  The v8 migration comment says the same in the schema itself.
- **History begins only from the real data accumulated after
  `review_events` was introduced.** A consequence that must be stated
  rather than hidden: the earliest possible retention observation
  requires *two* committed events after v8 shipped, so the instrument
  will legitimately return empty results for a period after any
  implementation, and will return nothing at all for items reviewed
  once or never. This is truthful scarcity, not a defect, and must
  not be papered over with estimates, extrapolation, or a synthesized
  first event (§Determinism and verification).

`PROJ-P-002` is therefore not triggered by this record, because no
schema change is proposed. That absence removes one gate; it does not
remove the plan-then-approval sequence (§Governance boundaries).

## Analytics boundary

- **D7.8 is NOT an Analytics consumer.** It reads `review_events`
  inside `lib/features/learning/`, the feature that already owns the
  table, and produces domain observations that no analytics tier
  consumes.
- **It must not enter** `lib/features/analytics/`,
  `lib/features/ai_tutor/`, `lib/features/learning_journey/`,
  `lib/features/smart_learning/`, or `lib/features/read_model/`.
  Those five remain exactly as forbidden as `DR-2026-0024` Decision
  14, `DR-2026-0025`, and D6.2 already make them.
- **`DR-2026-0025`'s five-element Analytics gate is therefore not
  invoked by this decision.** That gate governs records that would
  authorize Analytics consumption of `review_events`. This record
  authorizes no such thing, so the gate is neither satisfied,
  triggered, partially met, nor bypassed — it simply does not apply.
  This must not be misread later as D7.8 having "cleared" it.
- **This ADR does not authorize any future Analytics consumption.**
  Nothing here may be cited as precedent, groundwork, or partial
  approval for connecting retention observations — or `review_events`
  in any other form — to the five-tier chain.
- **Any future Analytics consumer requires its own governance path
  under `DR-2026-0025`**, satisfying all five elements of that
  record's gate in a new, separately accepted decision record.
  `DR-2026-0025` states that no single record may serve as blanket
  future authorization; this one certainly does not.
- **Current analytics behavior is unchanged.** `AnalyticsRepository`
  and `LearningStatistics` remain authoritative for their own
  metrics. `LearningStatistics`' documented `reviewsToday`/`accuracy`
  approximations are an accepted characteristic of that design; this
  record does not correct, deprecate, replace, or compete with them,
  and the existence of a retention instrument creates no obligation
  or permission to revisit them.

## Worship-First

Checked explicitly against `STUDY_ARCHITECTURE_CONSTITUTION.md` §15
("Worship First"), §14, §8, and the Sprint 7.8 Worship First
checkpoint ("Confirm metrics remain internal and diagnostic, and are
never surfaced back to the user as a score").

The instrument is compatible **only** in the following form, and each
constraint is binding on any implementation plan that follows:

- **Internal only.** Output is consumed by code, not by users.
- **Diagnostic only.** It exists to make durable recall *observable to
  the project*, not to inform, motivate, or direct the user.
- **No user-facing score.** No number derived from it may be
  presented to the user by anything this record authorizes — and this
  record authorizes no presentation at all.
- **No ranking.** No ordering of items, plans, days, or users by
  retention quality.
- **No target.** No goal interval, no "recommended" spacing, no
  threshold above or below which retention is deemed adequate.
- **No "good/bad" verdict.** An `again` grade after 40 days is
  evidence, not failure. A `lapsed` transition is the scheduler's
  recorded state change, not a judgement on the user.
- **No streak framing.** No consecutive-success counting, no
  unbroken-chain concept, no "kept" or "lost" language.
- **No gamification.** No achievements, badges, levels, points, or
  rewards.
- **No UI.** None is designed, authorized, or implied.
- **No pressure to optimize worship behavior around a metric.** The
  instrument must never become something the user manages, protects,
  or performs for.

The framing this record adopts, stated for future readers who may be
tempted to soften it: **the instrument measures evidence of durable
recall; it does not define the user's religious success.** Sincere
engagement with the Qur'an is not what this or any instrument
measures, and a low, sparse, or empty retention record is not a
statement about a person. The Hifz Progress screen's existing stated
intent — a truthful description, not an achievement — is the register
this instrument must be built in, one step further removed from the
user because it is not shown at all.

## Dormant-consumer property

**The instrument may initially have no production caller.** This is
stated up front as a property of the design, not discovered later as a
defect.

Why this is accepted here, when "an abstraction with no requirement"
would ordinarily be rejected — and D6.9/D6.10 did reject exactly that
reasoning for other candidates:

1. **Sprint 7.8 explicitly separates logging from later reporting.**
   Its one-line scope is "Logging first; reporting deferred until
   there's enough data to warrant it." A deliverable that reads
   accumulated evidence before a report exists to display it is the
   roadmap's stated sequencing, not a departure from it.
2. **`review_events` accumulates real historical evidence
   independently** of whether anything reads it. Every committed
   review has been writing rows since D6.6 shipped, driven by
   `applyReview`, with no dependency on this instrument. Evidence
   accrues on its own timeline.
3. **The instrument can later consume accumulated history.** Because
   the data is already being recorded, an instrument built now
   becomes useful the moment enough intervals have elapsed — without
   needing a backfill that `DR-2026-0024` Decision 10 makes
   impossible. Building the reader before the evidence matures is the
   only ordering available; the reverse ordering (wait for a
   consumer, then build) does not shorten the wait, because the wait
   is on wall-clock time, not on code.
4. **The dormancy is intentional and governed, not accidental
   architecture.** It is declared in this record, bounded by this
   record's scope, and constrained by this record's field list — not
   an unowned artifact that accumulated by neglect. It is
   distinguishable from ordinary dead code precisely because a
   decision record explains what it is for and what may activate it.
5. **This is different from inventing an abstraction with no
   requirement.** The requirement is named in the Constitution — §8
   states retention is the module's objective and that no instrument
   exists — and in the roadmap, which keeps Sprint 7.8 open. The gap
   is documented in the governing sources, not inferred from the
   existence of a table. This distinction is exactly the one D6.9 and
   D6.10 applied when they rejected candidates justified only by
   "the data now exists"; D7.8's justification is a stated
   constitutional obligation, which those candidates lacked.
6. **Future activation requires an independently authorized
   consumer.** Nothing here authorizes a caller, a screen, an
   analytics tie-in, or a report. When a consumer is proposed, it
   passes through its own governance — and if it is an Analytics
   consumer, through `DR-2026-0025`'s five-element gate.

A residual honesty requirement follows: dormant code that is never
activated is a cost, and this record does not pretend otherwise. See
§Risks and §Open decisions #1.

## Continuity and reset semantics

**Two events may be paired into a retention observation only when
continuity between them is provable.** Adjacency in time is not
continuity, and a shared `card_id` is not continuity.

The continuity predicate must require **all** of the following between
predecessor *p* and successor *s*:

- same `item_type`
- same `item_id`
- same `card_id`
- `p.after_state == s.before_state`
- `p.after_repetitions == s.before_repetitions`
- `p.after_interval_days == s.before_interval_days`
- `p.after_due_date == s.before_due_date`

When the predicate fails:

- **Do not emit a retention observation across the break.** The
  elapsed interval across a discontinuity does not measure retention
  of anything — it spans a period during which the card's scheduling
  identity was replaced.
- **Record a discontinuity in the diagnostic evidence** (§What the
  instrument measures, items 6 and 7). The break is a fact about the
  history and must be visible to the caller, not silently swallowed:
  an empty result caused by discontinuity is materially different from
  an empty result caused by absent data.

### Why `card_id` alone is not a lifecycle identity

`DR-2026-0024` Decision 6 is binding and states the mechanism:
`SchedulerRepositoryImpl.syncItemsForType` **revives the same
`srs_cards.id`** and resets it to `initialState()` when an item
re-enters the membership set. Deleting a Hifz plan and recreating the
same range therefore returns the *identical card id with wiped
progress* — behavior the product surfaces to users in its own delete
dialog ("Adding the same range again starts fresh — it does not
continue where this left off").

The consequence for this instrument is severe and specific: two events
sharing a `card_id`, ordered correctly in time, may nonetheless sit on
opposite sides of a full progress reset. Pairing them would compute an
elapsed interval spanning a period in which the card was deleted,
revived, and restarted from `newCard` — and would report, as evidence
of retention over months, an interval that measures nothing of the
kind. That is fabrication, which every existing Hifz snapshot doc
comment in this codebase explicitly refuses.

### Why before/after state is what detects the reset

`DR-2026-0024` Decision 6 also supplies the remedy, and this record
adopts it exactly as intended: "Storing full before-state makes a
reset *detectable* as a discontinuity — an event whose `before_*` does
not match the previous event's `after_*` for the same card — which is
sufficient to avoid silently presenting two cycles as one continuous
history, without inventing a domain concept ahead of the domain."

A revive-and-reset writes `initialState()` into the card. The next
event's `before_*` therefore reflects that initial state, while the
prior event's `after_*` reflects wherever the card had progressed to.
The mismatch is mechanical, local, and requires no new field, no
`cycle_id`, and no lifecycle model — which is precisely why
`DR-2026-0024` refused to introduce one. The instrument detects the
break and declines to pair across it. It does **not** name what lies
on either side "a cycle," because the product has no user-facing
learning-cycle concept to model.

Note that the four state terms are compared as exact equalities over
integers, an enum-backed string, and an epoch-millisecond integer —
all exactly comparable. This is a further reason the ease factors
(`double`) are excluded from both the predicate and the boundary
(§Field-exposure decision).

## Algorithm agnosticism

**Deriving elapsed retention from the current SM-2 due-date formula is
explicitly rejected.**

The instrument must derive the elapsed retention interval as:

```
elapsed = successor.reviewed_at - predecessor.reviewed_at
```

and by no other means. In particular it must not compute elapsed time
from `after_interval_days`, from `after_due_date`, from ease-factor
progression, or from any reconstruction of what SM-2 would have
scheduled.

The reasons are cumulative:

1. **Scheduled time is not survived time.** `after_interval_days` and
   `after_due_date` record what the scheduler *asked for*. Users
   review early and late. An instrument that measured the schedule
   would measure the algorithm's intent, not the user's retention —
   the exact substitution Constitution §8 forbids when it distinguishes
   durable recall from activity.
2. **The algorithm is explicitly expected to change.**
   `lib/features/learning/domain/scheduling_algorithm.dart` documents
   the intent to replace SM-2 with FSRS, and `DR-2026-0024` Decision 4
   stored `after_*` rather than recomputing it for exactly this
   reason, adding `algorithm_id` "so that old events remain
   interpretable after such a change." An instrument built on SM-2's
   formula would silently break, or worse silently misreport, at that
   migration.
3. **Two algorithms already coexist.** `'sm2-v1'` and
   `'hifz-sm2-capped-v1'` both write events today
   (`SchedulerRepositoryImpl` is instantiated twice), and
   `HifzSchedulingAlgorithm.maxIntervalDays` is a tunable constant. A
   formula-derived interval would already be ambiguous across the two.
4. **`reviewed_at` is unambiguous.** It is epoch milliseconds UTC,
   written from the same `nowMs()` value as `srs_cards.updated_at`
   inside the same transaction (`DR-2026-0024` Decision 13), so the
   two are guaranteed to agree.

The requirement, stated as a durable constraint on implementation:
**the instrument must remain correct without modification if the
scheduling algorithm changes to FSRS or to anything else.**
`algorithm_id` is carried as provenance so an observation can be
*read* in the context of the algorithm that produced its schedule —
never so that the algorithm's arithmetic can be re-derived.

## Determinism and verification

Authorized, and required of any implementation plan that follows:

- **Explicit `asOfMs`.** Any time-relative behavior takes an explicit
  epoch-millisecond parameter supplied by the caller. This follows the
  established local discipline: `computeHifzReviewHistory` takes
  `required DateTime now` and its doc comment states it does not read
  the system clock, matching `computeHifzPlanProgress` and
  `SchedulingAlgorithm`.
- **No implicit clock in the pure calculator.** No `DateTime.now()`,
  no ambient time source, no hidden default. A calculator that reads
  the clock cannot be tested deterministically and cannot be reasoned
  about across time zones or DST boundaries.
- **Deterministic ordering.** Events must be ordered by a total,
  reproducible ordering — `reviewed_at` ascending, with a documented,
  stable tie-break for events sharing a millisecond (possible in
  principle: `reviewed_at` has no uniqueness constraint, and
  `ReviewEvents` deliberately declares no `uniqueKeys`). The same
  input must always produce the same observations in the same order.
- **No future-data leakage.** Events with `reviewed_at > asOfMs` must
  be excluded from derivation entirely. An observation must never be
  informed by evidence that did not exist at the stated observation
  time — otherwise the instrument cannot be used to reason about any
  point in the past, and tests over fixed fixtures become
  irreproducible.
- **Raw grades.** Grades are carried through as `ReviewGrade` values,
  never mapped to booleans, weights, points, or percentages
  (§What the instrument does not measure).
- **Evidence counters.** Derivation counters are part of the output,
  not logging. They make the derivation auditable: a caller can
  distinguish absent data, rejected pairs, and out-of-scope input.
- **Truthful empty results.** When no retention observation can be
  derived, the instrument returns empty — with counters explaining
  why. It must not estimate, extrapolate, substitute a single-event
  proxy, synthesize a first event, or fall back to `srs_cards`
  current state. This matches the refusal-to-fabricate discipline
  already stated across `HifzPlanProgress`, `HifzOverallProgress` and
  `LearningStatistics`.
- **No invented minimum-history threshold.** The instrument must not
  define a minimum number of observations below which it reports
  nothing, nor a "not enough data" verdict of its own invention. Two
  continuous events are one observation; that is the honest floor, and
  any judgement about sufficiency belongs to a caller with a stated
  reason, not to the instrument.

## Non-goals

This record does **not** authorize, and explicitly excludes — including
every relevant non-goal inherited from `DR-2026-0024` and
`DR-2026-0025`:

- Code, of any kind, including the files named in §Decision.
- Tests.
- An implementation plan (its preparation is the *next* gate, not an
  authorization granted here).
- Any **retention rollup**, aggregate, summary table, materialized
  view, or derived-metric storage.
- Any **Analytics integration**, or any change to `analytics/`,
  `ai_tutor/`, `learning_journey/`, `smart_learning/`, `read_model/`.
- Any **UI**, screen, widget, chart, string, or l10n key.
- **Plan attribution** or **cycle attribution**; no `plan_id`, no
  `cycle_id`, no learning-cycle model, no historical plan-membership
  representation.
- **Lemma emission** or lemma access; `DR-2026-0024` Decision 3's
  deferral stands untouched, and its identity-contract prerequisites
  are not addressed here.
- **Cloud sync**; `DR-2026-0024` Open Decision #3 remains open.
- **Backfill** or historical reconstruction of any kind.
- **Schema work**: no migration, no column, no index, no
  `schemaVersion` change; `PROJ-P-002` is not engaged because nothing
  requiring it is proposed.
- **Scheduler changes**: no modification to `SchedulerRepository`,
  `SchedulerRepositoryImpl`, `applyReview`, `syncItemsForType`,
  `SchedulingAlgorithm`, or either algorithm implementation.
- **Any change to D6.11**: `HifzReviewHistoryRepository`, its
  implementation, `computeHifzReviewHistory`, `HifzReviewHistory`,
  its providers, its tests, and `DR-2026-0026`'s field restriction all
  stand exactly as they are.
- Mastery, accuracy percentage, streaks, gamification, achievements,
  leaderboards, recommendations, or any user-facing score.
- Modification of `review_events` immutability, its single write path,
  or its `deleted_at` semantics.

## Open decisions

Deliberately unresolved. Where the Session 2 architecture pass
produced a clear recommendation, it is recorded **as a recommendation
for the implementation plan to resolve**, not as an accepted decision —
because this record does not need to decide it, and pretending
otherwise would settle implementation questions under architectural
authority.

1. **Dormant-code property — how long, and what happens if no
   consumer ever appears?** §Dormant-consumer property accepts
   dormancy as intentional and governed. What is *not* decided:
   whether a review date should be set at which an unused instrument
   is reconsidered or removed, and who makes that call.
   *Recommendation:* state the expectation explicitly in the
   implementation plan rather than letting it accumulate silently.

2. **Unknown grade handling.** `grade` is stored as a plain string
   (`ReviewGrade.name`) with no database-level constraint, so a value
   outside `again`/`hard`/`good`/`easy` is representable in principle,
   as is an unrecognized `state` string. *Recommendation:* fail
   loudly, or record the row as ineligible with a counter — never
   silently coerce to a default, and specifically never repeat the
   write path's `?? LearningItemType.ayah` fallback pattern in a
   read-and-measure context, where a silent default would fabricate
   evidence. Which of "reject with counter" or "throw" is correct is
   an implementation-plan decision.

3. **Lemma rejection behavior.** `review_events` structurally contains
   no `lemma` rows, so a lemma-scoped query cannot return data. Not
   decided: whether the boundary should refuse a lemma-typed request
   explicitly (assert/throw), return empty with a counter, or make
   lemma unrepresentable in the parameter type. *Recommendation:*
   prefer making it unrepresentable if the type system allows it
   cleanly, since that removes the question rather than answering it —
   but the implementation plan decides.

4. **Provider wiring test location.** The repository's tests live in a
   flat `test/` directory, and D6.11 shipped three separate files
   (`hifz_review_history_repository_test.dart`,
   `hifz_review_history_calculator_test.dart`,
   `hifz_review_history_provider_test.dart`). *Recommendation:* mirror
   that three-way split. Not decided here, because test organization
   is an implementation-plan and testing-guide concern, not an
   architectural one.

5. **Whether `sinceMs` should be pre-authorized.** A time-lower-bound
   query parameter would let a caller scope to recent history and is
   supported by the existing `idx_review_events_reviewed_at` index.
   **Deliberately not pre-authorized here.** It is not required by the
   retention definition, and adding an unused query parameter would
   widen the boundary on the same reasoning `DR-2026-0026` used to
   restrict fields. If the implementation plan finds a concrete need,
   it must justify it there; it may not be added silently because it
   "seems useful."

Inherited and still open, unaffected by this record: `DR-2026-0024`
Open Decisions #1 (plan-level Hifz history need), #2 (`lemma`
emission timing and identity contract), #3 (sync strategy under
`PROJ-P-004`), #4 (user-data erasure policy for historical events),
and #5 as narrowed by `DR-2026-0025` (whether and when Analytics ever
consumes events).

## Governance boundaries

This ADR:

- **Authorizes** the retention-observation architectural direction —
  the definition, the placement inside `lib/features/learning/`, the
  read-only boundary shape, and the field list in §Field-exposure
  decision — *accepted by the human reviewer; this is now the binding
  architectural direction for D7.8.*
- **Does not authorize code.** No file named in §Decision may be
  created on the strength of this record.
- **Does not automatically authorize an implementation plan.**
  Acceptance permits a plan to be *prepared*; the plan is itself a
  deliverable requiring its own explicit human approval before any
  code follows.
- **Does not authorize Analytics consumption** — see §Analytics
  boundary; `DR-2026-0025`'s gate is untouched and uninvoked.
- **Does not authorize UI** of any kind.
- **Does not authorize future extensions** — not lemma, not generic
  history access, not a rollup, not plan/cycle attribution, not a
  wider field list, not an additional consumer. Each requires its own
  record.
- **Does not modify any existing record.** `DR-2026-0024`,
  `DR-2026-0025`, `DR-2026-0026`, `DR-2026-0005`, `DR-2026-0021`,
  D6.2, the Study Architecture Constitution, and
  `MILESTONE_7_STUDY_ROADMAP.md` are all left exactly as they stand.

**Status is `accepted`, and the limits above are load-bearing.**
Acceptance settles the architectural direction and nothing else. It
must not be cited — now or later — as authorization for code, for an
implementation plan's execution, for Analytics consumption, for UI, or
for any extension this record names as forbidden.

### Next gate

Now that this ADR is accepted, a following
session may prepare a standalone implementation plan under
`docs/release/`. Code implementation remains **forbidden** until that
implementation plan itself receives explicit human approval — the same
ADR → plan → approval → implementation → audit sequence this project
used for D6.6 and D6.11, with no step skipped or merged.

## Consequences

- Gives Constitution §8's explicitly named gap ("no
  retention-measurement instrument exists in the product today") a
  concrete, evidenced, architecturally bounded path toward being
  filled — without pre-committing to when it is built or what
  consumes it.
- Establishes the first governed precedent for a `review_events`
  consumer that reads **evidence fields**, not merely occurrence
  timestamps, and sets the reasoning pattern (per-boundary field
  justification, not inheritance) that any future such consumer must
  follow.
- Deliberately narrows future flexibility: a later implementation
  plan must stay inside this record's scope (`ayah`+`hifz`), field
  list (nine before/after and provenance fields, excluding both ease
  factors), placement (`learning/`), and framing (internal,
  diagnostic, unscored). Redesigning any of those requires amending
  or superseding this record, not reinterpreting it.
- Adds no code, no storage, no coupling and no runtime surface today;
  the working tree is unaffected beyond this document.
- Leaves D6.11 and every accepted record untouched and in force.

## Risks

- **Dormant code that is never activated.** Accepted knowingly
  (§Dormant-consumer property), but real: an instrument with no
  caller is maintenance surface that pays no dividend until evidence
  matures and a consumer is authorized. Mitigation is honesty about
  the property plus Open Decision #1; it is not eliminated.
- **Field-list creep.** Having argued that nine restricted fields are
  necessary here, the next proposal will find it easier to argue for
  the tenth and eleventh. Mitigation: §Field-exposure decision
  demonstrates minimal sufficiency by *excluding* the ease factors,
  establishing that the test is necessity, not availability.
- **Misreading this record as an exception to `DR-2026-0026`.** It is
  not — it is a separate boundary that record does not govern.
  Mitigation: stated explicitly in §Field-exposure decision; remains
  a documentation-discipline risk, as `DR-2026-0025` already observed
  for its own boundary.
- **Pressure to add a score once observations exist.** The single
  most likely drift: an observation set invites collapsing into a
  percentage or a "retention rate." Mitigation: §What the instrument
  does not measure and §Worship-First are binding on any
  implementation plan and must be re-checked at plan review, not
  assumed.
- **Silent pairing across a reset.** A consumer or implementation
  that groups by `card_id` alone would report intervals spanning a
  revive-and-reset as retention. Mitigation: the mandatory continuity
  predicate (§Continuity and reset semantics); the trap remains for
  anyone who ignores it, exactly as `DR-2026-0024` Decision 6 warned.
- **Algorithm-formula shortcut.** Deriving elapsed time from
  `after_interval_days`/`after_due_date` is easier to write and
  wrong. Mitigation: §Algorithm agnosticism states the required
  derivation explicitly; enforced by review discipline, not tooling.
- **Empty or sparse results being misread as a defect.** Because no
  backfill is possible and two continuous events are required, early
  results will be thin. Mitigation: derivation counters and truthful
  empty results (§Determinism and verification); an
  implementation-plan-level concern for any eventual caller, not an
  architecture defect.
- **Scope drift toward `lemma` "since the boundary already exists."**
  The same pressure `DR-2026-0024` named. Mitigation: `lemma` is a
  data *absence*, not a filter; §Non-goals and Open Decision #3.

## Evidence and references

All paths verified directly against the repository at `f2df50b`
(`schemaVersion` 8) while writing this record.

**Governing sources**

- `docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md` §8 (Role of
  Retention — the objective, the measured-over-time standard, and the
  explicit statement that no retention-measurement instrument exists
  today), §14 (Long-Term Vision — "what the user still remembers
  months later"), §15 (Architecture Principles — Minimal Sufficient
  Change, Long-Term Retention, Worship First).
- `docs/release/MILESTONE_7_STUDY_ROADMAP.md` — Sprint 7.8 (Learning
  Analytics Foundation: scope, "Not started" status, the statement
  that D6.6/`DR-2026-0024` does not satisfy this sprint, and the
  Worship First checkpoint requiring metrics stay internal and
  diagnostic).
- `PROJECT_CONSTITUTION.md`,
  `constitution/PROJ-P-002-dual-database-separation.md`,
  `constitution/PROJ-P-004-rls-mandatory-for-cloud-sync.md`,
  `CLAUDE.md` §"Stop and ask before" — the schema and sync gates,
  neither of which this record engages.

**Decision records**

- `docs/adr/DR-2026-0024-srs-review-event-storage.md` — Decision 3
  (`ayah`/`hifz` emission, `lemma` deferral), Decision 4 (event shape
  and `algorithm_id` provenance), Decision 5 (no `plan_id`),
  Decision 6 (`card_id` is not a lifecycle identity; before-state
  makes resets detectable — the basis of §Continuity and reset
  semantics), Decision 7 (immutability), Decision 8 (atomicity),
  Decision 10 (no backfill), Decision 12 (the two indexes),
  Decision 13 (time semantics), Decision 14 (analytics boundary),
  Decision 15 (no UI), and its Open Decisions #1–#5.
- `docs/adr/DR-2026-0025-analytics-review-event-consumption-boundary.md` —
  the five-element future gate for Analytics consumption, and the
  binding list of five forbidden feature directories; not invoked by
  this record.
- `docs/adr/DR-2026-0026-hifz-historical-review-count-and-pace.md` —
  §"Strict scope" (Hifz-only), §"Options considered" (rejection of
  Analytics routing, generic `SchedulerRepository` reads, and a
  generic history repository — reused here as Options A, B and D),
  Decision 1 (count is attempts, not correctness or retention), and
  §"Data sufficiency" (the field restriction this record addresses
  head-on in §Field-exposure decision).
- `docs/adr/DR-2026-0005.md` (Scheduler/SM-2 architecture),
  `docs/adr/DR-2026-0021-automatic-retention-seeding.md` (the
  provenance-blind Scheduler), `docs/adr/README.md` (record index and
  amendment conventions).

**Storage — `review_events` at schema v8**

- `lib/core/database/user/user_database.dart` — `schemaVersion => 8`;
  the additive v8 `onUpgrade` branch creating `reviewEvents`,
  `idxReviewEventsItem` and `idxReviewEventsReviewedAt`, with its
  in-schema no-backfill comment.
- `lib/core/database/user/user_tables.dart` — `class ReviewEvents
  extends Table with SyncColumns`; `@DataClassName('ReviewEventRow')`;
  `@TableIndex(name: 'idx_review_events_item', columns: {#itemType,
  #itemId, #reviewedAt})` and `@TableIndex(name:
  'idx_review_events_reviewed_at', columns: {#reviewedAt})` — the
  index sufficiency claim in §Data sufficiency; the full column list
  behind §Field-exposure decision; and the deliberate absence of
  `uniqueKeys`.

**Domain — `ReviewEvent` and its non-consumption**

- `lib/features/learning/domain/entities/review_event.dart` — the
  seventeen-field immutable entity, its `ayah`/`hifz`-only doc
  comment, and its stated absence of `planId`/`cycleId`. Verified to
  have **zero references and zero imports** anywhere in `lib/` or
  `test/`.
- `lib/features/learning/data/scheduler_repository_impl.dart` —
  `applyReview`'s single `_db.transaction(...)` writing the
  `srs_cards` UPDATE and `ReviewEventsCompanion.insert` together, the
  `ayah`/`hifz` emission gate with its "do not widen this" comment,
  and `syncItemsForType`'s revive-and-reset behavior behind
  §Continuity and reset semantics.
- `lib/features/learning/domain/scheduling_algorithm.dart` —
  `enum ReviewGrade { again, hard, good, easy }`,
  `SchedulingInput`/`SchedulingResult`, `algorithmId`, and the
  documented intent to replace SM-2 with FSRS behind §Algorithm
  agnosticism.
- `lib/features/learning/domain/entities/srs_card.dart` —
  `enum SrsCardState { newCard, learning, review, lapsed }` and its
  `toDbValue()` codec (`new`/`learning`/`review`/`lapsed`).
- `lib/features/learning/domain/sm2_scheduling_algorithm.dart`,
  `lib/features/learning/domain/hifz_scheduling_algorithm.dart` —
  `'sm2-v1'` and `'hifz-sm2-capped-v1'`, the two `algorithm_id` values
  present in the data today.

**D6.11 precedent — shape reused, boundary not**

- `lib/features/hifz/domain/repositories/hifz_review_history_repository.dart`
  — `Future<List<int>> reviewedAtMsForAyahs(Set<int> ayahOrdinals)`;
  read-only by declaration; its doc comment forbidding a generic
  equivalent on `SchedulerRepository`. The evidence that D6.11 exposes
  timestamps only.
- `lib/features/hifz/data/hifz_review_history_repository_impl.dart` —
  read-only Drift implementation; filters `item_type='hifz'`, orders
  by `reviewed_at` ascending, uses the existing
  `idx_review_events_item` prefix and states that no new index was
  needed.
- `lib/features/hifz/domain/hifz_review_history_calculator.dart` —
  pure function taking `required DateTime now`, explicitly reading no
  system clock; the determinism precedent adopted in §Determinism and
  verification.
- `lib/features/hifz/data/hifz_review_history_providers.dart` — the
  deliberate separation of history providers from snapshot providers.
- `lib/features/hifz/domain/entities/hifz_review_history.dart` — the
  "review attempts, not mastery/accuracy/score" framing, and the
  deliberate omission of any field collapsing its buckets into one
  number.
- `test/hifz_review_history_repository_test.dart`,
  `test/hifz_review_history_calculator_test.dart`,
  `test/hifz_review_history_provider_test.dart`,
  `test/review_events_migration_test.dart` — the existing three-way
  test split referenced in Open Decision #4.

**Analytics tiers — named to be excluded**

- `lib/features/analytics/domain/analytics_repository.dart`,
  `lib/features/analytics/domain/entities/learning_statistics.dart`,
  `lib/features/analytics/domain/entities/achievement.dart` — the
  current-state composition discipline, the documented
  `reviewsToday`/`accuracy` approximations left unchanged by this
  record, and the existing admission that no lifetime review counter
  exists.
- `lib/features/ai_tutor/`, `lib/features/learning_journey/`,
  `lib/features/smart_learning/`, `lib/features/read_model/` — the
  four further tiers this record must not enter.
