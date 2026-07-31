# F6 Implementation Report — Smart Learning (session recommendations, strategy grouping)

Source of truth: `G8_FEATURE_MATRIX.md`, `G8_DECOMPOSITION.md` §F6.
Branch: `feat/f6-smart-learning`, cut directly from `origin/main` at
`ff14bb4`. **1 commit — this phase's own scoped commit. Not pushed, no
PR opened.**

---

## 1 — Objective 1: PR #15 (F5) verified on `origin/main`

Checked independently before proceeding, same discipline applied
every phase since P4:

```
git fetch origin --prune --quiet
git log origin/main --oneline -3
ff14bb4 Merge pull request #15 from duso201189-nxp/feat/f5-learning-journey
981e04c feat(learning_journey): add Learning Journey — daily plan, progress, steps (F5)
f9ae143 Merge pull request #14 from duso201189-nxp/feat/f4-ai-tutor

git merge-base --is-ancestor 981e04c origin/main   → YES merged
```

Directory file counts confirmed directly:

```
lib/features/lexicon/          : 11 files
lib/features/flashcards/       : 19 files
lib/features/analytics/        : 16 files
lib/features/ai_tutor/         : 15 files
lib/features/learning_journey/ : 11 files
lib/features/{smart_learning,read_model}/ : 0 files each
```

## 2 — Branch created cleanly from current `origin/main`

```
git checkout -b feat/f6-smart-learning origin/main
```

No prerequisite layering needed — F6's dependency (F5, per
`G8_DECOMPOSITION.md`: *"F6 — Smart Learning | Dependencies | F4, F5,
`search`, P2"*, all already merged) is already on `main`.

## 3 — Extraction methodology

Same precedent as every prior group: F6 is not its own commit anywhere
in history — a named slice inside `d4976b0`. Content extracted via
`git diff --binary HEAD d4976b0 -- <files>`, applied as patches,
verified, committed.

## 4 — Scope: F6's own 20 files, plus 1 shared group, plus 2 corrections

**F6's own directory — 13 lib + 7 test files, all Added.** The initial
pattern search (`test/*smart_learning*`) found 5 of the 7 test files;
a broader sweep for any new test importing `features/smart_learning`
caught the other two (`test/recommendation_card_test.dart`,
`test/session_summary_card_test.dart`) — the same class of miss found
during F3's and F5's extractions, now systematically checked for every
time.

**1 shared group, and it was genuinely clean this time:**

| Group | What was kept (F6) | Note |
|---|---|---|
| `lib/app/router.dart` | 1 import + `smartLearning` route constant + 1 `GoRoute` | Unlike every prior group, this diff carried **nothing** beyond F6's own addition — F5 had already trimmed the router down to exactly its own scope, leaving no F7 content mixed in |
| `lib/l10n/*` (3 `.arb` + 4 generated) | 12 `smartLearning*`/`smartLearningStrategy*` keys | Excluded `learningSummaryFlashcardCount` (F8) and the pre-existing `homeLoading`/`homeTodaysVerseLoading` (Sprint 20) — confirmed via the same full JSON-keyset-diff method as every prior group |

## 5 — Two corrections, continuing the pattern from every prior F-group

**A. Removal**: `lib/features/smart_learning/domain/entities/smart_learning_session.dart`
(F6's own new file, extracted wholesale) arrived already carrying a
`journey` field. Its own doc comment read *"[journey] THÊM MỚI (Sprint
18 Phase 1)"* — added later so `LearningSnapshotRepository` (F7) could
read the full `LearningJourney` through `SmartLearningRepository.
getSmartLearningSession()` without depending on
`LearningJourneyRepository` directly (the doc comment even cites
`lib/features/read_model/domain/learning_snapshot_generator.dart` by
path). Removed the field and its doc-comment paragraph. Kept the
generator (`smart_learning_session_generator.dart`) accepting
`LearningJourney` as a parameter and using
`journey.todayPlan.steps` to compute recommendations — only the
*storage* of the object on the returned session was F7 scope, not
F6's own computation.

