/// Một Ayah rút gọn cho mục đích sinh câu hỏi Quiz — chỉ các trường
/// QuestionGenerator cần, thuần Dart.
class QuizAyahText {
  const QuizAyahText({
    required this.ayahId,
    required this.ayahNumber,
    required this.arabic,
    this.translation,
  });

  final int ayahId;

  /// Số Ayah trong Surah (1-based) — dùng để tìm Ayah kế tiếp
  /// (Ayah continuation) qua chỉ số trong [QuizSurahAyahs.ayahs].
  final int ayahNumber;
  final String arabic;
  final String? translation;
}

/// Ayah của một Surah, đã sắp theo ayahNumber tăng dần — nhóm theo
/// Surah để QuestionGenerator tìm được "Ayah kế tiếp" (liền kề trong
/// cùng nhóm) mà không cần biết gì về database.
class QuizSurahAyahs {
  const QuizSurahAyahs({
    required this.surahId,
    required this.surahNameLatin,
    required this.ayahs,
  });

  final int surahId;
  final String surahNameLatin;
  final List<QuizAyahText> ayahs;
}

/// Tập nội dung Qur'an tạm thời để sinh câu hỏi — do tầng Provider
/// nạp từ QuranRepository (nhóm A) rồi truyền vào QuestionGenerator.
/// KHÔNG được lưu trữ lại (không nhân bản nội dung Qur'an) — chỉ tồn
/// tại trong bộ nhớ cho một phiên Quiz.
class QuizContentPool {
  const QuizContentPool(this.surahs);

  final List<QuizSurahAyahs> surahs;

  bool get isEmpty => surahs.isEmpty;
}
