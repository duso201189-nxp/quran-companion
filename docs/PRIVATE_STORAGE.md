# Private artifact storage — provisioning runbook

Phase C1 of [`IMPLEMENTATION_PROGRAM.md`](../IMPLEMENTATION_PROGRAM.md).
Implements the storage half of
[`DR-2026-0009`](adr/DR-2026-0009-data-supply-chain.md) and holds the
artifacts defined by
[`DR-2026-0012`](adr/DR-2026-0012-artifact-registry.md).

> **Status: not provisioned.** The bucket does not exist yet. This
> document is everything C1 requires *except* the account actions, which
> need credentials this engineer does not have and must not create. See
> §1.

---

## 1. What is and is not done

C1 divides at the account boundary.

| Part | Who | State |
|---|---|---|
| Provider selection and justification | engineering | ✅ §2 |
| Bucket layout | engineering | ✅ §4 |
| Credential strategy · access model · threat model | engineering | ✅ §5–7 |
| Cost estimate · rollback · risk | engineering | ✅ §8–10 |
| Verification that no code depends on storage | engineering | ✅ §11 |
| **Creating the account, bucket and tokens** | **publisher** | ❌ §3 |

The remaining part cannot be executed here. This machine has no object
storage CLI (`aws`, `rclone`, `wrangler`, `b2`, `mc` — all absent), no
credential files (`~/.aws/*`, `rclone.conf`, `.s3cfg` — all absent) and
no storage environment variables. Creating a cloud account means
entering the publisher's identity and payment details and accepting
terms on their behalf, which is theirs to do.

§3 is a runbook: copy, run, done. Roughly thirty minutes.

---

## 2. Provider selected: Cloudflare R2

`DR-2026-0009` deliberately leaves the vendor open — *"private by
default with credentials in CI secrets; the vendor is a preference"*.
Within that, R2 is recommended.

### Why

| Criterion | R2 | AWS S3 | Backblaze B2 |
|---|---|---|---|
| **Egress cost** | **none** | billed per GB | billed above a free allowance |
| Storage cost at ~55 MB | free tier | pennies | pennies |
| S3-compatible API | yes | native | yes |
| Setup complexity | one bucket, one token | IAM roles, policies, OIDC trust | one bucket, one key |
| **GitHub OIDC** | ✗ static API tokens | **✓ short-lived, no stored secret** | ✗ |
| Operational surface | minimal | largest | minimal |

**Egress is the discriminator.** CI pulls the whole artifact set on
every `main` build. At ~55 MB per pull and a few hundred pulls a month
that is ~11 GB of egress — trivially cheap on S3 (~$1/month) but
*structurally free* on R2, and free removes a reason to start caching
aggressively and complicating the pipeline later.

### The honest trade-off against S3

`DR-2026-0009` C prefers **OIDC federation where the provider supports
it**, so that no long-lived credential exists to leak. **R2 does not
support GitHub OIDC**; it uses scoped API tokens. Choosing R2 therefore
accepts a static secret in exchange for operational simplicity and free
egress.

That is defensible at this scale — one maintainer, one repository, a
read-only token scoped to one prefix, rotated annually — and
`DR-2026-0009` C explicitly permits "otherwise a scoped read-only
token". It would stop being defensible if a second person gained
access, or if the storage held anything more sensitive than licensed
text the app already ships.

**Migrate to S3 + OIDC when** a second person needs credentials, or the
static token is implicated in any incident. That trigger is recorded
here so the decision is revisited on evidence rather than never.

---

## 3. Provisioning runbook — publisher actions

Approximately 30 minutes. Nothing here touches the repository.

### 3.1 Account and bucket

1. Sign in to Cloudflare (or create an account) → **R2**.
2. Create bucket: **`quran-companion-data`**
   - Location: **Automatic**
   - **Public access: OFF.** This is the entire point; verify it twice.
3. Confirm the bucket lists as *Private*.

### 3.2 Tokens — create two, never one

| Token | Permission | Scope | Lives |
|---|---|---|---|
| `qc-publisher` | **Object Read & Write** | bucket `quran-companion-data` | publisher's machine, in a password manager |
| `qc-ci-read` | **Object Read only** | bucket `quran-companion-data` | GitHub environment secret |

R2 → **Manage API Tokens** → *Create API Token* for each. Record for
both: Access Key ID, Secret Access Key, and the S3 endpoint
`https://<ACCOUNT_ID>.r2.cloudflarestorage.com`.

**Never create a single read-write token for CI.** A leaked read token
exposes content the app already ships; a leaked write token lets an
attacker replace the Qur'anic text that ships to users.

### 3.3 GitHub secrets — C2, not now

C1 stops here. Storing secrets in GitHub and adding a fetch step is
phase C2. Keep the tokens in a password manager until then.

### 3.4 Verification (publisher runs once)

