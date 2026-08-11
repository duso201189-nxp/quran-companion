import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/quran/ayah_ordinal.dart';
import 'package:quran_companion/features/study/domain/surah_completion.dart';

/// Sprint 7.4 — phần THUẦN của phát hiện ranh giới: không database,
/// không ProviderContainer, không widget (DR-2026-0023 mục 6).
void main() {
  group('SurahCompletion.completed', () {
    test('Ayah cuối cùng -> đọc trọn', () {
      // Al-Fatihah: 7 Ayah -> chỉ số 0-based cuối là 6.
      expect(
        SurahCompletion.completed(surahId: 1, maxAyahIndex: 6),
        isTrue,
      );
    });

    test('Ayah đầu tiên -> chưa trọn', () {
      expect(
        SurahCompletion.completed(surahId: 1, maxAyahIndex: 0),
        isFalse,
      );
    });

    test('Ayah áp chót -> chưa trọn', () {
      expect(
        SurahCompletion.completed(surahId: 1, maxAyahIndex: 5),
        isFalse,
      );
    });

    test('vượt quá miền -> vẫn tính là trọn, không kẹt vĩnh viễn', () {
      expect(
        SurahCompletion.completed(surahId: 1, maxAyahIndex: 99),
        isTrue,
      );
    });

    test('chỉ số âm -> false, không đoán', () {
      expect(
        SurahCompletion.completed(surahId: 1, maxAyahIndex: -1),
        isFalse,
      );
    });

    test('Surah ngoài 1..114 -> false, không ném', () {
      expect(SurahCompletion.completed(surahId: 0, maxAyahIndex: 5), isFalse);
      expect(SurahCompletion.completed(surahId: 115, maxAyahIndex: 5), isFalse);
      expect(SurahCompletion.completed(surahId: -3, maxAyahIndex: 5), isFalse);
    });

    test('mọi ranh giới của cả 114 Surah đều đúng', () {
      for (var surahId = 1; surahId <= 114; surahId++) {
        final count = AyahOrdinal.ayahCounts[surahId - 1];
        final lastIndex = count - 1;

        expect(
          SurahCompletion.completed(
            surahId: surahId,
            maxAyahIndex: lastIndex,
          ),
          isTrue,
          reason: 'Surah $surahId: chỉ số $lastIndex phải là trọn',
        );

        // Surah 1 Ayah (không có trong ấn bản này, nhưng luật vẫn phải
        // đúng nếu có) không có "áp chót" để kiểm.
        if (lastIndex > 0) {
          expect(
            SurahCompletion.completed(
              surahId: surahId,
              maxAyahIndex: lastIndex - 1,
            ),
            isFalse,
            reason: 'Surah $surahId: chỉ số ${lastIndex - 1} chưa trọn',
          );
        }
      }
    });

    test('Surah khác nhau có ranh giới khác nhau — không dùng chung một số',
        () {
      // An-Nas (114) có 6 Ayah; Al-Baqarah (2) có 286.
      expect(SurahCompletion.completed(surahId: 114, maxAyahIndex: 5), isTrue);
      expect(SurahCompletion.completed(surahId: 2, maxAyahIndex: 5), isFalse);
      expect(SurahCompletion.completed(surahId: 2, maxAyahIndex: 285), isTrue);
    });
  });

  group('SurahCompletion.lastAyahIndexOf', () {
    test('trả đúng chỉ số cuối 0-based', () {
      expect(SurahCompletion.lastAyahIndexOf(1), 6);
      expect(SurahCompletion.lastAyahIndexOf(2), 285);
      expect(SurahCompletion.lastAyahIndexOf(114), 5);
    });

    test('ngoài miền -> null', () {
      expect(SurahCompletion.lastAyahIndexOf(0), isNull);
      expect(SurahCompletion.lastAyahIndexOf(115), isNull);
    });
  });

  test('ngưỡng phiên dùng lại đúng 5 giây của ReadingScreen/StatsStore', () {
    expect(SurahCompletion.minSessionSeconds, 5);
  });
}
