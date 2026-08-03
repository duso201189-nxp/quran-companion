# Web Platform Verification — Phase 3 Sprint R3a Design Verification

Design-verification pass before implementation. **No code was written, no
file modified, no commit made.** Every claim below is either sourced from
the actual repository (file path + line cited) or from drift's official
documentation / a maintainer's own written statement (URL cited). Nothing
here is inferred from a summary of a summary.

---

## 0. Headline

The two-file requirement recorded in this project's own docs
(`sqlite3.wasm`, `drift_worker.js`) is **necessary but the story is more
specific than "download two files."** Five findings change the effort/
risk picture:

1. **The app code already degrades gracefully if the ideal storage tier
   is unavailable** — drift has a five-tier fallback chain, and the two
   files are sufficient for *all five tiers*, including the fastest.
2. **Version compatibility is a real, documented failure mode**, not a
   formality — a maintainer states forward-compat-only rules with an
   explicit "hours of debugging" precedent.
3. **CI never deploys the web build anywhere** — it only uploads a
   7-day artifact. There is currently no live hosting target to verify
   against.
4. **If the eventual host is GitHub Pages, the fastest storage tier is
   structurally unreachable** — GitHub Pages cannot set the headers that
   tier requires, and has no `_headers`-file mechanism to work around it.
5. **Whether the two files survive Flutter's own build/service-worker
   pipeline unmodified is not verified** — it must be checked against a
   real `flutter build web` output, not assumed from either project.

None of these is a blocker. All five change what "done" means and how
much of the effort is verification versus file-copying.

## 1. Every runtime dependency required by Drift WASM

Read from `lib/core/database/connection/web.dart` and
`lib/core/database/user/connection_web.dart` (both call
`WasmDatabase.open(sqlite3Uri:, driftWorkerUri:, ...)`), cross-checked
against drift's own web documentation.

