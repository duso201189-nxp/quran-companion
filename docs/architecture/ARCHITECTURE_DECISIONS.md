# Architecture Decisions — Qur'an Companion

Written during Phase 2.1 (Documentation Integration). This is a
**consolidated retrospective summary** of the major architectural
choices visible in the current codebase — it complements, and does not
replace, the individual, dated Decision Records in
[`docs/adr/`](../adr/) (`DR-2026-0001` through `DR-2026-0014`), each of
which documents one specific, narrower decision made at a specific
point in time. Where an `docs/adr/` record exists for a topic below,
it's cited; several of the decisions below (notably the AI composition
chain and the reliability layer's CrashReporter wiring) were never
captured as a formal numbered ADR and are recorded here for the first
time, reconstructed from the code's own doc comments rather than from
a contemporaneous design discussion.

Each entry follows Context → Decision → Consequences. See
[MASTER_ARCHITECTURE.md](MASTER_ARCHITECTURE.md) for how these
decisions manifest in the current code, with file:line citations.

---

## 1. Flutter architecture — feature-first, three-layer per feature

**Context.** The app needed to scale to 18+ distinct features
(reading, search, flashcards, analytics, AI tutor, etc.) built
incrementally across many sprints, often by re-entering the codebase
after a gap. A single flat `lib/` with type-based folders
(`lib/screens/`, `lib/models/`, `lib/services/`) would make it hard to
reason about what belongs to what, and hard to delete a feature
cleanly if ever needed.

**Decision.** Organize `lib/features/<name>/` per feature, and inside
each feature, repeat the same three-layer split every time:
`domain/` (entities, repository interfaces, pure logic) →
`data/` (repository implementations, Riverpod provider wiring) →
`presentation/` (screens, widgets, controllers). Shared code that
doesn't belong to one feature lives in `lib/shared/` (widgets/utils)
or `lib/core/` (infrastructure — database, logging, error types,
storage, audio, cache).

