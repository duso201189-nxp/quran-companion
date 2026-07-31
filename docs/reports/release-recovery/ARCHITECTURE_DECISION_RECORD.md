> **Superseded as a location, not as a decision.** This draft has been
> filed as the canonical record
> [`docs/adr/DR-2026-0008-content-distribution-strategy.md`](docs/adr/DR-2026-0008-content-distribution-strategy.md),
> status `accepted`. Edit the filed record, not this file; this copy is
> retained only as the Sprint 38.0 working draft and may be deleted.

---
id: DR-2026-0008
scope: project
owner_role: data-owner
date: 2026-07-26
deciders: [duso]
status: proposed
supersedes: null
review_by: 2027-01-26
reversibility: hard
threshold_reason: [materially-different-approaches, hard-to-reverse-later, legal-exposure]
links:
  task: "Sprint 38.0 — Repository & Distribution Strategy Review"
  verification_records: []
---

# DR-2026-0008 — Where licensed third-party content lives

**Status: proposed.** Nothing has been changed, deleted or rewritten.
File this as `docs/adr/DR-2026-0008-licensed-content-storage.md` when
accepted.

---

## Context

The repository is **public**. Its default branch is `main`.

Six third-party content sources reach the shipped application. Three
are fetched live at build time and never committed; three are committed
as JSON; and all six end up inside `assets/database/quran.sqlite`, which
is also committed.

| Source | In git? | Licence status |
|---|---|---|
| Arabic Uthmani (Tanzil) | no — fetched at build | verified, attribution + link |
| English Saheeh Int'l (Tanzil) | no — fetched at build | **non-commercial only** |
| Vietnamese Rowwad (QuranEnc) | no — fetched at build | verified, 7 conditions |
| Latin transliteration (Quran.com) | **yes**, 3.3 MB | unverified |
| Tafsir al-Muyassar (KFGQPC) | **yes**, 2.0 MB | unverified |
| **Tafsir Ibn Kathir abridged** | **yes, 10.1 MB** | **© Maktaba Dar-us-Salam 2003** |
| `assets/database/quran.sqlite` | **yes**, 32.7 MB | contains all six |

Measured, today:

```
GET .../sprint1-my-library/tool/data/tafsir_en-tafsir-ibn-kathir.json
    → HTTP 200, 10,555,494 bytes
GET .../main/tool/data/tafsir_en-tafsir-ibn-kathir.json
    → HTTP 404
```

Four historical blobs of the database exist in git history, totalling
**103.4 MB** across only four data versions.

### The problem, stated precisely

Two distinct acts of distribution are being conflated.

1. **Shipping content inside an application.** This is what the
   permission requests in `legal/OUTREACH.md` ask for. It is the normal
   thing a Qur'an app does, and publishers grant it.
2. **Publishing the content as a downloadable file.** This is what a
   public git repository does. It is unnecessary, it was never intended,
   and it is materially harder to justify to a rights holder — "our book
   is in your app" is a very different conversation from "our book is a
   JSON file on your GitHub".

The project has been doing (2) as an accident of doing (1).

**This is not a problem with one corpus.** Removing Ibn Kathir leaves
al-Muyassar (unverified), the transliteration (unverified) and Saheeh
International (non-commercial) still committed. The defect is the
pattern, not the instance.

---

## Decision

**Adopt the invariant: no third-party licensed content is ever committed
to a public repository.**

Implement it by extending a mechanism the pipeline already has. Three of
six sources are already fetched at build time rather than committed;
this completes that design for the remaining three, and for the built
database.

Sequenced in two moves, because the first is urgent and the second is
not:

**Move 1 — stop the bleeding (hours).** Remove the Ibn Kathir corpus
from the working tree and rebuild the database without it. This is
Strategy F, adopted **as a mitigation, not as the solution**.

