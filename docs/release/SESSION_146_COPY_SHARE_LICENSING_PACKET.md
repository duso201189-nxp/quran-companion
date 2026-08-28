# Session 146 — Copy/Share Licensing Escalation Packet

**Status:** owner / counsel / source-provider decision packet.
**Date:** 2026-08-28.
**Baseline:** `origin/main` `155845aaecec2bf43f9f991861651ebcd905dd22`.

> **This document is NOT legal advice, and it is NOT a Terms of Use.**
> It records what the repository can be made to prove, states plainly
> what it cannot, and hands the unresolved questions to the people
> entitled to answer them. It reaches no compliance conclusion and
> grants no permission.

Every claim below is tagged:

| Tag | Meaning |
|---|---|
| **FACT** | Verified directly against `origin/main` `155845a` this session. A path and line range is given. |
| **INFERENCE** | A reasoned step from stated facts. Explicitly labelled so it can be challenged. Not a finding. |
| **UNKNOWN** | The repository does not contain the evidence. Not guessed. |
| **COUNSEL REQUIRED** | Answerable only by legal counsel or by the upstream licensor. |

The word "violation" is used **only** where an authoritative licence
term directly supports it. It does not appear as a finding anywhere in
this packet.

---

## 1. Executive summary

The app has a Copy function and a Share function that place Qur'anic
Arabic text, a transliteration, and one or two translations onto the
system clipboard. **FACT.**

Three things about that outbound payload were established this session:

1. **The payload carries no attribution of any kind.** It names no
   source, no URL, no licence, no translation version. The only
   trailing metadata is a reference of the form `— Qur'an 2:255`, plus
   the literal string ` (Qur'an Companion)` on the Share path.
   **FACT** (§6).
2. **For Ayah 1 of 112 surahs, the outbound Arabic is not byte-identical
   to the stored Tanzil text** — the leading Basmalah is removed by a
   display-layer helper that both copy paths call. **FACT** (§7).
   Whether that is prohibited text modification is **UNKNOWN /
   COUNSEL REQUIRED**.
3. **The bundled transliteration was fetched from Quran.com's QDC API
   and then editorially rewritten** before being stored. **FACT** (§8).
   No upstream redistribution permission for it is established anywhere
   in the repository. That absence is **UNKNOWN** — it is *not*
   evidence of a licence violation, and this packet does not assert one.

`docs/LICENSING.md` assesses only content **bundled in** the app. Content
flowing **out of** the app through Copy/Share is a distinct redistribution
surface that no existing document in this repository had assessed. That
gap is what this packet exists to escalate.

Nothing here blocks or clears a release. The decisions in §10–§11 are
not engineering decisions.

---

## 2. Repository baseline

| Item | Value | Evidence |
|---|---|---|
| Remote main SHA | `155845aaecec2bf43f9f991861651ebcd905dd22` | `git ls-remote origin refs/heads/main` |
| App version | `0.8.1+7` | `pubspec.yaml:4` |
| Publish target | `publish_to: 'none'` | `pubspec.yaml:3` |
| Bundled content | one asset: `assets/database/quran.sqlite` | `pubspec.yaml:56-57` |
| Monetization code | none present | `pubspec.yaml`; no ad/payment dependency |

**FACT.** No payment, subscription, or advertising code exists in `lib/`
or in `pubspec.yaml` at this baseline. This packet does not treat that as
answering any non-commercial question; it records it as a fact about the
current build only.

---

## 3. Exact Copy/Share data flow

### 3.1 Entry points — **FACT**

| Control | Handler | Location |
|---|---|---|
| Copy (`l10n.copyAyah`) | `_copyAyah(context, l10n)` | `lib/features/quran/presentation/reading/reading_screen.dart:1194-1197` |
| Share (`l10n.shareAyah`) | `_copyAyah(context, l10n, forShare: true)` | `reading_screen.dart:1200-1204` |
| Copy Arabic (`l10n.copyArabic`) | `_copy(context, l10n, arabicText!)` | `lib/features/quran/presentation/annotations/ayah_actions_sheet.dart:102` |
| Copy translation (`l10n.copyTranslation`) | `_copy(context, l10n, translationText!)` | `ayah_actions_sheet.dart:109` |

