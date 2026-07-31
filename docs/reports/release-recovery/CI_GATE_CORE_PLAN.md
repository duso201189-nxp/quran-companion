# CI Gate Core Plan — component inventory

Sprint: Release Recovery Phase 2. Analysis only — no code, branch,
commit, push, or PR was created producing this. Source inspected:
`test/repository_boundary_test.dart`, 418 lines, read via
`git show origin/sprint1-my-library:test/repository_boundary_test.dart`
(the working checkout is on `main`, which predates this file — reading
it required no checkout, only a read-only `git show`). Also inspected:
`.github/workflows/ci.yml` on both branches, and `.gitignore` on
`sprint1-my-library`, to ground the "workflow integration" and
layered-defense claims in the file's own header comments rather than
assume them.

---

## 1 — Complete implementation, top to bottom

| Lines | Element |
|---|---|
| 1–31 | Header comment: rationale, four-layer defense model, phase scope |
| 33–36 | Imports: `dart:convert`, `dart:io`, `flutter_test` |
| 45–64 | `_restricted` — 4 regex deny-patterns with reasons |
| 77–85 | `_grandfathered` — 5 exact-path exemptions with removal-phase notes |
| 91–110 | `_trackedFiles()` — reads `git ls-files -z` |
| 112–117 | `_restrictionFor(path)` — pattern lookup |
| 132–165 | `_maxTrackedFileBytes` constant (1 MB) + its justification comment |
| 189–199 | `_trackedFileSizes(tracked)` — on-disk size reader |
| 201 | `_mb(bytes)` — formatting helper |
| 204–321 | Test group "Ranh giới kho mã" (B1) — 6 tests |
| 323–417 | Test group "Chặn theo kích thước" (B2) — 4 tests |

Ten tests total, in two `group()` blocks, sharing the helpers above.

---

## 2 — Every component belonging to the Core CI Gate

### Mechanism (code)

