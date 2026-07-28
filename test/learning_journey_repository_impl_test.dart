import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/ai_tutor_repository.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/data/learning_journey_repository_impl.dart';

/// Fake THUẦN của AITutorRepository — KHÔNG cần database/Analytics
/// nào, vì LearningJourneyRepository (Sprint 16 Phase 1) chỉ được
/// phép biết tới ĐÚNG 1 interface này. Cùng lợi ích kiến trúc đã công
/// khai ở Sprint 15 Phase 1 khi test AITutorRepositoryImpl bằng fake
/// AnalyticsRepository: không tốn 1 dòng thiết lập DB nào.
class _FakeAITutorRepository implements AITutorRepository {
  _FakeAITutorRepository({
    required this.context,
    this.suggestions = const [],
    this.insights = const [],
  });

  final TutorContext context;
  final List<TutorSuggestion> suggestions;
  final List<TutorInsight> insights;

  int getTutorContextCallCount = 0;
  int getSuggestionsCallCount = 0;
  int getInsightsCallCount = 0;

  @override
  Future<TutorContext> getTutorContext() async {
    getTutorContextCallCount++;
    return context;
  }

  @override
  Future<List<TutorSuggestion>> getSuggestions() async {
    getSuggestionsCallCount++;
    return suggestions;
  }

  @override
  Future<List<TutorInsight>> getInsights() async {
    getInsightsCallCount++;
    return insights;
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

void main() {
  group('getDailyPlan', () {
    test('sắp xếp ĐÚNG suggestions từ AITutorRepository.getSuggestions()',
        () async {
      final fake = _FakeAITutorRepository(
        context: _emptyContext,
        suggestions: const [
          TutorSuggestion(
            kind: TutorSuggestionKind.maintainStreak,
            priority: TutorSuggestionPriority.low,
          ),
          TutorSuggestion(
            kind: TutorSuggestionKind.reviewDueCards,
            priority: TutorSuggestionPriority.high,
          ),
        ],
      );
      final repo = LearningJourneyRepositoryImpl(
        fake,
        now: () => DateTime(2026, 7, 21),
      );

      final plan = await repo.getDailyPlan();

      expect(plan.date, DateTime(2026, 7, 21));
      expect(plan.steps.map((s) => s.suggestion.kind), [
        TutorSuggestionKind.reviewDueCards,
        TutorSuggestionKind.maintainStreak,
      ]);
    });

    test('KHÔNG gọi getTutorContext()/getInsights() (chỉ cần suggestions)',
        () async {
      final fake = _FakeAITutorRepository(context: _emptyContext);
      final repo = LearningJourneyRepositoryImpl(fake);

      await repo.getDailyPlan();

      expect(fake.getSuggestionsCallCount, 1);
      expect(fake.getTutorContextCallCount, 0);
      expect(fake.getInsightsCallCount, 0);
    });

    test('danh sách suggestions rỗng -> plan rỗng, không lỗi', () async {
      final fake = _FakeAITutorRepository(context: _emptyContext);
      final repo = LearningJourneyRepositoryImpl(fake);

      final plan = await repo.getDailyPlan();

      expect(plan.steps, isEmpty);
    });
  });

  group('getLearningJourney', () {
    test('gói ĐÚNG context + todayPlan (đã sắp xếp) + insights', () async {
      const insight = TutorInsight(
        kind: TutorInsightKind.accuracySummary,
        value: 0.8,
      );
      final fake = _FakeAITutorRepository(
        context: _emptyContext,
        suggestions: const [
          TutorSuggestion(
            kind: TutorSuggestionKind.strengthenWeakRoots,
            priority: TutorSuggestionPriority.medium,
          ),
        ],
        insights: const [insight],
      );
      final repo = LearningJourneyRepositoryImpl(
        fake,
        now: () => DateTime(2026, 7, 21),
      );

      final journey = await repo.getLearningJourney();

      expect(journey.context, same(_emptyContext));
      expect(journey.insights, [insight]);
      expect(journey.todayPlan.steps, hasLength(1));
      expect(
        journey.todayPlan.steps.single.suggestion.kind,
        TutorSuggestionKind.strengthenWeakRoots,
      );
    });

    test('gọi ĐÚNG 1 lần mỗi phương thức AITutorRepository', () async {
      final fake = _FakeAITutorRepository(context: _emptyContext);
      final repo = LearningJourneyRepositoryImpl(fake);

      await repo.getLearningJourney();

      expect(fake.getTutorContextCallCount, 1);
      expect(fake.getSuggestionsCallCount, 1);
      expect(fake.getInsightsCallCount, 1);
    });
  });
}
