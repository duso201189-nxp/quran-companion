# Project Index — Qur'an Companion

The entry point to this repository's documentation. If you're new
here, start with [README.md](README.md), then come back to this page
to find whatever you need next. This index tells you **what each
document is for, what order to read them in, and which document is
authoritative** for a given topic — this project accumulated a lot of
documentation across a long recovery engagement (see
[`docs/reports/release-recovery/`](docs/reports/release-recovery/)),
and more than one document sometimes touches the same subject. This
page resolves which one wins.

## Recommended reading order

**New contributor, first day:**
1. [README.md](README.md) — what this app is, how to set it up and run it.
2. [PROJECT_INDEX.md](PROJECT_INDEX.md) — this page.
3. [docs/architecture/MASTER_ARCHITECTURE.md](docs/architecture/MASTER_ARCHITECTURE.md)
   — the shape of the codebase.
4. [docs/architecture/MODULE_CATALOG.md](docs/architecture/MODULE_CATALOG.md)
   — what each of the 18 features does.
5. [CONTRIBUTING.md](CONTRIBUTING.md) — how to make a change here.
6. [docs/testing/TESTING_GUIDE.md](docs/testing/TESTING_GUIDE.md) —
   how to test it.

**About to change the database schema, a provider, or trace a bug
through a specific flow:**
7. [docs/architecture/DATABASE_REFERENCE.md](docs/architecture/DATABASE_REFERENCE.md)
8. [docs/architecture/PROVIDER_MAP.md](docs/architecture/PROVIDER_MAP.md)
9. [docs/architecture/DATA_FLOW.md](docs/architecture/DATA_FLOW.md)

**Trying to understand *why* something is built the way it is:**
10. [docs/architecture/ARCHITECTURE_DECISIONS.md](docs/architecture/ARCHITECTURE_DECISIONS.md)
    — consolidated Context/Decision/Consequences for the 9 major
    architectural choices.
11. [docs/adr/](docs/adr/) — individual, dated Decision Records for
    narrower, specific decisions.

**Planning what to work on next / preparing a release:**
12. [docs/release/RELEASE_PLAN_V1.md](docs/release/RELEASE_PLAN_V1.md)
    — what's actually blocking v1.0.
13. [docs/release/UPDATED_TECHNICAL_DEBT.md](docs/release/UPDATED_TECHNICAL_DEBT.md)
    — open, prioritized technical debt.
14. [docs/release/PRODUCT_ROADMAP.md](docs/release/PRODUCT_ROADMAP.md)
    — v1.0 / v1.1 / v2.0 sequencing.

## Source of truth, by topic

| Topic | Authoritative document | Notes |
|---|---|---|
| Overall architecture, layering, dependency rules | [docs/architecture/MASTER_ARCHITECTURE.md](docs/architecture/MASTER_ARCHITECTURE.md) | Supersedes [ARCHITECTURE.md](ARCHITECTURE.md) for anything touched by P1–P4/F1–F8; that file remains a valid historical design reference for what it does cover |
| Per-feature responsibility/dependencies/entry points | [docs/architecture/MODULE_CATALOG.md](docs/architecture/MODULE_CATALOG.md) | — |
| Database schema, relationships, migration history | [docs/architecture/DATABASE_REFERENCE.md](docs/architecture/DATABASE_REFERENCE.md) | Supersedes [DATABASE.md](DATABASE.md) for current schema state; `DATABASE.md` still holds original design rationale and the ADR trail |
| Riverpod providers, dependency graph, ownership | [docs/architecture/PROVIDER_MAP.md](docs/architecture/PROVIDER_MAP.md) | No prior document covered this at all — first of its kind |
| End-to-end flow traces (Reading/Search/Learning/AI) | [docs/architecture/DATA_FLOW.md](docs/architecture/DATA_FLOW.md) | No prior document covered this at all |
| *Why* a decision was made (architecture) | [docs/architecture/ARCHITECTURE_DECISIONS.md](docs/architecture/ARCHITECTURE_DECISIONS.md) | Consolidated summary; [docs/adr/](docs/adr/) has the individual dated records this summary draws from |
| Testing strategy, coverage, conventions | [docs/testing/TESTING_GUIDE.md](docs/testing/TESTING_GUIDE.md) | — |
| Coding standards, commit/PR conventions | [CONTRIBUTING.md](CONTRIBUTING.md) | — |
| Governed invariants (things that require explicit sign-off to change) | [PROJECT_CONSTITUTION.md](PROJECT_CONSTITUTION.md) + [`constitution/`](constitution/) | Takes precedence over any convention described elsewhere |
| v1.0 release blockers and checklist | [docs/release/RELEASE_PLAN_V1.md](docs/release/RELEASE_PLAN_V1.md) | Cross-references the pre-existing [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md), which remains current for store/legal/signing specifics |
| Open technical debt | [docs/release/UPDATED_TECHNICAL_DEBT.md](docs/release/UPDATED_TECHNICAL_DEBT.md) | Supersedes the archived `TECHNICAL_DEBT.md` (same item IDs, status updated) |
| Product roadmap (v1.0/v1.1/v2.0) | [docs/release/PRODUCT_ROADMAP.md](docs/release/PRODUCT_ROADMAP.md) | Supersedes [ROADMAP.md](ROADMAP.md)'s forward-looking content; that file's historical 12-step table is kept intact and marked historical |
| Performance measurements | [PERFORMANCE.md](PERFORMANCE.md) | Still current; not touched by this documentation pass |
| Release signing, store checklist, legal | [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) | Still current; independently verified line-by-line as of the last recorded pass |
| Historical, point-in-time reports (the recovery engagement) | [docs/reports/release-recovery/](docs/reports/release-recovery/) | Archive only — never authoritative for current state |
| AI agent / EIS governance orientation | [CLAUDE.md](CLAUDE.md) | For Claude Code sessions working in this repo specifically |
| Roles and ownership | [ROLES.md](ROLES.md) | — |

