// Tên 114 Surah — MỘT chuẩn duy nhất (Quran.com name_simple),
// hiển thị đồng nhất ở mọi màn hình vì mọi nơi đều đọc
// surahs.name_latin từ database (không hardcode).

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';

void main() {
  final assetFile = File('assets/database/quran.sqlite');
  final namesFile = File('tool/data/surah_names.json');
  final ready = assetFile.existsSync() && namesFile.existsSync();

  group(
    'tên Surah chuẩn hóa',
    () {
      late AppDatabase db;
      late QuranRepositoryImpl repo;

      setUpAll(() {
        db = AppDatabase(NativeDatabase(assetFile));
        repo = QuranRepositoryImpl(db);
      });

      tearDownAll(() async => db.close());

      test('database khớp dataset Quran.com cho cả 114 tên', () async {
        final names = (jsonDecode(namesFile.readAsStringSync())
            as Map<String, dynamic>)['names'] as Map<String, dynamic>;
        final surahs = await repo.getAllSurahs();
        expect(surahs.length, 114);
        for (final s in surahs) {
          final expected = (names['${s.id}'] as Map<String, dynamic>)['latin'];
          expect(s.nameLatin, expected, reason: 'Surah ${s.id}');
        }
      });

      test('các tên mốc đúng chuẩn quen thuộc', () async {
        final surahs = await repo.getAllSurahs();
        final byId = {for (final s in surahs) s.id: s.nameLatin};
        expect(byId[1], 'Al-Fatihah');
        expect(byId[2], 'Al-Baqarah');
        expect(byId[3], "Ali 'Imran");
        expect(byId[36], 'Ya-Sin');
        expect(byId[55], 'Ar-Rahman');
        expect(byId[56], "Al-Waqi'ah");
        expect(byId[114], 'An-Nas');
      });

      test('không còn dạng cũ kiểu Tanzil (Faatiha, Baqara, Naas)', () async {
        final surahs = await repo.getAllSurahs();
        const legacy = ['Faatiha', 'Baqara ', 'Naas', 'Aal-i', 'Maaida'];
        for (final s in surahs) {
          for (final old in legacy) {
            expect(
              s.nameLatin.contains(old),
              isFalse,
              reason: 'Surah ${s.id}: ${s.nameLatin}',
            );
          }
        }
      });
    },
    skip: ready
        ? false
        : 'cần assets/database/quran.sqlite + tool/data/surah_names.json '
            '(chạy tool/fetch_surah_names.py rồi tool/build_quran_db.py)',
  );
}
