# Phase 3 — Sprint R1 Plan

Planning only. No production code was written or modified to produce
this document; no commit was created. Synthesized from a fresh read of
`RELEASE_DASHBOARD.md` (repo root — see note below), `docs/release/RELEASE_PLAN_V1.md`,
`docs/release/PRODUCT_ROADMAP.md`, `docs/architecture/MASTER_ARCHITECTURE.md`,
`docs/architecture/MODULE_CATALOG.md`, `docs/architecture/PROVIDER_MAP.md`,
`docs/testing/TESTING_GUIDE.md`, plus a targeted, read-only look at
`tool/build_quran_db.py` and `tool/fetch_morphology.py` (necessary to
verify a claim below — no code was changed).

**Path note**: this task named `docs/release/RELEASE_DASHBOARD.md`.
That file actually lives at the repo root (`RELEASE_DASHBOARD.md`),
matching where every prior sprint deliverable in this engagement was
placed. Same document, different path than named — read from its
actual location.

---

# Sprint Goal

Wire Qur'an Companion's existing, working full-text search engine
(`ayahSearchProvider`, FTS5-backed, currently reachable only from
`SurahListScreen`) into the dedicated `SearchScreen` — so the Search
tab, for the Search-mode / Qur'an-scope combination, returns real Ayah
results instead of doing nothing. This closes the gap `PRODUCT_ROADMAP.md`
names as "the one clearly-visible 'UI exists, logic doesn't' gap a
real user would notice immediately."

---

# Why this blocker comes first

`RELEASE_DASHBOARD.md` and `RELEASE_PLAN_V1.md` both nominally rank
the **Lexicon data gap** (8 tables exist, shipped asset has 0 rows) as
the single highest-priority Critical blocker, ahead of Search wiring.
Reading the actual pipeline code before accepting that ranking at face
value surfaced something neither document states explicitly:

**The Lexicon gap is not an engineering task waiting to be picked up —
it's a genuine, already-investigated licensing conflict with no
resolution yet.** `tool/fetch_morphology.py`'s own doc comment (dated
to this project's Sprint 12, Phase 2.6/2.7/3) states that the Quranic
Arabic Corpus morphology data — the only real source for
Root/Lemma/WordInstance content — is distributed under terms that say
*"Permission is granted to copy and distribute verbatim copies of this
file, but CHANGING IT IS NOT ALLOWED,"* while the pipeline this project
needs *requires* transforming that data (segments → `WordInstance` →
`Lexeme` records) before it can go into `quran.sqlite`. On top of that,
the data can only be obtained by a human manually filling in a real
email on a third-party form at `corpus.quran.com` — there is no static
URL an automated script can fetch, and `fetch_morphology.py` is
deliberately written to *not* attempt this ("an automated agent should
not fill in a third party's contact form on someone's behalf"). This
is a **decision problem for the project owner** (accept the license
conflict in writing, negotiate/request explicit permission, or source
a different, license-compatible morphology dataset) — not something an
implementation sprint can close by writing more code, and not
something this planning document can decide on the project owner's
behalf either.

Committing R1 to "populate Lexicon" would mean opening a sprint that
cannot actually be finished by engineering work alone. The next
Critical/High item in the same blocker list — **Search wiring** — has
no such external dependency: `PROVIDER_MAP.md` §1.13 confirms the real
FTS5 engine (`ayahSearchProvider`, debounced, tested, used daily by
`SurahListScreen`) already exists and works correctly today. It is
simply attached to the wrong screen. This is a bounded, purely-internal
task, matches an architectural pattern this codebase already uses
elsewhere (bridging two features at the Provider layer — see
`flashcardSchedulerSyncProvider` in `MASTER_ARCHITECTURE.md` §3), and
requires no schema change, no external data, and no decision outside
engineering's own control. It is the highest-priority blocker that is
actually *actionable* in a single sprint — which is what R1 should be.

The Lexicon licensing decision is not dropped; it's named explicitly
under **Follow-up Sprint** below so it stays visible and doesn't get
silently lost.

---

# Scope

- Wire real FTS5 search results into `SearchScreen` for the
  **Search mode × Qur'an scope** combination only (the one combination
  with an existing, working engine to reuse).
