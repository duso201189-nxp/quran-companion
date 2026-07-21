import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/data/ai_tutor_providers.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/data/analytics_providers.dart';
import 'package:quran_companion/features/analytics/domain/analytics_repository.dart';
import 'package:quran_companion/features/analytics/domain/entities/achievement.dart';
import 'package:quran_companion/features/analytics/domain/entities/history_bucket.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_goal.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';

class _FakeAnalyticsRepository implements AnalyticsRepository {
  _FakeAnalyticsRepository(this.statistics);

  final LearningStatistics statistics;

  @override
  Future<LearningStatistics> getLearningStatistics() async => statistics;

  @override
  Future<List<HistoryBucket>> getLearningHistory(
    HistoryGranularity granularity, {
    int count = 7,
  }) async =>
      [];

  @override
  Future<PerformanceInsights> getPerformanceInsights({int limit = 20}) async =>
      const PerformanceInsights(
        weakRoots: [],
        difficultLemmas: [],
        frequentlyForgotten: [],
        fastestImproving: [],
      );

  @override
  Future<List<LearningGoal>> getLearningGoals() async => [];

  @override
  Future<List<Achievement>> getAchievements() async => [];
}

void main() {
  late ProviderContainer container;

  ProviderContainer makeContainer(LearningStatistics stats) {
    return ProviderContainer(
      overrides: [
        analyticsRepositoryProvider
            .overrideWithValue(_FakeAnalyticsRepository(stats)),
      ],
    );
  }

  tearDown(() => container.dispose());

  test(
      'aiTutorRepositoryProvider ghép ĐÚNG analyticsRepositoryProvider đã '
      'override, không tạo repository riêng', () async {
    container = makeContainer(
      const LearningStatistics(
        cardsStudied: 1,
        dueToday: 0,
        reviewsToday: 0,
        accuracy: 1,
        averageEase: 2.5,
        averageInterval: 1,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
      ),
    );

    final context = await container.read(tutorContextProvider.future);
    expect(context.statistics.cardsStudied, 1);
  });

  test('tutorSuggestionsProvider trả gợi ý đúng theo dữ liệu đã override',
      () async {
    container = makeContainer(
      const LearningStatistics(
        cardsStudied: 0,
        dueToday: 7,
        reviewsToday: 0,
        accuracy: 0,
        averageEase: 2.5,
        averageInterval: 1,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
      ),
    );

    final suggestions = await container.read(tutorSuggestionsProvider.future);

    final s = suggestions
        .singleWhere((s) => s.kind == TutorSuggestionKind.reviewDueCards);
    expect(s.relatedCount, 7);
  });

  test('tutorInsightsProvider trả đủ 4 nhận định', () async {
    container = makeContainer(
      const LearningStatistics(
        cardsStudied: 5,
        dueToday: 0,
        reviewsToday: 0,
        accuracy: 0.5,
        averageEase: 2.5,
        averageInterval: 1,
        readingStreakDays: 2,
        longestReadingStreakDays: 2,
      ),
    );

    final insights = await container.read(tutorInsightsProvider.future);
    expect(insights, hasLength(4));
  });
}
