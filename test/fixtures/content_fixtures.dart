import 'package:quran_companion/core/database/app_database.dart';

/// Dữ liệu mẫu CHỈ DÙNG CHO TEST (in-memory database).
///
/// Văn bản dịch là chuỗi fixture tự đặt — KHÔNG phải bản dịch thật
/// (bản thật có giấy phép riêng, đi vào app qua pipeline
/// tool/build_quran_db.py chứ không nằm trong source).
/// Test kiểm chứng LOGIC truy vấn, không kiểm chứng nội dung.
Future<void> seedTestContent(AppDatabase db) async {
  await db.batch((b) {
    b.insertAll(db.surahs, [
      const SurahRow(
        id: 1,
        nameArabic: 'الفاتحة',
        nameLatin: 'Al-Fatihah',
        nameVi: 'Al-Fatihah (Khai Đề)',
        nameEn: 'The Opening',
        ayahCount: 7,
        revelationPlace: 'mecca',
        orderRevealed: 5,
      ),
      const SurahRow(
        id: 114,
        nameArabic: 'الناس',
        nameLatin: 'An-Nas',
        nameVi: 'An-Nas (Nhân Loại)',
        nameEn: 'Mankind',
        ayahCount: 6,
        revelationPlace: 'mecca',
        orderRevealed: 21,
      ),
    ]);

    b.insertAll(db.ayahs, [
      for (var n = 1; n <= 7; n++)
        AyahRow(
          id: n,
          surahId: 1,
          ayahNumber: n,
          textUthmani: '(fixture) نص عربي $n',
          juz: 1,
          hizb: 1,
          page: 1,
          sajdah: false,
        ),
      for (var n = 1; n <= 6; n++)
        AyahRow(
          id: 6230 + n,
          surahId: 114,
          ayahNumber: n,
          textUthmani: '(fixture) نص عربي ١١٤:$n',
          juz: 30,
          hizb: 60,
          page: 604,
          // fixture: đánh dấu ayah cuối là sajdah để test ánh xạ cờ
          sajdah: n == 6,
        ),
    ]);

    b.insertAll(db.translationSources, [
      const TranslationSourceRow(
        id: 1,
        code: 'translit_latin',
        name: 'Phiên âm Latin',
        language: 'en',
        author: 'Fixture',
        type: 'transliteration',
        isEnabled: true,
        displayOrder: 1,
        license: 'fixture-license',
        sourceUrl: 'https://example.test',
        version: null,
        updatedAt: '2026-01-01',
      ),
      const TranslationSourceRow(
        id: 2,
        code: 'vi_main',
        name: 'Bản dịch tiếng Việt (fixture)',
        language: 'vi',
        author: 'Fixture',
        type: 'translation',
        isEnabled: true,
        displayOrder: 2,
        license: null,
        sourceUrl: null,
        version: null,
        updatedAt: null,
      ),
      const TranslationSourceRow(
        id: 3,
        code: 'en_sahih',
        name: 'English (fixture)',
        language: 'en',
        author: 'Fixture',
        type: 'translation',
        isEnabled: true,
        displayOrder: 3,
        license: null,
        sourceUrl: null,
        version: null,
        updatedAt: null,
      ),
      const TranslationSourceRow(
        id: 4,
        code: 'tafsir_off',
        name: 'Tafsir đang tắt (fixture)',
        language: 'vi',
        author: 'Fixture',
        type: 'tafsir',
        isEnabled: false,
        displayOrder: 4,
        license: null,
        sourceUrl: null,
        version: null,
        updatedAt: null,
      ),
    ]);

    b.insertAll(db.translations, [
      for (var n = 1; n <= 7; n++) ...[
        TranslationRow(
          sourceId: 1,
          ayahId: n,
          content: 'translit $n',
        ),
        TranslationRow(sourceId: 2, ayahId: n, content: 'việt $n'),
        TranslationRow(sourceId: 3, ayahId: n, content: 'english $n'),
        // nguồn 4 (tắt) vẫn có dữ liệu — để test bộ lọc is_enabled
        TranslationRow(sourceId: 4, ayahId: n, content: 'tafsir $n'),
      ],
      // Surah 114 chỉ có bản Việt — test trường hợp nguồn thiếu ayah
      for (var n = 1; n <= 6; n++)
        TranslationRow(
          sourceId: 2,
          ayahId: 6230 + n,
          content: 'việt 114:$n',
        ),
    ]);

    b.insertAll(db.metaEntries, [
      const MetaRow(key: 'data_version', value: '1'),
      const MetaRow(key: 'built_at', value: '2026-01-01'),
    ]);
  });
}
