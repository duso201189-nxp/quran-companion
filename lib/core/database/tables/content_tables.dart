import 'package:drift/drift.dart';

/// Bảng nhóm A — nội dung Qur'an tĩnh, CHỈ ĐỌC.
///
/// Mọi tên bảng/cột được khai báo TƯỜNG MINH (named/tableName) để
/// khớp 100% với schema do tool/build_quran_db.py sinh ra —
/// không phụ thuộc quy tắc đặt tên ngầm của Drift.

@DataClassName('SurahRow')
class Surahs extends Table {
  @override
  String get tableName => 'surahs';

  /// 1..114
  IntColumn get id => integer()();
  TextColumn get nameArabic => text().named('name_arabic')();
  TextColumn get nameLatin => text().named('name_latin')();
  TextColumn get nameVi => text().named('name_vi')();
  TextColumn get nameEn => text().named('name_en')();
  IntColumn get ayahCount => integer().named('ayah_count')();

  /// 'mecca' | 'madinah'
  TextColumn get revelationPlace => text().named('revelation_place')();
  IntColumn get orderRevealed => integer().named('order_revealed')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AyahRow')
class Ayahs extends Table {
  @override
  String get tableName => 'ayahs';

  /// Đánh số toàn cục 1..6236.
  IntColumn get id => integer()();
  IntColumn get surahId => integer().named('surah_id').references(
        Surahs,
        #id,
      )();

  /// Số Ayah trong Surah.
  IntColumn get ayahNumber => integer().named('ayah_number')();
  TextColumn get textUthmani => text().named('text_uthmani')();
  IntColumn get juz => integer().nullable()();
  IntColumn get hizb => integer().nullable()();
  IntColumn get page => integer().nullable()();

  /// Ayah có vị trí quỳ lạy (sajdah tilawah) hay không.
  BoolColumn get sajdah => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TranslationSourceRow')
class TranslationSources extends Table {
  @override
  String get tableName => 'translation_sources';

  IntColumn get id => integer()();

  /// Định danh ổn định: 'vi_main', 'en_sahih', 'translit_latin'...
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get author => text().nullable()();

  /// 'translation' | 'transliteration' | 'tafsir'
  TextColumn get type => text()();
  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();
  IntColumn get displayOrder =>
      integer().named('display_order').withDefault(const Constant(0))();

  // --- Metadata nguồn (bắt buộc cho mọi nguồn dữ liệu) ---
  /// Giấy phép sử dụng (vd: 'Tanzil terms', 'CC BY-ND'...).
  TextColumn get license => text().nullable()();

  /// URL gốc của nguồn.
  TextColumn get sourceUrl => text().named('source_url').nullable()();

  /// Phiên bản nguồn (nếu nguồn công bố).
  TextColumn get version => text().nullable()();

  /// Ngày import (ISO 8601).
  TextColumn get updatedAt => text().named('updated_at').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TranslationRow')
class Translations extends Table {
  @override
  String get tableName => 'translations';

  IntColumn get sourceId => integer().named('source_id').references(
        TranslationSources,
        #id,
      )();
  IntColumn get ayahId => integer().named('ayah_id').references(
        Ayahs,
        #id,
      )();

  /// Getter không thể tên `text` (trùng hàm builder của Drift)
  /// nên đặt `content`, ánh xạ sang cột SQL 'text'.
  TextColumn get content => text().named('text')();

  @override
  Set<Column<Object>> get primaryKey => {sourceId, ayahId};
}

@DataClassName('ReciterRow')
class Reciters extends Table {
  @override
  String get tableName => 'reciters';

  IntColumn get id => integer()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get nameArabic => text().named('name_arabic').nullable()();

  /// Mẫu URL audio, vd:
  /// https://everyayah.com/data/Alafasy_128kbps/{sss}{aaa}.mp3
  TextColumn get audioUrlTemplate => text().named('audio_url_template')();
  IntColumn get bitrateKbps => integer().named('bitrate_kbps').nullable()();
  TextColumn get license => text().nullable()();
  TextColumn get sourceUrl => text().named('source_url').nullable()();
  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();
  IntColumn get displayOrder =>
      integer().named('display_order').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MetaRow')
class MetaEntries extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

// ============================================================
// Lexicon (Sprint 12 — Phase 0.1/1/2). Phân cấp
// Root -> Lemma -> Lexeme -> WordInstance, GrammarFeature/Phrase là
// mục ngang hàng (không phải hậu duệ), LexiconRelation là quan hệ
// giữa 2 Lemma (không phải bảng nội dung).
//
// LƯU Ý QUAN TRỌNG: các bảng dưới đây khai báo TRƯỚC khi
// tool/build_quran_db.py sinh dữ liệu thật cho chúng — cùng tình
// trạng lemmas/word_instances đã ghi trong DATABASE.md từ Sprint 9.
// Test dùng NativeDatabase.memory() (onCreate chạy thật, xem doc
// AppDatabase ở trên) nên PASS bình thường; bản đóng gói thật
// (assets/database/quran.sqlite) CHƯA có các bảng này — mọi truy vấn
// qua LexiconRepositoryImpl sẽ lỗi "no such table" cho tới khi một
// giai đoạn data-pipeline riêng (chưa lên kế hoạch) build dữ liệu
// thật. Xem TODO.md.
// ============================================================

@DataClassName('RootRow')
class Roots extends Table {
  @override
  String get tableName => 'roots';

