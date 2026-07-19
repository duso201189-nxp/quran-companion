import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/features/library/data/bookmark_collection_repository_impl.dart';

void main() {
  late UserDatabase db;
  late BookmarkCollectionRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000;
    repo = BookmarkCollectionRepositoryImpl(
      db,
      newId: () => 'col-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  /// Chèn thẳng 1 bookmark còn sống cho Ayah [ayahId] — mô phỏng
  /// bookmark đã tồn tại từ trước (tạo qua UserContentRepository ở
  /// luồng thật), không đi qua repository đang test.
  Future<void> seedBookmark(int ayahId) async {
    await db.into(db.bookmarks).insert(
          BookmarksCompanion.insert(
            id: 'bm-$ayahId',
            ayahId: ayahId,
            createdAt: fakeNow,
            updatedAt: fakeNow,
          ),
        );
  }

  group('CRUD bộ sưu tập', () {
    test('createCollection: displayOrder tự tăng theo thứ tự tạo', () async {
      final id1 = await repo.createCollection(name: 'Yêu thích');
      final id2 = await repo.createCollection(name: 'Ôn tập', emoji: '📖');

      final collections = await repo.watchAllCollections().first;
      expect(collections.map((c) => c.id).toList(), [id1, id2]);
      expect(collections[0].displayOrder, 0);
      expect(collections[1].displayOrder, 1);
      expect(collections[1].emoji, '📖');
    });

    test('renameCollection và setEmoji cập nhật đúng field', () async {
      final id = await repo.createCollection(name: 'Cũ');
      await repo.renameCollection(id, 'Mới');
      await repo.setEmoji(id, '⭐');

      final collections = await repo.watchAllCollections().first;
      expect(collections.single.name, 'Mới');
      expect(collections.single.emoji, '⭐');
    });

    test('reorderCollections gán lại displayOrder theo thứ tự mới', () async {
      final a = await repo.createCollection(name: 'A');
      final b = await repo.createCollection(name: 'B');
      final c = await repo.createCollection(name: 'C');

      await repo.reorderCollections([c, a, b]);

      final collections = await repo.watchAllCollections().first;
      expect(collections.map((x) => x.id).toList(), [c, a, b]);
    });

    test('deleteCollection loại khỏi watchAllCollections (xóa mềm)', () async {
      final id = await repo.createCollection(name: 'Tạm');
      await repo.deleteCollection(id);

      expect(await repo.watchAllCollections().first, isEmpty);
    });
  });

  group('toàn vẹn gán bookmark (không có FK ở DB)', () {
    test('assignBookmark ném ArgumentError nếu collection không tồn tại',
        () async {
      await seedBookmark(42);
      expect(
        () => repo.assignBookmark(42, 'khong-ton-tai'),
        throwsArgumentError,
      );
    });

    test('assignBookmark ném StateError nếu Ayah chưa được bookmark', () async {
      final id = await repo.createCollection(name: 'Bộ sưu tập');
      expect(
        () => repo.assignBookmark(99, id),
        throwsStateError,
      );
    });

    test('assignBookmark thành công: xuất hiện trong watchAyahsInCollection',
        () async {
      final id = await repo.createCollection(name: 'Bộ sưu tập');
      await seedBookmark(7);

      await repo.assignBookmark(7, id);

      final ayahs = await repo.watchAyahsInCollection(id).first;
      expect(ayahs, [7]);
    });

    test('unassignBookmark gỡ collection_id, không lỗi nếu Ayah chưa gán',
        () async {
      final id = await repo.createCollection(name: 'Bộ sưu tập');
      await seedBookmark(7);
      await repo.assignBookmark(7, id);

      await repo.unassignBookmark(7);
      expect(await repo.watchAyahsInCollection(id).first, isEmpty);

      // Gọi lại lần 2 (đã gỡ rồi) không được ném lỗi.
      await repo.unassignBookmark(7);
    });

    test(
        'deleteCollection gỡ collection_id khỏi mọi bookmark đang trỏ '
        'tới nó (không để tham chiếu treo)', () async {
      final id = await repo.createCollection(name: 'Sẽ xóa');
      await seedBookmark(1);
      await seedBookmark(2);
      await repo.assignBookmark(1, id);
      await repo.assignBookmark(2, id);

      await repo.deleteCollection(id);

      expect(await repo.watchAyahsInCollection(id).first, isEmpty);
      final bookmark1 = await (db.select(db.bookmarks)
            ..where((t) => t.ayahId.equals(1)))
          .getSingle();
      final bookmark2 = await (db.select(db.bookmarks)
            ..where((t) => t.ayahId.equals(2)))
          .getSingle();
      expect(bookmark1.collectionId, isNull);
      expect(bookmark2.collectionId, isNull);
      // Bookmark bản thân không bị xóa — chỉ gỡ khỏi bộ sưu tập.
      expect(bookmark1.deletedAt, isNull);
      expect(bookmark2.deletedAt, isNull);
    });
  });
}
