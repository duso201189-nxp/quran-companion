# Final Extraction Report — G8 mega-commit decomposition

Capstone document for the full `d4976b0` decomposition effort (P1–P4,
F1–F8). Written at the completion of F8, the last group in
`G8_DECOMPOSITION.md`'s enumeration. Read-only analysis plus the
verification already performed while building the F8 branch — no new
commits beyond `feat/f8-learning-session-wiring`'s own `4f395ba`.

---

## 1 — Confirmation: F8 is the last remaining phase

`G8_DECOMPOSITION.md` enumerates exactly twelve groups: **P1, P2, P3, P4,
F1, F2, F3, F4, F5, F6, F7, F8.** Every one now has either a merged PR or
a committed, verified, not-yet-merged branch:

| Group | Status | Ref |
|---|---|---|
| P1 — Reliability layer | **Merged** | PR #3 (`17b92e1`) |
| P2 — Shared accessibility widgets | **Merged** | PR #5 (`2a232ea`) |
| P3 — DB schema migration | **Merged** | PR #11 (`357c7de`) |
| P4 — Reliability retrofit | **Merged** | PR #12 (`c2f94fb`) |
| F1 — Lexicon | **Merged** | PR #13 (`1e70a6d`, combined) |
| F2 — Flashcards | **Merged** | PR #13 (`1e70a6d`, combined) |
| F3 — Analytics | **Merged** | PR #13 (`1e70a6d`, combined) |
| F4 — AI Tutor | **Merged** | PR #14 (`f9ae143`) |
| F5 — Learning Journey | **Merged** | PR #15 (`ff14bb4`) |
| F6 — Smart Learning | Committed, not merged | `feat/f6-smart-learning` (`55355c4`) |
| F7 — Read Model | Committed, not merged | `feat/f7-read-model` (`55355c4`+`d78bcd1`) |
| F8 — Learning Session wiring | Committed, not merged | `feat/f8-learning-session-wiring` (`4f395ba`) |

No thirteenth group exists in the decomposition, and `origin/main`'s PR
sequence (`refs/pull/1` through `/15`, checked directly via
`git ls-remote`) confirms no PR beyond #15 exists yet — F6/F7's own
merges are still pending, and F8 has never been pushed. **This is the
final extraction of the original mega-commit's content; nothing remains
to be sliced out of `d4976b0` that isn't already assigned above.**

## 2 — Verification: every change from `d4976b0` is now assigned

### 2.1 — Method

A direct `git diff HEAD d4976b0` from a single branch is insufficient,
because F6 and F7 exist only on their own separate branches, not stacked
into F8 (§1 of `F8_IMPLEMENTATION_REPORT.md` — F8 has no real dependency
on F6/F7, so it was correctly cut straight from `origin/main`). Merging
all three together purely to diff was tried and abandoned: a
`git cherry-pick` of F8 onto a combined branch hit l10n merge conflicts
(expected — F6/F7 and F8 both add different keys near the same regions
of the `.arb` files) and was aborted rather than resolved, since the
merge itself wasn't needed for verification.

Instead: two diffs were computed independently, each against `d4976b0`,
each representing everything currently *un-reconciled* from the mega-commit
along one branch:

```
git diff --name-status feat/f7-read-model d4976b0   # origin/main + F6 + F7, vs. d4976b0
git diff --name-status feat/f8-learning-session-wiring d4976b0   # origin/main + F8, vs. d4976b0
```

Any file appearing in **both** lists is unaccounted for by *either*
branch — a `comm -12` intersection of the two sorted file lists isolates
exactly that set. Anything NOT in the intersection is already fully
covered by one branch or the other (i.e., already correctly extracted).

### 2.2 — Result: 23 files, all individually classified

```
comm -12 <sorted names from feat/f8-...> <sorted names from feat/f7-...>
→ 23 files
```

