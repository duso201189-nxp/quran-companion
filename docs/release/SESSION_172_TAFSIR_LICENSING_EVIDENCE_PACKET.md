# Session 172 — Tafsir Licensing Evidence Packet

**Baseline:** `main` at `6ca99bfbe1b332ad73bacc320d293bd66af12130`
**Prepared:** 2026-08-29
**Scope:** the two tafsir datasets proposed on the closed branch
`sprint1-my-library` (PR #1) — `tafsir_ar-tafsir-muyassar.json` and
`tafsir_en-tafsir-ibn-kathir.json` — and the Study Workspace feature
that renders them.
**Licence status:** **UNKNOWN — COUNSEL REQUIRED** for both datasets.
Neither dataset is on `main`; this packet changes nothing that `main`
ships.

> This document is an evidence record. It is **not legal advice**, it is
> **not** a legal clearance, and it resolves nothing. It does not
> conclude that redistribution of either dataset is permitted, and it
> does not conclude that redistribution is prohibited. It asserts no
> breach of any term by anyone. Every question of legal interpretation
> raised here is referred onward unanswered.

---

## 1. Executive conclusion

**Decision: C — LICENCE APPLICABILITY REMAINS UNKNOWN — COUNSEL
REQUIRED**, for both datasets, on independent grounds for each.

**What is materially new in this session, and why this packet exists.**

`docs/LICENSING.md` rows 5 and 6 record both tafsir datasets as obtained
"**(qua QUL)**" — via QUL — and its §1 sub-section "Truy ngược từng bộ"
frames the QUL FAQ as the terms document to reason from for them,
expressly exempting only the Latin transliteration from that framing
(lines 126–127). **That attribution is not supported by the retrieval
code.** The sole retrieval path for both datasets is
`tool/fetch_tafsir.py`, which contacts `api.quran.com` and
`api.qurancdn.com` and never contacts QUL (§3). This is the same
mis-attribution Session 147 corrected for the transliteration; it was
not carried across to the tafsir rows.

The consequence is not cosmetic. It moves both datasets out of the QUL
FAQ regime — the only upstream terms text `docs/LICENSING.md` quotes for
them — and into the **same unresolved QDC regime** that Session 164
documented for the transliteration, where `P2-2` sits open. The two
datasets do not thereby become better or worse placed; the terms that
were being reasoned from were simply the wrong ones.

Second, this session establishes for the first time that **no upstream
surface carries any licence assertion for these datasets at all**: not
the catalogue endpoint, not the content endpoint, not Quran Foundation's
own tafsir API documentation (§5). Every licence-looking string attached
to these datasets in PR #1 is project-authored (§4).

Third, the two datasets differ from the transliteration in a way that
matters and is now on first-party record: **each has an identified
third-party rights holder upstream of Quran.com** — Dar-us-Salam for the
abridged English Ibn Kathir, the King Fahd Glorious Qur'an Printing
Complex for Al-Muyassar (§6, §7). Whatever the QDC regime turns out to
permit, no located document shows either rights holder granting
anything, and Dar-us-Salam's own published terms grant nothing as to the
text of the books it publishes (§6.2).

**Nothing here upgrades or downgrades any licence conclusion.** The
UNKNOWN is narrowed on *which terms are even candidates* and on *who the
rights holders are*. It is not closed.

---

## 2. Ground truth at the time of writing

| Item | Value | Basis |
|---|---|---|
| `origin/main` | `6ca99bfbe1b332ad73bacc320d293bd66af12130` | `git rev-parse` |
| Open PRs | none (0) | `gh pr list --state open` |
| PR #1 state | `CLOSED`, `mergedAt: null`, `mergeCommit: null` | `gh pr view 1` |
| PR #1 head | `11d6176618aa6c7799a298efbc17e5c3e80f1419` | same |
| PR #1 head is an ancestor of `main`? | **No** | `git merge-base --is-ancestor` |
| Merge base | `b64a235c60c1b0be2327ad3451300ec4219953dd` | `git merge-base` |
| Commits on PR #1 not on `main` | 23 | `git log 6ca99bf..11d6176` |
| Branch `sprint1-my-library` | present on `origin` at the PR head | `git ls-remote` |
| Shipped DB on `main` | SHA-256 `f32ab9b8196e9aa864e9bb5264b6c631f1a821b038d493efee0bcf609e97b723` | measured; identical to the Session 164 baseline |

**FACT.** No new PR has appeared that bears on the tafsir decision.

---

## 3. Exact dataset identity and retrieval path

### 3.1 Inventory

| Dataset | Author field as recorded | Publisher / rights holder (§6, §7) | Retrieval path | Proposed storage | Attribution recorded | Licence evidence | On `main`? |
|---|---|---|---|---|---|---|---|
| Tafsir Muyassar (`ar-tafsir-muyassar`, upstream id 16) | `المیسر` — the **title of the work**, not an author; spelled with Persian ی U+06CC | نخبة من العلماء, published by مجمع الملك فهد لطباعة المصحف الشريف (KFGQPC) | `api.qurancdn.com/api/qdc/tafsirs/16/by_chapter/{1..114}` | `translation_sources` row + 5,278 `translations` rows | `author='المیسر'`, `source_url` 404s | **none upstream**; the recorded string is project-authored | **No** |
| Ibn Kathir (Abridged) (`en-tafsir-ibn-kathir`, upstream id 169, upstream slug `en-tafisr-ibn-kathir`) | `Hafiz Ibn Kathir` — the 14th-century author of the **original**, not the rights holder of the abridged translation | Dar-us-Salam / Darussalam, 2nd edn July 2003 | `api.qurancdn.com/api/qdc/tafsirs/169/by_chapter/{1..114}` | `translation_sources` row + 1,895 `translations` rows | `author='Hafiz Ibn Kathir'`, `source_url` 404s | **none upstream**; the recorded string is project-authored | **No** |

Artifact identities, measured at PR #1 head:

| Artifact | SHA-256 |
|---|---|
| `tool/data/tafsir_ar-tafsir-muyassar.json` (2,073,896 bytes) | `ee9417bb6d948aa0d065d69878ef415e7b407429cb8fcd8b7cd62b41126d76e2` |
| `tool/data/tafsir_en-tafsir-ibn-kathir.json` (10,555,494 bytes) | `4984b60fd894fdf4ba551b60fe2728d50110fd7b39da3ebd0fa7970ccc3827dc` |
| `tool/fetch_tafsir.py` | `2a44b08c2863db01a7713d4b9fb5c55256cba5ba2118696c41ca1322b0892279` |
| `assets/database/quran.sqlite` at PR #1 head (34,295,808 bytes) | `8bc873c0d89ff421d6036e3cfd2511fb48607ca228216d421b3f6c0aebb55965` |

### 3.2 The retrieval path — FACT

`tool/fetch_tafsir.py` uses exactly two hosts:

```
https://api.quran.com/api/v4/resources/tafsirs           <- catalogue metadata
https://api.qurancdn.com/api/qdc/tafsirs/{id}/by_chapter/{n}?per_page=300
                                                          <- the text itself
```

Requests are unauthenticated — no API key, no OAuth credential, no
registered-developer identifier anywhere in the script. The only header
sent is `User-Agent: QuranCompanion-DataPipeline/1.0 (+github repo)`.
The script iterates chapters 1–114 once.

**FACT — QDC is not QUL, for the tafsir datasets too.** Across the
entire PR #1 tree, the only file that mentions `qul.tarteel` at all is
`docs/LICENSING.md` itself. No script, no data file, and no code path in
PR #1 contacts QUL. The word "QUL" appears in `tool/fetch_tafsir.py`
only in the module docstring (line 2), in an explanatory comment (line
17), and inside the project-authored `license` string (line 182) — as
prose, never as an endpoint.

**INFERENCE, not established.** Whether Quran.com's own tafsir corpus was
itself ingested from QUL at some earlier point is **UNKNOWN**. Nothing
in this repository or in any located upstream document speaks to it, and
it must not be assumed in either direction.

### 3.3 Retrieval date — FACT

Both datasets record `fetched_at: 2026-07-25`. The single commit that
introduced them, `2fb5fd5` "Sprint 31.4: second real tafsir import and
production validation", is dated `2026-07-25`. The `version` column of
both `translation_sources` rows is `2026-07-25` — the project's
retrieval date, not an upstream version identifier.

This is **19 days later** than the `2026-07-06` transliteration
retrieval that Session 164 analysed. The date analysis is therefore not
inherited; it is redone at §8.

### 3.4 Transformation — FACT

`strip_markup()` rewrites every record before storage: `<br>`, `</p>`,
`</div>`, `</h1..6>` and `</li>` become newlines; all remaining HTML
tags are removed; HTML entities are unescaped; runs of spaces and tabs
are collapsed; leading and trailing whitespace per line is stripped; runs
of blank lines are collapsed to at most one. The stored bytes are
therefore **not** a verbatim copy of the upstream response body.

This is format normalisation, and is **narrower** than the editorial
rewriting Session 164 documented for the transliteration (`ALLAH_MAP`,
`normalize_words`). It is recorded because "is this a derivative work"
is a question for counsel, not a question this repository can answer,
and the honest input to that question is the exact set of operations
above.

A second derivation happens at **query** time, not build time. Upstream
attaches a passage commentary to the first ayah of a multi-ayah range;
`getTextsCoveringAyah` in PR #1 re-maps a stored record onto every ayah
the passage covers. The comment at `tafsir_section.dart` records that
exact-key matching would have missed 945 ayahs with real commentary.
The **presentation** mapping is therefore project-authored too.

### 3.5 Coverage — FACT

| Dataset | Ayahs with text | Of 6,236 | Empty from source | Chapters with gaps |
|---|---|---|---|---|
| Al-Muyassar | 5,278 | 84.6% | 0 | 80 (958 ayahs) |
| Ibn Kathir (Abridged) | 1,895 | 30.4% | 4,341 | 0 |

Ibn Kathir's 4,341 "empty from source" records are the passage-mapping
artefact described in §3.4, not missing data.

---

## 4. Every licence string in the chain is project-authored — FACT

```
api.qurancdn.com/api/qdc/tafsirs/...   <- carries NO licence field (§5)
        |  HTTP GET, unauthenticated, 114 chapters, 2026-07-25
        v
tool/fetch_tafsir.py                   <- the licence string is WRITTEN HERE
        |
        v
tool/data/tafsir_*.json                <- project-authored `meta.license`
        |
        v
tool/build_quran_db.py                 <- copies it verbatim into the DB row
        |
        v
assets/database/quran.sqlite           <- shipped offline in the app bundle
        |
        v
AttributionScreen                      <- displays it to the user as the
                                          source's licence (§9.3)
```

The string, in full, is a literal at `tool/fetch_tafsir.py:182`:

> `Quran.com/QUL community data — ghi nguồn khi phân phối; kiểm tra điều
> khoản trước khi phát hành thương mại`

("Quran.com/QUL community data — cite the source when distributing;
check the terms before commercial release.")

**FACT.** It is a project-authored note-to-self. It is **not** a
statement by Quran.com, by Quran Foundation, Inc., by QUL, by
Dar-us-Salam, or by KFGQPC, and it is not evidence of anything about
upstream terms. On its own face it records that the terms had **not**
been checked.

**FACT — `source_url` is project-constructed and does not resolve.**
`tool/fetch_tafsir.py:181` synthesises `https://quran.com/tafsirs/{slug}`
from the local slug. All three variants return **HTTP 404** when
retrieved on 2026-08-29:

| URL | Status |
|---|---|
| `https://quran.com/tafsirs/ar-tafsir-muyassar` | 404 |
| `https://quran.com/tafsirs/en-tafsir-ibn-kathir` (project slug) | 404 |
| `https://quran.com/tafsirs/en-tafisr-ibn-kathir` (upstream slug) | 404 |

`https://quran.com/terms-and-conditions` was retrieved successfully in
the same session, so the 404s are the URL pattern, not reachability.

**FACT — the dataset identifier does not match upstream.** The upstream
catalogue gives id 169 the slug `en-tafisr-ibn-kathir` (upstream
misspelling). PR #1 overrode it to `en-tafsir-ibn-kathir` via the
`--slug` flag. Any enquiry to a rights holder or to the operator must
name **id 169** and the upstream slug, not the repository's filename.

---

## 5. Authoritative upstream sources checked

All retrieved **2026-08-29**. "Covers the dataset?" asks whether the
document addresses the QDC tafsir data used here.

| # | Source | URL | Stated version / date | Covers the dataset? |
|---|---|---|---|---|
| T-1 | Quran.com catalogue endpoint, live | `https://api.quran.com/api/v4/resources/tafsirs` | undated | **No** — see §5.1 |
| T-2 | QDC tafsir content endpoint, live | `https://api.qurancdn.com/api/qdc/tafsirs/169/by_chapter/108` | undated | **No** — see §5.2 |
| T-3 | Quran Foundation tafsir API documentation | `https://api-docs.quran.foundation/docs/content_apis_versioned/tafsir/` | undated | **No** — see §5.3 |
| T-4 | Quran Foundation Developer ToS, live | `https://api-docs.quran.foundation/legal/developer-terms/` | "Last updated: 2026-08-26" | **No** — §5.4 |
| T-5 | Quran Foundation Developer ToS, archived pre-retrieval | `web.archive.org/web/20260521174610/…/legal/developer-terms/` | "Last updated: 2025-06-13" | **No** — §8 |
| T-6 | Quran.com site terms, live | `https://quran.com/terms-and-conditions` | "Last updated: July 28, 2026" | **No** — §8 |
| T-7 | Quran.com site terms, archived pre-retrieval | `web.archive.org/web/20260609202742/https://quran.com/terms-and-conditions` | "Last updated: March 20, 2024" | **No** — §8 |
| T-8 | Quran.com About Us / Credits | `https://quran.com/about-us` | undated | **No** — §5.5 |
| T-9 | Dar-us-Salam product record for the work | `https://dar-us-salam.com/quran/tafseer/q09-tafsir-ibn-kathir.html` | 2nd edn July 2003 | **Yes, as to the work** — §6.1 |
| T-10 | Dar-us-Salam Terms & Conditions | `https://dar-us-salam.com/information/terms-and-conditions.htm` | undated | **Partly** — §6.2 |
| T-11 | QUL tafsir resource index | `https://qul.tarteel.ai/resources/tafsir` | undated | corroborative only — §5.6 |
| T-12 | KFGQPC official site | `https://qurancomplex.gov.sa` (and `/en/`) | — | **NOT REACHED** — §7.2 |

### 5.1 T-1 — the catalogue declares no rights information

Verbatim, the two entries in full:

```json
{"id":16,"name":"Tafsir Muyassar","author_name":"المیسر",
 "slug":"ar-tafsir-muyassar","language_name":"arabic",
 "translated_name":{"name":"Tafsir Muyassar","language_name":"english"}}
```

```json
{"id":169,"name":"Ibn Kathir (Abridged)","author_name":"Hafiz Ibn Kathir",
 "slug":"en-tafisr-ibn-kathir","language_name":"english",
 "translated_name":{"name":"Ibn Kathir (Abridged)","language_name":"english"}}
```

**FACT.** No entry in this catalogue carries a `license`, `licence`,
`copyright`, `rights`, or `permissions` field. It is bibliographic
metadata only. The `author_name` values are the same two inaccurate
values the project copied into the database — the upstream catalogue is
where `المیسر` (a title) and `Hafiz Ibn Kathir` (the original author,
not the rights holder of the abridged translation) originate.

### 5.2 T-2 — the content endpoint declares no rights information

Field names returned, verbatim and complete:

- top level: `tafsirs`, `pagination`
- each tafsir object: `id`, `resource_id`, `verse_key`, `language_id`,
  `text`, `slug`
- pagination: `per_page`, `current_page`, `next_page`, `total_pages`,
  `total_records`

**FACT.** No licence, copyright, publisher, attribution or terms field
is present. One chapter (108, three ayahs) was requested to enumerate
field names; no text was retained or reproduced.

### 5.3 T-3 — Quran Foundation's own tafsir API docs are silent

**FACT.** The operator's documentation page for the tafsir endpoint
states nothing about licensing, copyright, attribution, permitted use,
or the rights holder of the content returned. The documented `meta`
object carries `tafsir_name`, `author_name` and `filters` — no licence
field, no publisher field.

### 5.4 T-4 — current Developer ToS, verbatim clauses

> "QF Content | Quran text, translations, metadata, audio, reflections,
> and any other content returned by the APIs."

> "QF Content is not sold, sublicensed, or redistributed."

> "QF Content and raw API data are not sold, sublicensed, or
> redistributed."

> "A Developer must obtain a signed commercial license before selling,
> sublicensing, or redistributing QF Content or raw API data."

> "provided that … the Application complies with these Terms and any
> source-specific license requirements."

> "Cache or store QF Content longer than 1 week, except where (a) QF has
> expressly permitted longer storage, or (b) the QF Content is available
> through the Content Sync APIs." *(listed under what a Developer must
> not do)*

**FACT.** The words "tafsir", "commentary" and "qurancdn" do not appear
anywhere in T-4. No attribution clause appears anywhere in T-4.

Two observations, both recorded without conclusion:

- The defined term "any other content returned by the APIs" is broader
  than the transliteration case Session 164 examined. Whether a tafsir
  is within it is a question of construction, and the document's silence
  on "tafsir" does not answer it either way.
- "any source-specific license requirements" is the clause that would
  carry Dar-us-Salam's and KFGQPC's rights forward if T-4 applied. QF
  granting a licence to QF Content cannot, on the face of that clause,
  grant more than QF itself holds.

### 5.5 T-8 — the operator names KFGQPC as a data source, not a licensor

**FACT.** `quran.com/about-us` lists project collaborators including
"QuranComplex" (the King Fahd Glorious Qur'an Printing Complex),
Tanzil, and QuranEnc. It states that Quran.com "is a waqf (endowment),
established as a public trust" managed by Quran.Foundation, a 501(c)(3)
nonprofit. **It does not name a copyright holder, publisher, licence or
permission for any tafsir**, and links to no credits or licensing page
for tafsir content.

**Boundary.** A collaborator credit is not a licence grant, and it is
not evidence that either party permits onward redistribution.

### 5.6 T-11 — QUL, recorded only to close the question

**FACT.** QUL's tafsir index lists "Tafsir Ibn Kathir" (resource 35) and
"Tafsir Muyassar" (resource 38) with download links, and states **no**
licence, copyright, publisher or attribution for either. The resource
detail page for 35 names no rights holder and does not mention
Dar-us-Salam.

This is corroborative only. Per §3.2, QUL is **not** the retrieval path
for either dataset, and QUL's FAQ is not the governing text for them.
It is recorded because `docs/LICENSING.md` currently reasons from that
FAQ for these two rows.

### 5.7 What was searched for and not found

- **No** licence, copyright, publisher or attribution field on any
  upstream surface for either dataset (T-1, T-2, T-3, T-11).
- **No** occurrence of "tafsir", "commentary" or "qurancdn" in T-4.
- **No** attribution clause in T-4, T-6 or T-7.
- **No** first-party statement by Dar-us-Salam or KFGQPC addressing
  redistribution of these datasets through Quran.com or any API.
- **No** record in this repository of any outreach to Dar-us-Salam,
  KFGQPC, Quran.com or Quran Foundation, Inc. concerning tafsir, and
  **no** record that outreach was not made. Unknown in both directions.
- The Session 167 enquiry that was sent covers the **transliteration**
  only. It does not name either tafsir dataset.

---

## 6. Ibn Kathir (Abridged, English) — upstream rights holder

### 6.1 First-party publisher record — FACT

Retrieved from the publisher's own site (T-9):

| Field | Value |
|---|---|
| Title | Tafsir Ibn Kathir — ENGLISH (10 Volumes) |
| Attributed author | Hafiz Ibn Katheer |
| Edition | 2nd, **July 2003** |
| ISBN | 1591440203 / EAN13 9781591440208 |
| Preparation | "translated and abridged by a group of scholars under the supervision of Shaykh Safiur-Rahman Al-Mubarakpuri" |
| Site notice | "© 1995-2026 - Dar-us-Salam Islamic Bookstore. All Rights Reserved" |

This **corroborates on first-party evidence** what `docs/LICENSING.md`
recorded from the printed copyright page ("Bản quyền: Maktaba
Dar-us-Salam, 2003"), and independently confirms the 2003 edition date
and the abridgement provenance.

**Boundary — do not over-read the notice.** "© 1995-2026 Dar-us-Salam
Islamic Bookstore. All Rights Reserved" is the **website footer**, not
the book's copyright page. It is evidence about the site, and only
corroborative as to the book.

### 6.2 The publisher's own terms — FACT

T-10 is the only Dar-us-Salam terms document located. It addresses the
online shop and the site's own materials. Verbatim:

> "The design of this site, our logo and name, our product photography,
> our original articles and author biographies, and our catalog
> descriptions belong to Dar-us-Salam"

> "The books and products we sell are the property of their respective
> authors and publishers."

> "You may read, print, and share these files intact and unaltered. You
> may not sell them, charge for access to them, remove the publisher's
> information, or present them as your own work." *(stated of the free
> digital materials Dar-us-Salam itself distributes)*

**FACT.** The document contains **no** grant of any kind covering reuse
of the text of the books Dar-us-Salam publishes. It is silent on the
question.

**Recorded, not applied.** The "intact and unaltered … not remove the
publisher's information" clause governs Dar-us-Salam's **own** free
files. It is **not** a term governing the QDC dataset and must not be
applied to it. It is recorded only because it is the nearest first-party
indication of the publisher's posture, and because two features of the
PR #1 pipeline would sit awkwardly against a clause of that shape if one
were ever found to apply: §3.4 alters the text, and §3.1 records
`author = 'Hafiz Ibn Kathir'` with no publisher information at all.

### 6.3 Entity identity — UNKNOWN

At least three names are in play and no located document reconciles them:

| Name | Where seen |
|---|---|
| Maktaba Dar-us-Salam | `docs/LICENSING.md`, from the book's copyright page |
| Dar-us-Salam Islamic Bookstore | T-9, T-10 (US site footer) |
| Darussalam Publishers | third-party references |

`docs/LICENSING.md` cites the 10-volume set ISBN `9960-892-71-9`; T-9
gives ISBN `9781591440208` for a 10-volume English set. **Multiple
editions and multiple corporate names exist**; which entity holds which
right in which territory is **UNKNOWN — COUNSEL REQUIRED**.

### 6.4 Original versus abridgement — FACT

The 14th-century Arabic original of Ibn Kathir's *Tafsir al-Qur'an
al-'Azim* is not what the dataset contains. The dataset is the **modern
English abridged translation**, prepared for Dar-us-Salam by a group of
scholars under Shaykh Safiur-Rahman Al-Mubarakpuri, first published 2000,
2nd edition 2003. The age of the original therefore does not bear on the
status of these bytes. **The `author = 'Hafiz Ibn Kathir'` value carried
from the upstream catalogue into the database does not name the party
whose permission would be at issue.**

---

## 7. Al-Muyassar (Arabic) — upstream rights holder

### 7.1 Attribution — FACT / INFERENCE

**FACT.** The work *at-Tafsir al-Muyassar* is attributed to نخبة من
العلماء ("a group of scholars") and published by مجمع الملك فهد لطباعة
المصحف الشريف — the King Fahd Glorious Qur'an Printing Complex,
Madinah. `quran.com/about-us` (T-8) independently lists "QuranComplex"
among its data-source collaborators.

**FACT.** KFGQPC is the same body whose UthmanicHafs font EULA the
project already relies on, and which `docs/LICENSING.md` already tracks
as risk item 7 for `main`.

**INFERENCE, held as inference.** That the KFGQPC edition is the exact
edition behind upstream id 16 is **not established** by any located
document. The upstream catalogue names no publisher (§5.1).

### 7.2 No first-party KFGQPC statement obtained — UNKNOWN

**FACT.** `https://qurancomplex.gov.sa` and `https://qurancomplex.gov.sa/en/`
both returned `ECONNREFUSED` from this session on 2026-08-29. No
first-party KFGQPC terms, copyright or permissions statement was
retrieved.

**This is an unclosed gap, not a finding.** It must not be read as
"KFGQPC publishes no terms". It means this session could not reach the
site. Per the standing lesson that absence of evidence is not evidence
of absence, the correct next step is a retrieval from a network that can
reach the host — not an assumption in either direction.

### 7.3 Attribution as recorded is wrong — FACT

The database records `author = 'المیسر'`. That is the **title** of the
work, not an author, and it is spelled with Persian ی (U+06CC) rather
than Arabic ي (U+064A). This value originates upstream (§5.1) and was
copied through unchanged. Correct attribution would name نخبة من العلماء
and KFGQPC.

---

## 8. Historical applicability — the 2026-07-25 retrieval date

Session 164's date analysis was performed for `2026-07-06`. The tafsir
retrieval is `2026-07-25` and is analysed here independently.

| Document | Snapshot | "Last updated" in that snapshot | Relative to 2026-07-25 |
|---|---|---|---|
| Quran.com site terms | `20260609202742` | **March 20, 2024** | 46 days **before** |
| Quran.com site terms | live, 2026-08-29 | **July 28, 2026** | 3 days **after** |
| QF Developer ToS | `20260521174610` | **2025-06-13** | 65 days **before** |
| QF Developer ToS | live, 2026-08-29 | **2026-08-26** | 32 days **after** |

Snapshot enumeration via the Wayback CDX API confirms the complete
captured set in the window:

- `quran.com/terms-and-conditions`: `20260416`, `20260525`, `20260604`,
  `20260609` — **none between 2026-06-09 and 2026-08-29**.
- `api-docs.quran.foundation/legal/developer-terms/`: `20260105`,
  `20260113`, `20260521`, `20260826` — **none between 2026-05-21 and
  2026-08-26**.

**FACT.** Both documents existed, in the versions quoted, before the
2026-07-25 retrieval.

**INFERENCE (strong, but an inference).** The version of the site terms
in force on 2026-07-25 was the "March 20, 2024" version. Supporting: the
last capture before retrieval still showed that date, and the next known
revision is dated 2026-07-28 — **three days after** retrieval. Not
closed: no capture exists between 2026-06-09 and 2026-07-25.

**INFERENCE (weaker).** The version of the Developer ToS in force on
2026-07-25 was the "2025-06-13" version. The capture gap is 65 days and
no evidence constrains it.

**Do not apply today's terms retroactively.** The current Developer ToS
(T-4) states flatly "QF Content is not sold, sublicensed, or
redistributed", whereas the version in force at retrieval carried the
qualifier "except as integral to the end-user experience of the
Application". Which text governs a dataset **retrieved once and then
redistributed continuously** is a question of legal interpretation and is
referred onward (§11, Q-11).

---

## 9. Redistribution model — what the app would actually do

Modelled from PR #1's committed code. Each row is an **activity**, its
**output**, and the **question** it raises — kept separate on purpose.

| # | Activity | Output | Status |
|---|---|---|---|
| R-1 | Bundle `assets/database/quran.sqlite` (34.3 MB) in the app package | Every install carries a full offline copy of 7,173 tafsir records | **FACT** — declared at `pubspec.yaml` `assets:` |
| R-2 | Store as `translation_sources` rows (type `tafsir`) + `translations` rows | 5,278 + 1,895 rows | **FACT** |
| R-3 | Render per-ayah in the Study Workspace, RTL for Arabic | User-visible full text | **FACT** — `tafsir_section.dart` |
| R-4 | Search indexing | **Excluded.** `build_quran_db.py` skips tafsir codes when building `search_index` | **FACT** |
| R-5 | Copy / Share | **Not included.** The clipboard payload is the ayah text plus `— Qur'an S:A`; the tafsir panel exposes no copy or share control | **FACT** |
| R-6 | Transformation | Markup stripped, entities unescaped, whitespace normalised (§3.4); passage→ayah coverage re-mapped at query time | **FACT** |
| R-7 | Attribution surface | `AttributionScreen` reads `translation_sources` and renders `name`, `author`, `language`, `version`, **`license`** and **`source_url`** per source | **FACT** — §9.3 |
| R-8 | Distribution channel | Free app, distributed through commercial app stores | **FACT** for the current model |
| R-9 | Ads / IAP | None present | **FACT** at PR #1 head |
| R-10 | Future paid model | Not implemented; `DR-2026-0014` governs the publishing model | **UNKNOWN** as a future state |

**Do not collapse R-8.** "Free app" is not established to mean
"non-commercial use", and "commercial app store" is not established to
mean "commercial use". Both readings are questions for counsel, already
open as `docs/LICENSING.md` risk items for the Saheeh International
translation that `main` **does** ship.

### 9.1 What R-4 and R-5 narrow

The tafsir redistribution model is **narrower** than the
transliteration's on two axes that Session 146 spent effort on: tafsir
text never enters the search index, and never enters the outbound
clipboard payload. The Copy/Share questions C-1…C-6 raised in Session
146 therefore **do not** extend to tafsir. The bundled-offline-copy
question (R-1) does, in full.

### 9.2 What R-1 raises against the located terms

If — and only if — T-5 were found to govern, its clause "Cache or store
QF Content longer than 1 week unless expressly permitted" would meet a
copy that is permanent by construction: it ships inside the installed
application and is never refreshed. Recorded as the factual shape of the
question, not as a conclusion that any term is engaged or breached.

### 9.3 What R-7 would have published — FACT

`AttributionScreen` renders `entry.license` under a localised "Licence"
label and `entry.sourceUrl` as a copyable link. With the PR #1 database,
that screen would have shown users, as each tafsir's licence:

> `Quran.com/QUL community data — ghi nguồn khi phân phối; kiểm tra điều
> khoản trước khi phát hành thương mại`

— a project-authored note that on its face says the terms had not been
checked (§4) — together with a `source_url` that returns 404.

This is recorded because it is a **product-integrity** finding
independent of any licensing question: the screen was designed to read
attribution from data so it could never drift, and the data it would
have read was project-authored placeholder text. The same class of
defect was found and corrected for the transliteration row in Sessions
161 and 162, where the value now reads `UNKNOWN — COUNSEL REQUIRED`.

---

## 10. Decision matrix

Categories: **A** clearly licensed · **B** licensed with conditions we
can mechanically satisfy · **C** applicability unresolved · **D**
explicitly unsuitable · **E** insufficient evidence.

| Dataset | Category | Why | Minimum evidence to move it |
|---|---|---|---|
| Ibn Kathir (Abridged, en) | **C**, with the adverse indicators concentrated here | An identified commercial publisher, an edition dated 2003, no located grant from that publisher, no licence declared on any upstream surface, and the publisher's own terms silent on reuse of its books' text | A written statement from the Dar-us-Salam entity that holds the abridged-translation copyright, addressing offline bundling and redistribution in a free app on commercial stores; **and** the operator's answer on whether it sub-licenses this specific resource |
| Al-Muyassar (ar) | **C / E** — unresolved, and the record is thinner | Rights holder identified as KFGQPC on strong but indirect evidence; **no first-party KFGQPC statement was reachable at all** (§7.2); no licence declared on any upstream surface | KFGQPC's own published terms or a written permission; and confirmation that upstream id 16 is the KFGQPC edition |
| Study Workspace UI, content-free | **not a licensing question** | The shell carries no tafsir data (§12); the question is product value, not rights | — |

**Neither dataset is placed at A.** No first-party evidence permits
redistribution of either.

**Neither dataset is placed at D.** D would require authoritative
evidence that the proposed model is excluded. What exists is an absence
of any grant, which is not the same thing, and the difference is exactly
what counsel is for.

### 10.1 The five questions, answered

1. **Can the tafsir be safely reintroduced into `main` now?**
   **No.** No located first-party evidence supports redistribution of
   either dataset, both rights holders remain unengaged, and the QDC
   regime that governs the retrieval is the same one holding `P2-2`
   open. `main`'s CI boundary gate blocks the files independently (§13).

2. **Can only the Study Workspace UI be reintroduced without tafsir
   content?** **Technically yes** — §12 establishes the separation is
   clean. But `kStudySections` contains only `tafsirSection`, and that
   section self-hides when no tafsir source exists, so a content-free
   Study Workspace renders an entirely blank screen. That is a product
   decision for the owner, not a licensing one, and it is out of scope
   for this session.

3. **Is a separate owner/counsel enquiry required?** **Yes** — and it is
   materially different from the one already sent. The Session 167
   enquiry names the transliteration only. The tafsir questions are
   addressed to **two additional parties** who have never been contacted.

4. **Which exact questions should be sent?** §11.

5. **What product capability should remain disabled until resolution?**
   Tafsir content ingestion, storage and display, in full. `main` today
   ships none of it; the correct posture is to leave it that way and to
   leave the boundary gate exactly as it is.

---

## 11. Questions requiring counsel or the owner

**To counsel — legal interpretation:**

| # | Question |
|---|---|
| TQ-1 | Do the Quran Foundation Developer Terms (2025-06-13 version, §8) extend to `api.qurancdn.com/api/qdc/tafsirs/…`, an unauthenticated host not named in the document? |
| TQ-2 | If they do, is a tafsir within "QF Content" — "any other content returned by the APIs" — given the document never uses the word "tafsir"? |
| TQ-3 | If they do, does the clause "the Application complies with … any source-specific license requirements" mean QF's grant cannot exceed the rights QF itself holds from Dar-us-Salam or KFGQPC? |
| TQ-4 | Does offline bundling (R-1) sit inside "except as integral to the end-user experience of the Application" as that clause stood at retrieval, or outside it? |
| TQ-5 | How does "Cache or store QF Content longer than 1 week" bear on a database shipped permanently inside an installed application (§9.2)? |
| TQ-6 | Do the Quran.com site terms (March 20, 2024 version) reach an API host at all? |
| TQ-7 | If they do, what is the effect of "PERSONAL, NON-COMMERCIAL USE ONLY" on a free application distributed through commercial app stores? |
| TQ-8 | Which version governs a dataset retrieved once on 2026-07-25 and redistributed continuously thereafter — the version then in force, or the current one (§8)? |
| TQ-9 | Does the format normalisation at §3.4, and the passage→ayah re-mapping at query time, together constitute preparation of a derivative work of the abridged English translation? |
| TQ-10 | Who must grant permission for the abridged English Ibn Kathir — Maktaba Dar-us-Salam, Dar-us-Salam Islamic Bookstore, Darussalam Publishers, the translating scholars, or some combination (§6.3)? Does it differ by territory or edition? |
| TQ-11 | What is the copyright status of the KFGQPC edition of *at-Tafsir al-Muyassar*, and does KFGQPC's practice of permitting da'wah reuse constitute a licence on which a distributor may rely? |
| TQ-12 | If a rights holder's permission were obtained, what attribution would discharge it for a **distributed offline copy** — the same question `P2-2` turns on? |

**To the owner — decisions, not legal conclusions:**

- **TO-1.** Instruct counsel on TQ-1…TQ-12, or a subset?
- **TO-2.** Authorise a written enquiry to the Dar-us-Salam entity
  identified at §6.3, asking whether the abridged English Ibn Kathir may
  be bundled offline and redistributed in a free application, and if so
  in what edition and with what attribution. **No such enquiry has ever
  been made; this repository holds no record of contact with any tafsir
  rights holder.**
- **TO-3.** Authorise a written enquiry to KFGQPC on the same footing for
  *at-Tafsir al-Muyassar*, and separately authorise retrieval of KFGQPC's
  published terms from a network that can reach `qurancomplex.gov.sa`
  (§7.2).
- **TO-4.** Extend the enquiry already sent to Quran Foundation on
  2026-08-29 (Session 167) to cover tafsir resources **id 16** and **id
  169**, or send a separate one? The sent enquiry covers the
  transliteration only.
- **TO-5.** Confirm whether the owner has ever contacted Dar-us-Salam,
  Darussalam or KFGQPC. The repository holds no record either way.
- **TO-6.** Decide whether a content-free Study Workspace has product
  value (§10.1 item 2) — an independent question that does not wait on
  any of the above.

---

## 12. Study Workspace — is it separable? FACT: yes

| File | Tafsir dependency |
|---|---|
| `study_workspace_screen.dart` | none |
| `study_workspace_shell.dart` | none — renders whatever list it is given |
| `study_panel.dart` | none — generic titled panel |
| `study_workspace_controller.dart` | none — resolves an ayah via `QuranRepository` |
| `study_section.dart` | **one line**: imports `sections/tafsir_section.dart` to populate `kStudySections` |
| `sections/tafsir_section.dart` | the entire tafsir dependency |

`StudySection` is a value type carrying an `id` and a builder; the shell
holds no knowledge of tafsir. `tafsirSection` degrades closed by design:
when no tafsir source exists it returns `SizedBox.shrink()` **before
touching the database**.

**FACT.** The shell would compile and run against `main`'s
tafsir-free database. **FACT.** It would render nothing, because
`kStudySections` has exactly one member and that member self-hides.

**Also FACT.** PR #1's `getTextsCoveringAyah` and `tafsirSourcesProvider`
do **not** exist on `main`; `SourceType.tafsir` and the
`'translation' | 'transliteration' | 'tafsir'` schema comment **do**.
Reviving the shell would require porting repository methods that are
absent today — an implementation question, deliberately not answered
here.

---

## 13. Existing controls on `main` — FACT

`test/repository_boundary_test.dart` blocks by pattern:

```
^tool/data/tafsir_.*\.json$
```

with the recorded reason: *"bộ chú giải Tafsir — Ibn Kathir (Abridged) là
(c) Maktaba Dar-us-Salam 2003; Al-Muyassar chưa xác minh"*. The
`_grandfathered` map exempts by **exact path** and deliberately omits both
tafsir files, because `main` never tracked them. The gate would fail on
any attempt to reintroduce either dataset, and on any newly named tafsir
dataset. The file's own comments record this as intended behaviour.

**Nothing in this packet changes that gate, and nothing here should.**

---

## 14. Red team — assumptions tested, and what remains unproven

| # | Challenge | Outcome |
|---|---|---|
| RT-1 | Assumption that the named publisher owns the text | **Not proven.** T-10 states "The books and products we sell are the property of their respective authors and publishers", leaving open whether Dar-us-Salam is proprietor or distributor for this title. §6.3 records three unreconciled entity names. |
| RT-2 | Multiple editions / multiple licences | **Confirmed live.** Two different 10-volume ISBNs are in the record (§6.3); which edition upstream id 169 reproduces is UNKNOWN. |
| RT-3 | Online edition may differ from the downloadable edition | **Unresolved.** No upstream surface states which printed edition id 169 corresponds to. The 30.4% ayah coverage and passage-level mapping (§3.5) show the API form is not a page-faithful reproduction of any print edition. |
| RT-4 | Translation confused with tafsir | **Held distinct throughout.** `main` ships translations (Saheeh International, Rowwad) under separate terms already analysed; neither bears on these datasets. |
| RT-5 | Arabic source text vs translation may carry different rights | **Confirmed material.** Al-Muyassar is Arabic and modern (KFGQPC); Ibn Kathir's dataset is a modern English abridged translation, not the public-domain 14th-century Arabic original (§6.4). The two datasets must never be reasoned about together. |
| RT-6 | Attribution requirements may differ per dataset | **Confirmed.** `docs/LICENSING.md` prescribes different attributions (نخبة من العلماء + KFGQPC vs Darussalam + translating team). Neither is sourced from an upstream requirement — both are project-authored proposals. **UNKNOWN** whether either rights holder requires anything. |
| RT-7 | Terms may govern API use only, not redistribution | **Open, and central.** T-4 addresses both use and redistribution; whether it reaches `api.qurancdn.com` at all is TQ-1. |
| RT-8 | PR #1 licence metadata may be project-authored | **Confirmed — it is** (§4). Both the `license` string and the `source_url` originate in `tool/fetch_tafsir.py`, and the `source_url` does not resolve. |
| RT-9 | Historical terms may differ from current terms | **Confirmed — they do** (§8). The redistribution clause was materially redrafted between the version in force at retrieval and the current one. |
| RT-10 | Study Workspace may be independently usable | **Confirmed separable, but empty** (§12). |
| RT-11 | The dataset may not be needed for the desired UX | **Open.** Not assessed here; product question, §10.1 item 2 and TO-6. |
| RT-12 | The QUL attribution in `docs/LICENSING.md` | **Contradicted by the retrieval code** (§3.2). This is the finding that most changes the shape of the file. |
| RT-13 | "No tafsir table" phrasing in the Session 137 note | **Imprecise, conclusion unaffected.** The schema has no separate tafsir table by design in *either* build; tafsir is `translation_sources.type='tafsir'`. Verified directly at this baseline: `main`'s `translation_sources` holds **3** rows (`translit_latin`, `vi_main`, `en_sahih`) and **none** of type `tafsir`. The conclusion — no tafsir content on `main` — stands, on stronger evidence. |
| RT-14 | Same note describes `main`'s third source as "Quran.com/QUL" | **Stale label.** Superseded by Sessions 147, 161 and 162, which established QDC and set the row's `license` to `UNKNOWN — COUNSEL REQUIRED`. Recorded, not edited: it is a historical record. |

### 14.1 Assumptions that remain unproven

1. That Quran Foundation, Inc. operates `api.qurancdn.com`. Strongly
   indicated, never stated first-party. Carried forward unchanged from
   Session 164 §6.
2. That upstream id 16 is the KFGQPC edition of *at-Tafsir al-Muyassar*.
3. That upstream id 169 is the Dar-us-Salam abridged English edition —
   the upstream catalogue names no publisher.
4. That either terms document was in force on 2026-07-25 (§8).
5. That the Dar-us-Salam entity named on `dar-us-salam.com` is the same
   entity as "Maktaba Dar-us-Salam" on the 2003 copyright page.
6. That KFGQPC publishes no applicable terms — **not tested**; the site
   was unreachable (§7.2).

---

## 15. What this packet does not do

1. It does **not** establish which licence or permission governs either
   dataset.
2. It does **not** conclude that redistribution is permitted, and does
   **not** conclude that it is prohibited.
3. It does **not** assert that any term has been breached by anyone. No
   violation is alleged or implied anywhere in this document.
4. It does **not** clear, and does **not** block, any release.
5. It does **not** change `P2-2`, which concerns the transliteration and
   stays **OPEN**.
6. It does **not** amend `docs/LICENSING.md`. The QUL attribution at rows
   5–6 and lines 126–127 is a historical record; §3.2 supersedes it on
   the facts, and correcting the file is a separate, separately
   justified change.
7. It does **not** contact, and does not authorise contacting, any third
   party.

---

## 16. Provenance of every fact in this document

| Claim class | Established by |
|---|---|
| Ground truth (§2) | `git`, `gh`, measured at the baseline |
| Dataset identity, coverage, hashes (§3) | `git show` / `git cat-file` at `11d6176`, and direct read-only queries of both SQLite artifacts |
| Retrieval path (§3.2) | `tool/fetch_tafsir.py` at `11d6176`, plus an exhaustive scan of the PR #1 tree for QUL references |
| Transformation (§3.4) | `strip_markup()` source; `tafsir_section.dart` |
| Licence-string provenance (§4) | `tool/fetch_tafsir.py:181–182`; `tool/build_quran_db.py`; both dataset JSON `meta` blocks; both `translation_sources` rows |
| URL 404s (§4) | live retrieval, 2026-08-29 |
| Upstream surfaces (§5) | live retrieval, 2026-08-29 |
| Publisher record (§6) | `dar-us-salam.com`, first-party, 2026-08-29 |
| Archived terms and snapshot enumeration (§8) | Wayback CDX API and the two named captures, 2026-08-29 |
| Redistribution model (§9) | PR #1 source: `pubspec.yaml`, `build_quran_db.py`, `tafsir_section.dart`, `ayah_actions_sheet.dart`, `attribution_screen.dart`, `attribution_entry.dart` |
| Study Workspace separability (§12) | full read of all six workspace files at `11d6176` |
| Boundary gate (§13) | `test/repository_boundary_test.dart` at the baseline |

No fact in this document rests on a blog, an aggregator, a forum, or
another project's attribution.
