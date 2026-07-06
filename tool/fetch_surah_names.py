#!/usr/bin/env python3
"""Tải tên 114 Surah theo chuẩn Quran.com (name_simple).

Sinh tool/data/surah_names.json — nguồn duy nhất của tên Surah
Latin trong app (Al-Fatihah, Al-Baqarah, Ya-Sin, Ar-Rahman,
Al-Waqi'ah...): dạng quen thuộc với cộng đồng, dễ đọc, thống nhất
một chuẩn — không trộn Faatiha/Fatihah hay Yaseen/Ya-Sin.

build_quran_db.py ưu tiên file này thay cho tname của Tanzil.

Cách chạy:
  python tool/fetch_surah_names.py
"""
from __future__ import annotations

import json
import sys
import urllib.request
from datetime import date
from pathlib import Path

for _stream in (sys.stdout, sys.stderr):
    if _stream.encoding and _stream.encoding.lower() not in ("utf-8", "utf8"):
        _stream.reconfigure(encoding="utf-8", errors="replace")

API = "https://api.qurancdn.com/api/qdc/chapters?language=en"
UA = {"User-Agent": "QuranCompanion-DataPipeline/1.0 (+github repo)"}
OUT = Path(__file__).parent / "data" / "surah_names.json"


def main() -> int:
    req = urllib.request.Request(API, headers=UA)
    with urllib.request.urlopen(req, timeout=60) as resp:
        chapters = json.load(resp)["chapters"]
    if len(chapters) != 114:
        raise SystemExit(f"LỖI: nhận {len(chapters)}/114 chương")

    names = {
        str(c["id"]): {
            "latin": c["name_simple"],
            "en": c["translated_name"]["name"],
        }
        for c in chapters
    }
    empty = [k for k, v in names.items() if not v["latin"]]
    if empty:
        raise SystemExit(f"Tên rỗng: {empty}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(
        json.dumps(
            {
                "source": {
                    "name": "Quran.com chapter names (name_simple)",
                    "url": "https://quran.com",
                    "fetched_at": date.today().isoformat(),
                },
                "names": names,
            },
            ensure_ascii=False,
            indent=1,
        ),
        encoding="utf-8",
    )
    print(f"✓ Đã ghi {OUT} (114 tên)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
