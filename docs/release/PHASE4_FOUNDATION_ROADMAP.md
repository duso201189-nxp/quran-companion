# Phase 4 — Foundation Roadmap

Planning only. No production code, no commits.

Supersedes the track structure in `PHASE4_IMPLEMENTATION_MASTER_PLAN.md`
(not its findings). Read against `DR-2026-0017`, `DR-2026-0018`,
`DR-2026-0019`, and `RELEASE_DASHBOARD.md`.

---

## 0. What changed, and why this document exists

The master plan answered *"do the beta blockers need the architecture?"*
— no. This document answers a different and better question:

> **What will cost more to change after beta than before it?**

Asking it produced two corrections to my own previous recommendation
(§1), one finding that lowers a risk I had assumed (§2.1), and one
hazard nobody has recorded (§2.2). The recommendation moves from *"defer
all architecture"* to *"do three specific things first, defer the rest"*
— and the reason is not that the architecture became more valuable, but
that I was wrong about what beta can teach.

## 1. Two corrections to the master plan

### C1 — A four-week closed beta cannot validate the retention thesis. I claimed it could.

The master plan's epic C2 promised *"an explicit verdict on the
retention thesis (supported / partly / contradicted)."*

**That was overclaimed.** The thesis is that spaced repetition over
Qur'anic vocabulary and resurfaced reflection produce durable
understanding. Durable is the operative word: it is a months-horizon
outcome, and measuring it properly would need instrumentation the
privacy position forbids.

What a 4-week beta with 10–50 users *can* establish:

| Can measure | Cannot measure |
|---|---|
| Does it work on real hardware | Whether retention improves |
| Do people return daily | Whether comprehension grows |
| What they ask for, unprompted | Whether SRS beats plain re-reading |
| Where they get stuck | Long-horizon efficacy of anything |

So beta yields **demand signal and a priority ranking** — not a verdict.
That is still decision-relevant, but it is weaker evidence than the
master plan assumed.

**This changes the calculus.** "Defer all architecture until the verdict"
was reasonable when a verdict was coming. Since no clean verdict is
coming, some architecture must be chosen on judgement — and the right
selection criterion becomes **option value**: pick what unblocks the
most possible futures, cheaply, rather than waiting for evidence that
will arrive muddy.

### C2 — "After beta" plausibly means "never," and I waved that away

The master plan listed this as risk #5 and accepted it: *"unbuilt
architecture that was correctly deferred is not waste."*

That is true of architecture that turns out not to be needed. It is
**not** true of architecture that is needed and never gets built because
a solo maintainer with live users is pulled permanently into feature
work by their feedback. The window closes.

The correct response is not "do it all now." It is: **identify the
subset that is cheap, unblocks the most futures, and realistically will
not happen later** — and do only that. §6.

## 2. Two findings from the code

### 2.1 Sharing produces text, not links — no public reference format is locked in

`DR-2026-0017` §6 defines a serialization format (`2:255`, `2:255:4`).
I expected beta sharing to lock it in prematurely.

Checked: `reading_screen.dart:999` implements share as **text**
(`_copyAyah(forShare: true)` appends `" (Qur'an Companion)"`). There is
no URL, no `share_plus`, no deep-link handler, no `app_links`.

**Consequence — a risk I assumed is not real.** No public reference
format exists to be locked in, so the serialization can be adopted
whenever it is needed at zero migration cost. This *lowers* the priority
of address work.

**One conditional guard**: if beta feedback prompts adding shareable
links, use `DR-2026-0017` §6's format from the first commit. It is the
familiar `2:255` form anyway, so adopting it costs nothing and prevents
inventing a second format that later needs migrating.

### 2.2 Session history is stored **0-based**, and `DR-2026-0017` I3 mandates 1-based — an unrecorded hazard

```dart
/// Chỉ số Ayah 0-based trong Surah — khớp ReadingPositionStore.
IntColumn get ayahFrom => integer().named('ayah_from')();
```

`study_sessions` stores āyah indices **0-based**. `DR-2026-0017` I3
requires Addresses to be 1-based everywhere, without exception.

This is **not** a growing migration cost — `DR-2026-0017` Rule 2 already
requires translation at the repository boundary, so the conversion is a
permanent boundary concern rather than a data migration.

It **is** a hazard: if anyone changes the writer to 1-based without a
`data_version` marker, old and new rows become indistinguishable and
**every streak and study-time statistic silently corrupts**. There is no
way to tell a 0-based row from a 1-based one after the fact.

