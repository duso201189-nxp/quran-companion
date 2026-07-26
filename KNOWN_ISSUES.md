# Known issues — release candidate

Every entry is a defect a user could hit, with how it was found. Sorted
by user impact. Nothing here is speculative; each was measured or read
from the code in Sprints 33.0–35.0.

---

## Blocking a public release

### K1 — "AI Tutor" contains no AI

The Study tab offers an **AI Tutor**. It has no model and no inference.
`ai_tutor_repository_impl.dart` says so in its own doc comment: *"KHÔNG
có logic AI/LLM nào"* — every suggestion and insight is produced by
threshold rules over the analytics repository.

The recommendations may well be useful. The label is not accurate, and
both stores now scrutinise AI claims.

**Fix:** rename the feature to what it is ("Study coach", "Gợi ý học
tập"), or implement a model. Renaming is a string change in three `.arb`
files.

### K2 — Vocabulary features ship with no vocabulary

Every lexicon table in the shipped database is **empty**:

| Table | Rows |
|---|---:|
| `lemmas` | 0 |
| `roots` | 0 |
| `lexemes` | 0 |
| `word_instances` | 0 |
| `phrases` | 0 |
| `grammar_features` | 0 |
| `lexicon_relations` | 0 |

The morphology pipeline exists (`tool/fetch_morphology.py`,
`tool/lexicon/`) but has never been run into a shipped artifact.

**User-visible effect:** from the Study tab → Flashcards → Add, all
three source types (Lemma, Root, Phrase) show *"No browsable data for
this type yet."* The empty state is graceful; the feature is
permanently empty in this build.

**Fix:** run the morphology import, or hide the entry points until the
data exists. Hiding is smaller and honest.

### K3 — Four content sources have unverified licences

Transliteration, both tafsir corpora, and all five recitations.
`docs/LICENSING.md` §4, risks 1–2.

**This is not an engineering defect and cannot be fixed by writing
code.** It needs a written answer from Quran.com/Tarteel and from
everyayah.com.

### K4 — App icon is the stock Flutter logo

Verified: `mipmap-xxxhdpi/ic_launcher.png` md5 `57838d52c318faff…`,
1,443 bytes. Both platforms. No adaptive icon, no monochrome variant.

---

## Degraded experience

### K5 — Audio stops when the app is backgrounded

`audio_service` is not integrated; `AudioController` runs foreground
only (`docs/AUDIO.md`). Locking the screen during a recitation stops
playback.

For an app people use while praying or commuting, this is the most
significant functional gap in the build.

### K6 — Cold start 2.5 s against a 2 s goal

Measured on a Pixel 8 emulator, Android 17, profile build:

| Metric | Value |
|---|---:|
| First launch, includes copying the 32.7 MB asset | 4,019 ms |
| Subsequent cold starts, mean of 4 | 2,530 ms |
| Flutter framework init | 488 ms |
| Time to first frame | 600 ms |
| Time to first frame rasterized | 1,396 ms |

`lib/main.dart` states the goal as "mở app < 2s". Release mode is
faster than profile, but the margin is not proven.

### K7 — Longest tafsir entry drops about four frames

The longest commentary entry is 66,445 characters. Text layout cost,
measured with warm-up, best of five:

| Characters | First-frame layout |
|---:|---:|
| 2,000 | 12.1 ms |
| 10,000 | 19.5 ms |
| 30,000 | 35.8 ms |
| 66,445 | **68.6 ms** |

Visible as a stutter when opening the Study panel on the longest entry,
not a freeze.

### K8 — Web build is broken

`web/` is missing `sqlite3.wasm` and `drift_worker.js`. The build
succeeds; opening the database in a browser fails. CI builds Web
release and reports success, which makes this look healthier than it is.

---

## Measured, acceptable, documented

### K9 — Al-Baqarah load exceeds one frame

`getAyahsOfSurah(2)` returns 286 Ayahs / 255,157 characters in
**17.2 ms**, just over a 16.7 ms frame budget. One-time cost when
opening the longest Surah.

### K10 — Latin search is 7× slower than Arabic search

`searchAyahs('Allah')` 19.2 ms vs `searchAyahs('الرحمن')` 2.89 ms. Both
are well inside interactive latency.

### K11 — Attribution URLs are not tappable

Source addresses are shown and copyable, not opened in a browser. Adding
`url_launcher` means a new dependency and an Android `queries` manifest
entry. Tanzil's requirement — that users can reach tanzil.net — is met
by a full, selectable, copyable address.

### K12 — Download is 34.5 MB per device

arm64-v8a release APK: 62% native code, 30% content database, 4% fonts.
Shipping an AAB rather than a fat APK is what brings 68.5 MB down to
34.5 MB.

---

## Never verified

These are not known to be broken. They are known to be **untested**, and
that distinction matters more in a release candidate than anywhere else.

| # | Area | Why it is unverified |
|---|---|---|
| K13 | TalkBack / VoiceOver | never run against a screen reader on a device |
| K14 | Font scale 200% | never checked |
| K15 | Scroll FPS on device | `dumpsys gfxinfo` returns 0 frames for Flutter on Android 17; `SurfaceFlinger --latency` returns no rows. Real capture needs `integration_test` + `flutter drive` |
| K16 | Battery drain | emulator battery is simulated |
| K17 | iOS, at all | no Apple Developer account; the app has never run on an iOS device |
| K18 | Physical Android hardware | all device measurement to date is emulator-only |

### K19 — CHANGELOG is 25 sprints behind

`CHANGELOG.md`'s `[Unreleased]` section ends at Sprint 10. Sprints 11–35
— including the entire Study Workspace, both tafsir imports, the
passage-aware query, the attribution system and the legal package — are
absent. The history exists in ADRs and sprint reports; it has not been
consolidated.

Not a user-facing defect, but a release without an accurate changelog
cannot answer "what changed?" for reviewers or for future maintainers.
