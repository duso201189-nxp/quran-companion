# Lexicon Dataset Validation — Phase 3 Sprint R3.1

Architecture / legal / data-validation sprint. **No production code, build
script, release document, or commit was touched.**

Every requirement below was derived by reading the pipeline source, not
its documentation. Where a claim rests on external research rather than
on code in this repository, it is marked **[external]** and cited.

---

## 1. The required-field contract, derived from code

`tool/lexicon/normalizer.py` is the authority — it decides what is
representable. Extracted by reading all 339 lines:

| Field | Source in code | Requirement | Consequence if absent |
|---|---|---|---|
| `sura`, `aya`, `word`, `segment` | `Segment` dataclass; `word_key`; `_ayah_id_for` | **Hard** | Cannot group segments into words or compute `ayah_id` FK |
| `form` (surface) | `Segment.form`; line 293 `full_form = "".join(...)` | **Hard** | `word_instances.arabic_form` is NOT NULL |
| Segmentation role (prefix/stem/suffix) | `is_prefix`/`is_suffix`/`is_stem` via `+` markers; `_select_head` line 151 | **Hard** | `_select_head` raises → **the entire word is skipped** (line 156-158) |
| `pos_tag` | `CONTENT_POS` line 24; `_fold_non_head` lines 173-181 | **Hard** | Head selection fails; DET/PRON folding misfires |
| `ROOT` | line 243, 251-256 | **Conditional-hard** | On a content word with no `LEM` either → **word skipped** (case G, line 246-250). With `LEM` present → `roots` stays empty, `root_id` NULL |
| `LEM` | lines 244, 258, 260-272 | **Conditional-hard** | `lemmas.arabic` has no value; see above |
| Morph flags (`3MS`, `GEN`, `PERF`, …) | `classify_flag` lines 37-60 | **Soft** | Unrecognised → warning, dropped (line 308). No data loss beyond `grammar_features` |

**The hard constraint is `ROOT`/`LEM` on content words.** A source
supplying POS and segmentation but no root/lemma would cause
`normalize()` to skip every noun, verb, adjective and proper noun — i.e.
produce an empty Lexicon. This was the single assumption
`DR-2026-0016` flagged as most likely to break the plan.

## 2. Validation answers

### Q1 — Does MASAQ contain the required fields?

**Yes, all six.** **[external]**

| Requirement | MASAQ | Evidence |
|---|---|---|
| Root | ✅ | Dedicated Root field |
| Lemma | ✅ | Dedicated Lemma field |
| Surface | ✅ | "the Quranic word and its word parts, including the segment of the word in Arabic script" |
| Segmentation | ✅ **explicitly** | "a field indicating the morpheme type whether it is a prefix, a stem or a suffix… prefixes represent all morphemes prior to the stem including the proclitics; suffixes represent all morphemes following the stem including enclitics" |
| POS | ✅ | Morphological tags per morpheme, **Arabella Corpus tagset** |
| Morphology | ✅ | 131K morphological entries; 55 of 71 tagset functions used |
| Location | ✅ | Sura, verse, and "an index representing the sequence of the word part within the word" |

Structure: **20 columns per row**, one row per word *or segment*, whole
Quran. Formats: **TSV, CSV, JSON, SQLite3 `.db`**.

Two findings materially better than expected:

1. **Segmentation is an explicit column**, not encoded in the surface
   string. The QAC `+`-marker convention that `segment_parser.py`
   reverse-engineers is a lossy notation; MASAQ states morpheme type
   directly. The adapter *synthesises* the `+` convention rather than
   parsing it — strictly more reliable.
2. **MASAQ's text derives from Tanzil.net** — the same source this
   project already ships for Arabic Uthmani (`docs/DATA_PIPELINE.md`).
   Surface forms should align with the existing `ayahs` table rather
   than needing reconciliation. This also means MASAQ adds **no new**
   text-licence exposure; the project already carries Tanzil terms.

