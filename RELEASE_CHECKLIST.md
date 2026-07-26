# Release gate — Qur'an Companion

Rewritten at Sprint 34.0. **Every item below is objective**: it names a
command to run or a condition with exactly one right answer. If an item
cannot be checked without a human opinion, it does not belong here.

Narrative history of earlier release preparation (keystore creation,
signature verification, R8) is archived at
[`docs/reports/RELEASE_PREP_HISTORY.md`](docs/reports/RELEASE_PREP_HISTORY.md).

Legend: ✅ passes today · ❌ fails today · ⬜ cannot be checked on this
machine (needs macOS, a Play/Apple account, or a physical device).

---

## A. Blocking — no build ships until all pass

| # | Item | Verification | Pass condition | Now |
|---|---|---|---|---|
| A1 | Licence verified for every bundled content source | `docs/LICENSING.md` §4 contains no row marked "CÒN TREO" | zero open rows | ❌ 2 open |
| A2 | Privacy policy live at a public URL | `curl -sI $PRIVACY_POLICY_URL` | HTTP 200 | ❌ |
| A3 | Terms of use live at a public URL | `curl -sI $TERMS_URL` | HTTP 200 | ❌ |
| A4 | No placeholder left in legal documents | `grep -rn "{{" legal/` | no output | ❌ |
| A5 | App icon is not the Flutter default | `md5sum android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` | ≠ `57838d52c318faff743130c3fcfae0c6` | ❌ |
| A6 | Formatter clean | `dart format --output=none --set-exit-if-changed lib test` | exit 0 | ✅ |
| A7 | Analyzer clean at strictest level | `flutter analyze --fatal-infos` | "No issues found!" | ✅ |
| A8 | Full test suite green | `flutter test` | "All tests passed!" | ✅ 904 |
| A9 | Coverage above CI gate | `flutter test --coverage` then CI's lcov filter | ≥ 70% | ✅ 84.0% hand-written |
| A10 | Release build succeeds and is signed with the upload key | `flutter build appbundle --release` then `jarsigner -verify -certs` | "jar verified", CN=Du So | ✅ built 35.0, 75.3 MB, `META-INF/UPLOAD.SF` present |
| A11 | Attribution complete for shipped data | `flutter test test/attribution_real_data_test.dart` | 4/4 pass | ✅ |
| A12 | Font licence notices present | `flutter test test/font_licenses_test.dart` | 4/4 pass | ✅ |
| A13 | App label is human-readable | `aapt2 dump badging <apk> \| grep application-label:` | `Qur'an Companion` | ✅ (fixed 34.0) |
| A14 | Font licence notices survive into the shipped artifact | `unzip -l app-release.aab \| grep licenses/` | 4 files | ✅ verified in the AAB (35.0) |

## B. Google Play

| # | Item | Verification | Pass condition | Now |
|---|---|---|---|---|
| B1 | Artifact is an AAB | file uploaded ends `.aab` | — | ⬜ |
| B2 | Target API level current | `aapt2 dump badging` → `targetSdkVersion` | ≥ 35 | ✅ 36 |
| B3 | Play App Signing enabled | Play Console → Setup → App signing | "Play App Signing is enabled" | ⬜ |
| B4 | Data safety form submitted | Play Console → Policy → Data safety | status "Submitted" | ⬜ (answers ready: `legal/STORE_COMPLIANCE.md` §1) |
| B5 | Content rating obtained | Play Console → Content rating | rating issued | ⬜ (answers ready: §2) |
| B6 | Privacy policy URL entered | Play Console → Store listing | field non-empty, resolves 200 | ⬜ |
| B7 | Store icon 512×512 uploaded | Play Console asset check | accepted | ❌ |
| B8 | Feature graphic 1024×500 uploaded | Play Console asset check | accepted | ❌ |
| B9 | ≥2 phone screenshots per listed language | Play Console asset check | accepted | ❌ |
| B10 | applicationId matches Console | `aapt2 dump badging \| grep package:` | `com.duso.qurancompanion` | ✅ |
| B11 | versionCode strictly greater than any previous upload | `aapt2 dump badging \| grep versionCode` | monotonic | ⬜ currently 7 |
| B12 | Internal testing track passes pre-launch report | Play Console → Pre-launch report | 0 crashes, 0 P1 issues | ⬜ |

## C. Apple App Store

