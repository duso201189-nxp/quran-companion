# C1 provisioning checklist — Cloudflare R2

**You perform every step.** This document is instructions, not actions.
No account was created, no bucket exists, no credential was issued or
handled in producing it.

Companion to [`docs/PRIVATE_STORAGE.md`](docs/PRIVATE_STORAGE.md), which
carries the reasoning (why R2, cost, threat model, rollback). This file
is the doing.

**Time:** ~30 minutes. **Cost:** $0 expected.
**Environment:** Windows 10, PowerShell. `curl.exe` and `winget` are
already present on your machine — verified.

---

## Before you start

- [ ] You have an email address for the account
- [ ] You have a **password manager** open — two secrets are produced
      and each is shown exactly once
- [ ] You accept that steps 1–7 are yours: I cannot create accounts,
      accept terms, or enter credentials

Already verified, no action needed:

- [x] No project code depends on this storage *(checked at C1 — only
      network host in `lib/` is `everyayah.com`, zero storage SDKs,
      zero storage packages, only CI secret in use is
      `secrets.GITHUB_TOKEN`)*
- [x] Provider selected and justified *(`docs/PRIVATE_STORAGE.md` §2)*
- [x] Bucket layout designed *(§4)*

---

## 1 · Create the Cloudflare account

- [ ] Go to **https://dash.cloudflare.com/sign-up**
- [ ] Register with your email; confirm the verification email
- [ ] Enable **two-factor authentication** immediately
      *(My Profile → Authentication). This account will hold write
      access to the Qur'anic text that ships to users. 2FA is not
      optional here.*

**Expect a payment method prompt.** Cloudflare generally requires a card
on file to activate R2, even though this workload sits inside the free
tier. Adding it is your call — if you'd rather not, stop here and tell
me; the S3-compatible layout means Backblaze B2 or another provider
drops into the same runbook with only the endpoint changing.

- [ ] Account created, 2FA on
- [ ] Record your **Account ID** — visible in the dashboard sidebar and
      on the R2 overview page. *Not a secret; it forms the endpoint URL.*

---

## 2 · Create the R2 bucket

- [ ] Dashboard → **R2 Object Storage** in the left sidebar
- [ ] Accept the R2 terms if prompted (your decision, not mine)
- [ ] **Create bucket**

| Field | Value |
|---|---|
| Name | `quran-companion-data` |
| Location | **Automatic** |
| Storage class | **Standard** |

- [ ] Bucket created

### 3 · About the bucket name

`quran-companion-data` — lowercase, hyphens, no dots.

Unlike S3, **R2 bucket names are unique within your account only**, not
globally. You will not have to fight for the name, and you do not need
a random suffix.

The name is not secret and will appear in CI configuration, so keep it
boring and descriptive. Avoid dots: they break TLS hostname matching if
you ever attach a custom domain.

- [ ] Name confirmed as `quran-companion-data`

### Public access — read this carefully

**R2 buckets are private by default. There is no "make private" toggle
to set, because there is nothing to turn off yet.**

*(Correction to `docs/PRIVATE_STORAGE.md` §3.1, which says "Public
access: OFF" as if it were a creation-time field. It is not. The real
risk is the two settings below being switched **on** later.)*

Exposure happens only if someone enables one of these. Both live under
the bucket's **Settings → Public access**:

| Setting | Must be |
|---|---|
| **R2.dev subdomain** | **Disabled** |
| **Custom domain** | **None connected** |

- [ ] Settings → Public access checked — r2.dev subdomain **disabled**
- [ ] No custom domain connected

Step 6 proves this empirically rather than trusting the screen.

---

## 4 · Create two API tokens

**R2 → Manage R2 API Tokens → Create API Token.** Do this twice.

Never create one token for both jobs. A leaked read token exposes text
the app already ships. A leaked write token lets someone replace the
Qur'anic text that reaches users. Those are not the same incident.

### Token A — `qc-ci-read` (create this one first)

| Field | Value |
|---|---|
| Token name | `qc-ci-read` |
| Permission | **Object Read only** |
| Specify bucket(s) | **Apply to specific buckets** → `quran-companion-data` |
| TTL / expiry | 1 year if offered |
| Client IP filtering | leave empty *(GitHub runner IPs are not stable)* |

- [ ] Created
- [ ] Access Key ID → password manager
- [ ] Secret Access Key → password manager **(shown once — if you
      navigate away it is gone and you create a new token)**

### Token B — `qc-publisher`

