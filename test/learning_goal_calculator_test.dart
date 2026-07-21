import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/analytics/domain/entities/learning_goal.dart';
import 'package:quran_companion/features/analytics/domain/learning_goal_calculator.dart';

void main() {
  group('computeLearningGoals', () {
    test('trả về đúng 3 mục tiêu theo LearningGoalKind', () {
      final goals = computeLearningGoals(
        minutesToday: 5,
        reviewsToday: 2,
        minutesThisWeek: 20,
      );

      expect(goals.map((g) => g.kind), [
        LearningGoalKind.dailyStudyMinutes,
        LearningGoalKind.dailyReviews,
        LearningGoalKind.weeklyStudyMinutes,
      ]);
    });

    test('current khớp đúng tham số truyền vào, target dùng ngưỡng mặc định',
        () {
      final goals = computeLearningGoals(
        minutesToday: 5,
        reviewsToday: 2,
        minutesThisWeek: 20,
      );

      final byKind = {for (final g in goals) g.kind: g};
      expect(byKind[LearningGoalKind.dailyStudyMinutes]!.current, 5);
      expect(
        byKind[LearningGoalKind.dailyStudyMinutes]!.target,
        LearningGoalDefaults.dailyStudyMinutes,
      );
      expect(byKind[LearningGoalKind.dailyReviews]!.current, 2);
      expect(
        byKind[LearningGoalKind.dailyReviews]!.target,
        LearningGoalDefaults.dailyReviews,
      );
      expect(byKind[LearningGoalKind.weeklyStudyMinutes]!.current, 20);
      expect(
        byKind[LearningGoalKind.weeklyStudyMinutes]!.target,
        LearningGoalDefaults.weeklyStudyMinutes,
      );
    });

    test('isAchieved đúng khi current >= target', () {
      final goals = computeLearningGoals(
        minutesToday: LearningGoalDefaults.dailyStudyMinutes,
        reviewsToday: 0,
        minutesThisWeek: 0,
      );
      final byKind = {for (final g in goals) g.kind: g};

      expect(byKind[LearningGoalKind.dailyStudyMinutes]!.isAchieved, isTrue);
      expect(byKind[LearningGoalKind.dailyReviews]!.isAchieved, isFalse);
    });

    test('progress kẹp trong [0,1] kể cả khi current vượt target', () {
      final goals = computeLearningGoals(
        minutesToday: LearningGoalDefaults.dailyStudyMinutes * 3,
        reviewsToday: 0,
        minutesThisWeek: 0,
      );
      final byKind = {for (final g in goals) g.kind: g};

      expect(byKind[LearningGoalKind.dailyStudyMinutes]!.progress, 1.0);
      expect(byKind[LearningGoalKind.dailyReviews]!.progress, 0.0);
    });

    test('progress = current / target khi chưa đạt', () {
      const goal = LearningGoal(
        kind: LearningGoalKind.dailyReviews,
        target: 10,
        current: 4,
      );
      expect(goal.progress, closeTo(0.4, 0.0001));
    });
  });
}
