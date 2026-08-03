# MASAQ Acceptance Report — Phase 3 Dataset Acceptance

Dataset acquired, hash-verified, and inspected byte-by-byte. No
production code, parser, build script, release document, or commit was
touched. The dataset file was written to the session scratchpad only —
**nothing was added to the repository.**

---

## 0. Headline

**REJECT.** Two independent disqualifying findings, either sufficient on
its own:

1. **MASAQ contains no Root column and no Lemma column.** Neither exists
   in the TSV, nor as a separate table in the SQLite distribution. The
   published descriptions that claimed otherwise are wrong.
2. **The current version's licence is CC BY-NC 3.0**, not CC BY 4.0.

Finding 1 is fatal to the pipeline contract regardless of licence.

**This report corrects two errors in my own prior deliverables**
(`LEXICON_DATASET_VALIDATION.md` and `DR-2026-0016`), both of which
relied on published dataset descriptions rather than the data. See §6.

## 1. Acquisition record

| | |
|---|---|
| Source | Mendeley Data, `10.17632/9yvrzxktmr` |
| File | `MASAQ.tsv` |
| Size | 18,650,409 bytes |
| SHA-256 | `aac224f1b852a1a87e5a896b76c4b55df7c29369a7da836aea1b7286a9c3a931` |
| Verified | ✅ matches the publisher's manifest hash exactly |
| Retrieved via | `data.mendeley.com/public-api/datasets/9yvrzxktmr/files?folder_id=root&version=5` → `download_url` |

Also range-fetched the first 2 MB of `MASAQ.db` to read its SQLite
schema (§4.3).

**A caution for anyone repeating this:** the endpoint
`data.mendeley.com/api/datasets/{id}/versions/{n}/files` returns
**HTTP 200 with an entirely unrelated dataset** (a paleomagnetic study
of Miocene volcanics in Sonora, Mexico). It silently ignores the dataset
id. Only the `public-api/.../files?folder_id=root&version=N` form
resolves correctly. Verify by SHA-256 against the manifest, as done here.

## 2. Licence finding

| Version | Published | Licence | Data |
|---|---|---|---|
| v5 | 12 Nov 2024 | **CC BY 4.0** | — |
| **v6 (latest)** | 10 Dec 2024 | **CC BY NC 3.0** | — |

All four files are **byte-identical between v5 and v6**, confirmed by
SHA-256 across `MASAQ.csv`, `MASAQ.db`, `MASAQ.json`, `MASAQ.tsv`:

```
MASAQ.csv  18650409  777d0cc8f24f4c17   (v5 == v6)
MASAQ.db   59199488  2dd121cd19ddbbf6   (v5 == v6)
MASAQ.json 98447745  cfd55ac85991851d   (v5 == v6)
MASAQ.tsv  18650409  aac224f1b852a1a8   (v5 == v6)
```

**v6 is a licence-only revision.** Same bytes, more restrictive terms.
The rights holders deliberately moved from permissive to NonCommercial
one month after publication.

Consequences had the data been otherwise suitable:

- Relying on v5's CC BY 4.0 is legally defensible — a granted CC licence
  is irrevocable for that version — but it means **pinning forever to a
  version the authors have since restricted**, against their evident
  current intent. That is a poor foundation for a shipped product.
- The paper states CC BY 3.0; the Mendeley v5 record states CC BY 4.0;
  the v6 record states CC BY-NC 3.0. **Three different licence strings
  for one dataset.** Any use would require pinning version, licence text,
  and retrieval date at acquisition — never citing the paper's statement.

## 3. Real schema — 19 columns

Published descriptions say "20 columns". **The actual file has 19.**

```
 0  ID                      10  Punctuation_Mark
 1  Sura_No                 11  Invariable_Declinable
 2  Verse_No                12  Syntactic_Role
 3  Word_No                 13  Possessive_Construct
 4  Segment_No              14  Case_Mood
 5  Word                    15  Case_Mood_Marker
 6  Without_Diacritics      16  Phrase
 7  Segmented_Word          17  Phrasal_Function
 8  Morph_Tag               18  Gloss
 9  Morph_Type
```

Sample row (Q1:1, word 1, segment 2 — the stem of بِسْمِ):

```
Sura_No=1  Verse_No=1  Word_No=1  Segment_No=2
Word='بِسْمِ'   Without_Diacritics='بسم'   Segmented_Word='اسم'
Morph_Tag='NOUN_ABSTRACT'   Morph_Type='Stem'
Syntactic_Role='PREP_OBJ'   Case_Mood='GENITIVE'   Case_Mood_Marker='KASRA'
Gloss='in-(the)-name'
```

**There is no Root column. There is no Lemma column.** A search of all
19 headers for `root`, `lemma`, `lex`, `base`, `asl`, `jidr` returns
nothing.

## 4. Measurements

### 4.1 Scale

| Metric | Value |
|---|---|
| Data rows (segments) | **157,676** |
| Malformed rows | **0** |
| Distinct words | 77,411 |
| Distinct suras | **114** (complete Quran ✅) |

