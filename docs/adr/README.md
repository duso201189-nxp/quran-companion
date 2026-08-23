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
| [DR-2026-0014](DR-2026-0014-publishing-model.md) | Publishing model for the artifact registry | proposed | 2026-07-26 |
| [DR-2026-0015](DR-2026-0015-coverage-measurement-policy.md) | Coverage measurement policy: generated code in the denominator | accepted | 2026-08-01 |
| [DR-2026-0016](DR-2026-0016-lexicon-data-source.md) | Lexicon morphology data source | rejected | 2026-08-01 |
| [DR-2026-0017](DR-2026-0017-universal-quran-address.md) | The Universal Qur'an Address | proposed | 2026-08-03 |
| [DR-2026-0018](DR-2026-0018-reading-session-architecture.md) | Reading Session architecture | proposed | 2026-08-03 |
| [DR-2026-0019](DR-2026-0019-reading-engine-architecture.md) | Reading Engine architecture | proposed | 2026-08-03 |
| [DR-2026-0020](DR-2026-0020-governance-model-for-verified-quranic-explanatory-content.md) | Governance model for verified Qur'anic explanatory content | proposed | 2026-08-10 |
| [DR-2026-0021](DR-2026-0021-automatic-retention-seeding.md) | Automatic Retention Seeding: Revision Queue eligibility amendment (amends DR-2026-0004) | accepted | 2026-08-10 |
| [DR-2026-0022](DR-2026-0022-review-evidence-architecture-for-verified-quranic-explanatory-content.md) | Review-evidence architecture for verified Qur'anic explanatory content | proposed | 2026-08-10 |
| [DR-2026-0023](DR-2026-0023-boundary-triggered-revision-moments.md) | Boundary-Triggered Revision Moments: completion detection, invitation persistence, and scoped revision targets | accepted | 2026-08-11 |
| [DR-2026-0024](DR-2026-0024-srs-review-event-storage.md) | SRS review event storage | accepted | 2026-08-15 |
| [DR-2026-0025](DR-2026-0025-analytics-review-event-consumption-boundary.md) | Analytics review-event consumption boundary | accepted | 2026-08-16 |
| [DR-2026-0026](DR-2026-0026-hifz-historical-review-count-and-pace.md) | Hifz historical review count and review pace (read boundary) | accepted | 2026-08-16 |
| [DR-2026-0027](DR-2026-0027-retention-observation-instrument.md) | Retention observation instrument (read-only boundary) | accepted | 2026-08-18 |
| [DR-2026-0028](DR-2026-0028-decision-record-authority-over-main.md) | Decision Record authority over `main` | accepted | 2026-08-19 |
| [DR-2026-0029](DR-2026-0029-qac-lexicon-licensing-decision.md) | QAC/Lexicon licensing: MASAQ rejection and unresolved-dependency governance | accepted | 2026-08-22 |
| [DR-2026-0030](DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md) | Formal deferral of Lexicon and Flashcards from v1.0 | accepted | 2026-08-22 |

`DR-2026-0017` is partially implemented: Sprint F0 (Phase 4) shipped its
Surah/Āyah subset as `lib/core/quran/quran_address.dart`. The record
remains `proposed` because its later milestones — Word/Segment levels,
`Range`, and the schema change at M4 — are neither built nor approved,
and M4 additionally requires `PROJ-P-002` sign-off.

## Authority over `main` (DR-2026-0028)

[`DR-2026-0028`](DR-2026-0028-decision-record-authority-over-main.md)
separates two questions about a Decision Record that this directory had
previously conflated.

**Approval** is what `status: accepted` records: the decision was made,
by the named deciders. **Jurisdiction** is which branch the decision
governs. Answering one does not answer the other — a record can be
fully approved and govern nothing on `main`.

**The test for `main` is repository presence.** A Decision Record
governs `main` when, and only when, that record — with
`status: accepted` — is present in `origin/main`'s tree:

```
git ls-tree -r origin/main -- docs/adr/
```

Listed there, it governs `main`. Not listed there, it does not. Nothing
substitutes for that test — not acceptance on another branch, not
presence in a working tree, not restoration from history, and not
citation by code on `main`. Implementation citations establish only
that someone referenced a record; they are never evidence of its
authority.

**`DR-2026-0006` … `DR-2026-0013` are accepted historical records that
do not govern `main`.** All eight were genuinely approved, on
2026-07-25 and 2026-07-26, on the branch `sprint1-my-library`. All
eight keep `status: accepted`, unchanged, and their content is
untouched. None of the eight is present on `origin/main`, so none of
them governs `main`, and `main` is not in breach of them: they are
authoritative history of what was decided on that branch, not
obligations on this one. Any of them may become governing for `main`
later, by a separate review that publishes it here — a review
`DR-2026-0028` neither performs nor prejudges.

The rule is **declaratory**. It invalidates no approval given before
its date, changes no record's `status`, supersedes nothing, and
reclassifies nothing as rejected. What it supplies is the missing
jurisdiction test, stated once, so the question is not re-argued per
record.

`DR-2026-0028` is subject to its own rule: it governs `main` once it is
present on `origin/main`, and not before.

## Known gap: `DR-2026-0002`

Referenced by id from 10 files in `lib/` (14 occurrences total —
**corrected 2026-08-23, Session 89 documentation-reconciliation pass**,
by direct `grep` against the working tree; previously undercounted as
"six places"): `app/router.dart`;
`features/quran/presentation/reading/reading_navigation.dart`;
`features/search/presentation/search_screen.dart` and three
`features/search/presentation/widgets/*.dart` files
(`search_result_section.dart`, `result_card.dart`,
`search_error_state.dart`); `features/study/presentation/revision_queue_screen.dart`;
`features/library/presentation/library_screen.dart`;
`features/learning/presentation/review_session_screen.dart`; and
`features/khatm/presentation/active_khatm_card.dart` — plus
`CHANGELOG.md` — but, like `DR-2026-0003` was until this same
Sprint-9 Phase-0 pass, it was never saved into this directory; it
only ever existed as a chat-session artifact from Sprint 7.1's
planning. Every one of those references currently points at nothing
a reader of this repository can open.

Not backfilled as part of this pass — Sprint 9's Phase 0 scope was
`DR-2026-0003` and `DR-2026-0004` specifically. Flagged here, and in
`TODO.md`, so it isn't lost a second time.
