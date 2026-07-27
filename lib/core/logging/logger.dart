/// Giao diện log chung toàn app (Sprint 19 Phase 1, Task 3) — CHỈ
/// interface, không phụ thuộc AppFailure/Flutter/package log nào (giữ
/// độc lập, gọi được từ bất kỳ tầng nào, cùng triết lý
/// "Riverpod-independent" đã áp dụng cho mọi Repository trong dự án).
/// Nơi gọi tự quyết định implementation nào đứng sau (xem
/// console_logger.dart — cài đặt cục bộ duy nhất ở phase này, "No
/// concrete cloud implementation").
abstract interface class Logger {
  /// Chi tiết kỹ thuật, chỉ hữu ích lúc debug — implementation thật
  /// (cloud, sprint sau) có thể lọc bỏ hoàn toàn ở bản release.
  void debug(String message);

  /// Thông tin vận hành bình thường, không phải lỗi.
  void info(String message);

  /// Có vấn đề nhưng app vẫn tiếp tục chạy được.
  void warning(String message, {Object? error, StackTrace? stackTrace});

  /// Lỗi thật sự — implementation thật (sprint sau) có thể đồng thời
  /// gửi cho CrashReporter, Logger ở phase này KHÔNG tự làm việc đó.
  void error(String message, {Object? error, StackTrace? stackTrace});
}
