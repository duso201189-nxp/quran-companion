# Phase 4 — Implementation Master Plan

Planning only. No production code was written, nothing was committed.

Read against: `DR-2026-0017`, `DR-2026-0018`, `DR-2026-0019`,
`PRODUCT_READINESS_REVIEW.md`, `RELEASE_DASHBOARD.md`, `CHANGELOG.md`,
and `QURAN_COMPANION_PRODUCT_VISION.md`.

---

## 0. Summary — the plan I am recommending is not the plan the ADRs imply

The three Phase 4 architecture records propose **nineteen milestones**
between them (`DR-2026-0017` M0–M6, `DR-2026-0018` S0–S6,
`DR-2026-0019` E0–E6). Concatenating them produces a coherent
engineering program that delivers, by its own admission, **no
user-visible change until the fifteenth step**.

I wrote those three records. I am recommending against starting them.

The reason is a single verified fact:

> **Zero of the Public Beta blockers are unblocked by any of the
> nineteen milestones.**

Checked directly, not inferred:

| Beta blocker | Needs the address/session/engine work? |
|---|---|
| Background audio | **No.** `audio_service` is absent from `pubspec.yaml`; this is a platform integration (foreground service, media session, manifest/`Info.plist`), touching neither the reading screen nor `AudioController`'s position model. |
| Audio cache UI | **No.** `IoCacheManager` has **zero references outside its own file** — verified by grep. This is wiring an existing engine to a new screen. |
| Real-device a11y pass | **No.** Measurement. |
| Android performance measurement | **No.** Measurement. |
| Store assets, privacy policy, legal | **No.** Not engineering at all. |
| Version bump, changelog cut | **No.** |

The architecture is correct. Its **timing** is wrong for this phase.
§3 states the alternative and §4 quantifies it.

---

## 1. What Phase 4 is actually for — forcing the choice

Two definitions are in circulation and they are not compatible at solo
capacity:

- **(a) Ship Public Beta** — `RELEASE_DASHBOARD.md`'s Go/No-Go, the
  vision document's Phase 4 framing.
- **(b) Build the reading-engine foundation** — the three ADRs.

Attempting both in one phase, alone, produces neither. The plan below
chooses **(a), with a deliberately small architectural subset**, and
§3 explains why the choice runs that direction rather than the other.

**Phase 4 is redefined here as: get the product in front of real users,
learn what they actually need, and only then commit the architecture
program.**

## 2. Three findings that change the sequencing

### F1 — The product thesis is unvalidated, and the entire architecture serves it

`QURAN_COMPANION_PRODUCT_VISION.md` §3 asserts the differentiator is
**retention** — vocabulary, reflection resurfacing, the re-encounter
loop. The word-addressable architecture exists almost entirely to serve
that thesis: tap-to-meaning, word-level capture, citation.

**Nobody outside the author has ever used this application.** The
thesis is a well-argued hypothesis with zero evidence behind it.

If beta users say what they want is tafsīr, background audio, and a
better mushaf, then nineteen milestones of correct engineering were
aimed at the wrong target. That is not an argument against the
architecture — it is an argument for finding out first, and it is
cheap to find out.

### F2 — The externally-blocked items are being sequenced as work, and they are not work

`RELEASE_DASHBOARD.md` §8 places store/legal readiness in R4, *after*
R1–R3. Three of the longest-lead items in the entire project sit there:

| Item | Lead time | Engineering cost |
|---|---|---|
| Translation commercial licensing | Weeks–months, external | **Zero** |
| Tanzil translation legal review | Weeks, external | **Zero** |
| QAC / Lexicon decision | Deadline **2026-08-24** — 21 days | **Zero** |

Scheduling a zero-cost, long-lead item *after* engineering work adds its
entire lead time to the end of the project. Starting all three on day 1
costs nothing and removes them from the critical path.

**This is a pure sequencing win with no trade-off.** It should happen
regardless of every other decision in this document.

