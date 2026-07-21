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

/// Fake đếm số lần getSuggestions() được gọi thật — dùng để CHỨNG MINH
/// (Sprint 18 Phase 2) dailyLearningPlanProvider tái dùng
/// tutorSuggestionsProvider đã watch trước đó thay vì tự kích hoạt 1
/// lượt AITutorRepository.getSuggestions() MỚI.
class _CountingAITutorRepository implements AITutorRepository {
  _CountingAITutorRepository(this.suggestions);

  final List<TutorSuggestion> suggestions;
  int getSuggestionsCallCount = 0;

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
  Future<List<TutorSuggestion>> getSuggestions() async {
    getSuggestionsCallCount++;
    return suggestions;
  }

  @override
  Future<List<TutorInsight>> getInsights() async => const [];
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

  test(
      'dailyLearningPlanProvider trả plan đã sắp xếp đúng theo dữ liệu '
      'đã override', () async {
    container = makeContainer(const [
      TutorSuggestion(
        kind: TutorSuggestionKind.maintainStreak,
        priority: TutorSuggestionPriority.low,
      ),
      TutorSuggestion(
        kind: TutorSuggestionKind.reviewDueCards,
        priority: TutorSuggestionPriority.high,
      ),
    ]);

    final plan = await container.read(dailyLearningPlanProvider.future);

    expect(plan.steps.map((s) => s.suggestion.kind), [
      TutorSuggestionKind.reviewDueCards,
      TutorSuggestionKind.maintainStreak,
    ]);
  });

  test(
      'dailyLearningPlanProvider tái dùng tutorSuggestionsProvider đã có '
      'màn hình khác giữ watch — KHÔNG gọi getSuggestions() thêm lần '
      'nào (Sprint 18 Phase 2)', () async {
    final fake = _CountingAITutorRepository(const [
      TutorSuggestion(
        kind: TutorSuggestionKind.reviewDueCards,
        priority: TutorSuggestionPriority.high,
      ),
    ]);
    container = ProviderContainer(
      overrides: [aiTutorRepositoryProvider.overrideWithValue(fake)],
    );

    // Mô phỏng TutorHomeScreen đang mounted bên dưới — 1 subscription
    // sống thật (khác container.read() rời rạc, vốn có thể bị
    // autoDispose ngay sau đó).
    final sub = container.listen(tutorSuggestionsProvider, (_, __) {});
    await container.read(tutorSuggestionsProvider.future);
    expect(fake.getSuggestionsCallCount, 1);

    final plan = await container.read(dailyLearningPlanProvider.future);

    expect(fake.getSuggestionsCallCount, 1);
    expect(plan.steps, hasLength(1));
    sub.close();
  });
}
