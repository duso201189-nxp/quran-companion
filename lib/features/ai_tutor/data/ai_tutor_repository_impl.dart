import '../../analytics/domain/analytics_repository.dart';
import '../domain/ai_tutor_repository.dart';
import '../domain/entities/tutor_context.dart';
import '../domain/entities/tutor_insight.dart';
import '../domain/entities/tutor_suggestion.dart';
import '../domain/tutor_insight_generator.dart';
import '../domain/tutor_suggestion_generator.dart';

/// Triển khai AITutorRepository (Sprint 15 Phase 1 mục 4) — ghép
/// DUY NHẤT AnalyticsRepository (Sprint 14, kiến trúc đã đóng băng,
/// KHÔNG đổi), KHÔNG tự ý gọi SchedulerRepository/FlashcardRepository/
/// LexiconRepository/StudySessionRepository trực tiếp — đúng yêu cầu
/// "Analytics remains the single source of learning insights".
///
/// KHÔNG cache gì giữa các lệnh gọi (đúng yêu cầu "No caching") —
/// getSuggestions()/getInsights() đều tự gọi lại getTutorContext(),
/// tự nó gọi lại 4 phương thức AnalyticsRepository mỗi lần — CHƯA tối
/// ưu (khác Sprint 14 Phase 3, nơi tối ưu NỘI BỘ 1 lệnh gọi được cho
/// phép) vì yêu cầu phase này rõ ràng "No caching", và AITutorRepository
/// chưa có Provider/UI thật nào gọi nhiều lệnh cùng lúc để cần tối ưu
/// — xem Return Phase 1 mục "Remaining backlog".
///
/// KHÔNG có logic AI/LLM nào — mọi TutorSuggestion/TutorInsight trả
/// về là NGƯỠNG/ĐIỀU KIỆN thuần (xem tutor_suggestion_generator.dart/
/// tutor_insight_generator.dart), đúng "Foundation only. No AI model
/// integration yet."
class AITutorRepositoryImpl implements AITutorRepository {
  const AITutorRepositoryImpl(this._analytics);

  final AnalyticsRepository _analytics;

  @override
  Future<TutorContext> getTutorContext() async {
    final statistics = await _analytics.getLearningStatistics();
    final goals = await _analytics.getLearningGoals();
    final achievements = await _analytics.getAchievements();
    final insights = await _analytics.getPerformanceInsights();
    return TutorContext(
      statistics: statistics,
      goals: goals,
      achievements: achievements,
      insights: insights,
    );
  }

  @override
  Future<List<TutorSuggestion>> getSuggestions() async {
    final context = await getTutorContext();
    return computeTutorSuggestions(context);
  }

  @override
  Future<List<TutorInsight>> getInsights() async {
    final context = await getTutorContext();
    return computeTutorInsights(context);
  }
}
