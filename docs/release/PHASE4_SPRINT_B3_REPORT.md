# Phase 4 — Sprint B3 (Background Audio Hardware Verification) — Report

**Status:** verification executed, **one real defect found and fixed**,
all four gates green, **not committed** — awaiting review.

---

## 0. Read this first — what "device" means here

**No physical Android or iOS hardware was available.** Verification ran
on the **Google Pixel 8 Android emulator (AVD)** that exists in this
environment. `flutter devices` reports only Windows, Chrome and Edge;
`flutter emulators` offered one AVD, which was launched and used.

That distinction is load-bearing and is applied throughout this report:

- **Verified** = observed on the emulator, with the command output quoted.
- **Not verified** = requires physical hardware or a platform that does
  not exist here.

**iOS was not verified at all.** iOS builds and simulators require
macOS; this is Windows 10. Every iOS row below is `NOT TESTED`. No iOS
claim in this report is based on observation.

An emulator is a genuine Android system image — the framework,
MediaSession, NotificationManager, ActivityManager and foreground-service
enforcement are the real implementations, which is why it found a real
bug. What it is **not** is real hardware: no Bluetooth radio, no headset
jack, no vendor OEM skin, no true power management or Doze.

---

## 1. Devices tested

| | |
|---|---|
| Device | **Google Pixel 8 emulator (AVD `Pixel_8`)**, `emulator-5554` |
| Model string | `sdk_gphone16k_x86_64` |
| Form | Emulator, x86_64, 1080×2400 |
| Physical Android device | **none available** |
| Physical/simulated iOS device | **none available** (requires macOS) |

## 2. OS versions

| | |
|---|---|
| Android release | **17** |
| API level | **37** |
| App `targetSdkVersion` | 36 |
| Build | `flutter build apk --debug`, Flutter 3.44.4 |

**Note on the "Android 14 foreground service" requirement.** The sprint
asks for Android 14 (API 34) behaviour. The only image available is API
**37** — three releases *newer*. API 34's typed-foreground-service rules
still apply at 37 (they were tightened, not relaxed), so a pass here
implies a pass at 34 for this specific rule. But **API 34 itself was not
tested**, and that is not the same statement.

---

## 3. Pass / fail matrix — Android

| # | Scenario | Result | Evidence |
|---|---|---|---|
| A1 | Screen off playback | ✅ **PASS** | `mWakefulness=Asleep`, `state=PLAYING(3)`, position advanced 5704 → 13254 ms, `isForeground=true` |
| A2 | Lock screen controls render | ✅ **PASS** | Screenshot with `KeyguardShowing=true`: card shows "Ayah 6", "Mishary Rashid Alafasy", pause + prev + next |
| A3 | Lock screen controls function | ✅ **PASS** (via media-button path) | Screen `Asleep`, keyguard up: `MEDIA_PAUSE`→`PAUSED(2)`, `MEDIA_PLAY`→`PLAYING(3)`, `MEDIA_PREVIOUS`→ Ayah 6→5. See §7 R3 on the tap caveat |
| A4 | Notification controls | ✅ **PASS** | `dumpsys notification`: channel `com.duso.qurancompanion.audio`, `MediaStyle`, actions `[0] Previous, [1] Pause, [2] Next`; shade screenshot confirms rendering |
| A5 | Bluetooth headset buttons | ⚠️ **PARTIAL** | No Bluetooth radio. The **code path** is verified — `MediaButtonReceiver` is the registered MBR and `KEYCODE_MEDIA_*` events drive the session. The **BT transport** is not |
| A6 | Wired headset buttons | ⚠️ **PARTIAL** | Same: no headset jack. Same receiver, same `KEYCODE_MEDIA_*` dispatch, verified |
| A7 | Audio focus interruption | ✅ **PASS** | Covered by A8 — an incoming call is a transient audio-focus loss |
| A8 | Phone call interruption | ✅ **PASS** | `adb emu gsm call` → `PLAYING(3)` → `PAUSED(2)` |
| A9 | Resume after interruption | ✅ **PASS** | `adb emu gsm cancel` → `PLAYING(3)`, automatic |
| A10 | Android 14 foreground service | ✅ **PASS** (on API 37) | `isForeground=true foregroundId=1124 types=0x00000002` (= `MEDIA_PLAYBACK`), `startForegroundCount=1`, **no `SecurityException`** anywhere in logcat |
| A11 | Notification tap → existing activity | ✅ **PASS** | `ActivityRecord{9254407 … t30}` **identical** before and after tap; playback uninterrupted. Confirms the `AudioServiceActivity` change |
| A12 | Queue boundary — `skipToNext` at last | ✅ **PASS** | At `active item id=6` (last of 7), `MEDIA_NEXT` → item unchanged, no crash. **This is B2's fix, confirmed on device** |
| A13 | Queue boundary — `skipToPrevious` at first | ✅ **PASS** | Stepped back to Ayah 1, one more `MEDIA_PREVIOUS` → stays Ayah 1, `PLAYING`, no crash |
| A14 | Queue population | ✅ **PASS** | `dumpsys media_session`: `queueTitle=null, size=7` for Al-Fātiḥah's 7 āyāt |
| A15 | Lock-screen metadata correctness | ✅ **PASS** | `metadata: description=Ayah 1, Mishary Rashid Alafasy, Al-Fatihah` — verifies `mediaItemFor` end-to-end |
| A16 | No crashes across session | ✅ **PASS** | No `FATAL`, `SecurityException`, `MissingPluginException` or `IndexOutOfBounds` from `com.duso.qurancompanion` |

