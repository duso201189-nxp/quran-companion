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

**Session 142 update (2026-08-28, re-verified against `origin/main`
SHA `ad505cb`).** Two classes of statement in this document had gone
stale and are corrected below **in place, with the original wording
preserved** wherever this document's supersession convention requires
historical traceability:

1. **§6 counted three outbound behaviours. There are now four.** An
   in-app Privacy Policy link shipped in Session 139 (PR #46) and
   introduces a fourth outbound destination,
   **duso201189-nxp.github.io**. See the Session 142 correction block
   in §6, and the extended owner-confirmation nuance in §4.
2. **§14's blockers are no longer accurate.** The canonical Privacy
   Policy URL no longer 404s (live HTTP 200 re-confirmed by this
   session), an in-app Privacy Policy link now exists, and the work
   §14 deferred to "Session 138" was completed in Sessions 138/139.
   §15's "no `PrivacyInfo.xcprivacy` exists yet" is also stale — the
   manifest exists and is wired into `project.pbxproj`, though it
   remains Xcode-unverified.

**Nothing here completes, submits, or pre-fills either console form,
and no legal review has occurred.** The Google Play Data safety form
and the Apple App Privacy questionnaire both remain unsubmitted. The
store-classification question raised in §4 — whether handing a URL to
the user's browser counts as "sharing" for either form's purposes —
is **UNKNOWN / LEGAL REVIEW REQUIRED** and is not resolved here.

**Session 159A update (2026-08-29) — transliteration source
attribution corrected.** Two stale references to "QUL" as the
transliteration source are corrected in place: one in §11 ("Qur'an/content
data") and one in the OWNER SUBMISSION CHECKLIST's legal-review bullet.
Both previously read *"Quran.com/QUL"* / *"Tanzil/QuranEnc/QUL/EveryAyah"*
— quoted here as historical wording, not as current statements.

**The corrected fact is source identity only.** The bundled Latin
transliteration is fetched through **Quran.com's QDC endpoint**,
`api.qurancdn.com` — `tool/fetch_transliteration.py:30`–`:34` calls
`https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}`, the
dataset's only fetch path. **QDC is not QUL**; QUL's FAQ is not the
governing terms document for this dataset and continues to govern only
datasets actually obtained through QUL. This matches the Session 147
correction in `docs/LICENSING.md` §1 and P2-2 in
`docs/release/V1_STORE_LEGAL_READINESS.md`.

**Nothing else changes.** This update does **not** assert that permission
exists, does **not** assert that permission is denied, does **not** assert
that redistribution is permitted or prohibited, does **not** declare any
dataset legally cleared, and does **not** conclude that any violation has
occurred. The licence or permission governing the QDC transliteration
remains **CHƯA XÁC ĐỊNH / UNKNOWN — COUNSEL REQUIRED**. **P1-4 and P2-2
both remain OPEN**, no checklist item's completion state is changed, no
legal review has occurred, and this document's **DRAFT ONLY / NOT
SUBMITTED** status is unchanged.

**Session 114 update (2026-08-25):** the OWNER SUBMISSION CHECKLIST's
target-audience bullet has been updated to reflect the owner's
confirmed general-audience positioning — see
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B4. No other
section of this document was changed; none of its FACT/UNKNOWN/
REQUIRES-OWNER-CONFIRMATION answers were owner-facing decisions this
session's confirmations affect.

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

**REQUIRES OWNER CONFIRMATION / LEGAL REVIEW — extended nuance for the
two `launchUrl` destinations (added Session 142, 2026-08-28).** The app
now hands two fixed third-party addresses to the user's browser via
`url_launcher`: `https://tanzil.net` (Session 134) and
`https://duso201189-nxp.github.io/quran-companion/privacy/`
(Session 139). Both are compile-time constants in
`lib/features/profile/presentation/profile_screen.dart` (lines 192 and
267-268), never built from user input, and both go through the single
`_launchExternal` helper at line 166. **The app transmits nothing
itself in either case** — it asks the operating system to open an
address, and the user's own browser then makes the request, carrying
that browser's own IP, user agent, and cookies.

Whether that hand-off counts as "sharing data with a third party" for
Google Play Data safety or Apple App Privacy purposes is **UNKNOWN**.
It is a store-policy classification question, not a code question, and
this repository's evidence cannot settle it. Two further points the
owner should carry into that determination rather than assume:

- The `duso201189-nxp.github.io` destination is a **GitHub Pages**
  address serving this app's own published Privacy Policy. The pages
  are hosted by GitHub, Inc.; the developer operates no server. It is
  a first-party *document* served from third-party *infrastructure* —
  which of those framings each console's form asks about is not
  determined here.
- Neither store's answer is inherited from the `everyayah.com` answer
  above: audio fetching is an app-initiated request, whereas both
  `launchUrl` cases are user-initiated browser hand-offs. They may or
  may not be classified alike.

**No classification is asserted by this document.** Both entries must
be read against each console's current form wording, with legal review
where the owner deems it appropriate.

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

> **CORRECTION (Session 137, 2026-08-27, re-verified against
> `origin/main` `5360f49`).** The "exactly one" framing below counts
> **Dart `HttpClient` call sites**, and on that narrow reading it is
> still right. As a *complete list of network requests* — which is what
> this section is titled and what a store form actually asks for — it
> is **incomplete**. Three outbound behaviours exist:
>
> 1. The `HttpClient` download described below
>    (`lib/core/cache/io_cache_manager.dart:12-28`). Prefetch/caching.
> 2. **Audio streaming.** Remote `https://everyayah.com` URIs are built
>    at `lib/features/quran/presentation/audio/audio_controller.dart:257,270`
>    and handed to `just_audio`, whose platform engine (ExoPlayer /
>    AVPlayer / browser `<audio>`) fetches them **itself**. That is a
>    genuine device-to-`everyayah.com` request that no Dart-level
>    `HttpClient` grep will ever show. The paragraph below is accurate
>    that these packages do not *phone home*; it should not be read as
>    saying they perform no network I/O — fetching the supplied remote
>    URL is exactly what they do.
> 3. **`launchUrl(https://tanzil.net)`** at
>    `lib/features/profile/presentation/profile_screen.dart:194`, via
>    `url_launcher` (added by PR #44, Session 134, *after* this section
>    was written). On tap it hands a third-party address to the user's
>    browser; the user's browser then contacts tanzil.net with its own
>    IP, user agent and cookies. The app sends nothing itself.
>
> All three are described in the published Privacy Policy
> (`privacy/index.md`). Answer store questions from that list, not from
> the "exactly one" sentence below. The original text is preserved
> unchanged for traceability.

> **FURTHER CORRECTION (Session 142, 2026-08-28, re-verified against
> `origin/main` `ad505cb`).** The Session 137 correction block above is
> itself now stale in one respect and is **preserved unchanged for
> traceability**: its count of **three** outbound behaviours became
> **four** when PR #46 (Session 139) added an in-app Privacy Policy
> link. Its citation of `profile_screen.dart:194` for the Tanzil
> `launchUrl` has also shifted with that edit. The current, re-verified
> list at `ad505cb` is:
>
> 1. **`HttpClient` audio download.** `httpDownloader` at
>    `lib/core/cache/io_cache_manager.dart:12-28`, fetching a URL built
>    by `buildAyahAudioUrl` (`lib/core/audio/audio_url.dart:6-14`).
>    Host: `everyayah.com`.
> 2. **Platform-engine audio streaming.** Remote URIs built at
>    `lib/features/quran/presentation/audio/audio_controller.dart:257,270`
>    and handed to `just_audio`, whose platform engine fetches them
>    itself. Host: `everyayah.com`.
> 3. **`launchUrl(https://tanzil.net)`** — URI constant at
>    `lib/features/profile/presentation/profile_screen.dart:192`,
>    dispatched through `_launchExternal` (same file, line 166) from
>    the tap handler at line 208. Host: `tanzil.net`.
> 4. **`launchUrl(https://duso201189-nxp.github.io/quran-companion/privacy/`)**
>    — **NEW in Session 139 (PR #46).** URI constant at
>    `lib/features/profile/presentation/profile_screen.dart:267-268`,
>    dispatched through the same `_launchExternal` helper from the tap
>    handler at line 277. Host: **duso201189-nxp.github.io** (GitHub
>    Pages). This is the app's own published Privacy Policy.
>
> **The complete external host set at `ad505cb` is exactly three:
> `everyayah.com`, `tanzil.net`, `duso201189-nxp.github.io`.** Verified
> by a repository-wide scan of every `http(s)://` literal under `lib/`
> and by reading all five `audio_url_template` rows out of
> `assets/database/quran.sqlite` directly (all five begin `https://` and
> all five point at `everyayah.com`). All four behaviours are described
> in the published Privacy Policy (`privacy/index.md`, "Network
> activity"). Answer store questions from **this** list. Whether
> behaviours 3 and 4 constitute "sharing" for either store's form is
> **UNKNOWN / LEGAL REVIEW REQUIRED** — see §4.

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
transliteration (**Quran.com QDC**, `api.qurancdn.com`), and the
Mushaf font (KFGQPC) are
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

> **ADDITION (Session 137, 2026-08-27, verified on `origin/main`
> `5360f49`).** This section did not record how *individual* deletion
> works, and it is materially different from what a user expects.
> **User-content deletion inside the app is a soft delete, not an
> erase.**
>
> `UserContentRepository`'s own contract says so
> (`lib/features/quran/domain/repositories/user_content_repository.dart:6`:
> "Mọi thao tác ghi là toggle/upsert idempotent, soft-delete, đánh dấu
> is_dirty"), and the implementation confirms it: removing a bookmark
> writes only `deletedAt`/`updatedAt`/`isDirty`
> (`user_content_repository_impl.dart:203-210`), and clearing a note to
> empty likewise sets `deletedAt` while **leaving the note's `content`
> column intact** (`user_content_repository_impl.dart:285-297`). The
> `deleted_at` column exists on the sync mixin precisely so a deletion
> can itself be synced (`lib/core/database/user/user_tables.dart:6,14`).
>
> Consequence for both store forms and for the policy: a user who
> deletes a personal note still has that note's text on their device
> until they clear app data or uninstall. Nothing is transmitted — the
> SyncEngine referenced in those comments does not exist on `main` —
> but "deleted in-app" must not be answered as "erased". The published
> policy (`privacy/index.md`, "Retention and deletion of your data")
> discloses this explicitly.
>
> Only the audio cache is a true delete: `IoCacheManager.clearAll()` /
> `clearReciter()` remove files from disk outright, as described below.

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

> **SUPERSEDED IN PART (Session 142, 2026-08-28).** The three blockers
> this section records below are no longer all open. The original text
> is **preserved unchanged for traceability**; read this block first.
>
> - **"the URL still returns 404" — SUPERSEDED.** The Session 137 PR
>   merged (PR #45, `0fef4f3`) and GitHub Pages rebuilt. Re-verified
>   live by this session on 2026-08-28:
>   `GET https://duso201189-nxp.github.io/quran-companion/privacy/` →
>   **HTTP 200**, `Server: GitHub.com`,
>   `Content-Type: text/html; charset=utf-8`, 0 redirects, HTTPS. The
>   instruction "do not paste this URL into either console yet" no
>   longer applies **on liveness grounds**; the other conditions in
>   this section and in the Owner Submission Checklist still do.
> - **"No in-app Privacy Policy link exists … Deferred to Session
>   138" — SUPERSEDED.** The link shipped in **Session 139 (PR #46,
>   merged at `ad505cb`)**, not Session 138. It lives in the Profile
>   screen's About section
>   (`lib/features/profile/presentation/profile_screen.dart:264-298`),
>   opens the canonical URL through `url_launcher`, is localised in
>   vi/en/ar via the `privacyPolicy` ARB key, and is covered by
>   `test/profile_screen_privacy_policy_link_test.dart`. This closes
>   the *mechanical* requirement only; it is **not** a determination
>   that Apple 5.1.1(i) or the Google Play User Data policy is
>   satisfied.
> - **"Terms of Use still does not exist" — STILL TRUE, unchanged.**
> - **"No legal review has occurred" — STILL TRUE, unchanged.** This
>   session performed none and claims none.
>
> Neither console form has been prepared, completed, or submitted, and
> this section does not authorise submitting either.

**RESOLVED IN REPOSITORY, NOT YET LIVE (Session 137, 2026-08-27).**

**Value for the form field:**
`https://duso201189-nxp.github.io/quran-companion/privacy/`

A single canonical Privacy Policy now exists at `privacy/index.md`,
effective **27 August 2026**. The earlier draft
(`docs/release/PRIVACY_POLICY_DRAFT.md`) is marked **SUPERSEDED** and
is not the policy. There is exactly one authoritative policy.

**Do not paste this URL into either console yet.** GitHub Pages for
this repository builds from `main` only (`source: {branch: "main",
path: "/"}`, legacy Jekyll build, `https_enforced: true` — verified via
the Pages API on 2026-08-27). The Session 137 PR is not merged, so the
URL still returns 404. It must be confirmed live with an actual HTTP
request returning **200** before being used in any submission.

Format requirements this URL is designed to meet, re-verified against
the **Google Play User Data policy** on 2026-08-27: active, publicly
accessible, non-geofenced, **not a PDF**, non-editable by visitors,
served over HTTPS, clearly labelled a privacy policy, and naming both
the app ("Qur'an Companion") and the developer ("DU SÔ"). That is a
format mapping, **not** a compliance determination.

**Still outstanding for this section, independent of the URL:**

- **No in-app Privacy Policy link exists.** Apple App Store Review
  Guideline 5.1.1(i) and the Google Play User Data policy each require
  the policy be linked *within the app* in addition to the store
  console field. No such route or screen exists in `lib/`. Deferred to
  **Session 138**. Neither console form should be submitted before it
  exists.
- **Terms of Use still does not exist** in any form.
- **No legal review has occurred.**

The remainder of this document is still a **DRAFT preparation aid**.
Nothing here submits, pre-fills, or completes either store form, and
publishing the policy did **not** complete Google Play's Data safety
section — that remains untouched and unsubmitted.

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
  > **SUPERSEDED (Session 142, 2026-08-28).** The bullet above is
  > stale; the original wording is kept for traceability.
  > `ios/Runner/PrivacyInfo.xcprivacy` **does exist** at `ad505cb`
  > (drafted Session 107) and **is wired into**
  > `ios/Runner.xcodeproj/project.pbxproj` (Session 109) at four
  > verified points: `PBXBuildFile` (line 10), `PBXFileReference`
  > (line 63), the Runner `PBXGroup` children list (line 124), and the
  > Runner target's `PBXResourcesBuildPhase` files list (line 235).
  > Its declared arrays are `NSPrivacyTracking = false`,
  > `NSPrivacyTrackingDomains`, `NSPrivacyCollectedDataTypes`, and
  > `NSPrivacyAccessedAPITypes` — the last three all **empty**. The
  > manifest carries its own in-file caveat that it is a repository
  > draft that **has never been Xcode-verified** (no Xcode/macOS
  > toolchain exists in this environment; no `ios/Podfile.lock`), and
  > that Xcode's archive-time manifest merge could still surface
  > Required-Reason API usage. Existence and wiring are therefore
  > closed-with-evidence; **Apple App Privacy label completion and
  > Xcode verification remain OPEN**.
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
      nuance in §4 — both the direct device-to-`everyayah.com` requests
      **and (added Session 142) the two `launchUrl` browser hand-offs
      to `tanzil.net` and `duso201189-nxp.github.io`, whose store-form
      classification is UNKNOWN** — and of
      whether the Tanzil / QuranEnc / **Quran.com QDC** / EveryAyah
      content-attribution
      requirements tracked in `docs/LICENSING.md` and
      `docs/release/V1_STORE_LEGAL_READINESS.md` (P1-4, P2-2) need to be
      resolved before or alongside store submission.
- [x] **Author an actual Privacy Policy and set its canonical URL
      (Session 137, 2026-08-27).** Written at `privacy/index.md`,
      effective 27 August 2026; §14 placeholder replaced with
      `https://duso201189-nxp.github.io/quran-companion/privacy/`; the
      old draft is marked SUPERSEDED. **Authoring is done; publication
      is not** — see the two unchecked items directly below. (`P0-1` in
      `docs/release/V1_STORE_LEGAL_READINESS.md`.)
- [x] **Canonical URL confirmed live (Session 138; re-verified
      Session 142, 2026-08-28).** `GET` over HTTPS to
      `https://duso201189-nxp.github.io/quran-companion/privacy/`
      returns **HTTP 200**, `Server: GitHub.com`, `text/html`, no
      redirects. Liveness is evidence-backed and closed. *This ticks
      liveness only — it is not permission to submit either console
      form, and says nothing about the policy's legal adequacy.*
- [x] **In-app Privacy Policy link added (Session 139, PR #46 —
      not Session 138 as originally written).** Profile → About shows
      a tappable link opening the canonical URL via `url_launcher`
      (`lib/features/profile/presentation/profile_screen.dart:264-298`),
      localised vi/en/ar (`privacyPolicy` ARB key), covered by
      `test/profile_screen_privacy_policy_link_test.dart`. *This ticks
      the mechanical existence of the link only. Whether it satisfies
      Apple 5.1.1(i) or the Google Play User Data policy is **not
      determined** — that remains part of the open legal review below.*
- [ ] **Confirm HTTPS behavior** of the live `everyayah.com` audio
      endpoint (§13) rather than relying on the documented URL template
      alone. *Partially advanced (Session 137): all five rows of the
      `reciters` table in `assets/database/quran.sqlite` were read
      directly and every `audio_url_template` begins `https://`, so
      what the app **requests** is verified. What the live server
      **does** with those requests (redirects, downgrades, TLS
      configuration) is still unverified, so this stays open.*
- [x] **Target-audience positioning stated (Session 114).** The owner
      has confirmed Qur'an Companion is a general-audience app, not
      designed or intentionally directed to children under 13 (see
      `docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B4). This
      is product positioning, not a COPPA/Apple Kids Category/Google
      Play Families Policy determination — **which specific checkbox
      or category each console's own current form requires for this
      positioning is still open** and must be confirmed against each
      store's current form wording at submission time, ideally with
      legal review.
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
      *(Session 142 note: the manifest now exists and is pbxproj-wired
      — see §15 — but is **Xcode-unverified**, so this cross-check
      stays open and must be redone after a real archive build.)*

**This document does not claim, assert, or imply that either store form
has been submitted, that a Privacy Policy exists or has been reviewed, or
that this app is cleared for store submission.** See
`docs/release/V1_STORE_LEGAL_READINESS.md` for the full, current list of
outstanding release blockers.
