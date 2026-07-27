// Sprint 2.1 — kiểm chứng chuẩn hóa phiên âm trên TOÀN BỘ Qur'an:
// 1. Từng ayah trong database khớp đúng dataset chuẩn
//    (tool/data/transliteration.json — Quran.com word-by-word).
// 2. TransliterationRepository.normalize là identity trên dữ liệu
//    chuẩn (không phá gạch nối 'l-lāhi', dấu ' trong "bis'mi").
// 3. Không HTML, không khoảng trắng lỗi, bộ ký tự trong whitelist.

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';
import 'package:quran_companion/features/quran/data/transliteration_repository.dart';

void main() {
  final assetFile = File('assets/database/quran.sqlite');
  final datasetFile = File('tool/data/transliteration.json');
  final ready = assetFile.existsSync() && datasetFile.existsSync();

  group(
    'chuẩn hóa phiên âm (toàn bộ 6236 ayah)',
    () {
      late AppDatabase db;
      late QuranRepositoryImpl repo;
      late Map<String, dynamic> dataset;

      setUpAll(() {
        db = AppDatabase(NativeDatabase(assetFile));
        repo = QuranRepositoryImpl(db, const ConsoleLogger());
        dataset = (jsonDecode(datasetFile.readAsStringSync())
            as Map<String, dynamic>)['ayahs'] as Map<String, dynamic>;
      });

      tearDownAll(() async => db.close());

      test('database khớp dataset chuẩn từng ayah một', () async {
        expect(dataset.length, 6236);
        var checked = 0;
        for (var surah = 1; surah <= 114; surah++) {
          final ayahs = await repo.getAyahsOfSurah(surah);
          for (final a in ayahs) {
            final key = '$surah:${a.ayah.ayahNumber}';
            final fromDb = a.texts['translit_latin'];
            expect(fromDb, dataset[key], reason: 'lệch tại $key');
            checked++;
          }
        }
        expect(checked, 6236);
      });

      test('normalize là identity trên dataset chuẩn', () {
        const translit = TransliterationRepository();
        for (final entry in dataset.entries) {
          final v = entry.value as String;
          expect(
            translit.normalize(v),
            v,
            reason: 'normalize làm đổi ${entry.key}',
          );
        }
      });

      test(
          'định dạng sạch: không HTML/AA, không lỗi khoảng trắng, '
          'ký tự trong whitelist', () {
        // A hoa duy nhất được phép: danh xưng Allāh.
        final whitelist = RegExp(
          r'^[a-zAʾʿāīūḥṣḍṭẓ\- ]+$',
        );
        for (final entry in dataset.entries) {
          final v = entry.value as String;
          expect(v.contains('<'), isFalse, reason: entry.key);
          expect(v.contains('AA'), isFalse, reason: entry.key);
          expect(v.contains('  '), isFalse, reason: entry.key);
          expect(v.trim(), v, reason: entry.key);
          expect(
            whitelist.hasMatch(v),
            isTrue,
            reason: '${entry.key} có ký tự ngoài chuẩn: $v',
          );
        }
      });

      test(
          'quy tắc biên tập: không dấu \' ASCII, không nguyên âm dài '
          'lặp (aa/āa/īi/ūu...), A hoa chỉ trong Allāh', () {
        final doubled = RegExp('(āa|aā|aa|īi|iī|ii|ūu|uū|uu)');
        for (final entry in dataset.entries) {
          final v = entry.value as String;
          expect(
            v.contains("'"),
            isFalse,
            reason: '${entry.key} còn dấu nháy ASCII: $v',
          );
          expect(
            doubled.hasMatch(v),
            isFalse,
            reason: '${entry.key} còn nguyên âm lặp: $v',
          );
          for (final w in v.split(' ')) {
            if (w.contains('A')) {
              expect(
                w.contains('Allāh'),
                isTrue,
                reason: '${entry.key}: A hoa ngoài Allāh: $w',
              );
            }
          }
        }
      });
    },
    skip: ready
        ? false
        : 'cần assets/database/quran.sqlite + tool/data/transliteration.json '
            '(chạy tool/fetch_transliteration.py rồi tool/build_quran_db.py)',
  );
}
