import 'entities/achievement.dart';

/// Ngưỡng mặc định cho từng thành tựu — hằng số cố định, cùng lý do
/// với [LearningGoalDefaults] (xem learning_goal_calculator.dart).
abstract final class AchievementDefaults {
  static const int firstStudy = 1;
  static const int tenCardsStudied = 10;
  static const int hundredCardsStudied = 100;
  static const int sevenDayStreak = 7;
  static const int thirtyDayLongestStreak = 30;

  /// Phần trăm (0-100), không phải 0.0-1.0 — [current] truyền vào
  /// cũng phải cùng đơn vị (xem computeAchievements).
  static const int sharpMemoryAccuracyPercent = 90;
}

/// Hàm THUẦN tính danh sách thành tựu từ LearningStatistics ĐÃ CÓ SẴN
/// (tham số truyền vào, không tự truy vấn) — mỗi thành tựu chỉ so 1
/// trường đã tồn tại với 1 ngưỡng cố định, KHÔNG tính lại số liệu
/// mới. `cardsStudied` dùng lại cho 3 mốc (firstStudy/ten/hundred) —
/// cùng 1 nguồn, khác ngưỡng, giống bậc Đồng/Bạc/Vàng của cùng 1 chỉ
/// số, không phải "trùng lặp thống kê".
List<Achievement> computeAchievements({
  required int cardsStudied,
  required int readingStreakDays,
  required int longestReadingStreakDays,
  required double accuracy,
}) {
  return [
    Achievement(
      kind: AchievementKind.firstStudy,
      current: cardsStudied,
      target: AchievementDefaults.firstStudy,
    ),
    Achievement(
      kind: AchievementKind.tenCardsStudied,
      current: cardsStudied,
      target: AchievementDefaults.tenCardsStudied,
    ),
    Achievement(
      kind: AchievementKind.hundredCardsStudied,
      current: cardsStudied,
      target: AchievementDefaults.hundredCardsStudied,
    ),
    Achievement(
      kind: AchievementKind.sevenDayStreak,
      current: readingStreakDays,
      target: AchievementDefaults.sevenDayStreak,
    ),
    Achievement(
      kind: AchievementKind.thirtyDayLongestStreak,
      current: longestReadingStreakDays,
      target: AchievementDefaults.thirtyDayLongestStreak,
    ),
    Achievement(
      kind: AchievementKind.sharpMemory,
      // studied=0 -> accuracy mặc định 0.0 (xem
      // learning_statistics_calculator.dart) -> current=0, không hiện
      // "đạt 0%/90%" gây hiểu lầm vì chưa học gì.
      current: cardsStudied > 0 ? (accuracy * 100).round() : 0,
      target: AchievementDefaults.sharpMemoryAccuracyPercent,
    ),
  ];
}