  IntColumn get id => integer()();

  /// Các phụ âm gốc, vd 'ك ت ب'.
  TextColumn get radicals => text()();
  TextColumn get meaningCore => text().named('meaning_core').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LemmaRow')
class Lemmas extends Table {
  @override
  String get tableName => 'lemmas';

  IntColumn get id => integer()();
  TextColumn get arabic => text()();
  TextColumn get transliteration => text().nullable()();
  TextColumn get posTag => text().named('pos_tag').nullable()();
  TextColumn get meaningVi => text().named('meaning_vi').nullable()();
  TextColumn get meaningEn => text().named('meaning_en').nullable()();
  TextColumn get explanationVi => text().named('explanation_vi').nullable()();
  IntColumn get rootId =>
      integer().named('root_id').nullable().references(Roots, #id)();
  IntColumn get occurrenceCount =>
      integer().named('occurrence_count').withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LexemeRow')
class Lexemes extends Table {
  @override
  String get tableName => 'lexemes';

  IntColumn get id => integer()();
  IntColumn get lemmaId =>
      integer().named('lemma_id').references(Lemmas, #id)();

  /// Khuôn/thể phái sinh, vd 'Form I'.
  TextColumn get formPattern => text().named('form_pattern').nullable()();
  TextColumn get partOfSpeechDetail =>
      text().named('part_of_speech_detail').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('WordInstanceRow')
class WordInstances extends Table {
  @override
  String get tableName => 'word_instances';

  IntColumn get id => integer()();
  IntColumn get ayahId => integer().named('ayah_id').references(Ayahs, #id)();
  IntColumn get lexemeId =>
      integer().named('lexeme_id').references(Lexemes, #id)();

  /// Vị trí từ trong Ayah (1-based).
  IntColumn get position => integer()();

  /// Dạng chữ Ả Rập thực tế xuất hiện (đã biến đổi), khác
  /// Lemmas.arabic (dạng đầu mục từ điển).
  TextColumn get arabicForm => text().named('arabic_form')();
  TextColumn get transliteration => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('GrammarFeatureRow')
class GrammarFeatures extends Table {
  @override
  String get tableName => 'grammar_features';

  IntColumn get id => integer()();
  IntColumn get wordInstanceId =>
      integer().named('word_instance_id').references(WordInstances, #id)();

  /// vd 'tense', 'person', 'case', 'gender', 'number'.
  TextColumn get featureKey => text().named('feature_key')();

  /// vd 'past', '3rd', 'nominative', 'masculine'.
  TextColumn get featureValue => text().named('feature_value')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PhraseRow')
class Phrases extends Table {
  @override
  String get tableName => 'phrases';

  IntColumn get id => integer()();
  TextColumn get arabic => text()();
  TextColumn get transliteration => text().nullable()();
  TextColumn get meaningVi => text().named('meaning_vi').nullable()();
  TextColumn get meaningEn => text().named('meaning_en').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Bảng nối Phrase <-> WordInstance, có thứ tự — Phrase.wordInstanceIds
/// (domain) tái dựng từ đây, sắp theo [position]. Dùng bảng nối quan
/// hệ thay vì cột danh sách tuần tự hoá (JSON) — đúng tiền lệ đã có
/// trong file này (Highlights lưu mỗi màu 1 dòng, không tuần tự hoá
/// mảng màu).
@DataClassName('PhraseWordInstanceRow')
class PhraseWordInstances extends Table {
  @override
  String get tableName => 'phrase_word_instances';

  IntColumn get phraseId =>
      integer().named('phrase_id').references(Phrases, #id)();
  IntColumn get wordInstanceId =>
      integer().named('word_instance_id').references(WordInstances, #id)();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {phraseId, wordInstanceId};
}

/// Quan hệ NGỮ NGHĨA giữa 2 Lemma (đồng nghĩa/trái nghĩa) — không
/// phải bảng nội dung độc lập, xem domain LexiconRelation.
@DataClassName('LexiconRelationRow')
class LexiconRelations extends Table {
  @override
  String get tableName => 'lexicon_relations';

  IntColumn get id => integer()();

  // 2 FK cùng trỏ tới Lemmas — @ReferenceName phân biệt 2 quan hệ
  // ngược riêng (Drift không tự đoán được nếu để trùng tên).
  @ReferenceName('relationsAsSource')
  IntColumn get fromLemmaId =>
      integer().named('from_lemma_id').references(Lemmas, #id)();
  @ReferenceName('relationsAsTarget')
  IntColumn get toLemmaId =>
      integer().named('to_lemma_id').references(Lemmas, #id)();

  /// 'synonym' | 'antonym'.
  TextColumn get relationType => text().named('relation_type')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
