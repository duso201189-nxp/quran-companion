/// Lịch sử ôn tập Hifz đã ghi nhận — Sprint D6.11 (DR-2026-0026, đã
/// `accepted`).
///
/// KHÁC HẲN [HifzPlanProgress]/[HifzOverallProgress]: hai lớp đó là ẢNH
/// CHỤP trạng thái hiện tại của `srs_cards`; lớp này dẫn xuất từ
/// `review_events` — chuỗi sự kiện BẤT BIẾN, chỉ thêm không sửa. Hai
/// khái niệm KHÔNG được gộp: một cái trả lời "bây giờ thẻ đang ở đâu",
/// cái kia trả lời "đã ôn bao nhiêu lần và vào những ngày nào".
///
/// PHẠM VI, KHÔNG PHẢI QUY GÁN (DR-2026-0026): các con số ở đây tính
/// trên TẬP AYAH của một phạm vi Hifz, không phải "những lượt ôn do kế
/// hoạch này gây ra". Kế hoạch Hifz được phép chồng lấn, và
/// `UNIQUE(item_type, item_id)` của `srs_cards` khiến một Ayah chỉ có
/// đúng một thẻ dù thuộc bao nhiêu kế hoạch — nên KHÔNG tồn tại sự thật
/// nào về việc kế hoạch nào "gây ra" một lượt ôn. Hệ quả bắt buộc phải
/// tôn trọng: cùng một sự kiện CÓ THỂ xuất hiện hợp lệ trong lịch sử
/// của nhiều kế hoạch chồng lấn, và tổng của các kế hoạch KHÔNG cộng
/// dồn được.
class HifzReviewHistory {
  const HifzReviewHistory({
    required this.totalReviewCount,
    required this.recentDays,
  });

  /// Tổng số dòng `review_events` thuộc phạm vi — MỌI dòng đều tính,
  /// không lọc theo `grade`.
  ///
  /// Đây là số LƯỢT ÔN ĐÃ THỰC HIỆN, KHÔNG phải mức độ thuộc, độ chính
  /// xác, tỉ lệ đúng hay điểm số. Cũng KHÁC `SrsCard.repetitions`:
  /// `repetitions` bị SM-2 reset về 0 mỗi lần trả lời `again`, còn con
  /// số này chỉ tăng, không bao giờ giảm.
  final int totalReviewCount;

  /// Đúng 7 mốc, mỗi mốc một NGÀY LỊCH ĐỊA PHƯƠNG, CŨ NHẤT TRƯỚC, mốc
  /// cuối là hôm nay. Ngày không có lượt ôn nào vẫn có mặt với giá trị
  /// 0 — khoảng trống cũng là dữ liệu, không phải thứ để giấu đi.
  ///
  /// Đây là PHÂN BỐ hoạt động, KHÔNG phải tốc độ/trung bình/chỉ tiêu/
  /// chuỗi ngày. Cố ý không có trường nào tổng hợp 7 mốc thành một con
  /// số duy nhất: một con số như thế mời gọi đặt mục tiêu, và mục tiêu
  /// chính là thứ Hiến pháp Study §"Worship First" cấm.
  final List<HifzReviewDayBucket> recentDays;
}

/// Số lượt ôn trong MỘT ngày lịch địa phương — Sprint D6.11.
class HifzReviewDayBucket {
  const HifzReviewDayBucket({
    required this.dayStart,
    required this.reviewCount,
  });

  /// 00:00 giờ ĐỊA PHƯƠNG của ngày này. KHÔNG có trường nhãn tính sẵn —
  /// tầng UI tự định dạng đa ngôn ngữ qua `intl.DateFormat`, cùng lý do
  /// đã ghi ở `HistoryBucket.periodStart`.
  final DateTime dayStart;

  final int reviewCount;
}
