import '../../../learning/domain/entities/srs_card.dart';

/// Ảnh chụp tiến độ HIỆN TẠI gộp mọi kế hoạch Hifz đang ACTIVE — Sprint
/// D6.4, mở rộng trực tiếp tiền lệ [HifzPlanProgress] (Sprint 7.7c-A)
/// sang phạm vi nhiều kế hoạch thay vì một.
///
/// CHỈ phản ánh trạng thái persisted hiện tại của các thẻ SRS
/// (`srs_cards`, item_type='hifz') thuộc Ayah của MỌI kế hoạch active —
/// KHÔNG phải lịch sử ôn tập: `srs_cards` không lưu sự kiện từng lần
/// ôn, chỉ lưu trạng thái mới nhất (cùng giới hạn đã ghi ở
/// [HifzPlanProgress]/`LearningStatistics`). Mọi trường ở đây là một
/// ẢNH CHỤP tại thời điểm tính, không phải một chuỗi sự kiện — không
/// được diễn giải thành "đã ôn bao nhiêu lần", "đã thuộc bao nhiêu %",
/// hay "chuỗi ngày ôn liên tục". Không có trường nào ở đây là mastery/
/// accuracy/streak/tổng lượt ôn — những khái niệm đó cần lịch sử sự
/// kiện chưa tồn tại trong schema hiện tại (xem D6.2/D6.3).
///
/// Kế hoạch paused/completed/xoá mềm KHÔNG góp phần vào ảnh chụp này —
/// chỉ `HifzPlanStatus.active` (xem `hifzActiveAyahIdsProvider`).
class HifzOverallProgress {
  const HifzOverallProgress({
    required this.activePlanCount,
    required this.totalPlannedAyahs,
    required this.trackedCardCount,
    required this.stateCounts,
    required this.dueNowCount,
    required this.nextDueAtMs,
    required this.reviewedCardCount,
    required this.averageEaseFactor,
    required this.averageIntervalDays,
  });

  /// Số kế hoạch đang ở trạng thái active.
  final int activePlanCount;

  /// Số Ayah DUY NHẤT (đã khử trùng lặp) thuộc đoạn của mọi kế hoạch
  /// active — kế hoạch chồng lấn dùng chung Ayah chỉ đếm Ayah đó MỘT
  /// lần, không cộng dồn `ayahCount` của từng kế hoạch.
  final int totalPlannedAyahs;

  /// Số thẻ SRS hifz còn sống ĐÃ khớp tập hợp Ayah active ở trên. Có
  /// thể nhỏ hơn [totalPlannedAyahs] ngay sau khi tạo kế hoạch, trước
  /// khi đồng bộ lần đầu — KHÔNG phải lỗi dữ liệu.
  final int trackedCardCount;

  /// Số thẻ theo từng [SrsCardState] hiện tại, gộp mọi kế hoạch active.
  /// Luôn có đủ 4 khoá, giá trị 0 nếu trạng thái đó không có thẻ nào.
  final Map<SrsCardState, int> stateCounts;

  /// Số thẻ đến hạn ôn NGAY BÂY GIỜ, gộp mọi kế hoạch active.
  final int dueNowCount;

  /// Epoch ms UTC của thẻ đến hạn GẦN NHẤT trong số thẻ được theo dõi
  /// — `null` nếu [trackedCardCount] bằng 0.
  final int? nextDueAtMs;

  /// Số thẻ đã được ôn ít nhất 1 lần (`repetitions > 0`), gộp mọi kế
  /// hoạch active.
  final int reviewedCardCount;

  /// Trung bình ease factor, CHỈ tính trên thẻ có `repetitions > 0` —
  /// `null` nếu chưa thẻ nào được ôn.
  final double? averageEaseFactor;

  /// Trung bình interval (ngày), CHỈ tính trên thẻ có
  /// `repetitions > 0` — `null` nếu chưa thẻ nào được ôn.
  final int? averageIntervalDays;
}
