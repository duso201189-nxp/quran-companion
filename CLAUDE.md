# CLAUDE.md — Qur'an Companion

This file is deliberately thin. It orients; it does not restate. If
something here ever drifts from the files it points to, those files win.

## What this project is

A Flutter Qur'an study app — start at `PROJECT_INDEX.md` for the full
documentation map. `ROADMAP.md`/`TODO.md` describe the original
12-step plan but are frozen as of Sprint 10 (see the banner at the top
of each) — they do **not** reflect current status. The codebase moved
substantially past that plan during a later "release recovery" pass
(a squashed mega-commit decomposed into 12 PRs, P1–P4/F1–F8, plus a
quality/audit pass, S1/S2) that never looped back to update those
planning docs. For current, code-verified status: `docs/architecture/`
(what's built and how), `docs/release/RELEASE_PLAN_V1.md` (what's left
before v1.0), `docs/release/PRODUCT_ROADMAP.md` (forward plan). Don't
trust "Step N of 12" as a status indicator for anything past Sprint
10 — it isn't one anymore.

## This project runs under EIS

`.claude/eis-profile.yaml` pins EIS Core `v0.1.0`
(`C:/Users/Admin/Documents/eis-core`). `PROJECT_CONSTITUTION.md` extends
Core's Constitution with five project-specific invariants/constraints —
read it before assuming a rule from `ARCHITECTURE.md` is "just
documentation" rather than a governed guarantee. `ROLES.md` names who
holds each of the six canonical roles (currently: all one person).

**Known gap, stated plainly**: no Claude Code adapter exists yet in EIS
Core (Phase 4b was never built). EIS's skills, prompts, and workflows are
real, schema-conformant specifications — they are not wired into
invokable tools here. Follow them by hand where relevant; don't assume
they run automatically.

## Definition of done for any change here

Unchanged from this project's own established discipline
(`README.md`): `dart format`, `flutter analyze --fatal-infos`,
`flutter test --coverage`, all clean, before any commit. Every new
feature ships tests in the same change. New user-facing strings go into
all three `lib/l10n/app_{vi,en,ar}.arb` files, never hardcoded.

## Conventions

Commit messages: English, `feat:`/`fix:`/`docs:`/`test:` prefixes
(already the case in this repo's own history). Code and identifiers:
English throughout. App UI strings: Vietnamese default, English and
Arabic (RTL) also supported — see `ARCHITECTURE.md` §7. Test
descriptions (the string arguments to `test()`/`testWidgets()`) are
written in Vietnamese, deliberately mirroring that same UI convention
— see `docs/testing/TESTING_GUIDE.md` §3.6.

**Docs are mixed-language, not uniformly English** — stated plainly
rather than papered over: the project's original root docs
(`README.md`, `ARCHITECTURE.md`, `DATABASE.md`, `ROADMAP.md`,
`TODO.md`) are written in Vietnamese, matching the person who wrote
them; everything produced during the later recovery/audit/
documentation-integration passes (`docs/architecture/`,
`docs/testing/`, `docs/release/`, `PROJECT_INDEX.md`,
`CONTRIBUTING.md`, `docs/reports/`) is in English. Match whichever
document you're editing — don't mix languages within one file.

## Stop and ask before

Any schema change to either database (`PROJ-P-002`); any change to the
Supabase RLS policy design once cloud sync begins (`PROJ-P-004`); any
move toward monetization (`PROJ-P-005` — licensing blocker); any
dependency major-version bump (16 packages are already known outdated,
see `TODO.md`); anything touching `android/key.properties` or the release
keystore (see `RELEASE_CHECKLIST.md`'s keystore-security section).

## Where things live

Full map: `PROJECT_INDEX.md` (source-of-truth table per topic — read
this before assuming which of two documents on the same subject is
current). Short version:

`docs/architecture/` — current architecture reference (overview,
per-feature catalog, database schema, provider map, data flow traces,
consolidated architecture-decision summary), verified against the
actual current code — includes `STUDY_ARCHITECTURE_CONSTITUTION.md`,
the governing architectural principles and constraints for the Study
module. `docs/testing/` — current testing strategy/
conventions. `docs/release/` — current release plan, open technical
debt, product roadmap — includes `MILESTONE_7_STUDY_ROADMAP.md`, the
authoritative sequencing reference for Milestone 7 Study sprints.
`docs/adr/` — individual, dated Decision
Records for this project (first one: adopting EIS itself).
`docs/reports/` — point-in-time deep-dive reports, archived once
superseded (`SPRINT2_REPORT.md`, `TRANSLITERATION_REPORT.md`, plus
`release-recovery/` — the full historical archive from the mega-commit
decomposition and S1/S2 passes; its own `README.md` explains what's
there). `docs/verification/` — Verification Records; created at Phase
10 (EIS Core's own build) when this project's Constitution was first
checked for real. `docs/knowledge/` — deep-dive docs on a specific
subsystem, created the first time something real needs one, not
pre-emptively (currently: `reliability_architecture.md`).
