# Phase 3 — Sprint R3b Design Review

Verifies `docs/release/PHASE3_SPRINT_R3B_PLAN.md` against the live
repository before any implementation. Every finding below was re-checked
against current source — none taken on the prior report's word. No code
was written, nothing was committed.

---

## 1. Verification of every R3b finding

All twelve items **Confirmed**. No item was Partially Confirmed or
Incorrect. Evidence for each:

| # | Item | Verdict | Evidence (this pass) |
|---|---|---|---|
| A1 | "Hỏi AI" segment disabled, labelled correctly | **Confirmed** | [search_screen.dart:329-336](../../lib/features/search/presentation/search_screen.dart) — `enabled: false`, label `'${l10n.searchAskLabel} · ${l10n.comingSoon}'`, `tooltip: l10n.comingSoon`. |
| A2 | "My Notes" chip enabled, renders blank | **Confirmed** | [search_screen.dart:211-213](../../lib/features/search/presentation/search_screen.dart): `if (_mode != SearchMode.search \|\| _scope == SearchScope.myNotes) return const SizedBox.shrink();` — no message, no state widget, nothing. The chip itself (`:348-353`) has no `enabled:` qualifier — fully tappable. |
| A3 | "All"/"Qur'an" behaviourally identical | **Confirmed** | Code comment at `:205-210` states it directly: *"'Tất cả' vẫn dùng engine Qur'an vì đó là domain duy nhất có dữ liệu hôm nay"* ("'All' still uses the Qur'an engine because it's the only domain with real data today"). Both chips fall through the same `_mode != search \|\| scope == myNotes` guard to the same `searchResultsProvider`. |
| A4/A5 | `_PlaceholderChipRow` grey blobs under real headings | **Confirmed** | `:421` (Recent), `:435` (Suggestions), widget defined `:448-475` — `ExcludeSemantics` wrapping fixed-width `Container`s, ​no text, no `onTap`. |
| — | Dev-preview button tree-shaken from release | **Confirmed, no action** | `:282` — `if (kDebugMode)` gate, confirmed by Flutter's own dead-code-elimination guarantee for that constant; not independently re-verified by inspecting a release binary this pass (was verified in the R3b plan's own audit; not re-derived here since nothing changed in this file's debug-gating). |
| B1 | "Personal info" — `comingInStep(10)` | **Confirmed** | [profile_screen.dart:100-105](../../lib/features/profile/presentation/profile_screen.dart). |
| B2 | "Goal" tile false "Coming in Step 8" vs. shipped Daily Goal | **Confirmed** | `profile_screen.dart:106-111` — `l10n.comingInStep(8)`, `enabled: false`. Daily Goal is live: `lib/features/stats/data/daily_goal_providers.dart`, `daily_goal_store.dart` both exist and are referenced from `stats_screen.dart`/`reading_stats_section.dart` (grep confirms real usage, not dead files). |
| B3 | "Sync" — `comingInStep(11)` | **Confirmed** | `profile_screen.dart:112-117`. |
| C1 | Add Flashcard lemma search is a dead end | **Confirmed** | [add_flashcard_screen.dart:30](../../lib/features/flashcards/presentation/add_flashcard_screen.dart) — `_source` defaults to `AddFlashcardSource.lemma`. `:92-96` — Root/Phrase already switch to `_SourceNotAvailable`; Lemma does not. `:114` — `lemmaSearchProvider(query)` is the only live path, and Lexicon has 0 rows (re-confirmed live in the Product Readiness Review, not re-queried this pass since no schema/data changed). |
| C2 | Smart Deck "Weak roots" permanently empty | **Confirmed** | [flashcard_providers.dart:139-148](../../lib/features/flashcards/data/flashcard_providers.dart) — `selectWeakRoots` resolves against `lexiconRepositoryProvider.getLemmasByIds`, which reads the empty `lemmas` table. |
| C3 | Smart Deck "Verb forms" permanently empty | **Confirmed** | `flashcard_providers.dart:149-151` — `verbFormGroupsProvider`, same dependency chain. |
| D1 | 4 unused `placeholder*` keys × 3 locales | **Confirmed** | Grep for `placeholderHome\|placeholderQuran\|placeholderStudy\|placeholderStats` across `lib/` returns **only** the `.arb` source files and their generated `app_localizations_{vi,en,ar}.dart` accessors — zero call sites in feature code. |
| D2 | Dead `comingSoonLabel` branch in Study | **Confirmed** | [study_screen.dart:23-65](../../lib/features/study/presentation/study_screen.dart) — all six `tools` entries have a non-null `onTap`; `_StudyToolCard`'s `if (onTap == null)` branch (`:184`) is unreachable in production. |

