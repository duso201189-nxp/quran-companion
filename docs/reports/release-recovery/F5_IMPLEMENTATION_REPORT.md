# F5 Implementation Report — Learning Journey (daily plan, progress, steps)

Source of truth: `G8_FEATURE_MATRIX.md`, `G8_DECOMPOSITION.md` §F5.
Branch: `feat/f5-learning-journey`, cut directly from `origin/main` at
`f9ae143`. **1 commit — this phase's own scoped commit. Not pushed, no
PR opened.**

---

## 1 — Objective 1: PR #14 (F4) verified on `origin/main`

Checked independently before proceeding, same discipline applied
every phase since P4:

```
git fetch origin --prune --quiet
git log origin/main --oneline -3
f9ae143 Merge pull request #14 from duso201189-nxp/feat/f4-ai-tutor
7c6cc59 feat(ai_tutor): add AI Tutor — summary, suggestions, insights, navigation (F4)
1e70a6d Merge pull request #13 from duso201189-nxp/feat/f3-learning-analytics

git merge-base --is-ancestor 7c6cc59 origin/main   → YES merged
```

Directory file counts confirmed directly, not inferred from the merge
alone:

```
lib/features/lexicon/    : 11 files
lib/features/flashcards/ : 19 files
lib/features/analytics/  : 16 files
lib/features/ai_tutor/   : 15 files
lib/features/{learning_journey,smart_learning,read_model}/ : 0 files each
```

## 2 — Branch created cleanly from current `origin/main`

```
git checkout -b feat/f5-learning-journey origin/main
```

No prerequisite layering needed — F5's dependency (F4, per
`G8_DECOMPOSITION.md`: *"F5 — Learning Journey | Dependencies | F4,
`search`, P2"*, with `search` already merged since PR #7) is already
on `main`.

## 3 — Extraction methodology

Same precedent as every prior group: F5 is not its own commit anywhere
in history — a named slice inside `d4976b0`. Content extracted via
`git diff --binary HEAD d4976b0 -- <files>`, applied as patches,
verified, committed.

## 4 — Scope: F5's own 18 files, plus 2 shared groups, plus 2 widget corrections

