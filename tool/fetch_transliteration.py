#!/usr/bin/env python3
"""Tải bộ phiên âm chuẩn Quran.com (word-by-word) và ghép theo Ayah.

Sinh ra tool/data/transliteration.json — NGUỒN DUY NHẤT của phiên âm
trong app. build_quran_db.py sẽ ưu tiên file này thay cho Tanzil.

Cập nhật phiên âm sau này = chạy lại script này (hoặc thay file JSON
bằng dataset khác cùng cấu trúc) rồi build lại database.

Chuẩn phiên âm: Quran.com word-by-word transliteration — một chuẩn
thống nhất toàn bộ Qur'an, mỗi từ Ả Rập luôn có đúng một phiên âm.

Cách chạy:
  python tool/fetch_transliteration.py
"""
from __future__ import annotations

import json
import re
import sys
import time
import urllib.request
from datetime import date
from pathlib import Path

for _stream in (sys.stdout, sys.stderr):
    if _stream.encoding and _stream.encoding.lower() not in ("utf-8", "utf8"):
        _stream.reconfigure(encoding="utf-8", errors="replace")

API = (
    "https://api.qurancdn.com/api/qdc/verses/by_chapter/{chapter}"
    "?words=true&word_fields=transliteration,text_uthmani"
    "&per_page=50&page={page}"
)
UA = {"User-Agent": "QuranCompanion-DataPipeline/1.0 (+github repo)"}
EXPECTED_AYAHS = 6236
OUT = Path(__file__).parent / "data" / "transliteration.json"
OUT_WORDS = Path(__file__).parent / "data" / "transliteration_words.json"


def fetch(url: str) -> dict:
    last_error: Exception | None = None
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=60) as resp:
                return json.load(resp)
        except Exception as e:  # noqa: BLE001 - retry mạng
            last_error = e
            time.sleep(1.5 * (attempt + 1))
    raise SystemExit(f"Tải thất bại sau 4 lần: {url}\n{last_error}")


# ---------------------------------------------------------------
# Quy tắc biên tập thống nhất (Sprint 2.1b) — "một biên tập viên":
# 1. Danh xưng Allah viết hoa, macron đầy đủ (ánh xạ TỪ CHÍNH XÁC —
#    không đụng l-lahabi 'ngọn lửa' 111:3 hay l-lahwi 'trò tiêu khiển').
# 2. MỘT kiểu dấu: ʾ = hamza, ʿ = ʿayn. Dấu ' ASCII của nguồn:
#    sau NGUYÊN ÂM = hamza -> ʾ; sau PHỤ ÂM = vạch ngăn âm tiết
#    thừa -> bỏ. (Đã kiểm chứng 0 ngoại lệ trên 77.429 từ.)
# 3. Không nguyên âm dài lặp (āa/aā/īi/ūu...): các cặp này luôn là
#    vị trí hamza trong chữ Ả Rập (0 ngoại lệ) -> chèn ʾ: jāa->jāʾa.
# ---------------------------------------------------------------
ALLAH_MAP = {
    "l-lahi": "Allāhi", "l-lahu": "Allāhu", "l-laha": "Allāha",
    "al-lahi": "Allāhi", "al-lahu": "Allāhu", "al-laha": "Allāha",
    "wal-lahi": "wallāhi", "wal-lahu": "wallāhu",
    "bil-lahi": "billāhi", "abil-lahi": "abillāhi",
    "tal-lahi": "tallāhi", "watal-lahi": "watallāhi",
    "fal-lahu": "fallāhu",
    "lillahi": "lillāhi",
    "l-lahuma": "Allāhumma",
}

_VOWELS = set("aiueoāīū")
_JUNCTURES = [
    ("āa", "āʾa"), ("aā", "aʾā"), ("aa", "aʾa"),
    ("īi", "īʾi"), ("iī", "iʾī"), ("ii", "iʾi"),
    ("ūu", "ūʾu"), ("uū", "uʾū"), ("uu", "uʾu"),
]


def standardize_token(tr: str) -> str:
    mapped = ALLAH_MAP.get(tr)
    if mapped is not None:
        return mapped
    # Dấu ' ASCII: hamza sau nguyên âm, bỏ sau phụ âm.
    out = []
    for i, ch in enumerate(tr):
        if ch == "'":
            if i > 0 and tr[i - 1] in _VOWELS:
                out.append("ʾ")
            # sau phụ âm: bỏ hẳn
        else:
            out.append(ch)
    s = "".join(out)
    # Cặp nguyên âm cùng họ = hamza ẩn.
    for pat, rep in _JUNCTURES:
        s = s.replace(pat, rep)
    return s


