"""Chính sách chuẩn hoá Segment -> Root/Lemma/Lexeme/WordInstance/GrammarFeature.

Hiện thực CHÍNH XÁC quy tắc đã đóng băng ở Sprint 12 Phase 2.7 (mục 2,
"Normalization rules" — bảng case A..I và bảng dẫn xuất Lexeme theo
POS). KHÔNG có logic mới ở đây — nếu 1 case không khớp bảng đó thì
đây là lỗi hiện thực, không phải quyết định thiết kế mới.

Quyết định cốt lõi (Phase 2.7 §2): 1 TỪ Qur'an (nhóm segment cùng
sura:aya:word) -> ĐÚNG 1 WordInstance. Segment "head" được chọn theo
thứ tự: segment STEM đầu tiên có TAG thuộc CONTENT_POS; nếu không có
-> segment STEM đầu tiên bất kỳ (từ chức năng đứng 1 mình, case F).
Mọi segment còn lại (PREFIX/SUFFIX, hoặc STEM thừa — case I) được gấp
vào WordInstance đó dưới dạng GrammarFeature, KHÔNG tạo WordInstance
riêng — hệ quả trực tiếp của việc WordInstance đã đóng băng ở Phase 1
chỉ có 1 lexemeId/1 arabicForm/1 position.
"""
from __future__ import annotations

import re
from dataclasses import dataclass, field

from .segment_parser import Segment

CONTENT_POS = frozenset({"N", "V", "ADJ", "PN"})

