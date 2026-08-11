---
id: DR-2026-0023
scope: project
owner_role: architect
date: 2026-08-11
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-11
reversibility: soft
threshold_reason: [materially-different-approaches, commits-real-cost]
links:
  task: "Sprint 7.4 — Boundary-Triggered Revision Moments (Milestone 7 Study Roadmap)"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0023 — Boundary-Triggered Revision Moments: completion detection, invitation persistence, and scoped revision targets

## Relationship to existing records

This record **builds on** [DR-2026-0021](DR-2026-0021-automatic-retention-seeding.md)
(Automatic Retention Seeding) and changes nothing in it: Revision Queue
eligibility remains exactly the union that record defines, and
`revisionEligibleAyahsProvider` remains the single authority on *what is
eligible*. This record only adds a way to ask "which of the already-eligible
Ayahs belong to the Surah just finished."

[DR-2026-0005](DR-2026-0005.md) (Learning Engine / Scheduler) is
**unaffected**: `SchedulerRepository`, `SchedulingAlgorithm`, and SM-2 are
untouched, and the Scheduler stays provenance-blind — it is never told that
an Ayah became eligible because of a boundary.

[DR-2026-0003](DR-2026-0003-sprint8-data-architecture.md) is **unaffected**:
`study_sessions` keeps its schema and its column semantics (see Decision 4).

## Context

