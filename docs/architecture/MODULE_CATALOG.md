# MODULE_CATALOG.md

Written after PR #19. 18 feature directories existed under
`lib/features/` at that time and are catalogued below by name:
`ai_tutor, analytics, flashcards, home, khatm,
learning, learning_journey, learning_session, lexicon, library,
profile, quiz, quran, read_model, search, smart_learning, stats,
study`. Each entry below was verified against that feature's own
repository/screen doc comments and actual cross-feature
`import '../../<feature>/...'` statements (not guessed from the
directory name), plus `lib/app/router.dart` for routes. See
`MASTER_ARCHITECTURE.md` for the architectural rules these all follow.

A 19th directory, `hifz`, was added in a later sprint and is **not yet
catalogued below** — its own entry needs the same verification pass
(dependencies, entry points, router wiring) as the 18 below, not a
guess from the directory name.

---

### `ai_tutor`
**Responsibility:** Foundation for an "AI Tutor" that turns Analytics
data into suggestions and insights using pure threshold/condition
logic — explicitly "Foundation only. No AI model integration yet."
**Dependencies:** `analytics` (the only repository it composes);
`flashcards` (`SmartDeckType`, used to route a suggestion to a Smart
Deck); `search` (`SearchErrorState` widget reuse). Database: none
directly — composes `AnalyticsRepository` only.
**Entry points:** `TutorHomeScreen` at `AppRoutes.aiTutor = '/ai-tutor'`,
pushed full-screen from the Study tab.

### `analytics`
**Responsibility:** Aggregates existing Scheduler/Flashcard/Lexicon/
StudySession data into learning statistics, activity history,
performance insights, goals, and achievements, owning no storage of
its own — "No duplicated statistics."
**Dependencies:** `flashcards` (`FlashcardRepository` interface,
`ResolvedFlashcard`/`FlashcardTile` widget in the dashboard);
`learning` (`SrsCard` entity + `SchedulerRepository`); `lexicon`
(`Lemma` entity + `LexiconRepository`); `stats` (`StudySession` entity
+ `StudySessionRepository`); `search` (`SearchErrorState` reuse).
Database: none directly — pure composition of 4 already-DB-backed
repositories.
**Entry points:** `ProgressDashboardScreen` at
`AppRoutes.progressDashboard = '/progress-dashboard'`.

### `flashcards`
**Responsibility:** Owns user-created Flashcards and Flashcard Decks
that point at Lexicon entries (Lemma/Root/Phrase) by reference rather
than copying content, plus dynamically-computed "Smart Decks."
**Dependencies:** `lexicon` (`LexiconEntryType`, `Lemma`, `Lexeme`
entities and `LexiconRepository`); `learning` (`SrsCard` entity and
`SchedulerRepository`, bridged only at the Provider layer via
`flashcardSchedulerSyncProvider` — never a direct repository
dependency). Database: UserDatabase, via `FlashcardRepositoryImpl`.
**Entry points:** `FlashcardBrowseScreen` (`/flashcards`),
`AddFlashcardScreen` (`/flashcards/add`), `FlashcardDecksScreen`
(`/flashcard-decks`), `SmartDeckScreen` (`/flashcards/smart-deck`),
`FlashcardReviewScreen` (`/flashcard-review`).

### `home`
**Responsibility:** App landing tab — a deterministic "Verse of the
Day" pick, continue-reading shortcut, and daily-goal summary,
aggregating Qur'an and Stats data.
**Dependencies:** `quran` (`quran_providers`, `AyahContent`/`Surah`
entities, `reading_position_store`, `surah_list_controller`); `stats`
(`daily_goal_providers`, `stats_store`, `study_session_providers`,
`daily_goal_dialog` widget). Database: none directly — no `domain/`/
`data/` folder of its own; reads entirely through `quran`'s and
`stats`' providers.
**Entry points:** `HomeScreen` at `AppRoutes.home = '/home'` — the
app's `initialLocation`.

### `khatm`
**Responsibility:** Tracks progress through a "Khatm" (a full Qur'an
read-through cycle): start, update progress, complete, delete.
**Dependencies:** `quran` (`quran_providers` and `reading_navigation`,
used by `ActiveKhatmCard` to jump back into reading). Database:
UserDatabase, via `KhatmCycleRepositoryImpl`.
**Entry points:** No dedicated screen or route — surfaces only as the
`ActiveKhatmCard` widget embedded at the top of `StatsScreen`, reached
via `AppRoutes.stats = '/stats'`.

