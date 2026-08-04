# Phase 4 — Sprint B2 (Background Audio, Phase 2) — Report

**Status:** implementation complete, all four gates green, **not
committed** — awaiting review as instructed.

**Base:** `582cb04` (B1 Phase 0–1). Working tree contains B2 only, plus
two files unrelated to it (see §10).

---

## 1. Architecture decisions

### D1 — Queue population and the `skipToNext` bound are one change, not two

The sprint listed them separately. They turned out to be the same
problem: the handler tracked `_index` but had **no source of playlist
length**, which is exactly why `skipToNext` could not bound itself.

`BaseAudioHandler` already owns a `queue` `BehaviorSubject`. Publishing
the queue therefore supplies the length for free, and `skipToNext` reads
`queue.value.length` rather than a private `_length` field. **One source
of truth, so nothing can drift out of sync.** Adding a separate counter
would have been the speculative abstraction.

### D2 — The playlist is a new stream, not derived from `currentItemStream`

The handler needs to know when the playlist changes. It would have been
smaller to piggyback on `currentItemStream`, since loading a playlist
usually changes the current item.

Rejected: *usually* is not *always*. Loading a new playlist whose
`initialIndex` matches the old current index leaves the current item
unchanged while the queue changes completely. Deriving one from the
other is an implicit contract that happens to hold — the precise defect
class Sprint F2 spent its budget removing. `AyahAudioPlayer` gains
`playlist` (sync, for late subscribers) and `playlistStream`, mirroring
the `currentItem`/`currentItemStream` pair B1 already established.

### D3 — `skipToNext` at the end does nothing; `skipToPrevious` at the start clamps

Deliberately asymmetric, and it matches every media player. "Previous"
on the first track restarts it — that is the expected affordance.
"Next" on the last track doing the equivalent would restart the āyah the
user is currently listening to, which is worse than silence.

```dart
final last = queue.value.length - 1;
if (last < 0 || _index >= last) return;   // includes "playlist not loaded"
```

### D4 — Platform support is a pure function, with `isWeb` as a separate parameter

`backgroundAudioSupported({required bool isWeb, required TargetPlatform platform})`.

Getting this wrong kills the app before the first frame — `AudioService.init()`
on a platform without a native implementation throws
`MissingPluginException`. So it is a parameterised pure function rather
than an `if (Platform.isAndroid)` buried in `main()`, and a test sweeps
all six `TargetPlatform` values × web/non-web from a Windows machine.

**`isWeb` cannot be derived from `platform`.** On web,
`defaultTargetPlatform` returns the **browser's** OS — Chrome on Android
reports `TargetPlatform.android`. Reading only `platform` would make the
web build call `init()` and crash: a working build broken by a change
that has nothing to do with it. Two independent signals, so two
parameters.

### D5 — Android and iOS only

| Platform | `init()` | Why |
|---|---|---|
| Android, iOS | **yes** | B2's target; native configuration declared |
| macOS | no | `audio_service` supports it, but B2 was authorised to touch only AndroidManifest and iOS Info.plist. Enabling a platform whose configuration you cannot declare ships a runtime crash. |
| Web | no | No "background" in this sense — closing the tab ends playback. Adds browser MediaSession only, which is not B2's objective, and the web build works today without it. |
| Windows, Linux | no | `audio_service` does not support them. They keep using `JustAudioAyahPlayer` unchanged — no branch inside the player. |

### D6 — The handler stays an observer (B1's D1, preserved)

`AudioService.init()` builds `QuranAudioHandler(player)` and the return
value is intentionally unused. The app still talks to the **player**
through `ayahAudioPlayerProvider`, exactly as before B2. Notification
buttons call down into the same player the controller already observes,
so there is still **no second write path into state** — no feedback loop
of the kind `DR-2026-0019` E3 exists to remove. `AudioController` was
not modified in this sprint.

---

## 2. Platform changes, and why each was necessary

### `android/app/src/main/AndroidManifest.xml`

| Change | Why it is necessary |
|---|---|
| `xmlns:tools` on `<manifest>` | Required for the `tools:ignore` attributes below |
| `WAKE_LOCK` | Without it the CPU may sleep between audio buffers once the screen is off, so playback stutters or stops — the exact failure background audio exists to prevent |
| `FOREGROUND_SERVICE` | Playing while the app is not foregrounded **is** a foreground service on Android. Normal-level, granted at install, never prompted |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Android 14 (API 34) split the above into typed permissions and requires the type matching the service's `foregroundServiceType`. `targetSdk` is Flutter's default (≥ 34), so without it the service throws `SecurityException` at playback start |
| `<service com.ryanheise.audioservice.AudioService>` with `foregroundServiceType="mediaPlayback"` and the `MediaBrowserService` intent-filter | The service that owns playback while the activity is gone. The intent-filter makes the session discoverable to the system — and to Android Auto/Wear later at no cost now |
| `<receiver ...MediaButtonReceiver>` | Routes hardware media keys — headset pause, Bluetooth car controls — into the session. Without it those buttons do nothing while locked |
| `tools:ignore="Instantiatable"` on both | Both classes live in the plugin AAR; lint cannot see them and would fail the build |

