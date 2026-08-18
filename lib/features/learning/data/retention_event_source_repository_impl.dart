import 'package:drift/drift.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/srs_card.dart';
import '../domain/repositories/retention_event_source_repository.dart';

/// Triển khai [RetentionEventSourceRepository] trên UserDatabase
/// (Drift) — Sprint D7.8 (DR-2026-0027, đã `accepted`).
///
/// CHỈ ĐỌC `review_events`. KHÔNG có một lệnh insert/update/delete nào
/// trong tệp này, và KHÔNG ĐƯỢC thêm — bây giờ hay ở bất kỳ lần sửa
/// nào về sau: bảng đó append-only, đường ghi duy nhất là
/// `SchedulerRepositoryImpl.applyReview` (DR-2026-0024 Quyết định 2 và
/// 7). Việc đọc được nhiều trường hơn D6.11 KHÔNG trao quyền ghi
/// chúng, và không trao quyền ghi bất cứ thứ gì khác.
///
/// Kiểu dòng Drift (`ReviewEventRow`) KHÔNG BAO GIỜ rời khỏi tệp này:
/// nó còn mang `id`, `user_id`, `updated_at`, `deleted_at`, `is_dirty`
/// và sẽ kéo Drift vào tầng domain. Mỗi dòng được chiếu xuống ĐÚNG 14
/// trường của [RetentionSourceEvent] và bảy cột còn lại bị BỎ ĐI.
///
/// Logger tiêm qua constructor, mọi phương thức công khai bọc
/// `withFailureLogging()` — cùng khuôn `HifzReviewHistoryRepositoryImpl`
/// và `SchedulerRepositoryImpl`.
class RetentionEventSourceRepositoryImpl
    implements RetentionEventSourceRepository {
  RetentionEventSourceRepositoryImpl(this._db, this._logger);

  final UserDatabase _db;
  final Logger _logger;

  @override
  Future<List<RetentionSourceEvent>> eventsForItems({
    required RetentionItemScope itemType,
    required Set<int> itemIds,
  }) {
    return withFailureLogging(_logger, 'eventsForItems', () async {
      // Tập rỗng -> không dựng truy vấn `IN ()` nào cả (tiền lệ D6.11).
      if (itemIds.isEmpty) return const <RetentionSourceEvent>[];

      // Lọc theo (item_type, item_id) — ĐÚNG tiền tố của chỉ mục
      // idx_review_events_item(item_type, item_id, reviewed_at) đã có
      // sẵn từ v8, nên KHÔNG cần thêm chỉ mục nào.
      //
      // Khoá phạm vi là item_id (ordinal Ayah toàn cục, cố định vĩnh
      // viễn theo Mushaf) chứ KHÔNG phải card_id: tính liên tục của
      // card_id phụ thuộc cách syncItemsForType hồi sinh thẻ, còn
      // ordinal thì không bao giờ đổi. card_id chỉ là ĐIỀU KIỆN liên
      // tục, kiểm ở hàm thuần.
      //
      // MỘT lần gọi phủ MỘT phạm vi: hai loại KHÔNG bao giờ được hợp
      // nhất bên trong đây.
      //
      // KHÔNG lọc deleted_at: theo DR-2026-0024 cột đó ở lại NULL vĩnh
      // viễn (không mã nào được uỷ quyền ghi vào nó); lọc ở đây sẽ ngầm
      // giả định một cơ chế xoá chưa hề được quyết định (Quyết định mở
      // #4 của chính DR đó). Cùng lập luận D6.11 đã ghi.
      final q = _db.select(_db.reviewEvents)
        ..where(
          (t) => t.itemType.equals(_dbValue(itemType)) & t.itemId.isIn(itemIds),
        )
        // Phá hoà bằng `id` (khoá chính TEXT) để hai dòng trùng
        // `reviewed_at` luôn ra cùng một thứ tự giữa các lần gọi:
        // `review_events` cố ý KHÔNG khai `uniqueKeys` và không gì ràng
        // buộc `reviewed_at` phải phân biệt, nên trùng mili giây là
        // biểu diễn được. `id` chỉ dùng ĐÚNG ở đây và không bao giờ
        // vượt qua cổng đọc — thứ tự toàn phần mà không cần trường thứ
        // mười lăm.
        ..orderBy([
          (t) => OrderingTerm.asc(t.reviewedAt),
          (t) => OrderingTerm.asc(t.id),
        ]);

      final rows = await q.get();
      return [
        for (final r in rows)
          RetentionSourceEvent(
            // Loại lấy từ THAM SỐ phạm vi, không phân giải lại từ
            // chuỗi trong dòng: truy vấn đã lọc đúng bằng chuỗi đó, nên
            // mọi dòng trả về đều thuộc đúng loại này. Nhờ vậy tránh
            // được khuôn mẫu `LearningItemType.values.asNameMap()[...]
            // ?? LearningItemType.ayah` của đường GHI — một fallback im
            // lặng không được phép xuất hiện trong đường đọc-và-đo.
            itemType: itemType,
            itemId: r.itemId,
            cardId: r.cardId,
            reviewedAtMs: r.reviewedAt,
            // Chuỗi THÔ, chưa phân giải: mọi việc kiểm tra hợp lệ dồn
            // về hàm thuần, nơi một giá trị lạ được ĐẾM chứ không bị ép
            // về mặc định.
            gradeRaw: r.grade,
            algorithmId: r.algorithmId,
            beforeStateRaw: r.beforeState,
            afterStateRaw: r.afterState,
            beforeRepetitions: r.beforeRepetitions,
            afterRepetitions: r.afterRepetitions,
            beforeIntervalDays: r.beforeIntervalDays,
            afterIntervalDays: r.afterIntervalDays,
            beforeDueDateMs: r.beforeDueDate,
            afterDueDateMs: r.afterDueDate,
            // BỎ ĐI, có chủ đích: before_ease_factor, after_ease_factor
            // (tham số tinh chỉnh riêng của SM-2, không nằm trong số
            // hạng nào của điều kiện liên tục, và sẽ kéo so sánh dấu
            // phẩy động vào đó), cùng id/user_id/updated_at/deleted_at/
            // is_dirty (sổ sách đồng bộ, không phải bằng chứng ghi nhớ).
          ),
      ];
    });
  }

  /// Ánh xạ phạm vi -> chuỗi `item_type` lưu trong database.
  ///
  /// Đi qua [LearningItemType] để chuỗi luôn khớp ĐÚNG cái mà
  /// `applyReview` đã ghi, thay vì viết lại chuỗi bằng tay ở đây. Ánh
  /// xạ này là chỗ DUY NHẤT hai từ vựng gặp nhau, và nó chỉ ở tầng
  /// data: tầng domain không bao giờ thấy `LearningItemType`, nên
  /// `lemma` vẫn không biểu diễn được ở cổng đọc.
  String _dbValue(RetentionItemScope scope) => switch (scope) {
        RetentionItemScope.ayah => LearningItemType.ayah.name,
        RetentionItemScope.hifz => LearningItemType.hifz.name,
      };
}