### 3.2 "Share" is a clipboard write, not an OS share sheet — **FACT**

There is no `share_plus` dependency and no platform share-sheet
invocation anywhere in `lib/`. Both Copy and Share terminate in
`Clipboard.setData` (`reading_screen.dart:1365`;
`ayah_actions_sheet.dart:198-200`). Share differs from Copy by exactly
one appended string: ` (Qur'an Companion)` (`reading_screen.dart:1364`).

**INFERENCE** (labelled as such): because the payload lands on the system
clipboard, the app has no visibility into, and no control over, where the
text is pasted afterwards. The onward destination is entirely the user's
act. This is stated so counsel can weigh it; it is not offered as a
defence, and see question **C-6**.

### 3.3 Full payload construction — **FACT**

`reading_screen.dart:1340-1365`, in order:

```
buf  = ayahDisplayText(surahId, ayahNumber, textUthmani)   // see §7
buf += '\n' + texts['translit_latin']   // if non-null
buf += '\n' + texts['vi_main']          // if non-null
buf += '\n' + texts['en_sahih']         // if non-null
buf += '\n— Qur'an {surahId}:{ayahNumber}'
buf += ' (Qur'an Companion)'            // Share path only
Clipboard.setData(ClipboardData(text: buf))
```

### 3.4 Actions-sheet payload construction — **FACT**

`ayah_actions_sheet.dart:198-200`:

```
ClipboardData(text: '{text}\n— Qur'an {surahId}:{ayahNumber}')
```

where `text` is supplied by `reading_screen.dart:1328-1333` as either:

- `arabicText` = `ayahDisplayText(...)` — the same Basmalah-stripping
  helper as §3.3; or
- `translationText` = `texts['vi_main'] ?? texts['en_sahih']`.

**FACT:** both copy paths route the Arabic through `ayahDisplayText`.
There is no path that copies the raw stored `textUthmani`.

---

## 4. The four content sources entering the payload

**FACT.** Exactly four upstream contents can appear in an outbound
payload: the Arabic text, and the three rows of `translation_sources`.

| Payload slot | Content | Source (as recorded in the shipped database) |
|---|---|---|
| Arabic | Uthmani Qur'an text | Tanzil Project |
| `translit_latin` | Latin transliteration | Quran.com / QDC |
| `vi_main` | Vietnamese translation | QuranEnc.com — Rowwad Translation Center |
| `en_sahih` | English translation | Saheeh International, obtained via Tanzil |

**These are four separate licensing positions and must not be merged.**
In particular: the Tanzil **Qur'an text** terms and the Tanzil
**translations** terms are different documents with different
restrictions; Saheeh International is a separately identified translation
that happens to be distributed *via* Tanzil; and Quran.com/QDC is **not**
QUL and **not** Tarteel (see §8.2).

---

## 5. Per-source position

Database values below are read directly from
`assets/database/quran.sqlite` (`translation_sources`, `meta`) at this
baseline — **FACT**. Licence characterisations are carried over from
`docs/LICENSING.md`, which quotes each source's own terms page verbatim.

### 5.1 Tanzil — Arabic Qur'an text