Copied from the package's own `example/android/app/src/main/AndroidManifest.xml`
(`audio_service-0.18.19`), read from the pub cache — not from memory.

### `android/.../MainActivity.kt`

`FlutterActivity` → `AudioServiceActivity`. Needed so that tapping the
media notification reattaches the **existing** `FlutterEngine` holding
the playback session, rather than constructing a new one — which would
lose app state and orphan the running service. `AudioServiceActivity`
is `FlutterActivity` plus that attachment; no other behaviour changes.

### `ios/Runner/Info.plist`

`UIBackgroundModes: audio`. Without it iOS suspends the app seconds
after the screen locks and playback simply stops; the entitlement is
what permits `AVAudioSession` to keep running. Exactly one mode is
claimed — App Review verifies that a declared mode is genuinely used,
and audio playback is the app's own feature.

**Store commitment:** these declarations are reviewable promises about
background behaviour. Removing them after release means amending store
listings, not just editing code. That is why B1 deferred them and why
they were made only once authorised.

---

## 3. Files changed

**Dart (5 changed, 1 new)**

| File | Δ | What |
|---|---|---|
| `lib/core/audio/background_audio_support.dart` | **new** +43 | Pure platform predicate |
| `lib/core/audio/ayah_audio_player.dart` | +19 | `playlist` + `playlistStream` on the contract |
| `lib/core/audio/just_audio_player.dart` | +13 | Implements them; closes the controller on dispose |
| `lib/core/audio/quran_audio_handler.dart` | +35/−8 | Queue population; bounded `skipToNext` |
| `lib/main.dart` | +42/−4 | Conditional `AudioService.init()` |

**Platform (3 changed)** — `AndroidManifest.xml` (+58), `MainActivity.kt`
(+15/−4), `ios/Runner/Info.plist` (+10).

**Tests (2 changed, 2 new)** — `quran_audio_handler_test.dart` (+90),
`fixtures/fake_audio_player.dart` (+7), `ayah_audio_item_test.dart`
(new), `background_audio_support_test.dart` (new).

**Docs (3 changed)** — `docs/AUDIO.md` (+86/−31, incl. the device
checklist), `CHANGELOG.md`, `RELEASE_DASHBOARD.md`.

### Scope compliance

Not allowed → not touched: Basmalah 2.0, Word Address consumers, Reading
Engine, Lexicon, UI redesign. No unrelated refactoring: every changed
line traces to `AudioService.init()`, the queue, or the `skipToNext`
bound. `AudioController` and every UI file are untouched.

One test was **modified rather than added**: `'Ayah kế / Ayah trước nhảy
đúng chỉ số'` previously ran with an empty queue, because the unbounded
`skipToNext` did not need one. It now loads a playlist first. The old
version was passing *because of* the defect, so leaving it would have
kept a test that asserts the bug.

---

## 4. Risks

| # | Risk | Severity | Notes |
|---|---|---|---|
| **R1** | **Background playback unverified on hardware** | **High** | The sprint's whole objective. Compile- and manifest-verified only. See §8. |
| **R2** | Notification channel name/description are hardcoded Vietnamese, not l10n | Low–Med | `AudioServiceConfig` is built once in `main()` before any `BuildContext` or locale exists, so `AppLocalizations` is unavailable there. Consistent with the app's Vietnamese default, but an English/Arabic user sees a Vietnamese channel name in system settings. Deferred, not overlooked — see §5. |
| **R3** | `QuranAudioHandler.close()` still has no caller | Low | The handler now lives for the process lifetime under `AudioService`, so there is nothing to tear down in practice. The method is retained because it is what the tests use. |
| **R4** | Store review may question the background entitlement | Low | Exactly one mode claimed, and it is genuinely used. Standard for a Qur'an/audio app. |
| **R5** | `androidStopForegroundOnPause: true` may let the OS reclaim a long-paused session | Low | The documented trade for not pinning a foreground service while idle. Preferred: an app paused for an hour should not hold a foreground service. |

---

## 5. Deferred work

