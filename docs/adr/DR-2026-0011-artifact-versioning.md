---
id: DR-2026-0011
scope: project
owner_role: data-owner
date: 2026-07-26
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-26
reversibility: hard
threshold_reason: [fixes-latent-defect, affects-upgrade-path]
links:
  task: "Sprint 40.0 — Data OS Architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0011 — Artifact versioning: three independent axes

Owns **identity and compatibility**. Does not own storage
(`DR-2026-0012`) or rights (`DR-2026-0010`).

## Context

One integer, `DATA_VERSION` in `tool/build_quran_db.py`, is paired with
`DatabaseConstants.expectedDataVersion` in Dart. A mismatch is caught by
`content_database_smoke_test.dart`. On mismatch at runtime, the app
replaces the installed content database wholesale and atomically.

That mechanism is correct and stays.

## Problem

`DATA_VERSION` carries three unrelated meanings at once. Adding a corpus
and changing a table both bump the same integer, so **the application
cannot distinguish "new content" from "new shape"**.

Today this is harmless because every change happened to be additive and
every consumer happened to be one app. Neither stays true: a table
change requires an app release, a content change does not, and the same
artifact will eventually serve more than one consumer.

## Decision

**Three independent version axes.**

| Axis | Changes when | Who cares | Breaks what |
|---|---|---|---|
| **Schema** | table shape changes | application code | requires an app release |
| **Artifact** | content changes, shape does not | data pipeline | content update only |
| **Dataset** | one input changes | provenance | recorded, not user-visible |

```
quran.sqlite@7 (schema 3)
   ├── tanzil.arabic@2026-07
   ├── quranenc.vi@1.0.8
   └── kfgqpc.muyassar@2026-07
```

**Rules:**

1. **Artifacts and dataset versions are immutable.** A correction
   produces a successor; a published version is never mutated. Some
   consumer has it pinned.
2. **The application pins both**: a supported schema *range*
   ("I understand shape 3") and an exact artifact ("version 7,
   sha256 …"). Schema is a compatibility statement; artifact is an
   exactness statement.
3. **Schema versions are monotonic.** The app declares a range, not a
   point, so a content update within the same shape needs no app
   release.
4. **Every artifact records its input versions and the builder
   revision**, so any release is reproducible years later. This is what
   makes private storage an archive rather than a cache.
5. **Retain every version ever shipped.** Tens of megabytes weighs
   nothing against an unreproducible release.

The existing `expectedDataVersion` becomes the *artifact* pin and gains
a schema field beside it. `content_database_smoke_test.dart` continues
to enforce the pairing; it simply has two things to check instead of
one.

## Consequences

**Positive.** Content updates stop implying app releases. Two consumers
pinning version 7 are guaranteed byte-identical input. A years-old
release can be rebuilt exactly. The app can reject an artifact whose
schema it does not understand, rather than failing obscurely.

**Negative.** Three numbers to keep straight instead of one, and a
discipline to observe: never mutate a published version. Both are
cheaper than the alternative.

**Neutral.** The wholesale-replacement upgrade path is unchanged, as is
the guarantee that a content update never touches user data — the
group-A / group-B separation carries that, not this record.

## Alternatives considered

| Alternative | Verdict |
|---|---|
| Keep the single `DATA_VERSION` | **Rejected.** Conflates three meanings; already prevents distinguishing content from shape. |
| Semantic versioning on one string (`3.7.0`) | **Rejected.** Looks tidy, encodes an ordering between axes that does not exist. Schema and content do not have a major/minor relationship. |
| Content hash as the only identity | **Rejected as sole identity, adopted as verification.** A hash cannot express compatibility or ordering. Used to *verify* a pin, not to *be* one. |
| Date-based artifact versions | **Rejected.** Ambiguous when two builds land the same day; says nothing about compatibility. |
| Mutable "latest" pointer | **Rejected.** Destroys reproducibility — the property this record exists to guarantee. |

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| A published version is mutated "just this once" | **High** | Immutability is the load-bearing rule; storage should be write-once where the provider supports it |
| Schema and artifact bumped together out of habit, losing the distinction | Medium | The smoke test checks both; a schema bump without an app release is a visible failure |
| Pin churn makes routine updates painful | Low | One constant and one manifest, which already had to move together |
| Storage growth from retaining every version | Low | Tens of MB per version; retention is the point |

## Future extensions

- Multi-artifact pinning when a second consumer exists — the same rules
  apply per artifact with no change here.
- Deprecation windows for old schema versions, once more than one schema
  is in the field.
- Signed artifacts, if supply-chain integrity ever needs to defend
  against an adversary rather than a mistake.
