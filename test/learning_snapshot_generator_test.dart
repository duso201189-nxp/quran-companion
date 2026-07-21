import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/read_model/domain/learning_snapshot_generator.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/learning_recommendation.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/session_strategy.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/smart_learning_session.dart';

const _stats = LearningStatistics(
  cardsStudied: 5,
  dueToday: 2,
  reviewsToday: 1,
  accuracy: 0.8,
  averageEase: 2.5,
  averageInterval: 3,
  readingStreakDays: 4,
  longestReadingStreakDays: 9,
);

const _insights = [
  TutorInsight(kind: TutorInsightKind.accuracySummary, value: 0.8),
  TutorInsight(kind: TutorInsightKind.streakSummary, value: 4),
];

const _context = TutorContext(
  statistics: _stats,
  goals: [],
  achievements: [],
  insights: PerformanceInsights(
    weakRoots: [],
    difficultLemmas: [],
    frequentlyForgotten: [],
    fastestImproving: [],
  ),
);

final _dailyPlan =
    DailyLearningPlan(date: DateTime(2026, 7, 21), steps: const []);

final _journey = LearningJourney(
  context: _context,
  todayPlan: _dailyPlan,
  insights: _insights,
);

final _session = SmartLearningSession(
  date: DateTime(2026, 7, 21),
  recommendations: const [
    LearningRecommendation(
      strategy: SessionStrategy.shortReview,
      estimatedMinutes: 10,
      relatedStepCount: 1,
    ),
  ],
  journey: _journey,
);

void main() {
  group('computeLearningSnapshot', () {
    test('timestamp.generatedAt ĐÚNG giá trị truyền vào (không cắt giờ)', () {
      final generatedAt = DateTime(2026, 7, 21, 14, 35, 10);
      final snapshot = computeLearningSnapshot(_session, generatedAt);

      expect(snapshot.timestamp.generatedAt, generatedAt);
    });

    test(
        'context/insights/dailyPlan lấy ĐÚNG từ session.journey, không '
        'tính lại', () {
      final snapshot = computeLearningSnapshot(
        _session,
        DateTime(2026, 7, 21, 14),
      );

      expect(snapshot.context, same(_context));
      expect(snapshot.insights, same(_insights));
      expect(snapshot.dailyPlan, same(_dailyPlan));
    });

    test(
        'smartSession CHÍNH LÀ session truyền vào (không sao chép/rút '
        'gọn)', () {
      final snapshot = computeLearningSnapshot(
        _session,
        DateTime(2026, 7, 21, 14),
      );

      expect(snapshot.smartSession, same(_session));
    });
  });
}
