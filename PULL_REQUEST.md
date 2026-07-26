# Pull request description

Paste the body below into the PR. Base `main`, compare
`sprint1-my-library`.

---

## Title

```
Release preparation: RC-1 truthfulness, legal package, release pipeline, official website
```

---

## Description

Brings `main` up to date with roughly fifteen sprints of work, ending in
a build that is engineering-complete and a public website that hosts the
legal documents both app stores require.

**22 commits, fast-forward, no conflicts.** `main` is an ancestor of this
branch, so nothing is being reconciled.

### What lands, in six groups

**1 · Architecture and Study (Sprints 27–32)**
`DR-2026-0006` and `DR-2026-0007`: the Reading/Study boundary, the
Study Workspace at `/study/:ayahId`, data-driven text sources, and the
passage-aware commentary query. Tafsir is written for clusters of Ayahs,
so `getTextsCoveringAyah` asks *"which passage covers this Ayah"* rather
than matching `ayah_id` exactly. Coverage went from 5,291 to
**6,236 / 6,236 Ayahs** with no schema change.

**2 · Real content (Sprints 31.3–31.4)**
Two tafsir corpora imported through the reproducible data pipeline:
Al-Muyassar (Arabic) and Ibn Kathir abridged (English). Content data
version 6.

**3 · Attribution and licensing (Sprint 33)**
An attribution screen generated from the database — author, language,
version, licence and source address for every shipped source — plus the
OFL and KFGQPC font notices bundled as assets and registered with
Flutter's licence registry. `docs/LICENSING.md` records every term
verbatim, including the ones that are unfavourable.

**4 · Release infrastructure (Sprints 34–35)**
Store metadata corrected (the launcher label was literally
`quran_companion`), `PrivacyInfo.xcprivacy`, export-compliance
declaration, a legal package, and a release gate where every item is a
command. CI now builds the **release AAB** on `main` and tags and
archives `mapping.txt` — previously it only ever built a debug APK, so
nothing R8-related was ever exercised.

**5 · RC-1 truthfulness (Sprints 36 → RC-1)**
Four user-visible surfaces overstated the build and are fixed:
- "AI Tutor" → **"Study coach"** — the screen has no model and no
  inference, and said so in its own doc comment
- **Flashcards hidden** behind a data gate — the only creatable card type
  is `lemma`, and `lemmas` has 0 rows
- **"Ask AI · coming soon" removed** from Search
- **Fake "Recent"/"Suggested" blocks removed** from the Search empty state
- Profile tiles stop citing internal roadmap step numbers

New `test/feature_truthfulness_test.dart` locks this: no string may claim
AI, and every gated feature must be visible **iff** its dataset has rows,
checked against the shipped database.

**6 · Official website (Sprint 36.0)**
Five hand-written pages plus one stylesheet at the repository root. No
framework, no JavaScript, responsive, light/dark. `_config.yml` limits
what GitHub Pages publishes to those six files — serving from root would
otherwise expose the 32.7 MB content database as a direct download.

### Not in this PR

No schema change. No dependency change. No version bump
(`pubspec.yaml` stays `0.8.1+7`). No release is published.

---

## Checklist

- [x] `dart format --output=none --set-exit-if-changed lib test` — 389 files, 0 changed
- [x] `flutter analyze --fatal-infos` — No issues found!
- [x] `flutter test` — **909 passing**
- [x] Coverage ≥ 70% — 84.1% of hand-written code
- [x] `flutter build appbundle --release` succeeds; `jarsigner -verify` reports `jar verified`, CN=Du So
- [x] Licence texts present inside the AAB (4 files)
- [x] Architecture boundary tests pass (5/5)
- [x] Truthfulness gate passes (7/7)
- [x] Store metadata gate passes (11/11)
- [x] Attribution gate passes on the real database (4/4)
- [x] Website: 5 pages, 0 broken links, 0 `<script>` tags
- [x] `_config.yml` excludes the database, fonts and Flutter source
- [x] Working tree clean; branch pushed
- [x] 0 commits behind `main`; fast-forward possible
- [ ] CI green on this SHA — **required before merging** (`main` is protected)
- [ ] Post-merge: GitHub Pages verified live and correctly restricted

---

## Risk

**Overall: low.** Nothing here is irreversible, and the merge is a
fast-forward.

| Risk | Severity | Mitigation |
|---|---|---|
| Pages publishes more than intended | **High if it happens** | `_config.yml` restricts it; post-merge check requires `assets/database/quran.sqlite` to return **404**. If it does not, disable Pages before anything else. |
| Merge conflicts | None | `main` is an ancestor; verified with `git merge-base --is-ancestor` |
| Regression in the app | Low | 909 tests; every changed screen has a test asserting the new behaviour |
| Squash loses history | Medium | **Use a merge commit.** 22 commits carry decision history the ADRs reference by name. |
| Someone pushes to `main` first | Low | re-run `git rev-list --count HEAD..origin/main` immediately before merging |

**This PR does not resolve the release blockers.** One content source
(Ibn Kathir abridged, © Maktaba Dar-us-Salam 2003) is in copyright with
permission not yet requested. Merging is safe; **publishing is not**. See
`PRODUCTION_READINESS.md`.

---

## Testing

| Layer | What was run | Result |
|---|---|---|
| Unit + widget | `flutter test` | 909 passing |
| Coverage | `flutter test --coverage` | 54.1% all · 84.1% hand-written |
| Static analysis | `flutter analyze --fatal-infos` | clean |
| Real data | attribution + tafsir corpus + truthfulness tests run against the shipped `.sqlite` | passing |
| Release build | `flutter build appbundle --release` | 75.3 MB AAB, signed, verified |
| Artifact contents | `unzip -l` on the AAB | 4 licence files present |
| Device | debug build on a Pixel 8 emulator, Android 17 | Study tab, Search and Profile visually confirmed after the RC-1 changes |
| Website | 5 pages rendered at 375 px and 600 px | no page-level horizontal overflow; tables scroll inside their own containers |

Three gates were proven load-bearing by deliberately breaking the code
and watching them fail: the licence-completeness gate, the app-label
gate, and the AI-claim gate.

**Not tested:** TalkBack/VoiceOver, 200% font scale, on-device frame
rate, battery, physical hardware, iOS at all. Listed in
`KNOWN_ISSUES.md` under "Never verified".

---

## Deployment notes

**Merging this PR changes what the public sees**, because GitHub Pages
serves `main` at the repository root. On merge, the site replaces the
rendered README at:

- <https://duso201189-nxp.github.io/quran-companion/>
- <https://duso201189-nxp.github.io/quran-companion/privacy.html>
- <https://duso201189-nxp.github.io/quran-companion/terms.html>
- <https://duso201189-nxp.github.io/quran-companion/third-party.html>

Post-merge, in order:

1. Settings → Pages reads `main` / `/ (root)`
2. `curl -sI …/privacy.html` → `200`
3. **`curl -sI …/assets/database/quran.sqlite` → `404`** — if this
   returns 200, disable Pages immediately
4. Actions → the `main` run produced `app-release-aab` and `r8-mapping`
5. Tag the internal candidate: `git tag -a v0.9.0-rc1`

**Record `main`'s pre-merge SHA in this PR** (`564f2b1d5433e1c47169fbcac1e1700175de6fb3`) so the rollback target is
unambiguous. Rollback options are in `MERGE_CHECKLIST.md`.

No migration, no data change, no configuration change on any device. No
app has been published, so no user is affected by this merge.
