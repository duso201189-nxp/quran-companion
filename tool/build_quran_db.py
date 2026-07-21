#!/usr/bin/env python3
"""Pipeline build assets/database/quran.sqlite — Qur'an Companion.

Tải dữ liệu từ nguồn mở, kiểm tra toàn vẹn, build file SQLite
đóng gói vào app. CHẠY LẠI ĐƯỢC bất cứ lúc nào (idempotent):
xóa file cũ, build mới từ đầu.

Nguồn:
  - Arabic Uthmani ...... Tanzil.net (bản verified, giấy phép cho phép
                          phân phối nguyên văn, phải ghi nguồn + link)
  - Transliteration ..... Tanzil.net (en.transliteration)
  - English ............. Sahih International, qua Tanzil.net
  - Vietnamese .......... QuranEnc.com (tự phát hiện key tiếng Việt;
                          ưu tiên bản Hasan Abdul Karim nếu có)

Thêm nguồn mới (tafsir, bản dịch khác...) = viết thêm 1 hàm
import_* trả về (source_meta, {(sura, aya): text}) và đăng ký vào
IMPORTERS — không đổi schema, không sửa code Flutter.

Cách chạy:
  python3 tool/build_quran_db.py                 # build đầy đủ
  python3 tool/build_quran_db.py --vi-key <key>  # chỉ định bản dịch Việt
  python3 tool/build_quran_db.py --list-vi       # liệt kê bản Việt có sẵn
"""
from __future__ import annotations

import argparse
import json
import sqlite3
import sys
import unicodedata
import urllib.request
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from lexicon.sqlite_writer import LEXICON_SCHEMA  # noqa: E402

# Console Windows mặc định cp1252 không in được tiếng Việt —
# ép UTF-8 để script không crash vì UnicodeEncodeError.
for _stream in (sys.stdout, sys.stderr):
    if _stream.encoding and _stream.encoding.lower() not in ("utf-8", "utf8"):
        _stream.reconfigure(encoding="utf-8", errors="replace")

EXPECTED_SURAHS = 114
EXPECTED_AYAHS = 6236
# v2 (Sprint 2.1): phiên âm chuẩn hóa Quran.com word-by-word.
# v3 (Sprint 2.1b): quy tắc biên tập thống nhất — Allah viết hoa,
#   một kiểu dấu (ʾ/ʿ), không nguyên âm dài lặp, không dấu ' thừa.
# v4: tên 114 Surah chuẩn Quran.com (Al-Fatihah, Ya-Sin, Ar-Rahman).
DATA_VERSION = "4"

TANZIL_METADATA_URL = "https://tanzil.net/res/text/metadata/quran-data.xml"
TANZIL_QURAN_URLS = [
    # thử lần lượt tới khi tải + parse thành công
    "https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true",
    "https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt&agree=true",
]


def tanzil_trans_urls(trans_id: str) -> list[str]:
    return [
        f"https://tanzil.net/trans/{trans_id}",
        f"https://tanzil.net/trans/?transID={trans_id}&type=txt-2",
        f"https://tanzil.net/trans/?transID={trans_id}&type=txt",
    ]


QURANENC_LIST_URL = "https://quranenc.com/api/v1/translations/list"
QURANENC_SURA_URL = "https://quranenc.com/api/v1/translation/sura/{key}/{sura}"

UA = {"User-Agent": "QuranCompanion-DataPipeline/1.0 (+github repo)"}


def fetch(url: str, timeout: int = 60) -> bytes:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def fetch_text(url: str) -> str:
    return fetch(url).decode("utf-8")


