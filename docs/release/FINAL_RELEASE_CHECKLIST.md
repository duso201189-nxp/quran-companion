# Final release checklist — all functions

Six tracks. Every item has one objective completion criterion. Where a
command can decide it, the command is given; where a person must
decide, the artifact that proves it is named.

`RELEASE_CHECKLIST.md` at the repo root remains the **engineering
gate** and is the source of truth for track A. This document adds the
five non-engineering tracks and the cross-track dependencies.

Legend: ✅ done · ❌ not done · ⏳ waiting on someone outside the team

---

## A. Engineering — 10 of 14 blocking gates pass

Full table: [`RELEASE_CHECKLIST.md`](../../RELEASE_CHECKLIST.md) §A.

| Criterion | Command | State |
|---|---|---|
| Formatter clean | `dart format --output=none --set-exit-if-changed lib test` | ✅ |
| Analyzer clean | `flutter analyze --fatal-infos` → "No issues found!" | ✅ |
| Tests green | `flutter test` → "All tests passed!" | ✅ 909 |
| Coverage ≥70% | CI lcov gate | ✅ 84.1% hand-written |
| Signed AAB builds | `jarsigner -verify -certs` → "jar verified" | ✅ |
| Licence texts in artifact | `unzip -l app-release.aab \| grep licenses/` → 4 | ✅ |
| Attribution complete | `flutter test test/attribution_real_data_test.dart` | ✅ |
| No AI claims | `flutter test test/feature_truthfulness_test.dart` | ✅ |
| No visible empty feature | same test — gate ⟺ data invariant | ✅ |
| App label human-readable | `aapt2 dump badging \| grep application-label:` | ✅ |

**Engineering is not the constraint.** Nothing in track A blocks the
release.

---

## B. Legal

| # | Criterion | Proof | State |
|---|---|---|---|
| B1 | Written permission for Ibn Kathir (Abridged), **or** the corpus removed | reply email on file, or `SELECT COUNT(*) FROM translation_sources WHERE code='tafsir_en_tafsir_ibn_kathir'` = 0 | ❌ **blocking** |
| B2 | Written permission for Tafsir al-Muyassar from KFGQPC | reply email on file | ⏳ |
| B3 | Written terms for everyayah recitations | reply on file | ⏳ |
| B4 | Transliteration provenance confirmed | reply on file | ⏳ |
| B5 | Attribution corrected for both tafsir sources | `docs/LICENSING.md` correction table applied; data rebuilt; `DATA_VERSION` bumped | ❌ |
| B6 | Zero placeholders in legal documents | `grep -rn "{{" legal/` → no output | ⚠️ 4 left: 2 publisher confirmations, 2 outreach fields |
| B7 | Privacy policy reachable | `curl -sI https://duso201189-nxp.github.io/quran-companion/privacy.html` → 200 | ⏳ page written and committed; live once the branch merges to `main` |
| B8 | Terms of use reachable | `curl -sI https://duso201189-nxp.github.io/quran-companion/terms.html` → 200 | ⏳ same |
| B9 | Non-commercial constraint recorded | `PROJ-P-005` active, `review_by` in future | ✅ |
| B10 | Project source licence decided | `LICENSE` exists at repo root, or a written decision not to publish source | ❌ |

**B1 is the release.** Everything else in this document is scheduling.

---

## C. Store