### F3 — Beta is being treated as one event; it should be two

The Go/No-Go checklist describes a **public** beta: store listing,
screenshots, privacy policy, Play Console, App Store review.

A **closed** beta — internal testing track / TestFlight, 10–50 invited
users — needs almost none of that. It needs a build that installs, does
not crash, and is not embarrassing.

Splitting them moves first real user contact forward by roughly two
months, and moves it *before* the architecture commitment rather than
after.

## 3. The innovation: sequence by information gained, not value delivered

In a pre-validation phase, the correct sort order is not "highest user
value first." It is **highest information gained per week**, because
every downstream decision is currently being made without evidence.

That reordering produces four classes, in priority order:

| Class | Rule | Contents |
|---|---|---|
| **1. Unblocks learning** | Ship it because nothing is knowable until it exists | Closed beta, feedback capture |
| **2. Prevents learning from being confounded** | Ship it because its absence would mask every other signal | Background audio, crash-free operation |
| **3. Long lead, zero cost, blocks later phases** | Start it now, in parallel, forever | Licensing, legal, store paperwork |
| **4. Delivers value but teaches nothing yet** | Defer until class 1 reports | **All nineteen architecture milestones** |

**Background audio's justification changes under this rule, and becomes
stronger.** The vision document argued it is "the highest
user-value-per-hour item." The better argument is that its absence is a
**churn mode that would poison the experiment**: beta users who leave in
week one because playback stops when they lock the phone never give
feedback on retention, vocabulary, or anything else. It is not shipped
because it is valuable; it is shipped because without it the beta
measures the wrong thing.

## 4. Quantified trade-off

Estimates, not measurements. Unit is *weeks of focused solo work*;
assumptions stated so they can be disagreed with.

**Plan A — architecture first** (concatenate the ADRs, then ship)

```
 19 architecture milestones  ~10–16 wks   (avg 0.5–1 wk; some days, some weeks)
 beta enablement             ~4–6 wks
 ────────────────────────────────────────
 first real user feedback    week 14–22   (month 4–5)
```

**Plan B — validate first** (recommended)

```
 beta enablement (A1–A4)     ~4–6 wks     (external tracks run in parallel)
 closed beta live            week 5–7
 first real user feedback    week 6–8     (month 1.5–2)
 architecture, informed      week 8+
```

**Delta: feedback arrives 8–14 weeks earlier.**

| Scenario | Plan A cost | Plan B cost |
|---|--:|--:|
| Retention thesis is **correct** | 0 | 0 — same total work, later start |
| Thesis is **partly mis-prioritised** (30% of architecture mis-aimed) | ~4–5 wks wasted **+** 3 months of no user contact | ~0 — the 30% is never built |
| Thesis is **substantially wrong** | ~10+ wks wasted | ~0 |

Plan B is weakly dominant: it costs nothing if the thesis holds and
saves substantially if it does not. **The only condition under which
Plan A wins is certainty about an unvalidated hypothesis.**

### The counterargument, tested rather than dismissed

`DR-2026-0019` §15 A8 argues deferral is costly because *"every feature
added to `AyahCard` before the split makes the split more expensive."*

Checked against the actual beta work: background audio touches
`AudioController` and platform config, not the reading screen. Cache UI
is a new screen. A11y fixes are small and local. Store work touches no
code.

**The beta program barely touches `reading_screen.dart` (1,265 lines) or
`AyahCard`.** The decay argument is real in general and近 zero for this
specific 6–8 week window.

**One exception, stated as a conditional**: if beta feedback prioritises
**tafsīr**, tafsīr display lands inside the reading screen and would
genuinely benefit from `DR-2026-0019` E1 (decoration extraction) first.
That is the trigger to pull E1 forward — §7.

## 5. Recommended roadmap

Four tracks. A, B, C run concurrently. D is gated on C2.

