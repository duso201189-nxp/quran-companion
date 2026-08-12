import '../entities/hifz_plan.dart';

/// Cổng dữ liệu cam kết học thuộc (Sprint 7.7a). Domain không biết
/// Drift.
///
/// Repository này CHỈ sở hữu cam kết (`hifz_plans`). Nó KHÔNG biết
/// `srs_cards`, không biết SchedulerRepository, và không tự lên lịch —
/// đúng tiền lệ FlashcardRepository/SchedulerRepository (DR-2026-0005
/// mục 1-2): hai repository độc lập, cầu nối nằm ở tầng Provider.
abstract interface class HifzPlanRepository {
  /// Mọi kế hoạch còn sống (chưa xoá mềm) — mới bắt đầu nhất trước.
  ///
  /// Gồm CẢ ba trạng thái active/paused/completed: cả ba đều còn góp
  /// Ayah vào tập hợp lên lịch. Lọc theo trạng thái là việc của nơi
  /// tiêu thụ, không phải của truy vấn này.
  Stream<List<HifzPlan>> watchAllPlans();

  /// Tạo một cam kết mới trên đoạn [ayahFrom]..[ayahTo] (ordinal toàn
  /// cục 1..6236, [ayahFrom] <= [ayahTo]). Trả về id vừa tạo.
  ///
  /// Đoạn không hợp lệ ([HifzPlan.isValidRange]) -> ném
  /// [ArgumentError]: đây là lỗi lập trình ở nơi gọi, không phải dữ
  /// liệu người dùng hỏng cần chịu đựng.
  ///
  /// Đoạn TRÙNG hoặc CHỒNG LẤN kế hoạch đang có là HỢP LỆ — mở rộng
  /// một đoạn đã học là hành vi thật. Chồng lấn không nhân đôi việc
  /// ôn: xem `hifzUnionAyahIdsProvider`.
  Future<String> createPlan({required int ayahFrom, required int ayahTo});

  /// Đổi trạng thái vòng đời.
  ///
  /// [HifzPlanStatus.completed] đóng dấu `completed_at`; chuyển khỏi
  /// `completed` xoá dấu đó. KHÔNG đụng tới thẻ SRS nào — hoàn thành
  /// là một cột mốc, không phải xoá lịch ôn (Hiến pháp Study §3.7).
  Future<void> setStatus(String planId, HifzPlanStatus status);

  /// Xoá mềm một cam kết. Đây là điều DUY NHẤT đưa Ayah của nó ra khỏi
  /// tập hợp lên lịch Hifz.
  Future<void> deletePlan(String planId);
}
