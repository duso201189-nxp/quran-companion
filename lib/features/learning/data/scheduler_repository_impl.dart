import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../domain/entities/srs_card.dart';
import '../domain/repositories/scheduler_repository.dart';
import '../domain/scheduling_algorithm.dart';

/// Triển khai SchedulerRepository trên UserDatabase (Drift).
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định — cùng
/// mẫu với StudySessionRepositoryImpl/KhatmCycleRepositoryImpl.
class SchedulerRepositoryImpl implements SchedulerRepository {
  SchedulerRepositoryImpl(
    this._db,
    this._algorithm, {
    String Function()? newId,
    int Function()? nowMs,
  })  : _newId = newId ?? const Uuid().v4,
        _nowMs = nowMs ?? _epochNow;

  final UserDatabase _db;
  final SchedulingAlgorithm _algorithm;
  final String Function() _newId;
  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  SrsCard _toEntity(SrsCardRow row) => SrsCard(
        id: row.id,
        itemType:
            LearningItemType.values.asNameMap()[row.itemType] ??
                LearningItemType.ayah,
        itemId: row.itemId,
        easeFactor: row.easeFactor,
        intervalDays: row.intervalDays,
        repetitions: row.repetitions,
        dueDate: row.dueDate,
        state: srsCardStateFromDbValue(row.state),
      );

  @override
  Future<void> syncWithReviewQueue(List<int> currentReviewAyahIds) async {
    final now = _nowMs();
    // Lấy CẢ thẻ đã xoá mềm — UNIQUE(item_type, item_id) không phân
    // biệt theo deleted_at, nên Ayah quay lại Queue phải HỒI SINH thẻ
    // cũ (update), không được insert thẻ mới trùng khoá — cùng mẫu
    // toggle/upsert idempotent của Bookmarks/Favorites.
    final existing = await (_db.select(_db.srsCards)
          ..where((t) => t.itemType.equals(LearningItemType.ayah.name)))
        .get();
    final existingByAyahId = {for (final r in existing) r.itemId: r};
    final currentSet = currentReviewAyahIds.toSet();

    for (final ayahId in currentSet) {
      final row = existingByAyahId[ayahId];
      if (row != null && row.deletedAt == null) continue; // đã có, còn sống

      final initial = _algorithm.initialState();
      if (row == null) {
        // Ayah mới vào Queue -> tạo thẻ với trạng thái khởi tạo do
        // thuật toán quyết định (không hardcode ease factor SM-2 ở đây).
        await _db.into(_db.srsCards).insert(
              SrsCardsCompanion.insert(
                id: _newId(),
                itemType: LearningItemType.ayah.name,
                itemId: ayahId,
                easeFactor: Value(initial.easeFactor),
                intervalDays: Value(initial.intervalDays),
                repetitions: Value(initial.repetitions),
                dueDate: now,
                state: initial.state.toDbValue(),
                updatedAt: now,
              ),
            );
      } else {
        // Ayah quay lại Queue sau khi rời -> hồi sinh thẻ cũ (giữ
        // nguyên id), reset về trạng thái khởi tạo.
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

    // Ayah đã rời Queue -> xoá mềm thẻ tương ứng (Scheduler theo sau
    // Queue theo cả hai chiều, không bao giờ ngược lại).
    for (final entry in existingByAyahId.entries) {
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
  }

  @override
  Stream<List<SrsCard>> watchAllCards(LearningItemType itemType) {
    final q = _db.select(_db.srsCards)
      ..where(
        (t) => t.itemType.equals(itemType.name) & t.deletedAt.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
    return q.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> applyReview(String cardId, ReviewGrade grade) async {
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
  }
}
