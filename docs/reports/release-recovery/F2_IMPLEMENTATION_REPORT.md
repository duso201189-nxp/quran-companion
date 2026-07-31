# F2 Implementation Report — Flashcards (browse, add, decks, smart deck, review)

Source of truth: `G8_FEATURE_MATRIX.md`, `G8_DECOMPOSITION.md` §F2.
Branch: `feat/f2-flashcards`, cut from `origin/main` at `c2f94fb`
(PR #2–#12 merged, including P4). **2 commits: F1 (cherry-picked
prerequisite) + F2 (new, this phase's own scoped commit). Not pushed,
no PR opened.**

---

## 0 — Correction to task context, verified independently

The task states F1 has been merged into `origin/main`. Checked before
proceeding, same discipline that caught the P4 discrepancy two phases
ago: **F1 has not been merged**, and its branch was never even pushed.

```
git fetch origin --prune --quiet
git ls-remote origin 'refs/pull/*/head'   → refs/pull/1 through /12 only, no #13
git log origin/main --oneline -1          → c2f94fb (PR #12 / P4, confirmed genuinely merged this time)
git merge-base --is-ancestor 271236b origin/main   → NO
```

Unlike the P4 case, **this is a real, hard dependency** — confirmed
directly in `G8_DECOMPOSITION.md`: *"F2 — Flashcards | Dependencies |
F1, `learning` ..., P1, P2, P3"*. F2's own code imports Lexicon types
(`LexiconEntry`, `Lemma`, etc.) directly, so it cannot compile without
F1 present.

**Resolution**: confirmed F1's commit (`271236b`, still present
locally) has zero file overlap with P4 and reapplies cleanly onto
current `origin/main` (`git apply --check --binary`, exit 0). Cut this
branch from `origin/main`, cherry-picked F1's exact existing commit
first (preserving its own history/message from the prior phase), then
built F2 as its own separate, newly-scoped commit on top — mirroring
the same pattern this engagement used earlier for G1+G6, where a
missing merged prerequisite was resolved by widening the branch rather
than the commit. **F2's own commit contains only F2's files** (§3);
F1's content is a distinct, separately-attributed commit, not folded
into F2's diff.

## 1 — Branch construction

```
git checkout -b feat/f2-flashcards origin/main   # base: c2f94fb
git cherry-pick 271236b                          # F1, applies clean, 0 conflicts
# ... F2 extraction and surgery (this report) ...
git commit                                       # F2, new commit c10b9f7
```

## 2 — Extraction methodology

Same precedent as P1/P3/P4/F1: F2 is not its own commit anywhere in
history — a named slice inside `d4976b0`. Content extracted via
`git diff --binary HEAD d4976b0 -- <files>` (diffed against this
branch's HEAD, i.e. after F1+P4 are already present, not against bare
`origin/main`), applied as patches, verified, committed.

## 3 — Scope: F2's own 20 files, plus 6 shared files requiring surgery

**F2's own directory — 19 lib + 5 test files, all Added, zero
ambiguity:**

```
lib/features/flashcards/  (19 files: data/, domain/, presentation/, presentation/widgets/)
test/flashcard_filter_test.dart
test/flashcard_repository_test.dart
test/flashcard_tile_test.dart
test/flashcard_ux_test.dart
test/smart_deck_selector_test.dart
```

**6 shared files required manual separation**, because their
`d4976b0` diffs bundle F2 together with later groups. Each was
checked by content, not assumed clean from its path:

