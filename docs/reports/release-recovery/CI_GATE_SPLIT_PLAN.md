# CI Gate Split Plan

Sprint: Release Recovery Phase 2. Analysis and planning only — no code
was written, no branch touched, nothing committed, pushed, or opened
as a PR. Builds directly on the component inventory in
[`CI_GATE_CORE_PLAN.md`](CI_GATE_CORE_PLAN.md); this document doesn't
re-derive that inventory, it acts on it.

---

## Part 4 — Refactoring plan

### Target shape: two files, not one

| File | Contains | Runs on |
|---|---|---|
| `test/repository_boundary_test.dart` | Everything marked **Core** in the inventory: `_restricted`, `_trackedFiles`, `_restrictionFor`, `_trackedFileSizes`, `_mb`, `_maxTrackedFileBytes`, the exemption **mechanism** (`_grandfathered` as a concept), and B1 #1–6 + B2 #7–9 | Any branch, unconditionally |
| `test/repository_boundary_completeness_test.dart` *(new)* | Only B2 #10, rewritten to not hard-fail when there's nothing to prove itself against | Any branch, but reports "not yet applicable" until real oversized content exists |

Splitting into two **files** rather than two `group()`s in one file is
deliberate: it means a reviewer (or a future contributor skimming
`test/`) sees the boundary the moment they see the file list, not only
after opening the file and reading which group a given test sits in.

### `_grandfathered`: mechanism stays, value becomes branch-correct

