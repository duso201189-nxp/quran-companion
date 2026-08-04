// Sprint BM4 — kiểm chứng Basmalah 2.0 trên DỮ LIỆU THẬT.
//
// Mọi test khác của BM1–BM3 chạy trên fixture do chính chúng dựng, nên
// chúng chứng minh LOGIC đúng chứ chưa chứng minh logic đó gặp đúng dữ
// liệu. Tệp này mở `assets/database/quran.sqlite` và chạy đúng các hàm
// mà màn hình đọc dùng, cho cả 114 Surah.
//
// Bỏ qua (skip) nếu asset chưa được build — cùng quy ước với
// `content_database_smoke_test.dart`.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/quran/data/quran_repository_impl.dart';
import 'package:quran_companion/features/quran/domain/basmalah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/reading_playlist.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_rows.dart';

void main() {
  final assetFile = File('assets/database/quran.sqlite');

  group(
    'BM4 — Basmalah 2.0 trên quran.sqlite (asset thật)',
    () {
      late AppDatabase db;
      late QuranRepositoryImpl repo;

      /// Ayah 1 của từng Surah, lấy một lần cho cả nhóm.
      final firstAyahs = <int, Ayah>{};
      final ayahCounts = <int, int>{};

      setUpAll(() async {
        db = AppDatabase(NativeDatabase(assetFile));
        repo = QuranRepositoryImpl(db, const ConsoleLogger());
        for (final surah in await repo.getAllSurahs()) {
          final ayahs = await repo.getAyahsOfSurah(surah.id);
          firstAyahs[surah.id] = ayahs.first.ayah;
          ayahCounts[surah.id] = ayahs.length;
        }
      });

      tearDownAll(() async => db.close());

      /// Chuỗi này có phải Basmalah không — chấp nhận cả biến thể chính
      /// tả ở Surah 95 & 97 bằng cách bỏ dấu phụ trước khi so.
      bool isBasmalah(String text) {
        String bare(String s) => s.replaceAll(RegExp(r'[ً-ْٰٓ-ٕـ]'), '');
        final reference = bare(
          firstAyahs[2]!.textUthmani.split(' ').take(4).join(' '),
        );
        return bare(text.trim()) == reference;
      }

      test('114 Surah: phần mở đầu phân loại đúng, không sót không thừa', () {
        var prefixes = 0, isFirstAyah = 0, none = 0;

        for (var id = 1; id <= 114; id++) {
          final opening = resolveSurahOpening(
            surahId: id,
            firstAyahText: firstAyahs[id]!.textUthmani,
          );
          switch (opening) {
            case OpeningPrefixesFirstAyah():
              prefixes++;
            case OpeningIsFirstAyah():
              isFirstAyah++;
            case NoOpening():
              none++;
          }
        }

        expect(prefixes, 112);
        expect(isFirstAyah, 1); // Al-Fatihah
        expect(none, 1); // At-Tawbah
      });

      test('mỗi Surah hiển thị ĐÚNG MỘT Basmalah mở đầu (At-Tawbah: không)',
          () {
        for (var id = 1; id <= 114; id++) {
          final first = firstAyahs[id]!;
          final opening = resolveSurahOpening(
            surahId: id,
            firstAyahText: first.textUthmani,
          );

          // Những gì màn hình đọc thật sự vẽ ở đầu Surah:
          // hàng mở đầu (nếu có) + văn bản thẻ Ayah 1.
          final openingRowText =
              opening is OpeningPrefixesFirstAyah ? opening.text : null;
          final ayahOneText = ayahDisplayText(
            surahId: id,
            ayahNumber: 1,
            textUthmani: first.textUthmani,
          );

          final shown = [
            if (openingRowText != null) openingRowText,
            ayahOneText,
          ];
          final basmalahCount = shown.where(isBasmalah).length;

          if (id == 9) {
            expect(basmalahCount, 0, reason: 'At-Tawbah không có Basmalah');
            expect(openingRowText, isNull);
          } else {
            expect(
              basmalahCount,
              1,
              reason: 'Surah $id phải hiện đúng một Basmalah',
            );
          }

          // Và không bao giờ hiện hai lần: nếu có hàng mở đầu thì thẻ
          // Ayah 1 phải đã bỏ phần Basmalah đi.
          if (openingRowText != null) {
            expect(
              isBasmalah(ayahOneText),
              isFalse,
              reason: 'Surah $id: Basmalah bị vẽ hai lần',
            );
            expect(ayahOneText, isNot(contains(openingRowText)));
          }
        }
      });

      test('Al-Fatihah: Basmalah LÀ Ayah 1, không có hàng mở đầu riêng', () {
        final opening = resolveSurahOpening(
          surahId: 1,
          firstAyahText: firstAyahs[1]!.textUthmani,
        );

        expect(opening, isA<OpeningIsFirstAyah>());
        expect(ReadingRows.openingRowFor(opening), isNull);
        expect(ReadingPlaylist.leadingItemsFor(opening), 0);
        // Thẻ Ayah 1 vẫn vẽ nguyên văn Basmalah.
        expect(
          isBasmalah(
            ayahDisplayText(
              surahId: 1,
              ayahNumber: 1,
              textUthmani: firstAyahs[1]!.textUthmani,
            ),
          ),
          isTrue,
        );
      });

      test('At-Tawbah: không Basmalah ở bất kỳ tầng nào', () {
        final opening = resolveSurahOpening(
          surahId: 9,
          firstAyahText: firstAyahs[9]!.textUthmani,
        );

        expect(opening, isA<NoOpening>());
        expect(ReadingRows.openingRowFor(opening), isNull);
        expect(ReadingPlaylist.leadingItemsFor(opening), 0);
        expect(
          ayahDisplayText(
            surahId: 9,
            ayahNumber: 1,
            textUthmani: firstAyahs[9]!.textUthmani,
          ),
          firstAyahs[9]!.textUthmani, // nguyên vẹn
        );
      });

      test('An-Naml 27:30 KHÔNG bị đụng tới — Basmalah ở đó là kinh văn',
          () async {
        final ayahs = await repo.getAyahsOfSurah(27);
        final target = ayahs.firstWhere((a) => a.ayah.ayahNumber == 30).ayah;

        // Câu này chứa Basmalah giữa dòng (thư của Sulayman). Nó KHÔNG
        // phải phần mở đầu, và mọi phép tách chỉ chạm Ayah 1.
        //
        // Chuỗi đối chiếu lấy TỪ DỮ LIỆU (4 token đầu của 2:1), không
        // gõ tay: một literal Ả Rập gõ tay rất dễ khác dữ liệu ở dấu
        // phụ mà nhìn thì y hệt.
        final basmalahFromData =
            firstAyahs[2]!.textUthmani.split(' ').take(4).join(' ');
        expect(target.textUthmani, contains(basmalahFromData));
        expect(
          ayahDisplayText(
            surahId: 27,
            ayahNumber: 30,
            textUthmani: target.textUthmani,
          ),
          target.textUthmani, // không đổi một ký tự
        );
      });

      test('ReadingRows: số hàng khớp số Ayah thật của cả 114 Surah', () {
        for (var id = 1; id <= 114; id++) {
          final opening = resolveSurahOpening(
            surahId: id,
            firstAyahText: firstAyahs[id]!.textUthmani,
          );
          final ayahCount = ayahCounts[id]!;

          expect(
            ReadingRows.rowCountFor(opening: opening, ayahCount: ayahCount),
            ayahCount + (id == 1 || id == 9 ? 1 : 2),
            reason: 'Surah $id',
          );
          // Hàng cuối luôn ứng với Ayah cuối.
          expect(
            ReadingRows.ayahIndexForRow(
              opening: opening,
              row: ReadingRows.lastRowFor(
                opening: opening,
                ayahCount: ayahCount,
              ),
            ),
            ayahCount - 1,
          );
        }
      });

      test('Playlist: độ dài = số Ayah + phần mở đầu, cho cả 114 Surah', () {
        for (var id = 1; id <= 114; id++) {
          final opening = resolveSurahOpening(
            surahId: id,
            firstAyahText: firstAyahs[id]!.textUthmani,
          );
          final expected = ayahCounts[id]! + (id == 1 || id == 9 ? 0 : 1);

          expect(
            ayahCounts[id]! + ReadingPlaylist.leadingItemsFor(opening),
            expected,
            reason: 'Surah $id',
          );
        }
      });

      test('Al-Fatihah: hàng đợi đúng 7, KHÔNG có mục mở đầu thừa', () {
        final opening = resolveSurahOpening(
          surahId: 1,
          firstAyahText: firstAyahs[1]!.textUthmani,
        );

        expect(ayahCounts[1], 7);
        expect(ayahCounts[1]! + ReadingPlaylist.leadingItemsFor(opening), 7);
      });
    },
    skip: assetFile.existsSync()
        ? false
        : 'assets/database/quran.sqlite chưa được build',
  );
}
