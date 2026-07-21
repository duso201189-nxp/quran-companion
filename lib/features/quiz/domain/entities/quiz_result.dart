/// Một kết quả Quiz đã lưu (Sprint 10 Phase 4 — DR-2026-0005 mục 5).
/// Chỉ điểm số — KHÔNG mang câu hỏi/nội dung Ayah.
class QuizResult {
  const QuizResult({
    required this.id,
    required this.quizType,
    this.surahId,
    required this.score,
    required this.total,
    required this.takenAt,
  });

  final String id;
  final String quizType;
  final int? surahId;
  final int score;
  final int total;

  /// Epoch ms UTC.
  final int takenAt;
}
