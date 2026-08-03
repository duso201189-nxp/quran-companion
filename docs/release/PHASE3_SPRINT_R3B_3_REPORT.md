# Phase 3 — Sprint R3b.3 Implementation Report

Implements **Priority Group 3 only** of `PHASE3_SPRINT_R3B_PLAN.md`, per
`PHASE3_SPRINT_R3B_DESIGN_REVIEW.md` §5 and building on
`PHASE3_SPRINT_R3B_1_REPORT.md` / `PHASE3_SPRINT_R3B_2_REPORT.md`. Not
committed, not pushed.

**Scope actually touched**: gated the Add Flashcard screen's Lemma
source (C1) on real Lexicon data availability, reusing the existing
`_SourceNotAvailable` treatment. Lexicon itself, Basmalah, and Search
were not touched — see §6. Smart Deck (C2/C3) was reviewed and found
**not currently reachable**, so left unmodified — see §3.

---

## 1. Re-verified before touching anything

Re-checked the live shipped database directly rather than trusting
either the prior reports or the repository implementation's own doc
comment (which turned out to be stale — see the callout below):

```
python3 -c "... sqlite3.connect('assets/database/quran.sqlite') ..."
tables found: ['roots', 'lemmas', 'lexemes', 'word_instances',
                'grammar_features', 'phrases', 'phrase_word_instances',
                'lexicon_relations']
lemmas 0
```

Confirms `PRODUCT_READINESS_REVIEW.md`'s finding still holds: all 8
Lexicon tables exist in the shipped asset, all at 0 rows. This matters
because `lexicon_repository_impl.dart`'s own class doc comment (lines
24–29) claims the Lexicon tables **don't exist yet** in the shipped
database ("mọi phương thức ở đây sẽ ném lỗi 'no such table'") — that
comment is **factually stale**: the tables exist and are simply empty,
so `searchLemmas()` returns an empty list, it does not throw. Had I
trusted that comment instead of re-querying the real file, I would have
designed the wrong fix (one that catches a "no such table" error rather
than one that checks for zero rows). **Not corrected here** —
`lexicon_repository_impl.dart` is a Lexicon file, and objective 4 says
"Do NOT modify Lexicon" (implement or otherwise); flagged here as a
finding for whoever next touches that file, not actioned.

## 2. Objective 1 — the Lemma dead end, fixed

### What was wrong

`add_flashcard_screen.dart`'s Lemma tab (the default tab) ran a real
query (`LexiconRepository.searchLemmas`) against a table with 0 rows.
Every search — any query, including none — returned empty, rendering
`l10n.addFlashcardNoResults` ("No results found."). That string implies
a search ran and failed to match; the actual situation is that the data
source has nothing in it yet. A user reaches this screen via an
affirmative call to action ("Add your first flashcard") and cannot
succeed no matter what they type.

### Fix: reuse the existing honest pattern, gated on real data

Root and Phrase sources in this same file already show
`_SourceNotAvailable` — a real widget, already shipped, already tested
— for exactly this situation ("no browsable data for this type yet").
Lemma was the one source with a real query method, so it never used
that widget. The fix makes Lemma's honesty **conditional on whether
Lexicon actually has data**, rather than permanently on or off:

- Added `lemmaLibraryAvailableProvider` in
  [`flashcard_providers.dart`](../../lib/features/flashcards/data/flashcard_providers.dart) —
  a `FutureProvider<bool>` that calls the **existing**
  `LexiconRepository.searchLemmas(limit: 1)` and returns
  `result.isNotEmpty`. No new repository method, no schema change — it
  reads the same method the search UI already calls, just with a
  minimal probe query.
- Added `_LemmaSourceBody` in
  [`add_flashcard_screen.dart`](../../lib/features/flashcards/presentation/add_flashcard_screen.dart),
  inserted between the source `switch` and `_LemmaResults`: it watches
  `lemmaLibraryAvailableProvider` and shows `_LemmaResults` (the real
  search UI) when data exists, or `_SourceNotAvailable` (the same
  widget Root/Phrase use) when it doesn't.
- The gate gives an **immediate** honest answer — `_SourceNotAvailable`
  renders as soon as the Lemma tab opens, before the user types
  anything, matching how Root/Phrase already behave. It does not wait
  for a failed search to reveal the truth.

