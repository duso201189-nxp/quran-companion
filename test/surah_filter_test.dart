import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_controller.dart';
import 'package:quran_companion/shared/utils/text_folding.dart';

Surah _surah(
  int id,
  String latin,
  String vi,
  RevelationPlace place, {
  String arabic = '',
  String en = '',
}) =>
    Surah(
      id: id,
      nameArabic: arabic,
      nameLatin: latin,
      nameVi: vi,
      nameEn: en,
      ayahCount: 7,
      revelationPlace: place,
      orderRevealed: id,
    );

void main() {
  final surahs = [
    _surah(1, 'Al-Fatihah', 'Khai Đề', RevelationPlace.mecca,
        arabic: 'الفاتحة', en: 'The Opening'),
    _surah(2, 'Al-Baqarah', 'Con Bò Cái', RevelationPlace.madinah,
        arabic: 'البقرة', en: 'The Cow'),
    _surah(114, 'An-Nas', 'Nhân Loại', RevelationPlace.mecca,
        arabic: 'الناس', en: 'Mankind'),
  ];

  group('foldDiacritics', () {
    test('bỏ dấu tiếng Việt đầy đủ', () {
      expect(foldDiacritics('Khai Đề'), 'khai de');
      expect(foldDiacritics('Nhân Loại'), 'nhan loai');
      expect(foldDiacritics('Con Bò Cái'), 'con bo cai');
    });

    test('bỏ dấu transliteration Ả Rập', () {
      expect(foldDiacritics('raḥīm'), 'rahim');
      expect(foldDiacritics('Sūrah'), 'surah');
    });
  });

  group('filterSurahs', () {
    test('query rỗng + filter all -> giữ nguyên', () {
      final result =
          filterSurahs(surahs, query: '', filter: SurahFilter.all);
      expect(result.length, 3);
    });

    test('tìm theo số Surah', () {
      final result =
          filterSurahs(surahs, query: '114', filter: SurahFilter.all);
      expect(result.single.nameLatin, 'An-Nas');
    });

    test('tìm tiếng Việt KHÔNG dấu vẫn khớp tên có dấu', () {
      final result =
          filterSurahs(surahs, query: 'nhan loai', filter: SurahFilter.all);
      expect(result.single.id, 114);
    });

    test('tìm theo tên Ả Rập nguyên văn', () {
      final result =
          filterSurahs(surahs, query: 'البقرة', filter: SurahFilter.all);
      expect(result.single.id, 2);
    });

    test('lọc Madinah', () {
      final result =
          filterSurahs(surahs, query: '', filter: SurahFilter.madinah);
      expect(result.single.id, 2);
    });

    test('lọc + tìm kết hợp: mecca + "al" -> loại Al-Baqarah', () {
      // 'al' khớp Al-Fatihah và Al-Baqarah; bộ lọc mecca loại
      // Al-Baqarah (madinah). An-Nas không chứa 'al' ở bất kỳ tên nào.
      final result =
          filterSurahs(surahs, query: 'al', filter: SurahFilter.mecca);
      expect(result.map((s) => s.id), [1]);
    });

    test('không khớp -> danh sách rỗng', () {
      final result =
          filterSurahs(surahs, query: 'xyz', filter: SurahFilter.all);
      expect(result, isEmpty);
    });
  });
}
