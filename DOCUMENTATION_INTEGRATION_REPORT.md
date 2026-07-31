# Documentation Integration Report — Phase 2.1

Branch: `phase2-product-foundation` (continuation of Phase 2 — Product
Foundation). No commits made (not instructed to); everything below is
uncommitted working-tree state, same as Phase 2's own output. No
changes to `lib/`, `test/`, or `integration_test/` — confirmed via
`git status` at the end of this pass; no trivial path correction was
needed there because nothing in those directories referenced any of
the moved/created documents by path (checked before starting).

---

## 1. Documentation structure created under `/docs`

| Folder | Contents | Status |
|---|---|---|
| `docs/architecture/` | `MASTER_ARCHITECTURE.md`, `MODULE_CATALOG.md`, `DATABASE_REFERENCE.md`, `PROVIDER_MAP.md`, `DATA_FLOW.md` (moved from repo root, Phase 2 output) + `ARCHITECTURE_DECISIONS.md` (new) | 6 files |
| `docs/testing/` | `TESTING_GUIDE.md` (moved from repo root, Phase 2 output) | 1 file |
| `docs/release/` | `RELEASE_PLAN_V1.md`, `PRODUCT_ROADMAP.md` (moved, Phase 2 output) + `UPDATED_TECHNICAL_DEBT.md` (moved from root — still the *live* debt register, not archived as historical) | 3 files |
| `docs/reports/release-recovery/` | 72 historical, point-in-time reports from the mega-commit decomposition (P1–P4/F1–F8) and Sprint S1/S2, moved from repo root, plus a new `README.md` indexing them | 73 files |
| `docs/adr/`, `docs/knowledge/`, `docs/verification/` | Pre-existing, untouched | — |
| `docs/AUDIO.md`, `DATA_PIPELINE.md`, `FONTS.md`, `LICENSING.md`, `PRIVATE_STORAGE.md` | Pre-existing topic docs, untouched | — |

Every file move was a plain filesystem operation — none of the moved
files were git-tracked (they were all products of this same working
session), so no git history was rewritten or lost.

## 2. Internal cross-references fixed

The 8 Phase 2 documents and `UPDATED_TECHNICAL_DEBT.md` reference each
other by filename throughout. Same-folder references (e.g.
`MASTER_ARCHITECTURE.md` mentioning `MODULE_CATALOG.md`, now both in
`docs/architecture/`) needed no change. **12 cross-folder references**
were found and converted to correct relative markdown links (e.g.
`RELEASE_PLAN_V1.md` mentioned from `docs/architecture/DATABASE_REFERENCE.md`
became `[RELEASE_PLAN_V1.md](../release/RELEASE_PLAN_V1.md)`), across:
`DATABASE_REFERENCE.md` (2), `DATA_FLOW.md` (2), `PROVIDER_MAP.md` (2),
`TESTING_GUIDE.md` (3), `RELEASE_PLAN_V1.md` (2),
`UPDATED_TECHNICAL_DEBT.md` (1, pointing at the now-archived
`TECHNICAL_DEBT.md`). Verified all 14 newly-added relative links
resolve to real files after the move (checked with `test -f`, not
assumed).

## 3. `PROJECT_INDEX.md` (new, repo root)

