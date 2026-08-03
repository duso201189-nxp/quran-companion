# Phase 3 — R3b Close-out Patch Report

Implements the small follow-up sprint `PHASE3_RELEASE_TRACKING_FINAL_REPORT.md`
§3 recommended: the last two Honest Surface Area items named in
`PHASE3_SPRINT_R3B_PLAN.md` (A4/A5, D1) that R3b.1–3 deliberately left
open. Not committed, not pushed.

---

## 1. `_PlaceholderChipRow` — removed, along with the sections it sat in

**Decision, restated from the final report rather than re-derived**:
Remove, not relabel or leave as intentional scaffolding. That trade-off
was already weighed in `PHASE3_SPRINT_R3B_PLAN.md` and re-confirmed in
`PHASE3_RELEASE_TRACKING_FINAL_REPORT.md` §3 with nothing new to change
the inputs — implemented here, not re-litigated.

**Scope note, not in the original two-item list but necessary for a
coherent result**: removing only the `_PlaceholderChipRow` widget and
leaving the "Gần đây" ("Recent") / "Gợi ý" ("Suggestions") headings
standing alone above empty space would have been *worse* than the
starting state — a real, accessible heading pointing at nothing is a
new kind of dishonest surface, not a fix for the old one. Both headings
and both chip rows were removed together, matching
`PHASE3_SPRINT_R3B_PLAN.md`'s own original scoping of this item
("A4 — Recent chips **+ heading**", "A5 — Suggestions chips **+
heading**" — both explicitly "Remove," not "remove chips only").
`SearchEmptyState` now shows exactly what the plan said would remain
useful: icon, title, and the typing-hint subtitle.

### What changed in `search_screen.dart`

- `_PlaceholderChipRow` class deleted entirely (was the only caller of
  `ExcludeSemantics`+`Wrap` for this purpose; no other widget shared
  it).
- The two `Semantics(header: true, child: Text(...))` blocks for the
  Recent/Suggestions section titles, and the two `_PlaceholderChipRow`
  instances beneath them, removed from `SearchEmptyState.build()`.
- Doc comments updated in place (`SearchScreen`'s class comment, Task
  7.1.8's note; `SearchEmptyState`'s own comment) to record that these
  sections existed from Sprint 7.1 through R3b.1–3 and were removed at
  this patch, rather than silently deleting the historical record —
  consistent with this file's established convention throughout R3b.

## 2. `placeholder*` l10n keys — removed, plus two more found unreachable as a direct consequence

**Objective 2's literal scope** (`placeholderHome`, `placeholderQuran`,
`placeholderStudy`, `placeholderStats` — 4 keys × 3 locales, 0 real
call sites, confirmed again immediately before removal): removed from
all three `.arb` files, then `flutter gen-l10n` re-run to regenerate
the four `app_localizations*.dart` accessors. Not hand-edited.

**Two additional keys, not named `placeholder*`, removed for the same
reason (`searchEmptyRecentSectionTitle`, `searchEmptySuggestedSectionTitle`)**:
these were the "Gần đây"/"Gợi ý" heading strings — their only call
site was the two `Semantics`/`Text` blocks removed in §1. Once that
code was gone, both keys had zero remaining references, the exact
"unreachable" test objective 2 sets, just not matching the
`placeholder*` name pattern literally. Flagged here rather than left
implicit: objective 2's wording named a pattern, not a rule about
*why* something counts as removable — the operative test throughout
this whole engagement's l10n cleanups (R3b.1, R3b.2) has been "zero
call sites," not "matches this string prefix," so removing these two
alongside the four named keys is consistent with precedent, not scope
creep. Grep-confirmed zero references in `lib/` before deletion, for
both keys, independently of the four `placeholder*` keys.

**Not touched**: `l10n.comingInStep` — flagged as orphaned back in
`PHASE3_SPRINT_R3B_1_REPORT.md` and still unreachable today, but it
does not match `placeholder*` and was not part of either the
`_PlaceholderChipRow` removal's consequences or objective 2's literal
list. Left exactly as open as the final report described it — a
correction of one boundary (unreachable-because-of-this-removal) is
not license to also sweep a pre-existing, differently-caused gap into
the same patch.

## 3. Tests removed or changed — every one explained

**Net: 1 test removed, 2 tests trimmed (assertions removed, tests
kept), 0 tests added.**

