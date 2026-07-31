import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from lexicon.segment_parser import Segment, SegmentParseError, parse_line, parse_lines
from lexicon.tests.fixtures import MALFORMED_LINES, SAMPLE_LINES


class ParseLineTests(unittest.TestCase):
    def test_dong_hop_le_tra_ve_segment(self):
        seg = parse_line("(1:1:1:1)\tktb\tV\tROOT:ktb|LEM:kataba|3MS|PERF|ACT")
        self.assertEqual(seg.sura, 1)
        self.assertEqual(seg.aya, 1)
        self.assertEqual(seg.word, 1)
        self.assertEqual(seg.segment, 1)
        self.assertEqual(seg.form, "ktb")
        self.assertEqual(seg.pos_tag, "V")
        self.assertEqual(seg.raw_features["ROOT"], "ktb")
        self.assertEqual(seg.raw_features["LEM"], "kataba")
        self.assertIn("3MS", seg.flags)
        self.assertIn("PERF", seg.flags)
        self.assertIn("ACT", seg.flags)

    def test_location_khong_co_ngoac_don_van_parse_duoc(self):
        seg = parse_line("1:1:1:1\tktb\tV\tLEM:kataba")
        self.assertEqual((seg.sura, seg.aya, seg.word, seg.segment), (1, 1, 1, 1))

    def test_dong_trong_va_comment_tra_ve_none(self):
        self.assertIsNone(parse_line(""))
        self.assertIsNone(parse_line("   "))
        self.assertIsNone(parse_line("# ghi chú"))

    def test_features_rong_hoac_gach_ngang(self):
        seg = parse_line("(1:1:1:1)\tAl+\tDET\t-")
        self.assertEqual(seg.raw_features, {})
        self.assertEqual(seg.flags, ())

    def test_prefix_suffix_stem_nhan_dien_qua_dau_cong(self):
        prefix = parse_line("(1:1:1:1)\tAl+\tDET\t-")
        suffix = parse_line("(1:1:1:2)\t+hi\tPRON\tLEM:hu")
        stem = parse_line("(1:1:1:3)\tkitAb\tN\tLEM:kitAb")
        self.assertTrue(prefix.is_prefix)
        self.assertFalse(prefix.is_suffix)
        self.assertTrue(suffix.is_suffix)
        self.assertFalse(suffix.is_prefix)
        self.assertTrue(stem.is_stem)
        self.assertFalse(stem.is_prefix)
        self.assertFalse(stem.is_suffix)

    def test_thieu_cot_nem_loi(self):
        with self.assertRaises(SegmentParseError):
            parse_line("chi\tco\tba-cot")

    def test_location_sai_dinh_dang_nem_loi(self):
        with self.assertRaises(SegmentParseError):
            parse_line("(1:1:1:a)\tform\tN\tLEM:x")

    def test_location_chi_so_nho_hon_1_nem_loi(self):
        with self.assertRaises(SegmentParseError):
            parse_line("(0:1:1:1)\tform\tN\tLEM:x")

    def test_form_rong_nem_loi(self):
        with self.assertRaises(SegmentParseError):
            parse_line("(1:1:1:1)\t\tN\tLEM:x")


class ParseLinesTests(unittest.TestCase):
    def test_toan_bo_sample_hop_le_khong_loi(self):
        segments, errors = parse_lines(SAMPLE_LINES)
        self.assertEqual(errors, [])
        self.assertEqual(len(segments), len(SAMPLE_LINES))

    def test_dong_hong_khong_lam_dung_ca_batch(self):
        segments, errors = parse_lines(MALFORMED_LINES)
        # 2 dòng trống/comment không tính lỗi; 5 dòng hỏng thật sự -> 5 lỗi
        # (thiếu cột, LOCATION thiếu phần, LOCATION không phải số, FORM
        # rỗng, TAG rỗng).
        self.assertEqual(len(errors), 5)
        self.assertEqual(segments, [])

    def test_tron_dong_hop_le_va_hong_van_giu_dong_hop_le(self):
        lines = SAMPLE_LINES[:2] + ["dòng hỏng\tchỉ 2 cột"] + SAMPLE_LINES[2:4]
        segments, errors = parse_lines(lines)
        self.assertEqual(len(errors), 1)
        self.assertEqual(len(segments), 4)


if __name__ == "__main__":
    unittest.main()
