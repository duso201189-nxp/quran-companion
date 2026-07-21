import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/srs_card.dart';
import '../domain/repositories/scheduler_repository.dart';
import '../domain/scheduling_algorithm.dart';

/// Triển khai SchedulerRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định — cùng
/// mẫu với StudySessionRepositoryImpl/KhatmCycleRepositoryImpl.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging()/withFailureLoggingStream()
/// (core/logging/repository_boundary_logging.dart), Logger TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây. Hành vi
/// giữ NGUYÊN, chỉ thêm log khi có lỗi (rethrow nguyên vẹn).
class SchedulerRepositoryImpl implements SchedulerRepository {
  SchedulerRepositoryImpl(
    this._db,
    this._algorithm,
    this._logger, {
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? const Uuid().v4,
        _nowMs = nowMs ?? _epochNow;

  final UserDatabase _db;
  final SchedulingAlgorithm _algorithm;
  final Logger _logger;
  final String Function() _newId;
  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  SrsCard _toEntity(SrsCardRow row) => SrsCard(
        id: row.id,
        itemType: LearningItemType.values.asNameMap()[row.itemType] ??
            LearningItemType.ayah,
        itemId: row.itemId,
        easeFactor: row.easeFactor,
        intervalDays: row.intervalDays,
        repetitions: row.repetitions,
        dueDate: row.dueDate,
        state: srsCardStateFromDbValue(row.state),
        updatedAtMs: row.updatedAt,
      );

  @override
  Future<void> syncWithReviewQueue(List<int> currentReviewAyahIds) =>
      syncItemsForType(LearningItemType.ayah, currentReviewAyahIds);

  @override
  Future<void> syncItemsForType(
    LearningItemType itemType,
    List<int> currentItemIds,
  ) {
    return withFailureLogging(_logger, 'syncItemsForType', () async {
      final now = _nowMs();
      // Lấy CẢ thẻ đã xoá mềm — UNIQUE(item_type, item_id) không phân
      // biệt theo deleted_at, nên 1 mục quay lại phải HỒI SINH thẻ cũ
      // (update), không được insert thẻ mới trùng khoá — cùng mẫu
      // toggle/upsert idempotent của Bookmarks/Favorites.
      final existing = await (_db.select(_db.srsCards)
            ..where((t) => t.itemType.equals(itemType.name)))
          .get();
      final existingByItemId = {for (final r in existing) r.itemId: r};
      final currentSet = currentItemIds.toSet();

      for (final itemId in currentSet) {
        final row = existingByItemId[itemId];
        if (row != null && row.deletedAt == null) continue; // đã có, còn sống

        final initial = _algorithm.initialState();
        if (row == null) {
          // Mục mới -> tạo thẻ với trạng thái khởi tạo do thuật toán
          // quyết định (không hardcode ease factor SM-2 ở đây).
          await _db.into(_db.srsCards).insert(
                SrsCardsCompanion.insert(
                  id: _newId(),
                  itemType: itemType.name,
                  itemId: itemId,
                  easeFactor: Value(initial.easeFactor),
                  intervalDays: Value(initial.intervalDays),
                  repetitions: Value(initial.repetitions),
                  dueDate: now,
                  state: initial.state.toDbValue(),
                  updatedAt: now,
                ),
              );
        } else {
          // Mục quay lại sau khi rời -> hồi sinh thẻ cũ (giữ nguyên id),
          // reset về trạng thái khởi tạo.
          await (_db.update(_db.srsCards)..where((t) => t.id.equals(row.id)))
              .write(
            SrsCardsCompanion(
              deletedAt: const Value(null),
              easeFactor: Value(initial.easeFactor),
              intervalDays: Value(initial.intervalDays),
              repetitions: Value(initial.repetitions),
              dueDate: Value(now),
              state: Value(initial.state.toDbValue()),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
        }
      }

      // Mục đã rời danh sách hiện tại -> xoá mềm thẻ tương ứng
      // (Scheduler theo sau nguồn thành viên theo cả hai chiều, không
      // bao giờ ngược lại).
      for (final entry in existingByItemId.entries) {
        if (currentSet.contains(entry.key)) continue;
        if (entry.value.deletedAt != null) continue; // đã xoá mềm rồi
        await (_db.update(_db.srsCards)
              ..where((t) => t.id.equals(entry.value.id)))
            .write(
          SrsCardsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      }
    });
  }

  @override
  Stream<List<SrsCard>> watchAllCards(LearningItemType itemType) {
    final q = _db.select(_db.srsCards)
      ..where(
        (t) => t.itemType.equals(itemType.name) & t.deletedAt.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchAllCards', stream);
  }

  @override
  Future<void> applyReview(String cardId, ReviewGrade grade) {
    return withFailureLogging(_logger, 'applyReview', () async {
      final row = await (_db.select(_db.srsCards)
            ..where((t) => t.id.equals(cardId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (row == null) return;

      final now = _nowMs();
      final result = _algorithm.review(
        current: (
          easeFactor: row.easeFactor,
          intervalDays: row.intervalDays,
          repetitions: row.repetitions,
          state: srsCardStateFromDbValue(row.state),
        ),
        grade: grade,
        now: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
      );

      await (_db.update(_db.srsCards)..where((t) => t.id.equals(cardId))).write(
        SrsCardsCompanion(
          easeFactor: Value(result.easeFactor),
          intervalDays: Value(result.intervalDays),
          repetitions: Value(result.repetitions),
          state: Value(result.state.toDbValue()),
          dueDate: Value(result.dueDate.millisecondsSinceEpoch),
          updatedAt: Value(now),
          isDirty: const Value(true),
        ),
      );
    });
  }
}
