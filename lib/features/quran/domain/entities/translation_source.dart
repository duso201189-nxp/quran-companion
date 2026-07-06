/// Loại nguồn văn bản đi kèm Ayah.
enum SourceType { translation, transliteration, tafsir }

/// Một nguồn bản dịch / phiên âm / tafsir.
///
/// Nguồn là DỮ LIỆU: thêm bản dịch tiếng Việt mới, thêm tafsir...
/// chỉ cần import lại file data — không sửa mã nguồn.
class TranslationSource {
  const TranslationSource({
    required this.id,
    required this.code,
    required this.name,
    required this.language,
    required this.type,
    required this.displayOrder,
    this.author,
    this.license,
    this.sourceUrl,
    this.version,
    this.updatedAt,
  });

  final int id;

  /// Định danh ổn định: 'vi_main', 'en_sahih', 'translit_latin'...
  final String code;
  final String name;
  final String language;
  final SourceType type;
  final int displayOrder;
  final String? author;

  // Metadata nguồn — hiển thị trong màn hình Giới thiệu/attribution.
  final String? license;
  final String? sourceUrl;
  final String? version;
  final String? updatedAt;
}
