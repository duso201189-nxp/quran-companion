import '../../learning/domain/entities/srs_card.dart';
import 'entities/hifz_plan.dart';
import 'entities/hifz_plan_progress.dart';

/// Tính ảnh chụp tiến độ một kế hoạch Hifz từ trạng thái SRS hiện tại
/// — Sprint 7.7c-A. Thuần Dart, không Flutter/Riverpod/Drift, cùng kỷ
/// luật `LearningStatisticsCalculator`/`selectDueCardsOrdered`: KHÔNG
/// tự truy vấn DB, chỉ nhận dữ liệu đã đọc sẵn từ nơi gọi.
///
/// [cards] PHẢI đã được lọc sẵn về đúng [plan] (chỉ thẻ có `itemId`
/// nằm trong `plan.ayahOrdinals`, `itemType == LearningItemType.hifz`)
/// — hàm này không tự lọc lại theo plan, để giữ ranh giới rõ giữa nơi
/// gọi (biết kế hoạch nào, biết cách đọc `HifzPlanRepository`/
/// `SchedulerRepository`) và hàm tính thuần (không biết nguồn dữ
/// liệu, không biết Riverpod/Drift).
///
/// KHÔNG suy ra hay bịa lịch sử ôn tập: mọi con số ở đây đến thẳng từ
/// trạng thái persisted hiện tại của [cards], không có bước nội suy
/// hay giả định thời điểm nào ngoài [now] (tham số tường minh, không
/// tự đọc đồng hồ hệ thống — cùng kỷ luật `SchedulingAlgorithm`).
HifzPlanProgress computeHifzPlanProgress({
  required HifzPlan plan,
  required List<SrsCard> cards,
  required DateTime now,
}) {
  final nowMs = now.toUtc().millisecondsSinceEpoch;

  final stateCounts = <SrsCardState, int>{
    for (final s in SrsCardState.values) s: 0,
  };
  var dueNowCount = 0;
  int? nextDueAtMs;
  var reviewedCardCount = 0;
  var easeSum = 0.0;
  var intervalSum = 0;
  var reviewedForAverage = 0;

  for (final card in cards) {
    stateCounts[card.state] = (stateCounts[card.state] ?? 0) + 1;

    if (card.dueDate <= nowMs) dueNowCount++;
    if (nextDueAtMs == null || card.dueDate < nextDueAtMs) {
      nextDueAtMs = card.dueDate;
    }

    if (card.repetitions > 0) {
      reviewedCardCount++;
      easeSum += card.easeFactor;
      intervalSum += card.intervalDays;
      reviewedForAverage++;
    }
  }

  return HifzPlanProgress(
    plan: plan,
    totalAyahCount: plan.ayahCount,
    trackedCardCount: cards.length,
    stateCounts: stateCounts,
    dueNowCount: dueNowCount,
    nextDueAtMs: nextDueAtMs,
    reviewedCardCount: reviewedCardCount,
    averageEaseFactor:
        reviewedForAverage == 0 ? null : easeSum / reviewedForAverage,
    averageIntervalDays: reviewedForAverage == 0
        ? null
        : (intervalSum / reviewedForAverage).round(),
  );
}
