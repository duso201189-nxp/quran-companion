# Product Readiness Review — Phase 3

Date: 2026-08-03 · HEAD `0ef9b9c` · No code, release document, or commit
was modified to produce this review.

Every figure below was measured against the working tree today, not
carried over from any prior document. Where a release document and the
code disagree, the code wins and the disagreement is recorded in §5.

---

## 1. Product maturity

**Engineering maturity: high. Product maturity: incomplete. These are
not the same axis, and conflating them is the main risk in this
project's own release documents.**

Measured today:

| Signal | Value |
|---|--:|
| Hand-written Dart (`lib/`, excl. generated) | 27,707 LOC |
| Generated Dart (Drift + l10n) | 17,825 LOC |
| Test code | 19,152 LOC |
| Tests passing | **802 / 802** |
| Coverage (hand-written product code) | **81.53%** |
| Feature modules | 18 |
| Routes | 22 |
| Screens | 24 |
| `TODO`/`FIXME` in production code | **3** |
| CI jobs | 5 (secret scan, quality, Android, Web, iOS) |
| Platforms building green | Android, iOS, Web |

**Test-to-production ratio of 0.69:1 and 81.5% coverage with a
`--fatal-infos` analyzer gate is a genuinely strong engineering
posture** — better than most products at public beta. Three TODOs
across 27k lines is unusually disciplined. The architecture is
consistent and enforced: domain/data/presentation separation, a single
repository-boundary error choke point (`withFailureLogging`), Riverpod
throughout, a reliability layer with structured failures, and
automated gates (secret scan, licence/size boundary, coverage) that
have repeatedly caught real problems — including twice in this session.

**What holds it back is not code quality. It is that the product
surface makes promises the data layer cannot keep.** Three visible
affordances ship today in a state a beta user would read as broken:

1. **Lexicon and Flashcards are structurally dead on a real install.**
   All 8 Lexicon tables ship with **0 rows** (verified today by direct
   query of `assets/database/quran.sqlite`). For contrast, the same
   asset carries 114 surahs, 6,236 ayahs, 18,708 translations and
   43,652 FTS5 index rows — the core content pipeline works fine. Only
   the Lexicon half is empty. Flashcards depends on Lexicon, so
   lemma-backed cards render blank.
2. **Search's "Hỏi AI" (Ask AI) mode is a permanently locked toggle**
   (`search_screen.dart:94` — *"luôn khoá"*). It is visible, it is not
   removable by the user, and nothing behind it exists.
3. **Search's "Recent" and "Suggestions" rows render as grey skeleton
   chips** (`_PlaceholderChipRow`, `search_screen.dart:448`) — shapes
   with no text and no interaction, permanently.

A user cannot distinguish "not implemented" from "loading forever" or
"broken." That is the single largest gap between this codebase's
quality and its readiness to meet the public.

**Also found:** four localisation keys (`placeholderHome`,
`placeholderQuran`, `placeholderStudy`, `placeholderStats`) exist in
all three `.arb` files with **zero references in real code** — leftover
scaffolding from an earlier phase.

## 2. Completion toward v1.0

Splitting the estimate by axis, because a single percentage would hide
the actual situation:

| Axis | Estimate | Basis |
|---|--:|---|
| **Feature engineering** | **~92%** | Every v1.0-scoped feature is built and tested. What remains is Lexicon *data* (not code) and polish on three dead affordances. |
| **Quality infrastructure** | **~95%** | 802 tests, 81.5% coverage, `--fatal-infos` clean, 5 CI jobs, licence/size boundary gate, secret scanning, three platforms building. |
| **Release readiness** | **~30%** | Go/No-Go: 4 of 14 boxes explicitly checked (Search, Read Model, Web, coverage); 2 more (gates clean, zero P0 debt) satisfied but unmarked. 8 remain genuinely open, and most are not engineering. |
| **Content completeness** | **~85%** | Core Qur'an content complete and verified; Lexicon (8 tables) entirely absent. |

**Weighted for a v1.0 *public release*: ≈ 55–60%.**
**Weighted for a *public beta*: ≈ 75%** — beta tolerates deferred
features; it does not tolerate visible broken ones.

I deliberately do not reproduce `RELEASE_DASHBOARD.md`'s ≈58% figure:
its own note concedes the model predates three shipped sprints and was
never recomputed. The numbers above are independently derived.

## 3. Remaining work, classified

### Critical

| Item | Type | Note |
|---|---|---|
| **Lexicon content absent** (0/8 tables) | External | Pipeline exists (2,140 lines, tested); blocked on a QAC licence answer, deadline 2026-08-24. Kills Lexicon + Flashcards. |
| **Store & legal readiness unstarted** | Business/Legal | Icons, screenshots, privacy policy, Apple Privacy Manifest, Play Data Safety, signing certs. Hard submission gate. |
| **Tanzil translation licence unresolved** | Legal | Translations are non-commercial-only; binary risk, external lead time. Blocks monetisation permanently and store submission conditionally. |
| **Dead affordances visible to users** | Product | Ask AI locked toggle, Search skeleton chips, empty Lexicon/Flashcards. **This is the one Critical item that is fully engineering-solvable today.** |