**Mitigation, and it belongs pre-beta because that is when history
starts mattering to real people**: document the 0-based storage
convention at the column and in `DR-2026-0017`'s migration section, and
make "never change the base without a version marker" an explicit rule.
Cost: a comment and a paragraph. Value: prevents an unrecoverable
data-integrity failure.

## 3. Track structure

The user's two-track framing is correct for the decision that matters —
but one class of work belongs in neither, because it does not compete
for engineering time.

| Track | Contents | Competes for engineering time? |
|---|---|---|
| **Track Ø — External** | Licensing, legal, store paperwork, the QAC decision | **No.** Zero engineering cost, longest lead time. Runs continuously from week 0 regardless of every other decision here. |
| **Track A — Foundation Architecture** | Architecture that must exist before beta | Yes |
| **Track B — Product Validation** | Everything required to put the app in real hands and learn | Yes |

Track Ø is not a compromise on the two-track framing; it is the
recognition that treating zero-cost, long-lead items as *sequenced work*
was the master plan's strongest finding and remains true. It is stated
first so it cannot be dropped by a reader who only reads the ranking.

## 4. Must-exist-before-beta analysis

For each candidate: what does beta make more expensive?

| Item | What beta locks in | Cost if delayed | Verdict |
|---|---|---|---|
| **Device access verification** | Nothing — but late discovery invalidates the schedule | **High** — replanning mid-phase | **Before** (week 0) |
| **Permission set** (background audio) | A shipped foreground-service permission; removing it later is a **store-listing change**, not a code change | **High** | **Before** — decide the full permission set at first submission |
| **Crash reporting decision** | Crashes during beta are unobservable if `NoopCrashReporter` still ships | **High** — the data is gone, not delayed | **Before** |
| **Auto-scroll behaviour (A5)** | Testers learn the current behaviour; changing it later is a UX change on established expectations | Medium | **Before** — cheap, and it makes testers learn the final behaviour |
| **0-based storage convention** (§2.2) | Real users' streak history | **High if mishandled**, zero if documented | **Before** — document it |
| **Session semantics** (`DR-2026-0018` S4) | Analytics definition; history is **not recomputable** from `study_sessions` | **Medium for closed beta** (30 testers, tell them stats reset) · **High for public beta** | **Before public beta, not before closed** |
| **Address serialization** | Nothing today — sharing is text (§2.1) | **Low** | **After** — unless links ship, then adopt §6's format immediately |
| **Decoration extraction (D2)** | Nothing stored, nothing public | **Low migration cost, but high option cost** — see §6 | **Judgement call** |
| **Basmalah declarative (D3)** | Nothing — behaviour-identical by design | **Low** | **After** |
| **Audio/scroll split (D4)** | Nothing stored | **Low** (A5 captures the user-visible part) | **After** |
| **Render + frame builder (D5)** | Nothing stored | **Low** | **After** |
| **Word foundation (D6)** | Schema + stored word addresses | **High** — but gated on the QAC answer anyway | **After** |

**The pattern worth naming**: almost every architecture item has a *low*
migration cost, and that is not luck. `DR-2026-0017` I7 forbids
migrating user data; `DR-2026-0018` and `DR-2026-0019` propose no schema
change through S5/E5. **The architecture is cheap to defer because it
was designed to be additive.** Had `DR-2026-0017` proposed rewriting
`bookmarks.ayah_id` into addresses, this table would read very
differently.

The genuinely expensive items are almost all *not* architecture:
external lead time, device access, permissions, and crash-data
observability.

## 5. Scoring and priority matrix

Scale 1–5, judgement-calibrated, not measured. **Migration Cost is the
cost of *delaying past beta*** — so a high score argues for doing it
early, unlike the other three.

