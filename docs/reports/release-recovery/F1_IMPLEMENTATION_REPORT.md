# F1 Implementation Report — Lexicon (domain, repository, build pipeline)

Source of truth: `G8_FEATURE_MATRIX.md`, `G8_DECOMPOSITION.md` §F1,
`G8_FINAL_VERIFICATION.md`. Branch: `feat/f1-lexicon`, cut from
`origin/main` at `357c7de`. **1 commit, content extracted from the G8
mega-commit `d4976b0`. Not pushed, no PR opened.**

---

## 0 — Correction to task context, verified independently

The task states P4 has been merged into `origin/main`. Checked before
proceeding, per this engagement's standing discipline of verifying
status claims against git rather than trusting them: **P4 has not
been merged.**

```
git fetch origin --prune --quiet
git ls-remote origin 'refs/pull/*/head'   → refs/pull/1 through /11 only, no #12
git log origin/main --oneline -1          → 357c7de (PR #11 / P3)
git merge-base --is-ancestor 69f5c9b origin/main   → NO
```

`feat/p4-reliability-retrofit` (commit `69f5c9b`, from the prior
phase) was implemented and validated locally but never pushed, since
that phase's instructions stopped at "READY FOR P4 PR" without a push
step. This does not block F1: `G8_DECOMPOSITION.md` states F1's
dependencies are **P1 and P3 only**, not P4 — confirmed both are
genuinely merged (§3). Flagging this discrepancy explicitly rather
than silently proceeding as if P4 were live, and rather than blocking
F1 on a dependency it doesn't actually have.

## 1 — Branch created cleanly from current `origin/main`

```
git checkout -b feat/f1-lexicon origin/main
```

