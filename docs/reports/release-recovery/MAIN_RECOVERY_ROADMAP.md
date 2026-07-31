# Main Recovery Roadmap — the backlog between PR #4 and P3

Read-only analysis. No code changed, no branch created, nothing
committed. Verified against `origin/main` at `17b92e1` (PR #2 and PR #3
both confirmed merged by reading the tree, not the task's status
summary alone) plus PR #4 (`ui/shared-accessibility-widgets`,
committed locally, not yet merged — treated as *ready*, not yet part of
`main`, per its own report).

## 1 — Every missing feature required before P3 becomes mergeable

`G8_DECOMPOSITION.md` established that P3's schema diff inserts new
tables between `SrsCards`/`QuizResults`, neither present on `main`.
Tracing exactly which commits create the tables P3 needs:

| Commit | Group | Tables added |
|---|---|---|
| `b41493c` (Sprint 8) | **G5** | `StudySessions`, `KhatmCycles`, `BookmarkCollections` |
| `fa8e358` (Sprint 10) | **G7** | `SrsCards`, `QuizResults` |

Neither commit applies to `main` standalone — both are themselves
incremental patches to `lib/core/database/user/user_tables.dart`
built on top of earlier changes to that same file. Tracing backward
through every commit between `main`'s current base and G8 that touches
either schema file or the feature directories G5/G7 depend on
surfaces the complete missing set — six commit groups, all originally
part of `sprint1-my-library`, none merged to `main`:

**G2 · My Library, G3 · Reading polish, G4 · Search Foundation, G5 ·
Sprint 8, G6 · Sprint 9, G7 · Sprint 10.**

Confirmed directly, not inferred from names: `lib/features/library`,
`khatm`, `learning`, `quiz`, `search`, `study`, `learning_session` are
**zero files** on current `main`; `stats` has only its pre-Sprint-8
shape (2 files).

## 2 — Dependency graph, from current `main`

Built from two kinds of evidence, kept distinct because they carry
different implications:

**A. Directory creation → extension pattern** (a later group modifies
files an earlier group created):
```
G2 creates lib/features/library/     (6 files)
G5 extends it                         (10 files) ── hard: G5 needs G2
G6 extends it further                 (3 files)  ── hard: G6 needs G2, G5
```

**B. Import-level dependency**, checked directly against the tree at
the tip of G7 (`394979d`), not assumed:
```
quran   → stats
stats   → khatm
study   → library
learning_session → learning, quiz
```
No cycle in either graph.

**C. Schema-file patch order** — the one that actually blocks P3.
`b41493c` (G5) and `fa8e358` (G7) both patch
`lib/core/database/user/user_tables.dart` **sequentially**: G7's diff
inserts `SrsCards`/`QuizResults` assuming G5's `StudySessions`/
`KhatmCycles`/`BookmarkCollections` are already present in that file.
Confirmed by direct inspection of both diffs' context lines. This
holds **even though G7's application code has zero import dependency
on G5** (`lib/features/learning`, `quiz`, `learning_session` import
nothing from `library`/`stats`/`khatm`, confirmed by grep) — the
dependency is at the shared-file patch level, not the feature level.
Worth stating precisely rather than rounding to "G7 needs G5" or "G7
is independent" — both are half-true.

**D. The `quran` file itself is touched by five of the six groups**
(G2, G3, G4, G5, G6) as successive incremental patches to the same
files (`quran_repository_impl.dart`, `quran_providers.dart`,
`user_content_repository_impl.dart`, reading-screen files). This was
already the concrete failure mode found in `G8_DECOMPOSITION.md` — a
version mismatch on this exact file is what proved P4's `quran` slice
doesn't apply cleanly to `main` either. The same risk applies to every
earlier group's `quran` touch: applying G5 before G2/G3/G4 risks the
identical class of failure.

**Combined graph:**
```
G2 ──┬─→ G5 ──→ G6
     │         (both extend library/stats/khatm G5 created)
     └─→ (quran incremental patch chain: G2 → G3 → G4 → G5 → G6)

G7 ── schema file requires G5 first; application code independent of all of it
```

## 3 — Independent mergeable PRs

Each of the six groups already exists as an atomic, previously-tested
commit from `sprint1-my-library`'s real history — none invented for
this roadmap. Proposed numbering continues from PR #4.

| PR | Group | Contents |
|---|---|---|
| **#5** | G2 | My Library: data layer, domain, screen, routing |
| **#6** | G3 | Reading-screen polish (Mushaf refactor, Basmalah fix) |
| **#7** | G4 | Search Foundation |
| **#8** | G5 | Sprint 8: Reading Stats, Khatm, Bookmark Collections |
| **#9** | G6 | Sprint 9: Daily Goal, Revision Queue, Streak |
| **#10** | G7 | Sprint 10: Learning Engine (Scheduler, Review Session, Quiz) |

