# F4 Implementation Report — AI Tutor (summary, suggestions, insights, navigation)

Source of truth: `G8_FEATURE_MATRIX.md`, `G8_DECOMPOSITION.md` §F4.
Branch: `feat/f4-ai-tutor`, cut directly from `origin/main` at
`1e70a6d`. **1 commit — this phase's own scoped commit. Not pushed,
no PR opened.**

---

## 1 — Objective 1: PR #13 verified on `origin/main`

Checked independently before proceeding, same discipline applied
every phase since P4 — and the first time in this sequence a stated
"already merged" claim has held on the very first check:

```
git fetch origin --prune --quiet
git log origin/main --oneline -3
1e70a6d Merge pull request #13 from duso201189-nxp/feat/f3-learning-analytics
a062573 feat(analytics): add Learning Analytics — statistics, history, insights, goals, achievements (F3)
c10b9f7 feat(flashcards): add Flashcards feature — browse, add, decks, smart deck, review (F2)

git merge-base --is-ancestor a062573 origin/main   → YES merged
```

PR #13 carried F1 + F2 + F3 combined (per the branch it was opened
from). All three are now confirmed live on `main` — directory file
counts checked directly, not inferred from the merge alone:

```
lib/features/lexicon/    : 11 files
lib/features/flashcards/ : 19 files
lib/features/analytics/  : 16 files
lib/features/{ai_tutor,learning_journey,smart_learning,read_model}/ : 0 files each
```

## 2 — Branch created cleanly from current `origin/main`

```
git checkout -b feat/f4-ai-tutor origin/main
```

Unlike F2/F3, **no prerequisite layering was needed this phase** —
F4's dependencies (F2, F3, per `G8_DECOMPOSITION.md`: *"F4 — AI Tutor |
Dependencies | F3, F2, P2"*) are already merged, so this branch is a
single clean commit directly on top of `origin/main`, not stacked on
other unmerged branches.

## 3 — Extraction methodology

Same precedent as every prior group: F4 is not its own commit
anywhere in history — a named slice inside `d4976b0`. Content
extracted via `git diff --binary HEAD d4976b0 -- <files>`, applied as
patches, verified, committed.

## 4 — Scope: F4's own 22 files, plus 2 shared groups requiring surgery, plus 1 removal

**F4's own directory — 14 lib + 8 test files, all Added:**

```
lib/features/ai_tutor/  (14 files: data/, domain/, domain/entities/, presentation/, presentation/widgets/)
test/ai_tutor_providers_test.dart
test/ai_tutor_repository_impl_test.dart
test/tutor_header_test.dart
test/tutor_home_screen_test.dart
test/tutor_insight_card_test.dart
test/tutor_insight_generator_test.dart
test/tutor_suggestion_card_test.dart
test/tutor_suggestion_generator_test.dart
```

**2 shared groups required manual separation:**

| Group | What was kept (F4) | What was excluded, and why |
|---|---|---|
| `lib/app/router.dart` | 1 import + `aiTutor` route constant + 1 `GoRoute` | `learningJourney`/`smartLearning` imports/constants/routes — F5/F6, same bundled-diff pattern found in every prior group |
| `lib/l10n/*` (3 `.arb` + 4 generated) | 30 `aiTutor*`/`studyAiTutor*` keys | `learningJourney*`/`journey*`, `smartLearning*`, `learningSummaryFlashcardCount` (F5/F6/F8) — confirmed via the same full JSON-keyset-diff method used for F2/F3. 2 further keys removed after §5's fix (see below) |

## 5 — A third issue: real code removal, not just diff exclusion

`flutter analyze` flagged `tutor_home_screen.dart` referencing
`AppRoutes.learningJourney` — a constant the router surgery above
deliberately doesn't define. Investigated the reference rather than
adding the constant back to silence the error: the widget calling it,
`_JourneyEntryCard`, carries its own doc comment reading *"Lối vào
Learning Journey (Sprint 16 Phase 2 mục 5)"* — meaning it was added to
this F4 file **later**, by F5's own work extending an already-shipped
F4 screen, not part of F4's original Sprint 15 build. The class-level
doc comment on `TutorHomeScreen` confirmed this independently: *"thêm
lối vào Learning Journey ở Sprint 16 Phase 2 mục 5"*.

Removed, confirmed each removal was safe before moving to the next:

1. The `_JourneyEntryCard` class in full (its `onTap` was the only
   `learningJourney` reference in the file).
