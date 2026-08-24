# V1.0 Store & Legal Readiness — Session 95 Audit

**Status: NOT RELEASED. VERSION 1.0.0 NOT AUTHORIZED.**

This document is a point-in-time inventory (2026-08-24, Session 95) of the
store-submission and legal-compliance surface for Qur'an Companion. It does
not replace, override, or duplicate `RELEASE_DASHBOARD.md`,
`docs/release/RELEASE_PLAN_V1.md`, or `RELEASE_CHECKLIST.md` — those remain
authoritative for release sequencing and sign-off. This document exists to
give one consolidated, evidence-linked view of what is blocking store
submission specifically, and to classify each blocker by who can act on it.

This document makes **no legal determinations**. Where a license, permission,
or approval question is open in the source documents, it is reported here as
open — never resolved, narrowed, or implied-resolved.

> **Session 104 amendment (2026-08-24, re-verified against `origin/main`
> `7c60f05`).** Between Session 95's baseline (`866fdc4`) and this
> re-verification, exactly four commits landed on `main`, touching only
> `lib/app/router.dart`, `lib/features/study/presentation/study_screen.dart`,
> and two test files (PRs #31/#32). No other file this document cites
> changed, so every other citation below (line numbers included) was
> re-checked and remains accurate as Session 95 recorded it. Those two
> commits close the gap this document originally flagged as **P0-3**: the
> Study-tab Flashcard shortcut now has `onTap: null` (renders the existing
> "Coming soon" affordance instead of navigating), and a router-level
> redirect blocks direct/deep-link entry into all five F2 routes
> (`/flashcards`, `/flashcards/add`, `/flashcard-decks`,
> `/flashcards/smart-deck`, `/flashcard-review`), sending them to `/study`.
> Route and screen definitions for F1/F2 remain in the codebase — per
> `DR-2026-0030`'s own `reversibility: soft` field, that is **intentional**,
> not an unresolved gap. The executive-status bullet, legal-inventory item
> 10, and P0-3 below are updated in place with this finding; nothing else in
> this document was altered, and no governance record (`DR-2026-0029`,
> `DR-2026-0030`) was reopened or reinterpreted to produce it.

## Executive status

- No store submission has occurred. No Apple Developer or Google Play
  Console account activity is evidenced in this repository.
- `pubspec.yaml` version is `0.8.1+7` — pre-1.0. This document does not
  propose or authorize a version bump.
- Legal review of the Tanzil translation license is **open, not returned**
  (`RELEASE_DASHBOARD.md:1152`).
- QAC permission status is **unknown/unrecorded** — DR-2026-0029 explicitly
  states it neither asserts a request was sent nor that one was never sent.
  MASAQ was evaluated and **rejected** by DR-2026-0029 on structural and
  licensing grounds.
- Lexicon (F1) and Flashcards (F2) are declared **deferred from v1.0 scope**
  by DR-2026-0030. **[Session 104 update]** As of `main` commit `7c60f05`,
  the Study-tab Flashcard shortcut is disabled and a router-level redirect
  blocks direct/deep-link access to all five F2 routes — see the amendment
  note above and P0-3 below (now resolved). Feature code and route
  definitions still exist; that is intentional soft-reversibility per
  DR-2026-0030, not a live/reachable gap.
- Privacy Policy and Terms of Use do not exist in any form (no draft, no
  URL, no in-app route).
- Android identity/signing mechanics are in place; the release keystore and
  `key.properties` correctly do not exist in this repository (gitignored,
  publisher-machine-only per `RELEASE_CHECKLIST.md`). Play Console
  registration/Play App Signing enrollment is unconfirmed.
- iOS has no signing, Team ID, or provisioning configured at all — expected,
  since this project has apparently never been built from macOS.
- No store listing metadata exists anywhere in the repository: no
  descriptions, no keywords, no screenshots, no feature graphic, no
  promotional assets.

## Android readiness

| Item | State | Evidence | Assessment |
|---|---|---|---|
| applicationId | `com.duso.qurancompanion` | `android/app/build.gradle.kts:19,29` | Ready — custom domain, consistent with `docs/release/RELEASE_PLAN_V1.md:79` |
| App label | `Qur'an Companion` | `android/app/src/main/AndroidManifest.xml:28` | Ready |
| Launcher icon | Present at all 5 densities | `android/app/src/main/res/mipmap-*/ic_launcher.png` | Unverified — `RELEASE_CHECKLIST.md:10` itself marks the 1024×1024 icon unchecked |
| Adaptive icon | Not configured | no `mipmap-anydpi-v26/ic_launcher.xml` exists | Missing |
| Splash/branding | Plain white placeholder, `flutter_native_splash` not wired | `android/app/src/main/res/drawable/launch_background.xml:4-11`; absent from `pubspec.yaml` | Missing/placeholder, matches `RELEASE_CHECKLIST.md:11` (unchecked) |
| Release signing mechanism | Reads `key.properties`, falls back to debug signing if absent | `android/app/build.gradle.kts:12-16,38-59` | Mechanism ready; secrets correctly absent from this worktree |
| Version derivation | `versionCode`/`versionName` from `pubspec.yaml` via Flutter's standard mechanism | `android/app/build.gradle.kts:34-35` | Ready |
| Play App Signing / Console registration | Not confirmed enrolled | `RELEASE_CHECKLIST.md:111-141` (unchecked) | Open — external action |

## iOS readiness

| Item | State | Evidence | Assessment |
|---|---|---|---|
| Bundle identifier | `com.duso.qurancompanion` (all configs) | `ios/Runner.xcodeproj/project.pbxproj:385,564,586` | Ready, consistent with Android |
| Display name | `CFBundleDisplayName = "Quran Companion"` (no apostrophe) — differs from Android's `"Qur'an Companion"` and README's `"Qur'an Companion"` | `ios/Runner/Info.plist:9-10` | Minor inconsistency — owner call, see P2-1 |
| AppIcon | Full 19-slot set present, real file sizes | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | Appears ready (not pixel-verified) |
| Launch screen | 1×1 pixel placeholder PNGs, unedited template `README.md` still present | `ios/Runner/Assets.xcassets/LaunchImage.imageset/` | Placeholder — never customized |
| Signing / Team ID / provisioning | None configured anywhere | `ios/Runner.xcodeproj/project.pbxproj` (no `DEVELOPMENT_TEAM`, no `CODE_SIGN_IDENTITY` on the app target) | Not started — requires macOS + Apple Developer enrollment |
| Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) | Does not exist | confirmed absent under `ios/` | Open, flagged at `docs/release/RELEASE_PLAN_V1.md:73-74` |
| App Store Connect | No app record, SKU, or account evidence | `docs/release/RELEASE_PLAN_V1.md:79-82`; `docs/release/PRODUCT_READINESS_REVIEW.md:154-158` | Not started |

