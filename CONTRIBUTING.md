# Contributing to Qur'an Companion

This document is the practical companion to
[`PROJECT_CONSTITUTION.md`](PROJECT_CONSTITUTION.md) (governed
invariants — read before assuming a rule here is "just a convention")
and [`docs/architecture/ARCHITECTURE_DECISIONS.md`](docs/architecture/ARCHITECTURE_DECISIONS.md)
(why the codebase is shaped the way it is). Start at
[PROJECT_INDEX.md](PROJECT_INDEX.md) if you haven't already — it maps
every topic to its current, authoritative document.

## Coding standards

- **Language**: Dart/Flutter throughout. Identifiers, class/function
  names, and all code comments are English. See "Language convention"
  below for the one deliberate exception (test descriptions).
- **Formatting**: `dart format` is the only source of truth for
  layout — don't hand-format around it. Run it before every commit;
  CI fails on any diff.
- **Linting**: `flutter analyze --fatal-infos` must report zero issues
  — not just zero errors. An `info`-level lint left unresolved is a
  failing gate here, not a suggestion.
- **Domain-layer purity** (`PROJ-P-003`, governed invariant): files
  under any `domain/` directory never import
  `package:flutter_riverpod`, `package:drift`, or Flutter itself.
  Business logic and entities belong there; DI wiring and database
  calls do not. See `ARCHITECTURE_DECISIONS.md` §3.
- **Repository pattern**: every repository is an `abstract interface
  class` in `domain/` with exactly one concrete implementation in
  `data/`, wired through exactly one `Provider<XRepository>`. Don't
  construct a repository implementation directly from presentation
  code — go through its provider.
- **Feature-first organization**: new code lives under
  `lib/features/<name>/{domain,data,presentation}/`. Cross-feature
  reusable widgets go in `lib/shared/widgets/`; cross-feature
  infrastructure goes in `lib/core/`. Don't create a new top-level
  `lib/` folder without a specific reason — see `MASTER_ARCHITECTURE.md`
  §1.
- **Reuse before inventing**: before writing a new widget or helper,
  check `lib/shared/widgets/` and the feature directories for
  something that already does the same thing (`StatCard`,
  `EmptyStateBanner`, `LoadingState`, `SearchErrorState` all exist
  specifically to prevent a second copy — see
  `ARCHITECTURE_DECISIONS.md` §1). A near-identical widget in two
  places is technical debt from the moment it's written, not just
  once someone notices it.
- **Localization**: every new user-facing string goes into all three
  `lib/l10n/app_{vi,en,ar}.arb` files (Vietnamese is the default
  locale) — never hardcode UI text. Prefer reusing an existing generic
  key (e.g. `errorLoadData`, `retry`) over adding a near-duplicate new
  one; only add a new key when the existing ones genuinely don't fit.
- **Error handling**: database-backed repositories wrap every public
  method in `withFailureLogging`/`withFailureLoggingStream`
  (`core/logging/repository_boundary_logging.dart`) — see
  `ARCHITECTURE_DECISIONS.md` §8. Don't add a new ad hoc try/catch
  pattern at a repository boundary; use the existing wrapper.
- **Language convention**: code, identifiers, and doc comments are
  English. Test descriptions (`test()`/`group()`/`testWidgets()`
  string arguments) are written in Vietnamese, matching this
  project's own established, intentional convention — see
  `docs/testing/TESTING_GUIDE.md` §3.6. This is not inconsistency; it
  mirrors the app's own UI-string convention (Vietnamese default,
  English/Arabic also supported) applied to the test suite's prose.

## Commit conventions

- **Format**: `type: short summary`, e.g. `feat(learning_session): add
  error handling`, `fix(logging): wire CrashReporter into
  ConsoleLogger`, `docs: update ROADMAP.md`, `test: cover
  daily_goal_providers`. Prefixes used throughout this project's
  history: `feat`, `fix`, `docs`, `test`, `chore`, `refactor`, `perf`,
  `ci`. A `(scope)` in parentheses naming the affected feature/area is
  encouraged but not mandatory.
- **One logical change per commit.** Don't bundle an unrelated
  refactor into a bug-fix commit, or multiple independent fixes into
  one commit — each should be reviewable and revertable on its own.
- **Message body**: explain *why*, not just *what* — the diff already
  shows what changed. A good commit message says what problem existed,
  why this is the right fix, and what (if anything) was deliberately
  left out of scope.
- **Never rewrite published history**: don't `git commit --amend` or
  force-push a branch that's already been shared/reviewed. Fix
  forward with a new commit instead.
- **Don't skip hooks or gates** (`--no-verify`, disabling CI checks)
  to get a commit through — if a gate is failing, fix the underlying
  issue.

## PR checklist

Before opening a pull request:

- [ ] `dart format --set-exit-if-changed lib test integration_test`
      reports zero changes.
- [ ] `flutter analyze --fatal-infos lib test integration_test`
      reports zero issues.
