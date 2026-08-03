# Release Governance Audit — 2026-08-01

Every checkable claim in the release-planning document set, verified
against the actual repository. This is an **audit report**, not a
replacement status document — the corrections below belong in
`RELEASE_DASHBOARD.md` and `RELEASE_PLAN_V1.md` themselves, and the
final section says how. Creating a fourth source of truth would
reproduce the problem this audit diagnoses.

No production code was modified to produce this document.

---

## 1. Why this audit exists

Three material errors were found in the release documents during
ordinary sprint work over a single session — not by looking for them:

1. Search FTS5 wiring listed as an open **Critical** blocker after it
   had already shipped (Phase 3 Sprint R1, commit `0f3f751`).
2. `PHASE3_SPRINT_R3_PLAN.md` claimed four route constants were unused;
   all four are live `path:` values in the shell routes.
3. The Lexicon blocker characterised as *"the single largest unknown…
   no source document specifies where the data comes from"* — while a
   1,610-line, unit-tested Lexicon pipeline sits in `tool/`, with the
   source named and the real blocker (a licence conflict) documented in
   the code.

A planning document that is wrong about its own critical path is a
larger risk than any item on the debt register, because every sprint
selection depends on it. Hence this pass.

## 2. Audit results

### 2.1 Confirmed accurate

| Claim | Source | Evidence |
|---|---|---|
| Lexicon tables ship empty | Plan §2, Dashboard §3 | Direct query of `assets/database/quran.sqlite`: all 8 tables present, **0 rows each** |
| Web platform broken | Plan §2 | `web/` contains only `favicon.png`, `icons/`, `index.html`, `manifest.json` — no `sqlite3.wasm`, no `drift_worker.js` |
| `pubspec.yaml` never bumped | Plan §0, Dashboard §3 | still `version: 0.8.1+7` |
| `DR-2026-0002` missing | Plan §3 | `docs/adr/` has 0001, 0003, 0004, 0005, 0014, 0015 — no 0002 |
| D8 duplication is real | Debt register | 23 `deletedAt.isNull()` sites across 7 files, verified by grep |
| D5 files genuinely dead | Debt register | No real import of any of the 5 files; the one `io_cache_manager` hit is a doc comment in `console_logger.dart` |
| Tanzil non-commercial constraint | Plan §2, `DATA_PIPELINE.md` | Confirmed in the pipeline's own source/licence table |

### 2.2 Stale — fixed since writing, never updated

| Claim | Status |
|---|---|
| "Search FTS5 engine not wired" — **Critical** | **Shipped** Sprint R1. `search_index_content` holds 43,652 rows; UI wired. Still listed as Critical in both documents. |
| "Read Model has no UI / no product decision" (D3) | **Shipped** Sprint R2 + R3.1. Screen exists, route exists, CTA from `SmartLearningScreen` exists. |
| "Coverage gate 70% vs 80% target, not re-measured" | **Resolved** Sprint R3.2 (`DR-2026-0015`). Measured 81.54%, gate at 80. |
| `RELEASE_PLAN_V1.md` §0: "CHANGELOG stops at Sprint 10" | **Fixed** in Phase 2.1 — CHANGELOG now has backfill sections for P1–P4/F1–F8 (line 18) and S1/S2 (line 54). |
| `RELEASE_PLAN_V1.md` §0: "CLAUDE.md states 'mid Step 8 of 12'" | **Fixed** — that string no longer appears in `CLAUDE.md`. |
| `RELEASE_PLAN_V1.md` §0: "ROADMAP.md/TODO.md status untrustworthy" | **Partly fixed** — both now carry frozen-as-of-Sprint-10 banners. The underlying tables are still stale by design, which is now disclosed rather than misleading. |
| "767 tests" (Roadmap), "767/799" (Dashboard) | **802** as of Sprint R3.1. |

### 2.3 Incorrect as written

| Claim | Correction |
|---|---|
| **"Lexicon data sourcing is unscoped… the single largest unknown in the entire v1.0 path"** (Dashboard §6) | **False.** A complete pipeline exists — `tool/build_quran_db.py` (701), `tool/fetch_morphology.py` (133), `tool/lexicon/` (776 across normalizer / segment_parser / sqlite_writer / 2 validators), plus 543 lines of unit tests. `sqlite_writer.py` implements all 8 tables. `build_quran_db.py` already imports `LEXICON_SCHEMA`. The source is named (Quranic Arabic Corpus). The blocker is a **licence conflict**, documented in `build_quran_db.py:364-373` and `fetch_morphology.py:1-38`. See §3. |
| "16 outdated packages" (both documents) | **Imprecise.** `flutter pub outdated`: **8 direct** dependencies, **3 dev** dependencies, remainder transitive. Major-version-behind direct deps: `flutter_riverpod` 2.6.1→3.4.2, `go_router` 14.8.1→17.3.0. EOL: `sqlite3_flutter_libs` 0.5.42→0.6.0+eol. |
| "D8 touches 9+ repository files" (Roadmap v1.1) | **7 files**, not 9+. Two of the nine base repositories (`lexicon`, `quran`) never touch `SyncColumns` tables. |

