/// Ảnh chụp số liệu học tập tại 1 thời điểm (Sprint 14 Phase 1). Bao
/// gồm CẢ 2 loại SrsCard (ayah + lemma) — Scheduler dùng chung cho cả
/// Hifz/Ôn tập lẫn Flashcard, nên "học" ở đây không giới hạn riêng
/// Flashcard.
///
/// LƯU Ý VỀ ĐỘ CHÍNH XÁC (công khai, không che giấu — xem
/// LearningStatisticsCalculator để hiểu cách suy ra):
/// - [reviewsToday]/[accuracy] là XẤP XỈ suy từ ảnh chụp hiện tại
///   (srs_cards không lưu lịch sử từng lần ôn, chỉ lưu trạng thái mới
///   nhất — xem docs/DATA_PIPELINE... không, xem Return Sprint 14
///   Phase 1 mục "Architecture compliance"). KHÔNG phải số đếm lịch sử
///   chính xác tuyệt đối.
/// - [readingStreakDays]/[longestReadingStreakDays] là TÁI SỬ DỤNG
///   NGUYÊN VẸN chuỗi ngày đọc đã có (StudySessionRepository,
///   DR-2026-0003/0004) — KHÔNG phải chuỗi ngày ôn SRS riêng (không
///   suy ra được chính xác từ ảnh chụp, xem Calculator).
class LearningStatistics {
  const LearningStatistics({
    required this.cardsStudied,
    required this.dueToday,
    required this.reviewsToday,
    required this.accuracy,
    required this.averageEase,
    required this.averageInterval,
    required this.readingStreakDays,
    required this.longestReadingStreakDays,
  });

  /// Số SrsCard đã ôn ít nhất 1 lần (repetitions > 0).
  final int cardsStudied;

  /// Số SrsCard đến hạn ôn ngay bây giờ (due_date <= hiện tại).
  final int dueToday;

  /// XẤP XỈ: số SrsCard có updated_at rơi vào hôm nay — dưới ước tính
  /// nếu 1 thẻ được ôn nhiều lần trong cùng 1 ngày (updated_at chỉ giữ
  /// lần ôn CUỐI), nhưng thuật toán SM-2 hiện tại không tạo lịch ôn
  /// lại cùng ngày (xem SM2SchedulingAlgorithm — 'again' đặt interval
  /// tối thiểu 1 ngày), nên trong thực tế sai số này gần như luôn là 0.
  final int reviewsToday;

  /// XẤP XỈ (0..1): tỉ lệ SrsCard ĐÃ ÔN (repetitions > 0) KHÔNG ở
  /// trạng thái 'lapsed' — chỉ số "sức khoẻ" tại thời điểm hiện tại,
  /// KHÔNG phải % câu trả lời đúng trên lịch sử (không có lịch sử).
  final double accuracy;

  final double averageEase;
  final double averageInterval;

  /// Tái sử dụng StudySessionRepository.currentStreak() — chuỗi ngày
  /// ĐỌC, không phải chuỗi ngày ôn SRS.
  final int readingStreakDays;
  final int longestReadingStreakDays;
}
