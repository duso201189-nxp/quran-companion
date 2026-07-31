# Data supply chain architecture

**Status: design only.** No code, configuration or data has been changed
by this document. It describes the target state; `DR-2026-0008` decides
whether to adopt it.

Companion to [`ARCHITECTURE.md`](ARCHITECTURE.md) (application
architecture) and [`docs/DATA_PIPELINE.md`](docs/DATA_PIPELINE.md) (how
the current builder works). This document covers the ten-year question
those two do not: **where does content come from, who is allowed to hold
it, and what must be true before it reaches a user.**

---

## 1. Why the current pipeline needs a redesign

The existing pipeline works and produces a correct database. Three
properties of it do not survive a ten-year horizon.

**The data build and the app build are the same build.** `flutter build`
expects `assets/database/quran.sqlite` to exist; the file is committed;
so it is produced by a developer, by hand, at an unrecorded moment, from
inputs that may no longer exist. Four versions of that 32.7 MB file sit
in git history, 103.4 MB in total. CI's
`if [ ! -f assets/database/quran.sqlite ]` guard has never once fired,
because the file is always there after checkout — the data pipeline is
therefore **untested by CI**.

**Licence status is prose, not a pipeline input.** `docs/LICENSING.md`
is accurate and thorough, and nothing in the build reads it. A dataset
with no permission and a dataset with written permission are
indistinguishable to `build_quran_db.py`.

**Acquisition mode was chosen by accident.** The builder already has two
kinds of loader, and their names give the split away:

| Prefix | Meaning | Datasets | Committed? |
|---|---|---|---|
| `import_*`, `try_sources` | fetch from upstream at build time | Tanzil Arabic, Saheeh Int'l, QuranEnc Vietnamese | **no** |
| `load_*` | read a file from `tool/data/` | transliteration, both tafsirs, surah names | **yes** |

Nobody decided that the copyrighted corpus should be the committed one.
It fell out of which fetch scripts happened to be written as separate
tools. The architecture below makes that choice deliberate and
enforceable.

---

## 2. The lifecycle

```
┌─── PUBLIC ─────────────────────────────────────────────────────────┐
│                                                                     │
│  ① SOURCE                    upstream publishers                    │
│     Tanzil · QuranEnc · QUL · KFGQPC · Darussalam · everyayah        │
│                                                                     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │  acquisition (manual, deliberate)
                                ▼
┌─── TRUSTED · publisher's machine ──────────────────────────────────┐
│                                                                     │
│  ② LICENCE VERIFICATION                                             │
│     dataset.manifest.json  ─ identity, provenance, licence,          │
│                              permission evidence, sha256, redist.    │
│     GATE: no manifest, or redistribution:"none" → import refused     │
│                                                                     │
│                                ▼                                    │
│  ③ PRIVATE STORAGE            private object store, versioned        │
│     datasets/<id>/<version>/{payload, manifest}                      │
│     artifacts/quran-<DATA_VERSION>.sqlite + .sha256 + .manifest      │
│     write: publisher only          read: CI, scoped, short-lived     │
│                                                                     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │  OIDC / scoped read token
                                ▼
┌─── SEMI-TRUSTED · CI runner (ephemeral) ───────────────────────────┐
│                                                                     │
│  ④ BUILD PIPELINE — data workflow, run deliberately, not per commit │
│     resolve manifests → verify checksums → licence gate →            │
│     ⑤ SQLITE GENERATION  build_quran_db.py                          │
│     ⑥ VERIFICATION       structural · coverage · integrity ·         │
│                          attribution · licence-parity                │
│                                ▼                                    │
│     publish immutable artifact quran-<DATA_VERSION>.sqlite           │
│                                                                     │
│  ─────────────── separate workflow, different cadence ───────────── │
│                                                                     │
│  ⑦ TESTING — app workflow, every push                               │
│     pull pinned artifact by version + checksum                       │
│     unit · widget · real-data · truthfulness · attribution gates     │
│                                ▼                                    │
│  ⑧ FLUTTER ASSETS   assets/database/quran.sqlite (never committed)   │
│                                ▼                                    │
│     AAB / IPA + mapping.txt                                          │
│                                                                     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │  signed on the publisher's machine
                                ▼
┌─── PUBLIC ─────────────────────────────────────────────────────────┐
│  ⑨ RELEASE     Play Console · App Store Connect                     │
│     users receive content embedded in a signed application           │
└─────────────────────────────────────────────────────────────────────┘
```