| Epic | Track | User Value | Arch Value | Validation Value | Migration Cost | Verdict |
|---|---|--:|--:|--:|--:|---|
| **Ø1** External: licensing, legal, store, QAC | Ø | 0 | 0 | 1 | **5** | **Week 0, continuous** |
| **B0** Device access verification | B | 0 | 0 | **5** | **5** | **Week 0** |
| **B1** Background audio + lock screen | B | **5** | 1 | **4** | 3 | **Pre-beta** |
| **B2** Crash-reporting decision | B | 1 | 2 | **5** | **4** | **Pre-beta** |
| **B3** Audio cache UI | B | **4** | 1 | 2 | 1 | Pre-beta |
| **B4** Real-device a11y + performance | B | 3 | 0 | 3 | 2 | Pre-beta |
| **B5** Release mechanics | B | 1 | 0 | **5** | 1 | Pre-beta |
| **B6** Closed beta launch | B | 0 | 0 | **5** | 0 | The point |
| **B7** Feedback synthesis | B | 0 | **5** | **5** | 0 | Gate |
| **A1** Address subset (Surah/Āyah only) | A | 0 | 4 | 0 | 1 | **Foundation** |
| **A2** Decoration extraction | A | 0 | **5** | 0 | 2 | **Foundation** |
| **A3** Auto-scroll politeness | A | **4** | 1 | 2 | 2 | **Foundation** |
| **A4** 0-based convention documented | A | 0 | 2 | 0 | **4** | **Foundation** |
| **D3** Basmalah declarative | — | 0 | 2 | 0 | 1 | Defer |
| **D4** Audio/scroll split | — | 2 | 4 | 0 | 2 | Defer |
| **D5** Render + frame builder | — | 0 | 4 | 0 | 2 | Defer |
| **D6** Word foundation | — | 4* | 3 | 0 | **5** | Defer — gated on QAC |

\* D6's user value is conditional on the retention thesis, which §1 C1
establishes beta cannot settle.

### Priority matrix

```
      HIGH  │  Ø1 ●        ● B0                    │
  Migration │  A4 ●   B2 ●                         │  D6 ●
    Cost    │              ● B1                    │   (gated)
  (if       │                                      │
   delayed) ├──────────────────────────────────────┼──────────────
            │  A3 ●  A2 ●                          │
            │  D4 ●  D5 ●                          │  B7 ●
      LOW   │  D3 ●  A1 ●  B3 ●  B4 ●  B5 ●        │  B6 ●
            └──────────────────────────────────────┴──────────────
                   LOW  ◀────  combined value  ────▶  HIGH

  Upper band  → do before beta regardless of value (lock-in risk)
  Lower-right → do before beta because value is high and cost is low
  Lower-left  → defer; cheap to revisit  ← almost all the architecture
```

The shape of that plot is the argument: **the entire deferrable
architecture cluster sits in the low-cost band**, and the
must-do-early items are dominated by external and operational
concerns rather than by design work.

## 6. The recommended Foundation Sprint

> **Four items. None changes schema. None changes stored formats. All
> four are cheap, and all four get materially harder or more dangerous
> after real users exist.**

| # | Item | Why it must be in the Foundation Sprint |
|---|---|---|
| **F1** | **`Address` + `Range`, Surah/Āyah levels only** | The subset that has a consumer *today*. Word and Segment levels are additive later at **zero** migration cost — `DR-2026-0017`'s arity-based grammar means adding a level changes nothing already emitted. Building only what F2 needs. |
| **F2** | **Decoration extraction** (`DR-2026-0019` E1) | **The highest option value in the plan.** It unblocks tafsīr display, reflection markers, *and* AI citations — three different futures, and beta will name at most one. Buying an option cheaply beats waiting for a verdict that §1 C1 shows will not arrive cleanly. It is also golden-testable and isolated, so its risk is measurable. |
| **F3** | **Auto-scroll politeness** (master plan A5) | XS. Makes testers learn the *final* behaviour rather than one that changes under them. Its architectural successor (D4) later replaces it in place. |
| **F4** | **Document the 0-based storage convention** (§2.2) | A comment and a paragraph. Prevents silent, unrecoverable corruption of every streak statistic. The cheapest high-value item in this entire document. |

**Explicitly excluded from the Foundation Sprint**, with reasons:

- **Full `Address` (Word/Segment)** — no consumer until D6; additive later.
- **Session/pipeline types (`DR-2026-0018` S0, `DR-2026-0019` E0)** — F2
  needs only enough address to key a map, not the full contracts.
- **D3 Basmalah** — real cleanup, zero migration cost, no consumer waiting.
- **D4 audio/scroll split** — F3 captures the user-visible part; the
  structural fix waits.
- **D5, D6** — no; D6 is gated on the QAC answer regardless.

### Why this is smaller than `DR-2026-0019` E0+E1 as written

