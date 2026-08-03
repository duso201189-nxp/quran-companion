import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_rows.dart';

/// Sprint F2 — bố cục hàng của danh sách đọc (hệ C).
///
/// Bộ test này CỐ Ý không dựng widget: phép quy đổi Ayah ↔ hàng là số
/// học thuần, và trước F2 nó được viết tay ở năm chỗ nằm trong một
/// widget 1.300 dòng, nên chỉ kiểm được gián tiếp qua widget test.
void main() {
  group('F2 — quy đổi Ayah ↔ hàng', () {
    test('hàng 0 là hàng dẫn đầu, không phải Ayah nào', () {
      expect(ReadingRows.isLeading(0), isTrue);
      expect(ReadingRows.ayahIndexForRow(0), isNull);
    });

    test('Ayah đầu tiên nằm ngay sau phần dẫn đầu', () {
      expect(ReadingRows.rowForAyahIndex(0), 1);
      expect(ReadingRows.ayahIndexForRow(1), 0);
    });

    test('khứ hồi không đổi giá trị', () {
      for (final ayahIndex in [0, 1, 6, 285]) {
        expect(
          ReadingRows.ayahIndexForRow(
            ReadingRows.rowForAyahIndex(ayahIndex),
          ),
          ayahIndex,
        );
      }
    });

    test('hàng dẫn đầu trả null chứ KHÔNG trả số âm', () {
      // Trước F2 chỗ này là `max(0, row - 1)`: hàng header lặng lẽ biến
      // thành "Ayah 0". Đúng kết quả, nhưng vì kẹp chứ không vì phân
      // biệt — và cái kẹp đó là thứ sẽ sai khi có thêm hàng dẫn đầu.
      expect(ReadingRows.ayahIndexForRow(0), isNull);
      expect(ReadingRows.ayahIndexForRow(1), isNotNull);
    });
  });

  group('F2 — kích thước danh sách', () {
    test('số hàng = số Ayah + phần dẫn đầu', () {
      expect(ReadingRows.rowCountFor(7), 8); // Al-Fatihah
      expect(ReadingRows.rowCountFor(286), 287); // Al-Baqarah
    });

    test('hàng cuối cùng ứng với Ayah cuối cùng', () {
      const ayahCount = 7;
      expect(
        ReadingRows.lastRowFor(ayahCount),
        ReadingRows.rowForAyahIndex(ayahCount - 1),
      );
    });

    test('danh sách rỗng vẫn còn hàng dẫn đầu', () {
      expect(ReadingRows.rowCountFor(0), 1);
      expect(ReadingRows.lastRowFor(0), 0);
    });

    test('mọi hàng không dẫn đầu đều ánh xạ vào một Ayah hợp lệ', () {
      const ayahCount = 7;
      for (var row = 0; row <= ReadingRows.lastRowFor(ayahCount); row++) {
        final ayahIndex = ReadingRows.ayahIndexForRow(row);
        if (ayahIndex == null) continue;
        expect(ayahIndex, inInclusiveRange(0, ayahCount - 1));
      }
    });
  });
}