| Field | Value |
|---|---|
| Content | Uthmani Qur'an text, all 6,236 ayahs |
| Upstream source | Tanzil Project — `meta.arabic_source` = `Tanzil.net Uthmani (verified text)` |
| Licence / terms | Tanzil Terms of Use (Qur'an text) — `https://tanzil.net/download/` |
| Commercial restriction | **None stated** on the text page — **FACT** (absence of a statement, not a grant) |
| Attribution requirement | Yes — source "(Tanzil Project) is clearly indicated" |
| URL / link requirement | **Yes** — "a link is made to tanzil.net" |
| Version requirement | **UNKNOWN** — no version recorded; `meta` carries no Tanzil text version |
| Redistribution requirement | Verbatim copies permitted; **"changing the text is not allowed"** |
| Confidence | High on the terms text; the terms are quoted verbatim in `docs/LICENSING.md` |
| Authoritative evidence URL | `https://tanzil.net/download/` |

### 5.2 Quran.com / QDC — transliteration

| Field | Value |
|---|---|
| Content | Latin transliteration, word-by-word, joined per ayah, then editorially rewritten (§8.3) |
| Upstream source | `https://api.qurancdn.com/api/qdc/verses/by_chapter/...` — `tool/fetch_transliteration.py:31-34` |
| Licence / terms | **UNKNOWN** — no upstream licence statement located |
| Commercial restriction | **UNKNOWN** |
| Attribution requirement | **UNKNOWN** |
| URL / link requirement | **UNKNOWN** |
| Version requirement | **UNKNOWN** — the DB `version` value `2026-07-06` is the project's fetch date, not an upstream version |
| Redistribution requirement | **UNKNOWN** — no permission established (§8.4) |
| Confidence | **High on provenance, none on terms** |
| Authoritative evidence URL | none located |

> **FACT.** The DB row's `license` string —
> `Quran.com/QUL community data — ghi nguồn khi phân phối` — was written
> by this project's own build pipeline
> (`tool/fetch_transliteration.py:205-210` → `tool/build_quran_db.py:550`).
> **It is not a quotation of any upstream licence.** It must not be
> relied on as evidence of a grant.

### 5.3 QuranEnc — Vietnamese translation (Rowwad Translation Center)

| Field | Value |
|---|---|
| Content | Vietnamese translation of the meanings |
| Upstream source | `https://quranenc.com/en/browse/vietnamese_rwwad` |
| Licence / terms | QuranEnc conditions (seven, quoted verbatim in `docs/LICENSING.md`) |
| Commercial restriction | Not stated as such; condition 7 restricts "inappropriate advertisements" |
| Attribution requirement | **Yes** — condition 2: "clearly referring to the publisher and the source (QuranEnc.com)" |
| URL / link requirement | **Yes** — QuranEnc.com named as the source |
| Version requirement | **Yes** — condition 3: "mentioning the version number when re-publishing" |
| Version held in DB | **`1.0.8`** — present in `translation_sources.version` — **FACT** |
| Redistribution requirement | Permitted subject to the seven conditions; condition 1 forbids "modification, addition, or deletion of the content" |
| Confidence | High — conditions are published and quoted verbatim |
| Authoritative evidence URL | `https://quranenc.com/en/browse/vietnamese_rwwad` |

> **This is the sharpest mechanical gap in the packet.** The version
> number that condition 3 asks for **exists in the shipped database**
> and is **absent from the outbound payload**. Whether a clipboard
> payload is "re-publishing" is **UNKNOWN / COUNSEL REQUIRED** — see
> **C-4**.

### 5.4 Saheeh International — English translation, via Tanzil

| Field | Value |
|---|---|
| Content | English translation of the meanings |
| Upstream source | Tanzil Project translations — `https://tanzil.net/trans/` |
| Licence / terms | Tanzil **translations** terms — a different document from §5.1 |
| Commercial restriction | **Yes, explicit** — "for non-commercial purposes only" |
| Attribution requirement | Yes — source indicated |
| URL / link requirement | Back-link required only when using **more than three** translations; the app uses one, so this specific trigger is not met — **FACT** |
| Version requirement | **UNKNOWN** — `translation_sources.version` is **NULL** for `en_sahih` — **FACT** |
| Redistribution requirement | Permitted for non-commercial purposes |
| Confidence | High on the terms text |
| Authoritative evidence URL | `https://tanzil.net/trans/` |

> **Do not merge this row with §5.1.** The non-commercial restriction
> attaches to the **translation**, not to the Qur'an text. Governance
> for it lives in
> `constitution/PROJ-P-005-non-commercial-translation-license.md`
> (active) — see §11.

---

## 6. Exact payload deficiencies — **FACT**

Measured against the outbound string constructed in §3.3/§3.4:

| # | Deficiency | Detail |
|---|---|---|
| D-1 | **No source attribution** | The payload names none of the four sources. Not "Tanzil Project", not "QuranEnc.com", not "Rowwad", not "Saheeh International", not "Quran.com". The only trailing text is `— Qur'an S:A`, plus ` (Qur'an Companion)` on Share. |
| D-2 | **No source URLs** | No `tanzil.net`, no `quranenc.com`, no `quran.com`. The database holds `source_url` for all three translation rows and a link requirement in `meta.arabic_license`; none reaches the payload. |
| D-3 | **No QuranEnc version number** | `translation_sources.version` = `1.0.8` for `vi_main` in the shipped DB; the payload omits it. |
| D-4 | **No licence or copyright notices** | The payload carries no licence text, no copyright line, and no non-commercial notice — including for `en_sahih`, whose upstream terms are expressly non-commercial. |

**FACT.** All four deficiencies are properties of the payload only. The
shipped database itself records source, URL, and (for `vi_main`) version.
The data exists; the outbound path does not carry it.

**Not asserted here:** that any of D-1 … D-4 breaches any term. Each maps
to an open question in §9. **COUNSEL REQUIRED.**

---

## 7. Basmalah stripping on the outbound Arabic

### 7.1 What happens — **FACT**

`ayahDisplayText` (`lib/features/quran/domain/basmalah.dart:192-209`):

- `ayahNumber != 1` → returns `textUthmani` unchanged.
- `ayahNumber == 1`, surah classified `OpeningPrefixesFirstAyah` (the
  **112** surahs other than 1 and 9) → returns **`remainder`**: the ayah
  text after the fourth space, i.e. **with the leading Basmalah removed**
  (`splitLeadingBasmalah`, `basmalah.dart:149-163`).
- Surah 1 (`OpeningIsFirstAyah`) and surah 9 (`NoOpening`) → returns
  `textUthmani` unchanged.

Both copy paths call it: `reading_screen.dart:1348-1352` (Copy/Share) and
`reading_screen.dart:1328-1332` (actions sheet).

### 7.2 The stated finding

> **FACT — outbound Ayah 1 copy is not byte-identical to the raw Tanzil
> text.** For Ayah 1 of those 112 surahs, the text placed on the
> clipboard is the stored Tanzil ayah with its leading Basmalah removed.

Two qualifications, both **FACT**:

- **The stored data is unmodified.** The removal happens in the
  presentation layer on the way out; `assets/database/quran.sqlite`
  retains the complete ayah text. `basmalah.dart:13-16` states the
  intent explicitly: the Basmalah is authentic scriptural text of Ayah 1
  and the data is deliberately not altered.
- **In the UI, the removed Basmalah is re-displayed** as a separate
  header element in List mode, so the reader still sees it.
  **It is not re-added to the clipboard payload.** The compensating
  header exists only on screen.

### 7.3 The question

> **UNKNOWN / COUNSEL REQUIRED.** Whether removing the leading Basmalah
> from an outbound copy of Ayah 1 constitutes "changing the text" within
> the meaning of Tanzil's term *"changing the text is not allowed"*, or
> whether it is a permissible display/excerpting convention that does not
> engage that term.

This packet does **not** answer it, and does **not** characterise the
behaviour as a violation. The engineering intent was a display
convention (`basmalah.dart:189-191` scopes the helper to List mode and
says it must not be used for Mushaf/Focus); whether that intent is
legally relevant is exactly what counsel must decide. See **C-2**.

---

## 8. Transliteration

### 8.1 Provenance — **FACT**

The bundled transliteration was fetched over HTTP from:

```
https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}
  ?words=true&word_fields=transliteration,text_uthmani
  &per_page=50&page={page}
```

`tool/fetch_transliteration.py:31-34`. That is the **Quran.com QDC**
API. The script's own docstring (`:1-15`) describes it as "Quran.com
word-by-word transliteration" and states it is the single source of
transliteration in the app.

### 8.2 Naming discipline — **FACT**

Quran.com / QDC (`api.qurancdn.com`) is **not** QUL
(`qul.tarteel.ai`) and **not** Tarteel. `docs/LICENSING.md` quotes the
QUL FAQ in places and labels the transliteration row
"Quran.com / QUL (Tarteel AI)"; the fetch path proves the shipped bytes
came from the QDC API. **Any analysis that reasons from QUL's FAQ to the
shipped transliteration is reasoning about the wrong endpoint.**
Separately — and this is the point QUL's own FAQ makes — QUL disclaims
warranting the licence of anything it hosts, so even a correct QUL
citation would not establish a grant.

### 8.3 The shipped bytes are a modified derivative — **FACT**

`tool/fetch_transliteration.py:55-90+` applies a unified editorial
normalization before storage:

- `ALLAH_MAP` rewrites the divine name with capitalisation and full
  macrons (`l-lahi` → `Allāhi`, and 14 further forms).
- ASCII `'` is reinterpreted: hamza after a vowel → `ʾ`; after a
  consonant → deleted as a redundant syllable break.
- `ʿayn` is unified to `ʿ`.
- Long-vowel junctures (`āa`, `īi`, `ūu`, …) receive an inserted `ʾ`.

**The app does not redistribute the upstream transliteration verbatim.**
It redistributes a systematically rewritten derivative of it.

### 8.4 Evidence position — stated precisely

- **FACT.** No upstream licence statement for this transliteration has
  been located, in this repository or cited by it.
- **FACT.** The `license` string in the database is the project's own
  wording, not an upstream quotation (§5.2).
- **UNKNOWN.** Whether redistribution — bundled, or outbound via
  Copy/Share — is permitted, and on what conditions.
- **Explicitly stated:** **the current evidence does NOT justify claiming
  a licence violation.** Absence of a located permission is absence of
  evidence, not evidence of infringement. This packet asserts no breach.
- **UNKNOWN.** Whether the §8.3 editorial rewriting would itself engage
  any upstream restriction, were one to exist.

### 8.5 Decision paths — presented, not chosen

Three paths are available. **This packet deliberately selects none of
them**; the choice is the owner's, informed by counsel.

1. **Obtain written permission** from Quran.com for redistribution of
   the transliteration (bundled and outbound), covering the derivative
   in §8.3.
2. **Replace** the transliteration with a source whose terms are
   established.
3. **Remove** the transliteration from the shipped database and from the
   Copy/Share payload.

**INFERENCE**, labelled: path 1 preserves current behaviour and is the
only path that requires no data or code change, but it depends on a third
party's response and cannot be scheduled. Paths 2 and 3 are within the
project's own control. Nothing follows automatically from this
observation.

---

## 9. Copy/Share legal questions C-1 … C-6

> **Provenance note — FACT.** Session 145 left no artifact in this
> repository. The six questions below were reconstructed this session
> from the verified facts in §3–§8 and carry the C-numbering used in the
> Session 146 brief. If a Session 145 record with different numbering
> exists outside this repository, reconcile against it before relying on
> these identifiers.

- **C-1 — Attribution on outbound Arabic.** Does placing the Tanzil
  Arabic text on the clipboard constitute distribution engaging Tanzil's
  conditions? If so, does a payload carrying neither "Tanzil Project" nor
  a `tanzil.net` link (D-1, D-2) meet them — and is in-app attribution on
  a different screen (Profile → Data sources) capable of satisfying a
  condition attached to the distributed copy itself? **COUNSEL
  REQUIRED.**
- **C-2 — Basmalah removal.** Does §7 constitute "changing the text" as
  Tanzil's term uses that phrase? **COUNSEL REQUIRED.**
- **C-3 — Saheeh International outbound.** Does outbound copying of the
  `en_sahih` translation fall within Tanzil's *translations* terms, and
  does an unattributed payload with no non-commercial notice (D-1, D-4)
  satisfy them? Distinct from the monetization question already governed
  by `PROJ-P-005`. **COUNSEL REQUIRED.**
- **C-4 — QuranEnc conditions 2 and 3.** Is a clipboard payload
  "re-publishing the translation"? If yes, the payload omits both the
  publisher/QuranEnc.com reference (condition 2) and the version number
  `1.0.8` (condition 3), which the database holds. **COUNSEL REQUIRED.**
- **C-5 — Transliteration redistribution.** Given no located upstream
  terms (§8.4), on what basis may the editorially rewritten Quran.com/QDC
  transliteration be redistributed outbound, and what attribution — if
  any — is owed? **UNKNOWN / COUNSEL REQUIRED.**
- **C-6 — Locus of responsibility.** Where the app composes and places
  the payload but the user chooses its destination (§3.2), does the
  attribution obligation attach at composition, at paste, or at both?
  Does the app's lack of downstream control alter its obligations at the
  point of composition? **COUNSEL REQUIRED.**

---

## 10. Owner decisions required

None of these are engineering decisions. None is taken in this packet.

- **O-1.** Whether to seek written clarification from **Tanzil** on C-1
  and C-2, and who signs that request.
- **O-2.** Whether to seek written clarification from **QuranEnc** on
  C-4.
- **O-3.** Whether to pursue **path 1, 2, or 3** for the transliteration
  (§8.5) — including whether to pursue a fallback in parallel rather than
  waiting on a third-party reply.
- **O-4.** Whether the Copy/Share feature ships in v1.0 **as-is**, ships
  **modified**, or is **withheld** pending answers to C-1 … C-6.
- **O-5.** Whether the `PROJ-P-005` scope mismatch (§11) is corrected
  before v1.0, and by what governance route.
- **O-6.** Whether to commission counsel for C-1 … C-6 as one instruction
  or to fold them into the already-open `P0-2` Tanzil review
  (`docs/release/V1_STORE_LEGAL_READINESS.md`).

---

## 11. PROJ-P-005 governance mismatch

**FACT + GOVERNANCE REVIEW REQUIRED.**

`constitution/PROJ-P-005-non-commercial-translation-license.md:15-18`
reads:

> "Tanzil's translation and transliteration data (English Sahih
> International, transliteration) is licensed non-commercial."

