import 'entities/srs_card.dart';

/// Đánh giá độ khó khi ôn một thẻ — 4 mức kiểu Anki (đơn giản hơn
/// thang 0-5 gốc của SuperMemo, xem ARCHITECTURE.md §10: "SM-2 —
/// đơn giản, đã kiểm chứng (Anki)").
enum ReviewGrade { again, hard, good, easy }

/// Trạng thái lịch trình tối thiểu mà một thuật toán scheduling cần
/// để tính bước tiếp theo — KHÔNG mang theo id/itemType/itemId (đó là
/// chi tiết lưu trữ, thuộc tầng repository).
typedef SchedulingInput = ({
  double easeFactor,
  int intervalDays,
  int repetitions,
  SrsCardState state,
});

/// Kết quả một lần tính lịch trình.
typedef SchedulingResult = ({
  double easeFactor,
  int intervalDays,
  int repetitions,
  SrsCardState state,
  DateTime dueDate,
});

/// Trừu tượng thuật toán lập lịch ôn tập (Sprint 10 — DR-2026-0005
/// mục 3). Domain thuần — KHÔNG import Flutter/Riverpod/Drift/SQLite.
/// Mọi input (kể cả thời điểm hiện tại) truyền vào tường minh, không
/// đọc đồng hồ hệ thống bên trong — thuần và kiểm thử được không cần
/// mock thời gian.
///
/// Cài đặt hôm nay: SM2SchedulingAlgorithm. Cài đặt mai sau: FSRS —
/// mọi tầng phía trên (repository, provider, UI, Revision Queue, Quiz,
/// Hifz) chỉ phụ thuộc giao diện này, không phụ thuộc SM-2 cụ thể.
abstract interface class SchedulingAlgorithm {
  /// Trạng thái khởi tạo cho một thẻ mới, trước lần ôn đầu tiên. Hằng
  /// số mặc định (vd. ease factor 2.5 của SM-2) thuộc về cài đặt cụ
  /// thể, không hardcode ở tầng repository.
  SchedulingInput initialState();

  /// Tính trạng thái lịch trình kế tiếp sau một lần ôn.
  SchedulingResult review({
    required SchedulingInput current,
    required ReviewGrade grade,
    required DateTime now,
  });
}
