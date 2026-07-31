import 'dart:io';

import 'package:drift/drift.dart'
    show DriftWrappedException, InvalidDataException;
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/error/app_failure.dart';
import 'package:quran_companion/core/error/failure_category.dart';
import 'package:quran_companion/core/error/failure_mapper.dart';
import 'package:quran_companion/core/error/failure_severity.dart';

void main() {
  group('mapToAppFailure', () {
    test('DriftWrappedException -> FailureCategory.database', () {
      final error = DriftWrappedException(message: 'bad statement');

      final failure = mapToAppFailure(error);

      expect(failure.category, FailureCategory.database);
      expect(failure.severity, FailureSeverity.error);
      expect(failure.cause, same(error));
    });

    test('InvalidDataException -> FailureCategory.database', () {
      final error = InvalidDataException('invalid column');

      final failure = mapToAppFailure(error);

      expect(failure.category, FailureCategory.database);
      expect(failure.cause, same(error));
    });

    test('FormatException -> FailureCategory.parsing', () {
      const error = FormatException('unexpected token');

      final failure = mapToAppFailure(error);

      expect(failure.category, FailureCategory.parsing);
      expect(failure.severity, FailureSeverity.error);
      expect(failure.cause, same(error));
    });

    test('FileSystemException -> FailureCategory.storage', () {
      const error = FileSystemException('cannot write', '/tmp/x');

      final failure = mapToAppFailure(error);

      expect(failure.category, FailureCategory.storage);
      expect(failure.severity, FailureSeverity.error);
      expect(failure.cause, same(error));
    });

    test(
        'Exception không rơi vào 3 nhóm trên -> FailureCategory.unexpected, '
        'severity critical', () {
      final error = StateError('should not happen');

      final failure = mapToAppFailure(error);

      expect(failure.category, FailureCategory.unexpected);
      expect(failure.severity, FailureSeverity.critical);
      expect(failure.cause, same(error));
    });

    test('giữ nguyên stackTrace truyền vào', () {
      final trace = StackTrace.current;

      final failure = mapToAppFailure(const FormatException('x'), trace);

      expect(failure.stackTrace, same(trace));
    });

    test(
        'idempotent — AppFailure truyền vào trả lại NGUYÊN VẸN, không bọc '
        'lồng nhau', () {
      const original = AppFailure(
        category: FailureCategory.storage,
        severity: FailureSeverity.warning,
        message: 'already mapped',
      );

      final result = mapToAppFailure(original);

      expect(identical(result, original), isTrue);
    });
  });
}
