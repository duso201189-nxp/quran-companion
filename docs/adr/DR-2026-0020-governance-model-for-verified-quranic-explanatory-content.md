---
id: DR-2026-0020
scope: project
owner_role: constitution-owner
date: 2026-08-10
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [constitution-touching, materially-different-approaches, cross-cutting-invariant]
links:
  task: "V2.0 pre-work — governance groundwork for 'Allah muốn chúng ta hiểu điều gì?' and related contextual learning layers"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0020 — Governance model for verified Qur'anic explanatory content in Study features

**Status of this record: proposed, not accepted. Revision 3.** Four
substantive decisions below have been reviewed and approved by the
project owner (2026-08-10) and are now treated as settled direction for
any future work. The record as a whole remains `proposed`, not
`accepted`, because several items it depends on for actual
implementation — reviewer authority, source corpus, final UI wording —
are explicitly unresolved and marked **OPEN DECISION** throughout. This
record does not authorize `docs/specs/DIVINE_MESSAGES_SPEC.md` to be
written, any Constitution to be amended, or any code to be changed.

Revision history: Revision 1 recommended AI-assisted private drafting
(Option B). Revision 2 withdrew that recommendation on a stricter
literal re-read of `STUDY_ARCHITECTURE_CONSTITUTION.md` §3.6. Revision
3 (this one) records the owner's approval of that reversal plus three
further decisions, without resolving anything left open in Revision 2.

## Decision summary (as of 2026-08-10)

| Topic | Status | Where decided |
|---|---|---|
| AI role in religious-content production | **Decided** | §6–§7 |
| Governance scope (Study vs. Reading/Understanding) | **Decided** | §4 |
| V1.0 / V2.0 boundary for this feature | **Decided** | §5a |
| Qur'an-wide coverage claim policy | **Decided** | §11 |
| Reviewer / verification authority | OPEN DECISION | §10 |
| Tafsir source | OPEN DECISION | §9 |
| Hadith source | OPEN DECISION | §9 |
| Asbab al-Nuzul source | OPEN DECISION | §9 |
| Final user-facing terminology | OPEN DECISION | §12 |
| Correction-history disclosure to users | OPEN DECISION | §13 |
| Ownership/authoring of the future Reading/Understanding governance document | OPEN DECISION | §4, §16 |

---

## 1. Context

V2.0 planning names a future contextual-learning layer whose centerpiece
is an ayah-level explanation feature — "Allah muốn chúng ta hiểu điều
gì?" — alongside Asbab al-Nuzul, Tafsir excerpts, authentic Hadith,
cross-references, terminology, practical lessons, common
misunderstandings, and topic classification, eventually spanning the
full Qur'an.

`docs/architecture/STUDY_ARCHITECTURE_CONSTITUTION.md` (2026-08-05,
"binding on all future Study-related work until formally revised") is
the only existing binding document addressing AI's relationship to
religious content. It was written for the Sequencing capability
(spaced-repetition scheduling), not this feature. No file in the
repository reconciles the two.

## 2. Problem

Two independent problems:

**(a) Governance-interpretation problem.** Does
`STUDY_ARCHITECTURE_CONSTITUTION.md` §3.6/§12/§14 permit any AI role in
producing this feature's content, and which module governs the feature
given it doesn't fit Study's own stated scope (§4)? **Resolved by owner
decision — see §4, §6–§7.**

**(b) Independent, non-AI licensing problem.** The project does not
currently have rights to any Tafsir text, and has never sourced a
Hadith collection. This is a `PROJ-P-005`-adjacent legal question, not
a Constitution-interpretation question, and it blocks the feature on
its own regardless of (a). **Not resolved — see §9, OPEN DECISION.**

## 3. Existing binding principles

Quoted in full, from `STUDY_ARCHITECTURE_CONSTITUTION.md`:

- §3.5 — *"Understanding is received; reflection is authored... one is
  intake from vetted sources, the other is the user's own internal
  engagement."*
