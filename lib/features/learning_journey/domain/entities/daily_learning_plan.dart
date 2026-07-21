import 'journey_step.dart';

/// Kế hoạch học tập CHO 1 NGÀY CỤ THỂ (Sprint 16 Phase 1) — danh sách
/// [JourneyStep] ĐÃ SẮP XẾP theo mức ưu tiên (xem
/// daily_learning_plan_generator.dart), suy TRỰC TIẾP từ
/// AITutorRepository.getSuggestions() — không có nguồn dữ liệu nào
/// khác, không lưu trữ (đúng yêu cầu "No persistence", "No write
/// path" — đối tượng này chỉ tồn tại trong bộ nhớ của 1 lượt gọi).
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class DailyLearningPlan {
  const DailyLearningPlan({required this.date, required this.steps});

  /// Ngày áp dụng kế hoạch (đã cắt về 00:00 — KHÔNG mang giờ/phút,
  /// tránh so sánh ngày sai lệch do giờ hiện tại).
  final DateTime date;

  /// ĐÃ sắp xếp — [JourneyStep.order] tăng dần đúng theo vị trí trong
  /// danh sách này.
  final List<JourneyStep> steps;
}
