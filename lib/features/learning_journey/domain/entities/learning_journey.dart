import '../../../ai_tutor/domain/entities/tutor_context.dart';
import '../../../ai_tutor/domain/entities/tutor_insight.dart';
import 'daily_learning_plan.dart';

/// Bức tranh tổng thể "hành trình học tập" (Sprint 16 Phase 1) — gói
/// lại ĐÚNG 3 thứ đã có sẵn từ AI Tutor (Sprint 15 Phase 1):
/// [context] (TutorContext.getTutorContext), [todayPlan] (dẫn xuất từ
/// getSuggestions — xem DailyLearningPlan), [insights]
/// (getInsights()) — KHÔNG tính toán/suy diễn thống kê mới nào, đúng
/// yêu cầu "using existing TutorContext, TutorSuggestions,
/// TutorInsights" / "No duplicated calculations".
///
/// CHỈ có kế hoạch CỦA HÔM NAY ở phase này ("Foundation") — chưa có
/// khái niệm nhiều ngày/hành trình dài hạn thật sự (tên "Journey" là
/// định hướng kiến trúc cho tương lai, không phải tính năng đã có ở
/// phase này) — xem Return Phase 1 mục "Remaining backlog".
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class LearningJourney {
  const LearningJourney({
    required this.context,
    required this.todayPlan,
    required this.insights,
  });

  final TutorContext context;
  final DailyLearningPlan todayPlan;
  final List<TutorInsight> insights;
}
