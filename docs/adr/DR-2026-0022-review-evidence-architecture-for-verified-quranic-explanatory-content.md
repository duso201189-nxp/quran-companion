---
id: DR-2026-0022
scope: project
owner_role: constitution-owner
date: 2026-08-10
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [constitution-touching, materially-different-approaches, constrains-future-architecture]
links:
  task: "V2.0 pre-work — architecture for representing and preserving verified Qur'anic explanatory-content review evidence"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0022 — Review-evidence architecture for verified Qur'anic explanatory content

**Status of this record: proposed, not accepted.** It answers one
architectural question and deliberately answers no other. Every item
`DR-2026-0020` §16 left open remains open here, restated in §Open
decisions rather than quietly resolved. This record authorizes no code,
no schema, no specification, and no V1.0 work of any kind.

## Relationship to existing records

This record **builds on `DR-2026-0020` and amends nothing.** That record
settled *whether and under what governance* a future verified
explanatory layer may exist; this one asks only *where the evidence of
review would live* within the architecture that already exists. All four
of its approved owner decisions are carried forward unchanged and
unreinterpreted:

1. No AI generation, paraphrasing, or adjudication of religious content
   at any stage, including private drafts.
2. The feature is governed as Reading/Understanding content, inheriting
   and never weakening `docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md`.
3. It is a V2.0 concept only and must not be implemented in V1.0 in any
   form — code, schema, specification, or UI.
4. Partial verified coverage is permitted; full Qur'an coverage may
   never be claimed until all 6,236 ayat have passed the required
   verification process.

`DR-2026-0021` (Automatic Retention Seeding) is unaffected — it concerns
Revision Queue eligibility and touches nothing here.

## The question this record answers

> How should Qur'an Companion represent and preserve future verified
> Qur'anic explanatory-content review evidence within the existing
> governance architecture, while preserving the absolute boundary that
> AI does not generate, paraphrase, or adjudicate religious content?

It does **not** answer: who reviews, what qualifies them, which sources
are used, what the user sees, or how corrections are disclosed.

## Context

A sequence of read-only reconnaissance passes established the following
as repository fact. Each is load-bearing for the options below.

**On what the existing governance can hold.** `docs/verification/` is
the EIS-sanctioned project-scope location for Verification Records
(`eis-core/schemas/verification-record.schema.md` §Scope). It sits
outside every `_restricted` pattern in `test/repository_boundary_test.dart`
— three are anchored to `assets/database/` and `tool/data/`, the fourth
is extension-based and does not match `.md` — and outside every
`**Files**` row of Streams A–F in
`docs/reports/release-recovery/IMPLEMENTATION_PROGRAM.md`, including the
D1 and D2 untracking phases. Only the generic 2 MB per-file size guard
applies; there is no record-count or directory-size limit anywhere, and
Verification Records are the one artifact type absent from
`eis-core/scalability/SCALE_MODEL.md`'s scalability-trigger table.

**On what a Verification Record can already express.** `verifier`
accepts `human:<name>` as a first-class value alongside
`agent:<session-id>`. `owner_role` is explicitly distinct from
`verifier` — *"who's accountable for this verification category existing
and staying meaningful over time, not who ran this specific instance."*
`independence_level` is mandatory and five-valued. A `## Evidence` body
section is required, because *"a Verification Record with a claimed
result and no attached evidence is exactly the unfalsifiable claim
`CORE-P-001` exists to prevent."* Failed records are never deleted.

**On what it cannot express.** `category` is a seven-value enum, all
engineering (`static`, `runtime`, `architecture`, `documentation`,
`consistency`, `regression`, `release`); none represents scholarly
review, and changing a Core schema enum is a Core release requiring
Constitution Owner sign-off. `subject` is free text, giving no
structured ayah linkage. There is no `supersedes` field. The project has
no VR index, though `eis-core/verification-records/VERIFICATION_LOG.md`
states project-scope records *"are indexed by the project."*

**On what EIS verification procedures actually do.** All seven
`eis-core/skills/verification/run-*-gate.md` specs verify properties of
the system and its artifacts — lint output, test results, cross-document
contradictions, stale references, architecture claims, regression
baselines, and an aggregate of the other six. **None verifies a truth
claim about the world, in any domain.** Six carry `permission_tier: 0`
("act, no confirmation") and one `permission_tier: 1`; not one sits at
Tier 2 or 3, even though `eis-core/CORE_CONSTITUTION.md`'s Permission
Tier Model places *"legal/licensing calls"* at Tier 3.

