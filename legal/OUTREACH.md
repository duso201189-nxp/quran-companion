# Licensing outreach — drafts, not sent

Four enquiries that must go out before any public release. **Nothing
here has been sent.** Sending is the publisher's action; these are
ready to paste, with the `{{…}}` filled in.

Log every reply in `docs/LICENSING.md` §4 with the date and the exact
wording received. A verbal "should be fine" is not a licence.

| # | Recipient | About | Priority | Channel |
|---|---|---|---|---|
| 1 | Darussalam | Ibn Kathir (Abridged) English | **Blocking** | publisher contact / rights dept. |
| 2 | King Fahd Complex (KFGQPC) | Tafsir al-Muyassar Arabic | High | fonts.qurancomplex.gov.sa contact |
| 3 | everyayah.com | 5 recitations | High | https://quran.zendesk.com/hc/en-us |
| 4 | Tarteel / QUL | transliteration provenance | Medium | https://github.com/TarteelAI/quranic-universal-library |

---

## 1 — Darussalam (BLOCKING)

> **Subject:** Permission request — Tafsir Ibn Kathir (Abridged),
> English, in a free non-commercial Qur'an study app
>
> Dear Darussalam Publications,
>
> I am the developer of Qur'an Companion, a free Qur'an reading and
> study application for Android and iOS. It contains no advertising,
> no in-app purchases and no paid tier, and collects no user data.
>
> I am writing to request written permission to include the English
> abridged translation of *Tafsir Ibn Kathir* (abridged under the
> supervision of Shaykh Safiur-Rahman al-Mubarakpuri, ISBN
> 9960-892-71-9, © Maktaba Dar-us-Salam 2003) as an optional
> commentary layer within the application.
>
> Specifically I would like to confirm:
>
> 1. Whether permission can be granted to distribute the text within a
>    free application, offline;
> 2. The exact attribution wording you require;
> 3. Any restriction on the amount of text shown, or any requirement
>    to link to your publications;
> 4. Whether permission would be withdrawn if the application ever
>    introduced a paid tier (it has no plans to).
>
> The application already displays a full sources-and-attribution
> screen naming every text's author, publisher, version and licence.
> I obtained this text from the Quranic Universal Library (QUL), whose
> terms state that per-resource licensing must be confirmed with each
> resource's author — which is why I am writing to you directly.
>
> **If permission cannot be granted, I will remove the text from the
> application.** I would rather ship less commentary than ship it
> without your consent.
>
> With thanks and salaam,
> Du So — qurancompanionhq@gmail.com

**If no reply within {{N}} days: remove the corpus.** Silence is not
permission. Removal is a data-build change plus a `DATA_VERSION` bump;
the app keeps working with Al-Muyassar alone, and the passage-aware
query needs no change.

---

## 2 — King Fahd Glorious Qur'an Printing Complex

> **Subject:** Permission request — Tafsir al-Muyassar text in a free
> Qur'an study application
>
> Assalamu alaikum,
>
> Qur'an Companion is a free, ad-free, offline Qur'an reading and
> study application. It already includes your KFGQPC HAFS Uthmanic
> Script font, unmodified, under the EULA distributed with the font
> file, with the full licence text bundled and shown in-app.
>
> I would like to confirm permission to include the text of
> **التفسير الميسر**, prepared by نخبة من العلماء and published by the
> Complex, as an optional commentary layer.
>
> 1. Is redistribution of the text within a free application
>    permitted?
> 2. What attribution wording does the Complex require?
> 3. Is there a licence document I should reference and bundle, as I
>    do for the font?
>
> Contact: fonts.qurancomplex.gov.sa / {{KFGQPC_CONTACT}}
>
> Jazakum Allahu khayran,
> Du So — qurancompanionhq@gmail.com

---

## 3 — everyayah.com

> **Subject:** Usage terms for recitation audio streamed by a free app
>
> Assalamu alaikum,
>
> Qur'an Companion is a free, ad-free Qur'an application that streams
> recitation audio directly from everyayah.com for five reciters:
> Mishary Rashid Alafasy, Abdul Basit (Murattal), Mohamed Siddiq
> El-Minshawi, Mahmoud Khalil Al-Husary and Abdur-Rahman As-Sudais.
> No audio is bundled; each file is fetched on demand.
>
> I could not find terms of use for the MP3 files themselves — the
> disclaimer in `data/timings_files/000_disclaimer.txt` covers the
> timing files, which this application does not use.
>
> 1. Is streaming these files from a third-party application
>    permitted?
> 2. What attribution do you require, and where?
> 3. Is there a rate limit or a preferred access pattern I should
>    respect?
> 4. Are the recordings themselves licensed to you by the reciters, or
>    should I approach them separately?
>
> Currently the app credits "everyayah.com" with a link, and describes
> the licence as non-commercial — a cautious assumption on my part,
> which I would like to replace with your actual terms.
>
> Du So — qurancompanionhq@gmail.com

Question 4 matters: if everyayah is itself a redistributor, permission
may need to come from the reciters or their publishers.

---

## 4 — Tarteel / QUL

> **Subject:** Provenance of the word-by-word transliteration dataset
>
> Hello,
>
> Thank you for QUL — it is a genuinely useful resource, and the FAQ's
> position on per-resource licensing is clear and honest.
>
> I use the Quran.com word-by-word transliteration in a free Qur'an
> application. Following the FAQ's guidance to confirm licensing with
> each resource's author, I would like to know:
>
> 1. Who holds the rights to that transliteration dataset — is it
>    community-produced under Quran.com/Tarteel, or derived from a
>    third-party work?
> 2. Is there a licence I should cite and bundle?
>
> Du So — qurancompanionhq@gmail.com

Also worth reporting to QUL: the two tafsir datasets carry no
publisher or licence field, which is precisely what the FAQ asks users
to check. Adding one would help every downstream developer.

---

## Attribution corrections — do these regardless of any reply

Independent of permission, the shipped attribution is **wrong** and
should be corrected at the next data build:

| Source | Currently | Should be |
|---|---|---|
| Ibn Kathir (Abridged) | `author = 'Hafiz Ibn Kathir'` | the abridging/translating team and **Darussalam** as publisher; Ibn Kathir credited as the original author |
| Tafsir al-Muyassar | `author = 'المیسر'` (the work's title, misspelled with Persian ی) | `نخبة من العلماء` · publisher `مجمع الملك فهد لطباعة المصحف الشريف` |

Both are one-line changes in `tool/build_quran_db.py` plus a
`DATA_VERSION` bump. Correct attribution is owed to a rights holder
whether or not they have answered.
