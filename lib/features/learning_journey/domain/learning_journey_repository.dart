import 'entities/daily_learning_plan.dart';
import 'entities/learning_journey.dart';

/// Cổng Learning Journey (Sprint 16 Phase 1) — CHỈ được phép tổng hợp
/// từ AITutorRepository (xem LearningJourneyRepositoryImpl), KHÔNG
/// được biết tới AnalyticsRepository/SchedulerRepository/
/// FlashcardRepository trực tiếp — cùng nguyên tắc lớp AI Tutor đã
/// đặt ra ở Sprint 15 Phase 1 áp cho chính nó ("Analytics remains the
/// single source of learning insights"): ở đây, AI Tutor là nguồn
/// DUY NHẤT của Learning Journey.
///
/// Domain thuần Dart — không phụ thuộc Flutter/Riverpod, gọi được
/// trực tiếp từ bất kỳ ngữ cảnh nào, cùng nguyên tắc AnalyticsRepository/
/// AITutorRepository.
///
/// Phase 1 CHỈ là nền kiến trúc — "Foundation" (đúng tên Sprint): kế
/// hoạch sinh ra bằng QUY TẮC/NGƯỠNG thuần (thứ tự ưu tiên), KHÔNG có
/// AI/LLM nào ("No AI model", "No networking").
abstract interface class LearningJourneyRepository {
  /// Bức tranh tổng thể — bối cảnh (TutorContext) + kế hoạch hôm nay +
  /// nhận định (TutorInsight), gói lại từ AITutorRepository.
  Future<LearningJourney> getLearningJourney();

  /// Chỉ kế hoạch hôm nay — dùng khi nơi gọi không cần bối cảnh/nhận
  /// định đầy đủ.
  Future<DailyLearningPlan> getDailyPlan();
}
