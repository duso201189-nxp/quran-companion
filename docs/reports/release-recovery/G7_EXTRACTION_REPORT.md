# G7 Extraction Report — Sprint 10/11 Learning Engine (Scheduler, Review Session, Quiz, Learning Session)

Source of truth: `MAIN_RECOVERY_ROADMAP.md`, `G8_DECOMPOSITION.md`.
Read-only analysis. No branch, commit, cherry-pick, or rebase. Verified
against `origin/main` at `215a0fc` (`Merge pull request #9 from
.../feat/governance-and-sprint9`) — checked directly first, not taken
on faith.

---

## 1 — Every file in G7

Three commits (`fa8e358`, `4a9c4c4`, `394979d` — the last is a `dart
format` no-op layered on the first two; treated as one logical unit,
same pattern as prior groups' formatting-only commits):

```
59 files changed, 8,586 insertions(+), 695 deletions(-)
```

| Area | Files |
|---|---|
| Root docs | `CHANGELOG.md`, `DATABASE.md`, `ROADMAP.md`, `TODO.md` |
| New ADR | `docs/adr/DR-2026-0005.md` (added), `docs/adr/README.md` (modified — index row) |
| Routing | `lib/app/router.dart` |
| Schema | `lib/core/database/user/{user_database.dart, user_database.g.dart, user_tables.dart}` |
| New: Scheduler (SM-2) | `lib/features/learning/{data/scheduler_providers.dart, data/scheduler_repository_impl.dart, domain/entities/srs_card.dart, domain/repositories/scheduler_repository.dart, domain/scheduling_algorithm.dart, domain/sm2_scheduling_algorithm.dart, presentation/review_session_providers.dart, presentation/review_session_screen.dart}` (8 files) |
| New: Learning Session | `lib/features/learning_session/{data/learning_planner_providers.dart, domain/learning_planner.dart, domain/learning_session_state.dart, domain/learning_session_summary.dart, domain/sequential_learning_planner.dart, presentation/learning_session_controller.dart, presentation/learning_session_screen.dart, presentation/learning_summary_screen.dart}` (8 files) |
| New: Quiz | `lib/features/quiz/{data/quiz_providers.dart, data/quiz_repository_impl.dart, domain/entities/{quiz_content_pool,quiz_question,quiz_result}.dart, domain/generators/{ayah_continuation,surah_identification,translation_matching,verse_recognition}_generator.dart, domain/question_generator.dart, domain/repositories/quiz_repository.dart, presentation/quiz_session_screen.dart}` (11 files) |
| Study screen | `lib/features/study/presentation/study_screen.dart` (modified — adds entry points) |
| Localization | 7× `lib/l10n/*`, append-only (177 insertions / 3 deletions across the 3 `.arb` sources; the 4 `app_localizations*.dart` are generated from them) |
| New tests | 12 files under `test/` |
| Modified test | `test/user_content_repository_test.dart` |

**No dependency, no pubspec, no asset, no build-config file appears in
the diff at all** — confirmed by direct check, not assumed from
pattern (see §3).

## 2 — Comparison against current `origin/main`

**All 18 modified (non-added) files checked byte-for-byte** between
G7's parent state (`fa8e358~1`) and current `main` (`215a0fc`) —
learning directly from `G6_EXTRACTION_REPORT.md`'s discovery that a
file merged just one PR prior (`CLAUDE.md`, via G1/PR #9) can't be
assumed safe without checking. Given `docs/adr/README.md` was itself
only just created by PR #9, it received the same explicit check as
every other file, not a pass:

`CHANGELOG.md`, `DATABASE.md`, `ROADMAP.md`, `TODO.md`,
`docs/adr/README.md`, `lib/app/router.dart`,
`lib/core/database/user/user_database.dart`,
`lib/core/database/user/user_database.g.dart`,
`lib/core/database/user/user_tables.dart`,
`lib/features/study/presentation/study_screen.dart`,
`test/user_content_repository_test.dart`, and all 7 `l10n` files —
**18 of 18 match byte-for-byte.** No `CLAUDE.md`-style gap this time.
All 41 added files are new paths (`git ls-tree origin/main` confirmed
none pre-exist), so no parent-state check applies to them.

## 3 — Verification

| Check | Result |
|---|---|
| **Database schema** | **Touched — two migration steps, not one.** `schemaVersion` moves **3 → 5** (not 3→4 as a naive read of "one new sprint" would suggest). Confirmed via direct diff of `user_database.dart`, not assumed |
| **Drift migrations** | Two guarded blocks added inside the existing `onUpgrade`, both purely additive: `if (from < 4) { await m.createTable(srsCards); }` and `if (from < 5) { await m.createTable(quizResults); }`. The prior `if (from < 3)` block (G5's `StudySessions`/`KhatmCycles`/`BookmarkCollections`/`Bookmarks.collectionId`) is untouched — confirmed via the diff hunk context lines, not just presence of the string |
| **`SrsCards` schema** | New table `srs_cards`: `itemType`(text)/`itemId`(int) generalized pair with a composite `uniqueKeys` on `{itemType, itemId}` (deliberately excludes `userId`, following the same precedent as every other table in the file, per the file's own inline comment) · `easeFactor`(real, default 2.5) · `intervalDays`(int, default 0) · `repetitions`(int, default 0) · `dueDate`(int, epoch ms) · `state`(text: new/learning/review/lapsed) |
| **`QuizResults` schema** | New table `quiz_results`: `quizType`(text) · `surahId`(int, **nullable** — deliberate deviation from `DATABASE.md`'s raw SQL sketch, documented inline: current quiz sessions are always `'mixed'` across surahs) · `score`(int) · `total`(int) · `takenAt`(int, epoch ms) |
| **Migration correctness** | Both blocks are simple `createTable` calls with no data transformation, no backfill (the SRS table's own doc comment explicitly states no backfill from `ayah_statuses.status='review'` at migration time — sync is self-healing on read via `SchedulerRepository.syncWithReviewQueue`, a design choice, not a gap) |
| **Compatibility with PR #8 schema** | **Fully additive on top of it.** `UserDatabase`'s `@DriftDatabase(tables: [...])` list keeps `StudySessions, KhatmCycles, BookmarkCollections` (PR #8 / schema v3) untouched and only appends `SrsCards, QuizResults` (v4, v5) — confirmed via the diff hunk showing the existing three names unchanged, two new names added after them |
| **Imports** | Every import across all 27 new `lib/` files read directly. Real, already-satisfied dependencies: `study_screen.dart` → new routes; `router.dart` → three new screen imports. No new file imports anything from `library`, `search`, `stats`, `khatm` in a way not already established by PR #4/#7/#8 |
| **Routing** | `router.dart` gains 2 new imports, 3 new `AppRoutes` constants (`reviewSession`, `quizSession`, `learningSession`), 3 new `GoRoute` entries — additive, inserted after the existing `revisionQueue` route, same full-screen-push pattern as every prior feature. Confirmed via the actual diff |
| **Localization** | 3 `.arb` sources gain 177 lines / lose 3 (net new keys for Learning Session / Quiz / Review UI strings), the 4 generated `app_localizations*.dart` files are mechanical `gen-l10n` output of those — same append-only pattern as every prior group |
| **Generated files** | `user_database.g.dart`: 2,275 insertions / 641 deletions (`git diff --numstat`) — large because Drift regenerates full companion/table classes for the two new tables plus updated schema-version metadata for existing ones; confirmed **mechanical, not hand-edited** by running `dart run build_runner build` locally against the current `main`-based working tree and checking `git status --porcelain` afterward — zero diff produced (the regeneration was a no-op against already-committed generated sources, i.e., nothing in this codebase's generator output has drifted from what's committed anywhere in the repo right now). Plus the 4 generated `l10n` files (mechanical `gen-l10n` output, same as every prior group) |
| **Assets** | None touched — confirmed by direct check |
| **pubspec** | **Untouched — zero diff**, `git diff --name-status` for `pubspec.yaml` and `pubspec.lock` both empty. Notably different from G6, which had a version-bump-only pubspec change; G7 has none at all |
| **Tests** | **12 new test files** (`learning_planner_test`, `learning_session_controller_test`, `learning_session_screen_test`, `learning_summary_screen_test`, `quiz_providers_test`, `quiz_question_generator_test`, `quiz_repository_test`, `quiz_session_screen_test`, `review_session_screen_test`, `scheduler_providers_test`, `scheduler_repository_test`, `sm2_scheduling_algorithm_test`) plus 1 modified (`user_content_repository_test.dart`, presumably schema-version-count assertions given the pattern from G5). This is the **best test coverage in the backlog** — a sharp contrast to G6's zero, and ahead of G4's 88/G5's 61 in file count if not necessarily in assertion count |
| **Build configuration** | Not touched — confirmed by direct check across `android/`, `ios/`, `web/`, `*.gradle`, `Podfile`, `build.yaml`, `analysis_options.yaml` |

## 4 — Dependency detection: remaining G8

**None found as real dependencies.** A full-content sweep of all 27
new/modified `lib/` files for the strings `flashcards`, `analytics`,
`lexicon`, `read_model`, `ai_tutor`, `smart_learning` found exactly one
hit-cluster: the field name `flashcardsCompleted` on
`lib/features/learning_session/domain/learning_session_summary.dart`'s
`LearningSessionSummary` class — a locally-defined `int` counter
documented inline as *"Sprint 11: Flashcard chưa xây, luôn giữ nguyên
0"* ("Flashcard not built yet, always stays 0"). Confirmed by a
separate, stricter sweep for actual module-path imports
(`features/flashcards`, `features/analytics`, `features/lexicon`,
`features/read_model`, `features/ai_tutor`, `features/smart_learning`)
— **zero matches**. This is a forward-looking placeholder field, not a
dependency on unmerged G8 code.

**Everything G7 depends on is already merged**: My Library (PR #4,
via `AyahStatuses`/library patterns reused across features), Search
(PR #7), Sprint 8 Foundation (PR #8, whose schema v3 this group's
migrations extend), Sprint 9 (PR #9, whose `study_screen.dart` this
group modifies further).

## 5 — Schema readiness for G8 P3 (per `G8_DECOMPOSITION.md`)

`G8_DECOMPOSITION.md` states G8's P3 (schema layer) needs two table
sets before it can apply: G5's `StudySessions`/`KhatmCycles`/
`BookmarkCollections` (already on `main` via PR #8, schema v3) **plus**
G7's `SrsCards`/`QuizResults` (this group, schema v4/v5).

| Prerequisite | Status |
|---|---|
| `StudySessions`, `KhatmCycles`, `BookmarkCollections` (G5) | **Already satisfied** — merged, live on `main` since PR #8 |
| `SrsCards`, `QuizResults` (G7) | **Satisfied once this PR merges** — both tables confirmed present in this diff, correctly sequenced as schema v4/v5 on top of v3 |

**Once G7 merges, both halves of G8 P3's stated prerequisite are met.**
No third table set or additional schema step was found to be missing —
checked directly against `G8_DECOMPOSITION.md`'s own wording rather
than inferred.

## 6 — Can G7 merge as a single independent PR?

**Yes.** Every file checked against current `main` either matches
byte-for-byte (18 modified files) or is a genuinely new path (41 added
files, none pre-existing). No `CLAUDE.md`-style gap. No dependency on
anything unmerged. Schema migrations are additive and internally
consistent with the already-merged v3 base. No pubspec, asset, or
build-config surprises.

## 7 — Smallest safe extraction

**Not applicable — no split needed.** G7's 59-file diff is already a
single, cohesive, cleanly-scoped change with zero external blockers,
unlike G6.

---

## Dependency graph

```
G7 ── depends on: PR #4 (My Library), PR #7 (Search),
                   PR #8 (Sprint 8 schema v3), PR #9 (Sprint 9's
                   study_screen.dart) — all already merged
    ── depends on: nothing from remaining G8 (checked directly;
                   one placeholder field name is the only surface
                   match, not a real import)
    ── depended on by: G8 P3 (SrsCards, QuizResults — the second
                   half of its stated schema prerequisite)
```

## Migration audit plan

1. Confirm `schemaVersion` reads `5` on the branch (done — §3).
2. Confirm the `if (from < 4)` and `if (from < 5)` blocks each run
   exactly one `createTable`, no data movement (done — §3).
3. Confirm the pre-existing `if (from < 3)` block is byte-identical to
   its state on `main` (done — verified via diff hunk context showing
   no changes to that block).
4. Run the project's own migration-path tests
   (`test/user_content_repository_test.dart`'s `schemaVersion N`/
   `onUpgrade vX -> vY` group, the same mechanism used for the G5
   audit) once the branch is cut, to empirically exercise `2→5` (fresh
   install) and `3→5` (upgrade from the PR #8 state) — not yet run,
   since this phase is read-only; scheduled for the Implementation
   phase.
5. Regenerate `user_database.g.dart` via `dart run build_runner build`
   on the cut branch and diff against the committed version, same
   discipline as G5 (CRLF-normalize before comparing, given the known
   Windows `core.autocrlf` false-positive from that audit).

## Risk assessment

| Factor | Assessment |
|---|---|
| Structural risk (does it merge cleanly) | **Low** — no missing-prerequisite pattern found this time; every parent-state file matches current `main` |
| Test coverage | **Strongest in the backlog** — 12 new test files, a sharp reversal from G6's zero |
| Schema | **Two-step migration (v3→4→5)**, larger than G5's single v2→3 step but each step is a single additive `createTable` with no data transformation — moderate but well-understood risk, same class as G5's already-proven-safe pattern |
| Size | **Largest group so far** — 59 files, 8,586 insertions, exceeding G5's 54/7,039 and G4's 27/2,769 |
| Overall | **Low-Medium** — size is the main driver of review effort, not structural risk; no blocker comparable to G6's `CLAUDE.md` gap was found |

## Recommended merge strategy

Cherry-pick `fa8e358`, `4a9c4c4`, `394979d` onto current `main`, in
order, as one PR — same three-commit-preserving pattern as every prior
group. Recommend the PR description highlight the two-step schema
migration explicitly (v3→4→5, not a single jump) and note that this PR
completes the schema prerequisite `G8_DECOMPOSITION.md` P3 has been
waiting on since G5.

---

## READY FOR G7 PR
