import '../entities/bookmark_collection.dart';

/// Cổng dữ liệu bộ sưu tập Bookmark (Sprint 8 — DR-2026-0003 mục
/// C). Database KHÔNG có ràng buộc khoá ngoại giữa
/// bookmarks.collection_id và bookmark_collections.id (không có
/// tiền lệ FK khai báo ở Drift trong schema này) — tầng repository
/// này CHỊU TRÁCH NHIỆM đảm bảo toàn vẹn: không gán vào collection
/// không tồn tại, và gỡ tham chiếu khi collection bị xóa.
abstract interface class BookmarkCollectionRepository {
  Future<String> createCollection({required String name, String? emoji});

  Future<void> renameCollection(String collectionId, String name);

  Future<void> setEmoji(String collectionId, String? emoji);

  /// Gán lại displayOrder theo đúng thứ tự [orderedIds] (0-based).
  Future<void> reorderCollections(List<String> orderedIds);

  /// Xóa mềm 1 bộ sưu tập VÀ gỡ collection_id khỏi mọi bookmark
  /// đang trỏ tới nó (không có FK cascade ở DB — tầng này tự đảm
  /// bảo không còn tham chiếu "treo").
  Future<void> deleteCollection(String collectionId);

  Stream<List<BookmarkCollection>> watchAllCollections();

  /// Gán 1 Ayah đã bookmark vào 1 bộ sưu tập.
  ///
  /// Ném [ArgumentError] nếu [collectionId] không tồn tại hoặc đã
  /// bị xóa, và [StateError] nếu Ayah đó chưa được bookmark — cả
  /// hai là kiểm tra toàn vẹn thay cho ràng buộc FK không có ở DB.
  Future<void> assignBookmark(int ayahId, String collectionId);

  /// Gỡ 1 Ayah khỏi bộ sưu tập hiện tại (collection_id -> null).
  /// Không lỗi nếu Ayah chưa từng được gán.
  Future<void> unassignBookmark(int ayahId);

  /// Mọi Ayah trong 1 bộ sưu tập (collection_id = [collectionId]),
  /// chỉ bookmark còn sống.
  Stream<List<int>> watchAyahsInCollection(String collectionId);
}