## Full document map

### Root — project-level

| Document | Purpose |
|---|---|
| [README.md](README.md) | Project overview, setup instructions, architecture summary, doc navigation, onboarding |
| [PROJECT_INDEX.md](PROJECT_INDEX.md) | This page |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Coding standards, commit conventions, PR checklist, testing requirements, architecture rules |
| [CLAUDE.md](CLAUDE.md) | Orientation for AI-assisted (Claude Code) sessions in this repo; points to the EIS governance layer |
| [PROJECT_CONSTITUTION.md](PROJECT_CONSTITUTION.md) | This project's governed invariants and constraints (extends EIS Core's Constitution) |
| [ROLES.md](ROLES.md) | Who holds each of the six canonical governance roles |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Original architecture design document (historical/original design rationale; current state lives in `docs/architecture/`) |
| [DATABASE.md](DATABASE.md) | Original schema design document and ADR trail (current schema state lives in `docs/architecture/DATABASE_REFERENCE.md`) |
| [PERFORMANCE.md](PERFORMANCE.md) | Measured startup/query performance, methodology, current gaps |
| [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) | App Store / Google Play release checklist — assets, legal, signing, verified technical items |
| [ROADMAP.md](ROADMAP.md) | Historical 12-step release-phase plan; see file for current status and pointer to `docs/release/PRODUCT_ROADMAP.md` |
| [TODO.md](TODO.md) | Historical open-items log through Sprint 10; see file for pointer to `docs/release/RELEASE_PLAN_V1.md` for current open items |
| [CHANGELOG.md](CHANGELOG.md) | Version history, [Keep a Changelog](https://keepachangelog.com/) format |

### `docs/architecture/` — current architecture reference (Phase 2 output)

| Document | Purpose |
|---|---|
| [MASTER_ARCHITECTURE.md](docs/architecture/MASTER_ARCHITECTURE.md) | Overall architecture, layer responsibilities, dependency rules, design principles |
| [MODULE_CATALOG.md](docs/architecture/MODULE_CATALOG.md) | Every feature: responsibility, dependencies, entry points |
| [DATABASE_REFERENCE.md](docs/architecture/DATABASE_REFERENCE.md) | Every table, relationship, and the full migration history for both databases |
| [PROVIDER_MAP.md](docs/architecture/PROVIDER_MAP.md) | Every Riverpod provider, the dependency graph, feature ownership |
| [DATA_FLOW.md](docs/architecture/DATA_FLOW.md) | Four end-to-end traces: Reading, Search, Learning Session, the AI composition chain |
| [ARCHITECTURE_DECISIONS.md](docs/architecture/ARCHITECTURE_DECISIONS.md) | 9 major architectural decisions, each with Context/Decision/Consequences |

### `docs/testing/`

| Document | Purpose |
|---|---|
| [TESTING_GUIDE.md](docs/testing/TESTING_GUIDE.md) | Test strategy, coverage summary, testing conventions with real code examples |

### `docs/release/` — current release/planning reference

| Document | Purpose |
|---|---|
| [RELEASE_PLAN_V1.md](docs/release/RELEASE_PLAN_V1.md) | Remaining v1.0 blockers, nice-to-haves, recommended release sequencing |
| [PRODUCT_ROADMAP.md](docs/release/PRODUCT_ROADMAP.md) | v1.0 / v1.1 / v2.0 forward-looking roadmap |
| [UPDATED_TECHNICAL_DEBT.md](docs/release/UPDATED_TECHNICAL_DEBT.md) | Live, prioritized technical debt register |

### `docs/adr/` — Architecture Decision Records (individual, dated)

Numbered `DR-2026-XXXX` records, one per specific decision, each with
its own date and status. See [docs/adr/README.md](docs/adr/README.md)
for the index. These are narrower and more granular than
`docs/architecture/ARCHITECTURE_DECISIONS.md`'s consolidated summary.

### `docs/knowledge/` — deep-dive topic documents

Point-in-time technical deep-dives on a specific subsystem, created
when something genuinely needed one (not pre-emptively — see
`CLAUDE.md`). Currently: [reliability_architecture.md](docs/knowledge/reliability_architecture.md).

### `docs/verification/` — Constitution conformance records

Verification Records checking this project's actual state against
`PROJECT_CONSTITUTION.md`'s governed invariants.

### `docs/reports/` — historical, point-in-time reports

Archived once superseded, per this project's own standing rule (see
`CLAUDE.md`). [SPRINT2_REPORT.md](docs/reports/SPRINT2_REPORT.md) and
[TRANSLITERATION_REPORT.md](docs/reports/TRANSLITERATION_REPORT.md)
predate the recovery engagement;
[release-recovery/](docs/reports/release-recovery/) holds the full
archive from that engagement (mega-commit decomposition, Sprint S1
audit, Sprint S2 quality pass) — see that folder's own `README.md` for
what's in it and why none of it is current.

