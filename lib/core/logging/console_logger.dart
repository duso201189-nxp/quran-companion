import 'dart:developer' as developer;

import 'logger.dart';

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
class ConsoleLogger implements Logger {
  const ConsoleLogger({LogSink? sink}) : _sink = sink;

  final LogSink? _sink;

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
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _effectiveSink(
        message,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
}
