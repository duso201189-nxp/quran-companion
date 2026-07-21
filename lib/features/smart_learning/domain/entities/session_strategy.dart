/// Chiến lược 1 phiên học (Sprint 17 Phase 1) — 4 ví dụ nêu trong yêu
/// cầu, mỗi giá trị ứng ĐÚNG 1 nhóm TutorSuggestionKind đã có sẵn từ
/// AI Tutor (qua LearningJourney -> DailyLearningPlan -> JourneyStep
/// -> TutorSuggestion) — xem
/// session_strategy_rules.dart để biết ánh xạ cụ thể. KHÔNG có chiến
/// lược nào tương ứng TutorSuggestionKind.maintainStreak — gợi ý đó
/// chỉ mang tính khích lệ, không có "cách học" cụ thể nào đi kèm
/// (cùng lý do nó không có TutorAction — xem AI Tutor Sprint 15 Phase
/// 3).
enum SessionStrategy {
  /// Ôn nhanh — ứng với thẻ đến hạn/mục tiêu ôn hằng ngày
  /// (reviewDueCards/completeDailyReviewGoal).
  shortReview,

  /// Học sâu — ứng với mục tiêu học hằng ngày chưa đạt
  /// (completeDailyStudyGoal).
  deepStudy,

  /// Ghi nhớ — ứng với gốc từ yếu cần củng cố (strengthenWeakRoots).
  memorization,

  /// Phục hồi — ứng với thẻ hay quên cần ôn lại tập trung
  /// (reviewFrequentlyForgotten).
  recovery,
}
