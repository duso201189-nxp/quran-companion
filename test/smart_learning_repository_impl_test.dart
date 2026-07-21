import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/journey_step.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/learning_journey/domain/learning_journey_repository.dart';
import 'package:quran_companion/features/smart_learning/data/smart_learning_repository_impl.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/session_strategy.dart';

/// Fake THUẦN của LearningJourneyRepository — KHÔNG cần AITutorRepository/
/// AnalyticsRepository/database nào, vì SmartLearningRepository
/// (Sprint 17 Phase 1) chỉ được phép biết tới ĐÚNG 1 interface này.
/// Cùng lợi ích kiến trúc đã công khai ở Sprint 15/16 Phase 1: không
/// tốn 1 dòng thiết lập DB nào.
class _FakeLearningJourneyRepository implements LearningJourneyRepository {
  _FakeLearningJourneyRepository(this.journey);

  final LearningJourney journey;
  int getLearningJourneyCallCount = 0;
  int getDailyPlanCallCount = 0;

  @override
  Future<LearningJourney> getLearningJourney() async {
    getLearningJourneyCallCount++;
    return journey;
  }

  @override
  Future<DailyLearningPlan> getDailyPlan() async {
    getDailyPlanCallCount++;
    return journey.todayPlan;
  }
}

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

LearningJourney _journeyWith(List<TutorSuggestionKind> kinds) {
  final steps = [
    for (var i = 0; i < kinds.length; i++)
      JourneyStep(
        order: i,
        suggestion: TutorSuggestion(
          kind: kinds[i],
          priority: TutorSuggestionPriority.medium,
        ),
      ),
  ];
  return LearningJourney(
    context: _emptyContext,
    todayPlan: DailyLearningPlan(date: DateTime(2026, 7, 21), steps: steps),
    insights: const <TutorInsight>[],
  );
}

void main() {
  group('getSmartLearningSession', () {
    test('sinh ĐÚNG đề xuất từ LearningJourney trả về', () async {
      final fake = _FakeLearningJourneyRepository(
        _journeyWith([TutorSuggestionKind.reviewDueCards]),
      );
      final repo = SmartLearningRepositoryImpl(
        fake,
        now: () => DateTime(2026, 7, 21),
      );

      final session = await repo.getSmartLearningSession();

      expect(session.date, DateTime(2026, 7, 21));
      expect(
        session.recommendations.single.strategy,
        SessionStrategy.shortReview,
      );
    });

    test('gọi ĐÚNG getLearningJourney() 1 lần, KHÔNG gọi getDailyPlan()',
        () async {
      final fake = _FakeLearningJourneyRepository(_journeyWith(const []));
      final repo = SmartLearningRepositoryImpl(fake);

      await repo.getSmartLearningSession();

      expect(fake.getLearningJourneyCallCount, 1);
      expect(fake.getDailyPlanCallCount, 0);
    });

    test('todayPlan.steps rỗng -> recommendations rỗng, không lỗi', () async {
      final fake = _FakeLearningJourneyRepository(_journeyWith(const []));
      final repo = SmartLearningRepositoryImpl(fake);

      final session = await repo.getSmartLearningSession();

      expect(session.recommendations, isEmpty);
    });
  });
}
