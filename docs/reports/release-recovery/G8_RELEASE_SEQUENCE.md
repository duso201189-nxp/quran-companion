# G8 Release Sequence

Builds on [`G8_FEATURE_MATRIX.md`](G8_FEATURE_MATRIX.md) and
[`G8_SPLIT_PLAN.md`](G8_SPLIT_PLAN.md). Analysis only.

---

## Optimal merge order

Derived directly from the verified dependency graph — not the order
features happen to appear in the directory listing.

```
 PR 1   P1  Reliability layer               ── no dependencies
 PR 2   P2  Shared accessibility widgets     ── no dependencies
                                                 (can swap order with PR 1,
                                                  or merge same day)
 PR 3   P3  Database schema migration        ── no dependencies, but gates
                                                 every feature that needs a
                                                 new table
 PR 4   P4  Reliability retrofit             ── needs PR 1
             (existing repos: khatm, learning,
              library, quiz, quran, stats)
 PR 5   F1  Lexicon                          ── needs PR 1, PR 3
 PR 6   F2  Flashcards                       ── needs F1, PR 1, PR 2, PR 3
 PR 7   F3  Analytics                        ── needs F2, F1, PR 2
 PR 8   F4  AI Tutor                         ── needs F3, F2, PR 2
 PR 9   F5  Learning Journey                 ── needs F4, PR 2
 PR 10  F6  Smart Learning                   ── needs F4, F5, PR 2
 PR 11  F7  Read Model                       ── needs F4, F5, F6
 PR 12  F8  Learning Session                 ── needs F2 only —
                                                 movable anywhere from
                                                 PR 7 onward, shown last
                                                 only for list clarity
```

**PRs 1–3 can merge in any relative order, including the same day** —
none depends on the other two. **PR 4 needs only PR 1.** **PR 12 (F8)
needs only PR 6 (F2)** and can be opened any time after that, in
parallel with F3–F7 — it does not sit on the F3→F7 critical path at
all. Everything else follows the strict chain
`F1 → F2 → F3 → F4 → {F5, then F6, then F7}`.

## Recommended smallest possible first PR

**PR 1 — the Reliability layer (P1).**

Measured against every other candidate in the commit:

| Candidate | Hand-written lines | Files | Depends on |
|---|---|---|---|
| **Reliability layer (P1)** | **347** | **10 + 6 tests** | **nothing** |
| Shared widgets (P2) | 232 | 4 + 1 test | nothing |
| Read Model (F7) | 230 | 7 | 3 other features |
| Learning Session (F8) | 64 | 4 | 1 other feature |

Shared widgets (P2) is smaller by line count and an equally valid
"first" candidate — either is defensible as the opening PR. Reliability
layer is the stronger recommendation for three reasons beyond size:

1. **It's the most-depended-upon single slice** — six existing
   repositories (P4) and two new features (Lexicon, and transitively
   everything built on it) need it; shared widgets are needed by five
   new features but nothing already shipped.
2. **It's purely additive with the highest proportional test coverage**
   in the commit — 6 dedicated test files for 10 source files, and zero
   existing code changes, so there is nothing for it to regress.
3. **It matches this project's own established pattern** for how to
   introduce foundational infrastructure safely — the same "ship it
   inert, prove it before anything depends on it" shape as the CI
   licence gate this engagement just finished landing on `main`.

## Estimated total PR count

**12 pull requests** to fully replace this one commit, following the
sequence above — 3 infrastructure PRs (P1–P3), 1 retrofit PR (P4), and
8 feature PRs (F1–F8).

This is a floor, not a ceiling, for two reasons stated plainly rather
than smoothed over:

- **F2 (Flashcards, 2,293 lines) and F3 (Analytics, 1,741 lines)** are
  each larger than several entire *other* PRs in this list combined.
  Either could reasonably be split further internally (e.g., Flashcards'
  deck-management UI separated from its smart-deck-selection algorithm)
  if a reviewer finds 19 or 16 files in one sitting still too large — that
  would raise the count to 13 or 14, not lower it.
- **The distributed shared-file touches** (`l10n`, `router`,
  `home_screen.dart`, `study_screen.dart`) are not counted as their own
  PR because they can't stand alone (§4 of `G8_SPLIT_PLAN.md`) — but
  they add small, real diff to most of the 12 PRs above. A strict "PR
  count" that only counted wholly-standalone units would undercount the
  actual review burden; 12 is the count of *mergeable units*, not of
  total files touched.

**12 is the number to plan against.** If review capacity is the
binding constraint rather than merge-order correctness, F2 and F3 are
the two candidates most likely to grow this to 13–14 without changing
anything else in this sequence.

---

## Executive Summary

Commit `d4976b0` describes itself as four things and actually contains
thirteen: eight independent feature verticals (the largest,
Flashcards, isn't named in the commit message at all), a cross-database
schema migration that needs its own `PROJ-P-002` review regardless of
everything else in the commit, a reliability-layer retrofit into six
already-shipped features, and infrastructure shared by nearly
everything else. Import-level dependency extraction — corrected once
after an initial false-negative from assuming the wrong import style —
found a real, acyclic dependency graph among the eight features:
Lexicon is the most foundational, Read Model the most dependent, and
Learning Session sits entirely outside the main chain. The database
migration's raw diff (8,883 lines) is 97% generated code; the actual
reviewable change is 259 lines. None of this is visible from the
commit message or from `git diff --stat` alone — it required opening
the tree and tracing imports directly.

## Recommended First PR

**The Reliability layer** (`lib/core/error/`, `lib/core/logging/`,
347 hand-written lines, 10 source files, 6 test files, zero
dependencies, zero existing files touched). The smallest defensible
unit that unblocks the most downstream work, with the highest
proportional test coverage of any slice in the commit.

## Estimated Total PR Count

**12**, following the sequence in this document — treated as a floor:
Flashcards and Analytics are each large enough that a reviewer could
reasonably ask for a further internal split, which would raise the
count without changing the dependency order established here.
