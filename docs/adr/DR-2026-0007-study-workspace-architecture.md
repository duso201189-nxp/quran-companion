---
id: DR-2026-0007
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
  task: "Sprint 31.0 — Study Workspace Architecture"
  intelligence_layer_artifact: null
  verification_records: []
---

# DR-2026-0007 — Study Workspace Architecture

## Relationship to earlier records

Builds directly on [DR-2026-0006](DR-2026-0006-study-architecture-foundation.md),
whose D4 (Tafsir loads per-ayah, on demand) and D5 (no `StudyRepository`)
are reaffirmed, not changed. Sprint 30.1 made Reading data-driven and
30.2 gave it a Tafsir loading boundary; this record generalises that
boundary from *Tafsir* to *all deep-learning data*, and names the
surface that will own it.

Nothing here changes a database schema. No Study UI, provider or route
was implemented — Sprint 31.0 was scoped as architecture-only, and a
route with no screen is exactly the placeholder this project forbids.

## Context

`reading_screen.dart` is 1377 lines and 17 classes. Every feature added
since Sprint 25 — jump-to-ayah, progress indicator, focus mode, action
sheet, settings panel, audio integration, session logging — landed in
it or beside it. The listed future work (Tafsir, multiple notes,
highlights, cross references, word analysis, learning modules) is an
order of magnitude larger than all of that. Continuing the current
trajectory makes Reading a feature container, which makes the reading
screen slow, hard to test, and impossible to change without risking the
app's most important screen.

## Audit: what Reading owns today that it should not

**R1 — Study-session logging.** `reading_screen.dart` imports three
`features/stats/**` files and writes a session from `dispose()`, with
the "< 5 seconds doesn't count" rule living in a widget lifecycle
method. Reading measures itself. Every future surface that counts as
study (a Tafsir reading session, a review session) would need the same
code in its own `dispose()`.

**R2 — Direct user-data writes from a presentation widget.** `AyahCard`
calls `userContentRepositoryProvider.toggleBookmark/toggleFavorite`
inline. Reading therefore knows how annotations are *stored*; the
multiple-notes change sketched in `DR-2026-0006` D6 would edit
`AyahCard`.

**R3 — Audio orchestration.** Reading builds the playlist
(`[for (final a in ayahs) a.ayah]`, in two places), owns the Space /
arrow shortcuts, and hosts `AudioBar`. Scroll-follow is legitimately
presentation; playlist construction and transport hosting are Audio's.

**R4 — Clipboard/share composition.** `_copyAyah` assembles Arabic plus
the visible translation layers into shareable text — a content-export
concern that re-derives which layers are visible.

**R5 — `AyahActionsSheet` is already an unnamed Study Workspace.** 491
lines owning bookmark, favorite, highlight, status, note editing, copy,
share and play-from-here. It is the per-ayah deep surface; it is simply
filed inside the Qur'an feature and has no route.

**R6 — There is no entry point to a deep surface other than the sheet.**
No route exists, so nothing — Search, Library, AI Tutor, a notification
— can link to "study this ayah".

**R7 — Reading imports a presentation widget from Search**
(`search/presentation/widgets/search_error_state.dart`). Pre-existing,
noted because dependency direction between sibling features is exactly
what this record freezes.

## Decisions

### D1 — The Study Workspace is a per-Ayah surface, not a tab

Scope is one ayah at a time.

*Why this design?* Every listed future feature — Tafsir, notes,
highlights, cross references, word analysis — is *about an ayah*. The
ayah is also the key every user-artifact table already uses
(`bookmarks.ayah_id`, `notes.ayah_id`, `highlights.ayah_id`,
`ayah_statuses.ayah_id`, `srs_cards.item_id`), so the surface's scope
matches the data's natural grain.

*Why not a sixth tab?* A Study tab has no subject until the user picks
one, so it would need its own ayah browser — a second, worse copy of
Reading's navigation.

*Why not a "study mode" inside ReadingScreen?* That is precisely
"Reading becomes a feature container". Every panel would add state,
imports and rebuild surface to the app's most performance-sensitive
screen.

### D2 — Ownership is fixed

| Area | Owns | Must not own |
|---|---|---|
| **Reading** | Presenting Qur'an text: layout modes, fonts, scroll position, focus mode, reading-layer rendering | Learning artifacts, their storage, their loading |
| **Study** | Per-ayah learning artifacts and their lifecycle: Tafsir, notes, highlights, cross references, word analysis | Qur'an text layout; anything list-wide |
| **Library** | Collections and cross-ayah lists of saved artifacts | Per-ayah editing surfaces |
| **Search** | Discovery and ranking | Rendering study content |
| **Audio** | Playback, playlist, transport | Reading layout |
| **Navigation** | Routes and their nesting rules | Feature logic |

*Why record what is mostly already true?* Because the pressure to break
it arrives with the first Tafsir panel: the cheapest-looking move is
always to add one more `if` to `AyahCard`.

### D3 — Study is a top-level route, entered from the existing sheet

Recommended: **`/study/:ayahId`**, a top-level `GoRoute`, opened from a
new action row in `AyahActionsSheet`.

Entry points evaluated:

