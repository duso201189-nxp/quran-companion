# Phase 3 — Sprint R1.1 Report: Search Integration (Implementation)

Implemented following [PHASE3_SPRINT_R1_PLAN.md](PHASE3_SPRINT_R1_PLAN.md)
and [PHASE3_SPRINT_R1_DESIGN_REVIEW.md](PHASE3_SPRINT_R1_DESIGN_REVIEW.md).
No commit was created; nothing was pushed; no PR was opened.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `lib/features/search/data/search_providers.dart` | **New** | `search/`'s first `data/` file. `searchQueryProvider` (`StateProvider<String>`, independent of `surahSearchQueryProvider`) + `searchResultsProvider` (`FutureProvider.autoDispose<List<AyahSearchResult>>`, same debounce/threshold contract as `ayahSearchProvider`, calling the existing `quranRepositoryProvider.searchAyahs()` unmodified). |
| `lib/features/search/presentation/search_screen.dart` | Modified | `_buildBody()`'s real-query branch replaced `SizedBox.shrink()` with an `AsyncValue.when()` over `searchResultsProvider` (loading → `SearchLoadingSkeleton`, error → `SearchErrorState`, data → `SearchResultSection.ayahs`). `SearchBar.onChanged` and the clear button now also write/reset `searchQueryProvider`. Two doc comments updated to stop describing pre-R1.1 behavior as current. |
| `test/search_providers_test.dart` | **New** | Provider-level tests: empty/under-threshold query short-circuits without calling the repository; a valid query calls it and returns its result; independence from `surahSearchQueryProvider`. |
| `test/search_screen_test.dart` | Modified | Rewrote the Task 7.1.5 test that asserted the placeholder bug ("typing shows nothing") to assert real rendering instead. Added a new "Sprint R1.1" group: loading→results transition, clear-button reset, under-threshold behavior — using an isolated `SearchScreen`-only wrapper + a local fake `QuranRepository` returning canned results. |
| `test/search_accessibility_test.dart` | Modified | One existing touch-target test types a query as setup; added the same pump-past-debounce sequence used elsewhere so the test doesn't leave a pending `Timer` at teardown (unrelated to the test's actual assertion, purely a side effect of search now being real). |

No other file was touched. `lib/features/quran/**`, `lib/shared/utils/highlight.dart`, `lib/features/search/presentation/widgets/**`, and every test file not listed above are unmodified (verified via `git status`/`git diff --stat`).

# Architecture decisions

