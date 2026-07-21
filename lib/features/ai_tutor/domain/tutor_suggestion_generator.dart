import '../../analytics/domain/entities/learning_goal.dart';
import 'entities/tutor_action.dart';
import 'entities/tutor_context.dart';
import 'entities/tutor_suggestion.dart';

/// Hàm THUẦN sinh gợi ý từ TutorContext ĐÃ CÓ SẴN (tham số truyền
/// vào, không tự truy vấn) — cùng kỷ luật với
/// selectDueCardsOrdered/smart_deck_selector.dart/
/// learning_goal_calculator.dart: tách khỏi Repository để test trực
/// tiếp không cần DB.
///
/// MỖI điều kiện ở đây là NGƯỠNG/SO SÁNH đơn giản trên số liệu ĐÃ TÍNH
/// SẴN của Analytics (KHÔNG tính lại gì) — placeholder rõ ràng cho 1
/// AI thật thay thế ở sprint sau ("No AI model integration yet");
/// KHÔNG có gợi ý nào ứng với LearningGoalKind.weeklyStudyMinutes —
/// cố ý giữ số lượng gợi ý đồng thời ở mức vừa phải (mục tiêu Tuần ít
/// cấp bách hơn mục tiêu Ngày để nhắc mỗi ngày), không phải bỏ sót.
///
/// Sprint 15 Phase 3 mục 3: mỗi gợi ý (trừ [TutorSuggestionKind.
/// maintainStreak] — chỉ mang tính khích lệ, không có màn hình đích
/// tự nhiên) gắn kèm 1 [TutorAction] tĩnh. [reviewFrequentlyForgotten]
/// trỏ về [TutorActionDestination.flashcards] (không phải Smart Deck
/// riêng) vì SmartDeckType (Sprint 13) KHÔNG có mục "hay quên" —
/// dùng đích gần nghĩa nhất đã có, không bịa loại Smart Deck mới.
List<TutorSuggestion> computeTutorSuggestions(TutorContext context) {
  final suggestions = <TutorSuggestion>[];
  final stats = context.statistics;

  if (stats.dueToday > 0) {
    suggestions.add(
      TutorSuggestion(
        kind: TutorSuggestionKind.reviewDueCards,
        priority: TutorSuggestionPriority.high,
        relatedCount: stats.dueToday,
        action: const TutorAction(
          destination: TutorActionDestination.reviewSession,
        ),
      ),
    );
  }

  for (final goal in context.goals) {
    if (goal.isAchieved) continue;
    final remaining = goal.target - goal.current;
    if (goal.kind == LearningGoalKind.dailyStudyMinutes) {
      suggestions.add(
        TutorSuggestion(
          kind: TutorSuggestionKind.completeDailyStudyGoal,
          priority: TutorSuggestionPriority.medium,
          relatedCount: remaining,
          action: const TutorAction(
            destination: TutorActionDestination.learningSession,
          ),
        ),
      );
    } else if (goal.kind == LearningGoalKind.dailyReviews) {
      suggestions.add(
        TutorSuggestion(
          kind: TutorSuggestionKind.completeDailyReviewGoal,
          priority: TutorSuggestionPriority.medium,
          relatedCount: remaining,
          action: const TutorAction(
            destination: TutorActionDestination.reviewSession,
          ),
        ),
      );
    }
  }

  if (context.insights.frequentlyForgotten.isNotEmpty) {
    suggestions.add(
      TutorSuggestion(
        kind: TutorSuggestionKind.reviewFrequentlyForgotten,
        priority: TutorSuggestionPriority.high,
        relatedCount: context.insights.frequentlyForgotten.length,
        action: const TutorAction(
          destination: TutorActionDestination.flashcards,
        ),
      ),
    );
  }

  if (context.insights.weakRoots.isNotEmpty) {
    suggestions.add(
      TutorSuggestion(
        kind: TutorSuggestionKind.strengthenWeakRoots,
        priority: TutorSuggestionPriority.medium,
        relatedCount: context.insights.weakRoots.length,
        action: const TutorAction(
          destination: TutorActionDestination.weakCards,
        ),
      ),
    );
  }

  if (stats.readingStreakDays > 0) {
    suggestions.add(
      TutorSuggestion(
        kind: TutorSuggestionKind.maintainStreak,
        priority: TutorSuggestionPriority.low,
        relatedCount: stats.readingStreakDays,
        // KHÔNG có action — xem doc comment lớp này.
      ),
    );
  }

  return suggestions;
}
