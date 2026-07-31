# Implementation program — Phase 1

Converts `DR-2026-0008` … `DR-2026-0013` into executable phases.
**Planning only — nothing in this document has been implemented.**

Architecture is frozen. No phase below redesigns an ADR; where a phase
deviates from the stated priority order it is a *sequencing* correction,
not an architectural one, and the reason is given.

---

## 0. One correction to the requested priority order

The brief prioritises:

```
1 remove exposure · 2 CI gate · 3 separate content from git
· 4 artifact versioning · 5 private storage · 6 licence registry
```

**Priority 3 cannot precede priority 5.** `pubspec.yaml` declares
`assets/database/quran.sqlite`; a Flutter build fails if a declared
asset is missing. Removing the database from git before a fetch
mechanism exists breaks the release build — violating the requirement
that *every phase must leave the repository buildable*.

Storage is therefore moved ahead of separation. Everything else keeps
its stated order:

```
A exposure → B enforcement → C storage → D separation
                                   ╷
             E versioning ─────────┘ (independent, parallelisable)
             F registry   ─────────┘ (independent, feeds B)
```

Enforcement stays at position 2 deliberately. Building storage first and
enforcement later leaves a window in which the rule exists and nothing
checks it — the state that produced the incident.

---

## Stream A — Remove active exposure

`DR-2026-0008` move A. No external dependency. **Start today.**

### A1 · Preserve two-source Tafsir rendering coverage

**Objective.** Move the "RTL and LTR tafsir in one panel" guarantee off
the real corpora and onto fixtures, *before* the data that currently
proves it is removed.

Three assertions in `test/tafsir_real_corpus_test.dart` require two
corpora — lines 86, 129 and 230. The third is not relaxable: it is
specifically about an Arabic and an English source rendering together,
and al-Muyassar alone cannot satisfy it. Without A1, A3 silently deletes
a capability guarantee that Sprints 30.1 and 31.4 exist to protect.

| | |
|---|---|
| **Files** | new `test/tafsir_multi_source_render_test.dart` |
| **Risk** | **Low** — additive; touches no production code |
| **Time** | 2 h |
| **Rollback** | delete the file |
| **Tests** | the new test itself: two fake sources (one `ar`, one `en`), assert both render, assert `displayOrder` ordering, assert `TextDirection.rtl` / `ltr` per source |
| **Acceptance** | new test green with both corpora present **and** with a single-corpus fixture; full suite green |

### A2 · Relax real-data assertions from "exactly two corpora" to "at least one"

**Objective.** Make the real-data suite express the invariant (*every
shipped tafsir source has complete metadata; every ayah resolves
commentary*) rather than today's incidental count.

| | |
|---|---|
| **Files** | `test/tafsir_real_corpus_test.dart` (3 assertions) |
| **Risk** | **Low** — the suite stays green with both corpora, so the change is provable before it matters |
| **Time** | 1 h |
| **Rollback** | `git revert` |
| **Tests** | run against the current v6 database; all 14 must still pass |
| **Acceptance** | 14/14 green **before** any data change; assertions reference "≥1" plus a documented note that multi-source rendering is covered by A1 |

### A3 · Remove the Ibn Kathir corpus and rebuild

**Objective.** End the confirmed exposure. `DR-2026-0008` move A.

| | |
|---|---|
| **Files** | delete `tool/data/tafsir_en-tafsir-ibn-kathir.json`; `tool/build_quran_db.py` (`DATA_VERSION` 6→7); `lib/core/database/database_constants.dart` (`expectedDataVersion` '6'→'7'); rebuilt `assets/database/quran.sqlite` |
| **Risk** | **Medium** — needs network to Tanzil and QuranEnc, which are fetched live at build time. Verified working 2026-07-26. If either is down the phase cannot complete; retry rather than work around. |
| **Time** | 1 h (build ~3 min; the rest is verification) |
| **Rollback** | `git revert` restores JSON, builder, constant and database together — one commit, one reversion |
| **Tests** | full suite; `content_database_smoke_test` (version parity); `attribution_real_data_test` (4/4); `feature_truthfulness_test` (7/7 — coverage must stay 6,236/6,236 on al-Muyassar alone) |
| **Acceptance** | `translation_sources` = 4 · commentary coverage still **6,236 / 6,236** · full suite green · `raw.githubusercontent.com/.../tafsir_en-tafsir-ibn-kathir.json` returns **404** on this branch |

