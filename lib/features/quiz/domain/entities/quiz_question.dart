/// Loại câu hỏi Quiz. Thêm loại mới KHÔNG cần sửa enum theo kiểu
/// exhaustive-switch bắt buộc — QuestionGenerator không switch trên
/// giá trị này (mỗi loại là 1 class riêng), enum chỉ để gắn nhãn/lọc
/// lịch sử sau này (DR-2026-0005 mục 5: "phải cắm được loại câu hỏi
/// mới mà không sửa code cũ").
enum QuizQuestionType {
  surahIdentification,
  ayahContinuation,
  translationMatching,
  verseRecognition,
}

/// Một câu hỏi trắc nghiệm đã sinh xong — 4 lựa chọn, đã trộn ngẫu
/// nhiên, đúng 1 đáp án đúng. Thuần Dart, không phụ thuộc Flutter.
class QuizQuestion {
  const QuizQuestion({
    required this.type,
    required this.promptText,
    required this.promptIsArabic,
    required this.options,
    required this.correctOptionIndex,
    required this.optionsAreArabic,
  });

  final QuizQuestionType type;

  /// Nội dung đề bài — Ayah (Ả Rập) hoặc tên Surah tuỳ loại câu hỏi.
  final String promptText;

  /// true = [promptText] cần hiển thị RTL/font Qur'an.
  final bool promptIsArabic;

  /// Đúng 4 lựa chọn, đã trộn — [correctOptionIndex] trỏ vào đây.
  final List<String> options;
  final int correctOptionIndex;

  /// true = mọi phần tử [options] cần hiển thị RTL/font Qur'an.
  final bool optionsAreArabic;
}
