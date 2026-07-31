# Architecture freeze report

Date: 2026-07-26 · Scope: Sprint 38.0 – 40.0 consolidation ·
Reviewer role: Chief Architect

Documentation only. No source, test or asset was modified; nothing was
committed or pushed.

---

## 1. What was frozen

Six new Decision Records, all `status: accepted`, filed in `docs/adr/`
and indexed in `docs/adr/README.md`.

| ID | Title | Owns the question |
|---|---|---|
| [DR-2026-0008](docs/adr/DR-2026-0008-content-distribution-strategy.md) | Content distribution strategy | *may this content be in the repository?* |
| [DR-2026-0009](docs/adr/DR-2026-0009-data-supply-chain.md) | Data supply chain | *how does content reach the app?* |
| [DR-2026-0010](docs/adr/DR-2026-0010-licence-registry.md) | Licence registry | *what is permitted?* |
| [DR-2026-0011](docs/adr/DR-2026-0011-artifact-versioning.md) | Artifact versioning | *identity and compatibility* |
| [DR-2026-0012](docs/adr/DR-2026-0012-artifact-registry.md) | Artifact registry | *what is consumable?* |
| [DR-2026-0013](docs/adr/DR-2026-0013-ci-licence-gate.md) | CI licence gate | *what enforces all of the above?* |

```
0008  policy       no licensed content in a public repository
 ├─ 0009  mechanism    data build separated from app build
 ├─ 0010  rights       work → edition → grant, three-valued
 ├─ 0011  identity     schema / artifact / dataset axes
 ├─ 0012  output       immutable verified artifacts, consumed by pin
 └─ 0013  enforcement  the only unbypassable layer
```

### What was deliberately not frozen

Sprint 40.0 designed more than these records adopt. Three items are
recorded under **Future extensions** with an explicit trigger, not as
decisions:

| Deferred | Trigger | Why not now |
|---|---|---|
| Licence envelope computation | a second consumer exists | With one consumer the intersection has one meaningful answer, and a human already knows it |
| Consumer manifests + build-time resolution | the same | One consumer's manifest is a constant |
| Registry service with an API | a second writer, or runtime resolution | Operations without benefit at ~6 records |

This is the project's own precedent applied to its own platform.
`DR-2026-0006` D4 refused a Tafsir loader before a Tafsir surface
existed — *"a provider without a consumer is speculation."*
`DR-2026-0007` D5 refused a `StudyRepository` nothing needed. Sprint
32.0 rejected a schema change on measurement rather than prediction.
Freezing an unbuilt six-consumer platform would have broken a rule this
project has kept three times.

`DATA_SUPPLY_CHAIN.md` and `DATA_OS_ARCHITECTURE.md` remain as design
documents — reasoning, not authority. Where they and an accepted ADR
differ, **the ADR wins**.

---

## 2. Architecture consistency review

### 2.1 No ADR contradicts another

Checked pairwise across all twelve records.

| Pair | Potential conflict | Finding |
|---|---|---|
| 0006 D3 ↔ 0008/0009 | "adding a source is a database row, not a code change" vs. moving content out of git | **No conflict.** 0006 D3 governs how the *app reads* sources; 0008/0009 govern where the *build gets* them. `translation_sources` is untouched. |
| 0007 D7 ↔ 0013 | frozen dependency budget vs. a new CI gate | **No conflict, same technique.** Both encode a rule as a failing test. 0013 reads git metadata, not imports. |
| 0003/0004/0005 ↔ 0009 E | existing schema decisions vs. one database per domain | **No conflict.** 0009 E adds *future* domains alongside group A / group B; it does not repartition existing tables. |
| 0011 ↔ existing upgrade path | three version axes vs. wholesale replacement on version change | **No conflict.** The replacement mechanism is unchanged; it gains a second thing to compare. |
| 0010 ↔ `PROJ-P-005` | machine-readable grants vs. a Constitution-tier constraint | **No conflict, correct subordination.** 0010 states it *implements and does not supersede* `PROJ-P-005`. An ADR may not override the Constitution. |
| 0012 ↔ 0011 | artifact record vs. version identity | **No overlap.** 0011 defines identity; 0012 stores and serves it. |
| 0008 ↔ 0013 | policy vs. enforcement | **Complementary by design.** 0008 without 0013 is a document; 0013 without 0008 has no deny-list. |

**Result: no contradictions found.**

