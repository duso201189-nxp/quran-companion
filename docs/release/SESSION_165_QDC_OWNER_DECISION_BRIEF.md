# Session 165 — QDC Transliteration: Owner Decision Brief

**Baseline:** `main` at `b0e27269b376da706edbca06995b89635ea5d4c8`
**Prepared:** 2026-08-29
**Scope:** the Latin transliteration shipped in `assets/database/quran.sqlite`
(`translation_sources.code = 'translit_latin'`).

**`P2-2` = OPEN.**
**Licence = UNKNOWN — COUNSEL REQUIRED.**

> This is a decision instrument, not an evidence packet and not legal
> advice. The evidence sits in
> `docs/release/SESSION_164_QDC_LICENSING_EVIDENCE_PACKET.md`; this brief
> adds no new evidence and no new legal reasoning. It does **not** state
> that the upstream terms govern this dataset, and it does **not** state
> that they do not. It reaches no conclusion about whether redistribution
> may or may not occur. Every interpretive question below is left
> unanswered and referred onward.

---

## 1. Decision required

Session 164 established the facts and left the licence question open. It
did not, and could not, take the two decisions that are the owner's:

| # | Decision | Owner-only because |
|---|---|---|
| **D-A** | Authorise a written enquiry to the operator (`developers@quran.com`), using the question set at §6 | Outbound contact with a third party on the project's behalf |
| **D-B** | Choose the interim product posture — §7 | Product scope, not law |

Secondary decisions carry over unchanged from Session 164 §10: instruct
counsel on the full question set or a subset (**O-1**); route it through
the existing `P0-2` counsel instruction or separately (**O-4**); and
confirm whether the owner has already contacted the operator, which this
repository cannot know either way (**O-5**).

**Nothing in this brief may be sent anywhere without D-A.**

---

## 2. Current FACTS

Established in the repository and unchanged by this brief.

1. The shipped dataset is a Latin transliteration of 6,236 ayah, stored
   under `translation_sources.code = 'translit_latin'`.
2. Its sole retrieval path was
   `https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` with
   `word_fields=transliteration,text_uthmani`, iterating chapters 1–114
   and paginating to exhaustion.
3. Retrieval occurred once, on **2026-07-06**, **unauthenticated** — no
   API key, no OAuth credential, no developer registration.
4. The shipped bytes are a systematically rewritten **derivative**, not a
   verbatim copy: divine-name recapitalisation, hamza and ʿayn
   normalisation, and a minority-spelling pass.
5. The `license` value `UNKNOWN — COUNSEL REQUIRED` in the database is a
   **project-authored string literal**. It is not a statement by any
   upstream party and is not evidence about upstream terms.
6. Quran.com and Quran Foundation, Inc. are the same entity, on the
   operator's own published statement.
7. The dataset did **not** come from QUL. QUL's FAQ is not the governing
   text for it.
8. This repository holds **no** record of outreach to Quran.com or Quran
   Foundation, Inc. — and **no** record that outreach was not made.

---

## 3. Upstream evidence discovered (Session 164)

Two first-party documents published by the operator were located, with
archived captures showing both were in force **before** the 2026-07-06
retrieval:

| Ref | Document | Version in force at retrieval |
|---|---|---|
| **S-2** | Quran.com Terms and Conditions | "Last updated: March 20, 2024" |
| **S-4** | Quran Foundation Developer Terms of Service | "Last updated: 2025-06-13" |

Both were amended **after** the retrieval date (site terms 2026-07-28;
developer terms 2026-08-26), so which version is operative is itself open.
They contain clauses that would bear on bundling, redistribution,
commercial use and modification **if** they were found to reach this
dataset — quoted verbatim at Session 164 §5.1–§5.3, not re-quoted here.

**What neither document contains** — searched and not found:

- Any occurrence of `qurancdn`, or any host, endpoint or API inventory.
- Any occurrence of `translit`, or any mention of word-by-word data.
- Any attribution clause whatsoever.
- Any statement of who authored or owns the transliteration.