```
 wk  0    1    2    3    4    5    6    7    8 ...
     │    │    │    │    │    │    │    │    │
 A   ├─A0─┼──A1 background audio──┼─A4─┤          engineering → beta
     │    ├─A5─┤   ├──A2 cache UI──┤   │
     │         │        ├──A3 device verify──┤
     │
 B   ├────────── B1/B2/B3/B4 external, continuous ──────────────▶
     │
 C   │                             ├─C1 closed beta─┼──C2 synthesis──┤
     │
 D   │                                              ╎ gated on C2 ▶▶▶
```

### Track A — Beta enablement

| ID | Epic | Objective |
|---|---|---|
| **A0** | Device access verification | Confirm physical Android + iOS hardware exists **before** planning around A3 |
| **A1** | Background audio + lock-screen controls | Remove the churn mode that would confound the beta |
| **A2** | Audio cache management UI | Make the offline claim true for audio |
| **A3** | Real-device verification (a11y + performance) | Two unchecked Go/No-Go boxes |
| **A4** | Release mechanics | Version bump, changelog cut, signed build, internal track |
| **A5** | Auto-scroll politeness (tactical) | Remove the daily annoyance without the architecture |

### Track B — External (start day 1, zero engineering)

| ID | Epic | Objective |
|---|---|---|
| **B1** | Translation commercial licensing | Unblock *all* future revenue — `en_sahih` is non-commercial today |
| **B2** | QAC / Lexicon decision | Deadline **2026-08-24**; decide, do not extend |
| **B3** | Store & legal assets | Privacy policy, icons, screenshots, Play/App Store enrolment |
| **B4** | Tanzil translation review | Binary licensing risk, external lead time |

### Track C — Learning

| ID | Epic | Objective |
|---|---|---|
| **C1** | Closed beta launch + feedback capture | First real users; a channel for what they say |
| **C2** | Feedback synthesis + architecture go/no-go | Decide what Phase 5 is, with evidence |

### Track D — Architecture (deferred, gated on C2)

| ID | Epic | Maps to |
|---|---|---|
| **D1** | Foundation value types | 0017 M0 · 0018 S0 · 0019 E0 |
| **D2** | Decoration extraction | 0019 E1 |
| **D3** | Basmalah declarative | 0017 M2 · 0019 E2 |
| **D4** | Audio/scroll split + sync policy | 0017 M3 · 0018 S2 · 0019 E3/E4 |
| **D5** | Render pipeline + frame builder | 0019 E5 · 0018 S1/S3/S4 |
| **D6** | Word foundation | 0017 M4/M5 · 0018 S6 · 0019 E6 — **gated on B2** |

## 6. Epic definitions

### A0 — Device access verification

| Field | |
|---|---|
| **Objective** | Confirm a physical mid-range Android device and an iOS device are available for A3. |
| **Complexity** | XS (hours) |
| **Migration risk** | None |
| **Dependency** | None |
| **Rollback** | N/A |
| **DoD** | Both devices identified and confirmed usable, **or** procurement started and A3 re-planned around the gap. |
| **Release impact** | None directly — but `RELEASE_DASHBOARD.md` §6 flags device access as *unverified*, and two Go/No-Go boxes assume it. **This is the item most likely to become the silent critical path.** Do it in week 0. |

### A1 — Background audio + lock-screen controls

| Field | |
|---|---|
| **Objective** | Playback continues when the app is backgrounded or the screen is locked, with OS media controls. |
| **Complexity** | **Medium–High.** New dependency (`audio_service` or `just_audio_background` — absent from `pubspec.yaml` today), Android foreground service + permission, iOS background audio mode, media-session metadata, notification handling. Fiddly across three platforms and poorly covered by automated tests. |
| **Migration risk** | **Medium.** Touches `AudioController` and platform manifests. No device-level automated coverage exists, so verification is manual. |
| **Dependency** | A0 (for real verification) |
| **Rollback** | Revert the integration. **Caveat**: once a build requesting a foreground-service permission reaches a store track, removing it later is a listing change, not just a code change. Decide the permission set before first submission. |
| **DoD** | Playback survives backgrounding and lock on both platforms; lock-screen controls work (play/pause/next/previous); audio focus is handled (pauses on call/other audio); manually verified on real hardware; gates clean. |
| **Release impact** | **Removes the single largest beta churn risk.** Closes no Go/No-Go box (none covers it) but is a prerequisite for the beta measuring anything real. |

