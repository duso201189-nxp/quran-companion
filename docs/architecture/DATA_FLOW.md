# Data Flow — Qur'an Companion

Written after PR #19. This document traces four representative
user-facing flows end to end: UI action → controller/provider →
repository → database (and back). It complements `MASTER_ARCHITECTURE.md`
(static design) and `DATABASE_REFERENCE.md` (schema) with concrete call
chains, file:line references, and the real Riverpod provider graph as
implemented today.

Two databases are involved throughout:
- **AppDatabase** (`core/database/app_database.dart`) — read-only static
  Qur'an content, packaged at `assets/database/quran.sqlite`, copied to
  `quran_content.sqlite` on device. Opened lazily via `appDatabaseProvider`
  (`core/database/database_providers.dart:8-12`).
- **UserDatabase** (`core/database/user/user_database.dart`) — mutable
  user data (`user_data.sqlite`), opened via `userDatabaseProvider`
  (`core/database/user/user_database_providers.dart`).

---

## Flow 1 — Reading

**Screen:** `features/quran/presentation/reading/reading_screen.dart`
(`ReadingScreen`, route `/quran/surah/:id` nested in the tab shell, and
`/read/:id` top-level — see Flow 2 for why two routes exist).

### 1. Loading Surah/Ayah content

1. `ReadingScreen.build()` watches `surahReadingProvider(widget.surahId)`
   (`reading_screen.dart:173`).
2. `surahReadingProvider` is a
   `FutureProvider.autoDispose.family<SurahReading, int>` defined in
   `reading_controller.dart:24-33`. It calls `quranRepositoryProvider`
   → `repo.getSurahById(surahId)` then `repo.getAyahsOfSurah(surahId)`,
   combining both into the `SurahReading` typedef `(surah, ayahs)`.
   `autoDispose` frees the Surah + all translation layers from memory
   as soon as the screen is left.
3. `quranRepositoryProvider` (`data/quran_providers.dart:8-13`) builds
   a `QuranRepositoryImpl` over `appDatabaseProvider` — i.e. this read
   never touches UserDatabase.
4. `QuranRepositoryImpl.getSurahById` (`data/quran_repository_impl.dart:47-53`)
   — `SELECT * FROM surahs WHERE id = ?` via Drift, mapped to the
   `Surah` entity.
5. `QuranRepositoryImpl.getAyahsOfSurah` (`data/quran_repository_impl.dart:67-110`)
   — one query on `ayahs` ordered by `ayah_number`, then **one** joined
   query across `translations` ⋈ `translation_sources` for *all*
   enabled sources for the whole Surah at once (explicit N+1
   avoidance). Transliteration rows are normalized through
   `TransliterationRepository.normalize()`. Results are assembled into
   `List<AyahContent>` keyed by `ayah.id`.
6. Both repository calls are wrapped in `withFailureLogging()`
   (`core/logging/repository_boundary_logging.dart`), which maps/logs
   failures and rethrows unchanged — behavior is unaffected, only
   logged.
7. `ReadingScreen.build()` renders the `AsyncValue<SurahReading>` via
   `.when(loading/error/data)` (`reading_screen.dart:262-304`),
   building either the list view (`_AyahListView`) or the paginated
   Mushaf view (`_MushafView`) depending on `readingSettingsProvider.mode`.

### 2. Reading-position tracking

`ReadingPositionStore` (`presentation/reading/reading_position_store.dart`)
wraps `SharedPreferences` (via `sharedPreferencesProvider`) — **not** a
database table. It keeps:
- `reading.last_surah_id` — last Surah opened globally (used by Home's
  "Continue Reading").
- `reading.pos.<surahId>` — last 0-based Ayah index read, per Surah.
- `reading.recent_surahs` — up to 6 most-recently-read Surah ids.

Write triggers, in `ReadingScreen`:
- `_ReadingScreenState.initState()` reads the last saved position for
  `widget.surahId` to compute `_initialAyahIndex` (`reading_screen.dart:72-73`),
  used as the initial scroll index / Mushaf page.