| # | Item | Verification | Pass condition | Now |
|---|---|---|---|---|
| C1 | Apple Developer Program membership active | developer.apple.com account page | "Active" | ❌ |
| C2 | Distribution certificate + provisioning profile | Xcode → Signing & Capabilities | no errors | ⬜ |
| C3 | `PrivacyInfo.xcprivacy` present in built app | `unzip -l Runner.app \| grep PrivacyInfo` | 1 hit | ⬜ **file created 34.0, not yet added to the Runner target** |
| C4 | App privacy labels submitted | App Store Connect → App Privacy | "Ready for submission" | ⬜ (answers ready: §4) |
| C5 | Export compliance declared | `ITSAppUsesNonExemptEncryption` in Info.plist | key present | ✅ (`false`, added 34.0) |
| C6 | App icon 1024×1024, no alpha channel | `sips -g hasAlpha Icon-App-1024x1024@1x.png` | `hasAlpha: no` | ❌ stock icon |
| C7 | Screenshots for every required device class | App Store Connect asset check | accepted | ❌ |
| C8 | Bundle display name correct | `plutil -p Info.plist \| grep CFBundleDisplayName` | `Qur'an Companion` | ✅ (fixed 34.0) |
| C9 | TestFlight build installs and launches | manual install from TestFlight | app reaches Home | ⬜ |

## D. Build and distribution hygiene

| # | Item | Verification | Pass condition | Now |
|---|---|---|---|---|
| D1 | CI builds the artifact that ships | `.github/workflows/ci.yml` contains `build appbundle --release` | present | ✅ (35.0 — PR: debug APK · main/tag: release AAB) |
| D2 | Release build is minified | `android/app/build.gradle.kts` | `isMinifyEnabled = true` | ✅ |
| D3 | R8 mapping file retained for crash de-obfuscation | CI artifact `r8-mapping`, 90-day retention, `if-no-files-found: error` | uploaded | ✅ in CI (35.0) · ⬜ permanent copy is the publisher's step 4 |
| D4 | Keystore backed up off this machine | manual confirmation by publisher | backup exists | ⬜ |
| D5 | `key.properties` and `*.jks` are git-ignored | `git check-ignore -v android/key.properties` | matched | ✅ |
| D6 | No debug/verbose logging in release | `grep -rn "print(" lib/ \| grep -v console_logger` | no output | ✅ |
| D7 | Version in `pubspec.yaml` matches the release being cut | `grep '^version:' pubspec.yaml` | intended value | ⬜ 0.8.1+7 |
| D8 | Content database version matches the app constant | `flutter test test/content_database_smoke_test.dart` | pass | ✅ v6 |

## E. Functional gates verifiable by command

| # | Item | Verification | Pass condition | Now |
|---|---|---|---|---|
| E1 | Architecture boundaries intact | `flutter test test/architecture_boundaries_test.dart` | 5/5 pass | ✅ |
| E2 | Every ayah resolves commentary | `flutter test test/tafsir_real_corpus_test.dart` | 14/14 pass | ✅ |
| E3 | App launches to Home without exception | `flutter test test/widget_test.dart` | pass | ✅ |
| E4 | Cold start under the project's own 2 s goal | `flutter run --profile --trace-startup` → `timeToFirstFrameRasterizedMicros` | < 2 000 000 | ❌ 1 395 879 µs to raster, but 2 530 ms to usable launch |
| E5 | Web build produces a working database | `flutter build web` then load in browser | no console error | ❌ `sqlite3.wasm` / `drift_worker.js` absent from `web/` |

## F. Cannot be automated — requires a device or a human

These are listed so they are not mistaken for done. Each has a binary
outcome even though a person must produce it.

| # | Item | Pass condition |
|---|---|---|
| F1 | TalkBack pass on Reading, Study, Attribution | every actionable control announces a label |
| F2 | VoiceOver pass, same screens | same |
| F3 | Font scale 200% on the five main screens | no clipped text, no overlapping controls |
| F4 | Scroll a 286-ayah Surah on a mid-range device | no visible stutter over 10 s of scrolling |
| F5 | Play audio for 10 minutes with the screen off | playback continues or fails cleanly (background audio is unimplemented — expected failure today) |
| F6 | Airplane-mode pass | every screen renders; audio fails with a message, no crash |
| F7 | Fresh install on a device with < 200 MB free | install completes or fails with a system message, no corruption |

---

## Current gate result

**A: 10 of 14 pass** (Sprint 35.0 added A14 and turned A10 green by
building the real AAB).

The four failures are unchanged in kind since Sprint 33.0 and none is
an engineering problem:

| Failing | Nature | Who can clear it |
|---|---|---|
| A1 licences unverified | legal | rights holders |
| A2/A3 documents not hosted | operational | publisher |
| A4 placeholders remain | publisher decisions | publisher |
| A5 stock Flutter icon | design | designer |

No item in section A can be waived by an engineering decision.