- Give the Search feature its own, independent query-state provider —
  **not** a reuse of `surahSearchQueryProvider` as-is (see Risks: that
  provider is shared with `SurahListScreen`'s own search box today).
- Wire result-tap navigation to the Reading screen, reusing
  `reading_navigation.dart` (already an existing `search/` → `quran/`
  dependency per `MODULE_CATALOG.md`).
- Add or extend tests per `TESTING_GUIDE.md`'s established provider/
  widget-test conventions for whatever is built.
- Any new user-facing strings added to all three `lib/l10n/app_{vi,en,ar}.arb`
  files in the same change (per `CLAUDE.md`'s Definition of Done).

# Out of Scope

- **"My Notes" and "All" search scopes.** No existing engine covers
  them — the FTS5 `search_index` virtual table (`tool/build_quran_db.py`)
  is built only from Arabic/transliteration/translation content
  (Group A). Searching notes/highlights would need a different query
  path against `UserContentRepository`, not a reuse of the Qur'an FTS5
  index. Left for a follow-up sprint, not silently half-built here.
- **"Ask" mode.** Per `PRODUCT_ROADMAP.md` v2.0, this is the reserved
  slot for a future real AI/RAG integration — genuinely new capability,
  not a continuation of anything built today. Not touched.
- **The Lexicon data-population blocker.** Explicitly deferred — see
  "Why this blocker comes first" and "Follow-up Sprint."
- **Any database schema change.** This sprint reuses `AppDatabase`'s
  existing `search_index` FTS5 table and `QuranRepository.searchAyahs()`
  as-is. If implementation discovers a schema change is actually
  needed, that crosses `CLAUDE.md`'s "stop and ask before" list
  (`PROJ-P-002`) and is out of this plan's scope.
- **Read Model (D3), coverage-gate changes, dependency upgrades, Web
  platform, store readiness.** All real per `RELEASE_PLAN_V1.md`, all
  unrelated to Search — left for their own sprints per
  `RELEASE_DASHBOARD.md`'s R2–R5 plan.
- **Refactoring anything not directly required to wire Search.** In
  particular, `surah_list_controller.dart`'s existing ayah-search logic
  is not to be rewritten — only, at most, read from or called by new
  code (see Estimated implementation order, step 1, for the two options
  this decision has).

---

# Existing architecture affected

Per `MASTER_ARCHITECTURE.md` and `MODULE_CATALOG.md`:

- **`search/` feature** — currently has no `data/` directory at all
  (presentation-only, per `MODULE_CATALOG.md`). This sprint gives it
  its first one. This is new code inside an existing, empty seam, not
  a restructuring of anything that currently exists.
- **`quran/` feature** — `QuranRepositoryImpl` (AppDatabase, Group A,
  read-only) already exposes `searchAyahs()`, already wrapped by the
  reliability layer's `withFailureLogging` (per `MASTER_ARCHITECTURE.md`
  §2.1/§2.2 — all 9 database-backed repositories are). No new
  repository-boundary error handling is needed; this sprint only adds
  a new *caller* of an already-instrumented method.
- **Design principle 9** (`MASTER_ARCHITECTURE.md` §5): "two
  independently-owned repositories are bridged only at the Provider
  layer, never through a direct repository→repository dependency" —
  this sprint follows that precedent exactly: `search/` gets its own
  provider(s) that watch `quranRepositoryProvider`, the same shape as
  `flashcardSchedulerSyncProvider` bridging `flashcards/` and
  `learning/`.
- **Design principle 2** (`MASTER_ARCHITECTURE.md` §5): "UI never
  accesses repositories directly — only the feature's own narrow
  provider set." `search_screen.dart` must consume `search/`-owned
  providers, not reach into `quranRepositoryProvider` directly from
  the widget tree.
- **Does not touch**: the 5-tier AI/learning composition chain, the
  dual-database split boundary (this sprint stays entirely inside
  Group A / read-only), or `UserDatabase` in any way.

# Files expected to change

| File | Change |
|---|---|
| `lib/features/search/data/search_providers.dart` (**new**) | `search/`'s first `data/` file — new query-state provider + new results provider, independent of `surahSearchQueryProvider`. |
| `lib/features/search/presentation/search_screen.dart` | Wire Search-mode/Qur'an-scope UI to the new providers; existing local widget state (mode/scope/dev-preview switcher) remains for everything this sprint doesn't touch. |
| `lib/features/search/presentation/widgets/result_card.dart` | Confirm/adjust to render real `AyahSearchResult` data (currently exists per the file tree; exact change depends on what it renders today — to be confirmed at implementation time, not assumed here). |
| `lib/features/search/presentation/widgets/search_result_section.dart` | Same as above. |
| `lib/l10n/app_vi.arb`, `app_en.arb`, `app_ar.arb` | Any new strings this sprint's UI needs (e.g. differentiated "no results" messaging), added to all three in the same change. |
| `test/search_screen_test.dart`, `test/search_result_section_test.dart`, `test/search_accessibility_test.dart`, `test/search_dark_mode_test.dart`, `test/search_responsive_test.dart` | Existing test files (per current `test/` contents) — extended/updated for real-data assertions. |
| A new provider-layer test file (e.g. `test/search_providers_test.dart`) | New — covers the new query/results providers per `TESTING_GUIDE.md` §1.3's `ProviderContainer` pattern. |

Files explicitly **not** expected to change: anything under
`lib/features/quran/` (the existing `ayahSearchProvider` and
`surahSearchQueryProvider` are read, not modified — see Risks and
Estimated implementation order for why), any `*_repository_impl.dart`,
any database table/migration file.

# Providers affected

- **Read, not modified**: `quranRepositoryProvider` (`quran/`) —
  this sprint's new provider(s) call `QuranRepository.searchAyahs()`
  through it, same as `ayahSearchProvider` does today.
- **Read, not modified, for reference only**: `ayahSearchProvider` and
  `surahSearchQueryProvider` (`quran/presentation/surah_list_controller.dart`)
  — these stay exactly as they are; `SurahListScreen`'s own search box
  keeps working unchanged.
- **New** (`search/`, exact naming an implementation decision, not
  prescribed here): a query-state provider scoped to `search/` (e.g.
  `StateProvider<String>`, analogous in shape but *not* the same
  instance as `surahSearchQueryProvider`), and a
  `FutureProvider.autoDispose<List<AyahSearchResult>>` that debounces
  and calls `quranRepositoryProvider.searchAyahs()` — the same
  responsibility `ayahSearchProvider` has today, independently owned
  by `search/` instead of shared with `quran/`.

# Database impact

**None.** No new table, no migration, no `schemaVersion` bump on
either `AppDatabase` or `UserDatabase`. This sprint is scoped
specifically to avoid `CLAUDE.md`'s "stop and ask before" schema-change
trigger (`PROJ-P-002`) — it reuses the FTS5 `search_index` virtual
table and `QuranRepository.searchAyahs()` exactly as they exist today.

---

# Risks

1. **Query-state coupling risk.** `ayahSearchProvider` is currently
   `FutureProvider.autoDispose` (not `.family`) and reads
   `surahSearchQueryProvider` internally — the *same* query text
   `SurahListScreen`'s own search box writes to. Reusing it as-is
   inside `SearchScreen` would silently couple two independent
   screens' search boxes together (typing in one would affect the
   other). This must be resolved architecturally (an independent
   query-state provider for `search/`), not discovered as a bug after
   the fact.