### Q2 — Can every pipeline stage consume MASAQ?

| Stage | Verdict | Reasoning |
|---|---|---|
| **fetch** (`fetch_morphology.py`) | ⚠️ **Replace** | Hard-wired to QAC: validates QAC line format, writes `morphology_source.json` naming QAC. Its *posture* (never auto-download, human accepts terms) is correct and must be preserved. A sibling `fetch_masaq.py` is the clean move; do not edit the original. |
| **parser** (`segment_parser.py`) | ⚠️ **New sibling required** | Expects `LOCATION⇥FORM⇥TAG⇥FEATURES`, 4 columns. MASAQ has 20. Needs `masaq_parser.py` emitting the identical `Segment` dataclass. |
| **normalizer** (`normalizer.py`) | ⚠️ **Needs a tagset mapping layer** | Logic is source-agnostic; its **constants are not**. See Q3. |
| **sqlite_writer** (`sqlite_writer.py`) | ✅ **Unchanged** | Consumes `NormalizedRecords`. No QAC reference anywhere in its 125 lines. |
| **pre_build_validator** | ✅ **Unchanged** | `validate_records(records: NormalizedRecords)` — operates on normalised output. |
| **post_build_validator** | ✅ **Unchanged** | Pure SQL against the 8 tables (`SELECT COUNT(*) FROM roots WHERE TRIM(radicals) = ''`, occurrence-count reconciliation, position uniqueness). Source-blind by construction. |

**Three of six stages need no change at all.** The architecture's
source-isolation seam holds.

### Q3 — Every incompatibility

**I-1 — Tagset mismatch (the material one).** `normalizer.py` hardcodes
QAC vocabulary:

```python
CONTENT_POS      = {"N", "V", "ADJ", "PN"}          # line 24
_PGN_RE          = ^([123])([MF])([SDP])$            # line 26  e.g. "3MS"
_CASE_VALUES     = {NOM, ACC, GEN}                   # line 27
_STATE_VALUES    = {DEF, INDEF}                      # line 28
_ASPECT_VALUES   = {PERF, IMPF, IMPV}                # line 29
_MOOD_VALUES     = {IND, SUBJ, JUS}                  # line 30
_VOICE_VALUES    = {ACT, PASS}                       # line 31
_VERB_FORM_VALUES= {I … XII}                         # lines 32-34
seg.pos_tag == "DET"   /   seg.pos_tag == "PRON"     # lines 173, 176
```

MASAQ uses the **Arabella Corpus tagset**. None of these literals can be
assumed to match. This is the real engineering content of the migration.

**I-2 — Segmentation encoding.** Explicit column → must be rendered into
the `+` convention (`"wa+"`, `"+hu"`, bare stem) so `is_prefix`/
`is_suffix`/`is_stem` behave. Mechanical, in the adapter.

**I-3 — Column layout.** 20 columns vs 4. Confined to the new parser.

**I-4 — Licence version ambiguity.** The paper states **CC BY 3.0**; the
Mendeley record for v5 states **CC BY 4.0**; the DOI has since advanced
to `.6`. Both permit derivatives and commercial use, so neither blocks —
but the exact version and licence **must be pinned and recorded at
download time**, not inferred from the paper. **[external]**

**I-5 — Word/segment indexing alignment (unverified).** `_ayah_id_for`
must produce ids matching the existing `ayahs` table, and
`word_instances.position` must be unique per ayah (enforced by
`post_build_validator`). Whether MASAQ's word numbering matches the
project's tokenisation of the same Tanzil text is **not verifiable
without the file**.

**I-6 — Unused syntactic annotation.** MASAQ's 123K i'rab entries and
72-role tagset have no destination in the current 8-table schema. Not an
incompatibility — surplus. `grammar_features(feature_key, feature_value)`
is generic enough to absorb a subset later if wanted.

