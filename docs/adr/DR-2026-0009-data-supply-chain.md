---
id: DR-2026-0009
scope: project
owner_role: data-owner
date: 2026-07-26
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-26
reversibility: soft
threshold_reason: [materially-different-approaches, affects-build-reproducibility]
links:
  task: "Sprint 39.0 — Data Supply Chain Architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0009 — Data supply chain: separate the data build from the app build

Implements `DR-2026-0008`. Owns **how content moves from upstream to the
application**. Does not own what is permitted (`DR-2026-0010`), artifact
identity (`DR-2026-0011`) or enforcement (`DR-2026-0013`).

## Context

`tool/build_quran_db.py` already has two kinds of loader, and their
names record an accident nobody chose:

| Prefix | Meaning | Datasets | Committed? |
|---|---|---|---|
| `import_*`, `try_sources` | fetch upstream at build time | Tanzil Arabic, Saheeh Int'l, QuranEnc Vietnamese | **no** |
| `load_*` | read a file from `tool/data/` | transliteration, both tafsirs, surah names | **yes** |

The split fell out of which fetch scripts happened to become separate
tools. Half the correct architecture therefore already exists and works.

## Problem

Three properties do not survive a ten-year horizon:

1. **The data build and the app build are the same build.** The database
   is produced by a developer, by hand, at an unrecorded moment, from
   inputs that may no longer exist.
2. **CI has never exercised the data pipeline.** The guard
   `if [ ! -f assets/database/quran.sqlite ]` has never fired, because
   the file is always present after checkout. The pipeline is untested.
3. **App builds are non-deterministic.** Three sources are fetched live,
   so two builds of the same commit can differ.

## Decision

**Separate the data lifecycle from the code lifecycle.**

| | Data build | App build |
|---|---|---|
| Cadence | a few times a year | many times a day |
| Trigger | deliberate — new corpus, correction | every push |
| Inputs | registered datasets | source + **one pinned artifact** |
| Output | immutable versioned artifact | AAB / IPA |
| Needs upstream network | yes | **no** |
| Content credentials | read + write | read-only |

Consequences of that split, all decided:

**A · The database is never committed and never built by an app build.**
It is produced by a dedicated pipeline, published as an immutable
artifact, and consumed by pin (`DR-2026-0011`, `DR-2026-0012`).

**B · Three access tiers, and the lowest must be genuinely usable.**

| Tier | Gets | Can run |
|---|---|---|
| 0 · Public | code, tests, a **public-profile database** | everything except restricted-content assertions |
| 1 · Contributor | + read access to restricted artifacts | the full suite |
| 2 · Publisher | + write access, signing keys | everything |

The public profile is a **real** database built from only those sources
whose grant permits redistribution — today the Tanzil Arabic text,
verified, complete, 6,236 ayahs. It is derived from grants
(`DR-2026-0010`), never hand-maintained. Synthetic fixtures were
rejected: they exercise the schema but not RTL rendering, passage
resolution or search relevance, and drift silently.

**C · CI obtains restricted data with short-lived, least-privilege,
environment-gated credentials, and verifies the checksum before use.**
OIDC federation where the provider supports it; otherwise a scoped
read-only token, rotated annually. Pull requests from forks cannot reach
those credentials and build the public profile instead.

**D · Two secret classes, never mixed.**

| Class | Lives | Blast radius if leaked |
|---|---|---|
| Build secrets (content read) | CI environment secrets | exposure of data already licensed to us |
| Release secrets (keystore, store keys) | **publisher's machine only** | **permanent loss of the ability to update the app** |

The existing behaviour — CI falls back to debug signing when
`key.properties` is absent — is correct and does not change.

**E · One database per content domain.** `quran.sqlite`,
`lexicon.sqlite`, `hadith.sqlite`, and derived packs delivered on
demand. A licence problem in one domain must never force a rebuild of
another. This extends the existing group-A / group-B database
separation rather than replacing it.

**F · Manifest before import.** A dataset with no manifest cannot be
imported. The manifest is where the licence question gets asked; the
current situation arose from importing first and documenting later.

## Consequences

**Positive.** The pipeline becomes testable — running it *is* its test.
App builds become deterministic. The repository stops growing by ~33 MB
per data version. Adding the eleventh corpus costs what the fourth did.

**Negative.** Two workflows to maintain instead of one. Tier-0
contributors get Arabic-only content. A build now depends on an object
store — although that store is more reliable than the live upstreams it
replaces.

**Neutral.** No application code changes. The three real-data test files
already begin with `if (!file.existsSync()) { skip }`; that guard
becomes "assert what this profile supports" rather than being removed.

## Alternatives considered

| Alternative | Verdict |
|---|---|
| Developer builds the database by hand (status quo) | **Rejected.** Irreproducible; unrecorded inputs; produced the four blobs in history. |
| App CI builds it on every run | **Rejected.** Wasteful and non-deterministic — live upstreams mean identical commits can produce different bytes. |
| Release pipeline builds it | **Rejected.** Too late: the database must exist before tests, not after. |
| Synthetic fixture database for tier 0 | **Rejected.** Exercises schema, not content; drifts silently. |
| Keep committing datasets for reproducibility | **Rejected**, and this was the original good-faith reason (`fetch_tafsir.py`: "rebuilding needs no network"). Private storage delivers the same determinism without the exposure. |

## Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Pipeline rots — unrun for two years, then fails under pressure | **High** | Run it quarterly even with no data change. A pipeline exercised only in a crisis is not a pipeline. |
| Private store becomes a single point of failure | Medium | It replaces less-reliable upstreams; keep an offline copy of every payload |
| Tier-0 contributors give up | Medium | Measure it: the full suite must pass against the public profile |
| Upstream vanishes before archiving | **High** | Archive on acquisition, not on need |
| Build credentials leak | Medium | OIDC, least privilege, environment gating, `gitleaks`, annual rotation |

## Future extensions

- Hadith, lexicon and derived knowledge packs enter as new domains
  (decision E) with no change to this record.
- Derived/embedding artifacts are delivered on demand, never bundled.
- A scheduled quarterly pipeline run, once the data workflow exists.
