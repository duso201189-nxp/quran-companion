# Phase 3 — Sprint R3a.3 Report: Web Asset CI Guard

Read first: `docs/release/PHASE3_SPRINT_R3A1_REPORT.md`,
`docs/release/PHASE3_SPRINT_R3A2_REPORT.md`. No commit was created;
nothing was pushed — awaiting review per this task's instructions.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `.github/workflows/ci.yml` | Modified (+20 lines) | One new step in the `build-web` job: verifies `web/sqlite3.wasm` and `web/drift_worker.js` exist, fails the job immediately with a named error if either is missing |

**Not touched**: anything under `lib/` or `test/` (confirmed —
`git status --short -- lib/ test/` returns empty before the gates were
run). No runtime code, no provider, no database code.

# Design

## Why this guard exists

`web/sqlite3.wasm` and `web/drift_worker.js` are the two files vendored
in Sprint R3a.1. They are **not generated** by any tool this repo runs
— not `build_runner`, not the `tool/build_quran_db.py` pipeline, not
`flutter pub get`. Nothing else in CI would notice if either were
accidentally deleted, renamed, or excluded by a future `.gitignore`
change. And critically — as `PHASE3_SPRINT_R3A1_REPORT.md` documented
and `docs/DATA_PIPELINE.md` already stated before this sprint — **their
absence does not fail the build**: `flutter build web --release`
succeeds either way, and the failure only surfaces at runtime, inside a
browser, which CI never exercises. This is exactly the failure mode
that went undetected for the entire time the Web platform was broken
(the original R3a blocker this whole sprint arc addressed).

## Why this is the smallest possible guard

- **One step, no new job, no new file.** Everything needed is a loop
  over two paths and an `exit` code — no script file, no custom action,
  no new dependency.
- **Placed immediately after `checkout`, before `Cài Flutter`.** This
  is the earliest point the files could possibly be checked, and it
  means a missing-file failure costs a few seconds of CI time instead
  of the ~1-2 minutes a Flutter SDK install would otherwise waste on a
  build that's going to fail anyway.
- **No new dependency.** `test -f` is a POSIX shell builtin, already
  available on every runner this workflow uses (`ubuntu-latest`) — no
  package install, no new action pinned to a version, nothing else that
  could itself go stale or need maintenance.
- **Reports both files if both are missing**, not just the first —
  verified in testing (see below) — so a future contributor gets the
  complete picture in one CI run rather than fixing one file, re-running,
  and discovering the second.
- **Uses GitHub Actions' native `::error::` annotation format**, so the
  failure surfaces directly in the PR/commit checks UI with the exact
  missing path and a pointer to `docs/DATA_PIPELINE.md`, not just a
  generic "step failed, check logs."

## What was deliberately not built

- No check for *version correctness* (whether the vendored files match
  the pinned `sqlite3`/`drift` versions in `pubspec.lock`) — that would
  require parsing `pubspec.lock` and either hardcoding expected hashes
  or fetching them from GitHub at CI time, which is meaningfully more
  machinery for a problem `docs/DATA_PIPELINE.md`'s existing provenance
  table (added in R3a.1, with recorded SHA-256 hashes) already makes
  auditable by a human on every version bump — that bump is already a
  `CLAUDE.md` "stop and ask before" event, not something that should
  happen unattended in CI anyway.
- No check inside `build-android` or `build-ios` — those jobs never
  touch `web/`, so a guard there would be dead code.

# Implementation

Added immediately after `- uses: actions/checkout@v4` in the `build-web`
job of `.github/workflows/ci.yml`:

```yaml
- name: Kiểm tra tồn tại web/sqlite3.wasm + web/drift_worker.js
  run: |
    MISSING=0
    for f in web/sqlite3.wasm web/drift_worker.js; do
      if [ ! -f "$f" ]; then
        echo "::error::Thiếu file bắt buộc cho Web runtime: $f (xem docs/DATA_PIPELINE.md mục \"Web runtime\")"
        MISSING=1
      fi
    done
    exit $MISSING
```

# Verification (before running the required gates)

The guard's logic was tested standalone, outside CI, before trusting it:

| Scenario | Result |
|---|---|
| Both files present (actual repo state) | Exit code `0` — no errors printed |
| Only `web/drift_worker.js` missing (simulated in a scratch directory, not the real repo) | Exit code `1`, one `::error::` line naming exactly that file |
| Both files missing (simulated) | Exit code `1`, **two** `::error::` lines, one per file |

This confirms the guard fails **immediately and specifically** (task 3)
rather than failing generically or only catching the first missing file.

`.github/workflows/ci.yml` was also re-parsed with a YAML loader after
the edit to confirm the file is still structurally valid and all five
jobs (`secret-scan`, `quality`, `build-android`, `build-web`,
`build-ios`) remain intact.

# Gate results

## `flutter analyze --fatal-infos`

```
Analyzing quran_companion...
No issues found! (ran in 8.6s)
```

## `flutter test`

```
01:10 +802: All tests passed!
```

802/802 — unchanged from the pre-sprint count, as expected: no test,
provider, or runtime file was touched, only a CI workflow step.

## `flutter build web --release`

```
Compiling lib\main.dart for the Web...
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 22144 bytes (98.7% reduction).
√ Built build\web
```

Clean build — this gate exercises the same build the new CI step now
guards, confirming the guard's precondition (files present) still holds
and the build it protects still succeeds.

# Remaining follow-up

- **Not yet committed** — per this task's explicit instruction, awaiting
  review.
- **Version-correctness auditing remains manual**, by design (see
  "What was deliberately not built" above) — `docs/DATA_PIPELINE.md`'s
  provenance table is the source of truth for that, not CI.
- **`RELEASE_DASHBOARD.md`** still has not been updated to reflect the
  Web platform work across R3a.1–R3a.3 — consistent with every prior
  report in this sub-sprint arc, this remains explicitly out of scope
  until requested.

---

READY FOR R3A.3 REVIEW
