import 'entities/tutor_context.dart';
import 'entities/tutor_insight.dart';

/// Hàm THUẦN sinh nhận định từ TutorContext ĐÃ CÓ SẴN — cùng kỷ luật
/// với tutor_suggestion_generator.dart. Mỗi TutorInsight chỉ ĐỌC LẠI
/// đúng 1 trường đã có sẵn (hoặc đếm đơn giản trên 1 danh sách đã có
/// sẵn, vd achievementsUnlockedSummary) — không tính lại số liệu nào.
List<TutorInsight> computeTutorInsights(TutorContext context) {
  final stats = context.statistics;
  final unlockedCount = context.achievements.where((a) => a.isUnlocked).length;

  return [
    TutorInsight(
      kind: TutorInsightKind.accuracySummary,
      value: stats.accuracy,
    ),
    TutorInsight(
      kind: TutorInsightKind.streakSummary,
      value: stats.readingStreakDays,
    ),
    TutorInsight(
      kind: TutorInsightKind.cardsStudiedSummary,
      value: stats.cardsStudied,
    ),
    TutorInsight(
      kind: TutorInsightKind.achievementsUnlockedSummary,
      value: unlockedCount,
    ),
  ];
}
