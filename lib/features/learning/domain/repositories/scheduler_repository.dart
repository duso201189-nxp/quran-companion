import '../entities/srs_card.dart';
import '../scheduling_algorithm.dart';

/// Cổng lịch ôn tập SRS (Sprint 10 — DR-2026-0005). Domain thuần —
/// không biết Drift.
///
/// KHÔNG sở hữu khái niệm "Ayah nào cần ôn" — đó vẫn là trách nhiệm
/// của Revision Queue (ayah_statuses.status='review', xem
/// UserContentRepository.watchAllReviewAyahs()). Scheduler CHỈ thêm
/// lớp lịch trình (ease/interval/due_date) lên trên các mục Revision
/// Queue đã có — không thay thế, không xoá, không sở hữu (DR-2026-0005
/// mục 1-2).
///
/// [syncWithReviewQueue] nhận danh sách thành viên Queue hiện tại từ
/// bên ngoài thay vì tự truy vấn ayah_statuses — Scheduler không phụ
/// thuộc UserContentRepository hay bảng ayah_statuses, giữ ranh giới
/// giữa hai repository độc lập. Việc đọc Revision Queue rồi đưa vào
/// đây là trách nhiệm của tầng provider (Phase 2).
abstract interface class SchedulerRepository {
  /// Đồng bộ thẻ SRS loại 'ayah' với Revision Queue hiện tại: tạo thẻ
  /// mới (trạng thái khởi tạo lấy từ SchedulingAlgorithm) cho Ayah vừa
  /// vào Queue, xoá mềm thẻ của Ayah đã rời Queue. Tự phục hồi khi gọi
  /// lại — không cần backfill lúc migration (DR-2026-0005 mục Migration
  /// Strategy).
  Future<void> syncWithReviewQueue(List<int> currentReviewAyahIds);

  /// Mọi thẻ SRS còn sống cho loại mục [itemType], sắp theo hạn ôn
  /// gần nhất trước.
  Stream<List<SrsCard>> watchAllCards(LearningItemType itemType);

  /// Áp dụng kết quả một lần ôn — uỷ quyền tính toán cho
  /// SchedulingAlgorithm, repository chỉ ghi kết quả xuống persistence.
  Future<void> applyReview(String cardId, ReviewGrade grade);
}
