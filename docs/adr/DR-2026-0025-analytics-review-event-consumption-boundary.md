---
id: DR-2026-0025
scope: project
owner_role: data-owner
date: 2026-08-16
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-15
reversibility: soft
threshold_reason: [constrains-future-architecture, materially-different-approaches]
links:
  task: "D6.7 — governance decision resolving DR-2026-0024 Open Decision #5"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0025 — Analytics review-event consumption boundary

**Status of this record: accepted.** It answers exactly one question —
DR-2026-0024's Open Decision #5, *"whether analytics should ever
consume events"* — and is a governance decision only.
**Accepting this record creates ZERO production behavior.** Acceptance
does not query `review_events`; does not add a read API; does not
modify `AnalyticsRepository`, `LearningStatistics`, or any analytics
calculation; does not modify any UI; does not modify schema or
migrations. Those each remain separate, later decisions gated behind
their own approval (D6.2's own binding pattern, restated by
DR-2026-0024 Decision 14).

## Context

`review_events` (schema v8, DR-2026-0024, accepted, implemented in
Sprint D6.6) is an append-only, immutable log of committed SRS review
outcomes for `item_type` `ayah`/`hifz`. It has zero production
consumers today (verified: no reference to `ReviewEvent` or
`review_events` anywhere outside `lib/core/database/user/`,
`lib/features/learning/data/scheduler_repository_impl.dart`, and its
own domain entity file). DR-2026-0024 Decision 14 states plainly that
building the table did **not** authorize connecting it to the
five-tier analytics chain (`AnalyticsRepository` → AI Tutor → Learning
Journey → Smart Learning → Study Summary/`read_model`) — "D6.2 remains
in force" — and left *whether that chain should ever consume events*
as Open Decision #5, explicitly unresolved by design.

That silence has a cost: without a stated policy, every future sprint
that touches analytics has to re-litigate whether `review_events` is
in scope, and the temptation Decision 14 itself names — "pressure to
connect events to the five-tier analytics chain because the data now
exists" — has no answer to point to. This record exists to remove that
ambiguity, not to schedule the work.

### Current analytics architecture (evidence)

`AnalyticsRepository` (`lib/features/analytics/domain/analytics_repository.dart`)
computes `LearningStatistics`/`HistoryBucket`/`PerformanceInsights`/
`LearningGoal`/`Achievement` entirely from **current-state** snapshots —
`SrsCard` (via `SchedulerRepository`) and `StudySession`. It owns no
storage of its own ("No duplicated statistics", per its own doc
comment).

`LearningStatistics`'s own doc comment
(`lib/features/analytics/domain/entities/learning_statistics.dart`)
already discloses, without prompting from this record, that
`reviewsToday` and `accuracy` are **approximations** derived from the
current snapshot, precisely *because* `srs_cards` "does not store
history of each review, only the latest state" — and states this is a
known, accepted trade-off, not a defect being tracked toward a fix.
`readingStreakDays` deliberately reuses `StudySessionRepository`'s
existing real day-chain rather than inventing a parallel SRS-review
streak.

No grep across `lib/features/analytics/`, `lib/features/ai_tutor/`,
`lib/features/learning_journey/`, `lib/features/smart_learning/`, or
`lib/features/read_model/` for `review`, `history`, `historical`,
`timeline`, `grade distribution`, `trend`, or similar surfaces any
TODO, stub, failing test, or commented-out call site referencing
`review_events`. There is no concrete, currently-blocked product
requirement that only `review_events` could satisfy — the documented
imprecision is a stated and accepted limitation, not an open bug.

## Options considered

**Option A — Analytics never consumes `review_events`.**
Forecloses the table's only documented future use case (Decision 14
itself frames the question as *whether*, implying the door was left
open on purpose) without evidence that no future need will exist.
Rejected: over-constrains for no benefit repository evidence supports.

**Option B — Analytics may consume `review_events` for historical
metrics, but only through a future, separately approved read
boundary.**
Matches the shape DR-2026-0024 Decision 14 already committed to
("a future decision of the same class as D6.2"): it answers the
in-principle question now (yes, this is an allowed direction) while
leaving every concrete step — read API design, which metrics move from
approximate to exact, any `AnalyticsRepository` code change — gated
behind its own future approval, exactly like D6.2 gates the five-tier
chain today. Matches evidence: closes the ambiguity Decision 14 left
open without authorizing anything not yet justified by a real
requirement.

