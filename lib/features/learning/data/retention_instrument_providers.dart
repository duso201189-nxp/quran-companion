import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../domain/repositories/retention_event_source_repository.dart';
import 'retention_event_source_repository_impl.dart';

/// Provider công cụ quan sát ghi nhớ — Sprint D7.8 (DR-2026-0027, đã
/// `accepted`).
///
/// Tệp RIÊNG với `scheduler_providers.dart` có chủ đích, vì HAI lý do
/// độc lập: gộp vào đó là sửa một tệp của Scheduler, mà DR-2026-0027
/// §Non-goals cấm mọi thay đổi Scheduler; và D6.11 đã lập sẵn quy ước
/// tách tệp cho đúng ranh giới ảnh-chụp-so-với-lịch-sử này
/// (`hifz_review_history_providers.dart` tách khỏi
/// `hifz_progress_providers.dart`).
///
/// ĐÚNG MỘT provider trong tệp này — chỉ TIÊM PHỤ THUỘC, không có
/// provider dẫn xuất nào.
///
/// TẠI SAO KHÔNG có provider quan sát dẫn xuất (ghép repository với
/// hàm thuần như `hifzPlanReviewHistoryProvider` của D6.11 đã làm):
/// provider đó của D6.11 tồn tại vì có một MÀN HÌNH THẬT đang hỏi một
/// CÂU HỎI THẬT. D7.8 cố ý chưa có nơi tiêu thụ nào được uỷ quyền, nên
/// một provider dẫn xuất sẽ phải tự bịa ra CẢ HAI vế của một câu hỏi
/// chưa ai đặt: những mục nào thuộc phạm vi, và `asOfMs` nghĩa là gì.
/// Bịa ra hai thứ đó đúng là lối "dựng hạ tầng chỉ vì dữ liệu đã có"
/// mà DR-2026-0026 phương án D và DR-2026-0027 §Dormant-consumer
/// property mục 5 bác bỏ — và nó còn buộc phải đọc đồng hồ ở tầng ghép
/// nối mà chẳng phục vụ nơi gọi nào. Đây là quyết định A1 của kế hoạch
/// hiện thực, đã được người duyệt thông qua.
///
/// Bản thân hàm thuần `deriveRetentionObservations` KHÔNG cần provider
/// nào: nó là một hàm tự do trên dữ liệu mà nơi gọi đã cầm sẵn.
///
/// `Provider` thường — KHÔNG `autoDispose` (tiêm phụ thuộc thì phi
/// trạng thái và rẻ, huỷ đi chẳng được gì) và KHÔNG `family` (không có
/// khoá nào: phạm vi là THAM SỐ của phương thức, không phải khoá
/// provider). Cùng hình dạng `hifzReviewHistoryRepositoryProvider` và
/// `schedulerRepositoryProvider`.
final retentionEventSourceRepositoryProvider =
    Provider<RetentionEventSourceRepository>(
  (ref) => RetentionEventSourceRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);
