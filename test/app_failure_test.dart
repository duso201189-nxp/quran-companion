import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/error/app_failure.dart';
import 'package:quran_companion/core/error/failure_category.dart';
import 'package:quran_companion/core/error/failure_severity.dart';

void main() {
  group('AppFailure', () {
    test('giữ đúng mọi trường đã truyền vào, cause/stackTrace mặc định null',
        () {
      const failure = AppFailure(
        category: FailureCategory.storage,
        severity: FailureSeverity.warning,
        message: 'disk full',
      );

      expect(failure.category, FailureCategory.storage);
      expect(failure.severity, FailureSeverity.warning);
      expect(failure.message, 'disk full');
      expect(failure.cause, isNull);
      expect(failure.stackTrace, isNull);
    });

    test('giữ nguyên cause gốc, không mất ngữ cảnh khi chuẩn hoá', () {
      final original = Exception('boom');
      final failure = AppFailure(
        category: FailureCategory.unexpected,
        severity: FailureSeverity.critical,
        message: 'unexpected',
        cause: original,
      );

      expect(failure.cause, same(original));
    });

    test('toString() chứa category/severity/message để đọc log dễ dàng', () {
      const failure = AppFailure(
        category: FailureCategory.parsing,
        severity: FailureSeverity.error,
        message: 'bad json',
      );

      final text = failure.toString();
      expect(text, contains('parsing'));
      expect(text, contains('error'));
      expect(text, contains('bad json'));
    });
  });
}
