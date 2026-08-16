---
id: DR-2026-0026
scope: project
owner_role: data-owner
date: 2026-08-16
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-15
reversibility: soft
threshold_reason: [materially-different-approaches, constrains-future-architecture]
links:
  task: "D6.11 — architecture for the first evidence-backed review_events consumer (D6.10 discovery)"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0026 — Hifz historical review count and review pace (read boundary)

**Status of this record: accepted.** It is a governance decision only.
Acceptance does **not** authorize code: no
read API, no repository method, no `AnalyticsRepository` change, no
UI, no schema change, no migration, no test. Every one of those is a
separate, later authorization — see "Non-goals" and "Governance
boundaries" below. This mirrors the discipline this project already
used for `review_events` itself: DR-2026-0024 (architecture) →
implementation plan → `PROJ-P-002` approval → implementation → audit
→ commit, never architecture-acceptance-as-code-authorization.

## Context

D6.6 (`DR-2026-0024`, accepted) shipped `review_events` — an
append-only, immutable log of committed SRS review outcomes for
`item_type` `ayah`/`hifz` — with zero consumers. `DR-2026-0025`
(accepted) then settled that Analytics *may* one day consume
`review_events`, but only through its own future, separately gated
decision, and explicitly stated that acceptance authorized nothing.

D6.8 and D6.10 (discovery-only, independently reviewed) searched the
repository for the first real, evidence-backed consumer. D6.9
concluded the leading Analytics candidate (`PerformanceInsights.
fastestImproving`) was **not** worth building: it is lemma-scoped, and
`review_events` v1 structurally contains zero `lemma` rows (Decision 3,
DR-2026-0024) — not a data-quality gap, a data-*absence* one. D6.10
then searched outside Analytics and found exactly one candidate with
concrete, self-documented repository evidence:

- `lib/features/hifz/domain/entities/hifz_plan_progress.dart:6-13` and
  `lib/features/hifz/domain/entities/hifz_overall_progress.dart:7-16`
  each state, in their own doc comments, that `HifzPlanProgress`/
  `HifzOverallProgress` are current-state snapshots only, and that
  "mastery/accuracy/streak/tổng lượt ôn" (total review count) "cần
  lịch sử sự kiện chưa tồn tại trong schema hiện tại" (require event
  history that does not exist in the current schema) — written before
  `review_events` existed, describing exactly the gap it now fills.
- `lib/l10n/app_en.arb:187` (`hifzProgressSnapshotNote`) is a
  **user-visible string**, shown today on the Hifz Progress screen:
  *"This is a current snapshot, not a review history."* This is not
  an internal comment; it is an admitted limitation the app currently
  states to the user.
- `lib/features/learning/domain/sm2_scheduling_algorithm.dart:38-41` —
  `SM2SchedulingAlgorithm.review()` resets `repetitions = 0` on any
  `again` grade. This makes "how many times has this card actually
  been reviewed" **structurally unrecoverable** from `srs_cards` alone,
  under any amount of computation — not an approximation that could be
  improved, an absence that only an append-only log can fill.

No equivalent evidence was found for Ayah (no dedicated Ayah progress
surface exists; Ayah `SrsCard`s are folded into the mixed, lemma+ayah
`LearningStatistics` in `analytics/`), for streak/consistency framing
(see "Worship-First compliance" below — actively prohibited, not just
unevidenced), or for any of AI Tutor / Learning Journey / Smart
Learning / Study Summary / `read_model` (D6.9 and D6.10 both confirmed
these tiers only compose already-existing Analytics output and touch
nothing new).

## Strict scope

**In scope:** Hifz only; the existing `review_events` table and its
existing fields, unchanged; historical total review count; historical
review pace; the existing `HifzPlanProgress`/`HifzOverallProgress`
entities and the existing Hifz Progress screen; descriptive
presentation only.

