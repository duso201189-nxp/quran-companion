# Phase 3 — Sprint R1 Design Review: Search

Design review only. No production code was written or modified; no
commit was created; nothing was refactored. Every claim below was
verified by reading the actual current source, not inferred from
`docs/architecture/` summaries — file paths and line-level behavior
are cited directly. Companion document to
[PHASE3_SPRINT_R1_PLAN.md](PHASE3_SPRINT_R1_PLAN.md), which this
review supersedes on implementation-level detail (the plan stays
authoritative for scope/sequencing).

Files read in full to produce this review:
`lib/features/search/presentation/search_screen.dart`,
`lib/features/search/presentation/widgets/{result_card,search_result_section,search_error_state}.dart`,
`lib/features/quran/presentation/surah_list_controller.dart`,
`lib/features/quran/presentation/reading/reading_navigation.dart`,
`lib/features/quran/domain/entities/ayah_search_result.dart`,
`lib/features/quran/domain/repositories/quran_repository.dart`,
`lib/features/quran/data/quran_repository_impl.dart` (search path),
`lib/features/quran/data/fts_query.dart`,
`lib/core/database/tables/content_tables.dart`,
`test/search_screen_test.dart`, `test/fixtures/search_test_harness.dart`,
`test/search_test.dart`.

---

# 1. Current architecture

**`SearchScreen`** (`lib/features/search/presentation/search_screen.dart`)
is a `ConsumerStatefulWidget` with **entirely local widget state**:
`_queryController` (`TextEditingController`), `_mode` (`SearchMode`),
`_scope` (`SearchScope`), `_devPreview` (`_DevPreviewState`, debug-only).
It does not `ref.watch` any search-data provider today. `_buildBody()`
has exactly three outcomes:

1. If `kDebugMode` and a dev-preview state other than `.real` is
   selected → render one of the four presentational widgets fed
   **static sample data** (`_devPreviewResults`, a hardcoded 3-item
   `List<AyahSearchResult>`).
2. Else, if the query field is empty → `SearchEmptyState`.
3. Else (a real, non-empty query, in both release builds and debug
   builds with preview off) → **`SizedBox.shrink()`** — literally
   nothing is rendered. This is the exact bug this sprint exists to
   fix, and `test/search_screen_test.dart` (Task 7.1.5, lines 119–129)
   currently asserts this as correct behavior — see §11 and §14.

Four presentational widgets already exist, are fully built, and are
already proven correct by the dev-preview-driven test suite:
`SearchEmptyState`, `SearchLoadingSkeleton`, `SearchErrorState`
(`widgets/search_error_state.dart`), `SearchResultSection` with an
`.ayahs()` factory (`widgets/search_result_section.dart`), and
`ResultCard` with a `.fromAyah()` factory
(`widgets/result_card.dart`). Result-tap navigation is **already
wired and already correct**: the dev-preview "Results" state's tap
handler calls `openAyahInReadingScreen(context, ref, surahId:,
ayahNumber:)` — the real, shared navigation helper — not a stub.

One feature directory away, a **complete, working, tested FTS5 search
engine already exists**, just not reachable from `SearchScreen`:

- `ayahSearchProvider` (`lib/features/quran/presentation/surah_list_controller.dart:35-43`)
  — `FutureProvider.autoDispose<List<AyahSearchResult>>`. Reads
  `ref.watch(surahSearchQueryProvider)` (a plain `StateProvider<String>`,
  **owned by and shared with `SurahListScreen`'s own filter box** —
  not a `.family`, not independent). Returns `const []` if the trimmed
  query is under 2 characters. Debounces 250ms via `Future.delayed`,
  then re-checks `ref.read(surahSearchQueryProvider)` against the
  original query before proceeding, discarding stale results.
