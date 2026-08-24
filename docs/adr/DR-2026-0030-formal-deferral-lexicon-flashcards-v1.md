---
id: DR-2026-0030
scope: project
owner_role: release-owner
date: 2026-08-22
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-02-22
reversibility: soft
threshold_reason: [materially-different-approaches]
links:
  task: "Session 60 governance decision — formal deferral of Lexicon (F1) and Flashcards (F2) from v1.0 scope, drawing on DR-2026-0029's accepted findings and RELEASE_PLAN_V1.md's deadline-expiry contingency (B2)"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0030 — Formal deferral of Lexicon and Flashcards from v1.0

**Status of this record: accepted** by the `owner_role` (release-owner
`duso`) on 2026-08-22; `review_by` 2027-02-22. `owner_role` is
**release-owner** rather than constitution-owner or product-owner: the
governing question here is v1.0 release *scope* — what ships and what
does not — which `ROLES.md` assigns to the Release Owner
(`RELEASE_CHECKLIST.md`, store submission), not a licensing-exposure
question in the sense that made `DR-2026-0016`/`DR-2026-0029` reserve
`constitution-owner`. On this solo project both are held by the same
person, but the role is named on its own merits, per `DR-2026-0016`'s
own precedent for stating that reasoning explicitly.

**On "Product Owner."** `RELEASE_DASHBOARD.md:653` and
`RELEASE_PLAN_V1.md:165-174` both name "Product Owner" as the holder of
the Lexicon dependency item. "Product Owner" is dashboard/plan
terminology, not one of the six canonical EIS Decision Ownership roles
named in `ROLES.md` (Constitution Owner, Architecture Owner,
Data/Schema Owner, Security Owner, Release Owner, Planning Owner) —
"Product Owner" does not appear among them. This record does not
silently treat "Product Owner" as equivalent to any single canonical
role; it uses `release-owner` because the question actually being
decided here — v1.0 release scope — falls under the Release Owner's
domain as `ROLES.md` states it. On this solo project the same person
(`duso`) holds "Product Owner" in the dashboard's usage and Release
Owner in `ROLES.md`'s, so nothing turns on the distinction in practice,
but the mapping is stated here rather than assumed.

As of this record's date (2026-08-22) this file existed only in the
working tree and was not committed or present on `origin/main`. It has
since been published to `origin/main` (merged via PR #25, commit
`0aa03b6`, merge commit `fb2694a`); by `DR-2026-0028`'s jurisdiction
test (accepted **and** present on `origin/main`), this record now
governs `main` — the same posture `DR-2026-0029` reached upon its own
publication in PR #24. This record authorizes no implementation: no
code under `lib/` or `tool/` is touched, no dataset is downloaded or
removed, no schema changes, and no other document in this repository is
edited by it.

This record does not assert that a QAC permission request was ever
sent, and does not assert that one was never sent. It states only what
repository evidence shows: no such request, or any response to one, is
recorded anywhere in this repository. It reaches no legal conclusion
about QAC's licence terms, and does not adopt, recommend, rank, or
select any alternative Lexicon source.

## Relationship to existing records

- **`DR-2026-0029`** ("QAC/Lexicon licensing: MASAQ rejection and
  unresolved-dependency governance," `accepted`, present on
  `origin/main`) governs a **different question**: what Lexicon *source*
  may be adopted and under what gates. It rejected the current MASAQ
  dataset, left QAC licensing unresolved, and forbade auto-adopting a
  replacement. This record does not amend, restate, or edit
  `DR-2026-0029`; it does not touch its Decisions 1–5, its evidence
  rule, or its architectural safeguards. This record answers a
  **separate** question `DR-2026-0029` explicitly left open — Out of
  scope: *"Formal deferral of Lexicon/Flashcards from v1.0.
  `MASAQ_ACCEPTANCE_REPORT.md` §8 lists this as a strengthening
  fallback option; this record neither adopts nor rejects it."* This
  record is that separate decision, brought as its own DR rather than
  as an edit to `DR-2026-0029`.
- **`DR-2026-0016`** ("Lexicon morphology data source," `proposed`,
  present on `origin/main`) is not edited or disposed of by this
  record; `DR-2026-0029` already addressed its disposition in prose
  without altering its `status` field, and this record does not revisit
  that.
- **`DR-2026-0028`** ("Decision Record authority over `main`,"
  `accepted`, present on `origin/main`) supplies the jurisdiction test
  applied above and throughout this record.

## Context

