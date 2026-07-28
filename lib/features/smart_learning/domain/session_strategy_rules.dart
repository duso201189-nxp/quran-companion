import '../../ai_tutor/domain/entities/tutor_suggestion.dart';
import 'entities/session_strategy.dart';

/// Ánh xạ TutorSuggestionKind (AI Tutor, Sprint 15) sang SessionStrategy
/// (Sprint 17 Phase 1) — QUY TẮC CỐ ĐỊNH, không AI. null cho
/// [TutorSuggestionKind.maintainStreak] — xem doc comment SessionStrategy.
SessionStrategy? strategyForSuggestionKind(TutorSuggestionKind kind) {
  return switch (kind) {
    TutorSuggestionKind.reviewDueCards => SessionStrategy.shortReview,
    TutorSuggestionKind.completeDailyReviewGoal => SessionStrategy.shortReview,
    TutorSuggestionKind.completeDailyStudyGoal => SessionStrategy.deepStudy,
    TutorSuggestionKind.strengthenWeakRoots => SessionStrategy.memorization,
    TutorSuggestionKind.reviewFrequentlyForgotten => SessionStrategy.recovery,
    TutorSuggestionKind.maintainStreak => null,
  };
}

/// Ước lượng thời lượng (phút) theo QUY TẮC CỐ ĐỊNH cho mỗi
/// SessionStrategy — xem doc comment LearningRecommendation.estimatedMinutes
/// (không đo từ dữ liệu thật, chỉ là hằng số hợp lý cho mỗi loại
/// phiên).
int estimatedMinutesFor(SessionStrategy strategy) {
  return switch (strategy) {
    SessionStrategy.shortReview => 10,
    SessionStrategy.deepStudy => 20,
    SessionStrategy.memorization => 15,
    SessionStrategy.recovery => 15,
  };
}
