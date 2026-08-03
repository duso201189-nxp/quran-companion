# Phase 3 — Sprint R3b.1 Implementation Report

Implements **Priority Group 1 only** of `PHASE3_SPRINT_R3B_PLAN.md`,
per `PHASE3_SPRINT_R3B_DESIGN_REVIEW.md`. Not committed, not pushed.

**Scope actually touched**: the blank "My Notes" search scope (A2), and
the three Profile tiles leaking internal step numbering (B1/B2/B3). AI
Toggle, Flashcards, Basmalah, Search scope architecture, and Lexicon
were not touched, per explicit instruction — verified in §5.

---

## 1. Objective 1 — the blank "My Notes" scope, fixed

### What was wrong

`search_screen.dart` had the "Ghi chú của tôi" (My Notes) `ChoiceChip`
fully enabled and selectable. Selecting it hit
`if (_mode != SearchMode.search || _scope == SearchScope.myNotes) return const SizedBox.shrink();`
— a silently blank body, indistinguishable from a crash.

### Chosen fix, and why

**Disable the chip using the exact pattern already used for the "Hỏi
AI" segment** (`enabled: false` there → `onSelected: null` here, since
`ChoiceChip` expresses disabled state via a nullable callback rather
than a boolean), rather than either of the two alternatives considered:

| Option | Rejected because |
|---|---|
| Leave the chip selectable, replace the blank body with a "not available" message | Requires the user to tap into what still looks like a working filter and be told afterward. A control that lets you select an option and then tells you the option doesn't work is a worse first impression than a control that visibly can't be selected — and it does not eliminate the interaction that reads as broken, only softens what follows it. |
| Remove the chip / collapse the scope row | Explicitly out of scope this task ("Do NOT touch: Search scope architecture") — this is exactly the fix the design review recommended for the *full* R3b sprint (§3), not for R3b.1. |

Disabling the chip was chosen because it is: (a) the **most honest**
option — a control the user cannot activate cannot mislead them about
what happens when activated, matching this codebase's own established
convention for "not yet, but visibly not yet" (the AI segment); (b) the
**most temporary** — nothing about the `SearchScope` enum, its three
values, or its extensibility design changed, so re-enabling the chip
later (when Notes search ships) is a two-line revert; (c) it makes the
blank-body outcome **structurally unreachable** through the UI, not
just less likely — `_scope` can never become `SearchScope.myNotes` via
user interaction anymore, the same class of guarantee the "Hỏi AI"
segment already gives for `SearchMode.ask`.

### Implementation

[`search_screen.dart`](../../lib/features/search/presentation/search_screen.dart):

- `_scopeLabel`: `myNotes` now returns `'${l10n.searchScopeMyNotes} · ${l10n.comingSoon}'`
  — same label pattern as the AI segment (`'${l10n.searchAskLabel} · ${l10n.comingSoon}'`).
  No new l10n key — reuses `comingSoon`, already defined in all 3
  locales.
- The `ChoiceChip` loop: added `tooltip: scope == SearchScope.myNotes ? l10n.comingSoon : null`
  and changed `onSelected` to `null` for `myNotes`, real callback for
  the other two. Flutter's `ChoiceChip` renders a `null` `onSelected` as
  visually dimmed and non-interactive automatically — no new widget.
- `_buildBody`'s existing `_scope == SearchScope.myNotes` branch was
  **kept, not deleted** — it is now a defensive fallback of the same
  kind the `_mode != SearchMode.search` check already was (unreachable
  via UI, kept as a safety net rather than trusted to never matter).
  Explained inline; nothing about its behavior changed.
- Doc comments updated in three places (class-level, `_scopeLabel`, and
  the `_buildBody` guard) to record *why*, appending a new "Sprint
  R3b.1" note rather than rewriting the historical R1.1 comment — this
  matches the file's existing convention of layering sprint notes
  rather than erasing prior ones.

### Verified against the running behavior, not just the diff

Re-read the edited file after applying the change: `_scope` is
initialized to `SearchScope.all` and, with `myNotes`'s `onSelected` now
`null`, has no code path left that can set it to `myNotes`. The
"unreachable branch" claim is therefore exact, not aspirational.

## 2. Objective 2 — internal roadmap references removed

### Swept for the pattern, not just the three known instances

