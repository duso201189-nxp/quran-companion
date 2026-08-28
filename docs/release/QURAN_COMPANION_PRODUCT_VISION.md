# Qur'an Companion — Product Vision & Competitive Strategy

Phase 4 strategy document. Written after Phase 3 closed (HEAD `50c6c16`).
No code was written, no release document edited, nothing committed.

**Epistemic note, stated up front.** Two classes of claim appear below and
they deserve different levels of trust:

- **Facts about this repository** — measured directly today (content
  database queried, licences read from `translation_sources`, schema
  inspected). Trust these. ⚠ **[Scope corrected 2026-08-28, Session
  157A — see the correction block below.]** "Trust these" covers what
  was *measured*: that a `translation_sources.license` string exists,
  and what it says. It does **not** extend to reading that string as
  authoritative **upstream** licensing evidence. For the
  transliteration row the string is project-authored metadata written
  by this repository's own pipeline, not a grant by any rights holder.
- **Claims about competitor apps** — from my knowledge as of early 2026,
  not freshly researched. The *structural* conclusions (what categories
  of value are unserved) are durable; the *feature-level* specifics
  ("app X does Y") should be verified before anyone acts on them
  commercially. I have marked the load-bearing ones.

> ### ⚠ Correction 2026-08-28 (Session 157A) — transliteration source and licensing claims
>
> This block corrects four claims made below about the shipped Latin
> transliteration dataset. It is a **documentation correction only**.
>
> **What this correction does NOT conclude.** It does **not** establish
> that permission exists. It does **not** establish that permission is
> denied. It does **not** establish that redistribution is permitted, and
> does **not** establish that redistribution is prohibited. It does
> **not** declare the dataset legally cleared, and it does **not**
> conclude that any violation has occurred. It makes no legal
> determination of any kind, resolves no open item, and closes nothing.
>
> **1. Source identity — corrected.** The shipped transliteration is
> **not** obtained through QUL (Tarteel AI). It is fetched through
> **Quran.com's QDC endpoint**, `api.qurancdn.com`:
>
> - `tool/fetch_transliteration.py:30`–`:34` calls
>   `https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` with
>   `?words=true&word_fields=transliteration,text_uthmani`. This is the
>   dataset's only fetch path.
> - The shipped database (`assets/database/quran.sqlite`, table
>   `translation_sources`, row `code = 'translit_latin'`) records
>   `name = 'Phiên âm Latin (Quran.com)'`, `author = 'Quran.com
>   word-by-word transliteration'`, `source_url = 'https://quran.com'`,
>   `version` = `updated_at` = `'2026-07-06'`.
>
> **QDC and QUL are distinct and must not be conflated.** QUL's FAQ is
> **not** the governing terms document for this dataset; it continues to
> govern datasets actually obtained through QUL. This brings the document
> into agreement with the Session 147 correction in `docs/LICENSING.md`
> §1 and with U3 / Q3 of
> `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md`. Neither of those files,
> nor `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md`, nor
> `privacy/index.md`, is modified by this session.
>
> **2. "Data already licensed and in hand" — RETRACTED.** Finding 1's
> transliteration row previously asserted *"Unblocked. Data already
> licensed and in hand; only the pipeline discards the structure."* The
> repository establishes no such licence. That clause is **withdrawn** as
> an unsupported licensing conclusion. What the repository does support
> is only mechanical: the data was fetched word-by-word and is stored
> flattened per ayah.
>
> **3. The database `license` field is not upstream licensing evidence.**
> The epistemic note above previously invited the reader to trust
> "licences read from `translation_sources`" as measured repository fact.
> The *existence and contents* of that field are indeed measurable; what
> it cannot be read as is an upstream grant. For the transliteration row
> the stored value is *"Quran.com/QUL community data — ghi nguồn khi
> phân phối"* (read from `assets/database/quran.sqlite`, and quoted
> identically in `docs/LICENSING.md` §1). That value is
> **project-authored**: it is a hard-coded literal in this repository's
> own fetch script (`tool/fetch_transliteration.py:206`–`:207`), copied
> into `tool/data/transliteration.json` and from there into the shipped
> database. It is not a statement by Quran.com or by any other rights
> holder, and it is not authority for anything. Note that §0's Finding 2
> block below renders this value in English — see the scope marker there.
>
> **4. "Need no new licence" — corrected.** The §5 roadmap claim that
> five of six word-level capabilities "need no new licence" is not
> supported for the transliteration capability. Which licence or
> permission actually governs the QDC transliteration — and which terms
> were in force at the `2026-07-06` fetch date recorded in the shipped
> metadata — remains **CHƯA XÁC ĐỊNH / UNKNOWN — COUNSEL REQUIRED**.
>
> **What is unaffected.** Finding 1's *QAC/morphology* analysis stands:
> the QDC transliteration is genuinely not governed by the QAC lexicon
> licence, which is the question that column asks. This correction does
> not touch the independently supported positions on the Tanzil Arabic
> text, the Tanzil / Saheeh International English translation, QuranEnc,
> EveryAyah, or the KFGQPC font, and it does not weaken or reinterpret
> any existing legal constraint — `PROJ-P-005` included. **P0-2, P1-4
> and P2-2 all remain OPEN**; no status label in this document is
> changed.
>
> **Historical wording is preserved, not erased.** The superseded
> sentences are quoted — in this block and at their original locations —
> and marked as historical. They are retained solely as an audit trail
> and are **not** current statements of fact.

