# Repository Boundary Policy Review — 2026-08-03

Not pushed. Read first: `test/repository_boundary_test.dart`,
`test/repository_boundary_completeness_test.dart`,
`docs/reports/release-recovery/CI_GATE_CORE_PLAN.md`,
`docs/reports/release-recovery/CI_GATE_SPLIT_PLAN.md`.

---

## 0. A correction before starting

**`DR-2026-0013` does not exist as a file.** Both test files' headers
cite `docs/adr/DR-2026-0013-ci-licence-gate.md`; `docs/adr/` contains
0001, 0003–0005, 0014–0016, no 0013. This is the same class of gap
already known in this repository — `docs/adr/README.md` documents an
identical situation for `DR-2026-0002` (referenced from six places,
never written). The design intent is fully recoverable from the tests'
own extensive comments and the archived planning documents in
`docs/reports/release-recovery/` (`CI_GATE_CORE_PLAN.md`,
`CI_GATE_SPLIT_PLAN.md`), which is what this review relies on. Not
fixed here — out of this task's scope (documentation gap, not a policy
question), flagged for a future pass.

## 1. Original intent of the threshold

The size-based guard is documented as the second of two independent
defense layers (`test/repository_boundary_test.dart:134-142`):

- **Pattern matching** (`_restricted`) blocks *known shapes* of
  restricted content (`assets/database/*.sqlite`, `tool/data/tafsir_*`,
  `tool/data/transliteration*`, any `.sqlite`/`.db` anywhere).
- **Size blocking** catches *unknown shapes* — content whose filename
  doesn't match any known pattern yet, on the reasoning that "a tracked
  file that's unusually large is almost certainly content, no matter
  what it's called" (`:139-141`).

The threshold's own value was chosen **empirically, not by intuition**
— the file's doc comment is explicit about this (`"CHỌN ... THEO SỐ ĐO,
không theo cảm tính"`). The method, per `CI_GATE_CORE_PLAN.md`
lines 145–156: measure the actual largest *legitimate* (non-restricted)
tracked file on the branch, then pick a threshold comfortably above it
— originally 1 MB against a 0.401 MB font, roughly 2.5×. A second test
(`"ngưỡng còn dư địa thật trên tệp hợp lệ lớn nhất"`) re-derives this
margin **at runtime, on whichever branch is actually running** — not
hardcoded — specifically so that if a future contributor either lowers
the threshold carelessly or adds a large legitimate asset, the
consequence is a **failing test forcing a conscious decision**, not a
silent overly-tight gate (`:359-364`, `:373-380`).

This is exactly what happened. Phase 3 Sprint R3a.1 vendored
`web/sqlite3.wasm` (747,018 bytes) — a legitimate build dependency, not
restricted content — which became the new largest legitimate file and
ate the margin down to `1,048,576 / 747,018 ≈ 1.40×`, below the
required `> 2×`. **The test did exactly its documented job.**

## 2. Should the threshold itself change?

**Yes.** The guard's own design says so: this exact scenario — margin
eroded by a new, legitimate large asset — is one of the two cases the
runtime-margin test exists to force a decision about (the other being a
threshold lowered without justification). This is not a bug to route
around; it's the gate correctly demanding the decision it was built to
demand.

## 3–4. Recommended change, and why not the alternatives

**Recommendation: raise `_maxTrackedFileBytes` from 1 MB to 2 MB.**
Grandfathering `web/sqlite3.wasm` instead was considered and rejected.

### Why not grandfather `web/sqlite3.wasm`

The `_grandfathered` mechanism has a specific, documented meaning that
does not fit here, on two independent grounds:

1. **Semantic mismatch.** Every existing entry and the mechanism's own
   design intent (`:80-94`) is for files *already tracked before the
   gate existed*, each scheduled for **removal** at a named future
   phase — the file's own words: *"Danh sách này chỉ được ngắn đi,
   không bao giờ dài ra"* ("this list only ever shrinks, never grows").
   `web/sqlite3.wasm` is the opposite case: newly added, intended to
   stay **permanently** — the Web platform cannot function without it.
   Grandfathering it would assert a future removal that will never
   happen, and there is no "phase" to name (every entry's reason string
   is checked by its own test, `:247-256`, to match
   `giai đoạn [A-F][0-9]` — a fabricated phase would be a lie the tests
   themselves would force into existence).
2. **Doesn't generalize.** A grandfather entry fixes exactly one file.
   If `sqlite3.wasm` or `drift_worker.js` grow even slightly on a
   future version bump (both are already tracked as version-pinned
   binaries whose exact size is not otherwise controlled — see
   `docs/DATA_PIPELINE.md`'s versioning rule), each change would need
   its own new permanent entry, growing a list that is supposed to only
   shrink. This is the "workaround exemption" this task's own rules
   caution against — it is not demonstrably the best long-term
   solution; it's the locally cheapest one that pushes the same problem
   to the next binary update.

Raising the threshold is the structural fix: it re-establishes real
margin for the *class* of "legitimate binary build assets," which the
Web platform work introduced as a genuinely new category this repo
didn't have before (everything above 100 KB previously was either a
font or grandfathered content).