### Why this design, not the alternatives

- **Not a hardcoded constant.** The design review (§5) flagged this as
  the one open question: a hand-flipped constant would be
  unambiguously "not new functionality," but would need a manual code
  change the day Lexicon data lands. A read-only availability check
  self-heals — the moment `lemmas` has rows, `available` flips to
  `true` and the real search UI appears with no further code change.
  I judge a read-only probe of an already-fully-built, already-called
  repository method to be an empty-state correction, not new
  functionality, consistent with the design review's own reading.
- **Not a new widget.** `_SourceNotAvailable` already exists, is
  already shown to users today for Root/Phrase, and its copy — "No
  browsable data for this type yet." — is worded around data
  availability, not build status. It reads honestly for Lemma's
  situation (built, but the data source is empty) without any wording
  change, which resolves the content-nuance question the design review
  flagged in its own §2 ("confirm the widget's copy reads correctly for
  'data not yet available' as well as 'feature not yet built'").
- **Not schema or repository changes.** `LexiconRepository`'s interface
  is untouched; `lemmaLibraryAvailableProvider` lives entirely in the
  Flashcards feature (`flashcard_providers.dart`, which already imports
  `lexicon_providers.dart` for other reads) and calls only a method
  that already existed and was already being called by this exact
  screen.

## 3. Objective 3 — every entry point reviewed

### Browse (`FlashcardBrowseScreen`)

Honest already. `resolvedFlashcardsProvider` (added flashcards) is
always empty today (nothing can be added while Lemma/Root/Phrase all
lacked data) — the screen correctly shows `_NoFlashcardsEmptyState`
("No flashcards yet" + "Add your first flashcard" CTA). The CTA is the
entry point into the fix in §2. The search/filter row and the 5 Smart
Deck action chips only render `if (resolved.isNotEmpty)` — see below,
this makes them currently unreachable through Browse, not broken.

### Add (`AddFlashcardScreen`)

Fixed — §2. Root/Phrase unchanged (already honest, already correct,
outside this sprint's objective since neither has a real query method
to gate).

### Empty state (all Flashcard-adjacent empty states, checked individually)

| Screen | Message shown when empty | Verdict |
|---|---|---|
| Browse, no flashcards | `_NoFlashcardsEmptyState` — "No flashcards yet" | Honest — true regardless of cause. |
| Browse, filter matches nothing | `_EmptyFilterResult` — deck-specific or generic "no results" | Honest, not reachable without flashcards existing first (not a dead end). |
| Decks, no decks | `flashcardDecksEmpty` — "No decks yet." | Honest — decks are user-created, unrelated to Lexicon. |
| Flashcard Review, nothing due | `_FlashcardReviewComplete` | Honest — "nothing to review right now" is true whether the cause is "reviewed everything" or "own zero cards"; verified by reading `flashcard_review_screen.dart` in full this pass. |
| Smart Deck, empty result | `smartDeckEmpty` — "No flashcards in this Smart Deck yet." | See below — currently unreachable, not fixed. |

### Navigation — the Smart Deck (C2/C3) finding

Traced every route into `AppRoutes.smartDeck` (`grep` for
`AppRoutes.smartDeck`/`SmartDeckType.weakRoots`/`SmartDeckType.verbForms`
across `lib/`, 3 call sites total, all inspected):

1. **`flashcard_browse_screen.dart`**'s Smart Deck `ActionChip` row —
   only builds `if (resolved.isNotEmpty)` (`:66-88`). `resolved` can
   never be non-empty today (Lemma was the only addable source before
   this fix, and it added nothing; Root/Phrase still add nothing). This
   row is **not reachable** in the running app right now.
2. **`tutor_action_navigator.dart`**'s "Open weak cards" action —
   pushes `SmartDeckType.weakRoots` directly, bypassing Browse. But its
   trigger (`tutor_suggestion_generator.dart:83`,
   `context.insights.weakRoots.isNotEmpty`) requires existing weak
   *lemma* SRS cards — which requires existing lemma flashcards, which
   requires exactly the path in (1). **Also not reachable** today, same
   root cause.
3. The route itself (`app/router.dart:233`) is inert without a caller.

And independently, `smartDeckFlashcardsProvider`'s `weakRoots`/
`verbForms` branches (`flashcard_providers.dart:139-151`) compute their
candidate pool from **the user's own existing lemma-type flashcards**,
not from the Lexicon at large — so even setting aside the two
unreachable navigation paths above, these decks have no data to show
until flashcards exist, which is the same C1 dependency, not an
independent break.

**Conclusion: C2/C3 are not a currently-reachable dead-end flow.**
Nothing in the shipped app can navigate a real user into
`SmartDeckScreen(weakRoots)` or `SmartDeckScreen(verbForms)` today. Per
objective 1's own framing ("users must never be led into an action
guaranteed to fail") — there is no path leading them there yet, so
there is nothing to fix to satisfy that objective for C2/C3. **Left
unmodified.** This is a "reviewed, evidence gathered, no action
required" outcome, not something skipped — recorded here rather than
silently passed over, matching objective 3's explicit instruction to
review Navigation.

Worth flagging forward: the moment §2's fix (or, eventually, real
Lexicon data) allows any lemma flashcard to be added, both paths above
become reachable again, and at that point Smart Deck's generic
`smartDeckEmpty` message would show for a **structurally-guaranteed**
empty deck (0 lemmas overall) exactly the way it already correctly
shows for a **genuinely-temporary** empty deck (user just hasn't
studied yet) — same message, two different truths. That distinction
doesn't matter today because the screen is unreachable, but it will be
worth another look once C1's fix is what's actually exposing users to
Smart Deck for the first time.

