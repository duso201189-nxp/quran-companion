import '../../../ai_tutor/domain/entities/tutor_suggestion.dart';

/// 1 bước trong hành trình học tập (Sprint 16 Phase 1 mục "Domain") —
/// BỌC LẠI (KHÔNG sao chép) 1 TutorSuggestion đã có sẵn từ AI Tutor
/// (Sprint 15), chỉ thêm [order] (vị trí trong chuỗi ngày hôm nay).
/// KHÔNG có trường title/detail/priority/action/relatedCount riêng —
/// tất cả đọc thẳng qua [suggestion], đúng yêu cầu "No duplicated
/// calculations": Learning Journey không tính lại/sao chép bất kỳ
/// điều kiện/ngưỡng nào AI Tutor đã tính, chỉ SẮP XẾP LẠI những gì đã
/// có (xem daily_learning_plan_generator.dart).
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class JourneyStep {
  const JourneyStep({required this.order, required this.suggestion});

  /// Vị trí trong DailyLearningPlan.steps, bắt đầu từ 0 — KHÔNG phải
  /// mức độ ưu tiên (xem suggestion.priority cho việc đó); order chỉ
  /// là thứ tự trình bày/thực hiện đã được sắp theo priority.
  final int order;

  final TutorSuggestion suggestion;
}