Base: `357c7de` (PR #2–#11 merged).

## 2 — Extraction methodology

Same precedent as P1/P3/P4: F1 is not its own commit anywhere in
history — it's a named slice inside `d4976b0`. Content extracted via
`git diff --binary origin/main d4976b0 -- <files>`, applied as one
patch, empirically verified with `git apply --check --binary` in a
throwaway worktree (exit code 0) before being applied to the real
branch and committed.

## 3 — Scope discovery: 30 files, not 24

The prior extraction-analysis phase (`G8_DECOMPOSITION.md`) listed 24
files (11 `lib/` + 13 `tool/lexicon/`). Re-verified fresh this phase,
not carried over on faith — a direct glob search
(`git diff --name-status origin/main d4976b0 -- 'lib/features/lexicon/*'
'tool/lexicon/*' 'test/*lexicon*'`) found **26**: the 24 plus 2
previously-uncounted test files (`test/lexicon_entities_test.dart`,
`test/lexicon_repository_contract_test.dart` — the extraction analysis
had only named `lexicon_repository_impl_test.dart`).

A further sweep for any **other** file (outside those paths) that
mentions "lexicon" in `d4976b0` surfaced 3 more, each checked by
content before inclusion, not assumed by path:

| File | Status | Why it belongs to F1 |
|---|---|---|
| `tool/build_quran_db.py` | Modified | Adds `SCHEMA += LEXICON_SCHEMA`, importing from `tool/lexicon/sqlite_writer.py` — the mechanical wiring that gets F1's schema into the shipped asset. Purely additive (4 new lines), nothing else in this large file touched |
| `tool/fetch_morphology.py` | Added | A deliberately non-networked vendor script for the Quranic Arabic Corpus morphology source. Read in full: documents a real, specific licensing conflict ("changing it is not allowed" vs. this pipeline's required transform step) and a data-collection concern (a third-party form requiring a real email), both cited as reasons this step is **not** automated — consistent with this project's established licensing caution (`PROJ-P-005`) |
| `assets/database/quran.sqlite` | Modified (binary) | The rebuilt asset, produced by the above script change. Verified **empirically**, not from the comment alone: extracted the `d4976b0` version of the asset and queried all 8 new Lexicon tables directly — every one returns 0 rows. Schema-only, no data, matching this project's established "schema ahead of data" precedent (`lemmas`/`word_instances` since Sprint 9, and P3's own tables) |

**Every other file `d4976b0` touches that mentions "lexicon"** — in
`ai_tutor/`, `analytics/`, `flashcards/`, `srs_card.dart`,
`study_screen.dart`, and their test files — is a **downstream
consumer** of Lexicon (F2/F3/F4 territory), not part of F1's own
definition. None included, confirmed by reading each one's content
before excluding rather than assuming from the directory name.

**Final scope: 30 files** — 11 `lib/features/lexicon/`, 3
`test/lexicon_*`, 13 `tool/lexicon/` (6 source + 7 of its own tests),
`tool/fetch_morphology.py`, `tool/build_quran_db.py`,
`assets/database/quran.sqlite`.

## 4 — Every touched import verified

All 11 `lib/` files' imports read individually:

| File | Imports beyond same-directory siblings |
|---|---|
| `lexicon_providers.dart` | `core/database/database_providers.dart`, `core/logging/logging_providers.dart` |
| `lexicon_repository_impl.dart` | `core/database/app_database.dart`, `core/logging/logger.dart`, `core/logging/repository_boundary_logging.dart` |
| 8 domain entities | Only `lexicon_entry.dart` (same directory) or nothing |
| `lexicon_repository.dart` (interface) | Only its own entities |

**Zero cross-feature import.** `lexicon_repository_impl.dart` already
uses the P1/P4 reliability pattern (`Logger`, `withFailureLogging`)
from its first line of history in `d4976b0` — it was written *after*
that pattern existed in the original `sprint1-my-library` timeline, so
it needed no separate retrofit. This only requires `core/logging/*`
(P1, merged) to exist, not P4 specifically — confirmed by the fact
this compiles and passes on a branch cut from `main` where P4 is not
present (§0).

The 3 test files' imports are equally clean — only Lexicon's own
types plus `flutter_test`, `drift/native.dart`,
`core/database/app_database.dart`, `core/logging/console_logger.dart`.

## 5 — Every modified file confirmed to belong to F1 only

`git status --porcelain` after the commit shows exactly the 30 files
in §3 — no 31st file. A full sweep of every import line across all
new/modified `.dart` files for `flashcard`/`analytics`/`ai_tutor`/
`smart_learning`/`read_model`/`learning_session`/`quiz`/`khatm`
returned nothing.

## 6 — Dependency verification: zero on F2–F8

| Check | Result |
|---|---|
| Import sweep (§4, §5) | Zero matches for any F2–F8 module path |
| `lib/features/flashcards/`, `analytics/`, `ai_tutor/`, `smart_learning/`, `read_model/` on this branch | Still 0 files each — untouched, identical to `origin/main` |
| P1 (reliability layer) | **Satisfied** — merged PR #3 |
| P3 (Lexicon content tables: `Roots`, `Lemmas`, `Lexemes`, `WordInstances`, `GrammarFeatures`, `Phrases`, `PhraseWordInstances`, `LexiconRelations`) | **Satisfied** — merged PR #11, confirmed present in `origin/main`'s `content_tables.dart` |
| P4 (reliability retrofit) | **Not required** — F1's own `lexicon_repository_impl.dart` was written with the reliability pattern already in place, needing only `core/logging/*` (P1), not the retrofit of other repositories |

**Downstream**: F2 (Flashcards) and F3 (Analytics) both depend on F1
per `G8_DECOMPOSITION.md` — this PR is what unblocks them, not the
reverse.

## 7 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 226 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` — clean on the first pass, no contamination this time (unlike P4's `scheduler_repository_impl.dart` incident) |
| `flutter test test` (full suite) | **534/534 pass** — up from the 461 baseline (P3, the actual current `main` state per §0). +73 new tests across `lexicon_entities_test.dart`, `lexicon_repository_contract_test.dart`, `lexicon_repository_impl_test.dart`. Zero regressions |

## 8 — `git diff origin/main` verification

```
30 files changed, 3260 insertions(+)
```

Zero deletions — F1 is purely additive, confirmed directly.

## 9 — State

| | |
|---|---|
| Branch | `feat/f1-lexicon` |
| HEAD | `271236b` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 10 — Remaining G8 work after F1

```
P4   Reliability retrofit    ← implemented locally (feat/p4-
                                 reliability-retrofit, 69f5c9b) but
                                 NOT yet pushed/merged — see §0.
                                 Independent of F1; can merge in
                                 either order
F2   Flashcards               ← needs F1 (this PR), P3 (merged)
F8   Learning Session (wiring) ← needs F2
F3   Analytics                ← needs F1 (this PR), F2
F4   AI Tutor                 ← needs F2, F3
F5   Learning Journey         ← needs F4
F6   Smart Learning           ← needs F4, F5
F7   Read Model               ← needs F4, F5, F6
```

Worth flagging for F2's own extraction phase: `P4_IMPLEMENTATION_
REPORT.md` §12 already noted that the `syncItemsForType`/
`LearningItemType.lemma` generalization excluded from P4 (because it
spans `scheduler_repository.dart`'s interface and `srs_card.dart`'s
entity, not just `lib/features/learning/`) will need to land as part
of F2, since Flashcards' smart-deck scheduling is what requires it.

---

READY FOR F1 PR