---

## 0. Two findings that change the plan before it starts

Both were discovered by querying the shipped database today, and both
were missed by every prior planning document. They come first because
they invalidate assumptions the roadmap currently rests on.

### Finding 1 — Word-level reading is **not** blocked by the Lexicon licence

Every planning document treats "Lexicon" as one blocker with one
deadline (QAC permission, 2026-08-24). It is actually **two separable
things**, and only one is blocked:

| Capability | Needs QAC/morphology licence? | Status |
|---|---|---|
| Word **segmentation** (token boundaries, positions) | **No** — derivable from the Uthmani text already shipped | Unblocked. `basmalah.dart` already does exactly this, splitting on spaces. |
| Word **transliteration** | **No** — already sourced word-by-word from **Quran.com QDC** (`api.qurancdn.com`), then *flattened to per-ayah* in the pipeline | **Pipeline**-unblocked: the word-level structure exists upstream and only the pipeline discards it. **Licensing is a separate and open question — UNKNOWN / COUNSEL REQUIRED.** ⚠ **[Corrected 2026-08-28, Session 157A]** this row previously read "already sourced word-by-word from Quran.com/QUL" and "Unblocked. Data already licensed and in hand" (quoted as historical wording, not current fact): the source is QDC, not QUL, and the licence claim is **retracted**. See the correction block above. |
| Word **audio timing** (segment timings per reciter) | **No** — separate published datasets, separate terms | Unblocked, pending sourcing. |
| Word-by-word **translation** | **No** — separate datasets under their own terms | Unblocked, pending sourcing. |
| Word **morphology** (root, lemma, grammar) | **Yes** | Blocked on 2026-08-24. |

**Consequence**: four of the five word-level capabilities can proceed
regardless of the QAC answer. The reading-experience roadmap — including
tap-a-word, word-level audio highlight, tajweed, and Basmalah as a real
element — is **not** hostage to that deadline. Only the *linguistic
annotation* layer is. No document currently says this, and the roadmap
is sequenced as though everything word-level waits for one letter from
one corpus maintainer.

### Finding 2 — Monetization is legally blocked today, and the reason is specific

`CLAUDE.md` flags monetization as a "stop and ask" licensing blocker
(`PROJ-P-005`) without saying why. The database says why:

```
en_sahih  → "Tanzil Terms of Use — phi thương mại (non-commercial), attribution + link"
vi_main   → "QuranEnc — use with attribution, see quranenc.com"
translit  → "Quran.com/QUL community data — attribution on distribution"
arabic    → "Tanzil Terms — distribute verbatim, attribution + link"
```

> ⚠ **Scope of the block above (marked 2026-08-28, Session 157A — the
> block itself is left exactly as written).** Two things about it.
>
> **It is this document's own English rendering of the database's
> `translation_sources.license` column, not a verbatim transcript of it.**
> The stored `translit_latin` value is *"Quran.com/QUL community data —
> ghi nguồn khi phân phối"*, as quoted in `docs/LICENSING.md` §1. The
> block is preserved unedited as the historical wording; it should not be
> cited as the literal column contents.
>
> **Whatever the column says, it is not an upstream licence grant.** The
> `translit` line in particular is **not** evidence of a grant by
> Quran.com: that value is project-authored, hard-coded in this
> repository's own `tool/fetch_transliteration.py:206`–`:207`. Its
> "Quran.com/QUL" wording is additionally **stale as to source** — the
> dataset comes through Quran.com QDC (`api.qurancdn.com`), not QUL. The
> licence or permission governing that dataset remains **UNKNOWN —
> COUNSEL REQUIRED**; see the correction block at the top of this
> document. The `en_sahih` non-commercial reading below is unaffected by
> this marker and rests on the Tanzil terms, quoted independently in
> `docs/LICENSING.md`.

The English translation ships under an explicitly **non-commercial**
licence. Any paid tier — subscription, one-time purchase, institutional
licence — distributed alongside Saheeh International would breach it.

**Consequence**: monetization is not a "decide later" item. It is gated
on a concrete prerequisite (§7) that has lead time measured in months
and must start now if revenue is ever intended. This is the highest-
urgency unflagged item in the entire plan.

---

## 1. Benchmark — by user value, not popularity

Competitors grouped by *what job they do*, because comparing a reference
tool to a memorization tool on a single axis produces nonsense.

