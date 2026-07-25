---
id: DR-2026-0006
scope: project
owner_role: data-owner
date: 2026-07-25
deciders: [duso]
status: accepted
supersedes: null
review_by: 2027-01-25
reversibility: soft
threshold_reason: [materially-different-approaches, hard-to-reverse-later]
links:
  task: "Sprint 30.0 — Tafsir & Study Architecture Foundation"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0006 — Study Experience Architecture Foundation

## Relationship to earlier records

This record **extends** `DR-2026-0003` (data architecture), `DR-2026-0004`
(derive-on-read discipline) and `DR-2026-0005` (Learning Engine). It
reverses nothing. Where it names a schema shape for a future capability,
that shape is a *recorded intention*, not an approved migration —
`PROJ-P-002` still requires an explicit stop-and-ask before any change to
either database.

Sprint 30.0 was scoped as architecture-first: no Tafsir data, no
placeholder UI, no empty repositories, no speculative providers. This
record is therefore the sprint's primary artifact. **No production code
was changed.**

## Context

The Study Experience must eventually carry Tafsir (from multiple
sources), footnotes, cross references, word explanations, reflection,
personal notes, study history, and integrations with the AI Tutor and
Learning Journey. The question this record answers is not *how to build
those* but *what must be true now so that building them later does not
require a rewrite*.

A full read of the study-related surfaces was performed first:
`ReadingScreen` / `AyahCard`, `AyahActionsSheet`, `StudyScreen`, the
Library (bookmarks, favorites, notes, highlights, collections), Search,
`AppRoutes`, `QuranRepository`, `UserContentRepository`,
`LexiconRepository`, both Drift schemas, `ReadingSettings`,
`ARCHITECTURE.md`, `DATABASE.md` and `docs/DATA_PIPELINE.md`.

## Existing architecture (what is already true)

**A1. Tafsir already has a schema home.** `translation_sources.type` is
declared as `'translation' | 'transliteration' | 'tafsir'`;
`SourceType.tafsir` exists in the domain; `_sourceFromRow` already maps
it; `docs/DATA_PIPELINE.md` already documents the import as *"1 row in
`translation_sources` (type='tafsir') + import text into
`translations`"*. Per-ayah Tafsir requires **no schema change and no new
repository**.

**A2. Sources are data; the reading UI is not.** `getEnabledSources()`
returns rows, but `ReadingSettings` carries three hardcoded booleans
(`showTransliteration`, `showVietnamese`, `showEnglish`) with three
hardcoded preference keys, and `AyahCard` reads three hardcoded source
codes (`translit_latin`, `vi_main`, `en_sahih`) into three hardcoded
text styles. This mismatch — data-driven storage, hardcoded
presentation — is the single concrete blocker to multiple Tafsir
sources.

**A3. The reading query is eager and whole-surah.**
`getAyahsOfSurah` performs one join that loads *every enabled source* for
*every ayah* of the surah. This is correct for short translations and
deliberately avoids N+1.

**A4. Ownership is already clean.** `QuranRepository` (8 members) owns
static content; `UserContentRepository` (11) owns per-ayah user
artifacts; `LexiconRepository` owns word-level data;
`BookmarkCollectionRepository` owns collections. None is a god
repository, and there is no repository that spans groups A and B.

**A5. Study entry points are three, and they do not overlap.**
`StudyScreen` (six tool cards → flashcards, review session, quiz,
revision queue, progress dashboard, AI tutor); `AyahActionsSheet`
(per-ayah: bookmark, favorite, highlight, status, note, copy, share,
play); the Library (four tabs + collections). The per-ayah surface is
the one Tafsir belongs to.

**A6. Search deliberately whitelists sources.** `searchAyahs` filters
`source_code IN ('arabic_plain','vi_main_plain','translit_latin_plain','en_sahih')`
as a literal inside the SQL string. `SearchScope` already anticipates
Tafsir as a future scope.

**A7. Personal notes are one-per-ayah.** `Notes.uniqueKeys = [{ayahId}]`.

**A8. `translations` is strictly per-ayah.** Primary key
`{sourceId, ayahId}`.

**A9. Translation layers are hardcoded LTR.** `AyahCard` passes
`TextDirection.ltr` to the transliteration, Vietnamese and English
layers, even though `TranslationSource.language` is available.

## Decisions

### D1 — Tafsir is a content *source*, not a new feature domain

Per-ayah Tafsir ships as rows in `translation_sources` (`type='tafsir'`)
and `translations`, read through the existing `QuranRepository`.