## 5. Exact new value, justified quantitatively

**2 MB (`2 * 1024 * 1024` = 2,097,152 bytes).**

Independently re-measured against `main`'s current tracked files (not
taken from the failing test's own numbers):

| File | Size | Status |
|---|--:|---|
| `assets/database/quran.sqlite` | 19.031 MB | grandfathered (D1) |
| `tool/data/transliteration_words.json` | 2.534 MB | grandfathered (D2) |
| `tool/data/transliteration.json` | 0.731 MB | grandfathered (D2) |
| **`web/sqlite3.wasm`** | **0.712 MB** | **largest legitimate file** |
| `assets/fonts/Inter-Bold.ttf` | 0.401 MB | legitimate |
| `assets/fonts/Inter-SemiBold.ttf` | 0.400 MB | legitimate |

```
required:  threshold > 2 × 747,018       = 1,494,036 bytes
chosen:    2,097,152 bytes  →  margin = 2,097,152 / 747,018 ≈ 2.81×
```

Reasoning for 2 MB specifically, not the bare minimum:

- **Matches the original design's margin, not just clears the test.**
  The original 1 MB gave ≈2.5× headroom over its largest file; a value
  just over the 2× floor (e.g. 1.5 MB → 2.10×) would pass today but
  immediately reproduce the same "too tight" failure mode on the next
  minor `sqlite3.wasm` version bump — the exact mistake this review is
  fixing, just relocated. 2 MB's 2.81× is in the same range as the
  original choice.
- **Round, defensible, easy to re-justify later.** Consistent with the
  original constant's own instruction to choose "theo số đo" (by
  measurement) but land on a clean number, not a bare computed minimum.
- **Still a real, tight bound.** Every actual restricted-content shape
  this gate exists to catch (a Tafsir corpus, a translation set, a
  content database) is measured in this repo at 0.7–19 MB — 2 MB does
  not meaningfully open a door for that class of content, and the
  independent pattern-matching layer (`_restricted`) is completely
  unaffected by this change regardless.

### Trade-off acknowledged, not hidden

Raising the size-guard ceiling does narrow the *specific* range
(1–2 MB) where an unknown-shaped restricted file would be caught by
size alone rather than by pattern. This is judged acceptable because
(a) the pattern-matching layer is the primary defense and is untouched,
(b) every known restricted-content shape in this project is far outside
1–2 MB either direction, and (c) the alternative (grandfathering) fixes
nothing about this trade-off while adding the structural problems in
§4 — it doesn't avoid the trade-off, it just doesn't examine it.

## 6. What was changed

**Exactly two files, both already part of the repository-boundary
mechanism — nothing else touched:**

| File | Change |
|---|---|
| `test/repository_boundary_test.dart` | `_maxTrackedFileBytes`: `1024 * 1024` → `2 * 1024 * 1024`. Justification comment (previously lines 144–164) rewritten with today's measured distribution, `web/sqlite3.wasm` identified as the new largest legitimate file, and an explicit "LỊCH SỬ ĐỔI NGƯỠNG" (threshold change history) section explaining why 1 MB → 2 MB, matching this project's established practice of never silently changing a number without recording why. |
| `test/repository_boundary_completeness_test.dart` | `_maxTrackedFileBytes` updated to match, per this file's own doc comment contract: *"TRÙNG với ngưỡng trong tệp cốt lõi"* ("must match the core file's threshold"). This duplication is pre-existing and intentional (`docs/reports/release-recovery/RED_TEAM_REVIEW.md:253` already documents it as an accepted cost of the two-file split) — updating only one side would have left the two files silently disagreeing, violating that documented invariant. |

**Not touched**: `docs/reports/release-recovery/*.md` — these are
archived, point-in-time planning documents (per `CLAUDE.md`'s own
convention for `docs/reports/`), not living specifications; editing
them to reflect an ongoing policy change would misrepresent them as
current. `docs/LICENSING.md` — grepped, contains no threshold
reference. No `_grandfathered` entry was added (§4). No production
code, no CI workflow, no other test file.

## 7. Gate results

```
flutter analyze --fatal-infos
...
No issues found! (ran in 7.9s)
```

```
flutter test test/repository_boundary_test.dart test/repository_boundary_completeness_test.dart
...
00:00 +10: All tests passed!
```

The specific test that failed before this change —
`"ngưỡng còn dư địa thật trên tệp hợp lệ lớn nhất"` — now passes; the
sibling check (`"KHÔNG tệp theo dõi nào vượt ngưỡng"`) correctly reports
the new `2048 KB` threshold.

```
flutter test
...
01:07 +802: All tests passed!
```

Full suite, unchanged count (802) — this was a two-constant policy
correction, not a functional change to anything else.

---

REPOSITORY BOUNDARY UPDATE COMPLETE — not committed, not pushed.
