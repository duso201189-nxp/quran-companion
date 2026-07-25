/// Loại nguồn văn bản đi kèm Ayah.
enum SourceType { translation, transliteration, tafsir }

/// Ánh xạ giá trị cột `translation_sources.type` sang [SourceType].
///
/// NƠI DUY NHẤT biết các chuỗi này (Sprint 30.2). Trước đây phép
/// `switch` nằm trong repository còn bộ lọc SQL viết chuỗi thẳng vào
/// truy vấn — hai chỗ mô tả cùng một sự thật, và chúng có thể lệch
/// nhau mà không ai phát hiện.
///
/// Chuỗi lạ (bộ dữ liệu mới hơn mã nguồn) -> [SourceType.translation],
/// giữ nguyên hành vi cũ: hiển thị được còn hơn biến mất.
const Map<String, SourceType> kSourceTypeByCode = {
  'translation': SourceType.translation,
  'transliteration': SourceType.transliteration,
  'tafsir': SourceType.tafsir,
};

/// RANH GIỚI ĐỌC (Sprint 30.2): các loại nguồn được phép đi theo
/// đường đọc — Ả Rập + phiên âm + bản dịch.
///
/// Tafsir CỐ Ý không nằm ở đây. Chú giải dài gấp hàng chục tới hàng
/// trăm lần một bản dịch; nạp kèm cả Surah (286 Ayah với Al-Baqarah)
/// biến việc mở trang đọc thành một lượt đọc hàng megabyte cho phần
/// văn bản không hề hiển thị. Xem `DR-2026-0006` quyết định D4.
const Set<SourceType> kReadingSourceTypes = {
  SourceType.transliteration,
  SourceType.translation,
};

/// Giá trị cột `type` KHÔNG thuộc đường đọc — dùng trực tiếp làm bộ
/// lọc SQL, dẫn xuất từ [kSourceTypeByCode] nên không thể lệch với
/// phép ánh xạ.
final List<String> kNonReadingSourceTypeCodes = [
  for (final entry in kSourceTypeByCode.entries)
    if (!kReadingSourceTypes.contains(entry.value)) entry.key,
];

/// Giá trị cột `type` ứng với [types] — dẫn xuất từ cùng
/// [kSourceTypeByCode], để nơi gọi nêu ý định bằng [SourceType] chứ
/// không viết chuỗi thẳng vào truy vấn (Sprint 31.2).
List<String> sourceTypeCodesFor(Set<SourceType> types) => [
      for (final entry in kSourceTypeByCode.entries)
        if (types.contains(entry.value)) entry.key,
    ];

/// Mã ngôn ngữ viết từ phải sang trái (ISO 639-1).
///
/// Sprint 30.1 — hướng chữ là THUỘC TÍNH CỦA NGÔN NGỮ, không phải của
/// một tính năng cụ thể, nên nó thuộc về domain chứ không nằm rải rác
/// trong widget. Trước đây `AyahCard` ép cứng `TextDirection.ltr` cho
/// mọi lớp dịch — một nguồn Tafsir tiếng Ả Rập (khả năng cao là nguồn
/// Tafsir đầu tiên) sẽ hiển thị sai hướng.
///
/// Danh sách giữ ở mức các ngôn ngữ RTL phổ biến có thật trong phạm vi
/// nội dung Qur'an; thêm ngôn ngữ = thêm mã vào đây, không sửa widget.
const Set<String> kRtlLanguageCodes = {'ar', 'fa', 'ur', 'he', 'ps', 'sd'};

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

  /// Văn bản của nguồn này viết từ phải sang trái hay không.
  ///
  /// Trả về `bool` chứ KHÔNG phải `TextDirection`: domain không được
  /// import Flutter (`PROJ-P-003`). Tầng trình bày tự quy đổi.
  bool get isRtl => kRtlLanguageCodes.contains(language);

  /// Nguồn này có phải một LỚP CỦA TRANG ĐỌC không.
  ///
  /// Tafsir trả về `false`: nó có đường nạp riêng, không đi kèm Ayah
  /// khi mở Surah (xem [kReadingSourceTypes]).
  bool get isReadingLayer => kReadingSourceTypes.contains(type);
}