| Field | Value |
|---|---|
| Token name | `qc-publisher` |
| Permission | **Object Read & Write** |
| Specify bucket(s) | **Apply to specific buckets** → `quran-companion-data` |
| TTL / expiry | 1 year if offered |

- [ ] Created
- [ ] Access Key ID → password manager
- [ ] Secret Access Key → password manager

Also record once, from the token page: the **S3 endpoint**,
`https://<ACCOUNT_ID>.r2.cloudflarestorage.com`.

- [ ] Endpoint recorded

---

## 5 · Least-privilege — why those exact settings

| Choice | Rejected alternative | Reason |
|---|---|---|
| **Object** Read only / Read & Write | **Admin** Read & Write | Admin can create and **delete buckets**, and reaches every bucket in the account. Neither token needs that. Object-level cannot destroy the container. |
| Scoped to one bucket | Apply to all buckets | An all-buckets token grows silently as you add buckets. Scoping is set once and stays correct. |
| CI gets **read only** | one shared read/write token | This is the single highest-value control here. CI never needs to write; giving it write turns a leaked secret from an exposure into a content-integrity incident. |
| Publisher token stays off CI | store it in GitHub too | Nothing in CI writes to storage — not at C2, not at D1. If a future phase needs a write, that phase justifies its own token. |
| Expiry set | never expires | Forces a yearly decision. A token nobody reviews is a token nobody revokes. |

Two separate blast radii, kept separate:

```
 qc-publisher   read+write  →  your machine only, password manager
 qc-ci-read     read only   →  GitHub environment secret (at C2)
```

And the boundary that matters most, from `docs/PRIVATE_STORAGE.md` §5:
**storage tokens and the Android release keystore are never handled as
the same class of secret.** A leaked storage token exposes licensed
text. A leaked signing key permanently ends this app's ability to ship
updates. The keystore never enters CI.

- [ ] Both tokens are Object-level, not Admin
- [ ] Both scoped to `quran-companion-data` only
- [ ] `qc-ci-read` is genuinely read-only
- [ ] Keystore untouched by any of this

---

## 6 · Verify

Install an S3 client — you have neither:

```powershell
winget install Rclone.Rclone
```

Open a **new** PowerShell window afterwards so `PATH` refreshes.

### 6a · Anonymous access must be DENIED

Run this **before** anything else. It needs no credentials, and it is
the test that matters — it proves the exposure this whole programme
exists to prevent is not present.

```powershell
curl.exe -sI https://<ACCOUNT_ID>.r2.cloudflarestorage.com/quran-companion-data/
```

| You see | Meaning |
|---|---|
| **401** or **403** | ✅ correct — private, as intended |
| **200** | 🛑 **STOP.** Public access is on. Return to §3, disable the r2.dev subdomain, re-run. Do not proceed. |

> Use `curl.exe`, not `curl`. In PowerShell, bare `curl` is an alias for
> `Invoke-WebRequest`, which does not take `-sI` and will throw a
> terminating error on a 403 — hiding the very result you want to see.

- [ ] Anonymous request returned **401 or 403**

### 6b · Token access must WORK

Configure rclone with the **publisher** token (it needs write to run a
full round-trip):

```powershell
rclone config create r2 s3 provider=Cloudflare region=auto endpoint=https://<ACCOUNT_ID>.r2.cloudflarestorage.com
```

Then supply the key and secret when prompted, or set them for the
session so they never land in your shell history file:

```powershell
$env:RCLONE_S3_ACCESS_KEY_ID = Read-Host "Access Key ID"
$env:RCLONE_S3_SECRET_ACCESS_KEY = Read-Host "Secret Access Key" -AsSecureString | ConvertFrom-SecureString -AsPlainText
```

Round-trip:

```powershell
"provisioned $(Get-Date -Format o)" | Out-File -Encoding utf8 .c1-probe.txt
rclone copy .c1-probe.txt r2:quran-companion-data/_probe/
rclone ls r2:quran-companion-data/_probe/
rclone cat r2:quran-companion-data/_probe/.c1-probe.txt
rclone delete r2:quran-companion-data/_probe/
Remove-Item .c1-probe.txt
```

- [ ] Write succeeded
- [ ] List showed the object
- [ ] Read returned the timestamp
- [ ] Delete succeeded, `_probe/` empty
- [ ] `.c1-probe.txt` removed from your working directory

> Run this from a scratch folder, **not** from inside the repository.
> `.c1-probe.txt` matches no `.gitignore` rule and would show up as an
> untracked file.

