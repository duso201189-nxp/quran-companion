---
id: DR-2026-0003
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
  task: "Sprint 8 — Reading Statistics, Khatm Tracking, Bookmark Collections (Phases 0-5)"
  intelligence_layer_artifact: null
  verification_records: []
---

## Note on this document

This record was reconstructed after the fact — Sprint 8 was designed
and implemented before `docs/adr/` held a file for it (the working
draft only ever existed as a chat-session artifact). Every reference to
`DR-2026-0003` elsewhere in this repository (`DATABASE.md`, `TODO.md`,
`CHANGELOG.md`, code comments in `lib/core/database/user/`,
`lib/features/khatm/`, `lib/features/library/`, `lib/features/stats/`)
was pointing at this decision before this file existed. This document
describes what Sprint 8 **actually shipped**, not the earlier draft's
exact wording — where implementation diverged from the original
discussion in any small way, this file follows the implementation.

## Context

By Sprint 7.1's close, `DATABASE.md` documented six Group B (user
data) tables — `study_sessions`, `streaks`, `khatm_cycles`,
`bookmark_collections`, `profiles`, `srs_cards` — that did not exist
in the actual Drift schema. Every planned Step 8 feature (Reading
Statistics, Khatm tracking, Bookmark Collections) depended on one or
more of them. Reading statistics at the time were entirely
SharedPreferences-backed (`StatsStore`): reading days, minutes, and
streak, with no Drift presence at all.

Before writing schema or code, five questions needed answers:
1. Should reading statistics move to Drift, and if so, how far?
2. Should the Revision Queue (`ayah_statuses.status='review'`, already
   built in Step 6) become a real spaced-repetition system now, or
   stay simple?
3. Should Bookmark Collections generalize to arbitrary annotation
   types, or stay Ayah-only?
4. Is `DATABASE.md` still Source of Truth for schema, given it had
   already drifted from the real database once?
5. What discipline prevents this drift from recurring?

## Options Considered

**1. Reading-statistics storage.**
*Option A — status quo.* Keep everything in SharedPreferences.
Rejected: no query surface for "last 7 days," no natural extension
point for Khatm/Collections (which needed real relational tables
regardless), and no path toward the eventual Supabase sync every
other Group B table already supports via `SyncColumns`.
*Option B — migrate schema and new writes to Drift; leave existing
SharedPreferences data and Daily Goal alone.* Chosen. Full historical
backfill of existing `StatsStore` data into Drift was explicitly
**not** attempted — a separate decision, deferred. Daily Goal
(`profileGoal`, not yet built at all) was explicitly scoped **out**
of this decision — "stays in SharedPreferences" here means "Sprint 8
does not build Daily Goal," not a permanent ban on ever moving it.

**2. Revision Queue.**
*Option A — simple: reuse the existing `ayah_statuses.status='review'`
value, no new table.* Chosen.
*Option B — real SRS: new `srs_cards` table (`item_type`/`item_id`,
`ease_factor`, `interval_days`, `repetitions`, `due_date`, SM-2).*
Rejected for Sprint 8: SRS is real algorithmic and UI work
(`ROADMAP.md` already reserves it for Bước 9 — Flashcard SM-2 +
Quiz), and Step 6 already ships a working, simple review mechanism.
Building `srs_cards` now would be speculative — no consumer for it
exists yet. The `ayah_statuses` column stays free-text
(`'learning'|'learned'|'review'`), not an enum-typed or
scheduling-aware column, preserving room for Option B later without
committing to its shape now.

**3. Bookmark Collections schema.**
*Option A — generalized `CollectionItem` (polymorphic: collections of
Ayahs, Notes, Highlights, or future item types, via a join table with
an `item_type` discriminant).* Rejected at the **database** level for
Sprint 8: no second collection-item type exists yet to justify the
extra join-table indirection.
*Option B — Ayah-only, direct FK from `bookmarks.collection_id` to
`bookmark_collections.id`.* Chosen at the database level.
The domain model is kept deliberately more general than the schema:
nothing in the domain layer assumes collections can only ever hold
Ayahs — the schema is intentionally the more conservative of the two,
extensible later via the same additive-migration discipline (Decision
5) if a second item type is ever needed, without designing that join
table speculatively today.

**4. `DATABASE.md`'s authority.**
*Option A — keep it as Source of Truth, correct the drift by hand.*
Rejected: this is exactly the failure mode that caused the original
drift — a hand-maintained document and a generated schema will
disagree again the next time someone edits one without the other.
*Option B — Drift schema files become Source of Truth for the
CURRENT schema; `DATABASE.md` becomes a Design Specification, split
into three explicit tiers (Implemented / Planned / Future Ideas), so
"what exists" and "what's intended" are never the same sentence.*
Chosen.