# ---------------------------------------------------------------
# Parse
# ---------------------------------------------------------------
def load_surah_metadata() -> list[dict]:
    """Tanzil quran-data.xml -> 114 dict {index, ayas, name, tname,
    ename, type, order}."""
    import xml.etree.ElementTree as ET

    root = ET.fromstring(fetch_text(TANZIL_METADATA_URL))
    suras = []
    for s in root.iter("sura"):
        suras.append(
            {
                "index": int(s.get("index")),
                "ayas": int(s.get("ayas")),
                "name": s.get("name"),          # tên Ả Rập
                "tname": s.get("tname"),        # phiên âm Latin
                "ename": s.get("ename"),        # tên tiếng Anh
                "type": s.get("type"),          # Meccan | Medinan
                "order": int(s.get("order")),   # thứ tự mặc khải
            }
        )
    if len(suras) != EXPECTED_SURAHS:
        raise SystemExit(
            f"LỖI metadata: {len(suras)} sura (mong đợi {EXPECTED_SURAHS})"
        )

    def boundaries(tag: str) -> list:
        pts = [
            (int(e.get("sura")), int(e.get("aya")))
            for e in root.iter(tag)
        ]
        pts.sort()
        return pts

    structure = {
        "juz": boundaries("juz"),          # 30 diem bat dau
        "quarter": boundaries("quarter"),  # 240 quarter -> hizb=ceil(q/4)
        "page": boundaries("page"),        # 604 trang Madani
        "sajda": set(boundaries("sajda")),
    }
    if len(structure["juz"]) != 30:
        raise SystemExit("LỖI metadata: thiếu ranh giới juz")
    return suras, structure


def position_value(bounds: list, sura: int, aya: int) -> int:
    # So thu tu vung chua (sura, aya): dem so ranh gioi <= vi tri.
    import bisect
    return bisect.bisect_right(bounds, (sura, aya))


def parse_verse_lines(raw: str, ayah_counts: dict[int, int]) -> dict:
    """Parse file văn bản Tanzil -> {(sura, aya): text}.

    Hỗ trợ 2 định dạng:
      a) 'sura|aya|text' mỗi dòng (txt-2)
      b) mỗi dòng 1 aya theo thứ tự toàn cục (txt) — ánh xạ bằng
         ayah_counts.
    Dòng trống và dòng bắt đầu bằng '#' (footer bản quyền) bị bỏ qua.
    """
    lines = [
        ln.strip()
        for ln in raw.splitlines()
        if ln.strip() and not ln.strip().startswith("#")
    ]
    result: dict[tuple[int, int], str] = {}
    piped = sum(1 for ln in lines[:20] if ln.count("|") >= 2)
    if piped >= 10:  # định dạng a
        for ln in lines:
            sura_s, aya_s, text = ln.split("|", 2)
            result[(int(sura_s), int(aya_s))] = text.strip()
    else:  # định dạng b
        seq = []
        for sura in sorted(ayah_counts):
            for aya in range(1, ayah_counts[sura] + 1):
                seq.append((sura, aya))
        if len(lines) != len(seq):
            raise ValueError(
                f"File tuần tự có {len(lines)} dòng, mong đợi {len(seq)}"
            )
        result = dict(zip(seq, lines))
    return result


def try_sources(urls: list[str], ayah_counts: dict[int, int]) -> dict:
    last_err: Exception | None = None
    for url in urls:
        try:
            verses = parse_verse_lines(fetch_text(url), ayah_counts)
            if len(verses) == EXPECTED_AYAHS:
                print(f"   OK  {url}  ({len(verses)} ayah)")
                return verses
            last_err = ValueError(f"{url}: chỉ parse được {len(verses)} ayah")
        except Exception as e:  # noqa: BLE001 - thử URL kế tiếp
            last_err = e
            print(f"   thử tiếp... ({url}: {e})")
    raise SystemExit(f"LỖI: không tải được từ mọi URL. Lỗi cuối: {last_err}")


# ---------------------------------------------------------------
# QuranEnc (tiếng Việt)
# ---------------------------------------------------------------
def quranenc_vi_keys() -> list[dict]:
    data = json.loads(fetch_text(QURANENC_LIST_URL))
    items = data.get("translations", data if isinstance(data, list) else [])
    return [
        t
        for t in items
        if str(t.get("language_iso_code", t.get("language", ""))).lower()
        in ("vi", "vietnamese")
        or "vietnam" in str(t.get("title", "")).lower()
        or str(t.get("key", "")).startswith("vietnamese")
    ]


def pick_vi_key(keys: list[dict], preferred: str | None) -> dict:
    if not keys:
        raise SystemExit("LỖI: QuranEnc không trả về bản dịch tiếng Việt nào.")
    if preferred:
        for t in keys:
            if t.get("key") == preferred:
                return t
        raise SystemExit(
            f"LỖI: không thấy key '{preferred}'. Chạy --list-vi để xem."
        )
    for want in ("hasan", "rwwad"):
        for t in keys:
            if want in str(t.get("key", "")).lower():
                return t
    return keys[0]


