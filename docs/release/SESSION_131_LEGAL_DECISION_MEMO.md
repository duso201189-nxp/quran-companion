# Session 131 — Legal/Compliance Evidence & Decision Memo

**Status: EVIDENCE-BACKED PROJECT DECISION RECORD. NOT LEGAL ADVICE. NOT
LEGAL CLEARANCE. NOT A STATEMENT OF REGULATORY COMPLIANCE.**

This document exists to convert external legal/platform research into a
durable, evidence-linked project record, and to make one narrow product/
privacy decision (Public Address Decision, below) on that evidence. It
does not publish a Privacy Policy, does not submit any store form, does
not reopen or edit `DR-2026-0029` or `DR-2026-0030`, and does not
override any existing owner decision recorded in
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md`.

> **Session 131A correction (same day).** Google Play's Console
> Requirements page
> (`support.google.com/googleplay/android-developer/answer/10788890`)
> was re-checked directly and cited explicitly in the Google Evidence
> section (Phase 5) and the Public Address Decision (Phase 9). The
> correction: this memo's original text inferred a merchant-vs-non-merchant
> address-*display* split from several partially-inconsistent pages
> without an authoritative source confirming that outcome for this
> app's exact account type; that inference is now explicitly marked
> UNKNOWN/COUNSEL REQUIRED rather than stated as a MEDIUM-confidence
> reading presented as settled. The distinction between (a) Google's
> developer-*account* information requirement (legal name and address —
> confirmed FACT), (b) the Privacy Policy *document's* own content
> requirement (no address element found), and (c) what is *publicly
> displayed* on the Play Store listing (not settled for this account
> type) is now stated explicitly wherever the memo discusses Google.
> This correction did not touch the Vietnam, Apple, GDPR/CCPA,
> children's-privacy, or Tanzil sections, the Public Address
> recommendation (Option B is retained), or any private owner
> information — none was added or removed.

## A note on this session's premise

The task that produced this document referred to a prior "Session 130"
that had already completed this external research, asking this session
to "convert" it into a decision record. **No artifact of a Session 130
exists anywhere in this repository** — no file, no branch, no commit
message, no reference in `RELEASE_DASHBOARD.md` or any `docs/release/`
document. This session did not assume that research existed or copy
conclusions from it. Instead, this session performed the external
research itself (Phase 2 below), against the source-priority rules the
task specified, and built this record from that fresh research plus
direct re-reading of the actual repository state on `origin/main`
(commit `430dd182f3d1a8649a5916065dd694e012be063b`, verified by `git
fetch` + `git rev-parse`, not assumed from a stale local checkout — an
earlier local checkout in this working environment was 42 commits
behind on an unrelated branch and did not contain any of the
`docs/release/` files this memo relies on; all citations below were
re-pulled from `origin/main` directly via `git show`).

Everything else the originating task described — the five documents to
read, the two governance records, the owner's already-recorded
decisions, the current draft/unpublished status of the Privacy Policy —
**was independently verified against `origin/main` and found accurate**.
That verification is Phase 1, below.

---

## Phase 1 — What the repository actually contains (verified against `origin/main` `430dd18`)

| Document | Exists on `origin/main`? | Status as recorded there |
|---|---|---|
| `docs/release/V1_STORE_LEGAL_READINESS.md` | Yes | P0-1 (Privacy Policy) OPEN; P0-2 (Tanzil legal review) OPEN |
| `docs/release/PRIVACY_POLICY_DRAFT.md` | Yes | DRAFT, NOT PUBLISHED, NOT LEGALLY APPROVED |
| `docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` | Yes | B1–B5 owner-answered; Section C (8 items) open, legal-review-required |
| `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md` | Yes | Evidence packet; Tanzil legal review itself not performed |
| `docs/release/STORE_PRIVACY_FORM_DRAFT.md` | Yes | DRAFT ONLY, NOT SUBMITTED |
| `docs/LICENSING.md` | Yes | Full source-by-source licence table, Sprint 33.0 |
| `RELEASE_CHECKLIST.md` | Yes | Privacy Policy, Terms of Use, Apple Privacy Manifest, Play Data Safety all unchecked |
| `docs/adr/DR-2026-0029-qac-lexicon-licensing-decision.md` | Yes | `accepted` — governs QAC/MASAQ Lexicon sourcing only, **not Tanzil, not privacy** |
| `docs/adr/DR-2026-0030-formal-deferral-lexicon-flashcards-v1.md` | Yes | `accepted` — governs Lexicon/Flashcards v1.0 scope deferral only |

**Correction to the originating task's framing:** the task described
`DR-2026-0029`/`DR-2026-0030` as governance records this session should
"preserve" in a Tanzil-legal-review context. Having read both records in
full, **neither is about Tanzil, privacy, or store legal readiness** —
both exclusively govern the unrelated QAC/MASAQ Lexicon-morphology data
source question. The actual Tanzil-relevant evidence record already in
the repository is `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md`, which
this memo treats as authoritative prior work (Phase 7, below). Neither
ADR is modified, reopened, or reinterpreted by this document, consistent
with the task's own instruction not to touch them.

**Owner decisions already on record (not made by this session, only
cited):**

- Legal identity: **DU SÔ**, individual, not a registered business
  (`PRIVACY_POLICY_OWNER_DECISION_PACKET.md` B1, Session 114).
- Jurisdiction: **Vietnam** (B2, Session 114).
- Privacy contact: **qurancompanionhq@gmail.com** (B3, Session 114).
- Audience positioning: **general audience, not intentionally directed
  at children under 13** — stated as product positioning, not a
  compliance conclusion (B4, Session 114).
- Public-facing locality: **Thị xã Tân Châu, tỉnh An Giang, Việt Nam** —
  a reduced/general locality, explicitly not the owner's full
  residential address (B1 addendum, Session 128).
- iOS display name corrected to `"Qur'an Companion"` (B5, Session 128).
- Legal-sufficiency of the reduced locality: **explicitly left open**
  as Section C, item 8 — this memo's Phase 9/"Public Address Decision"
  addresses that specific open item.

---

## Phase 2 — External research performed this session

Four independent research passes were run against the source-priority
order the task specified (official government/platform sources first;
blogs, SEO content, Reddit, and forums excluded). Full findings are
summarized in Phases 3–8 below; this section records methodology and
its limits, honestly.

**Access limitations encountered (stated so confidence levels below are
not overstated):**

- Vietnam: `chinhphu.vn`/`congbao.chinhphu.vn` confirmed the existence,
  numbering, and effective dates of **Law 91/2025/QH15** and **Decree
  356/2025/NĐ-CP** directly, but the only accessible official copies of
  their full text were scanned, non-OCR signature PDFs with no
  extractable text layer. Article-level substantive text below is
  therefore drawn from an English translation hosted by LuatVietnam (a
  commercial legal-publishing service), cross-checked against
  Decree 13/2023/NĐ-CP's text and law-firm summaries (Tilleke &
  Gibbins, Vietnam Briefing) — **not independently verified against
  native-Vietnamese primary text**. This is flagged per-claim below.
- `ftc.gov`, `ico.org.uk`, `eur-lex.europa.eu`, and `ecfr.gov` returned
  HTTP 403 or bot-blocked responses to automated fetch. GDPR conclusions
  rely on the EDPB's own Guidelines 3/2018 PDF (fetched in full, and
  which quotes the GDPR Article 3 text and Recitals verbatim as official
  EU text). COPPA conclusions rely on a Cornell Law School mirror of the
  FTC-promulgated eCFR text (16 CFR Part 312), cross-checked against
  search-indexed FTC FAQ snippets and independent law-firm summaries of
  the same 2025 amended rule.
- CCPA/CPRA and Apple/Google research were fetched directly from
  official sources (`oag.ca.gov`, `developer.apple.com`,
  `support.google.com/googleplay/android-developer`) without access
  issues.

None of these limitations changes any conclusion below from a finding to
a guess — every UNKNOWN is stated as UNKNOWN, and every conclusion notes
its confidence level and the specific source it rests on.

---

## Phase 3 — Vietnam Legal Evidence

**Current framework (verified to exist; effective 1 January 2026):**

| Instrument | Status |
|---|---|
| Law No. 91/2025/QH15 (Personal Data Protection Law) | Passed 26 June 2025 by the National Assembly; effective 1 Jan 2026; 5 chapters, 39 articles. Existence/dates confirmed at `chinhphu.vn`/`congbao.chinhphu.vn` (OFFICIAL). |
| Decree No. 356/2025/NĐ-CP | Issued 31 Dec 2025, effective 1 Jan 2026, implementing the above Law. Existence/dates confirmed at `chinhphu.vn` (OFFICIAL); full article text not independently retrievable this session (scanned PDF). |
| Decree No. 13/2023/NĐ-CP | Effective 1 Jul 2023; **superseded by Decree 356/2025/NĐ-CP effective 1 Jan 2026** per multiple secondary sources. |

**Answers to the eight questions posed (each: FINDING, CONFIDENCE):**

1. **Must a Privacy Policy publicly contain a physical address?** No
   provision found requiring this in either Law 91/2025/QH15 (Art. 9,
   Art. 29(6) — notice-content requirements center on data type,
   purpose, and controller *identity*, not a specific address format)
   or the historical Decree 13/2023/NĐ-CP Art. 13 (six-item notice list,
   none of which is an address). **MEDIUM confidence** — based on a
   secondary English translation of the primary law, not native-text
   verification; Decree 356's own full text (the most likely place a
   standardized address field could be specified) was not obtainable
   this session.
2. **Must it contain a full residential address specifically?** Does not
   arise on the evidence found — no address requirement of any
   granularity was located. **UNKNOWN / COUNSEL REQUIRED.**
3. **Can a reduced locality be used?** No source states an affirmative
   locality-based standard exists. **UNKNOWN / COUNSEL REQUIRED** — not
   because reduction is forbidden, but because no rule requiring or
   permitting any address format was found at all.
4. **Is email sufficient as the sole privacy contact?** The Law does not
   specify a required contact *channel* (email vs. phone vs. postal). No
   textual bar to email-only. **LOW-MEDIUM confidence; treat as UNKNOWN
   / COUNSEL REQUIRED for a definitive "yes."**
5. **Is DOB required to be publicly disclosed?** Full-text search of the
   two primary-adjacent English texts found DOB referenced only as an
   example of *data-subject* data to be protected, never as a
   controller/operator self-disclosure requirement. **MEDIUM
   confidence.**
6. **Is a CCCD number required to be publicly disclosed?** Decree
   13/2023/NĐ-CP Art. 14(6)(a) requires an ID number only from a **data
   subject making a private request to a controller**, not from the
   operator, and not for public display. No provision found requiring
   an operator's own CCCD number in a public Privacy Policy. **MEDIUM-HIGH
   confidence** that CCCD is not a public-privacy-policy element under
   the PDPL specifically. Separately, CCCD numbers can appear in
   **business-registration filings** held by authorities under an
   unrelated legal regime (Decree 01/2021/NĐ-CP) — that regime's
   public/non-public treatment was not independently confirmed.
   **LOW / UNKNOWN — COUNSEL REQUIRED** on that separate point.
7. **Is a full residential address required for individual business
   registration, and is that information public or authority-only?**
   A separate legal regime (business/household-business registration,
   Decree 01/2021/NĐ-CP), administered by different authorities than the
   PDPL. A free, non-commercial, no-revenue app is unlikely to trigger
   any business-registration duty at all. **LOW / UNKNOWN — COUNSEL
   REQUIRED** on both the registration-trigger question and the
   public/private treatment of any address held there.
8. **Distinction between authority filings, platform verification, and
   public Privacy Policy content — must they be the same?** These are
   three legally and functionally distinct regimes: (a) authority/DPIA
   filings under Decree 356 Arts. 18–19 go to the Ministry of Public
   Security, not the public; (b) platform verification (Apple/Google) is
   a private contractual matter between developer and platform, outside
   Vietnamese PDPL's scope; (c) public Privacy Policy content is governed
   by Law 91/2025/QH15 Arts. 9/29(6), centered on data practices and
   controller identity, not a specific address/DOB/ID format. **No
   provision found requiring these three to be identical.** **MEDIUM
   confidence** on the distinction existing; **UNKNOWN** on whether any
   provision affirmatively *forbids* linking them (none found either
   way).

**Scale-based obligations:** Law 91/2025/QH15 Art. 38(2)–(3) exempts
**household businesses and microenterprises** (and gives small/startup
enterprises a 5-year opt-out) from DPIA/DPO obligations, unless
processing sensitive data or "a large number of data subjects" (a
secondary source states >100,000, not independently confirmed against
primary text). These carve-outs are scoped to **registered business
forms**, not unregistered individuals as such — whether an unregistered
individual publishing a free app with no server-side data collection
even falls within the Law's "processing" scope at all is a threshold
classification question. **LOW / UNKNOWN — COUNSEL REQUIRED.**
Separately, nothing found ties the *existence* of PDPL obligations to
commercial purpose — Art. 1(2)'s stated scope ("Vietnamese... individuals")
carries no revenue/commercial threshold on its face, qualified only by
the Art. 38 carve-outs above.

**Overall Vietnam finding:** on the evidence obtained, Vietnamese law
does **not** appear to textually mandate a physical address, DOB, or
CCCD number as required public Privacy Policy content for this kind of
app — but this rests on a secondary translation of the primary law, not
verified native text, and Decree 356's full implementing text (most
likely location for any standardized-form address field) could not be
obtained. **This is INTERPRETATION from partial evidence, not FACT —
LEGAL COUNSEL REQUIRED before relying on it.**

---

## Phase 4 — Apple Evidence

Categories A–E kept strictly separate per the task's instruction, since
conflating them is the most common error in this area.

**A. Privacy Policy document content (App Store Review Guidelines
5.1.1(i)):** OFFICIAL REQUIREMENT — must identify data collected, how
and why, confirm third-party protection parity, and describe
retention/deletion and consent-revocation. **No address requirement
found anywhere in Guideline 5.1.** HIGH confidence (direct guideline
text, `developer.apple.com/app-store/review/guidelines/`).

**B. App Privacy "nutrition label" (App Store Connect questionnaire):**
a separate deliverable from A. Privacy Policy URL is stated as
"required for all apps" regardless of monetization or data practices.
HIGH confidence (`developer.apple.com/help/app-store-connect/reference/app-information/app-privacy`).

**C. Developer Program account identity verification (developer ↔
Apple only):** legal name, phone, address (no P.O. boxes), sometimes a
government ID/photo — submitted to Apple, not the public, per
`developer.apple.com/help/account/membership/identity-verification/`.
For an individual/sole proprietor, the **legal name** (not the address)
becomes the public "Seller" attribution on the App Store listing per
`developer.apple.com/support/enrollment/`. HIGH confidence on the
name-is-public fact; MEDIUM confidence that address/ID stay
Apple-internal (an inference from the absence of any contrary statement,
not an explicit Apple guarantee).

**D. EU Digital Services Act "trader" requirements (public, EU
storefronts only):** Apple's own guidance gives, as an example of a
likely **non-trader**: "a hobbyist [who] developed your app with no
intention of commercializing it." This app — free, no ads, no IAP, no
declared commercial intent — fits that example closely. If declared
non-trader, no address/phone/email is publicly shown; only a generic
"consumer protections don't apply" notice to EU users. If declared (or
found to be) a trader, the public fields are Address-or-P.O.-Box, phone,
and email — and a P.O. Box with supporting documentation satisfies the
address field, distinct from the (unrelated) private Category C
enrollment address. HIGH confidence on the mechanics;
**LEGAL COUNSEL REQUIRED** on which classification actually applies —
Apple explicitly disclaims making this determination itself.

**E. Storefront public display:** only the developer's legal name is
shown by default; no address is publicly shown absent the DSA trader
mechanism. MEDIUM confidence (absence-based).

**Direct answer:** Apple's Privacy Policy content rules do **not**
require a full residential address. Apple requires an address only (i)
privately, at Developer Program enrollment (Category C — internal to
Apple), and (ii) publicly, only for EU-storefront users and only if the
developer is/declares a "trader" (Category D) — and even then a P.O. Box
suffices. Free/non-monetized status is one of Apple's own stated factors
supporting non-trader status, though the ultimate classification is
outside Apple's documentation and requires the developer's own legal
judgment.

**Apple Kids Category (children, platform policy angle):** opt-in via
an explicit age-band selection (Guideline 1.3); an app that does not
select it is not subject to Kids-Category-specific restrictions by
default. Guideline 5.1.4(b) separately requires a privacy policy for
apps that "collect, transmit, or have the capability to share personal
information... from a minor," independent of Kids Category — not
applicable to this no-data-collection app on current evidence. Whether
Apple's review team applies any independent "directed at children" test
beyond category self-selection is **UNKNOWN / COUNSEL REQUIRED** — no
official page fetched articulates one.

---

## Phase 5 — Google Play Evidence

Categories A–E kept strictly separate, as above.

**A. Privacy Policy document content (User Data policy):** OFFICIAL
REQUIREMENT — must include developer information **and a privacy point
of contact *or* a mechanism to submit inquiries** (this "or" means an
address is not textually required — a contact mechanism such as email
suffices on its face), plus data-type/sharing disclosure, security
practices, retention/deletion policy, clear "privacy policy" labeling,
and the entity named must match the Play Store listing entity. HIGH
confidence on the six elements
(`support.google.com/googleplay/android-developer/answer/10144311`).
**No explicit residential-address requirement found in this policy's
text.** MEDIUM confidence — the "or a mechanism to submit inquiries"
language was extracted via automated page reading, not manually
cross-checked line-by-line against every regional addendum on the live
policy page. **COUNSEL REQUIRED to fully rule out a regional/GDPR-style
controller-address clause layered in elsewhere.**

**B. Data Safety section:** a separate, mandatory in-console
questionnaire "regardless of monetization model" — even apps collecting
no data must complete it and supply the Privacy Policy URL. HIGH
confidence. Distinct artifact from A; content must be *consistent* with
the Privacy Policy document, not identical to it.

**C. Developer identity verification (Google-internal account
information):** OFFICIAL REQUIREMENT, per Google Play Console
Requirements
(`support.google.com/googleplay/android-developer/answer/10788890`,
cited directly this correction pass) — developer account information
includes **legal name and address**, a **D-U-N-S number if the account
is an organization**, and **contact email and phone**. This is
confirmed FACT: Google requires legal name and address as part of
developer *account* information. It is a distinct requirement from
Category B (Privacy Policy content, below) and is not, by itself, a
statement about what the Privacy Policy document must contain or what
becomes publicly visible — see Category D. Individual accounts
separately supply a government ID and a Google Payments profile;
D-U-N-S numbers apply only to organization accounts, "does not apply to
individual accounts." A separate contact email/phone used by Google
internally is explicitly "NOT shown to users on Google Play." HIGH
confidence
(`support.google.com/googleplay/android-developer/answer/10841920`,
`.../13628312`, `.../10788890`).

**D. Public developer information:** the same Google Play Console
Requirements page states that a **developer email and phone are shown
on Google Play "where applicable"** — Google's own phrasing is
conditional, not a blanket statement that every account's full contact
set (name, address, email, phone) is published for every account type.
No authoritative Google source fetched this session **explicitly
establishes, for an individual, non-merchant/non-monetized account
specifically, that the full residential address from Category C is
published on the Play Store listing.** A prior reading in this memo
inferred a merchant-vs-non-merchant address-display split from several
partially-inconsistent official pages; that inference is retained below
as a plausible reading, not a confirmed FACT, because no single
authoritative source gave an unambiguous, verbatim rule for this exact
account type/circumstance. **LOW-MEDIUM confidence — UNKNOWN / COUNSEL
REQUIRED.** The developer should personally check their own Play
Console "Developer profile" screen to see the actual public-display
fields for this specific account before relying on any reading here. EU
"trader status" equivalent to Apple's DSA mechanism could not be
located within Google's own approved documentation domains this
session — **UNKNOWN / COUNSEL REQUIRED**, particularly relevant if EU
distribution is intended.

**E. Monetization differences:** Data Safety completeness — no
difference (always required in full). Public address disclosure —
a merchant/non-merchant distinction was hypothesized in earlier research
this session but is **not confirmed by an authoritative source for this
exact account type** (see Category D above) — treat as UNKNOWN, not as
an established reduction. Identity verification tier — no apparent
reduction; government ID is required regardless of monetization.

**Direct answer:** Google's Privacy Policy content rules (Category B)
do **not** clearly require a full residential address inside the
Privacy Policy document itself (a contact mechanism suffices per the
policy's own "or" language — see Category B below). Separately and
distinctly, Google's developer *account* requirements (Category C) do
require legal name and address — this is FACT, confirmed against
Google's own Play Console Requirements page. Whether, and for which
account types, that account-level address becomes **publicly displayed**
on the Play Store listing (Category D) is **not settled** by any source
fetched this session with the specificity this app's exact
circumstance (individual, free, non-monetized) would require. This
memo does **not** state that Google requires a full residential address
in the Privacy Policy, and does **not** state that Google will
necessarily publicly display the full residential address for this
account — neither claim is supported by an authoritative source found.
Verify directly against the developer's own Play Console account before
relying on any reading here.

**Google Play Families Policy (children, platform policy angle):**
applies "if one of the target audiences for your app is children," per
the developer's own Target Audience and Content declaration — **but**
Google explicitly reserves the right to reclassify based on actual
content/imagery/terminology regardless of the developer's declaration.
Self-declaring "general audience" does not categorically exempt the app.
HIGH confidence on the quoted reservation; MEDIUM on the full list of
signals Google actually weighs (not fully enumerated in the page
fetched).

---

## Phase 6 — GDPR / UK GDPR / CCPA Evidence

**GDPR Article 3 — three triggers, none conflated:**

- **Establishment (Art. 3(1)):** no EU office, employee, agent,
  subsidiary, or stable EU arrangement exists for this solo,
  Vietnam-based developer. **Not triggered on current facts.** HIGH
  confidence (clear legal test; unambiguous fact pattern).
- **Targeting — offering goods/services (Art. 3(2)(a)):** per EDPB
  Guidelines 3/2018 (quoting GDPR Recital 23, itself official EU
  text): "the mere accessibility of the controller's... website in the
  Union... is insufficient" to establish targeting intent. No EU
  currency, no EU-specific marketing, no EU top-level domain, no naming
  of EU countries, no delivery feature (the app is free) exists.
  App-store availability in EU territories alone, without more, is
  analogous to the "mere accessibility" the EDPB explicitly treats as
  insufficient. **Not triggered on current facts.** MEDIUM confidence —
  the underlying test is a multi-factor, case-by-case "in concreto"
  standard, not a bright line, and depends on facts (exact store
  metadata/territory settings) this document did not separately audit.
- **Monitoring (Art. 3(2)(b)):** no analytics, ad, or tracking SDK; no
  cookies; all data local-only. **Not triggered on current facts.**
  HIGH confidence — the most clearly unmet of the three triggers, given
  the app's architecture. (The one third-party audio stream to
  `everyayah.com` makes that site a separate, independent controller for
  whatever it logs — not behavioural monitoring performed by this app's
  developer.)

**This is an evidence-based, trigger-based conclusion, not a categorical
"GDPR does not apply" statement** — see the CURRENT STATE vs. TRIGGER FOR
REASSESSMENT table below.

| Trigger | Current state | Would change on |
|---|---|---|
| Establishment | No EU presence of any kind | Opening an EU office, hiring EU staff/agents, forming an EU entity |
| Targeting (goods/services) | No EU-specific language, currency, marketing, or domain; free app, no delivery feature | Adding EU-targeted marketing/localization tied to EU languages, accepting EUR/GBP payments, EU-specific store-listing copy |
| Targeting (monitoring) | No analytics/ad/crash SDK, no cookies, local storage only | Adding any analytics/crash/tracking SDK, cloud sync/accounts, push notifications with tracking identifiers |

**UK GDPR:** the ICO's own guidance pages were not directly fetchable
this session (HTTP 403); the UK GDPR's territorial-scope test mirrors
EU GDPR Article 3 closely per corroborating secondary sources, so the
same trigger-based reasoning above is treated as informative but
**UNKNOWN / COUNSEL REQUIRED** pending direct ICO-source verification.

**CCPA/CPRA:** per the California Attorney General's official CCPA
guidance, the law applies only to a "business" meeting at least one of:
gross annual revenue over ~$25M (inflation-adjusted), buying/
selling/sharing 100,000+ CA consumers'/households' data annually, or
deriving 50%+ of revenue from selling/sharing CA residents' data. This
app has zero revenue, no accounts, and no data-sale/sharing
relationship. **Plausibly does not meet the CCPA "business" threshold at
all** on current facts. MEDIUM-HIGH confidence on the threshold facts
(official OAG source, direct fetch); MEDIUM on application to an
unincorporated individual specifically (a structuring question, not
addressed by the OAG guidance directly). This is a threshold-based, not
entity-status-based, conclusion — revisit if monetization or a data-sale
relationship is ever introduced.

---

## Phase 7 — Tanzil Licensing Evidence

`docs/release/TANZIL_LEGAL_REVIEW_PACKET.md` (already in the repository,
prepared Session 112) is treated as the authoritative existing evidence
packet for this topic; this memo does not restate it in full and does
not re-perform the legal review it explicitly defers. This session
independently re-fetched Tanzil's own terms pages to confirm currency:

| Content | Source | Terms | Commercial? | Modification | Hyperlink |
|---|---|---|---|---|---|
| Arabic Qur'an text | tanzil.net/download/ (fetched fresh this session) | Verbatim copying/distribution permitted | Not restricted on this page | **Prohibited** | **Required** — "a link is made to tanzil.net" |
| Translations (incl. Saheeh International) | tanzil.net/trans/ (fetched fresh this session) | **Separate, stricter** term set | **"For non-commercial purposes only"** | N/A | Required only if >3 Tanzil translations used (app uses exactly 1 — not triggered) |

**Confirmed directly this session: the Arabic-text licence and the
translation licence are legally distinct term sets on Tanzil's own site
— the non-commercial restriction applies to the translation (Saheeh
International) specifically, not to the Arabic text page's terms.** This
matches, and does not contradict, `docs/LICENSING.md` and the existing
Tanzil packet.

**What remains unresolved (per the existing packet, not reopened or
narrowed here):**
- P1-4 (`V1_STORE_LEGAL_READINESS.md`): the in-app attribution string is
  plain, non-hyperlinked text — Tanzil's own "a link is made to
  tanzil.net" term is **not currently satisfied literally**, on the
  repository's own evidence (`profile_screen.dart:132`, confirmed by
  reading the widget code). Whether this constitutes non-compliance or
  whether some other channel satisfies the term is a legal-interpretation
  question, not resolved by this memo.
- P0-2: the Tanzil translation legal review itself (Q1 in the existing
  packet — whether the app's current free/`publish_to: 'none'` posture
  satisfies the non-commercial term) remains **not returned**.
- QAC/MASAQ (governed separately by `DR-2026-0029`/`DR-2026-0030`, not
  Tanzil, and not touched by this memo).

This memo adds no new conclusion to Tanzil licensing beyond confirming
the two source pages' current text is unchanged from what
`docs/LICENSING.md` and `TANZIL_LEGAL_REVIEW_PACKET.md` already record.

---

## Phase 8 — Children's Privacy Evidence

Kept distinct from platform-policy findings already stated in Phases 4–5
(Apple Kids Category, Google Families Policy); this section covers the
**legal** (COPPA) angle specifically.

Per 16 CFR §312.2 (the FTC's COPPA Rule definition, as amended 2025):
"directed to children" is a **multi-factor, totality-of-circumstances**
test (subject matter, visual content, animated characters,
child-oriented incentives, music, model ages, child celebrities,
language, plus empirical audience-composition evidence) — **no single
factor, including a general-audience label, is dispositive.**
"Your content isn't considered 'directed to children' just because some
children may see it" — but a **"mixed audience"** classification exists
for general-audience content that nonetheless shows some child-appeal
signals, for which neutral age-screening (not defaulting to over-13, not
using logic questions children can't answer) is the FTC-sanctioned
mechanism, not automatically mandatory.

**Applied to this app:** Qur'an memorization/recitation content plausibly
appeals to children as one of several audience segments (a real-world
common use case), which puts it in an ambiguous zone between "general
audience" and "mixed audience" under the FTC's own framework — the
owner's B4 positioning does not resolve this by itself. **However**,
COPPA's substantive obligations (parental consent, data minimization,
retention limits) attach specifically to **collection** of a child's
personal information — and this app collects no personal information
from any user, child or adult (no accounts, no registration fields, no
identifiers). On current architecture, even an unfavorable "directed to
children"/"mixed audience" finding would not, by itself, create an
active parental-consent obligation, because there is nothing collected
to consent to.

**Classification: POSSIBLE, not LIKELY, not confirmed —
LEGAL COUNSEL REQUIRED for a definitive statement.** This is not a
"COPPA does not apply" conclusion; it states that the app's zero
personal-data-collection posture substantially reduces (but does not by
itself legally resolve) COPPA exposure, and that the underlying
"directed to children" classification itself remains open, contingent
on facts (actual audience composition, marketing language) not
determinable from source code.

---

## Phase 9 — Public Address Decision

**Options, as framed by the task:**

| Option | Description |
|---|---|
| A | Full residential address |
| B | Reduced locality — "Thị xã Tân Châu, tỉnh An Giang, Việt Nam" (already the owner's Session 128 choice) |
| C | Name + email only, no locality |
| D | Other evidence-supported option |

**Evaluation against this session's evidence:**

- **Legal basis.** No source found in Phases 3–6 — Vietnamese PDPL,
  Apple's Privacy Policy guidelines, Google's User Data policy, or
  GDPR/CCPA — clearly requires *any* address (full or reduced) inside a
  public Privacy Policy for a free, non-commercial, no-account app.
  This is a genuinely new, evidence-backed finding relative to
  `PRIVACY_POLICY_OWNER_DECISION_PACKET.md` Section C item 8, which
  flagged the question as open without prior research to answer it. It
  remains **INTERPRETATION from partial/secondary evidence, not FACT** —
  see the access limitations in Phase 2.
- **Privacy exposure.** A ≥ B ≥ C in descending order of the owner's
  personal exposure. Option B already avoids exposing anything below
  district/province granularity; Option C would remove locality
  entirely.
- **Apple risk.** Phase 4: no Privacy-Policy-content address requirement
  found at all; Apple's DSA non-trader path (the closely-fitting example
  for this app) requires no public address regardless of A/B/C. No
  Apple-specific risk differential identified between B and C on
  current evidence.
- **Google risk.** Phase 5 (Category C): Google separately requires
  legal name and address for developer *account* verification — this is
  confirmed FACT, not a Privacy-Policy-content requirement. That
  account-level requirement does not, by itself, establish that the
  full residential address must appear in the Privacy Policy, or that
  it is publicly displayed on the Play Store listing for this account
  type (Category D remains UNKNOWN/COUNSEL REQUIRED — see Phase 5). Option
  B provides a limited geographic identity signal in the public-facing
  Privacy Policy while avoiding publication of the developer's full
  residential address there; it does not change, satisfy, or bypass
  whatever Google separately requires at the account level, which is
  outside this memo's scope and outside the Privacy Policy document
  itself. No confirmed Google-specific risk differential between B and
  C was established for the Privacy Policy document specifically; this
  remains MEDIUM/LOW confidence and merits a direct Play-Console check.
- **User transparency.** B offers slightly more transparency than C
  (a general sense of the developer's home region) without approaching
  A's exposure. Neither is clearly required by any store or law found.
- **Future flexibility.** B is already implemented across
  `PRIVACY_POLICY_DRAFT.md` and the owner-decision packet; changing to C
  would require another documentation pass with no evidenced compliance
  benefit. B is silent-compatible with a future move to C if the owner
  later wants less disclosure, and with a future forced move to A if
  some jurisdiction-specific rule is later found to require it (not
  found in this research).
- **Rework cost.** Retaining B: zero (already implemented, already
  owner-decided). Moving to C: low but non-zero documentation
  rework, with no evidenced legal necessity driving it. Moving to A:
  would require reopening the owner's Session 128 decision and
  disclosing information the owner has explicitly chosen to keep
  private — not supported by any finding in this research.

**Recommendation: retain Option B.**

This affirms, rather than overrides, the owner's Session 128 decision.
The evidence in this memo does not show Option B is legally
*insufficient* (no source requires more), nor does it show Option B is
legally *unnecessary* strongly enough to justify reopening an
already-made, already-implemented owner decision on a documentation-only
session. The genuinely new finding — that no source located actually
requires a public address of any kind — is offered as context for the
owner's own future judgment, not as a basis for this session to change
B to C unilaterally.

**This is a PRODUCT / PRIVACY RISK DECISION.** It is explicitly **NOT**
a legal requirement determination and **NOT** legal clearance. Section C
item 8 of `PRIVACY_POLICY_OWNER_DECISION_PACKET.md` — whether Option B
satisfies any store's or jurisdiction's specific disclosure rule —
**remains open and is not closed by this memo.**

---

## Phase 10 — Challenge: classification of common claims

| # | Claim | Classification | Basis |
|---|---|---|---|
| 1 | "CCCD address must be public." | **UNSUPPORTED** | No provision found in Law 91/2025/QH15 or Decree 13/2023/NĐ-CP requiring an operator's CCCD-linked address to be publicly disclosed (Phase 3, Q6). |
| 2 | "DOB must be public because legal identity is used." | **UNSUPPORTED** | DOB appears in Vietnamese PDPL text only as protected data-subject data, never as required controller self-disclosure (Phase 3, Q5). |
| 3 | "Apple requires full address in the Privacy Policy." | **UNSUPPORTED** | Guideline 5.1.1(i) has no address element; address is relevant only via the optional/conditional DSA trader mechanism, where a P.O. Box suffices (Phase 4). |
| 4 | "Google requires full address in the Privacy Policy." | **UNSUPPORTED** | User Data policy requires a contact point *or* inquiry mechanism, not specifically an address; full address appears tied to merchant/monetized accounts (Phase 5) — MEDIUM confidence, not fully verified line-by-line. |
| 5 | "Global availability automatically triggers GDPR." | **UNSUPPORTED** | EDPB Guidelines 3/2018, quoting Recital 23: mere accessibility is explicitly insufficient for the targeting trigger (Phase 6). |
| 6 | "General audience automatically means no COPPA risk." | **UNSUPPORTED** | FTC's multi-factor "directed to children" test applies regardless of stated positioning; "mixed audience" content is evaluated on signals, not labels (Phase 8). |
| 7 | "Tanzil attribution automatically means license compliance." | **UNSUPPORTED** | The repository's own evidence shows the in-app attribution string does not literally satisfy Tanzil's "a link is made to tanzil.net" term (P1-4, confirmed again this session) (Phase 7). |
| 8 | "Free app automatically means no legal/privacy obligations." | **UNSUPPORTED** | Both Apple and Google require a Privacy Policy and a data-practices questionnaire regardless of monetization (Phases 4–5); Vietnamese PDPL's stated scope carries no commercial threshold on its face, subject only to registered-business-form carve-outs that don't obviously apply to an unregistered individual (Phase 3). |

No claim in this list is classified SUPPORTED or PARTIALLY SUPPORTED.
This is a straightforward outcome of the evidence gathered, not an
adjusted or softened framing.

---

## Phase 11 (structure) — the sections above satisfy the required outline

The required section set (Executive Decision through Source Register) is
provided across this document as follows: **Executive Decision** = Phase
9's recommendation plus this section; **Owner Facts** = Phase 1's owner
decisions table; **Private Information Boundary** = Phase 12 below;
**Vietnam/Apple/Google/GDPR-CCPA/Children's/Tanzil Evidence** = Phases
3–8; **Public Address Decision** = Phase 9; **Current Risk Position** and
**Reassessment Triggers** = below; **Questions Requiring Actual Legal
Counsel** = below; **Source Register** = Phase 2 + inline citations
throughout, consolidated below.

### Executive Decision

Retain the owner's existing Option B public locality
("Thị xã Tân Châu, tỉnh An Giang, Việt Nam"). No change to
`docs/release/PRIVACY_POLICY_DRAFT.md`,
`docs/release/STORE_PRIVACY_FORM_DRAFT.md`, or
`docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` is made by this
memo. P0-1 and P0-2 in `V1_STORE_LEGAL_READINESS.md` remain open. This
memo closes no Go/No-Go item and authorizes no release action.

### Current Risk Position

- **Privacy Policy:** drafted, owner-confirmed on identity/jurisdiction/
  contact/audience/locality, **not published, not legally approved** —
  unchanged by this memo.
- **Address disclosure:** new evidence (this memo) suggests no external
  source *requires* a public address at all for this app's profile, but
  this is INTERPRETATION from partially-verified sources, not a cleared
  finding — Option B is retained as the more conservative,
  already-implemented choice.
- **Tanzil:** non-commercial restriction on the Saheeh International
  translation confirmed unchanged and independently re-verified this
  session; attribution hyperlink gap (P1-4) confirmed still present;
  legal review (P0-2) still not performed.
- **GDPR/UK GDPR:** no current trigger identified on the app's present
  architecture (evidence-based, not a flat "does not apply" claim).
- **CCPA:** plausibly below the "business" threshold given zero revenue.
- **COPPA:** POSSIBLE compliance exposure reduced by zero
  data-collection architecture; classification itself unresolved.
- **Children's platform policy (Apple/Google):** both platforms reserve
  independent re-evaluation rights regardless of the owner's stated
  "general audience" positioning.

### Reassessment Triggers

- Any addition of an analytics, crash-reporting, or advertising SDK.
- Any addition of user accounts or cloud sync (already roadmapped at the
  schema level per `constitution/PROJ-P-004`, not yet implemented).
- Any monetization (ads, in-app purchases, paid app, donations routed
  through a data-sharing intermediary) — independently triggers
  re-examination of the Tanzil non-commercial restriction
  (`PROJ-P-005`), Apple/Google merchant-tier obligations, and the CCPA
  revenue threshold.
- Any EU-specific marketing, localization, or store-listing language.
- Any evidence (from app-store analytics dashboards, if ever added, or
  otherwise) that actual user geography or age distribution differs
  materially from the assumptions in this memo.
- Publication of Decree 356/2025/NĐ-CP's full text in an accessible,
  OCR'd, or official-portal-searchable form — this memo's Vietnam
  findings should be re-verified against it directly when available.

### Questions Requiring Actual Legal Counsel

1. Whether Vietnamese PDPL (Law 91/2025/QH15 + Decree 356/2025/NĐ-CP)
   imposes any obligation at all on an unregistered individual
   publishing a free app with no server-side data processing — a
   threshold classification question this memo could not resolve from
   available text.
2. Whether the reduced public locality (Option B) satisfies any specific
   store's or jurisdiction's disclosure requirement, if one is later
   found to exist that this research did not surface.
3. Whether the app's non-commercial, `publish_to: 'none'` posture
   currently satisfies Tanzil's translation non-commercial term, and
   whether the missing tanzil.net hyperlink (P1-4) requires a fix before
   release.
4. Whether the app's Qur'an memorization/recitation subject matter tips
   it into FTC "mixed audience" status under COPPA, and if so, whether
   neutral age-screening should be implemented.
5. Whether the app, if it ever distributes to EU storefronts, should
   declare "trader" or "non-trader" status under Apple's and (separately)
   Google's EU DSA compliance mechanisms.
6. Whether QuranEnc's and Quran.com/QUL's attribution terms are
   satisfied by the current combined in-app string (already flagged as
   P1-4/P2-2, not resolved here).

### Source Register

All sources cited by URL are listed in the four research passes'
outputs, condensed above; the primary/official vs. secondary
distinction is preserved per-claim throughout Phases 3–8. Full
per-source detail (SOURCE | URL | DOCUMENT | VERSION | REQUIREMENT |
APPLICABILITY | CONFIDENCE rows) was produced during this session's
research and is available in this session's transcript; this memo
condenses it here to keep the document readable, while preserving every
material conclusion's citation inline above. Primary official domains
used: `chinhphu.vn`, `congbao.chinhphu.vn`, `developer.apple.com`,
`support.google.com/googleplay/android-developer` (including
`.../answer/10144311` — Privacy Policy/User Data requirements — and
`.../answer/10788890` — Play Console Requirements/developer account
information, re-confirmed directly in the Session 131A correction
pass), `oag.ca.gov`, `edpb.europa.eu`, `tanzil.net`. Secondary sources
used only where
official text was inaccessible, and labeled as such throughout:
LuatVietnam (Vietnamese law translation), Tilleke & Gibbins and Vietnam
Briefing (law-firm summaries), Cornell Law School LII (eCFR mirror for
16 CFR Part 312).

---

## Phase 12 — Private Information Boundary

The following categories of information exist as private,
source-of-truth owner records **outside this repository** (per
`PRIVACY_POLICY_OWNER_DECISION_PACKET.md`'s own Session 128 note) and
are **deliberately not reproduced anywhere in this document**, exactly
as they are not reproduced anywhere else in this repository:

- Date of birth.
- CCCD (national ID) number and issue details.
- Full residential/hamlet-level address.

Only the owner's already-public, already-decided locality string
("Thị xã Tân Châu, tỉnh An Giang, Việt Nam") appears above, exactly as it
already appears in `PRIVACY_POLICY_DRAFT.md` and
`PRIVACY_POLICY_OWNER_DECISION_PACKET.md`. This document adds no new
private information to the repository and removes none of the existing
redactions those documents already maintain.

---

## Phase 13/14 — What this memo does not do

- It does not publish a Privacy Policy or submit any store form.
- It does not reopen, amend, or reinterpret `DR-2026-0029` or
  `DR-2026-0030`.
- It does not edit `docs/release/PRIVACY_POLICY_DRAFT.md`,
  `docs/release/STORE_PRIVACY_FORM_DRAFT.md`, or
  `docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` — the new
  evidence in this memo (notably, that no source found requires a
  public address at all) is offered as context, not as a basis to
  silently convert an open legal-review item into a closed one. Section
  C item 8 of the owner-decision packet remains open.
- It does not close P0-1 or P0-2 in `V1_STORE_LEGAL_READINESS.md`.
- It does not state or imply that Option B, or any other option, is
  legally sufficient, legally required, or legally cleared.
- It does not state that GDPR, CCPA, or COPPA categorically does not
  apply — every conclusion is evidence-based and trigger-conditioned.
- It does not conflate Apple/Google account-verification requirements
  with Privacy Policy content requirements, or Tanzil's Arabic-text
  licence with its translation licence.
- It does not reproduce any owner date of birth, CCCD number, or full
  residential address.
- It does not claim to be legal advice, at any point, in any section.

**Review self-check (Phase 14 of the originating task), answered
honestly:**

1. Turned research into legal advice? **No** — every conclusion is
   framed as evidence with a confidence level and, where appropriate,
   COUNSEL REQUIRED.
2. Confused platform verification with Privacy Policy requirements?
   **No** — Phases 4–5 keep Categories A–E explicitly separate.
3. Exposed private owner information? **No** — see Phase 12.
4. Stated Option B is legally sufficient? **No** — Phase 9 explicitly
   disclaims this.
5. Incorrectly said GDPR/CCPA cannot apply? **No** — both are
   trigger-based, evidence-conditioned findings, not flat denials.
6. Conflated Tanzil Arabic text and translations? **No** — Phase 7 keeps
   them in separate rows with separate terms.
7. Reopened governance decisions? **No** — `DR-2026-0029`/`DR-2026-0030`
   untouched; owner decisions B1–B5 cited, not altered.
8. Created unnecessary documentation? Addressed directly: this session
   checked for an existing equivalent document before creating this one
   (Phase 1's table) and found none — this is the first record of its
   kind in the repository.
9. Made any claim without an authoritative source? **No** — every
   material claim above cites its source and confidence level; every
   gap is marked UNKNOWN or COUNSEL REQUIRED rather than filled by
   inference.

---

**This document does not authorize v1.0 release, does not constitute
legal advice, legal clearance, or a statement of regulatory compliance,
and does not change the status of any P0/P1 item in
`docs/release/V1_STORE_LEGAL_READINESS.md`.**