### High

| Item | Type |
|---|---|
| No real-device accessibility audit (TalkBack/VoiceOver) | Engineering (needs hardware) |
| `PERFORMANCE.md` Android column unmeasured on real hardware | Engineering (needs hardware) |
| 8 direct + 3 dev dependencies outdated; 2 major-behind (`flutter_riverpod` 2→3, `go_router` 14→17), 1 EOL (`sqlite3_flutter_libs`) | Engineering (gated: `CLAUDE.md` "stop and ask") |
| Arabic/RTL barely exercised — generated `ar` strings 16/368 covered | Engineering |
| **9 Decision Records referenced but absent** (see §5) | Product/governance |

### Medium

| Item | Type |
|---|---|
| `pubspec.yaml` still `0.8.1+7` after 12 PRs and 6 sprints | Engineering (trivial, gated on release cut) |
| Background audio not implemented (`audio_service` absent from `pubspec.yaml` — verified) | Engineering |
| Audio cache management UI absent; `IoCacheManager` unwired | Engineering |
| D8 — soft-delete/upsert duplication, 23 sites / 7 files | Engineering |
| D5 — 4 dead files (3 with zero external refs; `io_cache_manager` referenced once, from a doc comment only) | Engineering |
| D6 remainder — duplicate empty-state shape ×5, entry-card pair | Engineering (blocked on visual-regression tooling) |
| 4 unused `placeholder*` l10n keys ×3 locales | Engineering (trivial) |

### Low

- D10–D14 (P2 debt): coupling smells, minor perf, unused route
  constants, eager audio-player construction, type-level layer-skipping.
- Search polish (Recent/Suggestions/Filters) **with real logic** — v1.1.
- Hifz mode, "Nhật ký" — never specified beyond a name; v2.0.
- `CrashReporter` remains a deliberate no-op (by design until a backend
  exists).

## 4. Blocker taxonomy

**Engineering (solvable now, no external input):**
dead-affordance cleanup · unused l10n keys · D5/D8/D6 debt · version
bump · background audio · audio cache UI

**Engineering (blocked on hardware access):**
accessibility audit · Android performance measurement · RTL verification

**Engineering (blocked on policy):**
dependency upgrades — `CLAUDE.md` designates major bumps "stop and ask";
`RELEASE_DASHBOARD.md` §6 documents real `.autoDispose` regression risk

**Product (decision, not work):**
what ships in beta without Lexicon · whether Ask AI stays visible ·
Web hosting target (and therefore whether the fastest storage tier is
reachable) · 9 missing Decision Records

**Legal:**
QAC morphology licence (Lexicon) · Tanzil translation non-commercial
terms · everyayah.com audio terms

**Business:**
store assets · privacy policy · Play Console / Apple Developer
enrolment · signing certificates

**External (waiting on a third party):**
QAC permission response — **deadline 2026-08-24**, owner: Product Owner

**The distribution matters more than the list.** Of ~20 open items,
only about half are engineering, and of those only about half are
executable without hardware or a policy decision. **Engineering is not
the bottleneck to v1.0. It has not been for several sprints.**

## 5. Completed work missing from release tracking

Five real gaps found — this is the section with the most actionable
findings:

1. **Sprint R1 (Search FTS5) has no "Completed work" entry** in
   `RELEASE_DASHBOARD.md` §2. R2, R3.2 and R3a all have one; R1 is
   mentioned only in passing in §3/§4/§7. The largest single feature
   shipped this phase is the one least recorded.
2. **`CHANGELOG.md` omits three shipped sprints.** Measured: `R3a` → 6
   mentions, `R3.1` → 1, but **R1 → 0, R2 → 0, R3.2 → 0**. Search
   wiring, the Read Model UI, and the coverage-policy change are absent
   from the changelog entirely.
3. **The repository-boundary threshold change (commit `0ef9b9c`,
   1 MB → 2 MB) is recorded nowhere** in any release-tracking document
   or the changelog. It is a governed policy change, justified only in
   an untracked report.
4. **`PROJECT_INDEX.md` — described in `CLAUDE.md` as the
   source-of-truth map — lists none of the six documents created this
   phase**: `RELEASE_GOVERNANCE_AUDIT.md`, `WEB_PLATFORM_VERIFICATION.md`,
   `MASAQ_ACCEPTANCE_REPORT.md`, `LEXICON_DATASET_VALIDATION.md`,
   `DR-2026-0015`, `DR-2026-0016`.
5. **`docs/adr/README.md` does not list `DR-2026-0016`.**

### The larger governance finding

**Nine Decision Records are cited across the codebase and documentation
but do not exist as files.** Only 7 of 16 referenced DRs are present:

```
present:  0001, 0003, 0004, 0005, 0014, 0015, 0016
missing:  0002 (26 refs)  0006 (3)   0007 (3)   0008 (10)
          0009 (11)       0010 (4)   0011 (4)   0012 (5)
          0013 (15)
```

