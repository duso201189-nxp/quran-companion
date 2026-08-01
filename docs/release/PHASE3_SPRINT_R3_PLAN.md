# Phase 3 — Sprint R3 Plan

Read in full: `docs/release/RELEASE_PLAN_V1.md`, `RELEASE_DASHBOARD.md`,
`docs/release/UPDATED_TECHNICAL_DEBT.md`. Every claim below that could
be checked against the actual repository was checked against the
actual repository — not copied from those documents on trust. Two
corrections came out of that (§2). No code was modified, no commit was
created, to produce this document.

---

## 1. Documents reviewed

- `docs/release/RELEASE_PLAN_V1.md` — the authoritative v1.0 blocker
  list and recommended sequencing, written after PR #19.
- `RELEASE_DASHBOARD.md` — synthesized dashboard, last updated after
  Phase 3 Sprint R2 (commit `d7e9dae`).
- `docs/release/UPDATED_TECHNICAL_DEBT.md` — the D1–D14 debt register,
  last updated the same day (D3 marked resolved, P1 tally corrected).

## 2. Repository vs. release plan — verification, not trust

Every checkable claim in the three documents was re-verified directly
against the current repository. Two were found stale; everything else
checked out exactly as documented.

| Claim | Source | Verified how | Result |
|---|---|---|---|
| Lexicon tables ship empty (0 rows) | `RELEASE_PLAN_V1.md` §2, dashboard §3 Critical | Opened `assets/database/quran.sqlite` directly (Python `sqlite3`), counted rows in all 8 Lexicon tables (`roots`, `lemmas`, `lexemes`, `word_instances`, `grammar_features`, `phrases`, `lexicon_relations`, `phrase_word_instances`) | **Confirmed, unchanged.** All 8 tables, 0 rows. |
| Search FTS5 engine not wired to Search UI | `RELEASE_PLAN_V1.md` §2 Critical, dashboard §3 Critical | Same DB file: `search_index_content` (an FTS5 shadow table) holds **43,652 rows** — real, populated index, not a placeholder. `lib/features/search/data/search_providers.dart` and `search_screen.dart` both reference the search index at the code level. | **STALE — this blocker is actually resolved.** Shipped in Phase 3 Sprint R1 (commit `0f3f751`, "feat(search): integrate FTS5 search and complete search UX states"). Neither `RELEASE_PLAN_V1.md` nor the dashboard's §3 Critical list was updated to reflect it — the dashboard's own R2-completion note already flagged this exact gap in passing ("this table's percentages predate... Sprint R1") but didn't go back and edit §3's Critical bullet itself. Corrected in §3 below. |
| Web platform broken (`sqlite3.wasm`/`drift_worker.js` missing) | `RELEASE_PLAN_V1.md` §2 | Listed `web/` — contains `favicon.png`, `icons/`, `index.html`, `manifest.json`. Neither file present. | **Confirmed, unchanged.** |
| D5's 5 files are genuinely dead (unused) | `UPDATED_TECHNICAL_DEBT.md` D5 | Grepped every `lib/` file for real imports of each (not just doc-comment mentions) of `app_env.dart`, `snapshot_section.dart`, `simple_markdown.dart`, `io_cache_manager.dart`, `cache_manager.dart`. Found one hit for `io_cache_manager.dart` — a doc **comment** in `console_logger.dart` ("cùng mẫu Downloader ở core/cache/io_cache_manager.dart"), not an import. `cache_manager.dart`'s only reference is `io_cache_manager.dart` itself (the pair's own internal relationship, not external wiring). | **Confirmed, unchanged.** Zero real external usage for any of the 5 files. |
| D8 — soft-delete filter duplicated 20+ sites, 9 repository files | `UPDATED_TECHNICAL_DEBT.md` D8 | Grepped every `*_repository_impl.dart` for the actual pattern (`t.deletedAt.isNull()`): **23 call sites across 7 files** (`flashcard`, `khatm_cycle`, `scheduler`, `bookmark_collection`, `quiz`, `user_content`, `study_session`). 9 repository files exist total; the other 2 (`lexicon_repository_impl.dart`, and every repository outside the 9 base `_repository_impl.dart` files that only *compose* the base ones — `ai_tutor`, `analytics`, `learning_journey`, `smart_learning`, `read_model`) never touch `SyncColumns` tables directly, so they correctly have zero sites. The upsert-toggle idiom (`deletedAt: Value(existing.deletedAt == null ? now : null)`) — the "~5 for the upsert recipe" claim — was found verbatim 3× in `user_content_repository_impl.dart` alone; likely more elsewhere under slightly different local variable names, not yet exhaustively enumerated (see R3 Design Review, Scope). | **Confirmed, right order of magnitude, more precise now** (23 sites / 7 files, not just "20+ / 9"). |
| `pubspec.yaml` still `0.8.1+7` | Both docs | `grep "^version:" pubspec.yaml` | **Confirmed, unchanged.** |
| `DR-2026-0002` still missing | `RELEASE_PLAN_V1.md` §3 | Listed `docs/adr/`: `DR-2026-0001`, `0003`, `0004`, `0005`, `0014` exist; `0002` does not. | **Confirmed, unchanged.** |
| 16 outdated packages, 2 major-version gaps | Both docs | `flutter pub outdated` | **Confirmed, unchanged** — `flutter_riverpod`/`riverpod` 2.6.1→3.4.2, `sqlite3` 3.3.4→3.5.0 (EOL-flagged variant elsewhere), several more transitive packages behind. |
| Accessibility audit, Android performance measurement, store/legal readiness | Both docs | Not independently re-verifiable from the repository — these require a physical device, screen reader, and business/legal action respectively, none of which this review has access to. | **Not re-verified beyond what the source docs already state; taken as still-accurate since nothing in the repo could confirm or refute them either way.** |

**One correction is made to the blocker list as a result: Search FTS5
wiring is removed from Critical.** No other blocker status changes.

## 3. Remaining blockers (corrected)

### Critical

- **Lexicon tables empty (0 rows) in the shipped database asset.**
  Re-confirmed live (§2). Blocks Lexicon and, transitively, Flashcards
  (F2 depends on Lexicon) from working on a real install. Data-sourcing
  is unscoped — no document specifies where real lemma/word-instance
  data comes from. **Not Sprint-R3-shaped**: this needs a human
  decision about a data source/pipeline before any engineering task
  can be scoped, let alone executed inside one planning-to-implementation
  cycle.
- **Store & legal readiness unstarted.** Icons, screenshots, privacy
  policy, Tanzil translation license review, platform certificates.
  Process/business work, not engineering — cannot be a code sprint.

~~Search: FTS5 engine not wired~~ — **removed, resolved in Phase 3
Sprint R1** (§2).

### High

- **Web platform is broken** (missing WASM/worker files) and
  undecided — ship it or explicitly defer. Re-confirmed (§2). The "fix"
  branch of this decision has unscoped effort similar in shape to the
  Lexicon risk (setting up `sqlite3.wasm` + a Dart web worker for Drift
  is a platform-integration problem, not a contained refactor); the
  "defer" branch is a documentation-only decision. Genuinely a decision
  item, not an implementation sprint, until the decision is made.
- **No real accessibility audit** (screen readers), **`PERFORMANCE.md`
  Android column unmeasured** on real hardware. Requires physical
  device + screen reader access this environment cannot provide.
- **Coverage gate mismatch**: CI enforces 70%, target is 80%, not
  re-measured since F1–F8 landed.
- **16 outdated packages**, 2 major-version-behind + 1 EOL-flagged.
  Re-confirmed (§2). `CLAUDE.md` explicitly flags major-version bumps
  as "stop and ask before" — not a unilaterally-executable sprint
  either.

### Medium

- **D8 — duplicated soft-delete filter / upsert pattern**, re-confirmed
  at **23 sites across 7 of 9 repository files** (§2), plus at least
  one repeated upsert-toggle idiom. `RELEASE_PLAN_V1.md`'s own
  recommendation: an isolated sprint with full regression re-runs, not
  bundled with smaller cleanups.
- **D6, remainder** — a second empty-state shape duplicated 5×, and
  the `_JourneyEntryCard`/`_SmartLearningEntryCard` pair. Deferred
  pending visual-regression tooling this environment doesn't have —
  unchanged, still blocked on the same missing tooling.
- **D5 — 4 dead files** (5 physical files, one item is a pair),
  re-confirmed genuinely unused (§2). Each needs its own "wire in or
  delete" call — `io_cache_manager.dart` matches a live `TODO.md` item,
  so "delete" isn't safe there either; not a cohesive single-sprint
  refactor, more four independent micro-decisions.
- **`pubspec.yaml` version never bumped.** Re-confirmed (§2). Trivial
  but premature before more blockers close — bumping now would imply
  a release readiness that isn't real yet.
- **Background audio playback missing**, **audio cache management has
  no UI**. Both are new-feature-shaped work (a real UI, real
  `audio_service` platform wiring), not debt-closure — arguably outside
  what "Sprint R3: verification & debt closure" should mean; closer to
  v1.1 feature scope per `PRODUCT_ROADMAP.md`.

### Low

- D10–D14 (P2 — feature-coupling smells, minor perf nits, unused
  route-constant identifiers, eager audio-player construction,
  type-level layer-skipping). Explicitly out of scope for any Critical/
  High-focused sprint to date; still valid, still low priority.
- Missing `DR-2026-0002` file. Re-confirmed (§2).
- Search polish (Recent Searches, Suggestions, Filters) — correctly
  scoped to v1.1, not a v1.0 gap.
- Hifz mode, "Nhật ký" — v2.0 candidates, not concretely specified.

## 4. Sprint R3 selection

**Recommendation: Sprint R3 = D8, the soft-delete filter and upsert
pattern refactor across the 7 affected repository implementations.**

### Why not the other candidates

- **Lexicon data / Store & legal (Critical)**: both require a decision
  or input only a human can provide (a data source, a legal review, a
  set of store assets) before any engineering work can even be scoped.
  Neither can become a self-contained "plan → implement → verify"
  engineering sprint today. Flagging them as the two genuinely
  highest-priority open items is not the same as being able to execute
  them as Sprint R3 — being honest about that distinction matters more
  here than picking the technically-highest-priority item just because
  it's Critical-tier.
- **Web platform decision (High)**: same shape as Lexicon — the "ship
  it" branch is unscoped platform-integration effort with no source
  document estimating it; the "defer it" branch is a five-minute
  documentation edit, not a sprint. Doesn't fit "engineering sprint"
  either way until the decision itself is made (by you, not by this
  review).
- **Accessibility audit / Android performance (High)**: requires
  physical device and screen-reader access this environment does not
  have. Not executable here regardless of priority.
- **Coverage gate / 16 outdated packages (High)**: `RELEASE_DASHBOARD.md`
  §6 already flags major dependency bumps as carrying real regression
  risk specific to this codebase — "S2's own D9 fix uncovered a genuine
  `.autoDispose` provider-lifecycle bug class" — and `CLAUDE.md` lists
  major-version bumps under "stop and ask before." This fails the
  task's own "lowest architectural risk" criterion outright; it is
  also explicitly sequenced *after* Lexicon/Search in every existing
  plan (`RELEASE_DASHBOARD.md`'s own R3, which is a different sprint
  numbering than this Phase 3 R3 — see §6 below for the naming
  collision this causes).
- **D5 (Medium)**: small, but not one cohesive sprint — four
  independent micro-decisions, two of which (`io_cache_manager.dart`
  pair) already have a documented complication (`TODO.md` live item)
  that makes even "delete" unsafe without a separate decision first.
  Lower ROI per unit of planning effort than D8.
- **D6 remainder (Medium)**: explicitly blocked on visual-regression
  tooling this environment doesn't have — not executable here either.
- **Background audio / audio cache UI (Medium)**: new-feature-shaped,
  not debt-closure; doesn't fit a "verification & debt closure"-style
  sprint, and duplicates none of the analysis already done for D8.

### Why D8 has the highest ROI, lowest architectural risk, and best dependency order

- **Highest ROI of the executable candidates**: 23 confirmed call
  sites across 7 files collapse to (at minimum) one shared filter
  helper and one shared upsert-toggle helper — every future bug in
  "what counts as not-deleted" or "how a soft-delete toggle is
  written" gets fixed in one place instead of needing to be re-fixed
  23 times. This is exactly the kind of debt that compounds silently
  (a 24th call site added carelessly next feature is the realistic
  failure mode being prevented).
- **Lowest architectural risk of any remaining item**: D8 lives
  entirely inside the repository-implementation layer, below the
  provider layer and far below the UI. It touches zero widgets, zero
  providers, zero routes, zero l10n strings, zero database schema (the
  `SyncColumns` mixin and its `deletedAt` column are unchanged — only
  the *query expression* that reads them is being consolidated). This
  is the only remaining candidate with **zero UI-facing surface area**,
  which is exactly why several sections of the Design Review below
  (Accessibility, Localization) are close to trivially "not applicable"
  — not skipped, genuinely inapplicable, and that in itself is a risk
  signal worth reading positively.
- **Best dependency order**: D8 depends on nothing else in the
  remaining blocker list, and nothing else depends on it. It doesn't
  need Lexicon data, doesn't need the Web platform decision, doesn't
  need a real device, doesn't need a dependency upgrade. It can start
  immediately and finish without being blocked mid-sprint by an
  external decision — unlike every Critical/High item above.
- **Already pre-designated as sprint-shaped** by this project's own
  planning: both `RELEASE_PLAN_V1.md` and `UPDATED_TECHNICAL_DEBT.md`
  independently describe D8 as needing "its own dedicated sprint with
  full regression-test re-runs, not bundled with smaller cleanups" —
  this review is not inventing a new priority, it's executing a
  decision this project already made and had been correctly deferring
  until a sprint was free to take it on.
- **Fully within what this kind of engagement can actually execute**:
  every call site is enumerable by grep, the refactor is mechanically
  verifiable (extract, then diff-check behavior against the existing —
  already extensive — repository test suite), and "done" has an
  unambiguous, testable definition. This is the one remaining item
  where "plan it, then implement it, then verify it" is a complete,
  closeable loop without an external dependency.

## 5. Are Sprint R1 or R2's assumptions still valid?

Checked each explicit assumption recorded in this engagement's own R1/R2
planning and design-review documents against current reality:

- **R1's assumption that Search wiring was "scoped and mechanical" by
  comparison to Lexicon's unscoped data problem** — confirmed correct
  in hindsight: it shipped cleanly in one sprint, no scope surprises.
- **R1's assumption that Lexicon data-sourcing is unscoped and
  high-uncertainty** — still true, unchanged; no data has landed since.
- **R2's assumption ("a Read Model UI decision is easier to make once
  R1's Search work clarifies what the v1.0 discovery surface actually
  looks like")** — in practice this didn't end up mattering: the Read
  Model UI decision was made and executed independently of Search's
  specific implementation, reusing the existing `SmartLearningSession`
  chain regardless of how Search turned out. Not wrong, just a
  dependency that turned out to be soft rather than binding — worth
  noting so a future planning pass doesn't over-weight soft
  dependencies like this one when sequencing.
- **R2's own doc comment** ("no entry-point CTA from `SmartLearningScreen`
  yet") — still accurate, unchanged since Sprint R2.3.
- **No new technical debt was introduced by R1 or R2.** Both sprints
  went through an explicit final review (R1's own final review, and
  the "R2 Final Review" pass in this conversation) that found zero
  dead code, zero duplication, zero provider misuse, zero architecture
  violations. D8's scope (§2) is unaffected by anything R1/R2 touched —
  neither sprint modified any of the 7 repository files D8 targets.
- **No assumption from R1 or R2 blocks or conflicts with D8.** The two
  sprints operated entirely in the UI/provider layers (`search/`,
  `read_model/presentation/`); D8 operates entirely in the
  data/repository layer of unrelated features (`flashcards/`,
  `khatm/`, `learning/`, `library/`, `quiz/`, `quran/`, `stats/`). No
  shared files, no shared providers, no ordering dependency either
  direction.

**Conclusion: no R1/R2 assumption needs revision, and none constrains
or is threatened by taking on D8 next.**

## 6. Architectural direction check

Verified D8, as scoped, does not violate any direction established in
prior sprints:

- **"Do not access repositories directly from UI"** — not implicated;
  D8 never touches UI. ✓
- **5-layer AI composition chain / "optimize within one call, not
  across calls"** (the rule governing `ai_tutor` → `learning_journey`
  → `smart_learning` → `read_model`) — not implicated; the 7 files D8
  touches are all *base* Drift-backed repositories, entirely outside
  that composition chain. ✓
