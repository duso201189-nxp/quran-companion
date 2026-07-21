import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/data/ai_tutor_repository_impl.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/analytics/domain/analytics_repository.dart';
import 'package:quran_companion/features/analytics/domain/entities/achievement.dart';
import 'package:quran_companion/features/analytics/domain/entities/history_bucket.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_goal.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';

/// Fake THUẦN của AnalyticsRepository — KHÔNG cần database nào, vì
/// AITutorRepository (Sprint 15 Phase 1) chỉ được phép biết tới
/// ĐÚNG 1 interface này (không như AnalyticsRepositoryImpl, phải ghép
/// 4 repository thật nên test của NÓ cần Drift). Đây chính là lợi ích
/// kiến trúc "consume existing AnalyticsRepository" mang lại: test
/// AITutorRepositoryImpl không tốn 1 dòng thiết lập DB nào.
class _FakeAnalyticsRepository implements AnalyticsRepository {
  _FakeAnalyticsRepository({
    required this.statistics,
    this.goals = const [],
    this.achievements = const [],
    this.insights = const PerformanceInsights(
      weakRoots: [],
      difficultLemmas: [],
      frequentlyForgotten: [],
      fastestImproving: [],
    ),
  });

  final LearningStatistics statistics;
  final List<LearningGoal> goals;
  final List<Achievement> achievements;
  final PerformanceInsights insights;

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
      insights;

  @override
  Future<List<LearningGoal>> getLearningGoals() async => goals;

  @override
  Future<List<Achievement>> getAchievements() async => achievements;
}

const _fakeFlashcard = Flashcard(
  id: 'fc-1',
  type: FlashcardType.lemma,
  lexiconEntryType: LexiconEntryType.lemma,
  lexiconEntryId: 1,
  createdAt: 0,
);

const _stats = LearningStatistics(
  cardsStudied: 12,
  dueToday: 4,
  reviewsToday: 2,
  accuracy: 0.8,
  averageEase: 2.4,
  averageInterval: 3,
  readingStreakDays: 5,
  longestReadingStreakDays: 10,
);

void main() {
  group('getTutorContext', () {
    test('gói ĐÚNG 4 phần từ AnalyticsRepository, không tính lại gì', () async {
      final fake = _FakeAnalyticsRepository(
        statistics: _stats,
        goals: const [
          LearningGoal(
            kind: LearningGoalKind.dailyReviews,
            target: 10,
            current: 2,
          ),
        ],
        achievements: const [
          Achievement(kind: AchievementKind.firstStudy, current: 1, target: 1),
        ],
      );
      final repo = AITutorRepositoryImpl(fake);

      final context = await repo.getTutorContext();

      expect(context.statistics, same(_stats));
      expect(context.goals, hasLength(1));
      expect(context.achievements, hasLength(1));
      expect(context.insights, same(fake.insights));
    });
  });

  group('getSuggestions', () {
    test('suy ĐÚNG từ TutorContext gói lại (dueToday > 0 -> reviewDueCards)',
        () async {
      final fake = _FakeAnalyticsRepository(statistics: _stats);
      final repo = AITutorRepositoryImpl(fake);

      final suggestions = await repo.getSuggestions();

      expect(
        suggestions.any((s) => s.kind == TutorSuggestionKind.reviewDueCards),
        isTrue,
      );
    });

    test('không có gì đáng gợi ý -> danh sách rỗng, không lỗi', () async {
      final fake = _FakeAnalyticsRepository(
        statistics: const LearningStatistics(
          cardsStudied: 0,
          dueToday: 0,
          reviewsToday: 0,
          accuracy: 0,
          averageEase: 2.5,
          averageInterval: 1,
          readingStreakDays: 0,
          longestReadingStreakDays: 0,
        ),
      );
      final repo = AITutorRepositoryImpl(fake);

      final suggestions = await repo.getSuggestions();

      expect(suggestions, isEmpty);
    });

    test(
        'PerformanceInsights TÙY CHỈNH từ AnalyticsRepository được truyền '
        'đúng vào TutorContext -> phản ánh đúng trong gợi ý (không chỉ '
        'LearningStatistics)', () async {
      final fake = _FakeAnalyticsRepository(
        statistics: const LearningStatistics(
          cardsStudied: 0,
          dueToday: 0,
          reviewsToday: 0,
          accuracy: 0,
          averageEase: 2.5,
          averageInterval: 1,
          readingStreakDays: 0,
          longestReadingStreakDays: 0,
        ),
        insights: const PerformanceInsights(
          weakRoots: [],
          difficultLemmas: [],
          frequentlyForgotten: [
            (flashcard: _fakeFlashcard, lemma: null),
          ],
          fastestImproving: [],
        ),
      );
      final repo = AITutorRepositoryImpl(fake);

      final suggestions = await repo.getSuggestions();

      expect(
        suggestions.any(
          (s) => s.kind == TutorSuggestionKind.reviewFrequentlyForgotten,
        ),
        isTrue,
      );
    });
  });

  group('getInsights', () {
    test('trả đủ 4 loại nhận định, value khớp đúng LearningStatistics',
        () async {
      final fake = _FakeAnalyticsRepository(statistics: _stats);
      final repo = AITutorRepositoryImpl(fake);

      final insights = await repo.getInsights();
      final byKind = {for (final i in insights) i.kind: i};

      expect(insights, hasLength(4));
      expect(byKind[TutorInsightKind.accuracySummary]!.value, 0.8);
      expect(byKind[TutorInsightKind.cardsStudiedSummary]!.value, 12);
    });
  });
}
