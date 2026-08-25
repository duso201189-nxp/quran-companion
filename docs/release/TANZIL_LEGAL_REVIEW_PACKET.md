# Tanzil / Content-Licensing Legal Review Packet

**Status: EVIDENCE PACKET FOR LEGAL REVIEW. NOT A LEGAL OPINION. NOT A
COMPLIANCE CLAIM. NO CONCLUSION IS REACHED BELOW ON WHETHER CURRENT OR
PLANNED USE IS PERMITTED.**

This document exists to hand a legal reviewer (or the owner, before
engaging one) a single evidence-linked packet instead of scattered
citations across `docs/LICENSING.md`, `docs/release/V1_STORE_LEGAL_READINESS.md`,
and the app's own source. It does not perform the review itself. No
sentence below should be read as "license is approved," "commercial
use is allowed," "Tanzil permits us," or "legal compliant" — none of
those conclusions is supported by anything this repository contains,
and none is asserted here.

Prepared by reading `docs/LICENSING.md`,
`constitution/PROJ-P-005-non-commercial-translation-license.md`,
`docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md`,
`docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md`,
`lib/features/profile/presentation/profile_screen.dart`,
`lib/l10n/app_{en,vi,ar}.arb`, and `pubspec.yaml`, against `origin/main`
SHA `99e10c8f76e4c2cc1edcd2a0b7bf81f5f0f32f03` (Session 112,
2026-08-25). `docs/LICENSING.md` itself was authored Sprint 33.0
(2026-07-26) on a different branch and carries its own note that the
`main` database (~19.9 MB) predates a tafsir import — sources 5–6
(Al-Muyassar, Ibn Kathir tafsir) it describes are **not** currently
shipped on `main`; only sources 1–4 (Arabic text, transliteration, one
Vietnamese translation, one English translation) are. This packet
preserves that distinction rather than flattening it — see "Scope
actually shipping on `main` today," below.

No outreach to Tanzil, QuranEnc, QUL/Tarteel, or KFGQPC has been sent,
attempted, or drafted by this session. No claim is made anywhere below
that such contact has occurred.

---

## Scope actually shipping on `main` today

The current `assets/database/quran.sqlite` on `origin/main` contains
**only** sources 1–4 from `docs/LICENSING.md`'s table: Arabic Uthmani
text (Tanzil), Latin transliteration (Quran.com/QUL), Vietnamese
translation (QuranEnc.com, Rowwad), and English translation (Tanzil,
Saheeh International). The Al-Muyassar and Ibn Kathir tafsir sources
`docs/LICENSING.md` §1 also describes — including its "SERIOUS" Ibn
Kathir copyright finding — belong to a different branch's later import
and are **not** part of what `main` currently distributes. This packet
does not import that risk into scope it does not currently apply to,
and does not suppress it either — a reviewer evaluating a future merge
that adds tafsir content should re-read `docs/LICENSING.md` §1 and §4
in full at that time.

---

## FACT

Directly observable in the repository. No interpretation applied.

### F1. Sources used (currently shipping on `main`)

| # | Content | Source | In-app attribution string |
|---|---|---|---|
| 1 | Arabic Uthmani text | Tanzil Project | Yes — see F3 |
| 2 | Latin transliteration | Quran.com/QUL (Tarteel AI) | Not individually named — see F3 |
| 3 | Vietnamese translation (Rowwad) | QuranEnc.com | Yes — see F3 |
| 4 | English translation (Saheeh International) | Tanzil Project | Yes — see F3 (folded into "Tanzil.net") |
| 5 | Recitation audio (streamed, not bundled) | everyayah.com | Yes — see F3 |
| 6 | Mushaf font | KFGQPC | Yes — see F3 |

### F2. License terms as recorded in `docs/LICENSING.md`, quoted verbatim there from each source's own terms page

- **Tanzil, Qur'an text** (tanzil.net/download/): verbatim copying and
  distribution permitted; "changing the text is not allowed"; source
  attribution ("Tanzil Project") required; "a link is made to
  tanzil.net" required. No commercial-use restriction stated on this
  page.
- **Tanzil, translations** (tanzil.net/trans/) — a **separate, stricter**
  term set than the text page above: "for non-commercial purposes
  only"; otherwise requires "necessary permission from the translator
  or the publisher"; a link-back requirement triggers only when more
  than three Tanzil translations are used in one product (this app
  uses exactly one, so that specific clause is not currently
  triggered — the non-commercial restriction still applies
  independently).
- **QuranEnc** (quranenc.com/en/browse/vietnamese_rwwad) — seven
  conditions, quoted in full in `docs/LICENSING.md`: no modification;
  clear attribution to publisher and QuranEnc.com; version number
  must be mentioned on republish; transcript information must be
  kept inside the document; QuranEnc must be notified of any note on
  the translation; the translation must be updated to match QuranEnc's
  latest version; "inappropriate advertisements must not be included."
