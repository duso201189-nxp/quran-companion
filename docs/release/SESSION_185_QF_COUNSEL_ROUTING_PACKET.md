# Session 185 — QF/P2-2 Counsel Routing Packet

**Purpose of this document:** give counsel every fact needed to review
`P2-2` (the Latin word-by-word transliteration licensing gap) without
reconstructing 21 sessions of history. It consolidates, but does not
re-decide, findings already recorded in Sessions 164–184.

**This document is NOT legal advice, is NOT a legal conclusion, and
does NOT constitute or claim any license clearance.** Every technical
document referenced below (including this one) is written by an
engineering-assistant process, not by counsel, and says so explicitly
wherever it draws a line between fact and legal interpretation. See
§O.

**Routing status:** this packet has been **drafted**, not sent. Sending
it to counsel is an Owner Gate action (§16 of the Session 184 contract,
R30). No prior session has routed anything to counsel.

---

## A. Executive summary

Quran Companion, a Flutter Qur'an study app, displays Latin word-by-word
transliteration of the Qur'an sourced from a one-time static fetch
(2026, exact date in `docs/DATA_PIPELINE.md`) of `api.qurancdn.com/api/qdc`
— an endpoint operated by Quran Foundation ("QF"), the organization
that also operates Quran.com. That fetch:

1. was never re-synced since;
2. has no located, explicit, dataset-specific license grant covering
   embedding this data in a redistributed application;
3. is currently stored as a build-time-normalized dataset committed to
   this project's public GitHub repository, with no raw/unaltered copy
   retained separately from the normalized one; and
4. is baked into a SQLite database (`assets/database/quran.sqlite`,
   ~20 MB) also committed to the public repository.

QF has since responded, unprompted by any formal legal request, to an
informal outreach from this project's owner, with an email (quoted
verbatim, clause-by-clause, in `SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`)
that describes conditions under which this kind of use is acceptable —
conditions this project has not yet met. This project's own engineering
process has translated that email plus QF's official developer
documentation into a technical requirement contract and architecture
plan (`SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`, merged),
but **implementation has not started**, and no session has treated the
email as a legal green light. `P2-2` remains tracked **OPEN** as a v1.0
release blocker.

**What counsel is being asked to help with:** whether the QF email,
read together with QF's public Developer Terms, is sufficient
authorization to continue and to migrate this use as planned — and, if
not, what additional step (a written commercial-style permission, an
explicit written clearance, git-history remediation, or something else)
would be needed before `P2-2` could be considered closed.

## B. Current P2-2 status

Tracked in `RELEASE_DASHBOARD.md` and `docs/release/V1_STORE_LEGAL_READINESS.md`
on this repository's `main` branch (both files independently confirmed
this session, 2026-09-03, at commit `63483fb`):

> **P2-2 — OPEN.** Transliteration source (Quran.com QDC) is not yet
> confirmed licensed for this project's redistribution model.

No session in this project's history has closed, or recommended
closing, this item. The most recent technical planning document
(`SESSION_184_...REQUIREMENT_CONTRACT.md`, R29) states explicitly that
`P2-2` stays open until, at minimum: attribution is added, the raw
dataset is no longer newly committed to the public repository, an
ongoing sync mechanism exists and has run at least once, **and** —
the item directly relevant to counsel — "counsel input sought or
explicitly, knowingly deferred by the owner."

## C. QF primary-source evidence