The single most important line in that diagram is the one between ③ and
④: **content crosses into the build, never into the repository.**

---

## 3. Trust boundaries

| # | Boundary | What crosses | Enforced by |
|---|---|---|---|
| **B1** | upstream → publisher | raw dataset + licence evidence | human judgement, recorded in the manifest |
| **B2** | publisher → private storage | payload + manifest + checksum | write credentials held by the publisher only |
| **B3** | private storage → CI | payload, **read-only** | OIDC / scoped token, environment-gated |
| **B4** | CI → public repository | **nothing** — one-way valve | CI gate: no restricted path may be tracked |
| **B5** | CI → release artifact | built database inside the app bundle | checksum pinning; signing stays outside CI |
| **B6** | release → user | content embedded in a signed app | store review; the app's attribution screen |

**B4 is the boundary this whole design exists to create.** It is
currently absent, which is why 10.5 MB of a commercial publisher's text
is fetchable from `raw.githubusercontent.com` today.

**B5 deserves its own note.** CI holds *read* credentials for content.
It must never hold the release keystore. Those are two different secret
classes with two different blast radii: a leaked content token exposes
data already licensed to us; a leaked signing key ends the app's ability
to update, permanently. They stay separated, and signing stays on the
publisher's machine, as it already does today.

---

## 4. The seven questions

### 4.1 Who generates `quran.sqlite`?

**None of the three options as posed. A fourth: a dedicated data
pipeline, run deliberately, producing an immutable versioned artifact.**

| Candidate | Why not |
|---|---|
| Developer, by hand | irreproducible; unrecorded inputs; it is how four 33 MB blobs entered git |
| App CI, every build | wasteful and *non-deterministic* — three sources are fetched live, so two builds of the same commit can differ |
| Release pipeline only | too late; the database must exist before tests, not after |

The correct decomposition separates two lifecycles that are currently
fused:

| | Data build | App build |
|---|---|---|
| Cadence | a few times a year | many times a day |
| Trigger | deliberate — a new corpus, a correction | every push |
| Inputs | upstream datasets, manifests | source code + **one pinned artifact** |
| Output | `quran-<DATA_VERSION>.sqlite`, immutable | AAB / IPA |
| Needs network to upstream | yes | **no** |
| Needs content credentials | yes | read-only |

`DATA_VERSION` stops being a string in a Python file and becomes **the
identity of an immutable artifact**. `DatabaseConstants.expectedDataVersion`
becomes a *pin*: the app build requests exactly that artifact, verifies
its sha256, and fails if it cannot get it. The existing smoke test that
compares the two already enforces the pairing — it simply gains teeth.

This also fixes a defect nobody has noticed: the data pipeline currently
has no automated test at all. Under this design, running it *is* the
test.

### 4.2 How do contributors work without licensed data?

**Three access tiers, and the lowest one must be genuinely usable.**

| Tier | Who | Gets | Can run |
|---|---|---|---|
| **0 · Public** | anyone with a clone | code, tests, a **public-profile database** | everything except restricted-content assertions |
| **1 · Contributor** | invited | + read access to restricted artifacts | the full suite |
| **2 · Publisher** | owner | + write access, signing keys | everything |

Tier 0 is the design problem. Two options were considered:

*Synthetic fixtures* — generate a structurally valid database with
placeholder text. Rejected: it exercises the schema but not the content,
so RTL rendering, passage resolution and search relevance all go
untested, and the fixture drifts from reality silently.

**Public-profile build** — build a real database from only those sources
whose licence permits redistribution. Today that is the Tanzil Arabic
text: verified, permissive, complete, 6,236 ayahs. **Recommended.**

```
python tool/build_quran_db.py --profile=public     # no credentials needed
python tool/build_quran_db.py --profile=full       # tier 1+
```

The profile is not a hand-maintained list. It is derived from each
manifest's `redistribution` field, so a dataset that gains permission
enters the public profile automatically and one that loses it drops out.

A tier-0 contributor gets a working app in Arabic, a green test suite,
and every code path exercised on real text. The three data-dependent
test files already skip cleanly when an asset is absent — that guard
becomes "assert only what this profile can support" instead.

### 4.3 How should CI obtain restricted data?

**Short-lived, least-privilege, environment-gated, checksum-verified.**

