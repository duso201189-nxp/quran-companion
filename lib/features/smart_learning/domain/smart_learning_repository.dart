import 'entities/smart_learning_session.dart';

/// Cổng Smart Learning (Sprint 17 Phase 1) — CHỈ được phép tổng hợp
/// từ LearningJourneyRepository (xem SmartLearningRepositoryImpl),
/// KHÔNG được biết tới AITutorRepository/AnalyticsRepository trực
/// tiếp — đúng yêu cầu "Compose ONLY: LearningJourneyRepository.
/// Never access AITutorRepository directly." Cùng nguyên tắc phân lớp
/// đã thiết lập: Analytics -> AI Tutor (Sprint 15) -> Learning
/// Journey (Sprint 16) -> Smart Learning (Sprint 17), mỗi tầng CHỈ
/// biết tầng ngay dưới nó.
///
/// Domain thuần Dart — không phụ thuộc Flutter/Riverpod, gọi được
/// trực tiếp từ bất kỳ ngữ cảnh nào, cùng nguyên tắc AnalyticsRepository/
/// AITutorRepository/LearningJourneyRepository.
///
/// Phase 1 CHỈ là nền kiến trúc — "Foundation" (đúng tên Sprint): đề
/// xuất sinh ra bằng QUY TẮC thuần (ánh xạ loại gợi ý -> chiến lược),
/// KHÔNG AI/mạng ("No AI SDK", "No networking").
abstract interface class SmartLearningRepository {
  /// Phiên học thông minh hôm nay — đề xuất chiến lược ĐÃ xếp hạng,
  /// suy từ LearningJourney hiện có.
  Future<SmartLearningSession> getSmartLearningSession();
}
