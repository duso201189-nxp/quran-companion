import 'reciter.dart';
import 'translation_source.dart';

/// Loại nội dung của một mục ghi nguồn.
///
/// KHÔNG dùng lại [SourceType]: ghi nguồn phải bao được cả những thứ
/// không nằm trong bảng `translation_sources` — văn bản Ả Rập gốc (mô
/// tả trong bảng `meta`) và các bản thu âm (bảng `reciters`).
enum AttributionKind { quranText, transliteration, translation, tafsir, audio }

const Map<SourceType, AttributionKind> _kindBySourceType = {
  SourceType.transliteration: AttributionKind.transliteration,
  SourceType.translation: AttributionKind.translation,
  SourceType.tafsir: AttributionKind.tafsir,
};

/// Một mục trong màn hình Ghi nguồn (Sprint 33.0).
///
/// HÌNH DẠNG CHUNG cho ba nguồn dữ liệu khác nhau, để tầng trình bày
/// chỉ có MỘT nhánh dựng. Nếu không có kiểu này thì màn hình phải viết
/// riêng phần dựng cho văn bản Ả Rập, cho bản dịch và cho Qari — tức là
/// giao diện ép cứng theo loại nguồn, đúng thứ mà `DR-2026-0006` D3 đã
/// loại bỏ khỏi trang đọc.
///
/// Domain thuần: không import Flutter (`PROJ-P-003`). [kind] là dữ liệu,
/// tầng trình bày tự quy đổi ra nhãn đã bản địa hoá và biểu tượng.
///
/// HAI TRƯỜNG CÒN THIẾU so với đặc tả Sprint 33.0 — `organization` và
/// `description` — cố ý KHÔNG có mặt ở đây. Bảng `translation_sources`
/// không có cột nào chứa chúng, và thêm cột là thay đổi schema nhóm A,
/// tức phải dừng lại hỏi trước (`PROJ-P-002`). Bịa ra chúng trong tầng
/// trình bày sẽ vi phạm chính yêu cầu "không ép cứng giao diện" của
/// sprint này, nên chúng được nêu thành quyết định chờ duyệt thay vì
/// lặng lẽ bỏ qua.
class AttributionEntry {
  const AttributionEntry({
    required this.kind,
    required this.name,
    this.author,
    this.language,
    this.version,
    this.license,
    this.sourceUrl,
    this.updatedAt,
  });

  /// Nguồn văn bản (bản dịch / phiên âm / tafsir).
  factory AttributionEntry.fromTranslationSource(TranslationSource source) {
    return AttributionEntry(
      // Kiểu lạ (bộ dữ liệu mới hơn mã nguồn) -> `translation`, cùng
      // quy ước dự phòng với `kSourceTypeByCode`.
      kind: _kindBySourceType[source.type] ?? AttributionKind.translation,
      name: source.name,
      author: source.author,
      language: source.language,
      version: source.version,
      license: source.license,
      sourceUrl: source.sourceUrl,
      updatedAt: source.updatedAt,
    );
  }

  /// Một Qari.
  ///
  /// [author] chỉ nhận tên Ả Rập, và chỉ khi nó KHÁC [name]: nếu bản
  /// dữ liệu không có tên Ả Rập thì lặp lại tên Latin ở dòng "Tác giả"
  /// chẳng thêm thông tin gì, chỉ thêm một dòng.
  ///
  /// [language] cố định 'ar': bản thu là tiếng Ả Rập theo định nghĩa,
  /// không phải một giá trị bị thiếu trong dữ liệu.
  factory AttributionEntry.fromReciter(Reciter reciter) {
    return AttributionEntry(
      kind: AttributionKind.audio,
      name: reciter.name,
      author: reciter.nameArabic == reciter.name ? null : reciter.nameArabic,
      language: 'ar',
      license: reciter.license,
      sourceUrl: reciter.sourceUrl,
    );
  }

  final AttributionKind kind;
  final String name;
  final String? author;

  /// Mã ngôn ngữ ISO 639-1.
  final String? language;
  final String? version;
  final String? license;
  final String? sourceUrl;
  final String? updatedAt;

  /// [name] có viết bằng chữ viết phải-sang-trái không.
  bool get isNameRtl => containsRtlScript(name);

  /// [author] có viết bằng chữ viết phải-sang-trái không.
  bool get isAuthorRtl => author != null && containsRtlScript(author!);
}

/// Chuỗi có chứa ký tự thuộc chữ viết phải-sang-trái không.
///
/// CỐ Ý KHÁC [TranslationSource.isRtl], vốn suy ra hướng chữ từ mã
/// NGÔN NGỮ. Quy tắc đó đúng cho phần thân văn bản — thân văn bản viết
/// bằng chính ngôn ngữ của nguồn. Nhưng màn hình Ghi nguồn hiển thị
/// TÊN RIÊNG, và tên không nhất thiết cùng chữ viết với nội dung:
/// bản thu của "Mishary Rashid Alafasy" là tiếng Ả Rập (`language`
/// = 'ar') trong khi tên hiển thị là chữ Latin. Dùng quy tắc theo ngôn
/// ngữ ở đây làm dấu ngoặc và chấm câu của tên Latin nhảy sai chỗ.
///
/// Phạm vi: Ả Rập (kèm phần bổ sung/mở rộng và dạng trình bày) và
/// Do Thái — đủ cho mọi chữ viết RTL mà [kRtlLanguageCodes] nêu.
bool containsRtlScript(String text) {
  for (final rune in text.runes) {
    if ((rune >= 0x0590 && rune <= 0x08FF) ||
        (rune >= 0xFB1D && rune <= 0xFDFF) ||
        (rune >= 0xFE70 && rune <= 0xFEFF)) {
      return true;
    }
  }
  return false;
}
