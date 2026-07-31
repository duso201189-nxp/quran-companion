feat(learning_session): wire Flashcards into the Learning Session module (G8 F8)

## Summary

Wires the already-merged Flashcards feature (F2) into the pre-existing
Learning Session module (`lib/features/learning_session/`, shipped
earlier via G7/PR #10), which previously tracked review/quiz activity
only. Adds a flashcard branch to the session controller's activity
tracking, renders `FlashcardReviewScreen` for flashcard sessions instead
of a placeholder, and shows a flashcard-completion stat on the summary
screen. **This is the last of the twelve groups in
`G8_DECOMPOSITION.md`** (P1–P4, F1–F8) — once this merges, the entire
original `d4976b0` mega-commit's own scope will be fully represented on
`main`.

## Scope

**12 files — 213 insertions(+), 18 deletions(-).**

| Area | Files |
|---|---|
| Learning Session core (modified, not new) | `learning_session_summary.dart`, `learning_session_controller.dart`, `learning_session_screen.dart`, `learning_summary_screen.dart` |
| l10n | `app_{vi,en,ar}.arb` + 4 generated `app_localizations*.dart` — 1 new key, `learningSummaryFlashcardCount` |
| Test | `learning_session_controller_test.dart` |

No new directories, no `router.dart` changes — Learning Session already
has its route from G7; this PR only retrofits its internals.
`lib/features/learning_session/` is byte-identical to `d4976b0`'s own
final state after this change (direct diff confirms zero remaining
delta).

## Dependencies: F6 and F7 both verified merged

Checked directly before starting — **F6 (PR #16) and F7 (PR #17) are
both genuinely merged** into `main`. Neither is a real dependency of F8
though: per `G8_DECOMPOSITION.md` §F8, this PR's only dependency is **F2
+ the pre-existing `learning_session`/`quiz` modules**, both already
merged. Branch is cut directly from current `origin/main`.

## A mechanical l10n conflict, resolved

Rebuilding this branch from current `origin/main` (rather than the older
base it was originally drafted against) surfaced one expected merge
conflict: F6 added 8 `smartLearning*` l10n keys near the same region of
the `.arb`/generated files where F8 adds its own 1 key. Resolved via the
same JSON-keyset merge technique used throughout this decomposition —
kept `origin/main`'s full keyset and added exactly F8's 1 key, then
regenerated the 4 generated `app_localizations*.dart` files via `flutter
gen-l10n` rather than hand-editing them. Final diff is unchanged from
F8's original scope: still exactly 12 files, 213(+)/18(-).

## Validation

| Check | Result |
|---|---|
| `dart format` (`lib`, `test`, `integration_test`) | 341 files, 0 changed |
| `flutter analyze --fatal-infos` | No issues found |
| Full suite (`flutter test test`) | **731/731 pass** |

## Dependencies

**F2 (merged, PR #13), pre-existing `learning_session`/`quiz` modules
(merged, PR #10), P1–P4 (all merged) — all satisfied.** No dependency on
F3–F7.

## Known limitations / follow-up

- A separate, already-identified and already-fixed gap exists in
  already-merged code: five Analytics (F3) test files were never
  extracted from `d4976b0` during F3's own pass. A complete,
  fully-gated fix exists on its own branch
  (`feat/f3-test-completion`, commit `55b8de3`) — deliberately kept
  separate from this PR so this diff stays exactly what its name says.
  See `G8_COMPLETION_REPORT.md` §3 for the full account.