**I-7 — Pre-existing, source-independent.** `segment_parser.py`'s own
docstring: the QAC format was reconstructed from public documentation and
*"CHƯA được kiểm chứng trên file thật"* — **the pipeline has never
processed a real data file of any kind.** Unit tests run on synthetic
fixtures only. Expect first-contact defects in `normalizer.py` regardless
of which source is chosen. This is not a MASAQ risk; it is a pipeline
risk that MASAQ merely exposes first.

### Q4 — Engineering effort: **Medium**

| Work | Size |
|---|---|
| `fetch_masaq.py` (validate + record provenance, no auto-download) | ~80 lines — Tiny |
| `masaq_parser.py` → `Segment` | ~180 lines + tests — Small |
| Tagset mapping layer (Arabella → normalizer's feature axes) | ~120-180 lines + tests — **Small-Medium, and the real risk** |
| `build_quran_db.py` wiring | ~20 lines — Tiny *(out of scope this sprint)* |
| Iteration against real data | **Unbounded — dominant cost** |

**Not Small**: the tagset mapping needs linguistic judgement, not
transliteration, and the pipeline has never met real data.
**Not Large**: zero downstream changes, schema untouched, ~380 new lines
written against a contract that already exists and is already tested.

### Q5 — Implementation risk: **Medium**

| Risk | Severity | Note |
|---|---|---|
| Arabella tagset doesn't decompose onto normalizer's axes (case/state/aspect/mood/voice/verb-form) | **High impact, medium likelihood** | If Arabella conflates axes the QAC scheme separates, `grammar_features` loses fidelity. Degrades gracefully — `classify_flag` returns `None` → warning, not crash. |
| Word/segment indexing misaligns with `ayahs` | Medium | Caught loudly by `post_build_validator`'s position-uniqueness and occurrence-count checks. |
| Root/lemma sparser than expected on content words | **High impact, low likelihood** | Would skip words (case G). MASAQ explicitly carries both; likelihood low but consequence is a partial Lexicon. |
| First-contact defects in `normalizer.py` | Medium | Certain to some degree; unit tests are synthetic-only. |
| Asset size growth | Low | 131K entries will grow `quran.sqlite`. CI already reports APK/web bundle sizes, so it surfaces automatically. |

**No risk in this table is a correctness risk to shipped features** —
the failure modes are "Lexicon partially populated" or "features
lower-fidelity", both visible to the validators, none silent.

### Q6 — Does the SQLite schema stay unchanged?

**Yes. Zero schema changes.** `LEXICON_SCHEMA` (`sqlite_writer.py:18-79`)
is unaffected. All 8 tables, all 8 indexes, all FKs stay exactly as
declared — which also means `PROJ-P-002` ("stop and ask before any schema
change") is **not triggered**.

| Table | Populated by MASAQ? |
|---|---|
| `roots` | ✅ |
| `lemmas` | ✅ |
| `lexemes` | ✅ (derived) |
| `word_instances` | ✅ |
| `grammar_features` | ✅ |
| `phrases` | ❌ remains empty — no automated source (by design, Phase 2.6 §6) |
| `phrase_word_instances` | ❌ remains empty |
| `lexicon_relations` | ❌ remains empty |

The three empty tables are **unchanged by this decision** — they were
already out of scope for any automated source, QAC included.

### Q7 — Would Flashcards continue working?

**Yes — and it would work for the first time.**

`lib/features/flashcards/data/flashcard_providers.dart` calls
`lexiconRepositoryProvider.getLemmasByIds(...)` (lines 111, 145) and
`getLexemesForLemma(...)` (line 168) for every `type.name == 'lemma'`
card. With `lemmas` at 0 rows those lookups return empty today, so
lemma-backed flashcards render without content on a real install.
Populating the tables activates them. **Strictly an improvement; no
regression path.**

### Q8 — Would Search continue working?

**Yes — entirely unaffected.**

`search_index` is an FTS5 virtual table built over ayahs/translations
(`build_quran_db.py:359` creates it, `:673` populates it). It has **no
dependency on any Lexicon table**, and no file under
`lib/features/search/` references `roots`, `lemmas`, `word_instances` or
`lexeme` — verified by grep, zero matches. The index currently holds
43,652 rows and is independent of this decision.

### Q9 — Would AI Tutor benefit?

**Yes — it would activate a currently-dead suggestion path.**

`lib/features/analytics/domain/performance_insights_selector.dart:22,36`
resolves `weakRoots` against `lemmasByLemmaId`. With `lemmas` empty,
`weakRoots` is always empty. That makes
`tutor_suggestion_generator.dart:83` — `if (context.insights.weakRoots.isNotEmpty)`
— permanently false, so the `strengthenWeakRoots` suggestion **can never
fire**, and its navigation target (`tutor_action_navigator.dart:24` →
`SmartDeckType.weakRoots`) is unreachable in practice.

Populating the Lexicon brings an entire built-and-tested suggestion
branch to life. This is a concrete, currently-invisible benefit that no
release document records.

### Q10 — Commercial safety vs QAC

**Materially safer.** **[external]**

| Source | Derivatives | Commercial | Verdict |
|---|---|---|---|
| **QAC v0.4** | ❌ `# CHANGING IT IS NOT ALLOWED` in the data header, against a nominal GPL declaration | Unclear | Self-contradictory; the pipeline *must* transform, so this is unusable without accepting legal ambiguity |
| **QAC v2** (`kaisdukes/quranic-corpus`) | ✅ under GPL-3.0 | ✅ | Copyleft obligations on data embedded in a store binary |
| **MASAQ** | ✅ explicitly | ✅ explicitly | Attribution only |

CC BY (3.0 or 4.0) grants the right to *remix, transform and build upon*
the material, **for any purpose, including commercially**, conditioned
only on attribution — exactly the right QAC's header withholds and the
one this pipeline requires.

Effect on `PROJ-P-005` (monetisation blocker, `CLAUDE.md` "stop and ask"):
MASAQ **removes the Lexicon leg** of that blocker. It does **not** clear
`PROJ-P-005` — Tanzil's non-commercial translation terms remain the
binding constraint, and MASAQ's own text provenance is Tanzil, so nothing
about the translation exposure changes either way. Net: one fewer
obstacle, the principal one untouched.

## 3. Comparison table

| | **QAC v0.4** (current target) | **QAC v2** | **MASAQ** ← recommended | Text-Fabric Quran | CAMeL/Farasa analysers |
|---|---|---|---|---|---|
| Licence | GPL declared + `CHANGING IT IS NOT ALLOWED` | GPL-3.0 | **CC BY 4.0** (Mendeley v5) / 3.0 (paper) | CC BY 4.0 | Tool licences vary; output derivative |
| Derivatives permitted | **No** (contradictory) | Yes (copyleft) | **Yes** | Yes | N/A — generates, not distributes |
| Commercial safe | Unclear | Obligations attach | **Yes** | Yes | Depends on tool |
| Root | ✅ | ✅ | ✅ | ✅ | Generated, not gold |
| Lemma | ✅ | ✅ | ✅ | ✅ | Generated |
| Segmentation | ✅ (`+` notation) | ✅ | ✅ **explicit column** | ✅ | Generated |
| POS / morphology | ✅ QAC tagset | ✅ (AI-generated, community-verified) | ✅ Arabella tagset, expert i'rab | ✅ | Generated |
| Academic quality | Established, widely cited | Newer; AI-tagged + human review | **Peer-reviewed** (*Data in Brief*), expert linguists, Univ. of Jordan | Established | Strong tools, no gold Quran annotation |
| Maintenance | v0.4, long static | Active | Active (DOI at v6) | Active | Active |
| Format | Tab text | Repo | **TSV/CSV/JSON/SQLite** | Text-Fabric | Library output |
| Acquisition | Email-gated JS form | git clone | Mendeley download | Download | pip install |
| Engineering effort | Baseline (parser exists) | Small-Medium | **Medium** | Medium-Large (adapter) | Large (build + verify annotation) |
| Blocking flaw | **Licence** | Copyleft | *None identified* | Viable fallback | Not gold-standard data |

Ranking of viable alternatives, best first: **1. MASAQ · 2. Text-Fabric
Quran (CC BY 4.0) · 3. QAC v2 (GPL-3.0) · 4. Analyser-generated
(CAMeL/Farasa) · 5. QAC v0.4 (rejected on licence).** A deeper top-five
work-up was not pursued because MASAQ satisfies every hard requirement;
the bench above is recorded so a fallback does not need re-researching.

## 4. What remains unverified

Stated plainly, because the recommendation is conditional on it:

- **No MASAQ file was downloaded.** Acquiring third-party data means
  accepting its terms — the owner's action, not an automated one,
  matching the posture `fetch_morphology.py` already takes.
- The **exact 20-column layout and header names** are known only from
  published descriptions, not inspection.
- Whether **root/lemma are populated densely enough on content words** to
  avoid case-G skips is unverified.
- The **Arabella tagset's value vocabulary** — the input to the mapping
  layer — has not been enumerated.
- `pytest` is not installed locally, so the 543 lines of existing
  pipeline tests **could not be executed** during this sprint.

## 5. Recommendation

# APPROVE MASAQ

Conditional on a validation gate as the first task of any implementation
sprint, in this order:

1. **Owner acquires** the dataset from Mendeley (`10.17632/9yvrzxktmr`),
   reads and accepts its terms, records the exact version and licence
   string.
2. **Inspect the real schema** — confirm the 20 columns expose sura, aya,
   word, segment index, surface form, morpheme type, POS, root, lemma.
3. **Density check** — sample content words; confirm root/lemma present
   often enough to avoid mass case-G skips.
4. **Enumerate the Arabella value vocabulary** and draft the mapping onto
   `case / state / aspect / mood / voice / verb_form / person_gender_number`.
5. Only then write `masaq_parser.py` + mapping layer + tests.

**If step 2 or 3 fails, fall back to Text-Fabric (CC BY 4.0); if that
also fails, defer Lexicon from v1.0 under a superseding Decision Record.**
Do not fall back to QAC — its licence problem is not solved by any amount
of engineering.

`DR-2026-0016` should remain `proposed` until step 3 passes. This
document is the evidence base for accepting it, not the acceptance
itself.

---

## Sources

- [MASAQ dataset — Mendeley Data](https://data.mendeley.com/datasets/9yvrzxktmr/5)
- [MASAQ paper — *Data in Brief* (ScienceDirect)](https://www.sciencedirect.com/science/article/pii/S2352340924011739)
- [MASAQ paper — PubMed](https://pubmed.ncbi.nlm.nih.gov/39830618/)
- [MASAQ Parser — ACL Anthology 2025](https://aclanthology.org/2025.clrel-1.7/)
- [Quranic Arabic Corpus — download & licence](https://corpus.quran.com/download/)
- [Quranic Arabic Corpus — Wikipedia](https://en.wikipedia.org/wiki/Quranic_Arabic_Corpus)
- [QAC v2 — kaisdukes/quranic-corpus](https://github.com/kaisdukes/quranic-corpus)

Repository evidence: `tool/lexicon/normalizer.py`,
`tool/lexicon/segment_parser.py`, `tool/lexicon/sqlite_writer.py`,
`tool/lexicon/{pre,post}_build_validator.py`, `tool/fetch_morphology.py`,
`tool/build_quran_db.py`, `lib/features/flashcards/data/flashcard_providers.dart`,
`lib/features/analytics/domain/performance_insights_selector.dart`,
`lib/features/ai_tutor/domain/tutor_suggestion_generator.dart`.

---

LEXICON DATASET VALIDATION COMPLETE
