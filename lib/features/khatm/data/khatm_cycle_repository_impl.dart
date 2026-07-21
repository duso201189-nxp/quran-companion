import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/khatm_cycle.dart';
import '../domain/repositories/khatm_cycle_repository.dart';

/// Triển khai KhatmCycleRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging()/withFailureLoggingStream()
/// (core/logging/repository_boundary_logging.dart), Logger TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây. Hành vi
/// giữ NGUYÊN, chỉ thêm log khi có lỗi (rethrow nguyên vẹn).
class KhatmCycleRepositoryImpl implements KhatmCycleRepository {
  KhatmCycleRepositoryImpl(
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

  KhatmCycle _toEntity(KhatmCycleRow row) => KhatmCycle(
        id: row.id,
        name: row.name,
        startedAt: row.startedAt,
        targetDate: row.targetDate,
        completedAt: row.completedAt,
        currentAyahId: row.currentAyahId,
      );

  @override
  Future<String> startCycle({
    required String name,
    String? targetDate,
  }) {
    return withFailureLogging(_logger, 'startCycle', () async {
      final id = _newId();
      final now = _nowMs();
      await _db.into(_db.khatmCycles).insert(
            KhatmCyclesCompanion.insert(
              id: id,
              name: name,
              startedAt: now,
              targetDate: Value(targetDate),
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  @override
  Stream<List<KhatmCycle>> watchAllCycles() {
    final q = _db.select(_db.khatmCycles)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchAllCycles', stream);
  }

  @override
  Stream<KhatmCycle?> watchActiveCycle() {
    final q = _db.select(_db.khatmCycles)
      ..where((t) => t.deletedAt.isNull() & t.completedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
      ..limit(1);
    final stream = q.watch().map(
          (rows) => rows.isEmpty ? null : _toEntity(rows.first),
        );
    return withFailureLoggingStream(_logger, 'watchActiveCycle', stream);
  }

  @override
  Future<void> updateProgress(String cycleId, int currentAyahId) {
    return withFailureLogging(_logger, 'updateProgress', () async {
      await (_db.update(_db.khatmCycles)..where((t) => t.id.equals(cycleId)))
          .write(
        KhatmCyclesCompanion(
          currentAyahId: Value(currentAyahId),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> completeCycle(String cycleId) {
    return withFailureLogging(_logger, 'completeCycle', () async {
      final now = _nowMs();
      await (_db.update(_db.khatmCycles)..where((t) => t.id.equals(cycleId)))
          .write(
        KhatmCyclesCompanion(
          completedAt: Value(now),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> deleteCycle(String cycleId) {
    return withFailureLogging(_logger, 'deleteCycle', () async {
      final now = _nowMs();
      await (_db.update(_db.khatmCycles)..where((t) => t.id.equals(cycleId)))
          .write(
        KhatmCyclesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
    });
  }
}
