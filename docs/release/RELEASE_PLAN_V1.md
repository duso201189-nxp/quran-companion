# Release Plan — v1.0

Written after PR #19 (Sprint S2 — Quality & Polish), the final merge
of a long feature-recovery engagement (P1–P4 infrastructure, F1–F8
feature verticals: Lexicon, Flashcards, Analytics, AI Tutor, Learning
Journey, Smart Learning, Read Model, Learning Session wiring). This
document evaluates release readiness against the **actual current
code**, not against `ROADMAP.md`/`TODO.md`/`CHANGELOG.md`/`pubspec.yaml`
— see §0 for why those specifically should not be trusted as the
current source of truth right now.

---

## 0. A documentation-debt finding that affects this whole plan

`pubspec.yaml` still declares `version: 0.8.1+7`. `CHANGELOG.md`'s
`[Unreleased]` section stops at "Sprint 10: Learning Engine" — it has
no entry for any of P1–P4, F1–F8, or Sprint S2. `ROADMAP.md`'s 12-step
table still shows step 9 ("Flashcard SM-2 + Quiz + Thống kê") as
partially done with "Flashcard hoãn lại có chủ đích" (Flashcards
deliberately deferred) — but Flashcards (F2) is fully built and merged.
`TODO.md` has the same gap. `CLAUDE.md` states "Currently mid Step 8 of
12 (v0.8.1)."

**None of this reflects the current repository.** The feature work in
this repo has substantially overshot what these four files describe —
Lexicon, Flashcards, Analytics, AI Tutor, Learning Journey, Smart
Learning, and Learning Session wiring are all merged and gated (only
Read Model has no UI yet, see §2). This appears to be a side effect of
how this engagement's mega-commit decomposition happened outside the
normal per-sprint versioning/changelog workflow. **Reconciling these
four files (version bump, CHANGELOG backfill, ROADMAP/TODO status
update) should be its own small, first task before anything else in
this plan** — otherwise every subsequent release-prep step is working
from a map that doesn't match the territory.

## 1. What "done" actually looks like right now

Confirmed via direct code inspection
([MODULE_CATALOG.md](../architecture/MODULE_CATALOG.md) has the full
per-feature detail):

| Area | Status |
|---|---|
| Reading (Surah list, reading screen, audio, bookmarks/highlights/notes) | Built, shipped in earlier releases, unaffected by this engagement |
| Search | UI foundation built (Sprint 7.1); real FTS5 engine wiring is a separate, still-open item (§4) |
| Stats/Dashboard, Khatm, Daily Goal, Revision Queue | Built (Sprint 8–9) |
| Learning Engine (SRS scheduler, Review Session, Quiz) | Built (Sprint 10 / G7) |
| Lexicon, Flashcards, Analytics, AI Tutor, Learning Journey, Smart Learning | Built and merged (F1–F6) |
| Read Model | Built and merged (F7) — **no UI consumes it yet**, infrastructure-only |
| Learning Session wiring (unifies Review/Quiz/Flashcard into one session) | Built and merged (F8) |
| Reliability layer (structured failures, Logger, CrashReporter) | Built, and as of Sprint S2, actually wired end-to-end (was previously half-dead) |

This is, in substance, most of what `ROADMAP.md` calls "v1.5" scope
(vocabulary, flashcards, quiz, stats, khatm), already built under a
`v0.8.1` version string. The version number and the feature set have
diverged — see §0.

## 2. Remaining blockers for a real v1.0 release

Blockers = things that must be true before this ships to an app store,
not "nice to have." Sourced from `RELEASE_CHECKLIST.md`'s own
still-open items (independently verified there, not re-derived here)
plus this engagement's `UPDATED_TECHNICAL_DEBT.md`.

### Store & legal (from `RELEASE_CHECKLIST.md`, still open)
- App icon (1024×1024, adaptive Android + iOS set), splash screen,
  store screenshots (iPhone 6.7"/5.5", iPad 12.9", Android
  phone/tablet).
- Privacy Policy URL, Terms of Use, Apple Privacy Manifest
  (`PrivacyInfo.xcprivacy`) + App Privacy labels, Google Play Data
  Safety form.
- Confirm Tanzil's non-commercial translation license terms are
  compatible with the intended release model (free app) — not yet
  formally confirmed.
- Android `applicationId` (`com.duso.qurancompanion`) registered on
  Play Console to match; iOS Apple Developer Program enrollment,
  certificate + profile, TestFlight; Google Play Console internal
  testing track set up.

### Platform completeness (from `RELEASE_CHECKLIST.md`, still open)
- **Web platform is currently broken**: `sqlite3.wasm` and
  `drift_worker.js` are confirmed absent from `web/` — a real web build
  will fail to open the database. Either ship without Web for v1.0 or
  complete this before claiming Web support.
- Background audio playback (`audio_service` + platform manifest
  entries) not implemented — `AudioController` currently only plays in
  foreground.
- Audio cache management UI in Settings not built (the underlying
  `IoCacheManager` engine exists but is never wired in — this is also
  `UPDATED_TECHNICAL_DEBT.md` D5).

### Verification gaps (from `RELEASE_CHECKLIST.md`, still open)
- No real screen-reader (TalkBack/VoiceOver) accessibility audit has
  been run on a device — only functional manual testing and code-level
  review so far.
- `PERFORMANCE.md`'s "Android mid-range device" column is still
  unmeasured — only a Windows-desktop dev-machine number exists
  (161.6ms time-to-first-frame), explicitly flagged in that document as
  not a substitute.
