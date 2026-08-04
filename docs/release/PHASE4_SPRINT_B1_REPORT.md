# Phase 4 — Sprint B1 (Background Audio, Phase 0–1) — Report

**Status:** implementation complete and already on `main` as `582cb04`,
pushed. This report is the sprint's remaining deliverable; it was not
produced at commit time.

**Verified at:** `582cb040a35fb3cf0a3fd9ee2bc078742a0bb4ca`, working tree
clean apart from the untracked `docs/adr/ADR-0008-word-addressable-architecture.md`.

Nothing was re-implemented to produce this report. The code was read,
the scope boundaries were checked against the actual diff, and all four
gates were re-run on the current HEAD.

---

## 1. Objective and how it was met

Introduce `audio_service` as the long-term background-playback
foundation **while preserving current playback behaviour**.

Behaviour is preserved in the strongest available sense: `audio_service`
is a dependency and a fully-built handler exists, but nothing calls
`AudioService.init()`. Audio plays while the app is open, exactly as
before. There is no code path in which a user can observe a difference.

---

## 2. Architecture decisions

### D1 — The handler wraps the player; it is not the player

The idiomatic `audio_service` shape is *"the handler **is** the
player"* — `BaseAudioHandler` owns a `just_audio` instance and the app
talks only to the handler. `QuranAudioHandler` deliberately does not do
that. `AyahAudioPlayer` remains the single playback abstraction; the
handler only **observes** its streams and **forwards** notification
button presses back into it.

Two things follow, and both are why the decision is right:

- **Windows and Linux need no branch.** `audio_service` supports
  Android/iOS/macOS/web only. Under the idiomatic shape, the two
  unsupported desktop platforms would need a subclass or a conditional
  player. Under this shape they keep using `JustAudioAyahPlayer`
  unchanged and never learn that `audio_service` exists.
- **`AudioController` needed no change to its state machine.**
  Notification buttons call straight down into the player, which the
  controller already observes. There is no second write path into
  state — so no feedback loop of the kind `DR-2026-0019` E3 exists to
  remove. Adding one here would have created, in a new subsystem, the
  exact defect class Phase 4 is dismantling elsewhere.

### D2 — Playlist items carry identity, not just a URL

`AyahAudioPlayer.setPlaylist` took `List<Uri>`. Enough to play; not
enough to play *in the background*. Android and iOS media notifications
require a title, an album, a performer — and once the screen is locked,
the notification **is** the entire remaining interface.

`AyahAudioItem` adds those fields. Its identity is its `QuranAddress`
(Sprint F0), **not** its URL: URLs change with the reciter, addresses do
not, so a URL-keyed item would give one āyah two identities the moment
someone switches qāriʾ. This is the first place F0's investment pays
off outside the reading screen — playlist item, OS notification, and
āyah card now name a position the same way.

### D3 — The OS-facing projection is two pure functions

`mediaItemFor` and `playbackStateFor` are top-level pure functions, not
private methods. They are the only part of B1 that decides what a user
*reads* on a locked screen, and pulling them out of the handler makes
that decision testable with no device, no platform channel, and no
`audio_service` binding. 93% of the handler file is covered as a direct
result.

### D4 — The surah name is resolved inside the controller

`_resolveSurahName` does one keyed repository read rather than taking
the name as a parameter. A caller that forgot the argument would ship a
lock screen with missing text — a defect nobody sees until they are
holding a real phone. The read sits in an already-async path that
already shows a loading state, so it costs nothing perceptible, and a
missing name degrades to the address (`"2"`) rather than blocking
playback.

### D5 — Stop before platform configuration

`AudioService.init()` is **not** called; `AndroidManifest.xml` and
`Info.plist` are untouched. This is not timidity. Calling `init()`
without the manifest service declaration is a **runtime crash on
Android** — wiring early would not be "partially done", it would be
broken. See §5.

---

## 3. Files changed (`582cb04` — 14 files, +827 / −35)

