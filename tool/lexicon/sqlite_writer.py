"""NormalizedRecords -> INSERT vào 1 sqlite3.Connection đã có sẵn schema.

CHỈ ghi — không tạo bảng (schema tạo bởi LEXICON_SCHEMA trong
build_quran_db.py, xem tool/build_quran_db.py), không tự mở/đóng
connection, không validate (đó là việc của pre_build_validator /
post_build_validator). Thứ tự INSERT PHẢI đúng Phase 2.7 §4:
Roots -> Lemmas -> Lexemes -> (Ayahs đã có sẵn) -> WordInstances ->
GrammarFeatures. Phrases/PhraseWordInstances/LexiconRelations không
có nguồn tự động (Phase 2.6 §6) nên không ghi ở đây — để trống, đúng
tiền lệ "schema có trước, dữ liệu bổ sung sau" của lemmas/word_instances.
"""
from __future__ import annotations

import sqlite3

from .normalizer import NormalizedRecords

LEXICON_SCHEMA = """
CREATE TABLE roots (
  id INTEGER NOT NULL PRIMARY KEY,
  radicals TEXT NOT NULL,
  meaning_core TEXT
);
CREATE TABLE lemmas (
  id INTEGER NOT NULL PRIMARY KEY,
  arabic TEXT NOT NULL,
  transliteration TEXT,
  pos_tag TEXT,
  meaning_vi TEXT, meaning_en TEXT, explanation_vi TEXT,
  root_id INTEGER REFERENCES roots (id),
  occurrence_count INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE lexemes (
  id INTEGER NOT NULL PRIMARY KEY,
  lemma_id INTEGER NOT NULL REFERENCES lemmas (id),
  form_pattern TEXT,
  part_of_speech_detail TEXT
);
CREATE TABLE word_instances (
  id INTEGER NOT NULL PRIMARY KEY,
  ayah_id INTEGER NOT NULL REFERENCES ayahs (id),
  lexeme_id INTEGER NOT NULL REFERENCES lexemes (id),
  position INTEGER NOT NULL,
  arabic_form TEXT NOT NULL,
  transliteration TEXT
);
CREATE TABLE grammar_features (
  id INTEGER NOT NULL PRIMARY KEY,
  word_instance_id INTEGER NOT NULL REFERENCES word_instances (id),
  feature_key TEXT NOT NULL,
  feature_value TEXT NOT NULL
);
CREATE TABLE phrases (
  id INTEGER NOT NULL PRIMARY KEY,
  arabic TEXT NOT NULL,
  transliteration TEXT,
  meaning_vi TEXT, meaning_en TEXT
);
CREATE TABLE phrase_word_instances (
  phrase_id INTEGER NOT NULL REFERENCES phrases (id),
  word_instance_id INTEGER NOT NULL REFERENCES word_instances (id),
  position INTEGER NOT NULL,
  PRIMARY KEY (phrase_id, word_instance_id)
);
CREATE TABLE lexicon_relations (
  id INTEGER NOT NULL PRIMARY KEY,
  from_lemma_id INTEGER NOT NULL REFERENCES lemmas (id),
  to_lemma_id INTEGER NOT NULL REFERENCES lemmas (id),
  relation_type TEXT NOT NULL
);
CREATE INDEX idx_lemmas_root ON lemmas (root_id);
CREATE INDEX idx_lexemes_lemma ON lexemes (lemma_id);
CREATE INDEX idx_word_instances_ayah ON word_instances (ayah_id);
CREATE INDEX idx_word_instances_lexeme ON word_instances (lexeme_id);
CREATE INDEX idx_grammar_features_wi ON grammar_features (word_instance_id);
CREATE INDEX idx_phrase_word_instances_phrase ON phrase_word_instances (phrase_id);
CREATE INDEX idx_lexicon_relations_from ON lexicon_relations (from_lemma_id);
CREATE INDEX idx_lexicon_relations_to ON lexicon_relations (to_lemma_id);
"""


def write_lexicon_records(conn: sqlite3.Connection, records: NormalizedRecords) -> None:
    cur = conn.cursor()

    cur.executemany(
        "INSERT INTO roots (id, radicals, meaning_core) VALUES (?,?,?)",
        [(r.id, r.radicals, r.meaning_core) for r in records.roots],
    )
    cur.executemany(
        "INSERT INTO lemmas (id, arabic, transliteration, pos_tag, meaning_vi, "
        "meaning_en, explanation_vi, root_id, occurrence_count) "
        "VALUES (?,?,?,?,?,?,?,?,?)",
        [
            (
                lm.id, lm.arabic, lm.transliteration, lm.pos_tag,
                lm.meaning_vi, lm.meaning_en, lm.explanation_vi,
                lm.root_id, lm.occurrence_count,
            )
            for lm in records.lemmas
        ],
    )
    cur.executemany(
        "INSERT INTO lexemes (id, lemma_id, form_pattern, part_of_speech_detail) "
        "VALUES (?,?,?,?)",
        [
            (lx.id, lx.lemma_id, lx.form_pattern, lx.part_of_speech_detail)
            for lx in records.lexemes
        ],
    )
    cur.executemany(
        "INSERT INTO word_instances (id, ayah_id, lexeme_id, position, "
        "arabic_form, transliteration) VALUES (?,?,?,?,?,?)",
        [
            (wi.id, wi.ayah_id, wi.lexeme_id, wi.position, wi.arabic_form, wi.transliteration)
            for wi in records.word_instances
        ],
    )
    cur.executemany(
        "INSERT INTO grammar_features (id, word_instance_id, feature_key, "
        "feature_value) VALUES (?,?,?,?)",
        [
            (gf.id, gf.word_instance_id, gf.feature_key, gf.feature_value)
            for gf in records.grammar_features
        ],
    )