Row count exceeds the published "131K morphological entries" claim —
another figure that does not match the file.

### 4.2 Required-field coverage vs the pipeline contract

Contract derived from `tool/lexicon/normalizer.py` (see
`LEXICON_DATASET_VALIDATION.md` §1):

| Requirement | Required by | MASAQ coverage | Verdict |
|---|---|---|---|
| Sura / Verse / Word / Segment | Hard | **100.00%** | ✅ |
| Surface form | Hard | **100.00%** (`Word`, `Without_Diacritics`, `Segmented_Word`) | ✅ |
| Segmentation role | Hard | **100.00%** (`Morph_Type`) | ✅ |
| POS | Hard | **99.95%** (`Morph_Tag`) | ✅ |
| **Root** | Conditional-hard | **0.00% — column absent** | ❌ **FATAL** |
| **Lemma** | Conditional-hard | **0.00% — column absent** | ❌ **FATAL** |
| Morph feature flags | Soft | Fused into `Morph_Tag`, not separable | ⚠️ |

Full per-column non-empty coverage:

```
ID/Sura_No/Verse_No/Word_No/Segment_No  100.00%
Word / Without_Diacritics / Segmented_Word  100.00%
Morph_Tag                99.95%      Gloss                  100.00%
Morph_Type              100.00%      Invariable_Declinable   84.45%
Possessive_Construct     79.14%      Case_Mood               79.13%
Case_Mood_Marker         79.13%      Syntactic_Role          70.33%
Phrase                    1.80%      Phrasal_Function         1.79%
Punctuation_Mark          0.00%
```

### 4.3 Segmentation coverage

```
Stem          77,797   49.34%
Suffix        38,848   24.64%
Prefix        38,291   24.28%
Other_i3rab    2,740    1.74%   ← 4th value, no slot in the parser's tri-state
```

Segmentation is **excellent** — explicit, complete, and cleaner than
QAC's `+`-marker convention. `Other_i3rab` is a fourth category the
`is_prefix`/`is_stem`/`is_suffix` model has no representation for; minor
and mappable, but real.

### 4.4 Arabella tag vocabulary — **133 distinct tags**

Published descriptions say "55 of 71 functions". The file contains
**133 distinct `Morph_Tag` values**. Top of the distribution:

```
PREP 13418 · CONJ 13181 · DET 10937 · PV 8433 · NOUN_CONCRETE 8140
SUBJ_PRON 7963 · IV 7863 · IMPERF_PREF 7694 · POSS_PRON 7678
NOUN_ABSTRACT 6424 · GERUND 4216 · REL_PRON 3524 · NOUN_PROP 3491
OBJ_PRON 3211 · NOUN_ACTIVE_PART 3156 · None 2751 · NSUFF_FEM_SG 2716
```

Two structural problems:

1. **The tagset is fused, not decomposed.** Tags such as
   `PVSUFF_SUBJ:3MP`, `IVSUFF_SUBJ:MP_MOOD:I`, `CASE_INDEF_(ACC_GEN)`,
   `NSUFF_MASC_PL_GEN` conflate part-of-speech, person/gender/number,
   case and mood into single atomic labels. `normalizer.py` expects a
   clean `pos_tag` plus **separable** flags routed through
   `classify_flag` onto seven independent axes
   (`person_gender_number`, `case`, `state`, `aspect`, `mood`, `voice`,
   `verb_form`). Decomposing 133 fused labels back onto those axes is
   linguistic reverse-engineering, not a lookup table.
2. **The literal string `None` appears as a tag value** 2,751 times —
   a data-quality artefact requiring its own handling.

### 4.5 SQLite distribution — no hidden lexicon

Schema read from the first 2 MB of `MASAQ.db`:

```
MASAQ                  (the same 19 columns)
Quran_words            (ID, index, Sura_No, Verse_No, Word_No, Morph_No2,
                        Word, Word_nv, Gloss)
BAQ_V3                 (ID, Index_no, Sura_No, Aya_…)
Syntactic_Role         (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
Possessive_Construct   (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
Phrase                 (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
Phrasal_Function       (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
invariable_declinable  (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
Case_Mood_Marker       (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
case_mood              (ID, Tag, Desc_Eng, Desc_Ar)   ← tag glossary
```

**No `roots` table. No `lemmas` table.** The additional tables are
tag-description glossaries and word indexes. The four distributed files
are four serialisations of one dataset, not four different datasets.

## 5. Why this is fatal

`tool/lexicon/normalizer.py:242-250`:

```python
if head.pos_tag in CONTENT_POS:              # N, V, ADJ, PN
    root_text = head.raw_features.get("ROOT")
    lem_text  = head.raw_features.get("LEM")
    if root_text is None and lem_text is None:
        records.skipped.append(... "case G")
        continue                              # ← word discarded entirely
```

With neither field present, **every content word hits case G and is
skipped**. The output would be an empty Lexicon: `roots` 0 rows,
`lemmas` 0 rows, `word_instances` 0 rows — the exact state the project
is already in.