- **Reliability layer as the single repository-boundary choke point**
  (`withFailureLogging`/`withFailureLoggingStream`, Sprint 19) — this
  is the one place D8 must actively respect rather than simply avoid:
  every method in the 7 target files is already wrapped in
  `withFailureLogging(...)`. D8's extraction must sit *inside* that
  wrapping (extract the query-building expression, leave the
  surrounding `withFailureLogging` call untouched at every site) — see
  the Design Review's Architecture Impact section for the specific
  constraint this implies. ✓, with an explicit constraint carried
  into the Design Review.
- **"Every new feature ships tests in the same change"** — D8 is not a
  new feature; the applicable standard (matching D7's own precedent
  from S2) is behavior-preservation verified by the existing test
  suite passing unmodified, plus new dedicated tests for the extracted
  helpers themselves. ✓, addressed in the Design Review's Test
  Strategy.
- **Database schema stability** (`PROJ-P-002`, `CLAUDE.md`'s "stop and
  ask before any schema change") — D8 does not touch the schema. The
  `SyncColumns` mixin, its `deletedAt` column, and every table
  definition in `user_tables.dart` are unchanged; only the Dart-level
  query *expressions* that read/write that column are being
  consolidated. ✓

**One naming note, not a conflict**: `RELEASE_DASHBOARD.md` §4 has its
own "R1 through R5" sprint plan, and its "R3" (Verification & Quality
Gate — accessibility, performance, coverage, package upgrades) is a
**different sprint from this document's "Phase 3 Sprint R3"** (this
conversation's own numbering, which so far has covered: R1 = Search,
R2 = Read Model UI). The two numbering schemes have now diverged
enough to be worth flagging explicitly so a future reader doesn't
conflate "the dashboard's R3" with "Phase 3's R3" — they are not the
same sprint and don't have to happen in the same order relative to
each other's numbering.

---

Full technical design: `docs/release/PHASE3_SPRINT_R3_DESIGN_REVIEW.md`.

Do NOT implement. Do NOT refactor. Do NOT change any file except
creating this planning document and the paired design review.

READY FOR R3 DESIGN REVIEW
