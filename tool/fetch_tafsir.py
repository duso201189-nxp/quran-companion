#!/usr/bin/env python3
"""Tải MỘT bộ Tafsir từ Quran.com (QUL) và ghép theo Ayah.

Sinh ra tool/data/tafsir_<slug>.json — build_quran_db.py đọc file này
và nạp vào bảng `translations` với `translation_sources.type='tafsir'`.

CÙNG KHUÔN với tool/fetch_transliteration.py: script tải riêng, ghi
dataset JSON vào tool/data/, builder chỉ đọc file. Nhờ vậy build lại
database KHÔNG cần mạng, và đổi bộ Tafsir = chạy lại script này.

Mặc định: Tafsir Al-Muyassar (Ả Rập, id=16). Chọn bộ này vì:
  - Tiếng Ả Rập -> kiểm chứng đường RTL đầu-cuối, thứ mà Sprint 30.1
    và 31.2 khẳng định nhưng chưa từng chạy trên dữ liệu thật.
  - "Muyassar" = bản giản lược: chú giải NGẮN theo TỪNG Ayah, đúng
    giả định per-ayah của `DR-2026-0006` D2 — nếu giả định sai thì
    phải thấy ngay ở đây.
  - Nguồn Quran.com/QUL đã được dự án dùng cho phiên âm (xem
    fetch_transliteration.py), nên xuất xứ không phải tiền lệ mới.

Cách chạy:
  python tool/fetch_tafsir.py
  python tool/fetch_tafsir.py --tafsir-id 169 --slug en-tafisr-ibn-kathir
"""
from __future__ import annotations

import argparse
import html
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

LIST_API = "https://api.quran.com/api/v4/resources/tafsirs"
# per_page BẮT BUỘC: endpoint mặc định trả 10 mục/trang. Bỏ qua
# tham số này thì mỗi chương chỉ về 10 Ayah và tổng cộng ra ~1.013/6.236
# — trông y hệt "bộ Tafsir chỉ chú giải một phần", một kết luận SAI về
# dữ liệu. Surah dài nhất (Al-Baqarah) có 286 Ayah nên 300 đủ một trang,
# và `pagination.total_records` được kiểm lại bên dưới.
CHAPTER_API = (
    "https://api.qurancdn.com/api/qdc/tafsirs/{tid}/by_chapter/{n}"
    "?per_page=300"
)
UA = {"User-Agent": "QuranCompanion-DataPipeline/1.0 (+github repo)"}
EXPECTED_AYAHS = 6236
DATA_DIR = Path(__file__).parent / "data"

# Thẻ đánh dấu của nguồn: <span class="green">…</span>, <h2>, <br/>…
# Văn bản trong database phải là VĂN BẢN THUẦN — tầng hiển thị của app
# dùng `Text`, không phải trình dựng HTML. Chuẩn hoá ở pipeline (một
# lần, lúc build) thay vì lúc chạy, cùng tinh thần với phiên âm.
_TAG = re.compile(r"<[^>]+>")
_WS = re.compile(r"[ \t ]+")


def strip_markup(raw: str) -> str:
    """Bỏ thẻ HTML, giữ nguyên nội dung chữ và cấu trúc đoạn."""
    if not raw:
        return ""
    text = raw.replace("\r\n", "\n")
    # <br>, </p>, </div>, </h*> -> xuống dòng, để đoạn văn không dính nhau.
    text = re.sub(r"(?i)<br\s*/?>", "\n", text)
    text = re.sub(r"(?i)</(p|div|h[1-6]|li)\s*>", "\n", text)
    text = _TAG.sub("", text)
    # Sprint 31.4 — KHÔNG lọc dấu `<`/`>` còn lại sau khi bỏ thẻ.
    # Đã nghi ngờ là "thẻ hỏng" và suýt xoá: hoá ra nguồn ghi `&lt;`
    # (đã escape đúng chuẩn) ở Ibn Kathir 3:190, tức là NỘI DUNG THẬT,
    # và `html.unescape` bên dưới khôi phục nó đúng. Xoá đi là làm hỏng
    # văn bản. Cảnh báo cho lần sau: `LIKE '%<%'` trong kiểm tra dữ
    # liệu KHÔNG đồng nghĩa với "còn sót markup".
    text = html.unescape(text)
    text = _WS.sub(" ", text)
    # Gom tối đa 2 dòng trống liên tiếp; bỏ khoảng trắng đầu/cuối dòng.
    lines = [ln.strip() for ln in text.split("\n")]
    out: list[str] = []
    blank = 0
    for ln in lines:
        if ln:
            blank = 0
            out.append(ln)
        else:
            blank += 1
            if blank <= 1 and out:
                out.append("")
    return "\n".join(out).strip()


