# Implementation Report — Independent Core CI Gate

Sprint: Release Recovery Phase 3. Branch: `ci/repository-boundary-core-gate`,
cut from `origin/main` at `564f2b1`. **Nothing committed, pushed, or
opened as a PR** — three new files exist locally, uncommitted, ready
for review. This report is the review artifact.

---

## A correction found during implementation, before anything else

`CI_GATE_CORE_PLAN.md`/`CI_GATE_SPLIT_PLAN.md` assumed `main` was a
"clean" branch with respect to the deny-list — that an empty
`_grandfathered` map would be correct. **That assumption was checked,
not trusted, and turned out to be wrong.** `main` already tracks three
of the five files `sprint1-my-library` grandfathers:

| File | On `main`? | Size on disk |
|---|---|---|
| `assets/database/quran.sqlite` | **Yes** — pre-tafsir-import version | 19,877,888 bytes |
| `tool/data/transliteration.json` | **Yes** | 765,997 bytes |
| `tool/data/transliteration_words.json` | **Yes** | 2,657,101 bytes |
| `tool/data/tafsir_en-tafsir-ibn-kathir.json` | No | — |
| `tool/data/tafsir_ar-tafsir-muyassar.json` | No | — |

An empty map would have made the Core Gate **fail immediately on
`main`** — flagging three files that predate the gate itself, which is
exactly the false-alarm failure mode the grandfather mechanism exists
to prevent. Corrected before writing any code: `main`'s
`_grandfathered` has **three** entries, not zero, naming exactly the
content `main` already carries. The two Ibn-Kathir-related entries are
correctly **absent** — `main` never tracked them, so no exemption is
needed, and none was written.

This also changed a second planned behavior: `CI_GATE_SPLIT_PLAN.md`
expected the completeness test to need its "not yet applicable"
fallback on `main` today, since nothing large was thought to be
grandfathered there. In fact two of the three real entries
(`quran.sqlite`, `transliteration_words.json`) already exceed the 1 MB
threshold, so the completeness test **exercises its real assertion on
`main` today**, not its fallback path. The fallback was kept anyway —
it protects the day D1/D2 untracks these files and nothing new has
been grandfathered yet, which is a real future state, just not today's.

---

## Files changed

| File | Status | Lines |
|---|---|---|
| `test/repository_boundary_test.dart` | **New** | 383 |
| `test/repository_boundary_completeness_test.dart` | **New** | 107 |
| `docs/LICENSING.md` | **New** | 216 |

**3 files changed, 706 insertions(+), 0 deletions(-).** No existing
file was modified. `.github/workflows/ci.yml` was not touched.

## Reason for every change

### `test/repository_boundary_test.dart` — the Core Gate

Ported from `sprint1-my-library` per `CI_GATE_CORE_PLAN.md`'s
component inventory: all 6 helpers/constants and all 9 Core tests,
unchanged in logic. Three actual edits, all data/documentation, zero
logic changes:

1. `_grandfathered` reduced from 5 entries to the 3 that match `main`'s
   real tracked state (see correction above) — the two Ibn-Kathir
   entries are omitted, not emptied, because they'd otherwise be
   flagged stale by the gate's own hygiene test the moment it ran.
2. `_maxTrackedFileBytes`'s justification comment re-measured against
   `main`'s actual on-disk file sizes rather than carried over from
   `sprint1-my-library`. The largest legitimate file
   (`assets/fonts/Inter-Bold.ttf`, 420,428 bytes) is identical on both
   branches — fonts haven't diverged — so the margin conclusion (>2×)
   still holds, now verified for `main` specifically rather than
   assumed transferable.
3. Header comment rewritten to state plainly that this file is the
   Core half of a two-file split, why the split exists, and why
   `main`'s three-entry exemption list differs from
   `sprint1-my-library`'s five — so a future reader doesn't have to
   reconstruct that reasoning from git history.

Test #10 from the original file (**"every grandfathered entry over
threshold names its removal phase"**) was **removed from this file**
per `CI_GATE_CORE_PLAN.md`'s classification — it is Completeness, not
Core.

### `test/repository_boundary_completeness_test.dart` — new file

Contains exactly the one test removed above, rewritten per
`CI_GATE_SPLIT_PLAN.md` Part 4: if no grandfathered entry exceeds the
threshold, it calls `markTestSkipped(...)` with an explanatory message
instead of failing. On `main` today this branch is **not taken** — the
real assertion runs and passes, since two real oversized entries exist
(see correction above). The skip path exists for a future state, not
today's, and was validated by temporarily emptying its local copy of
`_grandfathered` during development (see Test Results).

Duplicates a small amount of helper code (`_trackedFiles`,
`_trackedFileSizes`, its own copy of `_grandfathered` and
`_maxTrackedFileBytes`) rather than sharing a third library file — a
deliberate choice from the approved split plan, trading a few dozen
duplicated lines for two files that are each fully self-contained and
independently reviewable. Documented in-file as an accepted tradeoff,
with the Core file named as the source of truth if the two ever
diverge.

### `docs/LICENSING.md` — new file