- `QuranRepository.searchAyahs(String query, {int limit})`
  (`quran_repository.dart:30`) → `QuranRepositoryImpl.searchAyahs()`
  (`quran_repository_impl.dart:143-165`) — already wrapped in
  `withFailureLogging` (the reliability layer's single choke point).
  Builds a MATCH expression via the pure, unit-tested
  `ftsMatchExpression()` (`fts_query.dart`), runs a raw `customSelect`
  against the FTS5 virtual table `search_index`
  (`SELECT DISTINCT ayah_id FROM search_index WHERE search_index
  MATCH ? AND source_code IN (...) ORDER BY ayah_id LIMIT ?`), then
  hydrates headers via `_headersForIds()` (3 further Drift queries:
  `Ayahs` by id, `Surahs` by id, `Translations` joined
  `TranslationSources` filtered to `vi_main`/`en_sahih`).
- `ftsMatchExpression()` (`fts_query.dart`) is a pure, already-tested
  function: strips quotes/asterisks (FTS5 syntax injection
  protection), folds Latin diacritics or Arabic harakat depending on
  script, builds AND-of-prefix-match tokens, and adds an OR-branch for
  the Arabic alef/alef-wasla (ا/ٱ) variant. `test/search_test.dart`
  covers this directly, and separately runs `searchAyahs()` against
  the **real shipped asset** (`assets/database/quran.sqlite`,
  skip-guarded if the asset isn't built locally) proving Vietnamese
  (with/without diacritics), Arabic, and English queries all return
  correct, Mushaf-ordered results **today**.
- The FTS5 index (`search_index`, defined in `tool/build_quran_db.py`)
  is built only from Arabic/transliteration/translation content
  (Group A). It has no coverage of user notes/highlights — confirmed
  by reading the schema directly, not assumed.

`search/` has **no `data/` directory today** — confirmed by directory
listing, matching `docs/architecture/MODULE_CATALOG.md`'s claim.

# 2. Desired architecture

`search/` gains its first `data/` file,
`lib/features/search/data/search_providers.dart`, owning:

- A query-state provider **independent of `surahSearchQueryProvider`**
  — same shape (`StateProvider<String>`), different instance, scoped
  to `search/`.
- A results provider — same responsibility and debounce contract as
  `ayahSearchProvider`, but watching the new query provider instead:
  `FutureProvider.autoDispose<List<AyahSearchResult>>` →
  `ref.watch(quranRepositoryProvider).searchAyahs(query)`. This calls
  the **exact same, unmodified** `QuranRepositoryImpl.searchAyahs()`
  that `SurahListScreen` already uses in production — no new
  repository code, no new SQL, no new reliability wrapping needed.

`SearchScreen._buildBody()`'s third branch (currently
`SizedBox.shrink()`) becomes an `AsyncValue`-driven switch over the
new results provider, reusing the four already-built presentational
widgets — plus one genuinely new state (see §8). The query text
field's `onChanged` gains a second responsibility: writing into the
new query provider, in addition to its existing `setState(() {})`
for clear-button visibility. `SearchMode.search × SearchScope.quran`
is the only combination wired; every other mode/scope selection keeps
today's behavior exactly (visually selectable, functionally inert),
per `PHASE3_SPRINT_R1_PLAN.md`'s scope.

# 3. Exact provider flow

```
_queryController (SearchScreen, onChanged)
  -> writes text into: searchQueryProvider (NEW, search/data/)
       [StateProvider<String>, independent of surahSearchQueryProvider]

searchResultsProvider (NEW, search/data/)
  [FutureProvider.autoDispose<List<AyahSearchResult>>]
  -> ref.watch(searchQueryProvider)
  -> if trimmed.length < 2: return const [] immediately
  -> await Future.delayed(250ms)
  -> re-check: query still == ref.read(searchQueryProvider)? else return const []
  -> ref.watch(quranRepositoryProvider).searchAyahs(query)

quranRepositoryProvider (EXISTING, quran/data/quran_providers.dart)
  -> QuranRepositoryImpl.searchAyahs(query)
       -> withFailureLogging(_logger, 'searchAyahs', () async { ... })
       -> ftsMatchExpression(query) -> null? return const []
       -> customSelect(FTS5 MATCH ... search_index ...) -> ayah_id list
       -> _headersForIds(ids) -> List<AyahSearchResult>

SearchScreen
  -> ref.watch(searchResultsProvider)  // AsyncValue<List<AyahSearchResult>>
  -> .when(loading: ..., error: ..., data: ...)
```

This mirrors `ayahSearchProvider`'s existing, already-correct shape
exactly — the only structural difference is which `StateProvider`
supplies the query text.

# 4. UI event flow

1. User taps the search icon (Home or `SurahListScreen`) →
   `SearchScreen` pushed. **Unaffected by this sprint.**
2. User types in the `SearchBar`'s internal `TextField` → `onChanged`
   fires → existing `setState(() {})` (clear-button visibility, kept)
   **and** a new write to `searchQueryProvider`.
3. Mode segmented button / Scope chips remain independent local state
   — unaffected; selecting a scope other than the implicit
   Qur'an-search path this sprint wires is still a visual-only,
   no-op change (Out of Scope, per the sprint plan).
4. Clear button tap → `_queryController.clear()` + existing
   `setState` **must also** reset `searchQueryProvider` back to `''`
   — a new wiring point; missing it leaves stale results on screen
   after the visible field is cleared (see §14, risk 4).
5. Result tap → **unchanged**: `openAyahInReadingScreen(context, ref,
   surahId:, ayahNumber:)`, already correct, already tested via the
   dev-preview path (`test/search_screen_test.dart` Task 7.1.14).
6. Dev-preview switcher (`kDebugMode` only) — **fully orthogonal,
   untouched**. Remains available for manual QA of all five states
   after real wiring lands, since it forces `_buildBody()`'s first
   branch regardless of the real provider's state.

# 5. Data flow

```
keystroke
  -> TextEditingController (SearchScreen, local)
  -> searchQueryProvider (search/, NEW)
  -> [debounce 250ms + staleness re-check]
  -> QuranRepository.searchAyahs()  (quran/, Group A, AppDatabase, read-only)
  -> raw FTS5 MATCH SQL against `search_index`
       (built at pipeline time by tool/build_quran_db.py from
        Tanzil Arabic Uthmani + QuranEnc Vietnamese + Tanzil English
        Sahih + transliteration — NOT Lexicon data, an unrelated
        blocker, see PHASE3_SPRINT_R1_PLAN.md "Why this blocker
        comes first")
  -> DISTINCT ayah_id list, Mushaf order, LIMIT 40 default
  -> header hydration: Ayahs.isIn(ids), Surahs.isIn(surahIds),
     Translations join TranslationSources (vi_main, en_sahih)
  -> List<AyahSearchResult>
  -> withFailureLogging: success path returns the value unchanged
  -> searchResultsProvider resolves -> AsyncValue.data(results)
  -> SearchResultSection.ayahs(results:, query:, onResultTap:)
  -> ResultCard.fromAyah(result, highlightQuery: query) per item
       -> highlightSpans() (shared/utils/highlight.dart, REUSED AS-IS)
          bolds/colors the matched substring in Arabic + translation
  -> tap -> reading_navigation (existing, unchanged)
```

No new table, no new query shape, no new database connection — this
sprint is entirely new *wiring* around fully existing *data flow*.

# 6. Error flow

Any exception inside `searchAyahs()` (e.g. a corrupted/missing asset,
or a Drift/SQLite error) is caught by `withFailureLogging`:
`mapToAppFailure` classifies it (a Drift exception → `category:
database`), `Logger.error()` logs it and forwards to `CrashReporter`
(today `NoopCrashReporter` — zero behavior change), then **the
original error is rethrown unchanged** — the reliability layer's
explicit contract, "only diagnostics improve." That rethrow
propagates up through the new `FutureProvider.autoDispose`, which
Riverpod wraps into `AsyncValue.error(err, stack)`.

`SearchScreen`'s `AsyncValue.when(error: ...)` branch renders
**`SearchErrorState`** — the exact widget already built and already
proven correct by the dev-preview "Error" test group
(`test/search_screen_test.dart`, Task 7.1.13). No new error-UI
component is needed. The only new code is the `onRetry` callback's
body: today it resets `_devPreview` to `.real`; the real-wiring
version calls `ref.invalidate(searchResultsProvider)`.

`ftsMatchExpression()`'s existing sanitization (stripping `"`/`*`
before building the MATCH clause) already prevents FTS5 syntax
errors from special characters in user input — this sprint should add
a defensive test confirming the new provider path doesn't bypass that
protection (see §11), not add new sanitization code.

