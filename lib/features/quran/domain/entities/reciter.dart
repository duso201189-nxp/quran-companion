/// Một Qari (người tụng đọc). Là DỮ LIỆU trong bảng `reciters` —
/// thêm Qari mới không cần sửa mã nguồn.
class Reciter {
  const Reciter({
    required this.code,
    required this.name,
    required this.audioUrlTemplate,
    this.nameArabic,
    this.bitrateKbps,
  });

  final String code;
  final String name;
  final String? nameArabic;
  final String audioUrlTemplate;
  final int? bitrateKbps;
}