Not proposing further internal splitting (the way G8 needed): each of
these was already reviewed, tested, and merged as one unit in
`sprint1-my-library`'s own history, and none shows the
four-unrelated-concerns bundling that made `d4976b0` (G8) the outlier
requiring decomposition in the first place.

## 4 — Estimated size

| PR | Files | Insertions | Deletions | Note |
|---|---|---|---|---|
| #5 (G2) | 26 | 1,060 | 5 | |
| #6 (G3) | 5 | 502 | 58 | |
| #7 (G4) | 27 | 2,769 | 5 | |
| #8 (G5) | 54 | 7,039 | 408 | **3,044 of the insertions (43%) are `user_database.g.dart`** — Drift-generated, not hand-reviewed; hand-written portion ≈ 4,329 insertions |
| #9 (G6) | 30 | 1,098 | 93 | Touches `pubspec.yaml` — the only dependency change in this backlog |
| #10 (G7) | 59 | 8,586 | 695 | **2,916 insertions (34%) are the same generated file** — hand-written portion ≈ 6,311 insertions |

**Totals: 201 files, 21,054 insertions, 1,264 deletions** across the
six PRs — larger in aggregate than G8 itself (229 files, 31,580
insertions), which is worth sitting with: the backlog this roadmap
surfaces is not a footnote to G8, it's a comparably large body of work
that happened to be invisible to a G8-scoped analysis.

## 5 — Ranking

| PR | Risk | Merge safety | Dependency level |
|---|---|---|---|
| #5 (G2) | Low | High — self-contained feature, own tests | **0** (root) |
| #6 (G3) | Low | High — small, a bug fix + refactor with regression tests | **1** (quran patch chain, after G2) |
| #7 (G4) | Low-Medium | High — largest of the low-risk group, but no schema/dependency change | **1** (quran patch chain; no feature dependency on G2/G3) |
| #8 (G5) | **Medium-High** | Medium — schema change (3 new tables), largest hand-written diff, extends G2's library | **2** (needs G2; `quran` chain needs G2/G3/G4 first for clean patching) |
| #9 (G6) | Medium | Medium — the only `pubspec.yaml`/dependency change in this set, extends G5's tables further | **3** (needs G2, G5) |
| #10 (G7) | **Medium-High** | Medium — second schema change (2 new tables), largest total diff, generated-code-heavy | **2 for app code / 3 for schema** — see §2.C; effectively needs G5 for a clean apply despite no import dependency |

**Highest risk: G5 and G7**, tied — both are schema-changing PRs
touching the same shared file, both large, both a prerequisite for
work beyond themselves (G5 for G6; G7 directly for P3). Neither is
a "just review carefully" risk the way G4's size is — they're the two
places this backlog can mechanically fail to apply if sequenced wrong.

**Lowest risk: G3** — smallest, a fix with tests, no schema, no new
top-level feature to reason about.

## 6 — Recommended safest merge order

**G2 → G3 → G4 → G5 → G6 → G7**, unchanged from `RELEASE_INVENTORY.md`'s
original Track B — but now justified by mechanism rather than by
following the original chronology on faith:

1. **G2 first**: root of the `library` extension chain (§2.A) and
   first link in the `quran` incremental-patch chain (§2.D).
2. **G3, G4 next, in either order relative to each other**: both only
   need G2 for the shared `quran` patch chain to stay clean; neither
   has a feature-level dependency on the other (confirmed — `search`
   imports nothing from `library`). Listed G3 before G4 to match their
   original chronological order and minimize how far the `quran` patch
   chain has to jump, not because evidence requires that specific
   order between them.
3. **G5 after G2/G3/G4**: hard dependency on G2 (`library` extension),
   and needs the `quran` chain intact up to this point for its own
   `quran` touch to apply.
4. **G6 after G5**: extends tables and directories G5 created.
5. **G7 last**: its schema addition requires G5's tables already in
   `user_tables.dart` (§2.C); its application code has no such
   requirement, but there is no PR boundary at which the schema file
   and the application code could be usefully separated without
   re-doing the kind of internal decomposition G8 needed and this
   backlog does not appear to need.

Once PR #10 (G7) lands, `main` has every table P3 depends on, and the
G8 sequence (`G8_RELEASE_SEQUENCE.md`) resumes exactly as documented —
P3, then P4, then F1 through F8 — unchanged by anything in this
roadmap.

---

READY FOR RELEASE PHASE 2