- 16 outdated packages, including 2 major-version gaps
  (`flutter_riverpod` 2→3, `go_router` 14→17) and `sqlite3_flutter_libs`
  marked `+eol` upstream — none upgraded yet; each needs its own
  regression pass before bumping per `README.md`'s dependency-update
  process.
- CI coverage gate is at 70%, not the 80% target `ARCHITECTURE.md`
  states for v1.0 — last measured real coverage was ~74% before this
  engagement's F1–F8 work landed; needs remeasuring now that ~40 files
  and hundreds of tests have been added since.

### Known engineering gaps from this engagement's own audits
- **D3** (`UPDATED_TECHNICAL_DEBT.md`): Read Model (F7) has zero UI
  consumers. Before v1.0, decide: build it a screen, or explicitly
  scope it out of v1.0 as backend-only groundwork for a later release.
  This is a product decision, not an engineering task — it blocks
  nothing technically, but shipping v1.0 without resolving it means
  shipping dead-weight infrastructure knowingly.
- **D8**: a soft-delete filter and an upsert pattern are duplicated
  across 9+ repository files. Not a correctness bug (tests pass,
  behavior is consistent), but real duplication debt — recommended as
  its own dedicated, carefully-regression-tested sprint before v1.0 if
  time allows, not required to ship.
- The 8 Lexicon tables declared in the Drift schema **are now present
  in the shipped `assets/database/quran.sqlite` asset — verified by
  opening the actual asset directly, not just from code comments —
  but every one of them is completely empty (0 rows)**. Code comments
  in three places (`content_tables.dart`, `app_database.dart`,
  `lexicon_repository_impl.dart`) still claim the tables are entirely
  absent and queries would throw "no such table" — that specific
  claim is now stale and should be corrected, since queries will
  actually succeed and just return empty results. The practical
  consequence is unchanged either way: **there is no real Lexicon
  content shipped yet**, so Lexicon/Flashcards (which depends on
  Lexicon) will appear functionally empty on a real install. This
  needs the content pipeline re-run — **this is likely the single
  highest-priority technical blocker for v1.0**, since it affects a
  feature that's otherwise fully built and merged. See
  [DATABASE_REFERENCE.md](../architecture/DATABASE_REFERENCE.md) §1.1
  for the full verification.

## 3. Nice-to-have (does not block v1.0)

- Consolidating the remaining duplicate widgets flagged in
  `UPDATED_TECHNICAL_DEBT.md` D6 (a second empty-state shape
  duplicated 5×, the `_JourneyEntryCard`/`_SmartLearningEntryCard`
  pair) — cosmetic/maintainability, zero user-facing risk either way.
  D10–D14 (minor coupling smells, small perf nits, unused route-constant
  identifiers, eager audio-player construction, type-level
  layer-skipping) — same category.
- `docs/adr/DR-2026-0002-*.md` (Search, Sprint 7.1) is referenced from
  6 places in `lib/` and `CHANGELOG.md` but the file doesn't exist —
  a documentation-completeness gap, not a functional one.
- Recent Searches, Suggestions, Filters, "Ask AI" in Search — UI
  scaffolding exists (empty-state placeholders, a locked "Ask AI" mode
  button) but nothing is wired to real logic yet.
- Hifz mode and the "Nhật ký" (journal) feature named in early roadmap
  notes were never concretely specified beyond a name — treat as v2.0
  candidates, not v1.0 scope creep.

## 4. Recommended release checklist (sequenced)

1. **Documentation reconciliation** (§0) — bump `pubspec.yaml`,
   backfill `CHANGELOG.md` for P1–P4/F1–F8/S2, update `ROADMAP.md`/
   `TODO.md`/`CLAUDE.md` to reflect actual current status. Cheap, and
   every later step benefits from working docs.
2. **Rebuild the content database asset** to include the 8 Lexicon
   tables — the highest-priority technical blocker (§2), since Lexicon/
   Flashcards are otherwise release-ready.
3. **Finish the FTS5 search engine wiring** (`TODO.md` Sprint 7.2 —
   `QuranRepository.searchAyahs` exists and the index is built, it just
   needs to replace the dev-preview static sample data in the Search
   screen). Search is a headline v1.0 feature per `ROADMAP.md`; shipping
   it with only a UI shell would be a visible gap.
4. **Resolve D3** (Read Model UI decision) — quick either way, but
   needs an explicit answer before v1.0 ships.
5. **Remeasure test coverage** and decide whether to raise the CI gate
   toward 80% now that F1–F8's own test suites exist.
6. **Real-device passes**: accessibility (TalkBack/VoiceOver),
   performance (Android mid-range), and the full store/legal checklist
   in §2 — these are the genuinely time-consuming, non-engineering
   items and should be scheduled with that in mind.
7. **Platform scope decision**: ship Web for v1.0 (requires the
   `sqlite3.wasm`/`drift_worker.js` fix) or explicitly defer Web to a
   later release and say so in store listings.
8. **Dependency upgrade pass** (16 outdated packages, 2 major
   versions) — do this deliberately, with its own regression cycle, not
   folded into a feature release.
9. Everything in §3 — pick up opportunistically, none of it gates
   ship.

This sequencing front-loads the cheap, high-leverage items (docs,
Lexicon DB asset, search wiring, the D3 decision) before the expensive,
manual, device-dependent verification work in step 6 — so that manual
testing happens against a build that's actually feature-complete, not
one that needs another round after.
