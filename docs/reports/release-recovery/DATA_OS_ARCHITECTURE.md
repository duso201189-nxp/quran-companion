# Data OS architecture

**Status: design only.** No code, configuration or data changed. This
elevates [`DATA_SUPPLY_CHAIN.md`](DATA_SUPPLY_CHAIN.md) (one pipeline,
one consumer) to a platform serving several consumers, and is governed
by [`ARCHITECTURE_DECISION_RECORD.md`](ARCHITECTURE_DECISION_RECORD.md).

Read §9 first if you only read one section. It is the part that decides
whether this document helps or harms.

---

## 1. What problem a Data OS actually solves

Not "we have a lot of data". The problem is that **the same body of
content must reach several consumers under different rights, and no
single person can hold that matrix in their head.**

Today one application ships six content sources. Their rights differ in
ways that already matter:

| Source | May be embedded in a free app | May be published as a file | May be used commercially |
|---|---|---|---|
| Tanzil Arabic | yes | yes, verbatim | not addressed |
| Saheeh Int'l | yes | yes, non-commercially | **no** |
| QuranEnc Vietnamese | yes | conditional | not stated |
| Transliteration | unknown | unknown | unknown |
| Al-Muyassar | unknown | unknown | unknown |
| **Ibn Kathir abridged** | **pending** | **no** | **no** |

Add a second consumer and the matrix doubles. Add a server-side AI
agent — which *uses* text without *distributing* it — and a third
column appears whose answer differs from both existing ones. Add a
dashboard that shows aggregate counts and no text at all, and a fourth.

**A Data OS is the mechanism that answers "may this consumer use this
content through this channel" without a human recalling six licence
documents.** Everything else here — registries, artifacts, pipelines —
exists to make that question answerable by a machine.

### The lesson this project already paid for

Ibn Kathir proved that **rights are layered, not flat**. The 14th-century
Arabic original is public domain. The English abridgement commissioned by
Darussalam in 2000 is not. A single `license: "..."` string on a dataset
cannot express that, and because it could not, the wrong answer shipped.

Any model that flattens rights to one field will make the same mistake
again. That constraint shapes the design below more than anything else.

---

## 2. Layer map

```
┌──────────────────────────────────────────────────────────────────────┐
│  CONSUMERS                                                            │
│                                                                       │
│  Qur'an Companion   NurVerse¹    AI agents     Dashboard    Website    │
│  (mobile, bundled)  (mobile)     (server)      (aggregate)  (public)   │
│        │               │            │             │            │      │
│        └───────────────┴────────────┴─────────────┴────────────┘      │
│                    each declares a CONSUMER MANIFEST                   │
│                    { domains, channel, commercial }                    │
└───────────────────────────────┬──────────────────────────────────────┘
                                │ resolution: envelope ⊇ declaration?
                                ▼
┌──────────────────────────────────────────────────────────────────────┐
│  ④ ARTIFACT REGISTRY          immutable, content-addressed            │
│     quran.sqlite@7        inputs[] · checksum · verification ·         │
│     quran-public.sqlite@7  LICENCE ENVELOPE = ⋂ of input grants       │
│     surahs.json@7          (an artifact is only as free as its most    │
│     embeddings.pack@3       restricted input)                          │
└───────────────────────────────▲──────────────────────────────────────┘
                                │ publish (only if verification passed)
┌───────────────────────────────┴──────────────────────────────────────┐
│  ③ VERIFICATION PIPELINE      structural · semantic · provenance ·    │
│                               LICENCE. Emits a signed report.          │
├──────────────────────────────────────────────────────────────────────┤
│  ② DATA PIPELINE              acquire → gate → archive → build         │
│                               deterministic · idempotent · rare        │
└───────────────────────────────▲──────────────────────────────────────┘
                                │ reads
        ┌───────────────────────┴───────────────────────┐
        ▼                                               ▼
┌───────────────────────────────┐   ┌──────────────────────────────────┐
│  ① DATA REGISTRY              │   │  ⓪ LICENCE REGISTRY              │
│  what exists, from where      │   │  what is permitted, to whom      │
│                               │   │                                  │
│  dataset id · version ·       │   │  work → edition → GRANT          │
│  provenance · checksum ·      │──▶│  three-valued: allow/deny/unknown│
│  shape contract · licence ref │   │  evidence · scope · expiry       │
└───────────────────────────────┘   └──────────────────────────────────┘
                ▲                                     ▲
                └──────────── PRIVATE STORAGE ────────┘
                       payloads never enter a public repo

¹ NurVerse is named as a future consumer; its requirements are not yet
  known. Nothing here is designed for it specifically — see §9.
```

