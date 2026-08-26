# Privacy Policy — Owner Decision Packet

**Status: DECISION AID. NOT A POLICY. NOT LEGAL ADVICE.**

**Session 114 update (2026-08-25):** the owner has confirmed answers to
B1 (legal name only — a public-facing address is still outstanding),
B2, B3, and B4 below. Each is annotated in place as **OWNER DECISION
(Session 114)**, with the original question and evidence review left
intact for provenance. B5 remains unanswered. These confirmed facts
have been carried into `docs/release/PRIVACY_POLICY_DRAFT.md` and,
where directly applicable, `docs/release/STORE_PRIVACY_FORM_DRAFT.md`
— see "How to use this packet" at the bottom for what that
finalization pass did and did not do. Section C's legal-review items
are **not** resolved by these confirmations; two of them (C6, C7) are
now unconditional rather than contingent, and are annotated
accordingly below.

**Session 128 update (2026-08-26):** the owner has now confirmed B1's
outstanding public-facing locality, and resolved B5. **OWNER DECISION
(Session 128)**, annotated in place below. The owner also confirmed a
full private residential address and date of birth as source-of-truth
identity facts for internal record-keeping — per explicit owner
instruction, **neither is reproduced in this document or any other
repository file**: only the reduced public locality is recorded here,
and no date-of-birth field exists anywhere in this packet. B1's
remaining sub-item (whether a reduced locality is legally sufficient
for store/publisher disclosure purposes) is **not** resolved by this
update and stays flagged **LEGAL REVIEW REQUIRED** below. B5 is now
fully resolved. No other Section B or C item was touched this session.

This document exists to let the owner answer every open Privacy-Policy
question **once**, in one place, instead of re-deriving them from
`docs/release/PRIVACY_POLICY_DRAFT.md` and
`docs/release/STORE_PRIVACY_FORM_DRAFT.md` piecemeal across sessions.
It does not restate those documents' evidence in full — it points to
it — and it does not answer any question on the owner's behalf.

Prepared by reading `docs/release/PRIVACY_POLICY_DRAFT.md`,
`docs/release/STORE_PRIVACY_FORM_DRAFT.md`,
`docs/release/V1_STORE_LEGAL_READINESS.md`, `pubspec.yaml`,
`README.md`, `ROLES.md`, `ios/Runner/Info.plist`,
`ios/Runner/PrivacyInfo.xcprivacy`, `android/app/src/main/AndroidManifest.xml`,
`lib/features/profile/presentation/profile_screen.dart`,
`lib/l10n/app_{en,vi,ar}.arb`, and a repository-wide search for email
addresses and legal-entity language, against `origin/main` SHA
`99e10c8f76e4c2cc1edcd2a0b7bf81f5f0f32f03` (Session 112, 2026-08-25).

---

## A. Already known from the repo — do not ask the owner about these

These were checked directly against the code. Re-asking them would
waste the owner's time on questions the repository already answers.

1. **App identifiers are consistent.** `com.duso.qurancompanion` on both
   Android (`android/app/build.gradle.kts:19,29`) and iOS
   (`ios/Runner.xcodeproj/project.pbxproj`). No decision needed.
2. **No accounts, no backend, no server-side data.** Confirmed by
   dependency and source search (`STORE_PRIVACY_FORM_DRAFT.md` §1).
3. **Exactly one network call site** (audio streaming to
   `everyayah.com`); no analytics, ads, or crash-reporting SDK anywhere
   in the codebase (§6–§10 of the same document). These are facts, not
   choices — the Privacy Policy can state them directly.
4. **App name is *almost* fully settled, not fully open.** README.md's
   title and Android's `AndroidManifest.xml:28` app label both already
   read `"Qur'an Companion"` (with apostrophe) — two of the three
   platform-facing sources agree. Only
   `ios/Runner/Info.plist:9-10`'s `CFBundleDisplayName` differs
   (`"Quran Companion"`, no apostrophe). This is **not** a
   three-way-open naming question; it is a one-file outlier. See B5
   below for the narrow question that remains.
