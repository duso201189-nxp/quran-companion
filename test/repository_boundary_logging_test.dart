import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/core/logging/repository_boundary_logging.dart';
import 'package:quran_companion/features/library/data/bookmark_collection_repository_impl.dart';

/// Fake ghi lại mọi lệnh gọi error() — dùng để CHỨNG MINH (Sprint 19
/// Phase 2) withFailureLogging()/withFailureLoggingStream() ghi đúng 1
/// dòng log khi có lỗi, KHÔNG ghi gì khi thành công ("Do NOT log
/// normal execution").
class _RecordingLogger implements Logger {
  final List<String> debugMessages = [];
  final List<String> infoMessages = [];
  final List<String> warningMessages = [];
  final List<String> errorMessages = [];
  final List<Object?> errorCauses = [];
  final List<StackTrace?> errorStackTraces = [];

  @override
  void debug(String message) => debugMessages.add(message);

  @override
  void info(String message) => infoMessages.add(message);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      warningMessages.add(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    errorMessages.add(message);
    errorCauses.add(error);
    errorStackTraces.add(stackTrace);
  }
}

void main() {
  group('withFailureLogging (Future)', () {
    test('thành công -> trả về ĐÚNG giá trị, KHÔNG ghi log nào', () async {
      final logger = _RecordingLogger();

      final result = await withFailureLogging(
        logger,
        'op',
        () async => 42,
      );

      expect(result, 42);
      expect(logger.errorMessages, isEmpty);
      expect(logger.debugMessages, isEmpty);
      expect(logger.infoMessages, isEmpty);
      expect(logger.warningMessages, isEmpty);
    });

    test(
        'lỗi -> ghi ĐÚNG 1 log error() rồi rethrow NGUYÊN VẸN lỗi gốc '
        '(đúng type, đúng identity, đúng stackTrace)', () async {
      final logger = _RecordingLogger();
      final original = StateError('boom');
      final originalTrace = StackTrace.current;

      Object? caught;
      StackTrace? caughtTrace;
      try {
        await withFailureLogging<int>(logger, 'riskyOp', () {
          return Future<int>.error(original, originalTrace);
        });
      } catch (e, st) {
        caught = e;
        caughtTrace = st;
      }

      expect(identical(caught, original), isTrue);
      expect(caughtTrace, same(originalTrace));
      expect(logger.errorMessages, hasLength(1));
      expect(logger.errorMessages.single, contains('riskyOp'));
      expect(logger.errorCauses.single, same(original));
      expect(logger.errorStackTraces.single, same(originalTrace));
    });
  });

  group('withFailureLoggingStream', () {
    test('thành công -> phát ĐÚNG mọi giá trị, KHÔNG ghi log nào', () async {
      final logger = _RecordingLogger();
      final source = Stream.fromIterable([1, 2, 3]);

      final values =
          await withFailureLoggingStream(logger, 'op', source).toList();

      expect(values, [1, 2, 3]);
      expect(logger.errorMessages, isEmpty);
    });

    test(
        'lỗi -> ghi ĐÚNG 1 log error() rồi vẫn phát lỗi gốc NGUYÊN VẸN cho '
        'listener (Stream.handleError mặc định sẽ NUỐT lỗi nếu không tự '
        'throw lại — đây là điểm dễ sai nhất của hàm này)', () async {
      final logger = _RecordingLogger();
      final original = Exception('stream boom');
      final source = Stream<int>.error(original);

      final wrapped = withFailureLoggingStream(logger, 'watchOp', source);

      Object? caught;
      try {
        await wrapped.toList();
      } catch (e) {
        caught = e;
      }

      expect(identical(caught, original), isTrue);
      expect(logger.errorMessages, hasLength(1));
      expect(logger.errorMessages.single, contains('watchOp'));
      expect(logger.errorCauses.single, same(original));
    });
  });

  group('Repository thật — end-to-end (Sprint 19 Phase 2 adoption)', () {
    test(
        'BookmarkCollectionRepositoryImpl.assignBookmark: ArgumentError của '
        'validation (collection không tồn tại) vẫn ném ra nguyên vẹn, đồng '
        'thời được ghi log qua Logger đã tiêm — chứng minh hành vi cũ giữ '
        'nguyên, chỉ thêm log ("Only diagnostics improve")', () async {
      final db = UserDatabase(NativeDatabase.memory());
      final logger = _RecordingLogger();
      final repo = BookmarkCollectionRepositoryImpl(db, logger);

      Object? caught;
      try {
        await repo.assignBookmark(1, 'khong-ton-tai');
      } catch (e) {
        caught = e;
      }

      expect(caught, isA<ArgumentError>());
      expect(logger.errorMessages, hasLength(1));
      expect(logger.errorMessages.single, contains('assignBookmark'));
      expect(logger.errorCauses.single, same(caught));

      await db.close();
    });
  });
}