---

## 3. Responsibilities

Each layer owns exactly one question. If two layers can answer the same
question, one of them is wrong.

### ⓪ Licence Registry — *what is permitted?*

The only authority on rights. Deliberately separate from the Data
Registry, for two reasons this project has already hit: one licence
governs several datasets (Tanzil's terms cover the Arabic text and its
translations **differently**), and one dataset carries several layers of
rights.

**Model: work → edition → grant.**

```
work:    "Tafsir Ibn Kathir"        public domain (d. 1373)
  edition: "English abridged, Darussalam 2003, ISBN 9960-892-71-9"
             rights_holder: Maktaba Dar-us-Salam
             grant:
               embed_in_app:      unknown     ← requested, no reply
               redistribute_file: deny
               commercial:        unknown
               modify:            deny
               evidence:          legal/OUTREACH.md#1  (sent YYYY-MM-DD)
               expires:           null
               review_by:         2027-01-26
```

Two properties are non-negotiable:

**Three-valued logic.** `allow` / `deny` / **`unknown`**. At every gate,
`unknown` behaves as `deny`. This project's entire licensing crisis was
`unknown` being treated as `allow` for four sprints — not through
carelessness, but because there was nowhere to record "we don't know".

**Evidence, not opinion.** A grant records *where the permission came
from*: a URL, an email, a PDF. "We think it's fine" is not a grant. A
grant with `status: granted` and `evidence: null` is invalid and must
fail validation.

### ① Data Registry — *what exists, and where did it come from?*

| Field | Purpose |
|---|---|
| `id` | stable, e.g. `tafsir.ibn-kathir.en.abridged` |
| `version` | immutable; corrections create a new version, never mutate |
| `domain` | `quran` · `hadith` · `lexicon` · `derived` |
| `provenance` | exact upstream URL + acquisition date |
| `checksum` | sha256 of the payload |
| `shape` | schema contract the payload satisfies |
| `licence_ref` | pointer into ⓪ — **a reference, never a copy** |

The pointer matters. If licence text were copied into dataset records,
a granted permission would have to be edited in N places. One source of
truth, N references.

### ② Data Pipeline — *turn registered inputs into candidate artifacts*

Deterministic and idempotent: same inputs, same builder version, same
bytes out. Runs rarely and deliberately — it is not part of an app
build. Detailed in `DATA_SUPPLY_CHAIN.md` §4.1.

### ③ Verification Pipeline — *is this artifact fit to exist?*

Separate from the build on purpose. The build's job is to produce;
verification's job is to refuse. Four classes:

| Class | Asks | Example from today's codebase |
|---|---|---|
| **Structural** | is the shape right? | 114 surahs, 6,236 ayahs — `validate()` already does this |
| **Semantic** | is the content right? | every ayah resolves commentary; no empty text; search index non-empty |
| **Provenance** | did it come from what we think? | artifact checksum ↔ registry; input versions ↔ manifest |
| **Licence** | may it exist at all, and where? | envelope computed and non-empty for at least one channel |

Output is a **verification report**, signed and attached to the
artifact. Consumers check the report; they never re-verify the data.
That is what makes "build once, consume many" safe rather than merely
convenient.

### ④ Artifact Registry — *what is consumable, and under what rights?*

An artifact is an immutable, content-addressed, consumable output.