def import_quranenc(key: str) -> dict:
    verses: dict[tuple[int, int], str] = {}
    for sura in range(1, EXPECTED_SURAHS + 1):
        data = json.loads(fetch_text(QURANENC_SURA_URL.format(key=key, sura=sura)))
        for row in data.get("result", []):
            verses[(int(row["sura"]), int(row["aya"]))] = row[
                "translation"
            ].strip()
        print(f"\r   QuranEnc {key}: sura {sura}/114", end="", flush=True)
    print()
    return verses


# ---------------------------------------------------------------
# Phiên âm chuẩn hóa (Sprint 2.1)
# ---------------------------------------------------------------
TRANSLIT_DATASET = Path(__file__).parent / "data" / "transliteration.json"
SURAH_NAMES_DATASET = Path(__file__).parent / "data" / "surah_names.json"


def load_surah_names() -> dict[int, dict] | None:
    """Tên Surah chuẩn Quran.com (tool/data/surah_names.json).

    Một chuẩn duy nhất, quen thuộc toàn cầu: Al-Fatihah, Al-Baqarah,
    Ya-Sin, Ar-Rahman, Al-Waqi'ah... None nếu file chưa có
    (fallback tname Tanzil).
    """
    if not SURAH_NAMES_DATASET.exists():
        return None
    data = json.loads(SURAH_NAMES_DATASET.read_text(encoding="utf-8"))
    names = {int(k): v for k, v in data["names"].items()}
    if len(names) != 114:
        raise SystemExit(f"LỖI: dataset tên Surah có {len(names)}/114")
    return names


def load_local_transliteration() -> tuple[dict, dict] | None:
    """Đọc bộ phiên âm chuẩn (tool/data/transliteration.json).

    Đây là NGUỒN ƯU TIÊN — một chuẩn thống nhất (Quran.com wbw),
    thay dataset chỉ cần thay file này rồi build lại. Trả về
    (meta, {(sura, aya): text}) hoặc None nếu file chưa có.
    """
    if not TRANSLIT_DATASET.exists():
        return None
    data = json.loads(TRANSLIT_DATASET.read_text(encoding="utf-8"))
    verses: dict[tuple[int, int], str] = {}
    for key, text in data["ayahs"].items():
        sura, aya = key.split(":")
        verses[(int(sura), int(aya))] = text.strip()
    if len(verses) != EXPECTED_AYAHS:
        raise SystemExit(
            f"LỖI: dataset phiên âm có {len(verses)}/{EXPECTED_AYAHS} ayah"
        )
    return data.get("source", {}), verses


# ---------------------------------------------------------------
# Chuẩn hóa cho tìm kiếm
# ---------------------------------------------------------------
def fold_latin(text: str) -> str:
    # Bo dau Latin: 'long' <- 'lòng', 'rahim' <- 'raḥīm', 'd' <- 'đ'.
    # Nguoi dung go khong dau van tim duoc (tieng Viet + transliteration).
    text = text.replace("đ", "d").replace("Đ", "D")
    # Ky hieu hong-thanh-quan cua phien am (bis'mi, samīʿun...):
    # bo khi fold de nguoi dung go 'bismi'/'samiun' van khop.
    for mark in ("'", "ʼ", "ʾ", "ʿ", "‘", "’"):
        text = text.replace(mark, "")
    nfd = unicodedata.normalize("NFD", text)
    return unicodedata.normalize(
        "NFC",
        "".join(c for c in nfd if unicodedata.category(c) != "Mn"),
    ).lower()


def strip_tashkeel(text: str) -> str:
    """Bỏ dấu thanh (harakat) Ả Rập để tìm kiếm không dấu."""
    nfd = unicodedata.normalize("NFD", text)
    stripped = "".join(c for c in nfd if unicodedata.category(c) != "Mn")
    return unicodedata.normalize("NFC", stripped)


