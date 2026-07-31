---
id: DR-2026-0014
scope: project
owner_role: release-owner
date: 2026-07-26
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [legal-exposure, prevents-recurrence-of-a-known-incident, content-integrity]
links:
  task: "Sprint C2 architecture review — publisher credential in GitHub"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0014 (draft) — Publishing model for the artifact registry

**Status of this record: proposed, not accepted.** It evaluates three
publishing models and ends with a recommendation, but the Decision
section below is deliberately left open. Acceptance is the
`owner_role`'s call, not this record's.

## Relationship to existing records

`DR-2026-0009` §B names a **Publisher** access tier — *"+ write access,
signing keys... everything"* — without stating whether that tier is a
human at a keyboard or a CI job. `DR-2026-0012` defines what a publish
action must produce (a verified, recorded artifact) without stating who
performs it. Neither gap was a defect in those records — the question
simply hadn't been asked yet. This record asks it and proposes an
answer; it amends neither.

## Context

`C1` provisioned two R2 credentials: a read-only one CI already uses for
consumption, and a write-capable **Publisher** credential intended for a
future release workflow that uploads `quran.sqlite`, manifests, and
dataset payloads. `C2`'s verification pass found the Publisher
credential's existence in GitHub Secrets defensible — secrets are inert
until a workflow references them — but found no workflow may reference
it yet, because no publish job has been designed with gating
proportionate to what it can do: overwrite the Qur'anic text and tafsir
served to users.