1. **OIDC federation where the provider supports it** — GitHub Actions
   exchanges its workload identity for a temporary credential. No
   long-lived key exists to leak. Where OIDC is unavailable, a scoped
   read-only API token, rotated on schedule.
2. **Least privilege** — read only, one bucket prefix, no list
   permission beyond what the build needs.
3. **Environment protection** — content credentials attach to a
   protected environment that only `main` and `v*` tags may use. A pull
   request from a fork cannot reach them; forks build the public profile.
4. **Pin, then verify** — the workflow requests the exact
   `DATA_VERSION` and verifies sha256 against the manifest before use.
   A mismatch fails the build. This makes tampering, truncation and
   silent upstream drift all the same, loud failure.
5. **No caching of restricted payloads** into shared CI caches — the
   existing `actions/cache` step keyed on `tool/data/*` disappears with
   the files it was caching.

### 4.4 How should secrets be managed?

**Two classes, never mixed.**

| Class | Examples | Where it lives | Blast radius if leaked |
|---|---|---|---|
| **Build secrets** | content-store read token | GitHub environment secrets, protected | exposure of data already licensed to us — serious, recoverable |
| **Release secrets** | upload keystore, `key.properties`, store API keys | **publisher's machine only; never in CI** | **permanent loss of the ability to update the app** |

Rules:

- Nothing in the repository, ever. `gitleaks` already runs on every push
  and scans full history; it stays.
- Prefer OIDC to static credentials wherever the provider supports it.
- Rotate build secrets annually, on the same cycle as `PROJ-P-002`'s
  `review_by` date, so the reminder already exists.
- The release keystore keeps its current handling — local, git-ignored,
  backed up off-machine. CI falls back to debug signing when
  `key.properties` is absent, which is exactly right and should not
  change.
- Every secret has a named owner and a documented revocation procedure.
  A secret nobody can revoke in ten minutes is not a managed secret.

### 4.5 How do future datasets fit?

**The pipeline must be dataset-shaped, not Qur'an-shaped.** Three
structural decisions carry it:

**One database per content domain.** Not one growing file.

| Database | Contents | Cadence | Ships |
|---|---|---|---|
| `quran.sqlite` | text, translations, tafsir, reciters, search index | rare | bundled |
| `lexicon.sqlite` | lemmas, roots, morphology, grammar | rare | bundled or on demand |
| `hadith.sqlite` | collections, chains, gradings | independent | **on demand** |
| `knowledge.pack` | embeddings / RAG index | frequent | **on demand, never bundled** |

Rationale: different licences, different sizes, different update rhythms.
A licence problem in Hadith must never force a Qur'an rebuild. The app
already separates group A (read-only content) from group B (user data);
this is the same idea applied within group A, and the existing
`DatabaseConstants` pattern extends to it unchanged.

**Every dataset carries a manifest.** This is the load-bearing artifact
of the whole design:

```jsonc
{
  "id": "tafsir.ibn-kathir.en.abridged",
  "version": "2026-07-25",
  "domain": "quran",
  "acquired_from": "https://qul.tarteel.ai/...",
  "acquired_at": "2026-07-25",
  "rights_holder": "Maktaba Dar-us-Salam",
  "work": "Tafsir Ibn Kathir (Abridged), ISBN 9960-892-71-9",
  "licence": "proprietary",
  "redistribution": "none",          // none | app-only | public
  "commercial": "unknown",
  "permission": {                    // the evidence, not an opinion
    "status": "not-requested",       // not-requested | pending | granted | refused
    "evidence": null,
    "expires": null
  },
  "attribution_required": "Maktaba Dar-us-Salam · abridged under...",
  "sha256": "…",
  "notes": "Ibn Kathir's Arabic original is public domain; this English
            abridgement is a modern commissioned work."
}
```

Four things follow from the manifest existing:

- `redistribution` decides the **build profile** (§4.2)
- `permission.status` decides whether the builder will import at all
- `attribution_required` flows into `translation_sources.license`,
  so the in-app attribution screen cannot drift from the licence record
- `sha256` makes the artifact verifiable

**Importers register against a stable contract.** The builder's
docstring already promises this — *"adding a new source = write one
`import_*` function returning `(source_meta, {(sura, aya): text})` and
register it in `IMPORTERS`"*. The design keeps that contract and adds
one requirement: an importer receives a **verified manifest**, not a raw
path. A dataset that cannot produce a manifest cannot be imported.

### 4.6 How does the pipeline prevent accidental commits?

