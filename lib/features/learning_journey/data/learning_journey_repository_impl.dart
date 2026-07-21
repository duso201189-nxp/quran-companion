import '../../ai_tutor/domain/ai_tutor_repository.dart';
import '../domain/daily_learning_plan_generator.dart';
import '../domain/entities/daily_learning_plan.dart';
import '../domain/entities/learning_journey.dart';
import '../domain/learning_journey_repository.dart';

/// Triển khai LearningJourneyRepository (Sprint 16 Phase 1) — ghép
/// DUY NHẤT AITutorRepository (Sprint 15, kiến trúc đã đóng băng,
/// KHÔNG đổi), KHÔNG tự ý gọi AnalyticsRepository/SchedulerRepository/
/// FlashcardRepository trực tiếp — đúng yêu cầu "Compose ONLY:
/// AITutorRepository".
///
/// KHÔNG cache gì giữa các lệnh gọi (đúng yêu cầu "No caching") —
/// getLearningJourney()/getDailyPlan() đều tự gọi lại
/// AITutorRepository mỗi lần, mỗi phương thức AITutorRepository lại tự
/// gọi lại AnalyticsRepository mỗi lần (xem AITutorRepositoryImpl,
/// Sprint 15 Phase 1) — CHƯA tối ưu liên tầng, cùng ranh giới CỐ Ý
/// dừng lại đã thiết lập ở Sprint 15 Phase 1/Sprint 14 Phase 3 (tối ưu
/// TRONG 1 lệnh gọi được cho phép, tối ưu XUYÊN nhiều lệnh gọi thì
/// không — rủi ro trả dữ liệu cũ) — xem Return Phase 1 mục "Remaining
/// backlog".
///
/// KHÔNG có logic AI/LLM nào — computeDailyLearningPlan (rule-based
/// thuần) là toàn bộ "thông minh" ở phase này, đúng "Rule-based only.
/// No AI model."
class LearningJourneyRepositoryImpl implements LearningJourneyRepository {
  LearningJourneyRepositoryImpl(this._aiTutor, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AITutorRepository _aiTutor;

  /// Tiêm được để test có kết quả xác định — cùng mẫu now/newId/nowMs
  /// đã dùng ở mọi repository impl khác trong dự án.
  final DateTime Function() _now;

  @override
  Future<DailyLearningPlan> getDailyPlan() async {
    final suggestions = await _aiTutor.getSuggestions();
    return computeDailyLearningPlan(suggestions, _now());
  }

  @override
  Future<LearningJourney> getLearningJourney() async {
    final context = await _aiTutor.getTutorContext();
    final suggestions = await _aiTutor.getSuggestions();
    final insights = await _aiTutor.getInsights();
    return LearningJourney(
      context: context,
      todayPlan: computeDailyLearningPlan(suggestions, _now()),
      insights: insights,
    );
  }
}
