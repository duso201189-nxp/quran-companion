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
