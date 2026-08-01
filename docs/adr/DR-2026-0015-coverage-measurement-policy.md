---
id: DR-2026-0015
scope: project
owner_role: release-owner
date: 2026-08-01
deciders: [duso]
status: accepted
supersedes: null
review_by: null
reversibility: soft
threshold_reason: [materially-different-approaches, changes-a-release-criterion]
links:
  task: "Phase 3 Sprint R3.2 — coverage policy review"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0015 — Coverage measurement policy: generated code in the denominator

**Status of this record: accepted (2026-08-01).** Implemented in the
same change that records this acceptance: `.github/workflows/ci.yml`
gained the `lib/l10n/app_localizations_*.dart` lcov exclusion and moved
`MIN_COVERAGE` 70 → 80, and the disclosure required by §5 was written
into `RELEASE_DASHBOARD.md` and `docs/release/RELEASE_PLAN_V1.md`.
Per `docs/adr/README.md`, `status` is the only field editable in place
after acceptance.

## Relationship to existing records

No existing Decision Record covers test-coverage measurement. The 70%
threshold and its lcov filters were introduced directly in
`.github/workflows/ci.yml` with an inline comment as their only
rationale, never as a recorded decision. This record does not supersede
or amend anything — it retroactively documents the policy that already
exists, and proposes one change to it.

## Context

CI enforces a line-coverage floor (`MIN_COVERAGE: '70'`) measured after
three lcov exclusions:

```
lib/main.dart                      # bootstrap only, no logic
**/*.g.dart                        # generated (Drift)
*/lib/core/database/connection/*   # platform conditional-import stubs
```

`ARCHITECTURE.md` states 80% as the v1.0 target.
`RELEASE_DASHBOARD.md` §5 item 7 and §7 box 7 both require the CI gate
and actual measured coverage to be *reconciled* before v1.0 — "gate
reflects reality, whatever that number turns out to be."

That reconciliation was never performed, because the number had never
been measured since the F1–F8 feature work landed. It has now been
measured, twice, against `main` (802 tests, post-Sprint-R3.1):

| Policy | Coverage | Lines |
|---|--:|---|
| A. Raw, no exclusions | 51.96% | 8816/16968 |
| B. Current CI policy | 76.25% | 6584/8635 |
| C. B + per-locale l10n delegates excluded | **81.54%** | 6141/7531 |
| D. B + all `lib/l10n/` excluded | 81.51% | 6123/7512 |

The gap between B and C is entirely four generated files:

| File | Covered | |
|---|---|---|
| `app_localizations.dart` | 18/19 | 94.7% — abstract base + `LocalizationsDelegate` |
| `app_localizations_ar.dart` | 16/368 | **4.3%** |
| `app_localizations_vi.dart` | 172/368 | **46.7%** |
| `app_localizations_en.dart` | 255/368 | **69.3%** |

## Problem

The three per-locale files are byte-for-byte structurally identical —
same 298 constant getters, same 33 parameterized methods, exactly one
`Intl.pluralLogic` call site each — yet they score 4.3%, 46.7%, and
69.3%. The only variable is which locale a given widget test happened
to set.

The metric is therefore not reporting how well the project is tested.
It is reporting the locale distribution of the test suite, mixed into
the same number as genuine product-code coverage, where the two cannot
be told apart.

Two second-order effects follow:

- **The denominator grows with translation volume.** Every new
  user-facing string adds three generated lines (one per locale) and
  dilutes measured coverage even when the feature shipping it is fully
  tested. Sprint R3.1 added 2 keys → 6 generated lines, two of which
  (Arabic) are structurally uncoverable by an English-locale suite.
- **Roughly 350 coverage points are purchasable without testing
  anything.** Rendering every screen under an Arabic locale, asserting
  nothing, would move the number several points. Line coverage on a
  constant getter is marked by *reading* the string, not by checking it.

### 1. Why generated localization is treated differently

Differently *from hand-written code*, and identically *to other
generated code*. `lib/l10n/app_localizations*.dart` is produced by
`flutter gen-l10n` from `lib/l10n/app_{vi,en,ar}.arb`, is never edited
by hand, and is regenerated on every build. Its correctness is
established by the generator and the compiler, not by tests: a getter
returning a string literal cannot fail at runtime in a way that passes
compilation.

Content census per locale file:

| Kind | Count |
|---|--:|
| Plain constant getters (`String get x => '…';`) | 298 |
| Parameterized string interpolation | 33 |
| Methods with real branching (`Intl.pluralLogic`) | **1** |

~90% of declarations are constant returns. There is one branch per
file. Asking tests to cover this is asking them to re-verify codegen.

### 2. Why generated Drift is already excluded

`**/*.g.dart` — `app_database.g.dart` (4349 lines) and
`user_database.g.dart` (3984 lines) — was excluded when the gate was
first written, for exactly the reasons above: machine-generated from a
source of truth (the Drift table definitions), never hand-edited, and
large enough that including it drags the measured figure far from
anything actionable. The raw-vs-filtered spread (51.96% → 76.25%)
is almost entirely those two files.

