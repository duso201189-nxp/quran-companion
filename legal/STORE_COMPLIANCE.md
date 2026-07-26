# Store compliance worksheets — Qur'an Companion

Prepared answers for the Google Play and App Store submission forms.
Every answer is derived from verified app behaviour (Sprint 34.0), not
from intent. Where an answer depends on a publisher decision rather
than on the code, it is marked `{{…}}`.

**Re-verify this file whenever cloud sync (Step 11) lands.** Almost
every "No" below becomes a "Yes" the moment the app transmits user
data.

---

## 1. Google Play — Data safety form

| Question | Answer | Basis |
|---|---|---|
| Does your app collect or share any of the required user data types? | **No** | no analytics/crash SDK; `NoopCrashReporter`; only egress is an audio GET |
| Is all user data encrypted in transit? | **Yes** | all requests are HTTPS |
| Do you provide a way to request data deletion? | **Not applicable** — no data is collected; uninstall removes everything local | |
| Data types collected | **None** | |
| Data types shared | **None** | see note below on IP address |
| Is your app's data collection independently validated? | No | |
| Does your app contain ads? | **No** | |
| Does your app have in-app purchases? | **No** | |

**Note to declare in the "Data shared" free-text, honestly:** playing a
recitation makes a direct request to `everyayah.com`, which necessarily
exposes the device IP address and the requested Surah/Ayah to that
third party. Play does not classify a plain media fetch as data
sharing, but the behaviour is disclosed in the privacy policy §4 rather
than left implicit.

## 2. Google Play — Content rating questionnaire (IARC)

Category: **Reference / Education**.

| Question | Answer |
|---|---|
| Violence, sexual content, profanity, controlled substances | None |
| User-generated content shared between users | **No** — notes are local only |
| Users can interact / communicate | **No** |
| Shares user location | **No** |
| Digital purchases | **No** |
| Gambling | **No** |
| Contains religious content | **Yes** — Qur'anic text, translations, commentary |

Expected outcome: **Everyone / PEGI 3 / ESRB Everyone**.

## 3. Google Play — other declarations

| Item | Answer |
|---|---|
| Target audience | 13+ (`{{CONFIRM}}` — the app is suitable for all ages, but declaring a child audience triggers Families Policy obligations) |
| Government app | No |
| COVID-19 contact tracing | No |
| News app | No |
| Financial features | No |
| Health apps | No |
| Data safety: account deletion URL required? | No — no accounts exist |
| Target API level | **36** (verified: `aapt2 dump badging` → `targetSdkVersion:'36'`) |
| App bundle required | Yes — Play has required AAB for new apps since Aug 2021 |

## 4. Apple — App privacy labels

| Section | Answer |
|---|---|
| Data used to track you | **None** |
| Data linked to you | **None** |
| Data not linked to you | **None** |
| Third-party SDKs collecting data | **None** |

Matches `ios/Runner/PrivacyInfo.xcprivacy`: `NSPrivacyTracking = false`,
`NSPrivacyCollectedDataTypes = []`.

## 5. Apple — Privacy manifest (required-reason APIs)

Declared in `ios/Runner/PrivacyInfo.xcprivacy`:

| API category | Reason code | Why |
|---|---|---|
| UserDefaults | `CA92.1` | read/write this app's own settings (`shared_preferences`) |
| File timestamp | `C617.1` | manage files inside the app sandbox (`path_provider`, drift) |
| Disk space | `E174.1` | check space before writing the 32.7 MB content database |

⚠️ **The file on disk is not enough.** It must be a member of the
`Runner` target's *Copy Bundle Resources* build phase, which requires
Xcode on macOS. Verification after archiving:
`unzip -l Runner.app | grep PrivacyInfo.xcprivacy` must return a hit.

## 6. Export compliance (both stores)

| Question | Answer | Basis |
|---|---|---|
| Does the app use encryption? | Yes — HTTPS only | |
| Is it exempt? | **Yes** | uses only standard OS-provided TLS; no proprietary or custom cryptography anywhere in `lib/` |
| `ITSAppUsesNonExemptEncryption` | `false` — set in `ios/Runner/Info.plist` | |
| French encryption declaration | Not required for exempt apps | |
| US ERN / CCATS | Not required for exempt apps | |

`{{PUBLISHER_CONFIRM}}` — the exemption claim is a legal declaration by
the publisher. It is factually correct for this codebase today; confirm
it again if any cryptography is ever added.

## 7. Required public URLs

| Item | Required by | Status |
|---|---|---|
| Privacy policy URL | Play **and** App Store, mandatory | `https://duso201189-nxp.github.io/quran-companion/privacy.html` — **document written, not yet hosted** |
| Terms of use URL | App Store (or Apple's standard EULA applies) | `https://duso201189-nxp.github.io/quran-companion/terms.html` — **document written, not yet hosted** |
| Support URL | App Store, mandatory | `https://duso201189-nxp.github.io/quran-companion/` |
| Marketing URL | Optional | — |
| Developer contact email | Both | `qurancompanionhq@gmail.com` |

Hosting the two documents is the smallest remaining step that unblocks
the largest number of store fields. Any static host (GitHub Pages) is
acceptable to both stores.

## 8. Store assets

| Asset | Spec | Status |
|---|---|---|
| Android launcher icon | adaptive, foreground + background, 108dp | ❌ **stock Flutter logo** |
| Android monochrome icon | for Android 13+ themed icons | ❌ missing |
| Play store icon | 512×512 PNG, 32-bit | ❌ missing |
| Play feature graphic | 1024×500 | ❌ missing |
| Play phone screenshots | 2–8, min 320px, 16:9 or 9:16 | ❌ missing |
| Play tablet screenshots | 7" and 10" | ❌ missing |
| iOS app icon | 1024×1024, no alpha | ❌ **stock Flutter logo** |
| iPhone 6.7" screenshots | 1290×2796, 3–10 | ❌ missing |
| iPhone 6.5" screenshots | 1284×2778 | ❌ missing |
| iPad 12.9" screenshots | 2048×2732 | ❌ missing |
| Short description (vi/en) | ≤80 chars | ❌ missing |
| Full description (vi/en) | ≤4000 chars | ❌ missing |

The icon is the single most visible gap: the app currently ships the
default Flutter logo on both platforms. Designing it is a branding
decision, not an engineering one — it is deliberately not invented here.
