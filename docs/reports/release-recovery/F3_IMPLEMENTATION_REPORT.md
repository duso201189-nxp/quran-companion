# F3 Implementation Report — Learning Analytics (statistics, history, insights, goals, achievements)

Source of truth: `G8_FEATURE_MATRIX.md`, `G8_DECOMPOSITION.md` §F3.
Branch: `feat/f3-analytics`, cut from `feat/f2-flashcards` (base
`c2f94fb`, PR #2–#12 merged, including P4). **3 commits: F1 + F2
(cherry-picked prerequisites, already implemented in prior phases) +
F3 (new, this phase's own scoped commit). Not pushed, no PR opened.**

---

## 0 — Correction to task context, verified independently

The task states F2 has been merged into `origin/main`. Checked before
proceeding, same discipline applied every phase since P4: **F2 has
not been merged**, and neither has F1.

```
git fetch origin --prune --quiet
git ls-remote origin 'refs/pull/*/head'   → refs/pull/1 through /12 only, no #13
git log origin/main --oneline -1          → c2f94fb (PR #12 / P4, still the tip)
git merge-base --is-ancestor c10b9f7 origin/main   → NO
git merge-base --is-ancestor 271236b origin/main   → NO
```

F3's real dependency chain (`G8_DECOMPOSITION.md`: *"F3 — Analytics |
Dependencies | F2, F1, ... P2"*) needs both. Resolution: the local
`feat/f2-flashcards` branch (F1 + F2, both already implemented and
reported in prior phases) still has `origin/main`'s current tip as its
exact parent — no rebase needed, confirmed directly
(`git merge-base --is-ancestor origin/main feat/f2-flashcards`). Cut
this branch from it, then built F3 as its own separate, newly-scoped
commit on top — same layering pattern used for F2 on F1, and originally
for G1+G6 earlier in this engagement. **F3's own commit contains only
F3's files** (§3); F1 and F2 remain distinct, separately-attributed
commits.

## 1 — Branch construction

```
git checkout -b feat/f3-analytics feat/f2-flashcards   # base: c2f94fb + F1 + F2
# ... F3 extraction and surgery (this report) ...
git commit                                              # F3, new commit a062573
```

## 2 — Extraction methodology

Same precedent as every prior group: F3 is not its own commit
anywhere in history — a named slice inside `d4976b0`. Content
extracted via `git diff --binary HEAD d4976b0 -- <files>` (diffed
against this branch's HEAD, i.e. after F1+F2 are already present),
applied as patches, verified, committed.

## 3 — Scope: F3's own 20 files, plus 4 shared groups requiring surgery

**F3's own directory — 16 lib + 4 test files, all Added.** The initial
pattern search (`test/*analytics*`, `test/*performance_insights*`)
found only 2 of the 4 test files; a broader sweep for any new test
file importing `features/analytics` caught the other two
(`test/learning_statistics_calculator_test.dart`,
`test/progress_dashboard_screen_test.dart`) that don't have "analytics"
in their filename:

```
lib/features/analytics/  (16 files: data/, domain/, domain/entities/, presentation/, presentation/widgets/)
test/analytics_repository_impl_test.dart
test/performance_insights_selector_test.dart
test/learning_statistics_calculator_test.dart
test/progress_dashboard_screen_test.dart
```

**4 shared groups required manual separation:**

| Group | What was kept (F3) | What was excluded, and why |
|---|---|---|
| `lib/app/router.dart` | 1 import + `progressDashboard` route constant + 1 `GoRoute` | `aiTutor`/`learningJourney`/`smartLearning` imports/constants/routes — F4/F5/F6, same bundled diff pattern as F2 found for this file |
| `lib/features/study/presentation/study_screen.dart` | Progress tool card (`studyProgress`/`studyProgressDesc`, `onTap` → `progressDashboard`) | The AI Tutor card — F4 |
| `lib/l10n/*` (3 `.arb` + 4 generated) | 41 `progressDashboard*`/`stat*`/`history*`/`insights*`/`goal*`/`achievement*` keys | `aiTutor*`, `learningJourney*`/`journey*`, `smartLearning*`, `learningSummaryFlashcardCount` — F4/F5/F6/F8. Determined via the same full JSON-keyset-diff method as F2, not line-scanning |
| `lib/features/learning/domain/entities/srs_card.dart` + `scheduler_repository_impl.dart` | **Restored** the `updatedAtMs` field F2 had deliberately excluded (its own doc comment always read *"Thêm ở Sprint 14 Phase 1 (Learning Analytics)"* — genuinely F3's, confirmed now that F3 is actually being built) | Nothing — this is a pure restoration, not a new exclusion |

## 4 — Ripple fixes from restoring `updatedAtMs`

Restoring the field broke every file constructing an `SrsCard`
without it — `flutter analyze` traced exactly 8, matching the pattern
established during P4/F2:

| File | Fix |
|---|---|
| `test/flashcard_filter_test.dart`, `test/flashcard_tile_test.dart`, `test/smart_deck_selector_test.dart` | Re-added the `updatedAtMs: 0` argument F2 had removed — a clean, single-line restoration each |
| `test/learning_session_screen_test.dart`, `test/review_session_screen_test.dart`, `test/scheduler_providers_test.dart` | Applied `d4976b0`'s own clean 1-line addition |
| `test/learning_session_controller_test.dart` | **Required surgical separation, not a straight apply.** Its `d4976b0` diff bundles the simple `updatedAtMs` fix together with a substantial new test group (`'flashcard completed (Sprint 13 Phase 2)'`), a `_FakeFlashcardQueue` class, and a `dueFlashcardCardsProvider` override wiring Flashcards into Learning Session's `flashcardsCompleted` field (left at a hardcoded 0 by G7, per `G7_EXTRACTION_REPORT.md` §4). That wiring is **F8's own scope** ("Learning Session wiring... needs F2"), not F3's — confirmed against `G8_DECOMPOSITION.md`. Applied only the one-line `updatedAtMs` addition to `_dummyCard`; left the rest of the file untouched |

## 5 — A genuine pre-existing test bug, found and fixed

`flutter test` initially failed one test:
`analytics_repository_impl_test.dart`'s *"gộp SrsCard CẢ 2 loại (ayah
+ lemma) + tái dùng streak đọc thật"* — expected `readingStreakDays >=
1`, got `0`.

Investigated rather than patched blindly: traced
`AnalyticsRepositoryImpl.getLearningStatistics()` →
`StudySessionRepositoryImpl.currentStreak()`, whose logic (unchanged,
already on `main`) compares the most recent logged reading date
against `today ?? DateTime.now()`. The test hardcodes
`date: '2026-07-21'` with **no `today:` override** — every *other*
streak test in this codebase (`study_session_repository_test.dart`)
pins `today:` explicitly for determinism, a pattern this one test
alone didn't follow. `AnalyticsRepositoryImpl` itself exposes no clock
injection at that layer, so the hardcoded date is simply stale
whenever the suite runs more than a day after it was authored — a
latent, pre-existing bug in `d4976b0`'s own test content, not
something this extraction introduced.

**Fix**: log the session for the real current date instead of a fixed
string, matching the test's own stated intent ("reuse the real
streak"). Verified the other two tests in the same file sharing the
same hardcoded date (`getLearningHistory`, `getLearningGoals`) were
unaffected — both pass regardless of wall-clock date, confirming the
streak calculation was the only date-sensitive path.

## 6 — Every touched import verified

Full sweep across all new/modified files in this commit for any
`ai_tutor`/`learning_journey`/`smart_learning`/`read_model` reference:

```
grep -rn "^import" <all F3 files> | grep -iE "ai_tutor|learning_journey|smart_learning|read_model"
→ (empty)
```

`analytics_repository_impl.dart` imports `SchedulerRepositoryImpl`,
`FlashcardRepositoryImpl`, `LexiconRepositoryImpl`,
`StudySessionRepositoryImpl` directly (composing all four, per
`docs/knowledge/provider_read_flow.md`'s architecture, excluded below)
— all already-merged, real dependencies, not leakage.

## 7 — Every modified file confirmed to belong to F3 only

`git status --porcelain` after the commit shows a clean tree. F3's own
commit (`a062573`, diffed against the F2 baseline `c10b9f7`) touches
exactly 38 files: 20 own files + 4 surgically-separated shared
groups (7 files: router.dart, study_screen.dart, 3 `.arb` + 2 of the 4
generated l10n files... — see exact list in §3/§4) + 7 ripple-fix test
files. No 39th file, no F4–F8 inclusion.

**Explicitly excluded**, surfaced by an initial "analytics" content
sweep but confirmed to be a separate initiative:
`docs/knowledge/provider_read_flow.md` — a new file explicitly titled
*"Provider read flow — Analytics → AI Tutor → Learning Journey → Smart
Learning → Read Model"*, written at Sprint 18 Phase 2, documenting all
five repository layers (F3 through F7) as one frozen architecture.
Same class of finding as F2's `home_screen.dart`/accessibility-docs
exclusion — not attributable to F3 alone despite covering it.

## 8 — Dependency verification: zero on F4–F8

| Check | Result |
|---|---|
| Import sweep (§6) | Zero matches for any F4–F8 module path |
| `lib/features/ai_tutor/`, `learning_journey/`, `smart_learning/`, `read_model/` | Still 0 files each on this branch — untouched |
| F1 (Lexicon), F2 (Flashcards) | **Required and present** — layered in as their own commits (§0), not F3's own scope |
| P1, P2, P3, P4 | **Satisfied** — merged (PR #3, #5, #11, #12) |

**Downstream**: F4 (AI Tutor) depends on F3 (and F2), per
`G8_DECOMPOSITION.md`.

## 9 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 270 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` — clean after fixing the `updatedAtMs` ripple (§4) |
| `flutter test test` (full suite) | **623/623 pass** — up from 622 at first attempt (1 genuine failure found and fixed, §5); zero regressions once fixed |

## 10 — `git diff` verification

F3's own commit, relative to the F2 baseline already on this branch:

```
git diff c10b9f7 --shortstat
38 files changed, 3586 insertions(+), 3 deletions(-)
```

Whole branch, relative to `origin/main` (F1 + F2 + F3 combined, since
that's what actually needs to build/test together):

```
git diff origin/main --shortstat
91 files changed, 11268 insertions(+), 42 deletions(-)
```

## 11 — State

| | |
|---|---|
| Branch | `feat/f3-analytics` |
| HEAD | `a062573` |
| Commits ahead of `origin/main` | 3 (`07b054d` F1, `c10b9f7` F2, `a062573` F3) |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 12 — Remaining G8 work after F3

```
F1   Lexicon                        ← implemented, included on this
                                        branch, still needs its own merge
F2   Flashcards                     ← implemented, included on this
                                        branch, still needs its own merge
F8   Learning Session (wiring)      ← needs F2 (present); will
                                        reintroduce the flashcard-
                                        completion wiring excluded from
                                        learning_session_controller_
                                        test.dart here, as its own scope
F4   AI Tutor                       ← needs F2, F3 (this PR)
F5   Learning Journey                ← needs F4
F6   Smart Learning                 ← needs F4, F5
F7   Read Model                     ← needs F4, F5, F6
```

`docs/knowledge/provider_read_flow.md` (§7) remains unclaimed by any
single F-group, same as the Sprint 20 accessibility docs flagged
during F2 — both will need their own extraction once enough of
F4–F7's screens exist for either document to describe a complete,
buildable state.

---

READY FOR F3 PR
