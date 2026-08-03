# Phase 3 — Final Release Tracking Cleanup Report

Closes the release-tracking gaps `PHASE3_EPIC_CLOSEOUT_REPORT.md` §4
found still open after that report's own updates. No production code
was modified — confirmed by `git status` showing zero diff under
`lib/` or `test/` (§4). Three documents touched:
`RELEASE_DASHBOARD.md`, `CHANGELOG.md`, `docs/release/RELEASE_PLAN_V1.md`.

---

## 1. Missing release tracking completed

### `RELEASE_DASHBOARD.md`

**One gap, now closed**: §2 "Completed work" had no entry for Sprint
R1 (Search FTS5 Integration) — the only one of the four named sprints
missing there; R2, R3.2, and R3b already had their own subsections
before this pass. Added a full "Phase 3 — Sprint R1" subsection
(commit `0f3f751`, three sub-sprints: R1.1 engine wiring, R1.2 the
dedicated "no results" state, R1.3 an accessibility fix plus a
rapid-typing regression test), sourced from
`docs/release/PHASE3_SPRINT_R1_PLAN.md` through `_R1_3_REPORT.md` — not
reconstructed from memory. §3, §4, and §7 already referenced R1
correctly in passing; only the dedicated completed-work entry was
missing.

### `CHANGELOG.md`

**Three gaps, now closed**: `[Unreleased]` had zero entries for Sprint
R1, Sprint R2, and Sprint R3.2 (confirmed by grep before writing —
`0` matches each). Added one `### Fixed` entry per sprint, in
reverse-chronological order matching the file's existing convention
(newest first — R3b, R3a already at top; R3.2, R2, R1 inserted below
R3a in that order, above the "Ghi chú — khoảng trống backfill" note),
in Vietnamese, matching the R3a/R3b entries' structure (a short
framing paragraph, a per-sub-sprint bullet list where applicable, a
"Chi tiết:" pointer to the source reports, and an explicit "còn mở"
close where something remains open). R3.1 was **not** added — it was
not named in this task's scope, and its one deliverable (the
`SmartLearningScreen` CTA) is already covered inside the R2 entry's
"còn mở" note as the thing that closed it.

### `docs/release/RELEASE_PLAN_V1.md`

No entry needed adding here — this document tracks blockers and
checklist items, not a chronological log, so "missing an entry" isn't
the right frame for it. Instead, verified for consistency (§2 below)
and found genuinely stale in three additional places beyond the one
`PHASE3_EPIC_CLOSEOUT_REPORT.md` already corrected.

## 2. Cross-document consistency — verified, and three new inconsistencies found

Checked every sprint named in this task (R1, R2, R3.2, R3b) plus R3a
(already tracked, checked for regression) against all three documents.
**Beyond the entries added in §1, found three places where
`RELEASE_PLAN_V1.md` still contradicted its own §4 checklist** — the
same document disagreeing with itself, not just lagging behind the
other two files:

1. **§1's status table said Search's "real FTS5 engine wiring is a
   separate, still-open item (§4)"** — while §4 item 3 already said
   `~~Finish the FTS5 search engine wiring~~ — done, Phase 3 Sprint R1`.
   One document, two contradictory claims about the same fact, 40 lines
   apart. Corrected: the table row now states plainly that Search is
   built and wired, with the correction dated and the prior wording
   named, per this project's established convention of never silently
   overwriting a stale claim.
2. **§1's status table said Read Model "no UI consumes it yet,
   infrastructure-only"** — while §4 item 4 already said
   `~~Resolve D3~~ — done, Phase 3 Sprints R2 and R3.1`. Same pattern,
   same document. Corrected the same way.
3. **§0's opening paragraph repeated the same stale Read Model claim**
   ("only Read Model has no UI yet, see §2") in its own words, a third
   place carrying the same outdated fact. Corrected.
4. **§2 "Known engineering gaps" still listed D3 as an open blocker**
   requiring a product decision — the exact decision `RELEASE_DASHBOARD.md`
   already recorded as made and shipped at Sprint R2. This is the most
   consequential of the four: D3 sat inside this document's own
   "Remaining blockers for a real v1.0 release" section, unmarked as
   resolved, through Sprints R3.2, R3a, *and* R3b — three full sprints
   after it actually closed. Corrected with the same strikethrough
   treatment already used elsewhere in this document for closed items
   (Web platform, coverage gate), so it now reads consistently with its
   neighbors instead of standing out as an oversight.

**Why this matters more than a wording fix**: `RELEASE_DASHBOARD.md`
had D3 right (§7's Go/No-Go already shows it checked, sourced
correctly to Sprint R2) the entire time. The inconsistency was
`RELEASE_PLAN_V1.md` alone disagreeing with the source of truth it
should have been consistent with — exactly the failure mode this task
exists to catch, and evidence that "reflected in one document" is not
the same as "reflected consistently across all of them," which is what
was actually asked.

**No inconsistency found for R3.2, R3a, or R3b** — each of those was
already correctly and consistently reflected across all three
documents before this pass began (R3.2 and R3a already had matching
strikethrough/closed treatment in both `RELEASE_DASHBOARD.md` and
`RELEASE_PLAN_V1.md`; R3b's one stale reference — the "Ask AI" toggle
description — was already corrected in the prior close-out pass and
re-verified unchanged here).

## 3. Honest Surface leftovers — decision

Two items, reviewed together since they share the same origin
(`PHASE3_SPRINT_R3B_PLAN.md`, Groups A4/A5 and D1), the same estimated
effort, and the same "reads as unfinished, not broken" severity
classification already recorded in `RELEASE_DASHBOARD.md` §3 (Medium).