That ADR sequences E1 behind E0, which depends on `DR-2026-0017` M0 and
`DR-2026-0018` S0 — three prerequisite steps. **F2 does not need them.**
A decoration map needs a key type, and an Āyah-level `Address` is a
sufficient key. The pipeline contracts, session types, and word levels
are prerequisites for the *full* engine, not for extracting one map.

That is a real reduction: **from six milestones to two**, with the same
option value delivered.

## 7. Sequence

```
 wk  0     1     2     3     4     5     6     7     8 ...
     │     │     │     │     │     │     │     │     │
 Ø   ├──── licensing · legal · store · QAC ────────────────────▶
     │
 A   ├─F4─┤├── F1 ──┤├──── F2 ────┤                              Foundation
     │    ├─F3─┤                                                  (~2 wks)
     │
 B   ├─B0─┤      ├──── B1 background audio ────┤├─B5─┤
     │           ├─B2─┤   ├─── B3 cache ───┤
     │                        ├──── B4 device verify ────┤
     │                                          ├── B6 beta ──┼─ B7 ─┤
```

Foundation runs first and is short. It does **not** delay beta, because
B0/B1's long pole (background audio, plus device procurement if B0 finds
a gap) runs concurrently and is the actual critical path.

## 8. Challenging this recommendation

As requested — and two of these landed.

**Challenge 1 — Is F2 justified without evidence?**
It is the one item chosen on judgement rather than need. Steelman
against: no consumer exists today; it could wait; it violates the
project's own `DR-2026-0006`/`0007` precedent (*"a provider without a
consumer is speculation"*).
**Held, narrowly.** The precedent forbids building a *capability* with
no consumer. F2 builds no capability — it relocates existing logic out
of a 1,265-line widget so that three plausible next features are
additive. If beta names any of tafsīr, reflection, or citations, F2 was
required; if it names none, F2 cost a contained, golden-tested refactor.
**But if capacity is tight, F2 is the first thing to cut** — it is the
only Foundation item that is not either free or protective.

**Challenge 2 — Does the Foundation Sprint delay beta?**
No, and this is checkable: beta's critical path is B0 → B1 → B4 → B5 →
B6, with background audio the long pole. Foundation is ~2 weeks of work
that fits inside that. **If it ever competes, beta wins** — the whole
argument of §1 is that learning is the scarcer resource.

**Challenge 3 — Am I still over-planning?**
Since Phase 3 closed at `50c6c16`, this engagement has produced **seven
planning documents and zero lines of code**: a product vision, four
decision records, a master plan, and this. Each was requested and each
found something real. But the marginal value of an eighth plan is now
plainly below the marginal value of starting F4 — a comment — or B0 — a
phone call.

**This document should be the last plan before work starts.** If the
next request is for more planning, that is worth questioning before it
is worth answering.

**Challenge 4 — Should the whole thing be replaced again?**
Considered, and no. The master plan's core finding — validate before
committing the architecture program — survived scrutiny and was
*strengthened* by §1 C1, not weakened: beta yields less evidence than I
claimed, which argues for choosing architecture by option value rather
than for choosing more of it. The change here is a correction of
selection criteria, not a replacement of the strategy. A third full
rewrite would be churn.

## 9. Recommendation

1. **Week 0, in parallel and before anything else**: start Track Ø
   (licensing, legal, store, QAC — zero engineering, longest lead), run
   **B0** device-access verification, and land **F4** (document the
   0-based convention — one comment, one paragraph).
2. **Weeks 1–2**: Foundation Sprint — **F1 → F2**, with **F3** slotted
   anywhere. Cut F2 first if capacity slips.
3. **Weeks 1–6, concurrently**: Track B — **B1** background audio (long
   pole), **B2** crash-reporting decision, **B3** cache UI, **B4**
   device verification, **B5** release mechanics.
4. **Weeks 5–7**: **B6** closed beta.
5. **Week ~10**: **B7** synthesis — a *demand ranking*, not a thesis
   verdict (§1 C1). Then choose D3/D4/D5 by what it says, and D6 only if
   the QAC answer allows.
6. **Before any public beta** (not closed): settle session semantics
   (`DR-2026-0018` S4), because study history stops being
   discard-able once it belongs to people who did not sign up to be
   testers.

**The smallest foundation that buys the most**: F1 + F2 + F3 + F4 — two
weeks, no schema change, no stored-format change, one option purchased
cheaply, one hazard closed, one annoyance removed before anyone meets
it.

---

PHASE 4 FOUNDATION ROADMAP — planning only. No production code, no
commits.
