# Session 142 — Privacy Fact-Base Reconciliation Report

**Type: DOCUMENTATION ONLY. NO APPLICATION CODE CHANGED.**

This report records the evidence behind the Session 142 documentation
changes. It makes **no legal determination**, asserts **no store
approval**, and closes **no item that requires counsel**.

---

## 1. Baseline

| Item | Value |
|---|---|
| `origin/main` SHA at session start | `ad505cb64e6c0712f771723610717421b95c67a7` |
| Expected SHA (per session brief) | `ad505cb64e6c0712f771723610717421b95c67a7` — **match** |
| Tip commit subject | `Merge pull request #46 from duso201189-nxp/session139-inapp-privacy-policy-link` |
| Working branch | `session142-privacy-reconciliation` |
| Worktree | `worktrees/session142-privacy-reconciliation` (isolated; created from the baseline SHA, clean at creation) |
| Primary worktree | **Not touched.** Left dirty on `publish-docs-reconciliation-s14` exactly as found — no checkout, reset, clean, stash, commit, or rebase. |
| Session date | 2026-08-28 |

The Session 141 report was **not** used as a source of truth. Every fact
below was re-derived from the repository or from a live request made by
this session.

---

## 2. Exact network call sites at `ad505cb`

Four outbound behaviours. The app initiates the first two; the user
initiates the last two by tapping.

| # | Behaviour | Call site | Host |
|---|---|---|---|
| 1 | `HttpClient` audio download (prefetch/cache) | `lib/core/cache/io_cache_manager.dart:12-28` (`httpDownloader`), URL built by `buildAyahAudioUrl` (`lib/core/audio/audio_url.dart:6-14`) | `everyayah.com` |
| 2 | Platform-engine audio streaming | URIs built at `lib/features/quran/presentation/audio/audio_controller.dart:257,270`, handed to `just_audio`; the platform engine (ExoPlayer / AVPlayer / browser `<audio>`) fetches them itself | `everyayah.com` |
| 3 | `launchUrl(https://tanzil.net)` | URI constant `lib/features/profile/presentation/profile_screen.dart:192`; tap handler line 208; dispatched via `_launchExternal` line 166 (`launchUrl(uri, mode: LaunchMode.externalApplication)`, line 168) | `tanzil.net` |
| 4 | `launchUrl(https://duso201189-nxp.github.io/quran-companion/privacy/)` — **NEW, Session 139 / PR #46** | URI constant `lib/features/profile/presentation/profile_screen.dart:267-268`; tap handler line 277; dispatched via the same `_launchExternal` helper | `duso201189-nxp.github.io` |

Both `launchUrl` destinations are **compile-time constants** in
`profile_screen.dart`, never built from user input, and both pass
through the single `_launchExternal` helper, which swallows platform
errors rather than crashing. In both cases the app transmits nothing
itself — it asks the OS to open an address, and the user's own browser
then makes the request.

`grep -rn "launchUrl" lib/ --include=*.dart` returns exactly one
executable occurrence: `profile_screen.dart:168`, inside
`_launchExternal`. Both link widgets route through it.

---

## 3. Exact external host set

Exactly **three**:

1. `everyayah.com`
2. `tanzil.net`
3. `duso201189-nxp.github.io`

---

## 4. How each host was verified

**Repository-wide URL literal sweep.** Every `http(s)://` literal under
`lib/` was extracted and reduced to its origin:

```
3  https://everyayah.com          (doc comments in audio_url.dart, content_tables.dart, app_database.g.dart)
2  https://tanzil.net             (URI constant + prose)
1  https://duso201189-nxp.github.io
```

No fourth origin appears anywhere in `lib/`.

**`everyayah.com` — audio, verified at the data layer, not just in
comments.** The audio host is *data-driven*: `buildAyahAudioUrl` only
substitutes `{sss}`/`{aaa}` into a template read from the `reciters`
table. The bundled content database `assets/database/quran.sqlite` was
therefore read directly. All five rows:

```
1  https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3
2  https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/{sss}{aaa}.mp3
3  https://everyayah.com/data/Minshawy_Murattal_128kbps/{sss}{aaa}.mp3
4  https://everyayah.com/data/Husary_128kbps/{sss}{aaa}.mp3
5  https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/{sss}{aaa}.mp3
```

