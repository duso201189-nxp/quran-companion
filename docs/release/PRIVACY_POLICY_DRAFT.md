# Privacy Policy — DRAFT

**STATUS: DRAFT. NOT LEGALLY APPROVED. NOT PUBLISHED. NOT A HOSTED
POLICY. Version 1.0.0 is not authorized for release by this document.**

This document is a factual first draft of a Privacy Policy for Qur'an
Companion, prepared for owner and legal review — it is not itself a
published policy and creates no legally binding disclosure. It exists
so that an owner or legal reviewer has a concrete, evidence-linked
starting point instead of a blank page. Both app stores require a
live, hosted Privacy Policy URL before any store submission; this
document is not that URL and does not simulate one.

Every factual claim below is drawn directly from repository evidence
and is labeled **FACT** (directly observable in the codebase, with a
citation), **UNKNOWN** (repository evidence is insufficient to
answer), or **REQUIRES OWNER CONFIRMATION** (a policy choice, legal
interpretation, or piece of business information only the app's owner
can supply). Nothing below asserts legal compliance with any specific
law or store policy (GDPR, CCPA, Apple's or Google's guidelines, or
any other). This document does not claim "no data is ever collected,"
"compliant with X," or "no third party ever receives data" — see
`docs/release/STORE_PRIVACY_FORM_DRAFT.md` for the full evidence base
this draft is condensed from, including its own FACT/UNKNOWN/
REQUIRES-OWNER-CONFIRMATION labeling of each underlying claim.

Prepared by inspecting `pubspec.yaml`, `pubspec.lock`, `lib/` source
code, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`,
`docs/LICENSING.md`, and `docs/release/STORE_PRIVACY_FORM_DRAFT.md` and
`docs/release/V1_STORE_LEGAL_READINESS.md` in this repository, worktree
checked out at `origin/main` SHA `3ca83c0a596ccdd7b03a780a448b4c97aedb3759`
(Session 109, 2026-08-24).

---

## App identity

**FACT.** App name: "Qur'an Companion" (Android/README spelling) /
"Quran Companion" (iOS `CFBundleDisplayName`, no apostrophe — a known,
unresolved cross-platform inconsistency, see
`docs/release/V1_STORE_LEGAL_READINESS.md` P2-1). Package identifiers:
`com.duso.qurancompanion` on both Android
(`android/app/build.gradle.kts:19,29`) and iOS
(`ios/Runner.xcodeproj/project.pbxproj`). Current version:
`0.8.1+7` (`pubspec.yaml:4`) — pre-1.0; this document does not
authorize or imply a version bump or release.

**REQUIRES OWNER CONFIRMATION.** Legal entity/developer name, business
address, and jurisdiction of operation are not recorded anywhere in
this repository and are not invented here. A Privacy Policy
conventionally names the entity or individual responsible for the app
("Company Name, located at ...", or an individual developer's name).
This draft leaves that placeholder open:

> **[LEGAL ENTITY / DEVELOPER NAME — NOT YET PROVIDED]**, based in
> **[JURISDICTION — NOT YET PROVIDED]**.

## Scope

This policy, once finalized, would apply to the Qur'an Companion
mobile and web application across the platforms it ships on
(Android, iOS, and Web/PWA per `docs/release/V1_STORE_LEGAL_READINESS.md`
"Web/PWA readiness"). It does not apply to any other product, service,
or website the owner may operate — none other is referenced anywhere
in this repository.

## Information stored locally

**FACT.** The app stores data exclusively on the user's own device.
There is no backend server, no user account system, and no
authentication of any kind — no sign-up/login UI or SDK exists in
`lib/`, and no `firebase_auth`, `supabase_flutter`, or equivalent
dependency is declared in `pubspec.yaml`
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §1). Locally stored data,
via two on-device SQLite databases (Drift) under the OS app-support
directory, includes:

- **User-generated content**: bookmarks, highlights, personal notes,
  favorites, per-ayah reading status, study-session history, Khatm
  (completion) tracking, bookmark collections, spaced-repetition (SRS)
  card state, flashcard decks/cards, quiz results, Hifz (memorization)
  plans, and review events (`docs/release/STORE_PRIVACY_FORM_DRAFT.md`
  §3, §5).
- **App settings**: theme, locale, selected reciter, daily-goal
  targets, and reading-display preferences, stored via
  `shared_preferences` (§5).
- **Downloaded audio cache**: recitation MP3 files cached locally
  after download, named only by surah/ayah number, with no user
  identifier in the filename or content (§5).
- **Bundled content** (not user data): the Qur'an text, translations,
  reciter metadata, and (currently empty) Lexicon tables shipped as a
  read-only asset database (§5).

None of this locally stored data includes a name, email address, phone
number, government ID, health data, financial data, or biometric data
— no such field or collection point exists anywhere in `lib/`
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §2). User-authored free
text (personal notes, highlights) is entirely user-controlled and
never leaves the device except as described under "Network behavior"
below.

**FACT.** No application-level encryption is applied to this local
data (`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §13) — it relies on
whatever device-level encryption the user's OS provides by default.