Against the baseline:

- **FACT.** The shipped transliteration is **not** Tanzil data. It was
  fetched from `api.qurancdn.com` (Quran.com/QDC) — §8.1 — and the
  database records its source as `https://quran.com`, not `tanzil.net`.
- **FACT.** `tool/fetch_transliteration.py:1-8` states in terms that
  `build_quran_db.py` prefers this file **instead of** Tanzil, which
  indicates the transliteration source was changed at some point after
  `PROJ-P-005` was written.
- **INFERENCE**, labelled: the `PROJ-P-005` wording appears to have gone
  stale when the transliteration source changed, rather than having been
  wrong when written.

Consequences, stated without resolving them:

1. The transliteration is currently scoped by a constraint that names the
   **wrong upstream licensor**.
2. Because Quran.com/QDC's terms are **UNKNOWN** (§5.2), it cannot be
   said whether `PROJ-P-005`'s non-commercial constraint is too strict,
   too loose, or accidentally correct for the source actually shipping.
3. The constraint remains **fully valid for `en_sahih`**, whose Tanzil
   translations terms are expressly non-commercial (§5.4). Only the
   transliteration half of its scope is in question.

**This packet does not decide how the constitution should be changed, and
`constitution/PROJ-P-005-non-commercial-translation-license.md` was NOT
modified by Session 146.** Amending a constitution-tier constraint is a
governance act requiring its own decision record and the `release-owner`
role named in that file's front-matter.

