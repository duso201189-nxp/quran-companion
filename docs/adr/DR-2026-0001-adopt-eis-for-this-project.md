---
id: DR-2026-0001
scope: project
owner_role: constitution-owner
date: 2026-07-08
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-08
reversibility: soft
threshold_reason: [constitution-touching, materially-different-approaches, commits-real-cost]
links:
  task: "Phase 9 - Project Profile instantiation"
  intelligence_layer_artifact: null
  verification_records: []
---

## Context

This project had grown across six roadmap steps (v0.1.0 through v0.6.0)
with real engineering discipline — a documented architecture, a database
migration policy, a CI quality gate, an unusually rigorous release
checklist — but no formal, portable governance layer: no Constitution, no
Decision Record process, no schema-conformant skill/prompt/workflow
library. Each of those disciplines lived only in this project's own
prose, re-derivable but not machine-checkable.

Separately, EIS Core — a portable, tool-agnostic engineering governance
framework — was designed and built (Phases 1 through 8), reaching a
tagged `v0.1.0` release meant to be reusable across projects, not
specific to this one.

## Options Considered

**Option A — Continue without a formal governance layer.** Keep relying
on `ARCHITECTURE.md`, `DATABASE.md`, and this project's own established
conventions alone. Rejected: this project's own documents already show
real, hard-won discipline (e.g. `RELEASE_CHECKLIST.md`'s insistence on
distinguishing verified-true from assumed) — formalizing it costs little
and makes it checkable rather than only inferable from reading prose.

**Option B — Build a bespoke, project-specific governance system from
scratch.** Rejected: this would duplicate EIS Core's already-built
Constitution, schemas, Intelligence Layer, and skill/prompt/workflow
library for no benefit — exactly the kind of redundant-concept problem
this whole exercise has repeatedly worked to avoid.

**Option C — Adopt EIS Core via a Project Profile, extending it with
project-specific Constitution entries.** Chosen.

## Decision

Adopt EIS Core `v0.1.0`, pinned via `.claude/eis-profile.yaml`. Extend it
with `PROJECT_CONSTITUTION.md` (five entries: offline-first,
dual-database-separation, domain-layer-purity, RLS-mandatory-for-cloud-
sync, non-commercial-translation-license) — all already-established
project rules, made Constitution-visible and schema-conformant rather
than newly invented.

## Consequences

- New files: `.claude/eis-profile.yaml`, `PROJECT_CONSTITUTION.md`,
  `constitution/PROJ-P-001` through `PROJ-P-005`, `ROLES.md`, `CLAUDE.md`,
  `docs/adr/`, `docs/reports/` (holding the two migrated reports).
- `ARCHITECTURE.md`, `DATABASE.md`, `ROADMAP.md`, `TODO.md`, and every
  other existing project document remain fully authoritative for
  project-specific technical detail — nothing about adopting EIS replaces
  or duplicates them; it adds a governance layer above them.
- `active_adapter: claude-code` is named but not implemented (EIS Core's
  Phase 4b was never built) — this project's day-to-day skill/prompt/
  workflow use is discipline-followed, not tool-enforced, until that
  changes.
- Reversibility is genuinely soft: the app builds and runs identically
  whether or not any of these files exist. Removing `.claude/`,
  `PROJECT_CONSTITUTION.md`, `ROLES.md`, and `CLAUDE.md` would fully
  undo this decision with no impact on the shipped product.
