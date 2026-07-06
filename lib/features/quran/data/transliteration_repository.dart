import '../../../shared/utils/transliteration.dart';

/// Nguồn chân lý DUY NHẤT cho phiên âm trong app.
///
/// Dataset chuẩn: Quran.com word-by-word (tool/data/transliteration.json,
/// đóng gói vào quran.sqlite bởi tool/build_quran_db.py). Muốn đổi bộ
/// phiên âm chỉ cần thay dataset + build lại data — KHÔNG sửa code.
///
/// [normalize] là chốt an toàn cuối: dataset chuẩn đi qua nguyên vẹn;
/// dữ liệu định dạng cũ (Tanzil HTML) — ví dụ file data cũ trên máy
/// người dùng chưa cập nhật — vẫn được chuyển sang Unicode sạch.
class TransliterationRepository {
  const TransliterationRepository();

  /// Mã nguồn văn bản của phiên âm trong bảng translation_sources.
  static const String sourceCode = 'translit_latin';

  /// Loại nguồn trong translation_sources.type.
  static const String sourceType = 'transliteration';

  /// Chuẩn hóa một chuỗi phiên âm trước khi hiển thị.
  String normalize(String raw) => cleanTransliteration(raw);
}
