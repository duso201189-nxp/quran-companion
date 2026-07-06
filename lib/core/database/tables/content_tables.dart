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