The Lexicon feature (F1) and Flashcards (F2, which depends on F1) are
built but non-functional on a real install: all 8 Lexicon tables ship
with 0 rows (`DR-2026-0029` Context; `DATABASE_REFERENCE.md` §1.1).
`RELEASE_DASHBOARD.md:643-652` and `RELEASE_PLAN_V1.md:165-174` both
classify Lexicon content as `WAITING_EXTERNAL_DECISION`, owned by the
Product Owner, dependency **"QAC permission response
(corpus.quran.com)"**, decision deadline **2026-08-24**.
`PHASE4_IMPLEMENTATION_MASTER_PLAN.md:340-350` frames the same item as
epic **B2**, DoD *"Decision recorded on the deadline; if unfavourable,
Lexicon and Flashcards formally deferred under a Decision Record. Do
not extend the date,"* and states the release impact precisely: **"Gates
D6 only. Per `QURAN_COMPANION_PRODUCT_VISION.md` §0, word-level reading
does not depend on this — only morphology does. An unfavourable answer
costs one attachment, not the roadmap."** `D6` is defined at
`PHASE4_IMPLEMENTATION_MASTER_PLAN.md:240` as "Word foundation... gated
on B2."

`DR-2026-0029`, accepted 2026-08-22 and now present on `origin/main`
(merged via PR #24, commit `667e292`), independently establishes: the
current MASAQ dataset is rejected as a Lexicon source on two
disqualifying grounds (structural and licensing); no MASAQ parser or
Lexicon build against it is authorized; no repository evidence exists
that a QAC permission request was ever sent or answered; and no
alternative source is to be auto-adopted.

**On timing.** This record is dated 2026-08-22 — the `RELEASE_PLAN_V1.md`
deadline of 2026-08-24 has **not** expired as of this date; two days
remain. `RELEASE_PLAN_V1.md:183-184`'s branch — *"On deadline expiry
with no clear grant: defer Lexicon and Flashcards from v1.0 under a
Decision Record. Do not renegotiate the date"* — is written as a
contingency triggered at expiry, and this record does not claim that
contingency has already fired. This record is instead a **proactive**
exercise of the same option the release plan anticipates, made on the
evidence available now: no QAC grant is evidenced, no QAC outreach is
evidenced (`DR-2026-0029` Fact 4), and nothing in the repository
indicates a response is pending or in progress. This record does not
change, extend, or shorten the 2026-08-24 date, and does not claim the
date has passed.

**Owner authorization for proactive exercise.** The choice to exercise
this deferral proactively, roughly two days ahead of the 2026-08-24
deadline rather than waiting for it to lapse, is not this record
inferring that choice on its own: it rests on an explicit owner
authorization, given by `duso` in the project decision channel in
Session 61 of this project's working sessions. That authorization is
the source and provenance for the timing choice made here, and this
record states its content without exaggerating it:

- `duso`, as release-owner, consciously elected to exercise the
  Lexicon/Flashcards v1.0 deferral approximately two days before the
  stated 2026-08-24 deadline, rather than waiting for the deadline to
  lapse.
- That election was made on the evidence basis already stated in this
  record: no repository evidence of a QAC permission response, and no
  repository evidence of a documented QAC outreach record (Fact 5).
- No evidence is currently available, in this repository or otherwise,
  that the remaining two-day window was expected to resolve the QAC
  dependency one way or the other.
- In authorizing early exercise, `duso` consciously accepts giving up
  those remaining two days as a window in which new evidence might
  still have arrived.
- This is an explicit owner decision, not an inference this record
  draws from silence or from the passage of time.
- It is **not** the automatic firing of `RELEASE_PLAN_V1.md:183-184`'s
  deadline-expiry contingency — that contingency triggers at expiry;
  this record instead documents a deliberate, conscious choice to act
  before expiry, on the strength of the owner's explicit authorization.
- The 2026-08-24 date itself is unaffected: it is not changed,
  extended, shortened, or renegotiated by this authorization, exactly
  as stated elsewhere in this record.

## Facts

1. **Lexicon (F1) and Flashcards (F2) remain non-functional on a real
   install.** 0 of 8 Lexicon tables populated. Unchanged since
   `DR-2026-0029`.
2. **`DR-2026-0029` is accepted and, as of `origin/main` HEAD `667e292`,
   present on `origin/main`.** By `DR-2026-0028`'s test it governs
   `main`. Its own body text (written before publication) still reads
   "not yet present on `origin/main`"; that wording was not updated
   when the record was merged. This record states the current, correct
   status independently; it does not edit `DR-2026-0029` to correct
   that wording.
3. **The current MASAQ dataset is rejected as a Lexicon source**
   (`DR-2026-0029` Decision 1, two independent grounds: structural,
   licensing).
4. **No MASAQ parser or MASAQ-based Lexicon build is authorized**
   (`DR-2026-0029` Decision 2). None exists in this repository.
5. **No repository evidence exists that a QAC permission request was
   ever sent, or that one was answered.** This record does not
   conclude that no request was sent, and does not conclude that QAC
   denied or would deny permission — only that no repository evidence
   establishes a sent request or a response (`DR-2026-0029` Fact 4,
   restated here because it is load-bearing for this decision too).
6. **The 2026-08-24 decision deadline stands, unchanged, unextended,
   and not yet reached.** `RELEASE_PLAN_V1.md:174`,
   `RELEASE_DASHBOARD.md:643`, `PHASE4_IMPLEMENTATION_MASTER_PLAN.md:349`.
7. **The deferral this record enacts gates D6 only.**
   `PHASE4_IMPLEMENTATION_MASTER_PLAN.md:240,350`. Word-level reading
   (Tracks A–C, D1–D5) does not depend on Lexicon morphology data and
   is unaffected.

## Options Considered

**Option A — Wait until 2026-08-24 and let the release plan's branch
fire automatically, taking no action now.** Not chosen for this
session. Nothing in the repository indicates a QAC request is even in
flight (Fact 5), so the two remaining days are not evidenced to change
the outcome; recording the decision now, honestly dated and honestly
reasoned (see "On timing," above), is more conservative than leaving
v1.0 scope undecided against an imminent, unextended deadline. This
option remains available in the sense that nothing prevents a later
session from revisiting before or at the deadline if new evidence
arrives — see "Revisit conditions."

**Option B — Amend `DR-2026-0029` to add a deferral decision.**
Rejected. `DR-2026-0029` governs Lexicon-*source* questions and was
explicit that formal deferral was a separate, un-adopted option
(its own "Out of scope"). Folding a release-scope decision into a
licensing-source record would blur the distinction `DR-2026-0029`
itself drew, and this session's scope forbids editing `DR-2026-0029`
regardless.

**Option C — Leave Lexicon/Flashcards nominally in v1.0 scope, undecided,
pending the literal deadline.** Rejected as the status quo this record
changes: `RELEASE_PLAN_V1.md`'s own Go/No-Go checklist item stays
unchecked either way (see "Release impact," below) but leaving v1.0
*scope itself* undecided, this close to an unextended deadline with no
evidenced progress, is the gap this record closes.

**Option D — Formally defer Lexicon (F1) and Flashcards (F2) from v1.0
scope now, under a new Decision Record, changing no code, no dataset,
no other document, and no date. — Chosen.** This is the option
`RELEASE_PLAN_V1.md` itself names as the fallback, exercised proactively
rather than waited-out, on the evidence already on record.

## Decision

**1. Lexicon (F1) and Flashcards (F2) are formally deferred from v1.0
scope.** They are not part of the v1.0 release. This is a release-scope
decision; it does not alter, weaken, or bypass anything `DR-2026-0029`
decided about Lexicon *sourcing*.

**2. Exact scope of the deferral.**
- Deferred: the Lexicon feature (F1) in its entirety (roots, lemmas,
  word-instance morphology data and any UI/behavior that depends on
  populated Lexicon tables), and Flashcards (F2), which depends on F1.
- Deferred with it: `D6` ("Word foundation,"
  `PHASE4_IMPLEMENTATION_MASTER_PLAN.md:240`), which is gated on this
  decision (B2) by that plan's own dependency graph.
- Not deferred, not touched, unaffected: word-level *reading* (Tracks
  A–C and D1–D5 of `PHASE4_IMPLEMENTATION_MASTER_PLAN.md`), which does
  not depend on Lexicon morphology data
  (`QURAN_COMPANION_PRODUCT_VISION.md` §0, as cited by that plan at
  line 350). Search, the Reading Engine, Reading Session architecture,
  and every other shipped feature are unaffected by this record.

**3. What remains in v1.0.** Everything currently in v1.0 scope other
than F1/F2/D6, unchanged by this record: all Track A–C and D1–D5 work,
existing shipped features (Search, Hifz/SRS, Reading Statistics,
Bookmark Collections, Revision Queue, etc.), and every other open
Go/No-Go item in `RELEASE_DASHBOARD.md` §7 — none of which this record
closes (see "Release impact," below).

**4. The 2026-08-24 decision date is not renegotiated, extended, or
shortened by this record.** `RELEASE_PLAN_V1.md` instructs "do not
renegotiate the date," and this record does not: it does not change
that date, does not assert it has already passed, and does not require
that it be reached before this deferral takes effect. If authoritative
QAC evidence (per `DR-2026-0029`'s evidence rule) arrives before or at
2026-08-24, "Revisit conditions" below governs how this record would be
reopened.

**5. No alternative Lexicon source is adopted, recommended, ranked, or
selected by this record.** That remains `DR-2026-0029` Decision 5's
territory, untouched here. Nothing in this record should be read as
narrowing or expanding the field of future candidate sources.

**6. No QAC outreach is initiated, and none is recorded as having
occurred, by this record.** Whether, when, or how a QAC permission
request should now be sent remains outside this record's scope, as it
was outside `DR-2026-0029`'s.

## Release impact

- Closes **D6 only**, per `PHASE4_IMPLEMENTATION_MASTER_PLAN.md:240,350`.
  No other Track A/B/C/D epic is affected.
- **Does not, by itself, check any box in `RELEASE_DASHBOARD.md` §7's
  Go/No-Go checklist.** That checklist's Lexicon item currently reads
  *"Closes either by a permission grant + pipeline run, or by formal
  deferral under a Decision Record"* (`RELEASE_DASHBOARD.md:1038-1041`).
  This record is the second of those two closure paths, but **checking
  that box is an edit to `RELEASE_DASHBOARD.md`**, which this record
  does not perform — consistent with `DR-2026-0029`'s own posture
  toward the release documents. That edit, and the corresponding
  update to `RELEASE_PLAN_V1.md`'s Lexicon entry, are left to a later,
  separate action.
- **Does not claim v1.0 is otherwise ready.** `RELEASE_DASHBOARD.md`
  §7 lists multiple other unchecked boxes (accessibility audit,
  performance measurement, package triage, `RELEASE_CHECKLIST.md`
  sign-off, Tanzil legal review, formatting/analyze/coverage gates on
  the release branch, zero open P0 debt, no open Critical blocker).
  None of those is addressed, closed, or asserted closed by this
  record.
- **Does not close any Go/No-Go item other than the one this deferral
  itself concerns.** No unrelated item is touched.

## Consequences

- Lexicon (F1) and Flashcards (F2) ship in a future release, not v1.0;
  `D6` is out of v1.0 scope.
- **AI Tutor's `weakRoots` morphology capability is unavailable in
  v1.0, as a direct consequence of this deferral.** `RELEASE_DASHBOARD.md:658-660`
  records the existing dependency: while Lexicon tables remain
  unpopulated, "`weakRoots` in AI Tutor can never fire." This record
  does not newly create that dependency; it confirms that deferring
  Lexicon (F1) from v1.0 means the specific AI Tutor behavior that
  depends on populated Lexicon data — `weakRoots` — is also unavailable
  for v1.0. This is narrower than a claim about AI Tutor generally: AI
  Tutor is not deferred, no other AI Tutor capability is asserted to be
  affected, and this record makes no change to AI Tutor code or to any
  AI Tutor implementation plan.
- No code, dataset, or schema change results from this record. No file
  under `lib/`, `tool/`, or `assets/` is touched.
- `DR-2026-0029`'s Decisions 1–5 and its architectural safeguards
  (Decision 4) remain fully in force, unmodified, and continue to
  govern any future Lexicon-source work whenever it resumes.
- `RELEASE_DASHBOARD.md` and `RELEASE_PLAN_V1.md` are not edited by
  this record. Both continue to show the Lexicon item as
  `WAITING_EXTERNAL_DECISION` until a later reconciliation pass adds
  this record's disposition — flagged here as a required follow-up,
  not performed.
- `docs/LICENSING.md` is unaffected and not edited by this record;
  `DR-2026-0029`'s own licensing-registry follow-up is unaffected and
  unduplicated here.
- As of this record's date (2026-08-22) this record was accepted but
  not yet committed or present on `origin/main`, so it did not yet
  govern `main` under the `DR-2026-0028` test. It has since been
  committed and published to `origin/main` (merged via PR #25, commit
  `0aa03b6`); it now governs `main` under that test.
- **Reversibility is soft.** A future Decision Record — one that
  accepts a new Lexicon source under `DR-2026-0029`'s evidence rule, or
  one that reinstates F1/F2/D6 into a later v1.0-equivalent scope
  decision — can supersede this record with no code or schema rollback
  required, because none is created here.

## What is explicitly NOT decided

Named explicitly, so none of this is read as settled here:

- **Whether QAC will, or would, grant permission.** Not addressed. No
  claim is made about QAC's likely or actual position.
- **Whether a QAC permission request was ever sent.** Not established
  either way; only its absence from repository evidence is stated
  (Fact 5).
- **Any legal conclusion about QAC's licence terms**, MASAQ's licence,
  or any other dataset's licence. None is reached here or inherited
  from elsewhere for this purpose.
- **Which alternative Lexicon source, if any, should eventually be
  adopted.** Left entirely to `DR-2026-0029` Decision 5 and whatever
  future Decision Record addresses it.
- **Whether or when Lexicon/Flashcards will ship in a future release
  after v1.0.** Not scheduled, scoped, or committed here.
- **Checking any Go/No-Go box in `RELEASE_DASHBOARD.md`**, including
  the Lexicon item itself. Left to a later, separate action.
- **Editing `RELEASE_PLAN_V1.md`, `RELEASE_DASHBOARD.md`,
  `PHASE4_IMPLEMENTATION_MASTER_PLAN.md`, `DR-2026-0029`, or
  `DR-2026-0016`.** None is touched by this record.
- **Whether the 2026-08-24 date has, or will have, been "reached"
  before this record is itself published to `origin/main`.** This
  record does not depend on that question — see "On timing," above —
  and does not resolve it.
- **Whether v1.0 is otherwise release-ready.** Not asserted; see
  "Release impact," above.

## Revisit conditions

This record should be revisited, ahead of its `review_by` date, if any
of the following occurs:

- Authoritative QAC licensing evidence, of the kinds `DR-2026-0029`'s
  "QAC external evidence rule" already enumerates, is obtained and
  added to the repository.
- A future Decision Record accepts a specific alternative Lexicon
  source under `DR-2026-0029` Decision 5 and its Decision 4 gates.
- The 2026-08-24 deadline is reached with new, evidenced developments
  not reflected in this record (e.g., a request shown to be in
  progress) — in which case this record's Facts, not its Decision,
  would need updating first.
- A future release-scope decision proposes reinstating F1/F2/D6 into a
  planned release.

Absent any of the above, this record stands as stated through its
`review_by` date of 2027-02-22.

## Evidence / provenance

All citations below were read directly from `origin/main` at HEAD
`667e292` (merge of PR #24, "docs(adr): accept DR-2026-0029 qac lexicon
licensing decision") on 2026-08-22, via `git show origin/main:<path>`
and `git ls-tree -r origin/main -- docs/adr/`, not from a working-tree
copy or from memory of prior sessions. `DR-2026-0016` and `DR-2026-0028`
were confirmed present with their stated `status` values by the same
method.

## Review point

`review_by: 2027-02-22`, matching `DR-2026-0029`'s cadence. Before that
date, any of the "Revisit conditions" above independently triggers an
earlier look.

## References

- `docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md` — governs
  Lexicon-source constraints; not edited by this record; this record's
  Facts 3–5 restate its Facts/Decisions for this record's own
  self-containedness.
- `docs/adr/DR-2026-0016-lexicon-data-source.md` — remains `proposed`;
  not edited by this record.
- `docs/adr/DR-2026-0028-decision-record-authority-over-main.md` — the
  jurisdiction test applied throughout.
- `docs/release/RELEASE_PLAN_V1.md:165-174,183-184` — Lexicon status,
  owner, dependency, deadline, and the deadline-expiry branch this
  record proactively exercises.
- `docs/release/PHASE4_IMPLEMENTATION_MASTER_PLAN.md:240,340-350,460`
  — epic B2, `D6` definition and gating, release-impact statement.
- `RELEASE_DASHBOARD.md:643-660,1038-1042` — external-dependency entry,
  the `weakRoots`/AI Tutor consequence cited under "Consequences," and
  the Go/No-Go checklist item this record's disposition corresponds to
  (not checked by this record).
- `docs/release/MASAQ_ACCEPTANCE_REPORT.md` §8 — names formal deferral
  as a strengthening fallback option, per `DR-2026-0029`'s own
  citation.
- `ROLES.md` — Release Owner's domain, underlying this record's
  `owner_role` choice.
- `eis-core/schemas/decision-record.schema.md` — the external EIS Core
  schema this project is pinned to per `CLAUDE.md`; not a file inside
  this repository.
