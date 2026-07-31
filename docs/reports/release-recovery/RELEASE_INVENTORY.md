# Release Inventory — `origin/main` vs `sprint1-my-library`

Analysis only. No branch was created, pushed, or merged in producing
this document; only read-only `git log`/`diff`/`show` were run.

## Headline fact

**`main` is 25 commits behind `sprint1-my-library` and has been since
`564f2b1` ("real release signing + enable R8 minification").** Every
sprint this engagement has done — Sprint 7 through B2 — exists only on
`sprint1-my-library`. A single merge would move **455 files,
+70,110/−3,076 lines**. That number is why this document exists: the
goal stated for this task is explicitly *not* to merge that as one
event.

---

## Part 1 — Release Inventory

25 commits, grouped into 16 logical units by feature coherence, not by
commit boundary (several sprints landed as one commit; one commit
spans several sprints).

### G1 — Governance foundation
| | |
|---|---|
| Commits | `42ba12e`, `b64a235` |
| Feature | Adopt EIS Core; first Verification Records |
| Sprint | EIS Phase 10 |
| Directories | `constitution/`, `docs/`, root (`PROJECT_CONSTITUTION.md`, `ROLES.md`, `CLAUDE.md`) |
| Scope | 15 files, ~449 lines, **docs/process only** |
| Dependencies | None |
| Merge risk | **Negligible.** No code, no tests, no runtime behavior. |
| Testing status | N/A — nothing executable changed |

### G2 — My Library feature
| | |
|---|---|
| Commits | `ecee0b9`, `a963ced`, `2f5c56d`, `dde27b4`, `db34209` |
| Feature | My Library: data layer, domain, screen, routing, tests |
| Sprint | 7.x |
| Directories | `lib/`, `test/`, `integration_test/` |
| Scope | 28 files, ~1,061 lines |
| Dependencies | None outside itself — self-contained feature slice |
| Merge risk | **Low.** New feature, own tests, no schema/asset touch |
| Testing status | Ships with unit/widget/E2E tests in the same commits (`db34209`) |

### G3 — Reading screen polish
| | |
|---|---|
| Commits | `a88753c`, `169700f` |
| Feature | Mushaf reading-screen refactor; Basmalah double-render fix |
| Sprint | (post-7.x polish) |
| Directories | `lib/`, `test/` |
| Scope | 7 files, ~525 lines |
| Dependencies | None |
| Merge risk | **Low.** A real bug fix with a regression test |
| Testing status | Tests added alongside the fix |

### G4 — Search Foundation
| | |
|---|---|
| Commits | `3facae1` |
| Feature | Sprint 7.1 Search Foundation |
| Sprint | 7.1 |
| Directories | `lib/` (15 files), `test/` (9), `TODO.md`/`ROADMAP.md`/`CHANGELOG.md` |
| Scope | 27 files, 2,769 lines |
| Dependencies | None |
| Merge risk | **Low-medium.** Functionally self-contained, but **its ADR, `DR-2026-0002`, was never filed** — `docs/adr/README.md` already documents this as a known gap, referenced by id from six places in `lib/`. Filing it (or accepting the gap) is cheap and should happen before or with this stage, not after. |
| Testing status | Tests present in the same commit |

### G5 — Sprint 8: Reading Stats, Khatm, Bookmark Collections
| | |
|---|---|
| Commits | `b41493c` |
| Feature | Reading streak/stats, Khatm cycle tracking, bookmark collections |
| Sprint | 8 |
| Directories | `lib/` (33), `test/` (17), `TODO.md`/`ROADMAP.md`/`DATABASE.md`/`CHANGELOG.md` |
| Scope | 54 files, 7,039 lines |
| Dependencies | Builds on G2's bookmark infrastructure |
| Merge risk | **Medium.** `DATABASE.md` changed — a schema-adjacent commit, which `PROJ-P-002` (dual-database separation, stop-and-ask on schema changes) says warrants explicit review before merge, not assumed-safe because it already exists on a branch |
| Testing status | 17 test files in the same commit |

### G6 — Sprint 9: Daily Goal, Revision Queue, Streak
| | |
|---|---|
| Commits | `fe33d62` |
| Feature | Daily goal storage split, revision queue reuse, canonical streak source |
| Sprint | 9 |
| Directories | `lib/` (21), `docs/` (3), `pubspec.yaml`, `DATABASE.md` |
| Scope | 30 files, 1,098 lines |
| Dependencies | G5 (shares the streak/stats surface) |
| Merge risk | **Medium.** Two flags at once: `DATABASE.md` again (schema), and **the only other `pubspec.yaml` change besides G11** — a dependency bump needs checking against whatever `main` currently has resolved, since `main` predates 25 commits of dependency drift |
| Testing status | `docs/adr/DR-2026-0004` exists for this sprint (filed, per `docs/adr/README.md`) |

