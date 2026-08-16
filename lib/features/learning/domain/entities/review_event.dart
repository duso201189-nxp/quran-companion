import '../scheduling_algorithm.dart';
import 'srs_card.dart';

/// Một sự kiện ôn SRS đã CAM KẾT — Sprint D6.6 (DR-2026-0024, đã
/// `accepted`). Domain thuần — không biết Drift.
///
/// KHÁC HẲN [SrsCard]: đây là BẢN GHI BẤT BIẾN của một lần ôn ĐÃ XẢY
/// RA (chuyển trạng thái thẻ SRS đã ghi thật xuống `srs_cards` trong
/// CÙNG một transaction — xem `SchedulerRepositoryImpl.applyReview`),
/// KHÔNG phải trạng thái hiện tại. Mỗi lần ôn tạo MỘT [ReviewEvent]
/// mới — không có sự kiện nào bị sửa hay xoá bởi thao tác thông
/// thường.
///
/// CHỈ tồn tại cho [itemType] `ayah`/`hifz` — `lemma` bị loại khỏi
/// phạm vi phát hành v1 (xem doc comment lớp `ReviewEvents`,
/// `lib/core/database/user/user_tables.dart`): định danh
/// `lemma.item_id` không có bảo đảm ổn định qua các lần build lại nội
/// dung, nên lịch sử bất biến gắn với id đó chưa thể chứng minh vẫn
/// đúng sau này.
///
/// KHÔNG có trường `planId`/`cycleId` — xem doc comment lớp
/// `ReviewEvents` để biết đầy đủ lý do (kế hoạch Hifz chồng lấn khiến
/// 1 `plan_id` là một khẳng định sai; `srs_cards.id` bị hồi sinh/reset
/// nên không phải định danh vòng đời).
class ReviewEvent {
  const ReviewEvent({
    required this.id,
    required this.cardId,
    required this.itemType,
    required this.itemId,
    required this.reviewedAt,
    required this.grade,
    required this.algorithmId,
    required this.beforeState,
    required this.beforeRepetitions,
    required this.beforeIntervalDays,
    required this.beforeEaseFactor,
    required this.beforeDueDate,
    required this.afterState,
    required this.afterRepetitions,
    required this.afterIntervalDays,
    required this.afterEaseFactor,
    required this.afterDueDate,
  });

  final String id;

  /// `srs_cards.id` của thẻ đã được cập nhật cùng lúc.
  final String cardId;

  /// Luôn `ayah` hoặc `hifz` trong v1 — không bao giờ `lemma`.
  final LearningItemType itemType;

  /// Cùng hệ ordinal Ayah toàn cục với `SrsCard.itemId`.
  final int itemId;

  /// Epoch ms UTC — thời điểm ôn, cùng giá trị đã ghi vào
  /// `SrsCard.updatedAtMs` trong cùng lần ôn.
  final int reviewedAt;

  final ReviewGrade grade;

  /// `SchedulingAlgorithm.algorithmId` của thuật toán đã tính lần ôn
  /// này — 'sm2-v1' hoặc 'hifz-sm2-capped-v1'.
  final String algorithmId;

  /// Trạng thái thẻ TRƯỚC lần ôn này.
  final SrsCardState beforeState;
  final int beforeRepetitions;
  final int beforeIntervalDays;
  final double beforeEaseFactor;

  /// Epoch ms UTC — `due_date` TRƯỚC lần ôn này.
  final int beforeDueDate;

  /// Trạng thái thẻ SAU lần ôn này — lưu lại (không suy từ before) để
  /// vẫn đọc đúng ngay cả khi thuật toán scheduling đổi sau này.
  final SrsCardState afterState;
  final int afterRepetitions;
  final int afterIntervalDays;
  final double afterEaseFactor;

  /// Epoch ms UTC — `due_date` SAU lần ôn này.
  final int afterDueDate;
}