### 2.2 Existing ADRs remain valid

| ADR | Status after freeze |
|---|---|
| 0001 EIS adoption | unaffected |
| 0003 Sprint 8 data architecture | unaffected |
| 0004 Streak / Daily Goal / Revision Queue | unaffected |
| 0005 Learning Engine | unaffected |
| 0006 Study foundation | **valid and reinforced** — D3 and D4 are cited as precedent |
| 0007 Study Workspace | **valid and reinforced** — D7's technique is reused by 0013 |

No record was amended or superseded. All six earlier ADRs keep
`status: accepted`.

### 2.3 No duplicate responsibilities

Each of the six new records owns exactly one question (§1 table). The
test applied: *if two records could answer the same question, one is
wrong.* Two near-misses were resolved during drafting:

- **Rights data vs. dataset data** — 0010 owns grants; 0009 owns
  datasets, which hold a *pointer* to a grant, never a copy. One source
  of truth.
- **Identity vs. storage** — 0011 owns version semantics; 0012 owns
  persistence and retrieval. 0012 cites 0011 rather than restating it.

### 2.4 No unnecessary abstraction

| Introduced | Justified by |
|---|---|
| Licence grant records | An incident that has already happened — an in-copyright corpus shipped for five sprints |
| Three-valued logic | The incident's root cause: `unknown` treated as `allow` |
| Three version axes | A latent defect: one integer carrying three meanings |
| Artifact record + checksum | Nobody could say which datasets produced the committed database |
| CI deny-list gate | `.gitignore` and hooks are both bypassable |
| Public build profile | Contributors must be able to work; the alternative was synthetic fixtures that drift |

Every abstraction traces to an observed defect. **None was introduced
on anticipation.**

### 2.5 No speculative platform accepted

Confirmed. The six deferred/rejected items are recorded with triggers,
under Future extensions, and are not part of any Decision section. The
freeze adopts a **content-governance model for one application**, not a
Data OS.

### 2.6 Suitable for one application, extensible to several

| Property | Today | Extension cost |
|---|---|---|
| One app, one website | fully served | — |
| Second mobile app | works — it pins the same artifact | zero architectural change |
| Server-side consumer | needs envelope computation | 0012 Future extension, trigger stated |
| New content domain | 0009 E already provides | new database, new grants |
| New corpus | grant → archive → register → build | unchanged per corpus |

**Result: suitable, and extensible without redesign.**

---

## 3. Architecture maturity

| Dimension | Score | Justification |
|---|---|---|
| **Decision coverage** | 9.0 | 12 accepted ADRs; every major subsystem has a record. −1: `DR-2026-0002` still missing. |
| **Internal consistency** | 9.5 | No contradictions across 12 records; two near-duplicate responsibilities caught and resolved. |
| **Enforceability** | 7.5 | Five gates exist and three were proven by deliberate breakage. −2.5: **0013 is written but not built** — the load-bearing record is currently a document. |
| **Traceability** | 9.0 | Every abstraction traces to an observed defect; every deferral names a trigger. |
| **Restraint** | 9.5 | A six-consumer platform was designed and deliberately not adopted, consistent with three prior refusals. |
| **Documentation quality** | 9.0 | Records state unfavourable findings verbatim, including one that reflects badly on earlier sprints. |
| **Implementation status** | **4.0** | **Nothing in 0008–0013 is implemented.** The encumbered corpus is still committed and still publicly fetchable. |
| **Overall architecture maturity** | **8.2** | The design is mature. Reality has not moved. |

The gap between 9.5 restraint and 4.0 implementation is the honest
summary of this freeze: **the thinking is finished and the work has not
started.**

---

## 4. Remaining open decisions

| # | Decision | Owner | Blocked by |
|---|---|---|---|
| O1 | Does the Ibn Kathir corpus stay (with permission) or go? | Darussalam | an unsent email |
| O2 | Governing law — Vietnam is inferred from the keystore certificate, not confirmed | publisher | publisher |
| O3 | Does the project's own source get a `LICENSE` file? | publisher | publisher |
| O4 | Web platform — fix `sqlite3.wasm` or formally drop it | publisher | publisher |
| O5 | Which object store (R2 / S3 / B2) | publisher | preference, not architecture |
| O6 | `organization` / `description` on the attribution screen — needs columns, gated by `PROJ-P-002` | publisher | publisher |
| O7 | Should `DR-2026-0002` be reconstructed or formally retired? | architect | — |

