# Sprint B1 verification report

Role: Release Manager · Date: 2026-07-26 · Subject: `DR-2026-0013`
phase B1, commit `d760626`

Documentation only. No code, workflow, commit or push was produced by
this verification.

---

## 1. Overall CI result

**Run [30201920551](https://github.com/duso201189-nxp/quran-companion/actions/runs/30201920551)**
· head `d760626` · branch `sprint1-my-library` · event `pull_request`
· started 2026-07-26 12:22:15Z

| Job | Result | Duration |
|---|---|---|
| Secret Scan (gitleaks) | ✅ **success** | 0m13s |
| Format · Analyze · Test · Coverage | ✅ **success** | 4m28s |
| Build Web (release) | ✅ **success** | 2m09s |
| Build iOS (no codesign) | ✅ **success** | 3m05s |
| Build Android (PR → APK debug · main/tag → AAB release) | ✅ **success** | 6m19s |

**Run conclusion: `success`. Failures: none. Longest job 6m19s.**

Step-level evidence from the job that exercises the gate:

| Step | Result |
|---|---|
| Kiểm tra format | ✅ success |
| Phân tích tĩnh (mọi cảnh báo đều fail) | ✅ success |
| Chạy unit & widget test | ✅ success |
| Coverage gate ≥ 70% | ✅ success |

### The one technical risk this run retired

The gate shells out to `git ls-files`. `actions/checkout@v4` performs a
**shallow clone** (`fetch-depth: 1` by default), and the `quality` job
does not override it. `ls-files` reads the *index*, not history, so
shallow depth should be irrelevant — but that was an assumption until
this run. It is now observed fact: the gate ran in CI, on a shallow
checkout, and passed.

---

## 2. Verification checklist

| # | Item | Method | Result |
|---|---|---|---|
| 1 | GitHub Actions completed successfully | GitHub REST API, all 5 jobs | ✅ **success**, zero failures |
| 2 | Repository clean | `git status --porcelain` | ✅ **0 tracked dirty files**; 5 untracked design documents (see A2) |
| 3 | Branch synchronised | `git rev-parse HEAD` vs `origin/…` | ✅ both `d760626`, no ahead/behind |
| 4 | No hidden production changes | `git diff --stat 1d4cf2c~1..d760626 -- lib assets android ios pubspec.* analysis_options.yaml l10n.yaml .github` | ✅ **empty diff** |
| 5 | Change surface | `git diff --name-status` over both commits | ✅ 8 files: 6 new ADRs, 1 ADR index, **1 new test** |
| 6 | Formatter | `dart format --output=none --set-exit-if-changed lib test` | ✅ 390 files, 0 changed (also green in CI) |
| 7 | Analyzer | `flutter analyze --fatal-infos` | ✅ No issues found (also green in CI) |
| 8 | Tests | `flutter test` | ✅ **915 passing** (909 + 6) |
| 9 | Coverage | CI lcov gate | ✅ ≥ 70% · local: 54.1% all, **84.1% hand-written** |
| 10 | Gate — clean tree | `flutter test test/repository_boundary_test.dart` | ✅ 6/6 |
| 11 | Gate — blocks a new corpus | `git add -f tool/data/tafsir_zz-verify.json` | ✅ **red**, named the file and the reason |
| 12 | Gate — allow-list self-cleans | `git rm --cached tool/data/transliteration.json` | ✅ **red**, flagged the stale entry |
| 13 | Rollback validity | `git revert --no-commit d760626` rehearsed | ✅ gate file removed, **suite 915 → 909**, nothing else touched |
| 14 | Rollback reversibility | `git reset --hard HEAD` after rehearsal | ✅ 0 dirty files, gate 6/6 again |
| 15 | No dependency on future phases | imports + external references audited | ✅ 3 imports (`dart:convert`, `dart:io`, `flutter_test`); 0 references to registry/storage/artifact/manifest |
| 16 | Referenced files exist | `docs/LICENSING.md`, `docs/adr/DR-2026-0013-…md` | ✅ both tracked |

**Item 13 detail.** The revert removes exactly the six gate tests —
915 → 909 — and the remaining suite stays green. The rollback
instruction `git revert d760626` is therefore valid, complete, and
touches nothing else. No rebuild, no data change, no coordination.

---

## 3. Approval decision

# APPROVED

Every gating item passed. No issue was found that invalidates B1.

---

## 4. Observations

### A · B1 findings

**A1 — The gate is correct and provably load-bearing.** Verified
independently of the implementation report: green on a clean tree, red
on a newly added restricted corpus, red on a stale allow-list entry.
Failure messages name the offending path and the reason.

**A2 — Five untracked design documents remain at the repository root.**
`ARCHITECTURE_DECISION_RECORD.md`, `ARCHITECTURE_FREEZE_REPORT.md`,
`DATA_OS_ARCHITECTURE.md`, `DATA_SUPPLY_CHAIN.md`,
`IMPLEMENTATION_PROGRAM.md`.

Not a defect: each came from a sprint that explicitly instructed
"do not commit", they are untracked, and they affect neither CI, the
build, nor the gate. One housekeeping note —
`ARCHITECTURE_DECISION_RECORD.md` now duplicates the filed
`docs/adr/DR-2026-0008-…md` and carries a banner saying so; it can be
deleted whenever convenient. **Does not affect approval.**

**A3 — The ADRs were committed alongside B1, in a separate commit.**
`1d4cf2c` files `DR-2026-0008` … `DR-2026-0013`; `d760626` is B1 alone.
This was necessary rather than scope creep: B1's failure message directs
a developer to `docs/adr/DR-2026-0013-ci-licence-gate.md`, and shipping
the gate with that file untracked would have created the same
dangling-reference defect the project already carries for
`DR-2026-0002`. Separating the commits preserves B1's requirement to be
reversible by a single `git revert`, which item 13 confirms.

**A4 — Scope was held.** No size guard (B2), no registry derivation
(F3), no production code, no workflow change. The `_grandfathered`
allow-list contains exactly the five files already tracked, each naming
the phase that deletes it, and both properties are asserted by test.

### B · Out-of-scope findings

**B1-OOS — The release-AAB path in CI has never executed.**

Every run on this branch fires as `event: pull_request`, because
`sprint1-my-library` is not in the workflow's `push:` branch list. The
Android job's release steps are gated on
`github.event_name != 'pull_request'`, so on the previous completed run
they report:

```
Build AAB release (main hoặc tag)   skipped
Ghi kích thước AAB vào summary      skipped
Lưu AAB                             skipped
Lưu mapping.txt                     skipped
```

The path added in Sprint 35.0 is therefore correct **by construction
only**. It will first execute on a push to `main` — i.e. at merge.

**This does not invalidate B1** and does not change the approval. B1 is
a test in the `quality` job, which ran and passed. The finding is
recorded because it bears on the merge decision, not on this gate.

*Consequence for the merge checklist:* `MERGE_CHECKLIST.md` D1 —
"CI builds the artifact that ships" — is currently satisfied in
configuration but unproven in execution. It should be treated as
**verified only after** the first `main` run produces the
`app-release-aab` and `r8-mapping` artifacts, which post-merge checks 7
and 8 already require.

**B2-OOS — The data-build step remains dead code in CI.** Every job
shows `Build dữ liệu Qur'an (nếu chưa có cache)` as `success`, but the
shell guard inside it is `if [ ! -f assets/database/quran.sqlite ]` and
the database is committed, so the step succeeds without doing anything.
Pre-existing, documented in `DR-2026-0009`, resolved by phase D1.

---

## 5. Recommendations

### Next sprint

**Start Sprint B2 — the tracked-file size guard.**

| | |
|---|---|
| Objective | fail CI if any tracked file exceeds ~5 MB — catches content *shapes nobody has seen*, which B1's pattern list cannot |
| Files | `test/repository_boundary_test.dart` (extend in place) |
| Effort | ~2 h |
| Risk | Low — but **red on arrival** unless it ships with the same allow-list, since `assets/database/quran.sqlite` (32.7 MB) and four `tool/data/*.json` files are still tracked |
| Rollback | delete the added group |
| Acceptance | green with the documented allow-list · red for any new oversized file · every allow-list entry names the phase that removes it |

B2 depends on nothing from streams A, C, D, E or F, and B1's
infrastructure — tracked-file enumeration, allow-list discipline,
proof-by-breakage — is already in place and now CI-verified.

### Remaining risks

| Risk | Level | Note |
|---|---|---|
| The corpus already in the repository | **Blocker** | B1 stops *new* restricted content. It does nothing about `tool/data/tafsir_en-tafsir-ibn-kathir.json`, still publicly fetchable. That is phase A3. |
| Git history retains the corpus | High | Unchanged by any phase; `DR-2026-0008` Future extensions |
| Release-AAB path unexecuted | Medium | B1-OOS; resolves at the first `main` run |
| Someone widens the deny-list to fix a red build | Medium | The failure message instructs recording licence evidence first |
| Allow-list ossifies | Low | Two tests make it impossible |

### Release readiness

**Unchanged by B1, and that is expected.** B1 is a preventive control,
not a remediation. It moves no release blocker:

| Blocker | Status |
|---|---|
| Ibn Kathir permission / removal | ❌ unchanged — the enquiry remains unsent |
| Legal documents not hosted | ❌ unchanged |
| App icon is the stock Flutter logo | ❌ unchanged |
| Store assets | ❌ unchanged |

What B1 does change is that the *next* corpus cannot repeat the
mistake. That is worth having, and it is not progress toward shipping.

**The highest-value action available remains outside this program:**
send the four enquiries in `legal/OUTREACH.md`. They are drafted, they
have been drafted for six sprints, and their latency is the release
schedule.
