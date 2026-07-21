import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/user/user_database.dart';
import '../../../core/logging/logger.dart';
import '../../../core/logging/repository_boundary_logging.dart';
import '../domain/entities/bookmark_collection.dart';
import '../domain/repositories/bookmark_collection_repository.dart';

/// Triển khai BookmarkCollectionRepository trên UserDatabase
/// (Drift). Bookmarks và BookmarkCollections cùng một database vật
/// lý (Group B) nên repository này đọc/ghi thẳng cả hai bảng —
/// không có tiền lệ FK khai báo trong schema, nên mọi ràng buộc
/// toàn vẹn (collection tồn tại, không còn tham chiếu treo sau khi
/// xóa) được tự thực thi ở đây.
///
/// [newId] và [nowMs] tiêm được để test có kết quả xác định.
///
/// Sprint 19 Phase 2 — mọi phương thức công khai được bọc bằng
/// withFailureLogging()/withFailureLoggingStream()
/// (core/logging/repository_boundary_logging.dart), Logger TIÊM QUA
/// constructor — KHÔNG bao giờ tự dựng ConsoleLogger ở đây. Hành vi
/// giữ NGUYÊN (kể cả ArgumentError/StateError của assignBookmark —
/// vẫn ném ra y hệt sau khi log), chỉ thêm log khi có lỗi.
class BookmarkCollectionRepositoryImpl implements BookmarkCollectionRepository {
  BookmarkCollectionRepositoryImpl(
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

  BookmarkCollection _toEntity(BookmarkCollectionRow row) => BookmarkCollection(
        id: row.id,
        name: row.name,
        emoji: row.emoji,
        displayOrder: row.displayOrder,
      );

  @override
  Future<String> createCollection({
    required String name,
    String? emoji,
  }) {
    return withFailureLogging(_logger, 'createCollection', () async {
      final id = _newId();
      final now = _nowMs();
      // Bộ sưu tập mới luôn xếp cuối danh sách hiện có.
      final existing = await (_db.select(_db.bookmarkCollections)
            ..where((t) => t.deletedAt.isNull()))
          .get();

      await _db.into(_db.bookmarkCollections).insert(
            BookmarkCollectionsCompanion.insert(
              id: id,
              name: name,
              emoji: Value(emoji),
              displayOrder: Value(existing.length),
              updatedAt: now,
            ),
          );
      return id;
    });
  }

  @override
  Future<void> renameCollection(String collectionId, String name) {
    return withFailureLogging(_logger, 'renameCollection', () async {
      await (_db.update(_db.bookmarkCollections)
            ..where((t) => t.id.equals(collectionId)))
          .write(
        BookmarkCollectionsCompanion(
          name: Value(name),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> setEmoji(String collectionId, String? emoji) {
    return withFailureLogging(_logger, 'setEmoji', () async {
      await (_db.update(_db.bookmarkCollections)
            ..where((t) => t.id.equals(collectionId)))
          .write(
        BookmarkCollectionsCompanion(
          emoji: Value(emoji),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> reorderCollections(List<String> orderedIds) {
    return withFailureLogging(_logger, 'reorderCollections', () async {
      final now = _nowMs();
      await _db.transaction(() async {
        for (var i = 0; i < orderedIds.length; i++) {
          await (_db.update(_db.bookmarkCollections)
                ..where((t) => t.id.equals(orderedIds[i])))
              .write(
            BookmarkCollectionsCompanion(
              displayOrder: Value(i),
              updatedAt: Value(now),
              isDirty: const Value(true),
            ),
          );
        }
      });
    });
  }

  @override
  Future<void> deleteCollection(String collectionId) {
    return withFailureLogging(_logger, 'deleteCollection', () async {
      final now = _nowMs();
      // Gỡ tham chiếu ở mọi bookmark đang trỏ tới collection này
      // TRƯỚC KHI xóa mềm collection, trong cùng 1 transaction — DB
      // không có FK cascade nên tầng này tự đảm bảo không còn
      // collection_id "treo" nếu có gián đoạn giữa 2 lệnh ghi.
      await _db.transaction(() async {
        await (_db.update(_db.bookmarks)
              ..where((t) => t.collectionId.equals(collectionId)))
            .write(
          BookmarksCompanion(
            collectionId: const Value(null),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
        await (_db.update(_db.bookmarkCollections)
              ..where((t) => t.id.equals(collectionId)))
            .write(
          BookmarkCollectionsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            isDirty: const Value(true),
          ),
        );
      });
    });
  }

  @override
  Stream<List<BookmarkCollection>> watchAllCollections() {
    final q = _db.select(_db.bookmarkCollections)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]);
    final stream = q.watch().map((rows) => rows.map(_toEntity).toList());
    return withFailureLoggingStream(_logger, 'watchAllCollections', stream);
  }

  @override
  Future<void> assignBookmark(int ayahId, String collectionId) {
    return withFailureLogging(_logger, 'assignBookmark', () async {
      final collection = await (_db.select(_db.bookmarkCollections)
            ..where((t) => t.id.equals(collectionId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (collection == null) {
        throw ArgumentError.value(
          collectionId,
          'collectionId',
          'Bộ sưu tập không tồn tại hoặc đã bị xóa',
        );
      }

      final bookmark = await (_db.select(_db.bookmarks)
            ..where((t) => t.ayahId.equals(ayahId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (bookmark == null) {
        throw StateError('Ayah $ayahId chưa được bookmark');
      }

      await (_db.update(_db.bookmarks)..where((t) => t.id.equals(bookmark.id)))
          .write(
        BookmarksCompanion(
          collectionId: Value(collectionId),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Future<void> unassignBookmark(int ayahId) {
    return withFailureLogging(_logger, 'unassignBookmark', () async {
      final bookmark = await (_db.select(_db.bookmarks)
            ..where((t) => t.ayahId.equals(ayahId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (bookmark == null) return;

      await (_db.update(_db.bookmarks)..where((t) => t.id.equals(bookmark.id)))
          .write(
        BookmarksCompanion(
          collectionId: const Value(null),
          updatedAt: Value(_nowMs()),
          isDirty: const Value(true),
        ),
      );
    });
  }

  @override
  Stream<List<int>> watchAyahsInCollection(String collectionId) {
    final q = _db.select(_db.bookmarks)
      ..where(
        (t) => t.collectionId.equals(collectionId) & t.deletedAt.isNull(),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final stream = q.watch().map((rows) => [for (final r in rows) r.ayahId]);
    return withFailureLoggingStream(_logger, 'watchAyahsInCollection', stream);
  }
}
