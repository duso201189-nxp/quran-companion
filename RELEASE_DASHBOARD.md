# Release Dashboard — Qur'an Companion v1.0

Synthesized from, and only from, the five documents named for this
task: [`docs/release/PRODUCT_ROADMAP.md`](docs/release/PRODUCT_ROADMAP.md),
[`docs/release/RELEASE_PLAN_V1.md`](docs/release/RELEASE_PLAN_V1.md),
[`docs/architecture/MASTER_ARCHITECTURE.md`](docs/architecture/MASTER_ARCHITECTURE.md),
[`docs/release/UPDATED_TECHNICAL_DEBT.md`](docs/release/UPDATED_TECHNICAL_DEBT.md),
[`PROJECT_INDEX.md`](PROJECT_INDEX.md). No code was read or run to
produce this document beyond the version string in `pubspec.yaml`
(`0.8.1+7`, unchanged) and current git branch/working-tree state,
checked only to keep this dashboard from citing a stale number.

No code was modified to produce this document.

---

## 1. Overall release progress

There is no single authoritative "% done" number in any source
document — this section builds one transparently, from the status
data those documents already contain, rather than asserting a bare
figure. Four categories, weighted by how directly each gates a v1.0
ship decision:

| Category | Score | Weight | Basis |
|---|--:|--:|---|
| Product feature completeness | 90% | 30% | `PRODUCT_ROADMAP.md`: "nearly all of the original v1.5 feature scope is already built" — reading, audio, bookmarks, search UI, full learning engine, 5-layer AI-adjacent chain. Open: Search engine wiring, Read Model UI decision. |
| Technical debt closure (P0+P1) | 63% | 20% | `UPDATED_TECHNICAL_DEBT.md` summary table: P0 2/2 fixed (100%), P1 2/6 fixed + 2/6 partial + 2/6 not actioned → 50%. Weighted by item count (2 P0 + 6 P1 = 8 items): 63%. P2 (5 items, explicitly out of scope) excluded from this score. |
| Documentation & planning foundation | 100% | 15% | Product Foundation (8 documents) + Phase 2.1 (integration, `PROJECT_INDEX.md`, `CONTRIBUTING.md`, `ARCHITECTURE_DECISIONS.md`) + this dashboard — all complete. |
| v1.0-specific release blockers closed | 10% | 35% | `RELEASE_PLAN_V1.md` §2's four blocker groups (Store & legal; Platform completeness; Verification gaps; Known engineering gaps) — none closed yet. The only movement is the documentation-debt sub-item from §0 (ROADMAP/TODO/CHANGELOG/CLAUDE reconciled in Phase 2.1); `pubspec.yaml`'s version itself is still unbumped. |

**Overall: ≈ 58%.**

Read this as: *the product is substantially built, but v1.0 is not
close to shippable* — the largest weight sits on the category with
the least progress, which is the accurate picture per `RELEASE_PLAN_V1.md`
(no blocker group has been actioned by any sprint to date; S1/S2 and
the documentation phases addressed code quality and knowledge capture,
not the release-blocking gaps themselves).

---

## 2. Completed work

### P1–P4 — Reliability & schema foundation (mega-commit decomposition, PR #3–#12)

