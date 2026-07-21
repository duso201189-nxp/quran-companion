import 'entities/learning_snapshot.dart';

/// Cổng Read Model (Sprint 18 Phase 1) — CHỈ được phép tổng hợp từ
/// SmartLearningRepository (xem LearningSnapshotRepositoryImpl), KHÔNG
/// được biết tới LearningJourneyRepository/AITutorRepository/
/// AnalyticsRepository trực tiếp — đúng yêu cầu "Compose ONLY:
/// SmartLearningRepository. Never access: LearningJourneyRepository/
/// AITutorRepository/AnalyticsRepository directly." Cùng nguyên tắc
/// phân lớp đã thiết lập xuyên suốt: Analytics -> AI Tutor (Sprint 15)
/// -> Learning Journey (Sprint 16) -> Smart Learning (Sprint 17) ->
/// Read Model (Sprint 18), mỗi tầng CHỈ biết tầng ngay dưới nó.
///
/// Domain thuần Dart — không phụ thuộc Flutter/Riverpod, gọi được
/// trực tiếp từ bất kỳ ngữ cảnh nào, cùng nguyên tắc mọi Repository
/// khác trong dự án.
///
/// "No caching policy yet" — [getSnapshot] tạo LearningSnapshot MỚI
/// mỗi lần gọi (không lưu/tái sử dụng kết quả cũ) — nền tảng để 1
/// phase SAU quyết định chính sách cache (TTL, invalidate theo sự
/// kiện...), CHƯA làm ở phase này.
abstract interface class LearningSnapshotRepository {
  /// Ảnh chụp bất biến trạng thái học tập hiện tại — gói lại
  /// TutorContext/TutorInsights/DailyLearningPlan/SmartLearningSession
  /// từ SmartLearningRepository.getSmartLearningSession() đã có.
  Future<LearningSnapshot> getSnapshot();
}
