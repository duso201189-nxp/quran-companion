import '../error/app_failure.dart';
import 'crash_reporter.dart';

/// CrashReporter cục bộ DUY NHẤT của phase này — không làm gì cả, an
/// toàn tuyệt đối (không gửi dữ liệu đi đâu, không cần mạng, không
/// cần cloud SDK). Giữ chỗ để crashReporterProvider có 1 giá trị hợp
/// lệ ngay hôm nay, và để mọi nơi gọi CrashReporter.recordFailure()
/// trong tương lai không cần sửa gì khi 1 implementation thật (cloud)
/// được override vào provider ở sprint sau.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  void recordFailure(AppFailure failure) {}

  @override
  void log(String message) {}
}