| # | Bucket | Files | Disposition |
|---|---|---|---|
| 1 | **Pre-existing recovery-engagement scaffolding — never part of `d4976b0`'s lineage** | `docs/LICENSING.md`, `test/repository_boundary_completeness_test.dart`, `test/repository_boundary_test.dart` | Not a gap. These originate in PR #2 (`ci/repository-boundary-core-gate`), which predates and is unrelated to the G8 decomposition — `d4976b0` never touched them in the first place. |
| 2 | **Sprint 20 — cross-cutting accessibility initiative** | `docs/knowledge/accessibility_audit.md`, `docs/knowledge/accessibility_checklist.md`, `lib/features/home/presentation/home_screen.dart`, `lib/features/search/presentation/widgets/search_error_state.dart`, `test/home_screen_test.dart`, plus 2 l10n keys (`homeLoading`, `homeTodaysVerseLoading`) spread across all 7 `lib/l10n/` files | Intentionally excluded, consistently, since F2's own report first flagged it. Not part of any single P/F group in `G8_DECOMPOSITION.md` — it's a separate, later initiative bundled into the same `d4976b0` commit. Confirmed via re-check: `search_error_state.dart`'s remaining diff is a doc-comment addition only; `home_screen_test.dart` is a dedicated new test for this same initiative. |
| 3 | **Sprint 18 Phase 2 doc** | `docs/knowledge/provider_read_flow.md` | Intentionally excluded by F7 (its own report §5) — the document's own opening line states it was written at "Sprint 18 Phase 2," distinct from F7's "Sprint 18 Phase 1" scope. Re-confirmed here: none of the four provider files it documents (Analytics/AI Tutor/Learning Journey/Smart Learning) carry any further diff, so nothing beyond the doc artifact itself remains. |
| 4 | **Already-merged phases' own deliberate corrections, diverging from `d4976b0` on purpose** | `test/analytics_repository_impl_test.dart` (F3 fixed a pre-existing hardcoded-date test bug, `F3_IMPLEMENTATION_REPORT.md`), `test/shared_widgets_a11y_test.dart` (P2's inlined-helper trim) | Not a gap — these two files are *better* than `d4976b0`'s own version, by design, and both changes are already merged and documented. |
| 5 | **Genuine, unresolved gap** | `test/achievement_calculator_test.dart`, `test/achievement_card_test.dart`, `test/goal_card_test.dart`, `test/learning_goal_calculator_test.dart`, `test/learning_history_calculator_test.dart` | **See §3.** |

`3 + 12 + 1 + 2 + 5 = 23`, matching the intersection count exactly.

### 2.3 — l10n keys specifically

A JSON-keyset diff (not a line diff) between `d4976b0`'s `app_en.arb`
and the union of (`feat/f8-learning-session-wiring` ∪
`feat/f7-read-model`) confirms only **2 keys** remain truly unclaimed by
either branch: `homeLoading`, `homeTodaysVerseLoading` — both Sprint 20
(bucket 2 above). Every other key, including F6's 8
`smartLearning*` keys and F7's namespace, is present on one branch or
the other.

## 3 — The one genuine gap, reported honestly