```bash
# any S3-compatible client; rclone shown
rclone config create r2 s3 provider=Cloudflare \
  access_key_id=<ID> secret_access_key=<SECRET> \
  endpoint=https://<ACCOUNT_ID>.r2.cloudflarestorage.com

echo "provisioned $(date -u +%FT%TZ)" > .c1-probe.txt
rclone copy .c1-probe.txt r2:quran-companion-data/_probe/   # write
rclone cat r2:quran-companion-data/_probe/.c1-probe.txt     # read
rclone delete r2:quran-companion-data/_probe/               # clean up
rm .c1-probe.txt
```

Then confirm the bucket is genuinely private — this must **fail**:

```bash
curl -sI https://<ACCOUNT_ID>.r2.cloudflarestorage.com/quran-companion-data/_probe/.c1-probe.txt
# expect 401/403. A 200 means public access is on — stop and fix it.
```

Record the outcome in this file's §12 log.

---

## 4. Bucket layout

Two top-level prefixes, mirroring `DR-2026-0009` (inputs) and
`DR-2026-0012` (outputs).

```
quran-companion-data/
├── datasets/                       ← INPUTS: what upstreams gave us
│   └── <dataset-id>/<version>/
│         payload.json              (or .txt, .zip — as acquired)
│         manifest.json             identity · provenance · licence ref · sha256
│
├── artifacts/                      ← OUTPUTS: what a build produced
│   └── quran.sqlite/<artifact-version>/
│         quran.sqlite
│         manifest.json             inputs[] · builder rev · schema · sha256
│         verification.json         the report from DR-2026-0012 §B
│
└── _probe/                         ← connectivity checks only, disposable
```

Rules:

- **Version directories are immutable.** A correction creates a new
  version (`DR-2026-0011`). Never overwrite a published path.
- **Every object has a sibling `manifest.json`.** An object without one
  is unidentifiable and must not be consumed.
- **Nothing is written to a bucket root.** Prefixes are how the CI
  token is scoped.
- `datasets/` and `artifacts/` are separate because they have different
  writers and different lifetimes: datasets arrive by acquisition,
  artifacts by build.

Expected initial contents at C2 (**not migrated in C1**): five dataset
payloads totalling ~17 MB, plus one 32.7 MB artifact. About 55 MB.

---

## 5. Credential strategy

| | Publisher token | CI token |
|---|---|---|
| Permission | read + write | **read only** |
| Scope | whole bucket | bucket, read |
| Storage | password manager | GitHub **environment** secret (C2) |
| Rotation | annually, with `PROJ-P-005`'s review cycle | annually |
| Revocation | Cloudflare → Manage API Tokens → Revoke, effective immediately | same |

Rules carried from `DR-2026-0009` D:

- **Never in the repository.** `gitleaks` runs on every push and scans
  full history; it stays.
- **Never in the same class as release secrets.** The upload keystore
  stays on the publisher's machine and never enters CI. A leaked
  storage token exposes licensed text; a leaked signing key ends the
  app's ability to update, permanently. Different blast radii, separate
  handling.
- **Environment-protected in CI** (C2) so a fork's pull request cannot
  reach the secret and builds the public profile instead.

---

## 6. Access model

```
   publisher machine ──read+write──►  quran-companion-data
                                            │
   GitHub Actions ─────read-only────────────┘
     (main / v* tags only, environment-protected)

   fork PR ─────────────── no access ──────► public profile build
   public internet ─────── no access ──────► 401/403
```

| Actor | datasets/ | artifacts/ | How enforced |
|---|---|---|---|
| Publisher | read+write | read+write | `qc-publisher` token |
| CI, `main`/tags | read | read | `qc-ci-read`, environment gate |
| CI, fork PR | none | none | environment gate; falls back to the public profile |
| Anonymous | none | none | bucket private |

This realises trust boundary **T3** from `DATA_SUPPLY_CHAIN.md`:
registries → pipeline, read-only, scoped, short-lived-ish.

---

## 7. Threat model

Defends against **mistakes**, not a determined adversary — the same
posture `DATA_SUPPLY_CHAIN.md` §5 states. It assumes the publisher is
honest and the CI provider is not hostile.

| Threat | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Bucket accidentally made public | Low | **High** — recreates the exact exposure this whole programme exists to end | §3.4 asserts a 401/403; re-check after any settings change |
| CI read token leaked | Low | Medium — exposes content the app already ships | Read-only, single bucket, revocable in seconds, rotated annually |
| Publisher write token leaked | Very low | **High** — attacker could replace Qur'anic text | Never in CI; password manager only; checksum pinning (`DR-2026-0012`) means a swapped artifact fails the consuming build |
| Fork PR exfiltrates the secret | Low | Medium | Environment protection restricts secrets to `main` and `v*` |
| Provider outage during a build | Low | Low | Content is baked into shipped apps; only *rebuilds* are blocked, and rebuilds are rare and deferrable |
| Provider terminates the account | Very low | **High** | Keep an offline copy of every payload — the bucket is a convenience, not the only archive |
| Silent object corruption | Very low | High | sha256 in every manifest, verified on consumption |

