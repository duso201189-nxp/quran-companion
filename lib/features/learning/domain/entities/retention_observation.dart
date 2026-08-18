import '../repositories/retention_event_source_repository.dart';
import '../scheduling_algorithm.dart';
import 'srs_card.dart';

/// MỘT quan sát ghi nhớ — Sprint D7.8 (DR-2026-0027, đã `accepted`).
/// Domain thuần — không biết Drift.
///
/// Là một cặp sự kiện ôn đã cam kết, CÓ THỨ TỰ và CHỨNG MINH ĐƯỢC TÍNH
/// LIÊN TỤC, của cùng một mục: đo khoảng thời gian thực tế (đồng hồ
/// treo tường) đã trôi qua giữa hai sự kiện, và kết quả nhớ lại được
/// ghi nhận ở cuối khoảng đó.
///
/// KHÁC HẲN [SrsCard]: thẻ SRS là ẢNH CHỤP trạng thái lập lịch hiện
/// tại; lớp này dẫn xuất từ `review_events` — chuỗi sự kiện bất biến.
/// Cũng KHÁC HẲN `HifzReviewHistory` của D6.11: lớp đó ĐẾM số lượt ôn
/// (một thước đo HOẠT ĐỘNG mà Hiến pháp Study §8 loại trừ tường minh
/// khỏi định nghĩa ghi nhớ); lớp này hỏi mục có SỐNG SÓT qua một
/// khoảng thời gian hay không.
///
/// CỐ Ý KHÔNG PHÁN XÉT. Đây là BẰNG CHỨNG, không phải phán quyết:
/// không điểm số, không xếp hạng, không tỉ lệ phần trăm, không cờ
/// "nhớ / không nhớ", không mức độ thuộc, không độ chính xác, không
/// chuỗi ngày, không chỉ tiêu, không tổng hợp thành một con số duy
/// nhất — ở lớp này hay bất kỳ đâu trong D7.8. Một lượt `again` sau 40
/// ngày là bằng chứng, không phải thất bại; một lần chuyển sang
/// `lapsed` là thay đổi trạng thái mà bộ lập lịch tự ghi lại, không
/// phải lời phán về con người. Công cụ này đo bằng chứng về sự nhớ
/// lâu; nó KHÔNG định nghĩa thành công tôn giáo của người dùng.
class RetentionObservation {
  const RetentionObservation({
    required this.itemType,
    required this.itemId,
    required this.cardId,
    required this.predecessorReviewedAtMs,
    required this.successorReviewedAtMs,
    required this.elapsedMs,
    required this.outcomeGrade,
    required this.beforeState,
    required this.afterState,
    required this.scheduledIntervalDays,
    required this.scheduledDueDateMs,
    required this.predecessorAlgorithmId,
    required this.successorAlgorithmId,
  });

  final RetentionItemScope itemType;
  final int itemId;

  /// Bằng nhau ở CẢ HAI đầu cặp — đó là số hạng 3 của điều kiện liên
  /// tục, nên một quan sát chỉ tồn tại khi hai đầu chung một `card_id`.
  final String cardId;

  /// Epoch ms UTC — thời điểm ôn của sự kiện TRƯỚC.
  final int predecessorReviewedAtMs;

  /// Epoch ms UTC — thời điểm ôn của sự kiện SAU.
  final int successorReviewedAtMs;

  /// `successorReviewedAtMs - predecessorReviewedAtMs`, mili giây.
  ///
  /// Là THỜI GIAN THẬT ĐÃ SỐNG SÓT, không phải thời gian đã hẹn lịch.
  /// TUYỆT ĐỐI không suy từ `after_interval_days`, `after_due_date`,
  /// diễn biến ease factor hay bất kỳ tái dựng công thức SM-2 nào:
  /// người dùng ôn sớm và ôn muộn, nên đo lịch trình là đo Ý ĐỊNH CỦA
  /// THUẬT TOÁN chứ không phải sự ghi nhớ của người dùng — đúng phép
  /// đánh tráo mà Hiến pháp Study §8 cấm. Yêu cầu này còn khiến công
  /// cụ vẫn đúng NGUYÊN VẸN khi thuật toán đổi sang FSRS
  /// (DR-2026-0027 §"Algorithm agnosticism").
  ///
  /// Lưu thẳng dù bằng hiệu hai đầu, vì nó CHÍNH LÀ phép đo và thực
  /// thể nên nói thẳng ra thay vì bắt mọi người đọc tự tính lại.
  ///
  /// KHÔNG quy đổi sang ngày/tuần/tháng: quy đổi lịch là quyết định về
  /// làm tròn và múi giờ, thuộc về nơi gọi nào thật sự cần nó.
  final int elapsedMs;

