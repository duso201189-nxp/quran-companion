/// Trạng thái học của một Ayah (không có = chưa đọc).
enum AyahStatus { none, learning, learned, review }

/// 6 màu highlight mặc định (tên lưu trong database; màu thật do
/// tầng UI ánh xạ — data không dính Flutter).
const List<String> kHighlightColorNames = [
  'amber',
  'green',
  'blue',
  'pink',
  'orange',
  'purple',
];

/// Toàn bộ chú thích người dùng gắn với một Ayah.
class AyahAnnotation {
  const AyahAnnotation({
    this.bookmarked = false,
    this.favorited = false,
    this.highlightColors = const {},
    this.note,
    this.status = AyahStatus.none,
  });

  final bool bookmarked;
  final bool favorited;
  final Set<String> highlightColors;
  final String? note;
  final AyahStatus status;

  bool get isEmpty =>
      !bookmarked &&
      !favorited &&
      highlightColors.isEmpty &&
      note == null &&
      status == AyahStatus.none;

  static const AyahAnnotation empty = AyahAnnotation();

  /// So sánh theo GIÁ TRỊ (Sprint 25.4) — để tầng UI dùng được
  /// `ref.watch(provider.select(...))`: khi chú thích của MỘT Ayah đổi,
  /// chỉ Ayah đó dựng lại, các Ayah khác trong Surah giữ nguyên. Không
  /// có `==` thì mỗi lần đọc lại sinh instance mới và `select` mất tác
  /// dụng.
  ///
  /// So sánh Set bằng tay (độ dài + containsAll) thay vì `setEquals`
  /// của Flutter: entity domain KHÔNG được import Flutter (PROJ-P-003).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahAnnotation &&
          other.bookmarked == bookmarked &&
          other.favorited == favorited &&
          other.note == note &&
          other.status == status &&
          other.highlightColors.length == highlightColors.length &&
          other.highlightColors.containsAll(highlightColors);

  @override
  int get hashCode => Object.hash(
        bookmarked,
        favorited,
        note,
        status,
        Object.hashAllUnordered(highlightColors),
      );
}
