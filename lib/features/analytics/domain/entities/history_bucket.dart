/// Độ chi tiết Learning History (Sprint 14 Phase 1 mục 2).
enum HistoryGranularity { daily, weekly, monthly }

/// 1 mốc trong biểu đồ lịch sử học tập — TÁI SỬ DỤNG dữ liệu phiên đọc
/// thật (StudySessionRepository, có lịch sử từng phiên) làm trục thời
/// gian, KHÔNG phải số liệu ôn SRS (srs_cards không có lịch sử từng
/// lần ôn để dựng biểu đồ nhiều mốc thời gian đáng tin cậy — xem
/// LearningStatistics doc comment và Return Phase 1 mục "Architecture
/// compliance").
class HistoryBucket {
  const HistoryBucket({
    required this.periodStart,
    required this.minutesStudied,
    required this.sessionCount,
  });

  /// Mốc bắt đầu (ngày cụ thể / đầu tuần / đầu tháng tuỳ
  /// [HistoryGranularity]). KHÔNG có trường "label" tính sẵn — nhãn
  /// hiển thị đa ngôn ngữ (vi/en/ar) do tầng UI tự định dạng qua
  /// `intl.DateFormat`, cùng cách _WeeklyChartCard hiện có
  /// (stats_screen.dart) đã làm cho biểu đồ 7 ngày — Calculator thuần
  /// Dart không nên nhúng chuỗi cố định 1 ngôn ngữ.
  final DateTime periodStart;

  final int minutesStudied;
  final int sessionCount;
}
