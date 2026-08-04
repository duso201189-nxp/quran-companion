// Sprint SF2 (Tier 0) — đối chiếu bảng hằng với DỮ LIỆU THẬT.
//
// `AyahOrdinal.ayahCounts` chép lại `surahs.ayah_count` để phép quy đổi
// thuần được (không cần database). Cái giá của việc chép là bảng hằng
// có thể TRÔI khỏi dữ liệu mà không ai biết — và nếu trôi thì mọi
// `ayah_id` đã lưu sẽ trỏ lặng lẽ sang Ayah khác.
//
// Tệp này là cái chốt chặn đó: nó mở `assets/database/quran.sqlite` và
// so từng con số, rồi so cả phép quy đổi trên toàn bộ 6236 dòng thật.
//
// Bỏ qua (skip) nếu asset chưa được build — cùng quy ước với
// `content_database_smoke_test.dart`.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/core/quran/ayah_ordinal.dart';
import 'package:quran_companion/core/quran/quran_address.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';

void main() {
  final assetFile = File('assets/database/quran.sqlite');

  group(
    'SF2 — AyahOrdinal đối chiếu quran.sqlite (asset thật)',
    () {
      late AppDatabase db;
      late QuranRepositoryImpl repo;

      /// `ayah_id` thật -> `(surah, ayah_number)` thật, lấy từ database.
      final truth = <int, QuranAddress>{};

      setUpAll(() async {
        db = AppDatabase(NativeDatabase(assetFile));
        repo = QuranRepositoryImpl(db, const ConsoleLogger());
        for (final surah in await repo.getAllSurahs()) {
          for (final content in await repo.getAyahsOfSurah(surah.id)) {
            truth[content.ayah.id] = QuranAddress.ayah(
              content.ayah.surahId,
              content.ayah.ayahNumber,
            );
          }
        }
      });

      tearDownAll(() async => db.close());

      test('bảng hằng khớp TỪNG số với surahs.ayah_count', () async {
        final surahs = await repo.getAllSurahs();

        expect(surahs, hasLength(AyahOrdinal.ayahCounts.length));
        for (final surah in surahs) {
          expect(
            AyahOrdinal.ayahCounts[surah.id - 1],
            surah.ayahCount,
            reason: 'Surah ${surah.id} (${surah.nameLatin}) lệch số Ayah',
          );
        }
      });

      test('tổng số Ayah thật khớp totalAyahs', () {
        expect(truth, hasLength(AyahOrdinal.totalAyahs));
      });

      test('ayah_id thật -> địa chỉ đúng, cả 6236 dòng', () {
        for (final entry in truth.entries) {
          expect(
            AyahOrdinal.tryFromOrdinal(entry.key),
            entry.value,
            reason: 'ayah_id ${entry.key} phải là ${entry.value}',
          );
        }
      });

      test('địa chỉ thật -> ayah_id đúng, cả 6236 dòng', () {
        for (final entry in truth.entries) {
          expect(
            AyahOrdinal.tryToOrdinal(entry.value),
            entry.key,
            reason: '${entry.value} phải là ayah_id ${entry.key}',
          );
        }
      });

      test('ayah_id thật dày đặc 1..6236 — tiền đề của song ánh', () {
        // Nếu database có lỗ hoặc id không bắt đầu từ 1 thì phép quy
        // đổi bằng cách trừ dần sẽ sai, dù bảng hằng vẫn đúng.
        final ids = truth.keys.toList()..sort();
        expect(ids.first, 1);
        expect(ids.last, AyahOrdinal.totalAyahs);
        expect(ids, hasLength(AyahOrdinal.totalAyahs));
      });

      test('ORDER BY ayah_id == thứ tự đọc — thứ tự tìm kiếm không đổi', () {
        // `quran_repository_impl` sắp kết quả FTS bằng `ORDER BY
        // ayah_id`. Nếu hai thứ tự khác nhau, đổi định danh sẽ đổi thứ
        // tự kết quả người dùng nhìn thấy.
        final byOrdinal = truth.keys.toList()..sort();
        final byAddress = truth.keys.toList()
          ..sort((a, b) => truth[a]!.compareTo(truth[b]!));

        expect(byAddress, byOrdinal);
      });
    },
    skip: assetFile.existsSync()
        ? false
        : 'assets/database/quran.sqlite chưa được build',
  );
}
