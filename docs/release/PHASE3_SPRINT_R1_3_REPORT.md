# Phase 3 — Sprint R1.3 Report: Search UX Polish & Stability

Built on R1.1/R1.2. No commit was created; nothing was pushed; no PR
was opened. This was primarily a **review** sprint: most of the six
areas in scope were verified correct as-is and required no code
change; one real accessibility gap was found and fixed; the debounce
mechanism was verified correct and documented, not replaced.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `lib/features/search/presentation/widgets/search_result_section.dart` | Modified | Added `liveRegion: true` to the existing title `Semantics` (alongside the pre-existing `header: true`) — the one real fix this sprint made. One line + comment. |
| `lib/features/search/data/search_providers.dart` | Modified | Doc-comment only — added a "Sprint R1.3" note on `searchResultsProvider` recording the debounce/rapid-typing verification (see Debounce decision below). No behavior change. |
| `test/search_providers_test.dart` | Modified | New test: rapid-typing/staleness verification at the provider level. |
| `test/search_accessibility_test.dart` | Modified | New test: `SearchResultSection`'s title now carries `isLiveRegion`. |
| `test/search_screen_test.dart` | Modified | New group: two focus/keyboard-stability tests. |

**`lib/features/search/presentation/search_screen.dart` was not
touched this sprint** — every area reviewed there (rapid typing,
clearing, loading/error/no-results transitions, focus) was verified
correct in its current form. No other file was touched; `lib/features/quran/**`
and all repository/provider APIs are unmodified.

# UX improvements

Only one behavioral change shipped this sprint:

- **Search-result announcements now reach screen readers.** Before
  this sprint, `SearchLoadingSkeleton`, `SearchErrorState`, and
  `SearchNoResultsState` (R1.2) all proactively announced themselves
  via `Semantics(liveRegion: true)` when they appeared — but
  `SearchResultSection` (the "you got real results" state) did not.
  A screen-reader user who typed a query that actually matched
  something got no signal that the search had finished or how many
  results came back; they had to manually navigate into the results
  list to discover it. This was the one asymmetry among the four
  body-states and is now fixed with the same one-flag pattern already
  used by the other three.

Everything else reviewed (see below) was already correct and is
**documented, not changed**, per objective 2/4/5.

# Debounce decision

**A debounce mechanism already exists in `searchResultsProvider`
(`lib/features/search/data/search_providers.dart`, built in R1.1) and
works correctly — it was reviewed, verified, and documented in place;
it was not replaced.**

Mechanism: every keystroke rewrites `searchQueryProvider`, which
`searchResultsProvider` watches — each write triggers a fresh build of
the closure: `await Future.delayed(250ms)`, then
`if (query != ref.read(searchQueryProvider)) return const [];` before
ever calling `QuranRepository.searchAyahs()`. Verified specifically for
rapid typing:

- Dart cannot cancel a pending `Future`, so a superseded build's delay
  keeps running in the background — but its own staleness check
  (comparing its captured `query` against the *current* provider
  value once the delay elapses) stops it from calling the repository
  for a query the user has already moved past. Confirmed with a new
  test that fires 5 rapid, un-awaited query changes and asserts the
  repository was called exactly once, with the final query only.
- Because `AsyncValue` for `searchResultsProvider` goes to `loading`
  the instant a rebuild starts (before the 250ms delay or the
  repository call even happens), and `SearchScreen`'s `.when()` always
  renders `SearchLoadingSkeleton` for that state, **stale results are
  never visually shown alongside a newer, still-pending query** — the
  old `ResultCard`s are replaced by the loading skeleton immediately,
  not left on screen until the new data arrives.

No new package, no architecture change — the existing mechanism was
sufficient and is now the subject of a direct regression test rather
than an assumption.

# Accessibility review

Reviewed all four items named in objective 6, plus general semantics
consistency:

- **Loading announcements**: `SearchLoadingSkeleton` — `Semantics(label:
  l10n.searchLoadingLabel, liveRegion: true)`. Verified present, unchanged
  (built pre-R1.1).
- **Result announcements**: `SearchResultSection` — **was missing**
  `liveRegion`; fixed this sprint (see UX improvements). Now consistent
  with the other three states.
- **No-results announcements**: `SearchNoResultsState` — `Semantics(liveRegion:
  true, label: '$title. $subtitle')`. Verified present, unchanged
  (built in R1.2).
