# Project Audit Report — Sprint S1 (Project Stabilization)

Full-project, read-only audit of all merged work: **P1, P2, P3, P4, F1,
F2, F3, F4, F5, F6, F7, F8** — all twelve groups confirmed merged into
`origin/main` (tip `bb9eea0`, PR #2–#18) before this audit began.
Performed on a dedicated read-only branch (`sprint-s1-audit`, cut from
`origin/main`); **no code was modified**, per this sprint's explicit
scope (no new features, no UX changes, no refactors except to fix a
real bug — and no real bug found here met the bar of "fixable without
touching UX or requiring a design decision," so nothing was changed;
see `TECHNICAL_DEBT.md` for the one item that came closest).

Methodology: six parallel research passes across the codebase (236
`lib/` files, 104 `test/` files, 18 feature directories), each required
to cite concrete `file:line` evidence for every claim rather than
impressions. The two highest-impact claims (an entire unreachable
repository, and a missing error-handling path) were independently
re-verified directly rather than taken on trust. Findings below are
organized by the 20 requested checklist items.

---

## 1. Architecture consistency

The documented 5-tier composition chain — **Analytics → AI Tutor →
Learning Journey → Smart Learning → Read Model**, "each layer composes
exactly the one below it" — is implemented cleanly at the call level:

```
AnalyticsRepositoryImpl        -> SchedulerRepository, FlashcardRepository,
                                   LexiconRepository, StudySessionRepository
AITutorRepositoryImpl          -> AnalyticsRepository (only)
LearningJourneyRepositoryImpl  -> AITutorRepository (only)
SmartLearningRepositoryImpl    -> LearningJourneyRepository (only)
LearningSnapshotRepositoryImpl -> SmartLearningRepository (only)
```

No repository skips a layer, reaches past its declared dependency, or
forms a cycle. The dual-database split (`AppDatabase` for static
content, `UserDatabase` for user data) is respected everywhere — no
repository touches both.

**Two real inconsistencies found:**

- **Type-level layer-skipping** (not a call-level violation):
  `smart_learning/domain/session_strategy_rules.dart:1` imports an
  `ai_tutor` entity directly, skipping `learning_journey`; and
  `read_model/domain/entities/learning_snapshot.dart:1-4` imports
  entities from both `ai_tutor` and `learning_journey` directly,
  skipping `smart_learning`. Both are for DTO/type flattening only —
  the actual repository *calls* still go through the declared single
  dependency — but it means the "one layer only" rule is honored at
  the call level while quietly not honored at the import level.

- **Reliability layer (Logger + `withFailureLogging`) adoption is
  split, not universal**: 9 of 14 repositories use it (every
  database-touching repository). The 5 pure composition-chain
  repositories (Analytics, AI Tutor, Learning Journey, Smart Learning,
  Learning Snapshot) have **no** `Logger` field and never call
  `withFailureLogging` — arguably defensible (they do no I/O of their
  own; the leaf repos they call already log), but it means an exception
  thrown inside one of their pure `compute*` functions propagates
  completely unlogged.

**Corroborating finding**: `crashReporterProvider`
(`lib/core/logging/logging_providers.dart:25`) — the other half of the
reliability layer alongside `Logger` — is fully scaffolded (interface,
no-op implementation, DI wiring) but is **never called by
`withFailureLogging`** and **never consumed anywhere in `lib/`**. This
was independently found by two separate research passes (architecture
and dead-code), which is a good confidence signal. `docs/knowledge/
reliability_architecture.md` confirms this was intentional at the time
(Phase 1 built the infra unwired; Phase 2 wired only `Logger`) — so
it's known, tracked debt, not a surprise.

## 2. Dead code

Five files are orphaned — declared but imported by nothing in `lib/`
(verified via `grep -rl "import .*<basename>"` across the whole tree,
excluding each file's own declaration):

| File | Why it's dead |
|---|---|
| `lib/core/env/app_env.dart` | Forward scaffolding for a future step (Supabase env vars), self-documented as "Bước 10-11 sẽ thêm" |
| `lib/features/read_model/domain/entities/snapshot_section.dart` | `SnapshotSection` enum, self-documented as unused: "CHƯA có nơi nào dùng enum này" |
| `lib/features/read_model/data/learning_snapshot_providers.dart` | Entire Read Model provider layer — see §4 |
| `lib/shared/utils/simple_markdown.dart` | A working, unit-tested markdown parser (`parseSimpleMarkdown`) that no widget actually calls — `TutorSuggestionCard`/`TutorInsightCard` render plain `Text` instead |
| `lib/core/cache/io_cache_manager.dart` + its `cache_manager.dart` interface | A complete offline-audio-cache subsystem, never constructed anywhere — matches an existing, explicit `TODO.md:13` item ("Nối IoCacheManager vào AudioController") |

**Not dead** (checked and ruled out): the `connection_{native,unsupported,web}.dart` platform-switch files looked orphaned under a plain import grep but are reached via conditional `export ... if (dart.library.io)` — standard, live Drift/Flutter web-platform code. No leftover/superseded screen widgets from earlier sprints were found — each of the 18 features has exactly one reachable primary screen. No unused private methods. No commented-out code blocks beyond one documented 2-line placeholder.

## 3 & 5. Unused providers / unused Riverpod providers

Four providers have zero consumers anywhere in `lib/` outside their own declaration file:

| Provider | File | Note |
|---|---|---|
| `statsRefreshProvider` | `stats/data/stats_store.dart:150` | Fully dead — zero hits even in `test/`. Declared with clear intent (refresh counter for the stats screen) that was never wired up. |
| `crashReporterProvider` | `core/logging/logging_providers.dart:25` | See §1 — corroborated by two independent passes. |
| `learningSnapshotRepositoryProvider` | `read_model/data/learning_snapshot_providers.dart:18` | See §4. |
| `learningSnapshotProvider` | `read_model/data/learning_snapshot_providers.dart:38` | See §4 — even its own sibling provider in the same file bypasses the repository it wraps. |

All other 76 Riverpod providers in the codebase have a confirmed real consumer.

## 4. Unused repositories

**`LearningSnapshotRepository` (F7, Read Model) is fully implemented, fully tested, and fully unreachable.** Independently re-verified:

```
grep -rln "read_model" lib --include="*.dart" | grep -v "^lib/features/read_model/"
  -> only lib/features/smart_learning/domain/entities/smart_learning_session.dart,
     and that's a one-directional doc-comment mention, not an import
grep -in "read_model\|LearningSnapshot" lib/app/router.dart
  -> zero matches
```

No screen, controller, or route imports anything from
`lib/features/read_model/`. This was already known and stated plainly
in F7's own PR description at merge time ("No UI consumes
`LearningSnapshotRepository` yet — Read Model exists purely as a
data-aggregation layer for now") — the audit confirms that statement is
still accurate today, not a new discovery. All 13 other repositories
are confirmed reachable from a real UI path.

## 6. Unreachable routes

All 23 declared routes in `lib/app/router.dart` are reachable from
application code — verified by grepping every `AppRoutes.*` constant
for a real `context.push`/`context.go` call site outside the router
file. No dead route, no broken navigation to a non-existent path.

One cosmetic note: `AppRoutes.home`/`.quran`/`.stats`/`.profile` (4 of
the 5 tab routes) are never referenced *by name* anywhere outside
`router.dart` — the bottom tab bar navigates by numeric index
(`navigationShell.goBranch(index)`), not by these string constants.
They are still live and reachable; only the identifiers themselves are
unused. Not a functional issue.

## 7. Duplicate widgets

- `_MetricCard` in `stats/presentation/stats_screen.dart:159-206` is a
  byte-for-byte reimplementation of `lib/shared/widgets/stat_card.dart`
  — unlike `TutorInsightCard`, which was migrated to delegate to
  `StatCard` directly, this one never was.
- `_EmptyHint` in `stats_screen.dart:122-157` is a verbatim copy of
  `EmptyStateBanner` — already self-documented as a known, unmigrated
  gap in `empty_state_banner.dart`'s own doc comment.
- A **second, undocumented** empty-state shape (full-page
  `Center > Icon > Title > Subtitle`, sometimes with a CTA button) is
  independently reimplemented with no shared widget at all in at least
  5 places: `SearchEmptyState` (`search/presentation/search_screen.dart:311`),
  `_EmptyState` (`quran/presentation/surah_list_screen.dart:408`),
  `_EmptyState` (`library/presentation/widgets/library_tab_view.dart:68`),
  `_NoFlashcardsEmptyState` (`flashcards/presentation/flashcard_browse_screen.dart:325`),
  `_QuizEmpty` (`quiz/presentation/quiz_session_screen.dart:57`). The
  first two are structurally identical apart from icon/text.
- `_JourneyEntryCard` (`ai_tutor/presentation/tutor_home_screen.dart:130-181`)
  and `_SmartLearningEntryCard` (`learning_journey/presentation/learning_journey_screen.dart:153-204`)
  are near-identical cross-feature navigation cards, explicitly
  copy-pasted per their own comment ("same pattern as ...; not
  inventing a new navigation style") rather than extracted into a
  shared widget. No `CrossFeatureEntryCard` exists anywhere despite
  this being exactly the recurring pattern it would serve.

## 8. Duplicate business logic

The domain/calculator layer is largely clean (streak calculation lives
in exactly one place; most `*_calculator.dart`/`*_generator.dart` files
carry explicit "pure function, no re-deriving" doc comments). One real
finding: the four `QuestionGenerator` implementations under
`lib/features/quiz/domain/generators/` (`ayah_continuation_generator.dart`,
`verse_recognition_generator.dart`, `surah_identification_generator.dart`,
`translation_matching_generator.dart`) each reimplement the same
"shuffle candidate pool → take 3 decoys → assemble options → shuffle →
compute correct index via `indexOf`" tail (~6-10 lines each, ~25-30%
of each file), despite all four implementing the same
`QuestionGenerator` interface. A shared
`buildShuffledOptions<T>(correct, decoys, random, toLabel)` helper
would remove the repetition.

## 9. Duplicate database queries

- The soft-delete filter `t.deletedAt.isNull()` is repeated verbatim
  **20+ times across 9 repository files**
  (`flashcard_repository_impl.dart:147,217`,
  `scheduler_repository_impl.dart:136,147`,
  `khatm_cycle_repository_impl.dart:68,77`,
  `quiz_repository_impl.dart:73`,
  `study_session_repository_impl.dart:78,87,97,111`,
  `bookmark_collection_repository_impl.dart:58,158,168,179,200,219`,
  `user_content_repository_impl.dart:102,115,128,143,169`) even though
  all 12 user tables already share a `SyncColumns` mixin
  (`user_tables.dart:10-17`). `user_content_repository_impl.dart:45`
  even defines a private one-off `alive(SyncColumns t)` helper that the
  other 8 files don't reuse.
- A "revive-or-insert" upsert recipe (look up existing row ignoring
  `deletedAt` → insert if absent, else flip `deletedAt` to
  preserve the row's UUID for sync) is independently reimplemented at
  least 5 times: `user_content_repository_impl.dart`'s
  `toggleBookmark`/`toggleFavorite`/`toggleHighlight` (183-260-ish),
  `flashcard_repository_impl.dart:addFlashcard` (71-90), and
  `scheduler_repository_impl.dart:syncItemsForType` (67-99). Comments
  at two of these sites explicitly say they're copying the pattern from
  Bookmarks/Favorites — an acknowledged, un-extracted duplicate.

## 10. L10n consistency

**Clean.** All three `.arb` files (`app_vi.arb`, `app_en.arb`,
`app_ar.arb`) have **identical key sets** — 319 regular keys, 32
`@`-metadata entries, verified via a full JSON keyset diff, not a
sample. ICU placeholder structures match across all three locales for
every key. No hardcoded user-facing strings were found in F1–F8
presentation code (the only literal strings found anywhere are a
`kDebugMode`-gated dev-preview panel in `search_screen.dart`, tree-shaken
from release builds, and a non-natural-language `"${speed}x"` label in
the audio bar — neither is a real gap). Generated `app_localizations*.dart`
files are in sync with the ARB source (spot-checked the 3 most recently
added keys across all 4 generated files).

## 11. Accessibility

The Sprint 20 accessibility conventions (merged `Semantics` labels on
cards, no color-only state indicators, shared `LoadingState`/
`SearchErrorState` for async states, `SectionHeader` with
`Semantics(header: true)` for section titles) hold consistently across
`ai_tutor`, `analytics`, `flashcards`, `learning_journey`, and
`smart_learning`.

**`learning_session` (F8, the newest feature) is a real regression**,
independently re-verified:

- `learning_summary_screen.dart`'s stat/activity rows have no
  `Semantics` wrapping at all, unlike every sibling card widget in the
  other F-features.
- No `SectionHeader` usage anywhere in the feature.
- **Most importantly**: `LearningSessionController` is a plain
  `Notifier<LearningSessionState>` (confirmed:
  `learning_session_controller.dart:23`), **not** an `AsyncNotifier`,
  and contains **zero `try`/`catch` blocks anywhere in the file**
  (confirmed directly by grep). Its `start()`/`completeCurrentActivity()`
  methods `await` repository calls that can throw
  (`ref.read(dueReviewCardsProvider.future)`, etc.) with nothing to
  catch the failure. `_LearningSessionLoading` renders a bare
  `CircularProgressIndicator` with no `Semantics`/`liveRegion` either.
  A failure here fails completely silently — no error text, no retry,
  no accessible announcement — the same class of bug as a previously-
  fixed Home-screen issue, but reintroduced in the newest feature.

This is the single most concrete, actionable finding in this audit —
see `TECHNICAL_DEBT.md` for why it wasn't fixed in this pass and what
fixing it correctly would require.

## 12. Performance issues

No misuse of `ref.watch` vs `ref.read` was found (checked explicitly;
one call site even uses `.select()` with a comment explaining why).
Two minor, low-severity findings:

- `flashcards/presentation/flashcard_browse_screen.dart:76-84` calls
  `filterFlashcards(...)` directly inside `build()` on every keystroke
  (no debounce, no memoized provider) — the textbook version of the
  anti-pattern this checklist item asks about, though impact is small
  given typical personal flashcard-collection sizes.
- `flashcards/presentation/smart_deck_screen.dart:141-157` uses a plain
  `ListView` instead of `.builder`, bounded by a small, fixed set of
  Arabic verb forms — low severity.

The documented provider-reuse-to-avoid-recomputation pattern (used by
`dailyLearningPlanProvider` and `learningSnapshotProvider` to skip
re-invoking their own repository chain) was followed correctly through
F5–F8 where it was safe to do so; the one place it wasn't followed
(`learningJourneyProvider`) has an explicit, documented correctness
reason (avoiding stale cached data on manual refresh). The underlying
"no caching across repository-chain calls" design (each Read Model call
can fan out to ~12 Analytics calls) is real, self-documented,
pre-existing perf debt — not a new F6–F8 regression.

## 13. Startup performance

`main.dart` has exactly one awaited I/O call before `runApp`
(`SharedPreferences.getInstance()`, justified inline to avoid a
theme/locale flash). Both databases open lazily on first provider
watch, and the content-database asset copy uses the documented atomic
temp-file-then-rename pattern. Nothing in F1–F8 touches `main.dart`,
`app.dart`, or the DB-open path — the startup-critical path is
unchanged from the last recorded baseline (`PERFORMANCE.md`). One minor
note: `JustAudioAyahPlayer()` is constructed eagerly in `main.dart`
before `runApp` rather than lazily — low risk, `just_audio`'s
constructor is non-blocking, but it's the one non-lazy thing on the
startup path.

## 14. Memory leaks

**Clean — none found.** Every `TextEditingController`,
`StreamController`, `StreamSubscription`, and `PageController` in the
codebase (11 instances checked, including the trickier custom
`_combineLatest5` stream-merge helper and the Riverpod `Notifier`-based
`AudioController`'s subscription list) has a confirmed, correct
disposal path in a `dispose()` method or `ref.onDispose()` callback. No
`Timer`, `AnimationController`, or `FocusNode` exists anywhere in the
codebase.

## 15. Navigation consistency

**Clean.** Push style (`context.push`) is used consistently across
~30 call sites, with exactly two deliberate, well-commented exceptions
(`pushReplacement` for surah paging, one `context.go` for exiting a
session with no route to pop back into). Every pushed screen checked
has a working default back button. No duplicate route paths. ID-based
navigation consistently uses path params; non-ID payloads consistently
use `extra` — a principled, not arbitrary, split.

## 16. Repository dependency graph

Full adjacency list documented (see §1 for the top of the chain).
Deepest chain: `LearningSnapshotRepositoryImpl → SmartLearningRepositoryImpl
→ LearningJourneyRepositoryImpl → AITutorRepositoryImpl →
AnalyticsRepositoryImpl → {SchedulerRepository | FlashcardRepository |
LexiconRepository | StudySessionRepository}` — six classes deep from
Read Model to a database-touching leaf. No repository has more than one
direct repository dependency except `AnalyticsRepositoryImpl` (4,
the designated fan-out point). No cycles among the 14 repositories.

## 17. Provider dependency graph

Provider composition mirrors the repository graph 1:1. The only
providers with large fan-in are infrastructure singletons
(`loggerProvider`: 9 dependents; `userDatabaseProvider`: 7) — expected
for DI, not a design smell. No unexpected god-provider was found among
business-logic providers. Two providers
(`dailyLearningPlanProvider`, `learningSnapshotProvider`) deliberately
bypass their own repository layer to reuse an upstream cached
provider's result — a documented, intentional optimization, but it
does mean there are now two live code paths to the same output (one
through the repository, one bypassing it) — worth knowing when
reasoning about "which provider is the source of truth."

## 18. Feature coupling

No circular feature dependency exists (checked systematically in both
directions for every pair). `quran`, `lexicon`, and `profile` are clean
leaves with zero outbound cross-feature imports. The two tightest
couplings (`flashcards ↔ learning`, `flashcards ↔ lexicon`, 5-6+ import
sites each) are expected and by design.

**Two real findings:**

- Four unrelated features (`ai_tutor`, `learning_journey`,
  `smart_learning`, `analytics`) import
  `search/presentation/widgets/search_error_state.dart` purely for a
  generic, search-independent empty/error widget — confirmed the
  widget itself has no dependency on search logic. This should live in
  `lib/shared/widgets/` (which these same 4 screens already import
  from for `EmptyStateBanner`/`LoadingState`), not in the `search`
  feature.
- `stats/data/stats_store.dart:4` (a **data**-layer file) imports
  `quran/presentation/reading/reading_position_store.dart` (a
  **presentation**-layer file) just to read a `SharedPreferences` key
  format — an odd layering inversion, even though the coupling itself
  is shallow.

## 19. Database migration integrity

**Clean.** `UserDatabase` is at `schemaVersion 6`; every version
transition 1→2→3→4→5→6 has an explicit `onUpgrade` step **and** a
dedicated test exercising it (`test/user_content_repository_test.dart`'s
`schema & migration` group seeds a real v1/v2/v3/v4/v5 database and
asserts each upgrade path runs correctly and preserves existing data).
`AppDatabase` has never had a version bump (still v1), so no migration
is needed there yet. Every table/column referenced by a repository impl
exists in its database's schema — confirmed both by direct
cross-reference and by `flutter analyze` compiling cleanly (Drift's
generated accessors make an orphaned reference a compile error, not
just a logic bug).

One pre-existing, already-tracked gap, not newly discovered here: 8
Lexicon tables are declared in the Drift schema but not yet present in
the shipped `quran.sqlite` asset — this is self-documented in
`content_tables.dart:158-166` and already listed in `TODO.md`.

## 20. Test coverage gaps

Roughly **83% (≈100 of 120)** of `domain`/`data` files have at least
one associated test. No stale tests referencing removed code (confirmed
via a clean `flutter analyze test` compile). Gaps found:

- The already-tracked 5 missing F3 (Analytics) test files — confirmed
  still missing from `main` (a complete, gated fix already exists on
  the separate, unmerged `feat/f3-test-completion` branch — not
  re-counted as a new finding here).
- **Novel gaps**: `smart_learning/domain/session_strategy_rules.dart`
  (pure functions, zero test references anywhere — an easy, valuable
  target), `stats/data/daily_goal_store.dart` +
  `daily_goal_providers.dart` (untested, unlike the sibling
  `ReadingPositionStore` which does have a test), and
  `flashcards/data/flashcard_providers.dart` +
  `lexicon/data/lexicon_providers.dart` (the provider *wiring* layer is
  untested even though the underlying repository impls are tested
  directly).

---

## Mechanical gates

| Command | Result |
|---|---|
| `dart format --set-exit-if-changed lib test integration_test` | `Formatted 341 files (0 changed)` |
| `flutter analyze --fatal-infos lib test integration_test` | `No issues found!` |
| `flutter test test` (full suite) | **731/731 pass** |

All three run clean on `sprint-s1-audit` (= `origin/main` at `bb9eea0`,
all of P1–P4/F1–F8 merged), confirming the audit's own baseline is
healthy before any of the findings above are considered.

See `TECHNICAL_DEBT.md` for a prioritized, itemized backlog of every
finding above, `PROJECT_HEALTH_SCORE.md` for a scored summary, and
`ROADMAP_RECOMMENDATION.md` for suggested next-sprint priorities.