**Move 2 — fix the pattern (one to two days).** Move all restricted
inputs and the built database to private object storage. CI fetches them
with credentials held in repository secrets. The repository keeps only
code, tests, documentation and the website.

---

## Alternatives considered

### Strategy A — keep the repository public, keep the current layout

| | |
|---|---|
| **Legal risk** | **Unacceptable.** One corpus is confirmed in copyright and publicly downloadable. Three more are unverified. Repository distribution is separate from, and additional to, app distribution. |
| **Cost** | zero today, unbounded later |
| **Verdict** | **Rejected.** This is the status quo, and the status quo is the finding. |

The only honest version of A is "accept a known infringement", which is
not a position an engineering team gets to take on behalf of a
publisher.

### Strategy B — move restricted content outside git; build injects it

| | |
|---|---|
| **Pros** | Fixes the pattern, not one instance · repository stays public and small · **zero application-code change** · reproducibility *improves* — the private store is a controlled archive, unlike a live upstream that can vanish · new corpora inherit the rule automatically |
| **Cons** | CI needs credentials · a fresh clone cannot build the full database without access · one more system to keep alive |
| **Complexity** | **Low.** ~15 lines in CI. Half the design already exists: Tanzil and QuranEnc are already fetched at build time. |
| **Maintenance** | One bucket, one credential pair, one rotation reminder. Lower than the alternative of auditing every future import by hand. |

Two properties of the existing codebase make this cheaper than it looks:

- `pubspec.yaml` declares `assets/database/quran.sqlite` as an asset
  path. Dart neither knows nor cares whether that file was committed or
  downloaded thirty seconds earlier. **No `lib/` change.**
- The three real-data test files already begin with
  `if (!file.existsSync()) { test(..., skip: true); return; }`. A
  contributor without credentials gets a green suite minus the
  data-dependent tests, by design that is already written.

CI's `if [ ! -f assets/database/quran.sqlite ]` guard is currently dead
code — the file is always present after checkout, so the build step has
never run. Under B it becomes live, which also means the data pipeline
finally gets exercised by CI instead of only by hand.

**Verdict: recommended.**

### Strategy C — private repository + separate public website repository

| | |
|---|---|
| **Pros** | Complete and immediate legal fix, including history · no build-pipeline change · reversible in one click |
| **Cons** | The project stops being inspectable — a real loss for an app asking users to trust its Qur'anic text · every future contributor needs an invitation · two repositories to keep in step |
| **Effect on GitHub Pages** | Pages from a **private** repo requires GitHub Pro or Team. Pages from a **public** repo is free. So the site must move to its own public repository — which works, and is arguably cleaner anyway. |
| **Effect on Play Store** | None, provided the legal URLs stay reachable. |
| **Effect on contributors** | Severe for an open project; negligible for a solo project, which this is today. |

**Verdict: viable fallback, not first choice.** It solves the legal
problem by hiding everything rather than by separating concerns, and it
gives up the transparency that is one of this project's genuine
strengths — an app whose attribution screen is unusually honest benefits
from a repository people can check.

Worth keeping in the back pocket: if Darussalam responds badly, going
private for a week is a faster tourniquet than a history rewrite.

### Strategy D — Git LFS

| | |
|---|---|
| **Legal** | **No effect whatsoever.** LFS objects in a public repository are publicly fetchable. LFS is a storage-mechanics change, not an access-control change. |
| **Cost** | GitHub's LFS free tier is small; 32.7 MB per data version plus bandwidth consumes it quickly, and overage is billed. |
| **Suitability** | Solves a problem this project does not have (clone speed) while leaving the problem it does have (public distribution of licensed content) exactly as it was. |
| **Repository growth** | Improves clone size; the objects still accumulate and are still billed. |

**Verdict: rejected.** Adopting LFS here would create the *appearance*
of having addressed the finding without addressing it at all. That is
worse than doing nothing, because it would close the ticket.

### Strategy E — release assets and artifact storage

