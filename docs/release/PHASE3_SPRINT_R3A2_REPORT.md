# Phase 3 — Sprint R3a.2 Report: Web Runtime Verification

Read first: `docs/release/PHASE3_SPRINT_R3A1_REPORT.md`,
`docs/release/WEB_PLATFORM_VERIFICATION.md`. This is the `R3a-b`
follow-up both of those reports flagged as unperformed. No production
code was modified — the runtime succeeded and no issue was discovered.
No commit was created; nothing was pushed; no release document was
updated.

---

## Method

`flutter build web --release` output (`build/web`, produced in Sprint
R3a.1, containing the vendored `sqlite3.wasm` / `drift_worker.js`) was
served with `python -m http.server 8765` from inside `build/web`, and
opened in a real browser tab (Chromium 148, confirmed via
`navigator.userAgent`). Python's `mimetypes` module was verified
beforehand to map `.wasm` → `application/wasm` on this machine, and the
live response header was checked directly (`curl -I`) before opening
the app — confirming the one real MIME requirement `WEB_PLATFORM_VERIFICATION.md`
§"MIME types" flagged as host-dependent is satisfied by this test setup.

This is a static-file server with no COOP/COEP headers set (matching
`web/index.html`'s current, unmodified state — no CSP, no header
configuration) and no service worker beyond Flutter's own generated
one. It represents the "no special headers" baseline case from the
design-verification report's fallback table, not the best-case tier.

---

## Findings, task by task

### 1–3. Run the app; `sqlite3.wasm` and `drift_worker.js` load

**Both loaded successfully.** Confirmed two ways:

- The static server's own access log (authoritative — sees every
  request from every JS execution context, including inside the spawned
  Worker, unlike the browser-tab network monitor which only captured
  main-frame requests):
  ```
  GET /drift_worker.js HTTP/1.1" 200 -
  GET /sqlite3.wasm HTTP/1.1" 200 -
  GET /assets/assets/database/quran.sqlite HTTP/1.1" 200 -
  ```
- On reload, both returned `304 Not Modified` (browser cache
  revalidated against the server) rather than a fresh 200 — ordinary,
  correct HTTP caching behavior, not an error.

**Tooling note worth recording**: the Browser pane's own network-request
monitor showed zero requests for `sqlite3.wasm` and duplicated
`drift_worker.js` entries under opaque hash IDs instead of the usual
numeric ones. This is because `sqlite3.wasm` is fetched from *inside*
the dedicated Worker `drift_worker.js` spawns — a context the tab-level
monitor doesn't fully see. The static server's access log was used as
the ground truth for this reason; relying on the browser tool's network
panel alone would have under-reported and should not be trusted alone
for this kind of Worker-context verification in the future.

### 4–5. `WasmDatabase.open` succeeds; the Quran database opens correctly

**Succeeded — verified by content, not just absence of error.** The app
loaded directly into a reading view (Al-Fatihah) showing real,
correctly-joined data: Uthmani Arabic text, transliteration, and
Vietnamese translation per ayah, plus a working audio player showing
the correct reciter name. This is only possible if `WasmDatabase.open`
resolved, `initializeDatabase` copied `quran.sqlite` into persistent
storage successfully, and the content database's tables (`ayahs`,
`translations`, `reciters`) were queried successfully through the WASM
SQLite engine.

### 6. Surah list is displayed

**Confirmed.** Navigated to the Qur'an tab: all surahs rendered in
order (Al-Fatihah through at least Yusuf, scrolled), each with correct
name, Arabic name, ayah count, and Meccan/Medinan classification —
reading directly from the `surahs` table.

### 7. Search works

**Confirmed, and this is the strongest single piece of evidence in this
report.** Typed `mercy` into the Search screen: **40 real results**
returned (*"Kết quả trong nội dung · 40"*), correctly ranked across
ayahs 2:64, 2:105, 2:157, 2:178, 2:218, 2:286 — each showing the correct
Arabic verse and a Vietnamese translation snippet. This exercises the
FTS5 virtual table (`search_index`, populated with 43,652 rows in Phase
3 Sprint R1) through the vendored WASM SQLite engine specifically — a
materially harder query path than simple row lookups, and it worked
correctly on the first attempt.

### 8. Database persistence after reload

**Confirmed with a real write, not an inference.** Bookmarked ayah 1:3
(Al-Fatihah) — the bookmark icon turned solid green, confirming a
successful `INSERT` into the `user_data` database's bookmarks table.
Reloaded the page via `navigate()` (a full page reload, not an
in-app state transition). After reload:

- The server log shows `quran.sqlite` was **not re-fetched** — the
  content database was reopened from persisted storage rather than
  re-copied from the asset bundle, exactly the intended behavior of
  `DatabaseConstants.expectedDataVersion`-gated copy logic.