**On accountability semantics.** EIS distinguishes verifier, owner, and
approver cleanly, but has no concept of reviewer *qualification*.
`independence_level: different-human` means a different person ran the
check and nothing more —
`eis-core/collaboration/MULTI_AGENT_RULES.md` ranks `different-method`
above it and defines none of them in terms of expertise. An EIS Approval
Gate's approver must be *"one of the six canonical roles"*
(`eis-core/decision-system/APPROVAL_GATES.md`), none of which implies
scholarly qualification, and adding a seventh role is not a documented
project extension mechanism.

**On enforcement.** EIS gates are *"discipline-followed rather than
compiler-enforced"* at every layer. In this project the only automated
enforcement is CI (`.github/workflows/ci.yml`) plus the human Go/No-Go
checklist in `RELEASE_DASHBOARD.md` §7. Because `flutter test --coverage`
sweeps all of `test/`, any Dart test is automatically a CI condition —
the route `DR-2026-0013`'s licensing gate already took.

**On what CI could mechanically check.** Tests already open the real
shipped database and git-tracked JSON together, iterate all 6,236 ayat,
and fail with a precise per-ayah address
(`test/content_database_smoke_test.dart`,
`test/ayah_ordinal_real_data_test.dart`, `test/surah_names_test.dart`).
Stable ayah addressing exists and is itself drift-tested. **A test can
therefore verify that a record exists, is complete, and is consistently
linked. It cannot verify that a religious judgment is sound** — that
boundary is not a limitation of any design, it is the nature of the
instrument.

**On premature abstraction.** `docs/release/QURAN_COMPANION_PRODUCT_VISION.md`
§Phase 6 states the project's own position on the platform question:
*"NurVerse is earned, not designed… designing for an unspecified
consumer produces abstractions that fit nothing."* The same section
independently reaches `DR-2026-0020`'s conclusion from a product angle,
naming AI interpretive risk *"the highest theological risk in this
plan"* and requiring that the constraint be *"architectural, not a
prompt instruction."*

## Problem

The reconnaissance leaves one architectural question genuinely open, and
it is not "where do we put a file." It is this: **the only durable,
auditable, human-accountable evidence container this project has was
built to attest that a machine check ran, and a religious review is not
a machine check.** Filing scholarly review inside a Verification Record
without care would conflate two different kinds of claim — and would do
so inside the very field (`category`) whose honesty the schema's own
design goes out of its way to protect.

The failure mode to avoid is precise: a future reader, or a future
release gate, treating *"a Verification Record exists and says pass"* as
*"this explanatory content is religiously sound."* Those are different
assertions with different warrants, and no mechanism in this repository
can produce the second one.

## Conceptual boundaries

This record distinguishes seven concepts. They are not interchangeable,
and this record recommends that no future specification collapse any two
of them into one mechanism — a recommendation, since this record is
`proposed` and binds nothing on its own.

**A · Source** — the Qur'an, a translation of meanings, a Tafsir work, a
Hadith collection, an Asbab al-Nuzul report. Content the project selects
and licenses; it does not author it. Governed today by
`docs/LICENSING.md` and `translation_sources`. *No source in categories
beyond Qur'an and translations is currently approved
(`DR-2026-0020` §9).*

**B · Scholarly review** — a qualified human's evaluation of religious
content. **The only category in this list that can bear on religious
soundness.** No mechanism in this repository performs it, and none can.

**C · Evidence** — the source material a review rests on: which passages
in which named works, at which editions, support which claim. Distinct
from B: evidence is what a reviewer *consulted*; review is what they
*concluded*.

**D · Verification record** — governance and audit evidence that a
review or check *occurred*: who, when, at what independence, with what
attached proof, pass or fail. **Attests process, never truth.** A
Verification Record can honestly say a review happened; it cannot say
the review was right.

**E · Technical integrity** — machine-checkable structural consistency:
does a record exist for a published item, is it complete, does it
reference a valid ayah address, does its reviewer field name a person.
Fully within CI's reach and fully outside any religious question.

**F · Release gate** — whether publication is permitted. Composed from
E (mechanically) and D (as recorded evidence), never from B directly,
because B is not machine-readable.