### `learning`
**Responsibility:** SM-2 spaced-repetition Scheduler — adds an
ease/interval/due-date layer on top of items already in the Revision
Queue (and, later, Flashcard lemma items), without owning or replacing
the queue itself.
**Dependencies:** `quran` (`quran_providers`, `AyahSearchResult`
entity, `reading_navigation`, `user_content_providers`). Database:
UserDatabase, via `SchedulerRepositoryImpl`.
**Entry points:** `ReviewSessionScreen` at
`AppRoutes.reviewSession = '/review-session'`.

### `learning_journey`
**Responsibility:** Third tier of the 5-tier AI/learning chain —
packages AI Tutor's context, suggestions, and insights into one
"Learning Journey" view (today's plan plus overall progress),
rule-based only.
**Dependencies:** `ai_tutor` (`AITutorRepository` — the only repository
it composes; domain entities `TutorSuggestion`/`TutorInsight`;
presentation helpers `tutor_action_navigator.dart`/`tutor_presentation.dart`,
reused unmodified); `search` (`SearchErrorState` reuse). Database: none
directly — composes `AITutorRepository` only.
**Entry points:** `LearningJourneyScreen` at
`AppRoutes.learningJourney = '/learning-journey'`, pushed only from
`TutorHomeScreen`.

### `learning_session`
**Responsibility:** Single-route orchestrator (`/learning-session`)
that stitches Review/Quiz/Flashcard activities into one guided
session, deciding "what's next" via a pure, swappable `LearningPlanner`
interface.
**Dependencies:** `flashcards` (`flashcard_providers`,
`FlashcardReviewScreen`, reused unmodified as the session body);
`learning` (`scheduler_providers`, `ReviewSessionScreen`); `quiz`
(`quiz_providers`, `QuizSessionScreen`); `search` (`SearchErrorState`
reuse). Database: none directly — composes other features' providers/
screens; its own `LearningPlanner` domain logic takes all state as
explicit input and touches no Flutter/Riverpod/Drift.
**Entry points:** `LearningSessionScreen` and `LearningSummaryScreen`
at `AppRoutes.learningSession = '/learning-session'` — deliberately one
route for the whole session, with no per-activity sub-route.

### `lexicon`
**Responsibility:** Read-only gateway to Qur'anic vocabulary content —
Roots, Lemmas, Lexemes, Word Instances, Grammar Features, Phrases, and
their relations — deliberately designed for future content types
beyond just Vocabulary/Flashcards.
**Dependencies:** None. Explicitly documented as depending on nothing
else: "Lexicon KHÔNG phụ thuộc Flashcards/LearningSession." Database:
AppDatabase, via `LexiconRepositoryImpl`.
**Entry points:** None — this feature has no `presentation/` directory
at all; it is consumed as a pure data source by `flashcards`,
`analytics`, and (transitively) `ai_tutor`.

### `library`
**Responsibility:** "My Library" — four tabs (Saved / Favorites /
Notes / Highlights) aggregating all of a user's Ayah annotations,
tap-to-jump to the Ayah, plus Bookmark Collections management.
**Dependencies:** `quran` (`quran_providers`, `user_content_providers`,
`AyahSearchResult` entity, `QuranRepository` interface,
`reading_navigation`). Database: UserDatabase, via
`BookmarkCollectionRepositoryImpl`; the underlying annotation data
itself is read through `quran`'s `UserContentRepository`, also
UserDatabase-backed.
**Entry points:** `LibraryScreen` (`/library`), pushed from
`ProfileScreen`; `CollectionsScreen` (`/collections`), pushed from
`LibraryScreen` itself.

### `profile`
**Responsibility:** Settings screen — theme (Light/System/Dark) and
language (vi/en/ar) today; personal profile, learning goals, and cloud
sync are documented as future steps.
**Dependencies:** None — imports only app-level infrastructure
(`app/locale/locale_controller.dart`, `app/router.dart`,
`app/theme/theme_controller.dart`), no other feature. Database: none —
settings are SharedPreferences-backed, not Drift.
**Entry points:** `ProfileScreen` at `AppRoutes.profile = '/profile'`.

### `quiz`
**Responsibility:** Generates ephemeral multiple-choice quiz questions
(4 question types) from Qur'an content and persists only the resulting
score — explicitly no Question Bank, no stored question content.
**Dependencies:** `quran` (`quran_providers`, used to build a temporary
content pool from Group A data for question generation, without
persisting it). Database: UserDatabase, via `QuizRepositoryImpl`.
**Entry points:** `QuizSessionScreen` at
`AppRoutes.quizSession = '/quiz-session'`.

### `quran`
**Responsibility:** The app's central feature, combining two
concerns: read-only Qur'an content access (Surahs, Ayahs, translations,
audio, full-text search) and user annotations on Ayahs (bookmark,
highlight, note, reading status) — presented through the app's most
important screen, the Reading screen.
**Dependencies:** `stats` (`stats_store`, `study_session_providers`,
`StudySessionRepository` interface — the Reading screen logs study
sessions as the user reads). Database: **both** — `QuranRepositoryImpl`
on AppDatabase and `UserContentRepositoryImpl` on UserDatabase, kept as
two entirely separate repository classes within this one feature
directory; neither class touches both databases.
**Entry points:** `SurahListScreen` (`/quran`); `ReadingScreen` nested
at `surah/:id` inside the 5-tab shell; and a second, top-level
`ReadingScreen` route at `/read/:id` for full-screen access from
outside the tab shell (e.g. from `library`) — see `DATA_FLOW.md` Flow 2
for why two routes exist.

