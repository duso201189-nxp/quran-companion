import 'dart:developer' as developer;

import '../error/failure_mapper.dart';
import 'crash_reporter.dart';
import 'logger.dart';
import 'noop_crash_reporter.dart';

/// Hàm ghi log thật sự — tách ra để test không cần đọc DevTools/
/// console (cùng mẫu Downloader ở core/cache/io_cache_manager.dart).
typedef LogSink = void Function(
  String message, {
  required int level,
  Object? error,
  StackTrace? stackTrace,
});

void _developerLogSink(
  String message, {
  required int level,
  Object? error,
  StackTrace? stackTrace,
}) {
  developer.log(
    message,
    name: 'QuranCompanion',
    level: level,
    error: error,
    stackTrace: stackTrace,
  );
}

/// Logger cục bộ DUY NHẤT của phase này (Sprint 19 Phase 1) — dùng
/// dart:developer (có sẵn trong SDK, KHÔNG phải package cloud nào,
/// đúng yêu cầu "No concrete cloud implementation"/"No cloud SDK"),
/// KHÔNG dùng print() (bị cấm bởi lint avoid_print — "dùng logger,
/// không dùng print", đúng lý do lint đó tồn tại). Mức level theo quy
/// ước package:logging phổ biến: debug=500, info=800, warning=900,
/// error=1000 — CHỈ để phân loại trong DevTools, KHÔNG có ý nghĩa
/// nghiệp vụ (khác FailureSeverity).
///
/// [crashReporter] (Sprint S2 — Quality & Polish, D2): trước đây
/// CrashReporter được dựng sẵn (Sprint 19 Phase 1) nhưng KHÔNG nơi nào
/// gọi `recordFailure()` — audit xác nhận qua grep toàn repo. Logger
/// là nơi DUY NHẤT `withFailureLogging`/`withFailureLoggingStream`
/// (core/logging/repository_boundary_logging.dart, "DUY NHẤT chỗ áp
/// dụng... cho mọi Repository") gọi khi có lỗi thật — đúng như doc
/// comment sẵn có của `Logger.error()` đã dự liệu ("implementation
/// thật... có thể đồng thời gửi cho CrashReporter"). Nối dây Ở ĐÂY
/// thay vì thêm tham số CrashReporter vào 61 lệnh gọi withFailureLogging
/// rải khắp 9 repository — same kết quả (mọi lỗi qua ranh giới
/// Repository đều tới CrashReporter), diện thay đổi nhỏ hơn nhiều, và
/// KHÔNG có repository/test nào cần sửa. Mặc định
/// `const NoopCrashReporter()` — hành vi cũ (không làm gì) không đổi
/// cho tới khi 1 implementation cloud thật được override vào
/// `crashReporterProvider`.
class ConsoleLogger implements Logger {
  const ConsoleLogger({
    LogSink? sink,
    this.crashReporter = const NoopCrashReporter(),
  }) : _sink = sink;

  final LogSink? _sink;
  final CrashReporter crashReporter;

  LogSink get _effectiveSink => _sink ?? _developerLogSink;

  @override
  void debug(String message) => _effectiveSink(message, level: 500);

  @override
  void info(String message) => _effectiveSink(message, level: 800);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _effectiveSink(
        message,
        level: 900,
        error: error,
        stackTrace: stackTrace,
      );

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _effectiveSink(message, level: 1000, error: error, stackTrace: stackTrace);
    // Chỉ ghi nhận khi CÓ error gốc — message-only .error() (hiếm,
    // không nơi nào trong app dùng dạng này hiện tại) không đủ dữ
    // liệu để mapToAppFailure() phân loại đúng, không có gì cụ thể để
    // báo cáo.
    if (error != null) {
      crashReporter.recordFailure(mapToAppFailure(error, stackTrace));
    }
  }
}