## Network and audio behavior

**FACT.** Exactly one network call site exists in the entire codebase:
a direct HTTP(S) request from the user's device to `everyayah.com` to
stream or download Qur'an recitation audio
(`lib/core/cache/io_cache_manager.dart:12-28`,
`lib/core/audio/audio_url.dart:4`;
`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §6). No other network call
site exists anywhere in `lib/` (confirmed by full-repository search).

This is a direct device-to-server request, not data routed through an
app-operated backend or a bundled analytics/tracking SDK — comparable
to loading an image from a URL. As with any network request, standard
HTTP/TCP metadata (including the device's IP address) is inherently
sent to `everyayah.com`'s servers as part of that request; no
additional personal identifier is attached to it by this app's code.

**REQUIRES OWNER CONFIRMATION.** Whether this direct, unauthenticated
streaming request to a third-party audio host constitutes "sharing
data with a third party" under Google Play's and Apple's current
disclosure rules is a question of each store's own policy text, not
something this repository's code can settle — see
`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §4 for the full discussion.
This draft does not characterize the behavior as "sharing" or "not
sharing"; it describes only what is observed.

**UNKNOWN.** Whether the live `everyayah.com` endpoint is served over
HTTPS in all cases was not independently re-verified against the
production server as part of this draft; the documented URL template
reads `https://…`
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §13).

## Third-party services

**FACT.** No advertising network, no analytics SDK, and no crash
reporting SDK is integrated anywhere in this app — see "Analytics,
crash reporting, and advertising" below.

**FACT.** Content sources that supply bundled or streamed content, and
therefore warrant disclosure as external sources even though none of
them receive user data from the app (except the audio-streaming
behavior described above): Tanzil.net (Qur'an text and one English
translation), QuranEnc.com (Vietnamese translation), Quran.com/QUL —
Tarteel AI (transliteration), everyayah.com (streamed recitation
audio), and the KFGQPC Mushaf font. Full licensing terms for each are
recorded in `docs/LICENSING.md`. These are content-attribution
relationships, not data-sharing relationships — none of them is a
dependency embedded in the app that transmits user data, with the
narrow exception of the direct audio-streaming request already
described above.

## Analytics, crash reporting, and advertising

**FACT — none present.** No analytics SDK (e.g. Firebase Analytics,
Mixpanel, Amplitude), no advertising SDK (e.g. AdMob, Meta Audience
Network), and no crash-reporting SDK (e.g. Crashlytics, Sentry) is
declared in `pubspec.yaml` or referenced in `lib/`
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §7, §8, §9). The in-repo
`lib/features/analytics/` module is a **local** learning-statistics UI
(progress dashboards, streaks, goals) that reads only from the
on-device database and transmits nothing off-device — it is not a
telemetry or tracking SDK. `lib/core/logging/crash_reporter.dart`
defines an abstract interface only, with an explicit in-code note that
a real crash-reporting implementation is deferred to a later
development phase; a no-op implementation is what currently ships.

**FACT — no advertising or cross-app tracking identifier is used.** No
Android Advertising ID, Apple IDFA, device fingerprinting, or
cross-app/cross-site tracking code exists anywhere in the codebase
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §10).

**UNKNOWN.** Whether OS-level or app-store-level crash/diagnostic
reporting that Google Play and Apple's platforms may collect
automatically, independent of any code in this app, applies here —
that is a question about each platform's own infrastructure, not this
app's code (`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §9).

## Children's privacy / target audience