| Class | Exemplars | The job it does |
|---|---|---|
| **Reference** | Quran.com, Ayat (KSU), Zad | Give me the text, translations, tafsir, accurately |
| **Devotional bundle** | Muslim Pro, Athan | Run my whole religious day (prayer, qibla, Qur'an, duas) |
| **Memorization** | Tarteel AI | Help me memorize and check my recitation |
| **Reading craft** | Quran Android (OSS), Ayah | Give me the mushaf, beautifully, offline |
| **Habit** | Quranly | Get me reading consistently |
| **Study system** | *(effectively vacant)* | Make what I read stay with me |

Qur'an Companion is currently a *reading craft* app with an unbuilt
*study system* attached. The vacancy in that last row is the whole
strategic opportunity.

### Area-by-area

| Area | Who leads, and why | Qur'an Companion | Verdict |
|---|---|---|---|
| **Reading** | Quran Android / Quran Majeed — true page- and line-faithful Madani mushaf. Memorizers navigate by visual position; a reflowed page actively harms hifz. | 3 modes (List/Mushaf/Focus), live pinch-scale, per-surah position restore. Mushaf mode groups *by* page but reflows text — not line-faithful. Focus mode is genuinely rare and good. | **Competitive on flexibility, behind on fidelity** |
| **Audio** | Quran.com app / Quran Android — background playback, lock-screen controls, ayah highlight, range repeat. | 5 reciters, ayah-level highlight + auto-scroll, 0.75–2.0× speed, repeat modes. **No background playback. No lock-screen controls. Cache engine exists but is unwired.** | **Materially behind — see below** |
| **Tafsir** | Quran.com, Ayat, Quran Majeed — multiple classical works, ayah-linked. | **None.** | **Absent** |
| **Translation** | Quran.com — 100+ languages. | 2 translations + 1 transliteration. | **Behind on breadth; uniquely strong on Vietnamese** |
| **Search** | Quran.com — topical/semantic search across text and tafsir. | FTS5, 43,652 indexed rows, **diacritic-folded Latin search** (type without Vietnamese tone marks and still match). Technically strong. | **Competitive; genuinely better for non-Arabic searchers** |
| **Memorization** | Tarteel — real-time speech recognition detects recitation mistakes. A hard technical moat built on ML and proprietary data. | SRS scheduler exists but **no hifz mode**: no progressive reveal, no verse hiding, no recitation checking, no page-position aid. | **Behind — has the engine, not the application** |
| **Learning** | *Nobody.* Quranly does habit streaks; Bayyinah sells courses; Quran.com does not attempt it. | SM-2 spaced repetition over Qur'anic items, 4 auto-generated quiz types, unified learning session, 5-layer recommendation chain over local data. | **Leads, uncontested** |
| **Personalization** | Weak field. Most "personalization" is engagement nudging. | Analytics → AI Tutor → Learning Journey → Smart Learning → Read Model, all rule-based over the user's own local data. | **Leads — but value is latent until data density exists** |
| **Offline** | Quran Android — full offline including audio. | Content fully bundled and local; no network needed to read. **But audio streams and the cache manager has no UI, so offline *audio* is not deliverable.** | **Strong on text, the audio claim is currently false** |
| **Accessibility** | Weak field generally. | Unusual investment: semantics headers, live regions, ≥48dp targets, RTL, 200% text scale, a dedicated a11y test suite. **Never verified on a real screen reader.** | **Designed to lead; unproven** |
| **Cross-platform** | Quran.com (excellent web). | Android + iOS + Web, all verified building; Web verified running in a browser. **No hosting target chosen, so Web reaches nobody.** | **Built but undelivered** |

### The one benchmark result that should change this week's priorities

**Background audio is not a feature gap. It is a usage-pattern
disqualifier.** A large share of Qur'an listening happens while
commuting, working, cooking, or with the screen off. An app that stops
playing when it backgrounds cannot participate in that behaviour at all.
Every competitor in every class has this. It is currently sitting in
`RELEASE_DASHBOARD.md` §3 at **Medium** priority, below several items
that affect nobody's daily use.

This is the highest user-value-per-engineering-hour item on the entire
board, and it is mispriced.

---

## 2. Position — strengths, gaps, and open ground

### What Qur'an Companion already does exceptionally well

Assessed honestly; flattery here would be useless.

1. **The learning engine is real, integrated, and unmatched.** A working
   SM-2 scheduler, generated quizzes, session unification, and a
   recommendation chain — all wired together over a user's own data. No
   competitor in any class has this. It is also the hardest thing on
   this list to copy, because it is a *system*, not a feature: a
   competitor must build scheduler + content model + analytics + UI and
   integrate all four before shipping anything a user notices.

2. **Verifiable text provenance.** The data pipeline records source,
   licence, version, and SHA-256 for every input; the repository
   boundary gate enforces it in CI; `DATA_OS_ARCHITECTURE.md` designs a
   licence registry with three-valued grants. **Almost no Qur'an app can
   prove where its text came from.** Mis-transmitted Qur'anic text is a
   real and serious failure mode in this category. The ability to say
   "here is the exact source, licence, and checksum of every glyph we
   ship" is a trust claim nearly nobody else can make — and it is
   currently invisible to users.

3. **Local-first with a sync-ready data model.** Separate content and
   user databases; client-generated UUIDs; soft deletes; dirty flags.
   Privacy today *without* foreclosing sync tomorrow. Most apps chose
   one or the other.

4. **Honest surface.** After Sprint R3b, no control in the app promises
   something it cannot do. This sounds like hygiene; it is actually a
   quality signal users detect immediately and cannot articulate.

5. **Engineering discipline that makes iteration safe.** 792 tests,
   81.5% coverage on hand-written code, `--fatal-infos`, licence/size
   CI gates, a reliability layer with a single repository-boundary error
   choke point. This does not sell the app. It determines how fast the
   app can change without breaking, which over three years matters more
   than any single feature.

### What competitors still do better

1. **Tafsir** — absent here, standard elsewhere. For a *study* product
   this is the most conspicuous content hole.
2. **Background/lock-screen audio** — see above. Disqualifying.
3. **Recitation verification (ASR)** — Tarteel's moat. Expensive to
   contest; possibly correct never to contest directly.
4. **Mushaf page fidelity** — matters enormously to memorizers.
5. **Translation breadth** — 2 vs 100+.
6. **Tajweed colouring** — common elsewhere, absent here, genuinely
   useful for correct recitation.
7. **Multiple qira'āt / riwāyāt** — Hafs only.
8. **Reciter breadth** — 5 vs dozens.
9. **Word-by-word display** — Quran.com's is excellent; ours is blocked
   by pipeline work (Finding 1). ⚠ **[Corrected 2026-08-28, Session
   157A]** This item previously read *"ours is blocked only by pipeline
   work (Finding 1), not by licensing"* — quoted as historical wording,
   not as a current statement. Pipeline work is what blocks *rendering*
   word-by-word; the licence or permission governing the Quran.com QDC
   transliteration is a separate question and remains **UNKNOWN —
   COUNSEL REQUIRED**.

Deliberately **not** listed as gaps: prayer times, qibla, duas, halal
restaurant finders, hijri calendars. Muslim Pro owns that bundle and
competing there means becoming a worse Muslim Pro. Focus is a feature.

### Open ground — what nobody is doing well

This is where the strategy lives.

1. **Retention of understanding.** Every app helps you *read*. Almost
   none help you *remember what you read* six months later. The gap
   between "I finished Al-Kahf" and "I can recall its themes, its key
   vocabulary, and what I noticed in it" is completely unserved.

2. **Vocabulary-first comprehension.** A well-established pedagogical
   fact is under-exploited in software: a few hundred of the most
   frequent Qur'anic words account for the large majority of all tokens.
   A curriculum built on that — *learn these words, and most of what you
   recite becomes intelligible* — is a credible path from "I can decode
   the letters" to "I understand what I'm saying." Qur'an Companion has
   the SRS engine and the flashcard surface for exactly this and is one
   dataset away from it.

3. **Reflection that resurfaces.** Notes exist in many apps. None bring
   your own reflection back to you at the moment it would land. "Three
   months ago, you wrote this about 2:255" is a product nobody ships.

4. **The re-encounter loop.** Study a word → later meet it while
   reading → recognize it. Closing that loop makes *reading itself*
   become reinforcement, and makes comprehension growth visible. Not
   shipped anywhere, as far as I know.

5. **Underserved language communities.** The app defaults to Vietnamese.
   That reads as an accident of authorship; it could be a strategy.
   Indonesian and Malay markets are well served. Vietnamese, Khmer, Lao,
   Burmese, Thai, and other Southeast Asian minority-Muslim languages
   are served poorly or not at all. Being *the* Qur'an study app for
   communities the majors ignore is a defensible beachhead that a
   global-English strategy cannot offer a solo maintainer.

6. **Reverence as a design position.** The category has quietly imported
   engagement mechanics from consumer software: streaks with loss
   aversion, leaderboards, push notifications engineered for return
   visits. Applied to worship this is uncomfortable at best. An app that
   deliberately refuses those mechanics — consistency support without
   gamified ibadah — is differentiated in a way competitors *cannot copy
   without damaging their own metrics*. (Note: this project already ships
   streaks, daily goals, and achievements. §4 proposes where the line
   should sit.)

7. **Teacher and halaqah tooling.** Hifz schools, madrasas, and study
   circles run on spreadsheets and WhatsApp. The learning engine is
   already 80% of what a teacher dashboard needs.

---

## 3. Unique Value Proposition

### The statement

> **Most Qur'an apps help you read the Qur'an.
> Qur'an Companion helps you keep it.**

Expanded:

> Qur'an Companion is built as a **study system**, not a reading surface.
> Every session feeds a spaced-repetition engine that brings back the
> vocabulary, the meanings, and your own reflections exactly when you are
> about to forget them — so a year of reading compounds into
> understanding instead of evaporating. It runs entirely on your device,
> asks for no account, shows no ads, and can prove the provenance of
> every word it displays.

### Why someone chooses it

- **The person who reads daily and retains nothing.** The most common
  and least-served user in the category. Every other app leaves them
  exactly where they started.
- **The adult learner who can decode Arabic but not understand it.**
  Served today by either scholarly Arabic-first tools (too advanced) or
  transliteration crutches (no progression). The vocabulary curriculum
  is the bridge.
- **The person who does not want to be a product.** After a major
  incumbent was found selling user location data, "no account, no ads,
  nothing leaves your device" is a claim with real demand — and here it
  is *structurally* true rather than promised, because the architecture
  has nowhere to send data.
- **The Vietnamese-speaking Muslim** who currently has no serious
  option. Then Khmer, Lao, Burmese, Thai.

### The three durable pillars

Each is defended by something other than a feature, which is what makes
it durable:

| Pillar | Defended by | Why a competitor can't just copy it |
|---|---|---|
| **Retention by design** — the study system | System complexity + accumulating user data | Requires scheduler, content model, analytics, and UI integrated before *any* of it is visible. Partial copies deliver nothing. |
| **Verifiable text** — provenance and licence discipline | A build pipeline, licence registry, and CI gates that already exist | Retrofitting provenance onto an existing content pipeline means re-sourcing everything. Most can't, and none have reason to until it's a market expectation. |
| **Reverent, private, unmonetized worship** | A business-model commitment | An ad-funded or data-funded incumbent cannot adopt this without dismantling its revenue. This is the strongest moat of the three. |

### What is deliberately *not* the UVP

Explicitly rejected as differentiation, because none survives contact
with a competitor's next release: beautiful UI (copyable in a quarter),
AI (everyone will claim it; ours is rule-based and honest about it),
offline (table stakes), number of reciters/translations (a purchasing
decision), free (many are).

---

## 4. The long-term reading experience

Design only. Nothing here is a build instruction.

### The architectural key: make the word addressable

Today the **Ayah is the sole addressable unit** across the entire app —
the audio playlist is one URI per ayah, highlight sync is
`currentIndex == ayahNumber - 1`, and the position store holds one
integer per surah. The Basmalah readiness assessment in
`PHASE3_SPRINT_R3B_DESIGN_REVIEW.md` §6 found this constraint blocks
four separate capabilities. It blocks more than that.

Making the **word (token)** addressable is *one* change that unlocks
*six* product capabilities:

1. Word-by-word translation and transliteration display
2. Tajweed colouring (per-word/per-letter rules)
3. Word-level audio highlight during recitation
4. Basmalah as a first-class element rather than a render-time string cut
5. **Tap a word → meaning → add to study list** (the study/read loop)
6. Precise memorization loops (repeat *this phrase*, not this ayah)

Per Finding 1, five of those six are unblocked by the **QAC/morphology**
licence specifically. ⚠ **[Corrected 2026-08-28, Session 157A]** This
sentence previously read *"Per Finding 1, five of those six need no new
licence"* — quoted as historical wording, not as a current statement.
That was too broad. Finding 1 supports only the narrower point that
these capabilities do not depend on the QAC lexicon licence; it does
**not** establish that no other licence or permission is required. For
capability 1 in particular, the licence or permission governing the
Quran.com QDC transliteration remains **CHƯA XÁC ĐỊNH / UNKNOWN —
COUNSEL REQUIRED**, and the transliteration licensing question is open
pending legal / counsel review — see the correction block at the top of
this document. This is infrastructure that *directly unlocks product
value* — the exact exception the strategy brief allows.

**The conceptual model** (four ideas, no implementation):

- **Token** — `(surah, ayah, position)` with its surface form. Derived
  deterministically from the Uthmani text already shipped.
- **Segment** — a *named, addressable token range*: a Basmalah, a
  phrase, an ayah, a rukūʿ, a mushaf line. The unit everything else
  refers to.
- **Timed Segment** — a Segment plus `(startMs, endMs)` for a given
  reciter. The audio-sync substrate. Degrades gracefully: word timings
  where data exists, ayah timings where it doesn't, never a hard
  dependency.
- **Reading Position** — a Segment reference *plus intent* (reading /
  listening / memorizing / studying). Today's position store holds one
  integer and cannot express "I was memorizing page 5 with Husary at
  0.75×."

### Basmalah — as a Core Reading Element

Treated properly, one model covers all three canonical situations with
no UI special-casing, because the data declares what exists:

| Situation | Surahs | Model |
|---|---|---|
| Basmalah **is** āyah 1 | Al-Fātiḥah | A Segment coinciding with āyah 1 |
| Basmalah **leads** āyah 1 | 2–8, 10–114 | A Segment spanning tokens 1–4 of āyah 1 |
| Basmalah **absent** | At-Tawbah | No Segment. Nothing to special-case. |

Behaviour, fully specified:

- **Rendering** — honoured typography and its own vertical rhythm.
  Never merged into the āyah body in flow mode; always rendered as the
  printed mushaf shows it in mushaf mode.
- **Audio** — plays as its own segment where the reciter recites it
  separately and timing data exists; plays as a sub-range of āyah 1's
  file where it is embedded; is skipped where absent. One mechanism,
  three outcomes.
- **Playlist** — included when starting a surah from its beginning;
  skipped when resuming mid-surah; user-configurable (with
  isti'ādhah as a matching pre-surah segment — same shape, worth
  modelling at the same time).
- **Progress** — **excluded** from āyah-count progress (reciting the
  Basmalah is not reading an āyah) but **included** in session
  continuity. Getting this wrong inflates every statistic in the app by
  113 phantom āyāt per khatm.
- **Highlight** — participates as a single unit.

### Āyah rendering — three tiers, three jobs

| Mode | Job | Design |
|---|---|---|
| **Flow** | Comprehension | Arabic with layered translation/transliteration. Word-tap enabled. The study surface. This is where the product's identity lives. |
| **Mushaf** | Recitation & memorization | **Page- and line-faithful** to the Madani mushaf. Requires per-line data — a real content-pipeline investment, justified because memorizers navigate by visual position and reflowing actively harms hifz. |
| **Focus** | Presence | Pure Arabic, no chrome. Already the most distinctive reading mode in the app; keep it exactly as austere as it is. |

### Audio

- **Background playback, lock-screen controls, media session.** Table
  stakes; currently absent; highest-priority item in this whole
  document.
- **Timed-segment sync** — word-level highlight where data exists,
  ayah-level everywhere else, never degrading below today's behaviour.
- **Memorization primitives** — A–B loop over any Segment; repeat-N with
  configurable silence gap (for shadowing); progressive speed (start
  slow, increase across repetitions); gapless playback across āyāt.
- **Offline audio** — wire the existing `IoCacheManager` to a real
  management UI (download by surah/juz/reciter, show size, delete). The
  engine has existed since Sprint 5 and has never been reachable.
- **Multi-reciter comparison** — same āyah, two reciters, for studying
  recitation style. Nobody does this well.

### Highlight synchronization — three decoupled axes

Today, audio position and reading position are the same thing, and the
screen auto-scrolls to follow audio. That is wrong once someone is
studying: they will pause on āyah 12's translation while audio continues
to 10, and the app will fight them.

Design them as three independent positions:

- **Audio position** — what is being recited
- **Reading position** — where the user's attention is
- **Study position** — what is being reviewed or memorized

Auto-scroll becomes *suggestive*, not coercive: once the user scrolls
away, the app offers "jump to what's playing" rather than dragging them
back. Small change, large difference in whether the app feels like a
tool or a treadmill.

### Reading flow

- **Sessions with beginnings and ends.** A session proposes a stopping
  point — a rukūʿ boundary, a thematic unit, or the user's own goal —
  instead of infinite scroll. Ending well is part of the practice.
- **Resume restores position *and* mode *and* intent**, not just an
  index.
- **"Continue reading" reachable from everywhere** — home, notification,
  eventually a home-screen widget.

### Reflection (tadabbur)

- **Notes attach to ranges**, not single āyāt. Thoughts span verses.
- **Prompted reflection at natural boundaries — and the prompts are
  questions, never interpretations.** This is the critical design
  decision in the entire product. "What is this passage asking of you?"
  or "Which word here did you not know?" is a prompt. "This āyah means
  X" is tafsīr, and the app is not a scholar. Framing every prompt as a
  question sidesteps the theological-authority problem permanently
  rather than managing it case by case.
- **Reflections enter the SRS pool and resurface.** Your own words,
  returned at the right interval. This is the single most emotionally
  resonant unbuilt feature in this document.
- **Private by default, always. Exportable, always.**

### Study workflow — the loop that *is* the product

```
   READ ──► NOTICE ──► CAPTURE ──► REVIEW ──► RECALL ──► RE-ENCOUNTER
    ▲     (tap word,  (to study    (SRS)     (quiz)    (word appears
    │      highlight)   list)                           while reading,
    └────────────────────────────────────────────────────  now known)
```

**Re-encounter is the innovation.** While reading, words the user has
studied carry a subtle affordance; words marked unknown carry another.
Over months, the density of unknown-marked words visibly falls, and the
user *watches their own comprehension grow inside the text itself*. No
competitor closes this loop. It converts reading from consumption into
reinforcement, and it is only possible once the word is addressable.

---

## 5. Phases 4, 5, 6

### Phase 4 — Ship it, and lay the reading foundation

**Objectives**: put the product in real hands with nothing broken and
nothing dishonest; close the gaps that block daily use; lay the word-
addressability foundation that Phase 5 depends on.

**Epics**

| # | Epic | Note |
|---|---|---|
| E4.1 | **Beta launch readiness** — store assets, privacy policy, translation legal review, real-device a11y pass, Android performance measurement, version bump | The existing R3/R4/R5 work |
| E4.2 | **Audio completion** — background playback, lock-screen/media-session controls, cache management UI | Highest user-value-per-hour item on the board |
| E4.3 | **Word addressability foundation** — token segmentation, word-transliteration re-derivation, reciter segment-timing ingestion | Infrastructure that directly unlocks product value; unblocked by Finding 1 **as corrected 2026-08-28 (Session 157A)** — that is, unblocked by the QAC/morphology licence. The licence or permission governing the Quran.com QDC transliteration is a separate open question (**UNKNOWN — COUNSEL REQUIRED**) |
| E4.4 | **Tafsīr v1** — one well-licensed work, ayah-linked | Start licensing now; lead time is the risk, not engineering |
| E4.5 | **Lexicon resolution** — decide on 2026-08-24, don't drift | Decide, then act; do not extend |
| E4.6 | **Translation licensing for commerce** — see §7 | Long lead time; must start in Phase 4 even though revenue is Phase 6 |

**Risks**

- *Solo capacity.* Six epics is already too many for one person. E4.1
  and E4.2 are the non-negotiable pair; the rest are ordered.
- *Background audio touches three platforms' native configuration* —
  the first genuinely platform-specific work this project has done.
- *Tafsīr licensing may be as hard as QAC.* Assume it is; start early.
- *Beta feedback may invalidate the study-system thesis.* This is a
  feature of shipping, not a bug — but the plan must be willing to hear
  it.

**Success criteria**

- A beta cohort exists and 4-week retention is *measured*, not assumed
- Zero P0 defects; no dishonest surface (holds the R3b line)
- Background audio shipped and verified on a real device
- Word-level data present in the shipped artifact
- Tafsīr either shipped or explicitly deferred in a Decision Record
- Lexicon decided, in writing, on the deadline

### Phase 5 — The study system nobody else has

**Objectives**: make the retention promise real and *demonstrable*.
Phase 5 is where the UVP stops being a claim.

**Epics**: word-level reading experience (word-by-word display, tap-to-
meaning, tajwīd colouring) · vocabulary curriculum (frequency-ordered
core, integrated with SRS) · **the re-encounter loop** · reflection
system (ranges, question-prompts, resurfacing) · hifz mode (page-
faithful mushaf + audio repetition primitives + progressive reveal) ·
adaptive Smart Learning (make the 5-layer chain genuinely adapt).

**Risks**

- **Pedagogical authority.** A vocabulary curriculum is the first place
  this product makes claims *about meaning*. That needs scholarly review
  and a governance process — not a solo judgement call. Design the
  review process before writing the curriculum.
- **Tarteel's ASR advantage in hifz.** Competing head-on is likely
  wrong. Compete on *scheduling and retention* (what to review, when),
  which is where their product is weakest and this one is strongest.
- **Gamification vs reverence.** Phase 5 adds the most engagement
  surface of any phase. This is where the line in §2 must actually be
  drawn.

**Success criteria**

- A measurable learning outcome — users demonstrably retain N words at
  30 days, tested, not inferred from usage
- The re-encounter loop is visible to users and they can articulate it
- Hifz cohort adopts and retains
- Curriculum passed an external scholarly review before shipping

### Phase 6 — Continuity, community, and platform

**Objectives**: multi-device without breaking the privacy promise;
community carefully; extract NurVerse *only* from what is proven.

**Epics**: sync (end-to-end encrypted, account optional, local remains
authoritative) · teacher/halaqah tooling · community (shared khatm,
study circles) · assisted study (retrieval over *licensed tafsīr with
mandatory citation*, never generative interpretation) · NurVerse
extraction.

**Risks**

- *Sync vs the privacy position.* The UVP says "nothing leaves your
  device." Sync changes that. The answer is end-to-end encryption and
  making sync opt-in — but the messaging must be handled honestly, not
  quietly.
- *Moderation burden.* Community features on religious content, run by
  one person, is a serious liability. Scope minimally or not at all.
- **AI interpretive risk — the highest theological risk in this plan.**
  A model that paraphrases scripture or answers "what does this āyah
  mean" is generating tafsīr. The only defensible design is retrieval
  with mandatory attribution: it shows you what named scholars wrote,
  with citation, and never composes its own answer. This constraint must
  be architectural, not a prompt instruction.
- *Premature platform abstraction.*

**On NurVerse specifically.** `DATA_OS_ARCHITECTURE.md` §9 already
states the correct discipline, and it should govern: *"designing for an
unspecified consumer produces abstractions that fit nothing."*
**NurVerse is earned, not designed.** Ship Qur'an Companion; let a
second product state real requirements; extract only what both need.
The plausible extraction candidates — already proven by one consumer —
are the content pipeline + licence registry, the reliability layer, the
learning engine, and the local-first sync-ready data model. None should
be abstracted before product #2 exists and disagrees with product #1
about something.

**Success criteria**: sync adopted without measurable trust loss; a
second NurVerse product reuses extracted modules; zero incidents of
machine-generated interpretation presented as authoritative.

---

## 6. Feature allocation

**Public Beta** — everything already shipped, plus: background audio and
lock-screen controls (**must**); audio cache management UI (**must** —
without it the offline claim is false for audio); real-device
accessibility pass; Android performance measurement; version bump and
changelog cut; Lexicon/Flashcards honestly gated (already done) or
populated if the licence lands; Web either hosted or explicitly
deferred. Tafsīr is **not** required for beta — its absence, stated
honestly, is acceptable; pretending otherwise is not.

**v1.0** — beta scope plus: at least one tafsīr work; two or three more
translations (prioritising Southeast Asian languages over another
English edition); word-level data shipped in the artifact; mushaf line
fidelity (stretch); store submission complete.

**v1.1** — word-by-word display; tap-to-meaning; vocabulary curriculum
v1; the re-encounter loop; reflection system; search polish (recent,
suggestions, filters — the real features, now that the placeholders are
gone); tajwīd colouring.

**v2.0** — authentication and end-to-end encrypted sync; hifz mode;
teacher/institution tooling; community circles; assisted study with
mandatory citation; home-screen widgets. Recitation ASR belongs here at
the earliest, and only if the vocabulary/retention thesis has already
proven itself — it is a large investment against an entrenched
incumbent.

---

## 7. Monetization

### The bright line

**The Qur'an, its translations, and its recitation are never paywalled.
Ever. In any tier.** Access to revelation is not a product. This is not
a marketing position that could be revisited under revenue pressure; it
is the constraint every other decision is fitted around.

### What is rejected, and why

| Rejected | Reason |
|---|---|
| **Advertising** | Ad networks serve content incompatible with the context, track users by construction, and degrade reverence. The category's largest trust scandal was data-related; adopting the same machinery is indefensible. |
| **Selling or sharing user data** | Absolutely excluded. Here it is *structurally* impossible, not merely promised — the architecture has nowhere to send it. That is worth saying publicly. |
| **Paywalled scripture, translation, or recitation** | The bright line. |
| **Gharar mechanics** — loot boxes, randomized rewards, unclear subscription terms | Excessive uncertainty in exchange is impermissible, and applying chance mechanics to worship is worse than merely impermissible. |
| **Engagement-farming** — streak loss-aversion, guilt notifications, leaderboards over worship | Turns ibadah into a metric. Also, *this is currently a live design question*, not a hypothetical: streaks, goals, and achievements already ship. |
| **Riba-based financing** | Excluded at the company level, not just the product. |

### The blocker that must be resolved first

Per Finding 2: **the English translation ships under a non-commercial
licence.** No paid tier of any kind can ship alongside it. Before any
revenue model is possible, one of:

1. Obtain written commercial permission from the rights holders
   (Tanzil/Saheeh International; and verify QuranEnc/Rowwad's terms for
   the Vietnamese text), **or**
2. Replace with commercially-licensable translations, **or**
3. Structure the product so paid components are separable from
   translation distribution — legally fragile; do not rely on it.

Option 1 or 2, started in Phase 4. Lead time is months. Nothing about
monetization is decidable until this resolves.

### The recommended model, in priority order

1. **Free forever, and complete.** Text, translations, recitation,
   search, reading, the learning engine, offline. No worship feature is
   ever gated. This is not the loss-leader — it is the product, and the
   marketing.

2. **Institutional licensing — the recommended primary revenue path.**
   Hifz schools, madrasas, mosques, and halaqah teachers pay for teacher
   dashboards, class progress, and curriculum assignment. It is the
   best-aligned model available: the highest-margin revenue comes from
   institutions with budgets, individual access is untouched, and it
   fits the learning engine — which is already most of what a teacher
   dashboard needs. Phase 6, but design toward it from Phase 5.

3. **Supporter tier — voluntary, no features withheld.** Recurring
   support with transparent cost reporting ("your support pays for:
   hosting, content licensing, audio bandwidth"). Highest integrity;
   communities fund what they trust; consistently underestimated.

4. **Sync and continuity subscription.** Pay for the *service* of
   running servers — cross-device sync, encrypted backup, family
   accounts. Defensible precisely because you are paying for
   infrastructure that costs real money, not for scripture. Phase 6.

5. **Waqf / endowment.** Pursue institutional funding to permanently
   endow the free tier. Slowest path, and the most Islamically elegant
   answer to the sustainability question. Worth starting conversations
   early because the timeline is measured in years.

### The public commitment worth publishing

> We will never charge for the Qur'an, never advertise inside it, and
> never sell anything about you.

Publishable because the architecture already makes it true, and
verifiable because the provenance pipeline can prove the content half.

---

## 8. The decisions only you can make

Five forks this document deliberately does not resolve, because they are
founder decisions and not analysis outputs.

1. **Who is this for?** Vietnamese-first / Southeast-Asian-minority-
   language strategy, or global English? This is *the* fork; everything
   downstream changes. My recommendation: own the underserved language
   communities first — defensible, genuinely unserved, and already half-
   built by accident — then expand on the strength of the study system.
   But this is a life-direction decision, not a product one.

2. **Lexicon, on 2026-08-24.** If QAC says no: build morphology
   independently (expensive), find an alternative source, or **drop
   morphology and keep the rest of word-level** — which Finding 1 shows
   is entirely viable and is my recommendation if the answer is
   unfavourable.

3. **Translation licensing.** Required before any revenue. Start now.

4. **Hifz or comprehension first?** Both are credible; leading both
   simultaneously is not possible at current capacity. Comprehension is
   the less contested field and plays to the existing engine; hifz is
   the larger market and faces Tarteel.

5. **Community: yes or no?** Moderation of religious discussion, run by
   one person, carries real liability. "No" is a legitimate permanent
   answer.

---

## Closing assessment

Phase 3 ended with a well-engineered product that had no dishonest
surface and no clear reason to exist in a crowded category. The
engineering was never the problem, and after four sprints it is still
not the problem.

**The strategy is to stop competing on reading and start competing on
retention** — the one job in this category that nobody has claimed, that
this codebase is uniquely already built for, and that compounds in value
the longer a user stays.

Three things should happen before anything else: **ship background
audio** (the cheapest large win available), **start the translation
licensing conversation** (the longest lead time, and it silently gates
all revenue), and **decide who this is for** (because a Vietnamese-first
study app and a global English study app are different products, and
building both is how solo projects die).

---

PRODUCT VISION COMPLETE — no code, no commits, no release-document edits.
