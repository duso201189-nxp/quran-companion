# G6 Extraction Report — Sprint 9 (Daily Goal, Revision Queue, Streak)

Source of truth: `MAIN_RECOVERY_ROADMAP.md`. Read-only analysis. No
branch, commit, cherry-pick, or rebase. Verified against `origin/main`
at `8ca69ae` (`Merge pull request #8 from .../feat/sprint8-foundation`)
— checked directly first, not taken on faith.

---

## 1 — Every file in G6

One commit: `fe33d62` ("feat(sprint9): daily goal, revision queue,
canonical streak source").

```
30 files changed, 1,098 insertions(+), 93 deletions(-)
```

| Area | Files |
|---|---|
| Root docs | `CHANGELOG.md`, `CLAUDE.md` ⚠️, `DATABASE.md`, `ROADMAP.md`, `TODO.md` |
| New ADRs | `docs/adr/{DR-2026-0003-sprint8-data-architecture.md, DR-2026-0004-sprint9-streak-daily-goal-revision-queue.md, README.md}` — filed retroactively for Sprint 8 alongside Sprint 9's own |
| Routing | `lib/app/router.dart` |
| Home / integration | `lib/features/home/presentation/home_screen.dart`, `lib/features/khatm/presentation/active_khatm_card.dart` |
| Library (extends PR #4/#8) | `lib/features/library/{domain/library_kind.dart, presentation/library_controller.dart, presentation/library_screen.dart}` |
| Quran (extends existing) | `lib/features/quran/data/user_content_repository_impl.dart`, `lib/features/quran/domain/repositories/user_content_repository.dart` |
| New: Daily Goal | `lib/features/stats/data/{daily_goal_providers.dart, daily_goal_store.dart}`, `lib/features/stats/presentation/widgets/daily_goal_dialog.dart` |
| Stats screen | `lib/features/stats/presentation/stats_screen.dart` (modified — now sources streak from Sprint 8's `study_sessions`) |
| New: Revision Queue | `lib/features/study/presentation/revision_queue_screen.dart` |
| Study screen | `lib/features/study/presentation/study_screen.dart` |
| Localization | 7× `lib/l10n/*`, append-only |
| Dependencies | `pubspec.yaml` — **version bump only, not a new package** (see §3) |

**Zero test files** — new or modified. See §5.

## 2 — Comparison against current `origin/main`

**16 of 17 non-l10n modified files match byte-for-byte** between G6's
parent state and current `main`: `CHANGELOG.md`, `DATABASE.md`,
`ROADMAP.md`, `TODO.md`, `router.dart`, `home_screen.dart`,
`active_khatm_card.dart`, `library_kind.dart`, `library_controller.dart`,
`library_screen.dart`, `user_content_repository_impl.dart`,
`user_content_repository.dart`, `stats_screen.dart`, `study_screen.dart`,
`pubspec.yaml`, and all 7 `l10n` files.

**One does not: `CLAUDE.md`.** `git show origin/main:CLAUDE.md` returns
*"fatal: path 'CLAUDE.md' does not exist in 'origin/main'"* — the file
G6 expects to modify isn't there at all. Traced precisely, not
assumed: `CLAUDE.md` was introduced by `42ba12e`
("feat: adopt EIS Core v0.1.0..."), which `RELEASE_INVENTORY.md`
classifies as **G1 — Governance foundation**. Confirmed G1 was never
opened as its own PR anywhere in the #2–#8 sequence (checked its
target files against every merged PR's scope; none touch it). This is
the first commit in the whole `MAIN_RECOVERY_ROADMAP.md` sequence to
touch `CLAUDE.md` at all — G2 through G5 never did, which is why this
gap went unnoticed until now.

**Cherry-picking `fe33d62` alone onto current `main` would fail**, or
at minimum produce a spurious conflict on `CLAUDE.md` — not because of
anything wrong with G6's content, but because its patch target doesn't
exist yet.

## 3 — Verification

| Check | Result |
|---|---|
| **Database schema** | **Not touched.** No `content_tables.dart` or `user_tables.dart` in the diff — confirmed by direct check, correcting an easy assumption to make given Sprint 8's precedent. `DATABASE.md`'s diff explains why: Daily Goal deliberately does **not** get a `profiles` table (documented inline: *"CỐ Ý không dùng bảng này... chờ tới khi có Auth/Sync thật"*) — it uses `SharedPreferences` via a new `DailyGoalStore`, the same pattern as `ThemeController`/`LocaleController`. Streak becomes canonically sourced from Sprint 8's `study_sessions` table via new `currentStreakProvider`/`longestStreakProvider` — a re-plumbing, not a schema change |
| **Drift migrations** | None — no `schemaVersion` touch, no `MigrationStrategy` change |
| **Imports** | Every import across all 14 modified/new `lib/` files read directly. Real, confirmed dependencies on PR #8 (`khatm_cycle_providers.dart`, `study_session_providers.dart`, `reading_stats_section.dart`, `collections_screen.dart` — all Sprint 8) and PR #7 (`reading_navigation.dart`, `search_screen.dart` — Search). Both already merged |
| **Routing** | `router.dart` gains one import, one `AppRoutes.revisionQueue` constant, one `GoRoute` for `/revision-queue` — additive, inserted after PR #8's `collections` route. Confirmed via the actual diff, not the full-file content |
| **Localization** | 7 files, small append (16–30 lines each) |
| **Generated files** | Only the 4 l10n-generated files — mechanical `gen-l10n` output |
| **Assets** | None touched |
| **pubspec** | **One line changed: `version: 0.6.0+6` → `0.8.1+7`.** This is the app's own version/build number, not a dependency addition — worth correcting explicitly, since earlier passes through this backlog (`RELEASE_INVENTORY.md`, `MAIN_RECOVERY_ROADMAP.md`) described this as "the only dependency change" in the pre-G8 set, which overstates what it actually is. Checked the diff directly rather than repeating that characterization |
| **Tests** | **Zero new or modified test files.** See §5 — a real finding, not an oversight in counting |
| **Build configuration** | Not touched |

## 4 — Dependency detection: G7 / remaining G8

**None found** — comprehensive search across all 14 `lib/` files for
`learning`, `quiz`, `learning_session`, `flashcards`, `analytics`,
`lexicon`, `read_model`, `ai_tutor`, `smart_learning`: zero matches.

**Two real dependencies, both on already-merged work:**

| File | Symbol | Why it exists | Removable? |
|---|---|---|---|
| `lib/features/stats/presentation/stats_screen.dart` | `khatmCycleProvider`-family, `studySessionProvider`-family (PR #8) | Streak/khatm display now reads Sprint 8's real data instead of `StatsStore`'s old counters | N/A — already satisfied, PR #8 merged |
| `lib/features/study/presentation/revision_queue_screen.dart` | `UserContentRepository.watchAllReviewAyahs()` (new method on an existing, already-merged interface), `LibraryTabView`/`LibraryAyahTile` (PR #4/#8) | Revision Queue is deliberately built by reusing My Library's existing list UI and the `AyahStatuses` table (documented in `DATABASE.md`'s own diff: *"KHÔNG có repository/bảng riêng"* — no separate repository or table) rather than duplicating it | N/A — already satisfied |

**One unmet dependency, on G1 — not G7/G8, but real and blocking:**

| File | Symbol | Why it exists | Removable? |
|---|---|---|---|
| `CLAUDE.md` | The file itself | G6 updates the project status line (*"Currently on Step 6 of 12 (v0.6.0)"* → *"mid Step 8 of 12 (v0.8.1)"*) — a 2-line documentation touch to a file only `42ba12e` (G1) creates | **No — cannot be removed from G6's dependency set.** It can only be *resolved*, by including G1 in the same extraction. Trimming this 2-line hunk out of G6 would let G6 merge alone, but would leave `CLAUDE.md` absent from `main` entirely, which is a worse state than a briefly-stale status line — several other project docs (`PROJECT_CONSTITUTION.md`, `ROLES.md`) reference it as the project's entry point. |

## 5 — Test coverage gap, stated plainly

Unlike every other group analyzed in this backlog (G2: 8 new tests, G3:
12, G4: 88, G5: 61), **G6 ships zero automated test coverage** for
Daily Goal, Revision Queue, or the "canonical streak source" claim its
own commit message makes. This isn't a missing-file oversight in this
report — confirmed twice, once by the file list and once by an
explicit `grep` for `^test/` in the diff, both empty. Recorded as a
risk in §7, not silently passed over.

## 6 — Can G6 merge as a single independent PR?

**No, not as originally scoped (the single commit `fe33d62` alone).**
The blocker is narrow and precisely identified: `CLAUDE.md` has no
patch target on current `main` because G1 was never merged. Nothing
about G6's own 30-file diff needs to be decomposed or trimmed — every
other file applies cleanly, every dependency beyond `CLAUDE.md` is
already satisfied by PR #7/#8.

## 7 — Smallest safe extraction

**Prepend G1, don't fragment G6.** G1 (`42ba12e`, `b64a235`) was
already independently classified "Ready to Merge" with zero
dependencies in `RELEASE_INVENTORY.md` and `RELEASE_RECOVERY_PLAN.md`,
and is confirmed here to apply cleanly to current `main` — every one
of its 14 added/renamed paths verified absent from `main` (safe to
add), and both of its file renames (`SPRINT2_REPORT.md`,
`TRANSLITERATION_REPORT.md` → `docs/reports/`) confirmed byte-identical
at their source paths.

**Recommended PR contents: 3 commits, in order — `42ba12e`, `b64a235`,
`fe33d62`.** 14 files from G1 (446 insertions) + 30 files from G6
(1,098 insertions, 93 deletions) = 44 files, 1,544 insertions, 93
deletions combined. This is not a "split" of G6's content in the sense
of breaking one feature into several PRs — it's recognizing that G6
was never actually a complete, self-contained unit on its own; G1 was
always its silent prerequisite, just never exercised until a commit
that happens to touch the one file G1 owns.

---

## Dependency graph

```
G1 ── depends on: nothing
    ── depended on by: G6 (CLAUDE.md) — the only group in the
       backlog analyzed so far that actually needs it

G6 ── depends on: G1 (CLAUDE.md, unmet), PR #7/#8 (already merged)
    ── depends on: nothing from G7 or remaining G8
    ── depended on by: nothing found — no later group in this
       backlog imports from lib/features/stats/data/daily_goal_*
       or lib/features/study/presentation/revision_queue_screen.dart
```

## Risk assessment

| Factor | Assessment |
|---|---|
| Structural risk (does it merge cleanly) | **Blocked as scoped** — the `CLAUDE.md` gap is a hard, mechanical blocker, not a judgment call; resolved simply by widening the PR to include G1 |
| Test coverage | **Weakest in the backlog so far** — zero dedicated tests for three shipped features (Daily Goal, Revision Queue, canonical streak). Elevated risk independent of the merge-mechanics question |
| Schema | None — lowest-risk axis for this group, unlike G5 |
| Size | Small (30 files, 1,098 insertions) — smaller than G4 or G5 |
| Overall | **Medium** — not for size or schema (both favorable), but for the combination of a real (if easily fixed) missing prerequisite and a genuine test-coverage gap that CI passing won't catch, since there's nothing there to run |

## Recommended merge strategy

Cherry-pick `42ba12e`, `b64a235`, `fe33d62` onto current `main`, in
that order, as one PR. Recommend the PR description name the test gap
explicitly (not hide it behind a passing CI run that simply has fewer
tests to fail) and treat "no regressions in the full suite" as
necessary but not sufficient evidence this PR's own new behavior is
correct.

---

## G6 MUST BE SPLIT

**Precisely what this means here, stated to avoid the wrong reading:**
G6's own content is not being decomposed — every one of its 30 files
applies as a single, cohesive, correctly-scoped change. What must
change is the PR *boundary*: G1's two commits need to be included
alongside it, because G6 depends on a file only G1 creates. The
"split" is additive (bring in a missing 446-line prerequisite), not
subtractive (break G6 apart).