- In list mode, `ScrollablePositionedList`'s `itemPositionsListener`
  fires `_onPositionsChanged()` (`reading_screen.dart:107-120`) on
  every scroll settle; it computes the first fully-visible Ayah index
  and, if changed, calls `ReadingPositionStore.save()`
  (`reading_position_store.dart:36-49`), which writes `kLastSurah`,
  `posKey(surahId)`, and re-pushes the Surah to the front of
  `recentSurahIds` — 3 `SharedPreferences` writes.
- In Mushaf mode, `PageView.onPageChanged` calls `_savePage()`
  (`reading_screen.dart:122-128`) with the new page's first Ayah
  index, same `save()` call.

### 3. Logging a completed reading session to `study_sessions`

`_ReadingScreenState` starts a `Stopwatch` in `initState()` and, in
`dispose()` (`reading_screen.dart:81-104`):
1. Computes elapsed seconds.
2. Always calls `StatsStore.addSeconds(seconds)` — the pre-existing
   `SharedPreferences`-backed stats source, used by the metrics grid
   (unchanged).
3. **If `seconds >= 5`** (same "< 5s ignored" threshold as
   `StatsStore.addSeconds`), also calls
   `StudySessionRepository.logSession(...)` (`reading_screen.dart:92-102`)
   — passing `date: StatsStore.dayKey(now)`, `surahId`,
   `ayahFrom: _initialAyahIndex`, `ayahTo: _lastSavedIndex ?? _initialAyahIndex`,
   `durationSec: seconds`. Both writes are `unawaited` (fire-and-forget)
   so `dispose()` doesn't block navigation.
4. `studySessionRepositoryProvider` builds `StudySessionRepositoryImpl`
   over `userDatabaseProvider`.
5. `StudySessionRepositoryImpl.logSession()`
   (`stats/data/study_session_repository_impl.dart:46-73`) inserts one
   row into UserDatabase's `study_sessions` table (`id` = uuid v4) via
   `StudySessionsCompanion.insert(...)`.

This is a genuinely parallel write path: `StudySessionRepository`
(Drift/UserDatabase, `study_sessions` table) exists **alongside**
`StatsStore` (SharedPreferences) rather than replacing it — feeding
the streak/summary features (`currentStreakProvider`,
`longestStreakProvider`, `todayStudySummaryProvider`) while
`StatsStore` remains the source for the existing metrics grid.

### Summary (Flow 1)

```
ReadingScreen.initState()
  → readingPositionStoreProvider.positionFor(surahId)         [SharedPreferences read]
ReadingScreen.build()
  → surahReadingProvider(surahId)  (reading_controller.dart)
    → quranRepositoryProvider → QuranRepositoryImpl
      → AppDatabase: surahs, ayahs, translations ⋈ translation_sources
Scroll / page change
  → ReadingPositionStore.save()                                 [SharedPreferences write]
ReadingScreen.dispose()
  → StatsStore.addSeconds()                                     [SharedPreferences write]
  → StudySessionRepository.logSession()  (if ≥ 5s)
    → StudySessionRepositoryImpl → UserDatabase.study_sessions   [INSERT]
```

---

## Flow 2 — Search

Two things share the name "search" in this codebase and are worth
distinguishing precisely, because only one is wired to a live query as
of this version.

### A. The live, FTS5-backed search (Qur'an tab's Surah list)

This is the code path that **actually executes a Drift FTS query
today**.

1. `SurahListScreen` (`presentation/surah_list_screen.dart`) has a
   search field bound to `surahSearchQueryProvider`
   (`presentation/surah_list_controller.dart:17`, a `StateProvider<String>`).
2. `ayahSearchProvider` (`surah_list_controller.dart:35-43`) — a
   `FutureProvider.autoDispose<List<AyahSearchResult>>` — watches the
   query, requires length ≥ 2, debounces 250 ms, re-checks the query
   hasn't changed during the delay, then calls
   `quranRepositoryProvider.searchAyahs(query)`.
