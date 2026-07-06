import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';

import 'fixtures/content_fixtures.dart';

void main() {
  late AppDatabase db;
  late QuranRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await seedTestContent(db);
    repo = QuranRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('QuranRepository — Surah', () {
    test('getAllSurahs trả về đúng số lượng, sắp theo id', () async {
      final surahs = await repo.getAllSurahs();

      expect(surahs.length, 2);
      expect(surahs.first.id, 1);
      expect(surahs.last.id, 114);
    });

    test('getSurahById ánh xạ đầy đủ trường và enum', () async {
      final surah = await repo.getSurahById(1);

      expect(surah, isNotNull);
      expect(surah!.nameLatin, 'Al-Fatihah');
      expect(surah.nameVi, contains('Khai Đề'));
      expect(surah.ayahCount, 7);
      expect(surah.revelationPlace, RevelationPlace.mecca);
      expect(surah.orderRevealed, 5);
    });

    test('getSurahById với id không tồn tại -> null', () async {
      expect(await repo.getSurahById(999), isNull);
    });
  });

  group('QuranRepository — nguồn văn bản', () {
    test('getEnabledSources: chỉ nguồn bật, đúng thứ tự', () async {
      final sources = await repo.getEnabledSources();

      expect(sources.length, 3);
      expect(
        sources.map((s) => s.code).toList(),
        ['translit_latin', 'vi_main', 'en_sahih'],
      );
      expect(sources.any((s) => s.code == 'tafsir_off'), isFalse);
    });

    test('metadata nguồn (license, url) được ánh xạ', () async {
      final sources = await repo.getEnabledSources();
      final translit =
          sources.singleWhere((s) => s.code == 'translit_latin');

      expect(translit.type, SourceType.transliteration);
      expect(translit.license, 'fixture-license');
      expect(translit.sourceUrl, 'https://example.test');
      expect(translit.updatedAt, '2026-01-01');
    });
  });

  group('QuranRepository — Ayah + văn bản', () {
    test('getAyahsOfSurah: đủ ayah, đúng thứ tự, đủ lớp văn bản',
        () async {
      final ayahs = await repo.getAyahsOfSurah(1);

      expect(ayahs.length, 7);
      expect(
        ayahs.map((a) => a.ayah.ayahNumber).toList(),
        [1, 2, 3, 4, 5, 6, 7],
      );

      final first = ayahs.first;
      expect(first.ayah.textUthmani, contains('نص عربي'));
      expect(first.texts['vi_main'], 'việt 1');
      expect(first.texts['en_sahih'], 'english 1');
      expect(first.texts['translit_latin'], 'translit 1');
    });

    test('nguồn bị tắt KHÔNG xuất hiện trong texts', () async {
      final ayahs = await repo.getAyahsOfSurah(1);

      expect(ayahs.first.texts.containsKey('tafsir_off'), isFalse);
    });

    test('Surah thiếu một số nguồn -> texts chỉ chứa nguồn có dữ liệu',
        () async {
      final ayahs = await repo.getAyahsOfSurah(114);

      expect(ayahs.length, 6);
      expect(ayahs.first.texts['vi_main'], 'việt 114:1');
      expect(ayahs.first.texts.containsKey('en_sahih'), isFalse);
    });

    test('ánh xạ juz/hizb/page/sajdah từ database', () async {
      final ayahs = await repo.getAyahsOfSurah(114);

      expect(ayahs.first.ayah.juz, 30);
      expect(ayahs.first.ayah.hizb, isNotNull);
      expect(ayahs.first.ayah.page, 604);
      expect(ayahs.first.ayah.sajdah, isFalse);
      expect(ayahs.last.ayah.sajdah, isTrue);
    });

    test('surahId không tồn tại -> danh sách rỗng, không lỗi', () async {
      expect(await repo.getAyahsOfSurah(999), isEmpty);
    });
  });

  group('QuranRepository — meta', () {
    test('đọc data_version', () async {
      expect(await repo.getMetaValue('data_version'), '1');
    });

    test('key không tồn tại -> null', () async {
      expect(await repo.getMetaValue('không_có'), isNull);
    });
  });
}