# 7. Loading flow

While the new provider is pending — during the 250ms debounce window
and the query's actual execution — `AsyncValue.loading()` is active
and `SearchScreen` renders **`SearchLoadingSkeleton`**, already built,
already proven correct by the dev-preview "Loading" tests. Because
the provider is `.autoDispose` `FutureProvider` (not `.family`), every
new query recreates a fresh future; the existing
debounce-then-staleness-recheck technique (copied from
`ayahSearchProvider`) prevents a slow, now-stale in-flight query from
overwriting a newer query's result — the same protection
`ayahSearchProvider` already relies on in production today.

# 8. Empty state flow

Two genuinely different conditions exist and **must not be
conflated**:

**(a) Nothing typed yet.** Today's `SearchEmptyState` (title,
typing-hint subtitle, placeholder "Recent"/"Suggested" sections) is
correct and unchanged — the right widget whenever
`query.trim().isEmpty`.

**(b) A real query was typed and FTS5 returned zero rows.** No
existing widget represents this correctly. `SearchEmptyState`'s copy
— "here's how to search" plus placeholder Recent/Suggested sections —
is actively misleading for someone who *already searched* and got
nothing; reusing it verbatim would ship confusing UX, not a clean
reuse. **This is a genuinely new state, not covered by any of the
four widgets reviewed above.** This review recommends a small,
dedicated "no results for '{query}'" surface (implementation decides
the exact shape — a new lightweight widget, or a parameterized mode
on an existing one — but not a silent reuse of `SearchEmptyState` as
a stand-in). This is the one place in this sprint where new UI, not
just new wiring, is genuinely required.

