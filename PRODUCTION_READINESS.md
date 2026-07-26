# Production readiness

Point-in-time assessment, Sprint 37.0. Read with
[`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) (the engineering gate),
[`docs/release/FINAL_RELEASE_CHECKLIST.md`](docs/release/FINAL_RELEASE_CHECKLIST.md)
(all six tracks) and [`KNOWN_ISSUES.md`](KNOWN_ISSUES.md).

---

## Current status

**Engineering is finished. The release is not.**

| Dimension | Score | One-line reason |
|---|---:|---|
| Architecture | 9.0 | boundaries test-enforced through 15 sprints of change |
| Truthfulness | 9.0 | 0 AI claims, 0 placeholder UI, 0 visible empty features — all test-enforced |
| Reliability | 8.0 | 909 tests, memory flat under scroll; no crash reporting |
| Testing | 8.5 | 84.1% of hand-written code; `lib/core` still 35.0% |
| Security | 8.0 | 2 permissions, HTTPS-only, zero telemetry, gitleaks in CI |
| Maintainability | 8.5 | source additions are data-only; 34 packages outdated |
| Documentation | 8.5 | architecture, licensing, legal, five release documents, all current |
| Accessibility | 6.0 | groundwork present, never verified with a screen reader |
| Legal | 6.5 | complete record; one source confirmed in copyright without permission |
| Release integrity | 7.5 | signed AAB verified, CI builds what ships, `mapping.txt` archived |
| **Overall** | **7.9** | the blockers are outside engineering |

### Verification at this commit

```
dart format --output=none --set-exit-if-changed lib test   389 files, 0 changed
flutter analyze --fatal-infos                              No issues found!
flutter test                                               909 passing
coverage                                                   54.1% all · 84.1% hand-written
website                                                    5 pages, 0 broken links, 0 scripts
legal package                                              4 documents, 4 placeholders left
```

---

## Completed

### Application
- Complete Qur'an: 114 Surahs, 6,236 Ayahs, verified Tanzil Uthmani
- Three independently toggleable text layers, data-driven — a new source
  is a database row, not a code change
- Two translations, two tafsir corpora, **commentary on all 6,236 Ayahs**
  via the passage-aware query
- Five reciters, speed, repeat, global mini player
- Full-text search over Arabic and Latin script
- Bookmarks, notes, highlights, collections; streaks, daily goal, Khatm
- Spaced repetition over ayahs, quiz sessions, learning sessions
- Sources & attribution screen generated from the shipped data

### Engineering
- Executable architecture boundaries; domain purity enforced by test
- Dual-database separation: a content update can never lose a note
- Reliability layer with typed failures at every repository boundary
- 909 tests; three gates proven load-bearing by deliberate regression
- CI builds the **release AAB** on `main`/tags and archives `mapping.txt`

### Release infrastructure
- Real upload keystore, signature verified with `jarsigner`
- R8 + resource shrinking; per-device download measured at 34.5 MB
- Objective release gate: 14 blocking criteria, each a command
- Five operational documents: notes, known issues, publisher, support,
  post-release
- Legal package: privacy policy, terms, third-party notices, store
  compliance worksheets, licensing record, outreach drafts
- **Public website live-ready**: 5 pages, no framework, no JavaScript

### Truthfulness
- Every label matches implementation — enforced by test
- Every visible feature has data behind it — enforced by test
- No placeholder UI, no fake loading state, no roadmap vocabulary

---

## Missing

### Blocking — no public distribution until resolved

| # | Item | Why it blocks | Owner |
|---|---|---|---|
| 1 | **Ibn Kathir (Abridged) permission** | © Maktaba Dar-us-Salam 2003. The app redistributes ~8.9 M characters of it in full. Enquiry drafted, **not sent**. | Darussalam |
| 2 | Legal documents not reachable over HTTP | both stores require a live privacy-policy URL | merge + Pages |
| 3 | App icon is the stock Flutter logo | store rejection risk; 4 other assets queue behind it | design |

### High

| # | Item | Owner |
|---|---|---|
| 4 | Tafsir al-Muyassar permission (KFGQPC) | rights holder |
| 5 | everyayah recitation terms | rights holder |
| 6 | Attribution corrections — Ibn Kathir credits the 14th-century author, not the publisher; al-Muyassar's `author` holds the work's title | engineering, 1 h |
| 7 | Store assets: screenshots, feature graphic, 512×512 icon | design |
| 8 | Play Console setup: Data Safety, content rating, App Signing | publisher |
| 9 | Keystore backup off this machine | publisher |

### Medium

| # | Item |
|---|---|
| 10 | Background audio unimplemented (disclosed in the store copy) |
| 11 | No crash reporting — field failures invisible at scale |
| 12 | Accessibility never verified with TalkBack or VoiceOver |
| 13 | Apple Developer account absent; `PrivacyInfo.xcprivacy` not in the Xcode target |
| 14 | Cold start 2,530 ms against the project's own 2 s goal |
| 15 | Governing law inferred (Vietnam), not confirmed by the publisher |

### Low

| # | Item |
|---|---|
| 16 | Web build broken — `sqlite3.wasm` / `drift_worker.js` absent; fix or drop from scope |
| 17 | 34 outdated packages, two major versions |
| 18 | `lib/core` coverage 35.0% |
| 19 | Attribution URLs displayed but not tappable |
| 20 | Longest tafsir costs ~4 dropped frames on open |
| 21 | No `LICENSE` file for the project's own source |

---

## Production risks

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| Shipping Ibn Kathir without permission | **Blocking** | certain if released today | permission, or remove the corpus — a data-build change plus a `DATA_VERSION` bump; Al-Muyassar alone still covers all 6,236 Ayahs |
| GitHub Pages exposing the content database | **Blocking** | prevented by `_config.yml` | post-merge check 5 verifies a 404; if not, disable Pages immediately |
| Play App Signing not enabled at first upload | High | low if the checklist is followed | irreversible; losing the keystore afterwards ends updates permanently |
| Keystore lost before backup | High | low | one machine holds the only copy today |
| Wrong attribution reaching users | High | certain if data is not rebuilt | correct before any distribution |
| Store rejection for the stock icon | High | high | design work, on the critical path |
| Silent crashes in the field | Medium | medium | no crash reporting; reviews and Android vitals are the only signal |
| Accessibility failure for low-vision users | Medium | medium | one day of TalkBack testing before Production |
| everyayah host disappears | Medium | low | per-reciter URL template makes a host change a data change |
| Dependency drift compounding | Low | high over time | one upgrade sprint per major dependency |

---

## Recommended release order

Each stage's exit criterion is objective.

| # | Stage | Exit criterion | Blocked by |
|---|---|---|---|
| 1 | **Merge to `main`** | `MERGE_CHECKLIST.md` post-merge 1–8 all pass | nothing — ready now |
| 2 | **Website live** | privacy and terms return HTTP 200; database returns 404 | stage 1 |
| 3 | **Internal RC** `v0.9.0-rc1` | signed AAB installed on the publisher's own device and used for one week | nothing |
| 4 | **Attribution corrected** | `docs/LICENSING.md` correction table applied, data rebuilt, `DATA_VERSION` bumped, tests green | engineering, 1 h |
| 5 | **Licensing resolved** | permission on file for Ibn Kathir **or** the corpus removed and the build retested | Darussalam |
| 6 | **Store assets** | icon, screenshots, feature graphic accepted by Play Console | design |
| 7 | **Closed Beta** | 10–20 testers, one week, zero crashes, zero content complaints | stages 2, 5, 6 |
| 8 | **Accessibility + crash reporting** | TalkBack pass on 5 screens; crash reports arriving from a test build | engineering, 2 days |
| 9 | **Open Beta / staged Production** | pre-launch report clean; rollout at 10% | stages 7, 8 |
| 10 | **Full Production** | 99%+ crash-free over one week at 10% | stage 9 |

**Stages 1–4 need nobody outside the team and can start today.**
Stage 5 is the schedule: its latency is not yours to control, which is
why the enquiries should go out before anything else.

### Version

Tag the first candidate **`v0.9.0-rc1`, not `v1.0.0-rc1`**. `ROADMAP.md`
defines v1.0 as reading + audio + commentary + search + dashboard, which
is delivered — but vocabulary, background audio and sync are absent, and
1.0 reads to a user as "complete". 0.9.0 is a claim this build can keep.

---

## Go / No-Go

**Merge to `main`: GO.** Every pre-merge check passes, the merge is a
fast-forward, conflicts are impossible, and nothing in it is
irreversible.

**Public distribution: NO-GO.** One content source is confirmed in
copyright without permission. That is a line, not a schedule item.