## Web/PWA readiness

Prior to this session, `web/manifest.json` and `web/index.html` carried
unedited Flutter scaffold placeholders (`"quran_companion"` raw package name
as both `name` and `short_name`, `"A new Flutter project."` as the
description, the same raw name in the page `<title>` and
`apple-mobile-web-app-title`). **Fixed in this session** — see "Exact
changes implemented" below. `theme_color`/`background_color` remain
Flutter's default `#0175C2` blue; this is a design decision, not a factual
defect, and was deliberately left for owner/design input.

## Store metadata inventory

No store listing metadata exists anywhere in this repository — confirmed by
direct search, not merely inferred from checklists:

| Item | Found? | Evidence |
|---|---|---|
| Store descriptions (short/long, any language) | Not found | `RELEASE_CHECKLIST.md:191` lists it as an unchecked TODO |
| ASO keywords | Not found | `RELEASE_CHECKLIST.md:192` unchecked |
| Release notes / "what's new" copy | Not found | `CHANGELOG.md` is a developer changelog, not store-facing |
| Screenshots (any device size) | Not found | no `fastlane/`, `store_assets/`, or `docs/release/screenshots/` directory exists; `RELEASE_CHECKLIST.md:12` unchecked |
| Feature graphic (Android 1024×500) | Not found | — |
| Play Store icon (512×512) | Not found | — |
| iOS marketing screenshot sets | Not found | — |
| Store listing draft document | Not found | no `STORE_LISTING.md`/`PLAY_STORE.md`/`APP_STORE.md` anywhere |

This document does **not** create any of the above — per Phase 3 rules, no
fake screenshots, no invented marketing copy, no fabricated store metadata.

## Legal inventory

Every item below is tagged by evidence bucket: **[repo-evidence]** (a fact
directly observable in the repository), **[draft]** (unfinished material
exists), **[needs-external-verification]**, or
**[needs-owner/legal-approval]**.

1. **Privacy Policy** — [repo-evidence: absent]. No file, no route, no
   hosted URL. `RELEASE_DASHBOARD.md:710-711` names it under "Store & legal
   readiness unstarted."
