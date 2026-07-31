import 'entities/achievement.dart';
import 'entities/history_bucket.dart';
import 'entities/learning_goal.dart';
import 'entities/learning_statistics.dart';
import 'entities/performance_insights.dart';

/// Cổng Analytics (Sprint 14 Phase 1 mục 5 — "Prepare Analytics API
/// for future AI Tutor"). Domain thuần Dart — không phụ thuộc
/// Flutter/Riverpod, gọi được trực tiếp từ bất kỳ ngữ cảnh nào (UI
/// hôm nay, AI Tutor sau này) không cần đi qua Provider.
///
/// KHÔNG sở hữu dữ liệu riêng — mọi triển khai PHẢI tổng hợp từ
/// SchedulerRepository/FlashcardRepository/LexiconRepository/
/// StudySessionRepository đã có (xem AnalyticsRepositoryImpl), không
/// có bảng lưu trữ nào của riêng Analytics (đúng yêu cầu "No
/// duplicated statistics").
abstract interface class AnalyticsRepository {
  /// Số liệu học tập hiện tại (Cards Studied/Reviews Today/Accuracy/
  /// Streak/Average Ease/Average Interval — mục 1).
  Future<LearningStatistics> getLearningStatistics();

  /// Lịch sử hoạt động học theo Ngày/Tuần/Tháng (mục 2) — [count] mốc
  /// gần nhất, tái dùng StudySessionRepository (có lịch sử thật).
  Future<List<HistoryBucket>> getLearningHistory(
    HistoryGranularity granularity, {
    int count,
  });

  /// Performance Insights (mục 4) — Weak Roots/Difficult Lemmas/
  /// Frequently Forgotten/Fastest Improving, [limit] mục mỗi loại.
  Future<PerformanceInsights> getPerformanceInsights({int limit});

  /// Mục tiêu học tập (Sprint 14 Phase 2.2 mục 1/3) — dẫn xuất TRỰC
  /// TIẾP từ getLearningStatistics()/getLearningHistory() đã có ở
  /// trên, không truy vấn gì mới, không lưu trạng thái nào (đúng yêu
  /// cầu "derived, not persisted").
  Future<List<LearningGoal>> getLearningGoals();

  /// Thành tựu (mục 2/3) — dẫn xuất TRỰC TIẾP từ
  /// getLearningStatistics(), cùng nguyên tắc với getLearningGoals().
  Future<List<Achievement>> getAchievements();
}