Not an alternative to B so much as the menu of implementations for it.

| Option | Access control | Cost | Verdict |
|---|---|---|---|
| **GitHub Releases on a public repo** | none — assets are public | free | **Rejected.** Identical exposure to today, one URL further away. |
| **GitHub Releases on a private repo** | token required | free | Workable, but couples content storage to the repository's visibility — the thing we are trying to decouple. |
| **Cloudflare R2, private bucket** | signed URL / API token | generous free tier, **no egress fees** | **Recommended.** ~17 MB of inputs is far inside the free tier; zero egress makes CI pulls free. Verify current terms before committing. |
| **AWS S3, private bucket** | IAM / presigned URL | pennies per month, **egress billed** | Works. Slightly more moving parts and a bill that scales with CI runs. |
| **Backblaze B2 / self-hosted** | varies | low | Fine. Choose on operational familiarity, not features. |

The differences between these are small. What matters is **private by
default with credentials in CI secrets**; the vendor is a preference.

### Strategy F — remove the Ibn Kathir corpus and rebuild

| | |
|---|---|
| **User impact** | **Coverage is unaffected** — al-Muyassar alone covers 6,236 / 6,236 ayahs. But al-Muyassar is Arabic, so **English-reading users lose all commentary they can read.** That is the real cost and it is a product decision, not an engineering one. |
| **Engineering impact** | Small and well-supported. Delete one JSON, rebuild, bump `DATA_VERSION` 6→7 and the Dart constant, re-run gates. The passage-aware query needs no change; the attribution screen loses a row by itself; `feature_truthfulness_test` still passes because it asserts invariants, not counts. |
| **Legal impact** | **Partial.** Fixes HEAD for one source. Does **not** remove the blob from git history — it stays reachable by commit SHA. Does **not** address al-Muyassar, the transliteration, or Saheeh International, all still committed inside the database. |
| **Future restoration** | Trivial. Re-add the JSON (from private storage, under B), rebuild, bump the version. The app updates the content database on next launch without touching user data. Perhaps two hours. |

**Verdict: adopt as an immediate mitigation, reject as the solution.**

---

## Trade-offs

The genuine tension is **reproducibility versus exposure**, and this
project already chose reproducibility once. `fetch_tafsir.py` says so in
its own header: the datasets are cached to `tool/data/` precisely so
that *"build lại database KHÔNG cần mạng"* — rebuilding needs no
network. That was a good decision for build determinism and a bad one
for licence exposure, and nobody noticed the second half.

Strategy B resolves the tension rather than trading one side away: a
private bucket is *more* reliable than a live upstream, because it
cannot change its URL scheme, rate-limit you, or shut down. The project
keeps determinism and loses the exposure.

| Dimension | A (today) | B (recommended) | C (private) | D (LFS) | F (remove) |
|---|---|---|---|---|---|
| Legal exposure removed | none | **all sources** | all, incl. history | **none** | one source, HEAD only |
| App code change | — | **none** | none | none | none |
| CI change | — | ~15 lines | none | moderate | none |
| Repo stays public | yes | **yes** | no | yes | yes |
| Repo growth solved | no | **yes** | no | partly | no |
| Reproducible builds | yes | **yes** | yes | yes | yes |
| Time to implement | — | 1–2 days | hours | hours | hours |
| Ongoing cost | — | ~$0 | $0 | billed | $0 |

---

## Recommendation

**F now, B this month, C held in reserve.**

1. **Today** — remove the Ibn Kathir corpus and rebuild. Roughly an
   hour. It stops the one confirmed infringement at HEAD and unblocks
   the merge.
2. **Today** — send the four enquiries in `legal/OUTREACH.md`. They have
   been drafted and unsent for four sprints and their latency is the
   whole release schedule.
3. **This month** — implement B: private bucket, CI fetch step,
   `.gitignore` the database and the restricted inputs, delete them from
   HEAD. New rule documented, and enforced by a CI check that fails if a
   restricted path reappears under version control.
