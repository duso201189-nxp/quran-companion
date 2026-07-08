---
id: PROJ-P-002
name: dual-database-separation
tier: invariant
scope: project
status: active
supersedes: null
version_introduced: 0.1.0
owner_role: data-owner
review_by: null
---

## Rule

Static Qur'an content (`assets/database/quran.sqlite`) and user data
(`user_data.sqlite`) are physically separate database files, never
merged. Updating Qur'an content (a new app release) never touches user
data; user data sync never touches Qur'an content.

## Rationale

Already established in `ARCHITECTURE.md` §3 and §12b, and in `DATABASE.md`'s
migration rules ("data nhóm A và nhóm B tách file database riêng"). This
is what lets a content update ship without any risk to a user's
bookmarks, notes, or progress — the two databases have entirely
independent lifecycles.

## Applies To

`lib/core/database/` (content) and `lib/core/database/user/` (user data).
Any future migration workflow for either database.