def fetch_json(url: str) -> dict:
    last: Exception | None = None
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=60) as resp:
                return json.load(resp)
        except Exception as e:  # noqa: BLE001 - retry mạng
            last = e
            time.sleep(1.5 * (attempt + 1))
    raise SystemExit(f"Tải thất bại sau 4 lần: {url}\n{last}")


def resource_meta(tafsir_id: int) -> dict:
    for t in fetch_json(LIST_API).get("tafsirs", []):
        if int(t.get("id", -1)) == tafsir_id:
            return t
    raise SystemExit(f"Không tìm thấy tafsir id={tafsir_id} trong danh mục")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tafsir-id", type=int, default=16)
    ap.add_argument("--slug", default=None)
    args = ap.parse_args()

    meta = resource_meta(args.tafsir_id)
    slug = args.slug or meta.get("slug") or f"tafsir-{args.tafsir_id}"
    print(f"Tafsir: id={args.tafsir_id} slug={slug} "
          f"name={meta.get('name')!r} lang={meta.get('language_name')!r}")

    by_key: dict[str, str] = {}
    empty_keys: list[str] = []
    gaps: dict[int, int] = {}
    t0 = time.time()
    for chapter in range(1, 115):
        data = fetch_json(CHAPTER_API.format(tid=args.tafsir_id, n=chapter))
        items = data.get("tafsirs", [])
        # Phân biệt HAI việc khác nhau:
        #   next_page != None  -> TA lấy thiếu (lỗi pipeline) -> dừng.
        #   items < total_records -> NGUỒN thiếu chú giải cho vài Ayah
        #                            (sự thật về dữ liệu) -> ghi nhận.
        pag = data.get("pagination") or {}
        if pag.get("next_page") is not None:
            raise SystemExit(
                f"Chương {chapter}: còn trang {pag.get('next_page')} chưa "
                "lấy — dừng để không sinh dataset thiếu"
            )
        total = pag.get("total_records")
        if total is not None and len(items) < total:
            gaps[chapter] = total - len(items)
        for it in items:
            key = it.get("verse_key")
            text = strip_markup(it.get("text") or "")
            if not key:
                continue
            if not text:
                empty_keys.append(key)
                continue
            by_key[key] = text
        if chapter % 20 == 0 or chapter == 114:
            print(f"  chương {chapter}/114 — {len(by_key)} ayah")
    elapsed = time.time() - t0

    lengths = [len(v) for v in by_key.values()]
    total_chars = sum(lengths)
    report = {
        "ayahs_with_text": len(by_key),
        "expected_ayahs": EXPECTED_AYAHS,
        "missing": EXPECTED_AYAHS - len(by_key),
        "empty_from_source": len(empty_keys),
        "chars_total": total_chars,
        "chars_min": min(lengths) if lengths else 0,
        "chars_max": max(lengths) if lengths else 0,
        "chars_avg": (total_chars // len(lengths)) if lengths else 0,
        "download_seconds": round(elapsed, 1),
        "chapters_with_gaps": len(gaps),
        "gap_ayahs_total": sum(gaps.values()),
    }

    out = {
        "meta": {
            "tafsir_id": args.tafsir_id,
            "slug": slug,
            "name": meta.get("name"),
            "author": meta.get("author_name"),
            "language": meta.get("language_name"),
            "source_url": f"https://quran.com/tafsirs/{slug}",
            "license": "Quran.com/QUL community data — ghi nguồn khi "
                       "phân phối; kiểm tra điều khoản trước khi "
                       "phát hành thương mại",
            "fetched_at": date.today().isoformat(),
        },
        "stats": report,
        "texts": by_key,
    }
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    path = DATA_DIR / f"tafsir_{slug}.json"
    path.write_text(json.dumps(out, ensure_ascii=False), encoding="utf-8")

    print("\n== ĐO ĐẠC ==")
    for k, v in report.items():
        print(f"  {k}: {v}")
    print(f"  json_bytes: {path.stat().st_size}")
    print(f"-> {path}")


if __name__ == "__main__":
    main()
