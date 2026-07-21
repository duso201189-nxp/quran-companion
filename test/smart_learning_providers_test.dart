import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/data/learning_journey_providers.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/journey_step.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/learning_journey/domain/learning_journey_repository.dart';
import 'package:quran_companion/features/smart_learning/data/smart_learning_providers.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/session_strategy.dart';

class _FakeLearningJourneyRepository implements LearningJourneyRepository {
  _FakeLearningJourneyRepository(this.journey);

  final LearningJourney journey;

  @override
  Future<LearningJourney> getLearningJourney() async => journey;

  @override
  Future<DailyLearningPlan> getDailyPlan() async => journey.todayPlan;
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
  late ProviderContainer container;

  ProviderContainer makeContainer(List<TutorSuggestionKind> kinds) {
    return ProviderContainer(
      overrides: [
        learningJourneyRepositoryProvider.overrideWithValue(
          _FakeLearningJourneyRepository(_journeyWith(kinds)),
        ),
      ],
    );
  }

  tearDown(() => container.dispose());

  test(
      'smartLearningRepositoryProvider ghép ĐÚNG learningJourneyRepositoryProvider '
      'đã override, không tạo repository riêng', () async {
    container = makeContainer([TutorSuggestionKind.reviewDueCards]);

    final session = await container.read(smartLearningSessionProvider.future);

    expect(
      session.recommendations.single.strategy,
      SessionStrategy.shortReview,
    );
  });

  test('smartLearningSessionProvider trả rỗng khi chưa có gợi ý nào', () async {
    container = makeContainer(const []);

    final session = await container.read(smartLearningSessionProvider.future);

    expect(session.recommendations, isEmpty);
  });
}
