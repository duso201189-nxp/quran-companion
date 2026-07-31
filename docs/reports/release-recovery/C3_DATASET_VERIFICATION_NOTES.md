# C3 — Dataset verification workflow: implementation notes

Phase: read-only verification only. No publishing implemented, per
scope. Sequenced after `C1` (provisioning) and `C2` (verification /
architecture review); this is the first phase in the R2 line that adds
actual workflow code.

## What was built

One new file: [`.github/workflows/dataset-verification.yml`](.github/workflows/dataset-verification.yml).
`.github/workflows/ci.yml` — the release workflow — was not opened for
editing and is confirmed untouched (`git status` shows zero diff on it).

## Design decisions, and why

**A separate workflow file, not a job added to `ci.yml`.** Keeps this
additive and independently reversible — deleting one file removes the
entire capability, with no risk of disturbing the release pipeline.
Matches the discipline `B1`/`B2`/`C1` already established for this
project.

**Trigger: `workflow_dispatch` + daily `schedule`, not `push` or
`pull_request`.** Bucket contents don't change on every commit, so
there's no benefit to referencing the read credential on every push to
every same-repo branch — `ci.yml`'s existing triggers already show how
wide `pull_request:` reaches. `workflow_dispatch` covers on-demand
checks (e.g., right after rotating a token); `schedule` catches
unattended drift — a revoked or expired credential is caught within a
day rather than only when someone happens to run this by hand.

**`aws` CLI against R2's S3-compatible API, no third-party Action.**
`ubuntu-latest` ships AWS CLI v2, `jq`, and `python3` pre-installed.
Using them directly means zero additional Actions are pulled from the
marketplace for a workflow that exists specifically to reduce risk
around a credential — adding an unpinned or lightly-audited third-party
Action here would work against the goal.

**Credential mapping.** `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
(names the AWS CLI requires) are populated only from
`secrets.R2_READ_ACCESS_KEY_ID` / `secrets.R2_READ_SECRET_ACCESS_KEY`.
`R2_BUCKET` and `R2_S3_ENDPOINT` are read as **repository variables**
(`vars.*`), matching how they were described when their verification
was requested. **If either was actually provisioned as a secret
instead** (as one earlier document — `C1_PROVISIONING_CHECKLIST.md`
§7 — originally suggested for the endpoint), change `vars.R2_S3_ENDPOINT`
to `secrets.R2_S3_ENDPOINT` on line 51; everything else is unaffected.
Flagged here rather than guessed at, since this session has no GitHub
API access to check which one is actually true.

## Requirement 5 — confirm no write operation is attempted

Implemented two ways, not just asserted:

1. **Structural guarantee.** No step in the workflow calls
   `put-object`, `delete-object(s)`, `s3 cp ... s3://`, `s3 sync`, or
   `s3 mv`. Every AWS CLI call in this file is `head-bucket`,
   `list-objects-v2`, or `get-object` — read operations only.
2. **A self-check step that enforces it, proven load-bearing.** The
   first step scans the workflow's own committed text for any of those
   write verbs, and separately for any `secrets.`/`vars.` reference
   containing `PUBLISH`, failing the run before anything else executes
   if either is found.

   This was proven, not assumed, the same way `B1`/`B2` proved their
   gates by deliberately breaking them:

   | Test | Result |
   |---|---|
   | Scan the real file as committed | 0 matches on both patterns — clean |
   | Inject `aws s3 cp foo.txt s3://quran-companion-data/foo.txt` into a scratch copy | **caught** |
   | Inject `${{ secrets.R2_PUBLISH_ACCESS_KEY_ID }}` into a scratch copy | **caught** |

   The first version of this check had a real bug, found by this same
   dogfooding: its own pattern-definition line (`WRITE_PATTERN='put-object|...'`)
   matched its own deny-list, and a bare case-insensitive search for
   `PUBLISH` matched the English word "Publisher" in this file's own
   comments. Both would have made the workflow permanently red — the
   exact failure mode `DR-2026-0013` warns about (*"false positives
   train people to bypass CI"*). Fixed by (a) excluding lines tagged
   `pattern-definition` from the text being scanned, and (b) requiring
   the `PUBLISH` check to match an actual `secrets.`/`vars.` reference,
   not the bare word. Re-tested per the table above.

## What "expected dataset presence" and "immutable version metadata"
## actually check right now, and why

Per this session's own prior work, nothing has been published through
the pipeline's Production stage yet — the Publisher credential is
"stored but intentionally unused." A workflow that hard-fails looking
for specific named artifacts that don't exist yet would be permanently
red from the day it's merged, which is worse than not having the check
at all.

So the workflow implements two things instead of one fabricated list:

- **A structural check that's meaningful today regardless of contents**:
  every object under `datasets/` or `artifacts/` must have a sibling
  `manifest.json`, per the layout `docs/PRIVATE_STORAGE.md` §4 already
  documents. This runs whether the bucket holds zero objects or many,
  and would catch a real mistake (an object published without its
  manifest) the moment it happened.
- **A configurable presence list (`REQUIRED_OBJECTS`), empty today.**
  The comment directly above it in the workflow explains why it's
  empty and how to populate it once the pipeline's Production stage
  (`DATASET_RELEASE_PIPELINE.md` §5) actually publishes something. This
  keeps the requirement implemented and exercised — not dead code —
  without asserting a fact that isn't true yet.

"Immutable version metadata (if applicable)" is handled the same way:
every `manifest.json` found is downloaded and checked for a `sha256`
field. If none exist yet, the step reports "no manifests found... not
applicable at this point in the pipeline" and passes — an honest
not-yet-applicable state, not a fabricated pass.

## Rollback

Fully additive; nothing else in the repository references this file.

1. Delete `.github/workflows/dataset-verification.yml` — or
   `git revert` the commit that adds it.
2. No secret, variable, or Environment needs to change. This workflow
   created none — `R2_READ_ACCESS_KEY_ID`, `R2_READ_SECRET_ACCESS_KEY`,
   `R2_BUCKET`, `R2_S3_ENDPOINT` all predate it (per `C1`/this sprint's
   context) and are unaffected by removing it.
3. If a scheduled run is currently mid-flight, it completes or times
   out (`timeout-minutes: 10`) harmlessly — it only ever reads.

**Nothing in `ci.yml` or any release path needs any change to roll this
back**, because nothing in `ci.yml` was touched to add it.

## What this does not do

- Does not publish, upload, or modify bucket contents — verified above,
  not merely stated.
- Does not implement `DR-2026-0014` Option A, B, or C. No
  `workflow_dispatch` input here names an artifact version to publish;
  this workflow's `workflow_dispatch` trigger takes no inputs at all and
  only ever reads.
- Does not modify `DATASET_RELEASE_PIPELINE.md` or any ADR — this
  implements a piece of infrastructure the design document already
  anticipated (verification-adjacent tooling with only the read
  credential in scope), it does not redesign anything in it.