| File | Change | Why |
|---|---|---|
| `test/search_screen_test.dart` — `'hiển thị tiêu đề, gợi ý gõ, và 2 khu vực placeholder'` | Renamed to `'hiển thị tiêu đề và gợi ý gõ'`; removed assertions for `'Gần đây'`/`'Gợi ý'` text and the two `Key('search-empty-recent-chips')`/`Key('search-empty-suggested-chips')` `Container` counts. Title/subtitle assertions kept unchanged. | The removed assertions checked widgets that no longer exist — not a weakened test, a test whose subject shrank along with the UI it verifies. |
| `test/search_screen_test.dart` — `'gõ chữ -> Empty State biến mất; xoá hết -> quay lại'` | Removed one line, `expect(find.text('Gần đây'), findsNothing)`, from inside an otherwise-unchanged test. | This assertion was already checking an absence; after §1, "Gần đây" doesn't exist anywhere in the widget tree, on any screen, ever — the assertion couldn't fail even if the surrounding logic were broken, so it verified nothing. Removed rather than left as dead weight; the test's real assertions (title disappears on typing, reappears on clear) are untouched. |
| `test/search_accessibility_test.dart` — `'Empty State: 3 tiêu đề đều là header semantics'` | Renamed to `'Empty State: tiêu đề chính là header semantics'`; loop over 3 labels (title, "Gần đây", "Gợi ý") replaced with a single direct check on the title. Subtitle-is-not-a-header check kept unchanged. | Same reasoning as the first `search_screen_test.dart` change — two of the three things this test checked no longer exist. `tester.getSemantics(find.text('Gần đây'))` would now throw (element not found), not merely return a false result, so leaving it unmodified would have been an outright test failure, not a silent pass. |
| `test/search_no_results_state_test.dart` — `'khác biệt trực quan với SearchEmptyState: không có 2 khu vực "Gần đây"/"Gợi ý"'` | **Removed entirely.** | This test's entire stated purpose — proving `SearchNoResultsState` doesn't show the "Gần đây"/"Gợi ý" sections that `SearchEmptyState` has — is moot once `SearchEmptyState` doesn't have them either. There is no longer a real distinction being verified; the assertions (`findsNothing` for text that exists nowhere in the app) would pass trivially regardless of whether `SearchNoResultsState` were implemented correctly or not, which is the definition of a test that no longer tests anything. Its one incidental assertion (`Icons.travel_explore_outlined` absent) was bundled into a test named for the now-gone comparison, not a stated purpose of its own — inventing a new, differently-scoped test to preserve that one line would be adding test surface, not removing an obsolete one, and wasn't requested by objective 3. |

No test file was deleted in its entirety. Every change is traceable to
a widget or l10n key removed in §1/§2 — none was trimmed speculatively.

## 4. Gate results

```
dart format --output=none --set-exit-if-changed lib test
...
Formatted 352 files (0 changed) in 0.98 seconds.
```

```
flutter analyze --fatal-infos
...
No issues found! (ran in 8.0s)
```

```
flutter test
...
+792: All tests passed!
```

Baseline entering this patch was 793 — the count recorded in
`PHASE3_SPRINT_R3B_3_REPORT.md` §11 and unchanged through the two
subsequent tracking-only tasks (neither touched `lib/` or `test/`).
**−1**, matching exactly the one test removed in §3
(`search_no_results_state_test.dart`) — the other two files' changes
trimmed assertions inside surviving tests, which does not move the
test count.

## 5. Confirmed scope

```
git diff --stat -- lib/ test/
```

```
 lib/features/search/presentation/search_screen.dart | 87 ++++------------------
 lib/l10n/app_ar.arb                                  |  6 --
 lib/l10n/app_en.arb                                  |  6 --
 lib/l10n/app_localizations.dart                      | 36 ---------
 lib/l10n/app_localizations_ar.dart                   | 22 ------
 lib/l10n/app_localizations_en.dart                   | 22 ------
 lib/l10n/app_localizations_vi.dart                   | 22 ------
 lib/l10n/app_vi.arb                                  |  6 --
 test/search_accessibility_test.dart                  | 22 +++---
 test/search_no_results_state_test.dart               | 11 ---
 test/search_screen_test.dart                         | 17 +----
```

Eleven files, all inside the Search feature and its l10n — no other
screen, provider, or repository touched. `CHANGELOG.md`,
`RELEASE_DASHBOARD.md`, and `docs/release/RELEASE_PLAN_V1.md` still
show modified in the working tree, but that is carryover from the
prior release-tracking task, untouched by this one — confirmed by not
appearing in this task's own diff above.

## 6. What this closes, precisely

Per `PHASE3_RELEASE_TRACKING_FINAL_REPORT.md` §3's own framing, this
patch finishes the two items `PHASE3_SPRINT_R3B_PLAN.md` originally
scoped as A4/A5 and (the `placeholder*` portion of) D1 — not a new
epic, the tail end of one already substantially shipped. With this
patch:

- **Zero user-visible Search surfaces remain that look interactive or
  informative but aren't** — the last two (grey placeholder chips
  under real headings) are gone. `RELEASE_DASHBOARD.md`'s Critical-tier
  "Dead/dishonest UI affordances" entry can now read as fully, not
  "substantially," resolved once that document is next updated (not
  done here — this report is the input to that update, not the
  update itself, matching this task's "do not commit" scope and this
  engagement's pattern of not touching release tracking except when
  explicitly asked).
- **Still open, unaffected by this patch**: `l10n.comingInStep` (§2),
  and everything else `PHASE3_RELEASE_TRACKING_FINAL_REPORT.md` §5
  listed as out of scope (`PROJECT_INDEX.md`, `docs/adr/README.md`,
  the nine missing Decision Records, the repository-boundary threshold
  change's own tracking gap).

---

R3B CLOSE-OUT PATCH COMPLETE — not committed, not pushed.
