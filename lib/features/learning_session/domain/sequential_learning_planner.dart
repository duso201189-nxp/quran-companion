import 'learning_planner.dart';

/// Cài đặt tất định của LearningPlanner (Sprint 11 Phase 1) — duyệt
/// [order] theo thứ tự cố định, trả về hoạt động đầu tiên vừa CHƯA
/// hoàn thành (không có trong `completedThisSession`) vừa CÒN sẵn có;
/// tự động bỏ qua hoạt động không sẵn có ("skip unavailable"). null
/// khi không còn hoạt động nào thoả cả hai điều kiện.
class SequentialLearningPlanner implements LearningPlanner {
  const SequentialLearningPlanner({
    this.order = const [
      LearningActivityType.review,
      LearningActivityType.quiz,
      LearningActivityType.flashcard,
    ],
  });

  /// Thứ tự ưu tiên khi nhiều hoạt động cùng sẵn có. Có thể tuỳ chỉnh
  /// (vd. test cô lập từng nhánh), mặc định Review -> Quiz -> Flashcard.
  final List<LearningActivityType> order;

  @override
  LearningActivityType? next(LearningPlanContext context) {
    for (final activity in order) {
      if (context.completedThisSession.contains(activity)) continue;
      if (!_isAvailable(activity, context)) continue;
      return activity;
    }
    return null;
  }

  bool _isAvailable(LearningActivityType activity, LearningPlanContext c) =>
      switch (activity) {
        LearningActivityType.review => c.dueReviewCount > 0,
        LearningActivityType.quiz => c.quizAvailable,
        LearningActivityType.flashcard => (c.dueFlashcardCount ?? 0) > 0,
      };
}
