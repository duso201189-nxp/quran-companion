# Project Constitution — Qur'an Companion

This document is an **index**, mirroring EIS Core's own
`CORE_CONSTITUTION.md` convention — it never restates a rule's full
content. Each rule is its own file under `constitution/`, one rule per
file, conforming to `eis-core`'s `schemas/constitution-entry.schema.md`.

## Relationship to Core

This Constitution **extends** EIS Core's Constitution
(`.claude/eis-profile.yaml` pins `eis_core_version: 0.1.0`) — it never
weakens a Core principle, and it never duplicates one. Every entry below
is `tier: invariant` or `tier: constraint` (never `tier: principle`,
which is Core-only), and none shares a name with a Core principle.

These five entries capture project-specific architectural guarantees
already established in `ARCHITECTURE.md` and `docs/DATA_PIPELINE.md` —
this document does not introduce new rules, it makes existing,
already-followed rules Constitution-visible and schema-conformant.

## Entries Index

| id | name | tier | status | file |
|---|---|---|---|---|
| PROJ-P-001 | offline-first | invariant | active | `constitution/PROJ-P-001-offline-first.md` |
| PROJ-P-002 | dual-database-separation | invariant | active | `constitution/PROJ-P-002-dual-database-separation.md` |
| PROJ-P-003 | domain-layer-purity | invariant | active | `constitution/PROJ-P-003-domain-layer-purity.md` |
| PROJ-P-004 | rls-mandatory-for-cloud-sync | constraint | active | `constitution/PROJ-P-004-rls-mandatory-for-cloud-sync.md` |
| PROJ-P-005 | non-commercial-translation-license | constraint | active | `constitution/PROJ-P-005-non-commercial-translation-license.md` |