A `WHERE audio_url_template NOT LIKE 'https://%'` query returned **zero
rows**: every shipped recitation address uses HTTPS. This verifies what
the app **requests**. It does **not** verify how the live
`everyayah.com` server responds (redirects, downgrades, TLS
configuration) — that remains unverified, as it was before.

**`tanzil.net`** — URI constant read directly at
`profile_screen.dart:192`.

**`duso201189-nxp.github.io`** — URI constant read directly at
`profile_screen.dart:267-268`; the path is `/quran-companion/privacy/`,
matching the canonical URL.

**Dependency cross-check.** `pubspec.yaml`'s runtime dependency list was
re-read. The only network-capable entries are `just_audio` /
`just_audio_windows` / `audio_service` (which fetch the URL the app
supplies) and `url_launcher` (which hands an address to the OS). No HTTP
client package, analytics SDK, ads SDK, or crash-reporting SDK is
declared. The sole `dart:io HttpClient` construction in `lib/` is
`io_cache_manager.dart:13`.

---

## 5. Live Privacy Policy HTTP status

Requested by this session on **2026-08-28**:

```
GET https://duso201189-nxp.github.io/quran-companion/privacy/
```

| Field | Value |
|---|---|
| Status | **HTTP 200** |
| Redirects | 0 |
| Scheme | HTTPS |
| `Server` | `GitHub.com` |
| `Content-Type` | `text/html; charset=utf-8` |
| `Last-Modified` | `Fri, 28 Aug 2026 03:42:23 GMT` |

The `Server: GitHub.com` response header is the direct evidence that the
canonical URL is served by GitHub Pages infrastructure. This is a
**liveness and hosting fact only** — it is not evidence that the policy
is legally adequate, nor permission to submit any store form.

---

## 6. Apple Privacy Manifest — verified references

`ios/Runner/PrivacyInfo.xcprivacy` **exists** (6180 bytes) and declares
`NSPrivacyTracking = false` with `NSPrivacyTrackingDomains`,
`NSPrivacyCollectedDataTypes`, and `NSPrivacyAccessedAPITypes` all
**empty arrays**.

It is wired into `ios/Runner.xcodeproj/project.pbxproj` at four
references, each read directly this session:

| Line | Reference |
|---|---|
| 10 | `PBXBuildFile` — `99E4FEF3… /* PrivacyInfo.xcprivacy in Resources */ … fileRef = 63DEFB52…` |
| 63 | `PBXFileReference` — `lastKnownFileType = text.plist.xml; path = PrivacyInfo.xcprivacy` |
| 124 | Runner `PBXGroup` children list, immediately after `Info.plist` |
| 235 | Runner target `PBXResourcesBuildPhase` (`97C146EC1CF9000F007C117D /* Resources */`) files list |

**Boundary.** Existence and pbxproj wiring are mechanical facts and are
marked closed **with this evidence and nothing more**. The project has
never been built with Xcode/CocoaPods — no `ios/Podfile.lock` exists and
no macOS toolchain is available in this environment — so Apple's
archive-time manifest-merge step has **never run**. Nothing in this
session claims Xcode archive verification, manifest completeness,
`NSPrivacyAccessedAPITypes` sufficiency, App Privacy label completion,
Apple approval, App Store approval, or legal compliance.

---

## 7. Old statements found vs. corrected statements

