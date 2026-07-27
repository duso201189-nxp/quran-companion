---
id: DR-2026-0004
scope: project
owner_role: data-owner
date: 2026-07-20
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-20
reversibility: soft
threshold_reason: [materially-different-approaches, commits-real-cost]
links:
  task: "Sprint 9 — Architecture Freeze (Phase 0)"
  intelligence_layer_artifact: null
  verification_records: []
---

## Relationship to DR-2026-0003

This record **amends two specific points** of
[DR-2026-0003](DR-2026-0003-sprint8-data-architecture.md) — its
streak-source ambiguity (that record's Decision 1, left open) and the
scope of its Daily Goal deferral (that record's Decision 6). It does
**not** supersede `DR-2026-0003` as a whole: the schema, the
additive-migration discipline, the no-SRS decision, and the
Ayah-only Collections shape all remain in force unchanged.
`DR-2026-0003`'s `status` stays `accepted`.

## Context

The Sprint 9 architecture review (pre-implementation, full codebase
read) found three things that made "continue Sprint 8's patterns
unexamined" the wrong default:

1. **Streak is already computed two independent ways.**
   `StatsStore.currentStreak`/`longestStreak` (SharedPreferences,
   read by `HomeScreen`) and `StudySessionRepository.currentStreak`/
   `longestStreak` (Drift, read by `StatsScreen`) are both live today,
   fed by two separate writes from the same `ReadingScreen.dispose()`
   call. `DR-2026-0003` built the second without retiring the first.
   Daily Goal needs exactly one canonical "did today's reading count"
   answer — picking either existing source without deciding would
   just add a third inconsistent consumer.
2. **`DR-2026-0003`'s Daily Goal line was scoped to "not this
   sprint," not "never on Drift."** Sprint 9 is the sprint that
   builds it, so the storage question needs an actual answer now.
3. **Revision Queue's natural shape already exists in this
   codebase.** `LibraryKind` / `LibraryTabView` / `LibraryAyahTile` /
   `libraryItemsProvider` already implement "watch a stream of
   Ayah-annotation metadata, render loading/empty/error/data, tap to
   open" for four annotation kinds (bookmarks, favorites, notes,
   highlights). A fifth kind — Ayahs with `status='review'` — is the
   same shape.

## Options Considered

**1. Streak canonical source.**
*Option A — leave both, let each screen pick.* Rejected: this is the
status quo that created the problem; it would let Daily Goal become a
third disagreeing consumer.
*Option B — consolidate onto `StatsStore`/SharedPreferences.*
Rejected: `study_sessions` is already the Sync-ready (`SyncColumns`),
per-session-detail source; collapsing back to a day-marker-only model
would lose data `study_sessions` already captures (surah, ayah range,
duration) for no benefit.
*Option C — consolidate onto `study_sessions`/Drift, scoped strictly
to streak.* Chosen. `StatsStore`'s other responsibilities
(`ayahsRead`, `completionPercent`, `totalMinutes`, `last7Days`) are a
different concept — Qur'an-completion tracking, not session-derived
streak — and are explicitly **not** touched by this decision.

**2. Daily Goal storage.**
*Option A — full Drift: build the `profiles` table `DATABASE.md` had
already sketched (`daily_goal_minutes`, `daily_goal_ayahs`,
Sync-shaped).* Rejected: a `SyncColumns`-shaped, RLS-ready table for
two user-configurable scalars is complexity sized for a sync system
that does not exist yet (Bước 10-11). Nothing about a goal *target*
needs conflict resolution, soft-delete, or a sync queue.
*Option B — full SharedPreferences: target and progress both computed
from local prefs.* Rejected: progress needs to answer "how much did I
read today," which is exactly what `study_sessions` was built to
answer (`StudySessionRepository.totalDurationOnDate`, already
composed into `todayStudySummaryProvider`). Computing it a second,
independent way in SharedPreferences would be a third parallel
time-tracking system layered on top of the two `DR-2026-0003` already
left unresolved.
*Option C — split: target in SharedPreferences, progress derived from
Drift.* Chosen.

**3. Revision Queue architecture.**
*Option A — bespoke repository + screen, mirroring how
`StudySessionRepository`/`KhatmCycleRepository`/
`BookmarkCollectionRepository` were each built as their own
interface + impl + screen in Sprint 8.* Rejected: those three exist
because each is genuinely new *data* (no prior table held session
logs, Khatm position, or collections). Revision Queue is not new
data — `ayah_statuses` already holds it, and `UserContentRepository`
already owns that table. A new repository class here would duplicate
ownership of the same table across two repositories.
*Option B — reuse: extend `UserContentRepository` and `LibraryKind`,
reuse `LibraryTabView`/`LibraryAyahTile` for rendering, in a
dedicated screen (not a 5th tab inside `LibraryScreen` itself, since
"my library" and "what I need to review" are different user-facing
concepts despite sharing machinery).* Chosen.

## Decision

1. **Streak.** `currentStreakProvider` / `longestStreakProvider`
   (Drift, `study_sessions`-derived) become the **only** canonical
   streak read source, for every screen, starting with `HomeScreen`
   and `StatsScreen`. `StatsStore.currentStreak` / `longestStreak`
   are retired from being *read* by any screen. `StatsStore.markToday`
   /`addSeconds` may continue to exist and be called (they still feed
   `readingDayCount`, `totalMinutes`, `last7Days`, none of which this
   decision touches) — only their role as a streak source ends.
2. **Daily Goal.**
   - Target (minutes/day, ayahs/day) — SharedPreferences, via a new
     `DailyGoalStore`, matching the existing `ThemeController` /
     `LocaleController` shape (a `Notifier` over
     `sharedPreferencesProvider`, not a Drift repository).
   - Progress (today vs. target) — a new `dailyGoalProgressProvider`,
     a pure derivation composing the **existing**
     `todayStudySummaryProvider` (built in Sprint 8, unchanged)
     against the stored target. No new repository method, no new
     table.
   - `profiles` stays in `DATABASE.md`'s Đã định (Planned) tier,
     explicitly not built.
3. **Revision Queue.**
   - `UserContentRepository` gains one new method,
     `watchAllReviewAyahs()`, symmetric with its four existing
     `watchAllX()` methods (bookmarks/favorites/notes/highlights). No
     new repository interface, no new domain entity.
   - `LibraryKind` gains a `.review` value.
   - A new, dedicated screen (own top-level push route, following the
     same pattern already used three times for `/library`, `/search`,
     `/collections`) renders it by reusing `LibraryTabView` /
     `LibraryAyahTile` — not by building new list/tile widgets.
   - No `srs_cards`, no scheduling columns, no due-dates. This
     reaffirms `DR-2026-0003`'s Decision 2 (Simple Revision Queue) —
     it does not reopen it.

## Consequences

- `HomeScreen` and `StatsScreen` both read `currentStreakProvider`;
  `StatsScreen`'s pre-existing `StatsStore`-sourced streak cards are
  removed from its metrics grid (they duplicated, and could disagree
  with, the "Phiên đọc" section already on the same screen).
- No schema migration. `UserDatabase.schemaVersion` stays **3**.
- One new top-level route for the Revision Queue screen.
- Two pre-existing, unrelated defects were found during the same
  review and are recommended for correction alongside this work (not
  a new architectural decision — enforcement of the navigation
  contract `DR-2026-0002` §9 already established): `LibraryScreen._open`
  and `ActiveKhatmCard._continueReading` both inline the same
  save-position-and-push steps that
  `reading_navigation.dart`'s `openAyahInReadingScreen()` already
  exists to centralize. Fixing both is in scope for Sprint 9's
  integration phase.
- Reversibility: soft. Every part of this decision is a read-source
  choice, a SharedPreferences addition, and a provider composition —
  nothing here is a schema commitment.
