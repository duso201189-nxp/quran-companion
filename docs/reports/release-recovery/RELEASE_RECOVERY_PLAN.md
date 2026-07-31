# Release Recovery Plan

Sprint: Release Recovery Phase 1 — analysis and planning only. No
source code was modified; no branch was checked out, merged, rebased,
cherry-picked, pushed, or rewritten in producing this document. Builds
on [`RELEASE_INVENTORY.md`](RELEASE_INVENTORY.md)'s 16 groups (G1–G16);
see that document for full file-level detail per group. This document
adds classification, effort, and next-action — it does not restate
every fact already recorded there.

---

## Classification legend

| Category | Meaning |
|---|---|
| **Ready to Merge** | The group's own content is safe and reviewed-enough to merge on engineering judgment alone. A dependency on another group may still delay *when*, but nothing about this group's own content needs to change. |
| **Blocked by Legal** | Merging exposes or perpetuates an identified rights/licensing problem. No amount of engineering review changes this; only a legal answer or content removal does. |
| **Requires Commit Split** | The group as it currently exists is too large, or bundles unrelated concerns, or (for G16) mixes a branch-independent mechanism with a branch-dependent self-check — and needs to be decomposed before it can be safely reviewed or merged as-is. |
| **Requires Additional Technical Review** | Not unsafe on its face, but touches something (schema, dependencies, signing, legal-adjacent static content) that this project's own standards say warrants a deliberate, named review pass before merging — not a blanket rubber stamp. |

---

## Part 1 — Group-by-group classification

### G1 — Governance foundation
| | |
|---|---|
| Release ID | G1 |
| Sprint(s) | EIS Phase 10 |
| Purpose | Adopt EIS Core as project profile; first Verification Records |
| Files/dirs | `constitution/`, `docs/`, root process docs |
| Dependencies | None |
| Risks | None — no executable code |
| Blocking condition | None |
| **Classification** | **Ready to Merge** |
| Review effort | **Low** |
| Recommended next action | Merge as-is |

### G2 — My Library feature
| | |
|---|---|
| Release ID | G2 |
| Sprint(s) | 7.x |
| Purpose | My Library: data layer, domain, screen, routing |
| Files/dirs | `lib/`, `test/`, `integration_test/` |
| Dependencies | None |
| Risks | Standard feature-merge risk; mitigated by in-commit tests |
| Blocking condition | None |
| **Classification** | **Ready to Merge** |
| Review effort | **Low** |
| Recommended next action | Merge as-is |

### G3 — Reading screen polish
| | |
|---|---|
| Release ID | G3 |
| Sprint(s) | post-7.x |
| Purpose | Mushaf reading refactor; Basmalah double-render fix |
| Files/dirs | `lib/`, `test/` |
| Dependencies | None |
| Risks | Low — bug fix with regression test |
| Blocking condition | None |
| **Classification** | **Ready to Merge** |
| Review effort | **Low** |
| Recommended next action | Merge as-is |

### G4 — Search Foundation
| | |
|---|---|
| Release ID | G4 |
| Sprint(s) | 7.1 |
| Purpose | Search feature, foundation layer |
| Files/dirs | `lib/` (15), `test/` (9), `TODO.md`/`ROADMAP.md`/`CHANGELOG.md` |
| Dependencies | None functional |
| Risks | Low technical risk; real process gap — `DR-2026-0002` was never filed, and `docs/adr/README.md` already documents this as referenced-but-missing from six call sites in `lib/` |
| Blocking condition | None hard, but the missing ADR should close before or with this merge, not drift further |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Low** |
| Recommended next action | File `DR-2026-0002` retroactively (or formally record the gap as accepted) alongside this merge |

### G5 — Sprint 8: Reading Stats, Khatm, Bookmark Collections
| | |
|---|---|
| Release ID | G5 |
| Sprint(s) | 8 |
| Purpose | Reading streak/stats, Khatm cycle tracking, bookmark collections |
| Files/dirs | `lib/` (33), `test/` (17), `DATABASE.md` |
| Dependencies | G2 (bookmark infrastructure) |
| Risks | `DATABASE.md` changed — schema-adjacent |
| Blocking condition | `PROJ-P-002` requires explicit stop-and-ask review on schema changes; not yet performed against current `main` |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Medium** |
| Recommended next action | Run the `PROJ-P-002` schema review explicitly, against `main`'s actual current schema, not assumed compatible because it works on `sprint1-my-library` |

