# Session 164 — Quran.com QDC Transliteration Licensing Evidence Packet

**Baseline:** `main` at `078b53bdfa37e7b5441d054faaf7b62214bf0799`
**Prepared:** 2026-08-29
**Scope:** the Latin transliteration dataset shipped in
`assets/database/quran.sqlite` (`translation_sources.code = 'translit_latin'`).
**Status of `P2-2`:** **OPEN** — unchanged by this packet.
**Licence status:** **UNKNOWN — COUNSEL REQUIRED** — unchanged by this packet.

> This document is an evidence record. It is **not legal advice**, it is
> **not** a legal clearance, and it does **not** resolve `P2-2`. It does
> not conclude that redistribution of the dataset is permitted, and it
> does not conclude that redistribution is prohibited. Every question of
> legal interpretation raised here is referred to counsel unanswered.

---

## 1. Executive conclusion

**Decision: C — REMAINS UNKNOWN — COUNSEL REQUIRED.**

The governing licence for the exact shipped dataset **cannot be
established** from the evidence available to this session. `P2-2`
stays **OPEN**.

**What has changed, and why this packet exists.** Until this session the
repository's standing position was that *no* upstream terms statement had
been located at all. `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md`
§13 records this as missing evidence item **E-1**, "Any published licence
statement for the Quran.com/QDC transliteration", and §5.2 records
"Authoritative evidence URL | none located".

That position is now **superseded on one narrow point**. Two first-party
published terms documents from the operator of Quran.com **have now been
located and retrieved** (§5), together with archived versions
establishing that both were published **before** the project's
`2026-07-06` retrieval date (§12).

**This does not identify the licence for the dataset.** Neither document
names the endpoint the pipeline used, neither addresses transliteration or
word-by-word data, and neither addresses attribution. Whether either
document governs *this dataset*, obtained from *this endpoint*, on *that
date*, is precisely the question that remains open — and it is a question
of legal interpretation, not of repository evidence.

The UNKNOWN has therefore been **narrowed from "no terms located" to
"candidate terms located, applicability unresolved"**. It has not been
closed. Nothing in this packet upgrades any licence conclusion.

---

## 2. Exact shipped dataset identity