*Why this design?* The schema, the domain enum, the row mapping and the
data-pipeline documentation already model it (A1). Choosing anything else
means ignoring a decision this project already made and documented.

*Why not a dedicated `tafsirs` table and `TafsirRepository`?* It would
duplicate the source metadata `translation_sources` already carries
(license, version, author, display order, enabled flag) — metadata that
`DR-2026-0003` made mandatory for every data source — and split "text
attached to an ayah" across two query paths. It would also mean creating
an empty repository, which this sprint forbids and which the Repository
Engineering Standard treats as premature.

### D2 — Passage-level Tafsir gets its own table, not a wider `translations`

Per-ayah Tafsir needs no schema change (D1). Classical Tafsir, however,
frequently comments on a *range* of ayahs, which `{sourceId, ayahId}`
(A8) cannot express. When passage-level Tafsir is required, the shape is
a **separate** table:

```
tafsir_passages(source_id, ayah_start, ayah_end, text)
```

*Why this design?* It leaves `translations` — and the single join in
`getAyahsOfSurah` that depends on its uniqueness — untouched, and it
preserves the identity of "one passage", which is required both for
correct display and for citing the source.

*Why not widen `translations` with nullable `ayah_start`/`ayah_end`?*
Every existing translation row would carry two permanently-null columns,
and the `{sourceId, ayahId}` uniqueness that the reading query relies on
would have to be relaxed for all sources to accommodate one.

*Why not duplicate the passage text onto each ayah in the range?* A 2 KB
passage spanning 20 ayahs becomes 40 KB, and the app can no longer tell
that those 20 rows are one commentary rather than 20.

**Not executed.** `PROJ-P-002` governs; this is a recorded shape.

### D3 — Reading layers must become data-driven before the first Tafsir source ships

Replace the three booleans in `ReadingSettings` with a visibility set
keyed by source `code`, persisted as one preference entry, and select
presentation (text style, direction) by `SourceType` and
`TranslationSource.language` rather than by hardcoded code.

*Why this design?* Sources are already rows (A1); only the UI is
hardcoded (A2). Once visibility is keyed by code, adding the first — or
the fourth — Tafsir source requires no widget change at all. It also
fixes A9: direction becomes a function of `language`, so an
Arabic-language Tafsir renders RTL correctly instead of being forced LTR.

*Why not simply add `showTafsir`?* It satisfies "Tafsir" and fails
"multiple Tafsir sources" on the very next source, and it repeats the
mistake for every future layer.

*Why not derive visibility purely from `translation_sources.is_enabled`?*
`is_enabled` is a packaging decision made by the data pipeline; layer
visibility is a per-user preference. Collapsing the two would make a
user's choice unshippable and a shipping choice unchangeable by the user.

**Not executed in this sprint.** It changes persisted settings (a
migration from three boolean keys) and visible reading behaviour, which
belongs in an implementation sprint with its own tests — not in an
architecture-first pass.

### D4 — Tafsir is fetched on demand per ayah, never as part of the surah payload

Tafsir text must **not** flow through `getAyahsOfSurah`. It is retrieved
by a dedicated repository method keyed by ayah, exposed as an
`autoDispose.family` provider.

*Why this design?* A3 loads every enabled source for the whole surah in
one query. Tafsir entries are one to three orders of magnitude longer
than a translation; Al-Baqarah alone is 286 ayahs. Eager loading would
turn opening a surah into a multi-megabyte read for text that is not on
screen. Per-ayah on-demand keeps the reading path's single-query, no-N+1
property intact and bounds memory to what is actually displayed.

*Why not lazy-load inside `AyahContent`?* It would put I/O behind a
domain entity accessor, breaking the rule that entities are pure data.

*Why not a cache layer?* The project's standing doctrine is no caching
across calls. `autoDispose.family` already gives per-ayah lifetime and
automatic disposal without hand-rolled cache invalidation.

**Not created now** — no UI consumes it, and a provider without a
consumer is exactly the speculation this sprint prohibits.

### D5 — There is no `StudyRepository`

Study is a **composition at the presentation layer**. New study
capabilities extend whichever repository already owns that data.

*Why this design?* A4 shows ownership is already clean and non-
overlapping. A repository named for a *screen* rather than for a *data
domain* would have to reach into content, user artifacts and lexicon at
once — the definition of a god repository, and a direct violation of the
single-responsibility and clear-ownership goals.

*Why not a thin façade over the three?* A façade with no logic adds an
indirection that must be kept in sync with three interfaces and hides
which database (group A read-only vs group B synced) a call touches —
a distinction `ARCHITECTURE.md` treats as invariant.