Grepped `lib/l10n/` and `lib/` for `Bước [0-9]`, `Step [0-9]`,
`Sprint [0-9]`, `Phase [0-9]`, and `giai đoạn [A-Z0-9]` to check for
user-facing leaks beyond the three tiles already known. Found one
additional family — the four `placeholder{Home,Quran,Study,Stats}` keys
in all three `.arb` files, which also say `"Bước N sẽ..."`. **Not
touched**: these keys have zero call sites in real feature code (only
their own `.arb`/generated-accessor definitions reference them — same
finding the Product Readiness Review and R3b plan already recorded as
Group D1). Since nothing in the shipped app currently displays them,
they are a dead-code / l10n-hygiene item, not a live "internal roadmap
reference reaching a user" — out of this task's stated objective, and
explicitly Group D's job in the full plan, not Group B's. Left for that
pass.

### Profile screen — three tiles, two different fixes

[`profile_screen.dart`](../../lib/features/profile/presentation/profile_screen.dart):

- **B1 ("Thông tin cá nhân" / Personal info)**: `l10n.comingInStep(10)`
  → `l10n.comingSoon`. Tile kept, disabled, generic label.
- **B3 ("Đồng bộ" / Sync)**: `l10n.comingInStep(11)` → `l10n.comingSoon`.
  Same treatment.
- **B2 ("Mục tiêu" / Goal)**: tile **removed entirely** — not relabeled.

### B2 needed a different fix than B1/B3, explained