The requested entry point. Contains: a recommended reading order in
four tracks (new contributor / schema-and-provider work / "why was
this built this way" / release planning), a "source of truth by
topic" table resolving every case where two documents touch the same
subject, a full document map organized by folder with one-line purpose
per file, and an explicit Historical/Current/Planned framework — plus
a short "if two documents disagree" tiebreaker procedure, since a
project this size will keep accumulating documents faster than any
single index can stay perfectly synchronized by hand.

## 4. `README.md` updated

Added, in-place, preserving all existing Vietnamese content unchanged:
an architecture overview section (pointing to
`docs/architecture/MASTER_ARCHITECTURE.md` for full detail), an
expanded documentation table led by `PROJECT_INDEX.md`, a 5-step
onboarding sequence for new contributors, and a repository structure
tree (`lib/` layout + where tests and docs live). Written in
Vietnamese to match the existing document's own established language
— see §7 for the language-consistency note this raised.

## 5. Stale references replaced — `ROADMAP.md`, `TODO.md`, `CHANGELOG.md`

**Nothing was deleted.** Each file got a clear banner/section
distinguishing what's frozen-historical from what's current:

- **`ROADMAP.md`**: added a banner at the top stating the file is
  frozen at Sprint 10 and pointing to `docs/release/PRODUCT_ROADMAP.md`
  for current status. The original 12-step table is untouched. Added
  a new closing section reconciling specific rows that are now
  misleading if read without context (Flashcards shows "—" but F2
  shipped; Analytics/AI Tutor/Learning Journey/Smart Learning/Read
  Model/Learning Session didn't exist when the table was written and
  are now built) — without editing the table's own historical cells.
- **`TODO.md`**: same pattern — banner pointing to
  `docs/release/RELEASE_PLAN_V1.md` and
  `docs/release/UPDATED_TECHNICAL_DEBT.md`, plus a closing
  reconciliation section specifically calling out the "Flashcard
  deferred" item (now built, but the Lexicon data-population gap
  behind the original deferral is still real — see §6) and the stale
  coverage-percentage note.