`DR-2026-0013` is the repository-boundary licence gate — cited by 15
files **including the production test code that enforces it**, and
whose policy was just amended in commit `0ef9b9c`. The project amended
a policy whose governing record a reader cannot open. `docs/adr/README.md`
already documents this failure mode for `DR-2026-0002` alone; the real
count is nine.

For a project that runs under EIS and treats Decision Records as
governed artifacts (`PROJECT_CONSTITUTION.md`, `ROLES.md`), this is a
material integrity gap — not a filing inconvenience.

## 6. Next engineering epic — highest ROI

### **Epic R3b — Honest Surface Area (Beta Readiness)**

**Scope:** eliminate every user-visible affordance that cannot do what
it appears to offer.

- Remove or hard-gate the **"Hỏi AI" locked toggle** in Search.
- Remove or replace the **`_PlaceholderChipRow` skeletons** (Recent,
  Suggestions) with either real logic or nothing.
- Give **Lexicon and Flashcards an honest empty state** — a "coming
  soon"/"content not available in this build" treatment instead of
  blank cards — or feature-flag them out of the beta build entirely.
- Delete the **4 unused `placeholder*` l10n keys** ×3 locales.

**Why this is the highest ROI available:**

- It is the **only Critical-tier item that engineering can close
  unilaterally** — Lexicon needs a licence answer, store/legal needs
  business action, device verification needs hardware. This needs none
  of them.
- It is **the difference between a beta that reads as unfinished and
  one that reads as broken.** Users forgive absent features; they do
  not forgive features that appear present and do nothing. This is the
  cheapest credibility purchase on the board.
- It is **small**: three UI surfaces plus a key deletion, no
  architectural change, no new dependency, no schema change.
- It **de-risks the Lexicon deadline.** If 2026-08-24 passes without a
  QAC grant, the app is already presentable without Lexicon — the
  deferral becomes a documentation change, not a scramble.
- It **unblocks store screenshots** (`RELEASE_DASHBOARD.md` R4's one
  hard Lexicon dependency), because screenshots of an honest empty
  state are permanently valid; screenshots of blank cards are not.

**Second priority — Epic R3c: Release Record Reconciliation.** Close the
five §5 gaps and backfill the nine missing DRs (or formally record them
as unrecoverable). This is not busywork: sprint selection has already
been mis-driven twice this phase by stale tracking, and a public beta
invites outside readers into these documents for the first time.

**Explicitly not recommended next:** D8 (zero release impact, no defect
history), dependency upgrades (high regression risk, policy-gated,
better after beta feedback), background audio (real feature work, v1.1).

## 7. Scope recommendation

### v1.0 / Public Beta — ship this

Everything currently built and verified working:

- Reading (Uthmani text, translations, transliteration), audio playback
  (foreground), bookmarks/highlights/notes/favourites
- **Search with real FTS5** (43,652 indexed rows, verified in browser)
- Stats, Khatm progress, Daily Goal, Revision Queue, Bookmark Collections
- Full SRS learning engine: Review Session, Quiz, Learning Session
- The 5-layer study-recommendation chain: Analytics → AI Tutor →
  Learning Journey → Smart Learning → **Study Summary** (reachable)
- **Web platform** (verified working in-browser, CI-guarded)
- Android + iOS + Web

Conditional on Epic R3b: Lexicon and Flashcards ship **only** if data
lands by 2026-08-24; otherwise they are gated out or honestly labelled.

Required before public beta regardless: real-device accessibility pass,
Android performance measurement, `pubspec.yaml` bump, CHANGELOG cut,
store/legal assets, privacy policy.

### v1.1

- **Lexicon + Flashcards** (if deferred from v1.0)
- **Search polish** with real logic — Recent, Suggestions, Filters
- **Background audio** (`audio_service` + platform manifests)
- **Audio cache management UI** (wires up the existing `IoCacheManager`,
  closing D5's hardest case)
- **Technical debt**: D8, D5 remainder, D6 remainder
- **Dependency upgrades** — deliberately, post-beta, with per-package
  regression passes
- Coverage gate raised further as RTL/Arabic coverage improves

### v2.0

- **Authentication** (Supabase) — prerequisite for everything below
- **Cloud sync** — the `SyncColumns` mixin is already groundwork
- **Real crash reporting** — swap `NoopCrashReporter` for a real
  backend; the interface boundary already exists
- **Real AI/RAG** — genuinely new capability; today's "AI Tutor" is
  rule-based local aggregation with no model call. The locked "Ask AI"
  affordance is a placeholder for this and should not ship visible
  until it is real.
- **Hifz mode** — needs product definition before engineering scoping
- Platform widgets (home-screen, lock-screen controls)

---

## Bottom line

This is a **well-engineered product with an incomplete product
surface**, four sprints past the point where engineering was the
constraint. The remaining critical path runs through a licence inbox, a
store console, and a physical device — not through the codebase.

The highest-leverage engineering action left before public beta is not
building anything new. It is making the app stop advertising things it
cannot do.

---

PRODUCT READINESS REVIEW COMPLETE