### D6 — Reflection is not a second notes table

A7 permits exactly one note per ayah. If reflection must be distinct from
a note, the correct change is to relax that unique key and add a `kind`
column to `notes` — not to add a `reflections` table.

*Why this design?* A second table would replicate the sync columns, the
editing path, the Library tab, the search integration and the collection
logic that notes already have, and would leave the app with two answers
to "what did the user write about this ayah".

*Why not do it now?* There is no reflection feature and no caller. The
constraint is recorded so that it is discovered at design time rather
than after a table exists.

### D7 — Study History is derived, not logged again

"What I studied" is derived from artifacts that already exist —
`study_sessions`, `ayah_statuses`, `notes`, `srs_cards` — following the
derive-on-read precedent `DR-2026-0003`/`DR-2026-0004` set for streaks.
If an explicit event log ever becomes unavoidable, it is **one** table
using the `item_type` / `item_id` pattern already proven by `srs_cards`,
not one table per activity.

*Why this design?* The alternative — a per-activity log written eagerly
by every study surface — creates duplicate state (the same fact recorded
both as an artifact and as an event) and a second source of truth for
progress numbers, which is precisely the failure `DR-2026-0004` was
written to prevent.

### D8 — Footnotes and cross references stay unbuilt, with shapes recorded

Neither has a caller today. Recorded shapes, both in the read-only
content database (group A):

- Footnotes: markers within translation text plus
  `translation_footnotes(source_id, ayah_id, marker, text)`.
- Cross references: `ayah_references(from_ayah_id, to_ayah_id, kind)`.

*Why record but not build?* Writing them down costs nothing and prevents
a future sprint from inventing a third pattern; building them now would
create empty tables and unused repositories.

### D9 — The search source whitelist becomes data when Tafsir becomes searchable

A6's literal list means a new Tafsir source will neither pollute ayah
search nor be findable. Not polluting is the correct default — Tafsir
commentary should not rank as an ayah match. When a Tafsir search scope
is built, the whitelist moves to a column (`translation_sources.is_searchable`)
and `SearchScope` gains its already-anticipated value.

*Why this design?* It keeps "which sources are searchable" with the
source definition instead of inside a SQL string literal, and
`SearchResultSection` / `ResultCard` are already domain-agnostic, so a
Tafsir scope needs no new result widgets.

### D10 — Dependency direction is frozen

```
ai_tutor ─┐
          ├─→ quran (content) · lexicon (words) · library (user artifacts)
learning_ ┘
journey
```

Consumers never own study data, and content never depends on consumers.
Presentation → Domain ← Data, unchanged from `ARCHITECTURE.md`; the
domain layer keeps importing neither Flutter nor Drift (`PROJ-P-003`).

*Why record something already true?* Because the pressure to break it
arrives with AI: the natural-looking shortcut is for a tutor to keep its
own copy of notes or its own ayah text. This record makes that a
detectable violation rather than a judgement call.

## Accessibility consequences

The architecture must preserve, and D3 actively improves, the following:

- **Screen readers** — each text layer stays a separate `Text`, so a
  Tafsir layer is announced as its own block. A per-ayah Tafsir surface
  must carry a `Semantics` header naming the source, matching the
  `SectionHeader` convention.
- **RTL** — direction becomes a function of `TranslationSource.language`
  (D3), fixing A9. Arabic-language Tafsir is a realistic first source, so
  this is not hypothetical.
- **Large text** — layers must not be given fixed heights; the current
  hardcoded `fontSize` values still scale with `textScaler`, but D3
  should move them onto the theme's type scale.
- **Keyboard** — `ReadingScreen` already binds Space and arrows. Any
  Tafsir panel must not swallow them; the existing sheets
  (`AyahActionsSheet`, `ReadingSettingsSheet`) are the precedent.

## What this record deliberately does not decide

Tafsir source selection UI; where Tafsir appears (inline layer vs sheet
vs dedicated panel); whether Tafsir participates in offline download;
AI-generated commentary of any kind. All require a product decision, and
none is blocked by anything above.

## Consequences

- Per-ayah Tafsir can be added by the data pipeline alone once D3 lands.
- D3 is the critical path and the only prerequisite; it is a
  self-contained refactor with a settings migration.
- Passage-level Tafsir, footnotes, cross references and reflection each
  need a schema change and therefore an explicit `PROJ-P-002` approval.
- No abstraction was created in this sprint, so nothing added here can
  rot before it has a user.
