# Session 186 — DR Ratification Review

**This document ratifies nothing.** No Decision Record's `status`
changes because of this review. No file under `docs/adr/` is created,
edited, or moved by this session. This is an analysis of whether, when,
and how `DR-2026-0008`…`DR-2026-0013` (and, for completeness,
`DR-2026-0028`) should be published onto `origin/main`, building on —
and in two places respectfully diverging from — Session 185's own
audit of the same question.

**Baseline verified fresh this session (2026-09-03):**

| Item | Value |
|---|---|
| `origin/main` | `c212f61b14dd3d3dce596f2c7671c8c4f2c17db1` (PR #67 merge) — matches the session brief's expectation exactly |
| PR #63 | OPEN — `session180-qf-response-reconciliation`, head `8dd17954e86e43a6f2af28aab86ecc90d71ffa7b` |
| PR #64 | OPEN — `session182-qf-primary-source-evidence`, head `0214db3ec56844d43e44d95a803587e075800208` |
| PR #67 | MERGED 2026-09-03T04:15:34Z |
| Open PRs (full list, `gh pr list --state all`) | Exactly #63, #64 open; 28 others merged; none closed-unmerged |
| Primary worktree | `publish-docs-reconciliation-s14`, HEAD `cd15ca11484ee3a20d8bbf72d5e9cd478091aabe`, 22-line `git status --porcelain`, 0 stashes — unchanged from Session 185's own recorded baseline |
| P2-2 | Confirmed **OPEN** (`V1_STORE_LEGAL_READINESS.md` legal-inventory item; QDC/QF transliteration licence status UNKNOWN — COUNSEL REQUIRED) |

No discrepancy from the session brief's assumed baseline was found.

---

## 1. What is actually new since Session 185

Nothing, on the governance question itself. `git log` shows no commit
touching `docs/adr/` between PR #67's merge and this session's start.
No PR addresses DR ratification. The primary worktree's untracked
`docs/adr/DR-2026-0008`…`0013` and modified `docs/adr/README.md` are
byte-identical in content to what Session 185 already read and
described (re-read directly this session, not assumed).

This session's contribution is therefore not new discovery — it is an
**independent second opinion** on a question Session 185 already
analyzed thoroughly, per this session's own brief (§3: "challenge the
ratification assumption," §4: "Em và Claude được phép tự quyết định").
Where this review agrees with Session 185, it says so briefly. Where it
diverges, it says so explicitly and states why.

---

## 2. DR Matrix

| DR | Decision | Approval evidence | Reversibility | Needed before Phase 1? | Needed before Phase 5? | Main required to govern? | Owner Gate? | Recommendation |
|---|---|---|---|---|---|---|---|---|
| `DR-2026-0008` | No licensed content committed to a public repository; content reaches the build, never the repo | `status: accepted`, `deciders: [duso]`, 2026-07-26. `verification_records: []` — never run through this project's own EIS verification | **hard** | No | Indirectly (root that `0009` "implements") | Yes, to bind `main` per `DR-2026-0028`'s own test | **Yes** | **Defer.** Do not land while `main` still tracks `quran.sqlite` with content this record would declare non-compliant (see §3.E). Bundle with `0010`/`0013` under a P2-2-linked gate, not a Phase-5 gate. |
| `DR-2026-0009` | Separate the data build from the app build; private storage, tiered access, credential-gated CI | Same evidence class | soft | No (Session 185 §5, confirmed) | **Yes**, directly (Session 184 R19–R20 reuse it) | Yes | **Yes** | Ratify together with `0011`/`0012`, gated to immediately before Phase 5 starts — not now. |
| `DR-2026-0010` | Licence registry: rights as machine-readable, three-valued (`allow`/`deny`/`unknown`) grants | Same | soft | No | Not directly (Session 185's own table: "not directly cited by Session 184's requirement set") | Yes | **Yes** | **Decouple entirely from the QF timeline.** This is P2-2's own subject matter — revisit alongside counsel's answer on P2-2, not alongside a QF engineering milestone. |
| `DR-2026-0011` | Three independent version axes: schema / artifact / dataset | Same | **hard** | No | **Yes**, directly (Session 184 R11 reuses it) | Yes | **Yes** | Ratify together with `0009`/`0012` at the Phase-5 gate. |
| `DR-2026-0012` | Artifact registry: immutable, verified, consumed by pin | Same | soft | No | **Yes**, directly (Session 184 R11 / artifact G reuse it) | Yes | **Yes** | Same bundle as `0009`/`0011`. |
| `DR-2026-0013` | CI licence gate: unbypassable, deny-list derived from the registry | Same | soft | No | Not functionally (Session 185: "Session 184 does not need it directly"; only a dangling-citation tidiness concern) | Yes | **Yes** | Defer with `0008`/`0010` — it enforces `0010`'s registry, which is not being ratified on this timeline either. |
| `DR-2026-0028` | Decision Record authority over `main`: a record governs `main` iff present on `origin/main` | `status: accepted`, 2026-08-19, from an unrelated, much earlier governance pass (Session ~20–21) | soft | N/A | N/A | **Already satisfied** — confirmed present via `git ls-tree -r origin/main -- docs/adr/` | **None — already resolved** | No action. Already ratified, already governing `main`, unrelated to the QF chain. Future sessions should stop re-flagging it as open. |

`DR-2026-0006`/`0007` (Study architecture, not in this session's
requested list but part of the same restoration batch) fall into the
same "historical, not governing" bucket as `0008`–`0013`, for the same
reason and by the same test. Not scored above because the brief did
not ask for them, but flagged so a future session does not treat their
absence from this table as an oversight.

---

## 3. Challenge: the ratification assumption

### A. Must all the DRs go to `main` before implementation can proceed?

- **FACT.** Session 184's own Phase 1 scope (§13 of that contract,
  reaffirmed by Session 185 §5) requires only a QF `client_id`/
  `client_secret` pair. No DR ratification is named as a Phase 1
  dependency anywhere in either document.
- **FACT.** `git ls-tree -r origin/main -- docs/adr/` — the exact test
  `DR-2026-0028` itself specifies — shows none of `0008`–`0013` present,
  and Phase 1 has proceeded to a fully specified, ready-to-execute state
  (per Session 185 §4) without them.
- **INFERENCE.** Implementation and ratification are on independent
  clocks for at least four phases (0–4) of the six-phase QF migration.
- **RECOMMENDATION.** No — the assumption in the session brief's own
  framing ("approved DR must be merged") is not supported by anything
  in this project's actual dependency chain, and should be retired as a
  default.

### B. Is any DR purely a historical planning artifact that should not be canonicalized?

- **FACT.** `DR-2026-0008`'s own text states "no application code
  changes" as a neutral consequence, and none of the six has any
  `verification_records` entries — none has passed this project's own
  EIS verification process, ever, on any branch.
- **FACT.** Per Session 19's restoration notes (`docs/adr/README.md`),
  `0006` and `0007` have **zero** implementation anywhere on `main` —
  not diverging, simply absent, because the Study-workspace feature
  they describe was never built there.
- **INFERENCE.** `0006`/`0007` are the closest candidates to "pure
  history with no live claim on `main`" — but they are outside this
  session's requested scope, so this review does not resolve them.
  Among the seven in scope, none is *purely* historical: `0008`/`0009`
  are actively cited by `test/repository_boundary_test.dart` on `main`
  today, and `0009`/`0011`/`0012` are actively reused as *forward*
  architecture by the merged Session 184 contract. Reuse of a record's
  ideas going forward is a different thing from the record governing
  `main` today — but it means none of the seven is inert.
- **RECOMMENDATION.** No DR in the requested set should be filed away
  as "planning artifact, no longer relevant." All seven remain live
  reference material regardless of the ratification decision.

### C. Has any DR been superseded by Session 184/185?

- **FACT.** Neither Session 184's contract nor Session 185's readiness
  audit carries `status: accepted`/`superseded` frontmatter, is filed
  under `docs/adr/`, or claims to supersede anything. Both are
  `docs/release/` planning documents, a different document class under
  this project's own `eis-core` schema.
- **FACT.** Both documents explicitly *reuse* `0009`/`0011`/`0012`'s
  designs rather than replacing them (Session 184 R11, R19–R20; Session
  185 §3, §7).
- **RECOMMENDATION.** No supersession has occurred or should be
  inferred. If `0009`/`0011`/`0012` are eventually ratified, Session
  184's contract is evidence they were validated by a second,
  independent design pass before ratification — a point in their
  favor, not a reason to skip formal ratification.

### D. Does any DR have hard reversibility but implementation can proceed without ratifying it?

- **FACT.** `DR-2026-0008` and `DR-2026-0011` are the two `hard`-
  reversibility records in scope. Neither is a Phase 1 dependency
  (§A above).
- **FACT.** `DR-2026-0011`'s architecture (three version axes) is a
  *design* Phase 1 can be built compatibly with, without the DR itself
  being on `main` — Phase 1's own output (§5, Session 185) is a raw,
  unnormalized local file, not yet touching `DATA_VERSION` or any
  schema at all.
- **INFERENCE.** Yes: for both hard-reversibility records, engineering
  work can proceed for several phases on the strength of the *design*
  being sound, deferring the *governance act* of ratification until the
  phase where the design becomes load-bearing on `main` (Phase 5 for
  `0011`; a separate, P2-2-linked gate for `0008` — see §E).
- **RECOMMENDATION.** Yes, this is possible and is exactly the "Needed
  before Phase 5?" column's function in the matrix above — hard
  reversibility is a reason for owner sign-off before the act, not a
  reason to force the act earlier than the dependency requires.

### E. What does `DR-2026-0028` say about repository presence and authority?

- **FACT.** `DR-2026-0028` is unambiguous and already governs `main`
  (it is present on `origin/main`, confirmed by the same
  `git ls-tree` test it names as authoritative): a Decision Record
  governs `main` **if and only if** it is present, with
  `status: accepted`, in `origin/main`'s tree. Nothing else —
  not acceptance elsewhere, not a working-tree copy, not citation by
  code — substitutes.
- **FACT.** `DR-2026-0028` explicitly declines to prejudge the
  publication question: "This record takes no position on whether any
  particular one should be [published into `main`], on what would then
  have to change in `main`, or in what order." This is a deliberate,
  named design choice (Option C in `DR-2026-0028`'s own "Options
  Considered" was rejected specifically because per-decision
  ratification ceremony was judged disproportionate for the *general*
  case — but the record does not forbid a case-by-case, gated approach
  for a case that actually warrants one).
- **INFERENCE.** `DR-2026-0028` was written to *answer the jurisdiction
  question once*, not to *compel* any particular publication timeline
  for `0006`–`0013`. Treating it as creating pressure to land the whole
  series promptly overreads it.
- **RECOMMENDATION.** Continue relying on `DR-2026-0028` exactly as
  written: the six records are accepted history, `main` is not in
  breach of them, and publication remains a separate, deliberate,
  future review — which this document *is*, and which still does not
  conclude "publish now."

### F. Could ratification happen via a governance index/summary instead of merging every DR?

- **FACT.** It already has. `docs/adr/README.md`, **already merged to
  `origin/main`**, contains a full "Authority over `main`
  (`DR-2026-0028`)" section stating in plain terms that `0006`–`0013`
  are accepted historical records not governing `main`, why, and how
  that could change. This is not a proposal — it is verified, current
  state of `origin/main` as of this session (`git show origin/main:docs/adr/README.md`).
- **INFERENCE.** The session brief's Option C ("tạo canonical
  architecture/governance index... còn DR giữ working-context") is not
  a choice this session faces — it is the **status quo**, already
  shipped, predating even Session 184. The real decision in front of
  this project is narrower than the brief assumes: not "index vs. full
  merge," but "when, if ever, do the underlying DR files themselves
  also get published, given the index already exists and already tells
  the truth."
- **RECOMMENDATION.** Keep the index. It is doing its job. Do not
  duplicate its content into a new document — a second "here is what's
  ratified and what isn't" file would itself become a staleness risk.

### G. If the whole series is merged as a bundle — conflicts, scope, legal implications?

- **FACT (git mechanics).** No merge conflicts are expected: `0008`–
  `0013` are new files with no existing counterpart on `main`; the only
  overlapping file is `docs/adr/README.md`, whose primary-worktree
  draft already reconciles both states (this session read it, did not
  need to re-derive it).
- **FACT (scope).** Landing the files changes zero application code, by
  every one of the six records' own "Consequences" sections (each says
  so explicitly) and by `DR-2026-0028`'s own consequences section
  ("No implementation change is authorized or required").
