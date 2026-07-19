/// Một phiên đọc đã ghi nhận (Sprint 8 — DR-2026-0003 mục A).
class StudySession {
  const StudySession({
    required this.id,
    required this.date,
    required this.surahId,
    required this.ayahFrom,
    required this.ayahTo,
    required this.durationSec,
    this.note,
    required this.createdAt,
  });

  final String id;

  /// 'yyyy-MM-dd' — khớp định dạng StatsStore.dayKey.
  final String date;

  final int surahId;

  /// Chỉ số Ayah 0-based trong Surah (khớp ReadingPositionStore).
  final int ayahFrom;
  final int ayahTo;

  final int durationSec;
  final String? note;

  /// Epoch ms UTC.
  final int createdAt;
}
