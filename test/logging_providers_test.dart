import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/error/app_failure.dart';
import 'package:quran_companion/core/error/failure_category.dart';
import 'package:quran_companion/core/error/failure_severity.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/core/logging/crash_reporter.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/core/logging/logging_providers.dart';
import 'package:quran_companion/core/logging/noop_crash_reporter.dart';

class _FakeCrashReporter implements CrashReporter {
  final failures = <AppFailure>[];
  final breadcrumbs = <String>[];

  @override
  void recordFailure(AppFailure failure) => failures.add(failure);

  @override
  void log(String message) => breadcrumbs.add(message);
}

void main() {
  late ProviderContainer container;

  tearDown(() => container.dispose());

  test('loggerProvider trả về 1 ConsoleLogger cục bộ mặc định (không cloud)',
      () {
    container = ProviderContainer();

    final logger = container.read(loggerProvider);

    expect(logger, isA<Logger>());
    expect(logger, isA<ConsoleLogger>());
  });

  test(
      'crashReporterProvider trả về 1 NoopCrashReporter mặc định (không '
      'cloud, an toàn)', () {
    container = ProviderContainer();

    final reporter = container.read(crashReporterProvider);

    expect(reporter, isA<CrashReporter>());
    expect(reporter, isA<NoopCrashReporter>());
  });

  test(
      'loggerProvider/crashReporterProvider override được như mọi provider '
      'khác trong dự án (sẵn sàng cho implementation cloud ở sprint sau)', () {
    final fakeReporter = _FakeCrashReporter();
    container = ProviderContainer(
      overrides: [
        crashReporterProvider.overrideWithValue(fakeReporter),
      ],
    );

    const failure = AppFailure(
      category: FailureCategory.database,
      severity: FailureSeverity.critical,
      message: 'boom',
    );
    container.read(crashReporterProvider).recordFailure(failure);

    expect(fakeReporter.failures, [failure]);
  });
}
