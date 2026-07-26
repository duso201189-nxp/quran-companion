---
id: DR-2026-0010
scope: project
owner_role: data-owner
date: 2026-07-26
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-26
reversibility: soft
threshold_reason: [legal-exposure, prevents-recurrence-of-a-known-incident]
links:
  task: "Sprint 40.0 — Data OS Architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0010 — Licence registry: rights as machine-readable data

Owns **what is permitted**. Does not own what exists (`DR-2026-0009`),
identity (`DR-2026-0011`) or enforcement (`DR-2026-0013`).

**Implements, does not supersede, `PROJ-P-005`.** That constraint is
Constitution-tier and outranks this record.

## Context

`docs/LICENSING.md` is accurate, thorough, and records every term
verbatim including unfavourable ones. Nothing in the build reads it. To
`build_quran_db.py`, a source with written permission and a source with
none are indistinguishable.

## Problem

Two defects, both demonstrated by the Ibn Kathir incident.

**Rights are layered; the model was flat.** The 14th-century Arabic
original is public domain. The English abridgement commissioned by
Darussalam in 2000 is not. A single `license: "…"` string cannot
express that, and because it could not, the wrong answer shipped —
`translation_sources.author` still reads `'Hafiz Ibn Kathir'` rather
than the rights holder.

**"Unknown" was silently treated as "allowed."** For five sprints three
sources carried no locatable terms, and the build imported them anyway.
There was nowhere to record *"we do not know"*, so the absence of a
prohibition functioned as a permission.

## Decision

**Record rights as machine-readable grants, separate from datasets, in
a file-based registry that gates the build.**

**A · Layered model: `work → edition → grant`.**

```
work:    "Tafsir Ibn Kathir"                     public domain (d. 1373)
  edition: "English abridged, Darussalam 2003, ISBN 9960-892-71-9"
             rights_holder:     Maktaba Dar-us-Salam
             grant:
               embed_in_app:      unknown
               redistribute_file: deny
               commercial:        deny
               modify:            deny
             evidence:  legal/OUTREACH.md#1 (sent <date>)
             expires:   null
             review_by: 2027-01-26
```

**B · Three-valued logic: `allow` / `deny` / `unknown`. At every gate,
`unknown` behaves as `deny`.** This is the single most important clause
in the record. It converts the incident's root cause into a build
failure.

**C · Evidence, not opinion.** A grant records where permission came
from — a URL, an email, a document. A grant with `status: granted` and
`evidence: null` is invalid and must fail validation. "We think it's
fine" is not a grant.

**D · Separate from the data registry, referenced by pointer.** One
licence governs several datasets — Tanzil's terms cover the Arabic text
and its translations *differently* — and one dataset carries several
layers. Copying licence text into dataset records would mean editing a
granted permission in N places.

**E · Files, not a service.** JSON or YAML in private storage:
reviewable, diffable, versioned, zero operations. Reconsider only when a
second person needs write access or a consumer needs runtime resolution.

**F · The registry drives four things**, so it cannot drift from
reality: the build gate (D-B above), the public build profile
(`DR-2026-0009` B), the in-app attribution string, and the artifact's
distribution constraints.

## Consequences

**Positive.** The Ibn Kathir class of defect becomes a build failure
rather than a discovery. Attribution is generated from the same record
that governs permission, so `attribution_real_data_test.dart` keeps
verifying a fact rather than a copy. `PROJ-P-005`'s non-commercial
constraint becomes mechanical instead of remembered.

**Negative.** Every new dataset needs a grant written before import —
deliberate friction at exactly the step this project has historically
rushed. Grants need periodic review; `review_by` makes that explicit.

**Neutral.** No application code changes. `translation_sources.license`
keeps its current shape; only its provenance changes.

## Alternatives considered

| Alternative | Verdict |
|---|---|
| Keep licensing as prose in `docs/LICENSING.md` | **Rejected.** Accurate and unenforced. Prose cannot fail a build; this is the status quo that produced the incident. |
| Single `license:` string per dataset | **Rejected.** Cannot express layered rights. It is precisely the model that shipped the wrong answer. |
| SPDX identifiers only | **Rejected.** SPDX covers software licences well and bespoke publisher permissions not at all. "Darussalam replied by email on date X" has no SPDX identifier. |
| Two-valued logic (permitted / not permitted) | **Rejected.** Forces "unknown" into one bucket. Into *permitted* it repeats the incident; into *prohibited* it blocks Tanzil's Arabic text, which is fine but unrecorded. Three values are the minimum honest model. |
| A registry service with an API | **Deferred**, not rejected. Operations without benefit at ~6 records. See Future extensions. |

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Registry written once, never maintained | **High** | `review_by` on every grant; annual review already scheduled by `PROJ-P-005` |
| Grants recorded optimistically without evidence | **High** | Validation rejects `granted` with `evidence: null` |
| Registry drifts from the shipped database | Medium | Verification asserts registry ↔ database parity, as `attribution_real_data_test.dart` already does for licence and URL |
| Friction encourages bypassing the gate | Medium | The gate is `DR-2026-0013`, in CI, unbypassable |
| Over-modelling — a rights ontology nobody needs | Medium | Four grant scopes only: embed, redistribute, commercial, modify. Extend on evidence, never on anticipation. |

## Future extensions

- **Deferred until a second consumer exists:** computing an artifact's
  distribution envelope as the intersection of its inputs' grants
  (`DR-2026-0012`). The record format here is designed so that becomes
  derivable, but the computation is not built.
- **Deferred until a second writer exists:** a registry service with an
  API and runtime resolution.
- Grant expiry notifications, if any permission is ever time-limited.