_PGN_RE = re.compile(r"^([123])([MF])([SDP])$")
_CASE_VALUES = frozenset({"NOM", "ACC", "GEN"})
_STATE_VALUES = frozenset({"DEF", "INDEF"})
_ASPECT_VALUES = frozenset({"PERF", "IMPF", "IMPV"})
_MOOD_VALUES = frozenset({"IND", "SUBJ", "JUS"})
_VOICE_VALUES = frozenset({"ACT", "PASS"})
_VERB_FORM_VALUES = frozenset(
    {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"}
)


def classify_flag(flag: str) -> tuple[str, str] | None:
    """1 mã rút gọn (vd '3MS', 'GEN', 'PERF') -> (featureKey, featureValue).

    None nếu không nhận diện được (mã lạ/chưa biết) — bị BỎ QUA có
    log cảnh báo ở tầng gọi, không suy đoán liều để tránh gán sai
    (đúng tinh thần "fail loud" của cả pipeline).
    """
    m = _PGN_RE.match(flag)
    if m:
        person, gender, number = m.groups()
        return "person_gender_number", f"{person}{gender}{number}"
    if flag in _CASE_VALUES:
        return "case", flag
    if flag in _STATE_VALUES:
        return "state", flag
    if flag in _ASPECT_VALUES:
        return "aspect", flag
    if flag in _MOOD_VALUES:
        return "mood", flag
    if flag in _VOICE_VALUES:
        return "voice", flag
    if flag in _VERB_FORM_VALUES:
        return "verb_form", flag
    return None


@dataclass
class RootRec:
    id: int
    radicals: str
    meaning_core: str | None = None


@dataclass
class LemmaRec:
    id: int
    arabic: str
    transliteration: str | None = None
    pos_tag: str | None = None
    meaning_vi: str | None = None
    meaning_en: str | None = None
    explanation_vi: str | None = None
    root_id: int | None = None
    occurrence_count: int = 0


@dataclass
class LexemeRec:
    id: int
    lemma_id: int
    form_pattern: str | None = None
    part_of_speech_detail: str | None = None


@dataclass
class WordInstanceRec:
    id: int
    ayah_id: int
    lexeme_id: int
    position: int
    arabic_form: str
    transliteration: str | None = None


@dataclass
class GrammarFeatureRec:
    id: int
    word_instance_id: int
    feature_key: str
    feature_value: str


@dataclass
class NormalizedRecords:
    roots: list[RootRec] = field(default_factory=list)
    lemmas: list[LemmaRec] = field(default_factory=list)
    lexemes: list[LexemeRec] = field(default_factory=list)
    word_instances: list[WordInstanceRec] = field(default_factory=list)
    grammar_features: list[GrammarFeatureRec] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    skipped: list[str] = field(default_factory=list)


class _IdAllocator:
    def __init__(self) -> None:
        self._next = 1

    def next(self) -> int:
        v = self._next
        self._next += 1
        return v


def _ayah_id_for(sura: int, aya: int, ayah_counts: dict[int, int]) -> int:
    """sura/aya -> id toàn cục 1..6236 (thứ tự Surah 1..114, Ayah 1..n).

    CÙNG công thức build_quran_db.py dùng khi build ayahs — không
    được lệch, nếu không FK WordInstance.ayah_id sẽ trỏ sai hàng.
    """
    ayah_id = 0
    for s in range(1, sura):
        ayah_id += ayah_counts[s]
    return ayah_id + aya


def _select_head(segments: list[Segment]) -> tuple[Segment, list[Segment]]:
    """1 nhóm segment cùng từ -> (head, phần còn lại theo thứ tự gốc).

    Case A/B: segment STEM đầu tiên có TAG thuộc CONTENT_POS.
    Case F: không có -> segment STEM đầu tiên bất kỳ.
    Case I: nhiều STEM nội dung -> lấy cái ĐẦU TIÊN, phần dư đi vào
    "còn lại" (bị gấp vào head như mọi segment không phải head, có
    cảnh báo riêng ở tầng gọi).
    """
    stems = [s for s in segments if s.is_stem]
    head = next((s for s in stems if s.pos_tag in CONTENT_POS), None)
    if head is None and stems:
        head = stems[0]
    if head is None:
        # Không có STEM nào (chỉ toàn PREFIX/SUFFIX) — dữ liệu hỏng,
        # tầng gọi (normalize()) coi là case G, bỏ cả nhóm.
        raise ValueError("nhóm segment không có STEM nào")
    rest = [s for s in segments if s is not head]
    return head, rest


def _fold_non_head(seg: Segment) -> tuple[str, str] | None:
    """Segment không phải head -> (featureKey, featureValue) để gấp vào
    WordInstance của head, hoặc None nếu bị bỏ qua có chủ đích.

    Case E: PREFIX có TAG=DET (mạo từ 'al+') — KHÔNG tạo feature
    riêng, đã có STATE:DEF trên head rồi (tránh trùng lặp thông tin).
    Case C: PREFIX khác (giới từ/liên từ gắn liền) -> 'attached_proclitic'.
    Case D: SUFFIX có TAG=PRON (đại từ hậu tố) -> 'attached_pronoun'.
    Case C (SUFFIX khác PRON) -> 'attached_enclitic'.
    """
    if seg.is_prefix and seg.pos_tag == "DET":
        return None
    lemma_value = seg.raw_features.get("LEM", seg.form.strip("+"))
    if seg.is_suffix and seg.pos_tag == "PRON":
        return "attached_pronoun", lemma_value
    if seg.is_prefix:
        return "attached_proclitic", lemma_value
    if seg.is_suffix:
        return "attached_enclitic", lemma_value
    # STEM thừa (case I) — gấp vào dưới nhãn riêng để không mất thông tin.
    return "additional_stem", lemma_value


def _lexeme_key(lemma_key: tuple, head: Segment) -> tuple:
    """Khoá dẫn xuất Lexeme theo TAG — đúng bảng Phase 2.7 §2.

    V: (lemma, form, aspect, voice). N/ADJ/PN/particle/pronoun: chỉ
    (lemma,) — 1:1 tổng hợp, không có dữ liệu phái sinh để tách thêm.
    """
    if head.pos_tag == "V":
        verb_form = next((f for f in head.flags if f in _VERB_FORM_VALUES), None)
        aspect = next((f for f in head.flags if f in _ASPECT_VALUES), None)
        voice = next((f for f in head.flags if f in _VOICE_VALUES), None)
        return (lemma_key, verb_form, aspect, voice)
    return (lemma_key,)


def normalize(
    segments: list[Segment],
    ayah_counts: dict[int, int],
) -> NormalizedRecords:
    """list[Segment] (thứ tự bất kỳ) -> NormalizedRecords hoàn chỉnh.

    ayah_counts: {sura: số ayah} — CẦN để tính ayah_id toàn cục khớp
    với bảng `ayahs` đã có sẵn (Lexicon build SAU core content, xem
    Phase 2.7 §4 "Database generation order").
    """
    records = NormalizedRecords()

    root_ids: dict[str, int] = {}
    lemma_ids: dict[tuple, int] = {}
    lexeme_ids: dict[tuple, int] = {}
    lemma_occurrence: dict[int, int] = {}

    root_alloc = _IdAllocator()
    lemma_alloc = _IdAllocator()
    lexeme_alloc = _IdAllocator()
    word_instance_alloc = _IdAllocator()
    feature_alloc = _IdAllocator()

    groups: dict[tuple[int, int, int], list[Segment]] = {}
    order: list[tuple[int, int, int]] = []
    for seg in segments:
        key = seg.word_key
        if key not in groups:
            groups[key] = []
            order.append(key)
        groups[key].append(seg)

    for key in order:
        sura, aya, word = key
        group = sorted(groups[key], key=lambda s: s.segment)
        try:
            head, rest = _select_head(group)
        except ValueError as e:
            records.skipped.append(f"{sura}:{aya}:{word}: {e}")
            continue

        root_id: int | None = None
        if head.pos_tag in CONTENT_POS:
            root_text = head.raw_features.get("ROOT")
            lem_text = head.raw_features.get("LEM")
            if root_text is None and lem_text is None:
                records.skipped.append(
                    f"{sura}:{aya}:{word}: head TAG={head.pos_tag} nhưng "
                    "thiếu cả ROOT và LEM — dữ liệu hỏng (case G)"
                )
                continue
            if root_text:
                if root_text not in root_ids:
                    rid = root_alloc.next()
                    root_ids[root_text] = rid
                    records.roots.append(RootRec(id=rid, radicals=root_text))
                root_id = root_ids[root_text]
        else:
            lem_text = head.raw_features.get("LEM", head.form.strip("+"))

        lemma_key = (lem_text, head.pos_tag if head.pos_tag in CONTENT_POS else "_FUNC")
        if lemma_key not in lemma_ids:
            lid = lemma_alloc.next()
            lemma_ids[lemma_key] = lid
            records.lemmas.append(
                LemmaRec(
                    id=lid,
                    arabic=lem_text,
                    pos_tag=head.pos_tag,
                    root_id=root_id,
                    occurrence_count=0,
                )
            )
            lemma_occurrence[lid] = 0
        lemma_id = lemma_ids[lemma_key]

        lex_key = _lexeme_key(lemma_key, head)
        if lex_key not in lexeme_ids:
            xid = lexeme_alloc.next()
            lexeme_ids[lex_key] = xid
            form_pattern = lex_key[1] if len(lex_key) > 1 and lex_key[1] else None
            records.lexemes.append(
                LexemeRec(id=xid, lemma_id=lemma_id, form_pattern=form_pattern)
            )
        lexeme_id = lexeme_ids[lex_key]

        try:
            ayah_id = _ayah_id_for(sura, aya, ayah_counts)
        except KeyError:
            records.skipped.append(f"{sura}:{aya}:{word}: sura {sura} không có trong ayah_counts")
            continue

        wi_id = word_instance_alloc.next()
        full_form = "".join(s.form.strip("+") for s in group)
        records.word_instances.append(
            WordInstanceRec(
                id=wi_id,
                ayah_id=ayah_id,
                lexeme_id=lexeme_id,
                position=word,
                arabic_form=full_form,
            )
        )
        lemma_occurrence[lemma_id] = lemma_occurrence.get(lemma_id, 0) + 1

        for flag in head.flags:
            classified = classify_flag(flag)
            if classified is None:
                records.warnings.append(
                    f"{sura}:{aya}:{word}: mã đặc trưng không nhận diện được: {flag!r}"
                )
                continue
            fkey, fvalue = classified
            records.grammar_features.append(
                GrammarFeatureRec(
                    id=feature_alloc.next(),
                    word_instance_id=wi_id,
                    feature_key=fkey,
                    feature_value=fvalue,
                )
            )

        for seg in rest:
            folded = _fold_non_head(seg)
            if folded is None:
                continue
            fkey, fvalue = folded
            records.grammar_features.append(
                GrammarFeatureRec(
                    id=feature_alloc.next(),
                    word_instance_id=wi_id,
                    feature_key=fkey,
                    feature_value=fvalue,
                )
            )

    for lemma in records.lemmas:
        lemma.occurrence_count = lemma_occurrence.get(lemma.id, 0)

    return records
