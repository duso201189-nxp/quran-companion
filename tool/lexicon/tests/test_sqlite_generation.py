"""Chứng minh cơ chế toàn bộ chuỗi Parser -> Normalizer -> pre_build_validator
-> sqlite_writer -> post_build_validator chạy đúng END-TO-END trên dữ liệu
TỰ TẠO (tool/lexicon/tests/fixtures.py) — KHÔNG động tới
assets/database/quran.sqlite thật, KHÔNG dùng dữ liệu QAC thật (chưa có).
"""
import sqlite3
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from lexicon.normalizer import normalize
from lexicon.post_build_validator import validate_lexicon_tables
from lexicon.pre_build_validator import validate_records
from lexicon.segment_parser import parse_lines
from lexicon.sqlite_writer import LEXICON_SCHEMA, write_lexicon_records
from lexicon.tests.fixtures import AYAH_COUNTS, SAMPLE_LINES

_AYAHS_STUB = "CREATE TABLE ayahs (id INTEGER NOT NULL PRIMARY KEY);"


class SqliteGenerationEndToEndTests(unittest.TestCase):
    def test_chuoi_day_du_tu_text_tho_den_sqlite_da_validate(self):
        segments, parse_errors = parse_lines(SAMPLE_LINES)
        self.assertEqual(parse_errors, [])

        records = normalize(segments, AYAH_COUNTS)
        self.assertEqual(validate_records(records), [])

        conn = sqlite3.connect(":memory:")
        conn.executescript(_AYAHS_STUB + LEXICON_SCHEMA)
        conn.executemany("INSERT INTO ayahs (id) VALUES (?)", [(i,) for i in range(1, 8)])
        conn.commit()

        write_lexicon_records(conn, records)
        conn.commit()

        errors = validate_lexicon_tables(conn)
        self.assertEqual(errors, [])

        n_words = conn.execute("SELECT COUNT(*) FROM word_instances").fetchone()[0]
        # 8 từ trong SAMPLE_LINES, trừ 1 bị case G bỏ (1:3:1) -> 7.
        self.assertEqual(n_words, 7)

        n_lemmas = conn.execute("SELECT COUNT(*) FROM lemmas").fetchone()[0]
        self.assertGreater(n_lemmas, 0)

        conn.close()


if __name__ == "__main__":
    unittest.main()
