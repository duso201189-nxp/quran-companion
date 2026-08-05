# Study Architecture Constitution
## Qur'an Companion — Study Module

*Reference document. Establishes the permanent philosophical and architectural direction for the Study module. Binding on all future Study-related work until formally revised.*

---

### 1. Purpose of the Study Module

The Study module exists to protect and deepen what the user has already read. It is retention infrastructure for Reading — not a parallel content feature, not a gamified trivia layer, and not an independent destination that competes with Reading for the user's first attention.

Study has no legitimate reason to activate before a first reading has occurred, and no legitimate reason to test, quiz, or schedule content the user has not engaged with. Its scope is bounded by the user's own reading history at all times.

This document scopes the Study module as it exists today: a solitary practice between the user and the text. It neither includes nor forecloses collaborative, teacher-guided, or accountability-partner features. Their absence here is a deliberate boundary on current scope, not an architectural judgment against them — a future extension into shared or mentored learning would be a scope change requiring its own review, not a violation of this constitution.

---

### 2. Core Learning Philosophy

Qur'an learning is a continuous, cyclical practice, not a linear curriculum with an end state. The traditional progression — Tilawah (recitation) → Tadabbur (reflection) → Hifz (memorization, for those who pursue it) → Murajaah (continuous revision) — is never "completed." The well-known caution that memorized Qur'an "escapes faster than a tied camel" without constant revision applies to the whole of engagement with the text, not only formal memorization: retention, not acquisition, is the permanent and harder work.

A second governing principle follows directly: consistency over volume. The practice sustained daily in small measure outweighs the practice pursued intensely and abandoned. This module is built to protect a sustainable daily rhythm, not to maximize sessions, streaks-for-their-own-sake, or scored performance.

---

### 3. Learning Principles

1. **Reading precedes everything.** No Study capability is meaningful before at least one reading session has occurred.
2. **Nothing is tested that hasn't been engaged with.** Assessment content is always scoped to what the user has actually read or revised — never general trivia.
3. **Revision is the core loop; assessment is peripheral.** The daily habit this module protects is Murajaah, not scoring.
4. **Small and sustainable beats large and abandoned.** Daily and weekly loops are bounded by design, not exhaustive.
5. **Understanding is received; reflection is authored.** The two must not be conflated — one is intake from vetted sources, the other is the user's own internal engagement.
6. **AI arranges; it does not author meaning.** AI may sequence and schedule. It may never generate, paraphrase, or adjudicate religious content.
7. **Completion is a checkpoint, not an exit.** Finishing a Surah, a Juz, or a full Khatm intensifies revision — it never simply resets a counter and moves on.

---

### 4. Complete Learning Flow

Sections 5–11 below describe architectural **roles** the module fulfills, not a mandatory linear sequence a user must pass through in order. A given reading session may touch several of these roles at once or in any order; the numbering is for reference, not for pipeline position.

```
Reading (Tilawah)                the only entry point; includes both visual
                                  reading and listening; Understanding is
                                  inherent to it, not a separate gate
        │
        ▼
Reflection (Tadabbur)            optional, personal, immediately adjacent
        │                        to a reading session; AI silent
        ▼
Retention Seeding                mechanical bridge: what was read becomes
                                  eligible for revision — default behavior,
                                  not a favor the user must remember to ask for
        │
        ▼
Revision (Murajaah)  ─────────►  RETENTION (the goal this entire flow serves)
        │                        Revision is the method; Retention is the
        │                        outcome — they are not the same stage.
        │                        Boundary-aware: Surah/Juz/Khatm completion
        │                        triggers a consolidated revision moment.
        ▼
Memorization (Hifz)              opt-in commitment of specific passages,
                                  from first encounter through long-term
                                  intensified revision
        │
        ▼
Assessment                       optional, occasional, self-initiated
                                  confidence check — never a gate, never
                                  the default first action

════════════════════════════════════════════════════════════════
Sequencing (cross-cutting)
Arranges what surfaces from Revision/Memorization/Assessment.
May be AI-driven or deterministic — the constraints below bind the
capability, not a particular implementation of it.
Never appears before Reading has happened at least once.
Never generates or interprets religious content.
════════════════════════════════════════════════════════════════
```

This flow is a cycle, not a funnel. There is no terminal stage — Revision continues indefinitely, re-anchored at each Surah, Juz, and Khatm boundary.

---

### 5. Role of Reading