**Not defended against:** a compromised publisher machine, a malicious
CI provider, or a state-level adversary. Out of scope and openly so.

---

## 8. Estimated monthly cost

| Item | Volume | R2 |
|---|---|---|
| Storage | ~55 MB now; ~150 MB with retained versions after 2 years | free tier |
| Class A ops (writes/lists) | tens per month | free tier |
| Class B ops (reads) | hundreds per month | free tier |
| **Egress** | ~11 GB/month worst case | **$0 — R2 charges none** |
| **Total** | | **$0.00/month expected** |

**Verify current terms at signup.** R2's published free tier has been
10 GB storage, 1M Class A and 10M Class B operations per month, with no
egress charge — but pricing changes and this document is not the
authority on it. The shape of the conclusion is robust regardless: this
workload is three orders of magnitude below any paid threshold, and the
egress-free property is R2's structural differentiator rather than a
promotional tier.

For comparison, the same workload on S3 would be roughly **$1–2/month**,
almost entirely egress. Neither figure is a decision factor; §2's
reasoning rests on operational simplicity and the absence of an egress
meter, not on saving a dollar.

---

## 9. Rollback procedure

C1 changes nothing in the repository, so rollback is entirely
account-side.

| Step | Action | Effect |
|---|---|---|
| 1 | Revoke `qc-ci-read` and `qc-publisher` | access ends immediately |
| 2 | Delete `_probe/` | removes the only objects C1 creates |
| 3 | Delete the bucket | removes the resource |
| 4 | *(optional)* close the Cloudflare account | full reversal |

**Nothing depends on this storage yet** (§11), so rollback at C1 breaks
nothing. That property disappears at C2 (CI references the secret) and
becomes load-bearing at D1 (the build requires the fetch) — which is
exactly why C1 is a separate phase.

If this documentation is committed and later unwanted:
`git revert <sha>` — it is one Markdown file.

---

## 10. Risk assessment

| Risk | Level | Note |
|---|---|---|
| Breaks the build | **None** | no code, no workflow, no `pubspec.yaml` change |
| Bucket left public by mistake | Medium | §3.4's negative test is mandatory, not optional |
| Provisioned then forgotten | Medium | An unused bucket costs nothing but rots; C2 should follow within a sprint |
| Wrong provider chosen | Low | S3-compatible API means migration is a re-upload and one endpoint string |
| Static CI token instead of OIDC | Low–Medium | Accepted trade-off with a stated migration trigger (§2) |
| Cost surprise | Very low | Three orders of magnitude below any paid threshold |

---

## 11. Verification: nothing depends on storage yet

Measured on this commit:

| Check | Command | Result |
|---|---|---|
| Network hosts in `lib/` | `grep -rhoE "https?://…" lib/` | **only `https://everyayah.com`** |
| Storage SDK/CLI references in `lib`, `tool`, `.github` | `grep -rlniE "amazonaws\|cloudflarestorage\|backblazeb2\|s3\.\|boto3\|minio\|presigned\|AWS_ACCESS\|R2_ACCOUNT"` | **none** |
| Storage packages | `pubspec.yaml` | **none** |
| CI secrets in use | `grep -oE 'secrets\.[A-Z_]+' .github/workflows/ci.yml` | **only `secrets.GITHUB_TOKEN`** |
| Local storage tooling | `aws rclone s3cmd b2 wrangler mc` | **all absent** |
| Local credentials | `~/.aws/*`, `rclone.conf`, `.s3cfg` | **all absent** |

An earlier grep for `bucket` matched `HistoryBucket` in the analytics
feature — time buckets, not object storage. Verified as a false
positive and excluded.

**The repository is provably independent of external storage at C1.**

---

## 12. Provisioning log

Fill in when §3 is executed. Empty until then — an unfilled table is an
honest record that the bucket does not exist.

| Field | Value |
|---|---|
| Provisioned on | — |
| Cloudflare account id | — *(not a secret; needed for the endpoint)* |
| Bucket name | `quran-companion-data` *(planned)* |
| Public access verified OFF | — |
| `qc-publisher` created | — |
| `qc-ci-read` created | — |
| Read/write probe passed | — |
| Anonymous access returns 401/403 | — |
| Next rotation due | — |

---

## 13. Remaining work before C2

| # | Item | Owner | Blocking C2? |
|---|---|---|---|
| 1 | Execute §3 — account, bucket, two tokens | publisher | **yes** |
| 2 | Verify the bucket is private (§3.4 negative test) | publisher | **yes** |
| 3 | Complete the §12 log | publisher | yes — C2 needs the endpoint |
| 4 | Store both tokens in a password manager | publisher | yes |
| 5 | Decide the GitHub environment name for C2's secret | publisher | no |

C2 adds `qc-ci-read` as an environment secret and an **additive** CI
fetch step, while the database remains committed — so the fetch is
provably redundant before D1 makes it required. Nothing about C2 is
started here.
