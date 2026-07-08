# Sprint 2.1 Report — Quran Transliteration Standardization

**Date:** 2026-07-06 · **Scope:** transliteration only — Arabic text, Vietnamese/English translations, audio, and UI untouched (verified byte-identical below).

> **Addendum (2.1b) — editorial rule set.** After the base standardization, a deterministic editorial pass was added so the whole Quran reads as one editor (data v3, 10,110 words adjusted):
>
> | Rule | Implementation | Evidence |
> |---|---|---|
> | الله → **Allāh** (capitalized, macron) | Exact-token map incl. idiomatic contractions `wallāhu`, `billāhi`, `lillāhi`, `tallāhi`, `fallāhu`, `Allāhumma` — traps `l-lahabi` (flame, 111:3) and `l-lahwi` (amusement) untouched | 2,209 occurrences |
> | One apostrophe style: `ʾ` hamza, `ʿ` ʿayn — zero ASCII `'` | Source `'` after a **vowel** = hamza → `ʾ` (1,426); after a **consonant** = redundant syllable break → removed (4,926). Verified 0 counterexamples against the Arabic across 77,429 words | 0 `'` remain |
> | Long vowels only `ā ī ū` — never `aa/ii/uu` (incl. `āa/aā/īi/ūu`) | Every same-vowel juncture verified to be a hamza position in the Arabic (0 exceptions) → `jāa` → `jāʾa`, `māan` → `māʾan` | 1,110 junctures fixed, 0 remain |
> | No duplicated syllables | Corpus scan: 0 within words; the 2 cross-word flags (`…nin ini l-ḥukmu` 12:40, `l-sijili lil…` 21:104) are correct Quranic text | 0 defects |
> | Sample | 1:1 = `bismi Allāhi l-raḥmāni l-raḥīmi` · 112:1 = `qul huwa Allāhu aḥadun` | |
>
> Rules live in `tool/fetch_transliteration.py` (`standardize_token`) and are locked by `test/transliteration_standard_test.dart` (no ASCII apostrophe, no doubled long vowels, capital A only inside `Allāh`, character whitelist). Data version 2 → 3; installs auto-upgrade. Validation after 2.1b: analyze 0 errors, 129/129 tests, E2E pass.

---

## 1. Audit of the previous dataset (Tanzil `en.transliteration`, 6,236 rows)

| Issue | Rows affected | Example |
|---|---|---|
| HTML tags stored in data (`<u>`, `<b>`, malformed `</U>`, `</B>`) | 6,229 / 6,236 | `Bismi All<u>a</U>hi a<b>l</B>rra<u>h</U>m<u>a</U>ni…` (1:1) |
| Raw `AA` encoding for ʿayn | 4,389 | `alAA<u>a</u>lameen<b>a</b>` (1:2) |
| Mid-word capitalization artifacts | 3,399 | `nastaAAeenu` |
| Mixed romanization styles in one text (macrons from tags + `ee`/`oo` digraphs) | corpus-wide | `alrra<u>h</u>eem` → "alrraḥeem" (ī written `ee`) |
| Repeated-syllable oddities | 11 | ayah 914 |
| Adjacent duplicated words (not matching Arabic) | 4 | ayah 1343 |

The runtime cleaner from Sprint 2 masked the HTML at display time, but the stored data remained non-standard and stylistically inconsistent (no single convention for long vowels; capitalization arbitrary).

## 2. Standard adopted

**Quran.com word-by-word transliteration** (the corpus used on quran.com), assembled per ayah from the word stream — no invented style. Convention: lowercase; macrons `ā ī ū`; dotted emphatics `ḥ ṣ ḍ ṭ ẓ`; `ʿ` for ʿayn; `'` for hamza/glottal stop (e.g. `bis'mi`); assimilated article written `l-`/`al-` per Quran.com's own contextual rule.

Example (1:1): `bis'mi l-lahi l-raḥmāni l-raḥīmi`

