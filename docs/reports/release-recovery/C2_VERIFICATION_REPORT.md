# C2 verification report

Role: Infrastructure Assistant · Date: 2026-07-26

**Result: NOT VERIFIED.** Most requested checks could not be executed
from this environment. This report says exactly which, and why, rather
than reporting success that didn't happen.

No code, workflow, or configuration was modified in producing this
report.

---

## 0 · Why most items couldn't run

This tool session has its own shell, separate from the PowerShell
session where R2 and rclone were configured. Probed just now:

| Tool | Present here? |
|---|---|
| `gh` (GitHub CLI) | ❌ absent |
| `rclone` | ❌ absent |
| `aws` / `s3cmd` | ❌ absent |
| R2/AWS credential env vars | ❌ none set |
| local `rclone.conf` | ❌ none found |

I have no GitHub API access and no R2 credentials in this session. I
also should not be handling `qc-publisher` (write) credentials directly
even if offered — that token's entire purpose, per
[`C1_PROVISIONING_CHECKLIST.md`](C1_PROVISIONING_CHECKLIST.md) §5, is to
never leave your machine or password manager. Items 1, 2, 5, 6, and 7
below need to be run where the credentials and tools actually live:
your PowerShell session, or CI itself.

---

## 1 · GitHub repository secrets

**Cannot verify.** No `gh` CLI, no API access from here.

Also worth stating plainly: even with `gh` authenticated, **GitHub
never returns a secret's value once set** — not to the CLI, not to the
API, not to a repository admin. `gh secret list` shows only names and
last-updated dates. So "verify the secret contains the right value" is
not something anyone can do after the fact by inspection — only the
workflow run that consumes it can prove the value works, by succeeding
or failing.

What you can run yourself:

```bash
gh secret list --repo duso201189-nxp/quran-companion
```

Expected names, per the plan: `R2_READ_ACCESS_KEY_ID`,
`R2_READ_SECRET_ACCESS_KEY`. See §7 below on the two additional names in
this sprint's request.

## 2 · Repository variables

**Cannot verify**, same reason — no API access from here.

```bash
gh variable list --repo duso201189-nxp/quran-companion
```

Expected: `R2_BUCKET`, `R2_S3_ENDPOINT` — variables, not secrets, so
their values are visible in that output.

## 3 · Workflow configuration matches the secret names

**Checked directly — this one I could run.**

```
grep -nE "R2_|r2\.cloudflarestorage|rclone|aws-actions" .github/workflows/ci.yml
→ no matches
```

`.github/workflows/ci.yml` currently contains **zero references to R2**,
to any of the four secret names, or to the two variables. This isn't a
mismatch — there's nothing yet to match against. The CI wiring that
consumes these credentials (the additive fetch step originally scoped
as C2 in `IMPLEMENTATION_PROGRAM.md`) has not been implemented in this
repository.

If secrets were added on GitHub, they are currently **unused** — no job
references them, so nothing can yet succeed or fail because of them.

## 4 · `PRIVATE_STORAGE.md` verification procedure

The procedure (§3.4 of `docs/PRIVATE_STORAGE.md`, restated with more
detail in `C1_PROVISIONING_CHECKLIST.md` §6) is written to run on the
machine holding the credentials — yours. I can't execute it from here
for the same reason as §1. If you already ran §6a–§6c and it passed,
that satisfies this item; if not, it's still outstanding.

## 5 · Real read verification against the bucket

**Cannot perform.** No credentials, no S3-capable client, in this
session.

## 6 · Round-trip upload/download/delete with publisher credentials

**Cannot perform**, same reason — and per §0, this specific credential
shouldn't be handed to me even if it could be. If you want this run
again, execute `C1_PROVISIONING_CHECKLIST.md` §6b yourself; it's the
exact same test.

## 7 · Read-only credential cannot write

**Cannot perform**, same reason as §5–6.

---

## Finding: two secret names weren't part of the documented plan

This sprint asks me to verify `R2_PUBLISH_ACCESS_KEY_ID` and
`R2_PUBLISH_SECRET_ACCESS_KEY` exist as GitHub secrets. Neither name
appears in `docs/PRIVATE_STORAGE.md` or `C1_PROVISIONING_CHECKLIST.md`.
What those documents specify is the opposite:

> *"`qc-publisher` gets no GitHub secret at all. It has no row in the
> table above because it must never have one."*
> — `C1_PROVISIONING_CHECKLIST.md` §7

> *"storage tokens... [are] never handled as the same class of secret"*
> as anything that can modify shipped content, and the write-capable
> token was scoped to stay off CI entirely — `docs/PRIVATE_STORAGE.md` §5

The reasoning was: CI has no task at C2 or D1 that requires writing to
the bucket, so giving it write capability only enlarges what a leaked
CI secret could do — from *exposing already-public text* to *replacing
the Qur'anic text that ships to users*.

If `R2_PUBLISH_ACCESS_KEY_ID`/`R2_PUBLISH_SECRET_ACCESS_KEY` were in
fact added to GitHub, that's a real deviation from the documented threat
model, not a naming detail — flagging it rather than quietly confirming
it as correct. Two honest paths from here, your call:

- **They shouldn't be there.** Revoke `qc-ci-read`'s sibling if it was
  over-scoped, remove the two secrets, and CI keeps only the read pair.
- **A real future need exists** (e.g., an artifact-publishing job planned
  before D1 that I haven't been told about). If so, say what it's for —
  `docs/PRIVATE_STORAGE.md` §5–§7 should be updated to document it
  deliberately rather than have it appear unexplained in a verification
  pass.

No secret was deleted, added, or touched in producing this report — the
account is where they live, not the repository.

---

## What's actually true right now

| Question | Answer |
|---|---|
| Does CI reference any R2 secret or variable? | **No** — `ci.yml` is unchanged since B2 |
| Can I confirm the four secrets exist? | **No** — no API access from this session |
| Can I confirm the two variables exist? | **No** — same |
| Is there a write-capable credential in GitHub secrets? | **Possibly** (`R2_PUBLISH_*`) — flagged above, not confirmed by me, contradicts the documented plan if true |
| Did a real read/write/read-only test run in this pass? | **No** — no tooling or credentials in this environment |
| Was any code, workflow, or secret modified? | **No** |

## Recommended next step

Two independent threads, either order:

1. **You run verification where the credentials live** — your
   PowerShell session with rclone installed. Re-run
   `C1_PROVISIONING_CHECKLIST.md` §6a–§6c against the read-only
   credential specifically, and paste back the §8 log. That's the only
   way items 5–7 get genuinely verified, by me or anyone.
2. **Resolve the `R2_PUBLISH_*` question above** before any CI workflow
   change is written, since the workflow (whoever writes it) should only
   ever be given the credential it actually needs.

The CI wiring itself (referencing `R2_READ_*` in an additive fetch step)
remains unimplemented and is its own sprint — not attempted here, since
this was scoped as verification only.
