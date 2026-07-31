# Dataset release pipeline — design document

Design review only. No code, workflow, or ADR was modified or created
by this document — it reads `DR-2026-0009` … `DR-2026-0014` as fixed
inputs and designs the process that sits on top of them.

**`DR-2026-0014` is treated as Proposed throughout.** Nowhere below does
the pipeline assume Option A, B, or C. Exactly one stage transition
needs a publishing model at all (§4→§5), and that section names both
of 0014's live paths explicitly rather than picking one.

---

## A correction the design depends on

A "staging → production → rollback" pipeline usually implies a mutable
pointer: something that currently says "the live one," which promotion
moves forward and rollback moves back. **That model is already
rejected for this project.** `DR-2026-0011` rule 5: *"a published
version is never mutated"*; alternatives-considered: *"Mutable 'latest'
pointer — Rejected. Destroys reproducibility."*

So this pipeline does not have a shared pointer to move. It has:

- an ever-growing set of **immutable, retained artifact versions** in
  the registry (`DR-2026-0012`), and
- a set of **independent consumers** (the app, eventually the website),
  each of which **pins its own exact version** and moves that pin
  forward on its own release schedule.

**"Production" means a version now exists in the registry, verified and
recorded — not that anything currently consumes it.** "Rollback" means
a consumer changes which version *it* pins — not that the registry
un-publishes or overwrites anything. This reframing is why §5 and §6
below look different from a conventional deploy pipeline, and it isn't
a stylistic choice — it's `DR-2026-0011` already having decided this.

---

## Roles

Named by function, not by person. `ROLES.md` currently assigns every
one of these to a single individual — separating them here is about
*which decision is being made*, so that the design still holds the day
a second person joins, per `DR-2026-0013`'s own future extension
(*"CODEOWNERS... if a second contributor ever joins"*).

| Role | Does | Holds the Publisher credential? |
|---|---|---|
| **Contributor** | proposes or acquires a dataset | never |
| **Pipeline** (automated) | runs Validation and Verification | never |
| **Reviewer** | reads the verification report, decides promote/reject | never — reviewing is not publishing |
| **Publisher** | executes the one write that creates a new registry version | **only role that ever does** |
| **Release-owner** | accountable for what got published and for rollback decisions | never directly — decides, does not necessarily execute |

---

## Lifecycle overview

```
 1 DRAFT          2 VALIDATION      3 VERIFICATION    4 STAGING         5 PRODUCTION
 ┌───────────┐    ┌───────────┐    ┌───────────┐     ┌───────────┐    ┌──────────────┐
 │ dataset   │───▶│ licence   │───▶│ build +   │────▶│ human     │───▶│ new immutable│
 │ proposed  │    │ + schema  │    │ 4-class   │     │ review    │    │ version      │
 │           │    │ gate      │    │ verify    │     │           │    │ recorded     │
 └───────────┘    └───────────┘    └───────────┘     └───────────┘    └──────────────┘
  no credential     no credential    no credential     no credential   Publisher
  needed             needed           needed            needed          credential
                                                                         (exactly here)

                                                                        6 ROLLBACK
                                                                    (a consumer's own
                                                                     pin moves to a
                                                                     different already-
                                                                     -published version;
                                                                     the registry is
                                                                     never touched)
```

