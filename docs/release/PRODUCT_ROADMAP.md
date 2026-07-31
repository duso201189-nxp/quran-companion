# Product Roadmap — Qur'an Companion

Written after PR #19. Reframes `ROADMAP.md`'s original v1.0/v1.5/v2.0
phases against what's actually built today (see `RELEASE_PLAN_V1.md`
§0 for why the original roadmap's status markers can't be trusted
as-is — this document supersedes its phase table, not its underlying
vision, which still holds).

---

## Where the product actually stands

Nearly all of the original "v1.5" feature scope is already built:
reading, audio, bookmarks/highlights/notes, full-text search (UI
built, engine wiring still open), a dashboard (streak, khatm progress,
daily goal, revision queue, bookmark collections), a full SRS learning
engine (spaced-repetition review, quiz, flashcards), a lexicon/
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

- **Fix the Lexicon content gap** — the 8 Lexicon tables exist in the
  schema but not in the shipped database asset. This single fix
  unblocks Lexicon and (since Flashcards depends on Lexicon) makes the
  vocabulary/flashcard experience actually work on a real install, not
  just in tests.
- **Finish Search** — wire the already-built FTS5 engine into the
  already-built Search UI. This is the one clearly-visible "UI exists,
  logic doesn't" gap a real user would notice immediately.
- **Decide Read Model's fate** — either give it a UI (a "smart study
  summary" screen would be the natural fit, aggregating everything the
  five-layer chain already computes) or explicitly scope it out of
  v1.0 as forward-looking infrastructure. Either is fine; leaving it
  undecided isn't.
- **Store readiness** — icons, screenshots, privacy policy, legal
  review of the Tanzil translation license, platform certificates. Pure
  process work, but real, and typically underestimated in time.
- **Real-device verification** — accessibility (screen readers),
  performance (mid-range Android), and a genuine QA pass beyond
  automated tests. The codebase's own test suite (767 tests) is strong
  for logic correctness; it does not substitute for a human using the
  app on real hardware.
- **Platform scope call**: ship Web or explicitly defer it (it's
  currently broken — missing WASM/worker files for the database layer).

Not in v1.0, and correctly so: authentication, cloud sync, any new
product feature beyond what's already built. Sprint S2's own
discipline (fix what's broken, don't add scope) is the right posture
for this whole phase, not just that one sprint.

## v1.1 — Consolidate and complete the "smart" layer

Once v1.0 ships, the highest-leverage next work is finishing what F1–F8
started rather than starting new verticals:

- **Give Read Model a real UI** if v1.0 deferred that decision — the
  data-aggregation work is already done; this is presentation-layer
  effort only.
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
- **Coverage gate**: raise CI's coverage threshold from 70% toward the
  original 80% target now that F1–F8 shipped with strong test coverage
  of their own — the gate should reflect the codebase's actual current
  health, not a number set when coverage was lower.

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
  a call to any language model. A real "Ask AI" (already reserved as a
  locked UI affordance in Search) or RAG-based study companion would
  be new capability, not a continuation of existing infrastructure —
  budget it as such.
- **Hifz mode** — named as a future direction as far back as early
  schema design (a general-purpose `srs_cards.item_type` was
  deliberately kept extensible for exactly this) but never concretely
  specified. Needs real product definition before engineering scoping,
  not just a name carried forward from old notes.
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