### A2 — Audio cache management UI

| Field | |
|---|---|
| **Objective** | Make offline audio real: download by surah/juz/reciter, show size, delete. |
| **Complexity** | **Medium.** The engine exists — `IoCacheManager` — and is **completely unwired** (zero references outside its own file, verified). Work is a screen plus wiring, not an engine. |
| **Migration risk** | **Low.** Additive: a new screen and a provider. Nothing existing changes behaviour. |
| **Dependency** | None (A1 makes it more valuable, not required) |
| **Rollback** | Remove the route and screen; the engine returns to dormant. |
| **DoD** | Download/delete works per reciter and per surah; sizes shown accurately; interrupted downloads recover; offline playback verified with the network disabled; gates clean. |
| **Release impact** | Makes the offline claim honest. `RELEASE_DASHBOARD.md` currently lists offline as a strength while audio streams — this closes a claim/reality gap of exactly the kind Sprint R3b existed to remove. Also retires part of technical-debt item **D5**. |

### A3 — Real-device verification (accessibility + performance)

| Field | |
|---|---|
| **Objective** | Run a screen-reader pass (TalkBack/VoiceOver) and measure `PERFORMANCE.md`'s Android column on real mid-range hardware. |
| **Complexity** | **Low** as engineering; **unknown** as logistics until A0 reports. Fixes arising from findings are separate and unestimatable in advance. |
| **Migration risk** | **None** — measurement only. Any resulting fixes are their own change. |
| **Dependency** | **A0**, hard. |
| **Rollback** | N/A |
| **DoD** | A screen-reader pass completed on ≥1 platform with Critical/High findings recorded; `PERFORMANCE.md`'s Android column populated with a real measurement; findings triaged into fix-now / fix-later. |
| **Release impact** | **Closes two Go/No-Go boxes** — the only two engineering-owned unchecked boxes on the entire checklist. Highest checklist value of any epic here. |

### A4 — Release mechanics

| Field | |
|---|---|
| **Objective** | Cut a real versioned build onto an internal distribution track. |
| **Complexity** | **Low.** Version bump (`0.8.1+7` → something honest), `[Unreleased]` closed into a dated entry, signing verified, internal track configured. |
| **Migration risk** | **Low**, with one exception: signing/keystore work is `CLAUDE.md`'s "stop and ask" territory. |
| **Dependency** | A1, A2 complete; B3 partially (internal tracks need less than public listings) |
| **Rollback** | A version bump is not meaningfully reversible; treat it as forward-only. |
| **DoD** | `pubspec.yaml` reflects the shipped feature set; `CHANGELOG.md`'s `[Unreleased]` is closed into a dated release; a signed build installs on real hardware from the internal track; `dart format` / `flutter analyze --fatal-infos` / `flutter test --coverage` clean on the release commit. |
| **Release impact** | **Closes two Go/No-Go boxes** (version/changelog; gates clean on the release branch). |

### A5 — Auto-scroll politeness (tactical)

| Field | |
|---|---|
| **Objective** | Stop the screen dragging a reader back to the recited āyah when they have deliberately scrolled away. |
| **Complexity** | **XS.** A "user scrolled recently" timestamp and one added condition in the existing `ref.listen` block. |
| **Migration risk** | **Low**, but it touches the most-used screen in the app. |
| **Dependency** | None. **Explicitly none** — see below. |
| **Rollback** | Revert one small change. |
| **DoD** | Scrolling away during playback suppresses auto-scroll for a defined window; a "jump to playing" affordance exists; existing reading tests pass unmodified. |
| **Release impact** | Removes a genuine daily annoyance before real users meet it. |