## 4. Objective 2 — kept, not removed

Flashcards remains fully visible: Browse, Decks, Review, and now an
honest Add flow are all present and functioning exactly as before.
Nothing was hidden behind a flag or removed. The design review never
called for removal of Flashcards as a whole — only for honesty at the
points where it currently overclaims — and this task follows that
reading exactly.

## 5. Objective 4 — confirmed not violated

- **No Lexicon implementation.** Zero new data, zero new repository
  methods, zero schema changes. `lemmaLibraryAvailableProvider` calls
  an existing method with an existing signature.
- **No fabricated data.** Nothing renders sample/mock lemmas; the
  screen now honestly reports the real, empty state instead of
  papering over it.
- **Basmalah untouched.** No file under `basmalah.dart`,
  `reading_screen.dart`, `reading_position_store.dart`, or
  `audio_controller.dart` appears in the diff.
- **Search untouched.** No file under `lib/features/search/` appears in
  this turn's diff (see §6 for the distinction from R3b.1/R3b.2's still
  -uncommitted carryover).

## 6. Confirmed scope, via `git status`

```
 M lib/features/flashcards/data/flashcard_providers.dart
 M lib/features/flashcards/presentation/add_flashcard_screen.dart
 M test/flashcard_ux_test.dart
```

are the only changes made **this turn**. `profile_screen.dart`,
`search_screen.dart`, the `.arb`/`app_localizations*.dart` files, and
the four `search_*_test.dart` files also show modified in the working
tree — all of that is carryover from R3b.1/R3b.2, still uncommitted per
those tasks' own "Do NOT commit" instructions, not touched by this
session's tool calls.

## 7. Localization

No l10n keys added or removed. `addFlashcardSourceNotAvailable` and
`errorLoadData` (both already defined in all 3 `.arb` files, already
used elsewhere in this same file) are the only strings the new code
path uses. `addFlashcardNoResults` ("No results found.") remains
defined and in active use — it's still correct for its real purpose
(Lemma search running with real data and genuinely matching nothing),
which is exactly what `test/flashcard_ux_test.dart`'s existing seeded-
lemma tests continue to exercise.

## 8. Accessibility

`_SourceNotAvailable` is reused verbatim — no new widget, no new
Semantics tree shape. The screen previously could show `addFlashcardNoResults`
text inside a `CircularProgressIndicator`-guarded async view; it now
may briefly show a `CircularProgressIndicator` (the availability check)
before either the real search UI or `_SourceNotAvailable` — same
loading-state pattern already used one level down inside `_LemmaResults`
itself, so no new accessibility surface was introduced.