Because the dataset is word-derived, **each Arabic word form maps to exactly one transliteration by construction**. Consistency audit over all 77,429 word occurrences / 21,295 unique Arabic forms:
- 99.97% of forms had exactly one transliteration in the upstream corpus.
- 22 forms vary only in the `al-`/`l-` article prefix — this is Quran.com's own positional (sandhi) convention, kept as-is per the "don't invent a new style" rule.
- **2 genuine upstream typos found and fixed** (both in 2:181): `sami'un` → `samīʿun`, `alimun` → `ʿalīmun`. The fetch tool now applies a majority-form normalization pass automatically, so refetches self-heal such defects.

## 3. Issues fixed

- All 6,229 rows with stored HTML → replaced with clean Unicode text (0 remaining).
- All 4,389 raw `AA` artifacts → gone (ʿ from source data).
- Capitalization now uniform (lowercase standard) across all 6,236 ayahs.
- No double spaces, no leading/trailing spaces, NFC-normalized Unicode throughout.
- 2 upstream word typos normalized to the dominant form.
- Search recall: the standard's `'` marker split FTS tokens (`bis'mi` ≠ query "bismi") — apostrophe/ʿ/ʾ are now stripped by both the pipeline fold (`fold_latin`) and the app fold (`foldDiacritics`), so `bismi`, `samiun`, `rahimi` all match. Verified against the rebuilt index.

## 4. Architecture — one replaceable dataset

- **`tool/data/transliteration.json`** — the single dataset (6,236 ayahs + source metadata). Replacing the transliteration in the future = replace this file (or re-run the fetcher) + rebuild the database. No code changes.
- **`tool/fetch_transliteration.py`** — downloads the Quran.com word-by-word corpus, applies majority-form normalization, validates counts, writes the dataset + word-pair audit file (`transliteration_words.json`).
- **`tool/build_quran_db.py`** — now prefers the local dataset (falls back to Tanzil with a warning if absent); writes proper attribution into `translation_sources` (name/author/url/version).
- **`TransliterationRepository`** (Dart, `lib/features/quran/data/transliteration_repository.dart`) — single in-app authority for the transliteration source code/type and normalization. `QuranRepositoryImpl` delegates to it. Its `normalize()` passes standard data through untouched and converts legacy Tanzil-format strings (safety net for stale on-device databases).
- **Data version bumped 1 → 2** (`meta.data_version` + `DatabaseConstants.expectedDataVersion`) — existing installs re-copy the standardized database automatically on next launch (verified on this machine: version marker upgraded to `2`).
- Legacy cleaner hardened: its hamza-hyphen rule now applies **only** to legacy-format strings, so the standard's meaningful hyphens (`l-lāhi`) can never be corrupted.

## 5. Validation (all 6,236 ayahs)

New permanent test `test/transliteration_standard_test.dart`:
- ✔ Database text == dataset text for **every one of the 6,236 ayahs** (via the app's own repository path).
- ✔ `normalize()` is an identity on all 6,236 standard rows (no accidental rewriting).
- ✔ Character whitelist holds corpus-wide (`a–z ' ʾ ʿ ā ī ū ḥ ṣ ḍ ṭ ẓ - space`); zero HTML, zero `AA`, zero spacing defects.

Also verified:
- ✔ Arabic text, Vietnamese translation, English translation **byte-identical** to the previous database (SQL group-concat comparison).
- ✔ `flutter analyze`: 0 errors · `flutter test`: **128/128 pass** · on-device E2E (Windows): pass, including the on-screen assertions "no raw HTML anywhere" and "standard Unicode diacritics present".
- ✔ FTS transliteration search re-indexed and matching folded queries.

## 6. Remaining items (known, by design or out of scope)

- `al-` vs `l-` article prefix varies by position — intentional, follows Quran.com's own convention (74 ayah-initial `al-`, plus lam-initial words like `al-layli`).
- Quran.com renders "Allah" as `l-lahi`/`al-lahu` (no macron) — kept verbatim; it is the platform's standard.
- The old Tanzil import path remains in the pipeline as an explicit fallback (warns and recommends the standard dataset) — kept so the build never hard-fails offline; can be removed once the team is comfortable.
- Attribution: the About screen lists data sources generically; adding an explicit "Transliteration: Quran.com" line is a one-string follow-up (source metadata is already in the database).
