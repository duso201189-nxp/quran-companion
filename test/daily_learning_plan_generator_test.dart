import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/learning_journey/domain/daily_learning_plan_generator.dart';

TutorSuggestion _s(
  TutorSuggestionKind kind,
  TutorSuggestionPriority priority,
) =>
    TutorSuggestion(kind: kind, priority: priority);

void main() {
  group('computeDailyLearningPlan', () {
    test('danh sách rỗng -> steps rỗng, không lỗi', () {
      final plan = computeDailyLearningPlan([], DateTime(2026, 7, 21, 15, 30));
      expect(plan.steps, isEmpty);
    });

    test('date bị cắt về 00:00 (bỏ giờ/phút)', () {
      final plan = computeDailyLearningPlan([], DateTime(2026, 7, 21, 15, 30));
      expect(plan.date, DateTime(2026, 7, 21));
    });

    test('sắp xếp ĐÚNG thứ tự high -> medium -> low', () {
      final low =
          _s(TutorSuggestionKind.maintainStreak, TutorSuggestionPriority.low);
      final high = _s(
        TutorSuggestionKind.reviewDueCards,
        TutorSuggestionPriority.high,
      );
      final medium = _s(
        TutorSuggestionKind.completeDailyStudyGoal,
        TutorSuggestionPriority.medium,
      );

      final plan = computeDailyLearningPlan(
        [low, medium, high],
        DateTime(2026, 7, 21),
      );

      expect(plan.steps.map((s) => s.suggestion.kind), [
        TutorSuggestionKind.reviewDueCards,
        TutorSuggestionKind.completeDailyStudyGoal,
        TutorSuggestionKind.maintainStreak,
      ]);
    });

    test('order tăng dần ĐÚNG theo vị trí, bắt đầu từ 0', () {
      final plan = computeDailyLearningPlan(
        [
          _s(TutorSuggestionKind.reviewDueCards, TutorSuggestionPriority.high),
          _s(
            TutorSuggestionKind.strengthenWeakRoots,
            TutorSuggestionPriority.medium,
          ),
          _s(TutorSuggestionKind.maintainStreak, TutorSuggestionPriority.low),
        ],
        DateTime(2026, 7, 21),
      );

      expect(plan.steps.map((s) => s.order), [0, 1, 2]);
    });

    test(
        'GIỮ NGUYÊN thứ tự ban đầu giữa các gợi ý CÙNG mức ưu tiên '
        '(ổn định)', () {
      final a = _s(
        TutorSuggestionKind.completeDailyStudyGoal,
        TutorSuggestionPriority.medium,
      );
      final b = _s(
        TutorSuggestionKind.completeDailyReviewGoal,
        TutorSuggestionPriority.medium,
      );
      final c = _s(
        TutorSuggestionKind.strengthenWeakRoots,
        TutorSuggestionPriority.medium,
      );

      final plan = computeDailyLearningPlan([a, b, c], DateTime(2026, 7, 21));

      expect(plan.steps.map((s) => s.suggestion.kind), [
        TutorSuggestionKind.completeDailyStudyGoal,
        TutorSuggestionKind.completeDailyReviewGoal,
        TutorSuggestionKind.strengthenWeakRoots,
      ]);
    });

    test(
        'KHÔNG tính lại/đổi priority hay bất kỳ trường nào của '
        'TutorSuggestion gốc — chỉ bọc lại', () {
      final s = _s(
        TutorSuggestionKind.reviewDueCards,
        TutorSuggestionPriority.high,
      );

      final plan = computeDailyLearningPlan([s], DateTime(2026, 7, 21));

      expect(plan.steps.single.suggestion, same(s));
    });
  });
}