Two of the Core Gate's failure messages point here
(`_restricted`'s tafsir/database reasons; the violation message's "see
`docs/LICENSING.md`" line). It didn't exist on `main`, so those
pointers resolved to nothing — objective 5's exact concern. Extracted
from `sprint1-my-library` (Sprint 33.0's licensing audit) largely
verbatim, with one addition: a note at the top stating plainly that
`main`'s database predates the tafsir import and does not yet contain
the two tafsir sources the document's §1 rows 5–6 and §4 risk table
describe. Extracting the file unedited-but-uncaveated would have
shipped a document overclaiming what `main` actually contains — this
project has spent multiple sprints correcting exactly that class of
overclaim (the Ibn Kathir misattribution itself), so the same standard
applies here rather than being set aside for convenience.

**Not extracted, and flagged rather than silently accepted:**
`docs/adr/DR-2026-0013-ci-licence-gate.md` and
`docs/adr/DR-2026-0009-data-supply-chain.md`, also referenced by the
gate's failure messages, remain absent from `main` — they belong to
release group G15, not G11, and objective 5 named only
`docs/LICENSING.md`. This mirrors a gap this project has already
accepted once (`DR-2026-0002`, tracked in `docs/adr/README.md`) rather
than introducing a new, unacknowledged one — see Remaining Risks.

---

## Test results

All commands run locally against branch `ci/repository-boundary-core-gate`
(`origin/main` + these 3 files). No live GitHub Actions run was
triggered — this session has no `gh` CLI or API access, consistent
with every prior sprint in this engagement; "CI still passes" below is
verified by running CI's own commands locally, not by observing a
hosted run.

| Command | Result |
|---|---|
| `flutter pub get` | Resolved cleanly against `main`'s existing `pubspec.lock` — no dependency conflict |
| `dart format --output=none --set-exit-if-changed` (both new test files) | `Formatted 2 files (0 changed)` |
| `flutter analyze --fatal-infos` (whole project) | `No issues found! (ran in 62.8s)` |
| `flutter test test/repository_boundary_test.dart test/repository_boundary_completeness_test.dart` | **10/10 pass** — 6 (B1 group) + 3 (B2 core group) + 1 (completeness) |
| `flutter test` (full suite) | **146/146 pass** — `main` had 136 pre-existing tests; +10 from this change; **zero regressions, zero failures** |
| `flutter test --coverage` | Completed, `146/146 pass`, `coverage/lcov.info` generated |
| CI's exact `lcov`-based percentage gate | **Not computed** — `lcov` binary is unavailable in this shell. Not blocking: this change adds zero lines to `lib/`, so the coverage denominator is unaffected: the percentage CI computes should be numerically identical to whatever it was on `main` before this change. Flagged here rather than asserted as passing without having run it. |

**Load-bearing validation, not just a pass count:** during development,
the completeness test's fallback path was exercised directly by
temporarily emptying its local `_grandfathered` copy and re-running —
confirmed it reports "not applicable" via `markTestSkipped` rather than
failing, then restored to the real 3-entry map before finalizing. This
follows the same "prove it by deliberately breaking it" discipline
`B1`/`B2` were held to, applied here to the one new piece of test logic
this implementation actually introduces.

---

## Remaining risks

1. **Two documentation references remain dangling.** `DR-2026-0013`
   and `DR-2026-0009` aren't on `main` yet (belong to G15). Doesn't
   affect what the gate enforces — only what a human reads if it
   fires. Resolved automatically whenever G15 merges; no action
   required by this change specifically.
2. **The completeness test's helper code is duplicated, not shared.**
   An accepted tradeoff (see above), but it means a future edit to the
   Core file's `_grandfathered` map must be manually mirrored in the
   completeness file, or the two will silently disagree. Both files
   say so in comments naming the Core file as authoritative; nothing
   currently enforces it beyond that comment.
3. **No live CI run has confirmed this.** Local simulation is thorough
   (format, analyze, targeted tests, full suite, coverage generation)
   but isn't identical to a hosted GitHub Actions run — matrix
   differences (OS, Flutter version pinning) are unlikely to matter
   here since the gate only calls `git` and reads files, but "unlikely"
   isn't "confirmed."
4. **This does not touch `sprint1-my-library` or resolve G10.** The
   Ibn Kathir corpus is unaffected by anything in this report; this
   change only stops a *future* restricted-content commit from landing
   cleanly on `main`.
5. **The `_maxTrackedFileBytes` justification comment will go stale
   again** the next time a large legitimate asset is added to `main`
   (a store icon, a new font) — same property the original file always
   had; test B2 #9 (kept in Core) catches the substantive case even if
   the comment's prose isn't manually refreshed.

---

## Recommended merge strategy

**Standalone PR, exactly as scoped — no bundling.**

- Base: `main`. Branch: `ci/repository-boundary-core-gate` (already
  exists locally, unpushed).
- Contents: exactly the 3 files above. Nothing else — confirmed via
  `git diff --name-only origin/main`.
- Do **not** bundle with the still-pending
  `ci/dataset-verification-workflow-onmain` branch from the prior
  sprint — that's a separate, unrelated capability and bundling would
  violate objective 7's "small and reviewable."
- Suggested PR description should lead with the correction in this
  report's first section — a reviewer comparing against
  `CI_GATE_SPLIT_PLAN.md` will otherwise wonder why `_grandfathered`
  isn't empty as that document anticipated.
- After merge, this becomes the first content-gate protection `main`
  has ever had. Recommend confirming the first real CI run's summary
  shows 10/10 gate tests passing, as a live counterpart to the local
  results above.

---

## Final tally

| | |
|---|---|
| **Changed files** | 3 (`test/repository_boundary_test.dart`, `test/repository_boundary_completeness_test.dart`, `docs/LICENSING.md`) — all new |
| **Total insertions** | 706 |
| **Total deletions** | 0 |
| **Ready for a standalone PR into `main`?** | **Yes**, pending only a live CI confirmation (Remaining Risk 3) — all local gates (`format`, `analyze --fatal-infos`, targeted gate tests, full suite) pass with zero regressions, the change is exactly the scope objectives 1–5 asked for, no protection was weakened (objective 6 — if anything, `main` goes from zero content-gate protection to full protection), and nothing outside the three named files was touched (objective 7). **Not yet pushed or opened as a PR** — that action was left for explicit instruction, consistent with every prior sprint in this engagement. |
