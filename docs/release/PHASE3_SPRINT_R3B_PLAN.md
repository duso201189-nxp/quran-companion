# Phase 3 — Sprint R3b Plan: Honest Surface Area

Based on `docs/release/PRODUCT_READINESS_REVIEW.md`. Planning only — no
code was written, no commit created.

**Goal**: every visible affordance in the app either works, or clearly
says it doesn't yet. Nothing in between.

**Non-goal**: new functionality. Not one feature is built in this
sprint. Every change removes, hides, relabels, or corrects something
that already exists.

---

## 1. Complete inventory of dead affordances

Found by sweeping all 24 screens for: disabled controls, `SizedBox.shrink()`
renders, placeholder widgets, empty states that can never fill, and
data-dependent surfaces whose data source is empty. **Twelve items in
four groups.** Three were not in the readiness review — the audit found
them.

### Group A — Search screen

| # | Element | Current behaviour | Severity |
|---|---|---|---|
| **A1** | "Hỏi AI" segment (`search_screen.dart:329`) | `enabled: false`, labelled `"Hỏi AI · Sắp ra mắt"`, tooltip "Sắp ra mắt" | Medium — honest, but prominent |
| **A2** | **"Ghi chú của tôi" scope chip** (`:348`) | **Fully enabled and selectable. Selecting it renders `SizedBox.shrink()` — a completely blank body** (`:211-213`) | **Critical** |
| **A3** | "Tất cả" scope chip | Labelled "All", searches Qur'an only — identical behaviour to the "Qur'an" chip | High — mislabel |
| **A4** | "Gần đây" (Recent) chips (`:421`) | `_PlaceholderChipRow` — 3 grey rounded blobs, no text, not tappable, under a real heading | High |
| **A5** | "Gợi ý" (Suggestions) chips (`:435`) | Same — 4 grey blobs under a real heading | High |
| — | Dev preview button (`:282`) | `if (kDebugMode)` — **tree-shaken out of release builds**. Verified. **No action needed.** | None |

**A2 is the single worst defect in the app.** The other items look
unfinished; this one looks *broken*. A user taps a normal-looking chip
and the screen goes empty with no message, no spinner, no explanation.
It is indistinguishable from a crash.

### Group B — Profile screen

| # | Element | Current behaviour | Severity |
|---|---|---|---|
| **B1** | "Thông tin cá nhân" tile (`profile_screen.dart:101`) | Disabled, subtitle `"Sẽ xây dựng ở Bước 10"` / `"Coming in Step 10"` | High |
| **B2** | **"Mục tiêu" (Goal) tile** (`:107`) | Disabled, subtitle **"Coming in Step 8"** — but **Daily Goal shipped**: `daily_goal_providers.dart`, `daily_goal_store.dart`, `daily_goal_dialog.dart` all exist and work | **Critical** |
| **B3** | "Đồng bộ" (Sync) tile (`:113`) | Disabled, subtitle `"Coming in Step 11"` | High |

All three leak an **internal 12-step roadmap into user-facing UI** — a
numbering scheme `CLAUDE.md` explicitly declares frozen and
meaningless: *"Don't trust 'Step N of 12' as a status indicator for
anything past Sprint 10 — it isn't one anymore."* A beta user has no
idea what "Step 10" is, cannot find out, and has no date.

**B2 is worse than meaningless — it is false.** The app tells users a
feature is unbuilt while that feature ships and works.

### Group C — Lexicon-dependent surfaces (0 rows in all 8 tables)

| # | Element | Current behaviour | Severity |
|---|---|---|---|
| **C1** | Add Flashcard → "Lemma" source (default) | Search box over `lemmaSearchProvider`; with 0 lemmas, **every query returns `addFlashcardNoResults` forever** | **Critical** |
| **C2** | Smart Deck → "Weak roots" | Resolves against empty `lemmas` → permanently empty deck | High |
| **C3** | Smart Deck → "Verb forms" | Depends on `lexemes.form_pattern` → permanently empty | High |
| — | Add Flashcard → "Root"/"Phrase" sources | Already render `_SourceNotAvailable` — **honest today. No action.** | None |
| — | Flashcards browse empty state | `_NoFlashcardsEmptyState` says the user has no cards — **true. No action.** | None |

