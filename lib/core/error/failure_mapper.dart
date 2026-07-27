import 'dart:io';

import 'package:drift/drift.dart'
    show DriftWrappedException, InvalidDataException;

import 'app_failure.dart';
import 'failure_category.dart';
import 'failure_severity.dart';

/// Tầng ánh xạ lỗi dùng chung (Sprint 19 Phase 1, Task 2) — hàm THUẦN
/// duy nhất, chuẩn hoá 1 Object lỗi bất kỳ (bắt được từ try/catch) về
/// đúng 1 AppFailure, theo ĐÚNG 4 nhóm Task 2 liệt kê: database,
/// parsing, storage, unexpected. KHÔNG catch/throw gì ở đây — hàm
/// nhận lỗi ĐÃ bắt, KHÔNG tự đi bắt lỗi (đó là việc của nơi gọi, vd 1
/// repository trong phase sau — "No write path"/"No business logic
/// changes" nên CHƯA có nơi gọi nào ở phase này).
///
/// Idempotent: nếu [error] đã LÀ 1 AppFailure (vd hàm này được gọi 2
/// lần do nhầm), trả lại nguyên vẹn, không bọc lồng nhau.
AppFailure mapToAppFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) return error;

  if (error is DriftWrappedException || error is InvalidDataException) {
    return AppFailure(
      category: FailureCategory.database,
      severity: FailureSeverity.error,
      message: 'Database error: $error',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is FormatException) {
    return AppFailure(
      category: FailureCategory.parsing,
      severity: FailureSeverity.error,
      message: 'Parsing error: $error',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is FileSystemException) {
    return AppFailure(
      category: FailureCategory.storage,
      severity: FailureSeverity.error,
      message: 'Storage error: $error',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  return AppFailure(
    category: FailureCategory.unexpected,
    severity: FailureSeverity.critical,
    message: 'Unexpected error: $error',
    cause: error,
    stackTrace: stackTrace,
  );
}
