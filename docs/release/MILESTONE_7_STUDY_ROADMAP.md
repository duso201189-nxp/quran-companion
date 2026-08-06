# Milestone 7 — Study Roadmap

Official planning reference for all Sprint 7 work. Frozen after two
architecture review passes. Implementation-independent by design — this
document defines *what* each sprint scopes and *why it sits where it
does*, never *how* it is built.

## Governing documents

This roadmap is subordinate to, and must remain consistent with:

- [`docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md`](../architecture/STUDY_ARCHITECTURE_CONSTITUTION.md)
  — the learning philosophy and architectural roles every sprint below
  serves. Any conflict between this roadmap and that document is
  resolved in the Constitution's favor; this roadmap would need to be
  revised, not the other way around.
- `PROJECT_CONSTITUTION.md` — the project's five standing
  invariants/constraints (offline-first, dual-database separation,
  domain-layer purity, RLS-for-cloud-sync, non-commercial translation
  license). No sprint below is scoped to touch any of these; if a
  future sprint's implementation ever would, that sprint requires its
  own stop-and-ask review before proceeding, per `CLAUDE.md`.

## How to read this roadmap

Each sprint lists its scope in one line, its hard dependencies (if
any), and a **Worship First checkpoint** — a question that must be
answered, not assumed, before that sprint is considered complete. This
checkpoint is a standing requirement of the Study Architecture
Constitution, not optional per-sprint polish.

---

## Sprint Order

| Order | Sprint | Scope | Depends on |
|---|---|---|---|
| 1 | **7.1** — Assessment Scoping | Quiz draws only from content the user has actually read | — |
| 2 | **7.3** — Automatic Retention Seeding | Reading feeds Revision by default; manual tagging becomes the exception, not the requirement | — |
| 3 | **7.2** — Foundation-First Session Default | "Start a learning session" no longer defaults a new user into Quiz | 7.3 |
| 4 | **7.5** — Reflection Practice | Give Reflection its own identity, adjacent to reading sessions | — |
| 5 | **7.4** — Boundary-Triggered Revision Moments | Finishing a Surah/Juz/Khatm invites a consolidated revision pass | 7.3 |
| 6 | **7.7** — Hifz Mode | Opt-in, deliberate memorization intensity, distinct from casual revision | 7.3 |
| 7 | **7.6** — Sequencing Consolidation | Treat AI Tutor / Learning Journey / Smart Learning as the one capability the Constitution names them as | — (final functional sprint, by decision) |
| 8 | **7.8** — Learning Analytics Foundation | Logging first; reporting deferred until there's enough data to warrant it | — |

---

## Sprint Detail

### 7.1 — Assessment Scoping
**Scope:** Quiz draws only from content the user has actually read.
**Depends on:** Nothing. Self-contained correctness fix.
**Worship First checkpoint:** Confirm scoping removes trivia-testing framing and does not introduce score pressure in its place.

### 7.3 — Automatic Retention Seeding
**Scope:** Reading feeds Revision by default; manual tagging becomes the exception, not the requirement.
**Depends on:** Nothing. The deepest foundational sprint in this roadmap — narrows the scope of 7.2 and is a hard prerequisite for 7.4 and 7.7.
**Worship First checkpoint:** Confirm seeding operates as silent infrastructure, not a new engagement mechanic the user is asked to notice or respond to.

### 7.2 — Foundation-First Session Default
**Scope:** "Start a learning session" no longer defaults a new user into Quiz.
**Depends on:** 7.3. Once reading automatically seeds Revision, most users with any reading history will already have due items, which narrows this sprint's remaining scope to the genuinely first-time, zero-history case.
**Worship First checkpoint:** Confirm the new default reads as an invitation, not a gate the user must clear.

### 7.5 — Reflection Practice
**Scope:** Give Reflection its own identity, adjacent to reading sessions.
**Depends on:** Nothing at this position. Covers the reading-adjacent form of Reflection, per the Study Architecture Constitution §6.
**Worship First checkpoint:** Confirm AI stays fully silent in this feature, and that no prompt implies there is a "correct" reflection to produce.

**Note carried from final review:** Reflection adjacent to a reading session is delivered by this sprint. Reflection adjacent to Surah/Juz/Khatm completion is the other form named in Constitution §6, and becomes available only after Sprint 7.4, since it shares the same completion-boundary detection 7.4 builds. This is not a scope gap in 7.5 — it is the correct, dependency-honest split between the two forms of Reflection the Constitution names.

### 7.4 — Boundary-Triggered Revision Moments
**Scope:** Finishing a Surah/Juz/Khatm invites a consolidated revision pass.
**Depends on:** 7.3, as a hard dependency — there is nothing meaningful to consolidate until reading is actually feeding a revision pool.
**Worship First checkpoint:** Confirm the moment reads as a quiet invitation to revisit, never a badge, achievement, or counter reset.

### 7.7 — Hifz Mode
**Scope:** Opt-in, deliberate memorization intensity, distinct from casual revision.
**Depends on:** 7.3, as a hard dependency — the Study Architecture Constitution (§10) defines Hifz as intensification of Revision, which presupposes Revision is already trustworthy.
**Worship First checkpoint:** Confirm no leaderboard, streak-pressure, or competitive framing is introduced around memorization.

### 7.6 — Sequencing Consolidation
**Scope:** Treat AI Tutor / Learning Journey / Smart Learning as the one capability the Study Architecture Constitution (§13) already names them as.
**Depends on:** Nothing functionally, but deliberately sequenced as the final functional sprint — it delivers no new user-facing value on its own and carries the highest regression surface of any sprint in this roadmap. Sequencing it earlier would be architecture work performed before user value, which this roadmap does not permit.
**Worship First checkpoint:** Confirm the consolidated surface is not more engagement-optimized than the three separate surfaces it replaces.

### 7.8 — Learning Analytics Foundation
**Scope:** Logging first; reporting deferred until there's enough data to warrant it.
**Depends on:** Nothing structurally.
**Worship First checkpoint:** Confirm metrics remain internal and diagnostic, and are never surfaced back to the user as a score.

**Note carried from final review:** Learning Analytics Foundation remains Sprint 7.8 — it is not reordered. Silent logging may begin earlier than Sprint 7.8 if a measurement baseline is ever judged necessary before 7.1–7.6 change user-facing behavior; if so, that logging is a quiet, minimal addition riding alongside an earlier sprint (most naturally 7.3), not a reason to move Sprint 7.8 itself. Sprint 7.8, wherever its preparatory logging began, remains the sprint where the analytics capability is formally built out and delivered as its own scoped unit.

---

## Status

Frozen. Ready for execution pending explicit sprint-start authorization. This roadmap does not authorize implementation of any sprint — each sprint requires its own explicit go-ahead before work begins, per this project's standing engagement convention.