| Component | Why it's Core |
|---|---|
| `_restricted` deny-pattern list | The actual protective rule. References no specific tracked file's existence — it's evaluated against whatever `git ls-files` returns, on any branch. |
| `_trackedFiles()` | Pure git-metadata reader. No content knowledge. |
| `_restrictionFor()` | Pure pattern lookup. No content knowledge. |
| `_trackedFileSizes()` | Pure on-disk size reader. No content knowledge. |
| `_mb()` | Formatting only. |
| `_maxTrackedFileBytes` (the constant, 1 MB) | A general policy value — "no tracked file should exceed this" — independent of which files currently exist. |
| The **existence of an exemption mechanism** (`_grandfathered` as a data structure consulted by the checks) | Core infrastructure: the deny-check and size-check both need *some* way to except known-legitimate large/matched files. The mechanism is generic; only its *current contents* are branch-specific (see §3 — this is the one place Core and content-specific meet, and they're separable). |

### Mechanism (tests)

| Test | Group | Why it's Core |
|---|---|---|
| "git đọc được và kho mã không rỗng" | B1 #1 | Sanity check on the mechanism itself (`tracked.length > 100`) — true on any real checkout of this repository, `main` included |
| **"KHÔNG tệp nội dung hạn chế nào mới được đưa vào git"** | B1 #2 | **The actual protective check.** This is the gate. |
| "mọi mục miễn trừ đều CÒN được theo dõi" | B1 #3 | Protects the *mechanism's* integrity — stops the exemption list from silently drifting stale. Currently red only because its input data (see §3) hasn't been updated for the target branch, not because the check is content-specific in design |
| "mỗi mục miễn trừ nêu rõ giai đoạn xoá nó" | B1 #4 | Same category: enforces that no exemption can linger forever without a stated removal plan. Design-level hygiene, not content-level |
| "miễn trừ là ĐƯỜNG DẪN CHÍNH XÁC, không phải mẫu" | B1 #5 | Protects the mechanism from being weakened into a pattern-based exemption, which would create a loophole for *future*, not-yet-seen content. Pure mechanism integrity |
| "mỗi mẫu cấm thật sự khớp thứ nó nói là khớp" | B1 #6 | Tests the regexes against **hardcoded example paths** — doesn't touch live repo state at all. Fully branch-independent |
| "đọc được kích thước của mọi tệp đang theo dõi" | B2 #7 | Sanity check on the mechanism |
| **"KHÔNG tệp theo dõi nào vượt ngưỡng"** | B2 #8 | **The actual size-based protective check.** |
| "ngưỡng còn dư địa thật trên tệp hợp lệ lớn nhất" | B2 #9 | Computes the largest **non-grandfathered** tracked file *at runtime* from whatever `sizes` actually is, and checks a 2× margin. Not hardcoded to any specific file — will correctly find `main`'s own largest legitimate file and self-verify against it |

**Result: 9 of 10 tests are Core**, and three of those nine (B1 #3, #4,
#5) are currently red on `main`-shaped data only because of a data
mismatch addressed in §3/§4 below — not because their design depends on
specific content.

### Workflow integration

**There is no separate integration point to migrate.** Checked
`ci.yml` directly: the `quality` job runs `flutter test --coverage`
(line 129) with no file-level filtering — this single command already
executes every `*_test.dart` file under `test/`, including this one,
automatically. Bringing the Core Gate to `main` requires **no workflow
change at all** — it activates the moment the test file exists on the
branch CI already checks out. This removes an entire category of risk
other splits in this recovery effort have had to deal with.

### Other layers named in the file's own header (checked, not assumed)

The header comment (lines 9–19) describes a four-layer model:
`.gitignore` → pre-commit hook → **this CI gate** → *(B2 size guard,
same file)*. Checked both of the other two layers directly:

- **`.gitignore`** on `sprint1-my-library` has **no entries** for
  `*.sqlite`, `tafsir`, or `transliteration` patterns — the deny-list
  described in the header as "layer 1" does not actually exist as
  written. The header's own text already says this layer "does not
  enforce it — `-f` bypasses it," so its absence doesn't weaken
  anything this CI gate does; the gate was written assuming this layer
  might not hold, which is exactly the situation found.
- **Pre-commit hook**: no hook config (`.githooks/`, `husky`,
  `lefthook`, or similar) is tracked anywhere in the repository. Same
  conclusion — the CI gate's own design already treats this layer as
  optional and bypassable (`--no-verify`), so its absence is consistent
  with, not contrary to, the gate's stated purpose: *"layer 3 is the
  only one nobody can skip."*

**Neither of these missing layers is a dependency of the Core Gate.**
The gate was designed to be the backstop precisely because the earlier
layers can't be relied on — this is confirmed by inspection, not
assumed from the header comment alone.

---

## 3 — Every component belonging only to Completeness Verification

### The one test

| Test | Group | Why it belongs only here |
|---|---|---|
| **"mọi mục miễn trừ vượt ngưỡng đều nêu giai đoạn gỡ nó"** | B2 #10 | Its assertion is `expect(neededBySizeGuard, isNotEmpty, ...)` — it requires at least one grandfathered entry to **actually exceed** `_maxTrackedFileBytes` on the branch it runs against. Its entire purpose is to prove the size-guard mechanism has been exercised against a real oversized file, not left as an untested code path. That is a coverage/completeness question — "is this protection currently backed by evidence" — not a protection question. Every other B2 test still enforces the actual size boundary without this one. |

This is exactly one test, out of ten. Nothing else in the file has this
property: everything else either doesn't reference `_grandfathered`'s
contents at all, or references them only to check the exemption
mechanism's own hygiene (which degrades gracefully to "vacuously true"
on an empty list, not to a failure).

### The data, not the mechanism

`_grandfathered`'s **current five entries** are legal-content-specific
data:

```
tool/data/tafsir_en-tafsir-ibn-kathir.json   → deleted at A3
assets/database/quran.sqlite                 → untracked at D1
tool/data/tafsir_ar-tafsir-muyassar.json     → untracked at D2
tool/data/transliteration.json               → untracked at D2
tool/data/transliteration_words.json         → untracked at D2
```

None of these five files exist on `main`. **The map itself (the
exemption mechanism) is Core; these five specific rows are content
belonging to whichever branch actually tracks Ibn Kathir and the
current database — i.e., `sprint1-my-library`, not `main`.** This is
the one place in the file where Core mechanism and legal-content-
specific data are the same variable, which is exactly what makes the
split in Part 4 of `CI_GATE_SPLIT_PLAN.md` a data change, not a logic
change.

### Documentation comment, not logic

The `_maxTrackedFileBytes` justification comment (lines 132–164) lists
the exact measured sizes of the five grandfathered files as the
empirical basis for choosing 1 MB, plus the two largest *legitimate*
files it found on `sprint1-my-library` (`Inter-Bold.ttf` 0.401 MB,
`app_database.g.dart` 0.334 MB). **This is documentation, not an
executable dependency** — test B2 #9 re-derives the real margin at
runtime regardless of what the comment says, so the comment going
slightly stale (describing `sprint1-my-library`'s file distribution
while running on `main`) doesn't affect correctness. It does affect
*accuracy for a future reader*, and should be refreshed against
`main`'s own distribution when this ports — a documentation task, not
a design change.

---

## Summary

| Category | Count | Components |
|---|---|---|
| Core — mechanism | 6 | `_restricted`, `_trackedFiles`, `_restrictionFor`, `_trackedFileSizes`, `_mb`, `_maxTrackedFileBytes` |
| Core — tests | 9 | B1 #1–6, B2 #7–9 |
| Completeness-only — tests | 1 | B2 #10 |
| Branch-specific data (mechanism stays, content doesn't) | 1 | `_grandfathered`'s five current entries |
| Documentation needing a refresh, not a redesign | 1 | `_maxTrackedFileBytes`'s justification comment |
| Workflow integration required | 0 | already automatic via existing `flutter test --coverage` |