**5. Recurrence prevention — the Future-Proof Data Evolution
Principle.**
*Option A — no formal principle, rely on discipline alone.* Rejected
— discipline alone is what already failed once.
*Option B — a named, written principle: migrations are additive-only;
backward compatibility is preserved; no destructive migrations;
existing user data is never lost; the design does not block future
Sync, does not block future SRS, and does not require a UI rewrite
when domain logic evolves.* Chosen.

## Decision

1. **Schema.** `UserDatabase.schemaVersion` 2 → 3. Three new tables —
   `study_sessions`, `khatm_cycles`, `bookmark_collections` — plus one
   new nullable column, `bookmarks.collection_id`. All four additions
   use the existing `SyncColumns` mixin (`id` UUID, `user_id`,
   `updated_at`, `deleted_at`, `is_dirty`). `bookmarks.collection_id`
   has **no Drift-level foreign-key declaration** — there is no
   precedent for a declared FK anywhere in this schema (cross-table
   references are already handled at the repository layer
   throughout); integrity is enforced in
   `BookmarkCollectionRepositoryImpl` instead (rejects assignment to a
   nonexistent/deleted collection; cascades `collection_id` to `NULL`
   for all affected bookmarks, inside a transaction, before soft-
   deleting a collection).
2. **Migration.** Purely additive (`m.createTable` × 3,
   `m.addColumn` × 1 inside `if (from < 3)`). No renames, no drops, no
   destructive statement anywhere. Both upgrade paths that can reach
   `schemaVersion 3` in production (v1→v3, v2→v3) are covered by
   tests that hand-seed a pre-upgrade database and assert existing
   data survives the real `onUpgrade` unchanged.
3. **Streak — no `streaks` table.** Current streak, longest streak,
   and "today's summary" are computed on-read from `study_sessions`
   (`StudySessionRepository.currentStreak()` /
   `longestStreak()`), not cached in a stored/denormalized table.
   This is the "equivalent derived-on-read design" allowance under
   Decision 1 — it avoids a second write path that could disagree
   with the session log itself.
4. **No SRS.** No `srs_cards` table, no `ease_factor`/`interval_days`/
   `due_date` columns anywhere. The Revision Queue is exactly
   `ayah_statuses.status='review'`, as it already was.
5. **Bookmark Collections.** `bookmark_collections` (name, emoji,
   `display_order`) + `bookmarks.collection_id` (nullable, no
   declared FK). No `CollectionItem`/join-table generalization was
   built.
6. **Daily Goal.** Not built in Sprint 8. `profiles` (the table
   `DATABASE.md` had sketched for it) was not created. The existing
   `profileGoal` UI placeholder (`ProfileScreen`, disabled,
   "Coming in Step 8") was left untouched.
7. **`DATABASE.md`.** Restructured into Đã triển khai (Implemented —
   must match `schemaVersion` exactly) / Đã định (Planned — named
   table, tied to a specific future Bước, not yet in code) / Ý tưởng
   tương lai (Future Ideas — no committed shape yet).
8. **Future-Proof Data Evolution Principle**, binding for all
   subsequent Group B schema work: additive-only migrations; backward
   compatibility preserved; no destructive migrations, ever; existing
   user data is never lost across an upgrade; the design must not
   block future Cloud Sync (Bước 11), must not block a future real
   SRS system (Bước 9), and must not force a UI rewrite when the
   underlying domain logic evolves.

## Consequences

- **New code**: `StudySessionRepository`, `KhatmCycleRepository`,
  `BookmarkCollectionRepository` (interfaces + Drift-backed impls);
  matching Riverpod providers, all interface-typed; UI for Reading
  Statistics and Active Khatm (added to the existing Stats screen,
  additive — the pre-existing SharedPreferences-sourced metrics grid
  was left in place) and a new Collections screen reachable from
  Library.
- **`ReadingScreen` integration**: on dispose, now calls
  `StudySessionRepository.logSession(...)` for sessions ≥5 seconds —
  the same threshold `StatsStore.addSeconds` already used, chosen for
  consistency between the two, alongside (not replacing) the existing
  `StatsStore.addSeconds` call.
- **Known limitation, carried forward rather than resolved here**:
  because `StatsStore.addSeconds`/`markToday` and
  `StudySessionRepository.logSession` are two independent write paths
  triggered from the same `ReadingScreen` lifecycle, `StatsScreen` can
  show two streak numbers computed by two different algorithms on the
  same screen, and `HomeScreen` (unmodified by Sprint 8) continues
  reading only the `StatsStore` figure. Sprint 8 did not pick a
  canonical source between them — flagged as open at the time this
  decision was made, and resolved separately in
  [DR-2026-0004](DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md),
  which amends point 1 of this decision (see that record).
- **Reversibility**: soft. Every addition is a table or column that
  can be dropped in a future version without touching Groups A or
  existing Group B tables; nothing here is structurally entangled
  with data that predates it.
