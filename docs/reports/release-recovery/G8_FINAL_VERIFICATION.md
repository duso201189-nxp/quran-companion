# G8 Final Verification — re-analyzed against current `origin/main`

Read-only analysis. No code changed, no branch created, nothing
committed, no cherry-pick, no rebase. Verified against `origin/main` at
`e0b20c4` (`Merge pull request #10 from
.../feat/sprint10-learning-engine`) — confirmed independently before
writing anything below, not taken on faith from the task's own status
summary:

```
git ls-remote origin 'refs/pull/*/head'   → refs/pull/1 through /10 exist
git merge-base --is-ancestor 3ae9981 origin/main   → YES, merged
```

Source of truth: `G8_DECOMPOSITION.md`, `MAIN_RECOVERY_ROADMAP.md`,
cross-referenced against `G8_RELEASE_SEQUENCE.md` for the originally
planned order.

---

## 1 — Every prerequisite identified in `G8_DECOMPOSITION.md` / `MAIN_RECOVERY_ROADMAP.md`

| Prerequisite | Source | Status |
|---|---|---|
| P1 (Reliability layer) merged | `G8_DECOMPOSITION.md` | **Satisfied** — PR #3, confirmed: `lib/core/error/`, `lib/core/logging/` present on `main` |
| P2 (Shared widgets) merged | `G8_DECOMPOSITION.md` | **Satisfied** — PR #5 |
| G2 My Library merged | `MAIN_RECOVERY_ROADMAP.md` | **Satisfied** — PR #4, `lib/features/library/` = 13 files on `main` |
| G3 Reading Polish merged | `MAIN_RECOVERY_ROADMAP.md` | **Satisfied** — PR #6 |
| G4 Search Foundation merged | `MAIN_RECOVERY_ROADMAP.md` | **Satisfied** — PR #7, `lib/features/search/` = 4 files |
| G5 Sprint 8 (schema v3) merged | `MAIN_RECOVERY_ROADMAP.md` | **Satisfied** — PR #8 |
| G6 Sprint 9 (+ G1 governance) merged | `MAIN_RECOVERY_ROADMAP.md` | **Satisfied** — PR #9 |
| G7 Sprint 10 (schema v4/v5) merged | `MAIN_RECOVERY_ROADMAP.md` | **Satisfied** — PR #10 |

**Every prerequisite either document identified is now satisfied.**

## 2 — The five required tables

Checked directly against `lib/core/database/user/user_tables.dart` and
`user_database.dart` on current `origin/main`, not assumed from the PR
history alone:

| Table | Present? | Registered in `@DriftDatabase(tables: [...])`? |
|---|---|---|
| `StudySessions` | **Yes** (`study_sessions`) | Yes |
| `KhatmCycles` | **Yes** (`khatm_cycles`) | Yes |
| `BookmarkCollections` | **Yes** (`bookmark_collections`) | Yes |
| `SrsCards` | **Yes** (`srs_cards`) | Yes |
| `QuizResults` | **Yes** (`quiz_results`) | Yes |

`schemaVersion` confirmed **`5`**, with both migration steps
(`if (from < 4)` creates `srsCards`, `if (from < 5)` creates
`quizResults`) present in `MigrationStrategy`. All 5 tables verified
present — not just referenced in a comment.

## 3 — The decisive structural finding

Before recomputing individual dependencies, one check settles nearly
all of them at once. `G8_DECOMPOSITION.md` traced P3's original
blocker to `d4976b0~1` (the tip of `sprint1-my-library` immediately
before the G8 mega-commit) containing schema state `main` didn't have.
With G2–G7 now fully merged, the natural question is: **how much of
that gap is left?**

```
git diff --shortstat d4976b0~1 origin/main
25 files changed, 2053 insertions(+), 0 deletions(-)
```

**Only 25 files differ at all, and all 25 are pure additions** — every
one of them is P1 (reliability layer: `lib/core/error/`,
`lib/core/logging/`, its docs and tests) or P2 (shared widgets:
`lib/shared/widgets/*` and its test) or their associated CHANGELOG/doc
entries. **Zero deletions. Zero modifications to any file outside
those 25.** In other words: `origin/main` right now *is*
`d4976b0~1`, plus P1 and P2 layered on top as pure additions that
touch nothing G8 touches.