- **Error announcements**: `SearchErrorState` — `Semantics(liveRegion:
  true, label: text)`. Verified present, unchanged (pre-existing).
- **Screen reader semantics generally**: header flags
  (`Semantics(header: true)`) on `SearchEmptyState`'s three section
  titles and `SearchResultSection`'s title were already correct and
  already covered by `test/search_accessibility_test.dart`'s existing
  "Task 7.1.15" group (touch target ≥48dp, RTL, 200% text scale,
  reading order, no redundant semantics) — re-ran, all still pass
  unmodified.
- **Not changed**: whether the loading label re-announces on every
  keystroke during rapid typing (since the label text itself never
  changes between repeated loading states) was considered — this is
  standard Flutter live-region behavior already used elsewhere in this
  screen before R1.3, not a new risk introduced by anything reviewed
  here, and not verifiable without a real screen reader/device. No
  code change proposed for it.

# Tests updated

No existing test's *assertions* were changed this sprint (nothing in
R1.1/R1.2's behavior was altered besides the one accessibility flag) —
all additions are new tests:

- `test/search_providers_test.dart` — new test: 5 rapid, un-awaited
  query writes → exactly one repository call, for the final query only.
- `test/search_accessibility_test.dart` — new test: `SearchResultSection`'s
  title has `isLiveRegion` (alongside the pre-existing `isHeader` check
  in the neighboring test, left untouched).
- `test/search_screen_test.dart`, new group "Sprint R1.3 — focus/bàn
  phím ổn định qua các lần chuyển trạng thái" (2 tests): the search
  field's software-keyboard connection (`tester.testTextInput.isVisible`)
  stays active across the Loading → Results transition, and stays
  active after tapping the clear button (clearing text must not
  incidentally drop focus).

# Analyze result

```
flutter analyze
...
No issues found! (ran in 8.7s)
```

# Test result

```
flutter test
...
00:54 +786: All tests passed!
```
786/786 passing (782 from R1.2 + 4 new this sprint: 1 rapid-typing
provider test, 1 liveRegion accessibility test, 2 focus tests). Zero
regressions — every existing Search test file (`search_screen_test.dart`,
`search_providers_test.dart`, `search_accessibility_test.dart`,
`search_result_section_test.dart`, `search_no_results_state_test.dart`,
`search_error_state_test.dart`, `search_dark_mode_test.dart`,
`search_responsive_test.dart`, `search_test.dart`) re-run and green,
and the full 786-test suite (including everything under
`lib/features/quran/**`) is unaffected.

# Remaining technical debt

Carried forward, not addressed this sprint (out of scope per the
review's own findings, not oversights):

- **Loading-skeleton flicker on very fast typing.** Every keystroke
  past the 2-character threshold puts the body into `AsyncLoading`
  immediately, so `SearchLoadingSkeleton` can visibly flash between
  keystrokes during rapid typing rather than the previous results
  staying put until new ones are ready. This is the safer failure mode
  (no risk of showing results for the wrong query) and is standard for
  a debounced-search UI, but a smoother "keep previous results dimmed
  while loading" treatment is a legitimate future polish item — would
  require `AsyncValue.whenOrPrevious`-style handling in `_buildBody`,
  which is a real (if small) change to `search_screen.dart`'s
  structure, deliberately not made here per "do not redesign the
  screen."
- **No autofocus on screen open.** `SearchScreen`'s field is not
  auto-focused when the screen is pushed — verified this causes no
  focus *loss* bug (the subject of this sprint), but whether the field
  *should* auto-focus on open is a product/UX decision, not a
  stability bug, and was left as-is.
- **"My Notes" and "Ask" scopes remain permanently inert** (unchanged
  from R1.1/R1.2, explicitly out of scope again this sprint) — no new
  findings here beyond what R1.1's plan already recorded.
- **`SearchResultSection`'s new live-region announcement re-announces
  its title text on every result-count change**, including from one
  non-zero count to another (e.g., 3 results → 2 results as a query is
  refined) — this is correct, intended behavior, not debt, but worth
  noting it wasn't specifically tested at that granularity (only
  "gains `isLiveRegion` at all" was tested, not "announces on every
  count change").

---

READY FOR R1.3 REVIEW
