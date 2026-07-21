"""Parser thuần túy: text thô kiểu QAC -> Segment có cấu trúc.

CHỈ phân tích cú pháp — không diễn giải ngữ nghĩa (không quyết định
đâu là "head segment", không suy ra Lexeme...) — đó là việc của
normalizer.py (xem docs Phase 2.7 "Importer responsibilities").

Định dạng dòng dữ liệu (đã xác nhận qua tài liệu công khai
corpus.quran.com/documentation/morphologicalfeatures.jsp — xem Sprint
12 Phase 2.6):

    LOCATION<TAB>FORM<TAB>TAG<TAB>FEATURES

  LOCATION  "(sura:aya:word:segment)" hoặc "sura:aya:word:segment"
  FORM      dạng chữ (Buckwalter/Ả Rập tuỳ nguồn). Tiền tố kết thúc
            bằng '+' (vd "wa+"), hậu tố bắt đầu bằng '+' (vd "+hu"),
            STEM (từ gốc của segment) không có '+' ở đầu/cuối — quy
            ước này đã được xác nhận, KHÔNG phải suy đoán.
  TAG       nhãn từ loại (POS), vd N, V, ADJ, PN, P, CONJ, DET, PRON...
  FEATURES  chuỗi token cách nhau '|'. Token có ':' là key:value
            (vd "LEM:kataba", "ROOT:ktb"). Token không có ':' là mã
            rút gọn (vd "3MS", "PERF", "GEN") — normalizer.py diễn
            giải các mã này, parser chỉ giữ nguyên dạng thô.

LƯU Ý: định dạng trên dựng lại từ tài liệu CÔNG KHAI mô tả cấu trúc
(không phải nội dung corpus có bản quyền) — parser CHƯA được kiểm
chứng trên file thật (xem TODO.md / Return Phase 3: tải file thật bị
chặn bởi giấy phép + cổng email, chưa có byte thật nào để đối chiếu).
"""
from __future__ import annotations

from dataclasses import dataclass, field


class SegmentParseError(ValueError):
    """1 dòng input không đúng định dạng tối thiểu (số cột, LOCATION)."""


@dataclass(frozen=True)
class Segment:
    sura: int
    aya: int
    word: int
    segment: int
    form: str
    pos_tag: str
    raw_features: dict[str, str] = field(default_factory=dict)
    flags: tuple[str, ...] = ()

    @property
    def is_prefix(self) -> bool:
        return self.form.endswith("+") and not self.form.startswith("+")

    @property
    def is_suffix(self) -> bool:
        return self.form.startswith("+")

    @property
    def is_stem(self) -> bool:
        return not self.is_prefix and not self.is_suffix

    @property
    def word_key(self) -> tuple[int, int, int]:
        return (self.sura, self.aya, self.word)


def _parse_location(raw: str) -> tuple[int, int, int, int]:
    loc = raw.strip().strip("()")
    parts = loc.split(":")
    if len(parts) != 4:
        raise SegmentParseError(f"LOCATION không đúng dạng sura:aya:word:segment: {raw!r}")
    try:
        sura, aya, word, seg = (int(p) for p in parts)
    except ValueError as e:
        raise SegmentParseError(f"LOCATION có phần không phải số: {raw!r}") from e
    if sura < 1 or aya < 1 or word < 1 or seg < 1:
        raise SegmentParseError(f"LOCATION có chỉ số < 1: {raw!r}")
    return sura, aya, word, seg


def _parse_features(raw: str) -> tuple[dict[str, str], tuple[str, ...]]:
    raw_features: dict[str, str] = {}
    flags: list[str] = []
    if not raw or raw == "-":
        return raw_features, ()
    for token in raw.split("|"):
        token = token.strip()
        if not token:
            continue
        if ":" in token:
            key, _, value = token.partition(":")
            raw_features[key.strip().upper()] = value.strip()
        else:
            flags.append(token)
    return raw_features, tuple(flags)


def parse_line(line: str) -> Segment | None:
    """1 dòng -> Segment. Dòng trống / dòng '#' (comment) -> None."""
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return None
    cols = stripped.split("\t")
    if len(cols) != 4:
        raise SegmentParseError(f"cần đúng 4 cột phân cách TAB, có {len(cols)}: {line!r}")
    location_raw, form, pos_tag, features_raw = cols
    sura, aya, word, seg = _parse_location(location_raw)
    if not form:
        raise SegmentParseError(f"FORM rỗng: {line!r}")
    if not pos_tag:
        raise SegmentParseError(f"TAG rỗng: {line!r}")
    raw_features, flags = _parse_features(features_raw)
    return Segment(
        sura=sura,
        aya=aya,
        word=word,
        segment=seg,
        form=form,
        pos_tag=pos_tag.strip().upper(),
        raw_features=raw_features,
        flags=flags,
    )


def parse_lines(lines: list[str] | 'Iterable[str]') -> tuple[list[Segment], list[str]]:
    """Phân tích nhiều dòng. Trả (segments hợp lệ, thông báo lỗi các dòng hỏng).

    KHÔNG dừng giữa chừng vì 1 dòng hỏng — thu thập lỗi, tiếp tục dòng
    sau (giống triết lý validate() của build_quran_db.py: báo đủ mọi
    lỗi 1 lần thay vì dừng ở lỗi đầu tiên).
    """
    segments: list[Segment] = []
    errors: list[str] = []
    for i, line in enumerate(lines, start=1):
        try:
            seg = parse_line(line)
        except SegmentParseError as e:
            errors.append(f"dòng {i}: {e}")
            continue
        if seg is not None:
            segments.append(seg)
    return segments, errors
