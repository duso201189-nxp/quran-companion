---
id: DR-2026-0028
scope: project
owner_role: constitution-owner
date: 2026-08-19
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-19
reversibility: soft
threshold_reason: [constitution-touching, materially-different-approaches]
links:
  task: "Session 20.1 governance authority audit / Session 20.2 validation / Session 21 filing"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0028 — Decision Record authority over `main`

**Status of this record: accepted.** It is a governance decision only.
It creates **zero production behavior**: no code, no schema change, no
migration, no test, no CI change, no asset change. It changes no
existing record's `status`, supersedes nothing, deletes nothing, and
rewrites nothing.

This record is **declaratory**. It states how authority over `main` is
determined; it does not retroactively invalidate any prior approval.
Every record that was `accepted` before this one remains `accepted`.

## Context

This project keeps its Decision Records in `docs/adr/`, under
`DR-2026-0001`'s adoption of EIS Core `v0.1.0`. `CORE-P-004`
(traceable-decisions) requires that a decision meeting the Decision
Threshold produce a Decision Record, and
`eis-core/schemas/decision-record.schema.md` gives that record a
`status` field whose `accepted` value marks the decision as approved.

Neither `CORE-P-004`, the schema, nor `PROJECT_CONSTITUTION.md` says
**where** an approved record must exist for it to bind this project's
mainline. That gap was latent until it produced a concrete, measured
ambiguity.

`DR-2026-0006` through `DR-2026-0013` were written, approved, and
committed on 2026-07-25 and 2026-07-26, in commits `b3739e5`, `2fb5fd5`
and `1d4cf2c`. All three commits sit on `sprint1-my-library` (also
reachable from `ci/dataset-verification-workflow`, and from both of
their `origin` counterparts). None of the three is an ancestor of
`origin/main`. `git ls-tree -r origin/main -- docs/adr/` does not list
any of the eight files. They were never deleted; they simply never
arrived. Sessions 18 and 19 restored the eight documents into the
working tree byte-identically — `git hash-object` on each restored file
reproduces the original blob SHA exactly — so the documents are
readable again, but restoration into a working tree decided nothing
about their force.

That produced the open question. Each of the eight carries
`status: accepted` and `deciders: [duso]`. Several are cited by
implementation and tests that live on `main`: the failure message in
`test/repository_boundary_test.dart` names
`DR-2026-0009-data-supply-chain.md`, and that same file grandfathers
`assets/database/quran.sqlite` with a reason naming `DR-2026-0008`'s
move B. Read one way, eight approved records already bind `main`, and
`main` is in breach of most of them. Read the other way, `main` is
governed only by the accepted records present on it, and the eight are
history.

The two readings differ in what they demand. The first would make
`main` retroactively non-compliant with decisions no reader of `main`
can open, and would let an accepted record on any branch — including an
abandoned one — silently acquire force over mainline. The second leaves
`main`'s governing set equal to what a reader of `main` can actually
read.

This record settles which reading holds. It is `constitution-touching`
because it fixes the meaning of `status: accepted` with respect to
jurisdiction, and `materially-different-approaches` because the two
readings above are genuinely different governance models, not parameter
variations of one.

## Options Considered

**Option A — `accepted` anywhere confers authority over `main`.**
Any record with `status: accepted`, on any branch, governs `main` from
the moment a decider accepts it. Rejected. It makes the governing set
of `main` unknowable from `main`: establishing what rules apply would
require enumerating every ref, including abandoned ones, and no reader
of the repository's mainline could list its own obligations. It also
makes governance silently expandable — accepting a record on a private
branch would bind mainline without any mainline change ever occurring.
Under this option `main` is immediately in breach of decisions its own
contributors cannot read, which is the failure mode `CORE-P-005`
(documented-truth) exists to prevent.

