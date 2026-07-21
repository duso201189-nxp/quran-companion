import 'entities/learning_goal.dart';

/// Ngưỡng mặc định cho từng loại mục tiêu — hằng số CỐ ĐỊNH, không
/// lưu ở SharedPreferences/DB nào (đúng yêu cầu "derived, not
/// persisted" — kể cả ngưỡng cũng không có trạng thái để đọc lại,
/// tính lại từ đầu mỗi lần). Người dùng CHƯA tự đặt được ngưỡng ở
/// phase này — xem Return Phase 2.2 mục "Remaining backlog": Stats
/// feature đã có sẵn `DailyGoalStore` (SharedPreferences, chỉ tiêu
/// phút đọc/ngày người dùng tự đặt) có thể nối vào đây ở phase sau,
/// CỐ Ý CHƯA làm ở phase này để tránh Analytics phụ thuộc chéo sang
/// Stats ngoài yêu cầu đã nêu.
abstract final class LearningGoalDefaults {
  static const int dailyStudyMinutes = 15;
  static const int dailyReviews = 10;
  static const int weeklyStudyMinutes = 60;
}

/// Hàm THUẦN tính danh sách mục tiêu từ số liệu ĐÃ CÓ SẴN (tham số
/// truyền vào, không tự truy vấn) — [minutesToday]/[minutesThisWeek]
/// tái dùng AnalyticsRepository.getLearningHistory (mốc Ngày/Tuần gần
/// nhất), [reviewsToday] tái dùng LearningStatistics.reviewsToday.
/// KHÔNG tính lại bất kỳ số liệu nào — chỉ so ngưỡng.
List<LearningGoal> computeLearningGoals({
  required int minutesToday,
  required int reviewsToday,
  required int minutesThisWeek,
}) {
  return [
    LearningGoal(
      kind: LearningGoalKind.dailyStudyMinutes,
      target: LearningGoalDefaults.dailyStudyMinutes,
      current: minutesToday,
    ),
    LearningGoal(
      kind: LearningGoalKind.dailyReviews,
      target: LearningGoalDefaults.dailyReviews,
      current: reviewsToday,
    ),
    LearningGoal(
      kind: LearningGoalKind.weeklyStudyMinutes,
      target: LearningGoalDefaults.weeklyStudyMinutes,
      current: minutesThisWeek,
    ),
  ];
}