> **Why this epic exists, and what it demonstrates.** `DR-2026-0019` §7.3
> presents this behaviour as the payoff of a five-milestone chain
> (0017 M0 → M3, 0018 S0 → S2, 0019 E3). That chain buys the
> **structural** fix — making the feedback loop impossible. The
> **behavioural** fix is a timestamp and a condition.
>
> This is not a hack that undermines the ADR. It is that ADR's sync
> policy, implemented in place rather than extracted, and when D4 lands
> it moves rather than being deleted. Separating "fix the annoyance" from
> "fix the architecture" is the clearest single illustration of why §3's
> reordering is right.

### B1 — Translation commercial licensing · **start week 0**

| Field | |
|---|---|
| **Objective** | Obtain commercial permission for the shipped translations, or identify replacements. |
| **Complexity** | Low effort, **unbounded lead time**, entirely external. |
| **Migration risk** | None now; **high later** if the answer forces a translation change after screenshots and store listings exist. |
| **Dependency** | None. Blocked by nothing. Blocks **all** revenue. |
| **Rollback** | N/A |
| **DoD** | A written answer on record for `en_sahih` (Tanzil terms are explicitly **non-commercial**) and `vi_main` (QuranEnc/Rowwad), **or** a decision to replace, recorded as a Decision Record. |
| **Release impact** | Gates every monetisation path in `QURAN_COMPANION_PRODUCT_VISION.md` §7. Also constrains store listing copy. **This is the longest-lead item in the project and nothing else depends on when it starts — so it starts now.** |

### B2 — QAC / Lexicon decision · **deadline 2026-08-24**

| Field | |
|---|---|
| **Objective** | Resolve `DR-2026-0016` — grant, or formal deferral. |
| **Complexity** | Zero engineering. |
| **Migration risk** | None |
| **Dependency** | External response |
| **Rollback** | N/A |
| **DoD** | Decision recorded on the deadline; if unfavourable, Lexicon and Flashcards formally deferred under a Decision Record. **Do not extend the date.** |
| **Release impact** | Gates **D6 only**. Per `QURAN_COMPANION_PRODUCT_VISION.md` §0, word-level *reading* does not depend on this — only morphology does. An unfavourable answer costs one attachment, not the roadmap. |

### B3 — Store & legal assets · **start week 0**

| Field | |
|---|---|
| **Objective** | Everything required for a public listing: privacy policy, icons, screenshots, Apple Privacy Manifest, Play Data Safety, enrolment, certificates. |
| **Complexity** | Medium, mostly process. |
| **Migration risk** | None |
| **Dependency** | Screenshots depend on final UI — **which is a reason to sequence them last within B3, not to delay starting B3.** |
| **Rollback** | N/A |
| **DoD** | `RELEASE_CHECKLIST.md` walked; every item either done or explicitly deferred with a reason. |
| **Release impact** | **Closes the largest remaining Critical blocker.** A closed beta needs only a fraction of this; a public beta needs all of it — which is precisely why F3's split is worth taking. |

### B4 — Tanzil translation legal review · **start week 0**

| Field | |
|---|---|
| **Objective** | Confirm the Arabic text and translation terms are compatible with the intended release model. |
| **Complexity** | Low effort, external lead time. Overlaps B1; keep separate because the Arabic text (verbatim distribution, permitted) and the translation (non-commercial) carry different terms. |
| **Migration risk** | **Binary** — an adverse finding forces a source change late. |
| **Dependency** | None |
| **Rollback** | N/A |
| **DoD** | A clear written result on record. |
| **Release impact** | Closes one Go/No-Go box. |

### C1 — Closed beta launch + feedback capture

