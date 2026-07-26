# Publisher checklist — cutting a release

For the person with the keystore and the store accounts. Run top to
bottom. Every step either succeeds or stops the release; none is a
judgement call.

The engineering gate (`RELEASE_CHECKLIST.md` §A) must already be green
before you start here.

---

## 1. Before building

```bash
git status --porcelain
```
Must print nothing. Never cut a release from a dirty tree.

```bash
grep '^version:' pubspec.yaml
```
Must be the version you intend to publish. Bump it and commit *before*
tagging, never after.

```bash
grep -rn "{{" legal/
```
Must print nothing. A placeholder in a published privacy policy is a
false statement to a regulator.

## 2. Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build appbundle --release
```

Expected output: `build/app/outputs/bundle/release/app-release.aab`.

**Never publish an APK.** Play requires AAB for new apps, and the AAB
is what lets Play deliver ~34 MB instead of ~69 MB.

## 3. Verify the artifact before uploading

```bash
jarsigner -verify -verbose:summary -certs build/app/outputs/bundle/release/app-release.aab
```
Must print `jar verified` and the expected certificate DN. If it prints
a debug certificate, `android/key.properties` was missing at build time
— the AAB is unusable for Play.

```bash
unzip -l build/app/outputs/bundle/release/app-release.aab | grep licenses/
```
Must list four files. These are the OFL and KFGQPC notices; shipping
without them violates the font licences.

```bash
ls -la build/app/outputs/mapping/release/mapping.txt
```
Must exist. **Copy it somewhere permanent, named after the version.**
Without it, every future crash report from this build is unreadable.

## 4. Archive with the release

Store together, keyed by version, outside this machine:

| Artifact | Why |
|---|---|
| `app-release.aab` | the exact bytes uploaded |
| `mapping.txt` | the only way to de-obfuscate crashes from this build |
| `pubspec.lock` | the exact dependency set that produced it |
| git tag / commit SHA | the source it came from |

## 5. Tag

```bash
git tag -a vX.Y.Z-rcN -m "Release candidate N"
git push origin vX.Y.Z-rcN
```

CI runs the full pipeline on `v*` tags and attaches the AAB and
`mapping.txt` as artifacts of that tag (90-day retention — the
permanent copy in step 4 is still yours to keep).

## 6. Upload

**Play Console**
1. Internal testing track first. Never production directly.
2. Confirm Play App Signing is enabled before the first upload — after
   it, the choice cannot be changed.
3. Wait for the pre-launch report. Zero crashes and zero P1 issues, or
   stop.
4. Data safety form and content rating must be submitted before the
   listing can go live.

**App Store Connect**
1. Confirm `PrivacyInfo.xcprivacy` is a member of the Runner target
   before archiving — a file on disk that is not in the target ships
   nothing.
2. Export compliance is pre-declared in `Info.plist`
   (`ITSAppUsesNonExemptEncryption = false`); confirm it still matches
   the build.
3. TestFlight first, internal testers, at least one full launch.

## 7. Do not skip

- Do not upload a build that CI has not seen.
- Do not change `applicationId` or the signing key after the first
  upload. Both are irreversible.
- Do not raise `versionCode` past what you intend — Play refuses lower
  numbers forever after.