Cross-checked for overlap: of the 229 files `d4976b0` itself modifies,
22 fall inside that same 25-file set (P1/P2 were themselves originally
slices of `d4976b0`, so of course the mega-commit's own diff recreates
them). Byte-compared each of those 22 against `d4976b0`'s own version:
**20 match exactly; 2 differ**, and both differences are the specific,
already-documented trims made during the P1/P2 extraction phases
(`RELIABILITY_PR_REPORT.md`, `P2_IMPLEMENTATION_REPORT.md`) — confirmed
by reading the actual diffs, not assumed from memory:

- `test/repository_boundary_logging_test.dart`: `main`'s version is
  missing one test group that constructs
  `BookmarkCollectionRepositoryImpl(db, logger)` — the 2-argument
  constructor P4 introduces. This isn't a new problem; it's the exact
  trim P1's extraction made because P4 hadn't landed yet. **P4 landing
  will restore this content**, not create a new conflict.
- `test/shared_widgets_a11y_test.dart`: `main`'s version defines
  `localizedTestApp()` locally instead of importing it from
  `test/fixtures/search_test_harness.dart` — the exact substitution
  P2's extraction made because Search didn't exist yet. Zero functional
  difference now that Search exists; nothing depends on switching it
  back.

**Capstone check**: applied the entirety of `d4976b0`'s remaining diff
(all 229 files, minus the 22 already-accounted-for P1/P2 files) against
`origin/main` in one shot via `git apply --check --binary` in a
throwaway worktree:

```
EXIT CODE: 0
```

**The entire remaining G8 diff — P3, P4, and all of F1 through F8 —
applies cleanly to current `main` as a single patch, mechanically.**
This was verified empirically, not inferred from file presence alone.

## 4 — Dependencies recomputed: P3, P4, F1–F8

With the structural blocker resolved, what follows are the **logical**
build-order dependencies — which pieces need which other pieces to
exist *in the tree* before they make sense to merge, independent of
whether the patch mechanically applies (it does, for all of them, per
§3).

| Group | Depends on | Status of each dependency |
|---|---|---|
| **P3** — Schema migration | Nothing (own tables); gates every feature below needing new tables | **No blocker.** Schema patch empirically apply-checked clean (§3) against `content_tables.dart`/`app_database.dart`/`user_tables.dart`/`user_database.dart`, all confirmed byte-identical to `d4976b0~1` |
| **P4** — Reliability retrofit | P1 (**satisfied**) + existence of `khatm`, `learning`, `library`, `quiz`, `quran`, `stats` (**all now present**) | **No blocker.** 14-file patch (7 `*_repository_impl.dart` + 7 `*_providers.dart`, correcting the original "7 files" estimate which undercounted `quran`'s content/user_content split) empirically apply-checked clean |
| **F1** — Lexicon | P1 (**satisfied**), P3 (**unblocked, not yet merged**) | Purely additive (11 new `lib/` files, 13 new `tool/lexicon/` files, all `Added` — zero collision risk). Genuinely needs P3's `Roots`/`Lemmas`/`Lexemes`/`WordInstances`/`GrammarFeatures`/`Phrases`/`PhraseWordInstances`/`LexiconRelations` tables — confirmed via `lexicon_repository_impl.dart`'s own `AppDatabase` usage, not assumed |
| **F2** — Flashcards | F1, `learning` (**present**), P1 (**sat**), P2 (**sat**), P3 (**unblocked**) | Needs F1's Lexicon entities (Flashcard content points into Lexicon) and P3's `FlashcardDecks`/`Flashcards` tables (the ones `d4976b0` inserts between `SrsCards` and `QuizResults`, confirmed in §3) |
| **F3** — Analytics | F2, F1, `learning`/`search`/`stats` (**all present**), P2 (**sat**) | Sequential on F1/F2 only now — every directory-existence dependency already satisfied |
| **F4** — AI Tutor | F3, F2, `search` (**present**), P2 (**sat**) | Sequential on F2/F3 only |
| **F5** — Learning Journey | F4, `search` (**present**), P2 (**sat**) | Sequential on F4 only |
| **F6** — Smart Learning | F4, F5, `search` (**present**), P2 (**sat**) | Sequential on F4/F5 only |
| **F7** — Read Model | F4, F5, F6 | Inherits the F4→F6 chain; no independent blocker |
| **F8** — Learning Session | F2 only | **Re-verified precisely** — `G8_DECOMPOSITION.md`'s original description ("Files: `lib/features/learning_session/`, 4, all Modified") is confirmed still accurate: F8 does **not** create this directory, it *modifies* the exact 4 files G7 (PR #10) already shipped (`learning_session_summary.dart`, `learning_session_controller.dart`, `learning_session_screen.dart`, `learning_summary_screen.dart`) — checked byte-identity of the pre-F8 state against current `main`: unchanged (implicit in §3's 25-file-only finding). F8's real import dependency on F2 confirmed directly: its diff adds `import '../../flashcards/data/flashcard_providers.dart'` and wires `FlashcardReviewScreen` into the session flow — this is precisely what the `flashcardsCompleted` placeholder field (found always-zero in G7's own code, `G7_EXTRACTION_REPORT.md` §4) exists to be filled in by. Not a stale assumption — a real, still-open dependency |