**G · User-facing explanation** — what the reader actually sees. Must be
presented as reasoned human understanding grounded in A, never as
Allah's words, never typographically indistinguishable from Qur'an text
(`DR-2026-0020` §9). Its wording is an unresolved owner decision.

The single most important relation among these: **E can gate on the
presence of D; D can attest that B occurred; only B can speak to
religious soundness; and nothing automates B.** Any design that lets F
depend on E alone, while implying B, is the failure mode this record
exists to prevent.

## Options Considered

Evaluated against sixteen criteria. "Compatible" below means *requires
no change to the named artifact*, not merely *not forbidden*.

**On the status of these assessments.** §Context above states repository
facts — each is directly verifiable in a named file, and several are
quoted verbatim. The sixteen-criterion assessments below are **not** of
that kind. They are architectural judgments and inferences reasoned *from*
those facts: ratings such as "strong," "weak," "poor," or "strongest"
express this record's evaluation, not something the repository states.
They are offered as argument to be challenged, not as evidence to be
cited. Where an assessment rests on a fact rather than a judgment, the
fact is named.

### Option A — Existing EIS Verification Records with a project-level extension

Record scholarly review directly as Verification Records in
`docs/verification/`, extending conventions at project level (e.g. by
convention in `subject`) to carry ayah linkage.

- **EIS compatibility**: high — no Core change. But `category` has no
  honest value for scholarly review; using `documentation` or `static`
  for a doctrinal judgment would misstate what was checked, against the
  schema's own honesty design.
- **Study Constitution compatibility**: neutral.
- **Religious-content safety**: **weak.** Puts religious substance
  inside a container whose semantics are "a check ran," inviting exactly
  the D-means-B conflation described in §Problem.
- **Human accountability**: strong (`verifier: human:<name>`).
- **AI boundary safety**: neutral — orthogonal to this choice.
- **Auditability**: strong; required `## Evidence`.
- **Git durability**: strong (verified clear of D1/D2 and all boundary
  rules).
- **Ayah-level traceability**: **weak** — free-text `subject` only.
- **Partial-coverage disclosure**: possible by counting records; no
  structure supports it.
- **Correction/history**: partial — fail-never-deleted rule exists; no
  `supersedes` field, and the referencing mechanism is undefined.
- **Release enforcement**: possible via a Dart test.
- **EIS Core impact**: none.
- **Qur'an Companion impact**: low.
- **NurVerse interoperability**: neutral.
- **Complexity**: lowest.
- **Conflation risk**: **highest of the four.** Rejected primarily on
  this criterion, not on cost.

### Option B — A separate Qur'an-specific scholarly review record system, independent of EIS

Build a domain-native review record with no EIS involvement.

- **EIS compatibility**: compatible by avoidance, at the price of
  forfeiting the envelope.
- **Study Constitution compatibility**: neutral.
- **Religious-content safety**: good — domain-shaped, no borrowed
  semantics.
- **Human accountability**: would have to re-invent `verifier`,
  `owner_role`, and `independence_level` from scratch, with no
  `CORE-P-001` anchoring and no honesty discipline inherited.
- **AI boundary safety**: neutral.
- **Auditability**: unproven — every discipline EIS already encodes
  would need re-deriving.
- **Git durability**: achievable.
- **Ayah-level traceability**: strong by design.
- **Partial-coverage disclosure**: strong by design.
- **Correction/history**: designable, but from nothing.
- **Release enforcement**: achievable via CI.
- **EIS Core impact**: none.
- **Qur'an Companion impact**: high — a second governance system to
  maintain alongside the first.
- **NurVerse interoperability**: poor — a bespoke system is the least
  extractable outcome.
- **Complexity**: high.
- **Conflation risk**: low, but bought by discarding proven discipline
  rather than by separating concerns.

### Option C — Extend EIS Core to support scholarly/religious verification

Add a religious/scholarly `category` value, and possibly a
subject-matter reviewer role, to EIS Core itself.

- **EIS compatibility**: requires a Core release with Constitution Owner
  sign-off and a migration note for dependents
  (`CORE_CONSTITUTION.md` §Change Authority). This *is* the sanctioned
  path when a fixed vocabulary genuinely cannot express a need —
  `SCALE_MODEL.md` treats the analogous workflow-category case as *"a
  `constitution-touching` decision… not an ad hoc addition."*
