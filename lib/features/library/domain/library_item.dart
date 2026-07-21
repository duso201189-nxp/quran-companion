import '../../quran/domain/entities/ayah_search_result.dart';

/// Một dòng trong "Thư viện của tôi": header Ayah (tên Surah, số,
/// văn bản, bản dịch) cộng thông tin riêng của nhóm.
///
/// Đặt tên [LibraryItem] (không phải CollectionEntry) để mở rộng
/// về sau — thư viện có thể thêm nhóm mới mà không đổi kiểu này.
class LibraryItem {
  const LibraryItem({
    required this.ayah,
    required this.savedAt,
    this.note,
    this.highlightColors = const {},
  });

  /// Header nội dung Ayah — tái dùng kiểu của tìm kiếm.
  final AyahSearchResult ayah;

  /// Thời điểm lưu/cập nhật (epoch ms) — dùng để sắp mới nhất trước.
  final int savedAt;

  /// Nội dung ghi chú (chỉ nhóm Notes).
  final String? note;

  /// Các màu highlight của Ayah (chỉ nhóm Highlights).
  final Set<String> highlightColors;
}
