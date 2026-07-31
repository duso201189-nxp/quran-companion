"""Pipeline Lexicon (Sprint 12) — Root/Lemma/Lexeme/WordInstance/GrammarFeature.

CHỈ chạy độc lập bằng dữ liệu hình thái học đã tải sẵn (xem
fetch_morphology.py) — KHÔNG tự tải mạng, KHÔNG đụng
assets/database/quran.sqlite. Mỗi module một trách nhiệm (xem
docs/adr — Sprint 12 Phase 2.7):

  segment_parser   text thô (LOCATION/FORM/TAG/FEATURES) -> Segment
  normalizer       list[Segment] -> NormalizedRecords (Root..GrammarFeature)
  pre_build_validator   kiểm NormalizedRecords TRƯỚC khi ghi SQLite
  sqlite_writer    NormalizedRecords -> INSERT vào 1 sqlite3.Connection
  post_build_validator  kiểm sqlite3.Connection SAU khi ghi (SQL thật)
"""
