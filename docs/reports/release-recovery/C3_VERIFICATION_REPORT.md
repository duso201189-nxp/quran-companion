# C3 verification report

Scope: `.github/workflows/dataset-verification.yml` only.

**This report covers what could be verified from this session — static
checks against the committed file. It does not cover a live GitHub
Actions run, for the same reason earlier reports in this thread
couldn't: this session has no `gh` CLI, no GitHub API access, and no R2
credentials. That gap is named explicitly in "Not verified" below
rather than glossed over.**

## Verified in this session

| # | Check | Method | Result |
|---|---|---|---|
| 1 | YAML is syntactically valid | `python3 -c "yaml.safe_load(...)"` | ✅ parses, 9 steps |
| 2 | Only the four approved names are referenced | regex scan for `secrets\.` / `vars\.` across the whole file | ✅ exactly `R2_READ_ACCESS_KEY_ID`, `R2_READ_SECRET_ACCESS_KEY`, `vars.R2_BUCKET`, `vars.R2_S3_ENDPOINT` — nothing else |
| 3 | No write-capable AWS CLI call exists in the file | manual read + the workflow's own self-check pattern, run locally against the committed text | ✅ 0 matches — every call is `head-bucket`, `list-objects-v2`, or `get-object` |
| 4 | No reference to any publisher-named secret/variable | same self-check pattern, run locally | ✅ 0 matches |
| 5 | The self-check is load-bearing, not decorative | injected a real `aws s3 cp ... s3://...` and a real `secrets.R2_PUBLISH_ACCESS_KEY_ID` reference into scratch copies, re-ran the check | ✅ **both caught** |
| 6 | The self-check has no false positives on the real file | ran the check's exact logic against the committed file as-is | ✅ clean — found and fixed two false-positive bugs first (see `C3_DATASET_VERIFICATION_NOTES.md`) |
| 7 | `ci.yml` (the release workflow) is untouched | `git status --porcelain .github/workflows/ci.yml` | ✅ empty diff |
| 8 | Change surface is exactly one new file | `git status --porcelain .github/` | ✅ only `dataset-verification.yml`, untracked |
| 9 | No ADR, dataset-pipeline doc, or other code was modified | `git status --porcelain` (full repo) | ✅ unchanged from before this task — this file plus two new root docs, nothing else |

## Not verified — needs an actual GitHub Actions run

| Item | Why it can't be confirmed from here |
|---|---|
| Bucket connectivity succeeds against the real endpoint | requires network access to the real R2 endpoint with real credentials — neither available in this session |
| The read credential actually authenticates | same |
| The four secrets/variables are actually set in GitHub, under the names this workflow expects | no `gh` CLI / API access this session (same limitation as `C2_VERIFICATION_REPORT.md`) |
| The classification of a real 403 vs 404 vs network error produces the intended distinct messages | the logic is written to distinguish them (see `C3_DATASET_VERIFICATION_NOTES.md`), but distinguishing real HTTP responses can only be confirmed by triggering real failure conditions against the real bucket |
| The manifest-integrity step behaves correctly once a manifest actually exists | the bucket is currently empty of datasets/artifacts per this session's own prior findings — this step's "no manifests found" branch is what will run today; its populated-branch logic is untested against a real object |

## Recommended first live run

1. Trigger via `workflow_dispatch` manually (not the schedule) so the
   result is available immediately.
2. Expect, on the current empty bucket: connectivity ✅, layout check
   ✅ (vacuously, nothing to violate), required-objects check ✅
   (placeholder, empty list), manifest-integrity ✅ ("no manifests
   found... not applicable").
3. If any step other than these fails, the failure message should name
   which of `R2_READ_ACCESS_KEY_ID` / `R2_READ_SECRET_ACCESS_KEY` /
   `R2_BUCKET` / `R2_S3_ENDPOINT` to check first — if it doesn't, that
   is itself a defect in this workflow worth reporting back.
4. Once a real dataset is published through the pipeline's Production
   stage, add its key to `REQUIRED_OBJECTS` in the workflow and confirm
   the presence check now genuinely exercises its populated branch —
   the same "prove it by giving it something to catch" step used for
   the self-check in this report's item 5.

## Result

**Static verification: passed, including proof the guardrails are
load-bearing. Live verification: outstanding, and honestly stated as
such rather than assumed.**