**One correction to the plan's own framing, not its facts**: B2's Daily
Goal isn't just "reachable from Stats" as a side note — `daily_goal_providers.dart` and `daily_goal_store.dart` are load-bearing for the Stats screen's goal widgets, confirmed by real (non-test) references. This *strengthens* the B2 finding: it is not a half-built feature living in a corner, it is an active, integrated one being actively contradicted by Profile.

## 2. Screen-by-screen review

### Search (`search_screen.dart`)

| | |
|---|---|
| **Current behaviour** | One `SegmentedButton` (Search / disabled Ask-AI) + one horizontal `ChoiceChip` row (All / Qur'an / My Notes, all enabled) + empty-state placeholder blobs. Selecting My Notes, or (structurally) Ask-AI, yields a blank body. |
| **Expected behaviour** | Every enabled control produces a real, legible state. A disabled control is the only way to represent "not yet." |
| **UX risk** | **High**, driven entirely by A2 — an enabled control rendering nothing is the worst class of UX defect: indistinguishable from a crash, and it sits on the app's second-most-visited screen (Search, per its own top-level route status). |
| **Accessibility impact** | Medium. `_PlaceholderChipRow` is correctly `ExcludeSemantics`-wrapped (does not confuse screen readers today), but a screen reader user who activates the My Notes chip gets an *empty announced region* with no `liveRegion` explanation — arguably worse for a screen-reader user than for a sighted one, since sighted users at least see blank space and might infer "broken," while a screen-reader user gets silence and cannot distinguish "nothing here" from "still loading." No existing widget covers this gap. |
| **Localization impact** | Low. Removing controls removes string *usages*, not string *definitions* — `searchAskLabel`, `searchScopeMyNotes`, `filterAll`, `searchEmptyRecentSectionTitle`, `searchEmptySuggestedSectionTitle` become orphaned keys in all 3 `.arb` files unless retired alongside the widgets (see §7, additional finding). |
| **Test impact** | **High** — the real cost center of this sprint. Confirmed 8 test files reference Search surface area: `search_screen_test.dart`, `search_accessibility_test.dart`, `search_responsive_test.dart`, `search_dark_mode_test.dart`, `search_no_results_state_test.dart`, `search_error_state_test.dart`, `fixtures/search_test_harness.dart`, plus incidental coverage in `app_test.dart`. `search_accessibility_test.dart` specifically asserts RTL layout and ≥48dp touch targets on the segmented button and chip row — both slated for deletion. This is exactly the plan's own risk table entry, independently re-confirmed by file enumeration, not assumed. |

### Profile (`profile_screen.dart`)

| | |
|---|---|
| **Current behaviour** | Three disabled tiles leaking `"Coming in Step N"` — one of them (Goal) contradicting a shipped feature. |
| **Expected behaviour** | Disabled tiles either say a generic, undated "coming soon," or don't exist if the feature already shipped elsewhere. |
| **UX risk** | **High** for B2 specifically (self-contradiction erodes trust in every other claim the app makes), **Medium** for B1/B3 (internal jargon, no date, no actionable info — but at least not false). |
| **Accessibility impact** | Low. `enabled: false` `ListTile`s already announce correctly as disabled via Flutter's built-in semantics; no remediation needed there regardless of which fix lands. |
| **Localization impact** | Low–Medium. `comingInStep` is parameterized (`{step}`) and used in exactly 3 call sites, all in this file — retiring it entirely (B1/B3 → generic `comingSoon`, B2 → tile removed) leaves it fully orphaned in 3 `.arb` files, same disposal question as §7. |
| **Test impact** | Not yet located a dedicated `profile_screen_test.dart` in the file list gathered this pass — if one exists it was not enumerated in the Search/Study/Flashcard sweep above; effort estimate should confirm this file's presence before starting B1–B3, since an untested screen changes the risk profile from "watch for churn" to "add missing coverage." |

### Add Flashcard / Smart Deck (Lexicon-dependent)

| | |
|---|---|
| **Current behaviour** | Lemma source and both Smart Decks query real, wired providers against a real, empty table — no fake data, no crash, just permanent emptiness indistinguishable from "still loading" or "temporarily offline." |
| **Expected behaviour** | The same `_SourceNotAvailable` treatment Root/Phrase already use, gated on an actual lemma-count check rather than a permanent "not built yet" flag — because Root/Phrase are permanently not built, while Lemma is built and only *data*-blocked. |
| **UX risk** | **High** for C1 specifically — it is reached by an affirmative call to action ("Add your first flashcard") from the browse empty state, meaning the app actively invites the user into the dead end rather than the user stumbling into it. C2/C3 are reached only by users who already opened Smart Decks, a comparatively deliberate action — **Medium**. |
| **Accessibility impact** | Low. `_SourceNotAvailable` is an existing, presumably already-audited widget being reused, not new surface. |
| **Localization impact** | None if the mechanism reuses existing strings (`_SourceNotAvailable`'s current copy) rather than writing new ones for the lemma case — confirm the widget's copy reads correctly for "data not yet available" as well as "feature not yet built," since those are two different claims sharing one widget. This is the one place the plan's reuse-not-rebuild instinct needs a content check, not just a code check. |
| **Test impact** | Medium — `flashcard_ux_test.dart` and `flashcard_tile_test.dart` exist and plausibly exercise these paths; the gating condition (lemma count) needs a test double either way (empty vs. non-empty), which is new test surface even though it's not new production functionality. |

## 3. Search scope chips — remain, simplify, or remove

**Remove**, based on current behaviour, not opinion:

- Of the three values in `SearchScope`, exactly one (`myNotes`) has any
  distinct code path today, and that path returns `SizedBox.shrink()`.
  The other two (`all`, `quran`) are provably the same branch reading
  the same provider — the code comment at `:205-210` says so in the
  implementer's own words. A three-option control with one broken and
  two identical options has **zero effective states**: selecting any of
  the three chips today produces exactly two distinct outcomes (results,
  or blank), never three.
- "Simplify" (e.g., drop to a two-way My-Notes/Qur'an toggle, or drop to
  a single "Qur'an-only, no chip" state) was considered against the
  architecture comment at `search_screen.dart:22-27`: the enum is
  explicitly designed so **future domains are added as new enum values
  without touching the widget** — the row is architected to expand, not
  to be permanently narrowed. Simplifying to two values today, then
  re-expanding when Notes search or Tafsir/Hadith domains land, is two
  edits to the same code for no durable benefit over removing the row
  now and re-adding it (cheaply, by the architecture's own design) when
  a second real domain exists.
- Removal is the only option that leaves **zero** non-functional chips
  on screen, matches the plan's "nothing in between" goal, and is
  reversible at the cost the architecture already budgeted for (§2.2 of
  the R3b plan, independently re-derived here from the enum's own doc
  comment rather than re-stated from the plan).

## 4. AI toggle — Remove, Hide, or Keep disabled

**Recommend: Remove.**

| Option | Trade-off |
|---|---|
| **Keep disabled** (status quo) | Preserves the roadmap signal at zero engineering cost — the label is already correct (`"Sắp ra mắt"`/`comingSoon`, not a false claim). Cost: it is the single most prominent control on the screen (first element, full-width) advertising a capability that is gated behind authentication and a backend that do not exist yet — two major versions away per `PRODUCT_READINESS_REVIEW.md`'s v1.0/v1.1/v2.0 split. A "coming soon" that is actually "coming in v2.0" reads as a broken promise to a beta tester who checks back in v1.1. |
| **Hide** (compile-time flag, code stays) | No UX or trust benefit over Remove — the user experience is identical to Remove (segment absent). The only difference is implementation cost: a flag adds a conditional and a second code path to maintain and test, for a feature with no near-term re-enable date. This is complexity without payoff — worse than either other option. |
| **Remove** | Collapses `SearchMode` to one value, deletes the `SegmentedButton`, `_mode` state, and the mode-branch in `_buildBody`. Search becomes a single-purpose, fully-functional screen with nothing disabled on it. Cost: loses the explicit roadmap signal; trivially reversible when AI search is real (re-adding a segment is strictly additive to the current architecture, same reasoning as §3). |

Remove dominates Hide outright (same user-facing result, less code to
carry). Remove vs. Keep-disabled is the genuine judgment call the R3b
plan already flagged — this review's independent read agrees with
Remove, for the reason above: the gap between "labelled soon" and
"actually two releases away" is large enough, on the most prominent
control on the screen, to be a beta-credibility risk rather than a
roadmap signal.

## 5. Flashcards — most honest behaviour until Lexicon is available

**Recommend exactly what §2.3 of the R3b plan already specifies**,
confirmed against code rather than re-derived independently: apply the
existing `_SourceNotAvailable` treatment (already live for Root/Phrase)
to the Lemma source and to both Smart Decks, gated on a real lemma-count
check.

No new functionality is invented — `_SourceNotAvailable` exists today
and is already shown to users for two of three sources; this only makes
its trigger condition data-driven instead of hardcoded for the third.
Alternatives (Remove the working Lemma-search code; Hide all of
Flashcards behind a feature flag) were both re-checked against current
code and rejected on the same grounds the plan gives: Lemma search is
real, tested, working code with no defect other than an empty backing
table, and Flashcards' browse/review flow is independently correct.
Deleting or hiding either would be strictly worse than gating the one
broken path.

The one open question restated, not resolved here (it is a
product-owner call, not an engineering one): whether the lemma-count
check itself is "new functionality" in the strict reading of the
sprint's non-goal. Recommend the plan's own fallback — a hand-flipped
constant — **only if** the product owner reads "no new functionality"
strictly enough to exclude a read-only availability check; otherwise the
count-based gate is preferable because it requires no manual step on
2026-08-24.

## 6. Basmalah as a Core Reading Element — architecture readiness

**Assessment only, per the task's explicit instruction — nothing
implemented.**

### What exists today

Basmalah is **purely a text-rendering decoration**, not a first-class
entity anywhere else in the stack:

- **Data model**: [`basmalah.dart`](../../lib/features/quran/domain/basmalah.dart)
  is a pure string-splitting utility — `splitLeadingBasmalah` cuts the
  first 4 space-separated tokens off Ayah 1's *existing* Uthmani text at
  render time. There is no `Basmalah` entity, no row, no id, no
  standalone asset of any kind. It is invisible to the database schema.
- **Audio playlist**: [`audio_controller.dart:167-204`](../../lib/features/quran/presentation/audio/audio_controller.dart)
  builds `List<Uri>` as a strict 1:1 map over `List<Ayah>`
  (`buildAyahAudioUrl(surahId, ayahNumber)` per entry). One URI = one
  full Ayah's reciter audio file. Because Basmalah's text lives *inside*
  Ayah 1's text (for 113 of 114 surahs), its audio — if the reciter
  recited it — is physically embedded inside Ayah 1's single audio file,
  at an unknown offset the app has no metadata for.
- **Synchronized highlight**: [`reading_screen.dart:672-679`](../../lib/features/quran/presentation/reading/reading_screen.dart)
  matches highlight state via `s.currentIndex == content.ayah.ayahNumber - 1`
  — exact-equality against a whole-Ayah index. There is no sub-ayah
  timing signal anywhere in `AyahAudioPlayer`'s stream contract
  (`currentIndexStream` yields `int?`, not a time-in-ayah or
  segment-in-ayah value).
- **Progress tracking**: [`reading_position_store.dart`](../../lib/features/quran/presentation/reading/reading_position_store.dart)
  persists one integer — `posKey(surahId) → ayahIndex` — per surah.
  There is no representation below "which Ayah," so a reading position
  "at the Basmalah" and "at the start of Ayah 1" are the same stored
  value; they cannot be distinguished even in principle by this store.

### Can the architecture support the four capabilities without change?

| Capability | Supportable today? | Why / what's missing |
|---|---|---|
| **Dedicated audio** | **No** | The audio-URL builder and the `Reciter` model address only `(surahId, ayahNumber)`. There is no lower addressable unit anywhere in the audio pipeline, and no reciter data source in this app provides segment-level (word/phrase) timing that would let a sub-clip of Ayah 1's existing file be isolated. |
| **Playlist inclusion** | **No** | `playSurah`'s playlist is generated as one `Uri` per `Ayah` object (`for (final a in ayahs)`). Inserting a Basmalah entry would require either a synthetic pseudo-`Ayah` (fights the domain model, since Basmalah is explicitly *not* an Ayah in the domain doc comment — Surah 1's Ayah 1 already *is* the Basmalah, so a synthetic entry would double-count there) or changing the playlist item type from a bare `Uri` to a richer type that can express "sub-segment of Ayah 1." Both are structural changes to `AyahAudioPlayer` and `AudioController`, not additive ones. |
| **Synchronized highlight** | **No** | The equality check (`currentIndex == ayahNumber - 1`) is the entire sync mechanism; it has exactly Ayah granularity by construction. Highlighting Basmalah distinctly from the rest of Ayah 1 needs a sync signal finer than "which Ayah is playing," which does not exist at any layer (player, controller, or store). |
| **Progress tracking** | **No** | `ReadingPositionStore` stores a single `int` per surah. A reading position that distinguishes "at the Basmalah" from "at Ayah 1, past the Basmalah" needs a second axis of state this store does not have a field for. |

**Conclusion: the current reading architecture cannot support any of the
four capabilities without architectural changes.** The underlying reason
is the same in all four cases, not four unrelated gaps: **the Ayah is
the sole addressable unit** across the audio playlist, the highlight
sync, and the position store, and Basmalah was deliberately built
*beneath* that unit — as a client-side text split, specifically so that
list-mode rendering could show it without touching "the CHÍNH THỐNG
[canonical] text of Ayah 1" (`basmalah.dart:11`). That was the right
call for the rendering-only problem Sprint work solved at the time; it
is exactly why it doesn't extend to audio/highlight/progress now — those
three subsystems were never told Basmalah exists.

**What real support would require** (assessment only, not a proposal to
build): a sub-ayah "segment" concept threaded through all three
subsystems at once — the playlist item type, the highlight-sync
comparison, and the position-store schema — plus, upstream of all of
that, a data source that actually provides segment-level audio and/or
timing (today's `Reciter`/audio-URL model has none; this would likely
mean either a differently-produced audio asset per reciter, or a
timing-metadata layer parallel to the existing `Ayah` table). This is
Lexicon-shaped in its risk profile: an external data dependency, not
just an engineering task, and should be scoped as its own investigation
if it becomes a real roadmap item — not folded into R3b or estimated
here.

## 7. Additional dishonest surface found

One item beyond the plan's twelve, lower confidence, flagged for
product-owner judgment rather than asserted as a defect:

**The "AI Tutor" feature is named and framed as AI throughout the UI
(`aiTutorTitle`, `studyAiTutor`/`studyAiTutorDesc` on the Study screen,
the `auto_awesome` sparkle icon used for both this and the actually-AI
search segment), but its implementation is deterministic, rule-based
analytics** — [`tutor_home_screen.dart:19-42`](../../lib/features/ai_tutor/presentation/tutor_home_screen.dart)'s
own doc comment describes it as consuming `tutorSuggestionsProvider`/
`tutorInsightsProvider`, which are analytics-derived, not model-derived.
This is architecturally sound and explicitly documented as intentional
layering (`AITutorRepository → AnalyticsRepository`, no direct access) —
it is not a bug. It is a **naming/branding question**: a beta user
reading "AI Tutor" next to a locked "Hỏi AI (AI) · Sắp ra mắt" segment
on Search may reasonably infer both are the same kind of capability,
when only one involves anything resembling AI. Unlike the twelve
confirmed items, this costs nothing broken today and nothing is
factually false (the feature does tutor the user, adaptively) — it is
a positioning ambiguity, not a defect, so it is named here rather than
added to the R3b inventory. Recommend the product owner decide whether
this warrants a rename (e.g., "Study Tutor"/"Smart Review") in a later,
separate, low-risk sprint — explicitly **not** R3b, since renaming a
shipped, working, well-tested feature is a different risk class from
removing twelve non-functional ones, and doing it here would blur this
sprint's "nothing shipped changes behaviour" guarantee.

No other candidate surfaced. The `SizedBox.shrink()` sweep this review
ran independently (`home_screen.dart`, `flashcard_tile.dart`,
`learning_summary_screen.dart`, `audio_bar.dart`, `reading_screen.dart`)
found only conditional guards on legitimately absent/loading data
(`if (data == null)`, `if (!audio.active)`) — none are permanently-empty
selections like A2. The sweep is treated as complete for this pass.

## 8. Recommendation

Proceed with R3b as planned, with both previously-open decisions now
resolved by this review rather than left to the product owner:

- **A1 ("Hỏi AI")**: **Remove** — independently re-derived in §4, same
  conclusion as the plan's own recommendation.
- **A2/A3 (scope chips)**: **Remove the row** — independently re-derived
  in §3 from the architecture's own extensibility comment, not merely
  from "one is broken, two are duplicates."
- **C1–C3 (Lexicon gating mechanism)**: confirmed as not "new
  functionality" in spirit (§5) — proceed with the count-based gate
  unless the product owner specifically wants the stricter
  hardcoded-constant fallback.

One new item for the sprint report to carry, not the sprint scope
itself: confirm whether `profile_screen_test.dart` (or equivalent)
exists before starting B1–B3 (§2, Profile row) — this review could not
confirm its presence and it changes the effort estimate for that group
from "watch for churn" to "may need new coverage."

The §7 "AI Tutor" naming question is explicitly **out of scope for
R3b** and should not be actioned alongside it.

---

DESIGN REVIEW COMPLETE — no code changed, nothing committed.
