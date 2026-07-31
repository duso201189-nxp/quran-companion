# Architecture review — publisher credential in GitHub

Role: Infrastructure Assistant · Date: 2026-07-26 · Architecture review
only. No code, workflow, or document was modified in producing this.

---

## 1 · Re-evaluating "publisher credentials should never exist in GitHub"

**The recommendation as written was too absolute, and I'm revising it.**

`C1_PROVISIONING_CHECKLIST.md` §7 said: *"`qc-publisher` gets no GitHub
secret at all... it must never have one."* That's a stronger claim than
the threat model actually supports, and it conflicts with architecture
this project already froze.

`DR-2026-0009` §B already names a **Publisher** access tier —
*"+ write access, signing keys... everything"* — as a real role
distinct from CI's read-only build tier. A future release workflow that
uploads `quran.sqlite`, manifests, and dataset payloads is that tier's
job. A credential provisioned for it, sitting in GitHub Secrets for
future use, is not by itself a departure from anything this project has
decided. GitHub encrypts secrets at rest and decrypts them only inside
a workflow run that explicitly references them — an unreferenced secret
has essentially the same exposure as one sitting in a password manager.

**Revised recommendation:** the publisher credential may exist in
GitHub Secrets now. What still shouldn't happen yet is any workflow
*referencing* it — see §3. That's a narrower, more defensible claim
than "must never exist," and it's the one worth keeping.

---

## 2 · Existing vs. referenced vs. actively used

These are three different exposure levels, and the earlier report
(`C2_VERIFICATION_REPORT.md`) collapsed them into one. Distinguishing
them properly:

| State | What it means | Who/what can reach the credential | Current status here |
|---|---|---|---|
| **Exists** | Stored in GitHub Secrets (repo or Environment) | No one, until a workflow step names it | Plausible — unverifiable from this session (§0 of the prior report: no `gh` access) |
| **Referenced** | A workflow YAML contains `${{ secrets.R2_PUBLISH_* }}` | Every run of every job/step that names it, for every trigger that reaches that job | **Confirmed absent** — `grep` over `.github/workflows/ci.yml` returns zero R2 matches of any kind |
| **Actively used** | A step in a running job actually calls the API with it | Whatever that step's logic does, at that moment | Cannot occur — there is nothing to call it |

The risk profile jumps at the second boundary, not the first. A secret
existing and unreferenced is inert. A secret *referenced* becomes
reachable by everything that can trigger the job it sits in — which is
the concrete question in §3.

---

## 3 · Why the publisher credential should not be referenced by current CI yet

Two independent reasons, one about *what triggers current CI* and one
about *what hasn't been designed yet*.

### 3a · The trigger surface is wider than "main"

```yaml
on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
```
— `.github/workflows/ci.yml:28-34`

`pull_request:` is unqualified — it runs for every PR branch pushed
*within this repository* (fork PRs don't get repo secrets by GitHub's
own default, but same-repo branches do). Every existing job in this
workflow sits under that trigger. The one place the workflow already
distinguishes trust levels is the Android build step, gated explicitly:
`if: github.event_name != 'pull_request'` — release signing only runs
off `main`/tags, debug APK runs everywhere else.

If `R2_PUBLISH_*` were referenced in any job that doesn't carry an
equivalent gate, every push to every PR branch in this repo would run
code with access to a credential that can overwrite the Qur'anic text
served to users. That's a much lower bar than "a maintainer decided to
publish a release," which is presumably the intent. A publish job needs
at minimum the same `event_name != 'pull_request'` discipline the AAB
step already uses, and — given the stakes — a GitHub **Environment**
with required-reviewer protection on top, not just a branch check.

### 3b · No publish job has gone through this project's own design discipline

Every phase in this engagement — B1, B2, C1 — was built to be
**provably inert before it becomes load-bearing**: B1 shipped and was
proven to fire on a deliberately-broken commit before anything relied on
it; B2 the same; C1 was scoped so nothing in the codebase depends on
storage yet, and that was verified by grep, not assumed. A CI-triggered
publish step is a materially bigger change than any of those — it's the
first thing in the whole program that would let an automated job
*write* to the artifact that ships in the app — and it hasn't had that
treatment yet. `IMPLEMENTATION_PROGRAM.md` doesn't currently name a
phase for it at all (§4 below).

