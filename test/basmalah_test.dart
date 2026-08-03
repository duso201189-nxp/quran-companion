import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/quran/quran_address.dart';
import 'package:quran_companion/features/quran/domain/basmalah.dart';

void main() {
  // Chuỗi thật lấy từ quran.sqlite.
  const basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  // Biến thể chính tả ở Surah 95 & 97 (thêm shadda ở ب).
  const basmalahVariant = 'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  // Ayah 1 của Surah 9 — Surah duy nhất không có Basmalah.
  const tawbahFirstAyah = 'بَرَآءَةٌ مِّنَ ٱللَّهِ وَرَسُولِهِۦٓ إِلَى';

  /// Sprint F2 — nhóm test này thay cho nhóm `surahHasLeadingBasmalah`
  /// cũ, đã xoá cùng chính hàm đó.
  ///
  /// Hàm cũ trả `false` cho CẢ Surah 1 lẫn Surah 9, vì hai lý do ngược
  /// nhau: Surah 1 CÓ Basmalah (nó là Ayah 1), Surah 9 KHÔNG có. Test
  /// cũ khẳng định đúng điều đó (`Surah 1 & 9 -> false`) nên nó không
  /// sai — nhưng nó khoá lại một sự mập mờ thay vì phát hiện ra. Ba
  /// nhánh dưới đây phân biệt được hai trường hợp ấy, nên chúng kiểm
  /// được nhiều hơn hẳn.
  group('F2 — SurahOpening: ba trường hợp, ba nhánh', () {
    test('Surah thường -> Basmalah là TIỀN TỐ của Ayah 1', () {
      final opening = resolveSurahOpening(
        surahId: 2,
        firstAyahText: '$basmalah الٓمٓ',
      );

      expect(
        opening,
        OpeningPrefixesFirstAyah(
          containingAyah: QuranAddress.ayah(2, 1),
          text: basmalah,
          remainder: 'الٓمٓ',
        ),
      );
    });

    test('Al-Fatihah -> Basmalah CHÍNH LÀ Ayah 1, và có địa chỉ 1:1', () {
      final opening = resolveSurahOpening(
        surahId: 1,
        firstAyahText: basmalah,
      );

      expect(opening, OpeningIsFirstAyah(QuranAddress.ayah(1, 1)));
      expect((opening as OpeningIsFirstAyah).address.toString(), '1:1');
    });

    test('At-Tawbah -> KHÔNG có phần mở đầu', () {
      expect(
        resolveSurahOpening(surahId: 9, firstAyahText: tawbahFirstAyah),
        const NoOpening(),
      );
    });

    test('Surah 1 và Surah 9 KHÔNG còn cho cùng một câu trả lời', () {
      // Chính là sự mập mờ mà F2 gỡ bỏ. Trước F2 cả hai là `false`.
      final fatihah = resolveSurahOpening(surahId: 1, firstAyahText: basmalah);
      final tawbah = resolveSurahOpening(
        surahId: 9,
        firstAyahText: tawbahFirstAyah,
      );

      expect(fatihah, isNot(tawbah));
      expect(fatihah, isA<OpeningIsFirstAyah>());
      expect(tawbah, isA<NoOpening>());
    });

    test('biến thể chính tả 95/97 vẫn tách đúng', () {
      final opening = resolveSurahOpening(
        surahId: 95,
        firstAyahText: '$basmalahVariant وَٱلتِّينِ وَٱلزَّيْتُونِ',
      );

      expect(
        opening,
        OpeningPrefixesFirstAyah(
          containingAyah: QuranAddress.ayah(95, 1),
          text: basmalahVariant,
          remainder: 'وَٱلتِّينِ وَٱلزَّيْتُونِ',
        ),
      );
    });

    test('114 Surah -> đúng 1 NoOpening, đúng 1 IsFirstAyah, 112 tiền tố', () {
      var none = 0, isAyah = 0, prefix = 0;
      for (var id = 1; id <= 114; id++) {
        switch (resolveSurahOpening(
          surahId: id,
          firstAyahText: '$basmalah نص',
        )) {
          case NoOpening():
            none++;
          case OpeningIsFirstAyah():
            isAyah++;
          case OpeningPrefixesFirstAyah():
            prefix++;
        }
      }

      expect(none, 1, reason: 'chỉ At-Tawbah');
      expect(isAyah, 1, reason: 'chỉ Al-Fatihah');
      expect(prefix, 112);
    });

    test('phần mở đầu là GIÁ TRỊ: bằng nhau, cùng hashCode, in ra đọc được',
        () {
      final a =
          resolveSurahOpening(surahId: 2, firstAyahText: '$basmalah الٓمٓ');
      final b =
          resolveSurahOpening(surahId: 2, firstAyahText: '$basmalah الٓمٓ');
      final fatihah = resolveSurahOpening(surahId: 1, firstAyahText: basmalah);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          resolveSurahOpening(surahId: 3, firstAyahText: '$basmalah الٓمٓ'),
        ),
      );
      expect(
        fatihah.hashCode,
        resolveSurahOpening(surahId: 1, firstAyahText: basmalah).hashCode,
      );

      // toString() là công cụ chẩn đoán: nó phải nêu ĐỊA CHỈ, vì đó là
      // thứ phân biệt hai phần mở đầu khi một test đỏ.
      expect(a.toString(), 'OpeningPrefixesFirstAyah(2:1)');
      expect(fatihah.toString(), 'OpeningIsFirstAyah(1:1)');
    });

    test('tiến độ rơi ra từ nhánh, không cần cờ riêng', () {
      // DR-2026-0017 §10.3 bác bỏ `countsTowardProgress`. Kiểm chứng
      // rằng thông tin đó vẫn đọc được từ chính kiểu: phần mở đầu của
      // Al-Fatihah LÀ một Ayah (hoàn thành 1), của Surah thường chỉ
      // nằm TRONG một Ayah (hoàn thành 0).
      int completedAyahs(SurahOpening o) => switch (o) {
            OpeningIsFirstAyah() => 1,
            OpeningPrefixesFirstAyah() || NoOpening() => 0,
          };

      expect(
        completedAyahs(
          resolveSurahOpening(surahId: 1, firstAyahText: basmalah),
        ),
        1,
      );
      expect(
        completedAyahs(
          resolveSurahOpening(
            surahId: 2,
            firstAyahText: '$basmalah الٓمٓ',
          ),
        ),
        0,
      );
      expect(
        completedAyahs(
          resolveSurahOpening(surahId: 9, firstAyahText: tawbahFirstAyah),
        ),
        0,
      );
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

  /// Cổng "byte-identical" của `DR-2026-0019` E2 / `DR-2026-0017` M2,
  /// phát biểu ở dạng THUẦN thay vì dựng 114 màn hình.
  ///
  /// Công thức cũ được chép nguyên vào đây làm chuẩn đối chiếu. Nếu lần
  /// khai báo hoá này làm lệch dù một Surah, test đỏ.
  group('F2 — tương đương từng byte với công thức trước F2', () {
    // Đúng mã nguồn `ayahDisplayText` trước Sprint F2.
    String before({
      required int surahId,
      required int ayahNumber,
      required String textUthmani,
    }) {
      final hasLeadingBasmalah = surahId != 1 && surahId != 9;
      if (ayahNumber == 1 && hasLeadingBasmalah) {
        return splitLeadingBasmalah(textUthmani).rest;
      }
      return textUthmani;
    }

    test('114 Surah × {Ayah 1, Ayah 2} -> kết quả y hệt', () {
      for (var id = 1; id <= 114; id++) {
        // Ayah 1: dạng thật của nhóm có tiền tố; Surah 1 và 9 dùng văn
        // bản thật của chúng để phép so sánh không chỉ đúng trên giấy.
        final firstAyah = switch (id) {
          1 => basmalah,
          9 => tawbahFirstAyah,
          95 || 97 => '$basmalahVariant نص',
          _ => '$basmalah نص',
        };

        for (final (number, text) in [(1, firstAyah), (2, 'نص عربي')]) {
          expect(
            ayahDisplayText(
              surahId: id,
              ayahNumber: number,
              textUthmani: text,
            ),
            before(surahId: id, ayahNumber: number, textUthmani: text),
            reason: 'Surah $id, Ayah $number',
          );
        }
      }
    });
  });
}
