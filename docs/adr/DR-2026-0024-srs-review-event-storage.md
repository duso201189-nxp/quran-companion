---
id: DR-2026-0024
scope: project
owner_role: data-owner
date: 2026-08-15
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: hard
threshold_reason: [hard-to-reverse, materially-different-approaches, constrains-future-architecture]
links:
  task: "D6.5 — Hifz review event / history architecture investigation"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0024 — SRS review event storage

**Status of this record: proposed, not accepted.** It records an
architecture and authorizes nothing: no schema change, no migration, no
Dart code, no UI, no analytics integration. The schema change it
describes is additionally gated by `PROJ-P-002`
(`PROJECT_CONSTITUTION.md`; `CLAUDE.md` §"Stop and ask before": *"Any
schema change to either database"*), which is a separate human approval
this record does not and cannot satisfy. See §Governance boundaries.

## Relationship to existing records

`DR-2026-0005` (Learning Engine architecture — Scheduler/SM-2) defined
`SchedulerRepository` and the `srs_cards` table as **scheduling state**.
This record does not change that. It adds a second, disjoint concept —
an append-only record of what happened — and explicitly does not
relocate, duplicate, or reinterpret any field of `srs_cards`.

`DR-2026-0021` (Automatic Retention Seeding) established that the
Scheduler is deliberately provenance-blind: it receives an opaque
`List<int>` and cannot distinguish how an item became eligible. This
record preserves that. A review event records *what the scheduler did*,
never *why the item was in the queue*.

`DR-2026-0003` (Sprint 8 data architecture) established the Group-B
table conventions this record follows without deviation: client-generated
UUID primary keys, `SyncColumns` (`user_id`/`updated_at`/`deleted_at`/
`is_dirty`), epoch-millisecond-UTC integer timestamps, and no
Drift-level foreign keys.

No existing record is superseded or amended.

## The question this record answers

> Where, and in what shape, should Qur'an Companion persist the fact
> that an SRS review happened — given that `srs_cards` stores only the
> latest state and overwrites everything else?

It answers that one question. It does not answer what should be built on
top of the resulting data, when, or for whom.

## Context

Three Hifz reporting capabilities ship today, all of them
**current-state only**, all of them explicit about that in their own
doc comments:

- **D5** — per-plan snapshot (`HifzPlanProgress`,
  `computeHifzPlanProgress`, `HifzProgressScreen`).
- **D6.4** — all-active-plans aggregate snapshot
  (`HifzOverallProgress`, `computeHifzOverallProgress`,
  `hifzOverallProgressProvider`, the summary card in `HifzPlansScreen`).
- **D6.2** — the binding decision that Hifz analytics stay inside the
  Hifz feature boundary and are *not* inserted into
  `AnalyticsRepository`/`LearningStatistics`.

Each of those deliberately refuses to fabricate history. `srs_cards`
cannot support history: it stores the latest state and nothing else.
`LearningStatistics`' own doc comment already concedes that
`reviewsToday` and `accuracy` are approximations for exactly this
reason, and `achievement.dart` records that no "100 Reviews" achievement
exists because `repetitions` resets to `0` on a wrong answer and is
therefore not a lifetime counter.

The D6.5 investigation traced the complete review write path and found
that everything needed to record a truthful event — except plan
identity — is already in scope at a single point, and that no new
infrastructure (transactions, uuid generation, injectable clocks,
append-only table precedent) needs to be invented.

## Problem — what is destroyed by every review

`SchedulerRepositoryImpl.applyReview(cardId, grade)`
(`lib/features/learning/data/scheduler_repository_impl.dart`) reads the
row, computes the next state via the injected `SchedulingAlgorithm`, and
overwrites the row. That `UPDATE` permanently destroys:

- **the grade** — consumed by the algorithm, never persisted anywhere;
- **the before-state** — ease factor, interval, repetitions, state,
  due date, all overwritten in place;
- **the occurrence of the review itself** — `updated_at` is
  overwritten, so *N* reviews in one day are indistinguishable from one;
- **all prior review timestamps** — only the most recent survives;
- **the lifetime review count** — `repetitions` resets to `0` on
  `again`;
- **which Hifz plan(s) were active** at that moment.

None of this is reconstructible from `srs_cards`. Any attempt to derive
it would be fabrication, which every existing Hifz snapshot doc comment
in this codebase explicitly refuses.

## Conceptual boundaries

Three distinct concepts, deliberately kept separate:

| Concept | Question it answers | Where it lives |
|---|---|---|
| **Current snapshot** (D5, D6.4) | *What is the state right now?* | Derived live from `srs_cards`; no storage of its own |
| **Scheduling state** (`DR-2026-0005`) | *When is this card next due?* | `srs_cards`, mutable, soft-deletable, resettable |
| **Review history** (this record) | *What happened, when, and with what result?* | A new append-only table; immutable |

This record does not replace or redefine the first two. A snapshot
remains a snapshot after history exists; history does not make snapshots
more accurate, and snapshots do not become historical.

## Options Considered

**Option A — a Hifz-specific `hifz_review_events` table.**
Semantically correct, but a poor fit for the actual code.
`SchedulerRepositoryImpl` is a *single class instantiated twice* — once
with `SM2SchedulingAlgorithm` via `schedulerRepositoryProvider`, once
with `HifzSchedulingAlgorithm` via `hifzSchedulerRepositoryProvider`.
`applyReview` does not know which instance it is and only learns the
item type by reading the row. Scoping the table to Hifz would require an
`if (itemType == hifz)` special case *inside a deliberately generic
repository*, adding a branch to shared scheduling code in order to
narrow a table. Rejected.

**Option B — a generic `review_events` table keyed by `item_type`.**
Matches the shape of the write path that already exists. The row being
mutated already carries `item_type`, so genericity costs one column of
data that is already in hand and requires no branching. Chosen — with
the emission policy scoped separately from the storage model (Decision
3): the *table* is generic, the *set of item types written to it in v1*
is a deliberate, narrower architectural boundary.

**Option C — extend `srs_cards`.** Rejected outright.
`srs_cards` is current-state by definition, and `syncItemsForType`
soft-deletes and *resets* rows as membership changes — history stored
there would be destroyed by ordinary synchronization.

**Option D — full event sourcing (rebuild card state from events).**
Rejected as grossly disproportionate. It would require rewriting the
Scheduler, the Revision Queue, Flashcards, and Hifz simultaneously, for
no capability this project has asked for.

Option B is chosen because it is **smaller**, not because it is more
general. This is the unusual case where the generic option is the one
that adds less code.

## Decision

1. **Definition.** A `ReviewEvent` is *the immutable record of one
   committed state transition of one SRS card caused by one user grade
   at one instant.* It is a persisted domain fact — not a button press,
   not a scheduling calculation, not a UI interaction. It exists only
   when the state transition actually commits. In particular,
   `applyReview`'s existing `if (row == null) return;` early return
   (grading a soft-deleted card is a silent no-op) must produce **no**
   event, because it produces no state change.

2. **Storage.** A new append-only table `review_events` in
   `UserDatabase` (Group B), owned by the `learning` feature, because
   the authoritative write path lives in
   `SchedulerRepositoryImpl.applyReview`. It follows the `quiz_results`
   precedent: `SyncColumns` plus a distinct domain timestamp
   (`quiz_results.taken_at` ↔ `review_events.reviewed_at`).

3. **Generic storage model, deliberately scoped v1 emission policy.**
   These are two separate decisions and must not be collapsed into one.

   *Storage model — generic.* The table is keyed by `item_type` +
   `item_id` and is capable of holding events for any
   `LearningItemType`, per Option B. No Hifz-specific history table and
   no lemma-specific history table is introduced, now or later; a
   second history table for a second item type would be the very
   duplication Option A was rejected for.

   *Emission policy — scoped.* v1 persists events for exactly two item
   types:

   | `item_type` | v1 policy |
   |---|---|
   | `ayah` | **persisted** — identity is the global Ayah ordinal (1..6236), canonically fixed |
   | `hifz` | **persisted** — Ayah-scoped, so it inherits that same stable identity |
   | `lemma` | **deferred** — see *Why lemma is deferred* below |

   This is an intentional architectural boundary, not a temporary
   implementation omission and not a scope cut to be quietly reversed
   during implementation. Widening it requires the identity contract
   below, not merely deleting a condition.

   **Why lemma is deferred — an identity-contract problem, not a
   convenience cut.**

   `srs_cards.item_id` means different things per `item_type`. For
   `ayah` and `hifz` it is the global Ayah ordinal 1..6236 — an identity
   fixed by the Mushaf itself, which no content rebuild can reassign.
   For `lemma` it references `lemmas.id` in **AppDatabase** (Group A), a
   plain integer primary key produced by the content build from an
   imported morphology source.

   The precise problem is an absence, and must be stated as such:
   **there is currently no documented repository-level identity
   guarantee sufficient to make immutable lemma history safely
   authoritative across content rebuilds.** This record does *not*
   claim that lemma ids do change, or will change — only that nothing
   in the repository presently promises they will not.

   That absence is tolerable for current state and intolerable for
   immutable history, and the asymmetry is the whole argument:

   - **Current SRS state self-heals.** `syncItemsForType` reconciles
     `srs_cards` against the current lemma set on every read, creating,
     reviving, or soft-deleting rows to match. A reassigned identifier
     is corrected by ordinary operation.
   - **Immutable history cannot self-heal.** Decision 7 forbids
     rewriting events. If an identifier were reassigned by a future
     content rebuild, an immutable event carrying only that identifier
     could no longer be *proven* to refer to the same lexical entity —
     and the record could not be corrected without violating its own
     immutability guarantee.

   Ayah events are safe because Ayah identity is the stable global
   ordinal; Hifz events are safe because they are Ayah-scoped and
   inherit that same identity. Lemma events are deferred until the
   project establishes and governs a stable lemma identity contract.

   **Prerequisites for enabling lemma emission** (a separate future
   decision; none of these is designed here): (1) a stable lemma
   identity contract; (2) content-rebuild semantics for that identity;
   (3) migration/reconciliation rules should identity change; (4) tests
   proving historical references remain authoritative across a rebuild.

   No new identity field is invented in this record to work around the
   deferral. The event shape in Decision 4 is unchanged.

4. **Conceptual shape.** No table is created by this record. The
   recommended columns are:

   | Group | Columns |
   |---|---|
   | Sync | *(SyncColumns)* `id`, `user_id`, `updated_at`, `deleted_at`, `is_dirty` |
   | Identity | `card_id`, `item_type`, `item_id` |
   | Time | `reviewed_at` (epoch ms UTC) |
   | Input | `grade` |
   | Provenance | `algorithm_id` |
   | Before | `before_state`, `before_repetitions`, `before_interval_days`, `before_ease_factor`, `before_due_date` |
   | After | `after_state`, `after_repetitions`, `after_interval_days`, `after_ease_factor`, `after_due_date` |

   The event must explain what happened **without depending on the
   future mutable state of `srs_cards`**. `after_*` is stored rather
   than recomputed because `HifzSchedulingAlgorithm.maxIntervalDays` is
   a tunable constant and `scheduling_algorithm.dart` explicitly
   anticipates replacing SM-2 with FSRS; `algorithm_id` exists so that
   old events remain interpretable after such a change.

   **Sprint D6.6 §11 update — the source contract now exists, storage
   does not.** `SchedulingAlgorithm` (domain code, no schema involved)
   now exposes `String get algorithmId`, deliberately **not** derived
   from `runtimeType` — a class rename must never silently rewrite
   historical provenance. `SM2SchedulingAlgorithm.algorithmId` returns
   `'sm2-v1'`; `HifzSchedulingAlgorithm.algorithmId` returns
   `'hifz-sm2-capped-v1'`. The versioning rule is binding: the `-vN`
   suffix must be bumped whenever a change alters what `review()` or
   `initialState()` would output for the same inputs — thresholds,
   formulas, tunable constants (including `maxIntervalDays`), ease
   deltas, or the quality mapping — enforced by manual code-review
   discipline, not by any automated mechanism. This resolves what
   `algorithm_id` will read at write time; it does **not** create the
   `review_events` column, the table, or any writer of it — the source
   value now exists ahead of the sink it is destined for, and the sink
   remains exactly as unimplemented as everything else in this record.
   No field is added beyond these without a repository convention
   requiring it.

5. **No `plan_id`. Binding.** Hifz plans may overlap —
   `HifzPlanRepository.createPlan` documents overlapping ranges as
   valid — and `srs_cards`' `UNIQUE(item_type, item_id)` guarantees one
   card per Ayah regardless of how many plans cover it (the
   deduplication `hifzUnionAyahIdsProvider` and D6.4 both rely on).
   A review of that single card is genuinely caused by, and genuinely
   serves, every plan covering the Ayah. Recording one `plan_id` would
   assert a fact that is not true. The v1 event model is therefore
   **Ayah/card-scoped, not plan-scoped**. Plan-level historical
   attribution is deferred; if it is ever required it must be designed
   as a historical membership representation captured at review time,
   **never** reconstructed from current plan ranges — plan ranges are
   immutable but plan creation dates are not, so retroactive derivation
   would attribute old reviews to plans created afterwards.

6. **`card_id` is not a learning-cycle identity.**
   `SchedulerRepositoryImpl.syncItemsForType` *revives the same
   `srs_cards.id`* and resets it to `initialState()` when an item
   re-enters the membership set. Deleting a Hifz plan and recreating the
   same range therefore returns the identical card id with wiped
   progress — behaviour the product surfaces to users in the delete
   dialog ("Adding the same range again starts fresh — it does not
   continue where this left off"). `card_id` alone must never be read as
   a permanent learning-cycle identity. This record introduces **no**
   `cycle_id`, no learning-cycle table, and no lifecycle event model,
   because the product has no user-facing learning-cycle concept to
   model. Storing full before-state makes a reset *detectable* as a
   discontinuity — an event whose `before_*` does not match the previous
   event's `after_*` for the same card — which is sufficient to avoid
   silently presenting two cycles as one continuous history, without
   inventing a domain concept ahead of the domain.

7. **Immutability.** Events are append-only historical facts. The
   eventual repository exposes **append** and **query** only, with no
   ordinary update operation. Historical grades and transitions must not
   be rewritten because a plan was paused, completed, or deleted;
   because a card was reset; or because the scheduling algorithm
   changed. If correction semantics are ever required, compensating
   events are the mechanism to consider — that mechanism is **not**
   designed here. `deleted_at` is inherited from `SyncColumns` for
   convention and future sync compatibility, and is reserved
   exclusively for user-initiated privacy erasure (Decision 9), never
   for ordinary history edits.

8. **Atomicity.** Required invariant: the `srs_cards` update and the
   event insert either both persist or neither does. The intended
   boundary is `SchedulerRepositoryImpl.applyReview` wrapped in the
   existing Drift transaction mechanism (`_db.transaction(...)`, already
   used in `FlashcardRepositoryImpl` and
   `BookmarkCollectionRepositoryImpl`), with the event created inside
   the same transaction as the state update. Both writes target the same
   `UserDatabase`, so one transaction suffices — no cross-database
   coordination, which `PROJ-P-002` would forbid in any case. This
   record does not implement it.

9. **Lifecycle semantics.** Historical activity does not disappear
   because current state changed:

   | Trigger | Effect on events |
   |---|---|
   | Plan paused | Unaffected |
   | Plan completed | Unaffected |
   | Plan soft-deleted | Unaffected |
   | SRS card soft-deleted | Unaffected |
   | SRS card revived / reset | Prior events remain; discontinuity detectable per Decision 6 |
   | Ayah content changes (Group A) | Unaffected — events store the stable ordinal identity, never duplicated Qur'an text (`PROJ-P-002`) |
   | User data deletion | **Undefined here** — the actual erasure policy is future privacy/sync governance under `PROJ-P-004` |

   No cascade from `hifz_plans` or `srs_cards` to `review_events`.

10. **No backfill. Historical data cannot be reconstructed.** Stated
    unambiguously: **every review performed before this table exists is
    permanently unavailable.** `srs_cards` holds current state only.
    Previous grades, previous states, previous intervals, previous ease
    factors, individual review occurrences, historical timestamps, and
    true lifetime review counts are all irrecoverable. No backfill will
    be attempted and no reconstructed history will be invented. This is
    stronger than the "no backfill" notes recorded at schema v4, v6, and
    v7 — there, backfill was *unnecessary*; here it is *impossible*.

11. **Schema version.** Implementation would require `schemaVersion`
    7 → 8, one additive `review_events` table, and the indexes in
    Decision 12. No changes to any existing table, column, or foreign
    key. **This record does not authorize that change** — see
    §Governance boundaries.

12. **Indexes.** Only two are currently justified:
    `(item_type, item_id, reviewed_at)` for per-item history and
    per-type filtering, and `(reviewed_at)` for time-range and
    day-bucketing queries. No speculative indexes, no rollup tables, no
    retention system, no analytics materializations.

13. **Time semantics.** `reviewed_at` is an `IntColumn` of epoch
    milliseconds UTC, sourced from the same injected `nowMs()` value
    already computed inside `applyReview` and written to `updated_at` —
    guaranteeing the two agree. This introduces no second time
    representation; it is the convention used by every timestamp in
    `user_tables.dart`.

14. **Analytics boundary — binding.** Creating `review_events` does
    **not** authorize integration with `AnalyticsRepository`,
    `LearningStatistics`, AI Tutor, Learning Journey, Smart Learning,
    Study Summary, or `read_model`. **D6.2 remains in force.** Event
    storage and analytics consumption are separate architectural
    decisions; whether the five-tier chain should ever consume events is
    a future decision of the same class as D6.2, not an automatic
    consequence of this one. The new event model must not be silently
    connected to that chain.

15. **No UI.** This record designs and authorizes no user interface.

## Consequences

- One additive table at schema v8; no existing table, column, index, or
  foreign key is modified. `srs_cards` semantics are unchanged.
- `applyReview` gains a transaction wrapper and one insert. Its public
  signature, its scheduling behaviour, and every algorithm remain
  unchanged. The UI (`HifzReviewScreen`) is untouched and gains no new
  responsibility — it cannot own event persistence under this design.
- D5 and D6.4 snapshots are unaffected in behaviour and in meaning.
- Events accrue for `ayah` reviews as well as `hifz` (Decision 3).
  Ayah events have no consumer yet; accumulating them is accepted
  because Ayah identity is stable and because excluding them would cost
  a condition without buying correctness. `lemma` reviews write no
  event in v1 and therefore leave no history — a known, accepted,
  documented gap rather than an oversight.
- Reversibility is **hard**: once the table ships and users accumulate
  events, it cannot be withdrawn without destroying real user history.
  This is the principal reason the record is `proposed` rather than
  self-approving.
- Growth is modest: at ~50 reviews/day a learner produces ~18k rows per
  year — well within SQLite's comfortable range. `HifzSchedulingAlgorithm`'s
  30-day interval cap raises steady-state review frequency by design
  (~12 reviews/card/year vs ~2 uncapped), which is intentional and still
  bounded.
- Cloud sync is **not implemented** today (no `lib/features/sync/`;
  `is_dirty`/`updated_at` are forward-compatibility scaffolding). An
  append-only, immutable, higher-volume table has materially different
  sync characteristics from the mutable last-write-wins tables that
  exist now. `PROJ-P-004` must address this when sync begins; it does
  not block schema v8.

### Capabilities this would eventually enable

Enumerated as *architectural capability*, not as committed features —
none of these is implemented, designed, or scheduled by this record:

daily and weekly review counts · a review timeline · grade distribution
· honest review accuracy (the first this project could truthfully
compute) · state-transition history · interval progression · ease
progression · lifetime review count per Ayah · an SRS review streak
distinct from the existing reading streak · Ayah-level history.

### Explicit non-goals

This decision does **not** introduce: mastery percentage or mastery
score; gamification or leaderboards; plan-level history; `cycle_id` or
any learning-cycle model; review duration capture; analytics
integration; any history UI; historical backfill; retention or rollup
infrastructure; cloud sync implementation.

Mastery scoring and gamification are not merely out of scope but
constitutionally disfavoured: `STUDY_ARCHITECTURE_CONSTITUTION.md` §10
and the Sprint 7.7 "Worship First" checkpoint rule out
leaderboard/score/streak-pressure framing, and both `HifzProgressScreen`
and D6.4's summary card already cite that constraint as the reason they
show state distributions rather than a single collapsed number.

## Risks

- **Silent history corruption if atomicity is skipped.** A card updated
  without its event (or vice versa) yields history that is wrong rather
  than merely absent. Decision 8 is not optional.
- **Misreading `card_id` as a cycle identity.** The revive-and-reset
  behaviour is easy to miss; a future consumer that groups purely by
  `card_id` would silently merge unrelated learning cycles. Decision 6
  mitigates by storing before-state, but the trap remains for anyone who
  ignores it.
- **Pressure to enable `lemma` emission "since the column already
  exists."** The generic storage model makes widening emission look
  like a one-line change. It is not: it requires the identity contract
  in Decision 3, without which lemma history cannot be proven
  authoritative across a content rebuild — and cannot be repaired
  afterwards, because Decision 7 forbids rewriting events.
- **Pressure to add `plan_id` later "for convenience."** Doing so would
  record false data under overlap. Decision 5 is binding precisely
  because the shortcut is tempting.
- **Pressure to connect events to the five-tier analytics chain**
  because the data now exists. Decision 14 forbids it absent a separate
  decision.
- **Hard reversibility.** Shipping the table is a durable commitment to
  storing this data for every user.

## Open decisions

Deliberately unresolved; none is quietly settled by this record:

1. **Is plan-level Hifz history actually required?** If yes, the
   historical membership representation must be designed *before* v8
   ships, because it cannot be derived retroactively (Decision 5).
2. **When should `lemma` emission be enabled?** *Not* whether v1 covers
   it — that is settled: v1 is `ayah` **yes**, `hifz` **yes**, `lemma`
   **deferred** (Decision 3). What remains open is the separate,
   later identity decision that would unblock it: establishing a stable
   lemma identity contract and its rebuild/reconciliation semantics.
   Until that decision exists, lemma emission stays off; it is not a
   flag to flip during implementation.
3. **Sync strategy for an immutable append-only table** under
   `PROJ-P-004`.
4. **User-data erasure policy** for historical events (Decision 9).
5. **Whether analytics should ever consume events** — a future decision
   of D6.2's class (Decision 14).

## Evidence and references

All paths verified against the repository at the time of writing.

- `lib/features/learning/data/scheduler_repository_impl.dart` —
  `applyReview` (the authoritative write path; before-state read,
  algorithm call, overwriting `UPDATE`, and the `row == null` early
  return), and `syncItemsForType` (the revive-and-reset branch behind
  Decision 6).
- `lib/features/learning/domain/repositories/scheduler_repository.dart`,
  `lib/features/learning/domain/scheduling_algorithm.dart` —
  `ReviewGrade`, `SchedulingInput`/`SchedulingResult`, the documented
  intent to replace SM-2 with FSRS, and (Sprint D6.6 §11, implemented)
  `SchedulingAlgorithm.algorithmId` — `'sm2-v1'`
  (`sm2_scheduling_algorithm.dart`) and `'hifz-sm2-capped-v1'`
  (`hifz_scheduling_algorithm.dart`) — the concrete values `algorithm_id`
  will hold once `review_events` exists.
- `lib/features/learning/domain/entities/srs_card.dart` —
  `LearningItemType` (`ayah`/`lemma`/`hifz`) and the `updated_at`
  doc comment stating it is overwritten and is *not* a review history.
- `lib/features/hifz/data/hifz_providers.dart` —
  `hifzSchedulerRepositoryProvider` (the second `SchedulerRepositoryImpl`
  instance behind Option A's rejection), `hifzUnionAyahIdsProvider` and
  `hifzActiveAyahIdsProvider` (deduplication behind Decision 5).
- `lib/features/hifz/domain/repositories/hifz_plan_repository.dart` —
  overlapping ranges documented as valid.
- `lib/core/database/user/user_tables.dart` — `SyncColumns`,
  `SrsCards` (`UNIQUE(item_type, item_id)`), and `QuizResults`, the
  existing append-only precedent this shape follows.
- `lib/core/database/tables/content_tables.dart` — `Lemmas.id`, a plain
  content-build integer primary key in Group A, carrying no documented
  stability guarantee across rebuilds; the basis for the lemma deferral
  in Decision 3. Contrast `srs_cards.item_id` for `ayah`/`hifz`, which
  is the global Ayah ordinal (`lib/core/quran/ayah_ordinal.dart`,
  `HifzPlan.ayahOrdinals`).
- `lib/core/database/user/user_database.dart` — `schemaVersion => 7`
  and the additive-only `onUpgrade` convention.
- `lib/features/flashcards/data/flashcard_repository_impl.dart`,
  `lib/features/library/data/bookmark_collection_repository_impl.dart`
  — the existing `_db.transaction(...)` idiom behind Decision 8.
- `lib/features/analytics/domain/entities/learning_statistics.dart`,
  `lib/features/analytics/domain/entities/achievement.dart` — existing
  admissions that history does not exist.
- `lib/features/hifz/domain/entities/hifz_plan_progress.dart`,
  `lib/features/hifz/domain/entities/hifz_overall_progress.dart` — D5
  and D6.4 snapshots, and their explicit refusal to fabricate history.
- `docs/architecture/DATABASE_REFERENCE.md` — table catalogue, the
  `srs_cards` entry, and the migration history table.
- `constitution/PROJ-P-002-dual-database-separation.md`,
  `constitution/PROJ-P-004-rls-mandatory-for-cloud-sync.md`,
  `PROJECT_CONSTITUTION.md`, `CLAUDE.md` §"Stop and ask before".
- `docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md` §10 —
  the constraint behind the gamification non-goals.

## Governance boundaries

**"Architecture approved" is not "implementation authorized."** Even
when this record reaches `status: accepted`, implementation remains
blocked by a separate gate:

> Any schema change to either database requires explicit human approval
> under `PROJ-P-002` (`CLAUDE.md` §"Stop and ask before").

Accepting this record settles *what the architecture should be*. It does
not settle *that it should be built now*. Schema v8 requires its own
approval, obtained separately and after this record is accepted.

Until both gates pass, the correct state of the repository is: no
`review_events` table, no migration, no `schemaVersion` change, no
change to `applyReview`, and no consumer of any kind.