2. **Regression risk to a working, tested screen.** `SurahListScreen`'s
   search-as-you-type is real, working, production behavior today.
   Any extraction of shared query logic (see Estimated implementation
   order, step 1, option A) risks regressing it. `test/surah_list_screen_test.dart`
   must stay green, unmodified in intent, throughout.
3. **Scope-boundary risk.** `SearchScope` already offers "My Notes" and
   "All" as UI options (per `MODULE_CATALOG.md`) with no backing engine
   for either. If R1 doesn't clearly leave these non-functional/visibly
   incomplete, there's a risk of shipping a scope selector where 2 of 3
   options look finished but silently do nothing.
4. **Debounce behavior under a new UI rhythm.** The existing ~250ms
   debounce was tuned for `SurahListScreen`'s usage; `SearchScreen`'s
   mode/scope switches are a different interaction shape and need
   verifying, not assumed identical.
5. **l10n gate risk.** Any new string not added to all three `.arb`
   files in the same change violates `CLAUDE.md`'s Definition of Done
   and would fail this project's own established gate.
6. **Under-scoping risk in the other direction.** If `result_card.dart`/
   `search_result_section.dart` already fully support real
   `AyahSearchResult` rendering (built in Sprint 7.1's UI-foundation
   pass but never fed real data), the actual remaining work could be
   smaller than the Files table above assumes — this plan treats that
   table as an upper bound to confirm at implementation time, not a
   guaranteed diff.

