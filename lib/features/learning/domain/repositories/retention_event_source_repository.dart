/// Cổng đọc nguồn sự kiện cho công cụ quan sát ghi nhớ — Sprint D7.8
/// (DR-2026-0027, đã `accepted`). Domain thuần — không biết Drift.
///
/// CHỈ ĐỌC. Không có phương thức thêm/sửa/xoá nào, và sẽ KHÔNG BAO GIỜ
/// có: `review_events` là bảng append-only, đường ghi duy nhất là
/// `SchedulerRepositoryImpl.applyReview` (DR-2026-0024 Quyết định 2 và
/// 7). Việc cổng này đọc được nhiều trường hơn D6.11 KHÔNG trao thêm
/// bất kỳ quyền ghi nào.
///
/// KHÔNG thêm phương thức tương đương vào `SchedulerRepository`: giao
/// diện đó là TRẠNG THÁI LẬP LỊCH (DR-2026-0005) và
/// `SchedulerRepositoryImpl` phục vụ cả `lemma` — một API lịch sử ở đó
/// sẽ với tới được loại chưa hề có sự kiện nào, khiến phạm vi
/// `ayah`+`hifz` của D7.8 không còn cưỡng chế được bằng HÌNH DẠNG.
/// Cũng KHÔNG nới cổng D6.11 (`HifzReviewHistoryRepository`): phạm vi
/// của nó chỉ-Hifz theo quản trị, và DR-2026-0026 §"Data sufficiency"
/// CẤM cổng đó lộ chín trường bằng chứng mà D7.8 cần. Đây là một cổng
/// KHÁC, không phải một ngoại lệ của quy định đó.
///
/// KHÔNG nới thành API lịch sử tổng quát: một repository "lịch sử ôn
/// tập" chung sẽ biến phạm vi, danh sách trường và ranh giới không-
/// `lemma` thành chuyện KỶ LUẬT NƠI GỌI thay vì HÌNH DẠNG GIAO DIỆN
/// (DR-2026-0026 phương án D, DR-2026-0027 §"Options considered").
///
/// KHÁC HẲN `retention_seeding_store.dart` (`lib/features/quran/data/`):
/// tệp đó là "retention seeding" của DR-2026-0021 — việc ĐỌC nuôi hàng
/// đợi ôn tập, tức TƯ CÁCH THÀNH VIÊN. Ở đây "retention observation"
/// là BẰNG CHỨNG VỀ SỰ NHỚ LÂU. Hai khái niệm không liên quan và không
/// được lẫn lộn.
library;

/// Phạm vi loại mục mà công cụ quan sát ghi nhớ đọc được — ĐÚNG hai
/// giá trị.
///
/// CỐ Ý KHÔNG dùng lại `LearningItemType`: kiểu đó có nhánh `lemma`.
/// `review_events` KHÔNG chứa dòng `lemma` nào về mặt cấu trúc
/// (DR-2026-0024 Quyết định 3, cưỡng chế tại
/// `SchedulerRepositoryImpl.applyReview`) — đó là SỰ VẮNG MẶT của dữ
/// liệu, không phải một bộ lọc. Làm cho `lemma` KHÔNG BIỂU DIỄN ĐƯỢC
/// sẽ xoá bỏ câu hỏi thay vì trả lời nó: không nơi gọi nào yêu cầu
/// được, nên không cần đường từ chối lúc chạy và không test nào phải
/// khẳng định một sự từ chối mà hệ thống kiểu đã khiến bất khả thi
/// (DR-2026-0027 Quyết định mở #3, giải theo đúng khuyến nghị của
/// chính nó).
enum RetentionItemScope { ayah, hifz }

/// Một dòng `review_events` đã chiếu xuống ĐÚNG 14 trường được uỷ
/// quyền — Sprint D7.8 (DR-2026-0027 §"Field-exposure decision").
///
/// KHÔNG phải `ReviewEvent` (17 trường, gồm cả hai ease factor mà
/// DR-2026-0027 loại trừ TƯỜNG MINH) và KHÔNG phải `ReviewEventRow`
/// của Drift (còn mang `id`, `user_id`, `updated_at`, `deleted_at`,
/// `is_dirty`, và sẽ kéo kiểu Drift vào tầng domain). Kiểu chiếu riêng
/// này tồn tại DUY NHẤT để định nghĩa hợp đồng dữ liệu của cổng này,
/// nên nó khai báo tại đây chứ không phải ở `domain/entities/` — nó
/// không được trở thành từ vựng domain dùng chung.
///
/// KHÔNG thêm trường thứ mười lăm vì "có vẻ hữu ích": cả DR-2026-0026
/// §"Data sufficiency" lẫn DR-2026-0027 §Risks đều nêu việc phình danh
/// sách trường là rủi ro trôi dạt hàng đầu. Một trường nữa cần một
/// quyết định quản trị mới, không phải một lựa chọn lúc hiện thực.
class RetentionSourceEvent {
  const RetentionSourceEvent({
    required this.itemType,
    required this.itemId,
    required this.cardId,
    required this.reviewedAtMs,
    required this.gradeRaw,
    required this.algorithmId,
    required this.beforeStateRaw,
    required this.afterStateRaw,
    required this.beforeRepetitions,
    required this.afterRepetitions,
    required this.beforeIntervalDays,
    required this.afterIntervalDays,
    required this.beforeDueDateMs,
    required this.afterDueDateMs,
  });

