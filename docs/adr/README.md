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
| [DR-2026-0015](DR-2026-0015-coverage-measurement-policy.md) | Coverage measurement policy: generated code in the denominator | accepted | 2026-08-01 |
| [DR-2026-0016](DR-2026-0016-lexicon-data-source.md) | Lexicon morphology data source | proposed | 2026-08-01 |
| [DR-2026-0017](DR-2026-0017-universal-quran-address.md) | The Universal Qur'an Address | proposed | 2026-08-03 |
| [DR-2026-0018](DR-2026-0018-reading-session-architecture.md) | Reading Session architecture | proposed | 2026-08-03 |
| [DR-2026-0019](DR-2026-0019-reading-engine-architecture.md) | Reading Engine architecture | proposed | 2026-08-03 |

`DR-2026-0017` is partially implemented: Sprint F0 (Phase 4) shipped its
Surah/Āyah subset as `lib/core/quran/quran_address.dart`. The record
remains `proposed` because its later milestones — Word/Segment levels,
`Range`, and the schema change at M4 — are neither built nor approved,
and M4 additionally requires `PROJ-P-002` sign-off.

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
