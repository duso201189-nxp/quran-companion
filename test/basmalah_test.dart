import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/quran/domain/basmalah.dart';

void main() {
  // Chuỗi thật lấy từ quran.sqlite.
  const basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  // Biến thể chính tả ở Surah 95 & 97 (thêm shadda ở ب).
  const basmalahVariant = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  group('surahHasLeadingBasmalah', () {
    test('Surah 1 & 9 -> false, còn lại -> true', () {
      expect(surahHasLeadingBasmalah(1), isFalse);
      expect(surahHasLeadingBasmalah(9), isFalse);
      expect(surahHasLeadingBasmalah(2), isTrue);
      expect(surahHasLeadingBasmalah(95), isTrue);
      expect(surahHasLeadingBasmalah(114), isTrue);
    });
  });

  group('splitLeadingBasmalah', () {
    test('tách đúng Basmalah + phần còn lại (Al-Baqarah)', () {
      final r = splitLeadingBasmalah('$basmalah الٓمٓ');
      expect(r.basmalah, basmalah);
      expect(r.rest, 'الٓمٓ');
    });

    test('bền với biến thể chính tả 95/97', () {
      final r =
          splitLeadingBasmalah('$basmalahVariant وَٱلتِّينِ وَٱلزَّيْتُونِ');
      expect(r.basmalah, basmalahVariant);
      expect(r.rest, 'وَٱلتِّينِ وَٱلزَّيْتُونِ');
    });

    test('câu dài nhiều từ vẫn chỉ cắt 4 từ đầu', () {
      final r = splitLeadingBasmalah('$basmalah قُلْ هُوَ ٱللَّهُ أَحَدٌ');
      expect(r.basmalah, basmalah);
      expect(r.rest, 'قُلْ هُوَ ٱللَّهُ أَحَدٌ');
    });

    test('ít hơn 5 token -> trả toàn bộ làm basmalah, rest rỗng', () {
      final r = splitLeadingBasmalah('a b c');
      expect(r.basmalah, 'a b c');
      expect(r.rest, '');
    });
  });

  group('ayahDisplayText', () {
    test('Ayah 1 Surah thường -> bỏ Basmalah', () {
      expect(
        ayahDisplayText(
          surahId: 2,
          ayahNumber: 1,
          textUthmani: '$basmalah الٓمٓ',
        ),
        'الٓمٓ',
      );
    });

    test('Ayah != 1 -> giữ nguyên', () {
      expect(
        ayahDisplayText(surahId: 2, ayahNumber: 2, textUthmani: 'نص'),
        'نص',
      );
    });

    test('Surah 1 (Basmalah LÀ Ayah 1) -> giữ nguyên', () {
      expect(
        ayahDisplayText(surahId: 1, ayahNumber: 1, textUthmani: basmalah),
        basmalah,
      );
    });

    test('Surah 9 (không có Basmalah) -> giữ nguyên', () {
      expect(
        ayahDisplayText(
          surahId: 9,
          ayahNumber: 1,
          textUthmani: 'بَرَآءَةٌ مِّنَ',
        ),
        'بَرَآءَةٌ مِّنَ',
      );
    });
  });
}