**C1 is a dead-end funnel**: browse Flashcards → "Add your first
flashcard" → search box → nothing, ever. The empty state that invites
the action is honest; the action it invites is not.

Worth recording: the codebase already handles Root/Phrase honestly with
`_SourceNotAvailable`. **The pattern to fix C1–C3 already exists in the
same file** — it simply was not applied to the lemma path, because when
it was written lemma data was expected to arrive.

### Group D — Hygiene (not user-visible)

| # | Element | Severity |
|---|---|---|
| **D1** | 4 unused l10n keys × 3 locales (`placeholderHome`, `placeholderQuran`, `placeholderStudy`, `placeholderStats`) — **zero references in real code** | Low |
| **D2** | `_StudyToolCard.comingSoonLabel` branch — dead; no study tool has a null `onTap` | Low |

## 2. Classification and decisions

| # | Item | Decision | Rationale |
|---|---|---|---|
| **A1** | "Hỏi AI" segment | **Remove** | See §2.1 — contested call |
| **A2** | "My Notes" scope chip | **Remove** (with A3) | See §2.2 |
| **A3** | "All" / "Qur'an" chips | **Remove** the whole scope row | See §2.2 |
| **A4** | Recent chips + heading | **Remove** | Grey blobs under a heading communicate nothing. The empty state keeps its icon, title and typing hint — all genuinely useful. |
| **A5** | Suggestions chips + heading | **Remove** | Same. |
| **B1** | Personal info | **Replace** subtitle → `l10n.comingSoon` | Keep the tile (signals roadmap, sets up v2.0 auth), drop the internal numbering. Reuses an existing key in all 3 locales. |
| **B2** | Goal | **Remove** the tile | The feature exists. Leaving a "coming soon" for shipped functionality is the worst of both worlds. Daily Goal is already reachable from Stats. |
| **B3** | Sync | **Replace** subtitle → `l10n.comingSoon` | Same as B1. |
| **C1** | Add Flashcard lemma search | **Mark Coming Soon** | Apply the existing `_SourceNotAvailable` treatment when the lexicon is empty. See §2.3. |
| **C2** | Weak roots deck | **Mark Coming Soon** | Same mechanism. |
| **C3** | Verb forms deck | **Mark Coming Soon** | Same mechanism. |
| **D1** | Unused l10n keys | **Remove** | 12 dead entries across 3 `.arb` files. |
| **D2** | Dead card branch | **Remove** (optional) | Lowest value in the sprint; drop if time-pressed. |

### 2.1 Why remove "Hỏi AI" rather than keep it labelled — the contested call

This is the one item where I'd expect disagreement, so the reasoning is
explicit.

**Keeping it** signals the roadmap and costs nothing to implement (it's
already labelled correctly). **Removing it** loses that signal.

I recommend **Remove** for public beta because:

- It is the **most prominent control on the Search screen** — first
  element below the search bar, full-width segmented button.
- Real AI is **v2.0 scope**, gated behind authentication and a backend
  that do not exist. This is not "coming soon"; it is coming after two
  major releases. Labelling a two-releases-away feature "Sắp ra mắt" on
  the primary search surface is an over-promise, and beta users are
  exactly the audience who will hold you to it.
- Removing it collapses `SearchMode` to a single value, so the entire
  `SegmentedButton` disappears — Search becomes a **cleaner, more
  confident screen**, not a screen with a hole in it.
- It is trivially re-addable when the capability is real.

**If the product owner prefers to keep the AI signal**, the fallback is
Mark Coming Soon (status quo) — but then A2/A3 must still be fixed, and
the sprint should not also remove the scope row, or Search ends up with
a disabled AI toggle and nothing else. Decide A1 and A2/A3 together.

### 2.2 Why remove the entire scope-chip row

