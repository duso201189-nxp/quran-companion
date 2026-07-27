import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../domain/entities/quiz_result.dart';
import '../domain/repositories/quiz_repository.dart';

/// Triển khai QuizRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định — cùng
/// mẫu với StudySessionRepositoryImpl/SchedulerRepositoryImpl.
class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl(
    this._db, {
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? const Uuid().v4,
        _nowMs = nowMs ?? _epochNow;

  final UserDatabase _db;
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
  }) async {
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
  }

  @override
  Stream<List<QuizResult>> watchHistory() {
    final q = _db.select(_db.quizResults)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.takenAt)]);
    return q.watch().map((rows) => rows.map(_toEntity).toList());
  }
}
