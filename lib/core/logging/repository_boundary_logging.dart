import '../error/failure_mapper.dart';
import 'logger.dart';

/// Bọc 1 lệnh gọi Future ở ranh giới Repository (Sprint 19 Phase 2,
/// Task 1+2) — DUY NHẤT chỗ áp dụng mapToAppFailure()/Logger cho mọi
/// Repository trong dự án (viết 1 lần, dùng lại ở mọi
/// *_repository_impl.dart, đúng tinh thần "Reuse everything").
///
/// KHÔNG đổi hành vi: [body] chạy y hệt như khi không có hàm này bọc
/// quanh — nếu thành công, trả về y hệt giá trị/Future gốc; nếu lỗi,
/// LUÔN `rethrow` NGUYÊN VẸN lỗi gốc (đúng type, đúng stackTrace gốc)
/// sau khi log — bất kỳ nơi gọi nào (test, UI qua AsyncValue.error...)
/// nhận được đúng lỗi y hệt như trước khi có hàm này. Log là TÁC DỤNG
/// PHỤ DUY NHẤT được thêm — "Only diagnostics improve" (Task 4).
///
/// [operation] là 1 nhãn ngắn xác định lệnh gọi (vd tên phương thức
/// Repository) — CHỈ dùng cho dòng log, không ảnh hưởng luồng chạy.
Future<T> withFailureLogging<T>(
  Logger logger,
  String operation,
  Future<T> Function() body,
) async {
  try {
    return await body();
  } catch (error, stackTrace) {
    final failure = mapToAppFailure(error, stackTrace);
    logger.error(
      '$operation failed: ${failure.message}',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

/// Cùng nguyên tắc [withFailureLogging] nhưng cho Stream (vd các
/// phương thức watchX() dùng Drift .watch() — lỗi phát sinh KHÔNG
/// đồng bộ, không bắt được bằng try/catch thường). `Stream.handleError`
/// mặc định NUỐT lỗi trừ khi handler tự throw lại — ở đây LUÔN throw
/// lại nguyên vẹn lỗi gốc sau khi log, giữ đúng hành vi cũ (mọi lỗi cũ
/// từng chảy tới listener vẫn chảy tới y hệt).
Stream<T> withFailureLoggingStream<T>(
  Logger logger,
  String operation,
  Stream<T> source,
) {
  return source.handleError((Object error, StackTrace stackTrace) {
    final failure = mapToAppFailure(error, stackTrace);
    logger.error(
      '$operation failed: ${failure.message}',
      error: error,
      stackTrace: stackTrace,
    );
    throw error;
  });
}
