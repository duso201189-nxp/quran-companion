"""Kiểm 1 sqlite3.Connection THẬT sau khi đã ghi bảng Lexicon (Phase
2.7 §3, "Post-Build") — cùng phong cách validate() gốc trong
build_quran_db.py: đếm bằng SQL thật, fail-loud, báo đủ mọi lỗi 1 lần.

Khác pre_build_validator (kiểm cấu trúc Python trong bộ nhớ):
module này kiểm DỮ LIỆU ĐÃ NẰM TRONG FILE SQLITE thật, bao gồm cả
PRAGMA foreign_key_check — bắt được lỗi mà pre-build không thấy được
(vd lỗi ghi/kiểu dữ liệu SQLite tự ép kiểu âm thầm).
"""
from __future__ import annotations

import sqlite3


def validate_lexicon_tables(
    conn: sqlite3.Connection,
    expected_word_count: int | None = None,
) -> list[str]:
    cur = conn.cursor()
    errors: list[str] = []

    fk = cur.execute("PRAGMA foreign_key_check").fetchall()
    if fk:
        errors.append(f"vi phạm foreign key (bảng Lexicon): {fk[:5]}...")

    n = cur.execute("SELECT COUNT(*) FROM roots WHERE TRIM(radicals) = ''").fetchone()[0]
    if n:
        errors.append(f"{n} Root có radicals rỗng")

    n = cur.execute("SELECT COUNT(*) FROM lemmas WHERE TRIM(arabic) = ''").fetchone()[0]
    if n:
        errors.append(f"{n} Lemma có arabic rỗng")

    n = cur.execute(
        "SELECT COUNT(*) FROM word_instances WHERE TRIM(arabic_form) = ''"
    ).fetchone()[0]
    if n:
        errors.append(f"{n} WordInstance có arabic_form rỗng")

    dup = cur.execute(
        "SELECT ayah_id, position, COUNT(*) c FROM word_instances "
        "GROUP BY ayah_id, position HAVING c > 1"
    ).fetchall()
    if dup:
        errors.append(f"{len(dup)} cặp (ayah_id, position) bị trùng WordInstance")

    bad = cur.execute(
        "SELECT lm.id FROM lemmas lm WHERE lm.occurrence_count != ("
        "  SELECT COUNT(*) FROM word_instances wi "
        "  JOIN lexemes lx ON lx.id = wi.lexeme_id WHERE lx.lemma_id = lm.id)"
    ).fetchall()
    if bad:
        errors.append(f"{len(bad)} Lemma có occurrence_count không khớp số WordInstance thực tế")

    if expected_word_count is not None:
        n = cur.execute("SELECT COUNT(*) FROM word_instances").fetchone()[0]
        if n != expected_word_count:
            errors.append(
                f"tổng WordInstance = {n}, mong đợi {expected_word_count} "
                "(đối chiếu tool/data/transliteration_words.json)"
            )

    bad = cur.execute(
        "SELECT id FROM lexicon_relations WHERE relation_type NOT IN ('synonym', 'antonym')"
    ).fetchall()
    if bad:
        errors.append(f"{len(bad)} LexiconRelation có relation_type ngoài synonym/antonym")

    # Thứ tự PhraseWordInstances phải liên tục 1..n cho mỗi Phrase
    # (LexiconRepositoryImpl._phraseFromRow dựa vào điều này).
    phrase_ids = [r[0] for r in cur.execute("SELECT id FROM phrases").fetchall()]
    for pid in phrase_ids:
        positions = [
            r[0]
            for r in cur.execute(
                "SELECT position FROM phrase_word_instances "
                "WHERE phrase_id = ? ORDER BY position",
                (pid,),
            ).fetchall()
        ]
        if positions != list(range(1, len(positions) + 1)):
            errors.append(f"Phrase id={pid}: position không liên tục 1..n: {positions}")

    return errors
