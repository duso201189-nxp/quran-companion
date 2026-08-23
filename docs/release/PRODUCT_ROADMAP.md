# Product Roadmap — Qur'an Companion

Written after PR #19. Reframes `ROADMAP.md`'s original v1.0/v1.5/v2.0
phases against what's actually built today (see `RELEASE_PLAN_V1.md`
§0 for why the original roadmap's status markers can't be trusted
as-is — this document supersedes its phase table, not its underlying
vision, which still holds).

---

## Where the product actually stands

Nearly all of the original "v1.5" feature scope is already built:
reading, audio, bookmarks/highlights/notes, full-text search (UI and
FTS5 engine wiring both built — **corrected 2026-08-18**: this
parenthetical previously said engine wiring was "still open," which
stopped being true in Phase 3 Sprint R1), a dashboard (streak, khatm
progress, daily goal, revision queue, bookmark collections), a full SRS
learning engine (spaced-repetition review, quiz, flashcards), a lexicon/
vocabulary layer, and a five-layer AI-adjacent recommendation stack
(Analytics → AI Tutor → Learning Journey → Smart Learning → Read
Model) that surfaces personalized study suggestions without calling
any actual AI/LLM service — it's rule-based aggregation over the
user's own study data, not generative AI. What's NOT built yet:
authentication, cloud sync, and any real AI/RAG integration (the
original "v2.0" scope) — those remain fully ahead of us.

This means the practical roadmap is less "climb from v0.8 to v1.5"
and more "finish what's already 90% built, ship v1.0, then decide how
much of the originally-v1.5-labeled work already shipped inside it."

## v1.0 — Ship what's built, close the real gaps

Scope: everything currently in the repo, minus the pieces that are
either broken on a real device or missing entirely. Full blocker list
in `RELEASE_PLAN_V1.md`; summarized here as roadmap items:

- ~~**Fix the Lexicon content gap**~~ — **deferred from v1.0, not a
  v1.0 gap to close.** **Corrected 2026-08-23** (Session 89
  documentation-reconciliation pass): this item previously framed
  populating the 8 Lexicon tables as v1.0 work to finish. `DR-2026-0030`
  (accepted, governing `main`, 2026-08-22) formally defers Lexicon (F1)
  and Flashcards (F2, which depends on F1) from v1.0 scope. The
  underlying gap is unchanged — the 8 Lexicon tables exist in the
  schema and ship with the database asset, but all remain empty (0
  rows); `DR-2026-0029` rejected the current MASAQ dataset as a source
  on structural and licensing grounds, and no repository evidence
  establishes that QAC permission was ever requested or granted.
  Whether, and in which release, Lexicon/Flashcards eventually ship is
  **not** scheduled or committed by `DR-2026-0030` — it is not
  reclassified into v1.1 below, only removed from v1.0. See
  `docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md` and
  `docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md`.
- **Finish Search** — **done; no longer a v1.0 gap**. **Corrected
  2026-08-18**: this item previously called it "the one clearly-visible
  'UI exists, logic doesn't' gap a real user would notice
  immediately." The already-built FTS5 engine was wired into the
  already-built Search UI in Phase 3 Sprint R1 (commit `0f3f751`), and
  Search has served real results out of `search_index` since.
- **Decide Read Model's fate** — **decided, and built**. **Corrected
  2026-08-18**: this item previously framed an open choice — "either
  give it a UI (a 'smart study summary' screen would be the natural
  fit, aggregating everything the five-layer chain already computes) or
  explicitly scope it out of v1.0 as forward-looking infrastructure."
  The first option was taken: `StudySummaryScreen` shipped in Phase 3
  Sprint R2 and became reachable via a CTA from `SmartLearningScreen`
  in Sprint R3.1.
- **Store readiness** — icons, screenshots, privacy policy, legal
  review of the Tanzil translation license, platform certificates. Pure
  process work, but real, and typically underestimated in time.
- **Real-device verification** — accessibility (screen readers),
  performance (mid-range Android), and a genuine QA pass beyond
  automated tests. The codebase's own test suite (1,293 tests —
  **corrected 2026-08-18** from a stale count of 767) is strong for
  logic correctness; it does not substitute for a human using the app
  on real hardware.
- **Platform scope call**: ship Web or explicitly defer it.
  **Corrected 2026-08-18**: this item previously added that Web was
  "currently broken — missing WASM/worker files for the database
  layer." Those files (`web/sqlite3.wasm`, `web/drift_worker.js`) were
  vendored version-matched to `pubspec.lock` and verified working in a
  real browser in Phase 3 Sprint R3a, with a CI guard against their
  removal. What is left here is the product call — whether to publish
  Web, and to what hosting target — not a broken-platform fix.

Not in v1.0, and correctly so: authentication, cloud sync, any new
product feature beyond what's already built. Sprint S2's own
discipline (fix what's broken, don't add scope) is the right posture
for this whole phase, not just that one sprint.

## v1.1 — Consolidate and complete the "smart" layer

Once v1.0 ships, the highest-leverage next work is finishing what F1–F8
started rather than starting new verticals:

- **Give Read Model a real UI** — **nothing outstanding**. **Corrected
  2026-08-18**: this item was conditional on v1.0 deferring that
  decision ("the data-aggregation work is already done; this is
  presentation-layer effort only"). v1.0 did not defer it — see the
  Read Model item above.
- **Search polish**: Recent Searches, Suggestions, Filters — the UI
  scaffolding already exists (empty-state placeholders reference these
  by name), just needs real logic behind it.
- **Technical debt from `UPDATED_TECHNICAL_DEBT.md`**: the duplicated
  soft-delete/upsert query pattern (D8, needs its own careful
  regression-tested pass given it touches 9+ repository files), the
  remaining duplicate-widget consolidation (D6's second half), and the
  handful of dead files (D5 — either wire `IoCacheManager` into
  `AudioController` with a real cache-management UI, finally closing a
  gap that's been open since early in this project's history, or
  remove it).
- **Background audio playback** — a real, user-visible gap
  (`AudioController` is foreground-only today) that's independent of
  any of the F1–F8 feature work and can land whenever audio engineering
  time is available.
- **Dependency upgrades** — the 2 major-version-behind packages
  (`flutter_riverpod`, `go_router`) and the EOL-flagged SQLite package,
  each with its own regression pass, done deliberately rather than
  bundled into a feature release.
- **Coverage gate** — **done**. **Corrected 2026-08-18**: this item
  asked to "raise CI's coverage threshold from 70% toward the original
  80% target now that F1–F8 shipped with strong test coverage of their
  own." That happened in Phase 3 Sprint R3.2 (`DR-2026-0015`): coverage
  was remeasured at 81.54% on hand-written code, and `MIN_COVERAGE` in
  `.github/workflows/ci.yml` now stands at 80.

## v2.0 — The originally-scoped "real" next chapter

This is where the roadmap's own long-standing vision picks back up,
unchanged in substance from `ROADMAP.md`'s original framing:

- **Authentication** (Supabase) — the actual prerequisite for
  everything below it; nothing in v2.0 is meaningful without an
  account system.
- **Cloud sync** — the `SyncColumns` mixin (`id`/`userId`/`updatedAt`/
  `deletedAt`/`isDirty`) already present on every `UserDatabase` table
  is explicitly forward-looking groundwork for this (per its own doc
  comments) — sync was designed for from the start, not bolted on
  later.
- **Crashlytics or an equivalent real crash-reporting backend** — the
  `CrashReporter` interface has existed since Sprint 19 and was fully
  wired into the reliability layer in Sprint S2; today it's a
  deliberate no-op. Swapping in a real implementation at that point is
  a `crashReporterProvider.overrideWithValue(...)` change, by design —
  the interface boundary was built specifically so this wouldn't
  require touching any repository.
- **Real AI/RAG integration** — genuinely new: everything the
  Analytics → AI Tutor → Learning Journey → Smart Learning chain does
  today is rule-based aggregation over the user's own local data, not
  a call to any language model. A real "Ask AI" or RAG-based study
  companion would be new capability, not a continuation of existing
  infrastructure — budget it as such. **Corrected 2026-08-18**: this
  entry previously described "Ask AI" as "already reserved as a locked
  UI affordance in Search." No such affordance remains — the mode
  toggle was removed outright in Phase 3 Sprint R3b.2, alongside the
  Scope Chips, because a permanently-locked control carried no product
  signal. Re-adding an AI mode starts from nothing, not from reserved
  scaffolding.
- **Hifz progress/history reporting** — **built; no longer future
  work**. **Corrected 2026-08-14**: this entry previously listed *Hifz
  mode* itself as an unbuilt v2.0 direction that had "never been
  concretely specified." That is no longer true — Hifz was specified
  and built as Milestone 7 Sprint 7.7
  (`docs/release/MILESTONE_7_STUDY_ROADMAP.md`) and now ships as part
  of v1.0: plan management (create, range selection, active/paused/
  completed lifecycle, soft delete), a Hifz-specific scheduling
  algorithm, and SRS-backed review with grading, reachable from the
  Study tab. It used exactly the extensibility seam the early schema
  reserved for it (the general-purpose `srs_cards.item_type`).
  **Corrected again 2026-08-18**: the entry then said what remained
  genuinely future work was a Hifz-specific progress/history surface,
  "no such view exists today." Both exist now — progress as a per-plan
  snapshot screen (Sprint 7.7c-A) plus an all-active-plans overview on
  the plans list (Sprint D6.4), and history as a review-history section
  on the per-plan progress screen (Sprint D6.11, `DR-2026-0026`,
  accepted) reading the `review_events` table added at schema v8: a
  total review count and a seven-day per-day distribution over the ayah
  set of a plan's range. What genuinely does not exist — by decision,
  not omission — is any cross-plan or aggregate Hifz history:
  overlapping plans share a single card per ayah, so no fact exists
  about which plan "caused" a review and the numbers do not sum.
- **Platform expansion** — native widgets (home-screen widgets,
  lock-screen controls) mentioned in the original roadmap's v2.0 line;
  genuinely new platform-integration work, sequenced last because it
  depends on nothing else here and adds the least to the app's core
  value proposition on its own.

## What this roadmap deliberately does not promise

Timelines. Every item above is sequenced by dependency and leverage,
not by date — this engagement's own experience (a mega-commit's worth
of feature work landing in a burst, followed by stale planning
documents that took a dedicated pass to reconcile) is itself evidence
that date-based roadmaps drift quickly in a project run this way.
Re-sequence freely as real priorities change; the dependency logic
(Lexicon DB fix before Flashcards works on-device, auth before sync,
sync before anything meaningfully "cloud") is the part worth keeping
stable.