**Out of scope, explicitly:** Ayah historical analytics;
`AnalyticsRepository`; `LearningStatistics`; AI Tutor; Learning
Journey; Smart Learning; Study Summary; `read_model`; any new
user-facing review-timeline/history screen; a "mastery" score; an
"accuracy" score; streaks; gamification; recommendations;
leaderboards; `plan_id`; `cycle_id`; `lemma`; cloud sync; schema
changes; migrations; backfill; new `review_events` columns.

## Options considered — read boundary

**A. Route through `AnalyticsRepository`.**
Rejected. This is the exact path `DR-2026-0025` deliberately did not
authorize, and the use case here is Hifz-specific, not an Analytics
concern — routing it through Analytics would cross D6.2's boundary for
no benefit and trigger `DR-2026-0025`'s five-element future gate for a
feature that doesn't need it.

**B. A generic `SchedulerRepository` read API.**
Rejected as premature. `SchedulerRepository` currently serves both
`ayah` and `hifz` (and `lemma`) through one shared implementation
class (`SchedulerRepositoryImpl`, instantiated twice — once per
algorithm). Adding a generic historical-read method there would
create a capability usable by any item type, including `lemma` and
Ayah, before any evidence justifies those — exactly the "premature
generic infrastructure" risk named below. It would also make the
Hifz-only scope of this decision harder to enforce mechanically (a
generic method invites generic future callers).

**C. A Hifz-specific historical read boundary.**
**Selected.** Scoped precisely to the evidenced use case — a read path
that only ever answers "how many `review_events` rows exist, and when,
for this Hifz card/scope" — living alongside the existing
`hifz/`+`learning/` code that already computes `HifzPlanProgress`/
`HifzOverallProgress` from `SrsCard` snapshots. It composes into the
existing pipeline (`hifz_progress_calculator.dart` already takes
pre-filtered data from its caller, per its own documented discipline)
without inventing a new general-purpose repository. Smallest boundary
that serves the actual evidenced need.

**D. A new generic review-history repository.**
Rejected as premature for the same reason as B, at larger scope — a
repository-level abstraction for "review history" in general has no
evidenced consumer beyond this one Hifz use case today, and building
it now would be exactly the kind of work D6.9/D6.10 warned against:
manufacturing infrastructure because the data now exists, not because
a concrete need does.

The future implementation plan (not authorized by this record) must
place the new read capability inside `lib/features/hifz/` and/or
`lib/features/learning/data/` — not inside `lib/features/analytics/`
or any of the four tiers above it — and must not add a new public
method to `SchedulerRepository`'s existing interface that a caller
outside Hifz could reach. The exact class/method name is left to that
future implementation plan (see "Open questions").

## Decision

**A narrow, Hifz-only historical read capability over the existing
`review_events` table is architecturally justified**, to support
exactly two descriptive metrics, replacing the admitted limitation
`hifzProgressSnapshotNote` currently states to the user. This decision
authorizes the *architecture*, not the code — see "Governance
boundaries."

### 1. Historical review event count

Defined as: the count of immutable `review_events` rows matching a
given Hifz scope (a card, or a set of cards resolved the same way
`HifzPlanProgress`/`HifzOverallProgress` already resolve their card
sets today — see "Plan-level semantic boundary"). This is categorically
different from `SrsCard.repetitions`: `repetitions` is a *current,
resettable* streak counter (reset to 0 by `SM2SchedulingAlgorithm` on
`again` — evidence above); the `review_events` count is a *permanent,
monotonically increasing* historical fact. The metric must not be
named or presented as "mastery," "success rate," "accuracy," or
"performance" — it counts *attempts*, not correctness or retention.

### 2. Historical review pace

The minimum honest shape, decided now: a count of `review_events` rows
grouped into a time window (day/week — exact granularity left open,
see "Open questions"), presented as a historical activity fact with
**no target, no streak, no reward, and no comparison** (to other
users, to a goal, or to a prior period framed as "better/worse"). This
mirrors `HistoryBucket`'s existing shape in `analytics/`
(period-bucketed counts, no scoring) rather than inventing a new
presentation pattern — reusing a proven shape, not because
`HistoryBucket` itself may be touched (it must not be — it belongs to
`analytics/`), but because its *pattern* (bucket + count, no judgment)
is the right precedent to follow when the future implementation plan
designs this.

