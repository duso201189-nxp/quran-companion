import '../entities/quiz_result.dart';

/// Cổng lưu trữ kết quả Quiz (Sprint 10 Phase 4 — DR-2026-0005 mục
/// 5). Domain không biết Drift. CHỈ persist điểm/kết quả — câu hỏi
/// sinh động ở tầng domain khác (QuestionGenerator), không có Question
/// Bank, không lưu lại nội dung Ayah/câu hỏi ở đây.
abstract interface class QuizRepository {
  /// Lưu 1 kết quả Quiz đã hoàn thành. Trả về id bản ghi vừa tạo.
  Future<String> saveResult({
    required String quizType,
    int? surahId,
    required int score,
    required int total,
  });

  /// Lịch sử kết quả Quiz, mới nhất trước.
  Stream<List<QuizResult>> watchHistory();
}