| # | File | Old statement (stale) | Corrected statement |
|---|---|---|---|
| 1 | `privacy/index.md` | "three kinds of outbound network activity" | **four** kinds; the Privacy Policy link added as behaviour 4, described factually |
| 2 | `privacy/index.md` | "The two websites your device may contact — everyayah.com … and tanzil.net" | **three** websites, adding `duso201189-nxp.github.io`, identified as a GitHub Pages address served by GitHub, Inc. |
| 3 | `privacy/index.md` | Withdrawing consent: "do not tap the Tanzil.net link" | "do not tap the links the app shows — the Tanzil.net credit link, or the link to this policy" (Tanzil treatment preserved) |
| 4 | `privacy/index.md` | Last updated: 27 August 2026 | Last updated: **28 August 2026** (Effective date left at **27 August 2026**, unchanged) |
| 5 | `STORE_PRIVACY_FORM_DRAFT.md` §6 | Session 137 block: "Three outbound behaviours exist" | New Session 142 correction block: **four**, with re-verified line citations; Session 137 block preserved verbatim |
| 6 | `STORE_PRIVACY_FORM_DRAFT.md` §6 | Tanzil `launchUrl` cited at `profile_screen.dart:194` | Re-verified: URI constant line 192, tap handler line 208, helper line 166 |
| 7 | `STORE_PRIVACY_FORM_DRAFT.md` §14 | "the URL still returns 404 … Do not paste this URL into either console yet" | **SUPERSEDED** — live HTTP 200 recorded; original text preserved |
| 8 | `STORE_PRIVACY_FORM_DRAFT.md` §14 | "No in-app Privacy Policy link exists … Deferred to **Session 138**" | **SUPERSEDED** — shipped in **Session 139 (PR #46)**; original text preserved |
| 9 | `STORE_PRIVACY_FORM_DRAFT.md` §15 | "No `PrivacyInfo.xcprivacy` (Apple Privacy Manifest) exists yet" | **SUPERSEDED** — exists and is pbxproj-wired; Xcode-unverified; original bullet preserved |
| 10 | `STORE_PRIVACY_FORM_DRAFT.md` §4 | Owner-confirmation nuance covered `everyayah.com` only | Extended to both `launchUrl` hand-offs, with classification recorded **UNKNOWN / LEGAL REVIEW REQUIRED** |
| 11 | `V1_STORE_LEGAL_READINESS.md` exec status | Policy "staged, not yet live"; "still **no in-app link**" | Live (HTTP 200) and in-app link exists (Session 139); still not legally approved |
| 12 | `V1_STORE_LEGAL_READINESS.md` iOS table | Privacy Manifest "Does not exist \| confirmed absent under `ios/`" | Exists + pbxproj-wired with line citations; Xcode-UNVERIFIED; App Privacy labels OPEN |
| 13 | `V1_STORE_LEGAL_READINESS.md` P0-1 | Sub-items 1 (404) and 2 (no in-app link) open; item 2 "Deferred to Session 138" | Both closed-with-evidence; **P0-1 remains OPEN** on sub-item 3 (no legal review) and Terms of Use |
| 14 | `V1_STORE_LEGAL_READINESS.md` P1-1 | "Apple Privacy Manifest … does not exist" | **PARTIALLY CLOSED WITH EVIDENCE, NOT VERIFIED**; App Privacy labels explicitly excluded and left to P1-2 |
| 15 | `RELEASE_CHECKLIST.md` | One combined unchecked item: "Apple Privacy Manifest (PrivacyInfo.xcprivacy) + App Privacy labels" | **Split into two separate unchecked items** (see §9) |

The `privacy/index.md` section **"What this policy does not claim"** was
**not modified**. Its existing final bullet ("It makes no representation
about how everyayah.com, tanzil.net, or any other independently operated
service handles the requests it receives") already covers the new host
through the "any other independently operated service" clause, so no
change was needed and none was made.

Owner identity, locality, and contact details were **not altered**. No
date of birth, CCCD number, full residential address, or other private
owner information was added anywhere.

---

## 8. Files changed

Exactly **five**, all documentation:

1. `privacy/index.md`
2. `docs/release/STORE_PRIVACY_FORM_DRAFT.md`
3. `docs/release/V1_STORE_LEGAL_READINESS.md`
4. `RELEASE_CHECKLIST.md`
5. `docs/release/SESSION_142_PRIVACY_RECONCILIATION_REPORT.md` (new — this file)

---

## 9. `RELEASE_CHECKLIST.md` split

The single combined item became two, **both left unticked**:

- `[ ]` **Apple Privacy Manifest** — drafted + pbxproj-wired (evidence
  cited inline), **Xcode-unverified**. The checklist text states
  explicitly that the file's existence is *not* grounds to tick, and
  that ticking requires a real `flutter build ios`/archive on macOS.
- `[ ]` **Apple App Privacy labels** — **OPEN, console action
  required.** No part of this work lives in the repository; it must be
  completed by the App Store Connect account holder. The text states
  that the manifest's existence does **not** complete this item.

---

## 10. Validation results

| Check | Result |
|---|---|
| `git diff --check` | **Clean** — no whitespace/conflict errors |
| `dart format --output=none --set-exit-if-changed .` | **Formatted 444 files (0 changed)**, exit 0. No Dart file was changed this session; run as a guard. |
| `flutter analyze --fatal-infos` | **No issues found!** (60.5s) |
| `flutter test` | **All tests passed — 1341/1341** |
| Secret scan (added lines only) | **No matches.** Pre-existing keystore-hygiene prose elsewhere in the files is untouched and contains no secret values. |
| Owner-PII scan (added lines only) | **No matches.** The single "street" hit is the pre-existing sentence "A full street address remains unpublished by owner choice", reflowed, not new. |
| Protected-path scan | **No changes** under `lib/`, `android/`, `ios/`, `pubspec*`, `docs/adr/`, `constitution/`, `test/`, `.github/` |
| Authorized-file count | **5 of 5**, no others staged |

**Note on `flutter pub get`.** Running it in a fresh worktree rewrites
seven generated desktop plugin-registrant files under `linux/`, `macos/`,
and `windows/` with line-ending-only churn. `git diff --numstat` reports
**zero added and zero deleted lines** for all seven — the content is
identical. They were deliberately **left unstaged and uncommitted**;
only the five authorized files were staged by explicit path.

---

## 11. Explicit legal UNKNOWNs

Recorded, not resolved:

1. **Store classification of the two `launchUrl` browser hand-offs.**
   Whether handing `tanzil.net` or `duso201189-nxp.github.io` to the
   user's browser constitutes "sharing data with a third party" for
   Google Play Data safety or Apple App Privacy purposes is **UNKNOWN /
   LEGAL REVIEW REQUIRED**. The policy discloses the behaviour
   **factually** and applies **no classification**, per this session's
   explicit constraint.
2. **First-party document on third-party infrastructure.**
   `duso201189-nxp.github.io` serves the app's own policy from GitHub,
   Inc.'s servers. Which framing each console's form asks about is not
   determined.
3. **Whether the in-app link satisfies Apple 5.1.1(i) or the Google Play
   User Data policy.** Only its mechanical existence is established.
4. **Legal review of the policy's content** — has not occurred. No
   counsel has reviewed `privacy/index.md`.
5. **Tanzil translation licence review (P0-2)** — still open, unchanged
   by this session.
6. **Publisher-address rules** — whether the reduced public locality
   satisfies any store's publisher-address requirement is unresolved.
7. **Live `everyayah.com` server TLS behaviour** — what the app requests
   is verified HTTPS; how the server responds is not.
8. **`NSPrivacyAccessedAPITypes` completeness** — resolvable only by a
   real Xcode archive build.
9. **Terms of Use** — does not exist in any form.

---

## 12. Explicit owner actions

Outside this session's authority; none were performed:

1. Complete and submit the **Google Play Data safety** form.
2. Complete and submit the **Apple App Privacy labels** questionnaire in
   App Store Connect.
3. Obtain **legal review** of `privacy/index.md`, and of the sharing
   classification in item 1 of §11.
4. Run a real **Xcode archive build** on macOS to verify
   `PrivacyInfo.xcprivacy` and address any Required-Reason API warning.
5. Author **Terms of Use**.
6. Resolve the **Tanzil licence** review (P0-2).
7. Decide the **publisher-address** question.

---

## 13. STOP conditions

This session was bound to stop on any of the following. Status:

| # | Condition | Status |
|---|---|---|
| 1 | GitHub Pages needs a legal classification, not a factual disclosure | **Encountered and handled as instructed** — recorded as UNKNOWN / LEGAL REVIEW REQUIRED (§11.1); the policy discloses the behaviour factually and classifies nothing |
| 2 | Application code would need to change | Not triggered — no `lib/` change |
| 3 | Android or iOS configuration would need to change | Not triggered — no `android/` or `ios/` change |
| 4 | Owner identity, locality, email, DOB, CCCD, or address would need to change | Not triggered — none altered, none added |
| 5 | Legal review would need to be marked complete | Not triggered — kept OPEN everywhere |
| 6 | Store approval would need to be marked complete | Not triggered — none claimed |
| 7 | `DR-2026-0016`, `DR-2026-0029`, `DR-2026-0030`, or `pubspec.yaml` would need modification | Not triggered — all untouched |
| 8 | `flutter test` fails | Not triggered — 1341/1341 pass |
| 9 | More than five files modified | Not triggered — exactly five |
| 10 | "What this policy does not claim" would need to change | Not triggered — preserved verbatim |

---

## 14. Governance preservation

No decision record was created, modified, reopened, or reinterpreted.
`DR-2026-0016`, `DR-2026-0029`, and `DR-2026-0030` are byte-identical to
the baseline, as is `pubspec.yaml` (version unchanged). Nothing under
`constitution/` was touched.