  /// `grade` THÔ của sự kiện SAU — bằng chứng đầu tiên về khả năng nhớ
  /// lại của mục SAU KHI khoảng thời gian đã trôi qua.
  ///
  /// Thô, và chỉ thô: không ánh xạ thành đúng/sai, không đánh trọng
  /// số, không lấy trung bình, không quy thành phần trăm hay boolean.
  /// Bốn mức là độ phân giải trung thực của bằng chứng gốc; ép chúng
  /// lại sẽ phá huỷ chính thông tin mà công cụ này tồn tại để giữ.
  ///
  /// KHÔNG mang `grade` của sự kiện TRƯỚC: nó không phải kết quả của
  /// khoảng thời gian này.
  final ReviewGrade outcomeGrade;

  /// Chuyển trạng thái của sự kiện SAU — `before_state` -> `after_state`.
  ///
  /// Là BẰNG CHỨNG, KHÔNG phải phán quyết: công cụ báo cáo lần chuyển,
  /// nó không chấm điểm lần chuyển đó.
  final SrsCardState beforeState;
  final SrsCardState afterState;

  /// `after_interval_days` của sự kiện TRƯỚC — điều bộ lập lịch ĐÃ
  /// YÊU CẦU.
  ///
  /// Mang theo để đọc quan sát TRONG NGỮ CẢNH: 60 ngày trôi qua trên
  /// một thẻ hẹn 10 ngày là bằng chứng khác hẳn 60 ngày trên một thẻ
  /// hẹn 60 ngày. CỐ Ý KHÔNG có trường `latenessMs` tính sẵn: "ghi
  /// nhận độ trễ như xuất xứ" đã thoả bằng việc mang cả hai đầu, còn
  /// một con số mang tên "độ trễ" thì tiến một bước về phía khung
  /// gắn-cờ-và-chấm-điểm mà §Worship-First cấm.
  final int scheduledIntervalDays;

  /// Epoch ms UTC — `after_due_date` của sự kiện TRƯỚC.
  final int scheduledDueDateMs;

  /// Xuất xứ thuật toán của CẢ HAI đầu, giữ độc lập: một quan sát có
  /// thể vắt qua một lần đổi thuật toán và vẫn phải đọc hiểu được.
  final String predecessorAlgorithmId;
  final String successorAlgorithmId;
}

/// Một ĐIỂM GÃY liên tục giữa hai sự kiện kề nhau của cùng một mục —
/// Sprint D7.8 (DR-2026-0027 §"Continuity and reset semantics").
///
/// Điểm gãy là một SỰ THẬT về lịch sử và phải nhìn thấy được, không
/// được nuốt trong im lặng: một kết quả rỗng do đứt gãy KHÁC HẲN một
/// kết quả rỗng do không có dữ liệu.
///
/// CỐ Ý KHÔNG đặt tên hai bên điểm gãy là "một chu kỳ": DR-2026-0024
/// Quyết định 5 và 6 ràng buộc — không `plan_id`, không `cycle_id`,
/// không mô hình vòng đời học. Lần reset được PHÁT HIỆN, không bao giờ
/// được ĐẶT TÊN.
///
/// CỐ Ý KHÔNG có enum "lý do" chỉ ra số hạng nào của điều kiện đã
/// hỏng: điều đó sẽ bịa ra từ vựng trước khi có nơi gọi nào cần tới,
/// còn định danh cặp cộng hai mốc thời gian đã đủ để người đọc chẩn
/// đoán định vị được điểm gãy.
class RetentionDiscontinuity {
  const RetentionDiscontinuity({
    required this.itemType,
    required this.itemId,
    required this.predecessorCardId,
    required this.successorCardId,
    required this.predecessorReviewedAtMs,
    required this.successorReviewedAtMs,
  });