## 4. Pass / fail matrix — iOS

| # | Scenario | Result |
|---|---|---|
| I1 | Background playback | ⛔ **NOT TESTED** |
| I2 | Lock screen controls | ⛔ **NOT TESTED** |
| I3 | Control Center | ⛔ **NOT TESTED** |
| I4 | Audio interruption | ⛔ **NOT TESTED** |
| I5 | Resume | ⛔ **NOT TESTED** |
| I6 | Notification behaviour | ⛔ **NOT TESTED** |

**Reason:** iOS toolchain requires macOS. Not a scheduling gap — it
cannot be run from this machine at all. The only iOS evidence that
exists is from B2: `Info.plist` parses and declares exactly `['audio']`.
That is a statement about a file, not about behaviour.

---

## 5. Bugs found

### BUG-B3-1 — Finishing a surah left a stuck notification and a leaked foreground service

**Severity: High** (user-visible, resource-holding, hit on every
completed surah — the single most common way a session ends).

**Reproduction (observed, not hypothetical):**

1. Open Al-Fātiḥah, tap play on āyah 1.
2. Let all 7 āyāt play to the end. Do nothing else.
3. Inspect: `adb shell dumpsys notification --noredact`
   and `adb shell dumpsys activity services com.duso.qurancompanion`.

**Observed before fix:**

- `dumpsys media_session` → `state=PlaybackState {state=PLAYING(3) …}`
  while nothing was audible, and the in-app audio bar showed ▶ (stopped).
- Notification action `[1] "Pause"` — offering to pause silence.
- `flags=ONGOING_EVENT|NO_CLEAR|FOREGROUND_SERVICE|NO_DISMISS` — the
  user **could not swipe the notification away**.
- `isForeground=true` — the app **kept holding a foreground service
  indefinitely** after playback ended.

**Root cause.** just_audio's `playing` flag means *"has been told to
play"*, not *"is producing sound"*; it stays `true` after a playlist
completes. `playbackStateFor` trusted it directly.

`AudioController` had **already** compensated for this — `audio_controller.dart:182`:

```dart
// Hết playlist (repeat off) -> hiển thị nút phát lại.
if (processing == AyahPlayerProcessing.completed && state.playing) {
  state = state.copyWith(playing: false);
}
```

So the in-app UI and the OS notification were reading the same player
and reporting **different answers**. B1's design note claimed state would
stay consistent because both observe the same player; that holds for the
player's raw signals but not for a correction only one side applied.
This is precisely the single-source-of-truth invariant `DR-2026-0019`
exists to protect.

### Observation (not fixed) — OBS-B3-2

Sending `KEYCODE_MEDIA_STOP` clears the notification and the session
(verified: 0 notification records, `state=NONE(0)`), but the **in-app
audio bar remains visible** with a replay button, because the handler's
`stop()` calls `_player.stop()` directly and does not go through
`AudioController.stop()`, which is what resets the app-side state.

Not fixed: the notification UI exposes only Previous/Play/Next — there
is no Stop button — so reaching this state requires a hardware/ADB media
STOP key. Low severity, and fixing it means adding a second write path
into controller state, which is exactly what B1's architecture
deliberately avoids. Recorded for the `DR-2026-0019` E3 work, which
restructures this properly.

---

## 6. Minimal fix applied

One condition, in the existing pure function, plus tests. No
architecture change, no refactor.

**`lib/core/audio/quran_audio_handler.dart`** — `playbackStateFor`:

```dart
final active = playing && processing != AyahPlayerProcessing.completed;
```

used for both `controls` (play vs pause button) and `playing:`. This
mirrors the rule `AudioController` already applies, so both consumers of
the player now agree.

Setting `playing: false` is also what makes `androidStopForegroundOnPause: true`
release the foreground service — so one condition fixes all three
symptoms.

### Fix verified on device (re-ran the same reproduction)