**Consequences.** Every feature is self-contained and independently
understandable — `MODULE_CATALOG.md`'s per-feature entries exist
precisely because this convention makes "what does this directory do,
what does it depend on" a well-posed question with a discoverable
answer. The cost: some genuine duplication across features before a
shared abstraction gets extracted (see decision 3's consequences, and
`UPDATED_TECHNICAL_DEBT.md` D6/D8 for two concrete, still-open
examples). The convention is enforced socially/by doc-comment
discipline, not by tooling — there's no lint rule preventing a feature
from reaching into another feature's `data/` internals; `PROVIDER_MAP.md`
§3.2 documents the handful of places this discipline has slipped
(e.g. `stats/data/stats_store.dart` reading a `quran/presentation/`
class's static helper directly).

## 2. Riverpod for state management and dependency injection

**Context.** The app needs both traditional widget state management
(loading/error/data for async screens) and a dependency-injection
mechanism for repositories, so that `main.dart` can wire real
implementations while tests substitute fakes without touching feature
code.

**Decision.** Use `flutter_riverpod` for both concerns with one
convention: every repository gets exactly one `Provider<XRepository>`
that constructs the concrete implementation from its dependencies
(`ref.watch(...)` calls only, no service locator, no global singleton
access). Screens/controllers only ever depend on providers, never
construct a repository directly.

**Consequences.** `main.dart` only needs to override two providers
(`sharedPreferencesProvider`, `ayahAudioPlayerProvider` —
`PROVIDER_MAP.md` §1.1) — every database, repository, and
cross-repository orchestration provider self-constructs lazily. Tests
override exactly the providers they need to fake
(`ProviderContainer(overrides: [...])`, `TESTING_GUIDE.md` §1.3) rather
than needing a full DI container rebuild per test. The cost: Riverpod's
`.autoDispose` semantics have real, non-obvious edge cases — an
`.autoDispose` provider chain without an active listener can silently
restart from scratch on a subsequent `read()`, which caused one
concrete, since-fixed test-authoring bug during Sprint S2 (documented
in `docs/testing/TESTING_GUIDE.md` §1.3's `_resolvedProgress` example)
and is a real trap for anyone writing a new test against a chain of
`.autoDispose` providers.

## 3. Repository pattern with domain-layer purity

**Context.** Business logic (SM-2 scheduling math, statistics
calculations, question generation) needs to be testable without
booting Flutter, Riverpod, or a real database, and ideally reusable
from a future context this app doesn't have yet (a background sync
process, a CLI tool, a future AI Tutor making its own decisions).

**Decision.** Every feature defines an `abstract interface class`
repository in `domain/`, implemented concretely in `data/`. The
`domain/` layer — interfaces, entities, and pure calculator/generator
functions — never imports `package:flutter_riverpod` or
`package:drift` (or Flutter itself). This is stated as an explicit,
repeated rule across nearly every domain repository interface's own
doc comment (`MASTER_ARCHITECTURE.md` §5, principle 1) — not
inferred, asserted directly in the code. This project's own
[`PROJECT_CONSTITUTION.md`](../../PROJECT_CONSTITUTION.md) elevates a
version of this rule to a governed invariant
(`PROJ-P-003-domain-layer-purity`).

**Consequences.** Every pure domain function (SM-2 math, quiz-option
shuffling, statistics aggregation, the 5-tier AI chain's rule-based
suggestion logic) is unit-testable with a plain `test()`, no widget
pump, no database — `TESTING_GUIDE.md` §1.1 confirms this is exactly
how the suite is organized, and it's the reason 43 of the ~120
domain+data files have direct unit-test coverage without needing any
Flutter test infrastructure at all. The cost is some ceremony: every
repository needs both an interface and an implementation file even
when there's currently only one implementation and no near-term plan
for a second — accepted deliberately, per the interfaces' own doc
comments, in exchange for testability and the option to swap an
implementation later without touching call sites (see decision 6,
where this optionality was actually exercised for the scheduling
algorithm).

## 4. SQLite via Drift as the local persistence layer

**Context.** The app needs typed, queryable, offline-first local
storage for a large, mostly-static content dataset (114 Surahs, 6236
Ayahs, translations, audio metadata, eventually full lexical/
morphological data) and a smaller, growing set of user-generated data
(bookmarks, notes, flashcards, learning progress), on every platform
Flutter targets.

**Decision.** Use Drift (a type-safe Dart ORM over SQLite) for both.
Tables are declared as Dart classes with explicit `tableName`/
`.named(...)` column mappings (not relying on Drift's implicit
snake_case convention), so that hand-built or externally-generated
SQLite files line up byte-for-byte with the Dart schema
(`DATABASE_REFERENCE.md` §1.1). Full-text search uses a raw SQLite
FTS5 virtual table alongside the typed Drift schema, queried via
`customSelect(...)` rather than forcing FTS5 into Drift's typed query
builder.

**Consequences.** Compile-time-checked queries catch schema/repository
mismatches as compiler errors rather than runtime "no such column"
failures — `DATABASE_REFERENCE.md` §3.3 notes this is strong enough
evidence of schema correctness that dedicated schema-consistency tests
weren't needed on top of it. The explicit column-naming convention
means the content database can be built entirely outside the Flutter
app (`tool/build_quran_db.py`, a Python pipeline) and just dropped in
as an asset, with zero coordination beyond keeping the Dart table
declarations and the Python schema generator in sync by hand — a real,
accepted coordination cost, and the source of the one operational gap
`DATABASE_REFERENCE.md` §1.1 documents (8 Lexicon tables exist in the
schema and the shipped asset, but the Python pipeline hasn't populated
them with real data yet).

## 5. Dual-database architecture (Group A / Group B split)

**Context.** The app has two fundamentally different kinds of data
with different lifecycles: static, shared, read-only Qur'an/lexicon
content (identical for every install, updated only by shipping a new
app version or content asset) and per-user, mutable, eventually
sync-needing data (bookmarks, flashcards, learning progress). Mixing
them in one database would make "what needs sync/backup" and "what can
be safely wiped and re-copied from the app bundle" much harder
questions to answer, and would put shared read-only content and
private user data in the same file for no functional benefit.

**Decision.** Two entirely separate Drift database classes —
`AppDatabase` ("Group A", read-only, ships as an asset) and
`UserDatabase` ("Group B", read-write, created empty per-device) —
each with its own connection, its own migration history, and a hard
rule that no single repository implementation touches both
(`MASTER_ARCHITECTURE.md` §2.1, §4.2). This is a governed invariant in
this project's constitution
(`PROJECT_CONSTITUTION.md` → `PROJ-P-002-dual-database-separation`),
not just a convention.

**Consequences.** Group A can be rebuilt/replaced by shipping a new
asset (`meta.data_version` bump) with zero risk to user data, and
Group B's migration history (`DATABASE_REFERENCE.md` §3.2, 5
version bumps, all additive, all with a dedicated migration test) only
ever needs to reason about the shapes of tables it actually owns. The
cost: **no cross-database foreign keys are possible** — every
reference from a Group B row to a Group A row (e.g.
`bookmarks.ayah_id` → `ayahs.id`) is enforced only at the repository
layer, verified by tests rather than by the database engine
(`DATABASE_REFERENCE.md` §2.2). This is an accepted, explicit tradeoff,
not an oversight.

