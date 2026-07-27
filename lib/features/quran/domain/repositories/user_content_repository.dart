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

  // ---- Thư viện của tôi: xem TẤT CẢ chú thích (không theo Surah) ----
  // Mọi stream: chỉ bản ghi còn sống (deleted_at null), mới nhất
  // trước. Trả về kiểu Dart thuần (record) — domain không biết Drift.

  /// Mọi Ayah đã bookmark. savedAt = created_at (epoch ms).
  Stream<List<({int ayahId, int savedAt})>> watchAllBookmarks();

  /// Mọi Ayah đã yêu thích. savedAt = created_at (epoch ms).
  Stream<List<({int ayahId, int savedAt})>> watchAllFavorites();

  /// Mọi Ayah có ghi chú kèm nội dung. savedAt = updated_at.
  Stream<List<({int ayahId, String note, int savedAt})>> watchAllNotes();

  /// Mọi Ayah có highlight, gộp các màu theo từng Ayah.
  /// savedAt = updated_at mới nhất của Ayah đó.
  Stream<List<({int ayahId, Set<String> colors, int savedAt})>>
      watchAllHighlights();

  /// Mọi Ayah có trạng thái 'review' — nguồn dữ liệu cho Revision
  /// Queue (DR-2026-0004 mục 3: tái dùng UserContentRepository,
  /// không có repository/bảng riêng). savedAt = updated_at.
  Stream<List<({int ayahId, int savedAt})>> watchAllReviewAyahs();
}
