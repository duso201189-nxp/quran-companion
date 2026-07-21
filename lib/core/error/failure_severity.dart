/// Mức độ nghiêm trọng của 1 AppFailure (Sprint 19 Phase 1) — TÁC
/// ĐỘNG nghiệp vụ của lỗi, KHÁC với mức chi tiết log (xem
/// core/logging/logger.dart — Logger có debug/info/warning/error
/// riêng, không dùng chung enum này, vì "log mức debug" không phải là
/// 1 lỗi).
enum FailureSeverity {
  /// Đáng ghi nhận nhưng KHÔNG ảnh hưởng người dùng (vd 1 lượt
  /// prefetch nền thất bại, đã có cơ chế tự thử lại).
  info,

  /// Người dùng có thể nhận thấy (vd 1 phần dữ liệu không tải được)
  /// nhưng app vẫn dùng được bình thường.
  warning,

  /// 1 thao tác người dùng yêu cầu thất bại hẳn (vd không đọc được
  /// Surah đang mở) — cần hiển thị lỗi, không được im lặng bỏ qua.
  error,

  /// App không thể tiếp tục hoạt động bình thường (vd không mở được
  /// database) — mức cao nhất, luôn phải báo cáo (CrashReporter).
  critical,
}