```
artifact: quran.sqlite@7
  schema:        3
  inputs:        [tanzil.arabic@2026-07, quranenc.vi@1.0.8,
                  tanzil.saheeh@2026-07, quran-com.translit@2026-07,
                  kfgqpc.muyassar@2026-07]
  builder:       build_quran_db.py@a1b2c3
  sha256:        …
  verification:  report-7.json (passed)
  envelope:                       ← the mechanism that makes this safe
    embed_in_app:      allow      (all inputs allow)
    redistribute_file: deny       (Saheeh Int'l: non-commercial only)
    commercial:        deny       (Saheeh Int'l: deny)
```

**The licence envelope is the intersection of all input grants.** An
artifact is only as free as its most restricted input. This is computed,
never asserted, and it is what lets one build serve many consumers
without a human reasoning about the combination.

Note what it says about today's database: because Saheeh International
is non-commercial-only, the *entire* artifact is non-commercial — which
is exactly what `PROJ-P-005` concluded by hand, three sprints ago. The
mechanism reproduces the human answer, then keeps reproducing it
forever.

### ⑤ Consumer Layer — *what may I have?*

Each consumer declares its needs; it does not choose its artifact.

```
consumer: quran-companion
  channel:     bundled-in-app
  commercial:  false
  domains:     [quran]
  → resolves to: quran.sqlite@7           (envelope.embed_in_app = allow)

consumer: website
  channel:     public-file
  commercial:  false
  domains:     [quran.metadata]
  → resolves to: surahs.json@7            (only inputs permitting
                                           file redistribution)

consumer: ai-agent
  channel:     server-side-use
  commercial:  false
  domains:     [quran, tafsir]
  → resolves to: quran.sqlite@7, never redistributed
                 (use ≠ distribution — a distinct grant)

consumer: dashboard
  channel:     aggregate-only
  domains:     [quran.stats]
  → resolves to: counts, no text — no content grant needed
```

Resolution runs at **build time** and fails loudly. A consumer whose
declaration exceeds the envelope does not get a warning; it gets a
broken build.

---

## 4. How every application consumes the same verified artifact

The direct answer, then the refinement that matters.

**The mechanism.** Data is built once, verified once, published once as
an immutable artifact addressed by version and checksum. Every consumer
pins `(artifact-id, version, sha256)`, downloads, verifies the checksum,
and proceeds. No consumer builds data. No consumer re-verifies content.
Two consumers pinning the same version are guaranteed byte-identical
input, because the artifact cannot change — a correction produces
version 8, never a new version 7.

```
        quran.sqlite@7  ─── sha256 ───┐
                                       │
   Qur'an Companion  ──pin──┐          │
   NurVerse          ──pin──┤          │
   AI agent          ──pin──┼──────────┘   one build · one verification
   Dashboard         ──pin──┤              N consumers · zero rebuilds
   Website           ──pin──┘
```

**The refinement.** They should not *all* receive the same bytes — and
insisting on it would be the bug, not the feature.

The website publishes files to the open internet. The app embeds content
in a signed binary. Those are different channels with different grants.
Handing the website the same artifact the app bundles would republish
Saheeh International as a downloadable file, which its licence forbids.

So the correct statement is: **one registry, one verification, many
artifacts derived from the same verified inputs.** The public JSON the
website consumes is *built in the same run*, from the same registered
datasets, verified by the same pipeline, and carries a wider envelope
because it contains only inputs that permit file redistribution.

No consumer rebuilds data. No consumer receives content it may not have.
Both properties come from the same mechanism.

---

## 5. Trust model

| # | Boundary | Crosses | Enforced by |
|---|---|---|---|
| T1 | upstream → publisher | payload + licence evidence | human judgement, recorded as a grant |
| T2 | publisher → registries | dataset + licence records | write access, publisher only |
| T3 | registries → pipeline | payloads, read-only | scoped short-lived credentials |
| T4 | **pipeline → public repository** | **nothing** | CI gate: no restricted path tracked |
| T5 | pipeline → artifact registry | artifact + signed verification report | verification must pass |
| T6 | **artifact → consumer** | artifact permitted by envelope | build-time resolution; checksum pin |
| T7 | consumer → end user | content inside a signed binary or a permitted file | store review; in-app attribution |

