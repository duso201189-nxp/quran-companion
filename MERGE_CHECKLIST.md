# Merge checklist — `sprint1-my-library` → `main`

Prepared at Sprint 37.0. **The merge has not been performed.** Nothing
in this document has been executed against `main`.

| Fact | Value |
|---|---|
| Source branch | `sprint1-my-library` |
| Target branch | `main` |
| Commits ahead of `main` | **22** |
| Commits behind `main` | **0** |
| Merge type possible | **fast-forward** |
| Conflicts | **none possible** — `main` is an ancestor of HEAD |
| Working tree | clean at merge time (verified below) |

---

## Pre-merge

Run every command from the repository root on `sprint1-my-library`.

| # | Check | Command | Pass condition |
|---|---|---|---|
| 1 | Working tree clean | `git status --porcelain` | no output |
| 2 | Branch pushed | `git status -sb \| head -1` | no `ahead` marker |
| 3 | Still 0 behind main | `git rev-list --count HEAD..origin/main` | `0` |
| 4 | Fast-forward possible | `git merge-base --is-ancestor origin/main HEAD` | exit 0 |
| 5 | Formatter | `dart format --output=none --set-exit-if-changed lib test` | exit 0 |
| 6 | Analyzer | `flutter analyze --fatal-infos` | "No issues found!" |
| 7 | Tests | `flutter test` | "All tests passed!" (909) |
| 8 | Coverage | `flutter test --coverage` + CI's lcov filter | ≥ 70% |
| 9 | Truthfulness gate | `flutter test test/feature_truthfulness_test.dart` | 7/7 |
| 10 | Store metadata gate | `flutter test test/store_metadata_test.dart` | 11/11 |
| 11 | Attribution gate | `flutter test test/attribution_real_data_test.dart` | 4/4 |
| 12 | Architecture boundaries | `flutter test test/architecture_boundaries_test.dart` | 5/5 |
| 13 | Release build | `flutter build appbundle --release` | AAB produced |
| 14 | Signature | `jarsigner -verify -verbose:summary -certs …app-release.aab` | "jar verified", CN=Du So |
| 15 | Licence texts in artifact | `unzip -l …app-release.aab \| grep licenses/` | 4 files |
| 16 | Website links | every relative `href` in the 5 HTML pages resolves | 0 broken |
| 17 | No JavaScript on the site | `grep -c "<script" *.html` | 0 |
| 18 | Pages exclusions intact | `_config.yml` excludes `assets/database/`, `assets/fonts/`, `lib/` | present |
| 19 | CI green on the branch head | GitHub Actions run for this SHA | all jobs pass |

**Do not proceed if any of 1–19 fails.** Item 19 is the project's own
rule: `README.md` states `main` is protected and merges require a fully
green CI run.

### Conflict review

None to review. `git merge-base --is-ancestor origin/main HEAD` returns
success, meaning every commit on `main` is already contained in this
branch. The merge is a fast-forward and cannot conflict.

This will stop being true if anyone pushes to `main` before the merge.
Re-run checks 3 and 4 immediately before merging.

---

## Merge

**Use a pull request, not a local merge.** `main` is protected and the
CI run is the gate.

```bash
# 1. Confirm nothing changed on main while you were preparing
git fetch origin
git rev-list --count HEAD..origin/main      # must print 0

# 2. Open the PR (description: PULL_REQUEST.md)
#    base: main   compare: sprint1-my-library

# 3. Wait for CI: secret-scan, quality, build-android (release AAB),
#    build-web, build-ios. All five must be green.

# 4. Merge on GitHub. Prefer "Create a merge commit" over squash:
#    22 commits carry ~15 sprints of decision history that the ADRs
#    and reports reference by name. Squashing discards it.
```

**Do not delete `sprint1-my-library` after merging** until GitHub Pages
has been confirmed live (post-merge item 3). It is the only other copy
of the site files.

---

## Post-merge

| # | Action | Verification | Owner |
|---|---|---|---|
| 1 | Confirm `main` moved | `git log --oneline -1 origin/main` shows the site commit | anyone |
| 2 | Confirm Pages source | GitHub → Settings → Pages reads `main` / `/ (root)` | publisher |
| 3 | Confirm the site is live | `curl -sI https://duso201189-nxp.github.io/quran-companion/` → `200` | publisher |
| 4 | Confirm the legal URLs | `curl -sI …/privacy.html` and `…/terms.html` → `200` | publisher |
| 5 | Confirm Pages published **only** the site | `curl -sI …/assets/database/quran.sqlite` → **404** | publisher |
| 6 | Confirm 404 page works | `curl -s …/nope \| grep -c "Page not found"` → `1` | publisher |
| 7 | Confirm CI produced a release AAB | Actions → latest `main` run → artifact `app-release-aab` | anyone |
| 8 | Confirm `mapping.txt` archived | Actions → artifact `r8-mapping` present | anyone |
| 9 | Update `docs/release/FINAL_RELEASE_CHECKLIST.md` B7/B8 to ✅ | file edited | anyone |
| 10 | Tag the internal RC | `git tag -a v0.9.0-rc1 -m "Internal release candidate 1"` | publisher |

**Item 5 is not optional.** If the content database is reachable over
HTTP, `_config.yml` did not take effect, and the Qur'anic text plus both
tafsir corpora — one of which is © Maktaba Dar-us-Salam and awaiting
permission — are being published as a downloadable file. If that URL
returns anything other than 404, disable Pages immediately and
investigate before doing anything else.

---

## Rollback

The merge is a fast-forward, so rolling back means moving `main` back to
its previous commit.

| Situation | Action |
|---|---|
| **Before the PR is merged** | Close the PR. Nothing on `main` changed. |
| **After merge, nothing else pushed to `main`** | `git push origin --force-with-lease origin/main~1:main` — but only if branch protection allows it and no one has pulled. Prefer the revert below. |
| **After merge, anything else pushed** | `git revert -m 1 <merge-sha>` and push a new commit. Never rewrite shared history. |
| **Only the website is wrong** | Revert just those files on a fix branch; the app is unaffected — the site and the Flutter app share no code. |
| **Pages is exposing files it should not** | GitHub → Settings → Pages → **disable**, then fix `_config.yml`, then re-enable. Disabling takes effect within a minute; that is faster than any revert. |

### Rollback prerequisites, in place today

- `main` is at `564f2b1d5433e1c47169fbcac1e1700175de6fb3` before the merge — **record this SHA in the PR**
  so the rollback target is unambiguous.
- The merge adds no schema change, no data migration and no irreversible
  action.
- `pubspec.yaml` version is unchanged (`0.8.1+7`), so nothing about the
  merge affects an already-published artifact — there is none.

### What cannot be rolled back

Nothing in this merge. No release is published, no store listing exists,
no `versionCode` is consumed, and Play App Signing has not been enabled.
Every irreversible action in this project is still ahead of us, not
behind.
