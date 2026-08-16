import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../domain/entities/hifz_plan.dart';
import '../domain/entities/hifz_review_history.dart';
import '../domain/hifz_review_history_calculator.dart';
import '../domain/repositories/hifz_review_history_repository.dart';
import 'hifz_providers.dart';
import 'hifz_review_history_repository_impl.dart';

/// Provider lịch sử ôn Hifz — Sprint D6.11 (DR-2026-0026, đã
/// `accepted`).
///
/// Tệp RIÊNG với `hifz_progress_providers.dart` có chủ đích: ảnh chụp
/// hiện tại (`HifzPlanProgress`/`HifzOverallProgress`) và lịch sử sự
/// kiện là HAI khái niệm tách biệt, và ranh giới đó nên nhìn thấy được
/// ngay ở cách bố trí tệp.
final hifzReviewHistoryRepositoryProvider =
    Provider<HifzReviewHistoryRepository>(
  (ref) => HifzReviewHistoryRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Lịch sử ôn của MỘT kế hoạch Hifz, theo `planId`.
///
/// Phạm vi = tập ordinal Ayah của kế hoạch. Đây là PHẠM VI, KHÔNG phải
/// QUY GÁN: nếu hai kế hoạch chồng lấn, cùng một sự kiện xuất hiện hợp
/// lệ trong lịch sử của cả hai (xem doc lớp [HifzReviewHistory]) — và
/// vì thế KHÔNG có provider nào cộng gộp lịch sử nhiều kế hoạch lại.
///
/// KHÔNG lọc theo `plan.startedAt`: một lượt ôn xảy ra TRƯỚC khi kế
/// hoạch được tạo vẫn thuộc phạm vi nếu Ayah của nó nằm trong đoạn.
/// Lọc theo mốc đó chính là quy gán hồi tố mà DR-2026-0026 cấm; sự
/// trung thực được bảo đảm bằng CÂU CHÚ THÍCH ở giao diện
/// (`hifzHistoryScopeNote`), không bằng cách cắt bớt dữ liệu.
///
/// Trạng thái kế hoạch (active/paused/completed) KHÔNG ảnh hưởng: tạm
/// dừng tác động tới việc lên lịch, không tác động tới sự việc đã xảy
/// ra. Trả `null` nếu `planId` không khớp kế hoạch còn sống nào — cùng
/// hợp đồng `hifzPlanProgressProvider`.
///
/// KHÔNG `await hifzSchedulerSyncProvider`: đồng bộ tồn tại để `srs_cards`
/// khớp tập kế hoạch hiện tại, còn provider này đọc `review_events` —
/// bảng mà đồng bộ không bao giờ chạm tới. Tránh phụ thuộc đó cũng là
/// tránh để một màn hình chỉ-đọc kích hoạt một đường ghi.
final hifzPlanReviewHistoryProvider =
    FutureProvider.autoDispose.family<HifzReviewHistory?, String>(
  (ref, planId) async {
    final plans = await ref.watch(hifzPlansProvider.future);
    HifzPlan? plan;
    for (final p in plans) {
      if (p.id == planId) {
        plan = p;
        break;
      }
    }
    if (plan == null) return null;

    final reviewedAtMs = await ref
        .watch(hifzReviewHistoryRepositoryProvider)
        .reviewedAtMsForAyahs(plan.ayahOrdinals.toSet());

    return computeHifzReviewHistory(
      reviewedAtMs: reviewedAtMs,
      now: DateTime.now(),
    );
  },
);