This project has one existing precedent for a comparably dangerous
credential: the Android release keystore, which `DR-2026-0009` §D keeps
**off CI entirely**, on the publisher's machine only, specifically
because its compromise is unrecoverable (*"permanent loss of the
ability to update the app"*). The Publisher R2 credential is not quite
that catastrophic — a bad artifact can be superseded, per
`DR-2026-0012`'s pin-and-verify model — but it is the next most
consequential credential in the project, and deserves the same level of
deliberate design before it is wired into anything.

## Problem

Three shapes are available for how a human decision, a build, and a
credential combine to produce a published artifact. They are not
equally safe, and the project should decide which one it is building
toward before any workflow references `R2_PUBLISH_*`.

## Options evaluated

### Option A — Fully automated CI publish

A workflow triggered by `push` (e.g., to `main` or a tag) builds,
verifies, and publishes in one run, using the Publisher credential
directly, with no human checkpoint between verification and upload.

| Criterion | Assessment |
|---|---|
| Security | **Weakest.** `ci.yml`'s existing triggers (`push: [main, develop, tags]`, unqualified `pull_request:`) show how broad "automatic" already is in this repository. A write-capable credential referenced by any job under those triggers is reachable by anything that can get a commit onto a qualifying branch — no human decision required to spend it. |
| Operational complexity | Low to run, but the design work to make it *safe* — dry-run modes, kill switches, staged rollout — largely re-invents the human checkpoint that Option C provides directly. |
| Recovery | Reactive only. A bad publish is caught after the fact via `DR-2026-0012` verification-on-consume, not prevented before it happens. |
| Auditability | Machine causality only — logs show *what commit* triggered a publish, never *who decided this should ship*. |
| Least privilege | **Violated.** The highest-privilege action is bound to the widest, most automatic trigger surface in the project. |
| Suitability for Qur'an datasets | **Poor.** This project has repeatedly used "would you recommend it to your own family" as its bar for shipping. Content this consequential publishing with no human in the loop fails that bar on its face. |
| Long-term maintainability | Degrades as contributors are added — every new person with push access silently widens who can cause a publish, without anyone deciding that tradeoff. |

### Option B — Manual publish from maintainer workstation

A human runs a local script using the Publisher credential from their
own password manager. GitHub never holds it; nothing in CI references
it.

| Criterion | Assessment |
|---|---|
| Security | **Strongest containment.** Mirrors the existing, working precedent for the release keystore (`DR-2026-0009` §D) — the most sensitive credential never leaves the publisher's machine. |
| Operational complexity | Simplest to build — a script, not a workflow. But correctness depends on the human remembering to run verification first; nothing enforces the order. |
| Recovery | Fast and direct — the person who published is the person who notices and fixes a mistake, immediately, at the same keyboard. |
| Auditability | **Weakest.** No CI log, no dispatch record, no reviewer trail. The only record is whatever the human chooses to write into the manifest afterward — entirely dependent on discipline, not mechanism. |
| Least privilege | Good in principle (one human, one machine) but has no mechanism to *stay* that way as the team grows — it's a habit, not a control. |
| Suitability for Qur'an datasets | Good today. `ROLES.md` currently names one person for all six canonical roles, so "the publisher" and "the only available reviewer" are the same person regardless of which option is chosen. |
| Long-term maintainability | **Weakest.** Single point of failure — if the one person with the credential is unavailable, nothing publishes. Does not scale if publish frequency increases. |

### Option C — Hybrid: CI builds and verifies, a human approves, a dedicated `workflow_dispatch` performs the publish

CI's existing broad-trigger jobs build, run `DR-2026-0012` verification,
and stage signing preparation — but never hold the Publisher credential.
A separate workflow, triggered **only** by `workflow_dispatch`, behind a
GitHub **Environment** requiring a named reviewer's approval, performs
the actual upload using the Publisher credential referenced nowhere
else.

| Criterion | Assessment |
|---|---|
| Security | **Strong.** The credential is referenced by exactly one job, reachable only through manual dispatch plus a required-reviewer gate — never by `push` or `pull_request`. Narrower trigger surface than Option A; no local-machine credential storage requirement like Option B. |
| Operational complexity | **Highest to build once** — needs a correctly separated publish workflow, Environment protection rules, and a clear diff between "what was verified" and "what is about to ship" for the approver to look at. This is a one-time design cost, and this project already has a working pattern for it: B1 and B2 were both built to be provably inert until deliberately exercised, then proven by deliberately breaking them. |
| Recovery | Good — the same approval checkpoint that prevents an accidental publish gives a known, repeatable path to approve a corrected republish. Machine verification also removes the class of error a human reviewing by eye would miss (`DR-2026-0012`: *"a truncated download and a tampered file are the same defect"*). |
| Auditability | **Strongest.** GitHub records the dispatching actor, the approving reviewer, and the full job log including the verification report — a complete "who decided this, and what did the machine confirm" trail that neither A nor B produces. |
| Least privilege | **Strongest.** Directly applies the existing vs. referenced vs. actively used distinction from the C2 review: build/verify jobs (broad trigger) never hold the credential; only the narrowest possible job does. |
| Suitability for Qur'an datasets | **Strongest.** Machine rigor (reproducible build, checksum verification) plus a mandatory human decision before anything reaches users — the combination the project's own release standard implies. |
| Long-term maintainability | **Strongest.** Scales past one maintainer without changing the mechanism — an Environment can later name additional eligible approvers. Separates "can build" from "can publish," so adding contributors (already anticipated in `DR-2026-0013`'s Future Extensions: *"CODEOWNERS... if a second contributor ever joins"*) doesn't automatically widen who can cause a publish, unlike Option A. |

## Recommendation (non-binding)

**Option C**, with **Option B as the explicit, legitimate interim state
until C is built** — not a fallback to apologize for, but the correct
choice for exactly as long as `ROLES.md` names one person for every
role. There is no reviewer to gate on until a second person exists to
be the reviewer, and Option C's added complexity buys nothing today that
Option B doesn't already provide via the same person's own judgment.

**Option A is not recommended at any point.** Every criterion above
resolves the same way for it, and the project's own repeated standard —
would this be something you'd recommend to your own family — is
answered no by a publish path with no human decision point, for content
whose accuracy this project has already spent multiple sprints
correcting misattribution on (Ibn Kathir).

**Suggested sequencing, not a decision:** operate under Option B now;
build Option C as its own phase, with the same discipline
`IMPLEMENTATION_PROGRAM.md` applied to B1/B2/C1 — additive, provably
inert until deliberately triggered, independently reversible — at the
point a second person joins the project, or before, if publish frequency
grows enough that Option B's manual-discipline dependency becomes the
bottleneck first.

## Decision

**Not yet decided.** This section is intentionally incomplete. Fill in
when the `owner_role` accepts, amends, or rejects the recommendation
above; update `status` in the frontmatter accordingly.

## Consequences

Not evaluated — consequences follow from whichever option is accepted,
and none has been.

## Risks

| Risk | Severity | Note |
|---|---|---|
| This record stays in `proposed` indefinitely and a publish workflow gets built anyway, off the books | High | Same failure mode `DR-2026-0013` was written to close for content — a rule that isn't enforced is a rule that gets bypassed under time pressure |
| Option B is treated as permanent rather than interim, past the point a second contributor joins | Medium | Named explicitly above so it isn't a silent drift |
| Option C is built with the publish job insufficiently separated from the build job (e.g., both in one workflow file, credential scoped to the whole run rather than one job) | Medium | Whoever implements C should be held to the same "prove by deliberately breaking it" discipline as B1/B2 — attempt to trigger the publish step via `push`/`pull_request` and confirm it cannot |

## Future extensions

- If Option C is accepted: a companion implementation phase, sequenced
  in `IMPLEMENTATION_PROGRAM.md` the same way B1/B2/C1 were.
- If a second contributor joins before C is built: revisit Option B's
  "interim" status explicitly rather than letting it persist by default.

## Measure of success

Not that a publishing model is chosen. That whichever one is, the
Publisher credential's reach in GitHub — referenced by, not merely
present in — matches exactly what this record decided, and nothing
wider crept in without a corresponding decision.
