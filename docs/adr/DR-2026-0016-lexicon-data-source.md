---
id: DR-2026-0016
scope: project
owner_role: constitution-owner
date: 2026-08-01
deciders: []
status: proposed
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [legal-exposure, materially-different-approaches, unblocks-a-release-blocker]
links:
  task: "Release Governance Recovery sprint — Lexicon licensing blocker"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0016 — Lexicon morphology data source

**Status of this record: proposed, not accepted.** It states a
recommendation and the evidence behind it; acceptance is the
`owner_role`'s call. No production code has been changed, no dataset
has been downloaded. Same posture as `DR-2026-0014` and `DR-2026-0015`.

`owner_role` is **constitution-owner** rather than data-owner or
release-owner because the governing question is licence exposure, which
`PROJECT_CONSTITUTION.md` reserves (`PROJ-P-005`, monetisation/
licensing). The data-owner and release-owner are both materially
affected and should co-sign.

## Relationship to existing records

No prior Decision Record covers Lexicon data sourcing. The
investigation that produced the current blocker lives in code comments
(`tool/fetch_morphology.py`, `tool/build_quran_db.py:364-373`) and in
Sprint 12 Phase 2.6/2.7/3 working notes, never as a governed decision.
This record is the first. It amends nothing.

## Context

The Lexicon feature (F1) and Flashcards (F2, which depends on it) are
fully built in Dart and fully non-functional on a real install: all 8
Lexicon tables ship with **0 rows**. `RELEASE_DASHBOARD.md` lists this
as the top Critical v1.0 blocker and Definition-of-Done item 1.

The release documents describe the cause as unscoped data sourcing —
*"No source document specifies where real lemma/word-instance data
comes from"*. That is incorrect. See
`docs/release/RELEASE_GOVERNANCE_AUDIT.md` §3. The repository contains
2,140 lines of purpose-built, unit-tested Lexicon pipeline; the source
is identified; the blocker is a licence conflict.

## Problem

The intended source, the Quranic Arabic Corpus (QAC v0.4), carries a
self-contradictory licence. The project's own investigation recorded it
verbatim from the data file header:

> `# Permission is granted to copy and distribute verbatim copies of`
> `# this file, but CHANGING IT IS NOT ALLOWED.`

QAC is nominally distributed under GPL — which permits derivative
works — while its data header forbids modification. Independent
confirmation: the corpus (Kais Dukes, v0.4) is widely documented as
GPL-licensed with exactly this restrictive data-file clause.

The pipeline **cannot** consume this data without transforming it:
`normalizer.py` folds segments into `WordInstance` records and derives
`Lexeme` entities before `sqlite_writer.py` persists them. That is
precisely the "changing" the header forbids, under the only reading a
release should rely on.

A secondary barrier: QAC's download is gated behind a JavaScript form
requiring a real email address. `fetch_morphology.py` deliberately
declines to automate acceptance of licence terms on a user's behalf —
correct, and unchanged by this record.

## Options evaluated

### Option A — Proceed with QAC on a favourable licence reading

Argue that loading data into an application database is *use*, not
*changing the file*.

- **Pro**: zero source-migration work; the existing parser targets this
  format.
- **Con**: bets a store submission on a contested reading of a
  contradictory licence. The project already carries one unresolved
  licence exposure (Tanzil translations are non-commercial, blocking
  monetisation per `PROJ-P-005`). Adding a second, on data that would
  be embedded in a shipped binary, compounds a risk class that
  `RELEASE_DASHBOARD.md` §6 already names as *binary, not gradable*.
- **Verdict: reject.**

### Option B — QAC v2 (`kaisdukes/quranic-corpus`, GPL-3.0)

The original author's newer corpus, unambiguously GPL-3.0.

- **Pro**: resolves the contradiction; derivatives clearly permitted.
- **Con**: GPL-3.0 is copyleft. Embedding GPL-derived data in a
  proprietary app-store binary raises obligations this project has no
  reason to take on and no counsel to evaluate. Its POS tagging is
  AI-generated with community verification — a quality profile that
  would itself need assessment.
- **Verdict: reject** — trades a licence contradiction for a licence
  obligation.

### Option C — MASAQ (CC BY 4.0) — **recommended**

*Morphologically-Analyzed and Syntactically-Annotated Quran*, Sawalha,
Yagi, Alshargi, Hammo & Alshdaifat (University of Jordan), published in
*Data in Brief*, hosted on Mendeley Data (`10.17632/9yvrzxktmr`).

- 131K morphological + 123K syntactic entries, full Quran coverage.
- Expert-verified using traditional i'rab methodology; 72-role tagset.
- Distributed in TSV / CSV / JSON / XML.
- **CC BY 4.0** — explicitly permits remixing, transforming and
  building upon the material, *for any purpose, including commercially*,
  with attribution.
- **Pro**: resolves the transformation conflict outright, and removes
  one leg of the `PROJ-P-005` monetisation blocker at the same time.
  Attribution is a requirement the project already satisfies routinely
  (`translation_sources` / `meta` tables, per `docs/DATA_PIPELINE.md`).
