/// Bố cục HÀNG của danh sách đọc — "hệ C" trong
/// `docs/knowledge/quran_index_conventions.md`.
///
/// Hệ C là khái niệm của TRÌNH BÀY, không phải của nội dung: nó nói
/// "hàng thứ mấy trong `ScrollablePositionedList`", không nói "Ayah thứ
/// mấy". Vì thế tệp này nằm ở tầng presentation dù không import Flutter.
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
/// không ném lỗi, không có test nào đỏ. Cùng loại nguy hiểm với cảnh
/// báo 0-based ở `study_sessions`.
///
/// Sau F2, [leadingRows] là con số duy nhất phải đổi.
abstract final class ReadingRows {
  /// Số hàng đứng TRƯỚC Ayah đầu tiên.
  ///
  /// Hôm nay: đúng một header Surah (kèm Basmalah trang trí nếu có).
  /// Basmalah 2.0 sẽ nâng con số này lên 2 với các Surah có phần mở đầu
  /// riêng — và khi đó nó phải thành một hàm của Surah, không còn là
  /// hằng. Chỗ đó là đây, không phải năm chỗ trong `ReadingScreen`.
  static const int leadingRows = 1;

  /// Tổng số hàng cho danh sách có [ayahCount] Ayah.
  static int rowCountFor(int ayahCount) => ayahCount + leadingRows;

  /// Chỉ số hàng cuối cùng. Danh sách luôn có ít nhất phần header, nên
  /// giá trị nhỏ nhất là 0.
  static int lastRowFor(int ayahCount) => rowCountFor(ayahCount) - 1;

  /// Hàng này thuộc phần dẫn đầu (header) chứ không phải một Ayah?
  static bool isLeading(int row) => row < leadingRows;

  /// Ayah thứ [ayahIndex] (0-based, hệ B) nằm ở hàng nào.
  static int rowForAyahIndex(int ayahIndex) => ayahIndex + leadingRows;

  /// Hàng [row] ứng với Ayah 0-based nào — `null` nếu đó là hàng dẫn
  /// đầu. Trả `null` thay vì một số âm: "đây không phải Ayah" là một
  /// câu trả lời, không phải một lỗi tính toán cần kẹp về 0.
  static int? ayahIndexForRow(int row) =>
      isLeading(row) ? null : row - leadingRows;
}
