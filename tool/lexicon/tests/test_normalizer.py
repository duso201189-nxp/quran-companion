import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from lexicon.normalizer import classify_flag, normalize
from lexicon.segment_parser import parse_lines
from lexicon.tests.fixtures import AYAH_COUNTS, SAMPLE_LINES


class ClassifyFlagTests(unittest.TestCase):
    def test_person_gender_number(self):
        self.assertEqual(classify_flag("3MS"), ("person_gender_number", "3MS"))
        self.assertEqual(classify_flag("2FD"), ("person_gender_number", "2FD"))
        self.assertEqual(classify_flag("1MP"), ("person_gender_number", "1MP"))

    def test_case_state_aspect_mood_voice_verbform(self):
        self.assertEqual(classify_flag("GEN"), ("case", "GEN"))
        self.assertEqual(classify_flag("DEF"), ("state", "DEF"))
        self.assertEqual(classify_flag("PERF"), ("aspect", "PERF"))
        self.assertEqual(classify_flag("JUS"), ("mood", "JUS"))
        self.assertEqual(classify_flag("ACT"), ("voice", "ACT"))
        self.assertEqual(classify_flag("II"), ("verb_form", "II"))

    def test_ma_khong_nhan_dien_duoc_tra_none(self):
        self.assertIsNone(classify_flag("ZZZ"))
        self.assertIsNone(classify_flag(""))


