import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/data/ai_tutor_providers.dart';
import 'package:quran_companion/features/ai_tutor/domain/ai_tutor_repository.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/data/learning_journey_providers.dart';

class _FakeAITutorRepository implements AITutorRepository {
  _FakeAITutorRepository(this.suggestions);

  final List<TutorSuggestion> suggestions;

  @override
  Future<TutorContext> getTutorContext() async => const TutorContext(
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

  @override
  Future<List<TutorSuggestion>> getSuggestions() async => suggestions;

  @override
  Future<List<TutorInsight>> getInsights() async => const [
        TutorInsight(kind: TutorInsightKind.cardsStudiedSummary, value: 5),
      ];
}

void main() {
  late ProviderContainer container;

  ProviderContainer makeContainer(List<TutorSuggestion> suggestions) {
    return ProviderContainer(
      overrides: [
        aiTutorRepositoryProvider
            .overrideWithValue(_FakeAITutorRepository(suggestions)),
      ],
    );
  }

  tearDown(() => container.dispose());

  test(
      'learningJourneyRepositoryProvider ghép ĐÚNG aiTutorRepositoryProvider '
      'đã override, không tạo repository riêng', () async {
    container = makeContainer(const []);

    final journey = await container.read(learningJourneyProvider.future);

    expect(journey.insights, hasLength(1));
    expect(journey.todayPlan.steps, isEmpty);
  });
}
