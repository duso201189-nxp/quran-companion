import 'failure_category.dart';
import 'failure_severity.dart';

/// Mô hình lỗi thống nhất toàn app (Sprint 19 Phase 1, Task 1) — Dart
/// thuần, KHÔNG phụ thuộc Flutter/Drift/Riverpod, KHÔNG nhúng chuỗi
/// hiển thị người dùng (cùng kỷ luật "domain locale-purity" đã áp
/// dụng xuyên suốt dự án — [message] là chuỗi CHẨN ĐOÁN cho log/
/// CrashReporter, KHÔNG phải chuỗi hiển thị UI; màn hình muốn hiện lỗi
/// cho người dùng tự ánh xạ [category] sang l10n ở tầng trình bày,
/// giống hệt cách TutorSuggestionKind được ánh xạ ở
/// tutor_presentation.dart — CHƯA xây tầng đó ở phase này, "No UI
/// changes").
///
/// KHÔNG có logic tính toán/hành vi (không catch, không log, không
/// throw) — chỉ là 1 GIÁ TRỊ, đúng vai trò 1 error model thuần.
class AppFailure {
  const AppFailure({
    required this.category,
    required this.severity,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final FailureCategory category;
  final FailureSeverity severity;

  /// Chuỗi chẩn đoán cho lập trình viên/log — KHÔNG phải chuỗi hiển
  /// thị người dùng (xem doc comment ở trên).
  final String message;

  /// Exception/error gốc đã bị bắt (nếu AppFailure này được dựng từ 1
  /// lỗi khác qua failure_mapper.dart) — giữ lại để log/CrashReporter
  /// có đủ ngữ cảnh gốc, KHÔNG bị mất khi chuẩn hoá.
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() => 'AppFailure(category: $category, severity: $severity, '
      'message: $message${cause != null ? ', cause: $cause' : ''})';
}
