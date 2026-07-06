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
}
