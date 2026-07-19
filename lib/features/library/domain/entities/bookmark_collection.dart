/// Một bộ sưu tập Bookmark (Sprint 8 — DR-2026-0003 mục C). Chỉ áp
/// dụng cho Ayah (Bookmarks.collection_id) — không tổng quát hoá
/// cho Highlight/Note/Favorite trong phạm vi Sprint 8.
class BookmarkCollection {
  const BookmarkCollection({
    required this.id,
    required this.name,
    this.emoji,
    this.displayOrder = 0,
  });

  final String id;
  final String name;
  final String? emoji;
  final int displayOrder;
}
