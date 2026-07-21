import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/journey_step.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/session_strategy.dart';
import 'package:quran_companion/features/smart_learning/domain/smart_learning_session_generator.dart';

const _emptyContext = TutorContext(
  statistics: LearningStatistics(
    cardsStudied: 0,
    dueToday: 0,
    reviewsToday: 0,
    accuracy: 0,
    averageEase: 2.5,
    averageInterval: 1,
    readingStreakDays: 0,
    longestReadingStreakDays: 0,
  ),
  goals: [],
  achievements: [],
  insights: PerformanceInsights(
    weakRoots: [],
    difficultLemmas: [],
    frequentlyForgotten: [],
    fastestImproving: [],
  ),
);

TutorSuggestion _sug(TutorSuggestionKind kind) => TutorSuggestion(
      kind: kind,
      priority: TutorSuggestionPriority.medium,
    );

LearningJourney _journeyWith(
  List<TutorSuggestionKind> kinds, {
  DateTime? date,
}) {
  final steps = [
    for (var i = 0; i < kinds.length; i++)
      JourneyStep(order: i, suggestion: _sug(kinds[i])),
  ];
  return LearningJourney(
    context: _emptyContext,
    todayPlan:
        DailyLearningPlan(date: date ?? DateTime(2026, 7, 21), steps: steps),
    insights: const <TutorInsight>[],
  );
}

void main() {
  group('computeSmartLearningSession', () {
    test('todayPlan.steps rỗng -> recommendations rỗng, không lỗi', () {
      final session = computeSmartLearningSession(
        _journeyWith(const []),
        DateTime(2026, 7, 21, 15, 30),
      );
      expect(session.recommendations, isEmpty);
    });

    test('date bị cắt về 00:00 (bỏ giờ/phút)', () {
      final session = computeSmartLearningSession(
        _journeyWith(const []),
        DateTime(2026, 7, 21, 15, 30),
      );
      expect(session.date, DateTime(2026, 7, 21));
    });

    test('reviewDueCards -> shortReview', () {
      final session = computeSmartLearningSession(
        _journeyWith([TutorSuggestionKind.reviewDueCards]),
        DateTime(2026, 7, 21),
      );
      expect(
        session.recommendations.single.strategy,
        SessionStrategy.shortReview,
      );
    });

    test('completeDailyReviewGoal -> shortReview', () {
      final session = computeSmartLearningSession(
        _journeyWith([TutorSuggestionKind.completeDailyReviewGoal]),
        DateTime(2026, 7, 21),
      );
      expect(
        session.recommendations.single.strategy,
        SessionStrategy.shortReview,
      );
    });

    test('completeDailyStudyGoal -> deepStudy', () {
      final session = computeSmartLearningSession(
        _journeyWith([TutorSuggestionKind.completeDailyStudyGoal]),
        DateTime(2026, 7, 21),
      );
      expect(
        session.recommendations.single.strategy,
        SessionStrategy.deepStudy,
      );
    });

    test('strengthenWeakRoots -> memorization', () {
      final session = computeSmartLearningSession(
        _journeyWith([TutorSuggestionKind.strengthenWeakRoots]),
        DateTime(2026, 7, 21),
      );
      expect(
        session.recommendations.single.strategy,
        SessionStrategy.memorization,
      );
    });

    test('reviewFrequentlyForgotten -> recovery', () {
      final session = computeSmartLearningSession(
        _journeyWith([TutorSuggestionKind.reviewFrequentlyForgotten]),
        DateTime(2026, 7, 21),
      );
      expect(session.recommendations.single.strategy, SessionStrategy.recovery);
    });

    test(
        'maintainStreak -> KHÔNG sinh đề xuất nào (chỉ khích lệ, không '
        'có chiến lược học tương ứng)', () {
      final session = computeSmartLearningSession(
        _journeyWith([TutorSuggestionKind.maintainStreak]),
        DateTime(2026, 7, 21),
      );
      expect(session.recommendations, isEmpty);
    });

    test('2 bước CÙNG chiến lược -> gộp thành 1 đề xuất, relatedStepCount=2',
        () {
      final session = computeSmartLearningSession(
        _journeyWith([
          TutorSuggestionKind.reviewDueCards,
          TutorSuggestionKind.completeDailyReviewGoal,
        ]),
        DateTime(2026, 7, 21),
      );
      expect(session.recommendations, hasLength(1));
      expect(session.recommendations.single.relatedStepCount, 2);
    });

    test(
        'GIỮ NGUYÊN thứ tự xuất hiện lần đầu theo plan.steps đã có '
        '(không sắp xếp lại)', () {
      final session = computeSmartLearningSession(
        _journeyWith([
          TutorSuggestionKind.strengthenWeakRoots, // memorization
          TutorSuggestionKind.reviewDueCards, // shortReview
          TutorSuggestionKind.reviewFrequentlyForgotten, // recovery
        ]),
        DateTime(2026, 7, 21),
      );

      expect(session.recommendations.map((r) => r.strategy), [
        SessionStrategy.memorization,
        SessionStrategy.shortReview,
        SessionStrategy.recovery,
      ]);
    });

    test('estimatedMinutes đúng theo quy tắc cố định mỗi chiến lược', () {
      final session = computeSmartLearningSession(
        _journeyWith([
          TutorSuggestionKind.reviewDueCards,
          TutorSuggestionKind.completeDailyStudyGoal,
          TutorSuggestionKind.strengthenWeakRoots,
          TutorSuggestionKind.reviewFrequentlyForgotten,
        ]),
        DateTime(2026, 7, 21),
      );
      final byStrategy = {
        for (final r in session.recommendations) r.strategy: r.estimatedMinutes,
      };

      expect(byStrategy[SessionStrategy.shortReview], 10);
      expect(byStrategy[SessionStrategy.deepStudy], 20);
      expect(byStrategy[SessionStrategy.memorization], 15);
      expect(byStrategy[SessionStrategy.recovery], 15);
    });
  });
}
