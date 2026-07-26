# Support checklist — answering users after release

What to ask, what it means, and what can actually be done. Written so a
support reply is a diagnosis, not a guess.

---

## Always collect first

| Field | Where the user finds it |
|---|---|
| App version | Profile → Version |
| Data version | Profile → Data sources → bottom of screen |
| Device model and Android/iOS version | device settings |
| Interface language | Profile → Language |

Without version **and** data version, a content report cannot be
reproduced — the same app version can carry different data builds.

---

## Known reports and their real cause

### "Audio stops when I lock the screen"

**Expected in this build.** Background playback is not implemented
(`KNOWN_ISSUES.md` K5). Not a device problem, not a settings problem.
Do not ask the user to reinstall.

### "Audio won't play at all"

1. Any other network activity working? Audio is the app's only network
   feature; everything else is offline.
2. Does another reciter work? If one fails and others work, that
   reciter's files are missing upstream, not a device issue.
3. Audio is streamed from everyayah.com. If that host is down, all
   audio fails for everyone at once.

### "A verse shows no commentary"

Should be impossible in data version 6 — all 6,236 Ayahs resolve
commentary. Ask for the exact Surah:Ayah and the data version. If data
version is below 6, the user has a stale content database; reinstalling
forces the copy.

### "Vocabulary / flashcards are empty"

**Expected in this build** (`KNOWN_ISSUES.md` K2). The lexicon tables
ship empty. There is no user action that fills them.

### "The app is slow to open"

Measured cold start is ~2.5 s, and the **first** launch after install is
~4 s because the 32.7 MB content database is copied into app storage.
First launch being slower than later ones is by design.

### "I lost my notes"

Ask, in this order:
1. Did the app get uninstalled and reinstalled? All user data is local —
   uninstall deletes it. There is no cloud backup in this version.
2. Was the device restored from an Android backup? Android's automatic
   backup may or may not have included the app.

**Be honest: there is no recovery path.** Do not promise one. Cloud sync
is roadmap step 11, not in this release.

### "Text renders in the wrong direction"

Ask for a screenshot and the source name. Direction is derived from the
source's language for body text and from the string's own script for
names. A genuine failure here is a bug, not a setting.

---

## What to escalate to engineering

Escalate with the crash report or screenshot attached:

- Any crash — the app has no crash reporting, so **a user report is the
  only signal that a crash happened**
- Any wrong or missing Qur'anic text — highest priority of all, always
- Any content rendering that looks corrupted (missing glyphs, mojibake)
- Any report of data loss that is not explained by uninstall

## What never to promise

- Cloud sync, account login, or restoring data to a new device
- Background audio
- Offline audio caching
- A web version

None exists in this release.

## Content complaints

If a user reports that a translation or commentary is wrong, misquoted,
or used without permission:

1. Do not argue about religious interpretation.
2. Record the exact source name and Surah:Ayah.
3. Route it to whoever holds the relationship with that content
   publisher — see `docs/LICENSING.md` for who each source belongs to.
4. Content complaints about attribution or permission are **legal**, not
   support. Escalate immediately.