**F5's own directory — 11 lib + 7 test files, all Added.** The initial
pattern search (`test/*learning_journey*`, `test/*journey*`) found 6
of the 7 test files; a broader sweep for any new test file importing
`features/learning_journey` caught the seventh
(`test/daily_learning_plan_generator_test.dart`, which doesn't have
"journey" in its filename despite testing
`daily_learning_plan_generator.dart`, already in F5's lib list) — the
same class of miss found during F3's extraction.

**2 shared groups required manual separation:**

| Group | What was kept (F5) | What was excluded, and why |
|---|---|---|
| `lib/app/router.dart` | 1 import + `learningJourney` route constant + 1 `GoRoute` | `smartLearning` import/constant/route — F6, same bundled-diff pattern found in every prior group |
| `lib/l10n/*` (3 `.arb` + 4 generated) | 12 keys: `learningJourneyTitle`, `journeyHeaderTitle`, `journeyStepCountLabel`, `journeyProgressTitle`, `journeyStepsTitle`, `learningJourneyEmpty`, `learningJourneyLoading`, `journeyStepNumber`, `aiTutorJourneyEntryTitle`, `aiTutorJourneyEntryDesc` (the last two used by §5's restored widget) | `smartLearning*`, `journeyEntrySmartLearningTitle`/`Desc` (F6), `learningSummaryFlashcardCount` (F8) — confirmed via the same full JSON-keyset-diff method as every prior group |

## 5 — Two files each needed a widget correction, same pattern as F4

**A. Restoration**: `lib/features/ai_tutor/presentation/tutor_home_screen.dart`
(an F4 file, already merged without this content) — `d4976b0`'s diff
adds `_JourneyEntryCard` here. This was **deliberately excluded during
F4's own extraction** because its doc comment read *"Sprint 16 Phase
2"* — i.e. it belongs to F5, not F4 (documented explicitly in
`F4_IMPLEMENTATION_REPORT.md` §5 and §12 as expected future work).
Applied verbatim now that F5 is the phase actually building Learning
Journey: the widget class, its call site in the `ListView`, its two
l10n keys, and the two imports F4 had removed as unused
(`go_router`, `../../../app/router.dart`) are all back, along with the
doc-comment text describing the Journey entry point.

**B. Removal**: `lib/features/learning_journey/presentation/learning_journey_screen.dart`
(F5's own new file, extracted wholesale since it didn't exist on this
branch before) — already contains a `_SmartLearningEntryCard` widget
whose own doc comment reads *"Sprint 17 Phase 2 mục 5"*, explicitly
labeling it as **F6's** later extension of this same F5 file, not part
of F5's original Sprint 16 build (mirrors router.dart's doc comment:
*"Smart Learning ... push từ [learningJourney] ... xem
LearningJourneyScreen._SmartLearningEntryCard"*). Removed:

1. The `_SmartLearningEntryCard` class in full.
2. Its one call site (plus the `SizedBox` spacer that followed it, to
   avoid double spacing) in `_JourneyContent`'s `Column`.
3. Its two l10n keys (`journeyEntrySmartLearningTitle`,
   `journeyEntrySmartLearningDesc`) — confirmed unused by grep before
   excluding, not assumed.
4. Two now-unused imports (`go_router`, `../../../app/router.dart`) —
   `flutter analyze`'s own `unused_import` warnings surfaced these
   after step 1–2, confirmed rather than assumed.

`LearningJourneyScreen`'s own class-level doc comment made no mention
of Smart Learning, so no further cleanup was needed there (unlike
`TutorHomeScreen`'s comment during F4, which needed a sentence
corrected).

## 6 — Every touched import verified

Full sweep across all new/modified files in this commit for any
`smart_learning`/`read_model` reference:

```
grep -rn "^import" <all F5 files> | grep -iE "smart_learning|read_model"
→ (empty)
```

`learning_journey_repository_impl.dart` composes `AITutorRepository`
only (per its own doc comment discipline, identical wording to
`AITutorRepositoryImpl`'s) — a real, already-merged dependency (F4),
not leakage. `learning_journey_screen.dart` reuses
`tutor_presentation.dart`/`tutor_action_navigator.dart` (F4) directly
rather than duplicating their mapping/navigation logic — also
legitimate.

## 7 — Every modified file confirmed to belong to F5 only

`git status --porcelain` after the commit shows a clean tree. F5's own
commit (`981e04c`) touches exactly 27 files: 18 own files + 2
surgically-separated shared groups (router.dart, 7 l10n files) + the
1 F4 file requiring restoration (`tutor_home_screen.dart`, already
counted separately from the 18 since it's not F5's own directory). No
28th file, no F6–F8 inclusion.

## 8 — Dependency verification: zero on F6–F8

| Check | Result |
|---|---|
| Import sweep (§6) | Zero matches for any F6–F8 module path |
| `lib/features/smart_learning/`, `read_model/` | Still 0 files each on this branch — untouched |
| F4 (AI Tutor) | **Satisfied** — merged via PR #14, confirmed in §1 |
| P1, P2, P3, P4 | **Satisfied** — merged (PR #3, #5, #11, #12) |

**Downstream**: F6 (Smart Learning) depends on F5, per
`G8_DECOMPOSITION.md` — and specifically on `LearningJourneyScreen`,
which F6's own commit will need to re-extend with its own
`_SmartLearningEntryCard` addition (removed here, §5B) as part of F6's
own scope.

## 9 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 311 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` — clean after the widget correction in §5 (first pass surfaced 2 `unused_import` warnings, both traced and fixed) |
| `flutter test test` (full suite) | **696/696 pass** — zero regressions |

## 10 — `git diff` verification

```
git diff origin/main --shortstat
27 files changed, 1846 insertions(+), 10 deletions(-)
```

## 11 — State

| | |
|---|---|
| Branch | `feat/f5-learning-journey` |
| HEAD | `981e04c` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 12 — Remaining G8 work after F5

```
F6   Smart Learning     ← needs F4, F5 (this PR); will need to
                            re-add a Smart Learning entry point into
                            LearningJourneyScreen as its own scope —
                            see §5B
F7   Read Model         ← needs F4, F5, F6
F8   Learning Session (wiring) ← needs F2 (merged); independent of F5
```

`docs/knowledge/provider_read_flow.md` and the Sprint 20 accessibility
docs (flagged during F2/F3, unaddressed in F4) remain unclaimed by any
single F-group and were not touched this phase either — still pending
until enough of F6–F7 exists for either document to describe a
complete, buildable state.

---

READY FOR F5 PR
