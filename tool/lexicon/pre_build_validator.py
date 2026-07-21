"""Kiểm NormalizedRecords TRƯỚC khi ghi SQLite (Phase 2.7 §3, "Pre-Build").

Chỉ kiểm trong bộ nhớ (không cần sqlite3) — bắt lỗi ở normalizer.py
CÀNG SỚM CÀNG TỐT, trước khi tới bước ghi file. Không sửa dữ liệu,
chỉ báo cáo — cùng triết lý fail-loud với validate() gốc trong
build_quran_db.py.
"""
from __future__ import annotations

from .normalizer import NormalizedRecords


def validate_records(records: NormalizedRecords) -> list[str]:
    errors: list[str] = []

    root_ids = {r.id for r in records.roots}
    lemma_ids = {lm.id for lm in records.lemmas}
    lexeme_ids = {lx.id for lx in records.lexemes}
    word_instance_ids = {wi.id for wi in records.word_instances}

    for r in records.roots:
        if not r.radicals.strip():
            errors.append(f"Root id={r.id}: radicals rỗng")

    for lm in records.lemmas:
        if not lm.arabic.strip():
            errors.append(f"Lemma id={lm.id}: arabic rỗng")
        if lm.root_id is not None and lm.root_id not in root_ids:
            errors.append(f"Lemma id={lm.id}: root_id={lm.root_id} không tồn tại")
        if lm.occurrence_count < 0:
            errors.append(f"Lemma id={lm.id}: occurrence_count âm")

    for lx in records.lexemes:
        if lx.lemma_id not in lemma_ids:
            errors.append(f"Lexeme id={lx.id}: lemma_id={lx.lemma_id} không tồn tại")

    seen_positions: set[tuple[int, int]] = set()
    for wi in records.word_instances:
        if wi.lexeme_id not in lexeme_ids:
            errors.append(f"WordInstance id={wi.id}: lexeme_id={wi.lexeme_id} không tồn tại")
        if not wi.arabic_form.strip():
            errors.append(f"WordInstance id={wi.id}: arabic_form rỗng")
        key = (wi.ayah_id, wi.position)
        if key in seen_positions:
            errors.append(
                f"WordInstance id={wi.id}: trùng (ayah_id={wi.ayah_id}, "
                f"position={wi.position}) với 1 WordInstance khác"
            )
        seen_positions.add(key)

    for gf in records.grammar_features:
        if gf.word_instance_id not in word_instance_ids:
            errors.append(
                f"GrammarFeature id={gf.id}: word_instance_id={gf.word_instance_id} "
                "không tồn tại"
            )
        if not gf.feature_key or not gf.feature_value:
            errors.append(f"GrammarFeature id={gf.id}: feature_key/feature_value rỗng")

    computed_occurrence: dict[int, int] = {}
    for wi in records.word_instances:
        lexeme = next((lx for lx in records.lexemes if lx.id == wi.lexeme_id), None)
        if lexeme is None:
            continue
        computed_occurrence[lexeme.lemma_id] = computed_occurrence.get(lexeme.lemma_id, 0) + 1
    for lm in records.lemmas:
        expected = computed_occurrence.get(lm.id, 0)
        if lm.occurrence_count != expected:
            errors.append(
                f"Lemma id={lm.id}: occurrence_count={lm.occurrence_count} "
                f"nhưng đếm thực tế={expected}"
            )

    return errors