### 2.4 Undocumented — exists but referenced by no release document

- **`docs/DATA_PIPELINE.md`** — the authoritative source/licence table for
  every dataset the app ships. Not linked from `RELEASE_PLAN_V1.md`,
  `RELEASE_DASHBOARD.md`, or `PRODUCT_ROADMAP.md`, despite being the
  document that governs the project's two live legal risks.
- **`tool/lexicon/tests/`** — 543 lines of unit tests for the Lexicon
  pipeline. Not counted in any coverage or test-count figure (they are
  Python; `flutter test` does not see them). `pytest` is not installed
  locally, so they could not be executed during this audit.
- **CHANGELOG has no Phase 3 entry.** P1–P4/F1–F8/S1/S2 were backfilled
  in Phase 2.1, but Sprints R1, R2, R3.1 and R3.2 are absent — a new
  instance of the exact gap §0 was written to close.

## 3. The Lexicon blocker, correctly characterised

**It is a licensing decision, not an engineering unknown.**

### What exists

```
tool/build_quran_db.py           701 lines   run by CI on every job
tool/fetch_morphology.py         133         deliberately does NOT auto-download
tool/lexicon/normalizer.py       339         Segment → Root/Lemma/Lexeme/WordInstance
tool/lexicon/segment_parser.py   141         raw text → Segment
tool/lexicon/sqlite_writer.py    125         8/8 tables
tool/lexicon/{pre,post}_build_validator.py  158
tool/lexicon/tests/              543         unit tests
                               ─────
                                2,140 lines already written
```

### What blocks it

`fetch_morphology.py` records the finding verbatim, from the QAC data
file's own header:

> `# Permission is granted to copy and distribute verbatim copies of`
> `# this file, but CHANGING IT IS NOT ALLOWED.`

The pipeline **must** transform that data — folding segments into
`WordInstance`, deriving `Lexeme` — before it can populate
`quran.sqlite`. Independently confirmed: QAC v0.4 is nominally GPL
while its data header forbids modification, a contradiction the
project identified across Sprint 12 Phases 2.6/2.7 and 3.

A second, practical barrier: the download is behind a JavaScript form
requiring a real email address. `fetch_morphology.py` deliberately
declines to automate that — correctly, since accepting licence terms on
a user's behalf is not an automation decision.

### What this means

The Lexicon blocker belongs in the **same category as the Tanzil
translation licence** — which `RELEASE_DASHBOARD.md` §6 already
identifies as *"binary risk… worth de-risking earliest."* It has been
misfiled as an unscoped engineering problem for the entire life of the
release plan, which is why it has never been actioned: it was framed as
an unknown-effort task when it is a decision with known follow-on work.

### One material caveat

`segment_parser.py`'s own docstring states the QAC format was
reconstructed from **public documentation of the structure**, and that
the parser *"CHƯA được kiểm chứng trên file thật"* — has never been run
against a real data file. The pipeline is well-designed and unit-tested
against synthetic fixtures, but **no byte of real morphology data has
ever passed through it.** Any plan that assumes it works end-to-end is
assuming something unverified.

## 4. Replacement dataset evaluation

The pipeline's architecture makes substitution cheap: only
`segment_parser.py` is source-specific. `normalizer.py` consumes
`Segment` objects and `sqlite_writer.py` consumes `NormalizedRecords` —
neither knows or cares where the data came from. Swapping sources means
writing one new parser that emits the same `Segment` dataclass.

| Candidate | Licence | Derivatives? | Commercial? | Assessment |
|---|---|---|---|---|
| **Quranic Arabic Corpus v0.4** (current target) | GPL declared; data header says "CHANGING IT IS NOT ALLOWED" | **No — self-contradictory** | Unclear | **Reject.** The contradiction is unresolved and unresolvable by us. |
| QAC v2 (`kaisdukes/quranic-corpus`) | GPL-3.0 | Yes, under GPL | Yes | Viable but **GPL-3.0 is copyleft** — shipping derived data inside a proprietary app store binary raises questions this project should not take on. POS tags are AI-generated with community verification. |
| **MASAQ** — Morphologically-Analyzed and Syntactically-Annotated Quran | **CC BY 4.0** (Mendeley Data v5) | **Yes, explicitly** | **Yes** | **Recommended.** University of Jordan (Sawalha, Yagi, Alshargi, Hammo, Alshdaifat). 131K morphological + 123K syntactic entries, full Quran, expert-verified via i'rab. Formats include TSV/CSV/JSON/XML. Peer-reviewed in *Data in Brief*. |
| Text-Fabric Quran corpus | CC BY 4.0 | Yes | Yes | Viable fallback. Column-oriented; would need its own adapter. |

