---
id: DR-2026-0021
scope: project
owner_role: data-owner
date: 2026-08-10
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-10
reversibility: soft
threshold_reason: [materially-different-approaches, commits-real-cost]
links:
  task: "Sprint 7.3 — Automatic Retention Seeding (Milestone 7 Study Roadmap)"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0021 — Automatic Retention Seeding (Revision Queue eligibility)

## Relationship to DR-2026-0004

This record **amends one specific point** of
[DR-2026-0004](DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md):
Decision 3 characterized Revision Queue membership as manual-only —
"A fifth kind — Ayahs with `status='review'` — is the same shape" as
the four other manually-toggled annotation kinds
(bookmarks/favorites/notes/highlights). That characterization is no
longer complete. Everything else in `DR-2026-0004` (streak canonical
source, Daily Goal storage split, the decision that
`UserContentRepository` — not a new repository — owns Revision Queue
data) remains unchanged and in force. `DR-2026-0004`'s `status` stays
`accepted`; this record is filed separately per this project's DR
governance rule (`docs/adr/README.md`: a DR is never edited in place
after acceptance).

`DR-2026-0005` (Learning Engine / Scheduler architecture) is
**unaffected** — Decision 1 ("Scheduler consumes the Revision Queue,
never owns or replaces it," fed an opaque `List<int>` with no
provenance) already anticipated exactly this kind of change to *how*
Queue membership is produced without requiring any change to
`SchedulerRepository`.

## Context

Sprint 7.3 (Study Architecture Constitution §4, §13: "Reading feeds
Revision by default; manual tagging becomes the exception, not the
requirement") required Revision Queue membership to include Ayahs the
user has read, not only Ayahs manually flagged `AyahStatus.review`.
Three design passes preceded this record (Planning Audit, Architecture
Decision Proposal, Final Design Validation) and converged on: reuse
`ayah_statuses`/`study_sessions` as-is, no schema change, prospective-
only activation via a per-device SharedPreferences marker.

A fourth check — performed while implementing, not before — found
that the originally-approved shape (compute the union *inside*
`UserContentRepositoryImpl.watchAllReviewAyahs()`) is not buildable
without giving that repository a `QuranRepository` dependency:
`study_sessions.ayah_from`/`ayah_to` are 0-based, per-Surah indices,
while `watchAllReviewAyahs()`'s `ayahId` and every downstream consumer
(`LibraryKind.review`, `SrsCards.item_id`) require the global
`Ayah.id` (`AppDatabase.ayahs`, Group A). Resolving one into the other
requires Group A. `UserContentRepositoryImpl` and
`StudySessionRepositoryImpl` are both Group-B-only today, and
`docs/architecture/MASTER_ARCHITECTURE.md` §2.1 records, as a verified
fact about the current codebase, that no repository implementation
touches both databases — consistent with `PROJ-P-002`
(`PROJECT_CONSTITUTION.md`). Implementation was paused and this
narrower architectural question was resolved before writing any
Revision-Queue code.

## Decision

1. **`UserContentRepository.watchAllReviewAyahs()` is unchanged** —
   type signature and semantics both stay exactly what they were
   before Sprint 7.3: the manually-flagged `AyahStatus.review` set,
   nothing more.
2. **`StudySessionRepository` gains one new method**,
   `watchAyahRangesCoveredSince(int cutoffMs)`, returning raw
   `(surahId, ayahFrom, ayahTo)` ranges (0-based, matching
   `study_sessions`' existing storage) for sessions created at/after
   `cutoffMs`. This method stays Group-B-only — no Group A dependency,
   no global-id resolution, keeping database details behind
   `StudySessionRepository`'s own boundary.
3. **A new Provider-layer composition**,
   `revisionEligibleAyahsProvider`
   (`lib/features/quran/data/user_content_providers.dart`), is the
   union of (1) and (2): it watches `watchAllReviewAyahs()` (manual),
   watches `watchAyahRangesCoveredSince()` (post-cutoff reading,
   gated by a new per-device activation marker — Decision 4), resolves
   each range to global `Ayah.id`s via the existing
   `QuranRepository.getAyahsOfSurah()` (Group A, no second Quran
   identity-resolution mechanism introduced), and deduplicates by
   `Ayah.id`. This is the same shape already used to bridge two
   independent, same-tier repositories elsewhere in this codebase
   (`schedulerSyncProvider` bridging `SchedulerRepository` and
   `UserContentRepository`) — the Provider layer, not a repository
   constructor, is where genuinely separate repositories are composed.
4. **Activation marker**: `RetentionSeedingActivation`
   (`lib/features/quran/data/retention_seeding_store.dart`) — a
   `Notifier<int>` over `sharedPreferencesProvider`, matching
   `ThemeController`/`LocaleController`/`DailyGoalStore`'s existing
   shape. Written exactly once, the first time it is read on a given
   device, holding that moment's epoch-ms timestamp. No new
   configuration framework.
5. **Two internal watch targets updated to consume the union
   instead of the manual-only stream** — `library_controller.dart`'s
   `LibraryKind.review` case and `scheduler_providers.dart`'s
   `schedulerSyncProvider` now watch `revisionEligibleAyahsProvider`
   instead of calling `watchAllReviewAyahs()` directly. `LibraryKind`,
   `LibraryTabView`, `LibraryAyahTile`, `RevisionQueueScreen`,
   `SchedulerRepository`, and `SchedulingAlgorithm` are all unchanged.

Resulting policy, unchanged from the prior design passes and restated
here for the record:

- Revision Queue eligibility = manual `AyahStatus.review` **UNION**
  Ayahs covered by `study_sessions` created at/after the activation
  marker.
- Seeding is **prospective-only** — pre-activation reading history is
  intentionally never backfilled.
- Activation is **per-device / per-installation** — there is no
  account or sync system today (`PROJ-P-004` applies only once
  Supabase is introduced); cross-device reconciliation of this marker
  is explicitly deferred until that architecture exists.
- Repository dual-database separation is unchanged: `UserContentRepositoryImpl`
  and `StudySessionRepositoryImpl` depend on `UserDatabase` only;
  `QuranRepositoryImpl` depends on `AppDatabase` only; the Provider
  layer remains the sole legitimate bridge between them.

## Consequences

- No Drift schema migration, no new table, no backfill job.
- `AyahStatus`, `setStatus()`, `AyahActionsSheet`, and the Reading
  screen's per-Ayah status badge are untouched — automatic eligibility
  never writes to `ayah_statuses` and is not visible there.
- The Scheduler remains provenance-blind, unchanged: it still receives
  an opaque `List<int>` and cannot distinguish a manually-flagged Ayah
  from an automatically-eligible one, by design (`DR-2026-0005`
  Decision 1).
- `LibraryKind.review`'s displayed set changes in meaning (from
  "manually flagged" to "manually flagged or read since activation")
  without any change to the widgets that render it.
- Reversibility: soft. Every part of this decision is a provider
  composition and a SharedPreferences addition — nothing here is a
  schema commitment.