**Option B — implementation citations confer authority.** Treat a
record as governing `main` when `main`'s code, tests, or documents cite
it by id. Rejected. It inverts the direction of authority: a citation
is evidence that someone believed a rule applied, not evidence that it
was approved for this branch. It is also demonstrably unsound here —
`main` cites `DR-2026-0002` from ten files in `lib/` for a record that
was never committed anywhere and is `proposed`, and cites
`DR-2026-0008` and `DR-2026-0009` while diverging from what both
decided. Under this option a copied comment would create governance.

**Option C — authority requires a separate ratification record per
decision.** Every branch-accepted record would need a second, mainline
record ratifying it before it binds `main`. Rejected as disproportionate
for the general case: it doubles the record count for every ordinary
decision, including the many that are authored and merged in one motion,
to solve a problem that arises only when a record and the branch it was
accepted on diverge. It also introduces a second approval concept
without removing the ambiguity in the first.

**Option D — authority over `main` follows presence of the approved
record on `origin/main`.** Chosen. It uses a fact that is already
recorded, already mechanically checkable by anyone holding the
repository, and already the thing this project's publishing practice
produces. It requires no new artifact type, no new status value, and no
per-decision ceremony. Its cost is that it makes the eight
branch-accepted records non-governing for `main` until they are
reviewed and published there — which this record accepts as the correct
outcome rather than an unwanted side effect, because those eight have
never been readable from `main` and `main`'s implementation was never
built to them.

## Decision

**1. Approval and jurisdiction are distinct.** They are two separate
questions about a Decision Record, and answering one does not answer
the other. *Approval* asks whether the decision was made, and by whom.
*Jurisdiction* asks which branch the decision governs. A record can be
fully approved and govern nothing on `main`.

**2. `status: accepted` establishes approval, not automatic authority
over every branch.** `accepted` means exactly what the schema says it
means: the decision was approved. That is a true and permanent
statement about the decision. It is not, by itself, a statement that
the decision governs `main` or any other branch.

**3. Authority over `main` is determined by presence of the approved
Decision Record on `origin/main`.** A Decision Record governs `main`
when, and only when, the record — with `status: accepted` — is present
in `origin/main`'s tree. This is the operative test, and it is the only
test. It is decidable by one command:

```
git ls-tree -r origin/main -- docs/adr/
```

If the approved record's file is listed there, it governs `main`. If it
is not listed there, it does not govern `main`. No other condition
substitutes for this one: not acceptance on a branch, not presence in a
working tree, not restoration from history, not citation from code, and
not the intent of whoever accepted it. `origin/main` is named
deliberately rather than a local `main`, so that the test resolves
against the shared published branch and not against any one machine's
checkout.

**4. An accepted DR on a non-`main` branch does not govern `main`
merely because a decider accepted it.** The identity of the decider is
not the missing ingredient. `deciders: [duso]` on a branch record and
`deciders: [duso]` on a `main` record differ in jurisdiction, not in
authority to decide. Bringing a branch-accepted record under `main`'s
authority is done by putting the record on `origin/main`, not by
re-asserting who accepted it.

**5. `DR-2026-0006` through `DR-2026-0013` remain accepted historical
records, and are historical-only with respect to `main`.** All eight
keep `status: accepted`. All eight were genuinely approved, on
2026-07-25 and 2026-07-26. None of the eight is present on
`origin/main`, and therefore none of the eight governs `main` today.
They are authoritative history of what was decided on
`sprint1-my-library`; they are not obligations on `main`. `main` is not
in breach of them, because they do not apply to `main`. Each may become
governing for `main` later, by a separate review that publishes it into
`main` — a review this record neither performs nor prejudges.

**6. No historical record is deleted, rewritten, or reclassified.**
This decision changes no `status` field. It supersedes nothing. It
marks no record `rejected` or `superseded`. It does not edit the
content of `DR-2026-0006` … `DR-2026-0013`, whose bytes are preserved
exactly as approved. "Historical-only with respect to `main`" is a
statement of jurisdiction recorded *about* those records; it is not a
change *to* them.

