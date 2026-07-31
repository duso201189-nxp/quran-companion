import '../../../analytics/domain/entities/achievement.dart';
import '../../../analytics/domain/entities/learning_goal.dart';
import '../../../analytics/domain/entities/learning_statistics.dart';
import '../../../analytics/domain/entities/performance_insights.dart';

/// Bối cảnh học tập gói lại cho AI Tutor (Sprint 15 Phase 1 mục 2) —
/// CHỈ đóng gói LẠI 4 kiểu dữ liệu ĐÃ CÓ SẴN từ AnalyticsRepository
/// (LearningStatistics/LearningGoal/Achievement/PerformanceInsights),
/// KHÔNG tính toán gì mới, KHÔNG có trường nào không truy nguyên được
/// về Analytics — đúng nghĩa "Do NOT duplicate statistics" (mục 3).
///
/// Đây LÀ hình dạng "snapshot" mà 1 AI thật (Sprint sau, có tích hợp
/// LLM) sẽ tuần tự hoá thành system/user prompt — TutorContext là
/// điểm cắt rõ ràng giữa "dữ liệu học tập" (domain thuần, ổn định) và
/// "cách trình bày cho mô hình AI" (sẽ đổi nhiều, phase sau, không
/// thuộc phạm vi phase này). Domain thuần Dart — không phụ thuộc
/// Flutter/Riverpod.
class TutorContext {
  const TutorContext({
    required this.statistics,
    required this.goals,
    required this.achievements,
    required this.insights,
  });

  final LearningStatistics statistics;
  final List<LearningGoal> goals;
  final List<Achievement> achievements;
  final PerformanceInsights insights;
}
