# Phase 3 — Sprint R3a.1 Report: Web Platform Completion (vendoring)

Read first: `docs/release/WEB_PLATFORM_VERIFICATION.md` (design
verification), `docs/DATA_PIPELINE.md`. No commit was created; nothing
was pushed.

---

# Files changed

| File | Type | Summary |
|---|---|---|
| `web/sqlite3.wasm` | **New** (747,018 bytes) | Vendored from `sqlite3.dart` release `sqlite3-3.3.4` |
| `web/drift_worker.js` | **New** (351,218 bytes) | Vendored from `drift` release `drift-2.34.0` |
| `docs/DATA_PIPELINE.md` | Modified (+22 lines) | Recorded exact source tag, SHA-256, and the forward-compat-only versioning rule for both files, per the existing per-source provenance convention already used for Tanzil/QuranEnc/everyayah |

**Not touched**: any file under `lib/` (verified: `git status --short -- lib/` returns empty), `pubspec.yaml`/`pubspec.lock`, `web/index.html`, `.github/workflows/ci.yml`. No provider, no database connection code, no runtime behavior changed — only two binary assets added and one doc updated.

# Version matching

Per the versioning rule established in `WEB_PLATFORM_VERIFICATION.md` §2a (a `drift` maintainer's direct statement: forward-compat only, `sqlite3.wasm` version must be ≤ the pinned `package:sqlite3` version):

| Package | Pinned (`pubspec.lock`) | Release tag used | Match |
|---|---|---|---|
| `sqlite3` | `3.3.4` | `sqlite3-3.3.4` | **Exact** — not "nearest" or "latest" |
| `drift` | `2.34.0` | `drift-2.34.0` | **Exact** |

Both tags were located by listing the full tag set of each GitHub repo (`simolus3/sqlite3.dart`, `simolus3/drift`) and filtering for the exact version string — not guessed from a naming pattern. Each release's asset list was fetched and inspected before download:

- `sqlite3-3.3.4` exposes three WASM variants: `sqlite3.wasm` (747,018 B, used), `sqlite3.debug.wasm` (assertions build, not for release), `sqlite3mc.wasm` (SQLCipher multi-cipher variant, not used — this project ships no SQLCipher-encrypted database). The plain `sqlite3.wasm` is the correct asset.
- `drift-2.34.0` exposes exactly one asset, already named `drift_worker.js` (not `drift_worker.dart.js` as the upstream naming convention is sometimes described) — no rename was needed.

Both downloads were SHA-256 verified twice: once against the byte count GitHub itself reported for the asset, and again after copying from the scratchpad into `web/` (hashes identical before/after copy — no corruption):

```
sqlite3.wasm      cfab48c6bbb718552ec19bc4f1365e19185311b72e4739cc19ef7333758304d3
drift_worker.js   b8b9f88cdfa0582eedacf3b55f6133b7d9bea7c8e74d4dc019a380da9976a7a8
```

# Configuration updated

`docs/DATA_PIPELINE.md`'s "Web runtime" section now records, in the same format as every other data source's provenance row in that document: exact release tag, exact SHA-256, and an explicit instruction that future `drift`/`sqlite3` version bumps (already a `CLAUDE.md` "stop and ask before" event) must re-vendor both files in the same PR rather than letting the Dart package version and the WASM/JS asset version drift apart silently.

No other configuration changed. `web/index.html` needed no edit — it carries no CSP, no service-worker registration script, and no reference to either vendored file; `WasmDatabase.open` locates them purely via the relative `Uri.parse('sqlite3.wasm')` / `Uri.parse('drift_worker.js')` calls already present in `lib/core/database/connection/web.dart` and `lib/core/database/user/connection_web.dart`.

# Gate results

## `flutter analyze --fatal-infos`

```
Analyzing quran_companion...
No issues found! (ran in 66.2s)
```

## `flutter test`

```
01:02 +802: All tests passed!
```

802/802 — identical to the pre-sprint count. Expected: no test file, provider, or runtime code was touched.

## `flutter build web --release`

```
Compiling lib\main.dart for the Web...
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 22144 bytes (98.7% reduction).
√ Built build\web
```

Clean build. Bundle size: **66 MB** (`build/web`), dominated by the Flutter engine and the vendored `sqlite3.wasm`/`drift_worker.js` themselves, not something this sprint's scope covers optimizing.

The `"Wasm dry run succeeded... consider --wasm flag"` note is Flutter's own experimental **Dart-to-WebAssembly compile target** for the app's own code (dart2wasm) — an entirely separate concern from drift's `sqlite3.wasm`, which is a pre-built C-library WASM module drift loads at runtime regardless of how the Dart app itself is compiled. Noted so the two are not conflated, per `WEB_PLATFORM_VERIFICATION.md`'s own caution on this exact point.

# Build-output verification

Beyond "the build succeeded" — the two specific things `WEB_PLATFORM_VERIFICATION.md` flagged as needing a real build to check, not an assumption:

## 1. Do the vendored files survive into `build/web/` unmodified?

```
build/web/sqlite3.wasm       747,018 bytes  — SHA-256 matches web/sqlite3.wasm exactly
build/web/drift_worker.js    351,218 bytes  — SHA-256 matches web/drift_worker.js exactly
```

Yes, byte-for-byte. Flutter's web build copies `web/`-root files verbatim.

## 2. Are they included in Flutter's generated Service Worker precache list? (the precedented CanvasKit-omission risk, `flutter/flutter#53639`)

**Finding: the concern doesn't apply — but not for the reason expected.** `build/web/flutter_service_worker.js` on this project's pinned Flutter version (**3.44.4**) is not a caching worker at all:

```js
'use strict';
self.addEventListener('install', () => { self.skipWaiting(); });
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    await self.registration.unregister();
    // ...reloads any clients still using the old service worker
  })());
});
```

31 lines total. No `RESOURCES` object, no `CORE` array, no cache-first fetch handler — it exists solely to **unregister** any service worker a returning user's browser had installed from an older Flutter version. Flutter has removed the old precaching mechanism entirely by this release; there is no manifest for either vendored file to be silently dropped from, because there is no manifest.

**Practical consequence**: every asset in `build/web/`, including `sqlite3.wasm` and `drift_worker.js`, is served via a plain HTTP fetch on each load (subject to ordinary browser HTTP caching, not a Flutter-managed cache). This is strictly simpler than the risk scenario `WEB_PLATFORM_VERIFICATION.md` flagged, and closes that report's single largest open item — confirmed by inspecting the actual file, not inferred from either project's documentation.

# What this sprint did **not** verify

Stated plainly, matching the design-verification report's own framing, so nothing here is overclaimed:

- **No real browser was opened.** The build compiles and the files are present and correctly named/served-as-static-assets, but whether `WasmDatabase.open` actually succeeds, which storage tier it selects (`chosenImplementation`), and whether data persists across a reload — none of that was exercised. This was explicitly out of this sub-sprint's scope (vendoring + static-build verification only); it remains `R3a-b` from the design-verification report.
- **No CI guard was added** to fail the build if either file goes missing in the future — that was proposed as part of the broader R3a plan but is not among this turn's eight enumerated tasks, and `.github/workflows/ci.yml` was correctly left untouched.
- **No hosting decision was made** — where `build/web` is actually deployed (and therefore whether COOP/COEP and the fastest storage tier are reachable) remains open, per `WEB_PLATFORM_VERIFICATION.md` §4/§5 (`R3a-d`).

# Remaining follow-up items

1. **`R3a-b` — real-browser runtime verification.** Serve `build/web` locally with correct MIME types (`application/wasm` for `sqlite3.wasm` — most static file servers, including Python's `http.server` on recent versions, set this correctly by extension; verify rather than assume) and confirm the app opens both databases and persists data across a reload.
2. **CI guard** — a small addition to the existing `build-web` job (e.g. `test -f web/sqlite3.wasm && test -f web/drift_worker.js` before the build step) so a future accidental deletion fails CI instead of silently shipping a broken Web build again.
3. **Hosting decision (`R3a-d`)** — still open. If GitHub Pages is chosen, COOP/COEP remain unreachable without a service-worker workaround (`WEB_PLATFORM_VERIFICATION.md` §4); this sprint's findings don't change that trade-off, only confirm the app will still function on the fallback storage tier.
4. **`RELEASE_DASHBOARD.md`** still needs its Web platform entry updated to reflect that vendoring is done — not performed here, since this task's scope was explicitly "do not modify [runtime/provider/database]" and did not list release-tracking docs among the allowed configuration changes. Flagging rather than acting, consistent with this sprint's stated boundaries.

---

READY FOR R3A.1 REVIEW