T4 and T6 are the two that do work no human process can do reliably.
T4 makes accidental publication impossible; T6 makes accidental
*re*-publication by a second consumer impossible. Everything else is
plumbing.

**Threat model, stated plainly.** This design defends against mistakes,
not adversaries. It assumes the publisher is honest and the CI provider
is not hostile. Against a determined insider it offers nothing — nor
should it try. The realistic failure is somebody adding a dataset in a
hurry in 2029 and forgetting a rule they never read.

---

## 6. Versioning

Today one integer, `DATA_VERSION`, carries three unrelated meanings.
That conflation is a latent defect: adding a corpus and changing a table
both bump the same number, so the app cannot distinguish "new content"
from "new shape".

**Three independent axes:**

| Axis | Changes when | Who cares | Breaks what |
|---|---|---|---|
| **Schema version** | table shape changes | application code | requires an app release |
| **Artifact version** | content changes, shape does not | data pipeline | content update only |
| **Dataset version** | one input changes | provenance | recorded, not user-visible |

```
quran.sqlite@7 (schema 3)
   ├── tanzil.arabic@2026-07
   ├── quranenc.vi@1.0.8
   └── kfgqpc.muyassar@2026-07
```

An app pins **both** schema (compatibility: "I understand shape 3") and
artifact (exactness: "give me version 7, sha256 …"). Adding a corpus
bumps the artifact; adding a column bumps the schema and forces an app
release. Today both would look identical.

**Rules:**

- Artifacts and dataset versions are **immutable**. Corrections create a
  successor. Never mutate a published version — some consumer has it
  pinned.
- Schema versions are **monotonic** and the app declares a supported
  range, not a point.
- Every artifact records the exact input versions and builder revision,
  so any release is reproducible years later. That is what makes the
  private store an archive rather than a cache.
- Retain every version ever shipped. Tens of MB is nothing against an
  unreproducible release.

---

## 7. Scalability over ten years

The honest scaling question is not throughput. Volumes here are trivial
— tens of megabytes, a handful of builds a year. It is **whether the
mechanism still works when nobody remembers why it exists.**

| Dimension | 2026 | 2036 | Breaks at |
|---|---|---|---|
| Datasets | 6 | 30–60 | nothing structural |
| Domains | 1 (quran) | 4–5 (+hadith, lexicon, derived) | one DB per domain, already the design |
| Consumers | 1 app + 1 site | 5–8 | resolution stays O(consumers) |
| Licences | 6 | 30+ | **hand-tracking breaks at ~10** |
| Artifact size | 32.7 MB | 100–300 MB | bundling breaks ~150 MB → on-demand delivery |
| Registry storage | files | files | ~50 datasets or a second writer |

**Registry as files, not a service.** Start with JSON/YAML in a private
repository: reviewable, diffable, versioned, zero operations. A registry
*service* is a system to run, monitor, back up and secure — operations
this project does not have and should not acquire to hold sixty small
records.

Migrate only on a named trigger: **a second person needs write access**,
or **a consumer needs runtime resolution** rather than build-time. Until
one of those is true, a service is cost without benefit.

**What genuinely breaks first:** licence tracking by hand, at roughly
ten sources. That is the argument for building ⓪ early even though it
looks like the most abstract layer — it is the one whose absence already
caused an incident.

---

## 8. Migration path

Stages 0–3 come from `DATA_SUPPLY_CHAIN.md` §8 and are unchanged. This
adds 4–6, each gated on a trigger rather than a date.