| Field | |
|---|---|
| **Objective** | 10–50 real users on real devices, and a channel through which they can tell you things. |
| **Complexity** | **Low–Medium.** Distribution is configuration; the harder part is deciding what to measure without violating the privacy position. |
| **Migration risk** | **Low technically. High reputationally** — a first impression is spent once. |
| **Dependency** | A1, A2, A3, A4 |
| **Rollback** | Pull the build from the track. |
| **DoD** | Testers recruited and onboarded; a feedback channel exists and is being used; crash reporting decided (`NoopCrashReporter` is deliberate today — a closed beta is the moment to decide whether that stays); **no telemetry that contradicts the privacy commitment**. |
| **Release impact** | **This is the point of Phase 4.** Everything else in Track A exists to make this measurement valid. |

> **One constraint that must not be traded away.** The product's stated
> position is "nothing leaves your device," and that claim is currently
> *structurally* true. Instrumenting a beta is the first moment there is
> a reason to weaken it. The answer is qualitative feedback and
> opt-in-per-report diagnostics — never silent telemetry. Breaking this
> to make the beta easier to measure would cost the one differentiator
> competitors cannot copy.

### C2 — Feedback synthesis + architecture go/no-go

| Field | |
|---|---|
| **Objective** | Decide what Phase 5 is, with evidence rather than with the vision document's hypothesis. |
| **Complexity** | Low effort, **highest leverage in the plan**. |
| **Migration risk** | None |
| **Dependency** | C1 running ≥ 4 weeks |
| **Rollback** | N/A |
| **DoD** | A written synthesis; an explicit verdict on the retention thesis (**supported / partly / contradicted**); Track D authorised, re-scoped, or dropped; `RELEASE_DASHBOARD.md` and the vision document updated with what was learned. |
| **Release impact** | Determines Phase 5 entirely. |

### D1–D6 — Architecture (deferred; gated on C2)

Definitions are already complete in the ADRs and are not restated here.
The plan-level facts:

| Epic | Complexity | Migration risk | Rollback | Release impact |
|---|---|---|---|---|
| **D1** Foundation types | Low | **None** — zero consumers | Delete | None (enabling) |
| **D2** Decoration extraction | Medium | **Low** — golden-testable, isolated | Revert | None directly; **unblocks tafsīr, reflection markers, AI citations** |
| **D3** Basmalah declarative | Low–Medium | **Low** — behaviour-identical by design | Revert | None visible; removes three hardcoded constants |
| **D4** Audio/scroll split | **Medium–High** | **Medium–High** — touches audio and the 1,265-line reading screen; weak automated coverage | Revert (larger surface) | Removes a defect class; supersedes A5 |
| **D5** Render + frame builder | High | **Medium** | Revert (large) | None visible; **carries a mandatory performance gate** |
| **D6** Word foundation | High | **High** — schema change | Migration | Unlocks the vocabulary thesis — **only if C2 supports it** |

**Every DoD in Track D**: gates clean; golden tests where the reading
screen is touched (`DR-2026-0017` M2, `DR-2026-0019` E1/E2/E5); no
schema change before `PROJ-P-002` sign-off.

## 7. Challenging the ADRs' internal order

If Track D is authorised, I recommend **changing the order the ADRs
imply**.

**Their implied order** is dependency-driven: D1 → D2 → D3 → D4 → D5 → D6.

**By user value** it would be D4 first — it is the only architecture
epic with a visible payoff.

**I recommend D1 → D2 → D3 → D4**, i.e. keeping D2 before D4, for two
reasons that are not the dependency graph:

1. **D4's user-visible payoff is already captured by A5** at a fraction
   of the cost. Its remaining value is structural, which is real but not
   urgent.
2. **D2's payoff is optionality.** Decoration extraction is what
   unblocks tafsīr display, reflection markers, and AI citations — *any*
   of which C2 might name as the priority. Doing the cheap, low-risk,
   golden-testable epic that unblocks the most possible futures is the
   right move when you do not yet know which future you are in.