**MASAQ resolves both live licence risks at once:** CC BY 4.0 permits
transformation (fixing the QAC conflict) *and* commercial use (removing
one leg of the `PROJ-P-005` monetisation blocker that Tanzil's
non-commercial translation terms otherwise create).

### What is *not* yet verified about MASAQ

Stated plainly, because the recommendation depends on it:

- Its exact column layout is unknown to this audit. It will **not**
  match `segment_parser.py`'s expected `LOCATION⇥FORM⇥TAG⇥FEATURES`.
- Whether it exposes `ROOT` and `LEMMA` per segment in the form
  `normalizer.py` requires is unconfirmed.
- Its POS tagset (72 syntactic roles, i'rab-based) will need mapping to
  the existing tag handling.
- No file was downloaded during this audit. Acquiring third-party
  datasets is the owner's call, not an automation decision.

**Format validation must therefore be the first task of any
implementation sprint, gating the rest of it.**

## 5. Recommendation

**Replace the data source.** Adopt MASAQ (CC BY 4.0) in place of QAC,
subject to format validation.

Rejected alternatives:

- **Proceed with QAC** — requires betting a store submission on a
  favourable reading of a licence that contradicts itself. This project
  already carries one unresolved licence risk (Tanzil). Adding a second
  is not a trade a release should make.
- **Defer Lexicon from v1.0** — viable, and genuinely better than
  shipping empty tables, but premature. It writes off 2,140 lines of
  built pipeline and two feature verticals (Lexicon, and Flashcards
  which depends on it) before the cheapest alternative has been tried.
  This remains the correct fallback **if** MASAQ fails format
  validation, and should then be recorded as a Decision Record rather
  than left implicit.

Proposed as `DR-2026-0016`, status `proposed` — acceptance is the
Constitution/Release Owner's call.

## 6. Corrections to apply

These belong in the existing documents, not here. Recommended, not
performed — a rewrite of this size should be approved before it lands.

**`RELEASE_DASHBOARD.md`**
- §3 Critical: remove Search FTS5 (shipped R1).
- §3 Critical: rewrite the Lexicon entry per §3 above — licence
  decision, not unscoped data sourcing.
- §6 Risks: replace "Lexicon data sourcing is unscoped… single largest
  unknown" with the licence framing; re-rank it alongside Tanzil.
- §1: test count 767/799 → 802; recompute or explicitly retire the
  weighted percentage model (it now understates progress by three
  shipped sprints).
- Add `docs/DATA_PIPELINE.md` to the document map.

**`docs/release/RELEASE_PLAN_V1.md`**
- §0: mark the CHANGELOG/CLAUDE.md/ROADMAP items resolved (Phase 2.1);
  add the new gap — no Phase 3 CHANGELOG entry.
- §2: rewrite the Lexicon paragraph; correct "16 outdated packages" to
  8 direct + 3 dev.
- §4: re-sequence — step 2 ("rebuild the content database asset") is
  blocked on a licence decision, not effort.

**`docs/release/PRODUCT_ROADMAP.md`**
- "Search — engine wiring still open" → shipped.
- "Decide Read Model's fate" → decided and shipped.
- v1.1 "coverage gate 70→80" → done (`DR-2026-0015`).
- "D8 touches 9+ repository files" → 7.

**`CHANGELOG.md`** — add a Phase 3 section (R1 Search, R2 Read Model,
R3.1 entry point, R3.2 coverage policy).

**`docs/release/PHASE3_SPRINT_R3_PLAN.md`** — correct the false D12
claim (already noted in the R3 verification report, not yet fixed at
source).

## 7. Governance finding

The failure mode here is structural, not clerical. Documents were
written accurately at a point in time and never re-verified, while
sprints shipped against them. Three sprints' worth of completed work
sat unrecorded in the Critical blocker list.

**Recommended standing rule:** a sprint is not complete until the
release documents it invalidates have been updated in the same change —
the same discipline `CLAUDE.md` already applies to tests ("every new
feature ships tests in the same change"). Sprint R2 and R3.2 did this
correctly; R1 did not, which is why its completion went unrecorded for
three sprints.

---

RELEASE GOVERNANCE AUDIT COMPLETE