1. **New, independent provider instead of reusing `ayahSearchProvider`.** Confirmed in the design review: `ayahSearchProvider` reads `surahSearchQueryProvider`, the same `StateProvider` `SurahListScreen`'s own search box writes to. Reusing it as-is would have coupled the two screens' search state. `searchQueryProvider`/`searchResultsProvider` are new, `search/`-owned, and copy the exact same shape (debounce, 2-character threshold, staleness re-check) rather than inventing a different mechanism.
2. **`quranRepositoryProvider.searchAyahs()` called directly, unmodified.** No new repository method, no new SQL, no schema change. `lib/features/quran/**` was not touched.
3. **Scope gate: `SearchMode.search` and `SearchScope` ∈ {`all`, `quran`} trigger the real engine; `SearchScope.myNotes` (and `SearchMode.ask`, already permanently disabled) keep the pre-R1.1 placeholder (`SizedBox.shrink()`).** This wasn't fully pinned down by the plan/design review, which discussed "Search mode × Qur'an scope" without resolving what the *default* scope (`all`) should do. Since `all` is the screen's default landing scope, gating real search on `quran` alone would have left the primary, default experience still showing nothing after typing — reintroducing a narrower version of the exact bug this sprint exists to fix. Since Qur'an is the only domain with a working engine today, treating `all` as "search across all available domains" (currently just Qur'an) was the more correct reading of "All" than leaving it inert. `myNotes` has no engine at all (no FTS5 index over notes/highlights), so it correctly stays a no-op, matching the plan's explicit "Out of Scope."
4. **Zero-result queries render the ordinary `SearchResultSection` with zero cards — no new "no results" widget.** Per objective 9, this sprint doesn't build dedicated no-results UI (that's R1.2). Rather than inventing a special case to avoid showing an empty section, the same generic `AsyncValue.data` branch handles both non-empty and empty results uniformly — the smallest, least-opinionated implementation that still satisfies "reuse existing widgets."
5. **Clear button explicitly resets `searchQueryProvider`, not just the `TextEditingController`.** `TextEditingController.clear()` does not fire `onChanged` (it's not a user-driven edit), so without an explicit reset the provider would keep the last typed query and stale results could remain visible after the field visually empties. This was flagged as a risk in the design review and fixed directly in the wiring rather than discovered later.
6. **No new l10n keys.** Every string reused by the real-query path (`SearchLoadingSkeleton`, `SearchErrorState`, `SearchResultSection`'s title, `ResultCard`) already existed and was already used by the dev-preview path — R1.1 only changes *when* they render, not their content.

# Tests updated

- **`test/search_screen_test.dart`, Task 7.1.5** — "gõ chữ chưa gọi truy vấn hay hiển thị kết quả nào" ("typing doesn't trigger a query or show results") rewritten. It previously asserted today's bug as correct behavior; it now asserts that typing a real query renders `SearchResultSection` (not `SearchEmptyState`) without error, using the shared `makeApp()` fixture (whose `FakeQuranRepo.searchAyahs()` always returns `[]` — this test intentionally only proves "the real path is reached and doesn't crash," not "results appear"; that's covered separately, see below).
- **`test/search_accessibility_test.dart`** — the touch-target test for the clear button types a query as setup (unrelated to its actual assertion). Added the same debounce-flushing pump sequence used elsewhere so the test doesn't end with a pending `Timer`, which Flutter's test framework treats as a hard failure at teardown.

# Tests added

- **`test/search_providers_test.dart`** (new file, 4 tests):
  - Empty query → `searchResultsProvider` resolves to `[]` immediately, repository never called.
  - Query under 2 characters → same, repository never called.
  - Query ≥ 2 characters → repository called exactly once with the right query string, result returned unchanged.
  - Independence from `surahSearchQueryProvider` — writing to it does not affect `searchQueryProvider` or trigger a repository call.
- **`test/search_screen_test.dart`**, new group "Sprint R1.1 — hiển thị kết quả tìm kiếm thật" (3 tests), using an isolated `SearchScreen`-only wrapper (single-route `GoRouter` + a local fake `QuranRepository` returning canned, non-empty data — the shared `FakeQuranRepo` in `app_harness.dart` always returns `[]`, so it can't exercise real rendering):
  - Typing a valid query shows `SearchLoadingSkeleton`, then real `ResultCard`/`SearchResultSection` content (not the dev-preview sample data).
  - Clearing the field after results are shown returns to `SearchEmptyState` with no stale `ResultCard` left behind — the direct regression guard for the clear-button wiring decision above.
  - Typing 1 character (under threshold) shows neither loading nor any `ResultCard`.

Per objective 9, no test was written for a distinct "no results" UI state — the zero-result case is only implicitly exercised (Task 7.1.5's rewritten test resolves to an empty result set and asserts no crash), not asserted on as its own scenario.

# Analyze result

```
flutter analyze
...
No issues found! (ran in 8.0s)
```
Clean on the first full pass except two minor lints in the new test files (`prefer_single_quotes`, `prefer_const_declarations`), both fixed immediately; final run clean.

# Test result

```
flutter test
...
00:53 +774: All tests passed!
```
774/774 passing, 0 failures. This includes the 4 new provider tests, the 3 new widget tests, the 1 rewritten test, and the full pre-existing suite (`test/surah_list_screen_test.dart` and every other file under `lib/features/quran/**`'s test coverage included) with zero assertion changes needed beyond the two files listed under "Tests updated."

Two intermediate, since-fixed problems surfaced while getting to a clean run, both from the same root cause and worth recording:

1. `pumpAndSettle()` alone does not reliably advance the test's virtual clock past the provider's 250ms debounce unless something keeps scheduling frames — a bare `pump()` first (to let the widget rebuild and actually create the debounced `Future`) followed by an explicit `pump(const Duration(milliseconds: 300))` was needed before a final `pumpAndSettle()`, in every new test that types a query and expects to observe the resolved state.
2. One pre-existing, otherwise-unrelated test (`search_accessibility_test.dart`'s clear-button touch-target check) types a query as incidental setup and, without the same fix, left a `Timer` pending at teardown — a hard failure under Flutter's test framework. Fixed the same way; its own assertion (button size) is untouched.

# Risks

- **Scope-gate judgment call (decision 3 above) isn't explicitly confirmed by the design review**, which only discussed the `quran` scope by name. If "All" was actually meant to stay inert until a later sprint, this sprint's default landing experience now does more than originally scoped. Flagging this explicitly for review rather than treating it as self-evidently correct.
- **`SearchResultSection` rendering with 0 results for very short/no-match queries** is a real, if minor, UX rough edge (decision 4) — a query with zero matches currently shows a "· 0" section header rather than a distinct message. This is deliberately deferred to R1.2 per objective 9, not overlooked.
- **The `pump()`-then-`pump(duration)` ordering requirement (test result, item 1) is not obvious** and could trip up whoever writes R1.2's "no results" tests if they don't know this codebase's `AutomatedTestWidgetsFlutterBinding` behaves this way for provider-driven debounce testing — worth calling out explicitly in that sprint's own test-writing, since no prior test file in this codebase exercised a debounced provider through a widget test before this sprint.
- **`_FakeQuranRepoWithResults` (in `search_screen_test.dart`) and `_FakeQuranRepository` (in `search_providers_test.dart`) are near-duplicate fakes**, each declared locally per `TESTING_GUIDE.md`'s convention of file-local fakes over shared ones. If R1.2 needs a similar fake a third time, it's worth reconsidering whether `test/fixtures/search_test_harness.dart` should absorb one canonical version — not done here to keep this sprint's diff minimal, per its own scope instructions.
- **No accessibility-specific assertions were added for the real-result path** (e.g., confirming `SearchResultSection`'s `Semantics(header: true)` still fires when driven by real data rather than dev-preview data). The underlying widget is unchanged and already covered by `test/search_accessibility_test.dart` against dev-preview data, so this is treated as low risk, not zero risk.

---

READY FOR R1.1 REVIEW