- **FACT (legal implication — the one this review weighs differently
  from Session 185).** `DR-2026-0008`'s decision text is **"No
  third-party licensed content is committed to a public repository.
  Content reaches the build; it never reaches the repository."**
  `main` today tracks `assets/database/quran.sqlite` (≈20 MB),
  containing content whose licence status is exactly what **P2-2**
  (still OPEN, COUNSEL REQUIRED) is asking about. Landing `DR-2026-0008`
  onto `main` **while P2-2 remains unresolved and the file remains
  tracked** would make `main`'s own governance record assert, in
  writing, with `reversibility: hard`, a policy that `main`'s own
  tracked assets visibly do not meet — turning an honestly-documented
  gap ("historical record, not governing, `main` diverges and is not
  in breach" — the current, true state) into a self-declared,
  hard-reversibility policy in active breach the moment it lands. This
  is not a hypothetical: `DR-2026-0008`'s own Risks table names exactly
  this failure shape ("Move A performed, move B never done; finding
  declared closed — **High** severity") for the mitigation/fix split it
  proposes; ratifying the record without executing or scheduling either
  move reproduces the same pattern one level up, in the governance
  record itself rather than the code.
- **INFERENCE.** This risk is specific to `0008` (and, by extension,
  `0010` and `0013`, which are its licence-registry and enforcement
  companions). It does **not** apply to `0009`/`0011`/`0012`, which
  describe data-pipeline mechanics (build determinism, versioning,
  artifact identity) with no direct textual claim about what `main`'s
  repository currently contains.
- **RECOMMENDATION.** Never bundle `0008`/`0010`/`0013` with
  `0009`/`0011`/`0012` under a single approval. Splitting them, as the
  matrix in §2 does, is not bureaucratic caution — it keeps a
  counsel-relevant legal question (P2-2) from being resolved as a side
  effect of an engineering-timeline decision (QF Phase 5), and vice
  versa.

---

## 4. Governance path — scoring and decision

| Option | Description | Score | Why |
|---|---|---|---|
| **A** — bundle all six, land after owner approval, decoupled from any phase timeline (Session 185's recommendation) | Simple, one decision, removes ambiguity fastest | **Rejected as stated** | Ignores §3.G: landing `0008` now converts an honest gap into a self-declared breach of a hard-reversibility record while P2-2 is still open. Efficient, but trades a documentation problem for a worse one. |
| **B** — ratify only the subset "truly necessary" | Sounds proportionate | **Rejected as stated** | Per §3.A, the necessary subset *before Phase 1* is empty — zero DRs. Applying this option literally would ratify nothing at all right now, which is close to correct but gives no forward plan for Phase 5, where three of the six *do* become load-bearing. |
| **C** — canonical index on `main`, DRs stay working-context until implementation validates them | Already implemented | **Confirmed as current state, insufficient alone** | Per §3.F, this already exists and is correct as far as it goes. It answers "what governs `main` today" but not "what should happen next, and when" — which the brief also asks for. |
| **D** — no ratification before Phase 1; ratify only before the phase with the actual dependency | Ties ratification timing to real need | **Adopted, refined** | Correct in spirit (§3.A, §3.D) but too coarse as stated: it treats all six DRs as one bundle tied to one future phase (Phase 5), which reintroduces §3.G's problem for `0008`/`0010`/`0013` at that later date instead of now. |

**Adopted: Option C (kept, unchanged) + a refined Option D that splits
the six into two independently-gated clusters** rather than one bundle
on one clock:

1. **Cluster 1 — data-pipeline architecture: `DR-2026-0009`,
   `DR-2026-0011`, `DR-2026-0012`.** No legal-exposure text, directly
   reused by the merged Session 184 contract, becomes load-bearing
   specifically at Phase 5 (the R2 publish step). **Gate: ratify as one
   bundle immediately before Phase 5 begins**, not now and not
   decoupled from the timeline — there is no benefit to landing them
   earlier, and no cost to waiting, since nothing before Phase 5 reads
   them as authority.

2. **Cluster 2 — licensing boundary: `DR-2026-0008`, `DR-2026-0010`,
   `DR-2026-0013`.** Directly entangled with **P2-2**, which is
   already, independently, a counsel-gated open item. **Gate: revisit
   alongside P2-2's resolution**, not alongside any QF engineering
   milestone. If counsel's eventual answer on P2-2 requires the
   content-distribution architecture these three describe, ratifying
   them becomes part of *executing* that answer, with a concrete
   remediation plan for `quran.sqlite` attached — not a bare policy
   statement landing ahead of the fix it exists to require.

3. **`DR-2026-0028`.** Already ratified, already governing. No gate.

This is not a fifth free-standing option invented for its own sake — it
is C, which this project already correctly has, plus a version of D
precise enough to avoid recreating the exact risk `DR-2026-0008` itself
warns against. Scored against the brief's own four options, it
dominates A (avoids the breach-optics risk), is more actionable than B
(gives a concrete forward path instead of "nothing now, unspecified
later"), and is more complete than C alone (adds the missing "what
happens next, and when").

---

## 5. Exact set proposed for (future) ratification, and what is excluded now

**Proposed for ratification, gated to immediately before Phase 5
starts (not now):** `DR-2026-0009`, `DR-2026-0011`, `DR-2026-0012`.

**Proposed for ratification, gated to P2-2's resolution (not now, and
not on the QF timeline):** `DR-2026-0008`, `DR-2026-0010`,
`DR-2026-0013`.

**Excluded from any ratification action by this review:**
`DR-2026-0028` (already ratified — no action needed);
`DR-2026-0006`/`0007` (out of this session's requested scope; same
"historical, not governing" status, unresolved by this review).

**Consequences of adopting this path today:** none — no file changes,
no `status` changes, no code changes. The only artifact this session
produces is this review and the owner-action brief (§8 below).

**Rollback implications:** none apply yet, since nothing is being
landed. When Cluster 1 is eventually ratified before Phase 5, rollback
is "revert the merge commit" — the records assert no code behavior
(§3.G), so no migration or data rollback is entailed. The same holds
for Cluster 2 whenever it is ratified.

**Owner Gate — exact question:** *Does the owner approve deferring
ratification of all six records past today, on the two-cluster,
two-trigger schedule above (Cluster 1 at the Phase-5 gate; Cluster 2 at
the P2-2 gate), rather than ratifying some or all of them now as a
single bundle?* If the owner instead wants Session 185's original
bundled-now approach, or a different split, that is the owner's call to
make explicitly — this review does not pre-empt it, only recommends
against the specific version that would land `DR-2026-0008` while P2-2
is still open.