3. `QuranRepositoryImpl.searchAyahs()` (`data/quran_repository_impl.dart:143-165`):
   - Builds a `MATCH` expression via `ftsMatchExpression()`
     (`data/fts_query.dart:27-51`) — tokenizes the query, wraps each
     token as a prefix match (`"word"*`), folds Latin diacritics
     (`foldDiacritics`) or Arabic harakat (`foldArabic`), and for
     Arabic queries also ORs in an alef-wasla (`ٱ`) variant for words
     starting with `ا` to match the index's normalized form.
   - Runs a raw SQL query via `_db.customSelect(...)` against the FTS5
     virtual table `search_index`, restricted to
     `source_code IN ('arabic_plain','vi_main_plain','translit_latin_plain','en_sahih')`,
     ordered by `ayah_id`, limited (default 40).
   - Feeds the matched `ayah_id`s into `_headersForIds()`
     (`quran_repository_impl.dart:179-223`), which joins `ayahs` +
     `surahs` (for `nameLatin`) + `translations`⋈`translation_sources`
     (for `vi_main`/`en_sahih` display text) to build
     `List<AyahSearchResult>`.
4. `SurahListScreen`'s `_SearchResultsView` (`surah_list_screen.dart:219-287`)
   renders `ayahResults.when(loading/error/data)` under an "in-content
   results" section, one `_AyahResultTile` per hit, with matched
   substrings highlighted.
5. Tapping a tile: saves the position
   (`readingPositionStoreProvider.save(surahId, ayahIndex: ayahNumber-1)`)
   then `context.push(AppRoutes.surahReading(result.surahId))` — the
   **nested** shell route (`/quran/surah/:id`), since this screen is
   already inside the 5-tab shell's Qur'an branch.

### B. The top-level Search screen (`/search`)

`SearchScreen` (`features/search/presentation/search_screen.dart`,
route `AppRoutes.search`) is a **top-level** route pushed outside the
5-tab shell, matching `AppRoutes.library`'s pattern.

As implemented in this version, `SearchScreen._buildBody()`
(`search_screen.dart:160-190`) only ever returns the empty state for a
non-empty query — there is no `ayahSearchProvider`-equivalent wired to
it yet. `SearchResultSection`/`ResultCard` exist and are used, but
only from a debug-only dev-preview switch (`kDebugMode`-gated, tree-shaken
out of release builds). This is the current state, not a bug — see
[RELEASE_PLAN_V1.md](../release/RELEASE_PLAN_V1.md) §2 for the
recommendation to finish this wiring.

What **is** fully wired, and is the important navigation contract for
this document, is what happens once a real result *is* tapped —
proven out today by the dev-preview path and reused by three other
features: `onResultTap: (result) => openAyahInReadingScreen(context, ref, surahId: result.surahId, ayahNumber: result.ayahNumber)`
(`search_screen.dart:173-178`).

`openAyahInReadingScreen()` (`presentation/reading/reading_navigation.dart:43-56`)
is a single shared helper used by **every** "jump to a specific Ayah
from outside the tab shell" feature — Search, Library, Bookmark
Collections, Revision Queue, and Review Session all call it. It does
exactly two things:
1. `ReadingPositionStore.save(surahId, ayahIndex: ayahNumber - 1)`.
2. `context.push(AppRoutes.read(surahId))`.

**Design decision — why `AppRoutes.read` and not
`AppRoutes.surahReading`:** documented in the doc comment at
`reading_navigation.dart:24-37`. `AppRoutes.surahReading` (`/quran/surah/:id`)
is nested inside the `StatefulShellRoute`'s Qur'an branch. Calling
`context.push(AppRoutes.surahReading(...))` from a route that is
itself pushed *outside* that shell (like `SearchScreen`,
`LibraryScreen`) forces go_router to rebuild the shell branch's
Navigator on top of an already-live `GlobalKey`, throwing
`'!keyReservation.contains(key)': is not true` (reproduced in a widget
test per the comment). `AppRoutes.read` (`/read/:id`) is a **second,
separate top-level route** that renders the same `ReadingScreen`
widget, defined specifically to avoid this collision — the app
deliberately reuses `ReadingScreen` (not a new screen) behind two
distinct routes rather than inventing a new reading surface, and
reuses the *existing* `ReadingPositionStore` mechanism rather than
adding a second "jump to Ayah" mechanism. `ReadingScreen` doesn't need
a "highlight this Ayah" parameter because it already re-reads
`ReadingPositionStore` in `initState()` (Flow 1, step 2) and scrolls
there.