That decision was correct and is not revisited here.

### 3. Why this policy is technically consistent

The project currently applies two different rules to one category. Both
Drift `.g.dart` and `flutter gen-l10n` output satisfy the same test:

| Criterion | `*.g.dart` | `app_localizations_*.dart` |
|---|---|---|
| Machine-generated | yes | yes |
| Regenerated from a source of truth in-repo | yes (`user_tables.dart`) | yes (`*.arb`) |
| Ever hand-edited | no | no |
| Author-written branching | no | 1 site per file |
| Correctness guaranteed by generator + compiler | yes | yes |

One is excluded, the other is not. The inconsistency is the defect;
this record removes it. The rule being applied is not "exclude things
that lower our number" — it is **exclude code no human wrote, whose
correctness no test can meaningfully assert.**

## Alternatives considered

### Alternative 1 — Change nothing; raise the gate to 76 under policy B

Keep measuring generated l10n; set `MIN_COVERAGE` just under the
current 76.25%.

- **Pro**: no policy argument to defend; nothing looks like
  redefinition.
- **Con**: locks in a metric that mixes locale distribution with
  product-code quality, and that drifts downward every time a string is
  added. The 80% target becomes unreachable by any means other than
  writing assertion-free multi-locale render tests — i.e. the policy
  actively incentivises hollow tests.

### Alternative 2 — Exclude the whole `lib/l10n/` directory (policy D)

- **Pro**: simplest possible filter, one glob.
- **Con**: also drops `app_localizations.dart`, which contains the real
  `LocalizationsDelegate` implementation and `supportedLocales` wiring —
  actual logic, already 94.7% covered. Gains 0.03pt over policy C
  (81.51 vs 81.54) while discarding a genuine signal. Laziness with no
  upside.

### Alternative 3 — Exclude only per-locale delegates (policy C) — **selected**

Exclude `lib/l10n/app_localizations_*.dart`; keep
`lib/l10n/app_localizations.dart` in scope.

- **Pro**: removes exactly the generated string tables, retains the
  hand-meaningful delegate logic. Most precise available line.
- **Con**: the filter glob is slightly more specific and must not be
  loosened carelessly later (addressed under Future maintenance rules).

### Alternative 4 — Cover the l10n files properly instead of excluding

Write per-locale render tests until Arabic reaches parity with English.

- **Pro**: would genuinely exercise RTL layout, which is a real,
  currently-open gap.
- **Con**: conflates two goals. The *value* of such tests lives in the
  widget files they exercise, and would be reported there. Their effect
  on l10n line coverage is a side effect, not the point. Pursuing them
  to move this metric is the wrong motivation for the right work —
  RTL/accessibility testing is tracked separately in
  `RELEASE_PLAN_V1.md` §2 and should be justified on its own terms.

## Decision

1. Add `lib/l10n/app_localizations_*.dart` to the lcov exclusion list in
   `.github/workflows/ci.yml`, alongside the existing `**/*.g.dart`
   exclusion, on the stated grounds that both are generated code.
2. Keep `lib/l10n/app_localizations.dart` in scope.
3. Set `MIN_COVERAGE` to **80**, matching the v1.0 target
   `ARCHITECTURE.md` states, which measurement shows is now genuinely
   met (81.54%) under the corrected denominator.
4. Record all four measured figures (51.96 / 76.25 / 81.54 / 81.51),
   the exact filter added, and this record's id in
   `RELEASE_DASHBOARD.md` when Go/No-Go box 7 is closed. **The filter
   change and the threshold change must land together, in one commit,
   citing this record** — never as two unexplained edits.

### 4. Why this is NOT gaming coverage

Stated plainly, because the appearance is real and worth confronting:
this change raises the reported number by ~5.3 points by removing lines
from the denominator, and it brings the project across its own 80%
target in the same motion. That pattern deserves suspicion by default.

What distinguishes it from gaming:

- **No untested product line becomes "tested."** Every hand-written
  line's covered/uncovered status is identical before and after. The
  numerator over product code does not move.
- **The removed lines are not product code by any definition the
  project already uses.** They are generated from `.arb` files by a
  build step, in the same category as the Drift output the project
  excluded from day one.
- **The removed measurement carried no signal.** A metric that reports
  4.3% and 69.3% for two structurally identical files is measuring test
  locale, not test quality. Deleting noise from a measurement improves
  it; that is not the same as deleting evidence.
- **It closes an incentive to fake coverage, rather than opening one.**
  Under the current policy the cheapest path to 80% is assertion-free
  multi-locale rendering. Under this policy that path yields nothing.

The honest framing is therefore: *this is a denominator correction that
happens to cross a threshold, not a threshold reached by choosing a
convenient denominator.* If the corrected figure had come out at 74%,
the correct action would have been to adopt this same policy and set
the gate at 72 — the policy argument does not depend on the number it
produces.

