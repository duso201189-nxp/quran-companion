import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/quran/data/fts_query.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';
import 'package:quran_companion/shared/utils/highlight.dart';

void main() {
  group('ftsMatchExpression', () {
    test('Latin: bỏ dấu + prefix', () {
      expect(ftsMatchExpression('Nhân từ'), '"nhan"* "tu"*');
      expect(ftsMatchExpression('  mercy  '), '"mercy"*');
    });

    test('Ả Rập: bỏ harakat + biến thể alef wasla', () {
      expect(
        ftsMatchExpression('الرحمن'),
        '("الرحمن"*) OR ("ٱلرحمن"*)',
      );
      expect(ftsMatchExpression('رحمن'), '"رحمن"*');
    });

    test('query rỗng/ký tự đặc biệt -> null hoặc sạch', () {
      expect(ftsMatchExpression('   '), isNull);
      expect(ftsMatchExpression('"*'), isNull);
    });
  });

  group('highlightSpans', () {
    const style = TextStyle(fontWeight: FontWeight.bold);

    test('khớp tiếng Việt không dấu (từng từ)', () {
      final spans =
          highlightSpans('Nhân danh Allah', 'nhan danh', highlightStyle: style);
      final marked =
          spans.where((s) => s.style == style).map((s) => s.text).toList();
      expect(marked, ['Nhân', 'danh']);
      expect(spans.last.text, ' Allah');
    });

    test('khớp Ả Rập bỏ tashkeel (vùng tô gồm cả harakat)', () {
      const arabic = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ';
      final spans = highlightSpans(arabic, 'الرحمن', highlightStyle: style);
      final marked =
          spans.where((s) => s.style == style).map((s) => s.text).toList();
      expect(marked, isNotEmpty);
      expect(marked.single, 'ٱلرَّحْمَٰنِ');
    });

    test('không khớp -> một span nguyên văn', () {
      final spans = highlightSpans('abc', 'xyz', highlightStyle: style);
      expect(spans.single.text, 'abc');
      expect(spans.single.style, isNull);
    });
  });

  group(
    'searchAyahs (asset thật)',
    () {
      final assetFile = File('assets/database/quran.sqlite');
      late AppDatabase db;
      late QuranRepositoryImpl repo;

      setUpAll(() {
        db = AppDatabase(NativeDatabase(assetFile));
        repo = QuranRepositoryImpl(db, const ConsoleLogger());
      });

      tearDownAll(() async => db.close());

      test('tiếng Việt có dấu lẫn không dấu ra cùng kết quả', () async {
        final withMarks = await repo.searchAyahs('Nhân danh Allah');
        final without = await repo.searchAyahs('nhan danh allah');
        expect(withMarks, isNotEmpty);
        expect(
          withMarks.map((r) => r.ayahId),
          equals(without.map((r) => r.ayahId)),
        );
        expect(withMarks.first.ayahId, 1); // 1:1 Bismillah
      });

      test('Ả Rập gõ alef thường vẫn khớp alef wasla', () async {
        final results = await repo.searchAyahs('الرحمن');
        expect(results, isNotEmpty);
        expect(results.first.surahNameLatin, isNotEmpty);
      });

      test('tiếng Anh', () async {
        final results = await repo.searchAyahs('mercy', limit: 10);
        expect(results, isNotEmpty);
        expect(results.length, lessThanOrEqualTo(10));
      });

      test('thứ tự Mushaf (ayah_id tăng dần)', () async {
        final results = await repo.searchAyahs('Allah', limit: 30);
        final ids = results.map((r) => r.ayahId).toList();
        expect(ids, orderedEquals([...ids]..sort()));
      });
    },
    skip: File('assets/database/quran.sqlite').existsSync()
        ? false
        : 'assets/database/quran.sqlite chưa build — '
            'chạy tool/build_quran_db.py',
  );
}