### Summary (Flow 2)

```
[Live path — Qur'an tab list]
SurahListScreen (search field)
  → surahSearchQueryProvider (StateProvider<String>)
  → ayahSearchProvider (debounce 250ms)
    → quranRepositoryProvider.searchAyahs(query)
      → ftsMatchExpression()  (fts_query.dart)
      → AppDatabase FTS5 `search_index` MATCH  → ayahs/surahs/translations join
  → _AyahResultTile tap
    → ReadingPositionStore.save()
    → context.push(AppRoutes.surahReading(surahId))   [nested shell route]

[Documented/wired-for navigation — top-level /search]
SearchScreen (query execution not yet connected to UI results in this version)
  → (intended) SearchResultSection.ayahs → ResultCard tap
    → openAyahInReadingScreen(context, ref, surahId, ayahNumber)
      → ReadingPositionStore.save()
      → context.push(AppRoutes.read(surahId))          [top-level route, avoids
                                                          GlobalKey collision with
                                                          the shell Navigator]
```

---

## Flow 3 — Learning Session

**Entry:** route `AppRoutes.learningSession` (`/learning-session`),
screen `features/learning_session/presentation/learning_session_screen.dart`
(`LearningSessionScreen`). It is intentionally the **only** route for
the whole session — no per-activity sub-route exists, which is itself
the mechanism that prevents the user from being routed back to
`StudyScreen` mid-session.

### 1. Starting the session — first activity

1. `_LearningSessionScreenState.initState()` calls
   `ref.read(learningSessionControllerProvider.notifier).start()`
   (`learning_session_screen.dart:50`).
2. `LearningSessionController.start()`
   (`presentation/learning_session_controller.dart:57-82`):
   - Builds a `LearningPlanContext` via `_buildContext({})`, reading
     (preferring already-cached sync values, falling back to `.future`
     only on cold start):
     - `dueReviewCardsProvider` (`learning/data/scheduler_providers.dart:82-88`)
       → `dueReviewCount`.
     - `dueFlashcardCardsProvider` (`flashcards/data/flashcard_providers.dart`)
       → `dueFlashcardCount`.
     - `quizAvailable: true` always (Quiz generates dynamically from
       always-available content, no "due" concept).
   - Reads `learningPlannerProvider`, which resolves to
     `SequentialLearningPlanner` by default.
   - Calls `planner.next(context)`.
3. `SequentialLearningPlanner.next()` (`domain/sequential_learning_planner.dart:21-29`)
   is pure and deterministic: it walks a fixed `order`
   (`[review, quiz, flashcard]`) and returns the first activity that
   is **not** already in `completedThisSession` and **is available**
   (`review` needs `dueReviewCount > 0`; `quiz` needs `quizAvailable`;
   `flashcard` needs `(dueFlashcardCount ?? 0) > 0`). Unavailable
   activities are silently skipped, not surfaced as errors.
4. `LearningPlanner` itself is a pure Dart interface
   (`domain/learning_planner.dart:30-34`) with no Flutter/Riverpod/Drift
   imports — everything arrives via `LearningPlanContext`. Deliberately
   swappable for a future AI Tutor-driven planner through the same
   interface without touching Review/Quiz/Flashcard.
5. `start()` sets `state` to `(status: inProgress or completed, currentActivity: next, ...)`.
   **As of Sprint S2 (D1)**: any exception during this is caught and
   turned into `status: failed` with the error preserved
   (`LearningSessionState.error`) — added because `Notifier` (unlike
   `AsyncNotifier`) doesn't auto-wrap async errors. The UI surfaces
   this via the same `LoadingState`/`SearchErrorState` widgets every
   other feature uses, with a `retry()` that re-attempts whichever
   step failed.

