import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/basmalah.dart';
import 'package:quran_companion/features/quran/domain/reading_playlist.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_rows.dart';

/// Sprint F2 + BM2 — bố cục hàng của danh sách đọc (hệ C).
///
/// Bộ test này CỐ Ý không dựng widget: phép quy đổi Ayah ↔ hàng là số
/// học thuần, và trước F2 nó được viết tay ở năm chỗ nằm trong một
/// widget 1.300 dòng, nên chỉ kiểm được gián tiếp qua widget test.
///
/// BM2 làm số hàng dẫn đầu phụ thuộc Surah, nên mọi test dưới đây chạy
/// trên CẢ BA dạng mở đầu.
void main() {
  const basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  SurahOpening openingOf(int surahId) => resolveSurahOpening(
        surahId: surahId,
        firstAyahText: surahId == 9 ? 'بَرَآءَةٌ مِّنَ' : '$basmalah نص',
      );

  final normal = openingOf(2); // có phần mở đầu riêng
  final fatihah = openingOf(1); // Basmalah LÀ Ayah 1
  final tawbah = openingOf(9); // không có Basmalah

  group('BM2 — số hàng dẫn đầu phụ thuộc phần mở đầu', () {
    test('Surah thường: header + phần mở đầu = 2 hàng dẫn đầu', () {
      expect(ReadingRows.leadingRowsFor(normal), 2);
    });

    test('Al-Fatihah và At-Tawbah: chỉ header = 1 hàng dẫn đầu', () {
      // Hai lý do ngược nhau (Basmalah LÀ Ayah 1 / không có Basmalah),
      // cùng một kết luận: không có hàng mở đầu riêng.
      expect(ReadingRows.leadingRowsFor(fatihah), 1);
      expect(ReadingRows.leadingRowsFor(tawbah), 1);
    });

    test('hàng của phần mở đầu là ngay sau header, hoặc null', () {
      expect(ReadingRows.openingRowFor(normal), 1);
      expect(ReadingRows.openingRowFor(fatihah), isNull);
      expect(ReadingRows.openingRowFor(tawbah), isNull);
    });

    test('hàng header luôn tồn tại, mọi dạng Surah', () {
      for (final opening in [normal, fatihah, tawbah]) {
        expect(ReadingRows.isLeading(opening: opening, row: 0), isTrue);
        expect(
          ReadingRows.ayahIndexForRow(opening: opening, row: 0),
          isNull,
        );
      }
    });
  });

  group('BM2 — hàng dẫn đầu KHÔNG phải Ayah nào', () {
    test('Surah thường: cả hàng 0 và hàng 1 đều trả null', () {
      expect(ReadingRows.ayahIndexForRow(opening: normal, row: 0), isNull);
      expect(ReadingRows.ayahIndexForRow(opening: normal, row: 1), isNull);
      expect(ReadingRows.ayahIndexForRow(opening: normal, row: 2), 0);
    });

    test('Surah không có mở đầu: hàng 1 ĐÃ là Ayah đầu', () {
      expect(ReadingRows.ayahIndexForRow(opening: fatihah, row: 1), 0);
    });

    test('trả null chứ KHÔNG trả số âm', () {
      // Trước F2 chỗ này là `max(0, row - 1)`: hàng header lặng lẽ biến
      // thành "Ayah 0". Đúng kết quả, nhưng vì kẹp chứ không vì phân
      // biệt — và cái kẹp đó là thứ đã sai khi BM2 thêm hàng dẫn đầu.
      expect(ReadingRows.ayahIndexForRow(opening: normal, row: 1), isNull);
    });
  });

  group('F2 + BM2 — quy đổi Ayah ↔ hàng', () {
    test('khứ hồi không đổi giá trị, với cả ba dạng mở đầu', () {
      for (final opening in [normal, fatihah, tawbah]) {
        for (final ayahIndex in [0, 1, 6, 285]) {
          expect(
            ReadingRows.ayahIndexForRow(
              opening: opening,
              row: ReadingRows.rowForAyahIndex(
                opening: opening,
                ayahIndex: ayahIndex,
              ),
            ),
            ayahIndex,
          );
        }
      }
    });

    test('Ayah đầu tiên nằm ngay sau phần dẫn đầu', () {
      expect(ReadingRows.rowForAyahIndex(opening: normal, ayahIndex: 0), 2);
      expect(ReadingRows.rowForAyahIndex(opening: fatihah, ayahIndex: 0), 1);
    });
  });

  group('F2 + BM2 — kích thước danh sách', () {
    test('số hàng = số Ayah + phần dẫn đầu', () {
      // Al-Fatihah: 7 Ayah + header = 8.
      expect(
        ReadingRows.rowCountFor(opening: fatihah, ayahCount: 7),
        8,
      );
      // Al-Baqarah: 286 Ayah + header + phần mở đầu = 288.
      expect(
        ReadingRows.rowCountFor(opening: normal, ayahCount: 286),
        288,
      );
    });

    test('hàng cuối cùng ứng với Ayah cuối cùng', () {
      const ayahCount = 7;
      for (final opening in [normal, fatihah, tawbah]) {
        expect(
          ReadingRows.lastRowFor(opening: opening, ayahCount: ayahCount),
          ReadingRows.rowForAyahIndex(
            opening: opening,
            ayahIndex: ayahCount - 1,
          ),
        );
      }
    });

    test('danh sách rỗng vẫn còn hàng dẫn đầu', () {
      expect(ReadingRows.rowCountFor(opening: fatihah, ayahCount: 0), 1);
      expect(ReadingRows.lastRowFor(opening: fatihah, ayahCount: 0), 0);
    });

    test('mọi hàng không dẫn đầu đều ánh xạ vào một Ayah hợp lệ', () {
      const ayahCount = 7;
      for (final opening in [normal, fatihah, tawbah]) {
        final last = ReadingRows.lastRowFor(
          opening: opening,
          ayahCount: ayahCount,
        );
        for (var row = 0; row <= last; row++) {
          final ayahIndex = ReadingRows.ayahIndexForRow(
            opening: opening,
            row: row,
          );
          if (ayahIndex == null) continue;
          expect(ayahIndex, inInclusiveRange(0, ayahCount - 1));
        }
      }
    });
  });

  /// Bất biến nối BM1 với BM2: hàng và playlist quyết định "có phần mở
  /// đầu riêng không" bằng CÙNG một hàm. Nếu ai đó tách hai định nghĩa
  /// ra, test này đỏ.
  group('BM2 — hàng và playlist cùng một định nghĩa', () {
    test('114 Surah: hàng dẫn đầu = header + đúng số mục dẫn đầu', () {
      for (var id = 1; id <= 114; id++) {
        final opening = openingOf(id);
        expect(
          ReadingRows.leadingRowsFor(opening),
          ReadingRows.headerRows + ReadingPlaylist.leadingItemsFor(opening),
          reason: 'Surah $id',
        );
      }
    });

    test('có hàng mở đầu khi và chỉ khi có mục phát mở đầu', () {
      for (var id = 1; id <= 114; id++) {
        final opening = openingOf(id);
        expect(
          ReadingRows.openingRowFor(opening) != null,
          ReadingPlaylist.leadingItemsFor(opening) == 1,
          reason: 'Surah $id',
        );
      }
    });
  });
}
