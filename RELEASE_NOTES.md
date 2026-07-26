# Release notes — Qur'an Companion

## v1.0.0-rc1 — **candidate prepared, NOT tagged**

**Status:** the build below is complete and every automated gate passes.
It is **not tagged** because four content licences remain unverified and
the store package is incomplete. See `KNOWN_ISSUES.md` and
`RELEASE_CHECKLIST.md` §A.

**Build identity**

| Field | Value |
|---|---|
| `pubspec.yaml` version | `0.8.1+7` — **deliberately not bumped**, see "Version" below |
| Content data version | `6` (built 2026-07-26) |
| applicationId / bundle id | `com.duso.qurancompanion` |
| Target API (Android) | 36 |
| Tests | 901 passing |
| Coverage | 84.0% of hand-written code |

---

## What is in this build

### Reading
- Complete Qur'an: 114 Surahs, 6,236 Ayahs, Uthmani script (Tanzil)
- Three text layers per Ayah — Arabic, Latin transliteration, and
  translation — each independently switchable
- Two translations: Vietnamese (Rowwad, via QuranEnc) and English
  (Saheeh International, via Tanzil)
- Reading modes, adjustable font size, focus mode, jump-to-Ayah,
  reading-position restore, progress indicator
- Right-to-left rendering driven by the source's language, not by
  hard-coded assumptions

### Audio
- Five reciters, streamed on demand
- Playback speed, repeat, per-Ayah navigation
- Global mini player that survives navigation away from the reading
  screen

### Study
- Per-Ayah Study Workspace at `/study/:ayahId`
- Two tafsir corpora: Al-Muyassar (Arabic) and Ibn Kathir (English,
  abridged)
- **Passage-aware commentary**: tafsir is written for groups of Ayahs,
  and the app resolves the passage covering any Ayah. All 6,236 Ayahs
  return commentary.

### Library and learning
- Bookmarks, favourites, notes, highlights, collections
- Full-text search across Arabic and Latin text
- Reading streaks, daily goal, Khatm progress, statistics
- Spaced repetition (SM-2), quiz sessions, review sessions

### Transparency
- **Sources & attribution screen** (Profile → Data sources): every
  shipped source with its author, language, version, licence and source
  address, generated from the database rather than hard-coded
- **Software & font licences**: full OFL 1.1 and KFGQPC licence texts
  bundled and viewable in-app

---

## Migration notes

### For users
This is the first release. There is no upgrade path to test, and no
user data exists to migrate.

### Content database
The bundled content database is at **version 6**. On launch, the app
compares `meta.data_version` in the installed copy against
`DatabaseConstants.expectedDataVersion`. On mismatch it replaces the
installed copy wholesale, atomically (write to `.tmp`, then rename).

**Nothing user-created is touched.** Content lives in
`quran_content.sqlite`; everything the user creates lives in a separate
user database. This separation is the reason a content update can never
lose a note.

### User database
Drift `schemaVersion` **6**, with stepwise `onUpgrade` migrations
already written for 1→2→3→4→5→6. Future releases must add a new step
rather than editing an existing one.

### If a future release changes content
1. Bump `DATA_VERSION` in `tool/build_quran_db.py`
2. Bump `DatabaseConstants.expectedDataVersion` to match
3. `flutter test test/content_database_smoke_test.dart` fails loudly if
   the two disagree — that mismatch is the guard, not a convention

---

## Version

`pubspec.yaml` still reads `0.8.1+7`. This is a deliberate choice, not
an oversight.

`ROADMAP.md` defines v1.0 as "Reading + Audio + Commentary + Search +
Dashboard" — steps 1–9 of 12. Those are substantially complete. But two
features reachable from the UI have no data or no implementation behind
them (see `KNOWN_ISSUES.md` K1 and K2), and calling that 1.0 overstates
it.

**Recommendation:** tag the first candidate `v0.9.0-rc1`, and reserve
`v1.0.0` for a build where every feature a user can reach does what its
label promises. The version number is a claim to users; it should be
one the build can keep.
