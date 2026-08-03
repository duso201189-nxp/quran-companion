# Phase 3 — Epic Close-out Report

Closes Phase 3 (Sprints R1, R2, R3a, R3b — all committed and pushed to
`main`, HEAD `e59c106`) from a product and release-governance
perspective. No production code or test file was modified to produce
this report — confirmed by `git status` showing zero diff under `lib/`
or `test/` (§6). Written as the Release Manager preparing for public
beta, not as the engineer who did the work — every figure below was
re-measured against the current repository, not carried forward from
earlier documents on trust.

---

## 1. What this close-out did

Three release-tracking documents reviewed; two updated, one reviewed
and found to need exactly one factual correction:

- **`RELEASE_DASHBOARD.md`**: added a "Sprint R3b" completed-work
  entry (§2), added a Critical-tier blocker entry documenting the
  dead-affordance problem as substantially (not fully) resolved (§3),
  added two Medium-tier entries for what R3b left open, added an R3b
  entry to the sprint plan (§4) and updated the recommended release
  order (§8), and added a one-line Go/No-Go clarification (§7) stating
  plainly that R3b checks no new box — rather than leaving that
  ambiguous.
- **`CHANGELOG.md`**: added one `### Fixed — Phase 3 Sprint R3b` entry
  under `[Unreleased]`, matching the R3a entry immediately below it in
  language, structure, and level of detail (Vietnamese, per this
  file's established convention; a per-sub-sprint bullet list; a
  closing note on what's still open).
- **`docs/release/RELEASE_PLAN_V1.md`**: reviewed in full. Found and
  corrected **one** stale factual claim — §3 previously described a
  "locked 'Ask AI' mode button" as existing Search UI scaffolding
  waiting to be wired up; that control no longer exists at all (removed
  outright, Sprint R3b.2). Corrected in place, with the surrounding
  strategic point (Search polish is v1.1 scope) left untouched, per
  this task's "do not rewrite strategy" instruction. **No other
  statement in this document was found stale as a result of R3b** —
  its scope (dead-affordance UI honesty) was never described in this
  document to begin with, so nothing else needed correcting. That is a
  real finding, not a null result: it means `RELEASE_PLAN_V1.md`'s
  Lexicon/D3/D8 analysis remains exactly as accurate as before R3b, and
  the document's silence on UI honesty was itself a release-tracking
  gap this close-out surfaces in §5, not a factual error.

## 2. Product readiness, recalculated

`docs/release/PRODUCT_READINESS_REVIEW.md` (2026-08-03, pre-R3b) is the
baseline — its own four-axis model, not `RELEASE_DASHBOARD.md`'s
differently-weighted table (which predates R1 and has never been
recomputed; see that dashboard's own §1 notes). Every number below was
re-measured today, not adjusted by feel:

| Signal | Pre-R3b (PRR) | Post-R3b | Change |
|---|--:|--:|--:|
| Tests passing | 802 / 802 | **793 / 793** | −9 |
| Coverage, hand-written code (CI policy) | 81.53% | **81.52%** | −0.01pp |
| Coverage, raw (no exclusions) | 51.96% | **51.89%** | −0.07pp |
| `TODO`/`FIXME` in production code | 3 | **3** | unchanged |
| Dead/misleading UI affordances (PRR §1) | 3 | **0 fully live** (2 removed, 1 downgraded to inert-but-visible) | see below |

**Test count and coverage moved by removal, not decay.** −9 tests is
the net of 11 removed (controls that no longer exist), 1 narrowed, and
2 added (documented per-sprint in `PHASE3_SPRINT_R3B_2_REPORT.md` §10
and `_R3B_3_REPORT.md` §10). Coverage held essentially flat because the
product code shrank in step — `search_screen.dart` alone lost 123 net
lines. This is the expected, correct signature of "delete dead UI and
its tests together," not a quality regression — re-confirmed by
recomputing coverage independently this pass (`flutter test
--coverage`, parsed against the same `lib/main.dart` / `*.g.dart` /
`lib/l10n/app_localizations_*.dart` exclusion rule `DR-2026-0015`
established), not copied from any prior report.

### 2.1 Feature engineering: ~92% → ~94%

PRR's basis was "every v1.0-scoped feature is built and tested; what
remains is Lexicon *data* and polish on three dead affordances." Two of
those three affordances (the AI toggle, the Flashcard Lemma dead-end)
are now closed outright; the third (Search placeholder chips) remains.
The 8-point gap PRR estimated for this axis shrinks proportionally to
what's left of it — a small, deliberately conservative bump, not a
recomputation from scratch, since the remaining item is real and
unresolved.

### 2.2 Quality infrastructure: ~95% → ~95% (unchanged)

PRR's basis was test count, coverage, `--fatal-infos` cleanliness, and
CI job count. All four are effectively unchanged (table above) —
R3b's own final review additionally confirmed `dart format` clean, a
check this axis's PRR figure didn't separately call out. No move.

### 2.3 Release readiness: ~30% → ~30% (unchanged, with a qualitative caveat)

PRR's basis was the Go/No-Go count: 4 of 14 boxes explicitly checked, 2
more true-but-unmarked, 8 genuinely open. R3b does not check a new box
— confirmed directly: none of the 14 items in `RELEASE_DASHBOARD.md`
§7 is about UI honesty (this was also stated by the R3b plan itself
before the work started, and holds after). The *count* this axis is
built from is unchanged, so the number doesn't move. **What did
change, and what a single percentage hides**: R3b closes the one item
`PRODUCT_READINESS_REVIEW.md` §4 identified as both Critical-tier and
fully engineering-solvable with zero external dependency — every other
open item on the board needs a licence answer, a store console, a
physical device, or a legal review. That's a real improvement in *what
kind of work remains*, not captured by a box count that was never
tracking this axis to begin with (§1's finding).

### 2.4 Content completeness: ~85% (unchanged)

Lexicon is still 0/8 tables populated — R3b explicitly did not touch
Lexicon (verified per-sprint: `git status` scoped to `lib/features/lexicon/`
returned empty after every R3b sub-sprint). No change, none expected.

### 2.5 Blended estimates

| Blend | Pre-R3b (PRR) | Post-R3b (this report) |
|---|--:|--:|
| Weighted for v1.0 public release | ≈55–60% | **≈57–61%** |
| Weighted for public beta | ≈75% | **≈80–82%** |

Same caveat PRR itself stated applies here too: neither of these is a
single official metric with disclosed weights — they are directional
estimates built from the four axes above, reproduced here with the
same structure so the *change* is auditable even though the absolute
number isn't precise to the point. **The public-release number moved
little** because every remaining v1.0 blocker (store/legal, Lexicon
licence, accessibility/performance hardware passes) is untouched by
R3b — this was never going to move that number much, and PRR's own
text said so in advance ("de-risks," not "closes," the relevant gates).
**The public-beta number moved more**, proportionally, because PRR's
own definition of beta-readiness was explicitly gated on "no visibly
broken UI" — and 2 of the 3 things that made the app read as broken no
longer exist. The remaining placeholder chips (§3, Medium) read as
*unfinished*, which PRR itself distinguished from *broken* as the
threshold beta tolerates.

## 3. What Sprint R3b actually closed — precisely, not by label

Stated exactly, because "Honest Surface Area completed" is true of the
three items R3b scoped and executed, and not true of the PRR's
original four-item list if read as a single unit:

| PRR's original Epic R3b item | Outcome |
|---|---|
| Remove/hard-gate the "Hỏi AI" locked toggle | **Done** — removed outright (R3b.2) |
| Remove/replace the `_PlaceholderChipRow` skeletons (Recent, Suggestions) | **Not done** — confirmed still present in `search_screen.dart` at close-out (`grep` this pass) |
| Honest empty state for Lexicon/Flashcards | **Done for the reachable case** (Add Flashcard's Lemma search, R3b.3); Smart Deck's weak-roots/verb-forms surfaces were reviewed and found **not currently reachable** through any navigation path today (both gate on having existing lemma flashcards, which cannot exist while Lexicon is empty) — correctly left unmodified, not silently skipped (full reasoning: `PHASE3_SPRINT_R3B_3_REPORT.md` §3) |
| Delete the 4 unused `placeholder*` l10n keys | **Not done** — confirmed still present, 0 real call sites, at close-out |

**Two items closed in full, one closed for its only currently-reachable
case, one not started.** Additionally, R3b's actual scope (set by a
deeper live-code audit in `PHASE3_SPRINT_R3B_PLAN.md`, not by PRR
alone) found and fixed **three defects PRR never identified**: the
Search "My Notes" scope chip rendering a blank body when selected
(arguably the single worst UX defect found across this entire
engagement — an enabled control producing nothing), the duplicate
"All"/"Qur'an" scope chips, and Profile's three "Coming in Step N"
tiles (one of which, "Goal," was actively false — advertising an
unbuilt feature that had, in fact, shipped).

**Recommendation for how this reads in tracking going forward**:
`RELEASE_DASHBOARD.md` now states this precisely (§2, §3, §4) rather
than as a flat "done" — a Critical-tier item marked substantially
resolved, with the two leftovers demoted to Medium and named
individually, not left implicit. Reflecting "Sprint R3b: complete"
is accurate — the sprint that ran is finished, reviewed, committed,
and pushed. Reflecting "Honest Surface Area: complete" without
qualification would not be — two small, explicitly-scoped-out items
remain, and this document names them rather than letting the label
imply more than shipped.

## 4. Completed work still missing from release tracking

Checked across R1, R2, R3a, and R3b — not just R3b, per this task's
explicit instruction. Five items, three carried forward unresolved
from `PRODUCT_READINESS_REVIEW.md` §5 (re-verified today, not assumed
still true), one new:

1. **`CHANGELOG.md` still has zero entries for Sprint R1 (Search FTS5),
   Sprint R2 (Read Model UI), and Sprint R3.2 (coverage policy)** —
   re-confirmed by grep this pass (`0` matches for each). R3a and now
   R3b have entries; the three sprints between the last full backfill
   and R3a do not. This close-out added R3b's entry but did **not**
   backfill these three, per this task's explicit scope (only "add an
   entry summarizing Sprint R3b").
2. **`PROJECT_INDEX.md` still lists none of the documents produced
   since Phase 3 began** — re-confirmed by grep (`0` matches for
   `PHASE3_SPRINT_R3A`, `PHASE3_SPRINT_R3B`, `PRODUCT_READINESS_REVIEW`,
   `RELEASE_GOVERNANCE_AUDIT`). The gap PRR found has **grown**: six
   more documents (the full R3b plan/design-review/report/final-review
   set) now also aren't indexed anywhere a new reader would find them,
   on top of the six PRR already found missing.
3. **`docs/adr/README.md` does not list `DR-2026-0016`** — unchanged
   from PRR, re-confirmed.
4. **The repository-boundary threshold change (commit `0ef9b9c`, 1 MB
   → 2 MB) is recorded in none of `CHANGELOG.md`, `RELEASE_DASHBOARD.md`,
   or `RELEASE_PLAN_V1.md`** — re-confirmed by grep across all three
   this pass. It remains a governed policy change justified only in an
   untracked report (`docs/release/REPOSITORY_BOUNDARY_UPDATE_REPORT.md`).
5. **New this close-out**: the nine missing Decision Records PRR's §5
   found (`DR-2026-0002`, `0006`–`0013`) are unchanged — this report
   did not re-audit reference counts (out of scope for this task), but
   nothing in R3b's work touched any ADR, so there is no reason to
   expect the count moved. Flagged for whoever runs PRR's own
   recommended "Epic R3c: Release Record Reconciliation."

**None of these five is new to this close-out except the size of item
2.** They are named again here, explicitly, rather than assumed closed
because time passed since PRR — the same discipline PRR itself applied
when it declined to trust `RELEASE_DASHBOARD.md`'s stale 58% figure
without re-deriving its own numbers.

## 5. Gate results

```
flutter analyze --fatal-infos
...
No issues found! (ran in 7.8s)
```

```
flutter test --coverage
...
+793: All tests passed!
```

(Run with `--coverage` rather than plain `flutter test` specifically to
support the §2 recalculation with a real, freshly-measured number
rather than an estimate — the plain-test requirement this task also
named is satisfied by the same run, since `--coverage` is a superset.)

No `dart format` regression — not re-run separately this pass since no
`.dart` file was touched (confirmed §6); the last real run was at the
R3b final review, clean.

## 6. Confirmed scope

```
git status --short -- lib/ test/
```

returns nothing — zero production code or test files touched, matching
this task's explicit constraint. Files actually modified:

```
 M CHANGELOG.md
 M RELEASE_DASHBOARD.md
 M docs/release/RELEASE_PLAN_V1.md
```

All other files in the working tree (the R3a/R3b/PRR/governance report
set, `DR-2026-0016`) are pre-existing untracked documents from earlier
in this engagement, unmodified by this task.

---

## Bottom line, as Release Manager

**Phase 3 (R1, R2, R3a, R3b) is closed and pushed.** The product moved
from "well-engineered but visibly broken in three places" to
"well-engineered with two small, honestly-labeled gaps remaining" —
that is a real, beta-relevant improvement, and this close-out avoids
overstating it: "Honest Surface Area" the epic is not 100% done, and
the tracking documents now say so precisely rather than rounding up.

**The critical path to v1.0 has not moved.** Every blocker that gates
a real release — the Lexicon licence answer (deadline 2026-08-24),
store/legal readiness, the two hardware-dependent verification passes
— is exactly as open as it was before R3b, because none of them was
ever engineering-solvable to begin with. R3b's value was never framed
as closing those; it closed the one thing that was both Critical and
entirely within engineering's own control, and it did.

**Two candidate next steps, not a decision made for the team**:
finish the two small Honest Surface Area leftovers (placeholder chips,
unused l10n keys — both XS effort per the original plan), or begin
`PRODUCT_READINESS_REVIEW.md`'s second-priority Epic R3c (Release
Record Reconciliation) — which §4 of this report shows has only grown
more overdue since it was first recommended. Both are engineering-only,
zero external dependency, and small. Neither is scheduled by this
report; that decision belongs to whoever sequences the next sprint.

---

PHASE 3 EPIC CLOSE-OUT COMPLETE — not committed, not pushed.