The site terms expressly reserve rights to Quran.com "its wholly-owned
subsidiaries, affiliates, **licensors, suppliers or other third
parties**" — so those terms do not themselves establish that the operator
owns this transliteration.

---

## 4. What remains UNKNOWN

The evidence **narrowed** the unknown from "no upstream terms located" to
"candidate terms located, applicability unresolved". It did not close it.

1. **Endpoint identity.** No located first-party document names
   `api.qurancdn.com`. That the operator runs that host is strongly
   indicated by branding and an internal client-ID string — inference,
   not a first-party statement.
2. **Dataset identity.** No located document addresses transliteration or
   word-by-word data.
3. **Acceptance.** Whether unauthenticated retrieval, with no
   registration and no credential, engages the developer terms'
   "By accessing or using the ... APIs ... you ... agree to be bound"
   clause is unresolved.
4. **Ownership.** Even if the terms reach the dataset, they do not
   establish who holds the rights in it, or whether an upstream
   third-party licensor imposes its own conditions.
5. **Operative version.** Which version applies to a copy retrieved once
   and redistributed continuously thereafter is unresolved.
6. **Attribution.** No located document states any attribution
   requirement. Absence of a located requirement is **not** evidence that
   none exists.

None is resolvable by further repository analysis. Items 1–2 and 4 are
answerable by the operator; the rest need legal interpretation.

---

## 5. Exposure if the terms are found to reach this dataset

Conditional, in every line. This section does **not** assert that the
terms reach the dataset, and it does **not** assert that any term has
been engaged.

| If a reviewer finds… | …then the clause bearing on it is | Which touches |
|---|---|---|
| the developer terms reach the endpoint | "QF Content is not resold, sublicensed, or redistributed except as integral to the end-user experience of the Application" | offline bundling of the whole dataset |
| the same | "Cache or store QF Content longer than 1 week unless expressly permitted" | a copy shipped inside an installed app |
| the same | "Attempt to extract, scrape, or index QF Content ... outside the API responses" | the one-time 114-chapter crawl |
| the same | "requires a separate written commercial license agreement" | distribution through commercial app stores |
| the site terms reach the endpoint | "PERSONAL, NON-COMMERCIAL USE ONLY" | the same |
| the same | "will not ... alter, modify, create derivative works from ... any of the Content" | the §2.4 editorial rewriting |

The current developer terms drop the "integral to the end-user experience"
qualifier and add a signed-licence requirement for redistribution "as a
dataset, data feed, API, content package" — a change post-dating the
retrieval, which is why the operative-version question at §4.5 matters.

**No finding of any kind is made here.**

---

## 6. Questions requiring an answer

Drafted so a recipient can answer them **without access to this
repository** — every fact needed is stated inside the question. Context
sentence to accompany the set:

> An open-source Qur'an study application retrieved, once, on 2026-07-06,
> the word-by-word Latin transliteration for all 114 chapters from
> `https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}?words=true&word_fields=transliteration,text_uthmani`,
> without any API key or developer registration. It normalised the
> transliteration's spelling and stores the result in a SQLite database
> shipped inside the installed application for offline use.

