import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/presentation/reading/mushaf_builder.dart';

AyahContent _ayah(int id, int number, {int? page}) => AyahContent(
      ayah: Ayah(
        id: id,
        surahId: 1,
        ayahNumber: number,
        textUthmani: 'نص$number',
        page: page,
      ),
      texts: const {},
    );

void main() {
  group('toArabicDigits', () {
    test('chuyển đúng chữ số Ả Rập-Ấn', () {
      expect(toArabicDigits(1), '١');
      expect(toArabicDigits(114), '١١٤');
      expect(toArabicDigits(286), '٢٨٦');
    });
  });

  group('buildMushafPages', () {
    test('gom Ayah theo số trang, giữ thứ tự', () {
      final pages = buildMushafPages([
        _ayah(1, 1, page: 1),
        _ayah(2, 2, page: 1),
        _ayah(3, 3, page: 2),
      ]);

      expect(pages.length, 2);
      expect(pages[0].pageNumber, 1);
      expect(pages[0].firstAyahIndex, 0);
      expect(pages[1].pageNumber, 2);
      expect(pages[1].firstAyahIndex, 2);
    });

    test('mỗi Ayah kết thúc bằng dấu ﴿n﴾ chữ số Ả Rập', () {
      final pages = buildMushafPages([_ayah(1, 1, page: 1)]);

      expect(pages.single.text, contains('نص1'));
      expect(pages.single.text, contains('﴿١﴾'));
    });

    test('Ayah thiếu số trang -> gom trang 0, không mất nội dung',
        () {
      final pages = buildMushafPages([_ayah(1, 1), _ayah(2, 2)]);

      expect(pages.single.pageNumber, 0);
      expect(pages.single.text, contains('نص2'));
    });

    test('danh sách rỗng -> không trang nào', () {
      expect(buildMushafPages(const []), isEmpty);
    });
  });

  group('pageIndexForAyah', () {
    final pages = buildMushafPages([
      _ayah(1, 1, page: 1),
      _ayah(2, 2, page: 1),
      _ayah(3, 3, page: 2),
      _ayah(4, 4, page: 2),
    ]);

    test('ayah 0,1 thuộc trang đầu; ayah 2,3 thuộc trang sau', () {
      expect(pageIndexForAyah(pages, 0), 0);
      expect(pageIndexForAyah(pages, 1), 0);
      expect(pageIndexForAyah(pages, 2), 1);
      expect(pageIndexForAyah(pages, 3), 1);
    });
  });
}