### G7 — Sprint 10: Learning Engine
| | |
|---|---|
| Commits | `fa8e358`, `4a9c4c4` (formatter-only), `394979d` |
| Feature | Scheduler (SM-2), Review Session, Quiz; later unified into one learning-session architecture |
| Sprint | 10 |
| Directories | `lib/` (32, then 17 more), `test/` (9, then 4), `DATABASE.md` |
| Scope | 82 files, 8,656 lines across three commits |
| Dependencies | G5/G6 (shares the learning/stats domain) |
| Merge risk | **Medium.** Third schema-adjacent commit in a row (`DATABASE.md`). `4a9c4c4` is a pure reformat and can be squashed into its neighbor for merge purposes without losing anything |
| Testing status | `docs/adr/DR-2026-0005` filed for this sprint |

### G8 — The mega-commit: Accessibility, Smart Learning, AI Tutor, Knowledge docs
| | |
|---|---|
| Commits | `d4976b0` |
| Feature | Several sprints' worth: accessibility pass, Smart Learning feature, AI Tutor feature (later renamed "Study Coach"), knowledge-base docs |
| Sprint | 19–21, 25 (per this engagement's own sprint numbering) |
| Directories | `lib/` (**143 files**), `test/` (66), `tool/` (15), `docs/` (4), `assets/` (database touched) |
| Scope | **229 files, 31,580 insertions, 2,627 deletions — the single largest commit in the divergence, larger than every other group combined** |
| Dependencies | Builds on G5/G6/G7's learning surface; **G13 directly depends on this** (renames/hides features this commit introduced) |
| Merge risk | **High, and structural, not just size.** This one commit bundles at least four unrelated concerns (a11y, Smart Learning, AI Tutor, docs) that happened to land together because of how the work was committed, not because they're logically coupled. A defect anywhere in 229 files can't be isolated to "which feature" without re-splitting the diff after the fact. **This is the strongest single candidate for a pre-merge rebase/split into smaller commits** before it goes anywhere near `main` — not because the content is necessarily wrong, but because nothing this size should be one atomic, one-decision merge. |
| Testing status | 66 test files present; `feature_truthfulness_test.dart` and the AI-Tutor-rename tests (from RC-1) are what later verified this feature's labeling honesty — but those fixes are in G13, a *later* commit, meaning **this commit alone, in isolation, shipped the AI Tutor under its original name** before RC-1 corrected it |

### G9 — Sprint 27–30: Study architecture
| | |
|---|---|
| Commits | `b3739e5` |
| Feature | Tafsir-as-content-source architecture, Study Workspace foundation |
| Sprint | 27–30 |
| Directories | `lib/` (62), `test/` (16), `docs/` (6) |
| Scope | 84 files, 7,589 lines |
| Dependencies | Architectural prerequisite for G10 (the tafsir import) |
| Merge risk | **Medium.** Large but coherent — one architecture, not four. `DR-2026-0006`/`DR-2026-0007` (filed later, in G15) describe this work; merging code well ahead of its own ADR being on the same branch is a minor documentation-consistency gap, not a functional risk |
| Testing status | 16 test files in-commit |

### G10 — Sprint 31.4: second real tafsir import ⚠️
| | |
|---|---|
| Commits | `2fb5fd5` |
| Feature | "second real tafsir import and production validation" |
| Sprint | 31.4 |
| Directories | `assets/database/quran.sqlite` (19.9 MB → 34.3 MB), `tool/data/tafsir_ar-tafsir-muyassar.json`, **`tool/data/tafsir_en-tafsir-ibn-kathir.json`** |
| Scope | 3 files changed, but one of them nearly doubles the shipped database |
| Dependencies | G9 (needs the tafsir-as-content-source architecture to exist first) |
| Merge risk | **This is not a technical risk. It is the legal exposure this entire program exists to manage.** This exact commit is where the English abridged Ibn Kathir tafsir — confirmed elsewhere in this engagement as © Maktaba Dar-us-Salam 2003, publicly downloadable (HTTP 200 on `sprint1-my-library`, 404 on `main` — because `main` doesn't have this commit) and misattributed — entered the committed database. **Merging this commit to `main` as-is republishes the exact exposure Sprints 38–40 and the ADR series were written to prevent, onto the branch the public actually sees by default.** `legal/OUTREACH.md`'s four enquiries are still unsent as of this engagement's most recent verification pass. |
| Testing status | "production validation" per the commit message — but validation of correctness is not the same as validation of licence, which is the actual open question |

### G11 — Sprint 35.0: RC engineering, distribution readiness
| | |
|---|---|
| Commits | `bb445ef` |
| Feature | Release-AAB pipeline groundwork, R8/signing config, store metadata, legal package drafts |
| Sprint | 35.0 |
| Directories | `test/` (22), `lib/` (20), `docs/` (6), `assets/` (5), `legal/` (4), `android/` (3) |
| Scope | 69 files, 4,002 lines |
| Dependencies | Depends on G10's database already existing (references/measures it); touches `pubspec.yaml` and `android/` |
| Merge risk | **Medium-high**, for a different reason than G10: this is release *mechanics* for content (G10's database) that shouldn't ship in its current form. Merging the signing/store-readiness work is safe on its own terms, but doing so alongside G10 packages the exposure with the tooling to actually publish it. |
| Testing status | 22 test files; store-metadata and licensing-audit tests referenced elsewhere in this engagement originate here |

### G12 — Official website (GitHub Pages)
| | |
|---|---|
| Commits | `b5f655a` |
| Feature | `index.html`, `privacy.html`, `terms.html`, `third-party.html`, `_config.yml` |
| Sprint | (post-35.0) |
| Directories | root HTML/CSS, `_config.yml` |
| Scope | 8 files, 1,456 lines |
| Dependencies | Legal content depends on `legal/` docs from G11 being final |
| Merge risk | **Distinct kind of risk: this one goes live the moment it merges, not figuratively.** `pages-build-deployment` already exists as a workflow on this repository (observed independently in this engagement's CI investigation) — if GitHub Pages is configured to build from `main`, merging this makes the privacy policy and terms **publicly served immediately**, with no additional trigger or review step. Legal content should get its own sign-off before this merge, separate from a normal code review. |
| Testing status | No automated tests apply to static HTML; correctness here is a legal-review question, not a CI question |

### G13 — RC-1: truthfulness completion
| | |
|---|---|
| Commits | `8d7dee5` |
| Feature | Rename AI Tutor → Study Coach, hide Flashcards when empty, remove fake placeholders, feature-gate data-driven availability |
| Sprint | RC-1 (post-36.0 audit) |
| Directories | `lib/` (18), `test/` (11) |
| Scope | 29 files, 1,464 lines |
| Dependencies | **Hard dependency on G8** — this commit renames and gates things G8 introduced. These two must never be split across separate releases with G8 landing alone; if G8 merges without G13, the app ships the mislabeled "AI Tutor" surface this whole sprint exists to correct. |
| Merge risk | **Low in isolation, but only if paired with G8.** Merging G8 without G13 is worse than merging neither. |
| Testing status | `feature_truthfulness_test.dart` — 7 tests, including the literal check that no `.arb` string claims AI — lands here |

### G14 — Release/merge documentation
| | |
|---|---|
| Commits | `be6e781` |
| Feature | `MERGE_CHECKLIST.md`, `PRODUCTION_READINESS.md`, `PULL_REQUEST.md`, legal doc updates |
| Sprint | 37.0 |
| Directories | `docs/`, `legal/`, root |
| Scope | 15 files, 1,185 lines, **docs only** |
| Dependencies | Describes a **full** merge of everything — will need rewriting for any staged/partial plan, since it currently assumes one merge event that this task's own goal rejects |
| Merge risk | **Negligible as code; misleading as-is for a staged plan.** Don't merge this document unedited alongside a partial release — it would describe a merge that didn't happen the way it says. |
| Testing status | N/A |

### G15 — ADR filing (Sprint 38–40 series)
| | |
|---|---|
| Commits | `1d4cf2c` |
| Feature | `DR-2026-0008` … `DR-2026-0013` + ADR index |
| Sprint | 38–40 / ADR Freeze |
| Directories | `docs/adr/` |
| Scope | 7 files, 839 lines, **docs only** |
| Dependencies | Describes a **target architecture** (licensed content moved out of the repository entirely) that isn't true yet on either branch — the database and tafsir files are still committed everywhere. Not wrong, just describes a future state. |
| Merge risk | **Negligible as code.** Worth merging at the same stage as whichever group first exposes the licensing question (G10), so the documentation and the actual repository state stay consistent for anyone reading `main`. |
| Testing status | N/A |

### G16 — CI licence gate (B1/B2) ⚠️ structurally entangled with G10
| | |
|---|---|
| Commits | `d760626`, `11d6176` |
| Feature | CI gate: no restricted-licence path may be tracked; size guard; grandfathered allow-list naming exactly 5 files (including `tool/data/tafsir_en-tafsir-ibn-kathir.json`) |
| Sprint | B1, B2 |
| Directories | `test/` only — 1 file each |
| Scope | 2 files, 418 lines |
| Dependencies | **This is the important structural finding of this inventory.** The gate's own tests assert that every grandfathered path is currently tracked — that assertion is written *against `sprint1-my-library`*, where G10 and G8 already exist. **If G16 merges to `main` before G10, its own tests fail**, because `main` doesn't yet track the files the allow-list names. The gate that exists to prevent recurrence cannot itself land ahead of the content it's grandfathering. |
| Merge risk | **Low as code, but see above — it has an ordering dependency on the exact commit (G10) this report is flagging as the program's central legal risk.** Merging the gate does not resolve that risk; it only starts preventing a *second* instance of it. |
| Testing status | Proven load-bearing by deliberate breakage (documented in this engagement's own B1 verification pass) — the strongest-tested group in the whole inventory, by process if not by count |

---

## Part 2 — Staged merge plan

The ordering below is **risk-ascending in three tracks that can run in
parallel**, not a strict single sequence — tracks converge only where
a real dependency forces it (G8↔G13, G10↔G16, G9→G10).

```
Track A (pure docs/process — no code risk):
  G1 → G15 → G14(rewritten for whichever stage is current)

Track B (feature code, no licensing entanglement):
  G2 → G3 → G4(+file DR-2026-0002) → G5 → G6 → G7

Track C (the entangled cluster — cannot be split further without
         re-deciding the underlying legal question):
  G9 → [G10 ⚠ BLOCKED] → G16(+G15) → G11 → G12(with legal sign-off)
              ↓ pairs with
  G8 → G13 (always together)
```

**G10 is marked blocked, not merely risky, because merging it changes
nothing about the licensing question this whole engagement has spent
multiple sprints on — it only moves the exposure from one branch to
the one the public sees by default.** Two ways to unblock it, not
decided here:

1. **Resolve first.** Complete `A3` (delete or replace the Ibn Kathir
   corpus) before this content ever reaches `main`, so `main` never
   carries the exposure at all.
2. **Clear first.** Get an actual licence response from
   `legal/OUTREACH.md`'s enquiries — currently unsent — before merging.

Until one of those happens, **G10, and everything downstream of it in
Track C (G11, G12, G16), stays unmerged.** Track A and Track B have no
dependency on this and can proceed independently.

---

## Part 3 — Recommended release roadmap

| Release | Contains | Why this boundary | Gate before merge |
|---|---|---|---|
| **R1 — Governance** | G1 | Zero code, establishes the process the rest of this roadmap follows | None beyond review |
| **R2 — Core reading features** | G2, G3, G4 | Self-contained, no schema/asset/licensing entanglement, smallest real feature slice | File or formally accept the `DR-2026-0002` gap |
| **R3 — Stats & learning engine** | G5, G6, G7 (squash `4a9c4c4`) | One coherent domain (stats/streak/learning); three schema-touching commits reviewed together once, not three separate ad-hoc reviews | Explicit `PROJ-P-002` schema review; dependency diff on `pubspec.yaml` against current `main` |
| **R4 — Split-and-review the mega-commit** | G8 (re-split), **with G13 in the same release, never apart** | The largest single risk by volume; do the splitting work *before* this release exists, not during its review | Re-split `d4976b0` into per-feature commits; confirm `feature_truthfulness_test.dart` (G13) ships in the same release as the features it's checking |
| **R5 — Study architecture** | G9 | Prerequisite for the licensing decision in R6; safe to land on its own | Standard review |
| **R6 — Content resolution (blocking)** | G10, G15, G16 | **Do not schedule a date for this release.** It exists only once A3 or legal clearance (Part 2) happens. When it does, the ADRs (G15) and the gate (G16) land in the same release as the content they describe/guard, keeping docs, code, and enforcement consistent from the moment `main` first sees any of it | A3 complete, or licence obtained — not a technical gate, a legal one |
| **R7 — Release mechanics** | G11 | Signing/store readiness for content that, by this point, has actually cleared R6 | Re-verify signing config against whatever `main`'s dependency state is by this point |
| **R8 — Public website** | G12 | Separate legal sign-off (privacy/terms), separate from code review, because this merge is publicly live the moment it lands if Pages builds from `main` | Legal sign-off on `privacy.html`/`terms.html` content specifically |
| **R9 — Release documentation** | G14 (rewritten), the already-pushed dataset-verification workflow | Written last, once it's known which releases actually happened, so it describes reality instead of a full merge that didn't occur this way | Rewrite `MERGE_CHECKLIST.md`/`PRODUCTION_READINESS.md` against the actual R1–R8 sequence |

**The one instruction this roadmap follows most deliberately: R6 has no
scheduled position in time.** Every other release can proceed on
engineering judgment alone. R6 waits on a legal answer this engagement
has been unable to obtain for six-plus sprints, and no amount of
technical readiness in R1–R5 or R7–R9 changes that. Sequencing
everything else around R6 — rather than after it — is what makes "not
merging everything" an actual risk reduction instead of just a
reordering of the same eventual outcome.