- §3.6 — *"AI arranges; it does not author meaning. AI may sequence and
  schedule. It may never generate, paraphrase, or adjudicate religious
  content."*
- §6 (Reflection) — *"a system-generated or AI-suggested 'reflection' is
  not reflection; it is content, and does not belong here."*
- §7 (Understanding) — *"It is received, not authored, and it comes
  only from vetted, attributed sources."*
- §12 (Sequencing must never) — *"Generate, paraphrase, summarize, or
  interpret Qur'anic meaning, tafsir, or religious guidance... Substitute
  generated text for attributed, scholarly-sourced translation or
  commentary... Present itself, in name or behavior, as a source of
  religious knowledge rather than a scheduling aid."* And: *"Authentic
  Islamic knowledge — translation, tafsir, scholarly commentary — comes
  only from vetted, attributed sources presented as such. This boundary
  is absolute."*
- §14 — *"...never mistaken, by design, for a source of religious
  knowledge, regardless of whether it is built deterministically or
  with AI assistance."*

None of these contain a visibility, audience, or "draft vs. final"
qualifier — load-bearing for §6.

This record does not amend, weaken, or reinterpret any of the above
more permissively than its literal text supports. Decision (1) below
exists precisely because it requires no such reinterpretation.

## 4. Scope analysis — DECIDED

**Repository fact — what Study means architecturally:** §1 scopes the
document to "the Study module," defined as "retention infrastructure
for Reading — not a parallel content feature." §7 places Understanding
(translation, context, scholarly commentary) as "a persistent,
always-available dimension of Reading and Revision alike," listed "for
clarity of ownership," not as a Study stage. Study's own named roles
(§§6–12) are Reflection, Retention, Revision, Memorization, Assessment,
Sequencing — none of which is "explain what an ayah means."

**Repository fact — what the future feature actually does:** ayah-level
explanatory content surfaced in connection with reading — squarely
inside what §7 calls "Understanding," not inside any of Study's six
named roles.

