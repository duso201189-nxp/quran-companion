# Project Health Score — Sprint S1 Audit

Scored against the 20-point audit in `PROJECT_AUDIT_REPORT.md`, covering
all merged work (P1–P4, F1–F8) as of `origin/main` `bb9eea0`. Scores are
a synthesis aid for prioritization, not a precise metric — each is
justified by the specific findings behind it, not a formula. 0–10 scale;
10 = no finding, working as intended.

## Overall: 8.3 / 10 — Healthy, with one real reliability gap in the newest feature

This is a substantially clean, well-disciplined codebase for its size
(236 lib files, 18 feature verticals built incrementally across 20+
sprints). Architecture, database integrity, memory management,
navigation, and localization are all essentially clean. The one
material weak spot is concentrated almost entirely in **F8 (Learning
Session)**, the newest and thinnest feature — it skips accessibility
conventions the rest of the app follows consistently, and has a genuine
unhandled-exception gap. Everything else in this report is
small-to-moderate, well-scoped technical debt rather than active risk.

---

## Scorecard

| # | Dimension | Score | Rationale |
|---|---|--:|---|
| 1 | Architecture consistency | 9/10 | 5-tier chain implemented exactly as designed at the call level; only type-level entity imports and a defensible reliability-layer split keep it off 10 |
| 2 | Dead code | 8/10 | 5 orphaned files, all small, all traceable to a documented reason (forward scaffolding, tracked TODO, or unwired feature) |
| 3 | Unused providers | 8/10 | 4 unused providers, all explained; one (`statsRefreshProvider`) is a genuine loose end with no tracking |
| 4 | Unused repositories | 7/10 | 1 of 14 (Read Model) fully unreachable — known since its own merge, not a surprise, but still real |
| 5 | Unused Riverpod providers | 8/10 | Same finding set as #3 |
| 6 | Unreachable routes | 10/10 | All 23 routes reachable; zero broken navigation |
| 7 | Duplicate widgets | 6/10 | Several concrete, evidenced duplicates (empty states, entry cards, one stat card) — moderate, additive-only to fix |
| 8 | Duplicate business logic | 8/10 | One real cluster (quiz question generators); everything else in the domain layer is clean |
| 9 | Duplicate database queries | 6/10 | A repeated filter pattern (20+ sites) and an upsert recipe (5 sites) — low risk, but genuinely widespread |
| 10 | L10n consistency | 10/10 | 319/319 keys match across all 3 locales, ICU metadata matches, zero hardcoded strings found in F1–F8 |
| 11 | Accessibility | 6/10 | Excellent through F4–F7; F8 (`learning_session`) is a real, concrete regression — see Technical Debt D1 |
| 12 | Performance | 9/10 | No `ref.watch`/`ref.read` misuse; two low-severity, low-traffic `build()` hotspots |
| 13 | Startup performance | 9/10 | One awaited call before `runApp`, both DBs lazy, atomic asset copy confirmed; one minor eager-init note |
| 14 | Memory leaks | 10/10 | Every controller/subscription in the codebase has a confirmed, correct disposal path — zero leaks found |
| 15 | Navigation consistency | 10/10 | Consistent push style, all screens have back navigation, no duplicate routes |
| 16 | Repository dependency graph | 9/10 | Clean 6-level-deep chain, no cycles, matches documented architecture |
| 17 | Provider dependency graph | 9/10 | Mirrors repo graph; no unexpected god-providers; two documented (not accidental) bypass optimizations |
| 18 | Feature coupling | 8/10 | Zero circular dependencies; two minor coupling/layering smells |
| 19 | Database migration integrity | 10/10 | Every schema version transition has both a migration step and a dedicated test exercising it |
| 20 | Test coverage gaps | 7/10 | ~83% of domain/data files covered; known F3 gap already has a ready fix; a handful of novel, low-effort gaps found |

**Weighted note**: architecture, database, and navigation/memory
(items 1, 14, 15, 16, 19) are the dimensions most correlated with
production risk if broken — all score 9-10 here, which is the strongest
signal in this report. The lowest scores (7, 11, 9) cluster around
code-organization debt and one feature's incomplete accessibility
follow-through, not around anything that risks data loss or crashes in
the shipped feature set today (with the one exception of D1's unhandled-
exception path, which is why accessibility scores lower than everything
else structural).

## By category

| Category | Items | Average |
|---|---|--:|
| Architecture & dependencies | 1, 16, 17, 18 | 8.75 |
| Code health (dead/duplicate) | 2, 3, 5, 7, 8, 9 | 7.3 |
| User-facing quality | 6, 10, 11, 15 | 9.0 |
| Runtime reliability | 12, 13, 14 | 9.3 |
| Data layer | 4, 19 | 8.5 |
| Test coverage | 20 | 7.0 |

## What would move the score most

1. Fixing D1 (`learning_session` error handling) — the only finding in
   this audit with genuine reliability/crash risk, not just tidiness.
2. A small dead-code/duplicate-widget sweep (D5, D6, D8) — mechanical,
   additive-only, and would lift three of the lower-scoring dimensions
   at once.
3. Closing the F3 test-completion gap already sitting ready on
   `feat/f3-test-completion`, plus the handful of novel test gaps in
   D9 — would move #20 from 7 to 9+ with minimal new work.

See `ROADMAP_RECOMMENDATION.md` for suggested sequencing.