---

## 12. Counsel questions

Consolidated instruction for external counsel:

1. **C-1 … C-6** (§9), each answered on its own terms.
2. Does in-app attribution on a **separate screen** discharge an
   attribution condition attached to a **distributed copy**? This
   underlies C-1, C-3, and C-4 jointly.
3. Is a **clipboard write** distribution / re-publication for the purpose
   of each of the four sources' terms (§4)? A single answer may not hold
   across all four.
4. Does the §8.3 **editorial derivative** change the analysis under any
   term that would otherwise permit verbatim redistribution?
5. Does the §7 **Basmalah removal** engage Tanzil's no-modification term,
   given the stored data is unmodified and the UI re-displays the
   Basmalah separately but the clipboard payload does not?
6. Is the **already-open `P0-2`** Tanzil translation review the right
   vehicle for C-1/C-2/C-3, or do the outbound questions need separate
   instruction?

---

## 13. Evidence still missing

Listed so nobody re-derives the same absence:

| # | Missing evidence | Bearing on |
|---|---|---|
| E-1 | Any published licence statement for the Quran.com/QDC transliteration | C-5, §8.4, §11 |
| E-2 | Any Tanzil statement on whether excerpting/omitting the Basmalah engages "changing the text" | C-2 |
| E-3 | Any Tanzil statement on whether attribution must travel **with** a copied excerpt | C-1, C-3 |
| E-4 | Any QuranEnc statement on whether user-initiated copying is "re-publishing" | C-4 |
| E-5 | A version identifier for the Tanzil `en_sahih` text (DB `version` is NULL) | §5.4 |
| E-6 | A version identifier for the Tanzil Arabic text (`meta` records none) | §5.1 |
| E-7 | Any record of outreach to Quran.com, Tanzil, or QuranEnc on these points | O-1, O-2, O-3 |

