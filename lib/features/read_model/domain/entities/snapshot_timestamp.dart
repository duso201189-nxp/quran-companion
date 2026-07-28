/// Thời điểm 1 LearningSnapshot được sinh ra (Sprint 18 Phase 1) — bọc
/// riêng thay vì dùng thẳng DateTime để làm rõ NGỮ NGHĨA ("đây là mốc
/// sinh snapshot, không phải ngày áp dụng kế hoạch" — khác
/// DailyLearningPlan.date/SmartLearningSession.date, vốn là NGÀY áp
/// dụng, không phải THỜI ĐIỂM đọc) — tránh nhầm lẫn khi
/// LearningSnapshot có NHIỀU trường DateTime-like khác nhau (ngày kế
/// hoạch bên trong dailyPlan/smartSession, VÀ thời điểm đọc snapshot
/// này).
///
/// Domain thuần Dart — không phụ thuộc Flutter.
class SnapshotTimestamp {
  const SnapshotTimestamp(this.generatedAt);

  /// Thời điểm THẬT (giờ/phút/giây) snapshot được tạo — KHÔNG cắt về
  /// 00:00 (khác DailyLearningPlan.date) vì đây là mốc thời gian đọc,
  /// không phải ngày áp dụng.
  final DateTime generatedAt;
}
