/// Tóm tắt tích luỹ của một Learning Session — thuần dữ liệu đọc từ
/// kết quả từng module khi hoạt động của module đó hoàn thành. KHÔNG
/// tự tính lại điểm/kết quả — mọi số liệu ở đây được SAO CHÉP từ
/// trạng thái module tương ứng (Review/Quiz/Flashcard) tại thời điểm
/// hoàn thành, không suy luận độc lập (tránh lặp lại lỗi hai nguồn
/// dữ liệu không khớp mà DR-2026-0004 từng phải sửa cho streak).
class LearningSessionSummary {
  const LearningSessionSummary({
    this.reviewCardsCompleted = 0,
    this.quizScore,
    this.quizTotal,
    this.flashcardsCompleted = 0,
  });

  /// Số thẻ Review đã ôn trong phiên — suy ra từ chênh lệch
  /// dueReviewCount trước/sau hoạt động Review (Review Session không
  /// tự đếm, không bị sửa để thêm bộ đếm này).
  final int reviewCardsCompleted;

  /// null = Quiz chưa hoàn thành trong phiên này.
  final int? quizScore;
  final int? quizTotal;

  /// Số Flashcard đã ôn trong phiên (Sprint 13 Phase 2) — cùng cách
  /// suy ra chênh lệch trước/sau [reviewCardsCompleted] dùng.
  final int flashcardsCompleted;

  LearningSessionSummary copyWith({
    int? reviewCardsCompleted,
    int? quizScore,
    int? quizTotal,
    int? flashcardsCompleted,
  }) =>
      LearningSessionSummary(
        reviewCardsCompleted: reviewCardsCompleted ?? this.reviewCardsCompleted,
        quizScore: quizScore ?? this.quizScore,
        quizTotal: quizTotal ?? this.quizTotal,
        flashcardsCompleted: flashcardsCompleted ?? this.flashcardsCompleted,
      );
}