Full verbatim transcription with context: `docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`
(currently on **open, unmerged** pull request [#64](https://github.com/duso201189-nxp/quran-companion/pull/64) —
its content has been independently re-read and cross-checked by the
later, merged `SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md` (PR #65)
and `SESSION_184_...REQUIREMENT_CONTRACT.md` (PR #66), both on `main`).
Key clauses, as previously numbered S1–S15 in that transcription:

- **S1/S6** — the prior one-time copy "does not qualify for indefinite
  offline storage"; QF frames continued use as conditioned on migrating
  to their supported Content Sync mechanism.
- **S2/S7** — ongoing storage is conditioned on: replacing the static
  snapshot, retaining a sync token, resyncing at least every 7 days,
  and treating QF as the continuing source of truth.
- **S8** — QF explicitly permits "a local database used internally by
  the installed application" — i.e., on-device storage for app
  functionality is not itself the concern.
- **S10** — a "written commercial license" pathway is referenced for
  some distribution models; this project's own technical analysis
  reads this as likely not triggered by an embed-in-app, free,
  non-commercial distribution model, but **flags this as
  not-yet-confirmed rather than asserted** (§K below is exactly this
  open question for counsel).
- **S11** — an instruction to remove the raw file from the public
  repository before release.
- **S12/S13** — normalization/editorial changes must not be
  represented as unaltered original QF content; a raw/normalized
  separation is required.
- **S14** — a request to be contacted before any derivative dataset is
  distributed.
- **S15** — a specific attribution string and link QF asks to be
  displayed: `Quran data provided by Quran Foundation.`, linked to
  `https://quran.foundation/`.

**What this evidence is not:** a formal written license, a signed
agreement, or a document that uses the word "license" for this specific
use case. It is an email response to informal outreach. Whether an
email of this kind is legally sufficient authorization for a shipped,
redistributed application is exactly the question this packet routes
to counsel (§M).

## D. Content Sync API requirements (independently verified this
session and Session 184 against QF's own published documentation)

- Resource: `resource_group=word_by_word_transliterations`,
  `resource_id=60`.
- Auth: OAuth2 `client_credentials` grant, `content` scope, against
  `prelive-oauth2.quran.foundation` (or `oauth2.quran.foundation` in
  production) — a **backend/server-only** credential; QF's own
  documentation states "Keep `client_secret` on the server only."
- Developer Terms (`https://api-docs.quran.foundation/legal/developer-terms/`,
  independently fetched this session): content may not be cached/stored
  longer than **1 week**, except that apps using the Content Sync API
  may retain it indefinitely provided they "perform a next sync" at
  least every 7 days; QF Content and raw API data "are not sold,
  sublicensed, or redistributed" without a separate signed commercial
  license.

These are QF's own general, standing terms — not something written
specifically for this project's email exchange, which independently
corroborates that S2/S6/S7 (§C) reflect a real, general policy rather
than an ad hoc reply.

## E. Current repository state (verified this session, 2026-09-03,
`origin/main` at `63483fba8bfd8cca4c9fa2294cb6e0785b1a33eb`)

- `assets/database/quran.sqlite` — tracked, committed, ~20 MB, contains
  the transliteration data among five other content sources.
- `tool/data/transliteration.json` — tracked, committed; schema is
  `{"ayahs": {key: <single normalized string>}}` — **one value per
  entry, no raw/unaltered layer retained separately from the
  normalized one**.
- `tool/fetch_transliteration.py` — the one-time fetch script;
  performs normalization (`ALLAH_MAP`, `standardize_token`,
  `normalize_words`) before the single value is ever written to disk.
- No ongoing sync mechanism of any kind exists today for this dataset.
- `test/repository_boundary_test.dart` (on `main`) explicitly
  grandfathers both files above out of its "no restricted content in
  the public repository" gate, with a code comment citing a decision
  record (`DR-2026-0008`) that is **itself not present on `main`** —
  see §I below.

## F. The `quran.sqlite` issue

The single committed database file bundles this transliteration data
together with five other third-party content sources (Tanzil Arabic
text, Saheeh International translation, QuranEnc Vietnamese
translation, two tafsir corpora, surah names). A remediation for the
transliteration data specifically must not be assumed to also resolve,
or to leave unaffected, the licensing posture of the other five —
those are tracked as **separate, already-distinct items** in this
project's release-legal inventory (`V1_STORE_LEGAL_READINESS.md`) and
are explicitly **out of scope** for this packet.

## G. The historical-copy issue

The current data is a **static one-time copy**, not a live QF-managed
feed. It has not been re-synchronized since it was fetched. QF's own
position (§C, S1/S6) is that this specific fact — a one-time copy with
no ongoing sync relationship — is the thing that does not qualify for
continued indefinite storage, independent of any other consideration.

## H. Attribution

No attribution to QF currently appears anywhere in the shipped
application. QF's own request (§C, S15) specifies exact wording and a
hyperlink. This project's release-legal inventory has previously
flagged, for a *different* source (Tanzil), the identical defect class
of a non-hyperlinked attribution string (`P1-4` in
`V1_STORE_LEGAL_READINESS.md`) — the same mistake must not recur for
QF.

## I. Normalization

The single stored value per word/ayah has already been passed through
project-authored spelling-normalization logic (`ALLAH_MAP`,
`standardize_token`) before storage. There is no way, today, to
recover what QF's API actually returned versus what this project's own
code computed. QF's own request (§C, S12/S13) is that normalized/
edited values never be represented as unaltered original QF content —
a condition the current single-value storage schema cannot
demonstrate compliance with, because it does not retain both forms.

## J. Commercial / app-store distribution terms

The app is currently **free, with no monetization implemented** —
no purchases, ads, or subscriptions (`PROJ-P-005`, this project's own
constitution-tier constraint, already treats *any* future monetization
as blocked pending separate licensing review, because at least one
other data source in the same database, Tanzil's translation and
transliteration text, is licensed non-commercial). QF's own Developer
Terms (§D) reference a distinct "written commercial license" pathway
for something described as selling/sublicensing/redistributing content
"as a dataset, data feed, API, content package, or other separately
distributed product" — this project's own technical reading is that an
embed-in-a-free-app model is a different act from that, but this is
exactly the kind of reading counsel is being asked to confirm or
correct (§M).

## K. The derivative-dataset question

QF's email (§C, S14) asks to be contacted before any "derivative
dataset" is distributed. This project's technical plan does not
currently intend to distribute the transliteration data as a
standalone dataset in any form — only to embed it, normalized, inside
the compiled application, as it does today for five other content
sources. Whether the *normalized presentation layer* itself — as
opposed to the raw layer — could be read as a "derivative dataset"
under S14 if it were ever exposed outside the compiled binary (e.g., a
future public API, a website) is an open question this project has not
needed to answer yet, because no such exposure is currently planned or
built.

## L. The Git history question

**Explicitly out of scope for this packet, exactly as it has been out
of scope for every prior session in this chain (Sessions 164–184).**
This project's public git repository history retains prior committed
versions of both the transliteration JSON and the SQLite database
containing it, regardless of any future decision to stop tracking
those files going forward. No session has recommended, planned, or
begun any git-history rewrite. This is recorded here as a fact counsel
should be aware exists, not as a question this packet asks counsel to
resolve — the owner has not raised it, and this document does not raise
it on the owner's behalf. If counsel's answer to §M below implicates
git history, that will surface from counsel's own analysis, not from
a leading question in this packet.

## M. Exact legal questions

Phrased to avoid presupposing an answer, per this session's own
governing instruction not to lead counsel toward a predetermined
conclusion:

1. Does the QF email quoted in `SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`
   (§C above), read together with QF's publicly published Developer
   Terms, constitute sufficient authorization for this project to
   continue displaying QF-sourced word-by-word transliteration data in
   a shipped, free, non-commercial mobile/web application, **provided**
   the technical conditions in that email (ongoing Content Sync,
   attribution, raw-file removal from the public repository,
   raw/normalized separation) are actually implemented?
2. If not sufficient on its own, what additional step — a formal
   written permission request and response, a signed license, an
   explicit written confirmation from QF that this specific use case
   is covered, or something else — would be needed, and from whom at
   QF should it be sought?
3. Does this project's current *free, non-commercial* distribution
   model fall inside or outside the "written commercial license"
   pathway QF's Developer Terms reference for selling/redistributing
   content "as a dataset, data feed, API, content package, or other
   separately distributed product" (§D, §J)? Put differently: is
   bundling normalized QF-sourced data inside a compiled application
   binary, with no separate downloadable file, the kind of act that
   pathway is meant to cover, or a different act?
4. Does QF's request to be contacted before distributing a "derivative
   dataset" (§C S14, §K) apply to data that is normalized and embedded
   in a compiled application but never exposed as a separate
   downloadable artifact? What, if anything, would make the normalized
   presentation layer a "derivative dataset" under that clause?
5. Is any git-history remediation (§L) advisable or required given
   (a) the QF correspondence and (b) QF's general Developer Terms —
   noting explicitly that this project is not proposing any specific
   remediation and is asking whether one is warranted at all, not how
   to perform one.
6. Does the historical fact that this project used a one-time static
   copy of QF-sourced data for some period *before* any correspondence
   with QF occurred, and before any Content Sync migration is
   implemented, create any distinct exposure that a forward-looking
   fix (attribution + sync + repository cleanup, per
   `SESSION_184_...REQUIREMENT_CONTRACT.md`) does not itself resolve?

## N. Documents / evidence for counsel to review

In recommended reading order:

1. This packet (overview).
2. `docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md` — the QF
   email, verbatim, S1–S15 (unmerged, PR #64 — read via
   `git show origin/session182-qf-primary-source-evidence:docs/release/SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`
   if reviewing before that PR merges).
3. `docs/release/SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md` (on
   `main`, PR #65) — this project's own decision-matrix reconciliation
   of that email against prior sessions' findings.
4. `docs/release/SESSION_184_QF_CONTENT_SYNC_REQUIREMENT_CONTRACT.md`
   (on `main`, PR #66) — the full technical requirement contract and
   architecture plan this migration would follow if authorized.
5. `https://api-docs.quran.foundation/legal/developer-terms/` — QF's
   own published terms (external, independently fetched by this
   session and Session 184).
6. `docs/release/V1_STORE_LEGAL_READINESS.md` — this project's full
   release-legal inventory, for the surrounding context of `P2-2`
   among other items (note: several other items in that inventory
   concern *different* data sources and are not part of this packet's
   scope).
7. `docs/LICENSING.md` — this project's licensing register for all six
   content sources currently in `quran.sqlite`.

## O. Explicit statement — this is not legal advice or clearance

This packet, `SESSION_182_QF_PRIMARY_SOURCE_EVIDENCE.md`,
`SESSION_182_QF_CONTENT_SYNC_OWNER_DECISION.md`, and
`SESSION_184_...REQUIREMENT_CONTRACT.md` are all engineering-assistant
work product. None of them:

- constitutes legal advice;
- concludes that any use described is or is not lawful;
- declares `P2-2` closed, closeable, or on a path that does not require
  counsel review;
- represents QF's own legal position (QF's email is quoted verbatim
  specifically so counsel can read QF's actual words rather than any
  session's paraphrase of them).

`P2-2` remains **OPEN**. Only the owner may decide to route this packet
to counsel; only counsel may answer §M; only the owner, informed by
that answer, may decide to close `P2-2`.

---

**Prepared by:** Session 185 (2026-09-03). **Not yet sent.** Sending
this packet to counsel is an Owner Gate action.