Every stage before Production can run with, at most, the existing
read-only credential (to check what's already published). The write
credential is never referenced before §5, and never referenced by
anything reachable through §1–§4.

---

## 1 · Draft

| | |
|---|---|
| **Role** | Contributor |
| **Required checks** | none automated yet — this is acquisition, not judgment. The one manual check: was the file actually fetched intact (a raw checksum recorded at download time, so a later corrupted re-download is detectable) |
| **Artifacts** | the raw payload (as acquired, untouched) + a draft manifest: source URL/citation, licence as claimed by the source, fetch date, raw sha256 |
| **Promotion criteria** | manifest exists with all four fields above; nothing else — Draft's job is to capture provenance before memory of it fades, per `DR-2026-0009`'s own stated problem |
| **Rollback** | discard. Nothing was published; nothing consumes a draft. No record of the discard is required. |

Needs no credential of any kind — this can happen entirely on a
contributor's machine, before anything touches shared storage.

---

## 2 · Validation

Automated, and deliberately the earliest point a dataset can be
rejected — before a single byte of it is built into anything.

| | |
|---|---|
| **Role** | Pipeline (automated) |
| **Required checks** | (a) licence grant resolves to something other than `deny`/`unknown` for the intended use — `DR-2026-0010`'s three-valued rule, applied here rather than only at the repository boundary; (b) raw payload parses under its declared format (encoding, structure); (c) the `DR-2026-0013`-class gate — size and path shape — applied to the *raw dataset*, so a mistake is caught here, not only if someone later tries to commit it |
| **Artifacts** | a validation report: grant resolution result, format-check result, gate result — attached to the Draft manifest, not a separate object |
| **Promotion criteria** | all three checks pass. A `deny`/`unknown` grant does not fail the pipeline outright — it restricts which *output* (§3·E below) the dataset may ever contribute to; e.g. non-commercial-only content can feed the app database but never the public website JSON |
| **Rollback** | reject with the specific failing check recorded (which of the three, and why). The dataset stays at Draft; nothing to undo elsewhere, since nothing downstream has run yet |

No credential needed. This stage can run with no network access to the
registry at all — it only needs the dataset's own manifest and, for the
licence check, a read of the licence registry (`DR-2026-0010`), which is
itself project-tracked data, not R2 content.

---

## 3 · Verification

This is `DR-2026-0012` §B, applied at the point a build actually
happens. **"Build produces; verification refuses"** — the split is
already decided; this stage just names where it sits in the lifecycle.

| | |
|---|---|
| **Role** | Pipeline (automated) |
| **Required checks** | the four classes `DR-2026-0012` §B already names: **Structural** (114 surahs, 6,236 ayahs — existing `validate()`), **Semantic** (coverage, no empty text — existing `tafsir_real_corpus_test.dart`-class checks), **Provenance** (built artifact's checksum matches the record), **Licence** (every input's grant permits the specific output being built) |
| **Artifacts** | the built artifact(s) — per `DR-2026-0012` §E, possibly more than one from the same inputs (`quran.sqlite` for the app; a smaller public JSON for the website, containing only redistribution-permitted inputs) — plus the artifact record (`DR-2026-0012` §A: schema, inputs[], builder revision, built-at, sha256) and the verification report itself |
| **Promotion criteria** | all four classes pass, for every artifact being built from this input set. `DR-2026-0012`: *"An artifact that fails verification is not published"* — failing here is terminal for this build, not a warning |
| **Rollback** | fix the input or the builder, re-run. Nothing was published, so there is nothing to roll back — only a failed build to discard |

No credential needed to *build or verify* — this can run entirely
against already-validated local/CI-local datasets and produce its
output as a CI job artifact or local file. Writing that output into the
shared registry is a separate act, and it hasn't happened yet.

---

## 4 · Staging

**This is the stage `DR-2026-0014` exists because of.** A verified
artifact is not automatically a published one — `DR-2026-0012` says
verification is a precondition for publishing, not the same act as
publishing. Staging is the gap between "the machine is satisfied" and
"a human decided."

| | |
|---|---|
| **Role** | Reviewer |
| **Required checks** | human reads the verification report (§3) and a diff summary against the last published version: ayah/surah counts unchanged (or a change explained), new or changed attribution entries correct, licence envelope not silently widened, dataset provenance matches what was expected |
| **Artifacts** | the same built artifact(s) + verification report from §3, sitting somewhere reviewable but not yet referenceable by any consumer's pin — plus a new artifact: **the review record** (who looked, when, decision, and why if rejected) |
| **Promotion criteria** | reviewer records an explicit go decision. No default; silence is not approval |
| **Rollback** | reviewer rejects, with reason recorded. The artifact stays unpublished — discard it or leave it to expire under a retention window; either way no consumer was ever exposed to it |

No credential needed to *review* — reading a report and writing a
decision requires no R2 access at all. This is exactly why the review
record can exist independent of whichever way `DR-2026-0014` resolves:
reviewing is not the credentialed act, publishing is.

---

## 5 · Production

**The only stage that writes.** Per the correction above, this is not
"go live" — it's "a new immutable version now exists in the registry,"
recorded per `DR-2026-0012` §A. No consumer's pin moves as a side
effect of this stage; that is each consumer's own, later decision.

| | |
|---|---|
| **Role** | Publisher (executes) · Release-owner (accountable for the decision to execute) |
| **Required checks** | exactly one: the artifact and record being written are byte-identical to what the Reviewer approved in §4 — the write must reference the reviewed version, never "whatever is currently built" |
| **Artifacts** | the published, immutable artifact + its `DR-2026-0012` §A record, now retained permanently per `DR-2026-0011` rule 5 |
| **Promotion criteria** | write succeeds; the record is readable back and its checksum matches. Nothing else — there is no "promote further," Production is terminal for this version |
| **Rollback** | not applicable *to this stage* — see §6. The write, once it succeeds, is never undone; a mistake found later is handled by consumers choosing not to pin it, not by un-publishing it |

**Where the Publisher credential becomes available: exactly here, and
nowhere upstream.** §1–§4 never reference it. This is deliberate, not
incidental — it's the "existing vs. referenced vs. actively used"
distinction from the prior architecture review, applied to its logical
conclusion: the write credential's *referenced* surface is the smallest
possible single action.

**How this act is authorized is exactly what `DR-2026-0014` leaves
open, and this design does not resolve it:**

- **Under Option B** (today's interim, per `DR-2026-0014`'s own
  recommendation): the Release-owner, having reviewed and approved at
  §4, runs the publish personally from their own machine, using the
  credential from their password manager. No GitHub Environment, no
  `workflow_dispatch`, no R2 credential ever enters GitHub.
- **Under Option C** (if `DR-2026-0014` is later accepted as drafted):
  the same action is instead performed by dispatching a dedicated
  workflow — see the two sections below.

Either way, the stage boundary is identical: nothing before a recorded
§4 approval may perform this write, and the write must name the
approved version explicitly.

---

## 6 · Rollback

Not a mirror of Production — a different kind of act entirely, because
of the correction at the top of this document.

| | |
|---|---|
| **Role** | Release-owner (decides) · whoever owns the affected consumer's release process (executes) |
| **Required checks** | the target version being reverted *to* already exists in the registry, already verified, already published — rollback never re-verifies, it only re-selects |
| **Artifacts** | for the app: a new app release with `expectedDataVersion` (the `DR-2026-0011` artifact pin) set to the prior version — the exact mechanism `content_database_smoke_test.dart` already enforces, unchanged by this pipeline; for any future live-fetching consumer: an updated pin in that consumer's own config |
| **Promotion criteria** | the reverted consumer build passes its own existing checks (for the app: the same smoke test, same release gates already in place) |
| **Rollback of the rollback** | move the pin forward again to whichever version is actually correct — this is not a special path, it is the same act as any other pin change |

**No R2 write credential is needed for rollback at all.** The registry
is never touched — every version it holds stays exactly as published,
forever, per `DR-2026-0011` rule 5. What moves is a value inside the
consumer's own release (an app build constant, a website deploy config),
authorized by whatever release process that consumer already has —
which for the app is the release keystore, a credential this pipeline
has no relationship to and should not acquire one.

**One boundary worth stating plainly:** if a bad artifact was already
embedded in a *shipped* app build (not just published to the registry),
reverting the pin and cutting a new release does not un-ship the old
one from devices that already installed it. That is the app store
release channel's own rollback/hotfix problem, outside this pipeline's
authority — this pipeline can make the *correct* version available
immediately; it cannot retract what already left the registry through a
consumer's own distribution channel.

---

## Where Publisher credentials must never be available

- In any job reachable by `push` to an unprotected branch or by
  unqualified `pull_request:` — the two triggers `ci.yml` already uses
  for every existing job.
- In §1–§4 tooling, under any circumstance. Validation and Verification
  are automated and unattended; an unattended process should never hold
  a credential that can alter what ships.
- Anywhere without a recorded §4 review decision preceding it. This is
  true regardless of which `DR-2026-0014` option is eventually chosen —
  it constrains the *order of events*, not the *mechanism*.
- On any machine or in any job that also has network access to
  untrusted input (e.g., a job that also fetches third-party datasets in
  the same run) — separate the job that can be influenced by external
  content from the job that can publish, even if the same person
  operates both.

## How GitHub Environments should be used, if `DR-2026-0014` adopts Option C

A single Environment (e.g. `release`), and nothing else references it:

- The Publisher credential lives as **environment secrets**, not
  repository-wide secrets — no other job can reference them even by a
  typo, because they don't exist outside this Environment's scope.
- **Required reviewers** configured on the Environment, so a dispatch
  pauses for a named approver before the job runs — this is the
  mechanism that turns "a human decided at §4" into something GitHub
  itself enforces, rather than something that merely happened to occur.
- **Deployment branch/tag restriction**, so only `main` or release tags
  can even request this Environment — closing the same gap `ci.yml`'s
  AAB step already closes for release signing (`if: github.event_name
  != 'pull_request'`), one level stricter.

Until `DR-2026-0014` is accepted, **no Environment referencing the
Publisher credential should exist in the workflow at all** — an
Environment with no consuming job is inert but has no purpose to serve
yet, and creating one preempts a decision this design was explicitly
told to leave open.

## How `workflow_dispatch` fits in, if `DR-2026-0014` adopts Option C

`workflow_dispatch` is the one GitHub trigger that requires a human to
explicitly invoke a run with explicit inputs — never `push`, never
`pull_request`, never a schedule. That property is exactly what §5
needs: a way to say "publish *this specific reviewed version*," not
"publish whatever the current build happens to be."

Composed with the Environment above, it becomes a two-step checkpoint:
someone **dispatches** the run naming the exact version approved at §4
(artifact id, version, sha256 — never "latest"), and the Environment's
required reviewer **approves** the run before it executes. Two
recorded, attributable actions — who asked, who allowed — replacing
the single unattributed act a `push`-triggered publish would be under
Option A.

This section describes a mechanism, not a decision. If `DR-2026-0014`
remains Proposed indefinitely, or resolves to Option B, no
`workflow_dispatch` publish job should be built — Production continues
to happen exactly as described in §5's "Under Option B" bullet, and
that remains a complete, correct pipeline on its own.

---

## Consistency check against existing records

| This pipeline | Rests on |
|---|---|
| §1 Draft manifest fields | `DR-2026-0009`'s stated problem: provenance forgotten under time pressure |
| §2 licence gate | `DR-2026-0010`'s three-valued grants |
| §2 raw-payload gate | `DR-2026-0013`'s deny-list/size-guard, applied one step earlier than the repository boundary |
| §3 four verification classes | `DR-2026-0012` §B, verbatim |
| §3 possibly-multiple outputs | `DR-2026-0012` §E |
| §4 human checkpoint before publish | the gap `DR-2026-0014` identified between "verified" and "published" |
| §5 immutable, retained versions | `DR-2026-0011` rules 1 and 5 |
| §5 credential locality | the C2 architecture review's existing/referenced/used distinction |
| §6 no mutable pointer to roll back | `DR-2026-0011`'s explicit rejection of that model |
| §6 app-side pin mechanism | `DR-2026-0011`'s existing `expectedDataVersion` / `content_database_smoke_test.dart` |
| Environments/`workflow_dispatch` sections | `DR-2026-0014` Option C, presented conditionally, not adopted |

No new architectural claim is made anywhere above that isn't already
one of these. Where this document goes further than an existing record,
it is sequencing and mechanism — how the stages compose — not policy.

## What this document does not decide

- Whether `DR-2026-0014` resolves to Option B, Option C, or something
  else. Both are designed for; neither is chosen.
- Any workflow YAML, Environment configuration, or code. Deliberately
  none was written.
- Retention windows for rejected §4 artifacts, or for superseded §5
  versions beyond `DR-2026-0011`'s "retain every version ever shipped."
- Who, specifically, holds each role today versus after a second
  contributor joins — `ROLES.md`'s concern, not this pipeline's.
