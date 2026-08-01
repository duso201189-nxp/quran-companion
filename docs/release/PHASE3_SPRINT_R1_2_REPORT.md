# Phase 3 — Sprint R1.2 Report: "No Results" Experience

Implemented on top of Sprint R1.1
([PHASE3_SPRINT_R1_1_REPORT.md](PHASE3_SPRINT_R1_1_REPORT.md)). No
commit was created; nothing was pushed; no PR was opened.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `lib/features/search/presentation/widgets/search_no_results_state.dart` | **New** | `SearchNoResultsState` — the dedicated "search ran, zero rows" widget. Icon + bold title (query interpolated) + subtitle, `Semantics(liveRegion: true)` announcement. Modeled directly on `SearchErrorState`'s layout (same icon size, spacing, centered-column shape) but with a distinct icon (`Icons.search_off`) and a neutral color (`scheme.onSurfaceVariant`, not `scheme.error`) so it reads as "nothing matched," not "something broke." |
| `lib/features/search/presentation/search_screen.dart` | Modified | `_buildBody()`'s `data:` branch now distinguishes three cases instead of one: `results.isEmpty && query.trim().length < 2` → `SearchEmptyState` (no real search ran); `results.isEmpty` otherwise → `SearchNoResultsState(query: query)`; `results.isNotEmpty` → `SearchResultSection.ayahs` (unchanged). Two doc comments updated. |
| `lib/features/search/data/search_providers.dart` | Modified | No behavior change — `searchQueryProvider` got an extended doc comment recording the lifecycle decision (see below); `searchResultsProvider` untouched. |
| `lib/l10n/app_vi.arb`, `app_en.arb`, `app_ar.arb` | Modified | Two new keys: `searchNoResultsTitle` (String placeholder `{query}`) and `searchNoResultsSubtitle`. |
| `lib/l10n/app_localizations.dart`, `app_localizations_{vi,en,ar}.dart` | Regenerated | Via `flutter gen-l10n` (the project's `l10n.yaml`/`generate: true` pipeline) — not hand-edited. |
| `test/search_no_results_state_test.dart` | **New** | Isolated widget tests for `SearchNoResultsState` alone (no `ProviderScope`, matching `search_error_state_test.dart`'s convention). |
| `test/search_screen_test.dart` | Modified | New "Sprint R1.2" group (3 tests) wiring the state into `SearchScreen`; one R1.1 test's stale comment/assertions updated now that the "no results" gap it flagged is closed; one earlier R1.1 test's expectation corrected (see Tests, below). |

No other file was touched. `lib/features/quran/**`, `lib/shared/utils/highlight.dart`, `lib/features/search/presentation/widgets/{result_card,search_error_state,search_result_section}.dart`, and every unrelated test file are unmodified.

# Lifecycle decision

**`searchQueryProvider` stays a plain `StateProvider`, not `.autoDispose`.** Documented in full in the provider's own doc comment; summary:

`SearchScreen` never `ref.watch`s `searchQueryProvider` directly — it only `ref.read`s it to write (`onChanged`, clear button). The only real `ref.watch` on it is inside `searchResultsProvider`, and `searchResultsProvider` itself is only watched by `SearchScreen` while its results branch is actually rendering (query non-empty, mode/scope wired). That means the provider's listener count already drops to zero constantly during ordinary use — every time the field is cleared, the scope is switched to "Ghi chú của tôi", or the empty state is showing — not just when the screen closes.

If `searchQueryProvider` were `.autoDispose`, Riverpod would tear it down and recreate it at its default value (`''`) at any of those moments, which would silently reset a query the user is actively typing — a real bug, not a theoretical one, because nothing in the current widget tree holds a continuous watch-based subscription to keep it alive. Making `.autoDispose` safe here would require adding a permanent `ref.watch(searchQueryProvider)` somewhere in `SearchScreen` specifically to keep it alive — exactly the kind of structural change objective 4 ("Do not redesign SearchScreen") rules out for this sprint.

The accepted tradeoff: the provider lives for the app's lifetime (like most of this project's other infrastructure providers), so if `SearchScreen` is closed and reopened later, its internal state could be "stale" relative to a fresh visit. This causes no visible bug today because the screen's branch logic reads `_queryController.text` (a local `State` field, always freshly empty on a new `SearchScreen` instance) to decide what to render — not `searchQueryProvider` directly. `searchResultsProvider` (unaffected by this decision, unchanged from R1.1) remains correctly `.autoDispose`, since it has no such "who's actually watching it" ambiguity — it's a derived async computation with no independent state to lose.

# Localization

Two new keys added to all three `.arb` files, each with a `String` placeholder (`{query}`), following the exact pattern already used by `smartDeckVerbFormLabel` (the only pre-existing String-placeholder key in this project):

| Key | vi | en | ar |
|---|---|---|---|
| `searchNoResultsTitle` | `Không tìm thấy kết quả cho "{query}"` | `No results found for "{query}"` | `لم يتم العثور على نتائج لـ "{query}"` |
| `searchNoResultsSubtitle` | `Thử một từ khoá khác hoặc kiểm tra chính tả.` | `Try a different keyword or check your spelling.` | `جرّب كلمة بحث مختلفة أو تحقّق من الإملاء.` |

Regenerated `lib/l10n/app_localizations*.dart` via `flutter gen-l10n` (this project's own pipeline, declared in `l10n.yaml`) rather than hand-editing the generated files — `flutter analyze` failed with `undefined_method`/`undefined_getter` before regeneration and was clean immediately after, confirming the generated code matches the ARB source.

A pre-existing, unrelated key (`searchNoAyahResults`, used only by `SurahListScreen`'s own in-place ayah-search-results list) was left untouched — it has no query placeholder and serves a different, smaller-scale UI (an inline "no results" line inside a scrollable list, not a full-body state). Reusing or extending it would have meant touching `SurahListScreen`, which is out of this sprint's scope (see `lib/features/quran/**` exclusion above).

# Tests

**New — `test/search_no_results_state_test.dart`** (5 tests, no `ProviderScope`, matching `search_error_state_test.dart`'s isolation convention):
- Renders `Icons.search_off` and the query interpolated into the title.
- Changing the `query` parameter changes the rendered message (not a hardcoded string).
- Visually distinct from `SearchErrorState`: no `cloud_off_outlined` icon, no retry button.
- Visually distinct from `SearchEmptyState`: no "Gần đây"/"Gợi ý" sections, no `travel_explore_outlined` icon.
- Title + subtitle form a single `liveRegion` semantics announcement (mirrors `SearchErrorState`'s accessibility pattern).

**New — `test/search_screen_test.dart`, group "Sprint R1.2"** (3 tests, using the isolated `_wrapSearchScreen` + fake-repository harness built in R1.1):
- A ≥2-character query resolving to zero results renders `SearchNoResultsState` with the correct query text, and explicitly not `SearchEmptyState`/`SearchErrorState`/`SearchLoadingSkeleton`/`SearchResultSection`.
- Following a no-results query with one that does match makes `SearchNoResultsState` disappear and real `ResultCard`s appear.
- Clearing the field while `SearchNoResultsState` is showing returns to `SearchEmptyState`.

**Updated, R1.1 tests affected by this sprint's more precise state handling:**
- "gõ 1 ký tự (dưới ngưỡng 2 ký tự)" — comment and assertions updated to explicitly confirm the under-threshold case renders `SearchEmptyState`, not `SearchNoResultsState` (this is the exact distinction objective 1 required: "search completed successfully" vs. "no search attempted at all" are different things, and only the former gets the new widget).
- Task 7.1.5's rewritten-in-R1.1 test ("gõ chữ đủ dài → gọi engine tìm kiếm thật") asserted `SearchResultSection findsOneWidget` for a query that (via `makeApp()`'s always-empty `FakeQuranRepo`) actually returns zero rows — that assertion was already slightly imprecise before this sprint (it happened to pass because an empty `SearchResultSection` still rendered as a widget) and is now corrected to assert `SearchNoResultsState`, matching the real, more specific current behavior.

Per objective 9 of R1.1 (still respected — R1.2 doesn't reopen it), no test asserts on the "My Notes"/"Ask" scope combinations, which remain untouched placeholders.

# Analyze

```
flutter analyze
...
No issues found! (ran in 7.9s)
```
One intermediate failure, expected and self-resolving: immediately after adding the ARB keys and before running `flutter gen-l10n`, `flutter analyze` reported 3 errors (`searchNoResultsTitle`/`searchNoResultsSubtitle` undefined on `AppLocalizations`) — resolved by regenerating, not by changing source.

# Test

```
flutter test
...
00:54 +782: All tests passed!
```
782/782 passing (up from R1.1's 774 — 5 new `SearchNoResultsState` tests + 3 new wiring tests = +8; matches). Zero regressions in `lib/features/quran/**`'s test coverage or any other unrelated file.

---

READY FOR R1.2 REVIEW