- **Study Constitution compatibility**: neutral.
- **Religious-content safety**: good if done well — but it would make a
  deliberately domain-neutral governance framework carry one project's
  domain concern.
- **Human accountability**: strong; could formalize a reviewer concept.
- **AI boundary safety**: neutral.
- **Auditability**: strong.
- **Git durability**: strong.
- **Ayah-level traceability**: would still need domain modelling.
- **Partial-coverage disclosure**: unaddressed by a category change
  alone.
- **Correction/history**: could add the missing `supersedes`.
- **Release enforcement**: unchanged — Core gates remain
  discipline-followed.
- **EIS Core impact**: **highest.** EIS has exactly one consumer today.
- **Qur'an Companion impact**: blocked on Core release cadence.
- **NurVerse interoperability**: superficially best, but directly
  against the project's own stated discipline that *"NurVerse is earned,
  not designed."*
- **Complexity**: highest.
- **Conflation risk**: moderate — it would make EIS appear to have an
  opinion about religious correctness, which it does not and should not.

### Option D — Hybrid: EIS Verification Record as the governance envelope, a Qur'an-specific record for the scholarly substance

Two linked artifacts with different jobs. The Verification Record
attests, in EIS's own vocabulary and with EIS's own evidence discipline,
that a defined review process was completed and recorded — a **process**
fact, honestly within what a VR is for. The Qur'an-specific record
carries the **domain** substance: which ayah, which sources were
consulted, what the named human reviewer concluded, and the review's own
lifecycle.

- **EIS compatibility**: high — no Core change. The `category` problem is
  *avoided rather than fudged*, because the Verification Record never
  claims to have verified religious content. What it attests is the
  **documented review process**: that a named human verifier carried out
  a defined review, at a stated independence level, on a stated date,
  with stated evidence attached, reaching a documented result. That is a
  process fact, honestly within what a Verification Record is for, and it
  is category D in §Conceptual boundaries. It asserts neither religious
  correctness nor scholarly soundness. **Nor does it assert that a domain
  record exists or is complete** — existence, completeness, and linkage
  are category E, machine-checkable, and belong to the technical
  integrity layer, not to the Verification Record's claim.
- **Study Constitution compatibility**: strong — the human-authored
  substance stays outside any AI-touchable pipeline, satisfying §3.6,
  §7, and §12 without reinterpretation.
- **Religious-content safety**: **strongest** — the D/B boundary is
  structural, not a naming convention.
- **Human accountability**: strong — `verifier: human:<name>` in the
  envelope, the named reviewer in the domain record, `owner_role`
  naming a canonical role accountable for the process existing.
- **AI boundary safety**: strong — nothing in either artifact requires or
  invites generation.
- **Auditability**: strong — inherits the required `## Evidence`
  discipline and the honesty of `independence_level`.
- **Git durability**: strong for the envelope (verified); the domain
  record's home is a specification question with several verified-safe
  candidates.
- **Ayah-level traceability**: strong — lives in the domain record where
  it can be structured, using the existing stable addressing.
- **Partial-coverage disclosure**: strong — coverage is countable from
  domain records, and honesty is enforceable by a test.
- **Correction/history**: strong — the VR's fail-never-deleted rule plus
  domain-record lifecycle; the missing `supersedes` becomes a
  domain-record concern rather than a Core gap.
- **Release enforcement**: strong — CI can check linkage and
  completeness (category E) without ever touching category B.
- **EIS Core impact**: none.
- **Qur'an Companion impact**: moderate — two artifacts, deliberately.
- **NurVerse interoperability**: best available — the envelope is
  already portable, and the domain half is exactly the part the vision
  says should not be abstracted before a second consumer exists.
- **Complexity**: moderate; the highest cost is keeping two artifacts in
  sync, which is itself mechanically checkable.
- **Conflation risk**: **lowest**, because separation is the design.

## Decision

**Recommended, not accepted: Option D.**

Represent future verified Qur'anic explanatory-content review evidence as
**two linked artifacts with deliberately different warrants** — an EIS
Verification Record carrying the governance and audit envelope, and a
Qur'an-specific record carrying the scholarly substance and its
ayah-level linkage.

The reasoning is not that D is cheapest — it is not — but that it is the
only option under which **EIS is never made to appear to have an opinion
about religious correctness.** Option A borrows a container whose
semantics mean something else. Option C makes a domain-neutral framework
carry a domain concern for its only consumer. Option B discards proven
evidence discipline to avoid a problem that separation solves more
cheaply. D keeps each mechanism doing the thing it was built to do.

