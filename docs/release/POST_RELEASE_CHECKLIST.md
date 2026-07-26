# Post-release checklist

Includes the rollback and recovery plans, because the time to write
those is before they are needed.

---

## First 24 hours

| # | Check | Where | Threshold |
|---|---|---|---|
| 1 | Crash-free sessions | Play Console → Android vitals | ≥ 99.0% |
| 2 | ANR rate | Play Console → Android vitals | < 0.47% (Play's bad-behaviour threshold) |
| 3 | Install failures | Play Console → Statistics | no spike |
| 4 | Uninstall rate day 1 | Play Console | no spike vs. installs |
| 5 | User reviews mentioning data loss or wrong text | Play Console → Reviews | **any single one is a stop-ship signal** |
| 6 | Support inbox | `{{SUPPORT_EMAIL}}` | triage within 24 h |

**The app has no crash reporting.** Android vitals and user reviews are
the *only* signals that something is wrong. Treat them accordingly, and
treat adding crash reporting as the highest-value post-release change.

## First week

| # | Check |
|---|---|
| 7 | Confirm `mapping.txt` for this exact build is archived and findable |
| 8 | Re-run `curl -sI` on the privacy policy and terms URLs — a dead legal URL is a policy violation |
| 9 | Verify the store listing renders correctly on a real phone, both languages |
| 10 | Confirm the attribution screen shows every source on a shipped device build |
| 11 | Check whether any content publisher has responded to the licensing enquiries |

---

## Rollback strategy

**Android has no true rollback.** Play cannot un-publish a version to
users who already installed it, and `versionCode` can never decrease.
Plan accordingly.

### Level 1 — halt the rollout (minutes)
Play Console → Release → **Halt rollout**. Stops new users receiving the
build. Existing installs are unaffected. Use for anything suspected but
unconfirmed.

**Always use a staged rollout** (start at 5–10%) so this lever exists.
A 100% rollout removes the cheapest safety mechanism you have.

### Level 2 — roll forward (hours)
Fix, bump `versionCode`, ship. This is the only way to fix users who
already installed the bad build. Budget for it: a fix must be
buildable, testable and uploadable in under a day, which is why the
publisher checklist insists the tree is clean and the pipeline is
reproducible.

### Level 3 — re-publish a previous build (last resort)
Rebuild the previous tag with a **higher** `versionCode`, upload as new.
Requires the previous tag to build reproducibly — which is why
`pubspec.lock` and the pinned `FLUTTER_VERSION` are archived with each
release.

### Content-only problems
If the defect is data rather than code, the fix is a new content
database plus a bump of `DATA_VERSION` and
`DatabaseConstants.expectedDataVersion`. The app replaces the installed
copy on next launch, atomically, without touching user data. This is
the cheapest fix path available and should be preferred whenever the
defect is in content.

---

## Recovery plan

### Lost upload keystore
- **Play App Signing enabled:** request an upload-key reset from Google
  through account-identity verification. Recoverable.
- **Not enabled:** the app can never be updated again. A new listing
  under a new applicationId is the only option, and every existing user
  is stranded.

This asymmetry is why enabling Play App Signing on the very first upload
is non-negotiable.

### Lost `mapping.txt`
Crash traces from that build are permanently unreadable. Not
recoverable, only preventable — hence step 7 above and the archive step
in the publisher checklist.

### Upstream content source disappears
Content is baked into the shipped database, so users are unaffected
immediately. Rebuilding, however, needs the upstream. `tool/data/*.json`
already caches transliteration and both tafsir corpora; the Arabic text
and both translations are still fetched live at build time and are the
exposed part.

### Audio host disappears
All audio fails for all users at once. `reciters` stores a URL template
per reciter, so switching hosts is a content-database change (see
"Content-only problems" above) rather than an app update — provided a
replacement host exists.

### Compromised keystore
Rotate through Play App Signing's upload-key reset. Never commit the
new key. Assume any build signed with the old upload key is suspect.

---

## Standing follow-ups after any release

| # | Item |
|---|---|
| 12 | Update `CHANGELOG.md` for the released version — move `[Unreleased]` into a dated section |
| 13 | Re-run the whole `RELEASE_CHECKLIST.md` §A against the next candidate; do not assume a previously-green item is still green |
| 14 | Re-check `docs/LICENSING.md` `review_by` dates — upstream terms change without notice |
| 15 | Confirm the keystore backup still exists and is readable |
