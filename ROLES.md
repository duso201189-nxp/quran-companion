# Roles — Qur'an Companion

Names who currently holds each of EIS's six canonical Decision Ownership
roles (`eis-core/CORE_CONSTITUTION.md` §Decision Ownership), per
`.claude/eis-profile.yaml`'s `project_roles`. On a solo project all six
are held by the same person — the roles exist as distinct concepts from
day one so a future handoff is a matter of reassigning one line here, not
redesigning anything.

| Role | Holder | Owns |
|---|---|---|
| Constitution Owner | duso | `PROJECT_CONSTITUTION.md`, this project's Decision Records |
| Architecture Owner | duso | `ARCHITECTURE.md`, domain-layer purity, offline-first invariant |
| Data/Schema Owner | duso | `DATABASE.md`, both databases, any future migration |
| Security Owner | duso | Env/secrets handling, future RLS policies, dependency license audits |
| Release Owner | duso | `RELEASE_CHECKLIST.md`, store submission, the Tanzil licensing constraint |
| Planning Owner | duso | `ROADMAP.md`, `TODO.md` |

## Changing a Role

Per `scalability/SCALE_MODEL.md` (EIS Core), moving a role from one
person to another is a `constitution-touching` decision — it gets a
Decision Record under `docs/adr/`, not a silent edit to this file or to
`.claude/eis-profile.yaml`.