5. **No Privacy Policy, Terms of Use, or in-app link to either exists
   anywhere in the repo.** Confirmed absent, not merely undocumented
   (`V1_STORE_LEGAL_READINESS.md` legal inventory items 1–2).
6. **QAC/Lexicon licensing status is already governed, not open for
   re-litigation here.** `DR-2026-0029` (accepted) rejected the current
   MASAQ dataset and left QAC permission unresolved without asserting a
   request was ever sent; `DR-2026-0030` (accepted) formally defers
   Lexicon (F1) and Flashcards (F2) from v1.0. See Phase 5/§ "QAC and
   Lexicon" below — no new owner input is being solicited on this by
   this packet.
7. **No contact email, business address, or legal-entity name exists
   anywhere in this repository.** A repository-wide search (`.md`,
   `.yaml`, `.dart`, `.plist`, `.xml`) for email-address patterns found
   none belonging to this project (only third-party content-source
   domains). `ROLES.md` records the project-role holder as the
   username `duso` — that is a role identity for internal governance,
   not a legal entity name, and this document does not treat it as
   one.

## B. Owner must decide

Each item below is something only the owner can supply — not because
the repository is incomplete, but because these are business/legal
facts external to the codebase.

### B1. Legal entity / publisher name and address

- **Question:** What name and address should the Privacy Policy and
  store listings identify as the app's publisher — an individual
  developer's name, or a registered business name?
- **Why it matters:** Both a Privacy Policy and each store's developer
  account conventionally name a responsible party. Google Play and
  Apple also require this at account-registration time, independent of
  the Privacy Policy itself.
- **Current repository evidence:** None. No LICENSE file, no
  copyright notice, no business name anywhere in the repo (§A7 above).
- **What answer is needed:** A name (individual or entity) and a
  mailing address suitable for public disclosure.
- **Example answer format:** `"[Full Name / Business Name], [City,
  Country]"` — e.g. `"Nguyen Van A, Hanoi, Vietnam"` or `"Duso Apps,
  registered in [jurisdiction]"`.
- **Legal review required?** Not to *answer* this question — it's a
  fact only the owner holds. Whether to operate as an individual vs. a
  registered entity is a decision the owner may want independent
  (non-Claude) advice on, but that advice-seeking is optional and
  outside this packet's scope.

**OWNER DECISION (Session 114, 2026-08-25):** Legal name is **DU SÔ**,
operating as an individual (not a registered business name). A
public-facing mailing address has **not** been supplied and remains
open — the Privacy Policy and store-account registrations still need
one before publication/submission. This is carried forward as an
explicit outstanding item in `docs/release/PRIVACY_POLICY_DRAFT.md`,
not silently dropped or invented.

**OWNER DECISION (Session 128, 2026-08-26) — public locality supplied:**
the owner has resolved the outstanding address item **only for public
disclosure purposes**, as a reduced/general locality rather than a
full street-level address:

> **Thị xã Tân Châu, tỉnh An Giang, Việt Nam**

This is the string to be used anywhere the Privacy Policy, store
listings, or developer-account public disclosures need a publisher
locality. It is **not** the owner's full residential address — the
owner separately holds a complete, hamlet-level address as private
source-of-truth information, which this document deliberately does
**not** reproduce (nor does any other file in this repository). This
packet does not assert that a reduced locality of this kind is
legally sufficient to satisfy any store's or jurisdiction's publisher-
disclosure requirements — whether it is remains **LEGAL REVIEW
REQUIRED** (see Section C, new item 8, below). No date-of-birth or
national-ID information is recorded in this document; the owner
confirmed those facts exist as private records outside the repository,
not for inclusion here.

### B2. Jurisdiction / governing legal location

- **Question:** Under which country's/region's law does the app
  operator consider themselves to operate, for the purposes of the
  Privacy Policy's governing-law statement?