---

# Testing strategy

Per `TESTING_GUIDE.md`'s established conventions — no new pattern
introduced:

- **New query/results providers** → plain `test()` with a bare
  `ProviderContainer` and `quranRepositoryProvider.overrideWithValue(...)`
  using a hand-written fake `implements QuranRepository` (no mocking
  framework — none exists in this project's `dev_dependencies`),
  following the shape in `test/khatm_cycle_providers_test.dart`/
  `test/daily_goal_providers_test.dart` (§1.3). Cover: empty query →
  no results without erroring; debounce behavior; query change
  produces new results; provider is independent of
  `surahSearchQueryProvider` (a test that changes one and asserts the
  other is unaffected is the direct regression guard for Risk 1).
- **`SearchScreen` widget tests** → `testWidgets()` with an isolated
  single-route `GoRouter` + `ProviderScope` overrides, following
  `test/quiz_session_screen_test.dart`'s shape (§3.4); assert real
  result rendering replaces the current placeholder/empty state for
  Search-mode/Qur'an-scope, and that My Notes/All/Ask remain
  unaffected (still non-functional, per Out of Scope).
- **Regression guard**: re-run `test/surah_list_screen_test.dart` and
  any existing test currently covering `ayahSearchProvider` unmodified
  — must stay green with zero changes to their own assertions.
- **Fakes**: any new fake follows §3.5's convention — `implements
  QuranRepository` directly, methods irrelevant to the test under
  `throw UnimplementedError()`, an explicit mutator method if the fake
  needs to be "poked" mid-test.
- **Vietnamese test descriptions** (§3.6) and a `'Sprint R1'` traceability
  tag (§3.7) on new tests, matching every prior sprint's convention in
  this suite.
- **No database schema test needed** — this sprint doesn't touch
  `AppDatabase`'s schema, so no new migration test applies (§3.3
  applies only if that changes, which it shouldn't per Database impact
  above).

---

# Acceptance Criteria

1. Typing a query into `SearchScreen` in Search mode, Qur'an scope,
   returns real Ayah results from the existing FTS5 index — no
   placeholder or dummy data.
2. Typing in `SearchScreen`'s search box does not change
   `SurahListScreen`'s own search box state, and vice versa (query
   state is independently owned).
3. Tapping a result navigates to the correct Ayah in the Reading
   screen via the existing `reading_navigation.dart` helper.
4. My Notes / All / Ask remain visibly non-functional (locked,
   disabled, or otherwise clearly not claiming to work) — not silently
   broken-looking finished UI.
5. `SurahListScreen`'s existing search/filter behavior is byte-for-byte
   unchanged; its existing tests pass without modification to their
   assertions.
6. Every new/changed user-facing string exists in `app_vi.arb`,
   `app_en.arb`, and `app_ar.arb`.
7. `dart format`, `flutter analyze --fatal-infos`, and
   `flutter test --coverage` all run clean.

# Definition of Done

- All Acceptance Criteria met.
- Diff matches the "Files expected to change" table, or this plan is
  updated first to explain a material deviation.
- Zero schema change to `AppDatabase` or `UserDatabase`.
- Zero behavior regression in `quran/` (`SurahListScreen`, `ReadingScreen`).
- New/changed tests per Testing Strategy; full suite green.
- Each logical change in its own commit, per `CONTRIBUTING.md`'s
  established convention for this project (matching how Sprint S2 was
  run).
- `docs/release/UPDATED_TECHNICAL_DEBT.md` and `RELEASE_DASHBOARD.md`
  updated afterward to reflect Search as wired — a documentation
  follow-up once R1 code lands, not part of this planning document.

---

# Estimated implementation order

1. **Decide query-logic ownership** (a real design decision to make
   *before* writing code, not while writing it): **(A)** extract the
   existing FTS5 query function out of `surah_list_controller.dart`
   into a shared, reusable helper both `quran/` and `search/` call with
   their own independent state, or **(B)** leave `quran/` completely
   untouched and write a new, independent implementation in `search/data/`
   that calls `quranRepositoryProvider.searchAyahs()` directly with its
   own debounce logic. **(B) is the lower-risk default** — it touches
   zero existing, working files — unless the query logic turns out to
   be large enough that duplicating it is worse than the extraction
   risk. This plan recommends starting with (B).
2. Add `lib/features/search/data/search_providers.dart`: a `search/`-owned
   query-state provider + a debounced results provider calling
   `quranRepositoryProvider.searchAyahs()`.
3. Wire `search_screen.dart`'s Search-mode/Qur'an-scope path to the new
   providers; leave every other mode/scope combination exactly as it
   is today.
4. Wire result-tap → `reading_navigation.dart` (reuse only, no new
   navigation code).
5. Add any new l10n keys to all three `.arb` files.
6. Write the new provider-layer test(s), including the Risk-1
   independence regression test.
7. Update the existing `search_screen_test.dart` and sibling widget
   tests for real-data assertions.
8. Run full gates (`dart format`, `flutter analyze --fatal-infos`,
   `flutter test --coverage`); explicitly re-run/confirm
   `test/surah_list_screen_test.dart` shows zero diff in behavior.
9. Update `docs/release/UPDATED_TECHNICAL_DEBT.md` and
   `RELEASE_DASHBOARD.md` in a separate, final commit.

---

# Follow-up Sprint

Candidates for R2, in the priority order `RELEASE_DASHBOARD.md`'s
sprint plan implies, adjusted for this sprint's findings:

- **Lexicon licensing decision.** Not an engineering sprint — a
  product/ownership decision: accept the Quranic Arabic Corpus license
  conflict in writing, formally request permission for the required
  transform step, or source a different, license-compatible morphology
  dataset. Once *that* decision is made, the follow-on engineering work
  (wiring `tool/fetch_morphology.py` + `tool/lexicon/*` — both already
  built — into `tool/build_quran_db.py`'s currently-empty Lexicon
  population step) is comparatively small, since the pipeline code
  already exists and only needs real, license-clear input data.
- **Search: "My Notes" and "All" scopes.** Needs a new query path
  against `UserContentRepository` (notes/highlights) — likely a simple
  in-memory filter given per-user data volume, not FTS5. Separate
  design decision from R1's Qur'an-scope wiring.
- **Search polish** (Recent Searches, Suggestions, Filters) — per
  `PRODUCT_ROADMAP.md` v1.1, UI scaffolding already references these
  by name; no logic behind them yet.
- **Read Model UI decision (D3)** — unrelated to Search; its own
  product decision per `RELEASE_PLAN_V1.md`.
- Everything else in `RELEASE_DASHBOARD.md`'s R2–R5 (verification,
  store readiness, dependency upgrades) unaffected by this reordering.

---

READY FOR R1 IMPLEMENTATION