class NormalizeCaseTests(unittest.TestCase):
    def setUp(self):
        segments, errors = parse_lines(SAMPLE_LINES)
        self.assertEqual(errors, [])
        self.records = normalize(segments, AYAH_COUNTS)

    def _wi_at(self, aya, word):
        # ayah_id cho surah 1 = chính aya (vì sura=1 -> không cộng gì trước đó)
        return next(
            wi for wi in self.records.word_instances
            if wi.ayah_id == aya and wi.position == word
        )

    def _lemma(self, lemma_id):
        return next(lm for lm in self.records.lemmas if lm.id == lemma_id)

    def test_case_A_stem_don_co_root_lem(self):
        wi = self._wi_at(1, 1)
        lexeme = next(lx for lx in self.records.lexemes if lx.id == wi.lexeme_id)
        lemma = self._lemma(lexeme.lemma_id)
        self.assertEqual(lemma.arabic, "kataba")
        root = next(r for r in self.records.roots if r.id == lemma.root_id)
        self.assertEqual(root.radicals, "ktb")

    def test_case_E_det_prefix_khong_tao_feature_rieng(self):
        wi = self._wi_at(1, 2)
        features = [gf for gf in self.records.grammar_features if gf.word_instance_id == wi.id]
        keys = {gf.feature_key for gf in features}
        self.assertNotIn("attached_proclitic", keys)  # DET không phải proclitic thường
        state_values = [gf.feature_value for gf in features if gf.feature_key == "state"]
        self.assertEqual(state_values, ["DEF"])  # feature DEF của chính stem N, không trùng lặp

    def test_case_C_va_D_proclitic_va_pronoun_gap_vao_head(self):
        wi = self._wi_at(1, 3)
        features = {
            gf.feature_key: gf.feature_value
            for gf in self.records.grammar_features
            if gf.word_instance_id == wi.id
        }
        self.assertEqual(features.get("attached_proclitic"), "bi")
        self.assertEqual(features.get("attached_pronoun"), "hu")
        lexeme = next(lx for lx in self.records.lexemes if lx.id == wi.lexeme_id)
        lemma = self._lemma(lexeme.lemma_id)
        self.assertEqual(lemma.arabic, "kitAb")  # head là N (kitAb), không phải bi/hu

    def test_case_F_tu_chuc_nang_dung_1_minh_co_wordinstance_rieng(self):
        wi = self._wi_at(2, 1)
        lexeme = next(lx for lx in self.records.lexemes if lx.id == wi.lexeme_id)
        lemma = self._lemma(lexeme.lemma_id)
        self.assertEqual(lemma.arabic, "wa")
        self.assertIsNone(lemma.root_id)  # từ chức năng không có root

    def test_case_B_proper_noun_khong_co_root(self):
        wi = self._wi_at(2, 2)
        lexeme = next(lx for lx in self.records.lexemes if lx.id == wi.lexeme_id)
        lemma = self._lemma(lexeme.lemma_id)
        self.assertEqual(lemma.arabic, "ibrAhym")
        self.assertIsNone(lemma.root_id)

    def test_verb_lexeme_key_gom_form_aspect_voice(self):
        wi_form1 = self._wi_at(1, 1)  # kataba, không có form roman -> None
        wi_form2 = self._wi_at(2, 3)  # kattaba, Form II
        lx1 = next(lx for lx in self.records.lexemes if lx.id == wi_form1.lexeme_id)
        lx2 = next(lx for lx in self.records.lexemes if lx.id == wi_form2.lexeme_id)
        self.assertNotEqual(lx1.id, lx2.id)  # 2 lemma khác nhau -> 2 lexeme khác nhau
        self.assertEqual(lx2.form_pattern, "II")

    def test_case_G_thieu_root_va_lem_bi_bo_qua_co_log(self):
        # Từ (1:3:1) không tạo WordInstance nào.
        found = [wi for wi in self.records.word_instances if wi.ayah_id == 3 and wi.position == 1]
        self.assertEqual(found, [])
        self.assertTrue(any("1:3:1" in s for s in self.records.skipped))

    def test_case_I_hai_stem_noi_dung_lay_stem_dau_gap_stem_thua(self):
        wi = self._wi_at(3, 2)
        lexeme = next(lx for lx in self.records.lexemes if lx.id == wi.lexeme_id)
        lemma = self._lemma(lexeme.lemma_id)
        self.assertEqual(lemma.arabic, "ism")  # stem ĐẦU TIÊN (smA/ism) được chọn làm head
        features = [gf for gf in self.records.grammar_features if gf.word_instance_id == wi.id]
        additional = [gf for gf in features if gf.feature_key == "additional_stem"]
        self.assertEqual(len(additional), 1)
        self.assertEqual(additional[0].feature_value, "kitAb")  # stem thừa bị gấp, không mất

    def test_occurrence_count_khop_so_wordinstance_thuc_te(self):
        for lemma in self.records.lemmas:
            actual = sum(
                1
                for wi in self.records.word_instances
                for lx in self.records.lexemes
                if lx.id == wi.lexeme_id and lx.lemma_id == lemma.id
            )
            self.assertEqual(lemma.occurrence_count, actual, msg=f"lemma {lemma.arabic}")

    def test_moi_nhom_tu_deu_co_ket_qua_ro_rang(self):
        # Mỗi nhóm (sura,aya,word) trong SAMPLE_LINES phải kết thúc ở
        # ĐÚNG MỘT trong 2 trạng thái: sinh 1 WordInstance, hoặc bị ghi
        # vào skipped (case G) — không có nhóm nào biến mất im lặng.
        segments, _ = parse_lines(SAMPLE_LINES)
        total_groups = len({seg.word_key for seg in segments})
        produced = len(self.records.word_instances)
        skipped = len(self.records.skipped)
        self.assertEqual(total_groups, produced + skipped)

    def test_moi_segment_khong_phai_head_deu_duoc_giai_thich(self):
        # Với từng WordInstance, mọi segment KHÔNG PHẢI head trong cùng
        # nhóm phải hoặc (a) sinh 1 GrammarFeature gấp vào, hoặc (b) là
        # DET prefix bị bỏ có chủ đích (case E) — không có khả năng thứ 3.
        segments, _ = parse_lines(SAMPLE_LINES)
        groups: dict[tuple[int, int, int], list] = {}
        for seg in segments:
            groups.setdefault(seg.word_key, []).append(seg)

        folded_fkeys = {"attached_proclitic", "attached_pronoun", "attached_enclitic", "additional_stem"}
        for wi in self.records.word_instances:
            group = sorted(groups[(1, wi.ayah_id, wi.position)], key=lambda s: s.segment)
            non_head_count = len(group) - 1  # đúng 1 head mỗi nhóm đã sinh WordInstance
            features = [
                gf for gf in self.records.grammar_features
                if gf.word_instance_id == wi.id and gf.feature_key in folded_fkeys
            ]
            det_prefix_count = sum(1 for s in group if s.is_prefix and s.pos_tag == "DET")
            self.assertEqual(
                non_head_count,
                len(features) + det_prefix_count,
                msg=f"WordInstance {wi.id} (ayah {wi.ayah_id}, vị trí {wi.position})",
            )


if __name__ == "__main__":
    unittest.main()