Sprint 7.4 (Study Architecture Constitution §3.7, §9: "Completion is a
checkpoint, not an exit"; "finishing a Surah invites a whole-Surah
consolidation pass") requires completion of a Surah, Juz, or Khatm to invite
a consolidated revision pass.

A design pass performed before any implementation verified the three
boundaries against current source and found that only one of them can be
built correctly today. The finding that drove this record:

**`study_sessions.ayah_to` records a reading *position*, not a reading
*extent*.** `ReadingScreen._onPositionsChanged` computes
`visible.map((p) => p.index).reduce(min)` — the **topmost** visible Ayah —
stores it in `_lastSavedIndex`, and `dispose()` passes that same value to
`logSession(ayahTo:)` and to the Khatm progress address. The existing test
`reading_screen_test.dart` ("tích hợp KhatmCycleRepository.updateProgress")
asserts exactly this: a 3-Ayah Surah, never scrolled, yields
`QuranAddress.ayah(2, 1)`.

That value is correct for its real purpose (resume-where-you-left-off) and
unusable for the question "did this session reach the last Ayah of the
Surah," which it systematically under-reports.

## Decision

1. **Sprint 7.4 ships Surah completion only.** Juz and Khatm are deferred to
   a follow-up sprint. This is a scope decision taken deliberately, recorded
   here so the omission is never mistaken for an oversight.

2. **Juz is deferred** because the boundary data does not exist in queryable
   form. `juz` is a nullable Group-A column (`content_tables.dart`) mapped
   into `Ayah.juz` and read by nothing; `QuranRepository` exposes no Juz
   query, and there is no const Juz-boundary table analogous to
   `AyahOrdinal.ayahCounts`. Producing one is net-new domain data requiring
   its own verification against the shipped asset — real work, not a
   line-item of this sprint.

3. **Khatm is deferred** because its completion signal is fed by the
   position-not-extent value described above. `KhatmCycle.completesJourney`
   requires ordinal ≥ 6236, i.e. address 114:6 as the *topmost visible*
   Ayah; An-Nas is six short Ayahs and normally fits one screen, so the
   topmost is 114:1 (ordinal 6231). The detection logic is sound; the input
   is not. Repairing it means changing what Khatm progress *means*
   (`isExtendedBy`, `updateProgress` call site) — behavior with its own
   Sprint SF-Khatm design and dedicated tests. Bundling that repair into
   this sprint would be a silent change to a documented invariant.

4. **`study_sessions.ayah_to` must not change.** `user_tables.dart` states
   in-code that the 0-based encoding must not be altered without a new
   `data_version` marker, because no column records which convention a row
   used; streak and daily totals are computed from these rows. Redefining
   the column from "position" to "extent" would silently reinterpret every
   row already written. Boundary detection therefore gets its own signal
   rather than repurposing this one.

5. **Session-local furthest-reached tracking, never seeded from stored
   position.** `ReadingScreen` keeps a private, in-memory
   `_maxAyahIndexReached` that starts at **0 for every session** and is
   raised in `_onPositionsChanged` from the **max** visible row. It never
   feeds `logSession`, `ReadingPositionStore`, or Khatm progress, and is
   never persisted. Revisiting earlier Ayahs after reaching the end still
   counts as complete, because the value is monotonic.

   It is explicitly **not** seeded from `_initialAyahIndex`. That value comes
   from `ReadingPositionStore` — i.e. from a *previous* session, or from
   `openAyahInReadingScreen`, which writes the position before pushing the
   reading screen. Seeding from it made "jump straight to a Surah's final
   Ayah from Search / Library / the Revision Queue, then idle five seconds"
   indistinguishable from "read the whole Surah." Because the completion
   marker is permanent (Decision 8), that spurious mark would have
   consumed the Surah's only invitation, so a later genuine read-through
   would never invite at all. This was found by the final audit of this
   sprint, after the first implementation had shipped it.

6. **Completion additionally requires forward traversal within the
   session.** The condition is
   `_maxAyahIndexReached > _initialAyahIndex && SurahCompletion.completed(...)`.
   The five-second threshold proves a session was *real*; it proves nothing
   about the user having traversed the final Ayah. Requiring the session to
   reach further than where it began is what distinguishes reading from
   arriving. Genuine paths are unaffected: opening at 0 and reading to the
   end, or resuming mid-Surah and finishing it, both satisfy it; landing
   directly on the final Ayah does not.

7. **Detection is a pure function.** `SurahCompletion.completed({surahId,
   maxAyahIndex})` compares against `AyahOrdinal.ayahCounts[surahId - 1] - 1`
   — 114 const integers, no database, no Group A, synchronous, unit-testable
   without a `ProviderContainer`. The existing `seconds >= 5` session-validity
   threshold is reused unchanged rather than inventing a second one.

8. **SharedPreferences marker, no schema change.**
   `BoundaryCompletionController` is a `Notifier<int?>` over
   `sharedPreferencesProvider`, the same shape as
   `RetentionSeedingActivation` / `ThemeController` / `DailyGoalStore`. Two
   key families:
   - `boundary.surah.<id>` — permanent, written once, "this Surah has already
     produced an invitation." Makes marking idempotent and stops re-reading a
     finished Surah from re-inviting.
   - `boundary.surah.pending` — the single outstanding invitation. Dismissing
     clears this and **keeps** the per-Surah marker, so dismissal is final
     rather than a snooze.

   No table, no migration, no backfill. Per-device, consistent with there
   being no account system today (`PROJ-P-004` stays dormant until Supabase).

   **Pending-invitation policy — one invitation, most recent wins.** Stated
   plainly rather than left to be discovered:
   - Permanent completion markers are **per Surah**; each Surah can be
     marked complete exactly once, and that mark is never cleared.
   - There is **exactly one** pending invitation at a time.
   - If Surah A completes and then Surah B completes before the user opens
     the Study screen, B's pending invitation **replaces** A's. A remains
     permanently marked complete, and **A will never generate another
     boundary invitation in this sprint** — its invitation is lost, not
     queued.
   - This is a deliberate Minimal Sufficient Change decision, not an
     oversight: a pending-invitation *queue* is real notification
     infrastructure (ordering, expiry, dismissal-per-item, surfacing more
     than one card) that this sprint does not need in order to honor
     Constitution §9 for the common single-Surah case.
   - A future notification/invitation queue may revisit this policy. If it
     does, the permanent per-Surah markers written by this sprint are the
     constraint it must work around — they already record completion, so a
     later design can choose to re-derive invitations from them.

9. **Provider-layer composition for the scoped target.**
   `surahRevisionTargetProvider(surahId)` watches
   `revisionEligibleAyahsProvider` and keeps only Ayah ids inside that
   Surah's ordinal range, computed purely via `AyahOrdinal`. Eligibility
   stays authoritative in `revisionEligibleAyahsProvider`; this provider only
   narrows it. No repository is modified, nothing is injected across the
   database boundary, and `PROJ-P-002` holds trivially because the scoping
   arithmetic needs no database at all.

   **This provider is the single source of truth for what a scoped
   revision pass contains.** `RevisionQueueScreen`, when given a
   `surahId`, watches it and shows exactly the Ayah ids it returns; the
   screen does not re-derive membership. The first implementation of this
   sprint instead compared `item.ayah.surahId == surahId` inside the
   screen — a second, parallel definition of the same thing, free to drift
   from the provider without any test noticing. The final audit flagged it,
   and it was replaced by the provider-driven filter. The unscoped queue
   (`surahId == null`) does not consult this provider at all and keeps its
   Sprint 9 behavior exactly.

10. **The invitation lives on the Study screen, not in the reading flow.**
   `dispose()` cannot present UI or await UI work, and interrupting the user
   as they leave the text would contradict the sprint's own Worship First
   checkpoint. `dispose()` writes a marker; the Study screen — where revision
   already lives — renders a quiet, dismissible card from that state. The
   card opens the **existing** `RevisionQueueScreen` scoped to the completed
   Surah (`/revision-queue?surah=<id>`). No new review screen, no second
   scheduler, no parallel revision engine.

11. **Worship First constraints, binding on the UI.** No badge, score,
    streak, counter, celebration, confetti, or congratulation. The copy
    invites consolidation ("read through … revisit when ready"), never
    praises completion. The card is dismissible and never blocks. AI is
    absent from this feature entirely — nothing here generates, ranks, or
    interprets content.

12. **Follow-up required.** Juz and Khatm boundary moments remain owed to
    Constitution §9, and completion-adjacent Reflection (§6, deferred by the
    Sprint 7.5 note in the Milestone 7 roadmap) remains gated on them. The
    Khatm work must begin by deciding what Khatm progress should mean, not
    by patching a detection branch onto an under-reporting input.

## Consequences

- No Drift schema migration, no new table, no backfill job.
- `study_sessions`, `ReadingPositionStore`, Khatm progress, `SchedulerRepository`,
  `SchedulingAlgorithm`, Quiz scoping (7.1), `RetentionSeedingActivation` (7.3),
  and the Sprint 7.5 Reflection surface are all untouched.
- `LibraryTabView` gains one optional filter parameter, defaulted off; every
  existing call site is unchanged in behavior.
- Reversibility: soft. Everything here is a pure function, a
  SharedPreferences key family, a provider composition, and one card widget.
- A user who finished a Surah before this sprint shipped receives no
  retroactive invitation — the marker is prospective, the same stance
  `DR-2026-0021` took for seeding.