**No group's dependency list contains anything unsatisfied that isn't
itself another G8 group already accounted for in this table.** No
external (non-G8) prerequisite remains.

## 5 — Newly discovered blocker?

**None found.** Checked deliberately rather than assumed:

- The two test-file mismatches in §3 were investigated in full rather
  than dismissed as "probably fine" — both trace to specific,
  previously-documented, deliberate trims from the P1/P2 extraction
  phases, and one of them (`repository_boundary_logging_test.dart`)
  will be *resolved by P4 landing*, not left dangling.
- The `learning_session` naming overlap between G7 (already-merged,
  creates the directory) and G8's F8 (modifies it) was checked
  explicitly rather than assumed harmless, given it was the exact
  *class* of gap (`CLAUDE.md`) that blocked G6 earlier in this
  engagement. Confirmed **not** a repeat of that pattern: F8's target
  files are confirmed present and byte-identical to what G7 shipped,
  and F8's diff is genuinely `Modified` against that known base, not
  expecting a different unmerged prerequisite.
- The full-diff capstone apply-check (§3) covers every file in every
  remaining G8 slice at once — if any group's patch target had drifted
  from `d4976b0~1`'s assumption, `git apply --check` would have failed
  on it specifically. It did not.

## 6 — Recommended implementation order for remaining G8 work

Cross-referenced against `G8_RELEASE_SEQUENCE.md`'s original plan
(unchanged in substance — only P1/P2, already merged, drop off the
front):

```
1.  P3   Database schema migration        ← next, no dependency left unmet
2.  P4   Reliability retrofit             ← independent of P3, needs
                                              only P1 (merged); may be
                                              sequenced before or in
                                              parallel with P3 if
                                              preferred — kept here to
                                              match the original plan's
                                              order
3.  F1   Lexicon                          ← needs P3
4.  F2   Flashcards                       ← needs F1, P3
5.  F8   Learning Session (wiring)        ← needs only F2; movable
                                              anywhere from here onward,
                                              placed early since it's
                                              the smallest remaining
                                              slice (64 hand-written
                                              lines) and closes the
                                              placeholder G7 already
                                              left for it
6.  F3   Analytics                        ← needs F1, F2
7.  F4   AI Tutor                         ← needs F2, F3
8.  F5   Learning Journey                 ← needs F4
9.  F6   Smart Learning                   ← needs F4, F5
10. F7   Read Model                       ← needs F4, F5, F6
```

**10 pull requests remain** (PR #11 through #20 in this engagement's
running numbering) to fully replace the original `d4976b0` mega-commit
— unchanged from `G8_RELEASE_SEQUENCE.md`'s original count of 12,
minus the 2 (P1, P2) already merged as PR #3 and PR #5.

---

## READY FOR P3