**Four layers, each independently sufficient to catch the mistake, and
one of them impossible to bypass.**

| Layer | Mechanism | Bypassable? |
|---|---|---|
| 1 | `.gitignore` for restricted paths and `*.sqlite` | yes — `git add -f` |
| 2 | pre-commit hook rejecting restricted paths and files > 5 MB | yes — `--no-verify` |
| 3 | **CI gate: `git ls-files` matched against a deny-list derived from the manifests** | **no** |
| 4 | size guard: CI fails if any tracked file exceeds a threshold | **no** |

Layer 3 is the one that matters, and it follows this project's strongest
existing habit. `store_metadata_test.dart` reads `AndroidManifest.xml`
and `Info.plist` directly; `feature_truthfulness_test.dart` reads the
`.arb` files and the shipped database; `font_licenses_test.dart` reads
`pubspec.yaml`. All three were proven load-bearing by deliberately
breaking the code and watching them fail. A content-boundary gate
belongs in exactly that family:

> **Assert that no path marked `redistribution: none` or `app-only`
> appears in `git ls-files`.**

Because the deny-list is *derived from the manifests* rather than
hand-written, adding a restricted dataset extends the guard
automatically. Nobody has to remember.

Layer 4 catches the class rather than the instance: any tracked file
over ~5 MB is almost certainly content that does not belong in the
repository, whatever its name.

### 4.7 The ten-year architecture

Six principles, in dependency order.

1. **Data has its own lifecycle.** Versioned, immutable, addressed by
   content hash, released deliberately. Code changes daily; content
   changes yearly; fusing them makes both worse.
2. **Licence is data, verified by the pipeline.** A manifest per
   dataset, machine-readable, gating the build. Prose in a document
   cannot fail a build.
3. **Trust boundaries are one-way.** Content flows toward the build,
   never toward the repository. Enforced by a test, not a policy.
4. **The public artifact contains only what may be public.** Derived
   from manifests, so it is correct by construction rather than by
   review.
5. **One database per content domain.** Independent licences,
   independent cadences, independent failure.
6. **Every stage has a gate that can fail.** Acquisition (manifest
   present), build (licence permits), verification (structure, coverage,
   attribution), commit (nothing restricted tracked), release
   (checksum pinned).

What this buys over ten years: adding the eleventh corpus costs the same
as adding the fourth; a licence withdrawal is a rebuild rather than an
incident; the repository stays the same size in 2036 as in 2026; and
nobody has to remember a rule, because the rule fails the build.

---

## 5. Risk analysis

| # | Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|---|
| R1 | Restricted content committed again | **High** | Low with layer 3; **certain without it** | manifest-derived CI gate |
| R2 | Private store becomes a single point of failure | Medium | Low | it *replaces* live upstreams that are less reliable; keep an offline copy of every payload |
| R3 | Build credentials leak | Medium | Low | OIDC, least privilege, environment gating, `gitleaks`, annual rotation |
| R4 | Data pipeline rots — nobody runs it for two years, then it fails | **High** | **Medium** | run it on a schedule (quarterly), even with no data change; a pipeline only exercised at crisis time is not a pipeline |
| R5 | Upstream vanishes before archiving | **High** | Medium | the private store *is* the archive; archive on acquisition, not on need |
| R6 | Manifest drifts from reality | Medium | Medium | verification stage asserts manifest ↔ database parity, as `attribution_real_data_test.dart` already does for licence and URL |
| R7 | Tier-0 contributors give up | Medium | Medium | the public profile must be genuinely usable, not a stub — measure it by running the full suite against it |
| R8 | Artifact storage costs grow | Low | Low | tens of MB per version; retain the last N and every released version |
| R9 | Checksum pinning makes routine updates painful | Low | Medium | one constant, one manifest, both already required to move together |
| R10 | Design adopted partially — storage moved, gate never built | **High** | **Medium** | the gate is the point; without layer 3 this is filing rather than architecture |

R4 and R10 are the two that actually kill designs like this. Both are
process risks, not technical ones.

---

## 6. Maintenance strategy

| Cadence | Activity | Owner |
|---|---|---|
| **Per app build** | pull pinned artifact, verify checksum | CI, automatic |
| **Per content change** | acquire → manifest → verify → build → publish | publisher |
| **Quarterly** | run the data pipeline unchanged, confirm it still works (R4) | publisher |
| **Quarterly** | re-check upstream terms; several have changed silently before | publisher |
| **Annually** | rotate build credentials; confirm keystore backup opens | publisher |
| **Annually** | review manifests whose `permission.expires` approaches | publisher |
| **On new corpus** | manifest first, import second — never the reverse | publisher |