**FACT.** For E-7 specifically: this repository contains no evidence that
such a request was sent, **and no evidence that one was not**. It is
recorded as unknown in both directions.

---

## 14. Recommended decision order

Ordering only — each step remains the owner's to take or decline.

1. **§11 first.** The `PROJ-P-005` scope mismatch is a governance fact
   already established. It needs no third party and blocks clear thinking
   about everything downstream of it.
2. **O-3 / E-1 next.** The transliteration is the only payload component
   with *no* located terms at all. It is also the only one the project can
   unilaterally replace or remove.
3. **O-1 / O-2 in parallel.** Tanzil and QuranEnc clarifications are
   third-party-dependent and have the longest lead time. Start them early;
   do not sequence them behind anything.
4. **O-6, then counsel (§12).** Deciding whether to fold C-1 … C-6 into
   the open `P0-2` instruction is cheap and shapes the whole engagement.
5. **O-4 last.** Whether Copy/Share ships as-is is answerable only once
   1–4 have returned. Deciding it earlier would be deciding it without
   the inputs.

**INFERENCE**, labelled: this ordering optimises for lead time and for
unblocking the items under the project's own control first. It is not a
recommendation about *what* to decide.

---

## 15. Terms of Use cannot cure upstream licensing

> **A Terms of Use document cannot grant rights the app does not itself
> possess from its upstream licensors.**