2. **Terms of Use** — [repo-evidence: absent]. No file, no route.
3. **Data collection disclosure** — [repo-evidence]. No network/backend SDK
   in `pubspec.yaml`; storage is local-only (Drift/SQLite +
   `shared_preferences`), consistent with `constitution/PROJ-P-001-offline-first.md`.
   The underlying fact (local-only, no analytics) is established; translating
   it into a completed Play "Data safety" form or Apple "App Privacy" label
   is **[needs-owner-approval]** — those are console submissions, out of
   this session's scope.
4. **Analytics/crash reporting** — [repo-evidence]. No Firebase/Sentry/
   Crashlytics/Mixpanel/AdMob dependency exists. The in-repo
   `lib/features/analytics/` module is local learning-statistics UI, not a
   telemetry SDK.
5. **Third-party services** — [repo-evidence]. Runtime deps per
   `pubspec.yaml`: `audio_service`, `drift`, `flutter_riverpod`,
   `go_router`, `just_audio`, `shared_preferences`, `sqlite3_flutter_libs`,
   etc. — no ad or analytics networks. Content sources needing disclosure
   (per `docs/LICENSING.md`): Tanzil.net, QuranEnc.com, Quran.com/QUL,
   everyayah.com (streamed, not bundled), KFGQPC font.
6. **Qur'an text source attribution** — [repo-evidence]. Source: Tanzil
   Project. In-app string (`lib/features/profile/presentation/profile_screen.dart:131-132`,
   `lib/l10n/app_{vi,en,ar}.arb`) reads: *"Arabic text & translations:
   Tanzil.net · QuranEnc.com. Audio: EveryAyah.com. Font: KFGQPC."* Plain
   text only, **no hyperlink** to tanzil.net — see P1-4 below.
7. **Transliteration attribution** — [repo-evidence]. Source: Quran.com/QUL
   (Tarteel AI). Not individually named in the in-app attribution string
   (folded generically, or omitted) — see P2-2 below.
8. **Tanzil license terms** — [repo-evidence, quoted verbatim in
   `docs/LICENSING.md:43-58`]. Qur'an text: verbatim copying permitted,
   source must be indicated, a link to tanzil.net required, no
   commercial-use restriction stated. Translations: **"for non-commercial
   purposes only"** — drives `constitution/PROJ-P-005-non-commercial-translation-license.md`
   (active), which blocks monetization without separate permission or a
   source change. This document does not interpret whether current app
   plans comply — that determination belongs to legal review.
9. **QAC/MASAQ status** — [repo-evidence, DR-2026-0029]. No QAC permission
   request is recorded as sent, granted, or denied anywhere in this
   repository — the record explicitly declines to assert either way. MASAQ
   was evaluated and **rejected** on two independent grounds (structural:
   no Root/Lemma columns in the real file; licensing: the published v6 is
   CC BY-NC 3.0, not the CC BY 4.0 that DR-2026-0016 assumed). This session
   does not reopen DR-2026-0029 and does not choose an alternative Lexicon
   source.
10. **Lexicon/Flashcards deferral vs. code state** — [repo-evidence,
    DR-2026-0030]. The record declares Lexicon (F1) and Flashcards (F2)
    "not part of the v1.0 release." **[Session 104 update, re-verified
    against `origin/main` `7c60f05`]** — as of PRs #31/#32 (commits
    `6b71126`, `be28e50`), the Study-tab Flashcard shortcut is disabled
    (`onTap: null` in `lib/features/study/presentation/study_screen.dart`,
    rendering the existing "Coming soon" chip) and a top-level router
    redirect in `lib/app/router.dart` blocks direct/deep-link navigation
    into all five F2 routes (`/flashcards`, `/flashcards/add`,
    `/flashcard-decks`, `/flashcards/smart-deck`, `/flashcard-review`),
    sending them to `/study` instead. `lib/features/lexicon/` and
    `lib/features/flashcards/` screen/route definitions remain present with
    0-row datasets — per DR-2026-0030's own `reversibility: soft` field,
    this is the intended shape of the deferral, not an inconsistency.
    **This closes what was previously flagged as P0-3** (see below); no
    router or feature code was modified by this document or this session —
    the fix already landed on `main` before this re-verification.
11. **Legal review status** — [needs-external-verification]. `RELEASE_DASHBOARD.md:1152,1181-1183`
    confirms the Tanzil translation license legal review has not returned
    a result and has not evidently started. DR-2026-0029 itself states a
    legal opinion on QAC's license language "is a lawyer's call, not an
    engineer's" and that none has been sought.

## P0 blockers (block v1.0; no path forward without owner/external action)

