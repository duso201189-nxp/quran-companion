# Testing Guide — Qur'an Companion

Written after PR #19. This guide documents how this codebase is
actually tested, not generic Flutter testing advice. It reflects the
conventions found in the ~104 files under `test/` (plus 5 shared
fixtures in `test/fixtures/` and one real-device end-to-end test in
`integration_test/`) as of this snapshot. Read this before writing a
new test — matching the existing pattern for the layer you're touching
is expected, not optional.

## 1. Test strategy

### 1.1 Layer-to-test-type mapping

The suite is organized by **what layer of the app the code lives in**,
not by feature-first "one giant test file per screen":

| `lib/` layer | Test type | Example |
|---|---|---|
| Pure domain logic (calculators, generators, rule tables, entities' derived properties) | Plain `test()`, no Flutter bindings needed | `test/session_strategy_rules_test.dart`, `test/shuffled_options_test.dart` |
| Repository implementations (`*_repository_impl.dart`) | Plain `test()` against a **real in-memory Drift database** | `test/flashcard_repository_test.dart`, `test/quran_repository_test.dart` |
| Riverpod providers (`*_providers.dart`) | Plain `test()` using `ProviderContainer` + hand-written fake repositories | `test/khatm_cycle_providers_test.dart`, `test/daily_goal_providers_test.dart` |
| Screens / widgets | `testWidgets()` with `ProviderScope` + `MaterialApp.router` | `test/quiz_session_screen_test.dart`, `test/learning_session_screen_test.dart` |
| Pure entities/data classes (`domain/entities/*.dart`) | Generally **not** tested directly — exercised transitively as fixtures inside every other test | — |

A rough split across the suite: **64 of 104 test files never call
`testWidgets()`** (pure Dart unit tests), and **40 do** (widget tests).
That ~60/40 split mirrors the intent: push as much logic as possible
into plain, fast, non-Flutter-bound classes/functions, and reserve
`testWidgets()` for the presentation layer and cross-widget
interaction (taps, snackbars, screen transitions).

### 1.2 Repositories: real in-memory Drift, never mocked

Every repository test constructs an actual `UserDatabase` or
`AppDatabase` backed by `NativeDatabase.memory()` — not a mock, not an
in-memory fake collection. Confirmed pattern, from
`test/flashcard_repository_test.dart`:

```dart
void main() {
  late UserDatabase db;
  late FlashcardRepositoryImpl repo;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    repo = FlashcardRepositoryImpl(
      db,
      const ConsoleLogger(),
      newId: () => 'card-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());
  ...
```

25 of the 104 test files construct `NativeDatabase.memory()` directly
(repository tests, provider-wiring tests, and screen tests that need a
real backing store rather than mocking the database layer away). This
means repository tests exercise real SQL — real Drift-generated
queries, real UNIQUE constraints, real soft-delete semantics — against
SQLite running in memory, which is fast (no disk I/O) and exact (no
behavioral drift between a fake and the real schema).

Two variants worth knowing:

- **`UserDatabase(NativeDatabase.memory())`** — the per-device
  learning/library/flashcard database (SRS cards, bookmarks,
  flashcards, Khatm cycles, study sessions, etc.).
- **`AppDatabase(NativeDatabase.memory())`** — the read-only Qur'an
  content database (lexicon, transliteration) when a test needs its
  schema without touching the real 21 MB shipped asset.

A third, rarer tier opens the **actual shipped SQLite asset** rather
than an in-memory copy — `test/content_database_smoke_test.dart`:

```dart
// Smoke test dữ liệu THẬT: mở assets/database/quran.sqlite (file do
// tool/build_quran_db.py sinh ra) qua đúng lớp AppDatabase + repository
// của app, đảm bảo danh sách Surah và nội dung đọc hoạt động.
...
db = AppDatabase(NativeDatabase(assetFile));
```

This is a *data* smoke test (114 Surahs present, `data_version`
matches the app constant, etc.), not a logic test — it's the only
place the real content dataset itself gets asserted against, and it's
designed to skip cleanly if the asset hasn't been built yet rather
than fail the whole suite.

### 1.3 Providers: `ProviderContainer` + overrides, not `ProviderScope` widgets

Provider-layer tests (anything testing a Riverpod `Provider`/
`StreamProvider`/`FutureProvider` in isolation, without rendering
widgets) construct a bare `ProviderContainer` and override the
repository dependency with a hand-written fake — confirmed in
`test/khatm_cycle_providers_test.dart`:

```dart
class _FakeKhatmCycleRepository implements KhatmCycleRepository {
  KhatmCycle? _current;
  void emitActive(KhatmCycle? cycle) => _current = cycle;

  @override
  Stream<KhatmCycle?> watchActiveCycle() => Stream.value(_current);
  // ...other members throw UnimplementedError() — deliberately, so an
  // accidental call to an untested method fails loudly instead of
  // silently returning a wrong default.
}

setUp(() {
  fakeRepo = _FakeKhatmCycleRepository();
  container = ProviderContainer(
    overrides: [khatmCycleRepositoryProvider.overrideWithValue(fakeRepo)],
  );
});
tearDown(() => container.dispose());
```

`test/daily_goal_providers_test.dart` shows the more advanced variant
— overriding a `FutureProvider` directly with `overrideWith((ref) =>
summary())` to control exactly when the underlying future resolves
(including a `Completer` that never completes, to assert the loading
state), plus the idiomatic way to force an `.autoDispose` async
provider chain to stay alive across an `await`:

```dart
Future<DailyGoalProgress?> _resolvedProgress(ProviderContainer c) async {
  final sub = c.listen(dailyGoalProgressProvider, (_, __) {});
  await c.read(todayStudySummaryProvider.future);
  final progress = c.read(dailyGoalProgressProvider);
  sub.close();
  return progress;
}
```

### 1.4 No mocking framework — hand-written fakes only

`pubspec.yaml`'s `dev_dependencies` are exactly: `build_runner`,
`drift_dev`, `flutter_lints`, `flutter_test`, `integration_test`.
**Neither `mockito` nor `mocktail` is a dependency**, and a repo-wide
search confirms zero references to either anywhere under `test/` or
`pubspec.lock`. Every test double in this codebase is a plain Dart
class that `implements` the real domain interface, named `Fake...` or
`_Fake...` (28 such classes across the suite) or, for cross-cutting
infra like logging, `_Recording...`. There is no `@GenerateMocks`
codegen step and no `when(...).thenReturn(...)` DSL anywhere —
behavior is expressed as ordinary Dart control flow inside the fake
class.

### 1.5 Deterministic seeded `Random` for anything involving randomness

Quiz question generation is the one place true randomness matters
(which distractor gets shown, in what order). Production generator
signatures take `Random` as an explicit parameter rather than
constructing their own internally:

```dart
// lib/features/quiz/domain/question_generator.dart
QuizQuestion? generate(QuizContentPool pool, Random random);

// lib/features/quiz/data/quiz_providers.dart — real runtime call site:
final questions = generator.generateQuiz(pool, Random(), questionCount);
```

Tests exploit exactly this seam by passing a seeded `Random(n)`
instead, from `test/shuffled_options_test.dart`:

```dart
test('cùng seed -> cùng kết quả (tất định, không phụ thuộc đồng hồ hệ '
    'thống)', () {
  final a = buildShuffledOptions('c', ['x', 'y', 'z'], Random(7));
  final b = buildShuffledOptions('c', ['x', 'y', 'z'], Random(7));

  expect(a.options, b.options);
  expect(a.correctOptionIndex, b.correctOptionIndex);
});
```

`test/quiz_question_generator_test.dart` does the same for all four
concrete generators (`SurahIdentificationGenerator`,
`AyahContinuationGenerator`, `TranslationMatchingGenerator`,
`VerseRecognitionGenerator`), each called with a specific `Random(seed)`
so shuffling is reproducible run-to-run and CI-stable. This pattern is
scoped to quiz generation specifically — other generators in the app
(e.g. Smart Learning's session generator) don't involve randomness and
correspondingly don't use this pattern.

### 1.6 A distinct, non-obvious test category: repository/architecture "boundary" gates

Three files — `test/repository_boundary_test.dart`,
`test/repository_boundary_completeness_test.dart`, and
`test/repository_boundary_logging_test.dart` — are not
application-logic tests at all. The first two use `git ls-files` to
enforce that no restricted-license content or oversized file gets
committed to this public repo (a licensing safety net that can't be
bypassed the way a `.gitignore` entry or pre-commit hook can be); the
third proves the `withFailureLogging()`/`withFailureLoggingStream()`
wrapper used by every repository logs exactly once on failure and
nothing on success, via a hand-rolled `_RecordingLogger implements
Logger`. A new contributor scanning `test/` should expect these three
and not mistake them for misplaced or broken feature tests — they're
CI-gate fitness functions, deliberately kept in the same `flutter test`
run so no separate CI wiring is needed.

---

## 2. Coverage summary

### 2.1 Methodology (read this before the numbers)

There is no reliable, up-to-date `lcov` report to source a single
coverage percentage from — see §2.4. Instead, coverage below is
estimated by **correlating file names**: for every non-generated file
under `lib/`, checking whether a `test/<same-basename>_test.dart`
exists (and, for repository implementations specifically, also
checking with the `_impl` suffix stripped, since that's this
codebase's actual naming convention — see §3). This is a **lower
bound**, not an exact measure: several test files exercise multiple
`lib/` files at once (e.g. all four quiz generators are tested inside
one `test/quiz_question_generator_test.dart`), so the true number of
`lib/` files touched by *some* test is higher than what direct
name-matching finds. Where this undercounting could be confirmed by
reading imports, it's called out explicitly below.

`lib/` totals: **237 files, 235 excluding the two Drift-generated
`*.g.dart` files** (`app_database.g.dart`, `user_database.g.dart`),
split across 18 feature directories plus `core/`, `shared/`, `app/`,
`l10n/`.

### 2.2 By category

| Category | File count | Direct-name-match hits | Notes |
|---|--:|--:|---|
| `domain/entities/*.dart` (pure data classes) | 44 | 0 | Expected — see §2.3 |
| Domain logic, excl. entities (calculators, generators, rule tables, scheduling algorithm, planners) | 43 | 22 direct | Real number is higher: repository *interfaces* never get their own test file by design — exercised only through their `_impl`. Several concrete files are tested inside a differently-named file, confirmed by reading imports: the 4 quiz generators + `question_generator.dart` all live inside `test/quiz_question_generator_test.dart`; `scheduling_algorithm.dart` is exercised inside `test/sm2_scheduling_algorithm_test.dart`; `learning_session_state.dart`/`sequential_learning_planner.dart` are exercised inside `test/learning_session_controller_test.dart`. |
| Data layer (`data/*.dart`: repository impls + provider-wiring) | 34 | 17 direct → **25/34** once the `_impl`-suffix convention is accounted for | The remaining 9 without any test are almost entirely bare `*_providers.dart` DI-wiring files: `analytics_providers.dart`, `flashcard_providers.dart`, `learning_planner_providers.dart`, `lexicon_providers.dart`, `quran_providers.dart`, `user_content_providers.dart`, plus `fts_query.dart`, `transliteration_repository.dart`, `stats_store.dart`. Provider-wiring is the thinnest-covered part of the data layer — `flashcardRepositoryProvider`/`lexiconRepositoryProvider` specifically were closed by `test/repository_provider_wiring_test.dart` (Sprint S2, D9), but the six others listed above still have no dedicated wiring test as of this snapshot. |
| Presentation (`presentation/*.dart`: screens + widgets + presentation-layer controllers) | 63 | 34 direct (54%) | Misses are mostly small leaf widgets/dialogs/controllers that likely get exercised *indirectly* inside their parent screen's widget test rather than in a dedicated file of their own — this wasn't verified file-by-file, so treat 54% as a conservative floor, not a ceiling. |
| `core/` (excl. `.g.dart`) | 32 | 7 direct | Most "misses" are Drift table/schema definitions and platform-conditional connection factories that aren't unit-tested directly by design — exercised transitively every time any of the 25 files that call `NativeDatabase.memory()` runs. |
| `shared/`, `app/`, `l10n/` | 18 | 3 direct | `shared/widgets/{section_header,stat_card,empty_state_banner}.dart` are covered collectively by `test/shared_widgets_a11y_test.dart` (not a name match, since it tests three widgets at once). |

### 2.3 Why entities have zero direct tests, and why that's expected

None of the 44 files under any `domain/entities/` directory has a
same-named test file. This is consistent, not a gap: these are `const`
constructors / simple data classes (occasionally with a small derived
getter, like `KhatmCycle.progressPercent`), and they're exercised
*constantly* as fixture data inside essentially every repository,
provider, and widget test in the suite. A derived property with real
logic worth asserting on tends to get its assertion folded into the
test of whatever consumes it, rather than spawning a dedicated
`<entity>_test.dart`.

### 2.4 A stale coverage artifact exists — don't cite its number

`coverage/lcov.info` exists in the repo, but it is **not** a report of
the current 767-test suite. It instruments only **57 files**, all from
the `quran`/`home`/`profile`/`stats`/`study`/app-shell surface — there
is not a single line from `flashcards`, `quiz`, `analytics`, `khatm`,
`ai_tutor`, `smart_learning`, `learning`, `learning_journey`,
`lexicon`, `library`, or `search`, even though all of those features
have substantial dedicated test files today. Its aggregate line
coverage (3026/6211 ≈ 48.7%) is real for the 57 files it does cover,
but citing it as "the app's coverage" would be misleading — it
predates most of the current feature set. **Before quoting a coverage
percentage in any future document, regenerate it**: `flutter test
--coverage` writes a fresh `coverage/lcov.info` covering every file the
current suite actually imports.

### 2.5 Known gaps — cross-checked against the debt registers, not copied blindly

[TECHNICAL_DEBT.md](../reports/release-recovery/TECHNICAL_DEBT.md)
(original, now archived) and
[UPDATED_TECHNICAL_DEBT.md](../release/UPDATED_TECHNICAL_DEBT.md)
(supersedes its priority/status columns, same item IDs, still the live
register) are both worth reading before assuming a gap is
undiscovered. Cross-checking their claims against the actual `test/`
contents in this snapshot:

- **D9 ("Test coverage gaps beyond the known F3 gap"), marked FIXED in
  S2 — verified true.** `test/session_strategy_rules_test.dart`,
  `test/daily_goal_store_test.dart`, `test/daily_goal_providers_test.dart`,
  and `test/repository_provider_wiring_test.dart` (covering
  `flashcardRepositoryProvider`/`lexiconRepositoryProvider`
  specifically) all exist and match what the debt doc claims was
  added.

- **The "F3 gap" (5 missing Analytics test files) — claimed fixed, but
  NOT actually present in this checkout.**
  [UPDATED_TECHNICAL_DEBT.md](../release/UPDATED_TECHNICAL_DEBT.md)
  and the standalone
  [F3_TEST_COMPLETION_REPORT.md](../reports/release-recovery/F3_TEST_COMPLETION_REPORT.md)
  both describe adding `test/achievement_calculator_test.dart`,
  `test/achievement_card_test.dart`, `test/goal_card_test.dart`,
  `test/learning_goal_calculator_test.dart`, and
  `test/learning_history_calculator_test.dart` on branch
  `feat/f3-test-completion` (commit `55b8de3`), bringing the suite to
  720/720. **None of these five files exist in `test/` in this
  snapshot** — independently re-verified: that branch exists only
  locally and was never pushed. So this is a real, currently-true gap,
  not a stale note to ignore — `achievement_calculator.dart`,
  `learning_goal_calculator.dart`, `learning_history_calculator.dart`,
  `achievement_card.dart`, and `goal_card.dart` (all under
  `lib/features/analytics/`) have **no test coverage today** despite
  documentation claiming otherwise. Anyone picking up Analytics work
  should treat this as open, re-port those five files from that branch
  (or rewrite them), and verify before trusting the "already covered"
  claim in either debt doc.

- **D3 (Read Model / `LearningSnapshotRepository` "fully unreachable"
  from the UI) — still true, but note it's a *product* gap, not a
  *test* gap.** `test/learning_snapshot_repository_impl_test.dart`,
  `test/learning_snapshot_providers_test.dart`, and
  `test/learning_snapshot_generator_test.dart` all exist — the Read
  Model layer is well unit-tested even though nothing in the UI
  currently calls it. Coverage and "shipped/reachable feature" are
  different axes; don't conflate a well-tested-but-unwired subsystem
  with an untested one.

- **D5 (dead files, never wired into production) — has a small
  nuance.** Of the five files listed as dead
  (`core/env/app_env.dart`, `read_model/domain/entities/snapshot_section.dart`,
  `shared/utils/simple_markdown.dart`, `core/cache/io_cache_manager.dart`,
  `core/cache/cache_manager.dart`), two — `simple_markdown.dart` and
  `cache_manager.dart` — still have their own dedicated test files
  (`test/simple_markdown_test.dart`, `test/cache_manager_test.dart`).
  "Dead" here means "not wired into the app's DI graph," not
  "untested."

### 2.6 Bottom line

There is no honest single "X% covered" figure to report — the
codebase doesn't have a current lcov run, and file-name correlation is
a floor, not a precise measurement. What can be said with confidence:
**domain logic and repository/data-access code are tested thoroughly
and consistently** (highest hit rate once naming conventions are
accounted for), **presentation code is tested at the screen level but
not exhaustively at the small-widget level**, **pure entities are
intentionally untested directly**, and **there is one confirmed, live
gap** — the five Analytics files described in §2.5 — that
documentation claims is fixed but the actual checkout shows is not.

---

## 3. Testing conventions

### 3.1 File naming: `<name>_test.dart`, no exceptions

All 104 test files at the top level of `test/` follow
`<name>_test.dart`. Shared, non-test helper code used by multiple test
files lives in `test/fixtures/` and is named descriptively without the
`_test` suffix (`app_harness.dart`, `content_fixtures.dart`,
`fake_audio_player.dart`, `fake_bookmark_collection_repository.dart`,
`search_test_harness.dart`) — `flutter test` only picks up files
ending in `_test.dart`, so this split is functional, not just
stylistic.

Two related naming conventions to know when hunting for a test:

- **Repository test files drop the `_impl` suffix.**
  `FlashcardRepositoryImpl` → `test/flashcard_repository_test.dart`
  (not `flashcard_repository_impl_test.dart`). Same for
  `khatm_cycle_repository_test.dart`, `scheduler_repository_test.dart`,
  `quiz_repository_test.dart`, `bookmark_collection_repository_test.dart`,
  `study_session_repository_test.dart`, `user_content_repository_test.dart`,
  `quran_repository_test.dart`. If you're looking for a repository's
  test and `<name>_impl_test.dart` doesn't exist, try `<name>_test.dart`.
- **One test file can legitimately cover several `lib/` files** when
  they're small and tightly related — e.g. all four quiz generators in
  `test/quiz_question_generator_test.dart`, or several
  `learning_session/domain/*.dart` files inside
  `test/learning_session_controller_test.dart`.

There is also exactly one real end-to-end test outside `test/`
entirely: `integration_test/app_e2e_test.dart`, which drives the
actual compiled app (`import 'package:quran_companion/main.dart' as
app;`) on a real device/desktop target. It is not part of the normal
`flutter test` run and not counted in the 767-test figure.

### 3.2 The "seed current value, then forward changes" fake-stream pattern

This is the codebase's standard shape for a fake repository whose
`watch...()` methods back a widget that must react live to a user
action (tap → repository mutation → open screen updates itself, no
remount) — as opposed to a provider-only test where setting state once
before the first subscribe is enough (see the simpler `Stream.value()`
variant in `test/khatm_cycle_providers_test.dart`, §1.3).

The shape, confirmed identically in
`test/fixtures/fake_bookmark_collection_repository.dart`,
`test/learning_session_screen_test.dart`, and
`test/review_session_screen_test.dart`:

```dart
class _FakeSchedulerRepository implements SchedulerRepository {
  final _controller = StreamController<List<SrsCard>>.broadcast();
  List<SrsCard> _cards = const [];

  void emitCards(List<SrsCard> cards) {
    _cards = cards;
    _controller.add(_cards);
  }

  @override
  Stream<List<SrsCard>> watchAllCards(LearningItemType itemType) async* {
    yield _cards.where((c) => c.itemType == itemType).toList();   // seed current value
    yield* _controller.stream
        .map((cards) => cards.where((c) => c.itemType == itemType).toList()); // then forward changes
  }
```

The doc comment on the `FakeBookmarkCollectionRepository` version
spells out exactly why: it's mimicking Drift's real `.watch()`
semantics ("replay the current value to a new subscriber, then keep
emitting on change") specifically because a plain
`StreamController.broadcast()` alone would silently drop events for
any subscriber that starts listening *after* the emit — exactly what
happens with Riverpod's `.autoDispose` providers that only subscribe
once something reads/watches them.

### 3.3 Database test setup/teardown

Standard shape, repeated verbatim across every repository test:

```dart
late UserDatabase db;   // or AppDatabase, depending on which schema

setUp(() {
  db = UserDatabase(NativeDatabase.memory());
  // ...construct the repository under test against `db` here
});

tearDown(() => db.close());
```

Widget/provider tests that need a database prefer `addTearDown(db.close)`
inline at the point of construction rather than a `tearDown()` block,
since the database is often built per-test-case rather than in a
shared `setUp()`:

```dart
final db = UserDatabase(NativeDatabase.memory());
addTearDown(db.close);
final container = ProviderContainer(
  overrides: [userDatabaseProvider.overrideWithValue(db)],
);
addTearDown(container.dispose);
```

Either way, always close the database — nothing in this suite leaves
an in-memory Drift instance open past its test.

### 3.4 How widget tests wrap their subject

Two shapes, both requiring `AppLocalizations.localizationsDelegates` +
`AppLocalizations.supportedLocales` wired through, since screens read
localized strings and the widget test would otherwise throw a
missing-delegate error immediately:

**Isolated single-route `GoRouter`** (the default — used whenever the
test only needs to exercise one screen, not cross-screen navigation),
from `test/quiz_session_screen_test.dart`:

```dart
Widget wrap() {
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, __) => const QuizSessionScreen())],
  );
  return ProviderScope(
    overrides: [
      userDatabaseProvider.overrideWithValue(db),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}
```

**The app's real router**, via `test/fixtures/app_harness.dart`'s
`makeApp()`, used specifically when a test needs to prove real
cross-screen navigation works (bottom-nav tab switches, drilling into
a sub-screen and back) — used by `test/app_test.dart`,
`test/sprint8_navigation_test.dart`, and similar. The doc comment in
`sprint8_navigation_test.dart` explains the tradeoff directly: an
isolated `GoRouter` per test is faster and more focused, but at least
one real navigation bug (a `Navigator` key issue) was only caught by
testing through the actual app router, so a handful of tests
deliberately pay that cost.

`makeApp()` also overrides `userDatabaseProvider` with an in-memory
`UserDatabase` and `quranRepositoryProvider` with a minimal
`FakeQuranRepo`, specifically to avoid touching `path_provider` (no
platform channel available in the widget-test environment) when a
screen under test happens to reach a real database provider.

### 3.5 Fake naming and shape

Fakes `implement` the real domain interface directly (28 classes named
`Fake...`/`_Fake...` across the suite, plus a handful of
`_Recording...` fakes for logging/crash-reporting infra). Two habits
worth copying:

- Methods genuinely irrelevant to the test at hand are left as `throw
  UnimplementedError()` rather than a plausible-looking stub — an
  accidental call fails loudly instead of returning a silently-wrong
  default (see `_FakeKhatmCycleRepository` in §1.3).
- Fakes that need to be "poked" from within a test expose an explicit
  mutator method for that purpose (`emitActive(...)`, `emitCards(...)`),
  rather than exposing a public mutable field directly — keeps the
  "trigger a change" call sites in tests self-documenting.

### 3.6 Vietnamese test descriptions — a real, intentional convention

Every one of the 104 top-level test files contains Vietnamese-language
prose (verified by grepping for Vietnamese diacritics across all of
them — zero files came back without any). This is **not** a
translation gap or leftover scaffolding: `test()`/`group()`/
`testWidgets()` string arguments and the doc comments explaining *why*
a fake or test exists are written in Vietnamese throughout,
consistently, while all identifiers, class/function names, and
production code remain English — exactly matching this repo's own
stated convention (`CLAUDE.md`: "Code and identifiers: English
throughout... App UI strings: Vietnamese default"). Test descriptions
extend that same split to the test suite's own prose. Examples,
verbatim:

```dart
test('thêm lại sau khi đã xoá mềm -> hồi sinh bản ghi cũ (giữ nguyên '
    'id), KHÔNG insert trùng khoá UNIQUE', () async { ... });

testWidgets('chọn 1 đáp án -> hiện phản hồi đúng/sai và chuyển sang câu 2/10 '
    '(scoring + next-question transition)', (tester) async { ... });
```

A new contributor should write new test descriptions in Vietnamese to
match, with English only in code identifiers — mixing English
descriptions in would be inconsistent with every existing file, not a
neutral choice.

### 3.7 Sprint/task-ID traceability tags

Many test descriptions and doc comments cite a sprint and item ID
inline — `'Sprint S2, D9'`, `'Sprint 8 Phase 5'`, `'Sprint 20 Phase 2,
Task 2+4'` — tying a specific test back to the roadmap/debt-register
item that motivated it (39 of 104 files contain at least one such
tag). This is how [UPDATED_TECHNICAL_DEBT.md](../release/UPDATED_TECHNICAL_DEBT.md)'s "D9 — FIXED (S2)"
claim in §2.5 above was independently verifiable just by grepping test
descriptions, without needing to trust the debt doc's prose alone.
When adding a test to close a specific tracked gap, tag it the same
way.
