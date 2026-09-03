# Session 182 — Quran Foundation Primary-Source Evidence Capture

**Baseline:** `origin/main` at `ad947bc9ee40fb935240a1c46ce0627d546815d2`
**Prepared:** 2026-08-31
**Scope:** transcribe and classify the actual Quran Foundation ("QF")
reply email now supplied by the owner, and reconcile it against
[`SESSION_180_QF_RESPONSE_RECONCILIATION.md`](SESSION_180_QF_RESPONSE_RECONCILIATION.md)
(not yet merged to `main`; open as
[PR #63](https://github.com/duso201189-nxp/quran-companion/pull/63)),
which recorded that no such evidence was accessible to that session.

> **Session 190 (2026-09-03) addendum — merge-status correction.** PR #63
> merged to `origin/main` at commit `bf87aca6c5d40f7fa57c099e84ca94f9c125a0e0`
> (2026-09-03T09:23:45Z). The "not yet merged / open" description above
> reflects this document's own baseline (2026-08-31, `origin/main` at
> `ad947bc9`) and is preserved unedited as historical text — it is no
> longer the current state.

**`P2-2` = OPEN. Licence = UNKNOWN — COUNSEL REQUIRED. Not closed by this
document (§16).** A concrete, QF-authored compliance pathway now exists
for one dataset (the Latin word-by-word transliteration) — see §16 for
exactly what changed and what did not.

> This is an evidence-capture document. It transcribes and classifies a
> primary source; it draws no legal conclusion, grants no clearance, and
> changes no code, database, ADR/DR, `docs/LICENSING.md` entry, or
> governance record. Where this document uses words like "permitted,"
> "required," or "authorized," they report **what the source document
> says**, not this document's own legal conclusion — see the
> terminology-safety scan in §21.

---

## 1. Executive Summary

The owner attached one file to this session:
`Terms applying to word-by-word transliteration from api.qurancdn.com.eml`
— a complete RFC 822 email export (headers + plain-text body), **not**
screenshots. This is a materially different, and materially stronger,
artifact than what Session 180's brief and this session's own Phase 1–3
instructions anticipated (which assumed images requiring visual
inspection and OCR-style transcription risk). §2 and §4 explain the
deviation and why the file was read directly rather than treated as
unreadable or declined.

The email is a **reply** ("Re: Terms applying to word-by-word
transliteration from api.qurancdn.com") from **Basit Minhas
(`basit@quran.com`)**, signed "Quran Foundation," to the project owner,
**Cc `developers@quran.com`**, dated **Sun, 30 Aug 2026 21:33:20 +0500**.
It is a direct reply (`In-Reply-To` a single prior Gmail message) to the
Q1–Q12 enquiry that Session 166 drafted and that Session 167 recorded, on
the owner's own confirmation, as sent from the owner's Gmail account on
**2026-08-29** to `developers@quran.com` — one calendar day before this
reply. Every structural signal (Cc address, reply threading, one-day
gap, subject line matching the owner's original subject) is internally
consistent with this being the actual reply to that actual enquiry.
Google's own authentication check on receipt reports `dkim=pass`,
`spf=pass`, `dmarc=pass` for the `quran.com` sending domain (§3) — a
technical signal about mail authenticity, not a legal one.

The email is **scoped to exactly one dataset**: the Latin word-by-word
transliteration (`translation_sources.code = 'translit_latin'`,
retrieved via `tool/fetch_transliteration.py` from
`api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` on 2026-07-06).
It explicitly names that dataset, that retrieval, and that old endpoint.
It does **not** mention either of the two tafsir datasets covered by
Session 172, and does not mention `word_by_word_translations` (a
different resource the email explicitly distinguishes from
`word_by_word_transliterations` — this repository does not use that
other resource at all; §12).

For the transliteration dataset, QF's reply states a concrete pathway:
continued offline use is permitted **conditioned on** migrating to the
"Content Sync API" (resource group `word_by_word_transliterations`,
production resource ID `60`), retaining a sync token, resyncing at
least every 7 days, removing the currently-committed raw SQLite from the
public repository, replacing the normalized dataset with Content-Sync
values (or keeping normalization strictly as a separate,
not-represented-as-original presentation layer), displaying a specific
attribution string and link, and contacting QF before distributing any
altered derivative dataset. None of these steps has been implemented in
this repository as of this session (§7, §14).

This is a **written, QF-authored, dataset-specific compliance pathway**
— categorically more than Session 180 had. It is **not** a signed
commercial licence, does not address the tafsir datasets, does not
resolve authorship/upstream-ownership of the transliteration (Session
165's Q11), and does not by itself constitute the legal clearance that
`P2-2` and Session 164/165's counsel questions were tracking. §16 states
precisely what is and is not changed.

---

## 2. Source Provenance

| Item | Value |
|---|---|
| File supplied | `Terms applying to word-by-word transliteration from api.qurancdn.com.eml` (path outside this repository, read directly from disk in this session) |
| File type | Complete RFC 822 email message export — full SMTP/MIME headers plus a single `text/plain; charset="UTF-8"` body, `Content-Transfer-Encoding: quoted-printable` |
| **Deviation from the governing brief** | Phases 1–3 of the brief that opened this session assume **screenshots** ("Inspect every attached screenshot directly," "number/order of screenshots," "mark UNKNOWN/UNREADABLE" for illegible text). The actual attachment is a **text `.eml` export**, not an image. There is nothing to OCR and nothing illegible: every header and every body byte is machine-readable plain text. This is treated as a strictly stronger evidentiary form than a screenshot (it carries full transport headers and an authentication verdict computed by Google's own mail servers, not just a picture of rendered text), and §4/§5 below satisfy the brief's screenshot-inventory and transcription intent using the format actually supplied. |
| How the file was read | Read in full, once, directly from the path given in this conversation. No OCR, no summarization tool, no intermediate transformation. The full raw header block and full body are reproduced or quoted from in §3 and §5. |
| Contiguity | The file is **one single, complete, well-formed email** — one `Message-ID`, one `Date`, one body, ending cleanly with a signature block ("Kind regards, Basit Minhas, Quran Foundation") and no truncation markers. There is no multi-part sequence to order. |
| What is **not** in this file | The **original outbound enquiry** this message replies to (the Q1–Q12 text Session 166 drafted and Session 167 recorded as sent) is **not** included — only its `Message-ID` is referenced via `In-Reply-To`/`References`. This session cannot verify QF received or read every one of the twelve questions verbatim; it can only compare QF's reply content against the Q1–Q12 text already committed in `SESSION_165_QDC_OWNER_DECISION_BRIEF.md` (§13 below). |

---

## 3. Email Metadata

Transcribed directly from the `.eml` header block. Routing/cryptographic
detail (raw DKIM signature blobs, internal Gmail routing hashes, sender
and relay IP addresses) is **omitted from this committed, public-repo
document** as unnecessary bulk with no evidentiary value beyond what is
summarized below (Phase 9 PII-minimization); the full raw headers remain
in the original `.eml` file, which this repository does not store.

| Field | Value |
|---|---|
| From | Basit Minhas `<basit@quran.com>` |
| To | the project owner's personal Gmail address — **redacted in this public-repository artifact**; the address is verifiable against the original `.eml` file, and matches the recipient the owner has used throughout this project's correspondence |
| Cc | `developers@quran.com` |
| Date | Sun, 30 Aug 2026 21:33:20 +0500 (sender's local time) |
| Received (Gmail, recipient side) | Sun, 30 Aug 2026 09:34:13/09:34:14 -0700 (PDT) — the same instant as the Date header (21:33:20 +05:00 = 09:33:20 -07:00), one minute of relay latency |
| Subject | "Re: Terms applying to word-by-word transliteration from api.qurancdn.com" |
| Message-ID | `<CAN0oGnRCi=bfp3rHKFY4SZncrD8ah7O0+7oEG52kOB2WdrJmUA@mail.gmail.com>` |
| In-Reply-To / References | `<CAJNn-sJV6ycOJL_XR8ij_fyaPs12N3dN=EcuWyRNX6fU4ScLtg@mail.gmail.com>` — a single prior message, not present in this file (§2) |
| Content-Type | `text/plain; charset="UTF-8"`, quoted-printable |
| Authentication (computed by Google on receipt, `Authentication-Results` / `ARC-Authentication-Results` headers) | `dkim=pass header.i=@quran.com header.s=google`; `spf=pass` (`209.85.220.41` permitted sender for `basit@quran.com`); `dmarc=pass` (`p=NONE sp=NONE dis=NONE`, `header.from=quran.com`) |
| Return-Path | `<basit@quran.com>` |

**Reading the authentication result correctly:** `dkim=pass`/`spf=pass`/
`dmarc=pass` are Google's technical verdicts that the message's
`From: quran.com` header was not spoofed in transit and that
`quran.com`'s own DNS-published mail policy accepts it as legitimate for
that domain. This is a **mail-authenticity signal**, not a determination
of the sender's authority to bind Quran Foundation to any statement, and
not a legal conclusion of any kind. It is recorded here because it is
independently verifiable repository-external fact, not because it
answers any legal question.

**Consistency with prior sessions' record:** Session 167 recorded, on
the owner's own confirmation, that the Q1–Q12 enquiry was sent
2026-08-29 to `developers@quran.com` from the owner's own Gmail account.
This message is dated one day later (2026-08-30), is `To` that same
personal address, `Cc`s that same `developers@quran.com` address, and
carries the "Re:" of a matching subject line and a genuine
`In-Reply-To` thread reference. Nothing in this file contradicts the
Session 167 record; everything about it is consistent with being the
actual reply to that actual enquiry.

---

## 4. Screenshot Inventory

**Not applicable — no screenshots were supplied.** See §2. One `.eml`
file was supplied, read in full, and is the single item transcribed in
§5. This section is retained (rather than deleted) to keep this
document's structure traceable to the governing brief's Phase 8
requirement, with the deviation recorded here rather than silently
dropped.

---

## 5. Faithful Transcription

The body below is the **complete, verbatim plain-text body** of the
email, exactly as received. The source uses quoted-printable MIME
encoding with soft line-wraps (a trailing `=` mid-word, e.g.
`snapshot=` / `s/word_by_word...`, and encoded punctuation, e.g.
`=E2=80=9C`/`=E2=80=9D` for curly quotes `"`/`"`, `=E2=80=99` for a
curly apostrophe `'`, `=3D` for `=`); those are decoded below into plain
readable text, with no wording added, removed, or reordered. Paragraph
breaks match the source exactly.

> Dear Du So,
>
> Thank you for the detailed message and for checking before releasing
> Qur'an Companion.
>
> The practical answer is that Quran Foundation now provides this
> word-by-word Latin-script transliteration through the supported
> Content Sync API. You may keep it locally for offline use inside the
> application, provided that you migrate to Content Sync and follow the
> sync, integrity, attribution, and redistribution requirements below.
>
> The production Content Sync details are:
>
> - Resource group: word_by_word_transliterations
> - Production resource ID: 60
> - Snapshot: https://apis.quran.foundation/content/api/v4/resources/snapshots/word_by_word_transliterations/60
> - Incremental record type: word_transliteration
>
> This group is separate from word_by_word_translations.
>
> For your existing July 6 retrieval, normal pagination through API
> responses is not what the Developer Terms mean by extracting or
> scraping content "outside the API responses." However, a one-time
> copy from the older api.qurancdn.com/api/qdc endpoint does not
> qualify for indefinite offline storage under the current Content
> Sync exception. Before releasing the app, please replace that copy
> with the Content Sync snapshot, retain the sync token, perform an
> incremental sync at least once every 7 days, and apply all available
> changes. Quran Foundation must remain the source of truth.
>
> A local database used internally by the installed application is
> permitted under that Content Sync flow, and an application containing
> the content may be distributed through Google Play or the Apple App
> Store, whether the application is free or commercial, as long as the
> content is part of the application's end-user experience. QF Content
> or raw API data may not be sold, sublicensed, or redistributed as a
> separate dataset, feed, API, content package, or other standalone
> product without a written commercial license. Because the SQLite file
> is currently present in the public source repository, please remove
> the raw dataset from the repository before release; the application
> code itself may remain public.
>
> Please also replace the normalized transliteration dataset with the
> values returned by Content Sync. Do not overwrite or redistribute
> altered source values as Quran Foundation content. If you need
> normalization purely for display, keep it as a separate presentation
> layer and do not represent the transformed text as the original QF
> source. Please contact us before distributing any altered derivative
> dataset.
>
> Please display this attribution in a reasonably visible About,
> Credits, or data-source area of the app, with "Quran Foundation"
> linked to https://quran.foundation/:
>
> Quran data provided by Quran Foundation.
>
> Documentation:
>
> - Content Sync tutorial: https://api-docs.quran.foundation/docs/tutorials/content-sync/getting-started/
> - Snapshot reference: https://api-docs.quran.foundation/docs/content_apis_versioned/4.0.0/resources-snapshot/
> - Python SDK resources: https://api-docs.quran.foundation/docs/sdk/python/resources/
> - JavaScript SDK resources: https://api-docs.quran.foundation/docs/sdk/javascript/resources/
> - Developer Terms: https://api-docs.quran.foundation/legal/developer-terms/
>
> If you use Python, the published quran-foundation-api==0.3.0 package
> includes the Content Sync helper for word-by-word transliteration.
>
> Kind regards,
> Basit Minhas
> Quran Foundation

Nothing in the body was unreadable or ambiguous; no `UNKNOWN /
UNREADABLE` markers are needed anywhere in this transcription.

---

## 6. Exact QF Statements — Provenance Table

Every substantive clause, with its exact wording and a provenance
record per the brief's Phase 3 format (adapted from "screenshot" to
"source file," per §4).

| # | Exact QF wording | Location in §5 | Classification | Confidence |
|---|---|---|---|---|
| S1 | "Quran Foundation now provides this word-by-word Latin-script transliteration through the supported Content Sync API." | ¶2 | PRIMARY-SOURCE FACT | HIGH |
| S2 | "You may keep it locally for offline use inside the application, provided that you migrate to Content Sync and follow the sync, integrity, attribution, and redistribution requirements below." | ¶2 | PRIMARY-SOURCE FACT | HIGH |
| S3 | "Resource group: word_by_word_transliterations / Production resource ID: 60 / Snapshot: https://apis.quran.foundation/content/api/v4/resources/snapshots/word_by_word_transliterations/60 / Incremental record type: word_transliteration" | ¶3 | PRIMARY-SOURCE FACT | HIGH |
| S4 | "This group is separate from word_by_word_translations." | ¶4 | PRIMARY-SOURCE FACT | HIGH |
| S5 | "normal pagination through API responses is not what the Developer Terms mean by extracting or scraping content 'outside the API responses.'" | ¶5 | PRIMARY-SOURCE FACT | HIGH |
| S6 | "a one-time copy from the older api.qurancdn.com/api/qdc endpoint does not qualify for indefinite offline storage under the current Content Sync exception." | ¶5 | PRIMARY-SOURCE FACT | HIGH |
| S7 | "Before releasing the app, please replace that copy with the Content Sync snapshot, retain the sync token, perform an incremental sync at least once every 7 days, and apply all available changes. Quran Foundation must remain the source of truth." | ¶5 | PRIMARY-SOURCE FACT | HIGH |
| S8 | "A local database used internally by the installed application is permitted under that Content Sync flow" | ¶6 | PRIMARY-SOURCE FACT | HIGH |
| S9 | "an application containing the content may be distributed through Google Play or the Apple App Store, whether the application is free or commercial, as long as the content is part of the application's end-user experience." | ¶6 | PRIMARY-SOURCE FACT | HIGH |
| S10 | "QF Content or raw API data may not be sold, sublicensed, or redistributed as a separate dataset, feed, API, content package, or other standalone product without a written commercial license." | ¶6 | PRIMARY-SOURCE FACT | HIGH |
| S11 | "Because the SQLite file is currently present in the public source repository, please remove the raw dataset from the repository before release; the application code itself may remain public." | ¶6 | PRIMARY-SOURCE FACT | HIGH |
| S12 | "Please also replace the normalized transliteration dataset with the values returned by Content Sync. Do not overwrite or redistribute altered source values as Quran Foundation content." | ¶7 | PRIMARY-SOURCE FACT | HIGH |
| S13 | "If you need normalization purely for display, keep it as a separate presentation layer and do not represent the transformed text as the original QF source." | ¶7 | PRIMARY-SOURCE FACT | HIGH |
| S14 | "Please contact us before distributing any altered derivative dataset." | ¶7 | PRIMARY-SOURCE FACT | HIGH |
| S15 | "Please display this attribution in a reasonably visible About, Credits, or data-source area of the app, with 'Quran Foundation' linked to https://quran.foundation/: / Quran data provided by Quran Foundation." | ¶8–9 | PRIMARY-SOURCE FACT | HIGH |

All fifteen are drawn from the same single file (§2); no cross-document
merging occurred.

---

## 7. Requirement Matrix

Legend: **EXPLICIT** (stated in so many words in §5) · **CONDITIONED**
(stated, but contingent on another action) · **NOT ADDRESSED** (this
email is silent).

| Topic | QF position | Status |
|---|---|---|
| Resource group | `word_by_word_transliterations` | EXPLICIT |
| Production resource ID | `60` | EXPLICIT |
| Snapshot endpoint | `https://apis.quran.foundation/content/api/v4/resources/snapshots/word_by_word_transliterations/60` | EXPLICIT |
| Incremental record type | `word_transliteration` | EXPLICIT |
| Sync token | must be retained | EXPLICIT that retention is required; **NOT ADDRESSED**: how a token is issued/obtained, its format, rotation, or whether it is a bearer secret (not in the email body — likely covered by the linked tutorial, which this session did not fetch, see §19) |
| Refresh cadence | incremental sync "at least once every 7 days," "apply all available changes" | EXPLICIT |
| Source-of-truth | "Quran Foundation must remain the source of truth" | EXPLICIT |
| Offline/local storage | permitted inside the installed app | CONDITIONED on Content Sync migration |
| Raw values | must not be overwritten/redistributed "as Quran Foundation content" once altered | EXPLICIT, in the specific sense of mislabeling — see §11 |
| Normalization | permitted for display only, as a separate presentation layer, never represented as original | CONDITIONED |
| Derivative datasets (altered) | must contact QF before distributing | EXPLICIT |
| Attribution wording | "Quran data provided by Quran Foundation." | EXPLICIT |
| Attribution link | `https://quran.foundation/` on the text "Quran Foundation" | EXPLICIT |
| Attribution placement | "a reasonably visible About, Credits, or data-source area of the app" | EXPLICIT |
| App Store / Play distribution | permitted, free or commercial | CONDITIONED on content being "part of the application's end-user experience" |
| Standalone/commercial redistribution (dataset, feed, API, package) | requires "a written commercial license" | EXPLICIT restriction; the licence itself is **NOT ADDRESSED** (no terms, price, or process given) |
| Raw SQLite in public repo | must be removed before release; app code may stay public | EXPLICIT |
| Tafsir datasets (Session 172) | — | **NOT ADDRESSED** at all — the email never mentions tafsir |
| `word_by_word_translations` (a different, unused resource) | explicitly distinguished from the transliteration resource | EXPLICIT (as a scope boundary, not a requirement on this project) |
| Authorship / upstream ownership of the transliteration (Session 165 Q11) | — | **NOT ADDRESSED** |
| Applicability of the Quran.com site Terms and Conditions (S-2) vs. the Developer Terms (S-3/S-4) | only the Developer Terms are invoked by name (implicitly, via "the Developer Terms mean") | S-2 **NOT ADDRESSED** |
| Retroactive authorization for the period before remediation | — | **NOT ADDRESSED** — the email is entirely forward-looking ("before releasing the app, please replace...") |

---

## 8. Content Sync Requirements

Consolidated from §5–§7, in the order a compliant migration would need
to perform them:

1. Obtain access to the Content Sync API for resource group
   `word_by_word_transliterations`, production resource ID `60`.
2. Fetch the current snapshot from
   `https://apis.quran.foundation/content/api/v4/resources/snapshots/word_by_word_transliterations/60`
   and replace the dataset currently stored in
   `assets/database/quran.sqlite` (fetched 2026-07-06 from the legacy
   `api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}` endpoint).
3. Retain the sync token returned by that process.
4. Perform an incremental sync (record type `word_transliteration`) "at
   least once every 7 days," applying all available changes.
5. Treat Quran Foundation as the continuing source of truth — i.e.,
   this is not a one-time migration but an ongoing obligation for as
   long as the app ships the dataset.

**Repository fact, for contrast (unchanged by this document):** no
Content Sync client, sync token storage, or periodic-resync scheduler
exists anywhere in `lib/` or `tool/` today (confirmed by Session 180 §7
and re-confirmed by this session's own read of §7 above — nothing in
this email's content requires re-litigating that repository finding).
Implementing §8's five steps is unscoped, unestimated engineering work.

---

## 9. Attribution Requirements

| Element | Exact value |
|---|---|
| Required string | `Quran data provided by Quran Foundation.` |
| Required link text/target | the words "Quran Foundation" linked to `https://quran.foundation/` |
| Required placement | "a reasonably visible About, Credits, or data-source area of the app" |

**Repository fact, for contrast:** the current in-app attribution string
(`aboutSourcesDetail`, `lib/l10n/app_en.arb`/`app_vi.arb` line 222,
quoted verbatim in Session 180 §7) reads "Arabic text & translations:
Tanzil.net · QuranEnc.com. Audio: EveryAyah.com. Font: KFGQPC (King Fahd
Complex)." — it does not name Quran Foundation, Quran.com, or QDC at
all. This email, for the first time, gives an exact, unambiguous
attribution string to add for this specific dataset if the app is
brought into the compliance pathway described here. Whether/how to add
it is an implementation and owner-decision matter, not decided by this
evidence-capture document (§19).

---

## 10. Distribution Requirements

- An application **containing** the transliteration content may be
  distributed through Google Play or the Apple App Store, **free or
  commercial**, "as long as the content is part of the application's
  end-user experience" (S9, §6).
- QF Content or raw API data may **not** be sold, sublicensed, or
  redistributed as a **separate** dataset, feed, API, content package,
  or other standalone product without a written commercial license
  (S10, §6).
- The distinction the email draws is between *(a)* shipping the data
  embedded inside an end-user application (permitted, under the
  Content Sync conditions) and *(b)* distributing the data itself as a
  product (requires a separate written commercial license, terms not
  given).
- The currently-committed raw `assets/database/quran.sqlite` in the
  **public** GitHub repository is treated by the email as its own,
  separate problem from app-store distribution: "please remove the raw
  dataset from the repository before release; the application code
  itself may remain public" (S11, §6). This reads as directed at the
  repository being public and containing the raw file, independent of
  whatever the shipped app itself does.

---

## 11. Modification / Derivative Requirements

- Normalization/formatting changes are permitted **only** "purely for
  display," kept as "a separate presentation layer," and the
  transformed text must never be "represent[ed]... as the original QF
  source" (S13, §6).
- The dataset actually shipped in `assets/database/quran.sqlite` today
  does not currently meet that description: Session 164 and Session
  180 §7 both establish that normalization (`ALLAH_MAP`
  recapitalisation, hamza/ʿayn handling, a minority-spelling pass) is
  applied by `tool/fetch_transliteration.py` **at fetch/build time**,
  before storage — the shipped bytes are already normalized, not kept
  as a separate presentation-layer transform over raw values. This
  email does not say the current implementation is acceptable as-is;
  it says the normalized dataset should be *replaced* with Content
  Sync values, and that any normalization going forward should be a
  separate, clearly-labeled presentation layer (S12–S13, §6). This is
  recorded as a **gap between current implementation and the
  pathway described**, not as a violation finding — this document
  reaches no compliance verdict (§18).
- "Please contact us before distributing any altered derivative
  dataset" (S14, §6) is a standing, forward-looking condition on any
  future distribution of a modified version of the dataset — it is not
  satisfied by this email itself, and nothing in this session
  constitutes that contact.

---

## 12. Existing Dataset Applicability

| Dataset | Addressed by this email? |
|---|---|
| Latin word-by-word transliteration (`translit_latin`, `api.qurancdn.com/api/qdc`, retrieved 2026-07-06) | **Yes — explicitly and by name.** The email opens by answering exactly this dataset ("your existing July 6 retrieval," "the older api.qurancdn.com/api/qdc endpoint") and gives the resource group/ID/snapshot for its replacement. |
| `word_by_word_translations` (a different QF resource, explicitly distinguished in S4) | Named only to say it is a **different** resource — this repository does not use it (confirmed by a repository-wide search for `word_by_word_translation`, zero hits in `docs/LICENSING.md`, `tool/`, or `lib/`). Not otherwise relevant here. |
| Tafsir dataset — Ibn Kathir (QDC tafsir ID 16, Session 172) | **Not addressed.** Never mentioned. |
| Tafsir dataset — QDC tafsir ID 169 (Session 172) | **Not addressed.** Never mentioned. |
| Quran text / Tanzil translation (`docs/LICENSING.md` P0-2/P1-4) | **Not addressed.** Out of scope of this email entirely; unrelated licensing thread. |

**This email resolves nothing for the two tafsir datasets.** Session
172's finding — that both are retrieved from the same `api.qurancdn.com`
QDC host, under the same class of undetermined licence, Decision C
"UNKNOWN, counsel required" — stands completely unchanged. Nothing in
§16 below should be read as touching tafsir status.

---

## 13. Answers to Previous Questions

Session 165 §6 sent exactly twelve questions (Q1–Q12, quoted from
`SESSION_165_QDC_OWNER_DECISION_BRIEF.md:168-179`) to QF via the
enquiry Session 167 recorded as sent. Comparing this reply against each:

| Q | Question (as sent) | Answered by this email? |
|---|---|---|
| Q1 | Do the Quran.com T&C or the QF Developer Terms of Service govern content from `api.qurancdn.com/api/qdc/`? | **Partially.** The email invokes "the Developer Terms" by name when discussing scraping/extraction (S5). It never mentions the Quran.com site Terms and Conditions (S-2) at all. |
| Q2 | Do those terms govern the word-by-word Latin transliteration specifically? | **Yes**, implicitly and specifically — the entire email is QF answering for exactly this dataset. |
| Q3 | May a project download the complete dataset and bundle it for offline use? | **Yes, conditioned** — "You may keep it locally for offline use inside the application, provided that you migrate to Content Sync..." (S2). |
| Q4 | How does the "cache >1 week" restriction bear on a copy shipped permanently inside an installed app? | **Yes** — resolved via the Content Sync exception: permanent local storage is permitted if migrated to Content Sync with 7-day incremental resync (S7–S8); the old one-time copy does not qualify for indefinite storage on its own (S6). |
| Q5 | How does "extract/scrape... outside the API responses" bear on a one-time paginated retrieval? | **Yes** — "normal pagination through API responses is not what the Developer Terms mean by extracting or scraping" (S5). The *retrieval method* was not scraping; the *indefinite retention of that one-time copy* is the separate issue addressed by S6. |
| Q6 | Which licence/permission governs onward redistribution inside a distributed app? | **Yes** — described in S8–S11 (§6, §10): embedding is permitted app-store-wide under the Content Sync conditions; standalone redistribution requires a separate written commercial licence, terms not given. |
| Q7 | Is attribution required? Exact wording/link/placement? | **Yes, fully** — S15 (§9). |
| Q8 | May the app be distributed through commercial app stores, including free distribution through a commercial channel? | **Yes** — S9 (§6, §10). |
| Q9 | Are normalization/formatting/DB conversion/derived works within contemplation, or is consent needed first? | **Yes, split answer** — display-only normalization as a separate presentation layer needs no prior consent (S13); distributing an *altered derivative dataset* requires contacting QF first (S14). |
| Q10 | Does a separate QDC data licence exist superseding/supplementing the general terms? | **Not addressed.** No separate licence document is named; this email itself functions as a direct, dataset-specific clarification rather than pointing to another instrument. |
| Q11 | Who authored the transliteration, and is it under a third-party licence with its own conditions? | **Not addressed at all.** |
| Q12 | For a dataset retrieved 2026-07-06, is the operative text the version in force then, or the current version? | **Sidestepped rather than answered** — QF does not rule on which version's terms apply retroactively; instead it requires migrating to the *current* Content Sync snapshot before release, which makes the question about the historical July 6 copy largely moot going forward without directly resolving it. |

**Net: 8 of 12 questions receive a direct, on-point answer (Q2–Q9); Q1
and Q6 are answered but only partially/by inference for one document
(Q1); Q10–Q12 remain effectively unaddressed or sidestepped.**

---

## 14. Session 164–181 Reconciliation

Classification legend: **CONFIRMED** · **REFINED** · **CONTRADICTED** ·
**NEW INFORMATION** · **STILL UNKNOWN**.

| Prior statement | Source | Classification | Basis |
|---|---|---|---|
| "No raw QF response text, screenshot, or email was present in this session's conversation context" | Session 180 §1 Finding A | **CONFIRMED** (as an accurate description of Session 180's own context) — and **superseded going forward** by this session's evidence, which is exactly the gap Session 180 §15 recommended closing | Session 180 correctly described what it lacked; it did not claim no such evidence would ever exist |
| The 20-item requirement list in the Session 180 brief was "TASK-BRIEF TOPIC LABELS, not QF statements" | Session 180 §2 | **CONFIRMED**, and now largely **superseded**: this email supplies actual QF wording for most of those same topics (§7) | — |
| Resource group / production resource / snapshot endpoint / incremental record type (matrix rows 1–4) | Session 180 §5 rows 1–4: UNKNOWN — INPUT NOT PROVIDED | **REFINED → EXPLICIT** | §5 S3, §7 |
| "Content Sync mechanism" named but undescribed | Session 180 §5 row 5 | **REFINED → EXPLICIT**, fully described | §5 S1–S3, S7–S8 |
| Sync token existence/requirement | Session 180 §5 row 6: UNKNOWN | **REFINED → EXPLICIT** requirement to retain one; issuance mechanism still **STILL UNKNOWN** | §7 |
| "1-week cache ceiling is a **ceiling**, not a **mandate to resync every 7 days** — conflating the two is an unsupported inference" | Session 180 §5 row 7, §10 red-team #3 | **REFINED**: the email states a **separate, explicit** 7-day resync mandate (S7) — this is no longer an inference from the caching ceiling, it is a directly stated requirement in its own right. Session 180's caution about *conflating* the two clauses remains sound methodology; it simply no longer matters, because the resync mandate is now independently confirmed by primary source | §5, §7 |
| Requirement to remain synced / apply all changes (rows 8–9) | Session 180: UNKNOWN | **REFINED → EXPLICIT** | S7 |
| Raw values / normalization at presentation layer (rows 10–11) | Session 180: repo-fact only, QF position UNKNOWN | **NEW INFORMATION** — QF's own position now stated (S12–S13); reveals a **gap** between it and current implementation (§11) | §11 |
| Local/offline storage (row 12) | Session 180: repo-fact only, applicability open (Session 164 Q-4) | **REFINED** — applicability substantially answered, conditioned on Content Sync migration | S2, S8 |
| Raw SQLite in public repo (row 13) | Session 180: repo-fact only, QF position UNKNOWN | **NEW INFORMATION** — explicit instruction to remove it before release (S11) | §10 |
| Attribution wording/link/placement (rows 14–16) — "no attribution clause exists in any located QF/Quran.com document" | Session 180 §5 rows 14–16, citing Session 164 §5.4 | **REFINED → EXPLICIT**, fully specified (S15) | §9 |
| App Store/Play distribution (row 17) — "this is exactly Session 165's Q8, unresolved" | Session 180 §5 row 17 | **REFINED → EXPLICIT**, resolved (S9) | §10, §13 |
| Free/commercial distribution (row 18) | Session 180: only S-2's ambiguous "PERSONAL, NON-COMMERCIAL" clause, applicability unresolved | **REFINED** for this dataset specifically — email states free-or-commercial distribution is permitted under the stated conditions (S9). Does not resolve S-2's applicability generally, and does not touch other datasets governed by S-2 | §10 |
| Standalone redistribution/resale (row 19) | Session 180: S-3 clause exists, applicability to this dataset unresolved | **REFINED → CONFIRMED applicable** — the same substantive restriction is now restated directly to the owner, specifically for this dataset (S10) | §6, §10 |
| Contact-before-distributing derivatives (row 20) | Session 180: not established as a standalone requirement | **REFINED → EXPLICIT**, scoped specifically to "altered derivative dataset[s]" (S14) | §11 |
| Red-team #16–19 ("Does a QF response resolve P2-2 / retroactively authorize the existing dataset / etc.?" — "Cannot be evaluated," no response was accessible) | Session 180 §10 | **NEW INFORMATION supplied; questions now evaluable** — see §15 (Red-Team Analysis) and §16 below for the actual answers | §15, §16 |
| Tafsir datasets (Session 172) — Decision C, UNKNOWN, counsel required | Session 172 | **STILL UNKNOWN — unchanged.** This email never mentions tafsir (§12) | §12 |
| Authorship/upstream ownership of the transliteration (Session 165 Q11) | Session 165 §6 | **STILL UNKNOWN — unchanged.** Not addressed by this email (§13) | §13 |
| `P2-2` OPEN, licence UNKNOWN — COUNSEL REQUIRED | Sessions 164/165/172/180, `V1_STORE_LEGAL_READINESS.md`, `RELEASE_DASHBOARD.md` | **STILL OPEN, materially advanced — see §16** | §16 |

---

## 15. Red-Team Analysis

Answering the twenty questions specified by the governing brief.
Legend: **EXPLICIT** (stated in so many words) · **INFERRED** (a
reasonable reading, not a literal statement) · **NOT STATED**.

| # | Question | Answer | Basis |
|---|---|---|---|
| 1 | Does QF explicitly identify the resource? | **EXPLICIT** | "Resource group: word_by_word_transliterations" (S3) |
| 2 | Does QF explicitly identify resource 60? | **EXPLICIT** | "Production resource ID: 60" (S3) |
| 3 | Does QF explicitly identify the old `api.qurancdn.com` endpoint? | **EXPLICIT** | "the older api.qurancdn.com/api/qdc endpoint" (S6) |
| 4 | Does QF say the July 6 2026 retrieval is covered? | **EXPLICIT, but not in the sense of "covered as-is."** QF explicitly discusses "your existing July 6 retrieval" (S5) and explicitly says that one-time copy "does not qualify for indefinite offline storage under the current Content Sync exception" (S6) — i.e., it is explicitly addressed, and explicitly told it must be *replaced*, not retained unchanged | S5–S6 |
| 5 | Does QF say the existing static SQLite copy is covered? | **EXPLICIT — no, not as-is.** QF requires removing the raw dataset from the public repository and replacing the normalized dataset with Content Sync values before release (S11–S12) | S11–S12 |
| 6 | Does QF permit offline distribution? | **EXPLICIT — yes, conditioned** | S2, S8 |
| 7 | Under what conditions? | Migrate to Content Sync; retain sync token; resync ≥ every 7 days and apply all changes; QF remains source of truth; remove raw SQLite from the public repo; replace normalized values with Content Sync values (or keep normalization as a separate, not-original-labeled presentation layer); display the stated attribution; contact QF before distributing any altered derivative; no standalone/commercial redistribution of the raw dataset without a separate written licence | §7, §8 |
| 8 | Does QF require Content Sync? | **EXPLICIT** | "provided that you migrate to Content Sync" (S2) |
| 9 | Does QF require ongoing sync? | **EXPLICIT** | S7 |
| 10 | Does QF specify a 7-day cadence? | **EXPLICIT** | "at least once every 7 days" (S7) |
| 11 | Does QF require a sync token? | **EXPLICIT** requirement to retain one; issuance/format **NOT STATED** in this email | S7 |
| 12 | Does QF require raw values to remain unmodified? | **EXPLICIT, narrowly** — altered values must not be redistributed/overwritten "as Quran Foundation content" (S12); this is a labeling/representation requirement, not a blanket ban on ever transforming the text (see Q13) | S12–S13 |
| 13 | Does QF permit normalization? | **EXPLICIT — yes, conditioned**: display-only, as a separate presentation layer, never represented as the original source | S13 |
| 14 | Does QF permit database conversion? | **EXPLICIT** that a local database used internally by the app is permitted (S8); **NOT STATED** as to "database conversion" as its own term — the email does not use that phrase or address the mechanics of how normalized values are stored | S8, S13 |
| 15 | Does QF require attribution? | **EXPLICIT** | S15 |
| 16 | What exact attribution? | **EXPLICIT** — "Quran data provided by Quran Foundation." | S15 |
| 17 | What exact URL? | **EXPLICIT** — `https://quran.foundation/` | S15 |
| 18 | Where must attribution appear? | **EXPLICIT** — "a reasonably visible About, Credits, or data-source area of the app" | S15 |
| 19 | Does QF permit commercial app-store distribution? | **EXPLICIT — yes** | S9 |
| 20 | Does QF authorize the already-existing derivative? | **EXPLICIT — not as it currently stands.** QF requires specific remediation (replace the dataset, remove the raw file from the public repo, add attribution, migrate to Content Sync) before the pathway it describes is satisfied. It authorizes a **pathway**, conditioned on those steps; it does not say the dataset as currently shipped and committed is, today, in compliance | §7, §11, §16 |

---

## 16. P2-2 Impact

Per the governing brief: **`P2-2` is not closed by this document.** What
follows states precisely what changed and what did not, without
inferring permission from silence, ownership from branding, retroactive
authorization, or legal clearance (per the brief's Phase 4 constraints).

**What changed:**

- **QDC usage status** — from "one-time build-time fetch from an
  apparently-unsupported legacy endpoint, no QF position known" to "QF
  has identified the correct current endpoint (Content Sync, resource
  60) and requires migrating off the legacy endpoint before release"
  (S1, S3, S6).
- **Content Sync requirement** — from "named in a published ToS clause,
  mechanism completely unknown, with an explicit prior caution against
  inferring a 7-day sync mandate from the caching-ceiling clause" to
  "explicitly mandatory, explicitly specified end-to-end" (§8, §14).
- **Attribution requirement** — from "no clause located anywhere" to
  "exact string, exact link, exact placement, stated directly" (§9).
- **Distribution posture** — from "unresolved whether app-store/
  commercial distribution is allowed" (Session 165's own open Q8) to
  "explicitly permitted, free or commercial, conditioned on the content
  being part of the app's end-user experience and not resold/
  redistributed as a standalone product" (§10).
- **A concrete, QF-authored, dataset-specific compliance pathway now
  exists** where none existed before this session (§14).

**What did not change:**

- **`P2-2` remains OPEN.** `docs/LICENSING.md`, `V1_STORE_LEGAL_READINESS.md`,
  and `RELEASE_DASHBOARD.md` are not edited by this document (per the
  governing brief's explicit prohibition) and none of their `P2-2` entries
  is superseded by anything stated here.
- **This is not a signed commercial licence.** S10 explicitly
  contemplates a *separate* "written commercial license" for standalone
  redistribution — this email is not that instrument, and does not
  claim to be.
- **The tafsir datasets are untouched** — Session 172's Decision C
  (UNKNOWN, counsel required) for both stands exactly as before (§12).
- **Authorship/upstream ownership of the transliteration (Session 165
  Q11) remains unanswered.**
- **The existing shipped/committed dataset is not, as-is, described as
  compliant** — remediation (§8, §9, §11) has not been implemented in
  this repository as of this session.
- **No legal/counsel review of this email has occurred.** Whether a
  developer-relations email from a named individual, Cc'd to a shared
  support alias, satisfies whatever standard Session 164/165's counsel
  questions (Q-1…Q-15, Q1…Q12) were ultimately posed to resolve is
  itself a legal question this document does not answer (§17).
- **Retroactive authorization is not addressed.** The email is entirely
  forward-looking ("before releasing the app, please...") and does not
  state a position on the period between the 2026-07-06 retrieval and
  now.

**Exact-sentence distinction (QF statement vs. legal interpretation),**
as the brief's Phase 6 requires:

> QF statement (S2): "You may keep it locally for offline use inside the
> application, provided that you migrate to Content Sync and follow the
> sync, integrity, attribution, and redistribution requirements below."

Legal interpretation (not made by this document, left to counsel per
§17): whether this sentence, from this sender, in this format,
constitutes sufficient authorization to resolve `P2-2` even after the
listed remediation is completed — including questions of the sender's
authority to bind Quran Foundation, whether email correspondence
satisfies any "written" requirement referenced elsewhere in QF's own
terms, and whether the authorization survives changes in QF policy
after the date of this email.

**Conclusion of this section, stated exactly as the brief requires:**
*the email establishes a concrete permission pathway but leaves
conditions unresolved* — specifically the conditions listed under "What
did not change," above.

---

## 17. Legal / Counsel Boundary

Unchanged in kind from Sessions 164/165/172/180: whether this email's
statements are legally sufficient to authorize the project's use of the
transliteration dataset — now, retroactively, or after the described
remediation — is a legal-interpretation question this document does not
resolve. It is recorded here as fact-finding only: an operator
(identifying themselves as Quran Foundation staff, from an
authenticated `quran.com` mail domain) made specific, written statements
about specific technical resources and specific conditions. Whether
that satisfies the standard needed to close `P2-2`, and what if
anything should be communicated to counsel, remains an owner/counsel
decision, not one made by this session. The outstanding counsel
question sets from Session 164 §9 (Q-1…Q-15) and Session 165 §6
(Q1…Q12) stand exactly as before, now with several of the Q1–Q12
questions carrying a QF-sourced answer for counsel to evaluate (§13) —
evaluating them remains counsel's task, not this document's.

---

## 18. Explicit Non-Conclusions

This document does **not** conclude, state, or imply any of the
following:

- That `P2-2` is closed, closable, or trending toward automatic
  closure without further action.
- That the transliteration dataset, as currently shipped and committed
  to the public repository, is today compliant with anything QF has
  stated.
- That this email is, or is equivalent to, a signed commercial licence.
- That the tafsir datasets are covered, addressed, or affected in any
  way.
- That Quran Foundation, Inc. owns, or has clarified ownership of, the
  underlying transliteration text.
- That the sender's statements are legally binding on Quran Foundation.
- That any term of any QF or Quran.com document has been breached,
  violated, or infringed, or that the project is or is not compliant
  with any of them.
- That removing `assets/database/quran.sqlite` from Git, or rewriting
  Git history, is authorized, recommended, decided, or under active
  implementation by this document — remediation planning is explicitly
  out of scope for this evidence-capture session (§19, §20).
- That any code, database, ADR/DR, `docs/LICENSING.md` entry, or
  governance record has been changed — none has (§22).

---

## 19. Remaining Unknowns

- How a Content Sync sync token is actually issued, authenticated, or
  rotated — not stated in the email body; likely covered by the linked
  tutorial (`https://api-docs.quran.foundation/docs/tutorials/content-sync/getting-started/`),
  which this session did not fetch (fetching and evaluating external
  documentation is implementation research, not evidence transcription,
  and was left for a future session per the brief's own scope limits).
- What a "written commercial license" for standalone redistribution
  actually requires — cost, process, term — not stated.
- Whether the Quran.com site Terms and Conditions (S-2) apply to this
  dataset or endpoint at all — not addressed by this email (Q1, §13).
- Who authored the transliteration and whether it carries its own
  upstream third-party licence (Session 165 Q11) — not addressed.
- Which version of QF's terms is operative for the 2026-07-06 retrieval
  specifically — sidestepped rather than answered (Q12, §13).
- Whether email correspondence of this kind is treated by QF, or would
  be treated by counsel, as sufficient written authorization for
  purposes of closing `P2-2` — a legal question, not a factual one
  (§17).
- Whether the sender (Basit Minhas) has organizational authority to
  bind Quran Foundation to the statements made — not established by
  anything in this file alone.
- Whether the original outbound Q1–Q12 enquiry (referenced only by
  `Message-ID` here, not included in this file) was received and read
  by QF exactly as Session 166 drafted it — this session can compare
  content but cannot independently verify what QF actually saw.

---

## 20. Recommended SESSION 183

Following the same evidence-first sequencing Session 180 §15
recommended and this session's own instructions require (**Evidence →
Requirement Contract → Architecture Decision → Implementation**, not
**Email summary → Code**):

1. **Owner decision session** (mirroring Session 165's shape): given
   this evidence, decide whether to pursue the Content Sync migration
   pathway now, defer it, or seek counsel input first — and whether to
   route the "written commercial license" and authorship (Q10/Q11)
   gaps back to QF before proceeding.
2. **If migration is authorized:** a Content Sync **requirement
   contract** session — reading the linked tutorial and snapshot-
   reference documentation (§19), scoping the actual engineering work
   (sync client, token storage, 7-day resync scheduling, presentation-
   layer normalization refactor, raw-file removal from the public
   repository, attribution string update across `app_en.arb`/
   `app_vi.arb`/`app_ar.arb`) — **before** any implementation session
   touches `lib/`, `tool/`, or `assets/database/`.
3. Independently of the migration decision, the attribution-string
   addition (§9) is a small, low-risk, reversible change the owner may
   choose to authorize on its own schedule, exactly as Session
   164/165/180 already noted for the pre-existing "I-2" option.
4. `P2-2` itself should be updated (in `docs/LICENSING.md` and
   `V1_STORE_LEGAL_READINESS.md`) **only** in a session explicitly
   authorized to edit those files, reflecting whatever the owner
   decides in step 1 — not automatically, and not by this document.

---

## 21. Validation

- Encoding: UTF-8, no BOM.
- Line endings: LF throughout.
- No trailing whitespace on any line (verified, §22 command log).
- `git diff --check`: clean (verified, §22).
- No secrets: no API keys, tokens, or credentials appear anywhere in
  this document or in the source `.eml`.
- PII minimization: the recipient's personal email address is redacted
  (§3); raw DKIM signature blocks, Gmail routing hashes, and IP
  addresses are omitted (§3) as unnecessary bulk with no evidentiary
  value beyond the pass/fail verdicts already recorded.
- Every quotation in §5–§6 is traceable to the single source file named
  in §2; none was invented, paraphrased into a "quote," or merged from
  any other document.
- No unsupported legal conclusion appears anywhere (§18 states this
  explicitly; §16's terminology follows the same discipline as Session
  180 §17's terminology-safety scan — every use of "permitted,"
  "required," "authorized," or similar is either inside a direct
  quotation of the source email, or explicitly marked as this
  document's report of what the source says, never as this document's
  own legal conclusion).
- `P2-2` status is not silently changed: §16 states in full sentences,
  twice, that it remains OPEN.
- Exactly one new file is introduced by this session: this file.

---

## 22. Primary Worktree Safety

| Check | Before this session | After this session |
|---|---|---|
| Primary worktree path | `C:\Users\Admin\Desktop\quran_companion_v0.6.0\quran_companion` | unchanged |
| Branch | `publish-docs-reconciliation-s14` | unchanged |
| HEAD | `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe` | unchanged — not checked out, reset, stashed, cleaned, pulled, rebased, edited, or committed by this session |
| `git status --porcelain` line count | 22 | unchanged (not touched by this session) |
| `git status --porcelain` content hash (SHA-256) | `96b866a3d16e33435515adaba09c3862c2843149950df776ffa36df01b6cb5cf` | unchanged (not re-measured after, by design — the primary worktree was never touched during this session) |
| Stash count | 0 | unchanged |

All work in this session occurred exclusively in
`worktrees/session182-qf-primary-source-evidence`, a fresh worktree
branched from `origin/main` at `ad947bc9ee40fb935240a1c46ce0627d546815d2`
— the same baseline Session 180 recorded, confirming `main` has not
moved since Session 180 (PR #63, containing the Session 180 document
itself, is still open and unmerged).

> **Session 190 (2026-09-03) addendum — merge-status correction.** PR #63
> merged to `origin/main` at commit `bf87aca6c5d40f7fa57c099e84ca94f9c125a0e0`
> (2026-09-03T09:23:45Z), and `SESSION_180_QF_RESPONSE_RECONCILIATION.md`
> is now present on `origin/main`. The "still open and unmerged"
> description above is historical (accurate as of this document's own
> 2026-08-31 baseline) and is left unedited; `main` moving since then is
> expected and does not reopen this document's findings.

---

## References

**Repository — evidence, unmodified by this session:**

- `docs/release/SESSION_180_QF_RESPONSE_RECONCILIATION.md` (unmerged,
  [PR #63](https://github.com/duso201189-nxp/quran-companion/pull/63))
  - _Session 190 (2026-09-03) addendum: PR #63 merged to `origin/main`
    at `bf87aca6c5d40f7fa57c099e84ca94f9c125a0e0` (2026-09-03T09:23:45Z)._
- `docs/release/SESSION_164_QDC_LICENSING_EVIDENCE_PACKET.md`
- `docs/release/SESSION_165_QDC_OWNER_DECISION_BRIEF.md`
- `docs/release/SESSION_166_QDC_EXTERNAL_ENQUIRY_DRAFT.md` (including
  its §10 Session 167 addendum)
- `docs/release/SESSION_172_TAFSIR_LICENSING_EVIDENCE_PACKET.md`
- `docs/LICENSING.md`
- `docs/release/V1_STORE_LEGAL_READINESS.md` — `P2-2`
- `RELEASE_DASHBOARD.md`
- `tool/fetch_transliteration.py`, `assets/database/quran.sqlite`
- `lib/l10n/app_en.arb`, `lib/l10n/app_vi.arb` (line 222,
  `aboutSourcesDetail`)

**External — read directly, not committed to this repository:**

- `Terms applying to word-by-word transliteration from api.qurancdn.com.eml`
  (the primary source transcribed in §5; the file itself remains
  outside this repository)