2. Its one call site in `TutorHomeScreen`'s `ListView` children.
3. The now-stale "Sprint 16" sentence in `TutorHomeScreen`'s own doc
   comment, corrected to describe only what F4 actually contains.
4. Two now-unused l10n keys (`aiTutorJourneyEntryTitle`,
   `aiTutorJourneyEntryDesc`) — confirmed unused by grep before
   removing, not assumed.
5. Two now-unused imports (`go_router`, `../../../app/router.dart`) —
   confirmed via `flutter analyze`'s own `unused_import` warnings
   after step 1–2, not assumed.

**Checked, not assumed, that this didn't hide a wider problem**:
`tutor_presentation.dart` and `tutor_action_navigator.dart` — the two
files `TutorHomeScreen`'s doc comment says were factored out of it —
were swept separately for any F5/F6/F7 import and found clean; kept in
full. `tutor_home_screen_test.dart` doesn't reference
`_JourneyEntryCard`/`learningJourney` anywhere, so no test content
needed trimming to match.

This is the same class of finding as P4's `scheduler_repository_impl.dart`
and F3's `learning_session_controller_test.dart` — a file correctly
identified as "F4's own" by directory still needed a piece of later
work's content surgically removed from inside it.

## 6 — Every touched import verified

Full sweep across all new/modified files in this commit for any
`learning_journey`/`smart_learning`/`read_model` reference:

```
grep -rn "^import" <all F4 files> | grep -iE "learning_journey|smart_learning|read_model"
→ (empty)
```

`ai_tutor_repository_impl.dart` imports `AnalyticsRepository` only —
confirmed directly against the class's own doc comment discipline
("Do not access AnalyticsRepository directly from UI. Only consume
AITutorRepository providers.") — a real, already-merged dependency
(F3), not leakage. `tutor_action_navigator.dart` imports
`flashcards/domain/entities/smart_deck_type.dart` (F2, already
merged) — also legitimate.

## 7 — Every modified file confirmed to belong to F4 only

`git status --porcelain` after the commit shows a clean tree. F4's own
commit (`7c6cc59`) touches exactly 32 files: 22 own files + 2
surgically-separated shared groups (router.dart, 7 l10n files) + the
1 file requiring the §5 code removal (`tutor_home_screen.dart`,
already counted in the 22). No 33rd file, no F5–F8 inclusion.

## 8 — Dependency verification: zero on F5–F8

| Check | Result |
|---|---|
| Import sweep (§6) | Zero matches for any F5–F8 module path |
| `lib/features/learning_journey/`, `smart_learning/`, `read_model/` | Still 0 files each on this branch — untouched |
| F2 (Flashcards), F3 (Analytics) | **Satisfied** — both merged via PR #13, confirmed in §1 |
| P1, P2, P3, P4 | **Satisfied** — merged (PR #3, #5, #11, #12) |

**Downstream**: F5 (Learning Journey) depends on F4, per
`G8_DECOMPOSITION.md` — and specifically on `TutorHomeScreen`, which
F5's own commit will need to re-extend with its own `_JourneyEntryCard`
addition (removed here, §5) as part of F5's own scope.

## 9 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 293 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` — clean after the code removal in §5 (first pass surfaced 1 `undefined_getter`, then 2 `unused_import` after the primary fix) |
| `flutter test test` (full suite) | **669/669 pass** — zero regressions |

## 10 — `git diff` verification

```
git diff origin/main --shortstat
32 files changed, 3146 insertions(+), 3 deletions(-)
```

## 11 — State

| | |
|---|---|
| Branch | `feat/f4-ai-tutor` |
| HEAD | `7c6cc59` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 12 — Remaining G8 work after F4

```
F5   Learning Journey   ← needs F4 (this PR); will need to
                            re-add a Journey entry point into
                            TutorHomeScreen (or its own screen) as
                            its own scope — see §5
F6   Smart Learning     ← needs F4, F5
F7   Read Model         ← needs F4, F5, F6
F8   Learning Session (wiring) ← needs F2 (merged); independent of F4
```

`docs/knowledge/provider_read_flow.md` and the Sprint 20 accessibility
docs (flagged during F2/F3) remain unclaimed by any single F-group and
were not touched this phase either — still pending until enough of
F5–F7 exists for either document to describe a complete, buildable
state.

---

READY FOR F4 PR
