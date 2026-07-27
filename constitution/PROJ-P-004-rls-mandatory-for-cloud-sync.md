---
id: PROJ-P-004
name: rls-mandatory-for-cloud-sync
tier: constraint
scope: project
status: active
supersedes: null
version_introduced: 0.1.0
owner_role: security-owner
review_by: null
---

## Rule

Once Supabase is introduced (Step 10-11 of this project's roadmap), every
user-data table enables Row Level Security with `user_id = auth.uid()`.
No user table ships without it.

## Rationale

Already stated in `ARCHITECTURE.md` §8. Recorded as a Constitution
constraint now, before Supabase actually arrives, so it's a precondition
checked at that step rather than a thing to remember under the pressure
of shipping cloud sync for the first time.

## Applies To

Every Supabase migration under a future `supabase/migrations/` directory,
once Step 10-11 begins. Not yet applicable in practice — Supabase
integration hasn't started — stated here so it's already governed the
moment it does.