### `_PlaceholderChipRow` (Search "Recent"/"Suggestions" grey chips)

**Considered and set aside**: leaving them in place is defensible in
the abstract — they preserve layout shape for a real Recent
Searches/Suggestions feature that is legitimately scoped for v1.1, and
they are already `ExcludeSemantics`-wrapped, so they don't mislead a
screen-reader user the way the three items R3b actually closed did.
That is a real, non-trivial argument, not a strawman.

**It doesn't win, for one specific reason**: the original design
review (`PHASE3_SPRINT_R3B_PLAN.md` §2) already weighed this exact
trade-off and landed on Remove, not "add a label" or "leave as
intentional scaffolding" — and nothing about the situation has changed
since that decision was made. Re-opening a reasoned, recorded decision
without new information isn't a review, it's just re-litigating. The
shape a real Recent-Searches row will eventually need is not
meaningfully hard to reconstruct from the `SearchResultSection`/`ResultCard`
patterns already in the same file when that feature actually gets
built — keeping four grey rectangles alive in the meantime isn't
saving real future work.

### 4 unused `placeholder*` l10n keys, and `l10n.comingInStep`

No live argument for keeping either — zero call sites, confirmed twice
now (Product Readiness Review, and independently again in this task).
Pure dead weight in three `.arb` files each. The only question is
timing, not whether.

### Decision: small follow-up sprint, not backlog

**Recommend bundling all three (`_PlaceholderChipRow` removal, the 4
`placeholder*` keys, `l10n.comingInStep`) into one small follow-up
sprint — not sending them to a generic backlog.**

Reasoning, as a release-tracking call rather than an engineering
estimate (the engineering estimate — XS effort, no architecture
change, per `PHASE3_SPRINT_R3B_PLAN.md` §3 — was already made and
isn't revisited here):

- **This project's own history shows what "backlog" actually means
  here.** D8, D5, and D6-remainder have sat in `RELEASE_DASHBOARD.md`'s
  Medium tier, correctly classified and never disputed, for multiple
  sprints with no forward motion — not because they're wrong to defer,
  but because nothing forces a return to low-severity items once
  higher-severity work exists to do instead. The same fate is the
  realistic default for these two items if filed the same way.
- **The cost of *not* doing it compounds specifically for this item,
  unlike D8/D5/D6.** Every sprint that ships without this closes with
  `RELEASE_DASHBOARD.md` describing "Honest Surface Area" as
  "substantially, not fully, resolved" — a caveat a release manager
  has to re-explain at every future check-in until it's gone. D8/D5/D6
  carry no equivalent narrative cost; they're just debt, not an
  unfinished decision under active narration.
- **The remaining work is genuinely small enough that "sprint" doesn't
  mean what it usually means here.** This isn't a call for a new epic
  or a multi-day effort — it's the same three-line-plan-then-review
  discipline this project already applies to everything, sized to
  match roughly R3b.1's own scope (one screen, one file family, one
  l10n pass), not a new R3c.
- **It closes the loop the Product Readiness Review actually opened.**
  PRR's Epic R3b scope named four items; three shipped (§3 of
  `PHASE3_EPIC_CLOSEOUT_REPORT.md` already stated this precisely).
  Finishing the fourth is completing a decision already made, not
  proposing new scope — the honest-tracking argument for *saying* "R3b
  complete" gets easier to make truthfully the sooner this lands, not
  harder if delayed.

**Not recommended**: reopening whether to Remove vs. Replace vs. Hide
these — that discussion already happened and nothing here changes its
inputs. This section decides *when*, not *what*, and the *what* was
already settled.

This is a recommendation for whoever sequences the next sprint, not a
scheduling decision made by this report — consistent with how
`PRODUCT_READINESS_REVIEW.md` and `PHASE3_EPIC_CLOSEOUT_REPORT.md` both
presented next-step options rather than committing the team to one.

## 4. Confirmed scope

```
git status --short -- lib/ test/
```

returns nothing — zero production code or test files touched, matching
this task's "Do NOT modify production code" constraint and the fact
that no code implementation was requested (task 3 is a decision to
record, not to execute).

```
 M CHANGELOG.md
 M RELEASE_DASHBOARD.md
 M docs/release/RELEASE_PLAN_V1.md
```

are the only files modified. `flutter analyze`/`flutter test` were not
re-run for this pass — not an oversight: no `.dart` file changed
(confirmed above), the prior close-out already re-ran and recorded both
clean against the identical code state, and a documentation-only diff
cannot regress either gate. Re-running them here would re-confirm a
fact already established minutes earlier in this same engagement, not
produce new information.

## 5. What's still open, deliberately not touched by this task

Named for continuity, not actioned — none of these were in this task's
explicit scope (`PROJECT_INDEX.md` and `docs/adr/README.md` backfill,
the nine missing Decision Records, and the repository-boundary
threshold change's own tracking gap were all named in
`PHASE3_EPIC_CLOSEOUT_REPORT.md` §4 and remain exactly as open as that
report left them):

- `PROJECT_INDEX.md` still doesn't list any document produced since
  Phase 3 began (now 8+ documents, including this one and the epic
  close-out report itself).
- `docs/adr/README.md` still doesn't list `DR-2026-0016`.
- The repository-boundary threshold change (commit `0ef9b9c`) is still
  recorded in no release-tracking document.
- Nine Decision Records remain cited but absent as files.

These are named again here on the same principle applied throughout
this pass: a gap that's been flagged twice and fixed neither time is
worth naming a third time, not assumed resolved because time passed.

---

RELEASE TRACKING CLEANUP COMPLETE — not committed, not pushed.
