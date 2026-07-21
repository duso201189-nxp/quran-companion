import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/error/app_failure.dart';
import 'package:quran_companion/core/error/failure_category.dart';
import 'package:quran_companion/core/error/failure_severity.dart';
import 'package:quran_companion/core/logging/noop_crash_reporter.dart';

void main() {
  group('NoopCrashReporter', () {
    const reporter = NoopCrashReporter();

    test('recordFailure() không làm gì, không throw', () {
      const failure = AppFailure(
        category: FailureCategory.unexpected,
        severity: FailureSeverity.critical,
        message: 'x',
      );

      expect(() => reporter.recordFailure(failure), returnsNormally);
    });

    test('log() không làm gì, không throw', () {
      expect(() => reporter.log('breadcrumb'), returnsNormally);
    });
  });
}
