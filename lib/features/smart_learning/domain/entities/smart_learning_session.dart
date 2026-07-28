import 'learning_recommendation.dart';

/// Phiên học thông minh CHO HÔM NAY (Sprint 17 Phase 1) — danh sách
/// [LearningRecommendation] ĐÃ XẾP HẠNG (recommendations.first là đề
/// xuất ưu tiên nhất — xem smart_learning_session_generator.dart cho
/// quy tắc xếp hạng), suy TRỰC TIẾP từ
/// LearningJourneyRepository.getLearningJourney(), không có nguồn dữ
/// liệu nào khác, không lưu trữ (đúng yêu cầu "No persistence", "No
/// write path" — đối tượng này chỉ tồn tại trong bộ nhớ của 1 lượt
/// gọi, giống DailyLearningPlan — Sprint 16 Phase 1).
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class SmartLearningSession {
  const SmartLearningSession({
    required this.date,
    required this.recommendations,
  });

  /// Ngày áp dụng (đã cắt về 00:00 — cùng quy ước DailyLearningPlan.date).
  final DateTime date;

  /// ĐÃ xếp hạng theo thứ tự ưu tiên đã có sẵn trong
  /// DailyLearningPlan.steps (xem generator) — KHÔNG tính lại mức ưu
  /// tiên nào.
  final List<LearningRecommendation> recommendations;
}
