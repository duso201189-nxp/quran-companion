import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/quran/quran_address.dart';
import 'package:quran_companion/features/quran/domain/basmalah.dart';
import 'package:quran_companion/features/quran/domain/reading_playlist.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_rows.dart';

/// Sprint BM1 — bố cục playlist audio.
///
/// Đây là bộ test canh cái rủi ro lớn nhất của sprint: thêm phần mở đầu
/// làm chỉ số playlist và chỉ số Ayah tách đôi, mà hai nơi tiêu thụ chỉ
/// số Ayah thì GHI XUỐNG ĐĨA. Vì thế phần lớn test dưới đây là về phép
/// quy đổi, không phải về Basmalah.
void main() {
  // Basmalah thật, để `resolveSurahOpening` chạy đúng đường.
  const basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  SurahOpening openingOf(int surahId) => resolveSurahOpening(
        surahId: surahId,
        firstAyahText: surahId == 9 ? 'بَرَآءَةٌ مِّنَ' : '$basmalah نص',
      );

  group('BM1 — có bao nhiêu mục dẫn đầu', () {
    test('Surah thường -> đúng 1 mục mở đầu', () {
      expect(ReadingPlaylist.leadingItemsFor(openingOf(2)), 1);
      expect(ReadingPlaylist.leadingItemsFor(openingOf(114)), 1);
    });

    test('Al-Fatihah -> 0: Basmalah CHÍNH LÀ Ayah 1, đã ở trong playlist', () {
      // Thêm mục mở đầu ở đây là phát Basmalah hai lần liên tiếp.
      expect(ReadingPlaylist.leadingItemsFor(openingOf(1)), 0);
    });

    test('At-Tawbah -> 0: không có Basmalah', () {
      expect(ReadingPlaylist.leadingItemsFor(openingOf(9)), 0);
    });

    test('114 Surah -> đúng 112 Surah có mục mở đầu', () {
      var withOpening = 0;
      for (var id = 1; id <= 114; id++) {
        withOpening += ReadingPlaylist.leadingItemsFor(openingOf(id));
      }
      expect(withOpening, 112);
    });
  });

  group('BM1 — quy đổi Ayah ↔ mục phát', () {
    test('có mở đầu: Ayah thứ i nằm ở mục i+1', () {
      final opening = openingOf(2);

      expect(
        ReadingPlaylist.itemForAyahIndex(opening: opening, ayahIndex: 0),
        1,
      );
      expect(
        ReadingPlaylist.ayahIndexForItem(opening: opening, item: 1),
        0,
      );
    });

    test('không mở đầu: hai hệ trùng nhau y như trước BM1', () {
      for (final opening in [openingOf(1), openingOf(9)]) {
        expect(
          ReadingPlaylist.itemForAyahIndex(opening: opening, ayahIndex: 5),
          5,
        );
        expect(
          ReadingPlaylist.ayahIndexForItem(opening: opening, item: 5),
          5,
        );
      }
    });

    test('mục mở đầu KHÔNG ứng với Ayah nào -> null, không phải 0', () {
      // Trả 0 sẽ là "Ayah đầu tiên", và nếu con số đó rơi xuống
      // ReadingPositionStore thì vị trí đọc lệch một Ayah, âm thầm.
      expect(
        ReadingPlaylist.ayahIndexForItem(opening: openingOf(2), item: 0),
        isNull,
      );
      // Surah không có mở đầu thì mục 0 LÀ Ayah đầu.
      expect(
        ReadingPlaylist.ayahIndexForItem(opening: openingOf(1), item: 0),
        0,
      );
    });

    test('khứ hồi không đổi giá trị, với cả 114 Surah', () {
      for (var id = 1; id <= 114; id++) {
        final opening = openingOf(id);
        for (final ayahIndex in [0, 1, 6, 285]) {
          expect(
            ReadingPlaylist.ayahIndexForItem(
              opening: opening,
              item: ReadingPlaylist.itemForAyahIndex(
                opening: opening,
                ayahIndex: ayahIndex,
              ),
            ),
            ayahIndex,
            reason: 'Surah $id, Ayah index $ayahIndex',
          );
        }
      }
    });
  });

  /// Sprint BM3 — thay nhóm `startItemForAyahIndex` cũ, đã xoá cùng
  /// chính hàm đó.
  ///
  /// Hàm cũ nhận chỉ số Ayah rồi ĐOÁN ý định từ `ayahIndex == 0`, nên
  /// "phát Ayah 1" và "đọc Surah từ đầu" không phân biệt được — bấm nút
  /// phát trên thẻ Ayah 1 lại nghe Basmalah trước. Test cũ khẳng định
  /// đúng hành vi đó, nên nó không sai; nó chỉ khoá lại một sự mập mờ
  /// mà BM2/BM3 vừa gỡ được bằng cách cho phần mở đầu nút riêng.
  group('BM3 — MỨC của địa chỉ mang ý định', () {
    test('mức Surah = đọc từ đầu -> bắt đầu ở phần mở đầu', () {
      expect(
        ReadingPlaylist.itemForAddress(
          opening: openingOf(2),
          from: QuranAddress.surah(2),
        ),
        0, // mục mở đầu
      );
    });

    test('mức Ayah 1 = phát Ayah 1 -> KHÔNG chèn Basmalah', () {
      // Chính là chỗ BM3 sửa: nút trên thẻ Ayah 1 giờ làm đúng thứ nó
      // hứa, vì phần mở đầu đã có nút của riêng nó.
      expect(
        ReadingPlaylist.itemForAddress(
          opening: openingOf(2),
          from: QuranAddress.ayah(2, 1),
        ),
        1,
      );
    });

    test('mức Ayah giữa Surah -> đúng mục của Ayah đó', () {
      expect(
        ReadingPlaylist.itemForAddress(
          opening: openingOf(2),
          from: QuranAddress.ayah(2, 5),
        ),
        5,
      );
    });

    test('Surah không có mở đầu -> hai mức cho cùng một mục', () {
      // Al-Fatihah: "đọc từ đầu" và "phát Ayah 1" là cùng một việc, vì
      // Ayah 1 CHÍNH LÀ Basmalah.
      for (final surahId in [1, 9]) {
        final opening = openingOf(surahId);
        expect(
          ReadingPlaylist.itemForAddress(
            opening: opening,
            from: QuranAddress.surah(surahId),
          ),
          0,
        );
        expect(
          ReadingPlaylist.itemForAddress(
            opening: opening,
            from: QuranAddress.ayah(surahId, 1),
          ),
          0,
        );
      }
    });
  });

  /// Bất biến quan trọng nhất của BM1: hàng và playlist phải cùng nhìn
  /// một Surah theo cùng một cách. Chúng lấy số phần tử dẫn đầu từ hai
  /// module khác nhau, nên không có gì ép chúng khớp ngoài test này.
  group('BM1 — hàng và playlist không được lệch nhau', () {
    test('cùng Ayah -> cùng "khoảng lệch" so với chỉ số Ayah', () {
      for (var id = 1; id <= 114; id++) {
        final opening = openingOf(id);
        const ayahIndex = 3;

        final rowOffset = ReadingRows.rowForAyahIndex(
              opening: opening,
              ayahIndex: ayahIndex,
            ) -
            ayahIndex;
        final itemOffset = ReadingPlaylist.itemForAyahIndex(
              opening: opening,
              ayahIndex: ayahIndex,
            ) -
            ayahIndex;

        // Sprint BM2: hàng lệch thêm đúng 1 so với mục phát, và cái 1 đó
        // là hàng HEADER — thứ chỉ tồn tại ở giao diện, không có trong
        // playlist. Ngoài nó ra, hai hệ đồng ý với nhau.
        expect(rowOffset - itemOffset, ReadingRows.headerRows);
        expect(itemOffset, ReadingPlaylist.leadingItemsFor(opening));
      }
    });
  });

  group('BM1 — địa chỉ của phần mở đầu', () {
    test('mức Surah KHÁC mức Ayah 1 -> không thể tô nhầm thẻ Ayah 1', () {
      // Tính chất này của F0 là thứ giữ cho phần tô sáng đúng khi
      // Basmalah đang phát. Khoá lại ở đây vì BM1 dựa vào nó.
      expect(QuranAddress.surah(2), isNot(QuranAddress.ayah(2, 1)));
    });

    test('mức Surah không có chỉ số Ayah -> tín hiệu "chưa tới Ayah nào"', () {
      // Phần cuộn theo audio dùng đúng dấu hiệu này để cuộn về header.
      expect(QuranAddress.surah(2).zeroBasedAyahIndex, isNull);
      expect(QuranAddress.ayah(2, 1).zeroBasedAyahIndex, 0);
    });

    test('mức Surah đứng TRƯỚC mọi Ayah của nó -> đúng thứ tự playlist', () {
      final sorted = [QuranAddress.ayah(2, 1), QuranAddress.surah(2)]..sort();
      expect(sorted.first, QuranAddress.surah(2));
    });
  });
}