O1 is the only one on the critical path. O5 is deliberately left open:
`DR-2026-0009` decides *private, credentialed, checksum-verified*, and
the vendor is an implementation detail.

---

## 5. Technical debt

### Architectural

| # | Debt | Severity | Note |
|---|---|---|---|
| A1 | **`DR-2026-0002` missing** — 26 references across `lib/`, none resolvable | **High** | Pre-existing and already tracked in `docs/adr/README.md`; it governs Search and cross-feature navigation. Six sprints of code cite an unopenable record. |
| A2 | 0008–0013 accepted but unimplemented | **High** | The subject of §6 |
| A3 | `features/stats/**` and `search_error_state.dart` in Reading's allowlist | Low | Marked as debt in `architecture_boundaries_test.dart` since Sprint 31.0 |
| A4 | `lib/core` has no boundary test of its own | Low | The most depended-upon layer is the least governed |

### Implementation

| # | Debt | Severity |
|---|---|---|
| I1 | Encumbered corpus committed and publicly fetchable | **Blocker** |
| I2 | Attribution wrong for both tafsir sources | High |
| I3 | `.git` grows ~33 MB per data version; 103.4 MB of DB blobs already | Medium |
| I4 | Data pipeline never exercised by CI | Medium |
| I5 | No crash reporting; accessibility unverified | Medium |
| I6 | 34 outdated packages, two majors | Low |
| I7 | `lib/core` coverage 35.0% | Low |

A1 deserves a note. The ADR index has flagged it since Sprint 9, and it
has not been fixed across roughly thirty sprints. A freeze report that
adds six records while ignoring a seventh that six sprints of code
depend on would be incomplete.

---

## 6. Architecture roadmap

Architecture only. No product features.

| Phase | Work | Depends on | Trigger |
|---|---|---|---|
| **P0** | Implement `DR-2026-0008` move A — remove the corpus, rebuild, bump versions | — | **now** |
| **P1** | Implement `DR-2026-0013` — CI deny-list gate + size guard, proven by deliberate breakage | P0 | **now** |
| **P2** | Implement `DR-2026-0009` — private storage, CI fetch, public profile, tiers | P1 | now |
| **P3** | Implement `DR-2026-0011` — split the version axes; extend the smoke test | P2 | now |
| **P4** | Implement `DR-2026-0012` — artifact records, verification stage, pinning | P3 | now |
| **P5** | Implement `DR-2026-0010` — grant records driving the gate and the profile | P2 | now |
| **P6** | Resolve `DR-2026-0002`: reconstruct from code, or retire with a superseding record | — | next architecture pass |
| **P7** | Boundary test for `lib/core` | — | opportunistic |
| **P8** | Envelope computation + consumer manifests | P5 | **second consumer** |
| **P9** | Registry service | P8 | **second writer** |

**P1 before P2 is deliberate.** Building storage first and enforcement
later leaves a window in which the rule exists and nothing checks it —
which is the state that produced the incident.

P8 and P9 have triggers, not dates. They should not be scheduled.

---

## 7. Recommendation

# APPROVE ARCHITECTURE

The frozen set is internally consistent, contradicts nothing, duplicates
no responsibility, introduces no abstraction without an observed defect
behind it, and declines to adopt the speculative platform it designed.
It serves one production application today and extends to several
without redesign.

**Approval is of the architecture, not of the state of the repository.**
Three qualifications:

**One · Approval is conditional on P0 and P1.** An accepted ADR that
forbids something the repository is currently doing is not architecture;
it is an aspiration. `DR-2026-0013` in particular is the load-bearing
record of the series and exists only as prose. If P1 is not built, this
freeze has produced six documents and no change in behaviour — the exact
failure mode `DR-2026-0013` §Risks names as High.

**Two · `DR-2026-0002` should be resolved in the next architecture
pass.** Twelve accepted records and one missing one that twenty-six code
comments depend on is a defect in the record set, not in the code.

**Three · The most important open item is not architectural.** No
Decision Record makes unlicensed content lawful. These six guarantee the
repository never distributes what it may not; whether the application
may ship a given text is answered by a rights holder. That answer
requires an email that has now been drafted for six sprints and sent in
none of them.

**Architecture: frozen and approved. Implementation: not started.
Recommended next action: P0, then P1, then send the email — or send the
email first, since it is the only one whose clock you do not control.**
