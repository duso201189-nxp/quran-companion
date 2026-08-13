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
///
/// Mô hình miền chính thống (Sprint 7.6 — Sequencing Consolidation):
/// `TutorSuggestion` (định nghĩa ở AITutorRepository) vẫn LÀ mô hình
/// dữ liệu chính thống của chuỗi Sequencing. `SessionStrategy`/
/// `LearningRecommendation` ở đây KHÔNG phải một mô hình gợi ý cạnh
/// tranh — đó là một GÓC NHÌN trình bày riêng, có lý do chính đáng
/// (nhóm theo chiến lược phiên học), suy ra TỪ `TutorSuggestion.kind`
/// của các bước Learning Journey đã có, không thêm nguồn dữ liệu hay
/// quy tắc đủ điều kiện mới nào.
abstract interface class SmartLearningRepository {
  /// Phiên học thông minh hôm nay — đề xuất chiến lược ĐÃ xếp hạng,
  /// suy từ LearningJourney hiện có.
  Future<SmartLearningSession> getSmartLearningSession();
}