A third sub-case worth naming: a query of 1 character (below the
2-character threshold both providers share) resolves to `const []`
immediately, with no debounce and no real "search attempted." This
should most naturally read as case (a), not case (b) — showing "no
results" for a single keystroke would be a false signal. Implementers
should treat "query non-empty but under threshold" as the empty-state
branch, not the no-results branch.

# 9. Performance considerations

- The 250ms debounce is inherited from the already-proven
  `ayahSearchProvider` pattern — no new tuning needed for this sprint;
  real-device latency verification is `RELEASE_PLAN_V1.md`'s separate
  "real-device verification" blocker, out of this sprint.
- The FTS5 query itself (`DISTINCT ayah_id ... ORDER BY ayah_id LIMIT
  40`) runs against an indexed virtual table already exercised in
  production via `SurahListScreen` daily, with no known performance
  issue — this sprint adds a second call site, not a new query shape.
- Header hydration costs 3 additional Drift queries per search — the
  exact same cost `ayahSearchProvider` already pays; not new overhead
  introduced by this sprint.
- `.autoDispose` on the new provider releases memory the moment
  `SearchScreen` is popped, matching this codebase's established
  convention for screen-scoped async data.
- A genuine **positive** performance/correctness property of the
  independent-provider design (§2): typing in `SearchScreen` cannot
  trigger redundant recomputation in `SurahListScreen` (or vice
  versa), because the two query providers are separate. Reusing
  `surahSearchQueryProvider` directly would have introduced exactly
  this cross-screen recomputation cost.
- `appDatabaseProvider` (the underlying content-DB connection) is
  already a lazily-opened, app-lifetime `Provider<AppDatabase>` — this
  sprint opens no new connection.

# 10. Accessibility considerations

- All four reused presentational widgets already carry verified
  semantics: `Semantics(header: true)` on section titles
  (`SearchEmptyState`'s two section headers, `SearchResultSection`'s
  count-labeled title), `liveRegion: true` on both
  `SearchLoadingSkeleton`'s "Đang tìm kiếm..." announcement and
  `SearchErrorState`'s error announcement, `ExcludeSemantics` on
  decorative skeleton bars/placeholder chips, and a single collapsed
  `Semantics.label` per `ResultCard` (source + primary + secondary
  text joined) with `excludeSemantics: true` to prevent double-reading
  child text nodes. `test/search_accessibility_test.dart` already
  covers touch target ≥48dp, RTL, 200% text scale, reading order, and
  absence of redundant semantics for all of these, passing today under
  dev-preview. This sprint's job is to make real state reach these
  widgets, not to redesign any accessibility behavior.