- **P0-1** — Privacy Policy and Terms of Use do not exist. Both stores
  require a privacy policy at minimum. *Category C* (owner must author or
  commission; legal review recommended before publishing).
- **P0-2** — Tanzil translation license legal review has not returned a
  result. *Category C* (external legal review).
- **P0-3 — RESOLVED (re-verified Session 104, 2026-08-24, `origin/main`
  `7c60f05`).** Originally: Lexicon/Flashcards declared deferred from v1.0
  but remained live, reachable, and data-empty in the shipped code path.
  Closed by PRs #31/#32: the Study-tab entry is disabled and a router-level
  redirect blocks direct/deep-link access to all five F2 routes. Route and
  screen definitions intentionally remain (soft reversibility per
  DR-2026-0030) — that is not a residual gap. No further owner action
  needed on this item specifically.
- **P0-4** — iOS has zero signing/Team ID/provisioning configuration; no
  Apple Developer enrollment evidenced. *Category C* (requires macOS +
  Apple Developer Program membership).
- **P0-5** — Google Play Console registration and Play App Signing
  enrollment are unconfirmed. *Category C* (requires Play Console access).
- **P0-6** — No store listing metadata exists (descriptions, keywords,
  screenshots, feature graphic, promo assets) for either store.
  *Category B* (owner-authored marketing content; this session will not
  invent it).
- **P0-7** — Real app icon (1024×1024 master) and splash screen art are
  unconfirmed/placeholder on both platforms (Android adaptive icon
  missing, iOS `LaunchImage` is a 1×1 px placeholder).
  *Category B/C* (real design asset creation).

## P1 findings

- **P1-1** — Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) does not
  exist. *Category B* — draftable once iOS signing work begins, but
  requires Xcode/macOS integration to verify.
- **P1-2** — Data safety (Play) / App Privacy (Apple) console forms not
  yet prepared. The underlying facts are known (local-only storage, no
  analytics) — *Category B*, drafting the form answers is safe, submitting
  them is not.
- **P1-3** — Android launcher icon and adaptive icon are unverified
  against the project's own checklist admission that they're not done.
  *Category B/C*.
- **P1-4** — Tanzil's terms require "a link is made to tanzil.net"; the
  in-app attribution string is plain text with no hyperlink.
  *Category C* — this is a legal-interpretation-adjacent question (does
  the current text satisfy the term?) and a code change to
  `lib/features/profile/` strings, both outside this session's safe scope.
  Flagged for owner/legal review, not fixed here.

## P2 / P3 findings

- **P2-1** — Display name inconsistency: Android/README use `"Qur'an
  Companion"` (with apostrophe); iOS `CFBundleDisplayName` uses `"Quran
  Companion"` (without). Cosmetic, but store listings should match.
  *Category B* — owner confirms canonical spelling; this session did not
  change `ios/Runner/Info.plist` to avoid touching iOS project files
  without that confirmation.
- **P2-2** — Transliteration source (Quran.com/QUL) is not individually
  named in the in-app attribution string, unlike Tanzil/QuranEnc/EveryAyah/
  KFGQPC. *Category C* — whether QUL's terms require named attribution is
  a legal-interpretation question, not decided here.
- **P3-1** — `web/manifest.json` `theme_color`/`background_color` remain
  Flutter's default `#0175C2`. Cosmetic/design, not a factual defect.
  *Category B*.

## Category A / B / C matrix

**Category A — implemented this session** (see "Exact changes implemented"):
- Web/PWA raw `quran_companion` branding → `Qur'an Companion` in
  `web/manifest.json` and `web/index.html`.
- Added standard iOS signing-secret patterns (`*.mobileprovision`, `*.p12`,
  `*.cer`, `*.pem`) to `ios/.gitignore`, mirroring Android's existing
  `key.properties`/`*.keystore`/`*.jks` discipline, pre-emptively — no such
  files exist yet, so this is precautionary hygiene, not a fix to an
  existing leak.
- This document.

**Category B — Claude can draft/prepare, owner must review or act:**
- Store listing description/keyword drafts (not yet written — would
  require owner input on tone/claims, per Phase 3's ban on inventing
  marketing copy).
- Data safety / App Privacy form answer drafts (P1-2).
- Real app icon / splash screen art (P0-7) — Claude cannot originate final
  brand art.
- Canonical app-name spelling reconciliation across platforms (P2-1).

**Category C — cannot be completed by Claude from the repo alone:**
- Privacy Policy / Terms of Use authorship and legal review (P0-1).
- Tanzil translation license legal review (P0-2).
- ~~Lexicon/Flashcards scope-vs-code reconciliation decision (P0-3)~~ —
  resolved on `main` prior to this re-verification; see P0-3 above.
