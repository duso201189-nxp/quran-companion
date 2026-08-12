import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/hifz/domain/hifz_range_input.dart';

/// Sprint 7.7b-ii — HifzRangeInputValidator: kiểm khoảng Ayah NGƯỜI
/// DÙNG nhập (Surah + số Ayah 1-based) trước khi gọi
/// HifzPlanRepository.createPlan (chỉ biết ordinal toàn cục). Thuần
/// Dart, không widget.
void main() {
  group('khoảng hợp lệ', () {
    test('Al-Fatihah 1..7 -> ordinal toàn cục 1..7', () {
      final result = HifzRangeInputValidator.validate(
        surahId: 1,
        surahAyahCount: 7,
        ayahFrom: 1,
        ayahTo: 7,
      );
      expect(result, isA<HifzRangeValid>());
      final valid = result as HifzRangeValid;
      expect(valid.ayahFromOrdinal, 1);
      expect(valid.ayahToOrdinal, 7);
    });

    test('một Ayah duy nhất (from == to) hợp lệ', () {
      final result = HifzRangeInputValidator.validate(
        surahId: 1,
        surahAyahCount: 7,
        ayahFrom: 3,
        ayahTo: 3,
      );
      expect(result, isA<HifzRangeValid>());
    });

    test('Al-Baqarah (Surah 2, ordinal bắt đầu ở 8) quy đổi đúng', () {
      final result = HifzRangeInputValidator.validate(
        surahId: 2,
        surahAyahCount: 286,
        ayahFrom: 1,
        ayahTo: 10,
      );
      final valid = result as HifzRangeValid;
      // Al-Fatihah chiếm ordinal 1..7 -> Al-Baqarah Ayah 1 là ordinal 8.
      expect(valid.ayahFromOrdinal, 8);
      expect(valid.ayahToOrdinal, 17);
    });
  });

  group('khoảng KHÔNG hợp lệ', () {
    test('Ayah From < 1 -> từ chối', () {
      final result = HifzRangeInputValidator.validate(
        surahId: 1,
        surahAyahCount: 7,
        ayahFrom: 0,
        ayahTo: 3,
      );
      expect(result, isA<HifzRangeInvalid>());
      expect(
        (result as HifzRangeInvalid).reason,
        HifzRangeInvalidReason.ayahFromBelowOne,
      );
    });

    test('Ayah To > số Ayah của Surah -> từ chối', () {
      final result = HifzRangeInputValidator.validate(
        surahId: 1,
        surahAyahCount: 7,
        ayahFrom: 1,
        ayahTo: 8,
      );
      expect(result, isA<HifzRangeInvalid>());
      expect(
        (result as HifzRangeInvalid).reason,
        HifzRangeInvalidReason.ayahToAboveSurahCount,
      );
    });

    test('Ayah From > Ayah To -> từ chối', () {
      final result = HifzRangeInputValidator.validate(
        surahId: 1,
        surahAyahCount: 7,
        ayahFrom: 5,
        ayahTo: 2,
      );
      expect(result, isA<HifzRangeInvalid>());
      expect(
        (result as HifzRangeInvalid).reason,
        HifzRangeInvalidReason.ayahFromAfterAyahTo,
      );
    });
  });
}