- The one genuinely **new** UI surface (§8's "no results" state) must
  get the same treatment *before* it ships, not as a follow-up: a
  `liveRegion`-announced message so a screen reader hears "no results
  for X" the moment a real query resolves empty — the same pattern
  `SearchLoadingSkeleton`/`SearchErrorState` already use, just applied
  to a new case.
- RTL for Arabic queries is already handled end-to-end
  (`ftsMatchExpression`'s Arabic branch, `ResultCard.fromAyah`'s
  `primaryTextDirection: TextDirection.rtl`) — no new RTL work for
  existing states, but the new "no results" copy must go through
  `AppLocalizations` in all three `.arb` files like everything else in
  this screen, and should be exercised under the Arabic locale the
  same way `search_accessibility_test.dart` already does for the
  other four states.

# 11. Test plan

- **New** `test/search_providers_test.dart` — bare `ProviderContainer`
  + `quranRepositoryProvider.overrideWithValue(_FakeQuranRepo())` (a
  hand-written fake `implements QuranRepository`, untested methods
  `throw UnimplementedError()`, per `TESTING_GUIDE.md` §3.5). Cases:
  empty query → no repository call, empty result; query under 2
  characters → empty result, repository never invoked (assert via a
  call-counting fake); debounce correctness (query changes twice in
  quick succession → only the final query's result survives — a test
  `ayahSearchProvider` itself never got, worth adding here since the
  new provider copies its untested-but-relied-upon contract);
  **independence from `surahSearchQueryProvider`** — the direct
  regression guard for §1's coupling risk: write to one provider,
  assert the other is completely unaffected.
- **Rewrite, not just extend**, `test/search_screen_test.dart`'s Task
  7.1.5 test at lines 119–129 ("gõ chữ chưa gọi truy vấn hay hiển thị
  kết quả nào" / "typing doesn't trigger a query or show results") —
  this test currently encodes the bug this sprint fixes as correct
  behavior. Replace with: typing a ≥2-character query shows
  `SearchLoadingSkeleton` then real results; typing <2 characters
  shows neither loading nor results (still empty state); clearing the
  query returns to `SearchEmptyState` **and clears any visible
  results** (the clear-button wiring point from §4.4).
- **New** widget-test coverage for the "no results" state (§8): a
  query that resolves to zero rows renders the new dedicated widget —
  not `SearchEmptyState`, not a blank screen, not
  `SearchLoadingSkeleton` left stuck.
- **Regression, expect zero diff**: `test/surah_list_screen_test.dart`
  — confirms `ayahSearchProvider`/`surahSearchQueryProvider` were not
  touched. Also re-run `test/search_result_section_test.dart`,
  `test/result_card_test.dart`, `test/search_error_state_test.dart`,
  `test/search_accessibility_test.dart`, `test/search_dark_mode_test.dart`,
  `test/search_responsive_test.dart` — these test the reused
  presentational widgets directly or via dev-preview; any change
  needed here beyond the new no-results case is a signal scope has
  crept beyond this plan.
- **Precondition, not new work**: `test/search_test.dart`'s
  `searchAyahs (asset thật)` group already proves the repository
  method works end-to-end against the real shipped asset. Confirm it
  passes (i.e. `assets/database/quran.sqlite` exists locally) before
  starting — if it's skip-guarded out, real search can't be manually
  verified during implementation either.
- Vietnamese test descriptions and a `'Sprint R1'` traceability tag on
  every new test, per `TESTING_GUIDE.md` §3.6/§3.7.

# 12. Files expected to change

| File | Change |
|---|---|
| `lib/features/search/data/search_providers.dart` | **New.** Independent query-state provider + debounced results provider. |
| `lib/features/search/presentation/search_screen.dart` | `_buildBody()`'s real-behavior branch wired to the new `AsyncValue`; `onChanged`/clear-button also write/reset the new query provider. |
| A new small widget (exact file TBD at implementation — e.g. `lib/features/search/presentation/widgets/search_no_results_state.dart`, or a parameterized addition to an existing file) | **New.** The §8 "no results for X" state. |
| `lib/l10n/app_vi.arb`, `app_en.arb`, `app_ar.arb` | New "no results for X" string(s), added to all three in the same change. |
| `test/search_providers_test.dart` | **New.** |
| `test/search_screen_test.dart` | Task 7.1.5's empty-query test rewritten; new real-search and no-results assertions added. |
| `test/fixtures/search_test_harness.dart` | Possibly extended if a shared fake `QuranRepository` or query-injection helper belongs here, consistent with its stated purpose as this feature's shared test fixture home — not required if each test file's own fake suffices. |

# 13. Files that MUST NOT change

- `lib/features/quran/presentation/surah_list_controller.dart` —
  `ayahSearchProvider`, `surahSearchQueryProvider`,
  `filteredSurahsProvider`, `filterSurahs` all stay exactly as they
  are. `SurahListScreen`'s own search must remain byte-for-byte
  identical in behavior.
- `lib/features/quran/data/quran_repository_impl.dart` and
  `lib/features/quran/domain/repositories/quran_repository.dart` —
  `searchAyahs()`'s signature and implementation are reused as-is.
- `lib/features/quran/data/fts_query.dart` — `ftsMatchExpression()` is
  already correct and already tested; reused, not modified.
- `lib/features/quran/presentation/reading/reading_navigation.dart` —
  `openAyahInReadingScreen()` reused as-is.
- `lib/shared/utils/highlight.dart` — `highlightSpans()` reused as-is.
- `lib/features/search/presentation/widgets/result_card.dart` and
  `search_result_section.dart` — reused via their existing
  `.fromAyah()`/`.ayahs()` factories. If implementation discovers a
  real defect in either, that is a scope deviation to flag explicitly,
  not something to silently patch inside this sprint.
- Any `AppDatabase`/`UserDatabase` table or migration file — zero
  schema change, per `PHASE3_SPRINT_R1_PLAN.md`'s explicit scope
  boundary (`CLAUDE.md`'s `PROJ-P-002` "stop and ask before" trigger).
- `test/surah_list_screen_test.dart` and any other existing test
  currently covering `ayahSearchProvider` — must show zero diff.

# 14. Risks

1. **Query-state coupling** (confirmed, not hypothetical):
   `ayahSearchProvider` is a plain `FutureProvider.autoDispose`
   internally reading `surahSearchQueryProvider` — the same instance
   `SurahListScreen`'s own search box writes to. Reusing it as-is
   inside `SearchScreen` would silently couple two independent
   screens' search state.
2. **A currently-passing test encodes the bug as correct.**
   `test/search_screen_test.dart:119-129` asserts that typing
   produces neither a loading indicator nor a results list — exactly
   today's bug. Once real wiring lands this test *should* start
   failing (a good sign, forcing an intentional rewrite) — the risk is
   an implementer "fixing" it by weakening the assertion instead of
   replacing it with a correct one for the new behavior.
3. **Missing "no results" state ships a narrower version of the same
   bug.** If §8's new state is treated as optional polish rather than
   in-scope, a real, valid query with zero matches will render nothing
   — the identical failure class this sprint exists to close, just for
   a smaller input space.
4. **Clear-button reset gap.** The clear button must reset the new
   query provider, not just the visible `TextEditingController` — easy
   to miss, produces a real, visible bug (stale results after
   clearing) if missed.
5. **Debounce/staleness-check must target the new provider, not the
   old one.** The re-check-after-delay pattern being copied from
   `ayahSearchProvider` must read the *new* query provider — copying
   the technique without updating which provider it reads would
   silently reintroduce the coupling risk from item 1.
6. **Regression risk to `SurahListScreen`.** Confirmed real given item
   1 — mitigated entirely by not touching `quran/` files at all (§13),
   not by care alone.
7. **FTS5 syntax/injection edge cases** are already mitigated by
   `ftsMatchExpression`'s existing sanitization — low residual risk,
   but the new provider's test suite should include a defensive case
   (a query containing raw `"`/`*`) to confirm the new call path
   doesn't bypass that protection.

# 15. Rollback strategy

- All new code is additive: a new provider file, new/parameterized
  widget for the no-results state, and a scoped change inside
  `SearchScreen._buildBody()`. No migration, no schema change, nothing
  to undo in stored data — rollback is a plain commit revert.
- Because `quran/` files are explicitly MUST NOT CHANGE (§13), any
  post-merge regression discovered in `SurahListScreen`'s search would
  itself indicate a scope violation rather than an entangled,
  hard-to-isolate bug — still a clean file-level revert, not a
  forensic exercise.
- Recommended commit granularity, matching `CONTRIBUTING.md`'s
  one-logical-change-per-commit convention: (1) the new provider file
  + its tests, (2) `SearchScreen` wiring to real loading/error/results
  states, (3) the new "no results" widget + its tests, (4) the
  `search_screen_test.dart` rewrite of the old Task 7.1.5 assertion.
  Each is independently revertable — e.g., the no-results widget could
  be reverted alone while keeping real search results working, if only
  that piece has an issue.
- No feature-flag mechanism exists elsewhere in this codebase and none
  is proposed here; `git revert` is this project's established
  rollback path, consistent with every prior sprint in this
  engagement.

---

READY FOR SEARCH IMPLEMENTATION