- Apple Developer Program enrollment, Team ID, provisioning, App Store
  Connect app record (P0-4).
- Google Play Console registration, Play App Signing enrollment (P0-5).
- QAC permission outreach and MASAQ-alternative sourcing decision (governed
  by DR-2026-0029; not reopened here).
- Tanzil attribution hyperlink / QUL attribution completeness — legal
  interpretation required (P1-4, P2-2).

## Owner action checklist

- [ ] Author or commission a Privacy Policy and Terms of Use; obtain legal
      review before publishing a URL.
- [ ] Commission/complete real app icon (1024×1024) and splash screen art
      for Android and iOS.
- [x] Decide: gate Lexicon/Flashcards UI before v1.0, or accept shipping
      deferred-but-reachable menu entries (P0-3). **Resolved on `main`
      (PRs #31/#32, re-verified Session 104): gated.**
- [ ] Confirm canonical app-name spelling (`Qur'an Companion` vs `Quran
      Companion`) across Android/iOS/store listings (P2-1).
- [ ] Start/complete Tanzil translation license legal review.
- [ ] Decide QAC outreach path or Lexicon-source alternative — governed by
      DR-2026-0029; do not reopen that record casually.
- [ ] Author store listing metadata (descriptions, keywords, screenshots,
      feature graphic) once assets and legal items above are resolved.
- [ ] Add a hyperlink to tanzil.net near the in-app Tanzil attribution, or
      obtain a legal opinion that current text satisfies the term (P1-4).

## External dependency checklist

- [ ] Apple Developer Program enrollment (macOS required to configure
      signing once enrolled).
- [ ] Google Play Console app registration and Play App Signing enrollment.
- [ ] Legal counsel engagement for Tanzil translation license review.
- [ ] Real device testing (both platforms) before submission.
- [ ] Graphic design resource for icons/splash/screenshots/feature graphic.

## Evidence paths referenced

`android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`,
`android/.gitignore`, `ios/Runner.xcodeproj/project.pbxproj`,
`ios/Runner/Info.plist`, `ios/.gitignore`, `web/manifest.json`,
`web/index.html`, `pubspec.yaml`, `RELEASE_DASHBOARD.md`,
`docs/release/RELEASE_PLAN_V1.md`, `RELEASE_CHECKLIST.md`,
`docs/LICENSING.md`, `docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md`,
`docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md`,
`docs/adr/DR-2026-0028-decision-record-authority-over-main.md`,
`constitution/PROJ-P-005-non-commercial-translation-license.md`,
`lib/app/router.dart`, `lib/features/profile/presentation/profile_screen.dart`,
`lib/features/study/presentation/study_screen.dart` (Session 104 addition),
`test/router_f2_guard_test.dart` (Session 104 addition).

## Exact changes implemented this session

1. `web/manifest.json` — `name`/`short_name` corrected from raw
   `"quran_companion"` to `"Qur'an Companion"`; `description` corrected
   from the unedited Flutter scaffold placeholder `"A new Flutter
   project."` to the app's own existing tagline (already used verbatim in
   `pubspec.yaml` and `README.md`): `"Ứng dụng học Kinh Qur'an chuyên
   nghiệp — người thầy đồng hành."`. `theme_color`/`background_color`
   deliberately left unchanged (design decision, not a factual defect).
2. `web/index.html` — `<title>`, `apple-mobile-web-app-title`, and the meta
   `description` corrected the same way.
3. `ios/.gitignore` — added `*.mobileprovision`, `*.p12`, `*.cer`, `*.pem`
   as precautionary ignore patterns (no such files currently exist in this
   repo; this only prevents future accidental commits).
4. This document.

No application code, ADRs, pubspec version, signing files, or credentials
were touched. No legal claim is asserted anywhere in this document beyond
what is directly quoted or cited from existing repository records.

**Session 104 note:** the three code/config items above (Session 95's
original scope) were recovered on top of current `origin/main` after being
lost from an unmerged branch; this document's F1/F2-related text was
re-verified and updated in place (see amendment note at top and the
Session 104 markers in "Legal inventory" item 10 and P0-3) to match code
that landed on `main` after Session 95 ran. No other section was changed.

---

**VERSION 1.0.0 IS NOT AUTHORIZED BY THIS DOCUMENT. THIS APP IS NOT
RELEASED.** Nothing in this document constitutes legal advice, QAC
permission, Tanzil license clearance, or store submission.
