import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/error/app_failure.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/core/logging/crash_reporter.dart';

class _FakeCrashReporter implements CrashReporter {
  final failures = <AppFailure>[];

  @override
  void recordFailure(AppFailure failure) => failures.add(failure);

  @override
  void log(String message) {}
}

class _Call {
  _Call(this.message, this.level, this.error, this.stackTrace);

  final String message;
  final int level;
  final Object? error;
  final StackTrace? stackTrace;
}

void main() {
  group('ConsoleLogger', () {
    late List<_Call> calls;
    late ConsoleLogger logger;

    setUp(() {
      calls = [];
      logger = ConsoleLogger(
        sink: (message, {required level, error, stackTrace}) {
          calls.add(_Call(message, level, error, stackTrace));
        },
      );
    });

    test(
        'debug()/info()/warning()/error() truyền đúng message + level tăng '
        'dần theo mức nghiêm trọng', () {
      logger.debug('d');
      logger.info('i');
      logger.warning('w');
      logger.error('e');

      expect(calls.map((c) => c.message), ['d', 'i', 'w', 'e']);
      expect(calls.map((c) => c.level), [500, 800, 900, 1000]);
    });

    test('warning()/error() chuyển tiếp error/stackTrace tuỳ chọn', () {
      final cause = Exception('boom');
      final trace = StackTrace.current;

      logger.error('e', error: cause, stackTrace: trace);

      expect(calls.single.error, same(cause));
      expect(calls.single.stackTrace, same(trace));
    });

    test(
        'không truyền sink vẫn dựng được (const ConsoleLogger() dùng '
        'dart:developer mặc định) — không throw khi gọi', () {
      const defaultLogger = ConsoleLogger();

      expect(() => defaultLogger.info('hello'), returnsNormally);
    });

    test(
        'const ConsoleLogger() mặc định dùng NoopCrashReporter — không '
        'throw, không làm gì (Sprint S2, D2)', () {
      const defaultLogger = ConsoleLogger();

      expect(
        () => defaultLogger.error('e', error: Exception('boom')),
        returnsNormally,
      );
    });

    test(
        'Sprint S2 D2 — error() với error khác null chuyển tiếp '
        'AppFailure tới crashReporter đã tiêm', () {
      final fakeReporter = _FakeCrashReporter();
      final loggerWithReporter = ConsoleLogger(
        sink: (message, {required level, error, stackTrace}) {
          calls.add(_Call(message, level, error, stackTrace));
        },
        crashReporter: fakeReporter,
      );
      final cause = Exception('boom');

      loggerWithReporter.error('e', error: cause);

      expect(fakeReporter.failures, hasLength(1));
      expect(fakeReporter.failures.single.cause, same(cause));
    });

    test(
        'Sprint S2 D2 — error() KHÔNG kèm error gốc thì KHÔNG ghi nhận '
        'gì (không đủ dữ liệu để mapToAppFailure phân loại)', () {
      final fakeReporter = _FakeCrashReporter();
      final loggerWithReporter = ConsoleLogger(crashReporter: fakeReporter);

      loggerWithReporter.error('e không kèm error object');

      expect(fakeReporter.failures, isEmpty);
    });

    test(
        'Sprint S2 D2 — debug()/info()/warning() không bao giờ chuyển '
        'tiếp tới crashReporter, chỉ error() mới làm việc đó', () {
      final fakeReporter = _FakeCrashReporter();
      final loggerWithReporter = ConsoleLogger(crashReporter: fakeReporter);

      loggerWithReporter.debug('d');
      loggerWithReporter.info('i');
      loggerWithReporter.warning('w', error: Exception('vẫn chỉ warning'));

      expect(fakeReporter.failures, isEmpty);
    });
  });
}