## 6. Learning Engine architecture (SM-2 scheduler, swappable by design)

**Context.** Spaced-repetition scheduling (SM-2 or a future
alternative like FSRS) needs to apply uniformly to two different kinds
of reviewable items — Ayahs already in a user's "Revision Queue" and,
later, vocabulary Flashcards — without hard-coding either the
scheduling algorithm or the item kind into the scheduler itself.

**Decision.** `SrsCard` is generic over `item_type`
(`'ayah'` | `'lemma'`) + `item_id` rather than being two separate
tables (`DATABASE_REFERENCE.md` §1.2, `srs_cards`). The actual
ease/interval/state math is delegated to a `SchedulingAlgorithm`
interface (`schedulingAlgorithmProvider`, default
`SM2SchedulingAlgorithm`) that `SchedulerRepository` calls but never
implements itself — swapping the algorithm later is one provider
override, not a repository rewrite. Membership in the SRS system for
ayahs is driven by an existing, independent concept (the "Revision
Queue," `ayah_statuses.status='review'`) via a Provider-layer sync
bridge (`schedulerSyncProvider`) rather than the Scheduler owning or
replacing that concept — a deliberate amendment to an earlier plan
(`docs/adr/DR-2026-0003-sprint8-data-architecture.md` originally
proposed the Scheduler *replacing* the Revision Queue;
`docs/adr/DR-2026-0005.md` records the reversal: consume it instead).

**Consequences.** Flashcards (a much later feature) plugged into the
exact same scheduling infrastructure with zero changes to
`SchedulerRepository` or the `srs_cards` schema — only a second
Provider-layer sync bridge (`flashcardSchedulerSyncProvider`) needed
to be added (`PROVIDER_MAP.md` §2.4). The generic `item_type` design
means a future third reviewable-item kind (e.g. grammar rules) could
plug in the same way. The cost is a small amount of indirection any
new contributor has to learn: "why does the Scheduler not just know
about ayahs and flashcards directly" is a real question with a
non-obvious answer (decoupling, see decision 3) until they read the
relevant doc comments.

## 7. AI composition chain — five rule-based layers, no LLM yet

**Context.** The product's roadmap includes AI-assisted study
recommendations, but building toward that incrementally requires each
layer of "smarter" behavior (basic stats → tutor suggestions → a daily
plan → grouped strategies → an aggregated snapshot) to be independently
buildable, testable, and reviewable — and to work *before* any actual
AI/LLM integration exists, since that integration is explicitly future
scope (see [PRODUCT_ROADMAP.md](../release/PRODUCT_ROADMAP.md) v2.0).

**Decision.** Five repositories, each composing **exactly one**
dependency — the layer directly below it — never skipping a level or
reaching sideways: `AnalyticsRepository` (aggregates 4 leaf
repositories) → `AITutorRepository` → `LearningJourneyRepository` →
`SmartLearningRepository` → `LearningSnapshotRepository` (feature
`read_model`). Every layer's own doc comment states its single
allowed dependency explicitly and states, equally explicitly, "No AI
model integration yet" / "Rule-based only" (`MASTER_ARCHITECTURE.md`
§4.1). This decision was never captured in a numbered `docs/adr/`
record at the time it was made — it's reconstructed here from the
code's own consistent, repeated doc-comment language across all five
repository implementations, which is strong evidence it was a
deliberate, single design intent applied uniformly rather than five
independent choices that happened to agree.

**Consequences.** Each layer can be built, reviewed, and merged
independently (and was — F3 through F7 in the project's own PR
history), and a future real AI/LLM integration has a natural
insertion point (most likely inside `AITutorRepository` or a new layer
above `LearningSnapshotRepository`) without needing to touch the layers
below it. The cost, explicitly acknowledged in the code rather than
hidden: **no caching between calls** at the repository level means a
single "give me everything" read at the top of the chain can fan out
to up to ~12 calls into `AnalyticsRepository` at the bottom
(`DATA_FLOW.md` Flow 4). A Provider-level workaround (two "bypass"
providers reusing an upstream sibling's cached result — `PROVIDER_MAP.md`
§2.3) mitigates this for the two hot paths that currently need it,
but is explicitly documented as unsafe to apply blindly everywhere
(it can serve stale data past a manual refresh) — this is a real,
load-bearing piece of the current design that any change to the AI
chain's performance characteristics needs to understand first. The
top layer, Read Model, currently has no UI consumer at all — an open
product decision, not an engineering gap (`RELEASE_PLAN_V1.md` §2, D3).

## 8. Error handling / reliability strategy

