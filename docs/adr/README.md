# Decision Records — Qur'an Companion

Index of Decision Records (DRs) for this project. Schema:
`eis-core/schemas/decision-record.schema.md`. A DR is never edited in
place after `status: accepted` except to change its `status` —
corrections happen via a new, superseding (or amending — see each
record's own "Relationship to" note) DR.

| ID | Title | Status | Date |
|---|---|---|---|
| [DR-2026-0001](DR-2026-0001-adopt-eis-for-this-project.md) | Adopt EIS Core for this project | accepted | 2026-07-08 |
| DR-2026-0002 | Search architecture (Sprint 7.1) | **missing — see below** | — |
| [DR-2026-0003](DR-2026-0003-sprint8-data-architecture.md) | Sprint 8 data architecture: Reading Statistics, Khatm, Bookmark Collections | accepted | 2026-07-20 |
| [DR-2026-0004](DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md) | Sprint 9: canonical streak source, Daily Goal storage split, Revision Queue reuse | accepted | 2026-07-20 |
| [DR-2026-0005](DR-2026-0005.md) | Sprint 10: Learning Engine architecture — Scheduler (SM-2), Review Session, Quiz | accepted | 2026-07-20 |
| [DR-2026-0006](DR-2026-0006-study-architecture-foundation.md) | Sprint 30: Study Experience architecture foundation — Tafsir as a content source, layer model, ownership, extension shapes | accepted | 2026-07-25 |
| [DR-2026-0007](DR-2026-0007-study-workspace-architecture.md) | Sprint 31: Study Workspace — per-ayah surface, `/study/:ayahId` route, feature ownership, enforced Reading dependency budget | accepted | 2026-07-25 |
| [DR-2026-0008](DR-2026-0008-content-distribution-strategy.md) | Content distribution strategy — no licensed content in a public repository | accepted | 2026-07-26 |
| [DR-2026-0009](DR-2026-0009-data-supply-chain.md) | Data supply chain — separate the data build from the app build | accepted | 2026-07-26 |
| [DR-2026-0010](DR-2026-0010-licence-registry.md) | Licence registry — rights as machine-readable grants, three-valued | accepted | 2026-07-26 |
| [DR-2026-0011](DR-2026-0011-artifact-versioning.md) | Artifact versioning — schema / artifact / dataset as independent axes | accepted | 2026-07-26 |
| [DR-2026-0012](DR-2026-0012-artifact-registry.md) | Artifact registry — immutable, verified, consumed by pin | accepted | 2026-07-26 |
| [DR-2026-0013](DR-2026-0013-ci-licence-gate.md) | CI licence gate — the boundary that cannot be bypassed | accepted | 2026-07-26 |

## Known gap: `DR-2026-0002`

Referenced by id from six places in `lib/` (`app/router.dart`,
`features/quran/presentation/reading/reading_navigation.dart`,
`features/search/presentation/search_screen.dart`, and three
`features/search/presentation/widgets/*.dart` files) plus
`CHANGELOG.md` — but, like `DR-2026-0003` was until this same
Sprint-9 Phase-0 pass, it was never saved into this directory; it
only ever existed as a chat-session artifact from Sprint 7.1's
planning. Every one of those references currently points at nothing
a reader of this repository can open.

Not backfilled as part of this pass — Sprint 9's Phase 0 scope was
`DR-2026-0003` and `DR-2026-0004` specifically. Flagged here, and in
`TODO.md`, so it isn't lost a second time.

## The Sprint 38–40 series (`DR-2026-0008` … `DR-2026-0013`)

Six records, one subject: **where licensed third-party content is
allowed to be, and what stops it being anywhere else.** Read `0008`
first; the rest implement it.

```
0008  policy      no licensed content in a public repository
 ├─ 0009  mechanism   data build separated from app build
 ├─ 0010  rights      what is permitted (work → edition → grant)
 ├─ 0011  identity    schema / artifact / dataset versions
 ├─ 0012  output      immutable verified artifacts, consumed by pin
 └─ 0013  enforcement CI gate — the only unbypassable layer
```

Each owns exactly one question. `ARCHITECTURE_FREEZE_REPORT.md` records
the consistency review that verified no two of them own the same one.

Design documents behind the series, kept for reasoning not authority:
`DATA_SUPPLY_CHAIN.md`, `DATA_OS_ARCHITECTURE.md`. Where they and an
accepted ADR differ, **the ADR wins** — the design documents explore,
the ADRs decide.