### `docs/` — topic-specific reference (unrelated to this pass)

[AUDIO.md](docs/AUDIO.md), [DATA_PIPELINE.md](docs/DATA_PIPELINE.md),
[FONTS.md](docs/FONTS.md), [LICENSING.md](docs/LICENSING.md),
[PRIVATE_STORAGE.md](docs/PRIVATE_STORAGE.md) — each documents one
specific subsystem, still current, untouched by this documentation
pass.

## Historical / Current / Planned — how this index distinguishes them

- **Current** = the documents in `docs/architecture/`, `docs/testing/`,
  `docs/release/`, plus untouched-but-still-accurate root docs
  (`PERFORMANCE.md`, `RELEASE_CHECKLIST.md`, `PROJECT_CONSTITUTION.md`,
  `ROLES.md`) and topic docs under `docs/`. These describe the
  codebase **as it exists today**, verified against the actual merged
  code, not against plans or intentions.
- **Historical** = everything under `docs/reports/`, plus the parts of
  `ROADMAP.md`/`TODO.md`/`CHANGELOG.md` explicitly marked as such in
  those files. These describe **what happened and when**, and are
  never updated to reflect later changes — that's what makes them a
  reliable historical record rather than a second, competing "current
  state" document.
- **Planned** = `docs/release/PRODUCT_ROADMAP.md` (v1.1/v2.0 sections)
  and `docs/release/RELEASE_PLAN_V1.md` (blockers not yet closed).
  These describe **what hasn't happened yet** — treat any specific
  detail in them as a proposal, not a commitment, until it's actually
  built (see `PRODUCT_ROADMAP.md`'s own closing note on this).

## If two documents disagree

1. `PROJECT_CONSTITUTION.md` and `constitution/` win over everything —
   these are governed, not descriptive.
2. For anything about the *current* codebase, the "Source of truth"
   table above wins.
3. If a document isn't in that table, prefer whichever one is newer
   and was verified against the actual code (check the document's own
   opening lines — this documentation set consistently states what it
   was verified against and when).
4. If you find a real contradiction this index doesn't resolve, that's
   a documentation bug — fix the stale document (or flag it) rather
   than trusting whichever one you found first.
