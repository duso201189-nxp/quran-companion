import 'learning_planner.dart';
import 'learning_session_summary.dart';

/// Trạng thái tiến trình của một Learning Session. Hoàn thành phiên
/// được biểu diễn bằng `status == completed` — không dùng thêm cờ
/// bool `isComplete` riêng để tránh hai nguồn có thể lệch nhau.
enum LearningSessionStatus { notStarted, inProgress, completed }

/// Trạng thái đầy đủ của LearningSessionController, expose cho nơi
/// gọi (Phase 3 — UI, chưa xây ở Phase 2 này): hoạt động hiện tại,
/// tập hoạt động đã hoàn thành, tóm tắt tích luỹ, trạng thái phiên.
typedef LearningSessionState = ({
  LearningSessionStatus status,
  LearningActivityType? currentActivity,
  Set<LearningActivityType> completedActivities,
  LearningSessionSummary summary,
});