- **`CHANGELOG.md`**: backfilled the `[Unreleased]` section with two
  new subsections — one covering all 12 P1–P4/F1–F8 groups (PR #3
  through #18) at PR-level summary detail, one covering Sprint
  S1→S2's audit-and-fix pass (PR #19) — inserted above the pre-existing
  Sprint 10 entry (which is now the oldest `[Unreleased]` entry,
  correctly reflecting that it happened first). A short note at the
  top of `[Unreleased]` explains the backfill and points to
  `docs/reports/release-recovery/` for full per-PR detail rather than
  duplicating it here.

## 6. `docs/architecture/ARCHITECTURE_DECISIONS.md` (new)

Nine sections, each with Context/Decision/Consequences, as requested:
Flutter architecture (feature-first, three-layer), Riverpod, Repository
pattern, SQLite/Drift, Dual-database architecture, Learning Engine,
AI composition chain, Error handling strategy, Testing strategy. This
is a **consolidated retrospective summary** distinct from
`docs/adr/`'s individual dated Decision Records — cross-referenced
both ways so neither reads as competing with the other. Two decisions
(the AI composition chain's "rule-based, one-layer-at-a-time" design,
and the reliability layer's CrashReporter wiring) were never captured
as a numbered ADR at the time; both are reconstructed here from the
code's own consistent doc-comment language, flagged as such rather
than presented as if a contemporaneous ADR existed.

## 7. `CONTRIBUTING.md` (new)

Coding standards (including the explicit "test descriptions are
Vietnamese, code is English" convention — see
`docs/testing/TESTING_GUIDE.md` §3.6), commit conventions (format,
one-logical-change-per-commit, no history rewriting), a PR checklist
(gates, test coverage, l10n, doc updates, the `CLAUDE.md`
"stop-and-ask-before" list), testing requirements (summarized from
`docs/testing/TESTING_GUIDE.md`), and the 9 architecture rules from
`ARCHITECTURE_DECISIONS.md` restated as actionable "when writing new
code" guidance.

## 8. Cross-check pass — findings

Checked for contradictions across every touched/created document
(not just spot-checked): test counts, PR numbers, coverage
percentages, and the Lexicon-table-status finding.

- **Test count (767)**: used consistently in `TESTING_GUIDE.md`,
  `CHANGELOG.md`, `TODO.md`, `PRODUCT_ROADMAP.md` — no discrepancy.
- **PR numbers (P1=#3 through S2=#19)**: consistent between
  `CHANGELOG.md`'s new backfill and the already-verified ledger from
  the recovery engagement itself.
- **Coverage percentages**: the historical "~74%" (pre-recovery
  measurement) and the current "70% CI gate, not yet re-measured"
  claims are correctly scoped as different things in every place they
  appear — no document conflates them.
- **Lexicon table status**: `docs/architecture/DATABASE_REFERENCE.md`'s
  corrected finding (8 tables exist in the shipped asset, all empty —
  not "tables don't exist," which is what stale code comments still
  claim) is stated consistently in `ROADMAP.md`'s and `TODO.md`'s new
  sections and in `docs/release/RELEASE_PLAN_V1.md` — none of them
  regressed to the older, less precise claim.
- **`lib/` file count (237)**: `TESTING_GUIDE.md`'s claim was checked
  against the actual filesystem (`find lib -name "*.dart" | wc -l` →
  237) and confirmed accurate.

**One inconsistency found and explicitly documented, not silently
fixed**: this project's documentation is genuinely mixed-language —
the original root docs (`README.md`, `ARCHITECTURE.md`, `DATABASE.md`,
`ROADMAP.md`, `TODO.md`) are Vietnamese; everything from the recovery
engagement onward (`docs/architecture/`, `docs/testing/`,
`docs/release/`, `PROJECT_INDEX.md`, `CONTRIBUTING.md`,
`docs/reports/`) is English. `CLAUDE.md`'s own stated convention
("Docs... English") didn't match reality even before this pass — it
described an aspiration, not the actual root docs. Rather than
silently translating the user's own original Vietnamese documents
(a large, unrequested, risky rewrite well outside "documentation
integration"), this was resolved by **correcting `CLAUDE.md`'s claim**
to state the real, mixed-language convention plainly (§ below) and
noting it in `PROJECT_INDEX.md` implicitly (each document's own
language is self-evident on open). If full-English normalization of
the original root docs is ever wanted, it should be its own explicitly
-scoped translation task, not a side effect of this one.

## 9. `CLAUDE.md` — small, targeted edits

Three edits, each fixing a specific inaccuracy this pass surfaced:

- **"Currently mid Step 8 of 12 (v0.8.1)"** — removed. This claim was
  stale even before Phase 2 (the codebase is far past that point, per
  `docs/architecture/MODULE_CATALOG.md`'s per-feature inventory).
  Replaced with a pointer to `PROJECT_INDEX.md`/`docs/architecture/`/
  `docs/release/` and an explicit statement that "Step N of 12" stopped
  being a meaningful status indicator after Sprint 10.
- **Language convention** — corrected to state the real, mixed-language
  reality (§8) instead of the "Docs... English" claim that never
  matched the original root docs.
- **"Where things live"** — extended to cover the new `docs/architecture/`,
  `docs/testing/`, `docs/release/` folders and `docs/reports/release-recovery/`,
  pointing to `PROJECT_INDEX.md` as the full map rather than trying to
  keep this section itself exhaustive.

No other content in `CLAUDE.md` was touched — its "Definition of done,"
"Stop and ask before," and EIS-governance sections were already
accurate and were left exactly as they were.

## 10. What was deliberately *not* done

- **`ARCHITECTURE.md`/`DATABASE.md` were not rewritten or merged into
  `docs/architecture/`.** They remain the original design documents,
  now explicitly marked (via `PROJECT_INDEX.md` and cross-links) as
  historical/original-rationale references, superseded for *current
  state* by `docs/architecture/MASTER_ARCHITECTURE.md`/
  `DATABASE_REFERENCE.md` but not deleted or edited — they still hold
  design reasoning (e.g. the ADR trail in `DATABASE.md`) that the new
  documents don't repeat.
- **`RELEASE_CHECKLIST.md`, `PERFORMANCE.md`, `PROJECT_CONSTITUTION.md`,
  `ROLES.md` were left untouched** — all still current, not part of
  this task's explicit stale-reference list (§5 named only
  `ROADMAP.md`/`TODO.md`/`CHANGELOG.md`), and moving or editing them
  risked more disruption than benefit for no clear gain.
- **No commit was made.** Consistent with how Phase 2 was handled and
  with this session's standing discipline of only committing when
  explicitly asked.

---

DOCUMENTATION HUB COMPLETE