| Symptom | Before | After |
|---|---|---|
| Session state after completion | `PLAYING(3)` | **`PAUSED(2)`** |
| Notification action `[1]` | `"Pause"` | **`"Play"`** |
| `FOREGROUND_SERVICE` flag | present | **gone** |
| Foreground service held | `isForeground=true` | **released** (no `isForeground` line) |

**Partially remaining:** the notification still carries
`ONGOING_EVENT|NO_CLEAR|NO_DISMISS`, so it is not swipe-dismissible even
when paused. The foreground service — the resource problem — is
released, and the button is now correct. The user's exit is the audio
bar's ✕ (verified: clears the notification entirely, 0 records). Making
it swipeable would mean flipping `androidNotificationOngoing`, which
changes behaviour *while playing* too; that is a product decision, not a
verified-defect fix, so it is **not** in this sprint. See §7 R2.

### Tests added

Three, in `quran_audio_handler_test.dart`, group `B3 — hết playlist thì
KHÔNG còn là đang phát`, documenting the device reproduction in the
comment:

1. `completed` + `playing=true` → state reports not-playing, control is
   `MediaControl.play`, not `pause`.
2. `completed` is still reported as `AudioProcessingState.completed` —
   the fix must not swallow "finished" into "paused".
3. Normal playback (`ready` + `playing=true`) is unaffected.

---

## 7. Remaining risks

| # | Risk | Severity | Note |
|---|---|---|---|
| **R1** | **iOS is entirely unverified** | **High** | Not a single iOS scenario observed. `UIBackgroundModes` is declared and parses; whether audio survives lock, whether Control Center works, whether interruptions resume — all unknown. Requires a Mac |
| **R2** | Notification not swipe-dismissible when paused/finished | Medium | Foreground service is released and the button is correct, so the resource and correctness problems are gone. The lingering card is cosmetic. Fix = flip `androidNotificationOngoing`, which also affects the playing state — a product call |
| **R3** | Lock-screen **taps** unverified | Low | Synthetic `input tap` does not register against SystemUI's keyguard surface. Rendering verified by screenshot; the callbacks behind those buttons verified via the media-button path, which is the same `MediaSession` dispatch |
| **R4** | Bluetooth / wired transport unverified | Medium | `MediaButtonReceiver` is registered and reacts to `KEYCODE_MEDIA_*`, but no real BT or jack exists here. Car-kit and headset quirks are a classic source of field bugs |
| **R5** | Emulator ≠ hardware | Medium | No Doze, no vendor battery-management (Xiaomi/Huawei/Samsung aggressively kill background audio), no real power management. Long-session background survival is unproven |
| **R6** | API 34 not directly tested | Low | Verified on API 37, where the same typed-FGS rule is enforced more strictly. Still an inference, not an observation |
| **R7** | Only one surah exercised | Low | Al-Fātiḥah (7 āyāt). Long surahs (Al-Baqarah, 286) were not run — buffering and queue size at scale untested |

---

## 8. Verification gates

| Gate | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 366 files, **0 changed** |
| `flutter analyze --fatal-infos` | **No issues found** |
| `flutter test` | **887 passed** |
| `flutter test --coverage` | **81.86%** filtered (gate 80) |

Test delta B2 → B3: 884 → **887** (+3, the BUG-B3-1 regression tests).
Coverage unchanged at 81.86% (the fix is one line inside an
already-covered function).

Changed files: `lib/core/audio/quran_audio_handler.dart` (fix),
`test/quran_audio_handler_test.dart` (3 tests). The other files in the
working tree are B2's, still uncommitted.

---

## 9. Recommendation

**Accept the fix. Do not treat background audio as verified for
release.**

The Android picture is genuinely good: 14 of 16 scenarios pass outright,
two are partial only because the hardware transport does not exist here,
and the one real defect found is fixed and re-verified against its own
reproduction. Running this sprint was worth it — BUG-B3-1 would have
shipped, and it fires at the end of *every* completed surah.

Three things before a beta build ships:

1. **Run the iOS half.** It is 0% verified. `UIBackgroundModes` being
   present is not evidence that background audio works. This needs a Mac
   and an iPhone, and it is the largest open risk in the audio feature.
2. **Run A5/A6 on real Bluetooth and a wired headset**, and A1 on at
   least one aggressive-battery-management vendor device (Xiaomi,
   Samsung, Huawei). Those are where field bugs in background audio
   actually come from.
3. **Decide R2** — whether the media notification should be swipeable
   while paused. Cosmetic, but it is the kind of thing beta testers
   report as "the notification is stuck".

**Commit BUG-B3-1's fix together with B2**, not separately: B2 is
unreviewed and unshipped, and the fix repairs a defect B2 introduced.
Splitting them would put a known-broken commit in history for no gain.
