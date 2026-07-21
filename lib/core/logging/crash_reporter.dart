import '../error/app_failure.dart';

/// Giao diện báo cáo lỗi nghiêm trọng (Sprint 19 Phase 1, Task 3) —
/// CHỈ interface. Implementation thật (Crashlytics/Sentry...) là việc
/// của 1 sprint sau khi CLOUD SDK được duyệt thêm vào — phase này
/// KHÔNG được phép ("No cloud SDK"), xem noop_crash_reporter.dart.
abstract interface class CrashReporter {
  /// Ghi nhận 1 AppFailure — implementation thật sẽ gửi lên dịch vụ
  /// theo dõi lỗi kèm [AppFailure.stackTrace]/[AppFailure.cause].
  void recordFailure(AppFailure failure);

  /// Breadcrumb — dòng log ngữ cảnh gắn kèm báo cáo lỗi TIẾP THEO nếu
  /// có (mẫu chuẩn của mọi CrashReporter thật, vd Crashlytics.log),
  /// KHÔNG tự nó là 1 lỗi.
  void log(String message);
}
