import '../../stats/domain/entities/study_session.dart';
import 'entities/history_bucket.dart';

/// Hàm THUẦN gộp StudySession (Sprint 8, DR-2026-0003 — CÓ lịch sử
/// từng phiên thật, khác srs_cards) theo Ngày/Tuần/Tháng (Sprint 14
/// Phase 1 mục 2). TÁI SỬ DỤNG StudySessionRepository.watchAllSessions()
/// làm nguồn — KHÔNG có bảng lịch sử riêng cho Learning History.
///
/// [count] mốc GẦN NHẤT tính đến [now], mốc cũ nhất trước (thứ tự vẽ
/// biểu đồ trái->phải theo thời gian).
List<HistoryBucket> computeLearningHistory(
  List<StudySession> sessions,
  HistoryGranularity granularity, {
  int count = 7,
  DateTime? now,
}) {
  final anchor = now ?? DateTime.now();
  final byDate = _groupByDateKey(sessions);
  return switch (granularity) {
    HistoryGranularity.daily => _bucketDaily(byDate, count, anchor),
    HistoryGranularity.weekly => _bucketWeekly(byDate, count, anchor),
    HistoryGranularity.monthly => _bucketMonthly(byDate, count, anchor),
  };
}

List<HistoryBucket> _bucketDaily(
  Map<String, List<StudySession>> byDate,
  int count,
  DateTime anchor,
) {
  final today = DateTime(anchor.year, anchor.month, anchor.day);
  return [
    for (var i = count - 1; i >= 0; i--)
      _bucketRange(
        start: today.subtract(Duration(days: i)),
        end: today.subtract(Duration(days: i - 1)),
        byDate: byDate,
      ),
  ];
}

List<HistoryBucket> _bucketWeekly(
  Map<String, List<StudySession>> byDate,
  int count,
  DateTime anchor,
) {
  final today = DateTime(anchor.year, anchor.month, anchor.day);
  // Đầu tuần hiện tại (Thứ 2), rồi lùi dần từng tuần trước đó.
  final startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
  return [
    for (var i = count - 1; i >= 0; i--)
      _bucketRange(
        start: startOfThisWeek.subtract(Duration(days: 7 * i)),
        end: startOfThisWeek.subtract(Duration(days: 7 * (i - 1))),
        byDate: byDate,
      ),
  ];
}

List<HistoryBucket> _bucketMonthly(
  Map<String, List<StudySession>> byDate,
  int count,
  DateTime anchor,
) {
  return [
    for (var i = count - 1; i >= 0; i--)
      _bucketRange(
        start: DateTime(anchor.year, anchor.month - i, 1),
        end: DateTime(anchor.year, anchor.month - i + 1, 1),
        byDate: byDate,
      ),
  ];
}

Map<String, List<StudySession>> _groupByDateKey(List<StudySession> sessions) {
  final map = <String, List<StudySession>>{};
  for (final s in sessions) {
    map.putIfAbsent(s.date, () => []).add(s);
  }
  return map;
}

/// Gộp mọi StudySession có `date` trong nửa khoảng [start, end) —
/// dùng chung cho cả 3 độ chi tiết (1 ngày / 7 ngày / 1 tháng đều là
/// 1 khoảng ngày liên tục, chỉ khác độ dài).
HistoryBucket _bucketRange({
  required DateTime start,
  required DateTime end,
  required Map<String, List<StudySession>> byDate,
}) {
  final sessions = <StudySession>[];
  for (final entry in byDate.entries) {
    final d = DateTime.parse(entry.key);
    if (!d.isBefore(start) && d.isBefore(end)) {
      sessions.addAll(entry.value);
    }
  }
  return HistoryBucket(
    periodStart: start,
    minutesStudied: _totalMinutes(sessions),
    sessionCount: sessions.length,
  );
}

int _totalMinutes(List<StudySession> sessions) {
  var totalSec = 0;
  for (final s in sessions) {
    totalSec += s.durationSec;
  }
  return totalSec ~/ 60;
}
