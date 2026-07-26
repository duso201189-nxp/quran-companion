---
id: DR-2026-0013
scope: project
owner_role: release-owner
date: 2026-07-26
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-26
reversibility: soft
threshold_reason: [legal-exposure, prevents-recurrence-of-a-known-incident]
links:
  task: "Sprint 38.0 / 39.0 / 40.0 — repository boundary enforcement"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0013 — CI licence gate: the boundary that cannot be bypassed

Owns **enforcement**. Everything `DR-2026-0008` … `DR-2026-0012` decide
is policy; this record is the part that makes policy fail a build.

**This is the load-bearing record of the series.** Storage without the
gate is a design that depends on memory — the thing it was meant to
replace.

## Context

The project's most effective habit is turning rules into tests that
fail, and proving them by deliberately breaking the code:

| Gate | Reads | Proven by |
|---|---|---|
| `architecture_boundaries_test.dart` | source imports | injecting a forbidden import |
| `attribution_real_data_test.dart` | the shipped `.sqlite` | nulling a licence field — it named the source |
| `store_metadata_test.dart` | `AndroidManifest.xml`, `Info.plist` | reverting the app label |
| `font_licenses_test.dart` | `pubspec.yaml` | — |
| `feature_truthfulness_test.dart` | `.arb` files + the database | reintroducing "AI Tutor" |

Three of the five were verified load-bearing by breaking production code
and watching them go red. No equivalent exists for content.

## Problem

`DR-2026-0008` forbids committing licensed content. `.gitignore` does
not enforce it — `git add -f` exists. A pre-commit hook does not enforce
it — `--no-verify` exists. A document does not enforce it at all.

In 2031 somebody will import a corpus in a hurry, having read none of
these records. Nothing currently stops them.

## Decision

**Four layers, two of them unbypassable, and the deny-list is derived
rather than written.**

| # | Layer | Bypassable |
|---|---|---|
| 1 | `.gitignore` for restricted paths and `*.sqlite` | yes — `git add -f` |
| 2 | pre-commit hook: restricted paths, files > 5 MB | yes — `--no-verify` |
| 3 | **CI gate: no path with a restrictive grant may appear in `git ls-files`** | **no** |
| 4 | **CI size guard: no tracked file exceeds ~5 MB** | **no** |

**A · Layer 3 is derived from the licence registry, not hand-written.**
A dataset whose grant is `redistribute_file: deny` **or `unknown`**
extends the deny-list automatically. Nobody has to remember, and
`DR-2026-0010`'s three-valued rule reaches the repository boundary
unchanged.

**B · Layer 4 catches the class, not the instance.** Any tracked file
over ~5 MB is almost certainly content that does not belong in a source
repository, whatever it is called. It would have caught the original
mistake without knowing anything about Ibn Kathir.

**C · Every gate must be proven by deliberately breaking it.** A gate
never observed failing is a gate nobody knows works. This is a
requirement of the record, not a suggestion.

**D · The gate runs on every push and every pull request**, including
from forks, since it reads only tracked paths and needs no credentials.

## Consequences

**Positive.** Recurrence becomes structurally impossible rather than
policy-dependent. The rule extends itself as datasets are added. A
contributor who has read nothing still cannot make the mistake.

**Negative.** A legitimate large file — a future icon set, a test
fixture — will trip layer 4 and need an explicit allow-list entry. That
friction is the mechanism working; the allow-list must stay short and
reviewed.

**Neutral.** No application code changes; the gate reads git metadata
and registry records only.

## Alternatives considered

| Alternative | Verdict |
|---|---|
| `.gitignore` alone | **Rejected.** Necessary, insufficient — `-f` bypasses it, and it is silent when bypassed. |
| Pre-commit hook alone | **Rejected.** Local, opt-in, `--no-verify`, and absent on a fresh clone. |
| Code review | **Rejected.** A 10 MB JSON in a diff is a one-line summary. The original mistake passed review because there was no review — and would have passed one anyway. |
| Branch protection / path-based CODEOWNERS | **Rejected as primary.** Governs who approves, not what is present. Useful later, not a substitute. |
| Hand-maintained deny-list | **Rejected.** It is a document that must be remembered, which is the failure mode under repair. |
| Secret scanning (`gitleaks`) extended to content | **Rejected.** Built for credential patterns; a tafsir corpus has no signature. `gitleaks` stays for its own purpose. |

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| **Gate never built** — storage moved, enforcement skipped | **High** | This record exists to make that omission visible; it is the deliverable of the series |
| Gate written but never proven to fail | **High** | Decision C: prove by deliberate breakage, as three existing gates were |
| False positives train people to bypass CI | Medium | Layer 4 threshold tuned once, with a short reviewed allow-list |
| Deny-list stale because the registry is stale | Medium | Derived, so registry review (`DR-2026-0010`) is the same maintenance |
| Gate green while history still holds the content | Medium | Accepted and out of scope; `DR-2026-0008` covers history |

## Future extensions

- Extend layer 3 to derived artifacts once `DR-2026-0012`'s envelope
  exists — no change to the mechanism, only to the deny-list source.
- A repository-size guard, if `.git` growth becomes an issue after the
  content moves out.
- CODEOWNERS on `docs/adr/` and the registry, if a second contributor
  ever joins.

## Measure of success

Not that a gate exists. That in 2031 somebody adds a corpus in a hurry,
has never read any of these records, and **the build stops them.**
