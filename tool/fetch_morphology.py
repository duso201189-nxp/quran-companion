#!/usr/bin/env python3
"""Vendor dữ liệu hình thái học (Root/Lemma/POS/Grammar) cho Lexicon.

KHÔNG tự tải mạng — khác hẳn fetch_transliteration.py/build_quran_db.py.
Lý do (xác nhận bằng bằng chứng thật, không phải suy đoán — xem Sprint
12 Phase 2.6/2.7 và Return của Phase 3):

  1. Giấy phép thật của file dữ liệu Quranic Arabic Corpus (đọc trực
     tiếp từ đúng khối comment đầu file, hiển thị ngay trên
     corpus.quran.com/download/) là:

         # Permission is granted to copy and distribute verbatim
         # copies of this file, but CHANGING IT IS NOT ALLOWED.

     Đây LÀ điều khoản áp dụng cho DỮ LIỆU (khác trang license.jsp
     chỉ hiển thị toàn văn GPLv3 làm nền, dễ gây hiểu lầm — đã xác
     nhận 2 nguồn tự động mâu thuẫn nhau ở Phase 2.6, và đã tự tay
     tải HTML thật để đối chiếu ở Phase 3 mới chốt được điều này).
     "CHANGING IT IS NOT ALLOWED" xung đột trực tiếp với việc pipeline
     này BẮT BUỘC phải biến đổi dữ liệu (gộp segment -> WordInstance,
     suy ra Lexeme...) trước khi đưa vào quran.sqlite — đây là mâu
     thuẫn kiến trúc THẬT, chưa có cách giải quyết, KHÔNG phải việc
     script này có thể tự quyết định thay người dùng.

  2. Trang tải yêu cầu điền email thật vào 1 form JS
     (`document.downloadForm`) — không có URL tĩnh nào tải được bằng
     script vô danh. Một agent tự động không nên tự ý điền thông tin
     liên hệ vào form của bên thứ 3 thay người dùng.

Vì 2 lý do trên, module này CHỦ ĐỘNG không tự tải — nó chỉ xử lý 1
file đã có sẵn TRÊN MÁY, do người dùng tự tải thủ công (tự đọc + chấp
nhận điều khoản trên trang corpus.quran.com bằng chính email của họ),
rồi đặt vào đường dẫn chỉ định. Script chỉ kiểm tra định dạng cơ bản
và ghi lại metadata nguồn — KHÔNG tự động hoá bước cấp phép/tải.

Cách dùng (sau khi đã tự tải thủ công):
  python3 tool/fetch_morphology.py --input <đường dẫn file .txt đã tải>
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from lexicon.segment_parser import parse_lines  # noqa: E402

OUT_META = Path(__file__).parent / "data" / "morphology_source.json"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--input",
        required=True,
        help="đường dẫn file hình thái học đã TỰ TAY tải từ "
        "corpus.quran.com/download/ (script này không tự tải)",
    )
    ap.add_argument(
        "--source-url",
        default="https://corpus.quran.com/download/",
        help="URL nguồn để ghi vào metadata (mặc định trang tải QAC)",
    )
    args = ap.parse_args()

    src = Path(args.input)
    if not src.exists():
        print(
            f"LỖI: không thấy file {src}\n"
            "File này KHÔNG được vendor sẵn trong repo (giấy phép chưa "
            "rõ ràng cho việc phân phối lại — xem docstring). Tự tải thủ "
            "công tại https://corpus.quran.com/download/ rồi chạy lại "
            "với --input.",
            file=sys.stderr,
        )
        return 1

    lines = src.read_text(encoding="utf-8", errors="replace").splitlines()
    segments, errors = parse_lines(lines)

    print(f"Đã đọc {len(lines)} dòng từ {src}")
    print(f"  parse OK: {len(segments)} segment")
    print(f"  lỗi parse: {len(errors)} dòng")
    if errors:
        for e in errors[:20]:
            print(f"    {e}")
        if len(errors) > 20:
            print(f"    ... còn {len(errors) - 20} lỗi khác")

    if not segments:
        print("LỖI: 0 segment hợp lệ — kiểm tra lại định dạng file input.", file=sys.stderr)
        return 1

    OUT_META.parent.mkdir(parents=True, exist_ok=True)
    OUT_META.write_text(
        json.dumps(
            {
                "source": {
                    "name": "Quranic Arabic Corpus (v0.4, Kais Dukes)",
                    "url": args.source_url,
                    "license_note": (
                        "Điều khoản gốc: chỉ được sao chép NGUYÊN VĂN, "
                        "'changing it is not allowed' — CHƯA xác nhận "
                        "pipeline chuẩn hoá (segment->WordInstance, suy "
                        "ra Lexeme) có được phép hay không. XEM Return "
                        "Sprint 12 Phase 3 trước khi dùng dữ liệu suy ra "
                        "từ file này trong bản build thật."
                    ),
                    "fetched_manually_by_user": True,
                    "recorded_at": date.today().isoformat(),
                    "input_file": str(src),
                    "segment_count": len(segments),
                    "parse_error_count": len(errors),
                },
            },
            ensure_ascii=False,
            indent=1,
        ),
        encoding="utf-8",
    )
    print(f"\n✓ Đã ghi metadata nguồn vào {OUT_META}")
    print(
        "  LƯU Ý: script này KHÔNG ghi dữ liệu segment vào tool/data/ — "
        "chỉ xác nhận file input parse được. Bước normalize + ghi "
        "SQLite thật vẫn cần quyết định giấy phép ở trên trước."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