Two kinds of constraint apply to any future specification built on this
decision, and they carry different authority. The distinction matters
because this record is `proposed`: it can recommend, but it cannot bind.

**Inherited constraints — already in force through `DR-2026-0020`'s
approved owner decisions, and unaffected by whether this record is ever
accepted:**

1. **The domain record names a human, and no AI-authored, AI-drafted, or
   AI-paraphrased content may appear in it at any stage** — `DR-2026-0020`
   §7. AI's permitted role remains retrieval, search, indexing, and
   organization over a human-selected corpus.
2. **Coverage claims stay bounded by `DR-2026-0020` §11** — partial
   coverage disclosed honestly; no full-Qur'an claim until all 6,236
   ayat have actually passed review.

**Proposed architectural constraints — recommendations of this record,
carrying no authority unless and until it is accepted:**

3. **An EIS Verification Record should never be used as an assertion of
   religious correctness.** Its honest claim is that a defined review
   process was completed and recorded by a named person.
4. **A release gate should check technical and structural integrity
   only** — existence, completeness, linkage, coverage honesty
   (category E). It should never be described, named, or presented as
   verifying scholarly soundness (category B).
5. **The separation between governance envelope and scholarly substance
   should be preserved** rather than collapsed into a single artifact.

**This decision is recommended at `status: proposed` and is not
self-executing.** It cannot reach `accepted` while the dependencies in
§Open decisions remain unresolved — most fundamentally, a review
architecture with no qualified reviewer describes an empty container.

## Consequences

- No code, schema, test, database, Constitution, EIS Core, or release
  document changes as a result of this record.
- `docs/specs/DIVINE_MESSAGES_SPEC.md` remains unauthorized and unwritten.
- V1.0 scope is untouched; `DR-2026-0020` §5a continues to bar any V1.0
  implementation in any form.
- A future specification phase inherits two constraints already in force
  through `DR-2026-0020` (§Decision, items 1–2), and — if this record is
  accepted — three proposed architectural constraints (§Decision, items
  3–5) plus seven conceptual boundaries (§Conceptual boundaries).
- The `subject` field's insufficiency for structured ayah linkage is
  recorded as a known limitation of the envelope, and is the reason the
  domain half exists. **No replacement field, column, frontmatter key,
  or file format is proposed here** — that is specification work.
- Two documentation defects observed during reconnaissance are recorded
  for the owner's awareness and deliberately **not** fixed by this
  record: `docs/DATA_PIPELINE.md` states that
  `assets/database/quran.sqlite` is not committed to git, while
  `git ls-files` shows it tracked; and `VR-2026-0001`'s `category: static`
  sits outside the scope `run-static-gate` defines for that category.
- If Option C is ever pursued independently, this record does not
  obstruct it — D's envelope would simply gain a more accurate
  `category` value.

## Risks

- **Conflation risk (primary).** Someone reads "Verification Record:
  pass" as "religiously verified." Mitigated structurally by §Conceptual
  boundaries and constraint 1, but mitigation is words until a
  specification and a reviewer exist.
- **Empty-container risk.** This architecture is unusable until the
  reviewer-authority question (`DR-2026-0020` §10) is answered. Building
  the container first is defensible only if that is stated plainly, as it
  is here.
- **Two-artifact drift.** Linked records can fall out of sync. This is
  the one risk that is mechanically checkable, and any specification
  should treat that check as mandatory rather than optional.
- **Independence illusion.** `different-human` establishes identity
  difference only. A record showing it must not be read as establishing
  qualification — EIS defines no such concept.
- **Gate-erosion risk.** Every gate in this project is
  discipline-followed. A religious review gate would inherit that
  weakness, not escape it.
- **Premature-abstraction risk.** Designing the domain half for a second
  consumer that does not exist would violate the project's own stated
  discipline; it should be shaped by this product's real needs only.
- **Scale risk.** Full coverage is 6,236 review events. No repository
  rule prevents that; sustaining genuine review quality at that volume
  is a capacity question, not a technical one, and `DR-2026-0020` §11
  already forbids resolving it by lowering the bar.

## Open decisions

Every item below remains **OPEN**. This record resolves none of them, and
where an architectural choice depends on one, the dependency is stated
rather than assumed.

