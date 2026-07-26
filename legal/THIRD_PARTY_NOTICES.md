# Third-Party Notices — Qur'an Companion

Everything distributed with or streamed by Qur'an Companion that was
not written for this project. Generated at Sprint 34.0 (2026-07-26)
from `pubspec.lock`, the `.ttf` name tables, and the shipped
`quran.sqlite`.

**In-app equivalents.** Content sources: Profile → Data sources.
Software and font licences, in full: Profile → Data sources →
Software & font licences (Flutter's `showLicensePage`, which also
enumerates every transitive package). This file exists for the store
listing and the project website, where an in-app screen cannot be
linked.

---

## 1. Software libraries — direct dependencies

Licence text for each is reproduced in full inside the app. All 13 are
permissive; **none is copyleft**, so none imposes a source-disclosure
obligation on this app.

| Package | Version | Licence | Copyright |
|---|---|---|---|
| drift | 2.34.0 | MIT | © 2021 Simon Binder |
| flutter_riverpod | 2.6.1 | MIT | © 2020 Remi Rousselet |
| go_router | 14.8.1 | BSD-3-Clause | © 2013 The Flutter Authors |
| intl | 0.20.2 | BSD-3-Clause | © 2013 the Dart project authors |
| just_audio | 0.9.46 | MIT | © 2019-2020 Ryan Heise and contributors |
| just_audio_windows | 0.2.3 | MIT | © 2022 Bruno D'Luka and contributors |
| package_info_plus | 10.2.0 | BSD-3-Clause | © 2017 The Chromium Authors |
| path | 1.9.1 | BSD-3-Clause | © 2014 the Dart project authors |
| path_provider | 2.1.6 | BSD-3-Clause | © 2013 The Flutter Authors |
| scrollable_positioned_list | 0.3.8 | BSD-3-Clause | © 2018 the Dart project authors |
| shared_preferences | 2.5.5 | BSD-3-Clause | © 2013 The Flutter Authors |
| sqlite3_flutter_libs | 0.5.42 | MIT | © 2020 Simon Binder |
| uuid | 4.5.3 | MIT | © 2021 Yulian Kuncheff |

Flutter and Dart themselves are BSD-3-Clause, © The Flutter Authors /
the Dart project authors. SQLite itself is in the **public domain**.

## 2. Fonts bundled in the app binary

Full licence texts ship in `assets/licenses/` and are registered with
Flutter's `LicenseRegistry` — see `lib/core/licenses/`.

| Font | Version | Licence | Copyright |
|---|---|---|---|
| KFGQPC HAFS Uthmanic Script | 0.18 | KFGQPC EULA | © 2010 King Fahd Glorious Quran Printing Complex |
| Amiri | 1.002 | SIL OFL 1.1 | © 2010–2022 The Amiri Project Authors |
| Noto Naskh Arabic | 2.021 | SIL OFL 1.1 | © 2022 The Noto Project Authors |
| Inter | 4.001 | SIL OFL 1.1 | © 2016 The Inter Project Authors |

KFGQPC grants "Use, Copy, Distribute" free of cost provided the font is
neither sold nor modified. This app distributes it unmodified.

OFL 1.1 requires the copyright and licence notice to accompany every
copy of the font — which is why those four text files ship as assets
rather than being referenced by URL.

## 3. Qur'anic content

Detailed terms, verbatim quotations and open legal risks:
[`docs/LICENSING.md`](../docs/LICENSING.md).

| Content | Source | Licence | Required notice |
|---|---|---|---|
| Arabic Uthmani text | Tanzil Project | Tanzil Terms | attribution + link to tanzil.net |
| Latin transliteration | Quran.com / QUL | **unverified** | attribution |
| Vietnamese translation | Rowwad Translation Center, via QuranEnc.com | QuranEnc Terms | publisher + QuranEnc.com + version |
| English translation | Saheeh International, via Tanzil | **non-commercial only** | attribution |
| Tafsir Al-Muyassar | Quran.com / QUL | **unverified** | attribution |
| Tafsir Ibn Kathir (abridged) | Quran.com / QUL | **unverified** | attribution |

## 4. Recitation audio (streamed, not bundled)

| Reciters | Host | Licence |
|---|---|---|
| Mishary Rashid Alafasy · Abdul Basit · Mohamed Siddiq El-Minshawi · Mahmoud Khalil Al-Husary · Abdur-Rahman As-Sudais | everyayah.com | **unverified** |

No audio file is distributed with the app; each is fetched from
everyayah.com on demand.

## 5. Notice of open items

Four of the ten content sources above carry **unverified** licences.
That word is used literally: the rights holders publish no terms that
could be located, and no assumption has been substituted for them. See
`docs/LICENSING.md` §4 for the risk ranking and the actions required to
close them.