The three chips are: **All** (searches Qur'an), **Qur'an** (searches
Qur'an), **My Notes** (renders nothing). One is broken and two are
duplicates of each other.

Fixing A2 alone (disable + label "My Notes") would leave a selector
whose two remaining options are behaviourally identical — a control
that appears to filter and does not. **A control that does nothing is
not more honest than no control.**

Notes search is genuinely plausible for v1.1 — notes exist as a
feature, they simply have no FTS5 index. The scope row returns then,
with three options that actually differ.

### 2.3 Why "Mark Coming Soon" for Lexicon, not Remove or Hide

The Lexicon decision is **external and unresolved** — a QAC licence
answer due 2026-08-24 (`DR-2026-0016`). The sprint must not pre-empt
it, and must work under either outcome.

- **Remove** would delete working, tested code for a feature that may
  be unblocked in three weeks.
- **Hide** (feature-flag the whole Flashcards module out) is heavier
  than needed and would hide surfaces that *do* work — the flashcard
  browse/review flow functions correctly for cards created by any
  future path.
- **Mark Coming Soon** is reversible in one condition, honest today,
  and correct in both futures.

Mechanism: a single availability check (lemma count > 0) driving the
`_SourceNotAvailable` treatment **that already exists in
`add_flashcard_screen.dart`** for the Root and Phrase sources. No new
widget, no new pattern, no new string family.

**Judgment call flagged**: an availability check is arguably a *small
new mechanism*, which brushes against "no new functionality." I read it
as an empty-state correction — it adds no capability, only tells the
truth about capability that is absent. If the product owner reads it
strictly, the fallback is a hardcoded constant flipped by hand on
2026-08-24, which is uglier but unambiguously not new functionality.

## 3. Effort

| Item | Effort | Notes |
|---|---|---|
| A1 — remove AI segment | **S** | Delete segment; `SearchMode` collapses to one value; remove the enum and its `_mode` state. Touches `_buildBody`'s mode branch. |
| A2+A3 — remove scope row | **S** | Delete `SearchScope` enum, `_scope` state, `_scopeLabel`, chip row; simplify `_buildBody` condition. |
| A4+A5 — remove placeholder chips | **XS** | Delete `_PlaceholderChipRow` class, two call sites, two headings. |
| B1+B3 — replace subtitles | **XS** | Two string swaps to an existing key. |
| B2 — remove Goal tile | **XS** | Delete one `ListTile`. |
| C1–C3 — lexicon availability gating | **M** | One provider + apply existing `_SourceNotAvailable` treatment at 3 sites. The only non-trivial item. |
| D1 — remove unused l10n keys | **XS** | 12 entries across 3 `.arb` files + `flutter gen-l10n`. |
| D2 — dead branch | **XS** | Optional. |
| **Test updates** | **S–M** | Search tests reference the removed segments/chips (`search_accessibility_test.dart` covers RTL/touch-target on these controls). Expect real churn here, not just deletions. |
| **Total** | **Small–Medium** | ~1 focused sprint. No architecture change, no schema change, no new dependency. |

**Effort risk sits almost entirely in tests, not source.** The Search
screen is one of the most heavily tested surfaces in the project;
removing controls will invalidate assertions that exist for good
reasons. Budget for reading those tests properly rather than deleting
failing ones.

## 4. UX impact

| Item | Impact | Direction |
|---|---|---|
| **A2** | **High** | Eliminates the single worst experience in the app — a chip that blanks the screen. |
| **C1** | **High** | Closes a dead-end funnel the app actively invites users into ("Add your first flashcard"). |
| **B2** | **High** | Stops the app contradicting itself about a feature that works. |
| A1 | Medium–High | Search gains a cleaner, more purposeful first impression. |
| A3 | Medium | Removes a filter that never filtered. |
| A4+A5 | Medium | Empty state becomes intentional rather than half-loaded. |
| B1+B3 | Medium | Removes internal jargon from a user-facing screen. |
| C2+C3 | Medium | Two Smart Decks stop looking silently broken. |
| D1+D2 | None | Invisible hygiene. |

**Net**: the app stops presenting **five** surfaces that read as broken
(A2, B2, C1, C2, C3) and **five** that read as unfinished (A1, A3, A4,
A5, B1/B3). Nothing a user can currently *do* is taken away — every
removed control was non-functional.

**The perceived-quality gain is disproportionate to the effort**, which
is exactly what makes this the right sprint before public beta. First
impressions of a beta are set by whether things look *deliberate*.

## 5. Release impact

- **Unblocks store screenshots** (`RELEASE_DASHBOARD.md` R4's one hard
  Lexicon dependency). Screenshots of an honest empty state stay valid
  permanently; screenshots of blank cards and grey blobs do not. This
  is the concrete dependency R3b clears.
- **De-risks the 2026-08-24 Lexicon deadline.** With C1–C3 gated, a
  "no grant" outcome becomes a documentation change plus a constant,
  not an emergency UI sprint.
- **Improves accessibility-audit quality.** The pending real-device
  a11y pass (`RELEASE_DASHBOARD.md` R3) would currently spend time
  auditing controls scheduled for deletion. Doing R3b first makes that
  audit count.
- **No Go/No-Go box is directly closed by R3b.** Stated plainly: this
  sprint does not tick a checklist item. It changes whether the beta is
  *credible*, which the checklist does not measure — and it is a
  prerequisite for two items that are on it (screenshots, a11y).
- **Zero risk to shipped functionality.** Every change removes or
  relabels a non-functional element. No working code path is modified.

## 6. Explicitly out of scope

- **Building** Recent Searches, Suggestions, Filters, notes indexing,
  or AI — all v1.1/v2.0 (`PRODUCT_READINESS_REVIEW.md` §7).
- **Deciding** the Lexicon outcome — external, owner: Product Owner,
  due 2026-08-24.
- Background audio, audio cache UI, D5/D6/D8 debt, dependency upgrades.
- The dev-preview button — correctly `kDebugMode`-gated and
  tree-shaken; verified, no action.
- Anything requiring a physical device.

## 7. Acceptance criteria

1. No enabled control in the app renders a blank body. Specifically:
   selecting any remaining Search control produces a real state
   (results / empty / no-results / error).
2. No user-facing string references the internal step numbering.
   `grep -rn "comingInStep" lib/` returns **only** the l10n definition,
   or nothing if the key is retired.
3. Every Lexicon-dependent surface (C1–C3) shows an honest
   unavailability message while `lemmas` is empty — verified by running
   against the actual shipped asset, not a fixture.
4. No `_PlaceholderChipRow`-style shape-only widget remains in
   production code.
5. `grep` confirms zero references to the four `placeholder*` l10n keys
   before their removal.
6. `dart format` · `flutter analyze --fatal-infos` · `flutter test` all
   clean; test count may **decrease** (assertions on removed controls) —
   any decrease must be itemised in the sprint report, never silent.
7. `flutter build web --release` still succeeds.
8. Manual pass in a browser over Search, Profile, Flashcards and Smart
   Decks — the R3a.2 method, which caught what static checks could not.

## 8. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Test churn larger than expected on Search | **Medium** | Read each failing assertion before changing it; a test failing because its control was deliberately removed is a *deletion* decision, not a fix. Itemise in the report. |
| Removing A1/A3 is a product opinion, not a fact | **Medium** | §2.1/§2.2 state the trade-off; both are reversible in minutes. Get an explicit decision on A1 before starting. |
| Lexicon gating pre-empts the 08-24 decision | Low | Gate is condition-driven, correct under both outcomes; no code deleted. |
| l10n key removal breaks a locale | Low | Verified zero references; `flutter gen-l10n` + full suite will catch any miss. |
| Scope creep into "just build Recent Searches" | **Medium** | This sprint's entire premise is that building is the wrong move now. Deferred items are named in §6. |

---

## Recommendation

Run R3b as scoped, with **one decision needed before starting**:
keep or remove the "Hỏi AI" segment (§2.1). Everything else is
uncontested.

Sequence within the sprint: **B2 → A2 → C1–C3 → A1/A3 → A4/A5 →
B1/B3 → D1/D2** — worst-and-cheapest first, so that if the sprint is
cut short, the items that make the app look broken are already gone.

---

READY FOR R3B REVIEW
