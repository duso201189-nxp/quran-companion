# Store Privacy Form Draft — Google Play Data Safety / Apple App Privacy

**Status: DRAFT ONLY. NOT SUBMITTED. NOT A COMPLETED STORE FORM.**

This document is a factual preparation aid for two future console submissions:
Google Play's "Data safety" form and Apple's "App Privacy" ("nutrition
label") questionnaire in App Store Connect. It does **not** submit,
pre-fill, or lock in either form — both are filled out directly in their
respective consoles, by whoever holds that account access, at submission
time. Nothing in this document constitutes legal advice, a completed
disclosure, or evidence that either store's requirements have been
satisfied.

This document was prepared by inspecting `pubspec.yaml`, `lib/` source
code, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`,
and existing release-readiness documentation
(`docs/release/V1_STORE_LEGAL_READINESS.md`, `docs/LICENSING.md`,
`constitution/PROJ-P-001-offline-first.md`,
`constitution/PROJ-P-004-rls-mandatory-for-cloud-sync.md`) in this
repository, worktree checked out at `origin/main` SHA `3d5da90`. Every
answer below is labeled **FACT** (directly observable in the repository,
with citation), **UNKNOWN** (repository evidence is insufficient to
answer), or **REQUIRES OWNER CONFIRMATION** (a policy interpretation or a
choice only the account holder/owner can make). Nothing is inferred as
"no data collection" merely from the absence of an SDK — each answer below
is backed by an actual code-behavior citation, not a dependency-list
default.

---

## 1. Does the app have user accounts?

**FACT — No.** No sign-up, login, or authentication UI or SDK exists
anywhere in `lib/`. No `firebase_auth`, `supabase_flutter`, or equivalent
dependency is declared in `pubspec.yaml`.

- `lib/core/env/app_env.dart:36-39` — Supabase URL/anon-key constants are
  present only as **commented-out** placeholders, annotated "to be added
  at steps 10-11" (a future roadmap step, not implemented).
- `lib/core/database/user/user_tables.dart:12` — every user-data table
  carries a `userId` column, but it is **nullable**, with an in-code
  comment stating it is null until a (not-yet-built) login/sync feature
  is added.

**Consequence for the form:** both stores' account-related questions
("Does your app require account creation?") should be answered **No** as
of this codebase revision.

## 2. What personal data does the app collect?

**FACT — None is collected or transmitted.** No form, field, or SDK call
site in `lib/` gathers name, email, phone number, address, government ID,
health data, financial data, biometric data, or any other
directly-identifying personal data.

- No network call site other than the audio-download client (§9, §11)
  exists anywhere in `lib/` (confirmed by full-repository search for
  `HttpClient`, `Dio`, `WebSocket`, and `http`/`https` literals).
- The only user-supplied content is local: notes, highlights, bookmarks,
  quiz answers, reading position, reciter choice, theme/locale
  preference — all written to on-device storage only (§5).

**Consequence for the form:** Play's "Does your app collect or share any
of the required user data types?" and Apple's per-category data
questions should each be answered based on the **local-storage-only**
facts in §5 below — the app does not transmit any of that data off the
device.

## 3. What personal data does the app store?

**FACT.** All storage is on-device (see §5 for full table/key inventory):
bookmarks, highlights, personal notes, favorites, per-ayah reading
status, study-session history, Khatm (completion) tracking, bookmark
collections, spaced-repetition (SRS) card state, flashcard decks/cards,
quiz results, Hifz (memorization) plans, review events, and app settings
(theme, locale, selected reciter, daily-goal targets, reading-display
preferences).

None of this is inherently identifying on its own (no name/email/phone is
collected to attach to it), but personal notes or highlights could
contain user-authored free text, which the user controls entirely and
which never leaves the device (§9).

## 4. Is any data shared with third parties?

**FACT — No app-operated data sharing.** There is no backend server this
app sends data to, and no third-party SDK embedded that would receive
data from the app (§7 confirms no analytics/ads SDKs).

**REQUIRES OWNER CONFIRMATION — one nuance for the Play/Apple forms
specifically:** the app's audio player makes a direct HTTP request from
the user's device to `everyayah.com` to stream/download Qur'an
recitation audio (§9, §11). This is not data routed through an
app-operated backend or a bundled SDK — it is a direct device-to-server
request, analogous to loading an image from a URL. Both stores have
specific (and store-specific) rules for whether a direct, unauthenticated
GET request like this counts as "sharing data with a third party" for
disclosure purposes, and those rules are a matter of each store's own
current policy text, not something this repository's code can settle.
The owner (or whoever completes the console form) should read Google's
and Apple's current guidance on this point before answering the
"third-party sharing" question for the audio-streaming behavior
specifically. No personal identifier is included in that request beyond
standard HTTP/TCP metadata (§9) — but IP address and standard request
headers are sent to `everyayah.com` as an inherent property of any
network request, exactly as they would be to any web server.

## 5. Local-only data — full inventory

**FACT.** Two separate on-device SQLite databases (via Drift), opened
under `path_provider`'s app-support directory
(`lib/core/database/connection/native.dart:59`,
`lib/core/database/user/connection_native.dart:10`):

**Content database** (`assets/database/quran.sqlite`, bundled read-only
asset, `pubspec.yaml:49-50`) — Qur'an text, translations, reciter
metadata; not user data. Tables: `surahs`, `ayahs`, `translation_sources`,
`translations`, `reciters`, `meta`, plus 8 Lexicon-related tables that
ship with 0 rows (`roots`, `lemmas`, `lexemes`, `word_instances`,
`grammar_features`, `phrases`, `phrase_word_instances`,
`lexicon_relations` — see `docs/LICENSING.md:222-226`; unrelated to this
document's scope, cited only for completeness).

**User database** (device-local, user-generated) —
`lib/core/database/user/user_tables.dart`: `bookmarks`, `highlights`,
`notes`, `favorites`, `ayah_statuses`, `study_sessions`, `khatm_cycles`,
`bookmark_collections`, `srs_cards`, `flashcard_decks`, `flashcards`,
`quiz_results`, `hifz_plans`, `review_events`. Every table carries
`SyncColumns` (`id`, nullable `userId`, `updatedAt`, `deletedAt`,
`isDirty`) — schema-level readiness for a future sync feature, with no
sync logic implemented (§12).

**`shared_preferences` keys** (all local device settings, no personal
data): `settings.theme_mode`, `settings.locale`,
`boundary.surah.pending` (+ per-surah keys),
`stats.reading_days` (+ per-day minute keys),
`settings.daily_goal.minutes`, `settings.daily_goal.ayahs`,
`audio.reciter`, `reading.last_surah_id`, `reading.recent_surahs` (+
per-surah position keys), `retention_seeding.activated_at_ms`, and
reading-display preference keys in
`lib/features/quran/presentation/reading/reading_settings.dart:65-124`.

**Downloaded audio cache** — MP3 files cached under the app-support
directory, named only by surah/ayah number
(`lib/core/audio/audio_url.dart:16-19`), with no user identifier in the
filename or file content.

## 6. Network requests — complete list

**FACT.** Exactly one network call site exists in the entire `lib/`
tree: `lib/core/cache/io_cache_manager.dart:12-28`, function
`httpDownloader`, using `dart:io HttpClient` to download an MP3 file from
a URL built by `buildAyahAudioUrl` (`lib/core/audio/audio_url.dart:6-14`).
The only external domain referenced anywhere in `lib/` is
`everyayah.com` (`lib/core/audio/audio_url.dart:4`,
`lib/core/database/tables/content_tables.dart:126`). The base URL is
technically data-driven from the `reciters.audioUrlTemplate` column in
the bundled content database rather than hardcoded, but the shipped seed
data points to `everyayah.com`.

No other package performs network I/O: `just_audio`/`just_audio_windows`
consume the URL the app supplies but do not independently phone home;
every other runtime dependency (`drift`, `flutter_riverpod`, `go_router`,
`intl`, `package_info_plus`, `path`, `path_provider`,
`scrollable_positioned_list`, `shared_preferences`,
`sqlite3_flutter_libs`, `uuid`) is local-only functionality with no
network capability.

**UNKNOWN:** whether any of these plugins perform their own
platform-native background telemetry beneath the Dart API surface (e.g.,
crash/ANR signals collected by the Android/iOS OS or app-store
infrastructure itself, independent of any code in this app). That is
outside what static inspection of this repository's Dart source can
verify — see §7 and the Owner Submission Checklist.

## 7. Analytics

**FACT — Not present.** No analytics SDK (Firebase Analytics, Mixpanel,
Amplitude, or similar) is declared in `pubspec.yaml` or referenced in
`lib/`. `lib/features/analytics/` is a **local** learning-statistics UI
module (progress dashboards, goals, streak displays) that reads only
from the on-device database — it is not a telemetry/tracking SDK and
sends nothing off-device. (Also independently confirmed in
`docs/release/V1_STORE_LEGAL_READINESS.md:141-144`.)

## 8. Advertising

**FACT — Not present.** No ad SDK (Google Mobile Ads/AdMob, Facebook
Audience Network, or similar) is declared in `pubspec.yaml`,
`android/app/build.gradle.kts`, or `ios/Runner`. No ad-related code
exists in `lib/`.

## 9. Crash reporting

**FACT — Not present (deliberately deferred).**
`lib/core/logging/crash_reporter.dart` defines an **abstract interface
only**, with an in-code comment stating a real implementation
(Crashlytics/Sentry) is deferred to a later sprint "after CLOUD SDK is
approved," and that this phase explicitly forbids adding one. A
`lib/core/logging/noop_crash_reporter.dart` no-op implementation exists,
confirming no real crash-reporting SDK is wired in. An unused
`crashReportingEnabled` flag exists in `lib/core/env/app_env.dart:29-34`,
defaulted `false` and not connected to any actual SDK.

**UNKNOWN:** whether the OS-level or store-level crash reporting that
Google Play Console and App Store Connect provide automatically for all
apps (independent of any in-app SDK) counts as "crash data collection"
for either form's purposes — this is a question about each store's own
form semantics, not this app's code, and should be confirmed against
each store's current help documentation at submission time.

## 10. Tracking (cross-app/cross-site identifiers, advertising ID, etc.)

**FACT — Not present.** No advertising identifier (Android
Advertising ID / Apple IDFA), fingerprinting, or cross-app tracking code
exists anywhere in `lib/`, `android/`, or `ios/`. No SDK capable of such
tracking is declared (§7, §8). `package_info_plus` reads the app's own
local version/build metadata only (`lib/` usage confirmed
network-free) — it does not read or transmit a device identifier.

**Consequence for the form:** Apple's "Data Used to Track You" section
and Play's "Does your app use an advertising ID?" question should both
be answerable **No** as of this codebase revision, subject to the Owner
Submission Checklist's re-verification step before actual submission.

## 11. Qur'an/content data

**FACT.** Qur'an text, translations (Tanzil.net, QuranEnc.com),
transliteration (Quran.com/QUL), and the Mushaf font (KFGQPC) are
**bundled** in the app (`assets/database/quran.sqlite`,
`pubspec.yaml:49-63`) — not fetched at runtime, not personal data.
Recitation audio (EveryAyah.com, 5 reciters) is **streamed/downloaded on
demand**, not bundled (`docs/LICENSING.md:140-144`), and is cached
locally after download for offline reuse (§5, §6). This is
content-licensing territory, governed by `docs/LICENSING.md` and
`docs/adr/DR-2026-0029`/`DR-2026-0030` for the Lexicon-specific
subset — this document does not restate or revisit those decisions, and
raises Qur'an content sourcing here only insofar as it is the one thing
the app's single network call site fetches.

## 12. Data retention / deletion

**FACT.** There is no backend server and no account (§1, §4), so there is
no server-side data for the app operator to retain or delete — all
retention is exactly what stays on the user's own device. Locally stored
data (§5) persists until the user uninstalls the app, clears app data via
OS settings, or (for cached audio specifically) uses the in-app cache
clear feature: `IoCacheManager.clearAll()` /
`IoCacheManager.clearReciter()`
(`lib/core/cache/io_cache_manager.dart:66-79`), which deletes downloaded
audio files from local storage. That feature is a **storage-management**
control, not a privacy/data-deletion feature per se, but it does give the
user a way to remove downloaded content on demand.

**FACT — no in-app "delete account" or "export my data" feature exists**,
consistent with there being no account or server-side data to act on
(§1, §4). A repository-wide search for such functionality (English and
Vietnamese terms) found no matching feature/UI code — only unrelated
Drift-generated row-delete helper methods.

## 13. Security

**FACT.** The on-device databases are opened via `sqlite3_flutter_libs`
with no application-level encryption layer: no `sqlcipher` or equivalent
encryption dependency is declared in `pubspec.yaml`, and no encryption
call sites were found under `lib/core/database/`. Data at rest therefore
relies on whatever OS-level device encryption (Android/iOS full-disk or
file-based encryption) the user's device provides by default — the app
does not add its own encryption-at-rest layer on top of that.

The one network request the app makes (§6) is a plain `HttpClient` GET to
`everyayah.com`; **UNKNOWN** whether that endpoint is served over HTTPS
in all cases (the URL template in the bundled seed data currently reads
`https://…`, per `lib/core/audio/audio_url.dart:4`'s doc comment, which
would mean the connection is TLS-encrypted in transit — this is a
repository-evidence-supported fact for the *documented* template, but
was not independently re-verified against the live `everyayah.com`
server's actual behavior as part of this audit, so it is listed here
as requiring confirmation rather than asserted outright).

