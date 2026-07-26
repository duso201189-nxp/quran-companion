# CLAUDE.md — Qur'an Companion

This file is deliberately thin. It orients; it does not restate. If
something here ever drifts from the files it points to, those files win.

## What this project is

A Flutter Qur'an study app — see `README.md` for setup, `ARCHITECTURE.md`
for design, `DATABASE.md` for schema, `ROADMAP.md` for the 12-step plan,
`TODO.md` for open items. Steps 1-9 are substantially done (v0.8.1);
steps 10-12 (auth, cloud sync, AI) are v1.5/v2.0 and unbuilt. The
project is in **release-candidate preparation** — see
`RELEASE_CHECKLIST.md` for the objective gate, `KNOWN_ISSUES.md` for
what is deliberately absent or unverified in the current build.

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

Docs and commit messages: English (already the case in this repo's own
history — `feat:`/`fix:`/`docs:`/`test:` prefixes). App UI strings:
Vietnamese default, English and Arabic (RTL) also supported — see
`ARCHITECTURE.md` §7. Code and identifiers: English throughout.

## Stop and ask before

Any schema change to either database (`PROJ-P-002`); any change to the
Supabase RLS policy design once cloud sync begins (`PROJ-P-004`); any
move toward monetization (`PROJ-P-005` — licensing blocker); any
dependency major-version bump (16 packages are already known outdated,
see `TODO.md`); anything touching `android/key.properties` or the release
keystore (see `RELEASE_CHECKLIST.md`'s keystore-security section).

## Where things live

`docs/adr/` — Decision Records for this project (first one:
adopting EIS itself). `docs/reports/` — point-in-time deep-dive reports,
archived once superseded (migrated here: `SPRINT2_REPORT.md`,
`TRANSLITERATION_REPORT.md`). `docs/verification/` — Verification
Records; created at Phase 10 (EIS Core's own build) when this project's
Constitution was first checked for real. `docs/knowledge/` — still not
created; created the first time something real needs to go there, not
pre-emptively.
