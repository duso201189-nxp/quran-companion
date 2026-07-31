# G8 Decomposition — re-analyzed against current `main`

Read-only analysis. No code changed, no commits, no rebases, no
cherry-picks, no branch modified. Verified against `origin/main` at
`17b92e1` (`Merge pull request #3 from .../core/reliability-layer`,
itself on top of `6ab2959`, `Merge pull request #2 from
.../ci/repository-boundary-core-gate` — both checked directly against
`origin/main`'s tree before writing anything below, not assumed from
the task's own status summary).

## The finding that changes this analysis

The prior G8 documents (`G8_FEATURE_MATRIX.md`,
`G8_SPLIT_PLAN.md`, `G8_RELEASE_SEQUENCE.md`) computed dependencies by
diffing `d4976b0` against **its own parent commit** — which already
contains every `sprint1-my-library` commit back through Sprint 7
(`RELEASE_INVENTORY.md` groups G2, G4, G5, G6, G7: My Library, Search
Foundation, Sprint 8 stats/Khatm/bookmarks, Sprint 9 daily goal, Sprint
10 learning engine). That was a correct analysis of `d4976b0` in
isolation. It is **not** a correct description of what's needed to
merge those pieces onto `main` — because `main` never received G2,
G4, G5, or G6, and only received part of G7's antecedents indirectly.

Checked directly, not assumed:

```
lib/features/khatm    : 0 files on main
lib/features/learning : 0 files on main
lib/features/library  : 0 files on main
lib/features/quiz     : 0 files on main
lib/features/search   : 0 files on main
lib/features/stats    : 2 files on main (pre-Sprint-8 shape only)
```

And the one schema table check that makes this concrete: `d4976b0`'s
diff to `user_tables.dart` inserts two new tables
(`FlashcardDecks`, `Flashcards`) **between** the existing `SrsCards`
and `QuizResults` table classes. `origin/main`'s `user_tables.dart`
has neither `SrsCards` nor `QuizResults` nor `StudySessions` nor
`KhatmCycles` nor `BookmarkCollections` — only `Bookmarks`,
`Highlights`, `Notes`, `Favorites`, `AyahStatuses`. **This diff cannot
apply to `main` as a patch; the lines it expects to find aren't
there.** The same check against `quran_repository_impl.dart` (the one
feature directory that does exist on `main`, 25 files) also shows
real divergence — `main`'s version predates a `getAyahsByIds`/
`_headersForIds` refactor that `d4976b0`'s parent already had.

**Consequence: most of G8's remaining candidates are not blocked by
each other. They're blocked by an entirely different, larger backlog
— the pre-G8 features that were never merged — which this
G8-scoped analysis had no reason to surface until asked to check
against `main` directly.**

---

## Subsystem-by-subsystem re-analysis

### P2 — Shared accessibility widgets
| | |
|---|---|
| Purpose | `EmptyStateBanner`, `LoadingState`, `SectionHeader`, `StatCard` |
| Files | `lib/shared/widgets/{empty_state_banner,loading_state,section_header,stat_card}.dart` (4 new files) |
| Dependencies | **None.** Every import checked individually: `package:flutter/material.dart` only, nothing else |
| Estimated review size | 232 lines, 4 files + 1 test file |
| Merge independently? | **Yes** |
| Why | Purely additive Flutter widgets with zero data-layer coupling. `lib/shared/` already exists on `main` (5 unrelated files: `app_scaffold.dart`, three `utils/`) — no name collision, nothing to reconcile. This is the **only** remaining G8 candidate with no dependency on the missing pre-G8 feature set. |

### P3 — Database schema migration
| | |
|---|---|
| Purpose | New tables backing Flashcards/Lexicon/Analytics |
| Files | `lib/core/database/{app_database.dart,tables/content_tables.dart}`, `lib/core/database/user/{user_database.dart,user_tables.dart}` + generated `.g.dart` |
| Dependencies | **G5, G6, G7 (`StudySessions`, `KhatmCycles`, `BookmarkCollections`, `SrsCards`, `QuizResults` tables must exist first)** — not P1, not P2, and not anything internal to G8 |
| Estimated review size | Unknown as a standalone diff — the 259/8,624-line split measured earlier described a patch that inserts into tables `main` doesn't have. Re-measuring requires first knowing what schema state it would apply to |
| Merge independently? | **No** |
| Why | Confirmed by direct diff inspection: the patch's context lines reference `SrsCards`/`QuizResults`, neither present on `main`. Applying it requires the schema state those groups establish to exist first — this is a hard, mechanical blocker, not a process preference. |

### P4 — Reliability retrofit into existing repositories
| | |
|---|---|
| Purpose | Adopt the (now-merged) reliability layer into khatm/learning/library/quiz/quran/stats repositories |
| Files | 7 files originally (`RELEASE_RECOVERY` era analysis) |
| Dependencies | P1 (**satisfied** — merged in PR #3) **and** the existence of the repositories themselves — G5 (khatm, part of stats), G6, G7 (learning, quiz) |
| Estimated review size | N/A as originally scoped |
| Merge independently? | **No** |
| Why | Confirmed directly: `khatm`, `learning`, `library`, `quiz` are **0 files on `main`** — there is nothing to retrofit. Even the one partially-present target, `quran_repository_impl.dart`, differs from the version this retrofit's diff expects (`main` predates a refactor `d4976b0`'s parent already has), so even that slice wouldn't apply cleanly. P1 landing did not unblock P4 the way the pre-merge analysis expected — it removed only one of several blockers. |

### F1 — Lexicon
| | |
|---|---|
| Purpose | Word-by-word morphology/lexicon |
| Files | `lib/features/lexicon/` (11), `tool/lexicon/` (13) |
| Dependencies | P1 (**satisfied**), P3 (**not satisfied**) |
| Estimated review size | 2,098 lines (unchanged from prior measurement — these files themselves haven't moved) |
| Merge independently? | **No** |
| Why | No dependency on any other new feature (confirmed in the original analysis and unchanged), but needs P3's tables, and P3 is itself blocked. Closest of the eight feature verticals to being ready — the moment P3's real prerequisite chain clears, this is next. |

### F2 — Flashcards
| Dependencies | F1, `learning` (**0 files on `main`**), P1, P2, P3 | **Merge independently? No** — blocked on a missing feature directory, not just F1/P3. |

### F3 — Analytics
| Dependencies | F2, F1, `learning`/`search`/`stats` (**all missing or partial on `main`**), P2 | **No** |

### F4 — AI Tutor
| Dependencies | F3, F2, `search` (**0 files on `main`**), P2 | **No** |

### F5 — Learning Journey
| Dependencies | F4, `search` (**missing**), P2 | **No** |

### F6 — Smart Learning
| Dependencies | F4, F5, `search` (**missing**), P2 | **No** |

### F7 — Read Model
| Dependencies | F4, F5, F6 | **No** — inherits every blocker above |

### F8 — Learning Session
| Dependencies | F2, `learning`/`quiz` (**both missing on `main`**) | **No** |

---

## Recommended safest merge order

**Two tracks, not one**, because this analysis found two different
kinds of blocker:

**Track A — genuinely G8-internal, resume once P2 lands:**
```
PR #4  P2  Shared accessibility widgets   ← ready now
```
Nothing else in G8's original candidate list follows P2 directly. P3
was the next step in the original plan; it is not next in reality.

**Track B — the newly-surfaced prerequisite backlog**, in the order
`RELEASE_INVENTORY.md` already established for it (independent of this
document, cross-referenced here rather than re-derived):
```
G2  My Library
G4  Search Foundation
G5  Sprint 8 — Reading Stats, Khatm, Bookmark Collections
G6  Sprint 9 — Daily Goal, Revision Queue, Streak
G7  Sprint 10 — Learning Engine (Scheduler, Review Session, Quiz)
```
Only after Track B lands does P3 become a diff that actually applies
to `main` — at which point P4, F1, and the rest of G8's dependency
chain resume exactly as `G8_RELEASE_SEQUENCE.md` originally laid out,
unchanged, because that internal ordering was never wrong — it was
just missing the ground it assumed it was standing on.

This is not a recommendation to open PRs for G2/G4–G7 as part of this
task — it's the honest statement of what actually sits between "P2
merges" and "P3 becomes possible," surfaced because the task asked for
re-analysis against the current repository, not against the
previously-assumed one.

---

## Smallest independent PR

**P2 — Shared accessibility widgets.** 4 files, 232 lines, zero
dependencies of any kind, verified by reading every import rather than
assumed unchanged from the pre-merge analysis.

## Highest-risk subsystem

**P3 — Database schema migration.** Already flagged as high-risk in
the original G8 analysis for touching both databases; now confirmed to
carry a second, larger risk — it is not a self-contained patch at all
against `main`'s actual current schema, and won't become one until
five other feature groups land first. Treating it as "next after P2"
without this finding would have produced a PR that fails to apply,
not merely a PR that needs careful review.

## Best candidate for PR #4

**P2.** The only subsystem in this document's table marked "Merge
independently? Yes." Same shape as PR #2 and PR #3 before it —
purely additive, zero dependency, small enough to review in one
sitting — and, unlike every other remaining G8 candidate, actually
buildable against `main` as it exists right now, not against a
`main` this analysis had been implicitly assuming.

---

READY FOR PR #4