**Known loss, accepted:** English-reading users lose all readable
commentary until permission arrives. This is a product cost, not an
engineering one, and it is the publisher's call — the phase should not
be executed without that decision being made explicitly.

**Not fixed by this phase:** git history retains the blob, reachable by
SHA. Covered by `DR-2026-0008` Future extensions.

### A4 · Correct tafsir attribution

**Objective.** Owed to a rights holder whether or not they reply
(`legal/OUTREACH.md` §"Attribution corrections"). Al-Muyassar's `author`
currently holds the *work's title*, misspelled with Persian ی (U+06CC).

| | |
|---|---|
| **Files** | `tool/build_quran_db.py` (`DATA_VERSION` 7→8, author metadata); `lib/core/database/database_constants.dart`; rebuilt database |
| **Risk** | **Low** — metadata only; no structural change |
| **Time** | 1 h |
| **Rollback** | `git revert` |
| **Tests** | `attribution_real_data_test` — extend to assert al-Muyassar's author is the compiler/publisher, not the title |
| **Acceptance** | attribution screen shows `نخبة من العلماء` / `مجمع الملك فهد` · full suite green |

Kept separate from A3 so each is independently revertible. A rebuild is
~3 minutes; two are cheap.

---

## Stream B — CI licence gate

`DR-2026-0013`. Independent of A, C, D. **Can run in parallel with A.**

### B1 · Restricted-path deny-list gate

**Objective.** Make it impossible to commit a new restricted asset.

| | |
|---|---|
| **Files** | new `test/repository_boundary_test.dart` |
| **Risk** | **Low** — reads `git ls-files`; no production code |
| **Time** | 3 h |
| **Rollback** | delete the file |
| **Tests** | the gate itself, **proven by deliberate breakage**: `git add -f` a dummy restricted path, confirm red, revert |
| **Acceptance** | green on a clean tree · red when a restricted path is force-added · runs without credentials so forks execute it too |

**Interim seeding.** Until Stream F exists there is no registry to derive
from, so B1 ships with a hand-seeded list plus an **allow-list**
containing `assets/database/quran.sqlite`, which is still tracked at this
point. F3 replaces the seed with derivation and D2 removes the
allow-list entry. Without the allow-list this phase would be red on
arrival, breaking the "always buildable" rule.

### B2 · Tracked-file size guard

**Objective.** Catch the *class* — any tracked file over ~5 MB is almost
certainly content, whatever it is called. This alone would have caught
the original mistake with no knowledge of Ibn Kathir.

| | |
|---|---|
| **Files** | `test/repository_boundary_test.dart` (extend) |
| **Risk** | **Low**, with one caveat: it is red on arrival unless `assets/database/quran.sqlite` and `tool/data/*.json` are allow-listed |
| **Time** | 2 h |
| **Rollback** | delete the added group |
| **Tests** | proven by adding an oversized dummy file |
| **Acceptance** | green with the documented allow-list · red for any new file over threshold · every allow-list entry carries a comment naming the phase that removes it |

---

## Stream C — Private storage

`DR-2026-0009` C/D. **Blocked on an external decision** (which object
store) and on credentials existing.

### C1 · Provision the bucket and upload current inputs

**Objective.** Somewhere for content to live that is not a public repo.

| | |
|---|---|
| **Files** | none in the repository — infrastructure only |
| **Risk** | **Low** technically; **blocked** on the publisher choosing a provider (`DR-2026-0009` leaves the vendor open) |
| **Time** | 2 h |
| **Rollback** | delete the bucket; nothing in the repo changed |
| **Tests** | manual: upload, download, checksum match |
| **Acceptance** | every current dataset and the built database present, private, with sha256 recorded |