def _base(form: str) -> str:
    """Dạng gốc bỏ tiền tố mạo từ al-/l- (biến âm theo ngữ cảnh)."""
    if form.startswith("al-"):
        return form[3:]
    if form.startswith("l-"):
        return form[2:]
    return form


def normalize_words(
    verses: dict[str, list[tuple[str, str]]],
) -> tuple[dict[str, list[tuple[str, str]]], list[tuple[str, str, str]]]:
    """Chuẩn hóa theo đa số: mỗi từ Ả Rập -> đúng MỘT phiên âm.

    Biến âm mạo từ al-/l- theo vị trí là quy ước của chính Quran.com
    -> giữ nguyên. Chỉ khi DẠNG GỐC lệch dạng đa số (lỗi chính tả
    upstream, vd 'alimun' thay vì 'ʿalīmun') mới thay bằng dạng đa số.
    Trả về (verses đã sửa, danh sách sửa đổi để báo cáo).
    """
    from collections import Counter, defaultdict

    by_arabic: dict[str, Counter] = defaultdict(Counter)
    for pairs in verses.values():
        for ar, tr in pairs:
            by_arabic[ar][tr] += 1

    dominant = {ar: c.most_common(1)[0][0] for ar, c in by_arabic.items()}
    fixes: list[tuple[str, str, str]] = []
    fixed: dict[str, list[tuple[str, str]]] = {}
    for key, pairs in verses.items():
        out = []
        for ar, tr in pairs:
            dom = dominant[ar]
            if tr != dom and _base(tr) != _base(dom):
                fixes.append((key, tr, dom))
                tr = dom
            out.append((ar, tr))
        fixed[key] = out
    return fixed, fixes


def main() -> int:
    # (arabic, translit) theo từng ayah — giữ cấu trúc để chuẩn hóa.
    verses: dict[str, list[tuple[str, str]]] = {}

    for chapter in range(1, 115):
        page = 1
        while True:
            data = fetch(API.format(chapter=chapter, page=page))
            for verse in data["verses"]:
                pairs = []
                for w in verse["words"]:
                    if w.get("char_type_name") != "word":
                        continue  # bỏ ký hiệu kết Ayah
                    text = ((w.get("transliteration") or {}).get("text")
                            or "").strip()
                    if text:
                        pairs.append((w.get("text_uthmani") or "", text))
                verses[verse["verse_key"]] = pairs
            nxt = data["pagination"]["next_page"]
            if not nxt:
                break
            page = nxt
        print(f"\r  chương {chapter}/114 — {len(verses)} ayah", end="")
    print()

    verses, fixes = normalize_words(verses)
    for key, wrong, right in fixes:
        print(f"  sửa {key}: '{wrong}' -> '{right}'")

    # Áp quy tắc biên tập thống nhất cho từng từ.
    changed = 0
    for key, pairs in verses.items():
        new_pairs = []
        for ar, tr in pairs:
            s = standardize_token(tr)
            if s != tr:
                changed += 1
            new_pairs.append((ar, s))
        verses[key] = new_pairs
    print(f"  chuẩn hóa biên tập: {changed} từ được điều chỉnh")

    ayahs = {
        key: re.sub(r"\s+", " ", " ".join(tr for _, tr in pairs)).strip()
        for key, pairs in verses.items()
    }
    words = [pair for pairs in verses.values() for pair in pairs]

    if len(ayahs) != EXPECTED_AYAHS:
        raise SystemExit(
            f"Thiếu dữ liệu: {len(ayahs)}/{EXPECTED_AYAHS} ayah"
        )
    empty = [k for k, v in ayahs.items() if not v]
    if empty:
        raise SystemExit(f"Ayah rỗng: {empty[:10]}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps(
            {
                "source": {
                    "name": "Quran.com word-by-word transliteration",
                    "url": "https://quran.com",
                    "license": "Quran.com/QUL community data — "
                               "ghi nguồn khi phân phối",
                    "fetched_at": date.today().isoformat(),
                    "standard": "quran.com-wbw",
                },
                "ayahs": ayahs,
            },
            ensure_ascii=False,
            indent=1,
        ),
        encoding="utf-8",
    )
    # Cặp (từ Ả Rập, phiên âm) — đầu vào cho audit nhất quán
    # (mỗi từ Ả Rập phải luôn có đúng MỘT phiên âm).
    OUT_WORDS.write_text(
        json.dumps(words, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"✓ Đã ghi {OUT} ({len(ayahs)} ayah, "
          f"{len(words)} từ) + {OUT_WORDS.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