The map's presence, its consultation by the deny-check and size-check,
and the three hygiene tests that watch it (B1 #3–5) all move into the
core file unchanged as **logic**. Its **value**, when this file is
authored for `main`, becomes:

```dart
const Map<String, String> _grandfathered = {};
```

This is not a weakening — it's a correction. An empty map makes B1 #2
and B2 #8 (the two actual protective checks) evaluate every tracked
path with zero exemptions, which is the *strictest* configuration the
mechanism can be in. B1 #3–5 pass vacuously and correctly, and keep
doing their job (catching future staleness) from that point forward.

### B2 #10: rewritten, not deleted, not weakened

Current form:
```dart
final neededBySizeGuard = _grandfathered.keys
    .where((p) => (sizes[p] ?? 0) > _maxTrackedFileBytes);
expect(neededBySizeGuard, isNotEmpty, ...);
```

Proposed form for the new completeness file:
```dart
final neededBySizeGuard = _grandfathered.keys
    .where((p) => (sizes[p] ?? 0) > _maxTrackedFileBytes);

if (neededBySizeGuard.isEmpty) {
  markTestSkipped(
    'No grandfathered entry currently exceeds the size threshold on '
    'this branch — the size guard has nothing to prove itself '
    'against yet. Not a failure: re-enable this assertion once real '
    'oversized content is grandfathered (see CI_GATE_CORE_PLAN.md).',
  );
  return;
}
expect(
  neededBySizeGuard.every(
    (p) => RegExp('giai đoạn [A-F][0-9]').hasMatch(_grandfathered[p]!),
  ),
  isTrue,
  reason: '...',
);
```

This preserves the exact original assertion — every oversized
grandfathered entry must name its removal phase — for any branch where
oversized content actually exists (i.e., `sprint1-my-library` today,
`main` once G10 or an equivalent lands). It only changes what happens
when there's *nothing yet to check*, from "hard fail, permanently, on
a branch with no oversized content" to "explicitly report not
applicable." **Nothing about what the test enforces changes; only what
it does in the absence of anything to enforce.**

### Documentation refresh (non-blocking)

`_maxTrackedFileBytes`'s justification comment should be updated when
this ports to `main`, to note plainly that the specific measured
figures (32.7 MB database, 10 MB Ibn Kathir file, 0.401 MB largest
legitimate file, etc.) describe `sprint1-my-library`'s distribution at
time of writing, and that `main`'s own largest legitimate file is
whatever test B2 #9 currently finds at runtime — which the test itself
already verifies has a real 2× margin, independent of the comment.
This is a documentation-accuracy task, not a prerequisite for merging;
listed here for completeness, not as a gate.

---

## Part 5 — Independent mergeability: verified, not assumed

**Conclusion: the Core Gate (the file described in Part 4's left
column) can be merged to `main` today with no code, schema, or
workflow dependency blocking it.** Checked each candidate dependency
directly rather than assuming none exist:

| Candidate dependency | Checked | Result |
|---|---|---|
| Runtime tooling (`git`, Dart, `flutter_test`) | Already present and used by every other test in the suite | **No new dependency** |
| CI workflow wiring | `ci.yml`'s `flutter test --coverage` step runs all of `test/` unconditionally | **No new dependency — already automatic** |
| Application code (`lib/`) | The gate reads only `git ls-files` and on-disk sizes | **Zero coupling** — this is the one part of the entire release-recovery inventory with no relationship to any feature group |
| Licence registry (`DR-2026-0010`) | Header comment itself states the deny-list is hand-seeded until phase F3, which doesn't exist yet | **Not a current dependency — explicitly future work, out of scope** |
| `.gitignore` / pre-commit hook | Checked directly (`CI_GATE_CORE_PLAN.md` §2) — neither is tracked, and the gate's own design already assumes neither can be relied on | **Not a dependency — the gate exists because these can't be trusted** |
| `_grandfathered` content | Becomes `{}` for `main` | **Not a dependency on another release group — a one-line data value, authored as part of this port itself** |

### The one real, non-blocking finding: dangling documentation references

The gate's failure messages point a developer to two files:

| Referenced path | Introduced by | Tracked on `main` today? |
|---|---|---|
| `docs/adr/DR-2026-0013-ci-licence-gate.md` | `1d4cf2c` (release-inventory group **G15**) | No |
| `docs/LICENSING.md` | `bb445ef` (release-inventory group **G11**, Sprint 35.0) | No |
| `docs/adr/DR-2026-0009-data-supply-chain.md` (B2 message only) | `1d4cf2c` (**G15**) | No |

**This does not block the merge or affect what the test enforces** —
nothing in the executable logic checks that these paths exist; they
only appear inside human-readable failure text. But shipping the gate
so its own error message points at nothing is the same class of defect
this project already carries and has already flagged once
(`DR-2026-0002` in `docs/adr/README.md`) — avoidable at near-zero cost,
not worth repeating knowingly.

**This is a soft dependency, not a hard one, and it splits across two
different release groups, not one:**

- `docs/adr/DR-2026-0013-ci-licence-gate.md` and `DR-2026-0009-...md` →
  **G15**, already classified **Ready to Merge**, no blockers of its
  own (`RELEASE_RECOVERY_PLAN.md`).
- `docs/LICENSING.md` → **G11**, which is *not* Ready to Merge on its
  own terms (Sprint 35.0 carries signing/store work whose usefulness
  is gated on G10). Pulling the single file `docs/LICENSING.md` out of
  G11 to accompany the gate, rather than waiting for all of G11, is
  the cheaper option and is flagged here as a decision for whoever
  implements this split, not decided in this analysis.

**Net: zero blocking dependencies. One cosmetic, fully documented,
independently resolvable loose end**, resolvable either by pairing the
merge with G15 (+ the single `docs/LICENSING.md` file), or by
temporarily adjusting the message text, or by accepting the gap
explicitly as this project has done once already for `DR-2026-0002`.

---

## Part 6 — Implementation sequence, minimizing review risk

Ordered so each step is independently verifiable before the next
begins — the same "prove it before trusting it" discipline this
project has used for every prior gate (B1, B2 were each proven by
deliberate breakage before being trusted).

| # | Step | Verifies | Review size |
|---|---|---|---|
| 1 | Split the file locally into the two-file shape from Part 4, on a scratch/feature branch — **not** on `main` yet | The split itself doesn't change behavior on `sprint1-my-library`, where grandfathered content still exists | Small — mechanical move, no logic change to the 9 Core tests |
| 2 | Run the full suite on that branch; confirm exactly 10/10 tests still pass, identical to pre-split | No regression from the split | Trivial — pass/fail, no judgement call |
| 3 | Deliberately empty `_grandfathered` in a scratch copy and re-run; confirm B1 #2 and B2 #8 get *stricter* (more paths flagged, not fewer) and B1 #3–5 pass vacuously | The "empty map is safe, not weaker" claim from Part 4, proven rather than asserted | Small — this is the load-bearing proof for the whole plan |
| 4 | Deliberately leave `_grandfathered` empty with no oversized tracked file present; confirm the rewritten B2 #10 reports "not applicable" rather than failing, and confirm it correctly fails again once a real oversized+grandfathered file is reintroduced | The rewritten completeness test still enforces its original property when there's something to enforce | Small — two directed test runs |
| 5 | Author the `main`-targeted core file with `_grandfathered = {}` and the refreshed threshold comment (Part 4) | The actual artifact intended for `main` | Medium — this is the file a reviewer actually reads |
| 6 | Resolve the documentation loose end (Part 5): either merge G15 alongside, extract `docs/LICENSING.md` alone, or adjust the message text — whichever is chosen | No dangling reference ships | Small |
| 7 | Merge the core file (step 5) to `main`, alone — no other release group needs to accompany it except the doc resolution from step 6 | Independent mergeability, for real, not just on paper | This is the actual release; everything before it was rehearsal |
| 8 | Hold the completeness file (`repository_boundary_completeness_test.dart`) out of `main` until G10 resolves, or merge it now in its "not applicable" state — either is safe; recommend merging it now, since a test that correctly reports "nothing to check yet" is more honest sitting in the repository than being absent | Nothing — this step carries no risk either way, included for completeness of the sequence |

Steps 1–4 can all happen without touching any real branch — they're
rehearsal on a disposable scratch copy, exactly how B2's original size
guard was proven by deliberately adding and removing a fake oversized
file before it was trusted. Step 7 is the only step that actually
changes `main`, and by the time it happens, six prior steps will have
already proven every claim this plan makes about it.

---

## Executive Summary

The CI licence gate's coupling to the grandfathered tafsir content was
real but narrow: of ten tests, nine are Core protection with no
dependency on any specific file existing, and exactly one
(`B2 #10`) exists solely to prove the size guard has been tested
against a real example — a completeness concern, not a protection
concern. Splitting the file along this line, emptying `_grandfathered`
for `main`, and rewriting the one completeness test to report "not
applicable" instead of hard-failing preserves every protective
property the gate currently has — indeed makes the two core checks
*stricter* on `main`, since zero exemptions means zero paths get a
pass. Checked directly rather than assumed: the Core Gate has no
dependency on application code, the licence registry, `.gitignore`, a
pre-commit hook, or any CI workflow change — `ci.yml` already runs it
automatically. The one real finding is cosmetic: two of its own
failure messages point to documentation files not yet on `main`
(`DR-2026-0013`, `DR-2026-0009` from release group G15; `LICENSING.md`
from G11), fully resolvable in either direction without touching the
gate's logic.

## Remaining Risks

1. **The split itself, if done carelessly, could accidentally weaken
   B1 #2 or B2 #8** (the two real protective checks) rather than just
   relocate B2 #10. Step 3 of the implementation sequence exists
   specifically to catch this before it ships, by proving the empty-map
   configuration is stricter, not looser.
2. **The rewritten B2 #10 could be implemented as a silent skip instead
   of a visible "not applicable" report**, which would make it
   indistinguishable from a test nobody wrote. The proposed
   implementation uses an explicit skip message for exactly this
   reason; a reviewer should confirm the message survives into the
   final version.
3. **The documentation loose end could be forgotten** if the person
   implementing this treats Part 5's "non-blocking" finding as "doesn't
   matter" rather than "resolve cheaply, don't ship dangling." This
   project has already carried one unresolved dangling-ADR-reference
   gap (`DR-2026-0002`) for multiple sprints; repeating the pattern
   knowingly, on the file whose entire purpose is preventing repeated
   mistakes, would be a specific kind of avoidable irony.
4. **This plan does not itself resolve G10.** Getting the Core Gate
   onto `main` stops *future* restricted-content commits from landing
   on `main` — it does nothing about the fact that `sprint1-my-library`
   still carries the Ibn Kathir corpus, or about the unsent enquiries
   in `legal/OUTREACH.md`. That risk is unchanged by this entire
   document and should not be read as progress toward resolving it.

## Recommended Implementation Order

1. Steps 1–4 (Part 6): rehearse the split and prove both claims — empty
   map is stricter, not weaker; rewritten completeness test still
   enforces its property when it has something to check — on a
   disposable scratch copy, before writing anything intended for
   `main`.
2. Step 5: author the actual `main`-targeted core file.
3. Step 6: resolve the documentation loose end — recommend extracting
   `docs/LICENSING.md` alone rather than waiting on the rest of G11,
   since G11 itself is gated on G10 and there's no reason to let a
   one-file doc dependency inherit that wait.
4. Step 7: merge the Core Gate to `main`, independently, as its own
   release — not bundled with G15, G11, or anything else beyond the
   single extracted `docs/LICENSING.md` file.
5. Step 8: merge the completeness file in its "not applicable" state at
   the same time or shortly after — low urgency, zero risk either way.