| Stage | Adds | Effort | Trigger |
|---|---|---|---|
| **0** | remove the encumbered corpus, rebuild | ~1 h | **now** |
| **1** | private storage + manifests + CI fetch | 1 d | now |
| **2** | gitignore, remove from HEAD, **CI boundary gate**, public profile | 1 d | now |
| **3** | separate data pipeline; versioned artifacts | 1–2 d | now |
| **4** | **Licence Registry** — grants, evidence, three-valued | 1–2 d | **≥ 8 sources, or first permission granted** |
| **5** | **Envelope computation + consumer manifests** | 2–3 d | **second consumer exists** |
| **6** | Registry service; runtime resolution | weeks | second writer, or runtime need |

Stages 0–3 are the current problem. **Stage 4 is the current lesson** —
it is the layer whose absence caused the Ibn Kathir incident, and it is
worth building slightly ahead of strict need. Stages 5–6 are speculation
until a second consumer is real.

**Nothing in stages 0–5 requires an application-code change.**
`pubspec.yaml` names an asset path; Dart cannot observe how the file
arrived. No schema change, `PROJ-P-002` not engaged.

---

## 9. The honest assessment

A Chief Platform Architect who does not write this section is not doing
the job.

**Six consumers were named. One exists.** There is one shipping
application, one static website, one maintainer, and roughly 17 MB of
source data. NurVerse, AI agents and the dashboard are intentions. A
platform designed for six consumers when one exists is the most common
way ambitious projects die — not from bad design, but from spending the
year building the platform instead of the product.

**And this project has already learned that lesson twice.**
`DR-2026-0006` D4 refused to build a Tafsir loader before a Tafsir
surface existed: *"a provider without a consumer is speculation."*
`DR-2026-0007` D5 refused a `StudyRepository` that nothing needed.
Sprint 32.0 rejected a schema change on measurement rather than
prediction. Every one of those refusals was right.

The same discipline applies here. So:

**Build now — because the absence already cost something:**

- Stages 0–3. Not platform work; it is stopping an active exposure.
- **Stage 4, the Licence Registry.** Small, file-based, and it is the
  precise thing whose absence let an in-copyright corpus ship for five
  sprints. Grants with evidence and three-valued logic would have made
  Ibn Kathir a build failure in Sprint 31.4 rather than a discovery in
  Sprint 38.

**Design now, build later:**

- Envelope computation. The *concept* should shape stage 4's record
  format so it is derivable later. The *code* waits for consumer #2.
- Consumer manifests. One consumer's manifest is a constant.

**Do not build until it is real:**

- A registry service. Files until a second writer or a runtime need.
- Anything designed for NurVerse. Its requirements are unknown;
  designing for an unspecified consumer produces abstractions that fit
  nothing. Capture what it needs, then design.

**The measure of success** is not that a Data OS exists. It is that
in 2031 somebody adds a corpus in a hurry, has never read this document,
and the build refuses because the grant says `unknown`.

That outcome needs stage 4 and the stage-2 CI gate. It does not need
stages 5 or 6. Build the two layers that fail loudly; leave the rest as
a shape the design can grow into.

---

## 10. Recommendation

**Adopt the model. Implement stages 0–4. Treat 5–6 as designed but
unbuilt.**

| Priority | Action | Why now |
|---|---|---|
| 1 | Stage 0 — remove the encumbered corpus | an active exposure |
| 2 | **Send the four enquiries** | unsent for five sprints; nothing here substitutes for it |
| 3 | Stage 2 — the CI boundary gate | makes recurrence structurally impossible |
| 4 | Stages 1, 3 — storage and pipeline separation | completes an already half-built design |
| 5 | Stage 4 — the Licence Registry | the layer whose absence caused the incident |
| — | Stages 5–6 | **wait for a second consumer** |

Two constraints outrank every diagram above.

**No architecture makes unlicensed content lawful.** This platform can
guarantee that content never leaves a boundary it may not cross. It
cannot decide whether the app may ship a given text. Only a rights
holder does that.

**The most valuable artifact in this design is not a registry. It is a
grant record containing real evidence** — and the first one cannot be
written until somebody sends the email.