  /// Định danh quan sát; khoá phạm vi. `ayah` và `hifz` của CÙNG một
  /// ordinal là HAI mục khác nhau, không bao giờ ghép cặp với nhau.
  final RetentionItemScope itemType;

  /// Ordinal Ayah toàn cục — cùng hệ số cho cả hai loại.
  final int itemId;

  /// `srs_cards.id`. Là ĐIỀU KIỆN liên tục (số hạng 3), KHÔNG phải
  /// khoá gom nhóm: tính liên tục của nó phụ thuộc cách
  /// `syncItemsForType` hồi sinh thẻ, còn ordinal thì cố định vĩnh
  /// viễn theo Mushaf.
  final String cardId;

  /// Epoch ms UTC — chính là PHÉP ĐO khoảng thời gian đã trôi qua.
  final int reviewedAtMs;

  /// Chuỗi `grade` lưu trong database, CHƯA phân giải.
  ///
  /// Cố ý là `String` chứ không phải `ReviewGrade`: cột này là
  /// `TextColumn` không ràng buộc ở mức database, nên một giá trị
  /// ngoài từ vựng vẫn biểu diễn được. Mọi việc kiểm tra hợp lệ dồn về
  /// MỘT chỗ thuần và kiểm thử trực tiếp được (`retention_instrument`),
  /// giữ cho repository ở mức "chỉ đọc, không hiểu".
  final String gradeRaw;

  /// Xuất xứ thuật toán — 'sm2-v1' | 'hifz-sm2-capped-v1'. Mang theo
  /// để một quan sát vắt qua lần đổi thuật toán vẫn đọc hiểu được, và
  /// để lần chuyển sang FSRS không âm thầm diễn giải lại bằng chứng cũ.
  final String algorithmId;

  /// Chuỗi trạng thái lưu trong database, CHƯA phân giải.
  ///
  /// KHÔNG dùng `srsCardStateFromDbValue`: bộ giải mã đó kết thúc bằng
  /// `_ => SrsCardState.newCard` — một FALLBACK IM LẶNG. Trong đường
  /// đọc-và-đo, fallback ấy sẽ BỊA RA bằng chứng: một trạng thái lạ bị
  /// báo cáo thành `new`, khiến một điểm gãy liên tục trông như có thật
  /// (hoặc che mất một điểm gãy thật). DR-2026-0027 Quyết định mở #2
  /// nêu đích danh khuôn mẫu này là thứ không bao giờ được lặp lại.
  final String beforeStateRaw;
  final String afterStateRaw;

  /// Số hạng 5 của điều kiện liên tục — phát hiện lần reset mà
  /// `syncItemsForType` thực hiện.
  final int beforeRepetitions;
  final int afterRepetitions;

  /// Số hạng 6 của điều kiện liên tục; đồng thời là xuất xứ khoảng
  /// lịch đã hẹn (KHÔNG BAO GIỜ dùng để tính thời gian đã trôi qua).
  final int beforeIntervalDays;
  final int afterIntervalDays;

  /// Epoch ms UTC — số hạng 7 của điều kiện liên tục; đồng thời là
  /// xuất xứ hạn đến (KHÔNG BAO GIỜ dùng để tính thời gian đã trôi
  /// qua, KHÔNG so với `asOfMs`, KHÔNG quy thành cờ "quá hạn").
  final int beforeDueDateMs;
  final int afterDueDateMs;
}

/// Đọc sự kiện ôn đã cam kết phục vụ suy dẫn quan sát ghi nhớ —
/// Sprint D7.8 (DR-2026-0027, đã `accepted`).
abstract interface class RetentionEventSourceRepository {
  /// MỌI sự kiện đã ghi cho loại [itemType] có `item_id` thuộc
  /// [itemIds] — tăng dần theo `reviewed_at`, có thứ tự phá hoà ỔN
  /// ĐỊNH cho hai dòng trùng mili giây.
  ///
  /// Trả về GIÁ TRỊ LƯU THÔ, không phải số liệu đã tính: mọi luật về
  /// ghép cặp, liên tục, hợp lệ và thời gian thuộc về hàm thuần
  /// `deriveRetentionObservations` — cùng ranh giới D6.11 đã lập
  /// (repository đọc, hàm thuần tính).
  ///
  /// MỘT lần gọi phủ MỘT phạm vi. Đọc cả `ayah` lẫn `hifz` là HAI lần
  /// gọi tường minh: phạm vi không bao giờ ngầm định, không bao giờ
  /// hợp nhất bên trong repository, và hai loại không bao giờ trộn vào
  /// cùng một danh sách kết quả.
  ///
  /// [itemIds] rỗng -> danh sách rỗng, không truy vấn.
  Future<List<RetentionSourceEvent>> eventsForItems({
    required RetentionItemScope itemType,
    required Set<int> itemIds,
  });
}
