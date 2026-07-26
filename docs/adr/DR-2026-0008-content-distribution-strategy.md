---
id: DR-2026-0008
scope: project
owner_role: data-owner
date: 2026-07-26
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-26
reversibility: hard
threshold_reason: [materially-different-approaches, hard-to-reverse-later, legal-exposure]
links:
  task: "Sprint 38.0 — Repository & Distribution Strategy Review"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0008 — Content distribution strategy

Root record of the Sprint 38–40 series. `DR-2026-0009` … `DR-2026-0013`
implement it; none of them may relax it.

## Context

The repository is public; its default branch is `main`. Six third-party
content sources reach the shipped application. Three are fetched at
build time and never committed; three are committed as JSON; all six end
up inside the committed 32.7 MB `assets/database/quran.sqlite`.

Measured 2026-07-26:

```
GET .../sprint1-my-library/tool/data/tafsir_en-tafsir-ibn-kathir.json
    → HTTP 200, 10,555,494 bytes
```

That payload is © Maktaba Dar-us-Salam 2003 (ISBN 9960-892-71-9), a
modern commissioned abridgement — not the public-domain 14th-century
original. Git history holds four blobs of the database, 103.4 MB total.

## Problem

Two acts of distribution were conflated:

1. **Shipping content inside an application** — what the permission
   requests in `legal/OUTREACH.md` ask for, and what publishers grant.
2. **Publishing content as a downloadable file** — what a public git
   repository does. Unnecessary, unintended, and far harder to justify
   to a rights holder.

The project was doing (2) as a side effect of doing (1). This is not a
one-corpus defect: removing Ibn Kathir would still leave al-Muyassar
(unverified), the transliteration (unverified) and Saheeh International
(non-commercial only) committed.

## Decision

**No third-party licensed content is committed to a public repository.
Content reaches the build; it never reaches the repository.**

Sequenced, because urgency and correctness differ:

| Move | Action | Status |
|---|---|---|
| **A** | Remove the Ibn Kathir corpus; rebuild; bump `DATA_VERSION` | mitigation, immediate |
| **B** | Restricted inputs and the built database move to private storage; CI fetches them | the actual fix, `DR-2026-0009` |

Move A alone is explicitly **not** the decision. It addresses one
instance of the pattern.

## Consequences

**Positive.** Exposure becomes structurally impossible rather than
policy-dependent. The repository stays public and small. Reproducibility
*improves* — private storage is a controlled archive, unlike a live
upstream that can vanish. New corpora inherit the rule.

**Negative.** CI needs credentials. A fresh clone cannot build the full
database without access; `DR-2026-0009` mitigates this with a
public-profile build. One more system to keep alive.

**Neutral but important.** **No application code changes.**
`pubspec.yaml` names an asset path; Dart cannot observe whether the file
was committed or downloaded moments earlier. No schema change;
`PROJ-P-002` is not engaged. `DR-2026-0006` D3 — "adding a source is a
database row, not a code change" — remains true and untouched.

## Alternatives considered

| Alternative | Verdict |
|---|---|
| **Keep the repository public, keep the layout** | **Rejected.** This is the status quo, and the status quo is the finding. Its only honest form is "accept a known infringement", which is not a position an engineering team may take on a publisher's behalf. |
| **Private repository + separate public site repository** | **Viable fallback, not first choice.** Complete and immediate, including history. Costs public inspectability, which for an app asking users to trust its Qur'anic text is a real loss. Pages from a private repo needs a paid plan; the site would move to its own public repo. Held in reserve if a rights holder objects. |
| **Git LFS** | **Rejected.** Legally inert — LFS objects in a public repository are publicly fetchable. It changes storage mechanics, not access control, and would create the appearance of a fix while closing the ticket. |
| **GitHub Releases on a public repo** | **Rejected.** Identical exposure, one URL further away. |
| **Remove the Ibn Kathir corpus only** | **Adopted as mitigation, rejected as solution.** Fixes one instance; three licensed sources remain committed; git history retains the blob regardless. |

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Move A performed, move B never done; finding declared closed | **High** | This record; `DR-2026-0013` is the enforcement that makes B real |
| Git history still contains the corpus after A and B | Medium | Accepted, paired with a sent permission request. Escalate to `git filter-repo` only if a rights holder objects — it rewrites every SHA the ADRs cite by name |
| Contributors cannot build the full app | Medium | Accepted and documented; `DR-2026-0009` tier 0 |
| Deliberating instead of acting | **High** | Move A is about an hour of work |

## Future extensions

- If permission is granted, the corpus returns via private storage under
  `DR-2026-0009` — it does **not** return to the repository. Permission
  to embed in an app is not permission to publish a file.
- If a rights holder objects, escalate to a private repository or a
  history rewrite. Both are disruptive; neither is needed pre-emptively.

## Standing caveat

No storage architecture makes unlicensed content lawful. This record
guarantees the *repository* never distributes what it may not. Whether
the *application* may ship a given text is answered by a rights holder,
not by an architecture.