| File | Δ | What |
|---|---|---|
| `lib/core/audio/ayah_audio_item.dart` | **new**, +55 | Playlist item with `QuranAddress` identity + OS metadata |
| `lib/core/audio/quran_audio_handler.dart` | **new**, +164 | Observer/forwarder handler + the two pure projections |
| `lib/core/audio/ayah_audio_player.dart` | +17/−? | `setPlaylist` signature; `currentItem`/`currentItemStream` |
| `lib/core/audio/just_audio_player.dart` | +37/−? | Implements the widened contract |
| `lib/features/quran/presentation/audio/audio_controller.dart` | +46/−? | `List<Uri>` → `List<AyahAudioItem>`; `_resolveSurahName` |
| `test/quran_audio_handler_test.dart` | **new**, +242 | Handler + projection tests |
| `test/audio_controller_test.dart` | +49/−? | Updated for the new playlist type |
| `test/fixtures/fake_audio_player.dart` | +23/−? | Fake widened to the new contract |
| `pubspec.yaml` | +9 | `audio_service: ^0.18.19`; Dart floor 3.4 → **3.6** |
| `pubspec.lock` | +80 | Resolved transitive deps |
| `docs/AUDIO.md` | +56 | Phase 0–1 recorded against the existing plan |
| `CHANGELOG.md` / `RELEASE_DASHBOARD.md` | +80 | Release tracking |
| `macos/Flutter/GeneratedPluginRegistrant.swift` | +4 | **Generated** by `flutter pub get`, not hand-edited |

### Scope compliance — checked against the diff, not the commit message

| Not allowed | Result |
|---|---|
| AndroidManifest changes | ✅ `git show --stat 582cb04 -- android/` → empty |
| Info.plist changes | ✅ `git show --stat 582cb04 -- ios/` → empty |
| Foreground service permissions | ✅ none declared anywhere |
| Play Store configuration | ✅ untouched |
| Basmalah 2.0 / Reading Engine / Word Address / Lexicon | ✅ untouched |
| Unrelated refactoring | ✅ every changed line traces to the playlist-type widening |

One item needs stating rather than ticking: `macos/Flutter/GeneratedPluginRegistrant.swift`
is a platform file. It was **generated** by `flutter pub get` registering
the new plugin, not authored. It is not a configuration commitment and
regenerates deterministically.

---

## 4. Risks

### R1 — `skipToNext` is unbounded while `skipToPrevious` is bounded (real, latent)

`QuranAudioHandler.skipToPrevious` clamps at 0, with a comment
explaining exactly why: *the OS still draws the button, the user can
still press it.* `skipToNext` has **no upper bound**:

```dart
Future<void> skipToNext() => _player.seekToIndex(_index + 1);
```

and `JustAudioAyahPlayer.seekToIndex` forwards straight to
`_player.seek(Duration.zero, index: index)` with no clamp. On the last
āyah of a surah, "next" on the lock screen seeks past the end of the
playlist.

The handler cannot currently fix this: it tracks `_index` but never
learns the playlist **length**, and it never populates `audio_service`'s
`queue`. The test does not catch it because `FakeAyahAudioPlayer.seekToIndex`
records the index without validating it.

**Cannot bite today** — the handler is unwired. **Will bite in Phase 2**,
on the last āyah, on a real device. Fix alongside wiring: give the
handler the queue length (populating `queue` solves this and the OS
queue UI together).

### R2 — `QuranAudioHandler` is dead on the live path

Zero references in `lib/` outside its own file. This is in direct
tension with the sprint's own rule *"no dead code"*, and it is worth
naming rather than glossing: **the Allowed and Not-allowed lists cannot
both be fully satisfied.** "Integrate `audio_service`" requires
`AudioService.init()`; `init()` requires a manifest service declaration;
manifest changes are forbidden. The only non-crashing resolution is to
build and test the foundation without activating it.