Reading (Tilawah) is the sole entry point to the entire module, and is fulfilled equally by visual reading of the text and by listening to recitation — both are legitimate, complete forms of Tilawah, and neither is a lesser substitute for the other. Understanding (translation, transliteration, meaning-in-context) is an inherent quality of Reading, not a downstream stage: a user reading with translation visible, or listening with meaning explained, is already engaged in Understanding as part of Tilawah. Nothing in Study may be positioned as preceding or substituting for Reading.

---

### 6. Role of Reflection

Reflection (Tadabbur) is the user's own, unprompted internal engagement with meaning already received during Reading. It is optional, low-friction, and occurs immediately adjacent to a reading session or a completion checkpoint (end of Surah, end of Juz). Reflection is authored by the user alone. Its value depends on that authorship being genuine — a system-generated or AI-suggested "reflection" is not reflection; it is content, and does not belong here.

---

### 7. Role of Understanding

Understanding is the comprehension of what a passage means — vocabulary, context, translation, scholarly commentary. It is received, not authored, and it comes only from vetted, attributed sources. Understanding is not a discrete sequential stage the user passes through once; it is a persistent, always-available dimension of Reading and Revision alike — a user may deepen Understanding of the same passage repeatedly, at any point in the cycle. It is listed separately here for clarity of ownership, not because it is a gate between Reading and Reflection.

---

### 8. Role of Retention

Retention is the objective of the entire Study module, not an activity within it. It is the durable, long-term recall of what has been read, revised, or memorized. Every other role in this document — Revision, Memorization, Assessment, Sequencing — exists to serve Retention. Retention is measured over time (recall weeks or months after first engagement), not measured by session count, streak length, or quiz score.

This is stated as the architectural objective regardless of current measurement capability. No retention-measurement instrument exists in the product today. That absence does not weaken the objective — it identifies the standard future work must build toward, not a capability already assumed available. Any future metric proposed for this module's success must be a retention metric, not an engagement metric, even before a retention instrument exists to measure it precisely.

---

### 9. Role of Revision (Murajaah)

Revision is the mechanism that produces Retention: the recurring, spaced practice of returning to previously-read content before it is forgotten. It is the daily habit core of the module — the single loop a returning user is expected to engage with most often. Revision content is drawn exclusively from what the user has read or previously revised; it is never populated from unread material.

Revision owns the *rules* of when consolidation is warranted: it is boundary-aware, and defines that finishing a Surah invites a whole-Surah consolidation pass, finishing a Juz opens a larger planned revision cycle, and finishing a Khatm shifts the module's overall emphasis toward revising everything gained so far. Sequencing (§12) owns the *mechanism* that carries these rules out day to day — ranking and timing what surfaces within the boundaries Revision defines. Where a boundary-triggered consolidation and routine day-to-day ranking would otherwise compete for the same moment, the boundary-triggered consolidation defined by Revision takes precedence.

---

### 10. Role of Memorization (Hifz)

Memorization is a deliberate, opt-in commitment applied to specific passages the user chooses to internalize — encompassing both the first-time work of committing new material to memory and the long-term, intensified revision that keeps memorized material retained. It is not the default behavior of Revision, and Revision must not silently escalate into memorization-level intensity without the user's explicit choice. Hifz and casual Murajaah are related but distinct commitments; the module must be able to represent both without conflating them into a single undifferentiated "review everything the same way" mechanism.

---

### 11. Role of Assessment

Assessment is an optional, occasional, user-initiated confidence check — never a gate, never a scheduled requirement, and never the first or default action offered by the module. Assessment content is always scoped to material the user has already read or revised. An assessment drawn from unread content is a violation of this constitution regardless of its technical correctness, because it tests a stranger to the text rather than a student of it.

---

### 12. Role of Sequencing and AI

Sequencing is the cross-cutting capability that determines what surfaces from Revision, Memorization, and Assessment, and when. Sequencing may be implemented deterministically (a fixed scheduling algorithm) or with AI assistance — the constraints in this section bind the *capability*, not one particular implementation of it. A deterministic scheduler satisfies these constraints trivially, since it generates no content in the first place; an AI-assisted implementation must satisfy them by design.

**Sequencing may:**
- Rank and schedule what to revise next, based on the user's own recorded engagement (due dates, accuracy trends, streaks).
- Surface patterns already present in the user's own *structured, behavioral* data.
- Decide *when* something should be offered.

**Sequencing must never:**
- Generate, paraphrase, summarize, or interpret Qur'anic meaning, tafsir, or religious guidance.
- Author or suggest the content of a user's reflection.
- Adjudicate whether a user's understanding or interpretation is correct.
- Substitute generated text for attributed, scholarly-sourced translation or commentary.
- Present itself, in name or behavior, as a source of religious knowledge rather than a scheduling aid.
- **Use Reflection or personal Notes content as input — for profiling, summarization, pattern extraction, or recommendations, under any framing.** This content is reserved to the user alone (§6). "The user's own data" in this section refers to structured, behavioral signals (due dates, accuracy, streaks, completion), never to free-text personal or reflective writing.

