/// Loại mục tiêu học tập (Sprint 14 Phase 2.2 mục 1). Chỉ 3 ví dụ nêu
/// trong yêu cầu — không thêm loại khác để giữ phạm vi "foundation".
enum LearningGoalKind { dailyStudyMinutes, dailyReviews, weeklyStudyMinutes }

/// 1 mục tiêu học tập — HOÀN TOÀN dẫn xuất mỗi lần đọc (KHÔNG lưu
/// trạng thái "đã đạt" ở đâu cả, đúng yêu cầu "derived, not
/// persisted"). Ngưỡng [target] là hằng số cố định
/// ([LearningGoalDefaults]), chưa cho người dùng tự đặt (xem Return
/// Phase 2.2 mục "Remaining backlog") — [current] tính lại từ
/// AnalyticsRepository mỗi lần gọi, không có bảng nào lưu lịch sử
/// "đã hoàn thành mục tiêu ngày X" (khác hẳn 1 hệ thống gamification
/// thật sự cần lưu trạng thái unlock).
///
/// KHÔNG có trường "label" tính sẵn — cùng kỷ luật với [HistoryBucket]:
/// Calculator thuần Dart không nhúng chuỗi 1 ngôn ngữ, tầng UI tự ánh
/// xạ [kind] sang chuỗi l10n.
class LearningGoal {
  const LearningGoal({
    required this.kind,
    required this.target,
    required this.current,
  });

  final LearningGoalKind kind;
  final int target;
  final int current;

  bool get isAchieved => current >= target;

  double get progress => target <= 0 ? 1.0 : (current / target).clamp(0.0, 1.0);
}
