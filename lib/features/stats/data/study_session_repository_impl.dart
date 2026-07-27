import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/study_session.dart';
import '../domain/repositories/study_session_repository.dart';

/// Triển khai StudySessionRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging()/withFailureLoggingStream()
/// (core/logging/repository_boundary_logging.dart), Logger TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây. Hành vi
/// giữ NGUYÊN, chỉ thêm log khi có lỗi (rethrow nguyên vẹn).
class StudySessionRepositoryImpl implements StudySessionRepository {
  StudySessionRepositoryImpl(
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

  StudySession _toEntity(StudySessionRow row) => StudySession(
        id: row.id,
        date: row.date,
        surahId: row.surahId,
        ayahFrom: row.ayahFrom,
        ayahTo: row.ayahTo,
        durationSec: row.durationSec,
        note: row.note,
        createdAt: row.createdAt,
      );

  @override
  Future<String> logSession({
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    String? note,
  }) {
    return withFailureLogging(_logger, 'logSession', () async {
      final id = _newId();
      final now = _nowMs();
      await _db.into(_db.studySessions).insert(
            StudySessionsCompanion.insert(
              id: id,
              date: date,
              surahId: surahId,
              ayahFrom: ayahFrom,
              ayahTo: ayahTo,
              durationSec: durationSec,
              note: Value(note),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  @override
  Stream<List<StudySession>> watchAllSessions() {
    final q = _db.select(_db.studySessions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchAllSessions', stream);
  }

  @override
  Stream<List<StudySession>> watchSessionsOnDate(String date) {
    final q = _db.select(_db.studySessions)
      ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchSessionsOnDate', stream);
  }

  @override
  Future<int> totalDurationOnDate(String date) {
    return withFailureLogging(_logger, 'totalDurationOnDate', () async {
      final rows = await (_db.select(_db.studySessions)
            ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
          .get();
      var total = 0;
      for (final r in rows) {
        total += r.durationSec;
      }
      return total;
    });
  }

  @override
  Future<Set<String>> distinctReadingDates() {
    return withFailureLogging(_logger, 'distinctReadingDates', () async {
      final rows = await (_db.select(_db.studySessions)
            ..where((t) => t.deletedAt.isNull()))
          .get();
      return {for (final r in rows) r.date};
    });
  }

  @override
  Future<int> currentStreak({DateTime? today}) {
    return withFailureLogging(_logger, 'currentStreak', () async {
      final dates = (await distinctReadingDates()).map(DateTime.parse).toList()
        ..sort();
      if (dates.isEmpty) return 0;

      final now = today ?? DateTime.now();
      var anchor = DateTime(now.year, now.month, now.day);
      final days = dates.reversed.toList();
      // Cho phép chuỗi kết thúc hôm qua (hôm nay chưa đọc).
      if (days.first != anchor) {
        anchor = anchor.subtract(const Duration(days: 1));
        if (days.first != anchor) return 0;
      }
      var streak = 0;
      for (final d in days) {
        if (d == anchor) {
          streak++;
          anchor = anchor.subtract(const Duration(days: 1));
        } else if (d.isBefore(anchor)) {
          break;
        }
      }
      return streak;
    });
  }

  @override
  Future<int> longestStreak() {
    return withFailureLogging(_logger, 'longestStreak', () async {
      final dates = (await distinctReadingDates()).map(DateTime.parse).toList()
        ..sort();
      if (dates.isEmpty) return 0;
      var longest = 1;
      var run = 1;
      for (var i = 1; i < dates.length; i++) {
        if (dates[i].difference(dates[i - 1]).inDays == 1) {
          run++;
          if (run > longest) longest = run;
        } else if (dates[i] != dates[i - 1]) {
          run = 1;
        }
      }
      return longest;
    });
  }
}
