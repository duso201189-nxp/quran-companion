# SUPERSEDED — Privacy Policy working draft (historical record)

> # ⚠ THIS IS NOT THE PRIVACY POLICY.
>
> **This document has been SUPERSEDED and is retained only as a
> historical record of how the policy was drafted.** It is not the
> active policy, it is not authoritative, and it must not be cited,
> linked, or submitted as the app's Privacy Policy.
>
> **The one authoritative, published Privacy Policy for Qur'an
> Companion is:**
>
> ## → <https://duso201189-nxp.github.io/quran-companion/privacy/>
>
> Source file: [`privacy/index.md`](../../privacy/index.md).
> Published Session 137 (2026-08-27), effective 27 August 2026.
>
> Where this historical draft and the published policy differ, **the
> published policy governs.** Session 137 re-verified this draft's
> technical claims against `origin/main` `5360f49` and corrected two
> of them in the published policy — see "Session 137 supersession
> note" immediately below. Those corrections were **not** back-applied
> to the body of this draft, which is preserved unedited as the
> historical record it now is.

## Session 137 supersession note (2026-08-27)

This draft was superseded by the published policy at the URL above.
Two substantive corrections were made during publication, after
re-verifying every material claim against `origin/main` `5360f49`:

1. **"Exactly one network call site" was no longer accurate.** This
   draft (written at `3ca83c0a`, re-checked at `a2d0683`) states that
   exactly one network call site exists. On `5360f49` there are
   **three** distinct outbound network behaviours:
   (a) the `HttpClient` audio download in
   `lib/core/cache/io_cache_manager.dart:12-28`;
   (b) audio **streaming**, where remote `https://everyayah.com` URIs
   built at `lib/features/quran/presentation/audio/audio_controller.dart:257,270`
   are handed to the platform media engine via `just_audio` and fetched
   by it directly — a real network request that is not a Dart
   `HttpClient` call site and so was not counted by the original
   search; and
   (c) `launchUrl(https://tanzil.net)` at
   `lib/features/profile/presentation/profile_screen.dart:194`, added
   by PR #44 (Session 134) after this draft was last revised, which
   hands a third-party address to the user's browser on tap.
   The published policy describes all three.

2. **The HTTPS status of audio requests was listed as UNKNOWN; it is
   now verified for what the app requests.** All five reciter rows in
   the bundled `assets/database/quran.sqlite` `reciters` table use
   `https://everyayah.com/...` templates. The published policy states
   this as fact, while still declining to warrant how the
   independently operated everyayah.com servers actually respond.

Everything below this line is the historical draft, unchanged.

---

**HISTORICAL DRAFT TEXT FOLLOWS — SUPERSEDED, DO NOT USE.**

This document was a factual first draft of a Privacy Policy for Qur'an
Companion, prepared for owner and legal review — it was not itself a
published policy and created no legally binding disclosure. It existed
so that an owner or legal reviewer had a concrete, evidence-linked
starting point instead of a blank page. Both app stores require a
live, hosted Privacy Policy URL before any store submission; **that URL
now exists and is the link at the top of this document — it is not this
file.**

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

**Session 114 finalization (2026-08-25).** The owner-name,
jurisdiction, contact, and target-audience placeholders below have
been replaced with facts the owner confirmed in
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` (B1–B4). Before
doing so, this session re-verified — against `session112-owner-legal`
branch HEAD `a2d0683` (based on `origin/main` SHA
`99e10c8f76e4c2cc1edcd2a0b7bf81f5f0f32f03`) — that the underlying
technical facts this draft depends on still hold: exactly one network
call site (`lib/core/cache/io_cache_manager.dart:13`, to
`everyayah.com`), no analytics/crash/advertising/auth SDK declared in
`pubspec.yaml`, and `ios/Runner/PrivacyInfo.xcprivacy` now exists as a
repository draft (added Session 107/109) — still explicitly marked
**not** Xcode-verified in its own header, and not claimed as verified
here either. No other section of this document was re-derived; see
each section's own citation for the SHA it was last checked against.

**Session 128 update (2026-08-26).** The owner has supplied a
public-facing reduced locality (see "App identity" below) and resolved
B5 (iOS `CFBundleDisplayName` corrected to "Qur'an Companion"). Neither
change alters this draft's status: it remains **DRAFT, NOT PUBLISHED,
NOT LEGALLY APPROVED**. Whether a reduced locality is legally
sufficient for publisher-address disclosure is not resolved by this
update — see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` Section C item
8. No other section of this document was changed.

---

## App identity

**FACT.** App name: "Qur'an Companion", consistent across Android
(`AndroidManifest.xml` app label), README.md, and iOS
`CFBundleDisplayName` — the iOS spelling was corrected from "Quran
Companion" (no apostrophe) to match the other two platforms, per owner
decision B5 (`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md`
B5, Session 128). Package identifiers:
`com.duso.qurancompanion` on both Android
(`android/app/build.gradle.kts:19,29`) and iOS
(`ios/Runner.xcodeproj/project.pbxproj`). Current version:
`0.8.1+7` (`pubspec.yaml:4`) — pre-1.0; this document does not
authorize or imply a version bump or release.

