"""Dữ liệu mẫu TỰ TẠO (KHÔNG trích từ Quranic Arabic Corpus thật — xem
LỆNH CẤM trong tool/fetch_morphology.py: chưa có byte thật nào của
QAC trong repo này). Chỉ dùng để kiểm tra CƠ CHẾ phân tích/chuẩn hoá
đúng định dạng LOCATION/FORM/TAG/FEATURES đã công bố công khai, phủ
đủ mọi case A..I của Sprint 12 Phase 2.7 §2.
"""
from __future__ import annotations

# (sura, aya): số ayah — chỉ cần đủ giá trị aya dùng trong SAMPLE_LINES.
AYAH_COUNTS = {1: 7}

# Mỗi dòng: LOCATION\tFORM\tTAG\tFEATURES
SAMPLE_LINES = [
    # --- Từ A (1:1:1) — case A: 1 stem V có ROOT+LEM ---
    "(1:1:1:1)\tktb\tV\tROOT:ktb|LEM:kataba|3MS|PERF|ACT",
    # --- Từ B (1:1:2) — case E (DET prefix bị bỏ) + case A (N) ---
    "(1:1:2:1)\tAl+\tDET\t-",
    "(1:1:2:2)\tsmA\tN\tROOT:smw|LEM:ism|DEF|GEN",
    # --- Từ C (1:1:3) — case C (P prefix gấp) + A (N) + D (PRON suffix gấp) ---
    "(1:1:3:1)\tbi+\tP\tLEM:bi",
    "(1:1:3:2)\tkitAb\tN\tROOT:ktb|LEM:kitAb|GEN|INDEF",
    "(1:1:3:3)\t+hi\tPRON\tLEM:hu|3MS",
    # --- Từ D (1:2:1) — case F: 1 mình từ chức năng, không có content stem ---
    "(1:2:1:1)\twa\tCONJ\tLEM:wa",
    # --- Từ E (1:2:2) — case B: PN không có ROOT ---
    "(1:2:2:1)\tibrAhym\tPN\tLEM:ibrAhym",
    # --- Từ F (1:2:3) — verb Form II, để kiểm khoá Lexeme theo verb ---
    "(1:2:3:1)\tkt~ab\tV\tROOT:ktb|LEM:kattaba|II|PERF|ACT|3MS",
    # --- Từ G (1:3:1) — case G: content POS nhưng thiếu cả ROOT lẫn LEM ---
    "(1:3:1:1)\txxx\tN\tGEN",
    # --- Từ H (1:3:2) — case I: 2 stem nội dung trong cùng 1 từ ---
    "(1:3:2:1)\tsmA\tN\tROOT:smw|LEM:ism|GEN",
    "(1:3:2:2)\tkitAb\tN\tROOT:ktb|LEM:kitAb|GEN",
]

MALFORMED_LINES = [
    "khong-du-cot\tchi-2-cot",
    "(1:1)\tform\tN\tLEM:x",  # LOCATION thiếu phần
    "(1:1:1:a)\tform\tN\tLEM:x",  # LOCATION có chữ, không phải số
    "(1:1:1:1)\t\tN\tLEM:x",  # FORM rỗng
    "(1:1:1:1)\tform\t\tLEM:x",  # TAG rỗng
    "",  # dòng trống -> bị bỏ qua, KHÔNG tính là lỗi
    "# comment -> cũng bị bỏ qua",
]