  final RetentionItemScope itemType;
  final int itemId;

  /// Hai `card_id` — có thể BẰNG NHAU: một điểm gãy do trạng thái
  /// before/after lệch nhau vẫn xảy ra trong cùng một `card_id`, và đó
  /// chính là dấu vết của lần hồi-sinh-và-reset mà `syncItemsForType`
  /// thực hiện trên CÙNG `srs_cards.id`.
  final String predecessorCardId;
  final String successorCardId;

  final int predecessorReviewedAtMs;
  final int successorReviewedAtMs;
}

/// Kết quả MỘT lần suy dẫn: các quan sát, các điểm gãy, và các bộ đếm
/// mô tả trung thực việc suy dẫn đã thật sự làm gì — Sprint D7.8
/// (DR-2026-0027 §"What the instrument measures" mục 7).
///
/// Bộ đếm là MỘT PHẦN CỦA KẾT QUẢ, không phải log. Nhờ chúng, nơi gọi
/// phân biệt được BA tình huống mà một danh sách rỗng đơn thuần không
/// phân biệt nổi: KHÔNG CÓ bằng chứng nào, CÓ bằng chứng nhưng bị
/// loại, và TRUY VẤN SAI PHẠM VI.
class RetentionDerivation {
  const RetentionDerivation({
    required this.observations,
    required this.discontinuities,
    required this.eventsConsidered,
    required this.eventsExcludedAsFuture,
    required this.eventsExcludedAsIneligible,
  });

  /// Theo thứ tự tất định: nhóm theo `(itemType, itemId)` tăng dần,
  /// trong mỗi nhóm theo thứ tự thời gian.
  ///
  /// Rỗng nghĩa là RỖNG — không ước lượng, không ngoại suy, không thay
  /// bằng một proxy một-sự-kiện, không bịa sự kiện đầu tiên, không lùi
  /// về trạng thái hiện tại của `srs_cards`.
  final List<RetentionObservation> observations;

  final List<RetentionDiscontinuity> discontinuities;

  /// Số sự kiện ĐẦU VÀO — trước mọi bước lọc.
  final int eventsConsidered;

  /// Số sự kiện bị loại vì `reviewedAtMs > asOfMs`.
  ///
  /// Tách riêng khỏi [eventsExcludedAsIneligible] chứ không gộp vào,
  /// vì đây là thuộc tính TẤT ĐỊNH: gộp hai loại lại sẽ khiến hành vi
  /// của `asOfMs` không kiểm toán được — đúng thứ ngược lại với lý do
  /// các bộ đếm này tồn tại.
  final int eventsExcludedAsFuture;

  /// Số sự kiện bị loại vì `gradeRaw`/`beforeStateRaw`/`afterStateRaw`
  /// nằm ngoài từ vựng đã biết. KHÔNG BAO GIỜ ép về giá trị mặc định.
  final int eventsExcludedAsIneligible;

  // CỐ Ý KHÔNG có trường đếm "đã phát ra" / "đã loại vì đứt gãy": hai
  // con số đó ĐÚNG BẰNG `observations.length` và
  // `discontinuities.length`. Thêm trường thừa sẽ lặp lại đúng sai lầm
  // mà `HifzReviewHistory` cố ý tránh khi nó không tổng hợp bảy mốc
  // thành một con số.
  //
  // CỐ Ý KHÔNG có trường nào là điểm số, tỉ lệ, phần trăm, chỉ số, mức
  // độ thuộc, chuỗi ngày, thứ hạng hay chỉ tiêu, và KHÔNG có ngưỡng
  // "chưa đủ dữ liệu" nào do công cụ tự đặt ra: hai sự kiện liên tục
  // là một quan sát — đó là mức sàn trung thực, và mọi phán xét về
  // "đủ hay chưa" thuộc về một nơi gọi có lý do được nêu rõ, không
  // thuộc về công cụ.
}