| File | What was kept (F2) | What was excluded, and why |
|---|---|---|
| `lib/app/router.dart` | 6 imports + `flashcards`/`addFlashcard`/`flashcardDecks`/`smartDeck`/`flashcardReview` route constants + 5 `GoRoute` entries | `progressDashboard`/`aiTutor`/`learningJourney`/`smartLearning` imports, constants, and routes — F3/F4/F5/F6 |
| `lib/features/study/presentation/study_screen.dart` | Flashcard card's doc-comment update + `onTap: () => context.push(AppRoutes.flashcards)` | Two new tool cards (`studyProgress`→Progress Dashboard, `studyAiTutor`→AI Tutor) — F3/F4 |
| `lib/l10n/{app_vi,app_en,app_ar}.arb` + 4 generated `app_localizations*.dart` | 49 new `flashcard*`/`addFlashcard*`/`smartDeck*` keys + 1 value update (`studyFlashcardsDesc`, now describing the real vocabulary feature instead of the old Ayah-based placeholder) | 114 other new keys: `homeLoading`/`homeTodaysVerseLoading` (unrelated Sprint 20 fix), `studyProgress*`/`progressDashboard*`/`stat*`/`history*`/`insights*`/`goal*`/`achievement*` (F3), `aiTutor*` (F4), `learningJourney*`/`journey*` (F5), `smartLearning*` (F6), `learningSummaryFlashcardCount` (F8). Determined by a full JSON keyset diff (`python3`, comparing parsed `.arb` dicts), not by scanning lines — confirmed exhaustive |
| `lib/features/learning/domain/entities/srs_card.dart` | `LearningItemType { ayah, lemma }` | The `updatedAtMs` field — its own doc comment reads *"Thêm ở Sprint 14 Phase 1 (Learning Analytics)"*, explicit F3 scope |
| `lib/features/learning/domain/repositories/scheduler_repository.dart` | `syncItemsForType(itemType, ids)` abstract method | Nothing else touched this file |
| `lib/features/learning/data/scheduler_repository_impl.dart` | `syncItemsForType` implementation, `syncWithReviewQueue` now delegates to it | The `updatedAtMs: row.updatedAt` population line in `_toEntity` — same F3 exclusion as above |

**Ripple fixes required** once `LearningItemType.lemma` and
`updatedAtMs`'s removal were applied, caught by `flutter analyze`
exactly as intended:

| File | Fix |
|---|---|
| `test/scheduler_repository_test.dart` | Restored the `syncItemsForType (Sprint 13 Phase 2)` test group (4 tests) that P4's extraction had deliberately removed and earmarked for this phase (`P4_IMPLEMENTATION_REPORT.md` §12) |
| `test/flashcard_filter_test.dart`, `test/flashcard_tile_test.dart`, `test/smart_deck_selector_test.dart` | Removed the `updatedAtMs: 0` constructor argument each had (present in `d4976b0`'s version since that entity had the field there) |
| `test/learning_session_screen_test.dart`, `test/review_session_screen_test.dart` | Both have a `_FakeSchedulerRepository` implementing the interface. Applied `d4976b0`'s own fix verbatim: `watchAllCards`'s fake previously ignored the `itemType` filter entirely (harmless with only `ayah` existing; a real bug once `lemma` cards can exist too) and both needed a `syncItemsForType` override to satisfy the widened interface. The matching `updatedAtMs: 0` addition in each file's `_card`/`_dueCard` helper was excluded, same as above |

**Explicitly excluded in full**, surfaced by an initial content sweep
for "flashcard" but confirmed to be a separate initiative, not F2:

| File | Why excluded |
|---|---|
| `lib/features/home/presentation/home_screen.dart` | A 278-line diff, entirely a Sprint 20 Phase 2 Task 5 accessibility/loading-state fix (`surahsAsync.when()` replacing silent `.valueOrNull`). "Flashcards" appears exactly once, inside a code comment listing 6 other screens already using this pattern — a passing reference, not a functional dependency |
| `docs/knowledge/accessibility_audit.md`, `docs/knowledge/accessibility_checklist.md` | Both brand-new files, explicitly scoped to *"8 màn hình: Home, Reading, Search, Flashcards, Analytics, AI Tutor, Learning Journey, Smart Learning"* — a cross-cutting Sprint 20 audit spanning screens that don't exist on this branch (Analytics, AI Tutor, etc.), not attributable to F2 alone |

This is a genuine, previously-undocumented finding: `d4976b0` contains
at least one more slice beyond P1–P4/F1–F8 — a Sprint 20 UX/
accessibility initiative touching `home_screen.dart` and producing two
audit docs, cutting across every later feature. Worth flagging for
whoever scopes the eventual F3–F8 extractions, since the same
entanglement will likely recur.

## 4 — Every touched import verified

Full sweep across all new/modified `.dart` files in this commit for
any `analytics`/`ai_tutor`/`smart_learning`/`read_model`/
`learning_journey`/`progress_dashboard` reference:

```
grep -rn "^import" <all F2 files> | grep -iE "analytics|ai_tutor|smart_learning|read_model|learning_journey|progress_dashboard"
→ (empty)
```

`flashcard_repository_impl.dart` imports `core/logging/*` (P1) and
`core/database/user/user_database.dart` (P3's `FlashcardDecks`/
`Flashcards` tables) — both already merged, both correctly in scope as
real dependencies, not leakage.

## 5 — Every modified file confirmed to belong to F2 only

`git status --porcelain` after the commit shows a clean tree. F2's own
commit (`c10b9f7`, diffed against the F1 baseline `07b054d`) touches
exactly 39 files — the 24 own files plus the 6 surgically-separated
shared files (`router.dart`, `study_screen.dart`, 3 `.arb` + 4
generated `.dart` l10n files, `srs_card.dart`,
`scheduler_repository.dart`, `scheduler_repository_impl.dart`) plus
the 3 ripple-fix files (`scheduler_repository_test.dart`,
`learning_session_screen_test.dart`, `review_session_screen_test.dart`).
No 40th file, no accidental F3–F8 inclusion.

## 6 — Dependency verification: zero on F3–F8

| Check | Result |
|---|---|
| Import sweep (§4) | Zero matches for any F3–F8 module path |
| `lib/features/analytics/`, `ai_tutor/`, `learning_journey/`, `smart_learning/`, `read_model/` | Still 0 files each on this branch — untouched |
| F1 (Lexicon) | **Required and present** — layered in as its own commit (§0), not F2's own scope |
| P1, P2, P3 | **Satisfied** — merged (PR #3, #5, #11) |
| P4 | **Satisfied** — merged (PR #12), confirmed genuinely this time |
| `learning` (Sprint 10 scheduler) | **Satisfied** — merged (PR #10) |

**Downstream**: F3 (Analytics), F8 (Learning Session wiring — the
`flashcardsCompleted` placeholder field G7 left, per
`G7_EXTRACTION_REPORT.md` §4) both depend on F2, per
`G8_DECOMPOSITION.md`.

## 7 — Validation

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 250 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` — clean after fixing the `updatedAtMs`/`syncItemsForType` ripple effects in §3 (first pass surfaced 6 issues, all traced and fixed) |
| `flutter test test` (full suite) | **593/593 pass** — zero regressions |

## 8 — `git diff` verification

F2's own commit, relative to the F1 baseline already on this branch:

```
git diff 07b054d --stat (39 files)
39 files changed, 4425 insertions(+), 42 deletions(-)
```

Whole branch, relative to `origin/main` (F1 + F2 combined, since that's
what actually needs to build/test together):

```
git diff origin/main --shortstat
69 files changed, 7685 insertions(+), 42 deletions(-)
```

## 9 — State

| | |
|---|---|
| Branch | `feat/f2-flashcards` |
| HEAD | `c10b9f7` |
| Commits ahead of `origin/main` | 2 (`07b054d` F1, `c10b9f7` F2) |
| Working tree | Clean |
| Pushed? | No |
| PR opened? | No |

## 10 — Remaining G8 work after F2

```
F1   Lexicon                        ← implemented, included on this
                                        branch, but still needs its OWN
                                        merge (separate PR from F2)
F8   Learning Session (wiring)      ← needs F2 (this PR)
F3   Analytics                      ← needs F1, F2 (this PR); will
                                        need updatedAtMs on SrsCard —
                                        excluded here, flagged as F3's
                                        own scope to reintroduce
F4   AI Tutor                       ← needs F2, F3
F5   Learning Journey               ← needs F4
F6   Smart Learning                 ← needs F4, F5
F7   Read Model                     ← needs F4, F5, F6
```

Also worth flagging for whichever phase picks this up: the Sprint 20
UX/accessibility slice found in §3 (`home_screen.dart` +
`docs/knowledge/accessibility_{audit,checklist}.md`) is not part of
any single F-group's dependency chain — it will need its own
extraction pass once enough of F3–F6's screens exist for the audit to
make sense as a coherent unit.

---

READY FOR F2 PR
