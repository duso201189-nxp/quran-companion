import sqlite3
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from lexicon.post_build_validator import validate_lexicon_tables
from lexicon.sqlite_writer import LEXICON_SCHEMA

# Stub tối thiểu — chỉ để word_instances.ayah_id có bảng REFERENCES hợp lệ,
# KHÔNG phải bảng ayahs thật của app.
_AYAHS_STUB = "CREATE TABLE ayahs (id INTEGER NOT NULL PRIMARY KEY);"


def _fresh_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(":memory:")
    conn.executescript(_AYAHS_STUB + LEXICON_SCHEMA)
    conn.execute("INSERT INTO ayahs (id) VALUES (1), (2), (3)")
    return conn


class PostBuildValidatorTests(unittest.TestCase):
    def test_bang_rong_khong_co_loi(self):
        conn = _fresh_conn()
        self.assertEqual(validate_lexicon_tables(conn), [])

    def test_du_lieu_hop_le_khong_co_loi(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO roots (id, radicals) VALUES (1, 'ktb')")
        conn.execute("INSERT INTO lemmas (id, arabic, root_id, occurrence_count) VALUES (1, 'kataba', 1, 1)")
        conn.execute("INSERT INTO lexemes (id, lemma_id) VALUES (1, 1)")
        conn.execute(
            "INSERT INTO word_instances (id, ayah_id, lexeme_id, position, arabic_form) "
            "VALUES (1, 1, 1, 1, 'kataba')"
        )
        conn.commit()
        self.assertEqual(validate_lexicon_tables(conn), [])

    def test_root_radicals_rong_bi_phat_hien(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO roots (id, radicals) VALUES (1, '')")
        conn.commit()
        errors = validate_lexicon_tables(conn)
        self.assertTrue(any("radicals rỗng" in e for e in errors))

    def test_wordinstance_trung_ayah_position_bi_phat_hien(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO lemmas (id, arabic) VALUES (1, 'x')")
        conn.execute("INSERT INTO lexemes (id, lemma_id) VALUES (1, 1)")
        conn.execute(
            "INSERT INTO word_instances (id, ayah_id, lexeme_id, position, arabic_form) "
            "VALUES (1, 1, 1, 1, 'a'), (2, 1, 1, 1, 'b')"
        )
        conn.commit()
        errors = validate_lexicon_tables(conn)
        self.assertTrue(any("trùng WordInstance" in e for e in errors))

    def test_occurrence_count_sai_bi_phat_hien(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO lemmas (id, arabic, occurrence_count) VALUES (1, 'x', 99)")
        conn.execute("INSERT INTO lexemes (id, lemma_id) VALUES (1, 1)")
        conn.execute(
            "INSERT INTO word_instances (id, ayah_id, lexeme_id, position, arabic_form) "
            "VALUES (1, 1, 1, 1, 'a')"
        )
        conn.commit()
        errors = validate_lexicon_tables(conn)
        self.assertTrue(any("occurrence_count không khớp" in e for e in errors))

    def test_relation_type_ngoai_synonym_antonym_bi_phat_hien(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO lemmas (id, arabic) VALUES (1, 'a'), (2, 'b')")
        conn.execute(
            "INSERT INTO lexicon_relations (id, from_lemma_id, to_lemma_id, relation_type) "
            "VALUES (1, 1, 2, 'hyponym')"
        )
        conn.commit()
        errors = validate_lexicon_tables(conn)
        self.assertTrue(any("relation_type ngoài synonym/antonym" in e for e in errors))

    def test_phrase_thu_tu_khong_lien_tuc_bi_phat_hien(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO phrases (id, arabic) VALUES (1, 'x')")
        conn.execute("INSERT INTO lemmas (id, arabic) VALUES (1, 'a')")
        conn.execute("INSERT INTO lexemes (id, lemma_id) VALUES (1, 1)")
        conn.execute(
            "INSERT INTO word_instances (id, ayah_id, lexeme_id, position, arabic_form) "
            "VALUES (1, 1, 1, 1, 'a'), (2, 1, 1, 2, 'b')"
        )
        # position 1 rồi nhảy thẳng 3 -> thiếu 2, không liên tục.
        conn.execute(
            "INSERT INTO phrase_word_instances (phrase_id, word_instance_id, position) "
            "VALUES (1, 1, 1), (1, 2, 3)"
        )
        conn.commit()
        errors = validate_lexicon_tables(conn)
        self.assertTrue(any("position không liên tục" in e for e in errors))

    def test_expected_word_count_khop_khong_loi(self):
        conn = _fresh_conn()
        conn.execute("INSERT INTO lemmas (id, arabic, occurrence_count) VALUES (1, 'x', 1)")
        conn.execute("INSERT INTO lexemes (id, lemma_id) VALUES (1, 1)")
        conn.execute(
            "INSERT INTO word_instances (id, ayah_id, lexeme_id, position, arabic_form) "
            "VALUES (1, 1, 1, 1, 'a')"
        )
        conn.commit()
        self.assertEqual(validate_lexicon_tables(conn, expected_word_count=1), [])
        errors = validate_lexicon_tables(conn, expected_word_count=999)
        self.assertTrue(any("tổng WordInstance = 1, mong đợi 999" in e for e in errors))

    def test_foreign_key_check_phat_hien_fk_hong(self):
        conn = _fresh_conn()
        # Chèn thẳng, bỏ qua tầng ứng dụng, để tạo 1 FK hỏng thật sự.
        conn.execute(
            "INSERT INTO lexemes (id, lemma_id) VALUES (1, 999)"
        )
        conn.commit()
        errors = validate_lexicon_tables(conn)
        self.assertTrue(any("vi phạm foreign key" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
