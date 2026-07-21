/// Loại nhận định tổng quan AI Tutor (Sprint 15 Phase 1 mục 2) — khác
/// [TutorSuggestionKind] (hành động NÊN làm), đây là quan sát/tóm tắt
/// KHÔNG kèm hành động cụ thể (vd "độ chính xác của bạn là X%"). Mỗi
/// loại đọc ĐÚNG 1 trường đã có sẵn trong LearningStatistics/
/// Achievement — không tính lại số liệu nào (mục "Do NOT duplicate
/// statistics").
enum TutorInsightKind {
  /// stats.accuracy (0.0-1.0).
  accuracySummary,

  /// stats.readingStreakDays.
  streakSummary,

  /// stats.cardsStudied.
  cardsStudiedSummary,

  /// Số Achievement có isUnlocked == true.
  achievementsUnlockedSummary,
}

/// 1 nhận định — [value] là số ĐÃ CÓ SẴN từ Analytics, đóng gói lại
/// dưới góc nhìn "AI Tutor". KHÔNG có trường "message"/"text" tính
/// sẵn — cùng kỷ luật locale-thuần với TutorSuggestion (xem doc
/// comment ở đó).
class TutorInsight {
  const TutorInsight({required this.kind, required this.value});

  final TutorInsightKind kind;

  /// `num` vì đơn vị khác nhau theo [kind] (tỉ lệ 0.0-1.0, số ngày, số
  /// thẻ, số thành tựu) — tầng trình bày tương lai tự định dạng theo
  /// [kind] (%, "X ngày", v.v.), giống HistoryBucket không tự định
  /// dạng ngày tháng.
  final num value;
}
