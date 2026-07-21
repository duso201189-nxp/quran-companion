import 'session_strategy.dart';

/// 1 đề xuất chiến lược học tập (Sprint 17 Phase 1) — [relatedStepCount]
/// ĐẾM lại (không tính lại) số JourneyStep/TutorSuggestion đã có sẵn
/// ứng với [strategy] này (xem smart_learning_session_generator.dart)
/// — đúng yêu cầu "No duplicated calculations": không suy thêm số
/// liệu học tập nào, chỉ nhóm/đếm những gì Learning Journey đã tính
/// sẵn. [estimatedMinutes] là ƯỚC LƯỢNG THEO QUY TẮC cố định cho mỗi
/// [SessionStrategy] (rule-based, KHÔNG phải số liệu đo thực tế) —
/// công khai rõ, xem session_strategy_rules.dart.
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class LearningRecommendation {
  const LearningRecommendation({
    required this.strategy,
    required this.estimatedMinutes,
    required this.relatedStepCount,
  });

  final SessionStrategy strategy;

  /// Ước lượng thời lượng theo quy tắc cố định — KHÔNG đo từ dữ liệu
  /// học tập thật (không có số liệu "thời gian hoàn thành 1 bước"
  /// nào tồn tại để đo).
  final int estimatedMinutes;

  /// Số JourneyStep đã có sẵn (trong DailyLearningPlan.steps hôm nay)
  /// ứng với [strategy] này — đếm lại, không tính toán mới.
  final int relatedStepCount;
}