Authentic Islamic knowledge — translation, tafsir, scholarly commentary — comes only from vetted, attributed sources presented as such. This boundary is absolute: Sequencing arranges access to that knowledge; it never becomes a source of it.

---

### 13. Relationship With Existing Capabilities

This list is intended to be complete as of this document's writing — every current integration point the Study module touches is named here.

- **Reading** — the foundation. Every other capability in this document is downstream of it.
- **Khatm** — the long-arc progress marker for Reading. Its completion is a Retention checkpoint (§9), not merely a counter reset; the next cycle begins alongside, not instead of, intensified revision of what came before.
- **Daily Goal** — stage-agnostic budgeting infrastructure. It should represent the user's full engagement (reading and revision together), not reading time alone.
- **Revision Queue** — the seed mechanism for Murajaah. Its role under this constitution is to become the default, automatic bridge from Reading into Revision, not a manual, easily-forgotten action.
- **Flashcards** — a vocabulary-support layer beneath Understanding, not a peer of Revision. Its content must be scoped to what supports comprehension of engaged material.
- **Quiz** — occupies the Assessment role only. It must never be the default outcome of any "start learning" action, and must never draw from unread content.
- **Notes** — the existing primitive closest to Reflection. Under this constitution it is understood as Reflection infrastructure, not general-purpose free text incidental to reading, and is reserved from AI input per §12.
- **AI Tutor, Learning Journey, Smart Learning** — these currently present the same underlying suggestion data through different surfaces. Under this constitution they are recognized as one logical capability — Sequencing (§12) — regardless of how many presentations of it exist today. Future work must treat them as one capability with one set of rules, not three independently-evolving features.
- **Progress Dashboard, Study Summary** — reporting lenses over Revision/Memorization/Assessment/Retention history. Both are views, not stages, and carry no independent role beyond presenting Retention-relevant data back to the user.

---

### 14. Long-Term Vision

A mature Study module works quietly. It does not compete with Reading for the user's attention; it follows Reading and protects it. On any given day, it asks little: a short, bounded revision of what is due, nothing more, unless the user deliberately chooses more. It never opens with a test. It never asks the user to prove themselves before it will help them.

Its success is measured in what the user still remembers months later, not in how many sessions they opened this week. Memorization remains available to those who choose it, at whatever depth they choose, without being forced on casual readers. Assessment remains available as a tool the user reaches for, never a wall placed in front of them. Completion of a Surah, a Juz, or a Khatm is met with the module asking the user to revisit and consolidate — not with a badge and a fresh counter.

Sequencing's presence in this vision is felt only as quiet convenience — the right thing surfaced at the right time — and is never mistaken, by design, for a source of religious knowledge, regardless of whether it is built deterministically or with AI assistance.

---

### 15. Architecture Principles

- **Foundation First** — No Study capability may present itself as the user's recommended first action before at least one reading session has occurred. Assessment specifically must never operate on unread content, under any circumstance.
- **Knowledge First** — No future Study sprint may assume a screen's purpose or behavior without verifying it directly from source. This constitution itself was produced under that discipline and expects the same of everything built against it.
- **Verification First** — Claims about what the module does must be checked against actual behavior, not inferred from naming or UI framing. Where something cannot be verified, that uncertainty must be stated, not silently assumed away.
- **Minimal Sufficient Change** — Future work should reuse existing engines (spaced repetition, analytics, rule-based sequencing) repositioned to match this philosophy, rather than introducing new systems. The correction this module most needs is placement and scope, not new machinery.
- **Long-Term Retention** — Every future decision affecting this module must be evaluated against durable recall, not session count, engagement metrics, or feature volume, even in the absence of a retention-measurement instrument today. Where a proposal increases engagement but does not serve retention, this constitution does not support it.
- **Worship First** — Every Study capability must ultimately support sincere worship (ibadah), not maximize engagement, gamification, rankings, or feature usage. Where a proposal would increase usage, streaks, or competitive framing without serving sincere engagement with the Qur'an, this constitution does not support it — engagement is a possible side effect of good design, never its goal.

---

*This document freezes the learning philosophy of the Study module. It does not authorize, schedule, or specify any implementation. Any future sprint touching Study must be consistent with the roles, relationships, and principles defined here, or must explicitly propose a revision to this constitution before proceeding.*