**REQUIRES OWNER CONFIRMATION.** This repository contains no
age-rating declaration, no COPPA/Google Play Families Policy
statement, and no target-audience decision of any kind. Whether this
app is directed at children, whether it will be listed under Apple's
Kids Category or enrolled in Google Play's Families Policy, and what
age rating it should carry are business/policy decisions for the
owner, not facts derivable from the code
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` "Owner Submission
Checklist"). This draft does not assume, imply, or default to any
answer — it must be filled in before publication:

> **[TARGET AUDIENCE / CHILDREN'S PRIVACY DECLARATION — REQUIRES OWNER
> DECISION. NOT YET DETERMINED.]**

## Data deletion and retention

**FACT.** Because there is no account and no backend server, there is
no server-side copy of any user data for an operator to retain or
delete — all data exists solely on the user's own device
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §12). Locally stored data
persists until the user uninstalls the app or clears app data via
their device's OS settings. The app additionally provides an in-app
cache-clearing feature (`IoCacheManager.clearAll()` /
`IoCacheManager.clearReciter()`,
`lib/core/cache/io_cache_manager.dart:66-79`) that removes downloaded
audio files on demand; this is a storage-management control, not a
dedicated privacy/data-deletion feature.

**FACT.** No in-app "delete my account" or "export my data" feature
exists, consistent with there being no account or server-side data to
act on. A repository-wide search (English and Vietnamese terms) found
no such feature.

## Security limitations

**FACT.** Local databases are opened via `sqlite3_flutter_libs` with
no application-level encryption layer (no `sqlcipher` or equivalent
dependency, no encryption call sites under `lib/core/database/`). Data
at rest relies entirely on the device's own OS-level encryption, which
this app does not add to. The app's one network request uses a plain
`HttpClient` GET; see "Network and audio behavior" above for its HTTPS
status.

This section describes technical fact, not a security guarantee. This
document makes no claim that the app's data handling is secure against
any particular threat model.

## Contact

**REQUIRES OWNER CONFIRMATION.** No support or privacy-contact email,
web form, or postal address is recorded anywhere in this repository.
Both a Privacy Policy and each store's submission process require a
real, monitored contact point. This draft does not invent one:

> Questions about this policy can be directed to:
> **[PRIVACY CONTACT EMAIL / FORM — NOT YET PROVIDED]**

## Effective date

**REQUIRES OWNER CONFIRMATION / not applicable until published.**

> This policy is not yet in effect. Effective date:
> **[EFFECTIVE DATE — TO BE SET AT PUBLICATION]**

## Privacy Policy URL

**REQUIRES OWNER CONFIRMATION / not yet available.** This document is
not itself hosted anywhere and has no URL. Both Google Play's Data
Safety form and Apple's App Privacy questionnaire require a live URL
before submission (already flagged as blocker P0-1 in
`docs/release/V1_STORE_LEGAL_READINESS.md`). The placeholder used
elsewhere in this repository's drafts
(`docs/release/STORE_PRIVACY_FORM_DRAFT.md` §14) applies here too:
`[PRIVACY_POLICY_URL — NOT YET CREATED]`.

## What this document does not do

- It does not assert compliance with GDPR, CCPA, COPPA, Apple's
  guidelines, Google Play's policies, or any other law or store
  policy.
- It does not constitute legal advice.
- It is not published, hosted, or linked from the app.
- It does not resolve the Tanzil translation license legal review or
  any other open legal item tracked in
  `docs/release/V1_STORE_LEGAL_READINESS.md`.
- It does not decide the app's target audience or children's-privacy
  posture.
- It does not supply a legal entity name, contact address, or
  jurisdiction — those are owner-supplied facts, not something this
  session can originate.

---

## Owner / legal review checklist

- [ ] Confirm or correct every FACT claim above against the codebase
      at the time of actual publication (this draft reflects
      `origin/main` SHA `3ca83c0a596ccdd7b03a780a448b4c97aedb3759`,
      2026-08-24 — re-verify if the code has since changed).
- [ ] Supply the legal entity/developer name, address, and
      jurisdiction.
- [ ] Decide and state the target-audience / children's-privacy
      declaration.
- [ ] Supply a real, monitored contact email or form.
- [ ] Obtain legal review of the third-party audio-streaming
      disclosure nuance (see "Network and audio behavior") against
      Google's and Apple's current policy text.
- [ ] Obtain legal review of this draft as a whole before publishing
      it anywhere.
- [ ] Publish the finalized policy at a real, hosted, stable URL, and
      set the effective date.
- [ ] Replace every `[PLACEHOLDER]` in this document before
      publication — none of them should ship as-is.
- [ ] Cross-reference the finalized policy against
      `docs/release/STORE_PRIVACY_FORM_DRAFT.md` and
      `ios/Runner/PrivacyInfo.xcprivacy` for internal consistency.
- [ ] Add an in-app route/link to the published policy (none exists
      today — no Privacy Policy screen or link is present anywhere in
      `lib/`).

**This document does not claim, assert, or imply that a Privacy
Policy has been published, reviewed by counsel, or that this app is
cleared for store submission.** See
`docs/release/V1_STORE_LEGAL_READINESS.md` for the full, current list
of outstanding release blockers.
