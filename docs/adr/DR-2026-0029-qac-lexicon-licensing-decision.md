---
id: DR-2026-0029
scope: project
owner_role: constitution-owner
date: 2026-08-22
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-22
reversibility: soft
threshold_reason: [security-privacy-legal-change, materially-different-approaches]
links:
  task: "Session 47 governance gate output (QAC Lexicon licensing) — routed to human decision; Session 48 drafts this record"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0029 — QAC/Lexicon licensing: MASAQ rejection and unresolved-dependency governance

**Status of this record: accepted** by the `owner_role`
(constitution-owner `duso`) on 2026-08-22; `review_by` 2027-02-22.
Acceptance makes it an accepted Decision Record. It is present on
`origin/main` (merged via PR #24, commit `667e292`); by
`DR-2026-0028`'s test (accepted **and** present on `origin/main`) it
now governs `main` (see "Consequences"). It states facts drawn
from repository evidence, a conservative decision set, and an evidence
rule for future resolution. Acceptance was the `owner_role`'s call, same
posture as `DR-2026-0014` and `DR-2026-0016`. This record authorizes
**no implementation**: no parser is written, no dataset is downloaded,
no schema changes, no code under `lib/` or `tool/` is touched, and no
other document in this repository is edited by it.

This record does not assert that a QAC permission request was ever
sent, and does not assert that one was never sent. It states only what
repository evidence shows: no such request, or any response to one, is
recorded anywhere in this repository.

## Relationship to existing records

- **`DR-2026-0016`** ("Lexicon morphology data source", `proposed`,
  2026-08-01) recommended adopting MASAQ (stated there as CC BY 4.0) as
  the Lexicon source, subject to a format-validation gate (its Decision
  2). That gate has since run — see Facts, below — and failed. This
  record does not amend `DR-2026-0016` and does not edit it. It records
  the outcome of the gate `DR-2026-0016` itself required, and states a
  disposition for `DR-2026-0016` in prose (§"`DR-2026-0016` disposition"
  below) without altering that record's own `status` field.
- **`DR-2026-0028`** ("Decision Record authority over `main`", `accepted`,
  present on `origin/main`) supplies the jurisdiction test this record
  relies on: a Decision Record governs `main` only when accepted **and**
  present on `origin/main`. `DR-2026-0016` is present on `origin/main`
  but remains `proposed` and therefore fails the acceptance leg of that
  test; it never governed `main`. This record inherits the test rather
  than restating it.

## Context

The Lexicon feature (F1) and Flashcards (F2) are built but non-functional
on a real install: all 8 Lexicon tables ship with 0 rows.
`RELEASE_DASHBOARD.md` and `docs/release/RELEASE_PLAN_V1.md` both list
Lexicon content as `WAITING_EXTERNAL_DECISION`, owned by the Product
Owner, with the recorded dependency **"QAC permission response
(corpus.quran.com)"** and a decision deadline of **2026-08-24**.

`DR-2026-0016` proposed resolving this by switching the Lexicon source
from QAC to MASAQ, gated on a format-validation step it specified as the
first task of implementation. `docs/release/MASAQ_ACCEPTANCE_REPORT.md`
records that validation having been run against the real, hash-verified
dataset file (`MASAQ.tsv`, SHA-256
`aac224f1b852a1a87e5a896b76c4b55df7c29369a7da836aea1b7286a9c3a931`,
Mendeley `10.17632/9yvrzxktmr`, retrieved via that dataset's v5 file
endpoint; v5 and v6 are byte-identical — `MASAQ_ACCEPTANCE_REPORT.md`
§1, §2). Its headline finding: **REJECT**, on two independently
disqualifying grounds.

## Facts

1. **The current MASAQ dataset has no Root column and no Lemma
   column.** Verified against the real 19-column TSV/DB schema, not
   published descriptions. Because v5 and v6 are byte-identical
   (`MASAQ_ACCEPTANCE_REPORT.md` §2), this finding holds for both
   versions; it is not a v6-only defect.
   `tool/lexicon/normalizer.py:242-250` discards any content word for
   which neither is present — with both columns absent, output is 0
   rows in `roots`, `lemmas`, and `word_instances`, i.e. the exact
   empty-Lexicon state already shipping.
   (`docs/release/MASAQ_ACCEPTANCE_REPORT.md` §3, §4.2, §5.)
2. **MASAQ's currently published version (v6) carries CC BY-NC 3.0,
   not CC BY 4.0.**
   `DR-2026-0016` and `docs/release/LEXICON_DATASET_VALIDATION.md`
   both stated CC BY 4.0; both are corrected by
   `docs/release/MASAQ_ACCEPTANCE_REPORT.md` §2 and §6, which found the
   licence changed between v5 (CC BY 4.0, 12 Nov 2024) and v6 (CC
   BY-NC 3.0, 10 Dec 2024) on byte-identical data, and that the
   NonCommercial v6 is the version currently published.
3. **Either finding independently defeats `DR-2026-0016`'s Decision 1**
   ("Adopt MASAQ (CC BY 4.0) as the Lexicon morphology source"). Finding
   1 defeats it on the pipeline's own structural contract, regardless of
   licence; finding 2 defeats it because the recommendation was
   conditioned specifically on CC BY 4.0, and the currently published
   MASAQ version does not carry that licence — a defeat of
   `DR-2026-0016`'s own CC-BY-4.0-conditioned recommendation, not a
   general legal conclusion about CC BY-NC 3.0 data. The proposed
   adoption of the current MASAQ dataset therefore cannot be accepted
   under `DR-2026-0016`'s own terms. Finding 1, being a property of the
   bytes, is not escaped by reverting to v5.
4. **No repository evidence exists that a QAC permission request was
   ever sent.** A search of this repository finds no email, no ticket,
   no logged correspondence, and no code or document recording that
   `fetch_morphology.py`'s deliberate non-automation of QAC's licence
   acceptance (`DR-2026-0016` §Problem) was ever followed by a human
   completing that step. `RELEASE_DASHBOARD.md:1090` records an
   **instruction** to send the request ("Send the QAC permission request
   today") dated 2026-08-03; the repository contains no record of that
   instruction having been carried out. This record does not conclude
   that no request was sent — only that no repository evidence
   establishes that one was.
5. **QAC permission therefore remains an unresolved external
   dependency.** `RELEASE_DASHBOARD.md:643` and `RELEASE_PLAN_V1.md:171-174`
   both still carry `WAITING_EXTERNAL_DECISION` against a
   **2026-08-24** deadline, two days after this record's date
   (2026-08-22). This record does not edit either document (see
   "Release documents", below) and does not change that deadline.
6. **`DR-2026-0016` is present on `origin/main` but remains `proposed`
   and was never accepted.** It therefore fails the acceptance leg of
   the `DR-2026-0028` test and never governed `main` — independent of,
   and prior to, any question this record raises about its content.

## Options Considered

**Option A — Treat `DR-2026-0016`'s MASAQ recommendation as still live
pending re-validation against a different MASAQ artifact (e.g. the
SQLite distribution, or a re-request to the authors for root/lemma
data).** Rejected for this record's scope. `MASAQ_ACCEPTANCE_REPORT.md`
§4.5 already inspected the SQLite distribution (`MASAQ.db`) and found
the same absence — no `roots` table, no `lemmas` table, only
tag-description glossaries and word indexes. Re-requesting different
data from the authors would be a new, separate dataset-acquisition
effort, not a defense of adopting the current MASAQ dataset; it is
out of scope here (see "Decision 5").

**Option B — Declare `DR-2026-0016` `superseded` in this record's own
frontmatter (`supersedes: DR-2026-0016`).** Rejected. The schema
(`eis-core/schemas/decision-record.schema.md` — the external EIS Core
schema this project is pinned to per `CLAUDE.md`, not a file inside
this repository) requires that `status: superseded` on a record hold
only when exactly one other DR's
`supersedes` field points back to it — a mutual pointer. Setting that
field here without `DR-2026-0016` itself being edited to
`status: superseded` would assert a link that does not exist on both
sides, and this session's scope forbids editing `DR-2026-0016`. See
"`DR-2026-0016` disposition", below, for the disposition this record
uses instead.

**Option C — Silently drop the Lexicon/MASAQ question and let
`DR-2026-0016` stand as the only Decision Record on file, unaddressed.**
Rejected — but not on the ground that the release documents hide the
MASAQ outcome. They do not. `RELEASE_DASHBOARD.md:650-652` and
`RELEASE_PLAN_V1.md:181-182` **already record that MASAQ was evaluated
as a replacement and rejected on the structural ground, and already link
`MASAQ_ACCEPTANCE_REPORT.md`.** The gap Option C would leave is narrower
and different: no Decision Record captures the **licensing** consequence
(Fact 2) or the **governance** consequence — that `DR-2026-0016`'s
Decision 1 is not accepted, that `DR-2026-0016` never governed `main`,
and which of its safeguards survive on some other record's authority.
Left alone, the only *Decision Record* on file would keep reading as a
live recommendation to adopt MASAQ under CC BY 4.0 — a licence the
currently published version does not carry. That is the gap this record
closes, and the only one it claims to.

**Option D — Record the MASAQ rejection and the QAC non-evidence as a
conservative, evidence-only Decision Record; leave `DR-2026-0016`'s own
`status` field, the release documents, and `docs/LICENSING.md` for
separate, later actions. — Chosen.** This is the narrowest option that
closes the gap Option C leaves, without the overreach Option B would
require, and without deciding (Option A) a dataset-sourcing question
this record has no new evidence for.

## Decision

**1. The current MASAQ dataset is not adopted as the Lexicon morphology
source.** MASAQ was proposed by `DR-2026-0016` as a **replacement for
QAC** in that role; it was never "the QAC Lexicon source", and nothing
here treats it as one. It is that replacement proposal —
`DR-2026-0016`'s Decision 1 — that is not accepted.

**Scope.** The current MASAQ dataset published on Mendeley
(`10.17632/9yvrzxktmr`, **v5 and v6, byte-identical** per
`MASAQ_ACCEPTANCE_REPORT.md` §2). Naming both versions is deliberate:
the structural ground below is a property of the bytes, so reverting to
v5 would not cure it.

Two independent grounds, of two different kinds:

- **Structural — a technical validation result.** The dataset
  carries no Root column and no Lemma column, neither in the 19-column
  TSV nor as a table in the SQLite distribution, and therefore does not
  satisfy the `Segment`/`normalizer.py` data contract (Facts 1, 3).
  This ground is version-independent and licence-independent.
- **Licensing — a failure of a condition this project set, not a
  legal conclusion.** The currently published version (v6) is
  CC BY-NC 3.0, not the CC BY 4.0 on which `DR-2026-0016`'s
  recommendation was expressly conditioned (Facts 2, 3). This record
  states only that the stated condition is unmet by what is currently
  published. It does **not** hold that CC BY-NC 3.0 data is unusable,
  and reaches no general legal conclusion about that licence or any
  other.

QAC's own licensing position is untouched by this decision; it is
addressed separately in Decision 3.

**2. Do not implement a MASAQ parser or build Lexicon/Flashcards against
the current MASAQ dataset (v5/v6).** No `masaq_parser.py`,
`fetch_masaq.py`, or equivalent is authorized by this record.
`tool/lexicon/segment_parser.py` is not modified by this record, and is
not to be modified on the basis of the current MASAQ dataset — the
specific instance of the general rule stated in Decision 4(c).

**3. Treat QAC licensing/permission as unresolved external governance
until authoritative evidence is obtained.** No repository evidence of a
sent QAC permission request exists (Fact 4). This record does not state
that no request was sent, does not state that a response was or was not
received, and does not draw any conclusion about QAC's licence terms
beyond what `DR-2026-0016`'s own Problem section already recorded. See
"QAC external evidence rule", below, for what would change this.

**4. Adopt the following architectural safeguards on this record's own
authority.** These rules are enacted **by `DR-2026-0029` itself**. They
are **not inherited from `DR-2026-0016`**: `DR-2026-0016` was never
accepted and therefore never governed `main` (Fact 6), so it never
imposed them and could not have. Its mention below is **historical
attribution only** — crediting where the reasoning was first written
down — and carries no governing force.

**(a) Licence before distribution.** Acquisition and licensing must be
resolved before distribution. A dataset is not adopted because it is
convenient; it is adopted because its licence and its structure both
clear review first.

**(b) Validate before adopt, against the real artifact.** Validation
must occur before adoption, against the actual file rather than
published descriptions — the exact gate that caught MASAQ's failure
(`MASAQ_ACCEPTANCE_REPORT.md` §6: *"The validation gate that
`DR-2026-0016` insisted on is precisely what caught this"*).

**(c) Source-specific parsing stays isolated behind the `Segment`
contract.** The pipeline's seam is
`<source file>` → parser → `Segment` → `normalizer.py` →
`sqlite_writer.py`, and only the parser is source-specific: the
`Segment` dataclass is defined at `tool/lexicon/segment_parser.py:38-39`
and consumed by `tool/lexicon/normalizer.py:22,142`, which names no
source. Operatively:

- **`tool/lexicon/segment_parser.py` must not be modified to
  accommodate a new Lexicon source.** It is the QAC-format reference
  parser and keeps its own tests
  (`tool/lexicon/tests/test_segment_parser.py`).
- **A new source must use a sibling parser** — a separate module
  alongside `segment_parser.py` — **emitting the same `Segment`
  dataclass/contract**, so that `normalizer.py` and `sqlite_writer.py`
  require no change.
- **This does not freeze `segment_parser.py`.** Ordinary maintenance of
  the QAC-format parser — bug fixes, added tests, refactors, or
  corrections to its handling of the QAC format itself — remains
  permitted and is not restricted by this record. The prohibition is
  narrow and specific: do not bend the QAC-format parser to fit a
  *different* source's format.

**(d) Both gates apply to every future source.** Any future Lexicon
source — MASAQ under a different artifact or version, QAC under a
resolved licence, or a different corpus entirely — must
independently pass both structural and licensing validation before any
implementation begins.

**5. Do not automatically adopt an alternative Lexicon source merely
because the current MASAQ dataset failed.** `MASAQ_ACCEPTANCE_REPORT.md` §8 names
candidates (the current MASAQ artifact under a different validation
angle, Text-Fabric Quran corpus, CAMeL Tools-generated analysis) and a
non-Lexicon use for MASAQ's syntactic annotation. None of that is
adopted, endorsed, or ruled out here. Any replacement source is a
separate evidence/licensing/architecture decision, to be brought as its
own Decision Record under the same gate this record adopts (Decision
4).

## `DR-2026-0016` disposition

`DR-2026-0016` remains, in its own frontmatter, `status: proposed`. This
record does not edit that file and does not change that field. Two
things follow from that, read together:

**It was never governing authority.** By `DR-2026-0028`'s test — accepted
**and** present on `origin/main` — `DR-2026-0016` never governed `main`,
independent of anything this record adds. It was `proposed`, unaccepted,
before this record existed; it still is.

**Neither `rejected` nor `superseded` can be validly applied to it by
this record.** The schema (`eis-core/schemas/decision-record.schema.md`)
makes `status` a field the record itself carries, and:
- `superseded` additionally requires a mutual pointer — this record's
  `supersedes` naming `DR-2026-0016`, and `DR-2026-0016`'s own status
  reading `superseded` in turn. This session's scope forbids editing
  `DR-2026-0016`, so that pointer cannot be validly formed here (Option
  B, rejected above). This record's `supersedes` field is accordingly
  `null`.
- `rejected` is schema-valid vocabulary and, on the evidence in
  `MASAQ_ACCEPTANCE_REPORT.md` §6 ("`DR-2026-0016` must be **rejected or
  superseded**, not accepted. It is still `proposed`, so nothing was
  built on it."), is this record's assessment of the **correct eventual
  disposition** for that record's own field — but setting it is an edit
  to `DR-2026-0016` itself, which is out of scope for this session.

**Recommendation, not an action taken here:** a future session, acting
directly on `DR-2026-0016` (not on this record), should set its
`status` to `rejected`, recording `DR-2026-0016`'s Decision 1 as not
accepted for the reasons in Facts 1–3 above. Until that happens,
`DR-2026-0016` continues to read as `proposed` to anyone opening it
directly — this record is the place that documents why its
recommendation should not be acted on in the meantime.

## QAC external evidence rule

For Decision 3 to be revisited, this record defines what would count as
authoritative evidence of QAC licensing resolution. Any of the
following, obtained and added to the repository as verifiable evidence
(not asserted from memory):

- A written response from QAC / `corpus.quran.com` (or its maintainer)
  addressing the intended use.
- An official licence statement from QAC that clearly covers the
  intended distribution (embedding transformed data in a shipped
  application).
- Explicit official permission or approval for the transformation
  `normalizer.py`/`sqlite_writer.py` perform.
- Authoritative published licensing terms — superseding or clarifying
  the self-contradictory header `DR-2026-0016` §Problem quotes — that
  unambiguously cover the intended use.
- A documented legal/counsel opinion that resolves the ambiguity of the
  existing QAC licence language for the intended use. This is distinct
  from QAC permission itself and from QAC's own official licence terms
  above — it is an independent legal reading of the language already on
  record, not a substitute for obtaining permission or a clearer
  licence statement from QAC. No such opinion has been sought or
  obtained as of this record; nothing here implies otherwise.

None of these currently exists in this repository. This record does not
assert, imply, or anticipate the content of any future response; it
states only the categories of evidence that would be sufficient to
revisit Decision 3.

## Release documents

`RELEASE_DASHBOARD.md` and `docs/release/RELEASE_PLAN_V1.md` are not
edited by this record. What they already carry, and what they do not, is
stated precisely below, so this record is not read as claiming more than
is true.

**Already recorded in both.** Both documents **already record that MASAQ
was evaluated as a replacement and rejected**, on the structural ground
(missing root/lemma columns), and both **already cite
`MASAQ_ACCEPTANCE_REPORT.md`**:

- `RELEASE_DASHBOARD.md:650-652` — "MASAQ was evaluated as a
  replacement and **rejected** (no root/lemma columns —
  `docs/release/MASAQ_ACCEPTANCE_REPORT.md`)".
- `RELEASE_PLAN_V1.md:181-182` — "MASAQ was evaluated as a
  replacement and **rejected** (`MASAQ_ACCEPTANCE_REPORT.md` — no
  root/lemma columns)".

This record therefore does **not** claim that the MASAQ rejection is
missing from the release documents, and neither document should be
described that way.

**Not yet recorded in either.**

- **The licence finding of Fact 2** — that the currently published
  MASAQ version carries CC BY-NC 3.0 rather than the CC BY 4.0
  `DR-2026-0016` relied on. Both documents state the structural ground
  alone.
- **The governance status and authority this record creates** — the
  disposition of `DR-2026-0016` (§"`DR-2026-0016` disposition"), the
  safeguards adopted under Decision 4, the QAC evidence rule under
  Decision 3, and this record's own existence and status.

**Still open and unchanged.** Both continue to carry the QAC dependency
at `WAITING_EXTERNAL_DECISION` against the **2026-08-24** deadline
(`RELEASE_DASHBOARD.md:643`, `RELEASE_PLAN_V1.md:171-174`), two days
after this record's date (2026-08-22). This record does not change that
deadline.

With this record accepted,
those two documents need a **partial** reconciliation pass: adding the
licence finding and this record's governance status — **not** adding
a MASAQ rejection they already carry. That remains a separate, later
action. This record does not perform it, does not assert that these
documents are otherwise fully reconciled, and does not silently change
either document's status fields.

## Licensing registry follow-up

`docs/LICENSING.md` is not edited by this record. As a follow-up,
with this record accepted, the
QAC/Lexicon licensing position should be represented in
`docs/LICENSING.md` consistently with whatever the accepted decision
states — including that no permission is currently evidenced and that
the current MASAQ dataset (v5/v6) is not adopted. That representation is
left to a later, separate action.

## `LEXICON_DATASET_VALIDATION.md` follow-up

`docs/release/LEXICON_DATASET_VALIDATION.md` is **not** edited by this
record, and is explicitly identified here as **requiring a later
reconciliation pass**. It is not merely stale documentation: it carries
substantive claims and implementation guidance that the MASAQ acceptance
evidence contradicts.

- **Root/Lemma availability claims.** Its §2 Q1 required-fields table
  ("Does MASAQ contain the required fields?") answers "**Yes, all
  six**" and marks both present — "Root ✅ Dedicated Root field",
  "Lemma ✅ Dedicated Lemma field"
  (`docs/release/LEXICON_DATASET_VALIDATION.md:37,41-42`) — and its
  risk table rates sparse root/lemma "low likelihood" on the reasoning
  that "MASAQ explicitly carries both" (`:152`). The real 19-column
  file carries neither (Fact 1).
- **Implementation planning against the now-rejected dataset.** It
  prescribes a sibling `fetch_masaq.py` and a `masaq_parser.py`
  emitting the `Segment` dataclass, with line estimates and a build
  order ending "Only then write `masaq_parser.py` + mapping layer +
  tests" (`:69-70`, `:135-136`, `:298`). Decision 2 authorizes none of
  that work against the current MASAQ dataset.

`MASAQ_ACCEPTANCE_REPORT.md` §6 (`:254-256`) already **logs** both the
Root/Lemma correction and the licence correction against this document,
and adds a column-count correction (`:258`). Logging them there did not
**edit** this document: it still reads as originally written. §6 also
does not touch the implementation-planning guidance (`:69-70`,
`:135-136`, `:298`) at all. Reconciling the document itself is a
separate, later action; this record neither performs it nor treats that
document as corrected.

## Consequences

- `DR-2026-0016`'s MASAQ recommendation is documented as not accepted,
  without editing `DR-2026-0016` itself.
- No implementation work is authorized: `tool/lexicon/segment_parser.py`
  is unchanged, no `masaq_parser.py` is created, no dataset is added to
  the repository.
- The QAC dependency in `RELEASE_DASHBOARD.md` /
  `docs/release/RELEASE_PLAN_V1.md` remains open and unedited by this
  record. Both documents already record the MASAQ **structural**
  rejection; what they lack is the Fact 2 licence finding and this
  record's governance status. That **partial** reconciliation is
  flagged here as a later action, not resolved.
- `docs/release/LEXICON_DATASET_VALIDATION.md` is explicitly flagged as
  requiring a later reconciliation pass — its Root/Lemma
  availability claims and its `masaq_parser.py`/`fetch_masaq.py`
  implementation planning are inconsistent with the MASAQ acceptance
  evidence; not edited here.
- `docs/LICENSING.md` is flagged as requiring a future, consistent
  representation of this decision; not edited here.
- The architectural safeguards first articulated in `DR-2026-0016`
  — licence before distribute (4a); validate before adopt against
  the real artifact (4b); source-specific parsing kept isolated behind
  the `Segment` contract, with `tool/lexicon/segment_parser.py` not
  modified to accommodate a new source and each new source given a
  sibling parser emitting the same `Segment` contract (4c); both gates
  applying to every future source (4d) — are **adopted by this
  record as its own Decision 4**, on this record's authority and not
  inherited from `DR-2026-0016`, which never governed `main`. Ordinary
  maintenance of `segment_parser.py` for the QAC format it already
  serves is expressly not restricted (4c).
- This record is present on `origin/main` (merged via PR #24, commit
  `667e292`); by the `DR-2026-0028` test (accepted and present on
  `origin/main`) it governs `main`.
- **Reversibility is soft.** This record can be superseded by a later DR
  — e.g. one that accepts a new Lexicon source under the evidence rule
  above, or one that formally defers Lexicon/Flashcards from v1.0 — with
  no code or schema rollback required, because no code or schema is
  touched here.

## Out of scope

Named explicitly, so none of these is read as settled here:

- **Editing `DR-2026-0016`'s own `status` field.** Recommended
  (`rejected`), not performed.
- **Whether a QAC permission request should now be sent, by whom, or
  what its content should be.** Outside this record's evidence and
  outside engineering scope per `RELEASE_PLAN_V1.md`'s own framing
  (Product Owner, not engineering).
- **Any legal reading of QAC's licence header** (`DR-2026-0016`
  §Problem's "changing it is not allowed" clause). `MASAQ_ACCEPTANCE_REPORT.md`
  §8 explicitly calls this "a lawyer's call, not an engineer's"; this
  record does not attempt one.
- **Formal deferral of Lexicon/Flashcards from v1.0.**
  `MASAQ_ACCEPTANCE_REPORT.md` §8 lists this as a strengthening fallback
  option; this record neither adopts nor rejects it.
- **Evaluation of alternative Lexicon sources** (Text-Fabric Quran
  corpus, CAMeL Tools-generated analysis, or others). Decision 5 leaves
  this to a separate Decision Record.
- **Reconciling `RELEASE_DASHBOARD.md` and `RELEASE_PLAN_V1.md`** to
  add the licence finding and this record's governance status. Left to
  a later action, per "Release documents" above; their existing record
  of the MASAQ structural rejection needs no addition.
- **Reconciling `docs/release/LEXICON_DATASET_VALIDATION.md`** — its
  Root/Lemma availability claims and its MASAQ implementation plan.
  Identified above as a required follow-up; not performed here.
- **Updating `docs/LICENSING.md`.** Left to a later action, per
  "Licensing registry follow-up" above.

## References

- `docs/adr/DR-2026-0016-lexicon-data-source.md` — the record whose
  Decision 1 is not accepted by this record.
- `docs/adr/DR-2026-0028-decision-record-authority-over-main.md` — the
  jurisdiction test this record relies on.
- `docs/release/MASAQ_ACCEPTANCE_REPORT.md` — the validation evidence
  Facts 1–3 are drawn from.
- `docs/release/LEXICON_DATASET_VALIDATION.md:37,41-42,69-70,135-136,152,298`
  — the Root/Lemma availability claims and MASAQ implementation
  planning identified above as requiring reconciliation.
  `MASAQ_ACCEPTANCE_REPORT.md` §6 (`:254-258`) logs corrections against
  the first of these but does not edit the document, and does not
  address its implementation planning at all.
- `RELEASE_DASHBOARD.md:643,650-652,1038-1042,1087-1093` — QAC
  dependency, the already-recorded MASAQ structural rejection, the
  Go/No-Go checklist item, and the 2026-08-03 instruction to send a
  request.
- `docs/release/RELEASE_PLAN_V1.md:171-174,181-182` — QAC dependency
  status, owner, deadline, and the already-recorded MASAQ structural
  rejection.
- `eis-core/schemas/decision-record.schema.md` — status vocabulary and
  the `superseded` mutual-pointer rule this record relies on; the
  external EIS Core schema this project is pinned to, not a file in
  this repository.
- `tool/lexicon/normalizer.py:242-250` — the root/lemma discard
  logic Fact 1 cites; `:22,142` — its consumption of the `Segment`
  contract.
- `tool/lexicon/segment_parser.py:38-39` — the `Segment` dataclass
  that Decision 4(c) makes the isolation seam;
  `tool/lexicon/tests/test_segment_parser.py` — the tests it
  keeps.
- `tool/fetch_morphology.py` — the deliberate non-automation of QAC
  licence acceptance, unchanged by this record.
