---
id: PROJ-P-001
name: offline-first
tier: invariant
scope: project
status: active
supersedes: null
version_introduced: 0.1.0
owner_role: architecture-owner
review_by: null
---

## Rule

The UI only reads from and writes to the local Drift database. No screen
waits on the network. Network is used only for background sync and audio
download — both fail silently and retry; losing internet must never
cause a crash.

## Rationale

Already established in `ARCHITECTURE.md` §2 as an "immutable requirement"
since Step 1 of this project's roadmap. Made Constitution-visible here so
it's checkable the same way every other invariant in this system is,
rather than living only in prose a future contributor might not read.

## Applies To

Every screen and controller. `ARCHITECTURE.md` §2, §12 (lazy database
opening, no heavy I/O before first frame).