Provenance, stated precisely: **items 1–8 are carried forward unchanged
from `DR-2026-0020` §16.** **Items 9–10 are newly identified open
architectural questions raised by this record** — they are not owner
decisions, were never put to the owner before now, and arise only because
this record proposes a two-artifact separation.

1. **Reviewer/verification authority** — unresolved. *Blocks acceptance
   of this record:* the envelope describes who is recorded, never who is
   qualified.
2. **Tafsir source** — unresolved; both known candidates are licensing-blocked.
3. **Hadith source** — unresolved; none has ever been identified.
4. **Asbab al-Nuzul source** — unresolved; absent from the repository.
   *Items 2–4 determine what category C evidence consists of in practice.*
5. **Final user-facing terminology** — unresolved. *Governs category G;
   no wording is chosen here.*
6. **Correction-history disclosure to end users** — unresolved.
   *Determines whether the domain record's history is user-visible.*
7. **Ownership and format of the Reading/Understanding governance
   document** — unresolved. *Determines which document ultimately binds
   this architecture.*
8. **Topic classification's review track** — unresolved.
9. **Whether EIS Core is ever extended (Option C)** — unresolved. *Would
   change which `category` value the envelope carries; does not change
   the two-artifact separation.*
10. **The domain record's durable home and format** — a specification
    decision, deliberately not made here. Reconnaissance verified several
    candidate locations as durable and machine-readable; choosing among
    them requires the source and reviewer decisions above.

## Evidence and references

- `docs/adr/DR-2026-0020-governance-model-for-verified-quranic-explanatory-content.md`
  — the four approved owner decisions carried forward.
- `docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md` §3.5, §3.6, §6,
  §7, §12, §14 — the binding AI/religious-content boundary.
- `eis-core/schemas/verification-record.schema.md` — envelope capability
  and limits.
- `eis-core/skills/verification/run-*-gate.md` (seven specs) — what EIS
  verification procedures do and do not verify.
- `eis-core/decision-system/APPROVAL_GATES.md` — six-canonical-role
  approver constraint; *"None are compiler-enforced."*
- `eis-core/CORE_CONSTITUTION.md` §Decision Ownership, §Change Authority,
  §Permission Tier Model.
- `eis-core/collaboration/MULTI_AGENT_RULES.md` §Verification Ownership
  — independence semantics.
- `eis-core/scalability/SCALE_MODEL.md` — scalability triggers; the
  fixed-vocabulary-overflow precedent.
- `eis-core/constitution/CORE-P-001-verified-completion.md` — the
  evidence standard the envelope inherits.
- `test/repository_boundary_test.dart`,
  `test/repository_boundary_completeness_test.dart` — boundary rules;
  `docs/verification/` verified clear.
- `docs/reports/release-recovery/IMPLEMENTATION_PROGRAM.md` §Stream D
  (archived) — D1/D2 definitions; `docs/verification/` absent from all
  file lists.
- `test/content_database_smoke_test.dart`,
  `test/ayah_ordinal_real_data_test.dart`, `test/surah_names_test.dart`
  — the demonstrated ceiling of automated content integrity checking.
- `.github/workflows/ci.yml`, `RELEASE_DASHBOARD.md` §5, §7 — what is
  actually release-blocking in this project.
- `docs/release/QURAN_COMPANION_PRODUCT_VISION.md` §Phase 6 — AI
  interpretive risk; *"NurVerse is earned, not designed."*
- `docs/LICENSING.md` — source licensing status for category A.

## Governance boundaries

- This record makes **no religious correctness claim** about any ayah,
  source, or explanation, and quotes or interprets no Qur'anic text.
- It **selects no reviewer**, asserts no qualification standard, and
  invents no reviewer role.
- It **selects no Tafsir, Hadith, or Asbab al-Nuzul source.**
- It **defines no religious-review methodology** and no correctness
  criteria.
- It **weakens nothing** in `PROJECT_CONSTITUTION.md`,
  `constitution/PROJ-P-001`–`005`, or
  `STUDY_ARCHITECTURE_CONSTITUTION.md`, and proposes no amendment to any
  of them.
- It **authorizes no V1.0 work.** `DR-2026-0020` §5a stands: the
  explanatory feature is V2.0-only and must not be implemented in V1.0
  in any form — code, schema, specification, or UI.
- It **authorizes no implementation** of any kind, including of itself.
