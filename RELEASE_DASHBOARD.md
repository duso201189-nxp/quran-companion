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
| Product feature completeness | 90% | 30% | `PRODUCT_ROADMAP.md`: "nearly all of the original v1.5 feature scope is already built" — reading, audio, bookmarks, search UI, full learning engine, 5-layer AI-adjacent chain. Read Model UI decision now closed (Phase 3 Sprint R2, see §2) — this score/list was not otherwise recalculated as part of that update; see note at end of §1. |
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

> **Note (post-Phase-3 R2 update)**: this table's percentages predate
> Phase 3 Sprint R1 (Search FTS5 wiring, shipped) and Sprint R2 (Read
> Model UI, shipped, see §2) — both closed real items this table still
> scores as open/unclosed. The individual facts affected by R2 were
> corrected in §2/§3/§4/§7 as part of this update; the numeric score
> itself was deliberately **not** recalculated here (that requires
> re-deriving the full weighted model this dashboard's original task
> built, which is out of scope for a single-sprint completion update)
> — treat 58%/10% as understating actual progress until a full
> dashboard refresh is run.
>
> **Note (post-Phase-3 R3b update, 2026-08-03)**: also predates Sprint
> R3a (Web platform, shipped) and Sprint R3b (Honest Surface Area,
> shipped — see §2). This table's weighted model is still **not**
> recalculated here for the same reason as above. An independently
> derived, axis-based readiness estimate (not this table's model) is
> maintained in `docs/release/PRODUCT_READINESS_REVIEW.md` and updated
> post-R3b in `docs/release/PHASE3_EPIC_CLOSEOUT_REPORT.md` — consult
> those for current numbers; treat this table as directional only.

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

### Phase 3 — Sprint R1 (Search FTS5 Integration)

Three sub-sprints, commit `0f3f751` ("feat(search): integrate FTS5
search and complete search UX states"), 2026-07-31. Closed the gap
`RELEASE_PLAN_V1.md` had flagged since before this dashboard existed:
Search had a built UI with no real engine behind it. **This entry was
missing from this dashboard until this close-out pass** despite being
the largest single feature shipped in Phase 3 — flagged as a
release-tracking gap in `PRODUCT_READINESS_REVIEW.md` §5, corrected
here.

- **R1.1**: wired `SearchScreen` to the existing FTS5 engine via a new,
  independent provider pair (`searchQueryProvider`/`searchResultsProvider`
  in the new `search/data/search_providers.dart`) — deliberately not
  reusing `SurahListScreen`'s `ayahSearchProvider`, to avoid coupling
  the two screens' search state. Calls `QuranRepository.searchAyahs()`
  directly and unmodified; no new repository method, no schema change.
- **R1.2**: added `SearchNoResultsState` — a query ran and matched
  nothing is now visually and semantically distinct from "haven't
  typed enough yet" (`SearchEmptyState`) and "something broke"
  (`SearchErrorState`). 2 new l10n keys.
- **R1.3**: verification pass — five of six reviewed areas (rapid
  typing/debounce, clearing, loading/error/no-results transitions,
  focus) were confirmed already correct and are documented, not
  changed; one real accessibility gap was found and fixed
  (`SearchResultSection`'s result announcement was missing
  `liveRegion: true`, the one asymmetry among the four body-states).
  A direct regression test now asserts 5 rapid, un-awaited query
  changes produce exactly one repository call, for the final query
  only.

`search_index_content` (FTS5) holds 43,652 real rows, verified end-to-end
in Sprint R3a.2's browser verification pass. 786 tests passing at R1.3
close (782 + 4 new this sub-sprint). Full detail:
`docs/release/PHASE3_SPRINT_R1_PLAN.md`, `_DESIGN_REVIEW.md`,
`_1_REPORT.md` through `_3_REPORT.md`.

### Phase 3 — Sprint R3.2 (coverage measurement policy)

Test coverage was measured for the first time since F1–F8 landed, and
the CI gate reconciled against it per `DR-2026-0015`
([docs/adr/](docs/adr/DR-2026-0015-coverage-measurement-policy.md)).

**All four measured figures, disclosed in full** (`flutter test
--coverage` on `main`, 802 tests, post-Sprint-R3.1):

| Measurement | Coverage | Lines |
|---|--:|---|
| Raw — no exclusions at all | 51.96% | 8816/16968 |
| Filtered — previous CI policy (`main.dart`, `*.g.dart`, db connection stubs) | 76.25% | 6584/8635 |
| **Filtered + generated localization excluded — current policy** | **81.54%** | **6141/7531** |
| (Reference) filtered + *all* of `lib/l10n/` excluded — rejected | 81.51% | 6123/7512 |

**The change**: one lcov pattern, `lib/l10n/app_localizations_*.dart`,
added alongside the `**/*.g.dart` exclusion that already existed.
`lib/l10n/app_localizations.dart` is deliberately **kept in scope** —
it holds the real `LocalizationsDelegate` logic and is 94.7% covered.
`MIN_COVERAGE` moved 70 → 80.

**Rationale, stated plainly**: the three per-locale files are
structurally identical — 298 constant getters, 33 interpolations, one
`Intl.pluralLogic` branch each — yet scored 4.3% (ar), 46.7% (vi), and
69.3% (en). That spread measures which locale the tests happened to
run in, not how well the project is tested. Generated Drift output was
already excluded on identical grounds; this applies one rule to one
category instead of two rules.

**This raises the reported number by ~5.3 points without a single new
test being written.** That is a denominator correction, not new
coverage: every hand-written line's covered/uncovered status is
unchanged. It is disclosed here rather than asserted quietly precisely
because §6 of this document warns against the opposite. The v1.0
coverage claim must always be stated with its scope — **"80% of
hand-written product code, generated sources excluded"** — never as a
bare "80% coverage."

**One real loss, re-homed not buried**: Arabic at 4.3% was an
accidental indicator that RTL is barely exercised. Excluding these
files removes that indicator; the underlying gap is unchanged and is
now tracked explicitly under `RELEASE_PLAN_V1.md` §2 "Verification
gaps." It is **not** closed by this change.

### Phase 3 — Sprint R3a (Web Platform Completion)

Three-part sprint, 2026-08-03. **R3a.1**: vendored `web/sqlite3.wasm`
and `web/drift_worker.js`, version-matched exactly against
`pubspec.lock` (`sqlite3-3.3.4`, `drift-2.34.0` — not "latest"), with
SHA-256 provenance recorded in `docs/DATA_PIPELINE.md`.
**R3a.2**: verified in a real browser against the release build —
content and user databases open, Surah list renders, FTS5 Search
returns 40 correctly-ranked real results, a bookmark write persisted
across a full reload, storage backend confirmed as IndexedDB
(`sharedIndexedDb`), zero console errors throughout. **R3a.3**: added a
CI guard to `build-web` that fails immediately, before the Flutter SDK
install, if either vendored file is missing — closing the "CI green on
a broken platform" gap this blocker was originally filed under. Full
detail: `docs/release/PHASE3_SPRINT_R3A1_REPORT.md` through
`PHASE3_SPRINT_R3A3_REPORT.md`.

This closes the Web platform High blocker (§3) for the verified
storage tier. Not decided by this sprint: a hosting target, and
therefore whether the fastest (OPFS/COOP-COEP) tier is ever reached —
see §3 for that trade-off, deliberately left open.

### Phase 3 — Sprint R2 (Read Model UI)

`StudySummaryScreen` shipped (`lib/features/read_model/presentation/study_summary_screen.dart`,
route `/study-summary`): renders all four `LearningSnapshot` sections
(context/insights/daily plan/recommended session) by reusing existing
widgets and pure presentation functions from `ai_tutor`/
`learning_journey`/`smart_learning`, with pull-to-refresh and retry
both invalidating `smartLearningSessionProvider` (never
`learningSnapshotProvider` directly — see
[`docs/release/PHASE3_SPRINT_R2_DESIGN_REVIEW.md`](docs/release/PHASE3_SPRINT_R2_DESIGN_REVIEW.md)
"Refresh Strategy"). 799 tests passing, `flutter analyze
--fatal-infos` clean, CI green on `main`
([run 30634893231](https://github.com/duso201189-nxp/quran-companion/actions/runs/30634893231),
commit `275204b`). This closes **D3** — the Read Model no longer has
"no product decision"; the decision made was to ship a UI. Still open,
deliberately unchanged by this sprint: no entry-point CTA from
`SmartLearningScreen` yet (route exists, nothing links to it), and no
action wiring on plan steps (the screen is display-only by design this
sprint). Full detail: `docs/release/PHASE3_SPRINT_R2_1_REPORT.md`
through `PHASE3_SPRINT_R2_3_REPORT.md`.

### Phase 3 — Sprint R3b (Honest Surface Area)

Committed `e59c106`, 2026-08-03. Follows directly from
`docs/release/PRODUCT_READINESS_REVIEW.md`'s finding that the product's
code quality was not the gap to public beta — three visible UI
affordances were. Run as three sub-sprints plus a final review, each
gated on `flutter analyze --fatal-infos` / `flutter test` / `dart
format`, none committed until an explicit final-review approval:

- **R3b.1**: the "Ghi chú của tôi" (My Notes) Search scope chip was
  fully selectable but rendered a blank body when chosen — fixed by
  disabling it, matching the pattern already used for the "Hỏi AI"
  toggle. Profile's "Personal info"/"Sync" tiles had their internal
  `"Coming in Step N"` labels replaced with a generic "coming soon."
  Profile's "Goal" tile was **removed outright**, not relabeled — it
  claimed a feature (Daily Goal) that had already shipped and was
  reachable from Stats; relabeling would have swapped one false claim
  for another.
- **R3b.2**: the "Hỏi AI" toggle and the entire Search scope-chip row
  (all three chips, not just the one already disabled in R3b.1) were
  removed outright, per a design review confirming neither had any
  remaining real behavioral distinction to offer — "All" and "Qur'an"
  ran the identical query, and My Notes had no data source.
- **R3b.3**: Add Flashcard's Lemma search — the one dead-end flow found
  to be currently *reachable* (Smart Deck's "weak roots"/"verb forms"
  were reviewed and found structurally unreachable today, not fixed,
  see below) — was gated behind a real Lexicon-availability check, so
  an empty Lexicon table shows "no data yet" immediately instead of
  inviting a guaranteed-empty search that reads as "tìm xong, không có
  kết quả" (a real search that ran and failed).

**Deliberately out of scope for R3b.1–3 itself** (sequenced later in
the original plan): the `_PlaceholderChipRow` grey skeleton chips under
Search's "Recent"/"Suggestions" headings, and the 4 unused
`placeholder*` l10n keys. Both closed in a small follow-up patch — see
"Phase 3 — R3b Close-out Patch," immediately below.

Net test count at R3b.1–3 close: 802 → 793 (−9: 11 tests removed for
controls that no longer exist, 1 narrowed, 2 added — full itemization
in `docs/release/PHASE3_SPRINT_R3B_2_REPORT.md` §10 and
`_R3B_3_REPORT.md` §10). Coverage on hand-written code re-measured at
close-out: **81.52%** (was 81.54% at Sprint R3.2) — effectively
unchanged; the product code shrank in step with the tests that covered
the removed UI. Full detail: `docs/release/PHASE3_SPRINT_R3B_PLAN.md`,
`_DESIGN_REVIEW.md`, `_1_REPORT.md` through `_3_REPORT.md`, and
`_FINAL_REVIEW.md`.

### Phase 3 — R3b Close-out Patch

Committed `75adf1c`, 2026-08-03. Closes the two items R3b.1–3
deliberately deferred (immediately above): `_PlaceholderChipRow` was
removed **together with** the two "Gần đây"/"Gợi ý" headings it sat
under, not on its own — removing only the grey chip shapes and leaving
a real, accessible heading pointing at empty space would have been a
*new* dishonest surface, not a fix for the old one.
`docs/release/PHASE3_SPRINT_R3B_PLAN.md`'s own original scoping for
this item already said "chips **+ heading**," matched here.
`SearchEmptyState` now shows only icon, title, and the typing-hint
subtitle.

The 4 unused `placeholder*` l10n keys were removed as scoped. Two
further keys not matching that name pattern
(`searchEmptyRecentSectionTitle`, `searchEmptySuggestedSectionTitle`)
were removed alongside them — they lost their only call site as a
direct consequence of the heading removal above, meeting the same
"zero call sites" bar this engagement's l10n cleanups have used
throughout, not a literal name match. `l10n.comingInStep` was
**not** touched — orphaned for a different reason (Sprint R3b.1, not
this patch) and out of this patch's stated scope; still open, see §3.

Net test count: 793 → 792 (−1: one test removed outright — its stated
purpose, proving `SearchNoResultsState` lacks sections
`SearchEmptyState` no longer has either, became impossible to fail
regardless of correctness once both sections were gone from the app
entirely; two other tests kept but had assertions on the removed
widgets trimmed). `flutter analyze --fatal-infos`, `flutter test`, and
`dart format` all clean. Full detail:
`docs/release/PHASE3_R3B_CLOSEOUT_PATCH_REPORT.md`.

### Phase 4 — Sprint F0 (Qur'an Address, Surah/Āyah)

First Phase 4 foundation step, per `DR-2026-0017` and
`docs/release/PHASE4_FOUNDATION_ROADMAP.md` §6. Not a beta blocker and
not a user-visible change — it removes a defect *class*.

Before F0, one āyah's position was represented three different ways in
the same application (1-based āyah number, 0-based āyah index, 0-based
list-row index), with conversions scattered as bare `+ 1` / `- 1`.
F0 adds `QuranAddress` — an immutable, **pure-Dart** value type (no
Flutter, no Drift, no database) covering Surah and Āyah levels only —
and routes two conversion sites through it: `AyahCard`'s
playing-highlight check and `AudioBar`'s reference display. **Behaviour
is unchanged; all 792 pre-existing tests pass unmodified**, +21 new.

Also recorded: a data-integrity warning at `study_sessions.ayah_from/
ayah_to`. Those columns store 0-based indices with no column recording
their own base, and streak/study-time statistics are computed *on read*
from that table — so changing the writer to 1-based without a
`data_version` bump would silently and **unrecoverably** corrupt every
statistic. The warning now sits at the column and in
`docs/knowledge/quran_index_conventions.md`.

Deliberately excluded: Word/Segment levels, `Range`, and the edition
axis — all specified in `DR-2026-0017` but with no consumer yet
(`DR-2026-0006` D4 / `DR-2026-0007` D5 precedent), and free to add later
because **F0 persists no address anywhere**. No schema change, no data
change. Coverage 81.52% → 81.58%.

### Phase 4 — Sprint F1 (decoration layer, auto-scroll politeness)

Second Phase 4 foundation step, per `DR-2026-0019` E1 and §7.3. Two
changes, one invisible and one deliberately visible.

**Decoration layer.** The rule deciding an āyah card's background —
playing beats user highlight beats plain — lived inside a nested
ternary in `AyahCard.build()`, so verifying it meant standing up a
database, a provider container and a frame. It now lives in
`resolveAyahDecoration` (`lib/features/quran/domain/ayah_decoration.dart`),
a pure function over a `sealed` result type. Presentation still owns
appearance: the engine names a *marker*, never a colour
(`DR-2026-0019` §6.3). The `sealed` type is the point — a future
decoration source (reflection marker, AI-tutor citation, search hit)
becomes a compile error at every branch rather than a silently missed
one.

Deliberately **not** done: the literal `Map<Address, Decoration>` the
roadmap sketched. Computing that map in the parent would move the audio
subscription from per-card `select()` to per-screen, turning today's
one-card rebuild on every audio tick into a whole-list rebuild — the
performance risk `DR-2026-0019` R2 flagged, arriving as a design
regression rather than a measurement. Revisit at E5, behind a
performance gate.

**Auto-scroll politeness.** Scrolling away during playback used to be
undone by the next āyah change, once per āyah. A 10-second grace window
after any user drag now suppresses the follow (`shouldFollowPlayback`,
`lib/features/quran/domain/playback_follow_policy.dart`). It expires on
its own, so no "jump to what's playing" affordance is needed and no user
can get stuck. This is the tactical fix; the structural one — audio and
scroll each being both producer and consumer of position — is
`DR-2026-0019` E3 and remains out of scope.

**Behaviour otherwise unchanged**: all 834 tests pass, +21 new (17 pure
+ 4 widget). The 4 widget tests assert the *rendered* card colour in all
four precedence states — before F1 nothing tested that colour at all, so
the extraction would otherwise have been guarded only by argument.
Coverage 81.58% → 81.60%. No schema change, no l10n change, no new UI.

### Phase 4 — Sprint F2 (surah-opening declaration, named row layout)

The last foundation step before Basmalah 2.0. **No user-visible change
at all** — F2 only removes two ambiguities that would otherwise get in
the way.

**Al-Fātiḥah and At-Tawbah gave the same answer.**
`surahHasLeadingBasmalah` returned `false` for both — for opposite
reasons. Al-Fātiḥah *has* a Basmalah (it **is** āyah 1); At-Tawbah has
none. One `false` carrying two meanings works today and fails silently
the moment anything asks *"does this surah have an opening to play, to
highlight, to count toward progress?"* — precisely what Basmalah 2.0
asks. A three-branch `sealed SurahOpening` separates them, and
Al-Fātiḥah's branch carries a real `QuranAddress` of `1:1`. Surah
numbers 1 and 9 now appear in exactly one function.

**Five hand-written row conversions, four of which fail quietly.**
`itemCount`, `itemBuilder`, `initialScrollIndex`, `_onPositionsChanged`
and the audio follow each converted between āyah index and list-row
index by hand; none of them stated the "row 0 is the header" contract
they all assumed. When Basmalah 2.0 gives the opening its own row, a
missed `- 1` writes a reading position one āyah off to disk — no
exception, no red test. `ReadingRows` makes `leadingRows` the single
number that changes.

**Data re-verified against `quran.sqlite` rather than taken from the doc
comments**: 112 surahs carry the Basmalah as the first 4 tokens of āyah
1 (110 byte-identical, 2 spelling variants at 95/97); the shortest āyah
1 in that group has 5 tokens, so the remainder is never empty;
Al-Fātiḥah 1:1 is exactly the 4 tokens and nothing more; At-Tawbah has
none.

**851 tests** (+17), including one that checks all 114 surahs × 2 āyahs
against the verbatim pre-F2 formula — `DR-2026-0019` E2's
"byte-identical" gate stated purely instead of by rendering 114 screens.
Coverage 81.60% → 81.72%. No schema change, no data migration, no new
UI, no l10n change.

**Deliberately not done — and this is a correction to `DR-2026-0019`
E2 / `DR-2026-0017` M2 as written.** Those milestones bundle two
separable things: the *declaration* (which delivers the architectural
value) and expressing the opening's extent as a Word-level `Range`
(which needs Word Address). The second cannot deliver its headline
benefit yet: this edition stores āyah text as a string with no word
index, so `Range(s:1:1 – s:1:4)` would **relocate** the magic `4` into
whatever resolves word addresses to text offsets, not remove it.
Removing it for real requires `DR-2026-0017` M4/M5 — schema change,
`PROJ-P-002`. The `4` therefore stays exactly where it was, now with a
comment saying why. Sequencing E2 ahead of M4/M5 buys less than the ADR
implies.

---

## 3. Remaining blockers

### External dependencies — NOT on the engineering critical path

These block v1.0 but cannot be resolved by engineering work. They are
tracked here so they stay visible, and deliberately excluded from sprint
selection so engineering is never idle waiting on them.

| Item | Status | Owner | Dependency | Deadline |
|---|---|---|---|---|
| **Lexicon content** | `WAITING_EXTERNAL_DECISION` | Product Owner | QAC permission response | **2026-08-24** (21 days from 2026-08-03) |

- **Lexicon tables empty (0 rows) in the shipped database asset.**
  Schema exists (8 tables, F1/P3) and the full build pipeline exists
  (`tool/lexicon/`, 2,140 lines, unit-tested). Neither is the blocker.
  The blocker is a **licence question on the Quranic Arabic Corpus**,
  now analysed in full — see `docs/release/RELEASE_GOVERNANCE_AUDIT.md`
  §3 and the Phase 3 Legal Decision Review. MASAQ was evaluated as a
  replacement and **rejected** (no root/lemma columns —
  `docs/release/MASAQ_ACCEPTANCE_REPORT.md`).
  **Resolution path**: Product Owner sends a written permission request
  to corpus.quran.com; if no clear grant by the deadline above, Lexicon
  and Flashcards are formally deferred from v1.0 under a Decision
  Record. **No engineering sprint should be scheduled against this item
  until the answer arrives.**
  Consequence while unresolved: Lexicon and Flashcards are
  non-functional on a real install; `weakRoots` in AI Tutor can never
  fire.

### Critical

- ~~**Search: FTS5 engine not wired**~~ — **shipped** in Phase 3 Sprint
  R1 (commit `0f3f751`). `search_index_content` holds 43,652 rows and
  the UI is wired end-to-end. This entry was stale for three sprints;
  corrected during the Release Governance Recovery audit.
- ~~**Dead/dishonest UI affordances**~~ — **resolved** (Phase 3 Sprint
  R3b, `e59c106`, plus the R3b Close-out Patch, `75adf1c`, both
  2026-08-03). This item was never entered into this dashboard while
  it was open — flagged as a release-tracking gap in
  `PRODUCT_READINESS_REVIEW.md` §5, corrected here at close-out. Of the
  three affordances that review found (a permanently locked "Hỏi AI"
  toggle, a Search scope chip that rendered blank when selected, an
  Add-Flashcard search guaranteed to return nothing), all three closed
  in R3b.1–3 — the first two removed outright, the third gated on a
  real data-availability check (§2 "Sprint R3b"). The two items R3b
  itself deliberately deferred — the `_PlaceholderChipRow` skeleton
  chips (Recent/Suggestions) and 4 unused l10n keys — closed in the
  follow-up patch (§2 "R3b Close-out Patch"). No open item remains
  under this banner.
- **Store & legal readiness unstarted per `RELEASE_PLAN_V1.md`**:
  icons, screenshots, privacy policy, legal review of the Tanzil
  translation license, platform certificates. Process work, not
  engineering, but a hard submission gate — status of each item is
  not otherwise tracked in the five source documents for this
  dashboard.

### High

- ~~**Web platform is broken**~~ — **resolved (Phase 3 Sprint R3a.1–R3a.3,
  2026-08-03)**. `web/sqlite3.wasm` (from `sqlite3.dart` release
  `sqlite3-3.3.4`, exact match to the pinned `pubspec.lock` version) and
  `web/drift_worker.js` (from `drift` release `drift-2.34.0`, exact
  match) are vendored, with provenance and SHA-256 hashes recorded in
  `docs/DATA_PIPELINE.md`. **Verified working in a real browser, not
  just built** (`docs/release/PHASE3_SPRINT_R3A2_REPORT.md`): the
  content and user databases both open, the Surah list renders, FTS5
  Search returns real ranked results (40 hits for a test query), a
  bookmark write survived a full page reload, and the browser console
  was clean throughout (zero WASM/worker/drift errors). Storage backend
  confirmed as IndexedDB (`sharedIndexedDb` tier — no COOP/COEP headers
  were set in this test, so the fastest OPFS tier was not exercised; see
  below). A CI guard (`docs/release/PHASE3_SPRINT_R3A3_REPORT.md`) now
  fails `build-web` immediately if either vendored file goes missing,
  closing the "green CI on a broken platform" finding this item
  originally flagged.
  **Still open, deliberately out of this sprint's scope**: no hosting
  target has been chosen yet, so whether the fastest storage tier
  (`opfsLocks`, needs COOP/COEP headers) is reachable is undecided — if
  GitHub Pages is chosen, those headers are unreachable without a
  service-worker workaround (`docs/release/WEB_PLATFORM_VERIFICATION.md`
  §4); this is a UX/performance trade-off, not a correctness gap, since
  the verified IndexedDB tier is fully functional and persistent.
- **No real accessibility audit** has been performed (screen readers);
  `PERFORMANCE.md`'s Android column is unmeasured on a real mid-range
  device; automated tests (767) verify logic, not an actual QA pass.
- ~~**Coverage gate mismatch**~~ — **resolved (Sprint R3.2, see §2)**.
  Measured at 81.54% on hand-written code; gate raised 70 → 80 under
  `DR-2026-0015`. Still open in the adjacent sense that Arabic/RTL
  remains under-tested — tracked under Verification gaps, not here.
- **16 outdated packages**, including 2 major-version-behind
  (`flutter_riverpod`, `go_router`) and one EOL-flagged SQLite
  package — each requires its own regression pass; `CLAUDE.md` flags
  major-version bumps as a "stop and ask before" item.

### Medium

- **`l10n.comingInStep`** — a parameterized string, 0 remaining call
  sites after Sprint R3b.1 removed its last three usages (Profile's
  step-numbered labels). Same class of cleanup as the item above,
  found during R3b, not yet actioned.
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
- **Search polish** (Recent Searches, Suggestions, Filters) — *building
  the real feature* (real recent-query history, real suggestion logic)
  is correctly scoped to v1.1 in `PRODUCT_ROADMAP.md`, not v1.0. The
  placeholder *shapes* that used to stand in for this feature's future
  UI were removed entirely (R3b Close-out Patch, §2) rather than kept
  as scaffolding — when this is actually built, it starts from
  nothing, not from resurrected placeholders.
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
- **Status (2026-08-03)**: **split**. Search FTS5 wiring is **done**
  (Sprint R1, `0f3f751`). The Lexicon half is **removed from the
  engineering critical path** and reclassified as an external
  dependency (see §3) — the original "effort depends on where the data
  comes from" framing was wrong: the pipeline exists and the source is
  identified; the gate is a licence answer. This milestone cannot close
  until that answer arrives or Lexicon is formally deferred.

### R3a — Web Platform Completion ← **RECOMMENDED NEXT SPRINT**

Inserted 2026-08-03, ahead of the dashboard's original R3, because it
is the highest-value work that is fully independent of every external
dependency.

- **Objective**: make the Web target either genuinely functional or
  explicitly excluded — and stop CI reporting green on a broken
  platform.
- **Why now**: closes Go/No-Go box 4 (High tier); zero dependency on
  Lexicon, on any legal answer, or on physical-device access; and it
  fixes a live false-positive in CI, which is a correctness problem in
  the release signal itself, not just a missing feature.
- **Why it is small**: the web database layer is **already fully
  written** (`connection/web.dart`, `user/connection_web.dart` — both
  complete drift WASM implementations). The gap is two published
  binaries — `sqlite3.wasm` and `drift_worker.js` — from packages
  already in `pubspec.yaml`, with instructions already in
  `docs/DATA_PIPELINE.md` §"Web".
- **Deliverables**: either (a) vendor the two artifacts, verify the app
  actually opens both databases in a browser, and add a CI check that
  fails when they are absent; or (b) a Decision Record deferring Web
  from v1.0, the `build-web` job removed or marked advisory, and Web
  dropped from any store/marketing claim.
- **Dependencies**: none.
- **Estimated complexity**: Low-Medium for (a), Low for (b). The real
  work in (a) is runtime verification, not integration.
- **Status (2026-08-03)**: **done** — path (a) completed in full
  (R3a.1 vendor, R3a.2 browser verification, R3a.3 CI guard; see §2
  above). Path (b) was not needed. Only the hosting-target decision
  (and therefore the OPFS/COOP-COEP question) remains open, tracked in
  §3, not blocking this milestone's closure.

*(R3a is listed here, immediately after R1, because it was the next
sprint to run. R2 below is already partially complete; the dashboard's
original R3/R4/R5 follow unchanged in their own sections.)*

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
- **Status**: Read Model UI deliverable **shipped** (Phase 3 Sprint R2,
  see §2 above). Web platform go/no-go **also resolved**, via R3a
  (§4a above) rather than as part of this milestone. D8 refactor and
  D5's 4 dead files remain open — this milestone is partially, not
  fully, closed.

### R3b — Honest Surface Area

Inserted 2026-08-03, following directly from
`docs/release/PRODUCT_READINESS_REVIEW.md`'s finding that code quality
was no longer the constraint on public beta readiness — three visible,
misleading UI affordances were.

- **Objective**: make every visible control either work, or clearly and
  passively say it doesn't yet — no control that looks interactive but
  silently does nothing or guarantees failure.
- **Why now**: the one Critical-tier item in the Product Readiness
  Review that engineering could close unilaterally — no dependency on
  the Lexicon licence answer, store/legal action, or physical-device
  access.
- **Deliverables**: remove the permanently-locked "Hỏi AI" toggle and
  the Search scope-chip row; gate Add Flashcard's Lemma search on real
  data availability instead of letting it search a permanently-empty
  table.
- **Dependencies**: none.
- **Status (2026-08-03)**: **done**. R3b.1–R3b.3 (committed `e59c106`)
  closed the three items scoped and executed; the two items named in
  the original plan but sequenced after R3b.3 (Search placeholder
  chips A4/A5, 2 sets of unused l10n keys) closed in a small follow-up
  patch the same day (committed `75adf1c` — see §2 "R3b Close-out
  Patch"). Nothing remains open under the "Honest Surface Area" theme.

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
- **Soft dependency on Lexicon (2026-08-03)**: R3 is **not blocked**,
  but an accessibility/QA pass run today would evaluate Flashcards and
  Lexicon screens in their empty state. Run R3 against everything
  *except* those two surfaces, and re-test them once the Lexicon
  external dependency resolves either way. Coverage was already closed
  separately (`DR-2026-0015`), so it is no longer part of this sprint.
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
- **Hard dependency on Lexicon (2026-08-03)**: **store screenshots
  cannot be finalised** while Lexicon is unresolved. Any screenshot of
  Flashcards or Lexicon would show empty content, and screenshots are
  a permanent public artifact. This is the one downstream sprint the
  Lexicon external dependency genuinely gates. Either wait for the
  answer, or — if Lexicon is deferred — take screenshots of the
  feature set that actually ships.
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

- [ ] **Lexicon database asset populated and verified on a real
      install — `WAITING_EXTERNAL_DECISION`**, Product Owner, blocked on
      QAC permission response, decision deadline **2026-08-24**. Closes
      either by a permission grant + pipeline run, or by formal deferral
      under a Decision Record. **Not an engineering task until then.**
- [x] Search returns real FTS5 results, not placeholder/empty states —
      shipped Phase 3 Sprint R1 (`0f3f751`); 43,652 rows in
      `search_index_content`
- [x] Read Model decision made and implemented (UI shipped or formally
      deferred) — shipped, Phase 3 Sprint R2 (see §2)
- [x] Web platform decision made and implemented (fixed or excluded) —
      fixed, Phase 3 Sprint R3a.1–R3a.3 (see §2); verified working in a
      real browser on the IndexedDB storage tier; hosting-target choice
      (and reachability of the fastest OPFS tier) remains open but is
      not a correctness gap
- [ ] Accessibility audit complete, Critical/High findings closed
- [ ] Performance measured on a real mid-range Android device
- [x] Coverage gate reconciled with actual measured coverage — measured
      81.54% (hand-written code, generated sources excluded), gate set
      to 80; all four figures and the rationale in §2, policy in
      `DR-2026-0015`
- [ ] All 16 outdated packages triaged; load-bearing/EOL ones upgraded
- [ ] `RELEASE_CHECKLIST.md` fully signed off (assets, legal, signing)
- [ ] Tanzil translation license legal review returned a clear result
- [ ] `pubspec.yaml` version bumped; `CHANGELOG.md` release entry cut
- [ ] `dart format` / `flutter analyze --fatal-infos` / `flutter test
      --coverage` all clean on the release branch
- [ ] Zero open P0 technical debt (currently satisfied)
- [ ] No Critical blocker from §3 remains open

**Sprint R3b note**: none of the 14 boxes above is directly about UI
honesty, so R3b (§2, §4) does not check a new one — stated plainly
rather than implied, per this dashboard's own §5 finding that
completed work has previously gone unrecorded here. Its effect is on
the *quality* of a beta a user would actually see, and on de-risking
the last unchecked box for R4 (store screenshots), not on this
checklist's count.

**Go** requires every box checked. Any single unchecked Critical-tier
item (§3) is an automatic **No-Go** regardless of how many other boxes
are checked — the Critical tier was chosen specifically because each
item there independently blocks a coherent v1.0 (a search that
doesn't search, a store submission with no privacy policy, a
flashcard feature with no data, are each disqualifying alone).

---

## 8. Recommended release order

**Revised 2026-08-03** — Lexicon reclassified as an external dependency;
sequence re-cut so engineering is never idle waiting on a third party.

1. **Send the QAC permission request today**, and **start the Tanzil
   legal review in parallel** — both are external, both have lead time,
   both carry binary risk (§6). Neither is engineering work. Hard
   decision date for QAC: **2026-08-24**.
2. ~~**R3a — Web Platform Completion**~~ — **done** (2026-08-03).
   Closed Go/No-Go box 4 and removed the false-green from CI; verified
   working in a real browser. Hosting-target choice still open, not
   blocking.
2a. ~~**R3b — Honest Surface Area**~~ — **done, fully** (2026-08-03,
    R3b.1–R3b.3 + the R3b Close-out Patch, see §4 "R3b"). Did not check
    a new Go/No-Go box (none of the 14 items in §7 is about UI
    honesty), but closes the one Critical-tier, engineering-only item
    the Product Readiness Review found, and materially de-risks R4's
    store-screenshot dependency on Lexicon (an honest empty state is a
    permanently valid screenshot; a blank/broken-looking one is not).
3. **R2 remainder** (D8 / D5 debt — Web go/no-go closed via R3a) — Read
   Model shipped; the rest can proceed at any time. **Next available
   engineering sprint candidate**, alongside, per
   `PRODUCT_READINESS_REVIEW.md` §6's second priority, a release-record
   reconciliation pass (§5 of this document lists what's still missing
   from tracking as of this close-out).

*(Historical: the original step 2 was "R1 — Lexicon data + Search
wiring". Search shipped in Sprint R1; the Lexicon half moved off the
engineering path entirely — see §3.)*
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