### C2 · Credentials in CI

| | |
|---|---|
| **Files** | none — GitHub environment secrets |
| **Risk** | **Medium** — a misconfigured secret is a leak. Read-only, single prefix, environment-protected so forks cannot reach it. |
| **Time** | 2 h |
| **Rollback** | revoke the token |
| **Tests** | a throwaway workflow that downloads one small object and prints only its checksum |
| **Acceptance** | `main` and `v*` can fetch · a fork PR cannot · `gitleaks` still green |

### C3 · CI fetch step, additive

**Objective.** CI can obtain content from storage **while the database
is still committed**. Nothing breaks; the capability simply exists.

| | |
|---|---|
| **Files** | `.github/workflows/ci.yml` |
| **Risk** | **Low** — additive; the committed file still satisfies the build if the fetch is skipped |
| **Time** | 3 h |
| **Rollback** | `git revert` |
| **Tests** | CI green on `main`; the fetched checksum matches the committed file byte-for-byte |
| **Acceptance** | fetch step succeeds and is proven redundant — which is exactly what makes D1 safe |

---

## Stream D — Separate content from git

`DR-2026-0008` move B. **Depends on C3.** This is the phase that ends
the pattern.

### D1 · Stop tracking the database

| | |
|---|---|
| **Files** | `.gitignore`; `git rm --cached assets/database/quran.sqlite`; `.github/workflows/ci.yml` (fetch becomes required, not optional) |
| **Risk** | **High** — the first phase where a mistake breaks the release build. Mitigated by C3 having already proven the fetch works. |
| **Time** | 3 h |
| **Rollback** | `git revert` restores tracking; the file is unchanged in history |
| **Tests** | full suite in CI (with fetch) · `flutter build appbundle --release` in CI · a clean clone without credentials builds the public profile |
| **Acceptance** | database untracked · CI green · release build produces an AAB · `.git` stops growing per data version |

### D2 · Stop tracking restricted inputs; remove the allow-list

| | |
|---|---|
| **Files** | `.gitignore`; `git rm --cached tool/data/*.json`; `test/repository_boundary_test.dart` (remove allow-list entries) |
| **Risk** | **Medium** — the data build now depends entirely on storage |
| **Time** | 2 h |
| **Rollback** | `git revert` |
| **Tests** | B1 and B2 green **with an empty allow-list** — the strongest form of the gate |
| **Acceptance** | no dataset tracked · no allow-list entry remains · size guard passes on its own merits |

### D3 · Public build profile

**Objective.** `DR-2026-0009` B tier 0 — a contributor without
credentials gets a real, working, Arabic-only app.

| | |
|---|---|
| **Files** | `tool/build_quran_db.py` (`--profile` flag); `README.md`; `CONTRIBUTING` note |
| **Risk** | **Low** |
| **Time** | 4 h |
| **Rollback** | `git revert`; the flag is additive |
| **Tests** | full suite against a public-profile database — data-dependent tests must **assert what the profile supports**, not skip wholesale |
| **Acceptance** | `--profile=public` builds with no credentials · full suite green against it · documented in README |

---

## Stream E — Artifact versioning

`DR-2026-0011`. **Independent of C and D.** Parallelisable.

### E1 · Split schema from artifact version

| | |
|---|---|
| **Files** | `lib/core/database/database_constants.dart` (add `expectedSchemaVersion`); `tool/build_quran_db.py` (write `schema_version` into `meta`); `test/content_database_smoke_test.dart` |
| **Risk** | **Medium** — touches the only production constant the content upgrade path reads. Additive: the existing `expectedDataVersion` check is unchanged; a second check is added beside it. |
| **Time** | 3 h |
| **Rollback** | `git revert`; requires a database rebuild to remove the new `meta` key, or the app tolerates its absence — **design the check to tolerate a missing key** so rollback needs no rebuild |
| **Tests** | smoke test asserts both parities · a fixture with a mismatched schema is rejected |
| **Acceptance** | both versions present in `meta` and pinned in Dart · content-only updates no longer imply a schema bump |

