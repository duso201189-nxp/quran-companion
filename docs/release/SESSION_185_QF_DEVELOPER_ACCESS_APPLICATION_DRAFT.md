# Session 185 — QF Developer Access Application Draft

**Status: DRAFT CONTENT ONLY. Not submitted. Not sent. No account,
credential, or application has been created by this or any prior
Claude session.**

This document exists so the **owner** can copy its content into the
Quran Foundation ("QF") Developer Console
(`https://dev-console.quran.foundation/projects`) when the owner
personally decides to create a developer account and request API
access. Creating that account, and submitting any request through it,
is an Owner Gate — see [`SESSION_185_IMPLEMENTATION_READINESS.md`](SESSION_185_IMPLEMENTATION_READINESS.md)
§Owner Gates and the governing Session 185 brief's own standing
tool-use rule ("Creating accounts… entering passwords to authenticate"
is prohibited for any Claude session to perform on the user's behalf).

No field below contains a placeholder credential. No field below
asserts a legal conclusion, a licence grant, or QF's prior approval of
anything not already evidenced in this repository (`docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`,
PR #64, and `docs/release/SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`,
merged via PR #66).

---

## 1. Project identity

| Field | Value |
|---|---|
| Application name | Quran Companion |
| Repository | `https://github.com/duso201189-nxp/quran-companion` (private-by-default developer repository; the shipped app is the distribution channel, not the repository itself) |
| Platform | Flutter — Android, iOS, Web |
| Android application ID | `com.duso.qurancompanion` |
| Current distribution | Not yet released to a public app store. Pre-release / development. |
| Application type (per QF's own distinction) | **Backend/server component required.** QF's quickstart documentation states Content Sync's OAuth2 `client_credentials` flow is for **"a Backend/server app"** and that `client_secret` must be **"kept on the server only."** The shipped Flutter client itself will not hold QF credentials — see §6. The credential-holding component is a scheduled CI/data-pipeline job, not the mobile/web app. |
| Contact (owner) | `[OWNER TO COMPLETE — name and preferred email]` |
| Contact (technical) | `[OWNER TO COMPLETE — same or different]` |

## 2. Intended use

Quran Companion is a Qur'an study application (reading, transliteration,
translation, tafsir, memorization tools). It currently displays
word-by-word Latin transliteration sourced from a legacy one-time
static fetch of `api.qurancdn.com/api/qdc` (Quran.com's QDC endpoint).

**Intended use of QF's Content Sync API:** replace that legacy,
unsynced, licensing-unclear fetch with QF's own supported, ongoing
Content Sync mechanism for the same underlying dataset — word-by-word
transliteration — as QF's own primary-source correspondence with this
project's owner has already indicated is the correct path forward
(`SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`, quoted clauses S1–S15).

This is a **migration to a QF-supported, compliant acquisition
mechanism** for a dataset the app already displays — not a new feature
built on previously unlicensed access.

## 3. Resource requested

| Field | Value |
|---|---|
| Resource group | `word_by_word_transliterations` |
| Resource ID | `60` |
| Content type | `word_transliteration` records (word-by-word Latin transliteration) |
| Access pattern | Content Sync API — bootstrap (`GET /resources/sync?bootstrap=true`) then incremental (`GET /resources/sync?sync_token=…`), per QF's official Content Sync tutorial |
| Environment requested first | **Pre-live** (`prelive-oauth2.quran.foundation` / `apis-prelive.quran.foundation`), consistent with QF's own guidance that "new apps begin in pre-live." Production access to be requested only after pre-live integration is proven. |

## 4. Intended distribution

The dataset is consumed **only** to render Qur'anic word-by-word
transliteration inside the Quran Companion end-user application
experience (mobile/web reading UI). It is:

- **Not** distributed as a standalone downloadable file, dataset,
  data feed, or API by this project (§7).
- **Not** published as a raw SQLite database, JSON export, or any
  other machine-readable artifact accessible outside the compiled
  application (§8).
- Consumed via a build-time data pipeline that produces a private,
  versioned database artifact, which is then bundled into the
  compiled application binary — the same mechanism already used for
  this project's other third-party Qur'anic content sources (Tanzil
  Arabic text, QuranEnc Vietnamese translation).

## 5. Free / commercial context

Quran Companion is currently distributed **free of charge**, with
**no monetization implemented** — no purchases, no subscriptions, no
advertising. This project's own governance record
(`PROJ-P-005`, `constitution/PROJ-P-005-non-commercial-translation-license.md`)
treats *any future move toward monetization* as a licensing blocker
requiring separate review before it may happen, because at least one
other data source already used by this app (Tanzil's translation and
transliteration data) is licensed non-commercial. This application
draft does not request, and does not need, any commercial-use grant
from QF at this time. If that changes in the future, this project's
own stated practice (§14 below) is to seek a fresh review before
acting, not to assume continuity of a free-tier grant into a
commercial context.

## 6. Content Sync compliance intent

This section states intent, not a claim of present compliance — `P2-2`
(the transliteration-licensing item this migration addresses) remains
**open** in this project's release tracking until the items below are
actually implemented and verified (see `docs/release/SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
§6, requirements R01–R20).

- **No runtime credential exposure.** The mobile/web application will
  never hold QF's `client_id`/`client_secret`. Only a server-side
  (CI) component will authenticate to QF's Content Sync API, per
  QF's own "keep `client_secret` on the server only" guidance.
- **Ongoing sync, not a one-time copy.** A scheduled process will call
  the incremental sync endpoint on an interval strictly under 7 days,
  storing and advancing QF's `sync_token` per QF's documented ordering
  rules (apply every `snapshot_url` before persisting a token on
  bootstrap; persist `next_sync_token` only from the final page of an
  incremental run).
- **QF remains the source of truth.** The legacy `api.qurancdn.com/api/qdc`
  one-time fetch is retired for this dataset once migration completes.

## 7. Sync frequency

**At most every 7 days**, matching QF's own Developer Terms — "Cache or
store QF Content longer than 1 week" is prohibited generally, with an
explicit exception for apps using the Content Sync API provided they
"perform a next sync" at least every 7 days and apply the changes.
This project's planned cadence is daily-to-every-3-days (via a
scheduled CI job) specifically to absorb one missed run without
breaching that 7-day ceiling.

## 8. Attribution commitment

This project commits to displaying, in every shipped locale (Vietnamese,
English, Arabic), the exact string and link QF's own correspondence
specifies:

> `Quran data provided by Quran Foundation.` — with "Quran Foundation"
> hyperlinked to `https://quran.foundation/`.

Placement: the application's existing About/Credits/data-sources
screen, alongside its existing attributions to Tanzil, QuranEnc,
EveryAyah, and KFGQPC. This is treated as a real, tappable hyperlink
in the shipped UI, not plain unlinked text.

## 9. No standalone dataset resale

This project will not sell, sublicense, or redistribute QF Content or
raw Content Sync API data as a standalone dataset, data feed, API,
content package, or other separately distributed product, consistent
with QF's own Developer Terms, which reserve that specifically to a
separate signed commercial license this project is not requesting.

## 10. No public raw SQLite / no public raw dataset file

The word-by-word transliteration data obtained via Content Sync will
**not** be committed to this project's git repository in raw form, and
will not be published as a standalone downloadable file (SQLite
database, JSON, or otherwise) anywhere this project controls. This is
consistent with this project's own pre-existing, independently-reached
architectural decision (`docs/adr/DR-2026-0008-content-distribution-strategy.md`
— not yet formally ratified onto this repository's `main` branch as of
this document's date; see `SESSION_185_IMPLEMENTATION_READINESS.md`
§Governance) that no third-party licensed content is committed to a
public repository, reached independently of and prior to QF's own
correspondence on this same point.

## 11. Normalization boundary

QF's word-by-word transliteration values will be stored **unaltered**
as received (the "raw" layer). A separate, deterministic,
project-authored normalization step (spelling standardization —
e.g. rendering variant forms of "Allah" consistently) is applied only
when producing a distinct **presentation layer** for display, and is
never written back over, or represented as, QF's original returned
value. The two layers are never conflated in storage or in any
external-facing description of the data.

## 12. Security of credentials

- `client_id`/`client_secret` will be created and held **only by the
  project owner**, who will store them in CI environment secrets
  (this project already operates a separate, unrelated private-storage
  credential pair — Cloudflare R2 read/publish tokens — under this
  same discipline: never committed to git, environment-scoped,
  read-only tier separated from write-capable tier).
- No Claude Code session, and no automated agent, will create, receive,
  handle, view, or transmit the actual `client_id`/`client_secret`
  values at any point. Provisioning them into CI secrets is itself
  listed as an Owner Gate action.
- The sync token (distinct from the OAuth credential) is treated as
  private runtime state, not a public artifact, though it does not
  require the same secrecy tier as `client_secret`.

## 13. Contact placeholders

| Field | Value |
|---|---|
| Submitting individual | `[OWNER TO COMPLETE]` |
| Organization (if QF's form asks) | `[OWNER TO COMPLETE — likely "Individual developer" or the owner's own framing]` |
| Application/project URL to reference | `[OWNER TO COMPLETE — repository URL is private; owner may prefer to describe the app rather than link a private repo]` |
| Expected go-live timeframe | `[OWNER TO COMPLETE — implementation has not started; see SESSION_185_IMPLEMENTATION_READINESS.md §Phase 1 Scope]` |

## 14. Explicit non-claims

This document does **not**:

- Claim QF has approved, reviewed, or been shown this specific
  application draft.
- Claim any license clearance for `P2-2` — that item stays open
  pending counsel review (`SESSION_185_QF_COUNSEL_ROUTING_PACKET.md`)
  regardless of whether QF grants API access.
- Constitute, or authorize any session to treat this as, a submitted
  application.
- Commit this project to any specific timeline for requesting or using
  production (as opposed to pre-live) access.

---

**Prepared by:** Session 185 (2026-09-03), drafted from primary-source
QF correspondence and QF's own published developer documentation,
building on Sessions 164–184's evidence chain. **For owner review and
owner-initiated submission only.**
