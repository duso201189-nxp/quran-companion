import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/quran/quran_address.dart';

/// Sprint F0 — QuranAddress (DR-2026-0017, phạm vi Surah/Ayah).
///
/// Bộ test này CỐ Ý không dùng ProviderContainer, database hay widget:
/// kiểu địa chỉ phải dựng/so sánh/tuần tự hoá được mà không cần gì cả
/// (DR-2026-0017 §3.5). Nếu một ngày phải thêm `TestWidgetsFlutterBinding`
/// hay một database vào tệp này thì thiết kế đã bị vi phạm.
void main() {
  group('F0 — dựng địa chỉ', () {
    test('mức Surah giữ nguyên số Surah, không có Ayah', () {
      final address = QuranAddress.surah(2);

      expect(address.surah, 2);
      expect(address.ayah, isNull);
      expect(address.isSurahLevel, isTrue);
      expect(address.isAyahLevel, isFalse);
    });

    test('mức Ayah nhận SỐ Ayah 1-based đúng như người đọc thấy', () {
      final address = QuranAddress.ayah(2, 255);

      expect(address.surah, 2);
      expect(address.ayah, 255);
      expect(address.isAyahLevel, isTrue);
      expect(address.isSurahLevel, isFalse);
    });

    test('dựng từ chỉ số 0-based cộng đúng 1 — điểm quy đổi DUY NHẤT', () {
      // Đây chính là phép `+ 1` từng nằm rải rác ở audio_bar/AyahCard.
      expect(QuranAddress.fromZeroBasedAyahIndex(2, 0).ayah, 1);
      expect(QuranAddress.fromZeroBasedAyahIndex(2, 254).ayah, 255);
      expect(
        QuranAddress.fromZeroBasedAyahIndex(2, 254),
        QuranAddress.ayah(2, 255),
      );
    });

    test('zeroBasedAyahIndex là chiều ngược lại, khứ hồi không đổi', () {
      final address = QuranAddress.ayah(55, 13);

      expect(address.zeroBasedAyahIndex, 12);
      expect(
        QuranAddress.fromZeroBasedAyahIndex(55, address.zeroBasedAyahIndex!),
        address,
      );
    });

    test('mức Surah không có chỉ số 0-based', () {
      expect(QuranAddress.surah(9).zeroBasedAyahIndex, isNull);
    });
  });

  group('F0 — đúng dạng, KHÔNG phải tồn tại', () {
    test('số < 1 bị từ chối ở cả ba hàm dựng (địa chỉ là 1-based)', () {
      expect(() => QuranAddress.surah(0), throwsArgumentError);
      expect(() => QuranAddress.ayah(0, 1), throwsArgumentError);
      expect(() => QuranAddress.ayah(1, 0), throwsArgumentError);
      expect(
        () => QuranAddress.fromZeroBasedAyahIndex(1, -1),
        throwsArgumentError,
      );
    });

    test(
        'địa chỉ KHÔNG tồn tại vẫn đúng dạng — kiểm tra tồn tại cần dữ '
        'liệu, không phải việc của giá trị này', () {
      // Al-Baqarah có 286 Ayah; Qur'an có 114 Surah. Cả hai vẫn dựng
      // được: đây là ranh giới thiết kế, không phải lỗ hổng.
      expect(QuranAddress.ayah(2, 300).ayah, 300);
      expect(QuranAddress.surah(999).surah, 999);
    });
  });

  group('F0 — chứa (containment)', () {
    test('Surah chứa mọi Ayah của chính nó', () {
      final surah = QuranAddress.surah(2);

      expect(surah.contains(QuranAddress.ayah(2, 1)), isTrue);
      expect(surah.contains(QuranAddress.ayah(2, 255)), isTrue);
      expect(surah.contains(QuranAddress.surah(2)), isTrue);
    });

    test('Surah KHÔNG chứa Ayah của Surah khác', () {
      expect(
        QuranAddress.surah(2).contains(QuranAddress.ayah(3, 1)),
        isFalse,
      );
    });

    test('Ayah chỉ chứa chính nó, không chứa Ayah kề bên', () {
      final ayah = QuranAddress.ayah(2, 255);

      expect(ayah.contains(QuranAddress.ayah(2, 255)), isTrue);
      expect(ayah.contains(QuranAddress.ayah(2, 256)), isFalse);
      expect(ayah.contains(QuranAddress.ayah(2, 254)), isFalse);
    });

    test('Ayah KHÔNG chứa Surah bao nó (quan hệ một chiều)', () {
      expect(
        QuranAddress.ayah(2, 255).contains(QuranAddress.surah(2)),
        isFalse,
      );
    });
  });

  group('F0 — thứ tự đọc', () {
    test('sắp theo Surah trước, rồi theo Ayah', () {
      final addresses = [
        QuranAddress.ayah(2, 10),
        QuranAddress.ayah(1, 5),
        QuranAddress.ayah(2, 2),
        QuranAddress.ayah(1, 1),
      ]..sort();

      expect(
        addresses.map((a) => a.toString()).toList(),
        ['1:1', '1:5', '2:2', '2:10'],
      );
    });

    test('mức Surah đứng TRƯỚC mọi Ayah của chính Surah đó', () {
      final addresses = [
        QuranAddress.ayah(2, 1),
        QuranAddress.surah(2),
      ]..sort();

      expect(addresses.first, QuranAddress.surah(2));
    });

    test('so sánh 2:10 và 2:2 theo SỐ, không theo chuỗi', () {
      // Bẫy kinh điển khi sắp xếp dạng chuỗi: '2:10' < '2:2'.
      expect(
        QuranAddress.ayah(2, 10).compareTo(QuranAddress.ayah(2, 2)),
        greaterThan(0),
      );
    });
  });

  group('F0 — bằng nhau theo giá trị', () {
    test('cùng giá trị thì bằng nhau và cùng hashCode', () {
      expect(QuranAddress.ayah(2, 255), QuranAddress.ayah(2, 255));
      expect(
        QuranAddress.ayah(2, 255).hashCode,
        QuranAddress.ayah(2, 255).hashCode,
      );
    });

    test('mức Surah KHÁC mức Ayah dù cùng số Surah', () {
      expect(QuranAddress.surah(2), isNot(QuranAddress.ayah(2, 1)));
    });

    test('dùng được làm khoá Map/Set', () {
      final seen = {
        QuranAddress.ayah(1, 1),
        QuranAddress.ayah(1, 1),
        QuranAddress.ayah(1, 2),
      };

      expect(seen, hasLength(2));
    });
  });

  group('F0 — tuần tự hoá', () {
    test('sinh ra đúng dạng chuẩn: "2" và "2:255"', () {
      expect(QuranAddress.surah(2).toString(), '2');
      expect(QuranAddress.ayah(2, 255).toString(), '2:255');
    });

    test('khứ hồi qua tryParse giữ nguyên giá trị', () {
      for (final address in [
        QuranAddress.surah(1),
        QuranAddress.surah(114),
        QuranAddress.ayah(1, 1),
        QuranAddress.ayah(2, 255),
        QuranAddress.ayah(114, 6),
      ]) {
        expect(QuranAddress.tryParse(address.toString()), address);
      }
    });

    test('đọc vào rộng rãi: chấp nhận dấu chấm và khoảng trắng thừa', () {
      expect(QuranAddress.tryParse('2.255'), QuranAddress.ayah(2, 255));
      expect(QuranAddress.tryParse('  2:255  '), QuranAddress.ayah(2, 255));
    });

    test('chuỗi hỏng trả null, KHÔNG ném lỗi', () {
      for (final bad in [
        '',
        '   ',
        'abc',
        '2:',
        ':255',
        '2:0',
        '0:1',
        '2:255:4',
        '-1',
        '2:x',
      ]) {
        expect(
          QuranAddress.tryParse(bad),
          isNull,
          reason: '"$bad" phải trả null',
        );
      }
    });
  });
}