Mitigation is that it is not *untested* dead code — 242 lines of tests,
93% file coverage — so it is a foundation waiting on a decision, not
speculative scaffolding. But it is unproven against a real device and
should not be treated as "done".

### R3 — Dart SDK floor raised 3.4 → 3.6

`audio_service ^0.18.19` requires Dart `^3.6.0`. CI pins Flutter
`3.44.4` (Dart 3.7+), so CI is unaffected — verified. Any contributor on
an older SDK is now locked out. Low impact at a team size of one;
recorded because it is a silent breaking change for anyone else.

### R4 — Background playback itself remains unverified

Nothing here proves audio survives a screen lock. That needs hardware —
roadmap **B4**. Every claim in this report is about code structure, not
about device behaviour.

### R5 — `AyahAudioItem` equality is untested

The class defines `==`/`hashCode`/`toString`; coverage is **1/11 lines
(9%)**, with lines 42–54 — the entire equality block — unexecuted. The
value semantics are load-bearing (playlist comparison, retry-after-error
reuses `_items`) but unproven. Cheap to close; see §7.

---

## 5. Deferred work — Phase 2

| Item | Why deferred | Blocking |
|---|---|---|
| `AudioService.init()` in `main.dart` | Crashes on Android without the manifest service | Manifest decision |
| `AndroidManifest.xml` service + `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Explicitly out of scope | **Product decision** — a Play Store commitment, not a code change |
| `Info.plist` `UIBackgroundModes: audio` | Explicitly out of scope | App Store review commitment |
| Populate `queue` + bound `skipToNext` (R1) | Needs the wiring context | Phase 2 |
| Call `QuranAudioHandler.close()` on teardown | No owner exists to call it yet | Phase 2 |
| Device verification | Needs hardware | Roadmap **B4** |

The permission set is the real gate. `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
is a declared, reviewable commitment about what the app does in the
background — a product and store decision, correctly not made
unilaterally inside an engineering sprint.

---

## 6. Test and coverage delta

Measured on this HEAD, against Sprint F2's recorded figures.

| Gate | Result |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 363 files, **0 changed** |
| `flutter analyze --fatal-infos` | **No issues found** |
| `flutter test` | **866 passed**, 0 failed |
| `flutter test --coverage` | **81.71%** filtered (gate 80) |

| Metric | F2 (`47452f8`) | B1 (`582cb04`) | Δ |
|---|---|---|---|
| Tests | 851 | **866** | **+15** |
| Coverage (filtered) | 81.72% | **81.71%** | −0.01 pp |
| Coverage (raw) | 52.19% | 52.32% | +0.13 pp |

Coverage is flat, which is the honest outcome: +58 well-covered handler
lines offset by +11 nearly-uncovered `AyahAudioItem` lines and the
widened controller surface.

Per-file:

| File | Lines covered |
|---|---|
| `quran_audio_handler.dart` | 54/58 — **93%** |
| `audio_controller.dart` | 104/131 — 79% |
| `ayah_audio_item.dart` | **1/11 — 9%** ⚠️ (R5) |

---

## 7. Recommendation

**Accept Sprint B1 Phase 0–1 as complete.** The scope boundaries hold
under inspection of the actual diff, not just the commit message; all
four gates are green; behaviour is unchanged by construction.

Two follow-ups, neither blocking acceptance:

1. **Close R5 now** (~15 lines): a value-equality test for
   `AyahAudioItem`, matching what Sprint F2 did for `SurahOpening` and
   `AyahDecoration`. It is the only new type in the codebase whose
   declared equality is unexercised, and equality is load-bearing for
   retry-after-error.
2. **Carry R1 into Phase 2's definition of done** explicitly: bound
   `skipToNext` by populating `queue`. It is invisible today and a
   guaranteed bug on the last āyah once the notification is live.

**Do not wire Phase 2 until the permission set is decided.** That
decision is the gate, and it is not an engineering one.