- [ ] `flutter test test` — full suite passes (not just the tests you
      added or touched).
- [ ] New/changed behavior has test coverage in the same PR — see
      "Testing requirements" below for what layer of test is
      appropriate.
- [ ] New user-facing strings are in all three `lib/l10n/app_{vi,en,ar}.arb`
      files, and `flutter gen-l10n` has been run so the generated
      `app_localizations*.dart` files are in sync.
- [ ] If the change affects architecture, database schema, or a
      pattern documented in `docs/architecture/`, that documentation
      is updated in the same PR — stale docs are worse than no docs,
      because they're actively misleading (see
      `docs/reports/release-recovery/README.md` for what happens when
      this discipline lapses for a long stretch).
- [ ] PR description states scope clearly: what changed, why, and
      anything deliberately excluded from scope (a pattern used
      consistently throughout this project's `PR_DESCRIPTION.md`
      history — state the boundary explicitly rather than leaving a
      reviewer to guess whether an adjacent issue was considered and
      rejected, or just not noticed).
- [ ] No schema change to either database, no Supabase RLS policy
      change, no monetization-related change, and no dependency
      major-version bump without first checking
      [`CLAUDE.md`](CLAUDE.md)'s "Stop and ask before" list — these
      require explicit sign-off before implementation, not just
      before merge.

## Testing requirements

See [`docs/testing/TESTING_GUIDE.md`](docs/testing/TESTING_GUIDE.md)
for the full strategy, conventions, and worked examples. In summary:

- **Domain logic** (calculators, generators, pure functions): a plain
  `test()`, no Flutter bindings. No mocking framework is a project
  dependency — write a hand-rolled fake `implements`-ing the real
  interface if you need a test double.
- **Repository implementations**: test against a real
  `NativeDatabase.memory()`-backed database, never a mocked database
  layer. This is a hard convention, not a suggestion — see
  `docs/architecture/ARCHITECTURE_DECISIONS.md` §9 for why.
- **Riverpod providers**: a bare `ProviderContainer` with
  `.overrideWithValue()`/`.overrideWith()`, not a full widget tree.
- **Screens/widgets**: `testWidgets()` with `ProviderScope` +
  `MaterialApp.router`, always wiring
  `AppLocalizations.localizationsDelegates`/`supportedLocales` (a
  screen reading a localized string will throw immediately otherwise).
- **Anything involving randomness** (e.g. quiz question generation):
  the production code must accept `Random` as an explicit parameter so
  tests can pass a seeded `Random(n)` for deterministic, CI-stable
  assertions.
- **Test file naming**: `<name>_test.dart`; for a `*_repository_impl.dart`,
  the convention drops the `_impl` suffix (`flashcard_repository_test.dart`,
  not `flashcard_repository_impl_test.dart`). One test file may
  legitimately cover several small, tightly-related `lib/` files.

## Architecture rules

Full detail and rationale in
[`docs/architecture/MASTER_ARCHITECTURE.md`](docs/architecture/MASTER_ARCHITECTURE.md)
§5 and
[`docs/architecture/ARCHITECTURE_DECISIONS.md`](docs/architecture/ARCHITECTURE_DECISIONS.md).
The short version, as rules to follow when writing new code:

1. Domain layer stays Flutter/Riverpod/Drift-independent.
2. UI never accesses a repository directly — only through that
   feature's own provider set.
3. In the 5-tier AI/learning chain (Analytics → AI Tutor → Learning
   Journey → Smart Learning → Read Model), a repository composes
   **only** the tier directly below it — never skip a level, never
   reach sideways.
4. Don't duplicate a statistic or calculation that's already derived
   elsewhere — compose the existing repository/provider instead of
   re-querying.
5. Reuse existing shared widgets/logic before writing new ones.
6. Repository-boundary error handling changes no behavior — the
   original error is always rethrown unchanged after logging; logging
   is the only side effect.
7. `UserDatabase` migrations are additive-only, one version step at a
   time, each with its own migration test — never drop user data.
8. User-owned data uses soft-delete + idempotent toggle/upsert
   (`SyncColumns`'s `deleted_at`/`is_dirty`), with integrity enforced
   at the repository layer, not by a database-level FK cascade.
9. Two independently-owned repositories that represent genuinely
   separate concerns are bridged only at the Provider layer (a
   `StreamProvider<void>` "sync bridge"), never through a direct
   repository→repository dependency.

Two databases, never mixed in one repository: `AppDatabase` ("Group A"
— static Qur'an/lexicon content, read-only) and `UserDatabase` ("Group
B" — user data, read-write). This split is a governed invariant
(`PROJ-P-002`), not a convention — see `PROJECT_CONSTITUTION.md`.

## Where to ask questions / who owns what

`ROLES.md` names who holds each of this project's six canonical roles.
As of this writing, all six are held by one person — if you're a new
contributor, that person is your point of contact for anything this
document and `PROJECT_INDEX.md` don't answer.