**B. Restoration, found by test failure, not the sweep**:
`lib/features/learning_journey/presentation/learning_journey_screen.dart`
(an F5 file, already merged) — `d4976b0` restores
`_SmartLearningEntryCard` here, which F5's own extraction correctly
excluded and documented as F6's deferred work
(`F5_IMPLEMENTATION_REPORT.md` §5B, §12). **This restoration was
missed on the first extraction pass in this phase.** The initial
content sweep searched every non-`smart_learning/` file for the
literal strings `"SmartLearningRepository|SmartLearningSession|
SmartLearningScreen|SessionStrategy"` — none of which appear in this
widget, since it only references the `AppRoutes.smartLearning`
constant and two l10n keys (`journeyEntrySmartLearningTitle`/`Desc`).
`flutter test` caught the gap, not the sweep: two
`smart_learning_screen_test.dart` tests navigate **from**
`LearningJourneyScreen` through this exact card into
`SmartLearningScreen`, and both failed with *"Found 0 widgets with
text 'Get your Smart Session'"*. Investigated the failure rather than
adjusting the test, traced it to the missing widget, and applied
`d4976b0`'s restoration verbatim (the widget class, its call site, and
its two l10n keys) — confirmed clean of any F7 content itself before
applying.

This finding is recorded honestly rather than smoothed over: the sweep
methodology (grep for type/class names) has a real blind spot for
widgets that only reference a route constant and l10n keys by name.
`flutter test`'s own coverage of cross-screen navigation is what
actually caught it here — a concrete argument for treating the test
run as a verification step in its own right, not just a formality
after the sweep.

## 6 — Every touched import verified

Full sweep across all new/modified files in this commit for any
`read_model` reference:

```
grep -rn "^import" <all F6 files> | grep -i "read_model"
→ (empty)
```

A follow-up content sweep (not just imports) for `"Sprint 18"`,
`"read_model"`, `"ReadModel"`, `"LearningSnapshot"` across every
touched file also returned nothing — confirming §5A's removal was
complete, not just the field declaration.

`smart_learning_repository_impl.dart` composes
`LearningJourneyRepository` only — a real, already-merged dependency
(F5), not leakage.

## 7 — Every modified file confirmed to belong to F6 only

`git status --porcelain` after the commit shows a clean tree. F6's own
commit (`55355c4`) touches exactly 29 files: 20 own files + 1
surgically-verified shared group (router.dart, 7 l10n files) + 1 F5
file requiring restoration (`learning_journey_screen.dart`). No 30th
file, no F7–F8 inclusion.

## 8 — Dependency verification: zero on F7–F8

| Check | Result |
|---|---|
| Import sweep (§6) | Zero matches for any F7–F8 module path |
| `lib/features/read_model/` | Still 0 files on this branch — untouched |
| F4 (AI Tutor), F5 (Learning Journey) | **Satisfied** — merged via PR #14/#15, confirmed in §1 |
| P1, P2, P3, P4 | **Satisfied** — merged (PR #3, #5, #11, #12) |

**Downstream**: F7 (Read Model) depends on F4, F5, F6, per
`G8_DECOMPOSITION.md` — and specifically on the `journey` field
removed in §5A, which F7's own commit will need to reintroduce as part
of its own scope, along with `LearningSnapshotRepository`'s dependency
on it.

## 9 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 331 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` — clean after the §5A field removal (zero ripple; nothing else constructed `SmartLearningSession` with `journey:`) |
| `flutter test test` (full suite) | **720/720 pass** — 2 genuine failures found on the first run (§5B), fixed by restoring the missing widget, zero regressions after |

## 10 — `git diff` verification

```
git diff origin/main --shortstat
29 files changed, 1707 insertions(+), 3 deletions(-)
```

## 11 — State

| | |
|---|---|
| Branch | `feat/f6-smart-learning` |
| HEAD | `55355c4` |
| Commits ahead of `origin/main` | 1 |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 12 — Remaining G8 work after F6

```
F7   Read Model                ← needs F4, F5, F6 (this PR); will need
                                   to reintroduce SmartLearningSession.
                                   journey (removed here, §5A) as its
                                   own scope — LearningSnapshotRepository
                                   depends on it to avoid coupling to
                                   LearningJourneyRepository directly
F8   Learning Session (wiring) ← needs F2 (merged); independent of F6
```

`docs/knowledge/provider_read_flow.md` (flagged during F2/F3, still
unaddressed) documents all five repository layers F3–F7 as one frozen
architecture written at Sprint 18 Phase 2 — will finally become
attributable to a single phase once F7 lands, since Sprint 18 is F7's
own sprint. The Sprint 20 accessibility docs remain unclaimed by any
single F-group and still pending.

---

READY FOR F6 PR