**Context.** Every repository that touches a database can fail (disk
errors, constraint violations, malformed data), and the app needs
consistent diagnostics without either (a) every repository method
hand-rolling its own try/catch/log boilerplate, or (b) silently
swallowing errors and changing behavior for callers that already
handle exceptions correctly.

**Decision.** A small, centralized reliability layer: `AppFailure`
(a plain-Dart classified error value — `category` × `severity`,
explicitly not a user-facing string), a pure `mapToAppFailure()`
classifier, an abstract `Logger` interface, and a single wrapper
function, `withFailureLogging()`/`withFailureLoggingStream()`, that
every database-backed repository calls at every public method. The
wrapper's own contract, stated in its doc comment, is absolute: on
success, return the value unchanged; on failure, log and **always
rethrow the original error, unchanged** — "Only diagnostics improve"
(`MASTER_ARCHITECTURE.md` §2.2).

**Consequences.** Adding structured logging to all 9 database-backed
repositories required writing the wrapper once and adding a
constructor parameter + call-site wrapping to each — not a new
per-repository error-handling design each time. This paid off
directly during Sprint S2: wiring `CrashReporter` (previously built,
Sprint 19, but never actually called by anything) into every
repository's failure path took a **2-file change** (inside
`ConsoleLogger`, since `Logger.error()` is the one and only place
`withFailureLogging` calls) rather than touching the 9 repositories,
their 9 provider files, or their ~17 constructing tests — a direct,
concrete payoff of centralizing the boundary once. The cost: this
strategy only covers repositories that call `withFailureLogging` in
the first place. Sprint S2 also found and fixed a real gap the
strategy doesn't automatically catch — `LearningSessionController`
(a pure orchestration `Notifier`, not a database-backed repository)
had zero error handling of its own, since `Notifier` (unlike
`AsyncNotifier`) doesn't auto-wrap async errors and this controller
sits outside the repository-boundary wrapper's reach entirely
(`docs/testing/TESTING_GUIDE.md` references this; full detail in
`docs/reports/release-recovery/S2_IMPLEMENTATION_REPORT.md`).

## 9. Testing strategy — real in-memory databases, hand-written fakes, no mocking framework

**Context.** With Drift-backed repositories, Riverpod providers, and
Flutter widgets all needing coverage, the project needed a consistent
answer to "what gets a real dependency vs. a test double, and how are
test doubles built" — inconsistency here (some repositories mocked,
some hitting real SQLite, some hand-faked) would make the suite harder
to trust and harder to extend consistently.

**Decision.** Repository tests always construct a **real**
`NativeDatabase.memory()`-backed `UserDatabase`/`AppDatabase` — never
a mock of the database layer (`TESTING_GUIDE.md` §1.2). Provider tests
use a bare `ProviderContainer` with `.overrideWithValue()`/
`.overrideWith()`, faking only the repository interface, not Riverpod
itself (§1.3). No mocking framework (`mockito`/`mocktail`) is a
dependency anywhere in the project — every test double is a
hand-written class that `implements` the real domain interface, with
untested methods left as `throw UnimplementedError()` rather than a
plausible-looking stub (§1.4, §3.5). Anything involving randomness
(quiz question generation) takes `Random` as an explicit parameter so
tests can seed it (§1.5).

**Consequences.** Repository tests exercise real SQL — real
Drift-generated queries, real `UNIQUE` constraints, real soft-delete
semantics — with no risk of a mock silently diverging from actual
database behavior, at the cost of a small amount of setup
boilerplate (`setUp`/`tearDown` around a real database) repeated
across ~25 test files. The "no mocking framework" choice means every
fake is visible, ordinary Dart code with no code-generation step and
no `when(...).thenReturn(...)` DSL to learn — but it also means there
is no automatic verification that a fake still matches its real
interface after the interface changes (a mocking framework's generated
mock would fail to compile in that case; a hand-written fake compiles
fine and just silently doesn't implement the new method until someone
notices `UnimplementedError()` at runtime). Given the project's small
team size (`ROLES.md`: all six canonical roles currently held by one
person), this tradeoff — favoring transparency and zero magic over
automatic interface-drift detection — has been judged worth it so far;
revisit if the project ever needs to scale review capacity across
multiple contributors who don't have the whole domain model in their
head.

---

See [MASTER_ARCHITECTURE.md](MASTER_ARCHITECTURE.md) for how these
decisions show up in the current code, [`docs/adr/`](../adr/) for
individual, dated Decision Records on narrower topics, and
[`PROJECT_CONSTITUTION.md`](../../PROJECT_CONSTITUTION.md) for which of
these are governed invariants (stop-and-ask-before-changing) rather
than conventions that could reasonably evolve.
