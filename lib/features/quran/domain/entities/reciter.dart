/// Một Qari (người tụng đọc). Là DỮ LIỆU trong bảng `reciters` —
/// thêm Qari mới không cần sửa mã nguồn.
class Reciter {
  const Reciter({
    required this.code,
    required this.name,
    required this.audioUrlTemplate,
    this.nameArabic,
    this.bitrateKbps,
    this.license,
    this.sourceUrl,
  });

  final String code;
  final String name;
  final String? nameArabic;
  final String audioUrlTemplate;
  final int? bitrateKbps;

  // Metadata ghi nguồn (Sprint 33.0). Hai cột `license`/`source_url` ĐÃ
  // có sẵn trong bảng `reciters` từ đầu nhưng chưa bao giờ được đọc lên
  // — audio là nội dung của bên thứ ba giống hệt bản dịch, nên nó phải
  // xuất hiện trong màn hình Ghi nguồn cùng một cách. Không đổi schema.
  final String? license;
  final String? sourceUrl;
}