**Owner decision (approved 2026-08-10):** the feature is governed as
**Reading/Understanding content**, not as a Study capability. It must
**inherit all applicable religious-content integrity principles**
already established for Understanding in §7 and for Islamic knowledge
generally in §12 ("received, not authored... only from vetted,
attributed sources... this boundary is absolute") — inheritance, not
reinvention. It must **never weaken**
`STUDY_ARCHITECTURE_CONSTITUTION.md`. Where this content is later reused
inside Study (e.g. Flashcards, Quiz per §13's existing scoping), Study's
rules govern that reuse directly and without exception.

**Still open:** which document formally carries this governance (a new
Reading/Understanding constitution document, an extension of
`PROJECT_CONSTITUTION.md`, or something else), and who owns/authors it.
Not decided here — see §16.

## 5. Options considered — AI assistance

**Option A — No AI generation, paraphrase, or drafting of religious
explanatory content, at any stage, public or private.** AI may
retrieve, search, index, organize metadata, cross-reference, and
present already-existing, already-published human content. All
explanatory prose is authored by a human, start to finish.

**Option B — AI may create private, non-user-facing drafts from a
fixed vetted corpus, followed by mandatory human/scholarly review
before anything ships.** (Revision 1's recommendation; withdrawn in
Revision 2.)

**Option C — AI assists a human author's process** (retrieval, passage
comparison, cross-referencing, organizing candidate source excerpts)
but never itself produces candidate explanatory prose, at any stage.
The human is the sole author of the final text.

### 5a. Release sequencing — DECIDED

**Owner decision (approved 2026-08-10):** "Allah muốn chúng ta hiểu
điều gì?" remains a **V2.0 product concept only** and **must not be
implemented in V1.0**, in any form (code, schema, spec, or UI). This is
consistent with, and reinforces, the existing scoping already recorded
in `docs/release/PRODUCT_ROADMAP.md` ("Not in v1.0, and correctly so:
authentication, cloud sync, any new product feature beyond what's
already built") and `RELEASE_PLAN_V1.md`'s general "fix what's broken,
don't add scope" posture for the current release phase. Nothing in
`docs/release/RELEASE_PLAN_V1.md`'s existing blocker list is affected by
this record.

## 6. AI-assistance compatibility analysis

**Option A — compatible.** §12's permitted list for Sequencing ("rank
and schedule," "surface patterns... in structured, behavioral data,"
"decide when") describes a retrieval/arrangement role that produces no
new religious text at any point. Nothing in §3.6/§12/§14 restricts
retrieval and presentation of already-existing, human-authored content.

**Option B — not clearly compatible.** §3.6's prohibition — *"It may
never generate, paraphrase, or adjudicate religious content"* — carries
no audience qualifier. Reading it as "never generate content shown to a
user" (vs. content generated privately) adds a condition the text does
not contain. On a literal reading, the Constitution as currently
written does **not** permit Option B. Enabling it would require an
explicit, transparent amendment to §3.6 by the Constitution Owner —
not something this record may enable by reinterpretation.

**Option C — compatible**, and is the operational form of Option A: the
line that matters is "does AI ever produce candidate religious prose"
(no, under A/C), not "does AI's output ever leave the pipeline" (Option
B's line, unsupported by the text).

## 7. Decision — AI role in religious-content production (DECIDED)

**Owner decision (approved 2026-08-10): adopt Option A/C.** No AI
generation, paraphrasing, or adjudication of religious content **at any
stage**, under the current Constitution — including private,
non-user-facing drafts. AI's permitted role is retrieval, search,
indexing, cross-referencing, and organizational assistance over a
fixed, human-selected corpus, strictly in service of a human author who
alone produces the actual explanatory text.

This decision requires no amendment to
`STUDY_ARCHITECTURE_CONSTITUTION.md` and introduces no new
interpretation of it. If AI-assisted drafting under review (Option B)
is ever wanted, it is available only through a separate, explicit
amendment to §3.6, proposed and accepted on its own terms — not implied
by this or any future record.

## 8. Religious-content verification workflow

Not finalized as an implementable spec — governance-level only, pending
§9/§10's open decisions.

**Is a single flat `draft → in_review → verified → rejected/
needs_revision` model sufficient?** No. The repository's content types
split into two provenance categories:

- **Sourced content** (a translation, a Tafsir excerpt, a Hadith quoted
  from a graded collection) — not authored by the app; selected and
  licensed from an existing published work verbatim. Governed by source
  selection + license + attribution correctness (the existing
  `docs/LICENSING.md` / `docs/DATA_PIPELINE.md` pattern), not by
  editorial review of "authorship," since none occurs.
- **Synthesized content** (the explanatory synthesis itself, an Asbab
  al-Nuzul narrative, a practical lesson) — genuinely human-authored per
  §7, and what the draft/review/verified cycle is for.
- **Topic classification** — interpretive but lower-risk than doctrinal
  explanation; which track applies to it is **OPEN DECISION** (§16).

**For sourced content:** source selected once, license terms recorded
(extending the existing `translation_sources` schema pattern already in
place); each import checked against the recorded license/attribution
requirement, not re-adjudicated editorially.

**For synthesized content:** human-authored `draft` (informed by
AI-assisted retrieval per §7, never AI-authored) →
`in_review` (reviewer checks accuracy, doctrinal soundness, absence of
unsupported claims, honest representation of legitimate scholarly
difference) → `verified` (only status that may ship or reach a user) →
`rejected`/`needs_revision` (returns to `draft` with notes, not
discarded).

## 9. Content-category boundaries and source corpus — OPEN DECISION (mostly)

- **Qur'an (Arabic text)** — not subject to any review/verification
  workflow; revelation itself. **Status: approved, shipped.** Source:
  Tanzil Project, verbatim only, attribution + link required.
- **Translation of meanings** — **Status: approved, shipped**, subject
  to `PROJ-P-005` (Tanzil English Sahih International, non-commercial
  only) and QuranEnc's 7-condition terms (Vietnamese).
- **Tafsir** — **OPEN DECISION. Status: NOT approved, NOT shipped on
  `main`.** `docs/LICENSING.md` (2026-07-26, unmerged branch) names two
  candidates, both blocked: *Tafsir Al-Muyassar* (KFGQPC — no permission
  secured) and *Tafsir Ibn Kathir, abridged* (Darussalam — active
  unresolved copyright; the document's own conclusion: no public
  release, even free, until resolved). Neither may be used without a
  written licensing resolution this repository does not have.
- **Hadith** — **OPEN DECISION. Status: no source ever identified.**
  `docs/DATA_PIPELINE.md` describes only a generic technical pattern for
  *how* such data could be added, not *which* collection or authenticity
  standard.
- **Asbab al-Nuzul** — **OPEN DECISION. Status: not mentioned anywhere
  in the repository.**
- **Verified explanatory synthesis** — human-authored, `verified`-status
  output of §8's pipeline. Presented as reasoned human understanding,
  never as Allah's own words, never typographically indistinguishable
  from Qur'an text.
- **AI-generated draft material** — per §7's decision, this category
  does not exist under the current Constitution.

## 10. Human/reviewer responsibilities — OPEN DECISION

**Repository fact:** `ROLES.md` defines six EIS engineering-governance
roles, all currently held by one person; none implies Islamic scholarly
qualification. No document establishes a religious-content review role
or names any qualified reviewer or partner organization.

**Not resolved by this record, and not to be resolved by inventing a
title or assigning it to an existing person.** The project needs a
future, affirmative decision about how genuine qualified review will be
obtained (partner organization, individual qualified reviewer, or
adopting an already-verified corpus wholesale). This repository does
not contain enough information to determine which.

Once a reviewer/process exists, responsibilities per §8 apply: verify
every citation against its source directly; confirm alignment with
reliable Sunni scholarship; confirm legitimate differences are
represented honestly; own `verified` sign-off and respond to
corrections (§13).

## 11. Qur'an-wide coverage policy — DECIDED

**Owner decision (approved 2026-08-10):**

- **Partial verified coverage is allowed in V2.0.** The feature may
  ship, and grow, with less than full Qur'an coverage.
- **The product must never claim full Qur'an coverage until all 6,236
  ayat have passed the required verification process** (§8's
  synthesized-content pipeline, once §10's reviewer authority is
  resolved). Not negotiable by scale, timeline, or convenience.
- Coverage should be disclosed honestly at whatever granularity is
  implemented (e.g., unreviewed ayat show an explicit "not yet
  available" state) — extending the already-agreed principle that
  insufficient evidence must be indicated, not guessed around, to
  coverage itself.
- If review capacity cannot keep pace, the correct response is
  continued disclosed partial coverage, never a lowered verification
  bar.

## 12. User-facing terminology — OPEN DECISION

**Repository fact:** "Allah muốn chúng ta hiểu điều gì?" originates from
the project owner's stated product direction; no repository document
evaluates it as UI copy.

**Risk, not a decision:** as literal UI text it frames the app's output
as a direct statement of Allah's will — a framing risk independent of
content accuracy, adjacent to the agreed principle that religious
explanations must not be presented as Allah's words.

**Recommendation only (not decided):** reserve the phrase for
internal/product-vision naming; use an "explanation of this ayah"-style
label on-screen (e.g. "Điều Ayah này truyền đạt"), always paired with
explicit explanatory-synthesis-not-revelation framing. **Explicitly not
recommended:** "Điều cần suy ngẫm" — collides with
`STUDY_ARCHITECTURE_CONSTITUTION.md` §6's definition of Reflection as
exclusively user-authored. Final wording remains **OPEN DECISION** for
the product owner.

## 13. Correction policy — OPEN DECISION (framework only)

Triggers: reviewer-caught error, new evidence, a scholarly difference
later found misrepresented, source-edition change, incorrect citation,
incorrect synthesis. All corrections re-enter `in_review` from
`verified` — never a silent in-place edit.

**History preservation recommended**, by direct project precedent:
`docs/adr/README.md`'s own rule that an accepted DR is never edited in
place, only superseded. The same discipline is recommended for
religious content corrections.

**Not resolved:** whether correction history is shown to end users
(transparency) or kept internal. No repository basis to decide either
way.

## 14. Risks

- **Theological/reputational risk** — content near the Qur'an that is
  inaccurate or misleadingly framed; §7's no-AI-generation decision and
  §8's pipeline exist to contain this.
- **Licensing risk, independent of governance** — both identified
  Tafsir sources are blocked; Hadith has no source. Can stall the
  feature regardless of every governance decision in this record.
- **Gate-erosion risk** — §7's rule or §8's gate eroding under release
  pressure, not their design on paper.
- **Authority-invention risk** — assigning review responsibility
  without genuine qualification would invent an authority structure
  this record is instructed not to invent.
- **Scale risk** — full-coverage review is a large, ongoing burden;
  §11 explicitly rejects lowering the bar to compensate.
- **Framing risk** — resolved accuracy does not resolve UI-wording risk
  (§12).
- **Scope-creep risk against decision (3)** — any V1.0 work that
  references, previews, or partially builds this feature would violate
  §5a; flagged explicitly given how easy silent scope creep has proven
  elsewhere in this project's own history (`RELEASE_PLAN_V1.md` §0).

## 15. Consequences

- `STUDY_ARCHITECTURE_CONSTITUTION.md` is not amended or reinterpreted
  more permissively than its literal text supports.
- No code, schema, or UI change results from this record.
- This feature is confirmed out of scope for any V1.0 work, including
  spec-writing (`docs/specs/DIVINE_MESSAGES_SPEC.md` must not be
  authored yet, per the current task's explicit instruction).
- A future Reading/Understanding-scoped governance document is
  identified as needed (§4) but not authored, titled, or owned by this
  record.
- Reviewer role/process (§10), source corpus (§9), and terminology
  (§12) remain unresolved and are not staffed or decided here.

## 16. Open decisions that genuinely cannot be resolved from the repository

1. **Reading/Understanding governance document** (§4) — format and
   ownership.
2. **Reviewer/verification authority** (§10).
3. **Tafsir source resolution** (§9) — licensing block on both known
   candidates.
4. **Hadith source** (§9) — entirely unscoped.
5. **Asbab al-Nuzul source/methodology** (§9) — entirely unscoped.
6. **Topic classification's review track** (§8).
7. **User-facing terminology** (§12) — recommendation only.
8. **Correction-history disclosure to end users** (§13).

---

## OWNER DECISIONS ALREADY MADE (2026-08-10)

1. No AI generation, paraphrasing, or adjudication of religious content
   at any stage, under the current Constitution (§6–§7).
2. This feature is governed as Reading/Understanding content, inheriting
   all applicable religious-content integrity principles, and must never
   weaken `STUDY_ARCHITECTURE_CONSTITUTION.md` (§4).
3. "Allah muốn chúng ta hiểu điều gì?" remains a V2.0 product concept;
   must not be implemented in V1.0 (§5a).
4. Partial verified coverage is allowed in V2.0; full Qur'an coverage
   may never be claimed until all 6,236 ayat pass verification (§11).

## OWNER DECISIONS STILL REQUIRED

- Reviewer/verification authority (§10).
- Tafsir, Hadith, and Asbab al-Nuzul source resolution (§9).
- Final user-facing terminology (§12).
- Correction-history disclosure policy (§13).
- Ownership/format of the future Reading/Understanding governance
  document (§4, §16).