### Could `Segmented_Word` substitute for Lemma?

No. It is the **surface stem**, not a dictionary lemma. Using it would:

- Mint a distinct "lemma" per inflected stem variant, inflating
  `lemmas` with non-dictionary forms and corrupting `occurrence_count`.
- Leave `roots` **permanently empty** — there is no root data at any
  price. That kills the `weakRoots` benefit claimed for AI Tutor
  (`performance_insights_selector.dart:22`), which was one of the
  strongest arguments for the migration.
- Show learners inflected surface fragments instead of dictionary words
  in Flashcards.

That is a segment index mislabelled as a lexicon. It would satisfy the
schema and defeat the feature.

## 6. Corrections to my own prior deliverables

Stated plainly, because both are in the repository and both are wrong:

| Document | Claim | Reality |
|---|---|---|
| `LEXICON_DATASET_VALIDATION.md` §2 Q1 | "**Yes, all six.** Root ✅ Lemma ✅ … Dedicated Root field / Dedicated Lemma field" | **False.** Neither column exists. |
| `LEXICON_DATASET_VALIDATION.md` §2 Q10 | "MASAQ **removes the Lexicon leg** of `PROJ-P-005`" | **False for v6** (CC BY-NC 3.0). True only of v5. |
| `LEXICON_DATASET_VALIDATION.md` §3 | "Licence CC BY 4.0 (Mendeley v5) / 3.0 (paper)" | Incomplete — omits v6's CC BY-NC 3.0, the current version. |
| `DR-2026-0016` Decision 1 | "Adopt MASAQ (CC BY 4.0) as the Lexicon morphology source" | Must not be accepted. |
| Both | "20 columns", "131K entries" | 19 columns, 157,676 rows. |

Every one of these came from published descriptions — the paper, the
Mendeley abstract, search summaries — rather than from the file. **The
validation gate that `DR-2026-0016` insisted on is precisely what caught
this**, and it caught the exact risk that document named as "the single
assumption most likely to break the plan." The process worked; the
earlier confidence did not.

`DR-2026-0016` must be **rejected or superseded**, not accepted. It is
still `proposed`, so nothing was built on it.

## 7. What MASAQ is actually good for

Recording this so the work is not lost — MASAQ is a high-quality dataset,
simply not a lexicon:

- Best-in-class **i'rab syntactic annotation** (`Syntactic_Role` 70.33%,
  `Case_Mood` 79.13%, 72-role tagset with bilingual glossaries).
- Complete, explicit **segmentation** (100%), cleaner than QAC's.
- Complete **English glosses** (100%) — potentially useful for
  `lemmas.meaning_en` *if* a lemma source existed to attach them to.
- Expert-verified, peer-reviewed, whole-Quran, well-formed (0 malformed
  rows).

If the project ever wants grammatical-analysis features (i'rab display,
case/mood teaching), MASAQ is a strong candidate — under a licence
review, and against a schema that does not exist yet.

## 8. Recommended next step

Do **not** proceed to a parser. Options, in order:

1. **Validate the next candidate under this same gate before any design
   work.** The non-negotiable acceptance test is now precise: *does the
   file contain a per-segment root and a per-segment lemma?* Candidates:
   Text-Fabric Quran corpus (CC BY 4.0) — note it may be QAC-derived,
   which would reinstate the original licence problem and must be checked
   first; then CAMeL Tools-generated analysis (tool-licensed, but
   generated rather than gold-standard).
2. **Reconsider the QAC licence question as a legal question**, since QAC
   demonstrably *does* carry `ROOT:` and `LEM:` features — that is why
   `segment_parser.py` reads them. Counsel may read "CHANGING IT IS NOT
   ALLOWED" as governing redistribution of the file rather than internal
   transformation for display. That is a lawyer's call, not an
   engineer's, and it is the shortest path to a working Lexicon if it
   resolves favourably.
3. **Defer Lexicon and Flashcards from v1.0** under a Decision Record.
   Given two failed sourcing attempts, this is now a materially stronger
   option than it was a sprint ago and should be treated as the default
   if option 2 does not resolve quickly.

---

## Evidence index

- Downloaded file: `MASAQ.tsv`, SHA-256 `aac224f1…a931`, verified against publisher manifest
- Partial: `MASAQ.db` first 2 MB, SQLite schema extracted
- [MASAQ v6 — Mendeley (CC BY NC 3.0)](https://data.mendeley.com/datasets/9yvrzxktmr/6)
- [MASAQ v5 — Mendeley (CC BY 4.0)](https://data.mendeley.com/datasets/9yvrzxktmr/5)
- [MASAQ paper — *Data in Brief*](https://www.sciencedirect.com/science/article/pii/S2352340924011739)
- Repository contract: `tool/lexicon/normalizer.py:242-250`, `tool/lexicon/segment_parser.py`, `tool/lexicon/sqlite_writer.py:18-79`

---

# REJECT DATASET