## 9. Architecture

`LexiconRepository`'s interface, `AppDatabase` schema, and
`FlashcardRepository` are all untouched. The new provider follows the
same shape as every other read-only Riverpod provider in
`flashcard_providers.dart` (`FutureProvider`, `.autoDispose`, watches
an existing repository through the existing `lexiconRepositoryProvider`).
No new architectural pattern was introduced.

## 10. Test changes — every change explained

**Net: +1 test, 0 removed, 3 existing tests updated to call
`_seedLemmas` explicitly instead of relying on a global `setUp()`
seed.** No test was deleted.

| Change | What | Why |
|---|---|---|
| `setUp()` | Removed the unconditional `await _seedLemmas(appDb);` call. | The file's `setUp()` previously seeded 2 lemmas into every test's in-memory database, meaning **no test in this file exercised the real production state** (Lexicon empty) at all — every existing test ran against a Lexicon that already had data. That's the opposite of what this sprint's fix needed to verify. |
| `'Onboarding CTA -> AddFlashcardScreen, tìm + thêm 1 Lemma...'` | Added `await _seedLemmas(appDb);` as the test's first line. | This test searches for and adds a specific lemma ('kataba') — needs seeded data to pass; behavior and assertions unchanged, only the seed call moved from implicit (`setUp`) to explicit (in-test). |
| `'Smart Deck: chạm chip "Today's Review"...'` | Same — added explicit `_seedLemmas(appDb)`. | This test adds a flashcard via lemma search before reaching Smart Deck; same reasoning. |
| `'Add Flashcard: nguồn Root/Phrase...'` and the `FlashcardDecksScreen`/browse-empty-state tests | No seed added. | None of these exercise Lemma search — Root/Phrase are unconditionally `_SourceNotAvailable` regardless of Lexicon state, and Decks/browse-empty-state don't touch Lexicon at all. Confirmed by re-reading each test before deciding, not assumed from its name. |
| **New test**: `'Sprint R3b.3 — Add Flashcard: nguồn Lemma hiện trạng thái "chưa có dữ liệu"...'` | Added, no seeding. | Opens Add Flashcard with a genuinely empty Lexicon (the real production state) and asserts: (a) `_SourceNotAvailable`'s text shows immediately on the default Lemma tab, before typing anything; (b) `addFlashcardNoResults` ("No results found.") never appears, before or after typing an arbitrary query. This is the test that directly proves the fix — without it, nothing in the suite would catch a regression back to the infinite-empty-search dead end. |

No test was removed. The three "seed moved" changes are mechanical
(same assertions, same outcome, only *when* the data is inserted
changed) and are listed for transparency, not because they represent a
loss of coverage — if anything, the file now has broader coverage,
since it exercises both the "Lexicon has data" and "Lexicon is empty"
states where previously it only exercised the former.

## 11. Gate results

```
flutter analyze --fatal-infos
...
No issues found! (ran in 69.0s)
```

```
flutter test
...
+793: All tests passed!
```

Baseline entering this sprint was 792 (per `PHASE3_SPRINT_R3B_2_REPORT.md`
§8). **+1**, matching exactly the one new test in §10 — the three
"seed moved" edits changed *when* seeding happens, not how many tests
exist, so they don't affect the count.

## 12. What Priority Group 4+ still owns

Unchanged by this task, listed for continuity, not actioned:

- **A4/A5** (Recent/Suggestions placeholder chip rows on Search) —
  still deferred per `PHASE3_SPRINT_R3B_2_REPORT.md` §9.
- **C2/C3** (Smart Deck weak roots/verb forms) — reviewed this sprint
  (§3), found not currently reachable, left unmodified. Worth
  revisiting once C1's fix (or real Lexicon data) makes Smart Deck
  reachable again — see the forward-looking note in §3.
- **Basmalah** — still assessment-only per the design review; no
  implementation.
- **D1** (`placeholder*` keys), **`comingInStep`** (orphaned by
  R3b.1), **`lexicon_repository_impl.dart`'s stale "no such table"
  comment** (found this sprint, §1) — all still deferred, none
  actioned.

---

R3B.3 COMPLETE — Priority Group 3 only. Not committed, not pushed.