### 2. Rendering the current activity

`LearningSessionScreen.build()` (`learning_session_screen.dart:54-119`)
switches on `session.status`/`session.currentActivity` and returns the
existing, **unmodified** screen widgets directly as the build result
(no extra `Scaffold` wrapper): `ReviewSessionScreen`,
`QuizSessionScreen`, or `FlashcardReviewScreen`.

### 3. Detecting activity completion — the `ref.listen` pattern

Because `LearningSessionController` doesn't own Review/Quiz/Flashcard
state, completion must be detected by watching those modules' own
providers from the UI layer and reacting:

- While `currentActivity == review`: `ref.listen(dueReviewCardsProvider, ...)`
  (`learning_session_screen.dart:63-71`) — when the due list becomes
  empty, calls `completeCurrentActivity()` once (guarded by
  `_reviewCompletionHandled` to avoid duplicate calls if the provider
  re-emits "done" more than once).
- While `currentActivity == quiz`: `ref.listen(quizSessionControllerProvider, ...)`
  (`learning_session_screen.dart:76-88`) — fires when
  `quiz.isComplete`. Deliberately **only** listened to while Quiz is
  the current activity, because merely reading
  `quizSessionControllerProvider` triggers its `AsyncNotifier.build()`
  (which generates 10 random questions) — reading it early would
  generate a quiz before the user ever reaches it.
- While `currentActivity == flashcard`: `ref.listen(dueFlashcardCardsProvider, ...)`
  (`learning_session_screen.dart:92-104`) — same "due list empty"
  pattern.

Each branch resets its `*_CompletionHandled` flag when the activity is
no longer current, so the guard is per-activity-instance, not global.

### 4. Feeding completion back into the controller

`LearningSessionController.completeCurrentActivity()`
(`presentation/learning_session_controller.dart:94-126`):
1. Adds the current activity to `completedActivities`.
2. Rebuilds `LearningPlanContext` reflecting the post-completion state.
3. Calls `_accumulate()` to fold results into `LearningSessionSummary`:
   - **Review**: `reviewCardsCompleted += (dueCountBeforeActivity - dueCountAfter)`,
     since Review Session doesn't track its own completed-count.
   - **Quiz**: reads `quizSessionControllerProvider.future` for
     `score`/`questions.length`.
   - **Flashcard**: same before/after delta pattern as Review.
4. Asks the planner for the next activity again
   (`planner.next(contextAfter)`).
5. Sets `status: completed` when `planner.next()` returns `null`,
   otherwise `inProgress` with the new `currentActivity`.
6. Same try/catch → `status: failed` handling as `start()` (Sprint S2).

`retry()` re-invokes whichever of `start()`/`completeCurrentActivity()`
had failed, based on whether `currentActivity` is still null.

### 5. Ending at the summary screen

When `session.status == completed`, `LearningSessionScreen.build()`
returns `LearningSummaryScreen(state: session)`. `LearningSummaryScreen`
is a pure, stateless presentation of the already-accumulated
`LearningSessionState` — it reads no providers itself: a stats card
(`reviewCardsCompleted`/`flashcardsCompleted`/`quizScore`) and an
activities checklist. Its "Done" button calls
`context.go(AppRoutes.study)`, returning to the Study tab.

### 6. SRS scheduling, at a high level

`SchedulerRepository` is the sole owner of the ease/interval/due-date
layer on top of items already in the Revision Queue — it does **not**
decide which Ayahs need review (that's `UserContentRepository`/
`ayah_statuses.status='review'`).

- `schedulerSyncProvider` (`learning/data/scheduler_providers.dart:37-47`)
  watches `UserContentRepository.watchAllReviewAyahs()` and calls
  `SchedulerRepositoryImpl.syncItemsForType()` whenever the Queue
  changes: new members get a fresh `srs_cards` row seeded from
  `SchedulingAlgorithm.initialState()`; members no longer in the Queue
  get soft-deleted; members that return are revived rather than
  re-inserted, preserving the `UNIQUE(item_type, item_id)` constraint.