**Option C — Analytics becomes a primary consumer now, with
event-derived statistics becoming authoritative for selected
metrics.**
No repository evidence supports this: no failing requirement, no
product ask, no test expecting exact (non-approximate) figures. Would
require a read API, `AnalyticsRepository` changes, and probably UI —
all forbidden under this task's scope and unjustified by anything
found. Rejected.

**Option D — Defer the decision entirely until a concrete product
requirement exists.**
This is close to the status quo (Open Decision #5 already stands
unresolved) and would leave the ambiguity Decision 14 named as a
standing risk. It under-delivers relative to Option B: Option B costs
nothing additional (it still authorizes zero code) but removes the
recurring "is this in scope" question for every future analytics
sprint. Rejected in favor of B, which is strictly more useful at equal
cost.

## Decision

**Analytics is NOT authorized to consume `review_events` now.** No
code, read API, `AnalyticsRepository` change, schema change, or UI
work toward that end is authorized by this record.

Only after stating that prohibition does this record settle the
narrower, separate question DR-2026-0024 Open Decision #5 actually
asked — **Option B**: analytics consumption of `review_events` remains
architecturally *possible in principle* (the answer to Open Decision
#5 is not "never"), but strictly through a future, separately approved
decision. Acceptance of this record does not begin, schedule, or
pre-clear that future work.

Any future decision that would actually authorize `review_events`
consumption must require, at minimum — mirroring the governance
discipline this project already used for DR-2026-0024 → D6.6 (an
accepted ADR, then a concrete implementation plan, then approval, then
audit, before any code was written) — not this ADR, or any single
future ADR, alone:

1. Its own accepted decision record defining the consumer's purpose —
   the specific metric(s) that would move from snapshot-approximate to
   event-derived-exact, with the concrete product or correctness
   justification for doing so;
2. A concrete implementation plan, not just a decision record —
   acceptance of a future ADR is not, by itself, sufficient to begin
   implementation, exactly as acceptance of *this* ADR is not;
3. The read/query boundary and API shape explicitly designed (what
   queries, what aggregation, whether it lives behind
   `AnalyticsRepository` or a new interface) rather than exposing
   `review_events`/`ReviewEvent` directly to any of the five tiers;
4. Data/semantic authority rules — confirming no schema change is
   required, that append-only/immutability guarantees are not broken,
   and accounting for the `lemma` emission gap (Decision 3,
   DR-2026-0024) and any Hifz plan-level history gap (Open Decision
   #1) if those metrics are in scope;
5. Explicit validation/testing requirements for the new consumption
   path, named as its own required element of that future record —
   not merely implied by "ship tests."

Until such a record exists, is accepted, and is followed by its own
implementation plan, `lib/features/analytics/`, `ai_tutor/`,
`learning_journey/`, `smart_learning/`, and `read_model/` remain
exactly as forbidden to touch, in connection with `review_events`, as
DR-2026-0024 Decision 14 already states.

## Current analytics status — unchanged

`AnalyticsRepository`/`LearningStatistics` and every metric they
currently expose remain current product behavior and remain
authoritative for those metrics, exactly as implemented today. This
record does not deprecate, replace, invalidate, or reinterpret any of
them. The approximation `LearningStatistics` already documents in its
own doc comment (`reviewsToday`/`accuracy` derived from a current-state
snapshot, not per-review history) is an accepted characteristic of the
current design, not a defect this record marks for correction. Nothing
in this record authorizes replacing any current analytics calculation
with a `review_events`-derived one — that would itself require the
future decision described above.

## Governance boundaries

- **Preserves D6.2 and DR-2026-0024 Decision 14 unmodified.** This
  record adds a named future path; it does not weaken the current
  binding prohibition.
- **Authorizes no code.** No `AnalyticsRepository` method, no read
  API, no query against `review_events`, no schema change, no UI.
- **Does not authorize itself as a blanket future authorization.** A
  later implementer cannot cite this record alone to justify
  connecting analytics to `review_events`; a new, separately accepted
  decision record is required each time, per the Decision section
  above.
- **Does not resolve** DR-2026-0024 Open Decisions #1 (plan-level Hifz
  history), #2 (`lemma` emission timing), #3 (sync strategy), or #4
  (erasure policy) — those remain independently open and, where
  relevant (#1, #2), are explicit preconditions for any future
  analytics-consumption record that touches Hifz or lemma metrics.

## What remains forbidden

- Any modification to `lib/features/analytics/`, `lib/features/ai_tutor/`,
  `lib/features/learning_journey/`, `lib/features/smart_learning/`,
  `lib/features/read_model/`.
- Any read/query method exposing `review_events` or `ReviewEvent`
  outside `lib/features/learning/`.
- Any schema change.
- Any UI surfacing review-event history, in analytics or elsewhere.

## What becomes allowed later (only after a new, separate, accepted DR)

- Designing and implementing a scoped read boundary for specific,
  named metrics.
- Modifying `AnalyticsRepository` (or introducing a narrower interface
  it composes, matching the existing AI Tutor/Learning Journey/Smart
  Learning composition pattern) to consume that boundary.

## Consequences

- Removes the standing ambiguity DR-2026-0024 Decision 14 named as a
  risk ("pressure to connect events... because the data now exists")
  by giving future implementers a concrete, bounded answer instead of
  an open question.
- Adds no new coupling, storage, or code surface today — the working
  tree is unaffected beyond this document.
- Slightly narrows future flexibility versus doing nothing: a future
  analytics-consumption proposal must follow the five-element gate in
  Decision above rather than being freely designed from scratch — this
  is intentional, mirroring D6.2's own discipline.

## Risks

- **Documentation drift**: if a future sprint implements analytics
  consumption without registering a new DR per the Decision section,
  this record's boundary is violated silently. Mitigation: same
  precedent as D6.2 — the boundary is enforced by review discipline,
  not tooling.
- **False sense of closure**: accepting this record could be mistaken
  for authorizing implementation. Mitigation: this record states
  explicitly, twice, that no code is authorized.

## Open decisions

Unresolved by this record, inherited from DR-2026-0024 and unaffected
by it:

1. Plan-level Hifz history need (DR-2026-0024 Open Decision #1).
2. `lemma` emission timing/identity contract (DR-2026-0024 Open
   Decision #2).
3. Sync strategy for `review_events` under `PROJ-P-004` (DR-2026-0024
   Open Decision #3).
4. User-data erasure policy for historical events (DR-2026-0024 Open
   Decision #4).
5. The concrete shape of any future analytics-consumption proposal
   (metric selection, read-boundary design) — deliberately left to
   that future record, not this one.

## Evidence and references

- `docs/adr/DR-2026-0024-srs-review-event-storage.md` — Decision 14
  (the binding analytics boundary this record answers the "future
  decision" placeholder for) and Open Decision #5 (the exact question
  this record resolves).
- `lib/features/analytics/domain/analytics_repository.dart` —
  `AnalyticsRepository` interface; doc comment confirms it owns no
  storage and composes only existing repositories.
- `lib/features/analytics/domain/entities/learning_statistics.dart` —
  `LearningStatistics` doc comment, pre-existing and unmodified,
  disclosing `reviewsToday`/`accuracy` as accepted approximations
  because `srs_cards` holds no per-review history — the closest thing
  in the repository to a standing "would benefit from `review_events`"
  signal, and still not a blocking requirement.
- `lib/features/learning/domain/entities/review_event.dart`,
  `lib/features/learning/data/scheduler_repository_impl.dart` —
  confirmed zero consumers of `review_events` outside the write path,
  verified by repository-wide search.
- `lib/features/ai_tutor/domain/ai_tutor_repository.dart`,
  `lib/features/learning_journey/domain/learning_journey_repository.dart`,
  `lib/features/smart_learning/domain/smart_learning_repository.dart`,
  `lib/features/read_model/domain/learning_snapshot_repository.dart` —
  the existing five-tier composition discipline ("Compose ONLY... do
  not access X directly") that any future analytics-consumption record
  must continue to respect.