### `read_model`
**Responsibility:** Top tier of the 5-tier AI/learning chain —
packages `TutorContext`/`TutorInsights`/`DailyLearningPlan`/
`SmartLearningSession` into one immutable "Learning Snapshot," with an
explicitly deferred caching policy ("No caching policy yet").
**Dependencies:** `smart_learning` (`SmartLearningRepository` — the
only repository it composes; `smartLearningSessionProvider`, reused at
the Provider layer). Database: none directly — composes
`SmartLearningRepository` only.
**Entry points:** None. This feature has no `presentation/` directory.
Its own provider file states plainly: "Read Model chưa có màn hình" —
it is not currently reachable from any route.

### `search`
**Responsibility:** UI foundation for searching the Qur'an and
personal notes, structured around two independent axes (Search vs. Ask
mode; content scope — Qur'an / My Notes / All) plus a dev-only
state-preview switcher; explicitly **not yet wired** to a real search
engine.
**Dependencies:** `quran` (`AyahSearchResult` entity,
`reading_navigation`). Database: none — this feature has no `data/`
directory; presentation-only, and does not yet call
`QuranRepository.searchAyahs()`.
**Entry points:** `SearchScreen` at `AppRoutes.search = '/search'`,
pushed from `HomeScreen` and `SurahListScreen`.

### `smart_learning`
**Responsibility:** Fourth tier of the 5-tier chain — turns Learning
Journey's suggestions into a ranked "Smart Learning Session" of
recommended strategies, rule-based only.
**Dependencies:** `learning_journey` (`LearningJourneyRepository` — the
only repository it composes; `LearningJourney` domain entities);
`search` (`SearchErrorState` reuse). Database: none directly —
composes `LearningJourneyRepository` only.
**Entry points:** `SmartLearningScreen` at
`AppRoutes.smartLearning = '/smart-learning'`, pushed only from
`LearningJourneyScreen`.

### `stats`
**Responsibility:** Local statistics screen — reading days, Ayahs
read, minutes studied, completion %, streaks, and a 7-day bar chart,
computed from `StudySession` records.
**Dependencies:** `khatm` (`ActiveKhatmCard` widget, embedded at the
top of the screen); `quran` (`reading_position_store`, used for the
continue-reading affordance). Database: UserDatabase, via
`StudySessionRepositoryImpl`; also reads/writes SharedPreferences
directly for local counters and the daily-goal setting, alongside the
DB-backed session history.
**Entry points:** `StatsScreen` at `AppRoutes.stats = '/stats'`.

### `study`
**Responsibility:** The "Study" tab hub — a primary "Start Learning
Session" entry point plus four direct shortcut tools (Flashcards,
Spaced Repetition, Quiz, Daily Revision), both intentionally kept side
by side.
**Dependencies:** `library` (`LibraryItem`/`LibraryKind` entities and
the `LibraryTabView` widget, reused unmodified by `RevisionQueueScreen`);
`quran` (`reading_navigation`). Database: none directly — a pure
navigation hub plus `RevisionQueueScreen`, which itself reads through
`quran`'s/`library`'s providers rather than owning any repository of
its own.
**Entry points:** `StudyScreen` at `AppRoutes.study = '/study'` and
`RevisionQueueScreen` at `AppRoutes.revisionQueue = '/revision-queue'`.

---

See `PROVIDER_MAP.md` §3 for the full cross-feature provider
consumption graph, and `DATA_FLOW.md` for how several of these features
compose together in practice across four representative user flows.
