import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from lexicon.normalizer import GrammarFeatureRec, LemmaRec, LexemeRec, NormalizedRecords, RootRec, WordInstanceRec, normalize
from lexicon.pre_build_validator import validate_records
from lexicon.segment_parser import parse_lines
from lexicon.tests.fixtures import AYAH_COUNTS, SAMPLE_LINES


class PreBuildValidatorTests(unittest.TestCase):
    def test_du_lieu_chuan_hoa_tu_sample_khong_co_loi(self):
        segments, _ = parse_lines(SAMPLE_LINES)
        records = normalize(segments, AYAH_COUNTS)
        self.assertEqual(validate_records(records), [])

    def test_root_radicals_rong_bi_bao_loi(self):
        records = NormalizedRecords(roots=[RootRec(id=1, radicals="  ")])
        errors = validate_records(records)
        self.assertTrue(any("radicals rỗng" in e for e in errors))

    def test_lemma_tro_toi_root_khong_ton_tai(self):
        records = NormalizedRecords(
            lemmas=[LemmaRec(id=1, arabic="x", root_id=999)]
        )
        errors = validate_records(records)
        self.assertTrue(any("root_id=999 không tồn tại" in e for e in errors))

    def test_lexeme_tro_toi_lemma_khong_ton_tai(self):
        records = NormalizedRecords(
            lexemes=[LexemeRec(id=1, lemma_id=999)]
        )
        errors = validate_records(records)
        self.assertTrue(any("lemma_id=999 không tồn tại" in e for e in errors))

    def test_wordinstance_trung_ayah_position(self):
        records = NormalizedRecords(
            lemmas=[LemmaRec(id=1, arabic="x")],
            lexemes=[LexemeRec(id=1, lemma_id=1)],
            word_instances=[
                WordInstanceRec(id=1, ayah_id=1, lexeme_id=1, position=1, arabic_form="a"),
                WordInstanceRec(id=2, ayah_id=1, lexeme_id=1, position=1, arabic_form="b"),
            ],
        )
        errors = validate_records(records)
        self.assertTrue(any("trùng (ayah_id=1, position=1)" in e for e in errors))

    def test_grammarfeature_tro_toi_wordinstance_khong_ton_tai(self):
        records = NormalizedRecords(
            grammar_features=[GrammarFeatureRec(id=1, word_instance_id=999, feature_key="k", feature_value="v")]
        )
        errors = validate_records(records)
        self.assertTrue(any("word_instance_id=999 không tồn tại" in e for e in errors))

    def test_occurrence_count_sai_bi_bao_loi(self):
        records = NormalizedRecords(
            lemmas=[LemmaRec(id=1, arabic="x", occurrence_count=5)],
            lexemes=[LexemeRec(id=1, lemma_id=1)],
            word_instances=[
                WordInstanceRec(id=1, ayah_id=1, lexeme_id=1, position=1, arabic_form="a"),
            ],
        )
        errors = validate_records(records)
        self.assertTrue(any("occurrence_count=5 nhưng đếm thực tế=1" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