4. **Only if a rights holder objects** — go private (C) as a tourniquet,
   or rewrite history with `git filter-repo`. Both are disruptive;
   neither is needed pre-emptively.

### Answers to the five questions asked

**1 · Is removing the corpus the best solution, or only the fastest?**
Only the fastest. It is the right *first* action and the wrong *last*
one. It fixes one instance of a pattern that will recur with the next
import, and it leaves three other licensed sources committed.

**2 · Best strategy for a 10-year horizon?** **B.** Over ten years the
repository will see more corpora, more contributors and more data
versions. A pattern that makes exposure impossible beats a policy that
requires someone to remember. And at ~33 MB per data version, A reaches
roughly 300 MB of history by v10 — B keeps it flat.

**3 · What would I choose as CTO?** The same, with the sequencing above.
The urgent thing and the correct thing are different things here, and
the mistake would be to do only one of them. Doing F alone declares
victory over a symptom; doing B alone leaves a known infringement live
for another week.

**4 · Would permission from Darussalam change this?** **No.** Three
reasons. Permission to embed in an application is not permission to
publish the text as a file on GitHub, and asking for the latter makes
the former harder to obtain. Three other sources remain unverified
regardless. And permission does nothing about repository growth. What
permission changes is whether the corpus can ship in the app — a
product question, not a storage question.

**5 · Can this be done without changing the app architecture?**
**Yes — entirely.** `pubspec.yaml` names an asset path; the Flutter
build copies whatever file is there into the bundle. Dart cannot observe
whether that file was committed or downloaded moments earlier. Not one
line under `lib/` changes, no schema changes, no query changes, and
`PROJ-P-002` is not engaged. The three data-dependent test files already
skip cleanly when the asset is absent — the codebase was, without
anyone planning it, already written for this.

---

## Long-term maintenance

| Concern | Under B |
|---|---|
| Credential rotation | one token pair; rotate annually, note it in `PROJ-P-002`'s review cycle |
| Bucket availability | a build-time dependency, same class as Tanzil and QuranEnc already are; the bucket is the more reliable of the three |
| Onboarding a contributor | read-only credentials, or work without them — tests skip, `lib/` is fully testable |
| Adding a new corpus | upload to the bucket, register in `build_quran_db.py`. The rule is inherited; nobody has to remember it. |
| Preventing regression | a CI check that fails if any restricted path is tracked — the same technique as `store_metadata_test.dart` and `feature_truthfulness_test.dart`, both of which read raw config files and are proven load-bearing |
| Repository size | flat. The database stops entering history at all. |

The enforcement point matters most. This project's strongest habit is
turning rules into tests that fail — the architecture boundary tests,
the licence-completeness gate, the AI-claim gate. The content rule
should join them rather than living in a document.

---

## Risk

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| Doing F only, declaring the finding closed | **High** | **High** — it is the tempting path | This record exists to prevent it |
| Private bucket becomes a single point of failure | Medium | Low | It replaces live upstreams that are *less* reliable; keep an offline copy of the inputs |
| Credentials leaked in CI logs | Medium | Low | GitHub secrets are masked; `gitleaks` already runs on every push |
| Contributors cannot build the full app | Medium | Certain | Documented and accepted: `lib/` is fully testable without content; only data-dependent tests skip |
| History still contains the corpus after F and B | **Medium** | **Certain** | Accepted, with the permission request sent. Escalate to `filter-repo` only if a rights holder objects. |
| Doing nothing while deliberating | **High** | — | F is hours of work. Deliberation is not a reason to leave it live. |

### The risk that is not on this table

Every option above manages exposure. None of them makes the app's use of
the Ibn Kathir text lawful. Only a reply from Darussalam does that, and
that reply cannot be obtained by any architecture. **The most important
action arising from this review is not architectural — it is sending
the email.**
