/// Một đoạn văn bản PHỦ một Ayah, kèm phạm vi thật của nó.
///
/// Sprint 32.0 — chú giải thường viết theo ĐOẠN nhiều câu, không theo
/// từng câu. Trả kèm [startAyahId] để tầng hiển thị nói đúng sự thật
/// ("chú giải cho 2:8–2:12") thay vì ngầm ám chỉ đoạn này chỉ nói về
/// Ayah đang mở.
class CoveringText {
  const CoveringText({
    required this.sourceCode,
    required this.text,
    required this.startAyahId,
  });

  final String sourceCode;
  final String text;

  /// Ayah mở đầu đoạn. Bằng chính Ayah đang xem khi nguồn viết theo
  /// từng câu.
  final int startAyahId;
}
