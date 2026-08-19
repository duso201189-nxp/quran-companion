# MASTER_ARCHITECTURE.md

Written after PR #19 (Sprint S2 — Quality & Polish), studying the fully
merged codebase directly rather than prior documentation. Where this
disagrees with `ARCHITECTURE.md`'s original design narrative, this
document reflects the code as it exists today; `ARCHITECTURE.md` remains
useful for historical design rationale.

## 1. Overview

Qur'an Companion is a Flutter app organized as a **feature-first,
three-layer architecture**: `presentation → domain ← data`, applied
independently inside each of the 19 directories under `lib/features/`
(18 at the time of this writing plus `hifz`, added in a later sprint;
see `MODULE_CATALOG.md`'s own note on `hifz`).
This is not a top-down textbook layering imposed once at the app root —
it is repeated per feature, and verified here directly against two
representative features (`lib/features/flashcards/` and
`lib/features/analytics/`) rather than assumed.

```
lib/
├─ main.dart              # bootstrap: only sharedPreferencesProvider and
│                          # ayahAudioPlayerProvider need explicit override
│                          # (lib/main.dart:16-23) — everything else
│                          # (AppDatabase, UserDatabase, Logger,
│                          # CrashReporter, every repository) self-
│                          # constructs lazily inside its own provider
├─ app/                   # MaterialApp.router assembly, go_router, theming, locale
├─ core/                  # cross-cutting infrastructure — no business logic
│  ├─ database/           # AppDatabase (Group A) + database/user/ (UserDatabase, Group B)
│  ├─ error/              # AppFailure / FailureCategory / FailureSeverity / failure_mapper
│  ├─ logging/             # Logger / CrashReporter / ConsoleLogger / repository_boundary_logging
│  ├─ storage/             # SharedPreferences provider (settings, not Drift)
│  ├─ audio/, cache/, env/ # audio playback, download cache, dev/staging/prod config
├─ features/<name>/       # 19 feature modules, each own presentation/domain/data
├─ shared/widgets/, shared/utils/  # cross-feature reusable UI + pure helpers
└─ l10n/                  # app_vi.arb (default) / app_en.arb / app_ar.arb (RTL)
```

Confirmed against `flashcards/` (`lib/features/flashcards/{data,domain,presentation}`)
and `analytics/` (`lib/features/analytics/{data,domain,presentation}`):
both follow the same three-folder shape, and both keep `domain/` free of
Flutter/Riverpod/Drift imports (verified below in §3).

Two infrastructure concerns run orthogonally to this feature layering
and are described in their own sections:

- **The dual-database split** (§2) — which repositories read/write
  `AppDatabase` (static Qur'an/lexicon content, "Group A") vs
  `UserDatabase` (user-generated data, "Group B").
- **The reliability layer** (§2) — `AppFailure`/`Logger`/`CrashReporter`
  wrapping every repository boundary that touches a database directly.

## 2. The two infrastructure concerns

### 2.1 Dual-database split (Group A vs Group B)

The terminology "Group A" / "Group B" is not documentation-only — it is
used directly in code. `lib/core/database/tables/content_tables.dart:3`
labels its tables `/// Bảng nhóm A — nội dung Qur'an tĩnh, CHỈ ĐỌC.`
("Group A tables — static Qur'an content, READ ONLY"), and
`lib/core/database/user/user_tables.dart:3` labels its tables
`/// Bảng nhóm B — dữ liệu người dùng.` ("Group B tables — user data").
`lib/core/error/failure_category.dart:6` even classifies database
failures as `/// Lỗi từ Drift/SQLite (đọc/ghi Group A hoặc Group B
database).`

- **`AppDatabase`** (`lib/core/database/app_database.dart:23-39`) — a
  Drift database over 14 tables (`Surahs, Ayahs, TranslationSources,
  Translations, Reciters, MetaEntries, Roots, Lemmas, Lexemes,
  WordInstances, GrammarFeatures, Phrases, PhraseWordInstances,
  LexiconRelations`), built offline by `tool/build_quran_db.py`,
  shipped as a read-only asset, opened lazily via `appDatabaseProvider`
  (`lib/core/database/database_providers.dart:8-12`).
- **`UserDatabase`** (`lib/core/database/user/user_database.dart:10-26`)
  — a **separate** Drift database, opened via a separate connection
  (`user_database_providers.dart:6-10`), currently at
  `schemaVersion = 8` with 14 tables (`Bookmarks, Highlights, Notes,
  Favorites, AyahStatuses, StudySessions, KhatmCycles,
  BookmarkCollections, SrsCards, QuizResults, FlashcardDecks,
  Flashcards, HifzPlans, ReviewEvents`). Migrations are strictly
  additive — the doc comment is explicit: `KHÔNG BAO GIỜ drop dữ liệu
  người dùng` ("NEVER drop user data", `user_database.dart:37`), and
  every `onUpgrade` step only calls `createTable`/`addColumn`
  (`user_database.dart:38-75`).
  Every Group B table mixes in `SyncColumns` (`user_tables.dart:10-17`) —
  client-generated UUID `id`, nullable `user_id`, `updated_at`,
  nullable `deleted_at` (soft delete), `is_dirty` — preparing for a
  not-yet-built cloud sync engine without any sync code existing yet.

**Which repository implementation touches which database** (verified
by reading each `*_repository_impl.dart`, not inferred from feature
names):

| Repository implementation | File | Database | Tables owned |
|---|---|---|---|
| `QuranRepositoryImpl` | `lib/features/quran/data/quran_repository_impl.dart:3` | AppDatabase (Group A) | Surahs, Ayahs, Translations, Reciters, MetaEntries |
| `LexiconRepositoryImpl` | `lib/features/lexicon/data/lexicon_repository_impl.dart:3` | AppDatabase (Group A) | Roots, Lemmas, Lexemes, WordInstances, GrammarFeatures, Phrases, LexiconRelations |
| `UserContentRepositoryImpl` | `lib/features/quran/data/user_content_repository_impl.dart:6` | UserDatabase (Group B) | Bookmarks, Highlights, Notes, Favorites, AyahStatuses |
| `StudySessionRepositoryImpl` | `lib/features/stats/data/study_session_repository_impl.dart:4` | UserDatabase (Group B) | StudySessions |
| `KhatmCycleRepositoryImpl` | `lib/features/khatm/data/khatm_cycle_repository_impl.dart:4` | UserDatabase (Group B) | KhatmCycles |
| `BookmarkCollectionRepositoryImpl` | `lib/features/library/data/bookmark_collection_repository_impl.dart:4` | UserDatabase (Group B) | BookmarkCollections |
| `SchedulerRepositoryImpl` | `lib/features/learning/data/scheduler_repository_impl.dart:4` | UserDatabase (Group B) | SrsCards |
| `QuizRepositoryImpl` | `lib/features/quiz/data/quiz_repository_impl.dart:4` | UserDatabase (Group B) | QuizResults |
| `FlashcardRepositoryImpl` | `lib/features/flashcards/data/flashcard_repository_impl.dart:4` | UserDatabase (Group B) | FlashcardDecks, Flashcards |

That is exactly 9 repositories with direct database access — the same
9 that import `repository_boundary_logging.dart` (confirmed by grep of
both `AppDatabase|UserDatabase` imports and `withFailureLogging` call
sites — identical file sets). **No single repository class touches both
databases.** The one place this needs a caveat is the `quran` feature
*directory*, which contains two separate repository classes —
`QuranRepositoryImpl` (Group A only) and `UserContentRepositoryImpl`
(Group B only) — kept as independent classes precisely so neither one
crosses the boundary; they are bridged, where needed, at the Provider
layer rather than inside either repository.

A fifth tier of repositories (`AnalyticsRepositoryImpl`,
`AITutorRepositoryImpl`, `LearningJourneyRepositoryImpl`,
`SmartLearningRepositoryImpl`, `LearningSnapshotRepositoryImpl`)
touches **neither** database directly — see §4, "5-tier composition
chain."

Outside the two Drift databases,
`lib/core/storage/prefs_provider.dart` wraps `SharedPreferences` for
lightweight settings (theme, locale, reading position, reading font
scale, daily-goal counters, stats' local counters in
`stats_store.dart`/`daily_goal_store.dart`) — this is a third, much
smaller persistence mechanism that sits alongside, not inside, the
Group A/B split.

### 2.2 Reliability layer (Logger / AppFailure / CrashReporter)

The reliability layer normalizes and logs every error at the
repository boundary, without changing any behavior:

- **`AppFailure`** (`lib/core/error/app_failure.dart:16-42`) — a
  plain-Dart value type (`category`, `severity`, diagnostic `message`,
  `cause`, `stackTrace`), explicitly *not* a UI-facing string: `KHÔNG
  nhúng chuỗi hiển thị người dùng` ("does not embed user-facing display
  strings", `app_failure.dart:6`).
- **`FailureCategory`** (`lib/core/error/failure_category.dart:5-18`)
  — exactly 4 values: `database`, `parsing`, `storage`, `unexpected`,
  classified by *technical origin*, not by feature.
- **`FailureSeverity`** (`lib/core/error/failure_severity.dart:6-22`) —
  `info` → `warning` → `error` → `critical`, describing business
  impact, distinct from the `Logger`'s own debug/info/warning/error
  levels (`failure_severity.dart:1-5`).
- **`mapToAppFailure`** (`lib/core/error/failure_mapper.dart:20-60`) —
  the single pure function that classifies any caught `Object` into an
  `AppFailure` (Drift exceptions → `database`, `FormatException` →
  `parsing`, `FileSystemException` → `storage`, everything else →
  `unexpected/critical`). Idempotent if already an `AppFailure`.
- **`withFailureLogging` / `withFailureLoggingStream`**
  (`lib/core/logging/repository_boundary_logging.dart:18-56`) — the
  *only* place in the project that applies `mapToAppFailure`/`Logger`
  to a repository call. The doc comment states the contract explicitly:
  on success, return the identical value; on error, **always
  `rethrow` the original error unchanged**
  (`repository_boundary_logging.dart:9-14`) — logging is described as
  "the only side effect" ("Only diagnostics improve"). This wrapper is
  used inside all 9 database-backed `*_repository_impl.dart` files
  listed in §2.1 (61 call sites across those 9 files).
- **`Logger`** (`lib/core/logging/logger.dart:8-22`) — an abstract
  interface (`debug/info/warning/error`), deliberately independent of
  `AppFailure`/Flutter/any logging package, so it "can be called from
  any layer" (`logger.dart:1-7`).
- **`ConsoleLogger`** (`lib/core/logging/console_logger.dart:56-93`) —
  the sole concrete `Logger` today, backed by `dart:developer.log` (not
  `print`, which is lint-forbidden).
- **`CrashReporter`** (`lib/core/logging/crash_reporter.dart:7-16`) —
  an abstract interface (`recordFailure`, `log` for breadcrumbs);
  **`NoopCrashReporter`** (`lib/core/logging/noop_crash_reporter.dart:10-18`)
  is the only implementation, intentionally doing nothing ("No cloud
  SDK" at this phase).

**The recent wiring change (Sprint S2, D2):** prior to this pass,
`CrashReporter` existed but nothing called `recordFailure()`. `ConsoleLogger`
now takes a `crashReporter` constructor parameter (default
`const NoopCrashReporter()`) and forwards to it inside `error()`, but
**only when a non-null `error` object is present**
(`console_logger.dart:82-92`). `loggerProvider`
(`lib/core/logging/logging_providers.dart:26-28`) now injects
`crashReporterProvider` into the `ConsoleLogger` it builds. Because
`Logger` is the single choke point that `withFailureLogging`/
`withFailureLoggingStream` call on every repository-boundary error,
this one change means **every error crossing any of the 9
database-backed repository boundaries now also reaches
`CrashReporter`** — without touching any of the 9 repository files or
their tests. With `NoopCrashReporter` still the only implementation,
this has no observable effect yet; it is architecture prepared for a
future Crashlytics/Sentry-style implementation to be swapped in with a
single `crashReporterProvider.overrideWithValue(...)` in `main.dart`.

The 5 composition-only repositories in the AI/learning chain
(Analytics, AI Tutor, Learning Journey, Smart Learning, Read Model —
see §4) do **not** call `withFailureLogging` themselves, since they
hold no direct database/Drift dependency; any database error they
might encounter would already have been logged and classified at the
underlying repository they compose.

## 3. Layer responsibilities

Verified against `flashcards/` and `analytics/`, and cross-checked
against `quran/`, `ai_tutor/`, and `learning_journey/`:

### `domain/`
Contains entities (plain Dart classes/records, e.g.
`lib/features/quran/domain/entities/surah.dart`), abstract repository
interfaces (`abstract interface class`, e.g. `FlashcardRepository` at
`lib/features/flashcards/domain/repositories/flashcard_repository.dart:10`),
and pure calculation/generation logic with no side effects (e.g.
`learning_statistics_calculator.dart`, `achievement_calculator.dart`,
`learning_snapshot_generator.dart`, `sequential_learning_planner.dart`).
The independence from Flutter/Riverpod/Drift is stated as an explicit,
repeated design rule rather than an accident — see §5, principle 1.

### `data/`
Contains two kinds of files:
- **`*_repository_impl.dart`** — concrete implementations of the
  domain repository interfaces. Either backed directly by
  `AppDatabase`/`UserDatabase` (the 9 repositories in §2.1) or composed
  purely from other repositories (the 5-tier chain in §4).
- **`*_providers.dart`** — the only place `flutter_riverpod` appears
  in the data layer; constructs repository instances
  (`ref.watch(userDatabaseProvider)`, `ref.watch(loggerProvider)`, e.g.
  `flashcard_providers.dart:19-24`) and wires cross-repository
  orchestration that is *not* allowed to live inside a repository class
  itself. Example: `flashcardSchedulerSyncProvider`
  (`flashcards/data/flashcard_providers.dart:50-73`) watches
  `FlashcardRepository` and calls
  `SchedulerRepository.syncItemsForType(...)` — explicitly because
  `FlashcardRepository KHÔNG phụ thuộc SchedulerRepository`
  ("FlashcardRepository does not depend on SchedulerRepository",
  `flashcard_providers.dart:54-56`) — two independently-testable
  repositories, bridged only at the provider layer (principle 9, §5).

### `presentation/`
Screens (`*_screen.dart`, `ConsumerWidget`/`ConsumerStatefulWidget`),
colocated controllers/notifiers (`reading_controller.dart`,
`learning_session_controller.dart`, `surah_list_controller.dart`), and
pure presentation-mapping helpers that convert domain enums into
icon/l10n pairs without recomputing any numbers — e.g.
`tutor_presentation.dart` and `session_strategy_presentation.dart`,
whose purpose is stated directly in the consuming screens: "màn hình
chỉ trình bày lại" — the screen only re-presents figures already
computed at the domain/data layer.

## 4. Dependency rules

### 4.1 The 5-tier AI/learning composition chain

Verified by reading all five `*_repository_impl.dart` files directly.
The chain is real and each tier composes **exactly** the one
immediately below it — never skips a level, never reaches sideways:

```
AnalyticsRepository
   ↑ composed by
AITutorRepository
   ↑ composed by
LearningJourneyRepository
   ↑ composed by
SmartLearningRepository
   ↑ composed by
LearningSnapshotRepository   (feature: read_model)
```

| Tier | Repository | File | Composes | Explicit "never touch directly" rule |
|---|---|---|---|---|
| 1 | `AnalyticsRepository` | `analytics/data/analytics_repository_impl.dart:76-88` | `SchedulerRepository`, `FlashcardRepository`, `LexiconRepository`, `StudySessionRepository` (4 base repositories) | Owns no storage of its own — "No duplicated statistics" |
| 2 | `AITutorRepository` | `ai_tutor/data/ai_tutor_repository_impl.dart:9-13, 27-30` | **only** `AnalyticsRepository` | "KHÔNG tự ý gọi SchedulerRepository/FlashcardRepository/LexiconRepository/StudySessionRepository trực tiếp" |
| 3 | `LearningJourneyRepository` | `learning_journey/data/learning_journey_repository_impl.dart:7-11, 26-30` | **only** `AITutorRepository` | "Compose ONLY: AITutorRepository" |
| 4 | `SmartLearningRepository` | `smart_learning/data/smart_learning_repository_impl.dart:6-9, 23-27` | **only** `LearningJourneyRepository` | "Compose ONLY: LearningJourneyRepository. Never access AITutorRepository directly." |
| 5 | `LearningSnapshotRepository` (feature `read_model`) | `read_model/data/learning_snapshot_repository_impl.dart:6-10, 25-29` | **only** `SmartLearningRepository` | "Compose ONLY: SmartLearningRepository." |

Every tier is explicitly **rule-based, not AI/LLM-backed**, at this
stage of the codebase — each doc comment repeats variants of "No AI
model integration yet." The `read_model` tier additionally documents
that it deliberately performs **no caching yet** — `getSnapshot()`
recomputes fresh every call.

One caching exception is worth noting because it changes call volume
without changing the architecture: at the Provider level (not inside
any repository), `learningSnapshotProvider` and `dailyLearningPlanProvider`
reuse an upstream sibling provider's already-computed result instead of
re-walking the chain — see `PROVIDER_MAP.md` §2.3 for the full
mechanism.

### 4.2 Group A vs Group B repository split

See §2.1 for the full table. Summary: **Group A** (AppDatabase,
read-only) repositories are `QuranRepositoryImpl` and
`LexiconRepositoryImpl`. **Group B** (UserDatabase, read-write)
repositories are `UserContentRepositoryImpl`, `StudySessionRepositoryImpl`,
`KhatmCycleRepositoryImpl`, `BookmarkCollectionRepositoryImpl`,
`SchedulerRepositoryImpl`, `QuizRepositoryImpl`, `FlashcardRepositoryImpl`.
No repository class implements both; the `quran` feature directory
hosts one of each, kept as two independent classes.

## 5. Design principles

The following principles recur across the codebase's own doc comments
— each is cited at its clearest statement, though most appear more
than once:

1. **Domain layer stays Riverpod/Flutter-independent ("Domain thuần
   Dart").** Stated verbatim across nearly every domain repository
   interface. The stated payoff is that these repositories can be
   called "directly from any context (today's UI, a future AI Tutor)"
   without going through a Provider.
2. **UI never accesses repositories directly — only the feature's own
   narrow provider set.** `tutor_home_screen.dart:21-29`: "Do not
   access AnalyticsRepository directly from UI. Only consume
   AITutorRepository providers." Repeated for `learning_journey_screen.dart`
   and `smart_learning_screen.dart`.
3. **Each layer of the 5-tier chain composes exactly the tier directly
   below it.** See §4.1.
4. **No duplicated statistics — everything derived, nothing
   re-persisted.** Analytics owns no table of its own; the same
   "derived, not persisted" language covers `getLearningGoals()`/
   `getAchievements()`.
5. **Reuse existing widgets/logic before inventing new ones.** The
   reliability layer's own justification ("viết 1 lần, dùng lại ở mọi
   *_repository_impl.dart"); `EmptyStateBanner`, `LoadingState`,
   `StatCard`, `SearchErrorState` were each extracted specifically to
   avoid a second copy. New user-facing strings go into all three
   `lib/l10n/app_{vi,en,ar}.arb` files, never hardcoded (`CLAUDE.md`).
6. **Repository-boundary error handling changes no behavior — "only
   diagnostics improve."** The original error and stack trace are
   always rethrown unchanged after logging.
7. **User database migrations are additive-only; user data is never
   dropped.** Every `onUpgrade` step only adds tables/columns, one
   version at a time, each with its own migration test.
8. **Soft-delete + idempotent toggle/upsert for user-owned data, with
   integrity enforced at the repository layer** (no DB-level FK
   cascades exist in the UserDatabase schema) — built on the
   `SyncColumns` mixin's `deleted_at`/`is_dirty`.
9. **Two independently-owned repositories are bridged only at the
   Provider layer, never through a direct repository→repository
   dependency, when they represent genuinely separate concerns.**
   `FlashcardRepository` does NOT depend on `SchedulerRepository` — the
   bridge is always at the Provider layer (`flashcardSchedulerSyncProvider`).
   The same precedent is cited for `SchedulerRepository`/
   `UserContentRepository`.

See `MODULE_CATALOG.md` for the per-feature breakdown, `PROVIDER_MAP.md`
for the full Riverpod dependency graph, and `DATA_FLOW.md` for
end-to-end traces through this architecture.
