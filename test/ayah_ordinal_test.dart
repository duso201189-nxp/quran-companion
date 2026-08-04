import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/quran/ayah_ordinal.dart';
import 'package:quran_companion/core/quran/quran_address.dart';

/// Sprint SF2 (Tier 0) — quy đổi ordinal ↔ [QuranAddress].
///
/// Bộ test này CỐ Ý không dùng database, widget hay `ProviderContainer`:
/// nếu một ngày phải thêm bất kỳ thứ nào vào đây thì phép quy đổi đã
/// thôi thuần, và cái lợi lớn nhất của nó (repository không cần kéo
/// database nội dung vào để gọi tên dữ liệu của mình) đã mất.
///
/// Phần đối chiếu với dữ liệu THẬT nằm ở `ayah_ordinal_real_data_test.dart`.
void main() {
  group('SF2 — bảng số Ayah', () {
    test('đúng 114 Surah', () {
      expect(AyahOrdinal.ayahCounts, hasLength(114));
    });

    test('tổng đúng bằng totalAyahs', () {
      final sum = AyahOrdinal.ayahCounts.fold<int>(0, (a, b) => a + b);
      expect(sum, AyahOrdinal.totalAyahs);
      expect(sum, 6236);
    });

    test('mọi Surah có ít nhất một Ayah', () {
      expect(AyahOrdinal.ayahCounts.every((c) => c >= 1), isTrue);
    });
  });

  group('SF2 — ordinal -> địa chỉ', () {
    test('các mốc đã biết', () {
      expect(AyahOrdinal.tryFromOrdinal(1), QuranAddress.ayah(1, 1));
      expect(AyahOrdinal.tryFromOrdinal(7), QuranAddress.ayah(1, 7));
      // Ranh giới Surah: 8 là Ayah đầu của Al-Baqarah, không phải 1:8.
      expect(AyahOrdinal.tryFromOrdinal(8), QuranAddress.ayah(2, 1));
      expect(AyahOrdinal.tryFromOrdinal(6236), QuranAddress.ayah(114, 6));
    });

    test('At-Tawbah bắt đầu ở ordinal 1236', () {
      expect(AyahOrdinal.tryFromOrdinal(1236), QuranAddress.ayah(9, 1));
    });

    test('luôn trả địa chỉ mức Ayah, không bao giờ mức Surah', () {
      for (final ordinal in [1, 8, 1236, 3000, 6236]) {
        expect(AyahOrdinal.tryFromOrdinal(ordinal)!.isAyahLevel, isTrue);
      }
    });
  });

  group('SF2 — địa chỉ -> ordinal', () {
    test('các mốc đã biết', () {
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(1, 1)), 1);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(1, 7)), 7);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(2, 1)), 8);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(114, 6)), 6236);
    });

    test('mức Surah -> null, KHÔNG phải Ayah đầu của Surah', () {
      // Trả 8 cho `QuranAddress.surah(2)` sẽ là đổi ngữ nghĩa lặng lẽ:
      // "Surah 2" và "Ayah 2:1" là hai thứ khác nhau (F0 có test riêng
      // cho việc hai mức không bằng nhau).
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.surah(2)), isNull);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.surah(1)), isNull);
    });
  });

  group('SF2 — song ánh trên TOÀN BỘ miền', () {
    test('khứ hồi ordinal -> địa chỉ -> ordinal, cả 6236 Ayah', () {
      for (var ordinal = 1; ordinal <= AyahOrdinal.totalAyahs; ordinal++) {
        final address = AyahOrdinal.tryFromOrdinal(ordinal);
        expect(address, isNotNull, reason: 'ordinal $ordinal');
        expect(
          AyahOrdinal.tryToOrdinal(address!),
          ordinal,
          reason: 'khứ hồi hỏng ở ordinal $ordinal ($address)',
        );
      }
    });

    test('khứ hồi địa chỉ -> ordinal -> địa chỉ, cả 6236 Ayah', () {
      for (var surah = 1; surah <= 114; surah++) {
        for (var n = 1; n <= AyahOrdinal.ayahCounts[surah - 1]; n++) {
          final address = QuranAddress.ayah(surah, n);
          final ordinal = AyahOrdinal.tryToOrdinal(address);
          expect(ordinal, isNotNull, reason: '$address');
          expect(
            AyahOrdinal.tryFromOrdinal(ordinal!),
            address,
            reason: 'khứ hồi hỏng ở $address (ordinal $ordinal)',
          );
        }
      }
    });

    test('toàn ánh: 6236 ordinal cho ra 6236 địa chỉ KHÁC NHAU', () {
      final addresses = {
        for (var o = 1; o <= AyahOrdinal.totalAyahs; o++)
          AyahOrdinal.tryFromOrdinal(o),
      };
      expect(addresses, hasLength(AyahOrdinal.totalAyahs));
    });

    test('đơn ánh: không hai địa chỉ nào cho cùng một ordinal', () {
      final ordinals = <int>{};
      for (var surah = 1; surah <= 114; surah++) {
        for (var n = 1; n <= AyahOrdinal.ayahCounts[surah - 1]; n++) {
          ordinals.add(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(surah, n))!);
        }
      }
      expect(ordinals, hasLength(AyahOrdinal.totalAyahs));
    });
  });

  group('SF2 — thứ tự được giữ nguyên', () {
    test('sắp theo ordinal == sắp theo địa chỉ', () {
      // Quan trọng vì tìm kiếm FTS sắp kết quả bằng `ORDER BY ayah_id`
      // (`quran_repository_impl.dart`). Nếu hai thứ tự khác nhau thì
      // đổi định danh sẽ đổi thứ tự kết quả người dùng thấy.
      final sample = [6236, 1, 1236, 8, 3000, 7, 2, 6235];
      final byOrdinal = [...sample]..sort();
      final byAddress = [...sample]..sort(
          (a, b) => AyahOrdinal.tryFromOrdinal(a)!
              .compareTo(AyahOrdinal.tryFromOrdinal(b)!),
        );

      expect(byAddress, byOrdinal);
    });

    test('ordinal tăng dần theo thứ tự đọc, không đứt quãng', () {
      var previous = 0;
      for (var surah = 1; surah <= 114; surah++) {
        for (var n = 1; n <= AyahOrdinal.ayahCounts[surah - 1]; n++) {
          final ordinal =
              AyahOrdinal.tryToOrdinal(QuranAddress.ayah(surah, n))!;
          expect(ordinal, previous + 1, reason: '$surah:$n');
          previous = ordinal;
        }
      }
      expect(previous, AyahOrdinal.totalAyahs);
    });
  });

  group('SF2 — biên và đầu vào hỏng: trả null, KHÔNG ném', () {
    test('ordinal ngoài miền', () {
      // `ayah_id` đã lưu KHÔNG có ràng buộc toàn vẹn nào (không khoá
      // ngoại, không CHECK, và không thể có vì hai database là hai
      // tệp riêng), nên giá trị rác là chuyện có thật, không giả định.
      for (final bad in [0, -1, -6236, 6237, 999999]) {
        expect(
          AyahOrdinal.tryFromOrdinal(bad),
          isNull,
          reason: 'ordinal $bad phải trả null',
        );
      }
    });

    test('số Ayah vượt quá số Ayah của Surah đó', () {
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(1, 8)), isNull);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(2, 287)), isNull);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(114, 7)), isNull);
    });

    test('Surah ngoài 1..114 — địa chỉ đúng dạng nhưng không tồn tại', () {
      // F0 cho phép dựng địa chỉ đúng dạng mà không tồn tại, nên nhánh
      // này không phải giả thuyết.
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(115, 1)), isNull);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(999, 1)), isNull);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.surah(999)), isNull);
    });

    test('biên chính xác: nhận cận, từ chối cận + 1', () {
      expect(AyahOrdinal.tryFromOrdinal(1), isNotNull);
      expect(AyahOrdinal.tryFromOrdinal(0), isNull);
      expect(AyahOrdinal.tryFromOrdinal(6236), isNotNull);
      expect(AyahOrdinal.tryFromOrdinal(6237), isNull);

      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(114, 6)), isNotNull);
      expect(AyahOrdinal.tryToOrdinal(QuranAddress.ayah(114, 7)), isNull);
    });

    test('không đầu vào nào làm hàm ném lỗi', () {
      for (final bad in [0, -1, 6237, 999999]) {
        expect(() => AyahOrdinal.tryFromOrdinal(bad), returnsNormally);
      }
      for (final address in [
        QuranAddress.surah(1),
        QuranAddress.surah(999),
        QuranAddress.ayah(999, 999),
        QuranAddress.ayah(1, 8),
      ]) {
        expect(() => AyahOrdinal.tryToOrdinal(address), returnsNormally);
      }
    });
  });
}
