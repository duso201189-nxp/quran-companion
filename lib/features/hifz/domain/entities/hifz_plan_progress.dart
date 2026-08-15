import '../../../learning/domain/entities/srs_card.dart';
import 'hifz_plan.dart';

/// Ảnh chụp tiến độ HIỆN TẠI của một kế hoạch Hifz — Sprint 7.7c-A.
///
/// CHỈ phản ánh trạng thái persisted hiện tại của các thẻ SRS
/// (`srs_cards`, item_type='hifz') thuộc đoạn của [plan] — KHÔNG phải
/// lịch sử ôn tập: `srs_cards` không lưu sự kiện từng lần ôn, chỉ lưu
/// trạng thái mới nhất (cùng giới hạn đã ghi ở `LearningStatistics`,
/// Sprint 14 Phase 1 — xem doc comment lớp đó). Mọi trường ở đây là
/// một ẢNH CHỤP tại thời điểm tính, không phải một chuỗi sự kiện —
/// không được diễn giải thành "đã ôn bao nhiêu lần" hay "đã học được
/// bao lâu".
class HifzPlanProgress {
  const HifzPlanProgress({
    required this.plan,
    required this.totalAyahCount,
    required this.trackedCardCount,
    required this.stateCounts,
    required this.dueNowCount,
    required this.nextDueAtMs,
    required this.reviewedCardCount,
    required this.averageEaseFactor,
    required this.averageIntervalDays,
  });

  final HifzPlan plan;

  /// Tổng số Ayah trong đoạn kế hoạch (= `plan.ayahCount`).
  final int totalAyahCount;

  /// Số Ayah trong đoạn ĐÃ có thẻ SRS hifz còn sống. Có thể nhỏ hơn
  /// [totalAyahCount] ngay sau khi tạo kế hoạch, trước khi
  /// `hifzSchedulerSyncProvider` chạy lần đầu — KHÔNG phải lỗi dữ
  /// liệu, chỉ là đồng bộ chưa xảy ra.
  final int trackedCardCount;

  /// Số thẻ theo từng [SrsCardState] hiện tại. Luôn có đủ 4 khoá
  /// ([SrsCardState.values]), giá trị 0 nếu trạng thái đó không có thẻ
  /// nào — nơi gọi không cần tự phòng thủ khoá thiếu.
  final Map<SrsCardState, int> stateCounts;

  /// Số thẻ đến hạn ôn NGAY BÂY GIỜ (`due_date` <= thời điểm tính,
  /// cùng ngữ nghĩa "đến hạn" của `selectDueCardsOrdered`).
  final int dueNowCount;

  /// Epoch ms UTC của thẻ đến hạn GẦN NHẤT trong số thẻ được theo dõi
  /// (kể cả đã đến hạn) — `null` nếu [trackedCardCount] bằng 0.
  final int? nextDueAtMs;

  /// Số thẻ đã được ôn ít nhất 1 lần (`repetitions > 0`) — cùng định
  /// nghĩa `LearningStatistics.cardsStudied`.
  final int reviewedCardCount;

  /// Trung bình ease factor, CHỈ tính trên thẻ có `repetitions > 0` —
  /// `null` nếu chưa thẻ nào được ôn. Ease factor mặc định (2.5) của
  /// thẻ mới không mang thông tin thật, đưa vào trung bình sẽ làm sai
  /// lệch số liệu (cùng cách `LearningStatisticsCalculator` xử lý).
  final double? averageEaseFactor;

  /// Trung bình interval (ngày), CHỈ tính trên thẻ có
  /// `repetitions > 0` — cùng lý do và cùng điều kiện trên. `null` nếu
  /// chưa thẻ nào được ôn.
  final int? averageIntervalDays;
}