- **Con**: format differs from QAC; requires a new parser. Its exact
  columns, root/lemma availability and tagset mapping are **unverified**
  — see Risks.
- **Verdict: adopt, subject to format validation.**

### Option D — Defer Lexicon and Flashcards from v1.0

Ship without them; record the deferral formally.

- **Pro**: unblocks v1.0 immediately and honestly; strictly better than
  shipping a feature backed by empty tables.
- **Con**: writes off 2,140 lines of built pipeline and two feature
  verticals before the cheapest alternative has been attempted.
- **Verdict: hold as the fallback**, to be exercised only if Option C
  fails validation.

## Decision

1. **Adopt MASAQ (CC BY 4.0) as the Lexicon morphology source**,
   replacing QAC.
2. **Gate adoption on format validation.** The first task of the
   implementation sprint is to acquire the dataset, inspect its actual
   schema, and confirm it exposes per-segment location, surface form,
   POS tag, **root** and **lemma**. If it does not, Option D applies.
3. **Acquisition is the owner's action, not an automated one** — the
   dataset is downloaded by a human who reads and accepts its terms,
   consistent with the posture `fetch_morphology.py` already takes.
4. **Do not modify `segment_parser.py`.** Add a sibling
   `masaq_parser.py` emitting the same `Segment` dataclass. The
   existing parser stays as the QAC-format reference and keeps its
   tests.
5. **Record attribution** in `translation_sources`/`meta` and
   `docs/DATA_PIPELINE.md`'s licence table, as CC BY 4.0 requires.

## Why this is architecturally cheap

The pipeline already isolates source-specific parsing behind a clean
seam:

```
<source file> → segment_parser.py → Segment   ← only this is source-specific
                normalizer.py     → NormalizedRecords
                sqlite_writer.py  → 8 tables
```

`normalizer.py` (339 lines) consumes `Segment`; `sqlite_writer.py`
(125) consumes `NormalizedRecords`. Neither references QAC. Swapping
sources means writing one parser against an already-defined output
contract — roughly 150 lines plus tests, against ~1,000 lines of
downstream logic that does not change.

## Risks

- **MASAQ's format is unverified.** It will not match
  `LOCATION⇥FORM⇥TAG⇥FEATURES`. Mitigation: validation gates the sprint
  (Decision 2).
- **Root/lemma availability is unconfirmed.** `normalizer.py` requires
  both to populate `roots`/`lemmas`. If MASAQ supplies i'rab syntax but
  not derivational roots, it is not a drop-in replacement and Option D
  applies. **This is the single assumption most likely to break the
  plan.**
- **The pipeline has never processed real data.**
  `segment_parser.py`'s own docstring records that its format was
  reconstructed from public documentation and *"CHƯA được kiểm chứng
  trên file thật"* — never verified against a real file. Unit tests run
  against synthetic fixtures only. Expect first-contact defects in
  `normalizer.py` regardless of source.
- **Tagset mismatch.** MASAQ's 72 syntactic roles are a different
  scheme from QAC's POS tags; `classify_flag`/`_fold_non_head` in
  `normalizer.py` will need mapping work.
- **Asset size.** 131K morphological entries will grow
  `assets/database/quran.sqlite`. Bundle-size impact is unmeasured; CI
  already reports APK and web bundle sizes, so a regression would be
  visible but is not currently budgeted for.

## Consequences

- v1.0 Definition-of-Done item 1 and Go/No-Go box 1 become closable —
  by implementation if validation passes, by documented deferral if not.
- Flashcards (F2) becomes functional on a real install for the first
  time.
- `docs/DATA_PIPELINE.md` gains a fourth licence row; attribution
  obligations grow by one source.
- `RELEASE_DASHBOARD.md` §6's "single largest unknown" risk is retired
  and replaced by a narrower, testable one (does MASAQ carry roots and
  lemmas?).
- If validation fails, this record is superseded by a deferral DR
  rather than silently abandoned.

## Measure of success

All 8 Lexicon tables populated in the shipped asset; `pre_build_validator`
and `post_build_validator` pass on real data; Lexicon and Flashcards
verified working on a fresh install; attribution recorded; CI bundle-size
report reviewed and accepted.

## References

- `docs/release/RELEASE_GOVERNANCE_AUDIT.md` §3–§4
- `tool/fetch_morphology.py`, `tool/build_quran_db.py:364-373`
- `tool/lexicon/{segment_parser,normalizer,sqlite_writer}.py`
- `docs/DATA_PIPELINE.md` — source/licence table
- MASAQ dataset: https://data.mendeley.com/datasets/9yvrzxktmr
- MASAQ paper: https://www.sciencedirect.com/science/article/pii/S2352340924011739
- QAC download/licence: https://corpus.quran.com/download/
- QAC v2: https://github.com/kaisdukes/quranic-corpus
