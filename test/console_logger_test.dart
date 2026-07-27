import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/logging/console_logger.dart';

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
  });
}