## 14. Privacy Policy URL

**REQUIRES OWNER CONFIRMATION / not yet available.** No Privacy Policy or
Terms of Use exists in this repository in any form — no file, no in-app
route, no hosted URL
(`docs/release/V1_STORE_LEGAL_READINESS.md:56-57,130-133,200-202`,
already flagged there as blocker **P0-1**). Both Google Play and Apple
require a live, hosted Privacy Policy URL before a Data Safety / App
Privacy form can be submitted. This document does not author that
policy, does not propose placeholder text for it, and does not assert
one exists.

**Placeholder for the form field:** `[PRIVACY_POLICY_URL — NOT YET
CREATED]`. This must be replaced with a real, hosted URL before either
console form is submitted.

## 15. Platform-specific differences

**FACT.**

- **Android** (`android/app/src/main/AndroidManifest.xml`) declares:
  `INTERNET` (line 5), `ACCESS_NETWORK_STATE` (line 6), `WAKE_LOCK`
  (line 24), `FOREGROUND_SERVICE` (line 25),
  `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (line 26). All five exist solely to
  support background audio playback via the `audio_service` plugin; none
  are runtime/dangerous-level permissions requiring a user prompt. No
  camera, location, microphone, contacts, or storage permission is
  declared.
- **iOS** (`ios/Runner/Info.plist`) declares **no** `NS*UsageDescription`
  keys at all (no camera/location/microphone/photo-library/etc.). The
  only privacy-adjacent entry is `UIBackgroundModes = [audio]`, with an
  in-file comment stating explicitly: background audio playback only, no
  location, no VoIP, no background fetch.
- **No `PrivacyInfo.xcprivacy` (Apple Privacy Manifest) exists yet** —
  see Phase 4 of this session's work,
  `docs/release/V1_STORE_LEGAL_READINESS.md:229-231` (P1-1).
- Both platforms therefore present the **same** underlying data profile
  (no accounts, no analytics/ads/crash SDK, one audio-streaming network
  call, local-only storage) — there is no known platform-specific
  divergence in what data is collected, only in how each store's own
  form vocabulary categorizes it.

## 16. Cloud sync — explicitly not a current-state answer

**FACT, stated to prevent a common form-answer mistake:** the codebase
contains schema-level *preparation* for a future Supabase-backed cloud
sync feature — nullable `userId` and sync-tracking columns on every user
table (§1, §5), and commented-out Supabase config constants
(`lib/core/env/app_env.dart:36-39`) — but **no sync logic is implemented
anywhere in this codebase revision**.
`constitution/PROJ-P-004-rls-mandatory-for-cloud-sync.md:14-31` states
outright that this is "not yet applicable in practice — Supabase
integration hasn't started." **Neither store form should be answered as
if cloud sync is a current data-collection or data-sharing practice.**
If either form has an optional field for describing planned/future data
practices, the owner may choose to note this roadmap item there — that
choice, and its wording, is left to the owner, not decided here.

---

## OWNER SUBMISSION CHECKLIST

This document prepares form *answers*; it does not submit anything. The
following steps remain, all outside this session's authority:

- [ ] **Owner review** of every FACT/UNKNOWN/REQUIRES-OWNER-CONFIRMATION
      answer above against the actual code at the time of submission
      (this draft reflects `origin/main` SHA `3d5da90` as of
      2026-08-24 — re-verify if the codebase has since changed).
- [ ] **Legal review**, where appropriate, of the third-party-sharing
      nuance in §4 (direct device-to-`everyayah.com` requests) and of
      whether the Tanzil/QuranEnc/QUL/EveryAyah content-attribution
      requirements tracked in `docs/LICENSING.md` and
      `docs/release/V1_STORE_LEGAL_READINESS.md` (P1-4, P2-2) need to be
      resolved before or alongside store submission.
- [ ] **Author and publish an actual Privacy Policy** at a real, hosted
      URL, and replace the §14 placeholder with it. (`P0-1` in
      `docs/release/V1_STORE_LEGAL_READINESS.md`.)
- [ ] **Confirm HTTPS behavior** of the live `everyayah.com` audio
      endpoint (§13) rather than relying on the documented URL template
      alone.
- [ ] **Decide the app's target-audience / children's-privacy
      declaration** (e.g., Google Play Families Policy, Apple's Kids
      Category, COPPA applicability) — not addressed anywhere in this
      document; requires an owner policy decision, not a code fact.
- [ ] **Complete and submit the Google Play Console "Data safety" form**
      using these answers as a starting draft, re-verified in the
      console's own current question wording (which changes over time
      independent of this document).
- [ ] **Complete and submit the Apple App Store Connect "App Privacy"
      questionnaire** using these answers as a starting draft, likewise
      re-verified against Apple's current question wording.
- [ ] Cross-check both submissions against the final
      `ios/Runner/PrivacyInfo.xcprivacy` manifest (Phase 4 of this
      session, if produced) for internal consistency before submitting.

**This document does not claim, assert, or imply that either store form
has been submitted, that a Privacy Policy exists or has been reviewed, or
that this app is cleared for store submission.** See
`docs/release/V1_STORE_LEGAL_READINESS.md` for the full, current list of
outstanding release blockers.
