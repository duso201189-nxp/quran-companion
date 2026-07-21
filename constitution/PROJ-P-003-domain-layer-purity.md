---
id: PROJ-P-003
name: domain-layer-purity
tier: invariant
scope: project
status: active
supersedes: null
version_introduced: 0.1.0
owner_role: architecture-owner
review_by: null
---

## Rule

The domain layer never imports Flutter, Drift, or Supabase. Dependency
direction is Presentation → Domain ← Data, always.

## Rationale

Already stated in `ARCHITECTURE.md` §1 ("Domain KHÔNG import Flutter,
KHÔNG import Drift/Supabase"), and independently verified during this
project's Repository Discovery by checking `lib/features/quran/domain/`
for framework imports directly (none found). Kept as a Constitution
entry, not just architecture prose, because it's exactly the kind of
rule that erodes silently one convenient import at a time if nothing
names it as a hard line.

## Applies To

`lib/features/*/domain/`. A future `architecture-audit`-style check
(EIS Core's `skills/discovery/architecture-audit.md` describes the
general pattern) could verify this mechanically rather than by manual
grep, once this project has a real EIS skill/prompt layer of its own.