There's also an open question at the ADR level, not just an
implementation gap: neither `DR-2026-0009` nor `DR-2026-0012` states
*who* performs the publish action — a human on the publisher's machine,
or a CI job. `DR-2026-0009` §B's "Publisher" tier reads as a **role**
("write access, signing keys... everything"), which is at least as
naturally a human at a keyboard as it is a GitHub Actions job. Wiring
`R2_PUBLISH_*` into a workflow now would silently resolve that question
in favor of "CI publishes" without it ever having been decided at the
ADR level — the same kind of undocumented architectural decision this
project has repeatedly stopped to avoid making by accident.

**Conclusion:** referencing the credential should wait until (a) a
publish job exists with trigger gating appropriate to its blast radius,
and (b) the CI-vs-human question is answered explicitly in an ADR or ADR
amendment, not implied by a workflow diff.

---

## 4 · Documents that need updating, and exactly what in them

None of these were edited in this pass — listed for your review.

| Document | Location | What's wrong | What it should say instead |
|---|---|---|---|
| `C1_PROVISIONING_CHECKLIST.md` | §5 table, row *"Publisher token stays off CI"* | States an absolute exclusion | Existence in GitHub Secrets is fine; **reference** in a workflow is what's deferred, and only until a gated publish job exists |
| `C1_PROVISIONING_CHECKLIST.md` | §7, *"`qc-publisher` gets no GitHub secret at all... must never have one"* | Same absolute claim, the direct source of the flagged "deviation" | Replace with: publisher credential may be stored as a GitHub secret for the future release workflow; must not be referenced by any job reachable from `pull_request` without equivalent gating to the existing AAB step |
| `docs/PRIVATE_STORAGE.md` | §5 Credential strategy, *"Never in CI"* | Same | Narrow to: not *referenced* by the current workflow; scoped for a future protected publish job |
| `docs/PRIVATE_STORAGE.md` | §6 Access model diagram | Shows only publisher-machine↔bucket and CI-read↔bucket | Add the future release-workflow write path, marked dormant/unreferenced |
| `docs/PRIVATE_STORAGE.md` | §13 Remaining work before C2 | Doesn't mention a publisher credential in GitHub at all | Add: publisher credential may exist in GitHub Secrets; referencing it is gated on the publish-job design (§3 above) |
| `C2_VERIFICATION_REPORT.md` | "Finding" section | Flags `R2_PUBLISH_*` as an unexplained deviation from the documented plan | Should be marked **superseded by this review** — the credential's existence is architecturally justified; only its use in workflow needs to wait |
| `IMPLEMENTATION_PROGRAM.md` | phase list | No phase names a CI-driven publish/release workflow at all | Add a not-yet-designed phase (naming convention aside, call it what it is — e.g. "publish workflow") so the eventual wiring goes through the same phase discipline as B1/B2/C1: additive, provably inert until load-bearing, independently reversible |
| `docs/adr/DR-2026-0009-*.md` and/or `DR-2026-0012-*.md` | §B (0009) / publish description (0012) | Neither states whether the publish actor is CI or a human on the publisher's machine | Needs an explicit statement, or a short ADR amendment — this is a real open decision, not a documentation nit, since it changes the workflow's trigger and secret-scoping requirements |

The last row is the one worth flagging most: it's not phrasing, it's an
undecided piece of architecture that the earlier documents happened to
avoid contradicting only because they never addressed it.

---

## Summary

| Question | Answer |
|---|---|
| Can the publisher credential exist in GitHub Secrets today? | **Yes** — revising the earlier absolute "never" |
| Is it currently referenced by any workflow? | **No** — confirmed by grep, zero R2 matches anywhere in `ci.yml` |
| Should it be referenced yet? | **Not yet** — the workflow's `pull_request:` trigger reaches every same-repo branch, and no publish job has the design/gating/ADR backing this project requires before something gets to write to the shipped artifact |
| What changes are needed? | Six documents, all listed in §4, all currently stating or implying an absolute exclusion that was too strong |
| Does this affect C1 or C2's approval status? | No — C1 remains about provisioning, C2 remains about verification; this review only corrects the credential-strategy documentation those two built on |
