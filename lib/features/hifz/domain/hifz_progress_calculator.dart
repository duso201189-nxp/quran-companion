import '../../learning/domain/entities/srs_card.dart';
import 'entities/hifz_overall_progress.dart';
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
  final agg = _aggregateCardStats(cards, nowMs);

  return HifzPlanProgress(
    plan: plan,
    totalAyahCount: plan.ayahCount,
    trackedCardCount: cards.length,
    stateCounts: agg.stateCounts,
    dueNowCount: agg.dueNowCount,
    nextDueAtMs: agg.nextDueAtMs,
    reviewedCardCount: agg.reviewedCardCount,
    averageEaseFactor: agg.averageEaseFactor,
    averageIntervalDays: agg.averageIntervalDays,
  );
}

/// Tính ảnh chụp tiến độ TOÀN CỤC — gộp mọi kế hoạch Hifz đang ACTIVE
/// — Sprint D6.4. Cùng kỷ luật thuần Dart với [computeHifzPlanProgress]
/// (không tự truy vấn, [cards] PHẢI đã được lọc sẵn).
///
/// [cards] PHẢI đã được lọc theo tập hợp ordinal Ayah của [activePlans]
/// (nơi gọi dùng `hifzActiveAyahIdsProvider` — xem doc comment provider
/// đó) — hàm này không tự lọc lại, cùng ranh giới đã lập ở
/// [computeHifzPlanProgress].
///
/// KHỬ TRÙNG LẶP khi kế hoạch chồng lấn: hai kế hoạch active có thể
/// cùng chứa một Ayah (`HifzPlanRepository.createPlan` cho phép đoạn
/// chồng lấn là HỢP LỆ), nhưng `UNIQUE(item_type, item_id)` của
/// `srs_cards` đảm bảo Ayah đó chỉ có ĐÚNG 1 thẻ Hifz vật lý — nơi gọi
/// truyền [cards] đã qua lọc theo tập hợp (Set) ordinal của
/// `hifzActiveAyahIdsProvider`, nên [cards] tự nhiên không có phần tử
/// trùng. [totalPlannedAyahs] cũng phải đếm trên tập hợp (Set) ordinal
/// của [activePlans], KHÔNG cộng dồn `plan.ayahCount` của từng kế
/// hoạch — cộng dồn trực tiếp sẽ đếm Ayah chồng lấn nhiều lần, sai với
/// bản chất "1 Ayah = 1 thẻ" mà `hifzActiveAyahIdsProvider` đã xác lập.
HifzOverallProgress computeHifzOverallProgress({
  required List<HifzPlan> activePlans,
  required List<SrsCard> cards,
  required DateTime now,
}) {
  final nowMs = now.toUtc().millisecondsSinceEpoch;
  final agg = _aggregateCardStats(cards, nowMs);

  final uniqueOrdinals = <int>{
    for (final plan in activePlans) ...plan.ayahOrdinals,
  };

  return HifzOverallProgress(
    activePlanCount: activePlans.length,
    totalPlannedAyahs: uniqueOrdinals.length,
    trackedCardCount: cards.length,
    stateCounts: agg.stateCounts,
    dueNowCount: agg.dueNowCount,
    nextDueAtMs: agg.nextDueAtMs,
    reviewedCardCount: agg.reviewedCardCount,
    averageEaseFactor: agg.averageEaseFactor,
    averageIntervalDays: agg.averageIntervalDays,
  );
}

/// Vòng lặp tổng hợp DÙNG CHUNG bởi [computeHifzPlanProgress] (1 kế
/// hoạch) và [computeHifzOverallProgress] (nhiều kế hoạch active) —
/// Sprint D6.4. Trích ra để KHÔNG có 2 bản cài đặt độc lập của cùng 1
/// luật đếm trạng thái/đến hạn/trung bình — sửa 1 lần, cả hai hàm công
/// khai cùng đúng theo.
///
/// Trung bình ease/interval CHỈ tính trên thẻ có `repetitions > 0` —
/// thẻ mới (chưa ôn lần nào) mang giá trị ease/interval MẶC ĐỊNH, đưa
/// vào trung bình sẽ làm sai lệch số liệu (không phản ánh gì về việc
/// ôn tập thật).
({
  Map<SrsCardState, int> stateCounts,
  int dueNowCount,
  int? nextDueAtMs,
  int reviewedCardCount,
  double? averageEaseFactor,
  int? averageIntervalDays,
}) _aggregateCardStats(List<SrsCard> cards, int nowMs) {
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

  return (
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