**7. Implementation citations are not evidence of governance
authority.** Code, tests, comments, CHANGELOG entries and release
documents on `main` that cite a record by id establish only that
someone referenced it. They do not establish approval, and they do not
establish jurisdiction. Where `main` cites a record that is not present
on `origin/main`, the citation is a dangling reference, to be corrected
or resolved on its own merits — not a route by which the cited record
acquires force over `main`.

**Declaratory, not retroactive.** This record does not invalidate any
approval given before its date. Every record accepted before
2026-08-19 remains accepted. What this record supplies is the missing
jurisdiction test, stated once, so that the question is not re-argued
per record.

## Consequences

- **New file:** this record. **Changed file:** `docs/adr/README.md`,
  which registers this record and classifies `DR-2026-0006` …
  `DR-2026-0013` as accepted historical records that do not govern
  `main`. Nothing else changes.

- **No implementation change is authorized or required.** No file under
  `lib/`, `test/`, `integration_test/`, `tool/`, `.github/workflows/`,
  `assets/`, and no database schema, is touched by this decision, and
  none is obliged to change because of it. In particular, `main`'s
  `test/repository_boundary_test.dart`, its CI content-build step, its
  tracked `assets/database/quran.sqlite`, and its single `DATA_VERSION`
  axis are **not** made non-compliant by this record — the eight
  records those facts diverge from do not govern `main`.

- **The governing set of `main` becomes enumerable from `main`.** As of
  this record's date, `origin/main` carries eighteen Decision Records,
  of which eleven have `status: accepted`: `DR-2026-0001`,
  `DR-2026-0003`, `DR-2026-0004`, `DR-2026-0005`, `DR-2026-0015`,
  `DR-2026-0021`, `DR-2026-0023`, `DR-2026-0024`, `DR-2026-0025`,
  `DR-2026-0026`, `DR-2026-0027`. Those eleven govern `main` and are
  unaffected by this decision. This record becomes the twelfth once it
  is itself present on `origin/main` — by its own test, it does not
  govern `main` before then.

- **Eight records move from ambiguous to clearly classified**, without
  any of them losing approval or content. The open question recorded in
  `docs/adr/README.md` under the `DR-2026-0013` and `DR-2026-0006` …
  `DR-2026-0012` restoration notes — *whether the record binds `main` at
  all* — is answered: not until it is present on `origin/main`.

- **A future publication path stays open and is unprejudged.** Any of
  the eight may be reviewed and published into `main`, at which point it
  governs `main` by the same test. This record takes no position on
  whether any particular one should be, on what would then have to
  change in `main`, or in what order.

- **Cost of applying the test is one command.** Determining whether a
  record governs `main` requires no judgment call, no archaeology across
  refs, and no interpretation of intent.

- **Reversibility is soft.** This record is a statement of rule with no
  code behind it; a later superseding DR could adopt a different
  jurisdiction test with no migration and no rollback.

## Out of scope

Named explicitly, so that none of these is read as settled here:

- **`DR-2026-0014`** (`proposed`, present on `origin/main`) is not
  decided by this record.

- **The duplicate `DR-2026-0008` identifier** —
  `docs/reports/release-recovery/ARCHITECTURE_DECISION_RECORD.md` on
  `main` carries `id: DR-2026-0008`, `status: proposed`, as the Sprint
  38.0 working draft of the restored record — is untouched and
  unresolved here.

- **The Human Decision Log / EIS approval-evidence gap** is a separate
  issue, deliberately not bundled into this record.

- **`DR-2026-0002`'s acceptance question** (open item **O7** in
  `docs/reports/release-recovery/ARCHITECTURE_FREEZE_REPORT.md`) is
  unaffected: that record is `proposed`, so the jurisdiction test above
  does not reach it.

- **Whether, when, and how to publish any of `DR-2026-0006` …
  `DR-2026-0013` into `main`** is left to separate review.