- **Why it matters:** Privacy policies conventionally state a
  governing jurisdiction, and it affects which privacy regime
  (GDPR, CCPA/CPRA, Vietnam's PDPD, etc.) the policy should be written
  against.
- **Current repository evidence:** None. `docs/` is mixed
  Vietnamese/English (per `CLAUDE.md`'s own note on documentation
  language), which reflects the author's working language, not a
  declared legal jurisdiction — this packet does not treat one as
  evidence for the other.
- **What answer is needed:** A country (and, if relevant, a
  state/province).
- **Example answer format:** `"Vietnam"` or `"California, United
  States"`.
- **Legal review required?** Recommended once stated — see Section C
  ("Which privacy-law regime applies") below. Naming the jurisdiction
  is an owner fact; determining full compliance obligations that follow
  from it is a legal question.

**OWNER DECISION (Session 114, 2026-08-25):** Jurisdiction is
**Vietnam**. This is an owner-stated governing-law fact only — it does
not itself determine which privacy-law regime(s) apply to the app's
actual users (see Section C, item 6, now unconditional).

### B3. Privacy contact email or form

- **Question:** What monitored email address (or web form) should the
  Privacy Policy list for privacy-related questions?
- **Why it matters:** Both the Privacy Policy and each store's
  submission process require a real, monitored contact point.
- **Current repository evidence:** None found (§A7).
- **What answer is needed:** A real, monitored email address the owner
  controls.
- **Example answer format:** `"privacy@[yourdomain].com"` or an
  existing personal/support email the owner is willing to publish.
- **Legal review required?** No — this is an operational choice, not a
  legal interpretation.

**OWNER DECISION (Session 114, 2026-08-25):** Privacy contact is
**qurancompanionhq@gmail.com**. This is stated by the owner as the
monitored contact point; this packet does not independently verify
that the mailbox is monitored — that remains the owner's operational
responsibility.

### B4. Children's privacy / target audience declaration

- **Question:** Is this app directed at, or likely to attract, children
  under 13 (COPPA) / under 16 (some other regimes)? Should it be listed
  under Apple's Kids Category or enrolled in Google Play's Families
  Policy?
- **Why it matters:** This determines a specific, mandatory disclosure
  and design posture on both stores, and potentially under COPPA and
  similar laws elsewhere.
- **Current repository evidence:** None. No age-rating declaration, no
  COPPA/Families Policy statement, no target-audience decision exists
  anywhere in the repo (confirmed by search — §Phase 2 audit). Note,
  for owner context only: this is a Qur'an study/memorization app,
  which *could* plausibly appeal to children as well as adults, but
  this packet does not infer or suggest an answer from that
  observation — it is exactly the kind of inference this session is
  instructed not to make.
- **What answer is needed:** A yes/no/mixed-audience determination, in
  the owner's own words.
- **Example answer format:** `"General audience, not specifically
  directed at children"` or `"Directed at children under 13"` or
  `"Mixed audience, family-friendly"`.
- **Legal review required? Yes, once the owner states an intended
  audience.** The *choice* of intended audience is the owner's; whether
  that choice satisfies COPPA/Apple/Google's specific rules for the
  audience stated is a legal-interpretation question (see Section C).

**OWNER DECISION (Session 114, 2026-08-25):** Qur'an Companion is a
**general-audience application, not designed or intentionally
directed to children under 13**. This states the owner's product
positioning and design intent only. It is **not** a claim that
children are prohibited from using the app, and it is **not** a
universal legal-age or compliance claim for Vietnam or any other
jurisdiction — whether this positioning satisfies COPPA, Apple's Kids
Category rules, Google Play's Families Policy, or any other regime's
specific requirements remains open (Section C, item 7, now
unconditional).

### B5. iOS display-name correction (narrow, not a naming decision)

- **Question:** Should `ios/Runner/Info.plist`'s `CFBundleDisplayName`
  be corrected from `"Quran Companion"` to `"Qur'an Companion"` to
  match README.md and the Android app label (§A4)?
- **Why it matters:** Store listings and the installed app name should
  match across platforms; this is currently the one inconsistent file,
  not a three-way open question.
- **Current repository evidence:** README.md title and
  `AndroidManifest.xml:28` already agree on `"Qur'an Companion"`
  (with apostrophe). Only `Info.plist:9-10` differs.
  `V1_STORE_LEGAL_READINESS.md` P2-1 already flags this and explicitly
  declined to change `Info.plist` "without that confirmation" — i.e.
  it was already waiting on exactly this yes/no.
- **What answer is needed:** A yes/no. (If the owner instead wants
  `"Quran Companion"` without the apostrophe to become canonical
  everywhere, say so explicitly — that would mean changing README.md
  and Android instead, the opposite direction.)
- **Example answer format:** `"Yes, correct iOS to match"` or `"No,
  keep iOS as-is and change the other two instead"`.
- **Legal review required?** No.

**OWNER DECISION (Session 128, 2026-08-26):** **YES** — correct iOS to
match. `ios/Runner/Info.plist`'s `CFBundleDisplayName` is changed from
`"Quran Companion"` to `"Qur'an Companion"`, making all three
platform-facing sources (README.md, Android's `AndroidManifest.xml`
app label, and now iOS's `CFBundleDisplayName`) consistent. This was a
one-file outlier correction, not a three-way naming decision — see §A4
above. No bundle identifier, Team ID, signing, provisioning,
certificate, `project.pbxproj`, version, or build-number change was
made alongside it.

## C. Legal review required — not owner-decidable by guessing

These are flagged so the owner does not attempt to resolve them
unilaterally. None is answered here.

1. **Tanzil translation license vs. any future monetization
   (`PROJ-P-005`).** Tanzil's translation/transliteration data is
   licensed "for non-commercial purposes only"
   (`docs/LICENSING.md`, quoted verbatim). This already blocks paid
   features/ads without either separate permission from Tanzil or a
   source change. Not reopened or reinterpreted by this packet.
2. **Tanzil legal review itself (P0-2 in `V1_STORE_LEGAL_READINESS.md`)
   remains open, not returned.** This packet does not perform it — see
   `docs/release/TANZIL_LEGAL_REVIEW_PACKET.md` (Phase 4 of this
   session) for the evidence packet prepared to support that review.
3. **Whether the direct, unauthenticated audio-streaming request to
   `everyayah.com` counts as "sharing data with a third party"** under
   Google Play's and Apple's current disclosure rules
   (`STORE_PRIVACY_FORM_DRAFT.md` §4). This is a question of each
   store's own current policy text, not something derivable from the
   app's code.
4. **Whether the in-app Tanzil attribution string satisfies Tanzil's
   "a link is made to tanzil.net" term.** Verified in this session:
   the in-app string
   (`lib/l10n/app_{en,vi,ar}.arb:222`, rendered via plain
   `Text(l10n.aboutSourcesDetail)` at
   `lib/features/profile/presentation/profile_screen.dart:132`) is
   plain text with **no hyperlink** — confirmed by reading the widget
   code, not merely the string. Whether that satisfies the term, or
   whether a tappable link must be added, is a legal-interpretation
   question already flagged as P1-4 in `V1_STORE_LEGAL_READINESS.md`.
5. **Whether the transliteration source (Quran.com/QUL) needs
   individual named attribution** beyond the current combined string
   (P2-2 in `V1_STORE_LEGAL_READINESS.md`).
6. **Which privacy-law regime(s) apply, now that B2's jurisdiction
   (Vietnam) is known** (Vietnam's PDPD at minimum, plus GDPR,
   CCPA/CPRA, or others depending on where users are actually located,
   not just where the owner is based). Stating the jurisdiction does
   not by itself answer this — it is still open, and now unconditional
   rather than contingent on B2.
7. **Whether B4's stated target audience (general audience, not
   intentionally directed at children under 13) satisfies COPPA /
   Apple Kids Category / Google Play Families Policy requirements.**
   The audience positioning itself is now stated (§B4); whether that
   positioning, as stated, meets each regime's specific test is still
   open and now unconditional rather than contingent.
8. **Whether a reduced/general locality ("Thị xã Tân Châu, tỉnh An
   Giang, Việt Nam", supplied Session 128 — see B1) is legally
   sufficient to satisfy any store's or jurisdiction's publisher-
   address disclosure requirement**, as opposed to a full street-level
   address. This packet does not assert sufficiency either way; it
   only records the owner's chosen public-disclosure string.

## D. External platform required — Apple / Google / macOS / hosting

Nothing here can be completed by Claude from this repository.

1. **Hosting the finalized Privacy Policy at a live, public URL.**
   Both Google Play's Data Safety form and Apple's App Privacy
   questionnaire require this before submission (P0-1).
2. **Xcode/macOS archive build** to verify
   `ios/Runner/PrivacyInfo.xcprivacy` against Apple's own
   manifest-merge step — explicitly flagged as unverified in that
   file's own header comment (Session 107/109) because no
   Xcode/macOS toolchain has ever been available in this environment.
3. **Confirming HTTPS behavior of the live `everyayah.com` endpoint**
   against the production server, not just the documented URL template
   (`STORE_PRIVACY_FORM_DRAFT.md` §13).
4. **Apple Developer Program enrollment** and **Google Play Console
   registration/Play App Signing enrollment** — both prerequisites to
   ever submitting either privacy form at all (P0-4, P0-5 in
   `V1_STORE_LEGAL_READINESS.md`).

## What this packet does not do

- It does not answer B1–B5 on the owner's behalf — as of Session 128,
  B1's public locality and B5 are now owner-confirmed above; B1's
  legal-sufficiency question (Section C item 8) and Section C generally
  remain unanswered.
- It does not reach any legal conclusion listed under Section C,
  including the new item 8.
- It does not reopen, edit, or reinterpret `DR-2026-0029` or
  `DR-2026-0030`.
- It does not publish a Privacy Policy or submit any store form.
- It does not assert the app is closer to release-ready than
  `V1_STORE_LEGAL_READINESS.md` already states.
- It does not claim that a reduced/general locality is legally
  sufficient for any purpose — see Section C item 8.
- It does not record the owner's date of birth, national-ID (CCCD)
  number, or full residential address anywhere in this document.

## How to use this packet

The owner can answer B1–B5 in one pass (a single message or edit to
this file is enough) and hand C's items to whoever performs legal
review. Once B1–B4 are answered, `docs/release/PRIVACY_POLICY_DRAFT.md`
can be finalized by replacing its `[PLACEHOLDER]` markers with the
supplied answers — that finalization is a separate, later action, not
performed by this packet.

**Session 114 status:** B1 (name only), B2, B3, and B4 are now
answered above and have been carried into
`docs/release/PRIVACY_POLICY_DRAFT.md`'s corresponding placeholders.
B1's address component and B5 (iOS display-name correction) remain
open. None of Section C's legal-review items have been resolved by
this update — items 6 and 7 are now unconditional rather than
contingent, but still require legal review, not owner guessing. This
packet still does not publish a Privacy Policy, submit any store form,
or assert legal compliance.

**Session 128 status (2026-08-26):** B1 is now fully answered — a
public-facing reduced locality (`Thị xã Tân Châu, tỉnh An Giang, Việt
Nam`) has been supplied and carried into
`docs/release/PRIVACY_POLICY_DRAFT.md`. B5 is resolved **YES** and
`ios/Runner/Info.plist`'s `CFBundleDisplayName` has been corrected to
`"Qur'an Companion"`. Whether the reduced locality satisfies any
store's or jurisdiction's legal disclosure requirement is **not**
resolved — see Section C item 8 (new). No Section C item is closed by
this update. `DR-2026-0029`/`DR-2026-0030` were not touched. The
Privacy Policy remains **DRAFT, NOT PUBLISHED, NOT LEGALLY APPROVED**.
