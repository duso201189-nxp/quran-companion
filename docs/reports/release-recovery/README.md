# Release Recovery Archive

This folder holds **historical, point-in-time reports** from a long
recovery engagement: decomposing a single squashed mega-commit
(`d4976b0`, "Sprint 20: Accessibility, Smart Learning, AI Tutor,
Knowledge docs") back into reviewable, independently-mergeable pull
requests, plus the stabilization/quality/documentation work that
followed once every piece had landed.

**None of these files are the current source of truth for anything.**
They are kept per this project's own standing rule
(`CLAUDE.md`: "`docs/reports/` — point-in-time deep-dive reports,
archived once superseded") — useful for understanding *how* the
current codebase came to be and *why* specific decisions were made,
not for understanding what it looks like *today*. For that, see
[PROJECT_INDEX.md](../../../PROJECT_INDEX.md) at the repo root.

## What actually happened, in order

1. **Mega-commit decomposition ("G8")** — `d4976b0` was split into 12
   independently-reviewable groups: **P1–P4** (reliability layer,
   shared accessibility widgets, DB schema migration, reliability
   retrofit) and **F1–F8** (Lexicon, Flashcards, Analytics, AI Tutor,
   Learning Journey, Smart Learning, Read Model, Learning Session
   wiring). Each group was extracted onto its own branch, verified,
   gated (`dart format`/`flutter analyze --fatal-infos`/`flutter test`),
   and eventually merged as PR #11 through PR #19.
2. **Sprint S1 — Project Audit** — a full architectural/quality audit
   of the fully-merged codebase, producing a prioritized technical debt
   register.
3. **Sprint S2 — Quality & Polish** — fixed the Critical/High debt
   items from the S1 audit (learning_session error handling, wiring
   `CrashReporter`, a handful of dead-code/duplication cleanups, new
   test coverage), merged as PR #19.
4. **Phase 2 — Product Foundation** — a fresh, code-verified
   architectural reference (the documents now living in
   `docs/architecture/`, `docs/testing/`, `docs/release/`), since the
   project's older planning docs (`ROADMAP.md`, `TODO.md`,
   `CHANGELOG.md`) had drifted far behind the actual code during the
   recovery effort.
5. **Phase 2.1 — Documentation Integration** (this pass) — organized
   everything above into the structure you're looking at now.

## Index by group (files here, not exhaustively categorized further)

Some files predate the phase-prefixed naming convention or come from
earlier planning rounds within the same recovery effort; they're
listed as-is rather than force-fit into a category.

**G8 decomposition — planning & tracking**: `G8_DECOMPOSITION.md`,
`G8_FEATURE_MATRIX.md`, `G8_SPLIT_PLAN.md`, `G8_RELEASE_SEQUENCE.md`,
`G8_FINAL_VERIFICATION.md`, `G8_COMPLETION_REPORT.md`,
`FINAL_EXTRACTION_REPORT.md`, `RELEASE_DEPENDENCY_GRAPH.md`,
`RELEASE_INVENTORY.md`, `RELEASE_RECOVERY_PLAN.md`,
`MAIN_RECOVERY_ROADMAP.md`, `IMPLEMENTATION_PROGRAM.md`,
`RED_TEAM_REVIEW.md`.

**Earlier group extractions (G1–G7, pre-dating the P/F naming)**:
`G1_G6_IMPLEMENTATION_REPORT.md`, `G1_G6_PULL_REQUEST_REPORT.md`,
`G2_EXTRACTION_REPORT.md`, `G2_IMPLEMENTATION_REPORT.md`,
`G2_PULL_REQUEST_REPORT.md`, `G3_EXTRACTION_REPORT.md`,
`G3_IMPLEMENTATION_REPORT.md`, `G3_PULL_REQUEST_REPORT.md`,
`G4_EXTRACTION_REPORT.md`, `G4_IMPLEMENTATION_REPORT.md`,
`G4_PULL_REQUEST_REPORT.md`, `G5_EXTRACTION_REPORT.md`,
`G5_IMPLEMENTATION_REPORT.md`, `G5_PULL_REQUEST_REPORT.md`,
`G6_EXTRACTION_REPORT.md`, `G7_EXTRACTION_REPORT.md`,
`G7_IMPLEMENTATION_REPORT.md`, `G7_PULL_REQUEST_REPORT.md`,
`RELIABILITY_PR_REPORT.md`, `RELIABILITY_PULL_REQUEST_REPORT.md`,
`SHARED_WIDGETS_PULL_REQUEST_REPORT.md`,
`SHARED_WIDGETS_REVALIDATION_REPORT.md`, `ARCHITECTURE_FREEZE_REPORT.md`,
`ARCHITECTURE_DECISION_RECORD.md` (superseded by the current
[ARCHITECTURE_DECISIONS.md](../../architecture/ARCHITECTURE_DECISIONS.md)
— note the singular/plural naming difference is real, not a typo: this
is the old, pre-Phase-2.1 file), `IMPLEMENTATION_REPORT.md`,
`FINAL_IMPLEMENTATION_REPORT.md`, `PULL_REQUEST_REPORT.md`.

**P-group extractions**: `P2_IMPLEMENTATION_REPORT.md`,
`P3_IMPLEMENTATION_REPORT.md`, `P3_PULL_REQUEST_REPORT.md`,
`P4_IMPLEMENTATION_REPORT.md`, `P4_PULL_REQUEST_REPORT.md`.

**F-group extractions**: `F1_IMPLEMENTATION_REPORT.md` through
`F8_IMPLEMENTATION_REPORT.md`, `F3_TEST_COMPLETION_REPORT.md` (a
follow-up closing a gap found during F8's own capstone verification).

**Sprint S1 (audit) / S2 (quality & polish)**:
`PROJECT_AUDIT_REPORT.md`, `PROJECT_HEALTH_SCORE.md`,
`TECHNICAL_DEBT.md` (superseded by
[UPDATED_TECHNICAL_DEBT.md](../../release/UPDATED_TECHNICAL_DEBT.md),
which is **not** archived — it's still the live register),
`ROADMAP_RECOMMENDATION.md`, `S2_IMPLEMENTATION_REPORT.md`,
`RELEASE_READINESS_REPORT.md`.

**Data pipeline / dataset planning** (a parallel workstream within the
same recovery effort): `DATA_OS_ARCHITECTURE.md`,
`DATA_SUPPLY_CHAIN.md`, `DATASET_RELEASE_PIPELINE.md`,
`C1_PROVISIONING_CHECKLIST.md`, `C2_ARCHITECTURE_REVIEW.md`,
`C2_VERIFICATION_REPORT.md`, `C3_DATASET_VERIFICATION_NOTES.md`,
`C3_VERIFICATION_REPORT.md`, `B1_VERIFICATION_REPORT.md`.

**CI/governance planning**: `CI_GATE_CORE_PLAN.md`,
`CI_GATE_SPLIT_PLAN.md`.

**Working artifacts**: `PR_DESCRIPTION.md` — a scratch file, overwritten
per-PR throughout the whole effort; its content at any given time only
described whichever PR was being prepared last (F8/S2), not a
standalone record. Kept for completeness, not for its literal content.

## If you're looking for something and it's not obviously here

Check [PROJECT_INDEX.md](../../../PROJECT_INDEX.md) first — it maps
every topic (architecture, database, providers, testing, release
planning) to its current, authoritative document. Everything in this
folder is superseded, by design, by something newer for any question
about the codebase's *current* state.
