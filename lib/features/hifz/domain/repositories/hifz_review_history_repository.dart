/// Cổng đọc lịch sử ôn Hifz — Sprint D6.11 (DR-2026-0026, đã
/// `accepted`). Domain không biết Drift.
///
/// CHỈ ĐỌC. Không có phương thức ghi/sửa/xoá nào, và sẽ không bao giờ
/// có: `review_events` là bảng append-only, chỉ
/// `SchedulerRepositoryImpl.applyReview` được phép ghi vào đó
/// (DR-2026-0024).
///
/// Phạm vi HẸP có chủ đích — chỉ Hifz. KHÔNG thêm phương thức tương
/// đương vào `SchedulerRepository`: một API lịch sử tổng quát ở đó sẽ
/// dùng được cho cả `ayah` lẫn `lemma`, hai loại chưa có bằng chứng
/// nào cần tới, và `lemma` thậm chí chưa hề phát sinh sự kiện
/// (DR-2026-0024 Quyết định 3). Xem DR-2026-0026 §"Options considered"
/// — phương án B/D bị loại vì đúng lý do này.
abstract interface class HifzReviewHistoryRepository {
  /// Thời điểm (epoch ms UTC) của MỌI lượt ôn đã ghi cho các Ayah
  /// trong [ayahOrdinals], loại `item_type='hifz'` — tăng dần theo
  /// thời gian.
  ///
  /// Trả về DẤU THỜI GIAN THÔ, không phải số liệu đã tính: mọi luật về
  /// ngày/tháng nằm ở hàm thuần `computeHifzReviewHistory`, cùng ranh
  /// giới `hifz_progress_calculator.dart` đã lập (repository đọc, hàm
  /// thuần tính).
  ///
  /// [ayahOrdinals] rỗng -> danh sách rỗng, không truy vấn.
  Future<List<int>> reviewedAtMsForAyahs(Set<int> ayahOrdinals);
}
