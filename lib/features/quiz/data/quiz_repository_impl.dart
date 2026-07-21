import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/quiz_result.dart';
import '../domain/repositories/quiz_repository.dart';

/// Triển khai QuizRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định — cùng
/// mẫu với StudySessionRepositoryImpl/SchedulerRepositoryImpl.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging()/withFailureLoggingStream()
/// (core/logging/repository_boundary_logging.dart), Logger TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây. Hành vi
/// giữ NGUYÊN, chỉ thêm log khi có lỗi (rethrow nguyên vẹn).
class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl(
    this._db,
    this._logger, {
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? const Uuid().v4,
        _nowMs = nowMs ?? _epochNow;

  final UserDatabase _db;
  final Logger _logger;
  final String Function() _newId;
  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  QuizResult _toEntity(QuizResultRow row) => QuizResult(
        id: row.id,
        quizType: row.quizType,
        surahId: row.surahId,
        score: row.score,
        total: row.total,
        takenAt: row.takenAt,
      );

  @override
  Future<String> saveResult({
    required String quizType,
    int? surahId,
    required int score,
    required int total,
  }) {
    return withFailureLogging(_logger, 'saveResult', () async {
      final id = _newId();
      final now = _nowMs();
      await _db.into(_db.quizResults).insert(
            QuizResultsCompanion.insert(
              id: id,
              quizType: quizType,
              surahId: Value(surahId),
              score: score,
              total: total,
              takenAt: now,
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  @override
  Stream<List<QuizResult>> watchHistory() {
    final q = _db.select(_db.quizResults)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchHistory', stream);
  }
}