The exact window length, exact bucketing rule, and exact chart/list
presentation are **not decided here** — they are implementation-plan
questions, not architecture questions, per this record's own
instruction not to pretend precision that isn't justified yet.

## Plan-level semantic boundary

**This record does not authorize attributing historical review count
to a specific Hifz plan**, and states explicitly why: `DR-2026-0024`
Decision 5 deliberately rejected `plan_id` because
`HifzPlanRepository.createPlan` permits overlapping plans, and
`UNIQUE(item_type, item_id)` on `srs_cards` guarantees one physical
card serves every plan that includes that Ayah — there is no fact of
the matter about which plan "caused" a given review when two plans
share a card. `review_events` inherits this: it has no `plan_id`
either, correctly.

What **is** truthful and already has precedent: aggregating by the
*current* card-set resolution `HifzOverallProgress` already uses today
— `hifzActiveAyahIdsProvider`'s deduplicated-by-ordinal-set approach
(cited in D6.10's evidence, `hifz_progress_calculator.dart:43-61`).
This answers "how many reviews have happened across the Ayahs
currently in my active plans," not "how many reviews happened under
plan X" — a scope, not an attribution. A single-plan (`HifzPlanProgress`)
view is truthful for exactly the same reason `HifzPlanProgress` itself
already is: it counts the cards in *that* plan's `ayahOrdinals` today,
consistent with `HifzPlanRepository.createPlan`'s existing permission
for overlapping plan ranges ("Đoạn TRÙNG hoặc CHỒNG LẤN kế hoạch đang
có là HỢP LỆ" —
`lib/features/hifz/domain/repositories/hifz_plan_repository.dart:25-27`,
also cited in `DR-2026-0024`'s own evidence) — a card belonging to
more than one plan is not a new edge case this record introduces. This
record does **not** invent new semantics beyond what
`HifzPlanProgress`/`HifzOverallProgress` already establish — it only
adds a historical count/pace over the same, already-resolved card set.

If a future implementation plan cannot express this without inventing
new plan-membership semantics beyond what exists today, it must say so
and stop — **not** solve it by adding `plan_id` or any retroactive
plan-ownership concept.

## Worship-First compliance

Explicitly checked against `docs/architecture/
STUDY_ARCHITECTURE_CONSTITUTION.md:185` ("Worship First" — no
gamification, streaks, rankings, or competitive framing; engagement
is never the goal) and `docs/release/MILESTONE_7_STUDY_ROADMAP.md:81`
("Confirm no leaderboard, streak-pressure, or competitive framing is
introduced around memorization").

This decision is compatible **only** in the descriptive form defined
above. It must not:

- Present a higher count or faster pace as inherently better.
- Introduce a target, goal, streak, or reward tied to review count.
- Compare a user's pace to any other user, to an average, or to a
  "recommended" rate.
- Reframe the existing Hifz Progress screen's own stated design intent
  — "một mô tả trung thực, không phải một thành tích" (a truthful
  description, not an achievement), `hifz_progress_screen.dart:25-30`
  — which this decision extends, not replaces.

Any future implementation plan or UI design that violates this
compatibility requires its own separate re-examination against the
constitution before proceeding — this ADR's acceptance does not
pre-clear that check.

## Data sufficiency

Verified against the actual D6.6 schema (`lib/core/database/user/
user_tables.dart`, `ReviewEvents` class): `card_id`, `item_type`,
`item_id`, `reviewed_at`, and `grade` are sufficient for both metrics
defined above — a `COUNT(*)` grouped by the resolved card set answers
review count; the same query grouped additionally by a `reviewed_at`
time bucket answers review pace. `before_state`/`after_state`/
`before_repetitions`/`after_repetitions`/`before_interval_days`/
`after_interval_days`/`before_ease_factor`/`after_ease_factor`/
`before_due_date`/`after_due_date`/`algorithm_id` are **not needed**
for either metric as defined and must not be exposed by whatever
narrow read boundary a future implementation plan designs — exposing
unused fields would widen the boundary past what this record justifies.
**No schema change or new column is proposed or required.**

## Governance boundaries

- **Preserves D6.2, `DR-2026-0024`, and `DR-2026-0025` unmodified.**
  This record adds a new, separate, Hifz-scoped path; it does not
  touch, weaken, or reinterpret any of their decisions.
- **Authorizes no code.** No repository method, no read API, no
  `HifzPlanProgress`/`HifzOverallProgress` field, no UI, no schema
  change, no migration, no test.
- **Does not authorize itself as implementation authorization.**
  Acceptance settles the architecture question only. Per this
  project's established discipline (D6.6's own ADR → implementation
  plan → `PROJ-P-002`-class approval → implementation → audit →
  commit sequence), a concrete implementation plan must exist and be
  separately approved before any code is written. No `PROJ-P-002` gate
  applies to that future plan specifically *because* no schema change
  is proposed here — but the plan-then-approval sequence still applies
  as this project's general practice for any change to `review_events`
  consumption.
- **Does not authorize any of the four other tiers.** `ai_tutor/`,
  `learning_journey/`, `smart_learning/`, `read_model/` remain exactly
  as untouched by this record as by `DR-2026-0025`.

## Consequences

- Gives the Hifz Progress screen's admitted limitation
  (`hifzProgressSnapshotNote`) a concrete, evidenced, architecturally
  bounded path to eventually being resolved — without pre-committing
  to *when* or to exact implementation shape.
- Establishes the first concrete precedent for *how* a narrow,
  feature-scoped `review_events` consumer should be architected
  (Option C's shape), which future non-Analytics consumers (if any
  are ever evidenced) could reference without re-deriving the same
  reasoning.
- Narrows future flexibility deliberately: a future implementation
  plan must stay within this record's field list, scope
  (Hifz-only), and framing (descriptive, non-competitive) rather than
  being freely redesigned.

## Risks

- **Misleading plan-level attribution:** mitigated explicitly above —
  no `plan_id`, no retroactive ownership; scope is card-set resolution,
  not causal attribution.
- **Treating count as mastery:** mitigated by explicit naming
  restrictions ("attempts, not correctness or retention") in the
  Decision section.
- **Gamification/streak pressure:** mitigated by the Worship-First
  compliance section; remains a real risk if a future implementation
  plan or UI design drifts from this record's descriptive-only framing
  — requires vigilance at implementation-plan review time, not
  something this record alone can guarantee.
- **Premature generic read infrastructure:** mitigated by rejecting
  Options B and D in favor of the narrowest viable boundary (C).
- **Accidental `AnalyticsRepository` coupling:** mitigated by Option A
  rejection and the explicit forbidden-scope list; must be re-checked
  at implementation-plan and audit time, same as D6.6's own precedent.
- **Future consumers bypassing the intended boundary:** a real risk
  this record cannot fully prevent by documentation alone — the same
  risk DR-2026-0025 named for Analytics ("pressure to connect... because
  the data now exists") applies here in miniature; mitigation is review
  discipline, not tooling, matching this project's existing practice.
- **Historical data semantics across algorithm versions:** `hifz`
  reviews only ever use `hifz-sm2-capped-v1` today (single algorithm
  since D6.6 shipped), so this is not a present risk, but a future
  algorithm change would need review-count semantics to remain
  algorithm-agnostic (a pure count of events, not an ease/interval
  interpretation) — already true of the metrics as defined, which use
  none of the before/after fields.
- **Empty/low-sample historical windows:** a card or plan with very
  few `review_events` rows could show a sparse, uninformative pace
  chart — an implementation-plan-level UX question (e.g., an
  empty-state), not an architecture defect.
- **Overlapping-plan double-counting appearance:** because overlapping
  Hifz plan ranges are valid (`hifz_plan_repository.dart:25-27`), a
  card shared by two plans contributes the same historical
  `review_events` rows to *both* plans' scoped counts/pace. This does
  **not** mean those events are owned by, or split between, either
  plan — it is the same underlying activity fact viewed through two
  different scopes, exactly as `HifzOverallProgress`'s existing
  dedup-by-ordinal-set already handles for the aggregate case. A future
  implementation plan must not present two plans' totals as if they
  were mutually exclusive, and any UI that ever compares two plans
  side-by-side must account for their card sets potentially
  overlapping. This is an implementation-time presentation constraint,
  not solved by `plan_id`, `cycle_id`, a new schema field, or any new
  attribution semantics.

## Non-goals

This record does **not** authorize: code; tests; schema changes;
migrations; a read API implementation; `AnalyticsRepository` changes;
Analytics integration; AI Tutor integration; Learning Journey
integration; Smart Learning integration; Study Summary integration; a
history/timeline UI; streaks; a mastery score; gamification; `plan_id`;
`cycle_id`; `lemma` event emission; backfill; cloud sync.

## Open questions

Left genuinely open, for a future implementation plan to resolve, not
decided here:

1. Exact time-window granularity for "review pace" (daily vs. weekly
   buckets, and how many buckets to show).
2. Exact repository/class/method name and file location within
   `hifz/`/`learning/data/`.
3. Exact presentation (list, sparkline, bar chart, or plain numbers)
   on the Hifz Progress screen.
4. Exact empty-state/low-sample-size UX.
5. Whether `HifzPlanProgress` and `HifzOverallProgress` both gain new
   fields, or whether a separate, parallel read path is cleaner —
   an implementation-plan-level design choice.

Inherited, still open, unaffected by this record: `DR-2026-0024`'s
Open Decisions #1 (plan-level Hifz history need — this record answers
a *narrower* question, count/pace without attribution, not #1's full
scope), #2 (`lemma` emission timing), #3 (sync strategy), #4 (erasure
policy); `DR-2026-0025`'s open question of whether/when Analytics
itself ever consumes `review_events` (unaffected — this record is not
that decision).

## Evidence and references

- `lib/features/hifz/domain/entities/hifz_plan_progress.dart:6-13`,
  `lib/features/hifz/domain/entities/hifz_overall_progress.dart:7-16` —
  self-documented gap this record resolves the architecture for.
- `lib/l10n/app_en.arb:187` (`hifzProgressSnapshotNote`) — user-visible
  admission of the limitation.
- `lib/features/learning/domain/sm2_scheduling_algorithm.dart:38-41` —
  `repetitions = 0` reset on `again`, proving historical count is
  structurally unrecoverable from `srs_cards`.
- `lib/features/hifz/domain/hifz_progress_calculator.dart:43-61` —
  existing card-set resolution pattern (`hifzActiveAyahIdsProvider`
  dedup-by-ordinal-set) this record's scope definition builds on,
  without adding new semantics.
- `lib/features/hifz/presentation/hifz_progress_screen.dart:25-30` —
  the screen's own stated design intent ("a truthful description, not
  an achievement") that this record's Worship-First compliance section
  extends.
- `lib/core/database/user/user_tables.dart` — `ReviewEvents` class,
  verified field list used in "Data sufficiency."
- `docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md:185`,
  `docs/release/MILESTONE_7_STUDY_ROADMAP.md:81` — Worship-First
  constitutional constraint verified above.
- `docs/adr/DR-2026-0024-srs-review-event-storage.md` — Decision 5
  (`plan_id` rejection, inherited by this record's plan-level
  boundary), Decision 3 (`lemma` deferral, why no Ayah/lemma equivalent
  is proposed here).
- `docs/adr/DR-2026-0025-analytics-review-event-consumption-boundary.md` —
  the Analytics-specific gate this record deliberately does not use,
  because this consumer is not Analytics.
- D6.8, D6.9, D6.10 (this session's discovery reports, read-only,
  independently reviewed) — the search process that ruled out every
  other candidate before arriving at this one.
