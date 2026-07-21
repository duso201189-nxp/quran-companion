// Smoke test dữ liệu THẬT: mở assets/database/quran.sqlite (file do
// tool/build_quran_db.py sinh ra) qua đúng lớp AppDatabase + repository
// của app, đảm bảo danh sách Surah và nội dung đọc hoạt động.
//
// Bỏ qua (skip) nếu asset chưa được build — chạy
// `python tool/build_quran_db.py` trước.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';

void main() {
  final assetFile = File('assets/database/quran.sqlite');

  group(
    'quran.sqlite (asset thật)',
    () {
      late AppDatabase db;
      late QuranRepositoryImpl repo;

      setUpAll(() {
        db = AppDatabase(NativeDatabase(assetFile));
        repo = QuranRepositoryImpl(db, const ConsoleLogger());
      });

      tearDownAll(() async => db.close());

      test('data_version khớp hằng số app', () async {
        expect(await repo.getMetaValue('data_version'), '4');
      });

      test('danh sách Surah: đủ 114, đúng thứ tự, đúng dữ liệu', () async {
        final surahs = await repo.getAllSurahs();
        expect(surahs.length, 114);
        expect(surahs.first.id, 1);
        expect(surahs.first.nameLatin, 'Al-Fatihah');
        expect(surahs.first.ayahCount, 7);
        expect(surahs.last.id, 114);
        expect(surahs.last.ayahCount, 6);
      });

      test('đọc Surah 1: đủ 7 ayah, có văn bản Arabic + bản dịch', () async {
        final ayahs = await repo.getAyahsOfSurah(1);
        expect(ayahs.length, 7);
        for (final a in ayahs) {
          expect(a.ayah.textUthmani, isNotEmpty);
          expect(a.texts, isNotEmpty); // có ít nhất 1 bản dịch/phiên âm
        }
      });

      test('đọc Surah 2 (dài nhất): đủ 286 ayah', () async {
        final ayahs = await repo.getAyahsOfSurah(2);
        expect(ayahs.length, 286);
      });

      test('tổng ayah toàn bộ Qur\'an = 6236', () async {
        final row = await db
            .customSelect('SELECT COUNT(*) AS c FROM ayahs')
            .getSingle();
        expect(row.read<int>('c'), 6236);
      });

      test('nguồn dịch đang bật: có tiếng Việt và tiếng Anh', () async {
        final sources = await repo.getEnabledSources();
        expect(sources.map((s) => s.language), containsAll(['vi', 'en']));
      });

      test('TOÀN BỘ 6236 phiên âm sạch: không thẻ HTML, không AA thô',
          () async {
        for (var surah = 1; surah <= 114; surah++) {
          final ayahs = await repo.getAyahsOfSurah(surah);
          for (final a in ayahs) {
            final t = a.texts['translit_latin'];
            if (t == null) continue;
            expect(
              t.contains('<'),
              isFalse,
              reason: 'Còn thẻ HTML ở $surah:${a.ayah.ayahNumber}: $t',
            );
            expect(
              t.contains('>'),
              isFalse,
              reason: 'Còn thẻ HTML ở $surah:${a.ayah.ayahNumber}: $t',
            );
            expect(
              t.contains('AA'),
              isFalse,
              reason: 'Còn AA thô ở $surah:${a.ayah.ayahNumber}: $t',
            );
          }
        }
      });
    },
    skip: assetFile.existsSync()
        ? false
        : 'assets/database/quran.sqlite chưa build — '
            'chạy tool/build_quran_db.py',
  );
}
