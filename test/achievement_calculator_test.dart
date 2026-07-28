import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/analytics/domain/achievement_calculator.dart';
import 'package:quran_companion/features/analytics/domain/entities/achievement.dart';

void main() {
  group('computeAchievements', () {
    test('trả về đúng 6 thành tựu theo AchievementKind', () {
      final achievements = computeAchievements(
        cardsStudied: 0,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        accuracy: 0,
      );

      expect(achievements.map((a) => a.kind), [
        AchievementKind.firstStudy,
        AchievementKind.tenCardsStudied,
        AchievementKind.hundredCardsStudied,
        AchievementKind.sevenDayStreak,
        AchievementKind.thirtyDayLongestStreak,
        AchievementKind.sharpMemory,
      ]);
    });

    test('3 mốc cardsStudied dùng CHUNG 1 nguồn, khác ngưỡng', () {
      final achievements = computeAchievements(
        cardsStudied: 15,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        accuracy: 0,
      );
      final byKind = {for (final a in achievements) a.kind: a};

      expect(byKind[AchievementKind.firstStudy]!.current, 15);
      expect(byKind[AchievementKind.tenCardsStudied]!.current, 15);
      expect(byKind[AchievementKind.hundredCardsStudied]!.current, 15);
      expect(byKind[AchievementKind.firstStudy]!.isUnlocked, isTrue);
      expect(byKind[AchievementKind.tenCardsStudied]!.isUnlocked, isTrue);
      expect(byKind[AchievementKind.hundredCardsStudied]!.isUnlocked, isFalse);
    });

    test(
        'sevenDayStreak/thirtyDayLongestStreak đọc đúng trường streak tương ứng',
        () {
      final achievements = computeAchievements(
        cardsStudied: 0,
        readingStreakDays: 7,
        longestReadingStreakDays: 15,
        accuracy: 0,
      );
      final byKind = {for (final a in achievements) a.kind: a};

      expect(byKind[AchievementKind.sevenDayStreak]!.isUnlocked, isTrue);
      expect(
        byKind[AchievementKind.thirtyDayLongestStreak]!.isUnlocked,
        isFalse,
      );
      expect(byKind[AchievementKind.thirtyDayLongestStreak]!.current, 15);
    });

    test('sharpMemory quy đổi accuracy (0.0-1.0) sang phần trăm nguyên', () {
      final achievements = computeAchievements(
        cardsStudied: 10,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        accuracy: 0.92,
      );
      final sharp =
          achievements.firstWhere((a) => a.kind == AchievementKind.sharpMemory);

      expect(sharp.current, 92);
      expect(sharp.isUnlocked, isTrue);
    });

    test('sharpMemory = 0 khi cardsStudied = 0, kể cả accuracy khác 0', () {
      final achievements = computeAchievements(
        cardsStudied: 0,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        accuracy: 0.5,
      );
      final sharp =
          achievements.firstWhere((a) => a.kind == AchievementKind.sharpMemory);

      expect(sharp.current, 0);
      expect(sharp.isUnlocked, isFalse);
    });

    test('progress kẹp trong [0,1]', () {
      const a = Achievement(
        kind: AchievementKind.tenCardsStudied,
        current: 25,
        target: 10,
      );
      expect(a.progress, 1.0);
    });
  });
}