# ---------------------------------------------------------------
# Schema — PHẢI khớp lib/core/database/tables/content_tables.dart
# ---------------------------------------------------------------
SCHEMA = """
CREATE TABLE surahs (
  id INTEGER NOT NULL PRIMARY KEY,
  name_arabic TEXT NOT NULL, name_latin TEXT NOT NULL,
  name_vi TEXT NOT NULL, name_en TEXT NOT NULL,
  ayah_count INTEGER NOT NULL,
  revelation_place TEXT NOT NULL,
  order_revealed INTEGER NOT NULL
);
CREATE TABLE ayahs (
  id INTEGER NOT NULL PRIMARY KEY,
  surah_id INTEGER NOT NULL REFERENCES surahs (id),
  ayah_number INTEGER NOT NULL,
  text_uthmani TEXT NOT NULL,
  juz INTEGER, hizb INTEGER, page INTEGER,
  sajdah INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE translation_sources (
  id INTEGER NOT NULL PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL, language TEXT NOT NULL, author TEXT,
  type TEXT NOT NULL,
  is_enabled INTEGER NOT NULL DEFAULT 1,
  display_order INTEGER NOT NULL DEFAULT 0,
  license TEXT, source_url TEXT, version TEXT, updated_at TEXT
);
CREATE TABLE translations (
  source_id INTEGER NOT NULL REFERENCES translation_sources (id),
  ayah_id INTEGER NOT NULL REFERENCES ayahs (id),
  text TEXT NOT NULL,
  PRIMARY KEY (source_id, ayah_id)
);
CREATE TABLE reciters (
  id INTEGER NOT NULL PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL, name_arabic TEXT,
  audio_url_template TEXT NOT NULL,
  bitrate_kbps INTEGER, license TEXT, source_url TEXT,
  is_enabled INTEGER NOT NULL DEFAULT 1,
  display_order INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE meta (
  key TEXT NOT NULL PRIMARY KEY,
  value TEXT NOT NULL
);
-- Index cho MOI truc truy van doc Qur'an (muc tieu < 50ms):
CREATE INDEX idx_ayahs_surah ON ayahs (surah_id, ayah_number);
CREATE INDEX idx_ayahs_juz ON ayahs (juz);
CREATE INDEX idx_ayahs_hizb ON ayahs (hizb);
CREATE INDEX idx_ayahs_page ON ayahs (page);
CREATE INDEX idx_ayahs_sajdah ON ayahs (sajdah) WHERE sajdah = 1;
CREATE INDEX idx_translations_ayah ON translations (ayah_id);
CREATE INDEX idx_translations_source ON translations (source_id);
CREATE INDEX idx_sources_enabled
  ON translation_sources (is_enabled, display_order);
CREATE INDEX idx_reciters_enabled ON reciters (is_enabled, display_order);
CREATE VIRTUAL TABLE search_index USING fts5(
  ayah_id UNINDEXED, source_code UNINDEXED, content
);
"""

# Lexicon (Sprint 12 — Phase 2.7/3). Schema khai báo TRƯỚC dữ liệu
# thật, cùng tình trạng lemmas/word_instances từ Sprint 9 (xem
# DATABASE.md, lib/core/database/tables/content_tables.dart). CHƯA có
# bước insert dữ liệu thật nối vào build này — nguồn hình thái học
# (QAC) vướng mâu thuẫn giấy phép CHƯA giải quyết (xem
# tool/fetch_morphology.py, Return Sprint 12 Phase 3). Build này chỉ
# tạo 8 bảng RỖNG, khớp 100% lib/core/database/tables/content_tables.dart
# và tool/lexicon/sqlite_writer.py — không phải quyết định thiết kế
# mới, chỉ mirror schema đã đóng băng.
SCHEMA += LEXICON_SCHEMA

RECITERS_SEED = [
    # (code, name, name_arabic, url_template, bitrate, license, source_url)
    # everyayah.com — {sss}=surah 3 chữ số, {aaa}=ayah 3 chữ số
    (
        "alafasy", "Mishary Rashid Alafasy", "مشاري راشد العفاسي",
        "https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3",
        128, "Phi thương mại — everyayah.com", "https://everyayah.com",
    ),
    (
        "abdul_basit", "Abdul Basit (Murattal)", "عبد الباسط عبد الصمد",
        "https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/{sss}{aaa}.mp3",
        192, "Phi thương mại — everyayah.com", "https://everyayah.com",
    ),
    (
        "minshawi", "Mohamed Siddiq El-Minshawi", "محمد صديق المنشاوي",
        "https://everyayah.com/data/Minshawy_Murattal_128kbps/{sss}{aaa}.mp3",
        128, "Phi thương mại — everyayah.com", "https://everyayah.com",
    ),
    (
        "husary", "Mahmoud Khalil Al-Husary", "محمود خليل الحصري",
        "https://everyayah.com/data/Husary_128kbps/{sss}{aaa}.mp3",
        128, "Phi thương mại — everyayah.com", "https://everyayah.com",
    ),
    (
        "sudais", "Abdur-Rahman As-Sudais", "عبدالرحمن السديس",
        "https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/{sss}{aaa}.mp3",
        192, "Phi thương mại — everyayah.com", "https://everyayah.com",
    ),
]



