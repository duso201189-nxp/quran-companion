import 'package:drift/drift.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../domain/repositories/hifz_review_history_repository.dart';

/// Triển khai [HifzReviewHistoryRepository] trên UserDatabase (Drift) —
/// Sprint D6.11 (DR-2026-0026, đã `accepted`).
///
/// CHỈ ĐỌC `review_events`. Không có một lệnh insert/update/delete nào
/// trong tệp này, và không được thêm: bảng đó append-only, đường ghi
/// duy nhất là `SchedulerRepositoryImpl.applyReview` (DR-2026-0024).
///
/// Logger tiêm qua constructor, mọi phương thức công khai bọc
/// `withFailureLogging()` — cùng khuôn `HifzPlanRepositoryImpl`.
class HifzReviewHistoryRepositoryImpl implements HifzReviewHistoryRepository {
  HifzReviewHistoryRepositoryImpl(this._db, this._logger);

  final UserDatabase _db;
  final Logger _logger;

  @override
  Future<List<int>> reviewedAtMsForAyahs(Set<int> ayahOrdinals) {
    return withFailureLogging(_logger, 'reviewedAtMsForAyahs', () async {
      // Tập rỗng -> không dựng truy vấn `IN ()` nào cả.
      if (ayahOrdinals.isEmpty) return const <int>[];

      // Lọc theo (item_type, item_id) — ĐÚNG tiền tố của chỉ mục
      // idx_review_events_item(item_type, item_id, reviewed_at) đã có
      // sẵn từ v8, nên không cần thêm chỉ mục nào.
      //
      // Khoá phạm vi là item_id (ordinal Ayah toàn cục, cố định vĩnh
      // viễn theo Mushaf) chứ KHÔNG phải card_id: card_id là UUID mà
      // tính liên tục của nó phụ thuộc vào cách syncItemsForType hồi
      // sinh thẻ, còn ordinal thì không bao giờ đổi.
      //
      // KHÔNG lọc deleted_at: theo DR-2026-0024 cột đó ở lại NULL vĩnh
      // viễn (không mã nào được uỷ quyền ghi vào nó); lọc ở đây sẽ ngầm
      // giả định một cơ chế xoá chưa hề được quyết định (Quyết định mở
      // #4 của chính DR đó).
      final q = _db.select(_db.reviewEvents)
        ..where(
          (t) =>
              t.itemType.equals(LearningItemType.hifz.name) &
              t.itemId.isIn(ayahOrdinals),
        )
        ..orderBy([(t) => OrderingTerm.asc(t.reviewedAt)]);

      final rows = await q.get();
      return [for (final r in rows) r.reviewedAt];
    });
  }
}
