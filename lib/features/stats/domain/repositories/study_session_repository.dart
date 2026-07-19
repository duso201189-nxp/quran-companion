import '../entities/study_session.dart';

/// Cổng dữ liệu phiên đọc (Sprint 8 — DR-2026-0003 mục A). Domain
/// không biết Drift. Streak/tổng phút TÍNH TRÊN TRUY VẤN từ đây —
/// không có repository/bảng streaks riêng (xem DR-2026-0003, "thiết
/// kế dẫn xuất-khi-đọc tương đương").
abstract interface class StudySessionRepository {
  /// Ghi 1 phiên đọc. Trả về id phiên vừa tạo.
  Future<String> logSession({
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    String? note,
  });

  /// Mọi phiên đọc còn sống, mới nhất trước.
  Stream<List<StudySession>> watchAllSessions();

  /// Phiên đọc trong 1 ngày cụ thể ('yyyy-MM-dd').
  Stream<List<StudySession>> watchSessionsOnDate(String date);

  /// Tổng số giây đọc trong 1 ngày.
  Future<int> totalDurationOnDate(String date);

  /// Các ngày có đọc (distinct date), không đảm bảo thứ tự.
  Future<Set<String>> distinctReadingDates();

  /// Chuỗi ngày liên tiếp tính đến [today] (hoặc hôm qua nếu hôm
  /// nay chưa đọc) — cùng thuật toán StatsStore.currentStreak,
  /// nhưng nguồn dữ liệu là study_sessions thay vì SharedPreferences.
  Future<int> currentStreak({DateTime? today});

  /// Chuỗi ngày liên tiếp dài nhất trong toàn bộ lịch sử.
  Future<int> longestStreak();
}