**And one trigger to pull D2 forward past everything**: if C2 names
**tafsīr** as the top request, D2 comes before all other Track D work,
because tafsīr display lands in the reading screen and D2 is what makes
that additive rather than another clause in `AyahCard.build()`.

## 8. Kill criteria and decision points

Stated in advance, so they are decisions rather than drift.

| Point | When | Criterion |
|---|---|---|
| **A0 result** | Week 0 | No device access → A3 re-planned or procurement started **before** anything is scheduled around it |
| **B2 deadline** | **2026-08-24** | Decide. Do not extend. Unfavourable → D6 drops; the rest of Track D is unaffected |
| **A1 verification** | End of A1 | Not verified on real hardware → A1 is not done, regardless of code state |
| **C1 launch gate** | Before invites | Crash-free on both platforms, or do not invite. A first impression is spent once |
| **C2 verdict** | C1 + 4 weeks | Thesis contradicted → Track D re-scoped or dropped, and the vision document amended, not quietly ignored |
| **B1 answer** | Whenever it lands | Non-commercial confirmed → monetisation is off the table until translations change; say so in the vision document rather than leaving it implied |

## 9. Open risks

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| **1** | **Device access does not exist**, and A3 silently becomes the critical path. | **High** | A0, in week 0. This is the plan's first action for exactly this reason. |
| **2** | Background audio is fiddlier across three platforms than estimated. | **High** | It is the largest single estimate here and the least covered by tests. If it overruns, ship the closed beta **without** iOS rather than delaying the whole beta. |
| **3** | Beta feedback is thin — 10–50 users may say little. | Medium | Recruit deliberately (people who will actually talk), not broadly. Qualitative depth beats sample size at this stage. |
| **4** | **Instrumentation pressure erodes the privacy position.** | **High** | C1's constraint is non-negotiable. Weakening it costs the one differentiator competitors structurally cannot copy. |
| **5** | Track D never happens because Phase 5 brings new features. | Medium | Accept it honestly: the ADRs are proposed, not accepted, and remain valid designs on the shelf. Unbuilt architecture that was correctly deferred is not waste. |
| **6** | Three ADRs of unbuilt vocabulary decay into confusion. | Medium | They are `status: proposed`. If C2 drops Track D, mark them **deferred** with a date rather than leaving them ambiguous. |
| **7** | I am recommending against my own three records, which is either good judgement or inconsistency. | — | Stated plainly so it can be judged: the records are correct designs; this is a claim about **timing**, not about their content. If the reasoning in §2–§4 is wrong, the original order stands. |

## 10. Recommendation

**Adopt Plan B.**

1. **Week 0**: start B1, B2, B3, B4 (zero engineering, longest lead) and
   run A0.
2. **Weeks 1–6**: A1 → A2 → A3 → A4, with A5 slotted anywhere.
3. **Weeks 5–7**: C1 — closed beta.
4. **Week ~10**: C2 — synthesis and the Track D go/no-go.
5. **Track D only after C2**, in the order D1 → D2 → D3 → D4, with D2
   pulled first if tafsīr is the verdict, and D6 only if B2 was
   favourable.

**What this buys**: first real user contact 8–14 weeks earlier, the two
engineering-owned Go/No-Go boxes closed, the longest-lead external items
off the critical path, and the architecture program committed *after*
there is evidence about what it should serve.

**What it costs**: the architecture is 6–8 weeks later. Verified in §4,
that costs approximately nothing, because the beta program barely
touches the reading screen.

**The single most important line in this plan**: the nineteen
architecture milestones are correct designs for a product thesis nobody
has tested. Test the thesis first. It is cheap, it is fast, and it is
the only thing that makes the next three months' work either
well-aimed or wasted.

---

PHASE 4 MASTER PLAN — planning only. No production code, no commits.
