import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/tutor_insight_generator.dart';
import 'package:quran_companion/features/analytics/domain/entities/achievement.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';

const _emptyInsights = PerformanceInsights(
  weakRoots: [],
  difficultLemmas: [],
  frequentlyForgotten: [],
  fastestImproving: [],
);

void main() {
  group('computeTutorInsights', () {
    test('trả về đúng 4 loại nhận định theo TutorInsightKind', () {
      final insights = computeTutorInsights(
        const TutorContext(
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
          insights: _emptyInsights,
        ),
      );

      expect(insights.map((i) => i.kind), [
        TutorInsightKind.accuracySummary,
        TutorInsightKind.streakSummary,
        TutorInsightKind.cardsStudiedSummary,
        TutorInsightKind.achievementsUnlockedSummary,
      ]);
    });

    test('value đọc ĐÚNG từ LearningStatistics, không tính lại', () {
      final insights = computeTutorInsights(
        const TutorContext(
          statistics: LearningStatistics(
            cardsStudied: 42,
            dueToday: 3,
            reviewsToday: 7,
            accuracy: 0.75,
            averageEase: 2.5,
            averageInterval: 1,
            readingStreakDays: 9,
            longestReadingStreakDays: 20,
          ),
          goals: [],
          achievements: [],
          insights: _emptyInsights,
        ),
      );
      final byKind = {for (final i in insights) i.kind: i};

      expect(byKind[TutorInsightKind.accuracySummary]!.value, 0.75);
      expect(byKind[TutorInsightKind.streakSummary]!.value, 9);
      expect(byKind[TutorInsightKind.cardsStudiedSummary]!.value, 42);
    });

    test('achievementsUnlockedSummary đếm ĐÚNG số Achievement.isUnlocked', () {
      final insights = computeTutorInsights(
        const TutorContext(
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
          achievements: [
            Achievement(
              kind: AchievementKind.firstStudy,
              current: 1,
              target: 1,
            ), // unlocked
            Achievement(
              kind: AchievementKind.tenCardsStudied,
              current: 1,
              target: 10,
            ), // locked
            Achievement(
              kind: AchievementKind.sevenDayStreak,
              current: 7,
              target: 7,
            ), // unlocked
          ],
          insights: _emptyInsights,
        ),
      );

      final unlocked = insights.singleWhere(
        (i) => i.kind == TutorInsightKind.achievementsUnlockedSummary,
      );
      expect(unlocked.value, 2);
    });
  });
}