| Dependency | Required by | Source |
|---|---|---|
| `sqlite3.wasm` — SQLite compiled to WebAssembly | `WasmDatabase.open`'s `sqlite3Uri` | package `sqlite3.dart`'s own GitHub releases — **not** drift's releases (confirmed distinct repos, see §2) |
| `drift_worker.js` (upstream name: `drift_worker.dart.js`) | `driftWorkerUri` — hosts the DB in a background Worker | drift's GitHub releases |
| A same-origin-servable static host | Both files are fetched by relative `Uri.parse(...)`, no CORS handling in the call | Implicit in the code — no `Uri` includes a scheme/host |
| Correct MIME type on `sqlite3.wasm` | Browsers require `Content-Type: application/wasm` for the WASM module | drift docs: *"must be served with `Content-Type: application/wasm`… `flutter run` handles this by default, but production servers must be explicitly configured."* [[drift.simonbinder.eu/web]](https://drift.simonbinder.eu/web/) |
| A persistence backend the browser actually supports | Drift probes and falls back automatically | See fallback chain, §4 |
| The shipped content asset (`assets/database/quran.sqlite`) | `initializeDatabase` callback loads it via `rootBundle.load` on first open ([web.dart:24-28](lib/core/database/connection/web.dart:24)) | Already an existing asset dependency (`pubspec.yaml:43`), not new to Web |

**Not required, contrary to what the phrase "runtime dependency" might
suggest:** no service worker, no manifest entry, no CSP directive is
*mandatory* for the app to function — see §4 for the precise, cited
reasoning behind each.

## 2. Every file that must exist inside `/web`

Current contents of `web/` (verified by listing):

```
web/favicon.png
web/icons/Icon-192.png
web/icons/Icon-512.png
web/icons/Icon-maskable-192.png
web/icons/Icon-maskable-512.png
web/index.html
web/manifest.json
```

Files that must be **added**:

| File | Exact source | Version constraint |
|---|---|---|
| `sqlite3.wasm` | `github.com/simolus3/sqlite3.dart` releases | See §2a |
| `drift_worker.js` | `github.com/simolus3/drift` releases, asset named `drift_worker.dart.js` upstream — **rename on placement**, the Dart code's `Uri.parse('drift_worker.js')` ([connection_web.dart:10](lib/core/database/user/connection_web.dart:10)) is what fixes the required filename, not the upstream release-asset name | See §2a |

No other new file is required. `index.html` needs **no edit** for the
minimal path (no CSP meta tag exists today to reconcile; see §4).

### 2a. Version constraint — verified against a maintainer's direct answer

Resolved versions in this repo, from `pubspec.lock`:

```
sqlite3          3.3.4   (transitive, pulled in by drift)
drift            2.34.0
sqlite3_flutter_libs  0.5.42   (native-platform loader — irrelevant on Web, see §6)
```

A maintainer of `drift`/`sqlite3.dart` (simolus3) stated the compatibility
rule explicitly in a GitHub Discussion a user opened after losing hours
to a mismatch:

> *"If you use a `sqlite3.wasm` from version x, the version of
> `package:sqlite3` must be at least that version."* Forward
> compatibility (older wasm, newer package) works; the reverse does not.
> Major-version jumps (their example: sqlite3 2.x → 3.x) have **no**
> compatibility.
> — [github.com/simolus3/drift discussion #3721](https://github.com/simolus3/drift/discussions/3721)

**Concrete instruction this produces**: the `sqlite3.wasm` binary must
come from a `sqlite3.dart` release tagged **`sqlite3-v3.3.4` or lower**
(never higher than the pinned Dart package), and `drift_worker.js` from
a `drift` release **compatible with drift `2.34.0`** — in practice, the
matching tagged release is the safe default, not "latest."  This is a
real acceptance criterion for the implementation sprint, not a footnote.

## 3. Are the two files sufficient?

**Yes — for correctness. Not necessarily for peak performance,
depending on where the app is hosted.** These are separable claims and
the design review should not conflate them.

Drift selects among five storage implementations at runtime, most to
least capable, entirely automatically — the two files are sufficient
input for the probe to run and land on *whichever tier the current
browser and headers support*:

| Tier | Requires | Persists across reloads | Notes |
|---|---|---|---|
| `opfsShared` | Origin Private File System + `SharedWorker` | ✅ | Firefox only, currently |
| `opfsLocks` | OPFS + **COOP/COEP headers** | ✅ | Fastest cross-browser tier |
| `sharedIndexedDb` | IndexedDB in a shared worker | ✅ | No special headers |
| `unsafeIndexedDb` | IndexedDB, no cross-tab sync | ✅ | No special headers |
| `inMemory` | — | ❌ (lost on reload) | Last-resort fallback |

Source, quoted directly: *"if you use `flutter run` just like always
Drift will fall back to a (slightly slower) implementation"* — i.e. the
absence of special headers is an explicitly supported, documented path,
not an error state. [[drift.simonbinder.eu/web]](https://drift.simonbinder.eu/web/)

**Conclusion: the two files alone take the app from "crashes on open"
(today's state) to "opens and persists data" on every evaluated browser
except pathological cases (private browsing with no IndexedDB, which
falls to in-memory).** Whether it lands on the fastest tier is a
*separate*, hosting-dependent question — §4.

## 4. Additional hosting/runtime requirements

### CSP

**No requirement identified.** `web/index.html` currently has no `<meta
http-equiv="Content-Security-Policy">` tag ([index.html](web/index.html),
verified line-by-line) — there is nothing to reconcile. If a CSP is
added later for unrelated reasons, it will need `worker-src` and
`script-src` to permit same-origin Workers and WASM instantiation
(`'wasm-unsafe-eval'` in current CSP spec terms), but this is
speculative against a control that does not exist in the repo today.

### MIME types

**Real requirement, host-dependent.** `sqlite3.wasm` must be served as
`application/wasm` (§1). GitHub Pages, Netlify, Cloudflare Pages, and
Firebase Hosting all serve `.wasm` with the correct type by extension
today as a matter of common, current practice — but this project has
**no confirmed deployment target** (§0.3), so this is a check to run
against whichever host is chosen, not an assumption to carry forward
silently.

### Service Worker

**Not required by drift.** Quoted directly: drift "uses dedicated or
shared web workers internally, which are managed automatically by
`WasmDatabase.open`" — a plain Web Worker, unrelated to the Service
Worker/PWA-caching layer. [[drift.simonbinder.eu/web]](https://drift.simonbinder.eu/web/)

**Flutter's own build *does* generate one, independently.**
`flutter build web` always emits `build/web/flutter_service_worker.js`,
which precaches a `RESOURCES` manifest keyed by content hash and
replaces entries on redeploy. Whether files placed directly in `web/`
(as opposed to Dart-declared assets) are reliably included in that
generated manifest **has a documented historical failure mode**:
CanvasKit's own `.wasm`/`.js` files were reported missing from
`RESOURCES` in past Flutter versions, requiring manual addition
([flutter/flutter#53639](https://github.com/flutter/flutter/issues/53639)).
**This must be checked against a real build of *this* project's current
Flutter version (3.44.4, pinned in `ci.yml:34`) — not assumed fixed or
assumed broken.** This is the single largest unverified item in this
report.

### Asset manifest

Not a Dart/Flutter asset in the `pubspec.yaml` sense (files under
`web/` are **not** declared under `flutter: assets:` —
[pubspec.yaml:42-43](pubspec.yaml:42) lists only the database and font
files). They are copied verbatim by the Flutter web build's own
tooling, then subject to the Service Worker question directly above.

### Cache

Browser HTTP caching of `sqlite3.wasm`/`drift_worker.js` themselves is
governed by the host's normal `Cache-Control` headers — no drift-specific
requirement found. **Separately**: the shipped `quran.sqlite` content
asset is versioned via `DatabaseConstants.expectedDataVersion`
(currently `'4'`,
[database_constants.dart:8-9](lib/core/database/database_constants.dart:8))
compared against `meta.data_version` inside the file, driving
app-level copy-over-stale-cache logic. That mechanism is
**unchanged by and independent of** the Web runtime fix — it already
exists for native platforms and applies identically once Web can open
a database at all.

### Browser compatibility

Cited directly from drift's own compatibility notes:

| Browser | Support |
|---|---|
| Firefox 114+ | Full (`opfsShared`); private browsing falls back to IndexedDB |
| Chrome 114+ | Full **with** COOP/COEP headers; "slightly slower" without |
| Chrome on Android | Limited without headers — no `SharedWorker` support there |
| Safari 16.2+ | "Slightly slower regardless of headers" |

No hard minimum version is stated below which the app cannot open at
all — degradation is graceful down to `inMemory` in the worst case.
[[drift.simonbinder.eu/web]](https://drift.simonbinder.eu/web/)

### The hosting question this report cannot close on its own

`ci.yml`'s `build-web` job ([ci.yml, `build-web:` block](.github/workflows/ci.yml))
runs `flutter build web --release`, reports bundle size, and uploads
`build/web` as a **7-day CI artifact**. It does not deploy anywhere.
This repository has exactly one workflow file
(`.github/workflows/ci.yml`) — there is no Pages-deployment workflow
committed to this repo.

**If the eventual choice is GitHub Pages**: as of this verification,
GitHub Pages has **no mechanism to set custom response headers** —
confirmed via an open, unresolved GitHub product discussion asking for
exactly this
([github.com/orgs/community/discussions/13309](https://github.com/orgs/community/discussions/13309))
and independently corroborated
([blog.tomayac.com, 2025-03-08](https://blog.tomayac.com/2025/03/08/setting-coop-coep-headers-on-static-hosting-like-github-pages/)).
COOP/COEP are therefore **unreachable on GitHub Pages** without a
service-worker workaround (`coi-serviceworker`, a known community
pattern — genuinely more engineering than this sprint's stated scope).
**Consequence, not a blocker**: the app would run correctly on
`sharedIndexedDb`/`unsafeIndexedDb` — see §3's fallback table — just
not the fastest tier. This is a scope decision (§5 R3a-b) the sprint
should make explicitly rather than default into silently.

## 5. Implementation effort estimate

Splitting the work the way the evidence above actually splits it —
**not** the single "vendor two files" step the backlog currently states:

| Task | Estimate | Why |
|---|---|---|
| **R3a-a**: Download & vendor `sqlite3.wasm` + `drift_worker.js` at the correct, version-matched release tags (§2a) | **Small** | Two file downloads, one rename, one `docs/DATA_PIPELINE.md` update recording the exact pinned tag (matching how every other data source in that file already records provenance) |
| **R3a-b**: Runtime verification in an actual browser — confirm the app opens, confirm which storage tier drift selects (`chosenImplementation`), confirm data persists across a reload | **Small-Medium** | This is the step that turns "should work per the docs" into "does work"; nothing in this report substitutes for it |
| **R3a-c**: Confirm the two files survive `flutter build web` unmodified — inspect `build/web/flutter_service_worker.js`'s `RESOURCES` list for their presence (§4 Service Worker) | **Small** | One build + one file inspection; only becomes Medium if the historical CanvasKit-omission bug reproduces and needs a workaround |
| **R3a-d**: Explicit hosting decision — where does `build/web` actually get served, and is COOP/COEP in scope for this release | **Tiny (decision) → Small (if a CI deploy step is added)** | Currently undecided; affects whether §4's GitHub-Pages caveat is even relevant |
| **CI update**: a check that fails the build if the two files are absent, closing the "green CI on a broken platform" finding from the prior sprint | **Tiny** | A two-line `test -f` guard in the existing `build-web` job |

**Overall: Small-Medium**, matching the prior estimate directionally,
but for a more precise reason: the *files* are genuinely small effort;
the *verification* (R3a-b, R3a-c) is the part that must not be skipped,
because both this project's docs and drift's own docs describe expected
behavior that neither has been confirmed against this specific app,
this specific Flutter version, or a real browser.

## 6. Runtime risk estimate

**Low-Medium**, with the risk concentrated in three specific,
independently-mitigable items rather than spread evenly:

| Risk | Severity | Mitigation |
|---|---|---|
| Version-mismatched `sqlite3.wasm`/`drift_worker.js` (§2a) — a maintainer-documented, real-world failure mode | **Medium** | Pin exact release tags in `docs/DATA_PIPELINE.md`; re-verify on every `drift`/`sqlite3` bump (already a "stop and ask" event per `CLAUDE.md`) |
| Files silently dropped from the Flutter Service Worker precache list (§4), a **precedented** bug class | **Medium** | R3a-c's build inspection catches this directly; not a hypothetical — CanvasKit hit exactly this |
| Suboptimal storage tier on the eventual host (e.g., GitHub Pages without COOP/COEP) | **Low** | Explicitly *not* a correctness risk — confirmed by drift's own graceful-degradation design (§3); a performance/UX trade-off to decide consciously, not accidentally |
| `sqlite3_flutter_libs` (native-library loader, `pubspec.lock` pins `0.5.42`) doing something unexpected on Web | **Low** | It is a `direct main` dependency but its role is exclusively native-platform library loading; the Web code path never references it (`connection/web.dart` imports only `package:drift/wasm.dart`) — worth a one-line confirmatory grep during R3a-a, not a redesign |
| Regression to native platforms (Android/iOS/desktop) | **Very Low** | Zero files in this sprint's scope touch `connection/native.dart` or `connection/unsupported.dart`; the change is additive to `web/` only |

**No risk identified rises to "correctness at stake."** The worst
realistic outcome — a suboptimal storage tier — still yields a working
app, per drift's own fallback design. The risk that would actually hurt
(shipping the wrong `sqlite3.wasm`/`drift_worker.js` pairing, or having
Flutter's build silently drop them) is real, precedented, and fully
addressed by R3a-b and R3a-c's verification steps rather than by any
code change.

---

## Summary for the implementation sprint

The prior sprint's estimate ("Low-Medium for (a) \[full fix\], the real
work is runtime verification, not integration") is **confirmed, and now
specific**: R3a-a (vendoring) is genuinely small; R3a-b and R3a-c
(runtime + build verification) are where the actual engineering
judgment is required, because they are the two places this report found
a real, documented, precedented failure mode. R3a-d (hosting) is a
decision, not an implementation task, and should be made explicitly so
the COOP/COEP trade-off in §4 isn't inherited by accident.

No code was written, no file modified, no commit made, to produce this
report.
