# Phase 3 — Sprint R3b.2 Implementation Report

Implements **Priority Group 2 only** of `PHASE3_SPRINT_R3B_PLAN.md`, per
`PHASE3_SPRINT_R3B_DESIGN_REVIEW.md` and building on
`PHASE3_SPRINT_R3B_1_REPORT.md`. Not committed, not pushed.

**Scope actually touched**: removed the "Hỏi AI" (Ask AI) segment (A1)
and the entire scope-chip row (A2/A3) from Search, per the design
review's own recommendation in both cases. Flashcards, Basmalah,
Lexicon, Profile, and Daily Goal were not touched this turn — see §6.

---

## 1. Objective 1/3 — Search cleanup, Design Review decisions used exactly

Both removals in this sprint are the design review's own explicit
recommendations, not re-derived or reinterpreted here:

- **§4 of the design review**: *"Recommend: Remove"* for the AI toggle
  — dominates "Hide" outright, and the gap between "labelled soon" and
  "gated behind two unbuilt releases" was judged too large for a public
  beta's most prominent Search control.
- **§3 of the design review**: *"Remove"* for the scope-chip row — of
  the three chips, exactly one (My Notes) had a distinct code path, and
  it was already disabled in R3b.1; the other two (All/Qur'an) are
  provably identical, per the removed code's own comment
  (`"'Tất cả' vẫn dùng engine Qur'an vì đó là domain duy nhất có dữ liệu
  hôm nay"`).

No new judgment calls were made this sprint — both decisions were
already settled in the design review; this task only implements them.

## 2. Objective 2 — AI toggle removed, no flag, no dead code

**Removed, not hidden.** Deleted from
[`search_screen.dart`](../../lib/features/search/presentation/search_screen.dart):

- `enum SearchMode { search, ask }` and its 8-line doc comment.
- The `_mode` state field.
- The `SegmentedButton<SearchMode>` widget and its `Align` wrapper in
  `build()`.
- The `_mode != SearchMode.search` half of `_buildBody`'s guard
  condition (see §4 — the whole guard is gone, not just this half).

No compile-time flag, no `if (false)` branch, no commented-out widget.
`grep` for `SearchMode` in `lib/` after the change returns **zero**
matches in code — the only surviving reference is a historical mention
in the class-level doc comment explaining *why* it was removed and
where to look for the reasoning (`PHASE3_SPRINT_R3B_DESIGN_REVIEW.md`
§4, this report), consistent with this file's established convention
of keeping a compressed trail of past sprints rather than either
leaving stale prose or erasing history outright.

`l10n.searchAskLabel` ("Hỏi AI") lost its only call site. Confirmed via
grep (zero references anywhere in `lib/`) and **removed** from all
three `.arb` files (§5) — this key becomes unreachable *in this
sprint*, which is exactly the condition the task set for l10n key
removal.

## 3. Objective 3 — scope row: the approved decision was removal, implemented

Removed, also from `search_screen.dart`:

- `enum SearchScope { all, quran, myNotes }` and its doc comment.
- The `_scope` state field and the `_scopeLabel` helper method (added
  in R3b.1 specifically to label the then-disabled My Notes chip — now
  removed along with the chip it labelled).
- The horizontal `SingleChildScrollView`/`Row` of `ChoiceChip` widgets
  in `build()`, including the R3b.1 disabled-chip treatment
  (`onSelected: null`, `tooltip`) — that fix is now superseded by this
  sprint's decision to remove the row it lived in, not left behind as
  dead code.
- The `_scope == SearchScope.myNotes` half of `_buildBody`'s guard.

`_buildBody`'s guard clause (`if (_mode != SearchMode.search || _scope
== SearchScope.myNotes) return const SizedBox.shrink();`) is **deleted
in full**, not narrowed — with both enums gone there is no state left
to gate on. Search now runs unconditionally against Qur'an content,
matching what the removed code's own comments already said was the
only real behavior. `build()`'s body simplified from a `Column`
wrapping three children (mode row, scope row, `_buildBody`) to
`_buildBody(l10n)` alone — the wrapping `Column` was removed too, since
a single-child `Column` was unneeded structure once its siblings were
gone.

`l10n.searchScopeMyNotes` ("Ghi chú của tôi") lost its only call site
(it was added for R3b.1's disabled-chip label, never used elsewhere) —
confirmed via grep, **removed** from all three `.arb` files (§5).

`l10n.filterAll`, `l10n.tabQuran`, and `l10n.searchLabel` were also used
in the removed scope row and mode segment, but **kept** — each still
has live call sites elsewhere (`filterAll` in
`surah_list_screen.dart`'s own filter chips; `tabQuran` in
`app_scaffold.dart`, `home_screen.dart`, `surah_list_screen.dart`;
`searchLabel` as a tooltip in `home_screen.dart` and
`surah_list_screen.dart`) — verified by grep before deciding, not
assumed from the removed usage alone.

## 4. What was deliberately left alone

**A4/A5** (the `_PlaceholderChipRow` grey blobs under "Gần đây"/"Gợi ý"
in `SearchEmptyState`) were **not touched**. Neither objective 1
("Search cleanup... Design Review decisions") nor objectives 2/3
(explicitly AI toggle and scope row only) named them, and the original
plan's own sequencing (`PHASE3_SPRINT_R3B_PLAN.md` §8) places them in a
later step than A1/A3. `SearchEmptyState`, `_PlaceholderChipRow`, and
their l10n keys (`searchEmptyRecentSectionTitle`,
`searchEmptySuggestedSectionTitle`) are unchanged — confirmed by
`git status` showing no diff in that region of the file.

## 5. Localization

Two keys retired — `searchAskLabel` and `searchScopeMyNotes` — removed
from `app_vi.arb`, `app_en.arb`, `app_ar.arb`, then `flutter gen-l10n`
run to regenerate the accessor files (`app_localizations*.dart`).
Verified after regeneration: grep for both key names across
`lib/l10n/` returns nothing.

Three keys kept despite losing their usage *in this file* —
`filterAll`, `tabQuran`, `searchLabel` — because each has independent
live call sites elsewhere (§3). This is the intended reading of "remove
obsolete l10n keys only if they become unreachable *in this sprint*":
unreachable means zero call sites app-wide, not zero call sites in the
file being edited.

No accessibility-facing strings changed in content — the two removed
keys were removed, not reworded; nothing users can still see had its
wording altered by this sprint.

## 6. Confirmed untouched (per explicit instruction)

```
git status --short
```

shows exactly two production files touched by this sprint:
`search_screen.dart` and the three `.arb` files plus their generated
`app_localizations*.dart` counterparts (the l10n regeneration touches
all locale files even though only `vi`/`en`/`ar` source keys changed,
since the generator rewrites each accessor file as a whole).

`profile_screen.dart` also shows modified in `git status` — this is
**carried over from R3b.1** (still uncommitted per that task's own "Do
NOT commit" instruction), not touched by this task. No edit tool was
invoked against it this session; confirmed by re-reading this session's
own action log rather than assumed from silence.

No Flashcards file, no `basmalah.dart`/`reading_screen.dart`/
`reading_position_store.dart`/`audio_controller.dart` (Basmalah/audio
architecture), no `lexicon/` file, and no Daily Goal file
(`daily_goal_providers.dart`/`daily_goal_store.dart`/
`daily_goal_dialog.dart`) appear in the diff — all five exclusions in
objective 4 hold.

## 7. Test changes — every change explained

Net: **11 tests removed, 0 net test files deleted, 1 test rewritten to
a smaller assertion** (not counted as removed — same test, narrower
scope, explained separately below). All removals fall under "remove
obsolete tests only if the removed UI no longer exists" — every one of
them exercised `SearchMode`, `SearchScope`, `SegmentedButton<SearchMode>`,
or `ChoiceChip` widgets/enums that no longer exist in `search_screen.dart`
after this sprint, confirmed individually before removal, not
batch-assumed.

| File | Removed | Why |
|---|---|---|
| `search_screen_test.dart` — group `'Task 7.1.6 — chuyển đổi Tìm kiếm / Hỏi AI'` | 2 tests | Both assert on `SegmentedButton<SearchMode>` and the "Hỏi AI" segment directly — the widget and enum are gone. |
| `search_screen_test.dart` — group `'Task 7.1.7 — Scope Chips'` | 3 tests | All three assert on `ChoiceChip`/`SearchScope`, including the test added in R3b.1 to prove the My Notes chip was disabled — that chip no longer exists, so the test it verified no longer applies. Superseded by this sprint's removal, not left behind. |
| `search_screen_test.dart` — `'không đụng Mode/Scope, không lỗi'` (inside Task 7.1.8) | 1 test | Asserted `SegmentedButton`/`ChoiceChip` state as a side-effect check within an Empty State test; the other two tests in that group (title/subtitle/placeholder chips, type-to-dismiss) are untouched and still valid — only this one sub-test targeted the removed controls. |
| `search_responsive_test.dart` — `'${entry.key}: Mode Switch + Scope Chips dựng được, không lỗi'` | 4 tests (one per breakpoint in the `_breakpoints` loop) | Directly asserted `find.byType(SegmentedButton<SearchMode>)`/`find.byType(ChoiceChip)` at each of 4 viewport widths — the widgets don't exist to find. The other three per-breakpoint tests in the same loop (Empty State, Results preview, Loading+Error) are untouched. |
| `search_dark_mode_test.dart` — `'Mode Switch: nhãn "Ask" (đã khoá) vẫn hiển thị, đọc được ở dark mode'` | 1 test | Asserted the "Hỏi AI" segment's label and disabled state render correctly in dark mode — the segment is gone. |

**Modified, not removed** — `search_accessibility_test.dart`'s reading-order
test (`'ô tìm kiếm -> Mode -> Scope -> nội dung thân màn hình'`): it
asserted a 4-point vertical order (query field < mode switch < scope
chips < empty state). With two of those four points gone, it now
asserts the 2-point order that remains (query field < empty state) and
its description was updated to say so explicitly, including a note that
the two intermediate checks were removed because their subjects no
longer exist — not silently dropped. This is a **genuine, small
reduction in what this specific test can verify** (it can no longer
prove *where* removed elements would have sat relative to each other,
because there's nothing left to check that against) — named here
rather than left implicit, since the task requires explaining removed
tests and this is the same class of information even though the test
itself wasn't deleted.

No test file was deleted in its entirety — every change above is a
group-level or single-test-level removal within a file that still has
other, valid tests.

## 8. Gate results

```
flutter analyze --fatal-infos
...
No issues found! (ran in 8.5s)
```

```
flutter test
...
+792: All tests passed!
```

Baseline entering this sprint was 803 (per `PHASE3_SPRINT_R3B_1_REPORT.md`
§7). **−11**, matching exactly the sum counted in §7 (2 + 3 + 1 + 4 + 1
= 11) — no test count movement beyond what's itemized above.

## 9. What Priority Group 3+ still owns

Unchanged by this task, listed for continuity, not actioned:

- **A4/A5** (Recent/Suggestions placeholder chip rows) — deliberately
  deferred, see §4.
- **C1–C3** (Lexicon-dependent Flashcard/Smart-Deck surfaces) —
  untouched, Flashcards explicitly excluded again this sprint.
- **Basmalah** — still assessment-only per the design review; no
  implementation.
- **D1** (`placeholder*` keys) and **`comingInStep`** (orphaned by
  R3b.1, see that report §2) — both still deferred to Group D.

---

R3B.2 COMPLETE — Priority Group 2 only. Not committed, not pushed.