- **Quran.com/QUL (Tarteel AI)** — its own FAQ states resource-by-resource
  licensing varies, "we recommend reviewing the licensing information
  provided by each resource's author before use," and that commercial
  use of QUL data is possible "however, please review the licensing
  terms for each resource" individually — i.e. QUL does not itself
  grant a blanket license; it names itself as a distribution point
  whose underlying resources each carry their own terms.
- **everyayah.com audio** — no terms page was found for the MP3 audio
  files themselves. A disclaimer file
  (`.../timings_files/000_disclaimer.txt`) states a link-back
  requirement, but for the *timing files*, which this app does not
  use — `docs/LICENSING.md` explicitly does not extend that term to
  the audio files themselves. `docs/LICENSING.md` records the app's
  own database as labeling this content "Non-commercial —
  everyayah.com" and states plainly that this label is **this
  project's own cautious assumption, not a quotation of any
  owner-stated term.**
- **KFGQPC font (UthmanicHafs)** — EULA text quoted in
  `docs/LICENSING.md`: free-of-cost use, copy, and distribution
  permitted; the font itself "cannot be Sold, Modified, Altered,
  Translated, Reverse Engineered, Decompiled, Disassembled,
  Reproduced." `docs/LICENSING.md` notes this clause addresses selling
  the *font*, not whether an app containing it may itself be sold —
  described there as "a point of ambiguity to ask KFGQPC before
  charging."

### F3. In-app attribution — verified directly in source this session

`lib/l10n/app_en.arb:222` (and the `vi`/`ar` equivalents at the same
line):

> `"Arabic text & translations: Tanzil.net · QuranEnc.com. Audio:
> EveryAyah.com. Font: KFGQPC (King Fahd Complex)."`

Rendered at `lib/features/profile/presentation/profile_screen.dart:132`
as `subtitle: Text(l10n.aboutSourcesDetail)` — a **plain, non-interactive
`Text` widget**. Confirmed by reading the widget code directly, not
inferred from the string content: there is no `InkWell`, `GestureDetector`,
`url_launcher` call, or `RichText`/`TextSpan` link styling anywhere
around this string. It is not tappable and contains no hyperlink markup
of any kind.

Two attribution facts follow directly:

- **No hyperlink to tanzil.net exists**, despite Tanzil's text-license
  term requiring "a link is made to tanzil.net."
- **Quran.com/QUL (transliteration) is not individually named** in this
  string — it is omitted, not folded under a visible label the way
  Tanzil/QuranEnc/EveryAyah/KFGQPC are.

### F4. Current license language recorded in this repository

- `docs/LICENSING.md` — the full source-by-source table and quoted
  terms this packet draws F1–F3 from.
- `constitution/PROJ-P-005-non-commercial-translation-license.md`
  (status: active) — a Constitution-tier constraint stating plainly:
  "This app may not introduce paid features, ads, or any commercial
  model without either securing separate permission from Tanzil or
  replacing those data sources," citing the Tanzil translation
  non-commercial term (F2).
- `docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md` (accepted,
  governs `main`) and `docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md`
  (accepted, governs `main`) — govern the QAC/MASAQ Lexicon question
  specifically (F5 below). Neither is reopened, edited, or
  reinterpreted by this packet.

### F5. QAC / Lexicon — current governed status (not reopened here)

- MASAQ (the dataset `DR-2026-0016` had proposed as a QAC substitute)
  is **rejected** as a Lexicon source by `DR-2026-0029`, on two
  independent grounds: it lacks the Root/Lemma columns the pipeline's
  data contract requires, and its currently published version (v6) is
  licensed CC BY-NC 3.0, not the CC BY 4.0 `DR-2026-0016` assumed.
- No repository evidence exists that a QAC (corpus.quran.com)
  permission request was ever sent or answered. `DR-2026-0029` states
  this explicitly and does not conclude, in either direction, whether
  one was actually sent outside the repository's own record.
- Lexicon (F1 feature) and Flashcards (F2 feature) are formally
  deferred from v1.0 scope by `DR-2026-0030`. All 8 Lexicon database
  tables ship with 0 rows on `main` today.
- This packet does not add to, narrow, or restate a position on any of
  the above beyond what is written here for the reader's context — the
  governing documents are `DR-2026-0029` and `DR-2026-0030` themselves.

### F6. Current app behavior relevant to licensing

- The app bundles Arabic text, transliteration, and both translations
  as a **read-only asset database** (`assets/database/quran.sqlite`,
  `pubspec.yaml:49-50`) — not fetched at runtime.
- Recitation audio is **streamed/downloaded on demand** from
  `everyayah.com` and cached locally after download — not bundled in
  the app package (`lib/core/cache/io_cache_manager.dart:12-28`,
  `lib/core/audio/audio_url.dart:4`).
- The KFGQPC font is bundled and distributed **unmodified**
  (`docs/LICENSING.md` §3 confirms this matches its EULA's
  "unmodified" condition).