- `dueReviewCardsProvider` watches `schedulerSyncProvider` first (to
  guarantee freshness), then filters/sorts/dedups via
  `selectDueCardsOrdered()` — "due" = `due_date <= now` (includes
  overdue cards).
- When a review is graded, `SchedulerRepository.applyReview(cardId, grade)`
  (`data/scheduler_repository_impl.dart:144-175`) loads the card's
  current `(easeFactor, intervalDays, repetitions, state)`, delegates
  the actual scheduling math to
  `SchedulingAlgorithm.review(current, grade, now)` (default:
  `SM2SchedulingAlgorithm`) — the algorithm returns a new state — and
  the repository simply persists that result back to the `srs_cards`
  row. The repository itself contains no SM-2 math; it's purely
  "load → delegate → write."

### Summary (Flow 3)

```
LearningSessionScreen.initState()
  → LearningSessionController.start()
    → _buildContext(): dueReviewCardsProvider, dueFlashcardCardsProvider
    → learningPlannerProvider (SequentialLearningPlanner).next(context)
    → state = inProgress(currentActivity) | completed | failed

LearningSessionScreen.build()
  → renders ReviewSessionScreen | QuizSessionScreen | FlashcardReviewScreen
    (unmodified, reused screens)
  → ref.listen(dueReviewCardsProvider / quizSessionControllerProvider /
               dueFlashcardCardsProvider)  [only for the CURRENT activity]
    → on "done" signal → completeCurrentActivity()
      → accumulate LearningSessionSummary (delta-based for review/flashcard)
      → planner.next(contextAfter) → next activity | null

status == completed
  → LearningSummaryScreen(state)  [pure presentation, no provider reads]
  → "Done" → context.go(AppRoutes.study)
status == failed (Sprint S2)
  → LoadingState/SearchErrorState + retry()

[SRS, underlying Review/Flashcard grading]
Grade submitted → SchedulerRepository.applyReview(cardId, grade)
  → SchedulingAlgorithm (SM2SchedulingAlgorithm).review(current, grade, now)
  → UserDatabase.srs_cards  [UPDATE easeFactor/intervalDays/repetitions/state/dueDate]
```

---

## Flow 4 — AI Composition Chain (Analytics → AI Tutor → Learning Journey → Smart Learning → Read Model)

This is a five-layer, strictly one-directional composition chain: each
layer's repository constructor takes **exactly one** dependency — the
repository directly below it. None of these layers contains an actual
AI/LLM call yet — every "smart" decision is a pure, rule-based/threshold
function over data computed by the layer(s) below. See
`MASTER_ARCHITECTURE.md` §4.1 for the architectural rule this follows.

### Layer 0 — Analytics's own leaf repositories

`AnalyticsRepositoryImpl` (`analytics/data/analytics_repository_impl.dart:76-219`)
is constructed from **four** independent repositories:
`SchedulerRepository`, `FlashcardRepository`, `LexiconRepository`,
`StudySessionRepository`. These are the actual leaves — they own real
Drift tables. Analytics is explicitly "no Drift table of its own —
every number is derived from data that already exists."

### Layer 1 — Analytics

`AnalyticsRepository` exposes: `getLearningStatistics()`,
`getLearningHistory(granularity)`, `getPerformanceInsights()`,
`getLearningGoals()`, `getAchievements()`. What each computes:
- `getLearningStatistics()`: loads all `SrsCard`s (ayah + lemma) via
  `_loadAllCards()` + current/longest reading streak from
  `StudySessionRepository`, runs the pure function
  `computeLearningStatistics()` — `cardsStudied`, `dueToday`,
  `reviewsToday`, `accuracy`, `averageEase`, `averageInterval`.
- `getLearningHistory(granularity)`: loads all study sessions, runs
  `computeLearningHistory()` — time-bucketed minutes-studied history.