### E2 · Record input versions and builder revision in the artifact

| | |
|---|---|
| **Files** | `tool/build_quran_db.py` (extra `meta` rows) |
| **Risk** | **Low** — metadata only |
| **Time** | 2 h |
| **Rollback** | `git revert` + rebuild |
| **Tests** | `attribution_real_data_test` extended to assert the provenance keys exist and are non-empty |
| **Acceptance** | any shipped database can name its exact inputs and builder revision |

---

## Stream F — Licence registry

`DR-2026-0010`. Independent; **feeds B1's deny-list**, closing the loop.

### F1 · Grant records for the six current sources

| | |
|---|---|
| **Files** | new `licences/*.json` (repository-tracked — grants contain no licensed content, only terms and evidence pointers) |
| **Risk** | **Low** |
| **Time** | 4 h |
| **Rollback** | delete the directory |
| **Tests** | schema validation: `granted` requires non-null `evidence`; every scope is `allow`/`deny`/`unknown` |
| **Acceptance** | six grants, each matching `docs/LICENSING.md` verbatim · three-valued · Ibn Kathir recorded as `redistribute_file: deny`, `embed_in_app: unknown` |

### F2 · Builder consumes grants

| | |
|---|---|
| **Files** | `tool/build_quran_db.py` (import gate + licence string sourced from the grant) |
| **Risk** | **Medium** — can refuse a build. That is the feature; it will be inconvenient exactly when it matters. |
| **Time** | 4 h |
| **Rollback** | `git revert` |
| **Tests** | a fixture grant with `embed_in_app: unknown` must fail the build; `attribution_real_data_test` must still pass, proving grant→database parity |
| **Acceptance** | no source imports without a grant · `unknown` behaves as `deny` · attribution strings originate from grants |

### F3 · Derive the deny-list from grants

**Objective.** Close the loop — the gate stops being hand-seeded.

| | |
|---|---|
| **Files** | `test/repository_boundary_test.dart` |
| **Risk** | **Low** |
| **Time** | 2 h |
| **Rollback** | `git revert` to the seeded list |
| **Tests** | add a fixture grant marked `deny`; confirm the gate extends automatically |
| **Acceptance** | the deny-list is derived, not written · adding a restricted dataset extends the gate with no test edit |

---

## Dependencies and critical path

```
A1 → A2 → A3 → A4                     (exposure — no external dependency)

B1 → B2                               (enforcement — parallel with A)
                    ╲
C1 → C2 → C3 → D1 → D2 → D3           (storage → separation)
                    ╱
E1 → E2                               (versioning — parallel)
F1 → F2 → F3 ───────┘                 (registry — F3 needs B1)
```

**Critical path: C1 → C2 → C3 → D1 → D2 ≈ 12 hours**, and it is gated by
an external decision (which object store) that has not been made.

**Longest chain by value: A1 → A2 → A3 ≈ 4 hours**, gated by a product
decision (accept the loss of English commentary) that has not been made
either.

### Parallel work

| Track | Phases | Blocked by |
|---|---|---|
| 1 | A1 → A4 | publisher decision on A3 |
| 2 | B1 → B2 | nothing |
| 3 | F1 → F2 | nothing |
| 4 | E1 → E2 | nothing |
| 5 | C1 → D3 | provider choice |

Tracks 2, 3 and 4 can start immediately and touch disjoint files. Track
1 touches `build_quran_db.py` and `database_constants.dart`; so do E1,
E2 and F2 — **sequence those within a track, not across tracks**, or
accept merge conflicts in two files.

---

## Risk matrix