**Five test files, dedicated to F3 (Analytics), were never extracted
during F3's original pass and are missing from `main` today**, even
though F3 itself is fully merged (PR #13):

- `test/achievement_calculator_test.dart`
- `test/achievement_card_test.dart`
- `test/goal_card_test.dart`
- `test/learning_goal_calculator_test.dart`
- `test/learning_history_calculator_test.dart`

Confirmed via their imports that all five test **already-shipped,
unchanged F3 library code** — `features/analytics/domain/achievement_calculator.dart`,
`.../learning_goal_calculator.dart`, `.../learning_history_calculator.dart`,
`.../presentation/widgets/achievement_card.dart`, `.../widgets/goal_card.dart`
— none of which have any outstanding diff themselves. This is a
**test-coverage gap in already-merged production code**, not missing
application logic, and not something any later phase (F4–F8) could have
been expected to catch, since none of them touch the Analytics feature.

**Why this can't be fixed inside F8**: F8's stated scope is Learning
Session/Flashcards wiring. Pulling in five unrelated Analytics test files
would violate the same single-responsibility-per-branch discipline this
entire engagement has enforced from P3 onward, and would make F8's diff
harder to review for what it actually is.

**Recommended remediation**: a small, additive-only follow-up PR —
`test(analytics): restore 5 test files missed during F3 extraction`,
cut from `origin/main` once F6/F7/F8 all land, adding exactly these five
files verbatim from `d4976b0` with zero production-code changes. Risk is
effectively zero: it only adds coverage for code that is already live and
unchanged.

## 4 — Final statistics

### 4.1 — Original scope

`d4976b0` vs. its own parent commit: **229 files changed, 31,580
insertions(+), 2,627 deletions(-).**

### 4.2 — Per-group extraction size (own commit, not merge-deduplicated)

| Group | Files | (+) | (-) | Status |
|---|--:|--:|--:|---|
| P1 | 17 | 969 | 0 | Merged, PR #3 |
| P2 | 5 | 377 | 0 | Merged, PR #5 |
| P3 | 7 | 9,100 | 1,908 | Merged, PR #11 |
| P4 | 27 | 838 | 610 | Merged, PR #12 |
| F1 | 30 | 3,260 | 0 | Merged, PR #13 |
| F2 | 39 | 4,425 | 42 | Merged, PR #13 |
| F3 | 38 | 3,586 | 3 | Merged, PR #13 |
| F4 | 32 | 3,146 | 3 | Merged, PR #14 |
| F5 | 27 | 1,846 | 10 | Merged, PR #15 |
| F6 | 29 | 1,707 | 3 | Committed, unmerged |
| F7 (own commit only) | 12 | 605 | 8 | Committed, unmerged |
| F8 | 12 | 213 | 18 | Committed, unmerged |
| **Sum of above** | **275** | **30,072** | **2,605** | |

The sum's file count (275) exceeds `d4976b0`'s own 229 because several
files are touched by more than one group and counted once per group —
`lib/app/router.dart`, all 7 `lib/l10n/` files, and the recurring
"entry-card" chain files (`tutor_home_screen.dart`,
`learning_journey_screen.dart`, `smart_learning_session.dart`,
`smart_learning_session_generator.dart`) are each claimed by 2–6 groups
in sequence, by design (§ established pattern across every prior report
in this engagement). Insertion/deletion totals are close (30,072 vs.
31,580 net insertions; 2,605 vs. 2,627 net deletions) but not exact, for
the same reason plus the bucket-2/3/4/5 exclusions in §2.2 that
deliberately don't appear in any group's own diff.

### 4.3 — Merged vs. outstanding, at time of writing

| | Files * | (+) | (-) |
|---|--:|--:|--:|
| **Merged** (P1+P2+P3+P4+F1+F2+F3+F4+F5, sum of each PR's own merge-commit stat: 17+5+7+27+91+32+27) | 206 | 27,544 | 2,573 |
| **Committed, not yet merged** (F6+F7+F8) | 53 | 2,525 | 29 |

\* PR #13's merge commit (F1+F2+F3 combined) shows 91 deduplicated files,
not 30+39+38=107, for the same shared-file-overlap reason as §4.2. This
206/53 split is still an approximation, not the completeness proof —
summing PR-level counts still double-counts any file (like
`router.dart` or the `.arb` files) that multiple *different* PRs each
touch once. **§2's set-intersection is the authoritative completeness
check; this table exists only to show relative scale.**

### 4.4 — Unclaimed content, final accounting

| Bucket | Files | Disposition |
|---|--:|---|
| Not part of `d4976b0`'s lineage | 3 | Correctly out of scope |
| Sprint 20 (cross-cutting, not a P/F group) | 12 | Correctly excluded pending its own future phase |
| Sprint 18 Phase 2 doc | 1 | Correctly excluded, consistent with F7's own reasoning |
| Deliberate already-merged improvements | 2 | Not a gap — intentional divergence, documented |
| **Genuine gap** | **5** | **Flagged in §3; recommended as a follow-up PR** |
| **Total accounted for** | **23** | **100% of the residual set is classified — zero unexplained files** |

## 5 — Bottom line

Every file `d4976b0` ever touched is now either (a) merged into `main`
through PR #3–#15, (b) sitting ready on `feat/f6-smart-learning`,
`feat/f7-read-model`, or `feat/f8-learning-session-wiring` awaiting its
own PR, (c) a deliberate, documented, already-justified exclusion, or (d)
the one flagged five-file test-coverage gap in §3, for which a safe,
scoped remediation path is already specified. No silent gaps remain.

---

READY FOR FINAL F8 PR
