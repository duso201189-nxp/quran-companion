import '../../domain/basmalah.dart';

/// Bố cục HÀNG của danh sách đọc — "hệ C" trong
/// `docs/knowledge/quran_index_conventions.md`.
///
/// Hệ C là khái niệm của TRÌNH BÀY, không phải của nội dung: nó nói
/// "hàng thứ mấy trong `ScrollablePositionedList`", không nói "Ayah thứ
/// mấy". Vì thế tệp này nằm ở tầng presentation dù không import Flutter.
///
/// ## Bố cục
///
/// ```
/// hàng 0            header Surah (tên, nơi giáng, số Ayah)
/// hàng 1            phần mở đầu — CHỈ với Surah có Basmalah tách rời
/// hàng kế tiếp...   từng Ayah một
/// ```
///
/// ## Sprint F2 — vì sao đáng có tên
///
/// Trước F2, phép quy đổi Ayah ↔ hàng được viết tay ở NĂM chỗ tách rời:
/// `itemCount`, `itemBuilder`, `initialScrollIndex`, `_onPositionsChanged`
/// và lệnh cuộn theo audio. Không chỗ nào phát biểu hợp đồng "hàng 0 là
/// header"; cả năm chỉ cùng giả định như vậy.
///
/// Điều đó đủ dùng cho tới khi Basmalah 2.0 biến phần mở đầu thành một
/// HÀNG riêng — lúc ấy cả năm phải đổi, và bốn trong năm chỗ hỏng LẶNG
/// LẼ: một `- 1` bị quên chỉ làm vị trí đọc lưu xuống đĩa lệch một Ayah,
/// không ném lỗi, không có test nào đỏ.
///
/// ## Sprint BM2 — điều đó vừa xảy ra
///
/// Số hàng dẫn đầu giờ phụ thuộc [SurahOpening], nên [leadingRowsFor]
/// thay cho hằng cũ. Nhờ F2 đã gom sẵn, đây là một lần đổi CHỮ KÝ ở một
/// tệp, không phải một cuộc truy lùng năm chỗ.
abstract final class ReadingRows {
  /// Header Surah — luôn đúng một hàng, mọi Surah, kể cả At-Tawbah.
  static const int headerRows = 1;

  /// Số hàng đứng TRƯỚC Ayah đầu tiên: header, cộng phần mở đầu nếu có.
  ///
  /// Điều kiện "có phần mở đầu riêng" đi qua [hasSeparateOpening] —
  /// cùng hàm mà playlist audio dùng, nên hai bên không thể lệch nhau.
  static int leadingRowsFor(SurahOpening opening) =>
      headerRows + (hasSeparateOpening(opening) ? 1 : 0);

  /// Hàng của phần mở đầu — `null` nếu Surah không có phần mở đầu riêng.
  ///
  /// Luôn nằm ngay sau header, nên giá trị là [headerRows]. Trả về qua
  /// hàm chứ không để bên gọi tự viết `1`: đó chính là loại hằng số ma
  /// mà F2/BM2 đi gỡ.
  static int? openingRowFor(SurahOpening opening) =>
      hasSeparateOpening(opening) ? headerRows : null;

  /// Tổng số hàng.
  static int rowCountFor({
    required SurahOpening opening,
    required int ayahCount,
  }) =>
      ayahCount + leadingRowsFor(opening);

  /// Chỉ số hàng cuối cùng. Danh sách luôn có ít nhất header, nên giá
  /// trị nhỏ nhất là 0.
  static int lastRowFor({
    required SurahOpening opening,
    required int ayahCount,
  }) =>
      rowCountFor(opening: opening, ayahCount: ayahCount) - 1;

  /// Hàng này thuộc phần dẫn đầu (header hoặc phần mở đầu) chứ không
  /// phải một Ayah?
  static bool isLeading({
    required SurahOpening opening,
    required int row,
  }) =>
      row < leadingRowsFor(opening);

  /// Ayah thứ [ayahIndex] (0-based, hệ B) nằm ở hàng nào.
  static int rowForAyahIndex({
    required SurahOpening opening,
    required int ayahIndex,
  }) =>
      ayahIndex + leadingRowsFor(opening);

  /// Hàng [row] ứng với Ayah 0-based nào — `null` nếu đó là hàng dẫn
  /// đầu. Trả `null` thay vì một số âm: "đây không phải Ayah" là một
  /// câu trả lời, không phải một lỗi tính toán cần kẹp về 0.
  static int? ayahIndexForRow({
    required SurahOpening opening,
    required int row,
  }) {
    final leading = leadingRowsFor(opening);
    return row < leading ? null : row - leading;
  }
}