### G6 — Sprint 9: Daily Goal, Revision Queue, Streak
| | |
|---|---|
| Release ID | G6 |
| Sprint(s) | 9 |
| Purpose | Daily goal storage split, revision queue reuse, canonical streak source |
| Files/dirs | `lib/` (21), `docs/`, `pubspec.yaml`, `DATABASE.md` |
| Dependencies | G5 (shares streak/stats surface) |
| Risks | Schema change **and** the only other dependency bump besides G11 |
| Blocking condition | Schema review (as G5) plus a dependency-resolution diff against whatever `main` currently pins — `main` predates 25 commits of drift, so "it resolved fine on `sprint1-my-library`" doesn't establish it resolves cleanly on `main` |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Medium** |
| Recommended next action | Schema review + `flutter pub get`/dependency-resolution check against `main`'s current lockfile before merge |

### G7 — Sprint 10: Learning Engine
| | |
|---|---|
| Release ID | G7 |
| Sprint(s) | 10 |
| Purpose | Scheduler (SM-2), Review Session, Quiz; unified learning-session architecture |
| Files/dirs | `lib/` (32, then 17), `test/`, `DATABASE.md` |
| Dependencies | G5/G6 (shared learning/stats domain) |
| Risks | Third consecutive schema-adjacent commit group; one of its three commits (`4a9c4c4`) is a pure reformat |
| Blocking condition | Schema review, same as G5/G6 |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Medium** |
| Recommended next action | Schema review; optionally squash `4a9c4c4` into its neighbor first (cosmetic, not required for safety) |

