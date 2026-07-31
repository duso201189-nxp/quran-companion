# Red-Team Review — Core CI Gate

Independent adversarial review of `test/repository_boundary_test.dart`,
`test/repository_boundary_completeness_test.dart`, and
`docs/LICENSING.md` on branch `ci/repository-boundary-core-gate`
(uncommitted, based on `origin/main`). Every finding below was tested
against the actual code — either executed directly (Dart scripts run
against the real regex/logic) or confirmed against real git history —
not inferred from reading alone.

No code was modified to produce this review.

---

## Findings

### F1 — CRITICAL — Grandfathered paths are content-blind and size-blind, and this is not hypothetical

**Both protective layers unconditionally skip any path in
`_grandfathered`, regardless of what that path's content becomes or
how large it grows.** Confirmed in code:

```dart
// deny-pattern check
if (_grandfathered.containsKey(path)) continue;
// size check
if (_grandfathered.containsKey(entry.key)) continue;
```

Nothing re-validates a grandfathered file's content or size once it's
in the exemption list. An in-place modification of
`assets/database/quran.sqlite` — same path, any new content, any new
size — passes both checks silently.

**This is not a hypothetical attack.** Checked directly against the
actual history that motivated this entire gate:

```
commit 2fb5fd5 — "Sprint 31.4: second real tafsir import"
 assets/database/quran.sqlite | Bin 19955712 -> 34295808 bytes
 1 file changed, 0 insertions(+), 0 deletions(-)
```

The real incident — the one `DR-2026-0013` exists to prevent a repeat
of — was exactly this shape: the same tracked path, modified in place,
nearly doubling in size, adding the Ibn Kathir corpus with no new file
added. **Had this gate existed before that commit, it would not have
caught it**, because `assets/database/quran.sqlite` is, and must be,
grandfathered — the whole point of grandfathering is to let the
already-tracked database keep existing. The mechanism that makes the
gate not immediately red on `main` today is the same mechanism that
would let the actual historical incident recur through the one file
everyone already agreed had to stay exempted.

**Severity: Critical.** This is the gate's central promise —
"prevents recurrence of a known incident" (`DR-2026-0013` frontmatter,
`threshold_reason`) — and the finding shows the *specific known
incident's exact mechanism* is not covered.

**Mitigation (not implemented here, per scope):** grandfathering should
pin a content hash, not just a path — e.g., `_grandfathered` entries
carrying an expected sha256 that only line up with the file's state
*as of when the exemption was written*, so any future content change
to a grandfathered path re-triggers scrutiny instead of silently
inheriting the exemption forever.

**Blocks merge?** Not this specific port — this property is identical
on `sprint1-my-library`, inherited unchanged, not introduced by the
split. Blocking this narrowly-scoped PR wouldn't fix it and would
delay `main` getting any protection at all. **Recommend: does not
block this PR, but must be explicitly acknowledged as an open risk in
the PR description, not silently merged as if the gate now fully
"prevents recurrence."** Silently shipping this as the load-bearing
prevention mechanism without flagging its central gap would itself be
a form of the overclaiming this project has repeatedly corrected
elsewhere (RC-1's whole truthfulness sprint exists for exactly this
reason).

---

### F2 — HIGH — Deny patterns are case-sensitive; CI runs on a case-sensitive filesystem

Dart's `RegExp` is case-sensitive by default; none of the four
`_restricted` patterns pass `caseSensitive: false`. `ci.yml` runs every
job on `ubuntu-latest` — case-sensitive. Tested directly against the
real pattern list:

| Path tested | Result |
|---|---|
| `assets/database/Quran.SQLITE` | **passes through** |
| `tool/data/Tafsir_new_corpus.json` | **passes through** |
| `TOOL/DATA/transliteration_new.json` | **passes through** |
| `some/place/backup.DB` | **passes through** |

All four confirmed by running the actual `_restricted` list against
these paths, not by inspection.

**Severity: High as a defect, partially mitigated in practice.** For
content the size of the real tafsir corpora (10 MB / 2.5 MB), the
*independent* size guard still catches a mis-cased file regardless of
name — size checking doesn't consult the pattern list at all. The true
gap is mis-cased content **under 1 MB**, where nothing catches it.

**Blocks merge?** Same reasoning as F1 — identical on
`sprint1-my-library`, not introduced by this port. **Does not block.**
Recommend a follow-up: `caseSensitive: false` on all four patterns is
a one-line-per-pattern fix with no downside.

---

### F3 — HIGH — Two of four deny patterns don't survive one extra directory level

`^tool/data/tafsir_.*\.json$` and `^tool/data/transliteration.*\.json$`
require the distinguishing keyword to appear **immediately** after
`tool/data/`, with no `.*` absorbing an intervening path segment.
Tested directly:

| Path tested | Result |
|---|---|
| `tool/data/imports/tafsir_ibn_kathir_v2.json` | **passes through** |
| `tool/data/2027/transliteration_new.json` | **passes through** |
| `assets/database/backups/quran.sqlite` (control) | correctly **blocked** |

The control case proves this isn't a universal weakness — pattern #1
(`assets/database/`) has its `.*` positioned *after* the distinguishing
directory name, so nesting is absorbed correctly. Patterns #2 and #3
put the keyword right at the anchor with nothing to absorb a
subdirectory in front of it, so they don't have the same property.
**The existing self-test for pattern correctness
("mỗi mẫu cấm thật sự khớp thứ nó nói là khớp") doesn't include a
nested-path example for any pattern**, so this gap wasn't caught by
the file's own test suite either, on either branch.

**Severity: High as a defect, same practical mitigation as F2** — real-
sized tafsir/transliteration content is still caught by the
size-independent size guard; the uncovered case is small content one
directory deeper than expected.

**Blocks merge?** Same as F1/F2 — inherited, unchanged. **Does not
block.** Worth the same one-line-per-pattern style fix
(`^tool/data/(?:.*/)?tafsir_.*\.json$` or equivalent) as a follow-up.

---

### F4 — MEDIUM — Small, arbitrarily-named restricted content is invisible to both layers, full stop

Combining F2/F3's mechanics isn't even necessary — a file that simply
doesn't resemble any of the four hand-seeded patterns bypasses
everything with no trickery required:

```
tool/data/commentary_en.json   → matches nothing, any size < 1 MB → invisible
```

**Severity: Medium.** Unlike F1–F3, this is **already explicitly
acknowledged** in the file's own header comment and in `DR-2026-0013`'s
own future-extensions section (phase F3: derive the deny-list from the
licence registry instead of hand-seeding it) — so this isn't a missed
gap, it's a known, documented, deliberately-deferred one. Included here
because the task asked to construct such scenarios concretely, not
because it's news.

**Blocks merge?** No — explicitly out of scope by the gate's own
design documents, on both branches equally.

---

### F5 — MEDIUM — The removal-phase annotation only checks shape, not truth

`RegExp('giai đoạn [A-F][0-9]')` — no anchors, matches anywhere in the
string. Tested against fabricated text:

| Reason string | Format check |
|---|---|
| `giai đoạn D1 — DR-2026-0008 nước đi B` (real) | passes |
| `giai đoạn A9 — chưa từng có ADR nào định nghĩa phase này` (fabricated) | **passes** |
| `xong rồi, giai đoạn F0, tin tôi đi` ("trust me") | **passes** |
| `thôi theo dõi ở giai đoạn Q9` (out-of-range letter) | correctly rejected |

A contributor adding a new grandfather entry can satisfy "every
exemption states its removal phase" with a well-formatted but
meaningless phase code — the test verifies the string *looks like* a
commitment, not that the phase actually exists anywhere. This directly
touches objective 5: a future contributor could reasonably believe
passing this test means their exemption is properly tracked and will
eventually be cleaned up, when nothing enforces that the referenced
phase is real.

**Severity: Medium.** Same root cause as F1 in spirit — the gate
enforces process *shape*, not process *substance*, and this is a
second instance of that pattern, specific to the exemption-hygiene
tests rather than the protective tests.

**Blocks merge?** No — the underlying test (checking the string shape)
is unchanged from `sprint1-my-library`. Worth noting as a real, if
narrow, gap in "future contributors could misunderstand the exemption
mechanism" terms.

---

### F6 — MEDIUM — New in this port: a skip message points to a document that was never committed anywhere

`repository_boundary_completeness_test.dart`'s `markTestSkipped`
message says *"Xem CI_GATE_SPLIT_PLAN.md Phần 4."* Checked directly:

```
git log --all --oneline -- CI_GATE_SPLIT_PLAN.md
(no output — never committed to any branch, ever)
```

`CI_GATE_SPLIT_PLAN.md` is a session planning artifact sitting
untracked in the working directory, exactly like every other
`RELEASE_*`, `CI_GATE_*`, and phase-report document produced in this
engagement's planning sprints — none of them were ever intended to
become permanent repository files. If this test merges as currently
written, its skip message references a document that doesn't exist in
the shipped repository and, unlike the `DR-2026-0013`/`DR-2026-0009`
references (which merge later with G15), **has no planned path to ever
existing there.**

**Severity: Medium.** Low runtime impact (it's a skip message, not a
failure a developer is forced to chase down), but unlike F1–F5 this is
**not inherited** — I wrote this text in this implementation, so
"pre-existing, not my scope to fix" doesn't apply to it.

**Blocks merge?** **Yes.** Cheap, self-contained fix: point the message
at something that will actually exist in the shipped repository — the
core file's own header, or simply inline the two-sentence reasoning
instead of citing an external document.

---

### F7 — LOW — Two independent snapshots instead of one