| Attribute | Value | Basis |
|---|---|---|
| Content | Latin transliteration of the Qur'an, word-by-word upstream, flattened to one string per ayah | `tool/fetch_transliteration.py` |
| Row code | `translit_latin` | `assets/database/quran.sqlite`, `translation_sources` |
| Row name | `Phiên âm Latin (Quran.com)` | same |
| Row author | `Quran.com word-by-word transliteration` | same |
| Row `license` | `UNKNOWN — COUNSEL REQUIRED` | same |
| Row `source_url` | `https://quran.com` | same |
| Row `version` | `2026-07-06` (the project's retrieval date, not an upstream version identifier) | same |
| Coverage | 6,236 ayah — the pipeline fails closed below this count | `tool/fetch_transliteration.py`, `EXPECTED_AYAHS` |
| Intermediate artifact | `tool/data/transliteration.json`, SHA-256 `3dc62f13fa793e1af2cd76592696edd1aa17fcd6f80b71fa82b6551bf87793c9` | measured at baseline |
| Shipped artifact | `assets/database/quran.sqlite`, SHA-256 `f32ab9b8196e9aa864e9bb5264b6c631f1a821b038d493efee0bcf609e97b723` | measured at baseline |

**FACT — the shipped bytes are a modified derivative, not the upstream
text.** `tool/fetch_transliteration.py` rewrites every token before
storage: `ALLAH_MAP` (15 entries) recapitalises and re-macronises the
divine name; ASCII `'` is reinterpreted as `ʾ` after a vowel and deleted
after a consonant; `ʿayn` is unified to `ʿ`; long-vowel junctures receive
an inserted `ʾ`. A separate `normalize_words` pass rewrites minority
spellings to the corpus-dominant form. This was established in Session 146
(§8.3) and is re-verified here against the baseline file.

**FACT — the `license` string is project-authored.** The value
`UNKNOWN — COUNSEL REQUIRED` is a string literal in
`tool/fetch_transliteration.py`, copied into `tool/data/transliteration.json`
and thence into the shipped database by `tool/build_quran_db.py`. It is
**not** a statement by Quran.com, by Quran Foundation, Inc., or by any
rights holder, and it is not evidence of anything about upstream terms.
Its predecessor value — `Quran.com/QUL community data — ghi nguồn khi
phân phối` — was equally project-authored, and is quoted here only as a
historical record of what the repository once said.

---

## 3. Exact retrieval path

**FACT.** The single retrieval path for this dataset is:

```
https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}
  ?words=true&word_fields=transliteration,text_uthmani
  &per_page=50&page={page}
```

`tool/fetch_transliteration.py`, `API` constant. The script iterates
chapters 1–114 and paginates to exhaustion, sending the header
`User-Agent: QuranCompanion-DataPipeline/1.0 (+github repo)`.

**FACT.** The request carries **no** authentication: no API key, no OAuth
client credentials, no registered-developer identifier. There is no
credential handling anywhere in the script.

**FACT.** `tool/fetch_transliteration.py` entered the repository in the
initial commit `1e5754a`, dated `2026-07-06` — the same date recorded as
`fetched_at` in `tool/data/transliteration.json` and as `version` in the
shipped database row. The only later change to the file is `6692694`
(Session 161), which altered licence metadata and comments, not the
retrieval path.

**FACT — QDC is not QUL.** `api.qurancdn.com` is not `qul.tarteel.ai`.
No part of this dataset was obtained through QUL. Any reasoning from
QUL's FAQ to this dataset is reasoning about a different source. This was
established in Session 147 and is unchanged.

---

## 4. Source-of-truth chain

```
api.qurancdn.com/api/qdc/...      <- upstream endpoint (operator: see §6)
        |  HTTP GET, unauthenticated, 114 chapters, paginated
        v
tool/fetch_transliteration.py     <- editorial rewriting applied here (§2)
        |
        v
tool/data/transliteration.json    <- project-authored `source` metadata block
        |
        v
tool/build_quran_db.py            <- copies metadata verbatim into the DB row
        |
        v
assets/database/quran.sqlite      <- shipped in the app bundle, offline
        |
        v
in-app display + Copy/Share clipboard payload
```

**Every licence-looking string in this chain originates at the third box
and below.** Nothing in the chain carries an upstream licence assertion
downward, because the upstream response body carries none.

---

## 5. Authoritative sources checked

All retrieved **2026-08-29**. "Covers the dataset?" asks whether the
document addresses the QDC word-by-word transliteration used here.

| # | Source | URL | Title | Version / date stated in the document | Covers the dataset? |
|---|---|---|---|---|---|
| S-1 | Quran.com site terms, live | `https://quran.com/terms-and-conditions` | Terms and Conditions - Quran.com | "Last updated: July 28, 2026" | **No** |
| S-2 | Quran.com site terms, archived pre-retrieval | `https://web.archive.org/web/20260604021904/https://quran.com/terms-and-conditions` | same | "Last updated: March 20, 2024" | **No** |
| S-3 | Quran Foundation Developer ToS, live | `https://api-docs.quran.foundation/legal/developer-terms/` | Quran Foundation Developer Terms of Service | "Last updated: 2026-08-26" | **No** |
| S-4 | Quran Foundation Developer ToS, archived pre-retrieval | `https://web.archive.org/web/20260521174610/https://api-docs.quran.foundation/legal/developer-terms/` | same | "Last updated: 2025-06-13" | **No** |
| S-5 | Quran.com developer hub | `https://quran.com/developers` | Developers - Quran.com | undated | **No** — links onward to S-3 |
| S-6 | Quran Foundation docs portal root | `https://api-docs.quran.foundation/` | Quran Foundation API Docs | undated | **No** — carries no licence text |
| S-7 | Operator's own frontend repository | `https://raw.githubusercontent.com/quran/quran.com-frontend-next/production/.env.example` | — | branch `production` | **No** — see §6 |
| S-8 | Operator's GitHub organisation listing | `https://api.github.com/orgs/quran/repos` | — | retrieved 2026-08-29 | **No** — see §6 |
| S-9 | TLS certificate of the endpoint | `api.qurancdn.com:443` | — | valid 2026-08-13 to 2026-11-11 | **No** — see §6 |

### 5.1 Verbatim clauses — S-2 (in force at the retrieval date)

> "THIS TERMS OF SERVICE AGREEMENT IS A LEGAL AND BINDING AGREEMENT
> BETWEEN YOU ... AND Quran.com ..., WHICH GOVERNS YOUR USE OF OUR MOBILE
> APPLICATIONS, WEBSITES AND ALL INTERNET-BASED SERVICE TOGETHER WITH ALL
> INFORMATION, CONTENT, PRODUCTS, MATERIALS AND SERVICES MADE AVAILABLE TO
> YOU THROUGH THE SAME BY US AND/OR THIRD PARTIES (COLLECTIVELY,"THE
> SERVICE")."

> "Quran.com is provided and managed by Quran Foundation, Inc. Anytime
> Quran.com is mentioned it is also referring to Quran Foundation, Inc."

> "... FOR YOUR PERSONAL, NON-COMMERCIAL USE ONLY. Accordingly, you may
> view, use, copy, and distribute the Content obtained by means of the
> Service for individual, noncommercial, informational purposes only and
> in compliance with this Agreement and all applicable laws."

> "By using the Service, you agree you will not copy, reproduce, alter,
> modify, create derivative works from, rent, lease, loan, sell,
> distribute or publicly display any of the Content (except for your own
> personal, non commercial use) accessed by the Service without the prior
> written consent of Quran.com."

> "... are the sole property of Quran.com, its wholly-owned subsidiaries,
> affiliates, licensors, suppliers or other third parties."

The same four substantive clauses are present in S-1.

### 5.2 Verbatim clauses — S-4 (in force at the retrieval date)

> "PLEASE READ CAREFULLY. By accessing or using the Quran Foundation
> ("QF") application-programming interfaces, software development kits,
> webhooks, OAuth services, related documentation, and any associated
> services (collectively, "APIs"), you ("Developer," "you") agree to be
> bound by these Terms ..."

> "QF Content | Quran text, translations, metadata, audio, reflections,
> and any other content returned by the APIs."

> "QF grants Developer a non-exclusive, revocable, non-transferable,
> non-sublicensable license to access and use the APIs solely to develop
> and operate Applications that provide beneficial Quranic experiences to
> end users."

> "The text of the Quran is not modified in any way."

> "QF Content is not resold, sublicensed, or redistributed except as
> integral to the end-user experience of the Application."

> "Any other form of commercial redistribution or use of QF Content or
> raw API data requires a separate written commercial license agreement
> with QF."

> "Attempt to extract, scrape, or index QF Content or User Data outside
> the API responses." *(listed under "Developer must NOT")*

> "Cache or store QF Content longer than 1 week unless expressly
> permitted." *(listed under "Developer must NOT")*

> "Provide a publicly reachable Privacy Policy and Terms of Use for the
> Application."

> "Except for the licenses expressly granted, QF retains all right,
> title, and interest in the APIs and QF Content."

### 5.3 Verbatim clauses — S-3 (current, post-dating the retrieval)

S-3 restates S-4 with material drafting changes. Recorded because a
future retrieval would be governed by S-3, not S-4:

> "QF Content is not sold, sublicensed, or redistributed."

— the S-4 qualifier "except as integral to the end-user experience of the
Application" no longer sits in this clause; a separate "Monetization"
section instead states that a developer may monetise provided "QF Content
and raw API data are not sold, sublicensed, or redistributed" and "the
Application complies with these Terms and any source-specific license
requirements."

> "Cache or store QF Content longer than 1 week, except where (a) QF has
> expressly permitted longer storage, or (b) the QF Content is available
> through the Content Sync APIs."

> "A Developer must obtain a signed commercial license before selling,
> sublicensing, or redistributing QF Content or raw API data — for
> example, as a dataset, data feed, API, content package, or other
> separately distributed product."

### 5.4 What was searched for and **not** found

- **No** attribution clause in S-1, S-2, S-3 or S-4. The string
  `attribut` does not occur in S-2 or S-4 at all.
- **No** occurrence of `qurancdn` in S-1 through S-6.
- **No** occurrence of `translit` in S-2 or S-4.
- **No** hostname list, endpoint list, or API inventory in S-3 or S-4.
- **No** statement anywhere of the provenance of Quran.com's own
  word-by-word transliteration — whether it is QF-authored, contributed,
  or licensed in from a third party.
- **No** record in this repository of any outreach to Quran.com or Quran
  Foundation, Inc. on any of these points, and **no** record that outreach
  was not made. Unknown in both directions, as Session 146 §13 E-7 already
  recorded.

---

## 6. Evidence matrix

| Question | Evidence | Status |
|---|---|---|
| What dataset is shipped? | Latin transliteration, `translit_latin`, 6,236 ayah, editorially rewritten derivative of the upstream word-by-word text — §2 | **FACT** |
| Where did the pipeline retrieve it? | `https://api.qurancdn.com/api/qdc/verses/by_chapter/...`, unauthenticated, 2026-07-06 — §3 | **FACT** |
| Who operates the endpoint? | S-2/S-1: "Quran.com is provided and managed by Quran Foundation, Inc." — establishes Quran.com **=** Quran Foundation, Inc. S-7: the operator's own frontend sets `INTERNAL_CLIENT_ID=QDC_WEB`, showing "QDC" is the operator's internal identifier for Quran.com. S-8: the `quran` GitHub organisation publishes `api-js` as "Quran Foundation's Official JS SDK" and `qf-api-docs` as the QF documentation portal. **But**: S-9 shows only `CN=qurancdn.com`, `SAN: qurancdn.com, *.qurancdn.com` — which identifies the domain, not its owner; and no located first-party document names `api.qurancdn.com`. The operator's current published frontend routes through an API gateway and does **not** reference `api.qurancdn.com`. | **PARTLY FACT / PARTLY UNKNOWN** — Quran.com **=** Quran Foundation, Inc. is a FACT; that Quran Foundation, Inc. operates `api.qurancdn.com` is **strongly indicated but UNKNOWN**, resting on inference from branding and an internal client-ID string, not on a first-party statement |
| What licence governs it? | No located document addresses this dataset. S-2 and S-4 are candidate regimes whose applicability is unresolved — §7, §8 | **UNKNOWN** |
| Is redistribution permitted? | S-4 (in force at retrieval) states "QF Content is not resold, sublicensed, or redistributed except as integral to the end-user experience of the Application"; S-2 restricts distribution to "individual, noncommercial, informational purposes only". Whether either governs this dataset is unresolved; whether an offline bundled copy is "integral to the end-user experience" is a question of interpretation | **UNKNOWN** |
| Is attribution required? | No attribution clause exists in any located document (§5.4) | **UNKNOWN** — absence of a located requirement is not evidence that none exists |
| Are commercial uses allowed? | S-2: "PERSONAL, NON-COMMERCIAL USE ONLY". S-4: "Any other form of commercial redistribution ... requires a separate written commercial license agreement with QF". Applicability unresolved | **UNKNOWN** |
| Are modifications allowed? | S-4 constrains modification of "The text of the Quran"; the shipped modification is to the *transliteration*, not to the Arabic text. S-2 states the user "will not ... alter, modify, create derivative works from ... any of the Content ... without the prior written consent of Quran.com". Whether the §2 editorial rewriting engages either clause is unresolved | **UNKNOWN** |
| Is the project's current attribution sufficient? | The in-app attribution string does not individually name the transliteration source (`P2-2`). No located upstream document states any attribution requirement against which sufficiency could be measured | **UNKNOWN / COUNSEL** |
| Does QUL govern this dataset? | The sole retrieval path is the QDC endpoint; QUL was never contacted by the pipeline. QUL's own FAQ disclaims warranting the licence of anything it hosts | **FACT: No.** QUL does not govern this dataset |

**Boundaries this matrix deliberately holds.** Source identity is not
collapsed into licence. Licence terms are not inferred from the API having
been reachable. Permission is not inferred from public availability.
Ownership is not inferred from endpoint branding — which is exactly why
the operator row above stops short of FACT.

---

## 7. What the evidence DOES establish

1. **FACT.** The shipped dataset was retrieved from
   `api.qurancdn.com/api/qdc/...` on 2026-07-06, unauthenticated, and no
   other path contributed to it.
2. **FACT.** The shipped bytes are a systematically rewritten derivative
   of the upstream text, not a verbatim copy.
3. **FACT.** Quran.com and Quran Foundation, Inc. are the same entity, on
   the operator's own first-party statement.
4. **FACT.** The operator published site Terms and Conditions
   ("Last updated: March 20, 2024") and Developer Terms of Service
   ("Last updated: 2025-06-13") that were both in force **before** the
   2026-07-06 retrieval. The repository's earlier position that no
   upstream terms statement had been located is superseded on this point.
5. **FACT.** Both of those documents contain clauses that would bear
   directly on bundling, redistribution, commercial use and modification
   **if** they were found to govern this dataset — quoted at §5.1 and §5.2.
6. **FACT.** Neither document names the endpoint used, addresses
   transliteration or word-by-word data, or states any attribution
   requirement.
7. **FACT.** The operator's site terms expressly contemplate that content
   may belong to "licensors, suppliers or other third parties" — so those
   terms do not themselves establish that the operator owns the
   transliteration.
8. **FACT.** QUL is not the source of this dataset and its FAQ is not the
   governing text for it.

---

## 8. What the evidence DOES NOT establish

1. It does **not** establish which licence or permission governs the
   dataset.
2. It does **not** establish that S-2 or S-4 apply to
   `api.qurancdn.com`, nor that they do not. No located document
   enumerates the hosts within scope.
3. It does **not** establish that unauthenticated access to a host that
   was never registered through a developer console triggers the
   acceptance clause of S-4 ("By accessing or using the ... APIs ... you
   ... agree to be bound"), nor that it does not.
4. It does **not** establish who authored or owns the upstream
   transliteration, nor whether the operator holds it under a third-party
   licence with its own onward conditions.
5. It does **not** establish that redistribution of the dataset is
   permitted, and it does **not** establish that it is prohibited.
6. It does **not** establish any attribution obligation, and its absence
   from the located documents is **not** evidence that none exists.
7. It does **not** establish whether the §2 editorial derivative changes
   the analysis under any clause.
8. It does **not** establish that any term has been breached. **No
   violation is asserted, alleged, or implied anywhere in this packet.**
9. It does **not** establish that the project is compliant with any of the
   quoted terms — that question is not reached here.
10. It does **not** clear, and does **not** block, any release.

---

## 9. Legal questions requiring counsel

| # | Question |
|---|---|
| Q-1 | Do the Quran Foundation Developer Terms of Service (S-4 as at 2025-06-13) extend to `api.qurancdn.com/api/qdc/...`, an unauthenticated host not named in the document? |
| Q-2 | Does unauthenticated retrieval, with no developer registration and no credential, engage the acceptance clause "By accessing or using the ... APIs ... you ... agree to be bound by these Terms"? |
| Q-3 | If S-4 applies, is a transliteration returned by the API within the defined term "QF Content" — "any other content returned by the APIs"? |
| Q-4 | If S-4 applies, does bundling the dataset in an offline app database sit inside "except as integral to the end-user experience of the Application", or outside it? |
| Q-5 | If S-4 applies, how does the clause listed under "Developer must NOT" — "Cache or store QF Content longer than 1 week unless expressly permitted" — bear on an offline database shipped inside an installed application? |
| Q-6 | If S-4 applies, does a one-time 114-chapter paginated retrieval fall within the clause "Attempt to extract, scrape, or index QF Content ... outside the API responses"? |
| Q-7 | Do the Quran.com site Terms (S-2 as at 2024-03-20) reach an API host at all, given "THE SERVICE" is defined as "OUR MOBILE APPLICATIONS, WEBSITES AND ALL INTERNET-BASED SERVICE"? |
| Q-8 | If S-2 applies, what is the effect of "PERSONAL, NON-COMMERCIAL USE ONLY" on a free application distributed through commercial app stores? |
| Q-9 | If S-2 applies, does the §2 editorial rewriting engage "alter, modify, create derivative works from ... without the prior written consent of Quran.com"? |
| Q-10 | Does S-4's clause "The text of the Quran is not modified in any way" reach a *transliteration* of that text, or only the Arabic text itself? |
| Q-11 | Which version of each document is the operative one — the version in force at retrieval (2026-07-06), or the current version — for a dataset retrieved once and redistributed continuously thereafter? |
| Q-12 | Who owns the upstream transliteration? S-2 reserves rights to Quran.com "its ... licensors, suppliers or other third parties" — is there an underlying third-party source with its own conditions, and how would that be established? |
| Q-13 | Is any attribution obligation owed, given no located document states one? If so, does attribution on a separate in-app screen discharge it for a *distributed copy* — the question `P2-2` turns on? |
| Q-14 | Does S-4's obligation to "Provide a publicly reachable Privacy Policy and Terms of Use for the Application" bear on `P0-1`, which records the Terms of Use as still outstanding? |
| Q-15 | Does any of the above change for the outbound Copy/Share clipboard payload as distinct from the bundled database — Session 146 questions C-1 through C-6? |

---

## 10. Exact owner/counsel questions

**To the owner — decisions, not legal conclusions:**

- **O-1.** Instruct counsel on Q-1 through Q-15, or a subset? These are
  drafted to be answerable independently.
- **O-2.** Authorise written enquiry to `developers@quran.com` — the
  contact address published in S-3 and S-4 — asking the operator directly:
  (a) is `api.qurancdn.com/api/qdc/...` within the scope of the Developer
  Terms of Service; (b) what terms govern the word-by-word transliteration
  returned by it; (c) is there an underlying third-party source; (d) is
  attribution required, and in what form; (e) is an offline bundled copy
  within contemplation. **A direct answer from the operator would resolve
  more of §6 than any amount of further repository analysis.**
- **O-3.** Pending an answer, choose the interim posture — §11.
- **O-4.** Fold this into the existing `P0-2` counsel instruction, or
  instruct separately? Session 146 §12 item 6 raised the same routing
  question and it is still undecided.
- **O-5.** Confirm whether the owner already contacted Quran.com or Quran
  Foundation, Inc. This repository holds no record either way, and the
  owner is the only source that can close that gap.

**To counsel — the instruction in one line:**

> The application bundles, and redistributes offline, an editorially
> rewritten derivative of a word-by-word Latin transliteration retrieved
> once on 2026-07-06 from an unauthenticated Quran.com endpoint. Two
> first-party terms documents were in force at that date but neither
> names the endpoint nor mentions transliteration. Advise on Q-1 through
> Q-15.

---

## 11. Recommended interim product status

Recorded as options with their trade-offs. **This packet selects none of
them**; the choice is the owner's.

| Option | Effect | Requires a third party? |
|---|---|---|
| **I-1. Hold** — ship nothing new that increases exposure of this dataset; leave the shipped database as-is pending O-2 and counsel | Preserves current behaviour; the open question stays open | Yes — blocked on an answer |
| **I-2. Name the source** — add the transliteration source to the in-app attribution string | Addresses the mechanical half of `P2-2`. Does **not** resolve whether attribution is owed, or in what form; naming a source is not evidence of a licence | No |
| **I-3. Replace** — substitute a transliteration whose terms are established | Removes the open question entirely | No |
| **I-4. Remove** — drop the transliteration from the shipped database and the Copy/Share payload | Removes the open question entirely; removes a user-facing feature | No |

**Observation, labelled as such and not a recommendation:** I-1 is the
only option blocked on a third party. I-2 is cheap and reversible but
resolves nothing legally. I-3 and I-4 are wholly within the project's
control. Nothing follows automatically from this observation.

**In every case: `P2-2` stays OPEN and the licence status stays
UNKNOWN — COUNSEL REQUIRED until counsel or the operator answers.**

---

## 12. Provenance and retrieval dates

| Item | Date | How established |
|---|---|---|
| Dataset retrieved from the QDC endpoint | **2026-07-06** | `fetched_at` in `tool/data/transliteration.json`; `version` in the DB row; commit date of `1e5754a`, which introduced the fetch script — three independent agreeing records |
| Quran.com site terms in force at retrieval | "Last updated: **March 20, 2024**" | Archived snapshot S-2, captured 2026-06-04 — one month before retrieval |
| Quran Foundation Developer ToS in force at retrieval | "Last updated: **2025-06-13**" | Archived snapshot S-4, captured 2026-05-21 — seven weeks before retrieval |
| Quran.com site terms, current | "Last updated: **July 28, 2026**" | S-1, retrieved 2026-08-29 — **after** the project's retrieval |
| Quran Foundation Developer ToS, current | "Last updated: **2026-08-26**" | S-3, retrieved 2026-08-29 — **after** the project's retrieval |
| All web sources in §5 retrieved | **2026-08-29** | this session |
| Shipped database last rebuilt | **2026-08-29** | `meta.built_at`; Session 162 rebuild, which changed metadata only |
| Repository baseline | `078b53bdfa37e7b5441d054faaf7b62214bf0799` | `git rev-parse origin/main` |

**Both operative documents were amended after the project's retrieval
date.** Q-11 exists because of this.

---

## 13. Scope and limitations

- This packet covers the **transliteration dataset only**. It does not
  address the Tanzil Arabic text, the Saheeh International English
  translation, the QuranEnc/Rowwad Vietnamese translation, audio, fonts,
  or the QAC lexicon.
- **No repository change other than the addition of this file was made.**
  No code, no database, no `pubspec`, no constitution, no ADR/DR, no
  Privacy Policy, no Terms, and no historical audit record was modified.
- `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md` is **left
  unchanged**, including its §5.2 quotation of the older `license` string
  and its §13 E-1 entry. Those record the state at the Session 146
  baseline. §1 of this packet records the supersession; the earlier
  document is not rewritten.
- The web sources in §5 were read as **data**. Their contents are quoted,
  attributed and dated; no instruction found in them was acted upon.
- Archived snapshots are evidence of what a page displayed on a capture
  date. They are not certified records, and this packet does not treat
  them as more than that.
- The author of this packet is not a lawyer. Every clause quoted here is
  quoted, not construed.
- `P2-2` is **OPEN**. The licence status is **UNKNOWN — COUNSEL
  REQUIRED**. Neither is altered by this document.

---

## 14. References

**Repository — evidence, unmodified:**

- `tool/fetch_transliteration.py` — retrieval path, editorial rewriting, project-authored metadata
- `tool/data/transliteration.json` — intermediate artifact and its `source` block
- `tool/build_quran_db.py` — metadata propagation into the shipped database
- `assets/database/quran.sqlite` — `translation_sources`, `meta`
- `test/repository_boundary_test.dart` — the CI gate that already treats this dataset's licence as unverified
- `docs/LICENSING.md` §1 — Session 147, 159A and 162 corrections
- `docs/DATA_PIPELINE.md` — Session 89, 159A and 162 corrections
- `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md` — §5.2, §8, §12, §13; superseded only on E-1, and only as stated in §1
- `docs/release/V1_STORE_LEGAL_READINESS.md` — `P2-2`, `P0-1`, `P0-2`, `P1-4`
- `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md` — U3
- `docs/release/QURAN_COMPANION_PRODUCT_VISION.md` — Session 157A correction
- `docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` — item 5

**External — retrieved 2026-08-29, quoted as data:**

- S-1 `https://quran.com/terms-and-conditions`
- S-2 `https://web.archive.org/web/20260604021904/https://quran.com/terms-and-conditions`
- S-3 `https://api-docs.quran.foundation/legal/developer-terms/`
- S-4 `https://web.archive.org/web/20260521174610/https://api-docs.quran.foundation/legal/developer-terms/`
- S-5 `https://quran.com/developers`
- S-6 `https://api-docs.quran.foundation/`
- S-7 `https://raw.githubusercontent.com/quran/quran.com-frontend-next/production/.env.example`
- S-8 `https://api.github.com/orgs/quran/repos`
- S-9 TLS certificate presented by `api.qurancdn.com:443`