The task's objective 2 is phrased in terms of relabeling step
references to "user-oriented language." Applying that literally to B2
— swapping `comingInStep(8)` for `comingSoon` — would have produced a
tile reading "Goal · Coming soon." That is still false: Daily Goal is
shipped and working (`lib/features/stats/data/daily_goal_providers.dart`,
`daily_goal_store.dart`, `daily_goal_dialog.dart`, all live and wired
into the Stats screen — re-confirmed this pass, not assumed from the
prior design review). Relabeling would have replaced one false claim
("not built until Step 8") with another false claim ("not built yet, in
general") on a tile for a feature that already works. That fails
objective 2's own underlying goal — user-oriented, *honest* language —
even though it would have matched the literal instruction pattern given
for B1/B3.

Removing the tile is the only option that makes the Goal claim true:
the feature isn't "coming soon," it already exists, reachable from
Stats, and Profile simply stops making a claim about it at all. This
mirrors the design review's own §2 recommendation for B2, re-verified
here against current code rather than re-stated from that document.

The class-level doc comment was updated to record this reasoning
in-place, so a future reader doesn't wonder why B2 got a different
treatment from B1/B3 sitting two lines above it in git history.

### One key now orphaned, not removed here

`comingInStep` (parameterized, `"Sẽ xây dựng ở Bước {step}"` / `"Coming
in Step {step}"` / Arabic equivalent) had exactly 3 call sites, all in
`profile_screen.dart`. After this change it has zero. **Not removed**
in this pass — l10n key retirement is the same class of hygiene work as
D1's `placeholder*` keys, explicitly sequenced as Group D in the full
plan, not part of either objective given for R3b.1. Flagged here so it
isn't lost: a future pass (D1, or a combined D1+`comingInStep` cleanup)
should grep-confirm zero references and retire it from all 3 `.arb`
files together.

## 3. Accessibility

- The My Notes chip's disabled state is communicated the same way the
  AI segment's already is: Flutter's built-in disabled-widget semantics
  (`ChoiceChip` with `onSelected: null`) plus a `tooltip` carrying
  `l10n.comingSoon` — no bespoke accessibility work needed, no new gap
  introduced. `search_accessibility_test.dart`'s existing touch-target
  and RTL assertions were not affected — that file asserts geometry
  (chip Y-position relative to other elements) and did not test
  interactivity, so it required no changes (confirmed by re-reading it
  this pass, not assumed).
- Profile's three `ListTile`s were already `enabled: false`, which
  Flutter's semantics tree already announces correctly; removing B2
  and relabeling B1/B3 changes only the announced subtitle text, not
  the disabled-state mechanism.

## 4. Localization

- Zero new l10n keys added. Both changes reuse existing keys
  (`comingSoon`, already defined in `app_vi.arb`/`app_en.arb`/`app_ar.arb`)
  across all 3 locales — verified present in all three files before
  using them, not assumed from the `vi` file alone.
- `profileGoal` (the Goal tile's title string) is **not** orphaned by
  B2's removal — it's still used by `daily_goal_dialog.dart` and
  `home_screen.dart` for the real, shipped Goal feature (grep-verified
  this pass). Only the *tile* that misused it in Profile was removed.
- `comingInStep` orphaned but not removed — see §2.

## 5. Confirmed untouched (per explicit instruction)

Re-checked after implementation, not assumed from memory:

```
git status --short -- lib/features/quran/ lib/features/flashcards/ \
  lib/features/lexicon/ lib/l10n/*.arb
```

returned nothing — no AI Toggle code (`SearchMode`/segment logic
unchanged beyond the doc-comment note), no Flashcards files, no
Basmalah files (`basmalah.dart`, `reading_screen.dart`,
`reading_position_store.dart`, `audio_controller.dart` all untouched),
no `SearchScope` enum or scope-row structure change, and no `.arb` key
additions or removals (only two existing values in two existing string
call sites changed). The only production files modified are
`search_screen.dart` and `profile_screen.dart`, exactly the two
surfaces the objectives named.

## 6. Test changes — every change explained

**No test was deleted.** Two tests were touched, one modified and one
added, both in `test/search_screen_test.dart`; zero changes were needed
in `test/search_accessibility_test.dart` or anywhere else (confirmed by
grep for `myNotes`/`Scope`/`ChoiceChip` across `test/` before and after,
per the design review's own §2 note that this is where churn was
expected).

| File | Change | Why |
|---|---|---|
| `search_screen_test.dart` — `'hiển thị 3 scope chip...'` | Removed the one assertion `expect((chips[2].label as Text).data, 'Ghi chú của tôi')` from this test. | The label text this assertion checked no longer exists — it's now `'Ghi chú của tôi · Sắp ra mắt'`. The UI element (the chip itself) still exists and is still asserted elsewhere in the same test (`chips, hasLength(3)`, `chips[2].selected == false`), so this is a **narrowing edit**, not a deletion — the stale sub-assertion was moved into a new, more specific test rather than dropped. |
| `search_screen_test.dart` — new test `'Sprint R3b.1 — "Ghi chú của tôi" khoá...'` | Added. Asserts the new label text, asserts `chips[2].onSelected` is `null` (proving the chip is genuinely disabled, not just relabeled), taps the chip, and re-reads the chip list afterward to assert selection state didn't change **and** that the screen's real content (the empty-state title) is still present — i.e., explicitly proves the blank-body bug is gone, not just that the label changed. | This is the test that directly exercises the objective-1 fix. Without it, nothing in the suite would catch a regression back to a selectable, blank-rendering chip. |

No test exists for `profile_screen.dart` (confirmed by grep — no
`profile_screen_test.dart` file and no other test file references
`profileGoal`, `profilePersonalInfo`, `profileSync`, `comingInStep`, or
`ProfileScreen`). This is a **pre-existing coverage gap**, not something
this task introduced or was asked to close — flagged already in
`PHASE3_SPRINT_R3B_DESIGN_REVIEW.md` §2 ("could not confirm whether
`profile_screen_test.dart` exists"). Confirmed here: **it does not.**
B1/B2/B3 shipped with zero regression protection before this change and
have zero after it. Recommend a future task add basic coverage
(disabled-tile presence/count, absence of "Goal," absence of the string
"Step") — out of scope for R3b.1 itself since the objectives here were
UI honesty fixes, not test-debt payoff, but worth naming so it isn't
silently lost.

## 7. Gate results

```
flutter analyze --fatal-infos
...
No issues found! (ran in 26.2s)
```

```
flutter test
...
+803: All tests passed!
```

Baseline was 802 (last recorded in `REPOSITORY_BOUNDARY_UPDATE_REPORT.md`
and unchanged since). **+1**, matching exactly the one new test added in
§6 — no other count movement, confirming no test was silently dropped
alongside the one intentional narrowing edit.

## 8. What Priority Group 2+ still owns

Unchanged by this task, listed for continuity, not actioned:

- **A1** ("Hỏi AI" segment) — design review recommends Remove; not
  touched here per explicit instruction.
- **A3/A4/A5** (scope-row duplication, placeholder chip rows) — Search
  scope architecture and the empty-state placeholders were both out of
  scope here.
- **C1–C3** (Lexicon-dependent Flashcard/Smart-Deck surfaces) —
  untouched, Flashcards explicitly excluded.
- **Basmalah** — assessed only in the design review, not implemented;
  still not implemented.
- **D1** (`placeholder*` keys) and the now-also-orphaned `comingInStep`
  — both hygiene, both deferred to Group D as originally sequenced.

---

R3B.1 COMPLETE — Priority Group 1 only. Not committed, not pushed.
