import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/hifz_plan.dart';
import '../domain/repositories/hifz_plan_repository.dart';

/// Triển khai HifzPlanRepository trên UserDatabase (Drift) — Sprint
/// 7.7a.
///
/// [newId]/[nowMs] tiêm được để test có kết quả xác định; mọi phương
/// thức công khai bọc withFailureLogging(), Logger tiêm qua
/// constructor — cùng khuôn với mọi repository impl khác (Sprint 19
/// Phase 2).
///
/// Chỉ chạm `hifz_plans` (nhóm B). Không biết `srs_cards`, không biết
/// nhóm A — `PROJ-P-002` không bị đụng tới.
class HifzPlanRepositoryImpl implements HifzPlanRepository {
  HifzPlanRepositoryImpl(
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

  HifzPlan _toEntity(HifzPlanRow row) => HifzPlan(
        id: row.id,
        ayahFrom: row.ayahFrom,
        ayahTo: row.ayahTo,
        status: hifzPlanStatusFromDbValue(row.status),
        startedAt: row.startedAt,
        completedAt: row.completedAt,
      );

  @override
  Stream<List<HifzPlan>> watchAllPlans() {
    final q = _db.select(_db.hifzPlans)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    final stream =
        q.watch().map((rows) => [for (final r in rows) _toEntity(r)]);
    return withFailureLoggingStream(_logger, 'watchAllPlans', stream);
  }

  @override
  Future<String> createPlan({required int ayahFrom, required int ayahTo}) {
    return withFailureLogging(_logger, 'createPlan', () async {
      if (!HifzPlan.isValidRange(ayahFrom, ayahTo)) {
        throw ArgumentError(
          'Đoạn Hifz phải là ordinal toàn cục 1..6236 và ayahFrom <= ayahTo '
          '(nhận $ayahFrom..$ayahTo)',
        );
      }
      final now = _nowMs();
      final id = _newId();
      await _db.into(_db.hifzPlans).insert(
            HifzPlansCompanion.insert(
              id: id,
              ayahFrom: ayahFrom,
              ayahTo: ayahTo,
              status: HifzPlanStatus.active.toDbValue(),
              startedAt: now,
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  @override
  Future<void> setStatus(String planId, HifzPlanStatus status) {
    return withFailureLogging(_logger, 'setStatus', () async {
      final now = _nowMs();
      await (_db.update(_db.hifzPlans)
            ..where((t) => t.id.equals(planId) & t.deletedAt.isNull()))
          .write(
        HifzPlansCompanion(
          status: Value(status.toDbValue()),
          // Rời khỏi 'completed' phải XOÁ dấu hoàn thành, nếu không một
          // kế hoạch đang hoạt động vẫn mang completed_at cũ và mọi nơi
          // đọc cột đó sẽ nói sai.
          completedAt: status == HifzPlanStatus.completed
              ? Value(now)
              : const Value(null),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> deletePlan(String planId) {
    return withFailureLogging(_logger, 'deletePlan', () async {
      final now = _nowMs();
      await (_db.update(_db.hifzPlans)
            ..where((t) => t.id.equals(planId) & t.deletedAt.isNull()))
          .write(
        HifzPlansCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
    });
  }
}
