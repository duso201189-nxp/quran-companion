# CLAUDE.md — Qur'an Companion

This file is deliberately thin. It orients; it does not restate. If
something here ever drifts from the files it points to, those files win.

## What this project is

A Flutter Qur'an study app — see `README.md` for setup, `ARCHITECTURE.md`
for design, `DATABASE.md` for schema, `ROADMAP.md` for the 12-step plan,
`TODO.md` for open items. Currently on Step 6 of 12 (v0.6.0).

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
`TRANSLITERATION_REPORT.md`). `docs/verification/`, `docs/knowledge/` —
not created yet; created the first time something real needs to go
there, not pre-emptively.