| Phase | Risk | Blast radius | Reversible | Notes |
|---|---|---|---|---|
| A1 | Low | tests only | trivially | additive |
| A2 | Low | tests only | trivially | provable before it matters |
| **A3** | **Medium** | data + release content | one revert | needs live upstreams; loses English commentary |
| A4 | Low | metadata | one revert | |
| B1 | Low | CI only | trivially | red without the interim allow-list |
| B2 | Low | CI only | trivially | same |
| C1 | Low | none in-repo | delete bucket | blocked on provider choice |
| **C2** | **Medium** | credentials | revoke | misconfiguration is a leak |
| C3 | Low | CI | one revert | additive, proven redundant |
| **D1** | **High** | **release build** | one revert | first phase where error breaks the build |
| D2 | Medium | data build | one revert | |
| D3 | Low | tooling | one revert | additive flag |
| **E1** | **Medium** | upgrade path | revert (design for no-rebuild rollback) | touches the constant the content upgrade reads |
| E2 | Low | metadata | revert + rebuild | |
| F1 | Low | docs | delete | |
| **F2** | **Medium** | can block builds | one revert | intended |
| F3 | Low | CI | revert to seed | |

**The three to plan carefully: D1, E1, F2.** Each can stop a build.
Each is one `git revert` from safety.

---

## Milestone plan

| Milestone | Contents | Effort | Exit criterion |
|---|---|---|---|
| **M1 · Exposure closed** | A1–A4 | ~5 h | corpus 404 on the branch; attribution correct; suite green |
| **M2 · Recurrence impossible** | B1–B2 | ~5 h | gate red on a forced restricted commit, proven |
| **M3 · Storage ready** | C1–C3 | ~7 h | CI fetches and the fetch is provably redundant |
| **M4 · Content out of git** | D1–D3 | ~9 h | nothing licensed tracked; allow-list empty; public profile builds |
| **M5 · Identity correct** | E1–E2 | ~5 h | schema and artifact versions independent; provenance recorded |
| **M6 · Rights mechanical** | F1–F3 | ~10 h | no import without a grant; deny-list derived |

**Total ≈ 41 hours of engineering**, plus two decisions that are not
engineering: the object-store provider, and whether to accept the loss
of English commentary.

Suggested order: **M1 and M2 in parallel first** (they share no files),
then M3 → M4, with M5 and M6 filled in wherever they fit. M6 last is
acceptable; M2 last is not.

---

## Expected release impact

| Area | Impact |
|---|---|
| **Application code** | **None.** No phase touches `lib/` except one constant file (E1, additive). `pubspec.yaml` names an asset path; Dart cannot observe its origin. |
| **Schema** | None. `PROJ-P-002` is not engaged by any phase. |
| **User-visible** | One: English commentary disappears (A3). Everything else is invisible. |
| **Store submission** | Unblocked on the repository-exposure axis; **not** on the app-licensing axis — only Darussalam resolves that. |
| **Merge to `main`** | M1 should land **before** the merge. Merging first would move the corpus onto the default branch, which the Release Manager review declined to approve. |
| **CI duration** | +1–2 min for the fetch; −0 elsewhere. Clone time improves materially after D1. |
| **Repository** | stops growing ~33 MB per data version |
| **Contributors** | tier 0 gets Arabic-only content; the full suite still runs (D3) |

### What this program does not achieve

- **Git history still contains the corpus.** Reachable by SHA after
  every phase. Out of scope by `DR-2026-0008`.
- **It does not make the app's use of Ibn Kathir lawful.** Only a reply
  from Darussalam does that. A3 removes the text; it does not obtain
  permission.
- **It does not address the other release blockers** — icon, hosted
  legal URLs, store assets, accessibility verification, crash reporting.

---

## Recommended first three actions

1. **Send the four enquiries in `legal/OUTREACH.md`.** Not in this
   program because it is not engineering, and still the only item whose
   clock you do not control. Drafted for six sprints; sent in none.
2. **Decide A3.** Removing the corpus costs English commentary. That is
   a product decision and the phase should not run without it being made
   explicitly.
3. **Start B1 today.** It blocks on nothing, touches no production code,
   is trivially reversible, and it is the record the freeze report named
   as load-bearing and currently unbuilt.