- `getPerformanceInsights()`: joins flashcards → lexicon lemmas →
  lemma-type SRS cards, runs `computePerformanceInsights()`.
- `getLearningGoals()`: the one call optimized *within itself* — via a
  private `_AnalyticsSnapshot` it loads cards + sessions exactly once,
  then calls the statistics/history calculators multiple times on that
  one snapshot, instead of re-issuing repository queries per
  calculator. This intra-call optimization is explicitly scoped to not
  span *across* separate public calls — calling `getLearningGoals()`
  and `getAchievements()` back-to-back still re-queries independently,
  to avoid ever returning stale data.
- `getAchievements()`: calls `getLearningStatistics()` again
  internally, then `computeAchievements()`.

Provider layer: `analyticsRepositoryProvider`, with
`FutureProvider.autoDispose` wrappers per method — consumed directly
by `ProgressDashboardScreen`.

### Layer 2 — AI Tutor

`AITutorRepositoryImpl` (`ai_tutor/data/ai_tutor_repository_impl.dart:27-57`)
composes **only** `AnalyticsRepository`. `getTutorContext()` calls all
four Analytics methods and bundles them into a `TutorContext`.
`getSuggestions()`/`getInsights()` each call `getTutorContext()` again
internally, then run the pure functions `computeTutorSuggestions()`
(threshold rules like "if `dueToday > 0`, suggest reviewing due cards
with high priority") and `computeTutorInsights()`. No caching between
calls by design — "Foundation only. No AI model integration yet."

Provider layer: `aiTutorRepositoryProvider`, plus
`tutorContextProvider`, `tutorSuggestionsProvider`,
`tutorInsightsProvider`. **UI consumer:** `TutorHomeScreen`
(route `/ai-tutor`) watches all three directly, and only these three
— never `AnalyticsRepository`/`AITutorRepository` internals.

### Layer 3 — Learning Journey

`LearningJourneyRepositoryImpl` (`learning_journey/data/learning_journey_repository_impl.dart:26-53`)
composes **only** `AITutorRepository`. `getLearningJourney()` calls
`getTutorContext()` + `getSuggestions()` + `getInsights()` (three
separate AI Tutor calls, each of which re-derives from Analytics),
then runs `computeDailyLearningPlan()` (pure priority sort of
suggestions) to build the `todayPlan`, bundling
`{context, todayPlan, insights}` into a `LearningJourney`.

Provider layer: `learningJourneyRepositoryProvider`,
`learningJourneyProvider` (full journey, watched by
`LearningJourneyScreen`, route `/learning-journey`, pushed from
`TutorHomeScreen`'s `_JourneyEntryCard`).

**Caching/reuse optimization #1 — `dailyLearningPlanProvider`:**
reuses `tutorSuggestionsProvider`'s already-computed result rather
than going through `learningJourneyRepositoryProvider.getDailyPlan()`
— see `PROVIDER_MAP.md` §2.3 for the full mechanism and why
`learningJourneyProvider` itself deliberately does **not** get this
treatment.

### Layer 4 — Smart Learning

`SmartLearningRepositoryImpl` (`smart_learning/data/smart_learning_repository_impl.dart:23-38`)
composes **only** `LearningJourneyRepository`. `getSmartLearningSession()`
calls `getLearningJourney()`, then runs `computeSmartLearningSession()`
— a pure grouping/ranking function that walks
`journey.todayPlan.steps` (already priority-ordered from Layer 3),
maps each step's suggestion kind to a `SessionStrategy`, and groups
steps by strategy in first-seen order into `LearningRecommendation`s
with estimated minutes. The result `SmartLearningSession` also retains
the source `LearningJourney` verbatim in its `journey` field — added
specifically so Layer 5 doesn't need to know `LearningJourneyRepository`
exists.

Provider layer: `smartLearningRepositoryProvider`,
`smartLearningSessionProvider`. **UI consumer:** `SmartLearningScreen`
(route `/smart-learning`, pushed from `LearningJourneyScreen`).

### Layer 5 — Read Model

`LearningSnapshotRepositoryImpl` (`read_model/data/learning_snapshot_repository_impl.dart:25-42`)
composes **only** `SmartLearningRepository`. `getSnapshot()` calls
`getSmartLearningSession()`, then `computeLearningSnapshot()` — a
pure, read-only projection (no recomputation) that pulls
`TutorContext`/`List<TutorInsight>`/`DailyLearningPlan` straight out
of `session.journey` (Layer 3's output, carried through Layer 4) plus
the `SmartLearningSession` itself, and stamps a `SnapshotTimestamp`.
`LearningSnapshot` is documented as **immutable** — once built, it
never changes; a new one requires calling `getSnapshot()` again.

**Current state — no UI consumer.** `features/read_model/` contains
only `data/` and `domain/` — no `presentation/`, no route, no screen
anywhere reads `learningSnapshotProvider` or
`LearningSnapshotRepository`. This is a statement of current fact, not
a defect — see [RELEASE_PLAN_V1.md](../release/RELEASE_PLAN_V1.md) §2
(D3) and [PRODUCT_ROADMAP.md](../release/PRODUCT_ROADMAP.md) v1.1 for
the decision this needs.

**Caching/reuse optimization #2 — `learningSnapshotProvider`**
(described by its own doc comment as "the biggest saving in the whole
chain"): bypasses `learningSnapshotRepositoryProvider.getSnapshot()`
and reuses `smartLearningSessionProvider`'s already-computed result if
some other screen (e.g. `SmartLearningScreen`) is keeping it alive —
avoiding the entire chain below it (Smart Learning → Learning Journey
→ 3×AI Tutor calls → up to 12×Analytics calls) when warm. See
`PROVIDER_MAP.md` §2.3.

### Summary (Flow 4)

```
Layer 0 (leaves, real Drift tables):
  SchedulerRepository (UserDatabase.srs_cards)
  FlashcardRepository (UserDatabase.flashcards)
  LexiconRepository   (AppDatabase, lemma tables)
  StudySessionRepository (UserDatabase.study_sessions)

Layer 1 — AnalyticsRepositoryImpl(scheduler, flashcards, lexicon, studySessions)
  getLearningStatistics / getLearningHistory / getPerformanceInsights /
  getLearningGoals / getAchievements
  → consumed directly by ProgressDashboardScreen

Layer 2 — AITutorRepositoryImpl(analytics)
  getTutorContext (calls all 4 Analytics methods) / getSuggestions / getInsights
  → consumed directly by TutorHomeScreen (/ai-tutor)

Layer 3 — LearningJourneyRepositoryImpl(aiTutor)
  getLearningJourney (calls 3 AI Tutor methods) → computeDailyLearningPlan
  → consumed directly by LearningJourneyScreen (/learning-journey)
  [optimization] dailyLearningPlanProvider reuses tutorSuggestionsProvider
                 directly, bypassing this repository

Layer 4 — SmartLearningRepositoryImpl(learningJourney)
  getSmartLearningSession (calls getLearningJourney) → computeSmartLearningSession
  → consumed directly by SmartLearningScreen (/smart-learning)

Layer 5 — LearningSnapshotRepositoryImpl(smartLearning)
  getSnapshot (calls getSmartLearningSession) → computeLearningSnapshot
  → LearningSnapshot (immutable) — NO UI CONSUMER as of this version
  [optimization] learningSnapshotProvider reuses smartLearningSessionProvider
                 directly, bypassing this repository AND everything below it
                 if the upstream provider is already warm (up to 12 Analytics
                 calls avoided)
```

---

**Notes on scope not covered above**: audio playback auto-scroll in
`ReadingScreen` (`ref.listen<AudioState>`, `reading_screen.dart:176-192`)
and bookmark/favorite annotation writes via
`userContentRepositoryProvider` both touch the reading screen but are
secondary to the four requested flows and were only skimmed. See
`PROVIDER_MAP.md` for the full provider catalog these flows draw on.