### 6c · Read-only token must be genuinely read-only

The one people skip, and the one that catches a mis-set permission
while it is still harmless:

```powershell
rclone config create r2ro s3 provider=Cloudflare region=auto endpoint=https://<ACCOUNT_ID>.r2.cloudflarestorage.com
# supply the qc-ci-read key and secret

rclone ls r2ro:quran-companion-data/          # expect: succeeds (empty is fine)
rclone copy .c1-probe.txt r2ro:quran-companion-data/_probe/   # expect: FAILS
```

| Result | Meaning |
|---|---|
| List works, copy fails with `AccessDenied` | ✅ correct |
| Copy **succeeds** | 🛑 the token has write permission. Revoke it, recreate as **Object Read only**. |

- [ ] `qc-ci-read` can list
- [ ] `qc-ci-read` **cannot** write

Clean up the local rclone config when done:

```powershell
rclone config delete r2
rclone config delete r2ro
```

- [ ] Local rclone configs deleted

---

## 7 · GitHub Secrets — names only

**These are set at C2, not now.** Listed so you know what the tokens are
for and can label them correctly in your password manager.

**No secret value appears in this document, and none should ever be
pasted into a file, a commit, an issue, or a chat message — including to
me.** You enter them directly into GitHub's UI.

| Secret name | Holds | From |
|---|---|---|
| `R2_READ_ACCESS_KEY_ID` | Access Key ID | **`qc-ci-read`** |
| `R2_READ_SECRET_ACCESS_KEY` | Secret Access Key | **`qc-ci-read`** |
| `R2_S3_ENDPOINT` | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` | account |

Repository **variables** (not secrets — these are not confidential):

| Variable name | Value |
|---|---|
| `R2_BUCKET` | `quran-companion-data` |

Three deliberate choices:

- **`_READ_` is in the name.** The generic `R2_ACCESS_KEY_ID` invites
  exactly one mistake — pasting the publisher token into CI — and the
  name is the only place that mistake is visible afterward.
- **`qc-publisher` gets no GitHub secret at all.** It has no row in the
  table above because it must never have one.
- **Endpoint as a secret, not a variable.** It embeds your Account ID.
  Not confidential, but there is no benefit to publishing it in CI logs.

At C2 these go into a GitHub **Environment** (not repository-wide
secrets), so a fork's pull request cannot reach them.

- [ ] Understood: nothing is entered into GitHub during C1
- [ ] Password manager entries labelled `qc-ci-read` and `qc-publisher`
      so they are never confused later

---

## 8 · Provisioning log

Fill this in as you go, then paste it back to me. It replaces §12 of
`docs/PRIVATE_STORAGE.md`.

| Field | Value |
|---|---|
| Provisioned on (UTC) | |
| Cloudflare Account ID | *(not secret — needed for the endpoint)* |
| Bucket name | |
| 2FA enabled on the account | ☐ |
| r2.dev subdomain disabled | ☐ |
| No custom domain connected | ☐ |
| `qc-ci-read` created — Object Read only, single bucket | ☐ |
| `qc-publisher` created — Object Read & Write, single bucket | ☐ |
| Token expiry set | |
| §6a anonymous access → HTTP status observed | |
| §6b round-trip write/list/read/delete passed | ☐ |
| §6c read-only token **rejected** a write | ☐ |
| `_probe/` emptied | ☐ |
| Local rclone configs deleted | ☐ |
| Both secrets stored in password manager | ☐ |
| Next rotation due | |

**Do not include key IDs or secret values in what you send back.**
The Account ID is fine.

---

## Final gate

C2 may begin when all four are true:

- [ ] §6a returned 401 or 403
- [ ] §6b round-trip passed
- [ ] §6c proved the CI token cannot write
- [ ] §8 log complete

If any step failed, stop and report it rather than working around it. A
bucket that is reachable anonymously, or a "read-only" token that
writes, is worse than no bucket — it looks provisioned while being
exactly the exposure this programme was built to end.

## If you want to undo all of this

Nothing in the repository depends on it, so rollback is clean:

1. Revoke both tokens (R2 → Manage R2 API Tokens → Revoke — immediate)
2. Delete `_probe/` if anything remains
3. Delete the bucket
4. Optionally close the Cloudflare account

That stays true through C1 only. From C2 the CI workflow references the
secret, and at D1 the build requires the fetch — which is precisely why
C1 is its own phase.