| # | Question |
|---|---|
| **Q1** | Do the Quran.com Terms and Conditions, or the Quran Foundation Developer Terms of Service, govern content retrieved from `api.qurancdn.com/api/qdc/`? Neither document names that host. |
| **Q2** | Do those terms govern the word-by-word Latin transliteration returned by that endpoint? Neither document mentions transliteration or word-by-word data. |
| **Q3** | May a project download the complete transliteration dataset for all 114 chapters and bundle it inside a mobile application for offline use? |
| **Q4** | The developer terms list "Cache or store QF Content longer than 1 week unless expressly permitted" under what a developer must not do. How does that bear on a copy shipped permanently inside an installed application rather than held in a server or client cache? |
| **Q5** | The developer terms list "Attempt to extract, scrape, or index QF Content ... outside the API responses" under what a developer must not do. How does that bear on a single one-time paginated retrieval of 114 chapters through the documented endpoint? |
| **Q6** | Which licence or permission governs onward redistribution of the transliteration inside a distributed application? |
| **Q7** | Is attribution required? If so, what exact attribution wording and what exact link must be shown, and where must it appear? |
| **Q8** | May an application containing this dataset be distributed through commercial application stores, including free-of-charge distribution through a store that is itself a commercial channel? |
| **Q9** | Are spelling normalisation, formatting changes, conversion into a database, and other derived works of the transliteration within contemplation, or is written consent needed first? |
| **Q10** | Does any separate Quran.com or QDC data licence exist for this dataset that supersedes or supplements the general Terms and Conditions and the Developer Terms of Service? |
| **Q11** | Who authored the transliteration, and is it held under a third-party licence carrying its own onward conditions? |
| **Q12** | For a dataset retrieved on 2026-07-06 and redistributed thereafter, is the operative text the version in force on that date, or the current version? |

Counsel questions requiring legal construction rather than an operator
statement remain as drafted at Session 164 §9 (**Q-1** … **Q-15**); this
set does not replace them.

---

## 7. Interim recommendation

**Recommended: I-2 + hold, pending D-A.** Reasoning, and its limits:

- **I-2 — name the transliteration source in the in-app attribution
  string.** This is the mechanical half of `P2-2`, is cheap, is
  reversible, and is within the project's sole control. It does **not**
  establish that attribution is owed, does **not** establish its correct
  form, and does **not** close `P2-2`. Naming a source is not evidence of
  a licence.
- **Hold on everything else** — ship nothing new that widens exposure of
  this dataset, and leave the shipped database unchanged, until D-A
  returns an answer or counsel reports.

**Not recommended now, but available and wholly within project control:**
**I-3** replace the transliteration with one whose terms are established;
**I-4** remove it from the shipped database and the Copy/Share payload.
Either removes the open question outright. Both cost user-facing value,
and neither should be taken before D-A has been tried, because an
operator answer may make them unnecessary.

**This recommendation does not resolve `P2-2` and is not a legal
position.**

---

## 8. Current project status

| Item | Status |
|---|---|
| `P2-2` — transliteration not individually named in the attribution string | **OPEN** |
| Licence of the shipped transliteration | **UNKNOWN — COUNSEL REQUIRED** |
| Upstream terms located | Yes — applicability **unresolved** |
| Enquiry to the operator | **Not sent.** Awaiting **D-A** |
| Counsel instruction | Not issued — **O-1**, **O-4** undecided |
| Application code, database, ADR/DR records | Unchanged by this brief |

No clearance of any kind is asserted or implied. This brief does not
clear, and does not block, any release.

---

## 9. Evidence references

**Primary evidence — read this first, this brief is only its front page:**

- `docs/release/SESSION_164_QDC_LICENSING_EVIDENCE_PACKET.md` — §2 dataset
  identity, §3 retrieval path, §5 sources and verbatim clauses, §6
  evidence matrix, §7–§8 what is and is not established, §9 counsel
  questions **Q-1**…**Q-15**, §10 owner decisions **O-1**…**O-5**, §11
  interim options **I-1**…**I-4**, §12 dates.

**Supporting:**

- `docs/release/V1_STORE_LEGAL_READINESS.md` — `P2-2`, `P0-1`, `P0-2`, `P1-4`
- `docs/release/SESSION_146_COPY_SHARE_LICENSING_PACKET.md` — Copy/Share
  questions **C-1**…**C-6**; missing-evidence item **E-1**, superseded only
  as stated at Session 164 §1
- `docs/LICENSING.md` §1 row 2; `docs/release/PRIVACY_POLICY_OWNER_DECISION_PACKET.md` item 5
- `tool/fetch_transliteration.py`, `tool/data/transliteration.json`,
  `tool/build_quran_db.py`, `assets/database/quran.sqlite`

**External sources** are listed with their retrieval dates at Session 164
§14 and are not re-listed here.