`repository_boundary_test.dart`'s B1 group calls `_trackedFiles()`
once in `setUpAll`; B2's group calls `_trackedFiles()` **again**,
independently, rather than reusing B1's result. In the (currently
theoretical) case of something mutating the git index between the two
`setUpAll` calls in the same test run, the two groups could see
different snapshots.

**Severity: Low.** Nothing in a normal `flutter test` invocation
mutates the working tree mid-run; this is a structural observation, not
a demonstrated exploit. Flagged because "race conditions" was
explicitly in scope for this review.

**Blocks merge?** No.

---

### F8 — LOW — Duplicated exemption data with asymmetric self-checking

`_grandfathered` and `_maxTrackedFileBytes` are duplicated verbatim
across the two files (a deliberate, documented tradeoff from
`CI_GATE_SPLIT_PLAN.md`). One asymmetry not previously called out: the
**core** file has a dedicated test that catches its own copy going
stale (a grandfathered path no longer tracked); the **completeness**
file has no equivalent self-check on its own copy — a stale entry
there just silently drops out of consideration rather than being
flagged. Low real impact, since the core file's staleness test and
phase-format test both already cover the full property for the
complete list; the completeness file's copy going stale mostly just
makes its one test quietly weaker, not wrong.

**Blocks merge?** No.

---

### F9 — LOW — Plausible future false positive, not currently triggered

`\.(sqlite3?|db)$` has no directory anchor at all — deliberately, per
its own stated reason ("database content anywhere in the tree"). A
project using Drift/sqlite3 as heavily as this one could plausibly add
a small on-disk `.db`/`.sqlite` test fixture in the future, which would
be flagged despite being clearly non-content. **Confirmed not currently
triggered** — the full local test suite passed 146/146 including this
gate's own checks against `main`'s actual current tracked files, so no
such fixture exists today.

**Blocks merge?** No — speculative, and exactly the kind of friction
`DR-2026-0013`'s own consequences section already accepts as "the
mechanism working."

---

### F10 — INFORMATIONAL — Deliberate, justified deviation from the written plan

`CI_GATE_CORE_PLAN.md`/`CI_GATE_SPLIT_PLAN.md` both specify
`_grandfathered = {}` for `main`. The actual implementation uses three
entries. **This is a correct deviation, not a defect** — verified
independently in this review by re-running `git ls-tree -r origin/main`
myself: `main` does track `quran.sqlite`, `transliteration.json`, and
`transliteration_words.json` already, so an empty map would have made
the gate fail immediately on files that predate it. The implementation
report already documents this correction; this review independently
reproduces the same finding rather than taking that report's word for
it, per objective 6.

**Blocks merge?** No — the deviation is correct, and matches what
objective 6 asked to be checked, not necessarily agreed with in
advance.

---

## Summary table

| # | Finding | Severity | Inherited or new to this PR? | Blocks merge? |
|---|---|---|---|---|
| F1 | Grandfathering is content/size-blind — matches the actual historical incident's mechanism | **Critical** | Inherited | No, but must be explicitly acknowledged, not silently shipped |
| F2 | Case-sensitive deny patterns | High | Inherited | No |
| F3 | Subdirectory-anchoring gap (2 of 4 patterns) | High | Inherited | No |
| F4 | Small/generic-named content invisible to both layers | Medium | Inherited, already documented | No |
| F5 | Removal-phase check validates shape, not truth | Medium | Inherited | No |
| F6 | Skip message cites a never-committed document | Medium | **New to this PR** | **Yes** |
| F7 | Two independent tracked-file snapshots per run | Low | Inherited | No |
| F8 | Completeness file's exemption copy has no staleness self-check | Low | New (structural, from the split itself) | No |
| F9 | Plausible future false positive for test fixtures | Low | Inherited pattern design | No |
| F10 | `_grandfathered` correctly deviates from the written plan | Info | New, and correct | No |

---

## Verdict

# NOT READY FOR PR

**Justification, concisely:** Nine of ten findings are real but
inherited unchanged from the already-reviewed `sprint1-my-library`
implementation, and blocking this narrowly-scoped port on fixing them
would delay `main` getting *any* content-gate protection while not
actually being this PR's job to fix (`CI_GATE_CORE_PLAN.md`'s own
mandate was to port and split, not redesign). Those findings — F1
above all — should travel with the PR as an explicit, written risk
acknowledgment, not be discovered later by someone assuming a green
gate means the historical incident can't recur through its own
grandfathered file.

What actually blocks: **F6 is new, self-introduced, and cheap to fix**
— a skip message this implementation wrote points to a document
(`CI_GATE_SPLIT_PLAN.md`) that has never been committed to any branch
and has no path to being committed. Shipping a reference to nothing,
in code written specifically for this PR, when the fix is a one- or
two-line message edit, doesn't meet the bar this project has held
everything else in this engagement to. Fix F6, add the F1 risk
acknowledgment to the PR description, and this is ready.