| Option | Verdict |
|---|---|
| **Long-press ayah → actions sheet → "Study"** | **Chosen.** The gesture and the sheet already exist; adding Study is one row. The sheet stays the *quick* surface (toggle a bookmark and get out); the workspace is the *deep* one. |
| **More menu (`more_horiz`)** | Same sheet — already covered by the above. |
| **A dedicated Study button on every AyahCard** | Rejected. Permanent chrome on every ayah, in the row that already holds five icons, so Reading pays layout and a11y cost for a Study affordance. |
| **Deep links** | **Required, not optional.** Search results, Library items, AI Tutor suggestions and Learning Journey steps must open Study without routing through Reading. This is what forces Study to be a route rather than a sheet. |

*Why top-level rather than nested under `/quran`?*
`reading_navigation.dart` documents the constraint: pushing a
shell-nested route from a top-level screen makes go_router rebuild the
branch Navigator over an existing `GlobalKey` and throw. Library and
Search are top-level; Study must be reachable from them.

*Why `ayahId` (global 1..6236) rather than `surah:ayah`?* One segment,
and it is the identity every artifact table already stores — no
translation step, no ambiguity, stable deep links.

### D4 — Reading never preloads Study data

Reading passes **only an `ayahId`** to the route. Study loads everything
itself, keyed by that id, through `autoDispose.family` providers. No
Study data enters `SurahReading` or `AyahContent`.

*Why this design?* It is the Sprint 30.2 Tafsir boundary generalised. If
`getAyahsOfSurah` grew a "study payload", opening Al-Baqarah would load
286 ayahs × every panel's data — the same silent, data-triggered blow-up
that boundary was created to prevent.

*Why `autoDispose.family` per ayah?* Study is open for one ayah at a
time and closed often; per-ayah lifetime with automatic disposal matches
that exactly and needs no hand-written cache, consistent with the
project's standing no-caching-across-calls rule.

### D5 — Study composes existing repositories; there is still no `StudyRepository`

Reaffirms `DR-2026-0006` D5. Study's providers fan out to
`QuranRepository` (Tafsir text), `UserContentRepository` (notes,
bookmarks, highlights, status), `LexiconRepository` (word analysis) and
`BookmarkCollectionRepository`.

*Why not one repository for the workspace?* It would span the read-only
content database and the synced user database — a distinction
`ARCHITECTURE.md` treats as invariant — and would be named after a
screen rather than a data domain.

### D6 — One panel, one provider; the workspace is a list of panels

Adding a Study feature = one widget + one `autoDispose.family` provider,
appended to the workspace's panel list. Nothing else changes.

Extensibility, concretely:

- **1 Tafsir** — a Tafsir panel + `tafsirForAyahProvider(ayahId)`.
- **10 Tafsir** — *the same panel*, iterating a Tafsir view over the
  catalogue (`translationSourcesProvider` filtered to
  `type == SourceType.tafsir`) — the exact mirror of
  `readingSourcesProvider`. **Zero code change from 1 to 10**, and zero
  extra queries: it filters an already-resolved result.
- **Multiple notes** — the notes panel reads a list instead of one row;
  the schema change (`DR-2026-0006` D6: relax the unique key, add
  `kind`) is confined to `UserContentRepository`.
- **Multiple highlight systems** — a second panel. Reading's highlight
  dots are untouched.
- **Future plugins** — a panel registry. Reading unchanged.

In all five cases Reading's file set is not opened.

### D7 — Reading's dependency budget is frozen and enforced by a test

`test/architecture_boundaries_test.dart` pins the exact set of
cross-feature imports `lib/features/quran/presentation/reading/**` may
have, and forbids importing any feature that Study will own. A new
feature wired into Reading fails the suite rather than passing review.

*Why a test rather than a convention?* Every prior sprint's report has
recommended keeping Reading thin, and Reading grew anyway. A boundary
that isn't executable isn't a boundary.

The allowlist currently includes `features/stats/**` (R1) and
`features/search/presentation/widgets/search_error_state.dart` (R7).
Both are recorded in the test as **debt**, not as approval.

## Data flow

```
ReadingScreen                     (owns: text presentation)
   │ passes ayahId only
   ▼
/study/:ayahId                    (owns: workspace lifecycle)
   │
   ├─ tafsirForAyah(ayahId)       → QuranRepository
   ├─ notesForAyah(ayahId)        → UserContentRepository
   ├─ highlightsForAyah(ayahId)   → UserContentRepository
   ├─ wordAnalysis(ayahId)        → LexiconRepository
   └─ …one provider per panel, autoDispose.family
   ▼
panels render independently; one panel's failure or slowness
does not block the others
```

Reading's flow is unchanged and unaware of any of this.

## What this record deliberately does not decide

Study's visual design; whether panels are collapsible, tabbed or a
single scroll; which panel ships first; whether Study logs its own study
sessions (R1's proper home); offline behaviour for Tafsir. All are
product or implementation decisions, none is blocked by the above.

## Consequences

- The first Study feature adds a route, a screen and one panel — it does
  not modify Reading.
- R1–R4 remain in Reading until a Study sprint moves them; they are now
  named, budgeted and test-fenced against growth.
- `AyahActionsSheet` keeps its current job as the quick surface and
  gains exactly one row when Study ships.
- No provider, route or table was created in this sprint, so nothing
  added here can rot before it has a user.
