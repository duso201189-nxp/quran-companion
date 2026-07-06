import '../entities/ayah_annotation.dart';

/// Cổng dữ liệu người dùng gắn với Ayah: bookmark, highlight,
/// ghi chú, trạng thái học. Domain không biết Drift.
///
/// Mọi thao tác ghi là toggle/upsert idempotent, soft-delete,
/// đánh dấu is_dirty — sẵn sàng cho SyncEngine (Bước 11).
abstract interface class UserContentRepository {
  /// Stream chú thích của các Ayah cho trước — UI phản ứng tức thời
  /// khi người dùng thao tác (Drift watch phía dưới).
  /// Ayah không có chú thích sẽ không có key trong map.
  Stream<Map<int, AyahAnnotation>> watchAnnotationsForAyahs(
    List<int> ayahIds,
  );

  /// Bookmark 1 chạm: chưa có -> thêm; đang có -> bỏ.
  Future<void> toggleBookmark(int ayahId);

  /// Yêu thích 1 chạm: chưa có -> thêm; đang có -> bỏ.
  Future<void> toggleFavorite(int ayahId);

  /// Bật/tắt một màu highlight. Một Ayah có thể nhiều màu.
  Future<void> toggleHighlight(int ayahId, String colorName);

  /// Lưu ghi chú (Markdown cơ bản). Nội dung rỗng = xóa ghi chú.
  Future<void> saveNote(int ayahId, String content);

  /// Đặt trạng thái học. [AyahStatus.none] = xóa trạng thái.
  Future<void> setStatus(int ayahId, AyahStatus status);
}