# ---------------------------------------------------------------
# Kiểm tra toàn vẹn TRƯỚC khi ghi file cuối
# ---------------------------------------------------------------
def validate(conn: sqlite3.Connection, source_codes: list[str]) -> None:
    cur = conn.cursor()
    errors: list[str] = []

    n = cur.execute("SELECT COUNT(*) FROM surahs").fetchone()[0]
    if n != EXPECTED_SURAHS:
        errors.append(f"surahs = {n}, mong đợi {EXPECTED_SURAHS}")

    n = cur.execute("SELECT COUNT(*) FROM ayahs").fetchone()[0]
    if n != EXPECTED_AYAHS:
        errors.append(f"ayahs = {n}, mong đợi {EXPECTED_AYAHS}")

    n = cur.execute("SELECT SUM(ayah_count) FROM surahs").fetchone()[0]
    if n != EXPECTED_AYAHS:
        errors.append(f"SUM(ayah_count) = {n}, mong đợi {EXPECTED_AYAHS}")

    # từng Surah: số ayah thực = ayah_count khai báo, đánh số liên tục 1..n
    bad = cur.execute(
        """SELECT s.id FROM surahs s
           WHERE (SELECT COUNT(*) FROM ayahs a WHERE a.surah_id = s.id)
                 != s.ayah_count
              OR (SELECT MAX(a.ayah_number) FROM ayahs a
                  WHERE a.surah_id = s.id) != s.ayah_count
              OR (SELECT MIN(a.ayah_number) FROM ayahs a
                  WHERE a.surah_id = s.id) != 1"""
    ).fetchall()
    if bad:
        errors.append(f"Surah sai số/đánh số Ayah: {[b[0] for b in bad]}")

    # mỗi nguồn phủ đủ 6236 ayah, không có text rỗng
    for code in source_codes:
        n = cur.execute(
            """SELECT COUNT(*) FROM translations t
               JOIN translation_sources s ON s.id = t.source_id
               WHERE s.code = ?""",
            (code,),
        ).fetchone()[0]
        if n != EXPECTED_AYAHS:
            errors.append(f"nguồn '{code}' có {n}/{EXPECTED_AYAHS} ayah")
        n = cur.execute(
            """SELECT COUNT(*) FROM translations t
               JOIN translation_sources s ON s.id = t.source_id
               WHERE s.code = ? AND TRIM(t.text) = ''""",
            (code,),
        ).fetchone()[0]
        if n:
            errors.append(f"nguồn '{code}' có {n} ayah rỗng")

    n = cur.execute(
        "SELECT COUNT(*) FROM ayahs WHERE TRIM(text_uthmani) = ''"
    ).fetchone()[0]
    if n:
        errors.append(f"{n} ayah Arabic rỗng")

    n = cur.execute(
        "SELECT COUNT(*) FROM ayahs WHERE juz IS NULL OR juz < 1 "
        "OR juz > 30"
    ).fetchone()[0]
    if n:
        errors.append(f"{n} ayah có juz không hợp lệ")
    n = cur.execute("SELECT COUNT(DISTINCT page) FROM ayahs").fetchone()[0]
    if n < 600:
        errors.append(f"chỉ có {n} trang (mong đợi ~604)")

    fk = cur.execute("PRAGMA foreign_key_check").fetchall()
    if fk:
        errors.append(f"vi phạm foreign key: {fk[:5]}...")

    if errors:
        print("\n== KIỂM TRA TOÀN VẸN THẤT BẠI ==")
        for e in errors:
            print(" ✗", e)
        raise SystemExit(1)
    print("== Kiểm tra toàn vẹn: PASS ==")