If Tanzil, QuranEnc, or the transliteration's owner do not permit a given
redistribution, no clause the project writes for its own users creates
that permission. A Terms of Use governs the relationship between the
project and its users; it has no effect on the relationship between the
project and its licensors, and it cannot be used to pass along rights
that were never obtained.

**FACT:** no Terms of Use exists in this repository at this baseline, and
**Session 146 did not draft one.** It is recorded as still outstanding in
`docs/release/V1_STORE_LEGAL_READINESS.md` (P0-1). This section exists so
that a future Terms of Use is not mistaken for an answer to §9.

---

## 16. What this packet explicitly does not conclude

- It does **not** conclude that any licence has been breached.
- It does **not** conclude that the current Copy/Share behaviour is
  compliant.
- It does **not** clear, or block, any release.
- It does **not** resolve C-1 … C-6, or any question marked UNKNOWN.
- It does **not** decide the transliteration path (§8.5).
- It does **not** amend, or propose specific wording for, `PROJ-P-005`.
- It does **not** constitute legal advice, and it is **not** a Terms of
  Use.

---

## 17. References

- `docs/LICENSING.md` — bundled-content licence record, including the
  Session 146 corrections
- `docs/release/V1_STORE_LEGAL_READINESS.md` — P0-1, P0-2, P1-4, P2-2
- `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md` — bundled-content packet
  (F1–F6, U1–U6); note its **U2 is superseded** by the corrected P1-4
- `constitution/PROJ-P-005-non-commercial-translation-license.md` — not
  modified by Session 146
- `lib/features/quran/presentation/reading/reading_screen.dart`
- `lib/features/quran/presentation/annotations/ayah_actions_sheet.dart`
- `lib/features/quran/domain/basmalah.dart`
- `lib/features/profile/presentation/profile_screen.dart`
- `tool/fetch_transliteration.py`, `tool/build_quran_db.py`
- `assets/database/quran.sqlite` — `translation_sources`, `meta`