### 5. Why the release remains honest

Acceptance of this record is **conditional on disclosure**.
`RELEASE_DASHBOARD.md` §6 already names this exact hazard — *"treat any
gap found as a genuine finding, not a target to quietly lower
instead"* — and that warning applies with equal force to raising a
number by redefinition.

The release stays honest only if all of the following hold:

- All four figures are published, not just the flattering one.
- The 80% claim is always stated with its scope: *"80% of hand-written
  product code, generated sources excluded"* — never as a bare "80%
  coverage."
- The one real loss is recorded rather than buried: excluding these
  files removes an accidental indicator that Arabic/RTL is barely
  exercised (4.3%). That gap does not disappear; it moves to where it
  belongs, as an explicit open item under
  `RELEASE_PLAN_V1.md` §2 "Verification gaps," and must not be treated
  as closed by this record.

If those conditions are not met, this record should be rejected. The
policy is defensible; an undisclosed version of it is not.

## Pros

- Generated code is treated by one consistent rule instead of two.
- Coverage becomes attributable: a drop now points at product code.
- Denominator stops inflating with translation volume.
- Removes the cheapest route to hollow coverage gains.
- Makes the v1.0 coverage criterion (Go/No-Go box 7) closable on
  measured evidence for the first time.

## Cons

- Raises the reported figure by ~5.3pt without any new test being
  written — requires disclosure to avoid reading as goalpost-moving.
- Drops the three `Intl.pluralLogic` sites (one per locale) from
  measurement; small, but genuinely the only real logic in those files.
- Removes an accidental RTL under-testing signal, which must be
  re-homed explicitly rather than lost.
- A gate of 80 leaves ~1.5pt (~116 lines) of headroom; a large untested
  addition will turn CI red. That is the gate working as intended, but
  it is tighter than the status quo.

## Consequences

- `.github/workflows/ci.yml` gains one lcov `--remove` pattern and its
  `MIN_COVERAGE` moves 70 → 80.
- CI fails if hand-written coverage falls below 80% — roughly 116 lines
  of new untested code. The project's existing Definition of Done
  ("every new feature ships tests in the same change") already
  sustains this: Sprint R3.1 added 74 lines of widget code and coverage
  moved *up* (81.46 → 81.54).
- `RELEASE_DASHBOARD.md` Go/No-Go box 7 becomes closable.
- Any future lowering of `MIN_COVERAGE` must be a documented decision
  with the measured number stated — never a silent edit. A superseding
  DR is the expected mechanism.

## Future maintenance rules

1. **The exclusion list is for generated code only.** A path may be
   added if and only if it is machine-generated from an in-repo source
   of truth, never hand-edited, and regenerable by a documented command.
   "This file is hard to test" is not a qualifying reason and never
   becomes one.
2. **New generators inherit this rule automatically.** If the project
   later adopts `freezed`, `json_serializable`, `mockito` codegen, or
   similar, their output is excluded under the same justification — and
   the exclusion is added in the same change that introduces the
   generator, not retroactively once it starts hurting the number.
3. **Do not loosen the l10n glob.** The pattern is
   `app_localizations_*.dart`, deliberately not `lib/l10n/**`.
   `app_localizations.dart` stays measured. If a future
   `flutter gen-l10n` layout change breaks this distinction, re-derive
   it rather than widening the glob for convenience.
4. **Raise the gate as coverage rises; never lower it silently.**
   Increases may be made freely when measurement supports them.
   Decreases require a superseding DR stating the measured figure and
   the reason.
5. **Re-measure and re-state at each release.** The four-figure
   disclosure is part of release sign-off, not a one-time exercise for
   v1.0.
6. **Coverage is a floor, not a goal.** No test may be written whose
   purpose is to move this number. If a test does not assert something
   a reader would care about, it does not belong in the suite
   regardless of what it does to coverage.

## Recommendation

Accept, conditional on the disclosure requirements in §5 being met in
the same change that edits CI. Implement as a single commit that adds
the lcov pattern, moves `MIN_COVERAGE` to 80, updates
`RELEASE_DASHBOARD.md` with all four figures and a pointer to this
record, and re-homes the Arabic/RTL testing gap as an explicit open
item.

If the disclosure is not going to be written, reject this record and
keep policy B with the gate raised to 75 — an honest bad metric is
preferable to a good metric nobody can audit.

## References

- `.github/workflows/ci.yml` — current gate and filters
- `ARCHITECTURE.md` — 80% v1.0 coverage target
- `docs/release/RELEASE_DASHBOARD.md` §5 item 7, §7 box 7, §6 risks
- `docs/release/RELEASE_PLAN_V1.md` §2 "Verification gaps"
- `docs/release/PHASE3_SPRINT_R3_PLAN.md` — sprint context
- Measurements: `flutter test --coverage` on `main` @ 802 tests,
  post-Sprint-R3.1
