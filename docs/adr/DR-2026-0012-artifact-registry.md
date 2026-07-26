---
id: DR-2026-0012
scope: project
owner_role: data-owner
date: 2026-07-26
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-26
reversibility: soft
threshold_reason: [affects-build-reproducibility, multi-consumer-readiness]
links:
  task: "Sprint 40.0 — Data OS Architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0012 — Artifact registry: what is consumable

Owns **what is consumable and how a consumer obtains it**. Identity and
compatibility belong to `DR-2026-0011`; rights to `DR-2026-0010`.

**Scope warning.** This record deliberately decides less than Sprint
40.0 designed. Envelope computation and consumer manifests are recorded
under Future extensions with an explicit trigger, not adopted. There is
one consumer today; a resolution mechanism for many would be an
abstraction serving nothing, which `DR-2026-0006` D4 already refused
once in a different form.

## Context

`DR-2026-0009` produces immutable versioned artifacts. Something must
record which exist, what went into them, and whether they passed
verification.

## Problem

Without a record of provenance, an artifact is an anonymous binary. Three
questions become unanswerable: which datasets produced it, was it
verified, and is the file in hand the file that was published.

The third matters most. A truncated download and a tampered file are the
same defect; both must fail loudly rather than produce a subtly wrong
app.

## Decision

**Every published artifact carries a record; consumers obtain artifacts
by pin and verify before use.**

**A · The artifact record.**

```
artifact: quran.sqlite@7
  schema:        3
  inputs:        [tanzil.arabic@2026-07, quranenc.vi@1.0.8,
                  tanzil.saheeh@2026-07, quran-com.translit@2026-07,
                  kfgqpc.muyassar@2026-07]
  builder:       build_quran_db.py@<revision>
  built_at:      <timestamp>
  sha256:        …
  verification:  report-7.json (passed)
```

**B · Verification is separate from the build, and its report is part of
the record.** The build's job is to produce; verification's job is to
refuse. Four classes:

| Class | Asks | Already exists as |
|---|---|---|
| Structural | is the shape right? | `validate()` — 114 surahs, 6,236 ayahs |
| Semantic | is the content right? | `tafsir_real_corpus_test.dart` — coverage, no empty text |
| Provenance | did it come from what we think? | *new* — checksum ↔ record |
| Licence | may it exist at all? | *new* — grants permit every input (`DR-2026-0010`) |

An artifact that fails verification is not published. Consumers check
the report; they never re-verify content. That is what makes "build
once, consume many" safe rather than merely convenient.

**C · Consumers pin `(artifact-id, version, sha256)` and verify before
use.** A mismatch fails the build. No consumer builds data; no consumer
re-verifies content.

**D · Artifacts are content-addressed and immutable** — the storage
consequence of `DR-2026-0011`'s identity rules.

**E · A build may publish more than one artifact from the same verified
inputs.** The application bundles `quran.sqlite`; the website consumes a
small public JSON containing only inputs whose grants permit file
redistribution. Same run, same inputs, same verification, different
outputs — because publishing a file and embedding in a signed binary are
different acts under the licences the project actually holds.

This is the honest answer to "every consumer uses the same artifact":
**one registry and one verification, not necessarily one file.** Handing
the website the app's database would republish Saheeh International as a
downloadable file, which its licence forbids.

## Consequences

**Positive.** Any release is reproducible from its record. Corruption and
tampering fail identically and loudly. The pipeline gains a refusal step
it never had. A second consumer becomes an addition rather than a
redesign.

**Negative.** One more record to keep accurate, and a verification stage
that can block a release — which is the point, and will be inconvenient
exactly when it matters.

**Neutral.** No application code changes. `pubspec.yaml` names an asset
path; how the file arrived is invisible to Dart.

## Alternatives considered

| Alternative | Verdict |
|---|---|
| No registry — publish files, remember what is in them | **Rejected.** This is today, and it is why nobody could say which datasets produced the committed database. |
| Registry service with an API | **Deferred.** Operations without benefit at one consumer and a handful of artifacts. |
| Consumers verify content themselves | **Rejected.** Duplicates verification per consumer and lets two consumers disagree about the same bytes. |
| One artifact for all consumers | **Rejected.** It would republish non-commercial-only text as a public file. The constraint is legal, not technical. |
| Adopt envelope computation and consumer manifests now | **Deferred.** See below. |

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Record drifts from the artifact | Medium | Checksum verification on every consumption |
| Verification becomes a rubber stamp | Medium | Every check must be able to fail; prove each one by deliberately breaking it, as three existing gates already were |
| Scope creep into the deferred platform | Medium | This record's scope warning; `DR-2026-0013` needs none of it |
| Storage cost from retained artifacts | Low | Tens of MB per version |

## Future extensions

Both are **designed and not adopted**. The trigger is stated so the
decision is not re-litigated from scratch.

- **Licence envelope** — an artifact's distribution rights computed as
  the intersection of its inputs' grants; an artifact is only as free as
  its most restricted input. Applied to today's database it yields
  `commercial: deny`, reproducing the `PROJ-P-005` conclusion
  mechanically. **Trigger: a second consumer exists.** Until then the
  intersection has one meaningful consumer and a human already knows the
  answer.
- **Consumer manifests and build-time resolution** — consumers declare
  domains, channel and commercial status; resolution fails the build
  when a declaration exceeds the envelope. **Trigger: the same.** One
  consumer's manifest is a constant.
- **Registry service.** Trigger: a second writer, or a runtime
  resolution need.