# ---------------------------------------------------------------
# Build
# ---------------------------------------------------------------
def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", default="assets/database/quran.sqlite")
    ap.add_argument("--vi-key", default=None,
                    help="key bản dịch tiếng Việt trên QuranEnc")
    ap.add_argument("--list-vi", action="store_true",
                    help="liệt kê bản dịch tiếng Việt rồi thoát")
    args = ap.parse_args()

    if args.list_vi:
        for t in quranenc_vi_keys():
            print(f"  {t.get('key')}: {t.get('title')}")
        return

    print("1/6 Tải metadata Surah + cấu trúc juz/hizb/trang (Tanzil)...")
    suras, structure = load_surah_metadata()
    ayah_counts = {s["index"]: s["ayas"] for s in suras}

    print("2/6 Tải văn bản Arabic Uthmani (Tanzil)...")
    arabic = try_sources(TANZIL_QURAN_URLS, ayah_counts)

    local_translit = load_local_transliteration()
    if local_translit is not None:
        translit_meta, translit = local_translit
        print(
            "3/6 Phiên âm: dùng dataset chuẩn "
            f"({translit_meta.get('standard', 'local')} — "
            f"{TRANSLIT_DATASET.name})"
        )
    else:
        print(
            "3/6 Tải Transliteration (Tanzil)... "
            "[KHUYẾN NGHỊ: chạy tool/fetch_transliteration.py "
            "để dùng chuẩn Quran.com]"
        )
        translit_meta = None
        translit = try_sources(
            tanzil_trans_urls("en.transliteration"), ayah_counts
        )

    print("4/6 Tải bản dịch English — Sahih International (Tanzil)...")
    english = try_sources(tanzil_trans_urls("en.sahih"), ayah_counts)

    print("5/6 Tải bản dịch tiếng Việt (QuranEnc)...")
    vi_meta = pick_vi_key(quranenc_vi_keys(), args.vi_key)
    vi_key = vi_meta["key"]
    print(f"   dùng bản: {vi_key} — {vi_meta.get('title', '')}")
    vietnamese = import_quranenc(vi_key)
    if len(vietnamese) != EXPECTED_AYAHS:
        raise SystemExit(
            f"LỖI: bản Việt '{vi_key}' có {len(vietnamese)} ayah"
        )

    today = date.today().isoformat()
    # (id, code, name, lang, author, type, order, license, url, version)
    if translit_meta is not None:
        translit_source = (
            1, "translit_latin", "Phiên âm Latin (Quran.com)", "en",
            str(translit_meta.get("name", "Quran.com word-by-word")),
            "transliteration", 1,
            str(translit_meta.get("license", "ghi nguồn Quran.com")),
            str(translit_meta.get("url", "https://quran.com")),
            str(translit_meta.get("fetched_at") or ""),
        )
    else:
        translit_source = (
            1, "translit_latin", "Phiên âm Latin", "en",
            "Tanzil Project", "transliteration", 1,
            "Tanzil Terms of Use — phi thương mại, ghi nguồn + link",
            "https://tanzil.net/trans/", None,
        )
    sources = [
        translit_source,
        (2, "vi_main", str(vi_meta.get("title", "Bản dịch tiếng Việt")),
         "vi", str(vi_meta.get("translator") or vi_meta.get("title", "")),
         "translation", 2,
         "QuranEnc — sử dụng với ghi nguồn, xem quranenc.com",
         f"https://quranenc.com/en/browse/{vi_key}",
         str(vi_meta.get("version") or "")),
        (3, "en_sahih", "Saheeh International", "en",
         "Saheeh International", "translation", 3,
         "Tanzil Terms of Use — phi thương mại, ghi nguồn + link",
         "https://tanzil.net/trans/", None),
    ]
    texts_by_source = {1: translit, 2: vietnamese, 3: english}

    print("6/6 Build SQLite...")
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    if out.exists():
        out.unlink()  # idempotent: build lại từ đầu
    conn = sqlite3.connect(out)
    conn.executescript(SCHEMA)

    surah_names = load_surah_names()
    if surah_names is not None:
        print("   tên Surah: chuẩn Quran.com (surah_names.json)")

    def latin_name(s: dict) -> str:
        if surah_names is not None:
            return surah_names[int(s["index"])]["latin"]
        return s["tname"]

    def en_name(s: dict) -> str:
        if surah_names is not None:
            return surah_names[int(s["index"])]["en"]
        return s["ename"]

    conn.executemany(
        "INSERT INTO surahs VALUES (?,?,?,?,?,?,?,?)",
        [
            (
                s["index"], s["name"], latin_name(s),
                # name_vi: tạm dùng tên Latin — thay bằng tên Việt chuẩn
                # qua bản data sau, KHÔNG cần sửa code (xem DATA_PIPELINE.md)
                latin_name(s), en_name(s), s["ayas"],
                "madinah" if s["type"] == "Medinan" else "mecca",
                s["order"],
            )
            for s in suras
        ],
    )

    ayah_id = 0
    id_of: dict[tuple[int, int], int] = {}
    rows = []
    for s in suras:
        for aya in range(1, s["ayas"] + 1):
            ayah_id += 1
            pos = (s["index"], aya)
            id_of[pos] = ayah_id
            quarter = position_value(structure["quarter"], *pos)
            rows.append(
                (
                    ayah_id, s["index"], aya, arabic[pos],
                    position_value(structure["juz"], *pos),
                    (quarter + 3) // 4 if quarter else None,  # hizb
                    position_value(structure["page"], *pos),
                    1 if pos in structure["sajda"] else 0,
                )
            )
    conn.executemany(
        "INSERT INTO ayahs (id, surah_id, ayah_number, text_uthmani, "
        "juz, hizb, page, sajdah) VALUES (?,?,?,?,?,?,?,?)",
        rows,
    )

    conn.executemany(
        "INSERT INTO translation_sources "
        "(id, code, name, language, author, type, display_order, "
        " license, source_url, version, updated_at) "
        "VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        [(*s, today) for s in sources],
    )
    for sid, verses in texts_by_source.items():
        conn.executemany(
            "INSERT INTO translations VALUES (?,?,?)",
            [(sid, id_of[k], v) for k, v in verses.items()],
        )

    conn.executemany(
        "INSERT INTO reciters (id, code, name, name_arabic, "
        "audio_url_template, bitrate_kbps, license, source_url, "
        "is_enabled, display_order) VALUES (?,?,?,?,?,?,?,?,1,?)",
        [
            (i + 1, *r[:4], r[4], r[5], r[6], i + 1)
            for i, r in enumerate(RECITERS_SEED)
        ],
    )

    # FTS: Arabic (nguyên bản + bỏ dấu) và mọi bản dịch
    fts_rows = []
    for (sura, aya), text in arabic.items():
        aid = id_of[(sura, aya)]
        fts_rows.append((aid, "arabic", text))
        fts_rows.append((aid, "arabic_plain", strip_tashkeel(text)))
    for sid, verses in texts_by_source.items():
        code = sources[sid - 1][1]
        folded = code in ("vi_main", "translit_latin")
        for k, v in verses.items():
            fts_rows.append((id_of[k], code, v))
            if folded:
                fts_rows.append((id_of[k], code + "_plain", fold_latin(v)))
    conn.executemany(
        "INSERT INTO search_index (ayah_id, source_code, content) "
        "VALUES (?,?,?)",
        fts_rows,
    )

    meta = {
        "data_version": DATA_VERSION,
        "built_at": today,
        "generator": "tool/build_quran_db.py",
        "arabic_source": "Tanzil.net Uthmani (verified text)",
        "arabic_license": "Tanzil Terms — phân phối nguyên văn, "
                          "ghi nguồn + link tanzil.net",
        "vi_translation_key": vi_key,
    }
    conn.executemany("INSERT INTO meta VALUES (?,?)", meta.items())

    conn.commit()
    validate(conn, [s[1] for s in sources])
    conn.execute("VACUUM")
    conn.close()

    size_mb = out.stat().st_size / 1024 / 1024
    print(f"\n✓ Đã tạo {out} ({size_mb:.1f} MB) — data_version {DATA_VERSION}")
    print("  Nhớ: app phải hiển thị attribution Tanzil + QuranEnc "
          "(màn hình Giới thiệu — TODO.md).")


if __name__ == "__main__":
    sys.exit(main())