- **P1** — Reliability layer: `AppFailure`/`FailureCategory`/`FailureSeverity`,
  `Logger`/`CrashReporter` interfaces, `ConsoleLogger`/`NoopCrashReporter`,
  `withFailureLogging`/`withFailureLoggingStream` as the single
  Repository-boundary error-handling choke point (PR #3).
- **P2** — Shared accessible widgets: `EmptyStateBanner`, `LoadingState`,
  `SectionHeader`, `StatCard` (PR #5).
- **P3** — Schema groundwork: `UserDatabase` schemaVersion 3→6
  (generalized `srs_cards`, `quiz_results`, `flashcard_decks`,
  `flashcards`); 8 new Lexicon tables in `AppDatabase` (PR #11).
- **P4** — Reliability layer applied across all 9 existing repositories
  (PR #12).

### F1–F8 — Feature build-out (PR #13–#18)

- **F1 — Lexicon**: domain/repository read layer for Root/Lemma/Lexeme/
  WordInstance/GrammarFeature/Phrase/LexiconRelation (PR #13).
- **F2 — Flashcards**: Smart Deck browse/add/remove/merge, wired to the
  Scheduler via the provider layer (PR #13).
- **F3 — Analytics**: stats, history, insights, goals, achievements —
  pure aggregation over 4 leaf repositories, no dedicated storage
  (PR #13).
- **F4 — AI Tutor**: rule-based suggestions/insights over Analytics —
  no real AI/LLM call (PR #14).
- **F5 — Learning Journey**: daily study plan, aggregated from AI Tutor
  (PR #15).
- **F6 — Smart Learning**: study-strategy ranking, aggregated from
  Learning Journey (PR #16).
- **F7 — Read Model**: immutable `LearningSnapshot` aggregating the
  full 5-layer chain — built, no screen consumes it yet (PR #17).
- **F8 — Learning Session**: unified Review/Quiz/Flashcard into one
  session flow, one route (PR #18).

Full test suite: 375 → 767 across this decomposition, all passing at
PR #19 merge.

### S1 — Audit (pre-PR #19)

Comprehensive audit (`docs/reports/release-recovery/PROJECT_AUDIT_REPORT.md`)
of all 12 merged groups, producing the prioritized technical-debt
register (D1–D14) that S2 and this dashboard both build on.

### S2 — Quality & Polish (PR #19)

Fixed both P0 items and 2 of 6 P1 items from the S1 register:
`learning_session` error handling + `retry()` (D1), `CrashReporter`
wired into `ConsoleLogger` (D2), dead-provider removal + duplicate
widget consolidation (D4/D6 partial), shared quiz option-shuffling
helper (D7), 4 new test files closing coverage gaps (D9). 22 new
tests. Full detail: `docs/release/UPDATED_TECHNICAL_DEBT.md`.

### Product Foundation (+ Phase 2.1 Documentation Integration)

Eight architectural reference documents generated
(`MASTER_ARCHITECTURE.md`, `MODULE_CATALOG.md`, `DATABASE_REFERENCE.md`,
`PROVIDER_MAP.md`, `DATA_FLOW.md`, `TESTING_GUIDE.md`,
`RELEASE_PLAN_V1.md`, `PRODUCT_ROADMAP.md`), then integrated into a
navigable `docs/` structure with `PROJECT_INDEX.md` as the entry
point, `ARCHITECTURE_DECISIONS.md` and `CONTRIBUTING.md` added, and
`README.md`/`ROADMAP.md`/`TODO.md`/`CHANGELOG.md`/`CLAUDE.md`
reconciled (historical content preserved, current status pointers
added, no silent rewrites). This closes the documentation-debt item
`RELEASE_PLAN_V1.md` §0 originally flagged — the one piece of
movement reflected in the "v1.0-specific blockers" score above.

---

## 3. Remaining blockers

### Critical

- **Lexicon tables empty (0 rows) in the shipped database asset.**
  Schema exists (8 tables, F1/P3); no data ships. Blocks the Lexicon
  feature and, transitively, Flashcards (F2 depends on Lexicon) from
  working on a real install — tests pass because they don't exercise
  the shipped asset. Flagged in `RELEASE_PLAN_V1.md` as likely the
  single highest-priority blocker for v1.0.
- **Search: FTS5 engine not wired to the Search UI.** The UI (4
  states, navigation) shipped in Sprint 7.1; the full-text engine is
  built but not connected. This is the one gap a user would notice
  immediately — a Search screen that doesn't search.
- **Store & legal readiness unstarted per `RELEASE_PLAN_V1.md`**:
  icons, screenshots, privacy policy, legal review of the Tanzil
  translation license, platform certificates. Process work, not
  engineering, but a hard submission gate — status of each item is
  not otherwise tracked in the five source documents for this
  dashboard.

### High

- **Read Model (D3) has no product decision.** `LearningSnapshotRepository`
  is fully built and fully unreachable — needs a call: give it a UI
  (natural fit: a "smart study summary" screen) or explicitly scope it
  out of v1.0. Not an engineering blocker by itself, but leaving it
  undecided blocks anyone from planning around it.
  ([`docs/release/UPDATED_TECHNICAL_DEBT.md`](docs/release/UPDATED_TECHNICAL_DEBT.md) D3)
- **Web platform is broken** (missing WASM/worker files for the
  database layer) and undecided — ship it or explicitly defer.
- **No real accessibility audit** has been performed (screen readers);
  `PERFORMANCE.md`'s Android column is unmeasured on a real mid-range
  device; automated tests (767) verify logic, not an actual QA pass.
- **Coverage gate mismatch**: CI enforces 70%; the project's own
  stated target is 80%, not yet re-measured since F1–F8 landed with
  their own strong coverage.
- **16 outdated packages**, including 2 major-version-behind
  (`flutter_riverpod`, `go_router`) and one EOL-flagged SQLite
  package — each requires its own regression pass; `CLAUDE.md` flags
  major-version bumps as a "stop and ask before" item.

### Medium

- **D8 — duplicated soft-delete filter / upsert pattern**, 20+ sites
  across 9 repository files. `RELEASE_PLAN_V1.md`'s own recommendation
  is that this get an isolated sprint with full regression re-runs,
  not be bundled with smaller cleanups — correctly deferred so far,
  not yet scheduled.
- **D6, remainder** — a second, undocumented empty-state shape
  duplicated 5 times, and the `_JourneyEntryCard`/`_SmartLearningEntryCard`
  pair; deferred pending visual-regression tooling this environment
  doesn't have.
- **D5 — 4 dead files** (`app_env.dart`, `snapshot_section.dart`,
  `simple_markdown.dart`, `io_cache_manager.dart`+`cache_manager.dart`)
  each need an explicit wire-in-or-delete call; none is safe to
  action unilaterally under a "preserve behavior" constraint.
- **`pubspec.yaml` version never bumped** — still `0.8.1+7` despite
  12 PRs and two quality sprints having shipped since.
- **Background audio playback missing** (`AudioController` is
  foreground-only) and **audio cache management has no UI** — both
  real, user-visible gaps independent of the F1–F8 feature work.

### Low

- **D10–D14** (P2, `UPDATED_TECHNICAL_DEBT.md`): feature-coupling
  smells, minor perf nits, unused route-constant identifiers, eager
  audio-player construction, type-level layer-skipping in entity
  imports. Explicitly out of S2 scope, still valid, still low
  priority.
- **Missing `DR-2026-0002` file** — referenced elsewhere but never
  written as its own record.
- **Search polish** (Recent Searches, Suggestions, Filters) — UI
  scaffolding exists, no logic behind it yet; correctly scoped to
  v1.1 in `PRODUCT_ROADMAP.md`, not v1.0.
- **Hifz mode, "Nhật ký"** — named as future directions, never
  concretely specified; v2.0 candidates per `PRODUCT_ROADMAP.md`, not
  a v1.0 gap.

---

## 4. Sprint plan — R1 through R5 (v1.0 completion path)

### R1 — Content & Search Foundation

- **Objective**: close the two "feature exists, doesn't work on a
  real install" gaps before anything else, since both are prerequisites
  for meaningful verification work later.
- **Deliverables**: populated Lexicon database asset (8 tables, real
  lemma/word_instance data); FTS5 search engine wired into the
  existing Search UI; migration + regression tests for both.
- **Dependencies**: none — can start immediately.
- **Estimated complexity**: High. The Lexicon gap is a data-sourcing
  and pipeline problem, not a code problem — effort depends on where
  the lemma/word-instance data comes from, which no source document
  specifies. Search wiring is scoped and mechanical by comparison.

### R2 — Scope Decisions & Debt Closure

- **Objective**: resolve the two open product/engineering decisions
  and take on the one P1 debt item large enough to need its own
  isolated pass.
- **Deliverables**: Read Model UI shipped, or an explicit, documented
  v1.1 deferral (D3 closed either way); Web platform go/no-go
  decision recorded; D8 soft-delete/upsert refactor across all 9
  repository files with full regression re-run; D5's 4 dead files
  each resolved (wired in or removed).
- **Dependencies**: none hard-blocking, but a Read Model UI decision
  is easier to make once R1's Search work clarifies what the v1.0
  discovery surface actually looks like.
- **Estimated complexity**: Medium-High. The decisions themselves are
  cheap; D8's refactor touches 20+ call sites and needs the full test
  suite green after, not just the touched files.

### R3 — Verification & Quality Gate

- **Objective**: replace "tests pass" with real evidence the app
  works for real users on real hardware.
- **Deliverables**: accessibility audit (screen reader pass, at least
  one platform); `PERFORMANCE.md`'s Android column measured on an
  actual mid-range device; coverage gate raised from 70% toward 80%
  with any newly-exposed gaps closed; the 16 outdated packages
  upgraded (2 major-version bumps + EOL SQLite package replacement),
  each with its own regression pass.
- **Dependencies**: R1 — verifying performance/accessibility against
  features about to change (Search, Lexicon) wastes the measurement.
- **Estimated complexity**: Medium. Mostly measurement and incremental
  fixes, but major dependency bumps carry real regression risk in a
  codebase where `.autoDispose` provider chains have already shown
  fragility once (S2's D9 fix).

### R4 — Store Readiness

- **Objective**: everything required to actually submit to app
  stores.
- **Deliverables**: icons, screenshots (final UI, so best done after
  R1–R3), privacy policy, Tanzil translation license legal review,
  platform signing certificates verified end-to-end, full
  `RELEASE_CHECKLIST.md` walkthrough and sign-off.
- **Dependencies**: R1–R3 substantially complete — screenshots need
  final UI, legal review should cover the actual shipped feature set.
  Exception: the legal review itself has external lead time and
  should be *started* in parallel with R1, not queued behind it.
- **Estimated complexity**: Medium. Mostly process and asset work, but
  legal/licensing review is outside engineering's direct control and
  is the one item here that can silently become the critical path if
  not started early.

### R5 — Release Candidate & Launch

- **Objective**: cut, verify, and ship the v1.0 release candidate.
- **Deliverables**: `pubspec.yaml` version bump, final `CHANGELOG.md`
  entry replacing the `[Unreleased]` backfill, tagged release build,
  store submission, dashboard closeout.
- **Dependencies**: R1–R4 all complete.
- **Estimated complexity**: Low-Medium — mechanical if everything
  upstream genuinely closed; the risk here is entirely inherited from
  earlier sprints slipping, not new risk of its own.

v1.1 work (D6 remainder, background audio, audio cache UI, Search
polish, dependency-driven follow-ups) begins after R5, per
`PRODUCT_ROADMAP.md` — deliberately excluded from R1–R5 to keep this
sprint plan focused on what actually gates v1.0.

---

## 5. Definition of Done — v1.0

A release candidate is v1.0-ready only when all of the following hold:

1. Lexicon database asset ships with real data in all 8 tables;
   Flashcards work end-to-end on a fresh install.
2. Search UI is backed by the real FTS5 engine — no placeholder
   results.
3. Read Model has either a shipped UI or a documented, explicit
   decision that it's v1.1+ infrastructure.
4. Web platform is either functional or explicitly excluded from the
   v1.0 release scope (not silently broken).
5. An accessibility audit has been performed and its Critical/High
   findings closed.
6. `PERFORMANCE.md`'s Android measurements reflect a real mid-range
   device, not an unmeasured placeholder.
7. CI coverage gate and actual measured coverage are reconciled (gate
   reflects reality, whatever that number turns out to be).
8. No dependency is both major-version-behind and load-bearing for a
   security-relevant path; the EOL SQLite package is replaced.
9. `RELEASE_CHECKLIST.md` fully walked: icons, screenshots, privacy
   policy, legal review of translation licensing, signing certificates
   all verified, not assumed.
10. `pubspec.yaml` version bumped to reflect the actual shipped
    feature set; `CHANGELOG.md`'s `[Unreleased]` backfill closed into
    a dated release entry.
11. Standing project gate unchanged and still enforced: `dart format`,
    `flutter analyze --fatal-infos`, `flutter test --coverage` all
    clean (`CLAUDE.md`'s definition of done for any change, which a
    release is not exempt from).
12. No P0 technical debt open (currently true — both P0 items are
    fixed; this is a hold-the-line condition, not new work).

---

## 6. Risks

- **Lexicon data sourcing is unscoped.** No source document specifies
  where real lemma/word-instance data comes from or how much effort
  populating 8 tables actually takes — this is the single largest
  unknown in the entire v1.0 path, and it sits on the critical path
  (R1, blocking Flashcards).
- **Major dependency version bumps** (`flutter_riverpod`, `go_router`)
  carry real regression risk specifically in this codebase: S2's own
  D9 fix uncovered a genuine `.autoDispose` provider-lifecycle bug
  class, meaning Riverpod upgrade testing needs to be deliberate, not
  perfunctory.
- **Legal/licensing risk is binary, not gradable.** If the Tanzil
  translation license review surfaces a real blocker, it doesn't
  slow v1.0 down — it can force a translation-source change late in
  the process. This is the one risk worth de-risking earliest (start
  the review now, in parallel with R1).
- **Single-person team** (per `PROJECT_INDEX.md`'s pointer to
  `ROLES.md`: all six governance roles currently held by one person).
  Every sprint above is sequential capacity on one person, not
  parallelizable across a team — the R1–R5 plan's dependencies matter
  more here than they would with more contributors.
- **Coverage-gate honesty risk.** Raising the gate toward 80% (R3)
  may surface that some of the 767 passing tests cover less real
  behavior than the count implies — treat any gap found as a genuine
  finding, not a target to quietly lower instead.
- **Real-device access is unverified.** No source document confirms
  accessibility or performance testing has ever run on physical
  hardware rather than emulators/simulators — R3 assumes device
  access exists; if it doesn't, procuring it becomes a dependency of
  its own.

---

## 7. Go / No-Go checklist

- [ ] Lexicon database asset populated and verified on a real install
- [ ] Search returns real FTS5 results, not placeholder/empty states
- [ ] Read Model decision made and implemented (UI shipped or formally
      deferred)
- [ ] Web platform decision made and implemented (fixed or excluded)
- [ ] Accessibility audit complete, Critical/High findings closed
- [ ] Performance measured on a real mid-range Android device
- [ ] Coverage gate reconciled with actual measured coverage
- [ ] All 16 outdated packages triaged; load-bearing/EOL ones upgraded
- [ ] `RELEASE_CHECKLIST.md` fully signed off (assets, legal, signing)
- [ ] Tanzil translation license legal review returned a clear result
- [ ] `pubspec.yaml` version bumped; `CHANGELOG.md` release entry cut
- [ ] `dart format` / `flutter analyze --fatal-infos` / `flutter test
      --coverage` all clean on the release branch
- [ ] Zero open P0 technical debt (currently satisfied)
- [ ] No Critical blocker from §3 remains open

**Go** requires every box checked. Any single unchecked Critical-tier
item (§3) is an automatic **No-Go** regardless of how many other boxes
are checked — the Critical tier was chosen specifically because each
item there independently blocks a coherent v1.0 (a search that
doesn't search, a store submission with no privacy policy, a
flashcard feature with no data, are each disqualifying alone).

---

## 8. Recommended release order

1. **Start the Tanzil legal review now**, in parallel with everything
   else — it's the one item with external lead time and binary risk
   (§6).
2. **R1** (Lexicon data + Search wiring) — highest-uncertainty,
   highest-leverage work; start immediately, don't let it drift to
   the end where its unscoped effort becomes a launch-date surprise.
3. **R2** (scope decisions + D8/D5 debt) — can overlap with the tail
   of R1; the Read Model and Web decisions don't require R1 to be
   finished, only informed by it.
4. **R3** (verification) — strictly after R1, since measuring
   performance/accessibility against features about to change wastes
   the work.
5. **R4** (store readiness) — screenshots and final checklist walk
   after R1–R3 so they reflect the actual shipped app; legal review
   (step 1) should already be resolved or close to it by this point.
6. **R5** (release candidate + launch) — only after every Go/No-Go
   box in §7 is checked.
7. **v1.1 planning begins after v1.0 ships**, per `PRODUCT_ROADMAP.md`
   — not before, and not by quietly absorbing v1.1-scoped items
   (Search polish, background audio, D6 remainder) into the v1.0 path
   under schedule pressure.

---

RELEASE DASHBOARD COMPLETE