**FACT (owner-confirmed, Session 114 — see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B1–B2).** This
app is operated by an individual, not a registered business entity:

> **DU SÔ**, based in **Vietnam**.

**FACT (owner-confirmed, Session 128 — see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B1).** A
public-facing locality has now been supplied, as a reduced/general
locality rather than a full street-level address:

> **Thị xã Tân Châu, tỉnh An Giang, Việt Nam**

This is the owner's chosen public contact locality — not the owner's
full residential address, which is held privately outside this
document and this repository. This draft does not claim that a
reduced locality of this kind is legally sufficient to satisfy any
store's or jurisdiction's publisher-address disclosure requirement;
whether it is remains **LEGAL REVIEW REQUIRED** (see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` Section C, item
8).

Naming an individual and a country here is a business/contact fact,
not a legal-jurisdiction compliance determination — see "Which
privacy-law regime(s) apply" in
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` Section C for
the still-open question of which privacy-law regime(s) actually govern
this app given where its users are located.

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

**FACT (owner-confirmed, Session 114 — see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B4).**

> Qur'an Companion is a general-audience application. It is not
> designed or intentionally directed to children under 13.

This states the owner's product positioning and design intent only.
It is **not** a statement that children are prohibited from using the
app, and it is **not** a claim of compliance with COPPA, Vietnam's
PDPD, or any other law's age-related requirements, nor a determination
of Apple Kids Category or Google Play Families Policy status.

**LEGAL REVIEW REQUIRED.** Whether this stated positioning satisfies
COPPA, Apple's Kids Category rules, Google Play's Families Policy, or
any other applicable regime's specific test is not determined by this
draft — see Section C, item 7 of
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md`. No age rating
or Kids Category/Families Policy enrollment decision has been made.

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

**FACT (owner-confirmed, Session 114 — see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B3).**

> Questions about this policy can be directed to:
> **qurancompanionhq@gmail.com**

This is the contact point the owner has stated as monitored. This
draft does not independently verify that the mailbox is actively
monitored, and does not supply a postal address — see "App identity"
above for the still-open mailing-address item.

## Effective date

> **SUPERSEDED (Session 137).** Resolved at publication. The published
> policy's effective date is **27 August 2026**. The historical text
> below is retained unchanged.

**REQUIRES OWNER CONFIRMATION / not applicable until published.**

> This policy is not yet in effect. Effective date:
> **[EFFECTIVE DATE — TO BE SET AT PUBLICATION]**

## Privacy Policy URL

> **SUPERSEDED (Session 137).** Resolved at publication. The canonical
> published Privacy Policy URL is
> **<https://duso201189-nxp.github.io/quran-companion/privacy/>**
> (source: [`privacy/index.md`](../../privacy/index.md)). The
> historical text below is retained unchanged.

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
- It does not reach any legal conclusion about whether the stated
  target-audience positioning satisfies COPPA, Apple Kids Category,
  Google Play Families Policy, or any other regime's specific test —
  see "Children's privacy / target audience" above.
- It does not claim that the reduced public locality supplied in
  Session 128 is legally sufficient to satisfy any store's or
  jurisdiction's publisher-address disclosure requirement — see
  `docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` Section C
  item 8.

---

## Owner / legal review checklist

- [ ] Confirm or correct every FACT claim above against the codebase
      at the time of actual publication (this draft reflects
      `origin/main` SHA `3ca83c0a596ccdd7b03a780a448b4c97aedb3759`,
      2026-08-24, technical facts re-verified against
      `session112-owner-legal` HEAD `a2d0683` on 2026-08-25 — re-verify
      again if the code has since changed).
- [x] Supply the legal entity/developer name and jurisdiction. **Done
      (Session 114): DU SÔ, Vietnam.**
- [x] Supply a public-facing locality. **Done (Session 128): "Thị xã
      Tân Châu, tỉnh An Giang, Việt Nam" (reduced/general locality, not
      a full street-level address).** Whether this satisfies any
      store's or jurisdiction's specific publisher-address disclosure
      requirement is **not** determined by this draft — remains open,
      see the legal-review items below.
- [x] Decide and state the target-audience / children's-privacy
      positioning. **Done (Session 114): general audience, not
      intentionally directed to children under 13.** Whether this
      positioning satisfies any specific regime's legal test remains
      open — see "Children's privacy / target audience" above.
- [x] Supply a real, monitored contact email or form. **Done (Session
      114): qurancompanionhq@gmail.com.**
- [ ] Obtain legal review of the third-party audio-streaming
      disclosure nuance (see "Network and audio behavior") against
      Google's and Apple's current policy text.
- [ ] Obtain legal review of which privacy-law regime(s) apply given
      the stated Vietnam jurisdiction and the app's actual user
      locations.
- [ ] Obtain legal review of whether the reduced public locality
      supplied in Session 128 satisfies any store's or jurisdiction's
      publisher-address disclosure requirement, or whether a full
      address must be published instead.
- [ ] Obtain legal review of whether the stated target-audience
      positioning satisfies COPPA / Apple Kids Category / Google Play
      Families Policy requirements.
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
