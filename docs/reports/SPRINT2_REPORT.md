# Sprint 2 Report — Quran Reader Polish

**Date:** 2026-07-06 · **Scope:** Quran reading experience to production quality
**Validation:** `flutter analyze` 0 errors · `flutter test` 125/125 pass · on-device E2E (Windows) pass · `flutter run -d windows` launches clean

---

## 1. Arabic typography
- Quran text renders in **KFGQPC Uthmanic Script HAFS** (official King Fahd Complex font, bundled; verified 100% glyph coverage of all 6,236 ayahs).
- One shared `quranTextStyle()` used everywhere (list, Mushaf, focus mode, search results, Today's Verse) — no per-widget drift.
- **Tashkeel no-clip fix:** `TextLeadingDistribution.even` distributes the 2.0 line height above/below the baseline so tall marks (fathatan, madd, superscript alef) are never clipped on the first line.
- RTL alignment (`textDirection: rtl`, right-aligned), responsive size 36/34/30 (desktop/tablet/mobile) × user zoom factor.

## 2. Transliteration
- Data-layer cleaner converts Tanzil semantic HTML → scholarly Unicode: `<u>` vowels → ā ī ū, `<u>` consonants → ṣ ḍ ṭ ẓ ḥ, `<u>th</u>` → dh, `AA` → ʿ, inter-vowel `-` → ʾ; `<b>` stripped; uppercase/malformed closing tags handled.
- **Corpus sweep test added:** all 6,236 transliterations verified free of `<`, `>`, and raw `AA` (test/content_database_smoke_test.dart).
- Rendered in Inter Italic 18 / 1.6 line height / soft gray.

## 3. Translation typography
- Vietnamese: Inter 18 / 1.65 height, full-contrast; English secondary: Inter 16 / 1.6, muted. Consistent 12px layer spacing inside the card.

## 4. Audio player (major upgrade)
- **Interface extended** (`AyahAudioPlayer`): `positionStream`, `durationStream`, `processingStream` (idle/loading/ready/completed), `errorStream`. Engine errors (404, network drop) never throw — they flow through `errorStream`.
- **State** (`AudioState`): position, duration, `progress`, `loading`, `errorMessage`.
- **AudioBar** now has: per-ayah **progress bar** with elapsed/total time, **loading spinner** replacing the play button while buffering, **error banner with Retry** (`retry()` reloads the playlist at the exact ayah), play/pause, previous/next ayah, cycling playback speed (0.75→2.0×), repeat modes (off / repeat-ayah / repeat-surah), reciter picker, stop.
- **Auto-advance** to the next ayah retained (gapless playlist); playlist completion resets the play button.
- Position updates throttled to ~300 ms.

## 5. Ayah cards
- Material 3 premium card: dark elevated surface, 16 px radius, 24 px padding, 24 px vertical rhythm, soft shadow.
- **Hover effect** (desktop): elevated shadow, primary-tinted border and surface wash, animated 250 ms.
- Green circular ayah-number badge; playing/highlight states blend into the card surface.

## 6. Per-ayah actions
- Card row: **Bookmark · Favorite (new) · Copy · Share · Play · More** — rounded icons, tooltips, hover-scale animation.
- Long-press / More sheet: Bookmark, **Favorite**, **Copy Arabic**, **Copy Translation**, 6-color Highlight, learning Status, Notes (markdown).
- **Favorite** is real user data: new `favorites` table, user DB **schema v1 → v2 additive migration** (UUID PK, soft delete, sync-ready columns like all user tables) + migration/toggle tests.

## 7. Search (full-text, new)
- **FTS5 content search** over the bundled `search_index`: Arabic (harakat-insensitive + alef-wasla variant so typing plain ا matches ٱ), Vietnamese (diacritic-insensitive), transliteration, and English — via new `searchAyahs()` with a pure, unit-tested `ftsMatchExpression()` builder (prefix match per token, injection-safe).
- Quran tab: typing now shows matching surahs **plus** ayah content results (Mushaf order, capped), each with surah name, reference, Arabic + translation snippets.
- **Result highlighting:** index-mapped folding maps matches back to the original text, so the highlighted Arabic span includes its tashkeel; Vietnamese matches highlight the accented original.
- Tapping a result opens the reading screen **at that exact ayah**.
- 250 ms debounce; queries under 2 characters skipped.

## 8. Performance
- **Rebuild isolation:** ayah cards watch audio state via `select()` on a single bool — position ticks (multiple/second while playing) rebuild only the AudioBar, never the 286-card list.
- Search debounced; FTS queries indexed; lazy list rendering (`ScrollablePositionedList`) unchanged.

## 9. Accessibility
- **Keyboard shortcuts** (reading screen): `Space` play/pause (starts from current position), `←`/`→` previous/next ayah, `+`/`−` Arabic font size, `F` focus mode, `M` list/Mushaf toggle.
- Fonts resizable via slider, pinch zoom, and now keyboard; setting persisted.
- Semantics preserved/extended: per-ayah labels, tooltips on all controls, labeled loading spinner, sajdah semantic label.

## Bugs fixed during the sprint
- Note dialog `TextEditingController` disposed during dialog close animation (pre-existing crash).
- Fresh-open of a surah hid the surah header (initialScrollIndex off-by-one).
- Stale test expectations + drift stream teardown timer invariant in the widget test harness.

## Test coverage added
- `test/search_test.dart` — FTS expression (Latin/Arabic/wasla/escaping), highlight mapping (Vietnamese diacritics, Arabic tashkeel), real-DB search in vi/ar/en, Mushaf ordering. 10 tests.
- Transliteration corpus sweep (6,236 rows).
- Favorites migration + toggle tests; updated audio fake to the richer engine contract.
- Suite total: **125 tests, all passing.**

## Explicitly unchanged
Database contents, Riverpod architecture, dark theme, localization (all new strings translated vi/en/ar), Mushaf mode, focus mode, pinch zoom, existing annotations.