- Navigating back to Al-Fatihah, **the bookmark on ayah 3 was still
  present** (solid green icon), unprompted by any re-bookmark action.

This proves both databases — content (`quran_content_v4`) and user data
(`user_data`) — persist correctly across a full reload, not just within
a single session.

### 9. Storage backend actually selected

**IndexedDB**, more specifically drift's `sharedIndexedDb` tier. Determined
by direct inspection in the page's JS context, not assumed from the
design-verification report's predictions:

```json
{
  "hasOPFS": true,
  "crossOriginIsolated": false,
  "sharedArrayBuffer": false,
  "opfsRootEntries": [],
  "indexedDbNames": ["quran_content_v4 v1", "user_data v1"],
  "hasSharedWorker": true
}
```

Reasoning: `crossOriginIsolated: false` and `sharedArrayBuffer: false`
rule out the `opfsLocks` tier (requires COOP/COEP — absent here, exactly
as `WEB_PLATFORM_VERIFICATION.md` §4 anticipated for a plain static
host with no header configuration). `opfsShared` is Firefox-only and
this is Chromium. The OPFS API exists in-browser (`hasOPFS: true`) but
its root directory is empty (`opfsRootEntries: []`) — drift is not
using it. **Two real IndexedDB databases exist, named exactly matching
the `databaseName:` parameters in the app's own code**
(`'quran_content_v${DatabaseConstants.expectedDataVersion}'` →
`quran_content_v4` in `web.dart`, `'user_data'` in
`connection_web.dart`) — direct, unambiguous proof of which tier is
active. `hasSharedWorker: true` narrows it to `sharedIndexedDb`
(cross-tab-synchronized) rather than `unsafeIndexedDb`.

This is exactly the outcome `WEB_PLATFORM_VERIFICATION.md` §3 predicted
for a host without COOP/COEP: not the fastest tier, but a fully
functional, persistent one — confirmed correct in practice, not just in
theory.

### 10. Browser console inspection

**Clean.** `read_console_messages` was checked four times across the
session (initial load, mid-session, after the JS diagnostic calls, and
after reload). The only entries at any point were two `[debug] Injecting
<script> tag. Using callback.` lines, which originate from the Browser
pane tooling's own automation injection, not from the app — confirmed
by their content and timing (they appear on every page this tool
navigates to, unrelated to Flutter, Drift, or SQLite).

**Zero WASM loading errors. Zero worker errors. Zero drift
initialization errors.** No red console entries, no unhandled promise
rejections, no `console.error` calls were observed at any point,
including during the SQLite WASM fetch, Worker startup, initial content
copy (a multi-megabyte asset load), the FTS5 search query, and the
bookmark write.

---

## Task 11 — recommendation

# Runtime succeeded. Recommend committing R3a.1 + R3a.2 together.

Both sub-sprints are one logical unit — R3a.1 vendored the files, R3a.2
is the proof they actually work — and splitting them across two commits
would leave a commit in history where the claim "web platform fixed"
is unverified. Suggested scope for that future commit (not performed
here, per this task's "do not commit" instruction):

- `web/sqlite3.wasm`, `web/drift_worker.js` (R3a.1)
- `docs/DATA_PIPELINE.md` provenance update (R3a.1)
- This report and `PHASE3_SPRINT_R3A1_REPORT.md`, if the project's
  established convention of committing sprint reports alongside their
  work is followed (see prior sprints' commit history)

**Not yet recommended for the same commit**: any release-tracking
document update (`RELEASE_DASHBOARD.md`, `RELEASE_PLAN_V1.md`) — this
task explicitly deferred that ("Do NOT update release documents yet"),
and `PHASE3_SPRINT_R3A1_REPORT.md` §"Remaining follow-up items" already
flagged it as pending a future, explicit instruction.

## What this sprint did not verify (honest scope boundary)

- **Only the no-special-headers fallback path was exercised.** The
  `opfsLocks`/`sharedIndexedDb` distinction was confirmed, but the
  fastest tier (`opfsLocks`, requiring COOP/COEP) was never reached
  because this test server sets no such headers — by design, since no
  hosting decision has been made (`WEB_PLATFORM_VERIFICATION.md` §4/§5
  `R3a-d`, still open).
- **Only Chromium was tested.** Firefox's `opfsShared` path and Safari's
  documented "slightly slower regardless of headers" behavior
  (`WEB_PLATFORM_VERIFICATION.md` §4) were not exercised.
- **No CI guard exists yet** to fail the build if either vendored file
  is later deleted — still open, as noted in the R3a.1 report.
- **This was a local static-file server, not the eventual production
  host.** MIME-type correctness was confirmed for this server
  specifically; a different host must be re-checked when chosen.

---

READY FOR R3A.2 REVIEW