### G8 — The mega-commit ⚠️
| | |
|---|---|
| Release ID | G8 |
| Sprint(s) | 19–21, 25 (per this engagement's internal numbering) |
| Purpose | Accessibility pass, Smart Learning feature, AI Tutor feature, knowledge-base docs |
| Files/dirs | `lib/` (143), `test/` (66), `tool/` (15), `assets/` (database touched) |
| Dependencies | Builds on G5/G6/G7; **G13 depends on this** |
| Risks | 229 files, 31,580 insertions in one commit — the single largest unit in the entire divergence, bundling ≥4 unrelated concerns that happened to land together by commit history, not by design |
| Blocking condition | Cannot be safely reviewed as one atomic decision at this size — a defect anywhere in 229 files can't be isolated to "which feature" without re-splitting after the fact |
| **Classification** | **Requires Commit Split** |
| Review effort | **High** |
| Recommended next action | Re-split into per-feature commits (accessibility / Smart Learning / AI Tutor / knowledge docs) *before* scheduling a review, not during it. This is the single highest-leverage action in this whole recovery plan — nothing downstream of G8 can be reviewed cleanly until this happens. |

### G9 — Sprint 27–30: Study architecture
| | |
|---|---|
| Release ID | G9 |
| Sprint(s) | 27–30 |
| Purpose | Tafsir-as-content-source architecture, Study Workspace foundation |
| Files/dirs | `lib/` (62), `test/` (16), `docs/` (6) |
| Dependencies | Architectural prerequisite for G10 |
| Risks | Large (84 files) but internally coherent — one architecture, not several bundled concerns |
| Blocking condition | None hard; large surface warrants a dedicated review pass on its own terms |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Medium-High** |
| Recommended next action | Architecture review of the tafsir-content-source model in isolation, ahead of G10 (which depends on this architecture existing) |

### G10 — Sprint 31.4: tafsir import ⚠️
| | |
|---|---|
| Release ID | G10 |
| Sprint(s) | 31.4 |
| Purpose | "Second real tafsir import and production validation" |
| Files/dirs | `assets/database/quran.sqlite` (19.9→34.3 MB), `tool/data/tafsir_en-tafsir-ibn-kathir.json`, `tool/data/tafsir_ar-tafsir-muyassar.json` |
| Dependencies | G9 |
| Risks | **Not technical.** This is confirmed (via `git show`) as the exact commit that added the English abridged Ibn Kathir tafsir — established elsewhere in this engagement as © Maktaba Dar-us-Salam 2003, publicly downloadable, and misattributed to the 14th-century author |
| Blocking condition | Either (a) phase A3 (delete/replace the corpus) completes, or (b) `legal/OUTREACH.md`'s four enquiries — still unsent as of this engagement's most recent check — receive an actual licence answer |
| **Classification** | **Blocked by Legal** |
| Review effort | N/A — not a review problem |
| Recommended next action | Do not schedule. Revisit only when the blocking condition changes. |

### G11 — Sprint 35.0: RC engineering, distribution readiness
| | |
|---|---|
| Release ID | G11 |
| Sprint(s) | 35.0 |
| Purpose | Release-AAB pipeline, R8/signing config, store metadata, legal package drafts |
| Files/dirs | `test/` (22), `lib/` (20), `android/` (3), `pubspec.yaml`, `legal/` |
| Dependencies | References/measures G10's database; touches `android/` and `pubspec.yaml` |
| Risks | Release-signing-adjacent; the only other `pubspec.yaml`/`android/` touch besides G6 |
| Blocking condition | Not itself legally blocked — its own code can be reviewed now — but **merging it has no purpose until G10 clears**, since it's release mechanics for content that can't ship yet |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Medium** |
| Recommended next action | Review signing/store-metadata correctness now if desired, but hold the actual merge until G10's blocking condition resolves — reviewing early is fine, shipping early is not |

### G12 — Official website (GitHub Pages)
| | |
|---|---|
| Release ID | G12 |
| Sprint(s) | post-35.0 |
| Purpose | `index.html`, `privacy.html`, `terms.html`, `third-party.html`, `_config.yml` |
| Files/dirs | root HTML/CSS, `_config.yml` |
| Dependencies | Legal content depends on `legal/` drafts (G11) being final |
| Risks | **Goes live immediately on merge, not figuratively** — `pages-build-deployment` already exists as a workflow on this repository; if Pages builds from `main`, the privacy policy and terms are publicly served the moment this lands, with no separate deploy gate |
| Blocking condition | Legal read-through of the actual policy/terms text, distinct from a code review, given the immediate real-world consequence |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Medium** |
| Recommended next action | Legal sign-off specifically on `privacy.html`/`terms.html` content before merge — treat this as a publishing decision, not a code-review checkbox |

### G13 — RC-1: truthfulness completion
| | |
|---|---|
| Release ID | G13 |
| Sprint(s) | RC-1 |
| Purpose | Rename AI Tutor → Study Coach, hide Flashcards when empty, remove fake placeholders, data-driven feature gating |
| Files/dirs | `lib/` (18), `test/` (11) |
| Dependencies | **Hard dependency on G8** — renames/gates what G8 introduced |
| Risks | None on its own content — small, clean, carries `feature_truthfulness_test.dart` |
| Blocking condition | **Must never merge separately from, or before, G8.** Since G8 requires a commit split first, G13 is procedurally gated on that split completing, not on any defect of its own. |
| **Classification** | **Ready to Merge** *(content itself; timing is gated by G8, not by G13)* |
| Review effort | **Low** |
| Recommended next action | Hold in lockstep with G8's post-split commits; merge in the same release, never apart |

### G14 — Release/merge documentation
| | |
|---|---|
| Release ID | G14 |
| Sprint(s) | 37.0 |
| Purpose | `MERGE_CHECKLIST.md`, `PRODUCTION_READINESS.md`, `PULL_REQUEST.md`, legal doc updates |
| Files/dirs | `docs/`, `legal/`, root |
| Dependencies | Describes a **full** merge of everything — inconsistent with this recovery plan's staged approach as currently written |
| Risks | Docs-only, zero code risk — but **misleading if merged unedited**, since it documents a single merge event that this plan explicitly rejects |
| Blocking condition | Needs rewriting to describe whichever release sequence actually happens, not the one it was originally written for |
| **Classification** | **Requires Additional Technical Review** |
| Review effort | **Low** |
| Recommended next action | Rewrite against the actual R1–R9 sequence (see roadmap) once it's known which releases have happened; do not merge as originally authored |

### G15 — ADR filing (Sprint 38–40 series)
| | |
|---|---|
| Release ID | G15 |
| Sprint(s) | 38–40 / ADR Freeze |
| Purpose | `DR-2026-0008` … `DR-2026-0013` + ADR index |
| Files/dirs | `docs/adr/` |
| Dependencies | Describes a target architecture (licensed content moved out of the repository) not yet true on any branch |
| Risks | None — docs only |
| Blocking condition | None hard; recommended to pair with whichever release first exposes the licensing question (G10/G16), so `main`'s documentation and actual state stay consistent for any reader |
| **Classification** | **Ready to Merge** |
| Review effort | **Low** |
| Recommended next action | Safe to merge anytime; scheduling alongside G10/G16 is a narrative-consistency preference, not a requirement |

### G16 — CI licence gate (B1/B2) — see Part 3 for full analysis
| | |
|---|---|
| Release ID | G16 |
| Sprint(s) | B1, B2 |
| Purpose | Deny-pattern gate against restricted content; tracked-file size guard |
| Files/dirs | `test/repository_boundary_test.dart` only |
| Dependencies | Partial — see Part 3. The **core deny/size mechanism has no real dependency on G10.** **One specific self-verifying test does.** |
| Risks | As currently written, two of its ten tests would fail on a target branch (`main`) that doesn't yet track any of the five grandfathered files |
| Blocking condition | See Part 3 — resolved by a small, scoped code change, not by waiting for G10 |
| **Classification** | **Requires Commit Split** |
| Review effort | **Medium** |
| Recommended next action | Split into (a) the branch-independent deny/size-threshold mechanism, mergeable to `main` now, and (b) the content-coupled completeness self-check, held until G10 or rewritten — see Part 3 for exactly which lines |

---

## Part 2 — Phased roadmap

### Phase 1 — Safe engineering work, proceed immediately
G1, G2, G3, G4 (with the ADR gap closed), G15, and **G16's core mechanism once split** (see Part 3). None of these carry a schema question, a legal question, or a size problem. This phase alone recovers governance, three real features, and — critically — gets *stronger* content-gate protection onto `main` immediately, sooner than any other phase.

### Phase 2 — Items requiring technical review
G5, G6, G7 (schema review under `PROJ-P-002`, one review pass covering all three since they share a domain), G9 (architecture review), G11 (signing/store review — review now, merge timing still gated by G10), G12 (legal content read-through), G14 (rewrite once the actual sequence is known).

### Phase 3 — Items requiring commit split
G8 (the mega-commit — highest priority action in this entire plan, since G13 and, transitively, much of Phase 2's usefulness depends on it being decomposable), G16's completeness self-check (small, scoped, see Part 3), G13 (not itself split, but held in lockstep with G8's split output).

### Phase 4 — Items blocked by legal or licensing
G10 only. No other group in this inventory carries a legal blocker — that fact is itself worth stating plainly, since it means 15 of 16 groups can proceed on engineering judgment alone once Phases 1–3 are worked through.

---

## Part 3 — CI licence gate: does it truly need to stay coupled to the grandfathered content?

Read the actual current implementation (`test/repository_boundary_test.dart`, 418 lines, fetched via `git show origin/sprint1-my-library:...` since the working checkout is on `main`, which predates this file) rather than assuming. Answer: **mostly no, and precisely where it does, the coupling is narrow and fixable without weakening anything.**

### What the gate actually checks (10 tests, two groups)

**Group "Ranh giới kho mã" (B1) — the deny-pattern mechanism:**
1. `git` readable, repo non-empty
2. **No newly-tracked path matches a restricted pattern, unless grandfathered** — the core protection
3. Every grandfathered entry is still tracked (*"the exemption list shrinks, never grows"*)
4. Every grandfathered entry states its removal phase
5. Every grandfathered entry is an exact path, not a pattern
6. Every deny pattern matches its intended examples and rejects legitimate ones (hardcoded example lists, not live repo state)

**Group "Chặn theo kích thước" (B2) — the size-threshold mechanism:**
7. Every tracked file's size is readable
8. **No tracked file exceeds 1 MB, unless grandfathered** — the core protection
9. The threshold has real margin over the largest legitimate file
10. **Every grandfathered entry that exceeds the threshold states its removal phase**

### Which of these actually require the grandfathered files to exist

Tests 1, 4, 5, 6, 7, 9 don't reference live grandfathered content at all — they check the mechanism itself (pattern-matching against hardcoded examples, threshold margin against whatever legitimate files exist). These pass identically regardless of what's tracked.

**Test 2** (core deny-check) and **test 8** (core size-check) don't need the grandfathered files to exist either — an empty or smaller `_grandfathered` map makes both tests *more* restrictive, not less, since fewer exemptions means more paths get flagged. **These are safe, indeed stronger, on `main` today.**

**Test 3** (*"every grandfathered entry is still tracked"*) fails today only because `_grandfathered` currently lists 5 files that don't exist on `main`. This is not a real design coupling — it's a mismatch between the map's contents and the branch it would run against. **Fix: ship this file on `main` with `_grandfathered` matching `main`'s actual tracked set (today, an empty map) rather than `sprint1-my-library`'s.** The test then passes vacuously, correctly, and the deny-check (test 2) becomes maximally strict in the process.

**Test 10** is the one genuine coupling. Its own logic:
```dart
final neededBySizeGuard = _grandfathered.keys
    .where((p) => (sizes[p] ?? 0) > _maxTrackedFileBytes);
expect(neededBySizeGuard, isNotEmpty, ...);
```
This test exists to prove the size-guard mechanism is actually being exercised by something, not just present and untested — consistent with this project's own stated discipline of proving gates by deliberate breakage rather than trusting them unverified. **With an empty or all-small `_grandfathered` map, `neededBySizeGuard` is empty and this test correctly, intentionally fails** — it's designed to catch exactly the situation "the size guard has nothing to prove itself against."

### Conclusion

**The gate does not need to remain coupled to the grandfathered content to provide its protection.** Nine of ten tests are safe — several become *strictly stronger* — merged to `main` today with an empty grandfather list. **Exactly one test (10) has a real, deliberate coupling**, and it exists specifically to prevent the size guard from becoming untested dead code — which is a legitimate concern, not an oversight.

**Recommended resolution (not implemented in this sprint):** split the file into two groups matching what's already structurally true — an unconditional core suite (tests 1–9, safe on any branch) and a completeness-proof (test 10) that is explicitly allowed to report "not yet applicable — no oversized tracked file exists to prove this against" rather than hard-failing, until a real one exists. That single change lets **G16's protective mechanism reach `main` immediately**, ahead of and independent of G10, while preserving — not weakening — every property the gate currently guarantees. The alternative, waiting for G10 to unblock G16 entirely, means `main` stays unprotected by this gate for exactly as long as the legal question stays open — precisely backwards from what a preventive control should do.

---

## Executive Summary

`main` is 25 commits and roughly 70,000 lines behind `sprint1-my-library`. This plan classifies all 16 identified release groups: **6 Ready to Merge**, **6 Requiring Additional Technical Review**, **3 Requiring Commit Split**, and **1 Blocked by Legal**. The overwhelming majority — 15 of 16 groups — carry no legal blocker at all and can proceed on engineering judgment; only the tafsir-import group (G10) is genuinely stuck, and it is stuck on a question this engagement has been unable to resolve for six-plus sprints regardless of technical readiness elsewhere. The most consequential finding is procedural rather than legal: the CI licence gate (G16), built specifically to prevent a repeat of the G10 problem, was assumed to be stuck waiting for G10 — reading its actual implementation shows nine of its ten tests are safe, and several strictly stronger, merged to `main` today with no dependency on G10 at all. Getting that protection onto `main` immediately, rather than after the legal question resolves, is the single highest-leverage action available right now.

## Top 5 Risks

1. **G10 (tafsir import) has no resolution timeline**, and every other release touching content or store readiness (G11, G12) is downstream of it in usefulness if not in code. Six-plus sprints of unresolved licence enquiries is itself the dominant risk to this entire program.
2. **G8's 229-file mega-commit is a single point of review failure.** Until it's split, nothing that depends on it (G13, and by extension the truthfulness of the shipped AI Tutor/Smart Learning surface) can be safely merged, reviewed, or reasoned about at commit granularity.
3. **`main` currently has zero content-gate protection**, and has had none since it diverged. Every day this stays true is a day a restricted-content mistake on `main` itself is possible, with nothing to catch it — independent of whatever happens with `sprint1-my-library`.
4. **G12's live-on-merge property is easy to miss in a normal review pass.** A reviewer treating this as an ordinary docs/website PR could inadvertently publish unreviewed legal text the moment it merges, with no separate deploy step to catch it.
5. **Schema drift across G5/G6/G7** (three separate `DATABASE.md`-touching commits, reviewed together on `sprint1-my-library` but never individually validated against `main`'s actual current schema) risks a merge that resolves cleanly in git but not at runtime, if `main`'s schema has diverged in ways these commits didn't anticipate.

## Recommended Next Sprint

**Two workstreams, both immediately actionable, neither blocked by G10:**

1. **Split G8** into per-feature commits. This is the single highest-leverage unblock in the plan — it's the prerequisite for G13, and by volume it's most of the remaining review burden in Phases 2–3.
2. **Split and merge G16's core mechanism** (Part 3 above) to `main` on its own, ahead of everything else. This is small, well-scoped, strictly increases protection, and — unlike everything touching G10 — doesn't need to wait for a legal answer that may not arrive soon.

Running both in parallel gets real protection onto `main` and clears the largest structural obstacle in the plan, without touching the one thing (G10) that genuinely can't be rushed.