- No payment, subscription, or advertising code exists anywhere in
  `lib/` or declared in `pubspec.yaml` (independently confirmed in
  `docs/release/STORE_PRIVACY_FORM_DRAFT.md` §7–§8). `pubspec.yaml:3`
  declares `publish_to: 'none'`.
- App version is `0.8.1+7` — pre-1.0, unreleased
  (`pubspec.yaml:4`).

---

## UNKNOWN

Repository evidence is insufficient to answer these. Not guessed here.

- **U1.** Whether the app's current (non-commercial, `publish_to:
  'none'`, no ads/payments) state, plus its planned v1.0 shape, would
  satisfy Tanzil's translation non-commercial term if v1.0 ships free
  with no monetization — vs. whether any future monetization would
  require separate Tanzil permission or a source change. `PROJ-P-005`
  states the constraint; it does not adjudicate compliance.
- **U2.** Whether the current in-app attribution string (F3) — naming
  "Tanzil.net" as plain text with no hyperlink — satisfies Tanzil's "a
  link is made to tanzil.net" term, or whether a tappable link is
  required. Already flagged as P1-4 in
  `docs/release/V1_STORE_LEGAL_READINESS.md`.
- **U3.** Whether omitting Quran.com/QUL from the visible attribution
  string (F3) is consistent with QUL's own recommendation to review
  and honor each underlying resource's terms — QUL's FAQ does not
  itself state a specific attribution format requirement, so this is
  an open question about the underlying transliteration resource's own
  (unstated) terms, not something QUL's FAQ text answers directly.
  Already flagged as P2-2 in `V1_STORE_LEGAL_READINESS.md`.
- **U4.** Whether the everyayah.com audio's actual licensing terms
  (never located, per F2) permit the app's current streaming/caching
  behavior, or whether the project's own cautious "non-commercial"
  self-label is the correct posture to take.
- **U5.** Whether KFGQPC's "cannot be Sold" font clause would restrict
  distributing an app containing the font if that app itself carries a
  price — distinct from selling the font in isolation, which the
  clause unambiguously prohibits.
- **U6.** Whether QuranEnc's seven conditions (F2) — particularly
  keeping "transcript information inside the document" and notifying
  QuranEnc "of any note on the translation" — are satisfied by the
  app's current bundled-database approach, which does not surface a
  separate "transcript" artifact per se.

---

## OWNER / LEGAL QUESTION

Decisions that require the owner's judgment, legal counsel, or both —
not resolved by this packet.

- **Q1.** Is the app's current non-commercial, unmonetized shape (as
  of this SHA) sufficient to proceed toward v1.0 release under Tanzil's
  translation term, or should legal counsel be engaged *before* release
  to confirm that reading?
- **Q2.** Should a hyperlink to tanzil.net be added near the in-app
  attribution string (addressing U2), or should a legal opinion be
  sought first on whether the current plain-text form already
  satisfies the term?
- **Q3.** Should Quran.com/QUL be added as an individually named source
  in the attribution string (addressing U3), independent of whether
  QUL's terms strictly require it?
- **Q4.** Should outreach be made to everyayah.com (a contact channel,
  `quran.zendesk.com`, is recorded in `docs/LICENSING.md` §4 risk item
  2, itself sourced from prior audit work — not verified or contacted
  by this session) to obtain an authoritative license statement for the
  audio files (addressing U4), before relying on the app's own
  cautious self-label?
- **Q5.** Should legal advice be sought on the KFGQPC "cannot be Sold"
  ambiguity (U5) before any paid tier is considered — not urgent while
  the app remains free and `publish_to: 'none'`, but relevant the
  moment monetization is discussed.
- **Q6.** Whether, when, and how to pursue QAC permission outreach
  remains open and is governed by `DR-2026-0029`/`DR-2026-0030`, not by
  this packet. This packet does not initiate that outreach and does
  not recommend a timeline for it.

---

## What this packet explicitly does not conclude

- It does not state that Tanzil's, QuranEnc's, QUL's, everyayah.com's,
  or KFGQPC's terms are satisfied by current app behavior.
- It does not state that the app is cleared for commercial release,
  monetization, or v1.0 store submission.
- It does not state that QAC permission has been sought, denied, or
  granted.
- It does not recommend a specific legal strategy, outreach script, or
  timeline.
- It does not send, draft, or imply that any communication to Tanzil,
  QuranEnc, QUL, everyayah.com, or KFGQPC has occurred.
- It does not reopen, amend, or reinterpret `DR-2026-0029`,
  `DR-2026-0030`, or `PROJ-P-005`.

## References

`docs/LICENSING.md`, `constitution/PROJ-P-005-non-commercial-translation-license.md`,
`docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md`,
`docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md`,
`docs/release/V1_STORE_LEGAL_READINESS.md` (P0-2, P1-4, P2-2),
`lib/features/profile/presentation/profile_screen.dart:132`,
`lib/l10n/app_en.arb:222`, `lib/l10n/app_vi.arb:222`,
`lib/l10n/app_ar.arb:222`, `pubspec.yaml`.