Two standing rules worth stating plainly:

**Never import before the manifest exists.** The manifest is where the
licence question gets asked. Importing first and documenting later is
exactly how the current situation arose — two corpora were imported in
Sprints 31.3 and 31.4, and the copyright was discovered in Sprint 38.

**Archive on acquisition.** The moment a dataset is downloaded it goes
to private storage with its manifest, whether or not it will be used.
Upstreams disappear; the cost of storing a few MB is nil against the
cost of an unrebuildable release.

---

## 7. Recommended workflow

**Adding a content source**

```
1. Acquire            fetch the dataset; keep the exact upstream URL and date
2. Verify licence     locate written terms; identify the actual rights holder
                      → write dataset.manifest.json
                      → GATE: permission "not-requested"/"refused" stops here
3. Archive            upload payload + manifest to private storage
4. Register           add an import_* function; register it against the manifest id
5. Build              data pipeline: resolve → verify → build → validate
6. Publish            immutable artifact quran-<DATA_VERSION>.sqlite + sha256
7. Pin                bump DatabaseConstants.expectedDataVersion to match
8. Test               full suite against the new artifact
9. Ship               app build consumes the pinned artifact
```

Step 2 is where this project has historically gone wrong, and it is the
only step that cannot be automated. Everything after it can.

**Routine app development** — unchanged from today. Clone, `flutter pub
get`, `flutter test`. The database arrives from the pinned artifact
(tier 1) or the public profile (tier 0). No developer builds content by
hand.

---

## 8. Migration plan

Four stages. Stage 0 is urgent; the rest are not.

| Stage | Action | Effort | Reversible |
|---|---|---|---|
| **0 · Stop the bleeding** | remove the Ibn Kathir corpus, rebuild, bump `DATA_VERSION` 6→7 | ~1 h | yes |
| **1 · Storage** | private bucket; upload every current dataset with a manifest; add the CI fetch step; keep the committed database in place | 1 day | yes |
| **2 · Cut over** | `.gitignore` the database and restricted inputs; remove from HEAD; **add the layer-3 CI gate**; `--profile=public` for tier 0 | 1 day | yes at HEAD; history retains the blobs |
| **3 · Separate the pipelines** | dedicated data workflow producing versioned artifacts; app CI consumes by pin | 1–2 days | yes |

Stage 2 is where the value lands — before it, the design is preparation;
after it, the exposure is structurally impossible.

**What migration does not do:** it does not remove existing blobs from
git history. They stay reachable by commit SHA. That is accepted, in
combination with a sent permission request. Escalate to `git filter-repo`
only if a rights holder objects — it rewrites every SHA the ADRs and
sprint reports reference by name, and that cost is only worth paying
under pressure.

**Order matters.** Stage 0 without the rest declares victory over a
symptom. Stages 1–3 without stage 0 leave a confirmed infringement live
while building infrastructure. Do stage 0 today.

---

## 9. Long-term recommendation

**Adopt the design. Sequence it 0 → 2 → 1 → 3. Treat the CI gate as the
deliverable.**

The measure of success is not that the content moved. It is that in 2031
someone imports the eleventh corpus, forgets everything in this document,
tries to commit it, and **the build stops them**.

Three things make that likely here, and they are already true:

- The application layer needs **no change**. `pubspec.yaml` names an
  asset path; Dart cannot observe where the file came from. Not one line
  under `lib/`, no schema change, `PROJ-P-002` not engaged.
- The pipeline is **already half-built**. Three of six sources are
  fetched rather than committed; the importer contract is documented;
  pre- and post-build validators exist for the lexicon path.
- The team's strongest habit is **turning rules into failing tests**,
  and it has proven three of them load-bearing by deliberately breaking
  the code. The content boundary is the same kind of rule.

The failure mode to guard against is not technical. It is adopting the
storage change, feeling finished, and never building the gate — leaving
a design that depends on memory, which is the thing it was meant to
replace.

**And the standing caveat from `DR-2026-0008` still holds:** no supply
chain makes unlicensed content lawful. This architecture guarantees that
the repository never distributes what it may not. Whether the *app* may
ship a given text is answered by a rights holder, not by a pipeline.