| Item | Why |
|---|---|
| **Device verification (11 items)** | No hardware. Roadmap **B4**; checklist in `docs/AUDIO.md` |
| **macOS background audio** | Native config not in B2's scope; predicate returns false today, one line to flip once configured |
| **Web MediaSession** | Not "background" in the sense B2 targets; no beta value |
| **Localised notification channel name (R2)** | Needs a locale before `runApp`, i.e. reading persisted locale from `SharedPreferences` and constructing strings without `AppLocalizations`. Real work, not a one-liner, and out of scope |
| **Android Auto / Wear** | The `MediaBrowserService` intent-filter makes it *possible*; surfacing content is a separate feature |
| **Notification artwork** | `MediaItem.artUri` unset, so the OS shows the app icon. Needs a per-surah or per-reciter image source that does not exist |

---

## 6. Test delta

| | B1 (`582cb04`) | B2 | Δ |
|---|---|---|---|
| Tests | 866 | **884** | **+18** |

- `background_audio_support_test.dart` — **+6**: Android/iOS yes;
  Windows/Linux no; macOS no (with the reason recorded); web no across
  *all* `TargetPlatform` values; total function.
- `ayah_audio_item_test.dart` — **+8**: equality, `hashCode`, list
  comparison (what `AudioController`'s retry actually relies on),
  `Set`/`Map` key use, `toString`, and the same-address/different-source
  case that distinguishes an item from its media id.
- `quran_audio_handler_test.dart` — **+4**: queue populated in reading
  order; queue replaced rather than appended; queue filled when the
  playlist was loaded *before* the handler existed; `skipToNext` bounded
  at the end and with no playlist.

---

## 7. Coverage delta

| | B1 | B2 | Δ |
|---|---|---|---|
| Filtered (CI policy, gate 80) | 81.71% | **81.86%** | **+0.15 pp** |
| Raw | 52.32% | 52.40% | +0.08 pp |

`ayah_audio_item.dart` moves from **1/11 (9%)** — the gap the B1 report
flagged — to fully exercised. `lib/main.dart` is excluded from the
filtered metric by `DR-2026-0015`, so the `init()` wiring does not
inflate the number; it is verified by the APK build instead.

---

## 8. Device verification status

**Not performed. No Android or iOS device or emulator is attached** —
`flutter devices` reports only Windows, Chrome and Edge. Stating this
plainly because the sprint's objective is "production-ready background
audio", and the one property that phrase most implies is the one thing
not observed.

### Verified by machine (facts)

| Check | Method | Result |
|---|---|---|
| Manifest merges and builds | `flutter build apk --debug` | ✅ `app-debug.apk` built |
| **Merged** manifest has all 3 permissions | Read back from `build/app/intermediates/merged_manifest/` | ✅ `WAKE_LOCK`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` |
| Merged manifest has the service, typed correctly | same | ✅ `AudioService` + `foregroundServiceType="mediaPlayback"` |
| Merged manifest has the receiver | same | ✅ `MediaButtonReceiver` |
| `MainActivity : AudioServiceActivity()` compiles | Kotlin compile in the APK build | ✅ |
| `Info.plist` valid, one mode | `plistlib` parse | ✅ `['audio']` |
| Platform gate correct on all platforms | Unit test | ✅ 6 platforms × web/non-web |
| Notification content, buttons, queue, bound | Unit tests | ✅ 884 passing |

### Assumed, not verified (must be confirmed on hardware)

Audio actually continuing after screen lock; lock-screen rendering;
notification buttons on a real MediaSession; hardware/Bluetooth media
keys; notification-tap reattaching the engine; no `SecurityException` on
Android 14+; Windows still playing with `init()` skipped.

The 11-item checklist is in `docs/AUDIO.md`. **Items 1, 5, 8 and 10 are
the ones most likely to fail** — they exercise, respectively, the
entitlement, the new bound, the activity change, and the typed
permission.

---

## 9. Recommendation

**Accept the code; do not call background audio done until B4 runs.**

The engineering is complete and the parts that can be verified without
hardware are verified — including the merged manifest, which is stronger
evidence than "the XML looks right". Both defects the B1 report raised
are closed, and closing them turned out to require each other.

Two things to schedule rather than assume:

1. **Run the 11-item checklist on one Android 14+ device and one iPhone
   before any beta build ships.** Items 1, 5, 8, 10 first. This is the
   difference between "configured correctly" and "works".
2. **Decide on R2 (Vietnamese notification channel name).** Cosmetic
   for a Vietnamese-first beta, visible in system settings for everyone
   else. Cheap to accept for beta; worth fixing before a wider release.

**Do not commit this alongside anything else** — a platform-permission
change is the commit you most want to be able to revert on its own.

---

## 10. Working tree note

Two untracked files predate B2 and are unrelated:

- `docs/adr/ADR-0008-word-addressable-architecture.md` — superseded by
  `DR-2026-0017`; withdrawal recommended, awaiting a decision.
- `docs/release/PHASE4_SPRINT_B1_REPORT.md` — the B1 report, produced
  after B1 was already pushed.

Neither is part of this sprint. Staging for B2 should exclude both.