| # | Criterion | Proof | State |
|---|---|---|---|
| C1 | Play Console app created, applicationId matches | Console shows `com.duso.qurancompanion` | ⏳ |
| C2 | Play App Signing enabled | Console → App signing → "enabled" | ⏳ **irreversible after first upload** |
| C3 | Data safety form submitted | Console status "Submitted" — answers in `legal/STORE_COMPLIANCE.md` §1 | ❌ |
| C4 | Content rating issued | Console shows a rating — answers §2 | ❌ |
| C5 | Store icon 512×512 | Console accepts upload | ❌ |
| C6 | Adaptive launcher icon | `md5sum .../ic_launcher.png` ≠ `57838d52c318faff743130c3fcfae0c6` | ❌ |
| C7 | Feature graphic 1024×500 | Console accepts | ❌ |
| C8 | ≥2 phone screenshots per language | Console accepts — shot list in `STORE_LISTING.md` | ❌ |
| C9 | Short + full description, vi and en | Console fields non-empty — copy ready in `STORE_LISTING.md` | ✅ written, ❌ entered |
| C10 | Privacy policy URL entered | Console field resolves 200 | ❌ (needs B7 — URL now known) |
| C11 | Apple Developer Program active | account page "Active" | ❌ |
| C12 | `PrivacyInfo.xcprivacy` in the Runner target | `unzip -l Runner.app \| grep PrivacyInfo` → 1 hit | ❌ needs macOS |
| C13 | App privacy labels submitted | ASC "Ready for submission" — answers §4 | ❌ |
| C14 | Export compliance declared | `ITSAppUsesNonExemptEncryption` in Info.plist | ✅ |
| C15 | iOS icon 1024×1024, no alpha | `sips -g hasAlpha` → no | ❌ |

---

## D. Publisher

| # | Criterion | Proof | State |
|---|---|---|---|
| D1 | Keystore backed up off this machine | publisher confirms a second copy exists and opens | ❌ |
| D2 | Keystore passwords in a password manager | publisher confirms | ❌ |
| D3 | `mapping.txt` archived per release | file present, named by version | ⏳ per release |
| D4 | Legal entity / individual name decided | `Du So` throughout `legal/` and the site | ✅ |
| D5 | Governing jurisdiction decided | publisher confirms Vietnam in writing | ⚠️ inferred from the keystore certificate, not confirmed |
| D6 | Public contact address decided | `qurancompanionhq@gmail.com` published; mailbox monitored | ✅ published · ⏳ monitoring |
| D7 | Version number decided | `pubspec.yaml` matches the intended tag | ❌ 0.8.1+7 |
| D8 | Staged rollout planned | Console rollout set to ≤10% at first | ⏳ |

---

## E. Support

| # | Criterion | Proof | State |
|---|---|---|---|
| E1 | Support inbox exists and is monitored | test message answered within 24 h | ❌ |
| E2 | Support checklist reviewed by whoever answers | `docs/release/SUPPORT_CHECKLIST.md` read and acknowledged | ✅ written |
| E3 | Escalation path for content complaints | named person, documented | ❌ |
| E4 | Post-release monitoring plan | `docs/release/POST_RELEASE_CHECKLIST.md` first-24 h table assigned | ✅ written |
| E5 | Rollback rehearsed | publisher can locate Halt rollout in Console | ❌ |

---

## F. Marketing

| # | Criterion | Proof | State |
|---|---|---|---|
| F1 | Store copy makes no claim the build cannot keep | copy contains no "AI", no flashcards, no sync, no background audio | ✅ |
| F2 | Limitations disclosed in the listing | "IN THIS BUILD" section present in both languages | ✅ |
| F3 | Screenshots taken from a release build | no dev-preview bug icon visible | ❌ |
| F4 | Keywords set | ASC field non-empty | ✅ written |
| F5 | Category set | Books & Reference / Reference | ✅ decided |

---

## Cross-track dependencies

```
B1 (Darussalam permission or removal)
 └─► everything. No public release without it.

B6/B7/B8 (legal docs hosted) ──► C10 ──► C3 ──► store listing can go live
C6 (adaptive icon) ───────────► C5, C7, C15
D4/D5/D6 (publisher identity) ► B6
C2 (Play App Signing) ────────► must be right BEFORE first upload; not changeable after
C11 (Apple account) ──────────► C12, C13, C15 — the whole iOS track
```

Two orderings are irreversible and must not be rushed:

- **Play App Signing** — decided at first upload, forever.
- **applicationId** — cannot change without becoming a different app.
