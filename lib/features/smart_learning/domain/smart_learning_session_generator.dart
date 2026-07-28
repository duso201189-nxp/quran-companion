import '../../learning_journey/domain/entities/learning_journey.dart';
import 'entities/learning_recommendation.dart';
import 'entities/session_strategy.dart';
import 'entities/smart_learning_session.dart';
import 'session_strategy_rules.dart';

/// Hàm THUẦN sinh SmartLearningSession từ LearningJourney ĐÃ CÓ SẴN
/// (tham số truyền vào, không tự truy vấn) — cùng kỷ luật với mọi
/// Calculator thuần trong dự án (vd
/// daily_learning_plan_generator.dart, tutor_suggestion_generator.dart):
/// tách khỏi Repository để test trực tiếp không cần DB/provider.
///
/// QUY TẮC XẾP HẠNG (rule-based, KHÔNG AI): duyệt
/// journey.todayPlan.steps THEO ĐÚNG THỨ TỰ ĐÃ CÓ (Sprint 16 Phase 1
/// — DailyLearningPlan.steps ĐÃ được sắp theo mức ưu tiên, xem
/// daily_learning_plan_generator.dart) — KHÔNG sắp xếp lại/tính lại
/// mức ưu tiên nào ở đây, chỉ NHÓM các bước theo SessionStrategy
/// tương ứng và giữ nguyên thứ tự nhóm xuất hiện lần đầu (nhóm chứa
/// bước ưu tiên cao nhất tự nhiên đứng trước) — đúng yêu cầu "No
/// duplicated calculations".
SmartLearningSession computeSmartLearningSession(
  LearningJourney journey,
  DateTime date,
) {
  final countByStrategy = <SessionStrategy, int>{};
  final firstSeenOrder = <SessionStrategy>[];

  for (final step in journey.todayPlan.steps) {
    final strategy = strategyForSuggestionKind(step.suggestion.kind);
    if (strategy == null) continue;
    if (!countByStrategy.containsKey(strategy)) {
      firstSeenOrder.add(strategy);
    }
    countByStrategy[strategy] = (countByStrategy[strategy] ?? 0) + 1;
  }

  final recommendations = [
    for (final strategy in firstSeenOrder)
      LearningRecommendation(
        strategy: strategy,
        estimatedMinutes: estimatedMinutesFor(strategy),
        relatedStepCount: countByStrategy[strategy]!,
      ),
  ];

  return SmartLearningSession(
    date: DateTime(date.year, date.month, date.day),
    recommendations: recommendations,
    journey: journey,
  );
}
