import 'entities/hifz_review_history.dart';

/// Số mốc ngày của phân bố "7 ngày gần đây" — cùng độ dài
/// `computeLearningHistory` mặc định và biểu đồ 7 ngày đã có ở
/// `stats_screen.dart`, không phải một hằng số mới tự đặt ra.
const int hifzReviewHistoryDayCount = 7;

/// Tính [HifzReviewHistory] từ danh sách dấu thời gian đã đọc sẵn —
/// Sprint D6.11 (DR-2026-0026). Thuần Dart: không Flutter/Riverpod/
/// Drift, KHÔNG tự truy vấn, KHÔNG tự đọc đồng hồ hệ thống — [now]
/// truyền vào tường minh, cùng kỷ luật `computeHifzPlanProgress`/
/// `SchedulingAlgorithm`.
///
/// [reviewedAtMs] là epoch ms UTC của MỌI lượt ôn thuộc phạm vi (nơi
/// gọi đã lọc theo `item_type='hifz'` và tập Ayah). Hàm này KHÔNG lọc
/// thêm gì nữa: mọi sự kiện đều được tính, không phân biệt `grade` —
/// một lượt `again` có trọng số hệt một lượt `easy`, vì đây là số LƯỢT
/// ÔN, không phải thước đo mức độ đúng.
HifzReviewHistory computeHifzReviewHistory({
  required List<int> reviewedAtMs,
  required DateTime now,
}) {
  final buckets = <HifzReviewDayBucket>[];

  // i = số ngày lùi về trước so với hôm nay; đếm ngược để danh sách ra
  // theo thứ tự CŨ NHẤT TRƯỚC.
  for (var i = hifzReviewHistoryDayCount - 1; i >= 0; i--) {
    // DateTime(y, m, d - i) tự chuẩn hoá khi tràn qua đầu tháng/năm và
    // luôn cho đúng 00:00 giờ địa phương — an toàn hơn trừ Duration khi
    // có đổi giờ. Cùng cách `_bucketMonthly` dựng mốc đầu tháng.
    final dayStart = DateTime(now.year, now.month, now.day - i);
    final nextDayStart = DateTime(now.year, now.month, now.day - i + 1);

    // Nửa khoảng [dayStart, nextDayStart) — cùng quy ước `_bucketRange`,
    // nhờ đó không sự kiện nào bị đếm hai lần ở ranh giới nửa đêm.
    final startMs = dayStart.toUtc().millisecondsSinceEpoch;
    final endMs = nextDayStart.toUtc().millisecondsSinceEpoch;

    var count = 0;
    for (final ms in reviewedAtMs) {
      if (ms >= startMs && ms < endMs) count++;
    }

    buckets.add(HifzReviewDayBucket(dayStart: dayStart, reviewCount: count));
  }

  return HifzReviewHistory(
    // Tổng tính trên TOÀN BỘ đầu vào, không giới hạn trong cửa sổ 7
    // ngày: một sự kiện cũ hơn cửa sổ vẫn là một lượt ôn đã xảy ra. Vì
    // thế tổng KHÔNG nhất thiết bằng tổng 7 mốc.
    totalReviewCount: reviewedAtMs.length,
    recentDays: buckets,
  );
}
