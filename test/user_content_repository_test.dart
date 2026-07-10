import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/features/quran/data/user_content_repository_impl.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_annotation.dart';

void main() {
  late UserDatabase db;
  late UserContentRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000;
    repo = UserContentRepositoryImpl(
      db,
      newId: () => 'uuid-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  Future<AyahAnnotation> annotationOf(int ayahId) async {
    final map = await repo.watchAnnotationsForAyahs([ayahId]).first;
    return map[ayahId] ?? AyahAnnotation.empty;
  }

  group('schema & migration', () {
    test('schemaVersion 2 tạo đủ 5 bảng user', () async {
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table'",
          )
          .get();
      final names = tables.map((r) => r.data['name']).toSet();
      expect(
        names.containsAll(
          {
            'bookmarks',
            'highlights',
            'notes',
            'favorites',
            'ayah_statuses',
          },
        ),
        isTrue,
      );
      expect(db.schemaVersion, 2);
    });

    test(
        'onUpgrade v1 -> v2: bảng cũ + dữ liệu mẫu còn nguyên, '
        'thêm bảng favorites', () async {
      // Dựng thủ công 1 database "v1" (4 bảng, KHÔNG có favorites) +
      // 1 bookmark mẫu, set PRAGMA user_version = 1 — mô phỏng máy đã
      // cài app từ trước khi favorites ra đời (Sprint 2). setup chạy
      // TRƯỚC khi Drift tự chạy migration, nên khi UserDatabase mở kết
      // nối này nó sẽ thấy user_version=1 < schemaVersion=2 và tự gọi
      // đúng onUpgrade thật (không phải bản giả lập) của user_database.dart.
      const seedAyahId = 42;
      const seedBookmarkId = 'seed-bookmark-1';
      final v1Migrated = UserDatabase(
        NativeDatabase.memory(
          setup: (rawDb) {
            for (final ddl in [
              '''
              CREATE TABLE bookmarks (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                ayah_id INTEGER NOT NULL,
                created_at INTEGER NOT NULL,
                UNIQUE(ayah_id)
              );
              ''',
              '''
              CREATE TABLE highlights (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                ayah_id INTEGER NOT NULL,
                color TEXT NOT NULL,
                UNIQUE(ayah_id, color)
              );
              ''',
              '''
              CREATE TABLE notes (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                ayah_id INTEGER NOT NULL,
                content TEXT NOT NULL,
                UNIQUE(ayah_id)
              );
              ''',
              '''
              CREATE TABLE ayah_statuses (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                ayah_id INTEGER NOT NULL,
                status TEXT NOT NULL,
                UNIQUE(ayah_id)
              );
              ''',
            ]) {
              rawDb.execute(ddl);
            }
            rawDb.execute(
              'INSERT INTO bookmarks '
              '(id, updated_at, ayah_id, created_at, is_dirty) '
              "VALUES ('$seedBookmarkId', 1000, $seedAyahId, 1000, 0);",
            );
            rawDb.execute('PRAGMA user_version = 1;');
          },
        ),
      );
      addTearDown(v1Migrated.close);

      // Chạm vào database lần đầu -> Drift chạy onUpgrade thật (1 -> 2).
      expect(v1Migrated.schemaVersion, 2);
      final tableNames = (await v1Migrated
              .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
              .get())
          .map((r) => r.data['name'])
          .toSet();
      expect(
        tableNames.containsAll(
          {'bookmarks', 'highlights', 'notes', 'favorites', 'ayah_statuses'},
        ),
        isTrue,
        reason: 'onUpgrade phải thêm favorites mà không đụng 4 bảng cũ',
      );

      // Dữ liệu mẫu từ "trước khi nâng cấp" phải còn nguyên vẹn.
      final bookmarks = await v1Migrated.select(v1Migrated.bookmarks).get();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.id, seedBookmarkId);
      expect(bookmarks.single.ayahId, seedAyahId);

      // Bảng mới thêm phải dùng được ngay qua API typed bình thường.
      final favorites = await v1Migrated.select(v1Migrated.favorites).get();
      expect(favorites, isEmpty);
    });

    test('toggleFavorite: bật -> tắt -> bật lại giữ nguyên UUID', () async {
      await repo.toggleFavorite(9);
      expect((await annotationOf(9)).favorited, isTrue);

      await repo.toggleFavorite(9);
      expect((await annotationOf(9)).favorited, isFalse);

      await repo.toggleFavorite(9);
      expect((await annotationOf(9)).favorited, isTrue);

      final rows = await db.select(db.favorites).get();
      expect(rows.length, 1);
    });
  });

  group('Bookmark 1 chạm', () {
    test('toggle: thêm -> bỏ -> hồi sinh cùng UUID (sync là update)', () async {
      await repo.toggleBookmark(7);
      expect((await annotationOf(7)).bookmarked, isTrue);

      fakeNow = 2000;
      await repo.toggleBookmark(7);
      expect((await annotationOf(7)).bookmarked, isFalse);

      fakeNow = 3000;
      await repo.toggleBookmark(7);
      expect((await annotationOf(7)).bookmarked, isTrue);

      // vẫn chỉ 1 dòng, giữ UUID gốc, updated_at mới nhất
      final rows = await db.select(db.bookmarks).get();
      expect(rows.length, 1);
      expect(rows.single.id, 'uuid-1');
      expect(rows.single.updatedAt, 3000);
      expect(rows.single.isDirty, isTrue);
    });
  });

  group('Highlight nhiều màu', () {
    test('một Ayah bật được nhiều màu, tắt từng màu độc lập', () async {
      await repo.toggleHighlight(7, 'amber');
      await repo.toggleHighlight(7, 'green');
      expect(
        (await annotationOf(7)).highlightColors,
        {'amber', 'green'},
      );

      await repo.toggleHighlight(7, 'amber');
      expect((await annotationOf(7)).highlightColors, {'green'});
    });
  });

  group('Note', () {
    test('tạo -> sửa -> nội dung rỗng = xóa -> lưu lại = hồi sinh', () async {
      await repo.saveNote(7, 'ghi chú **đậm**');
      expect((await annotationOf(7)).note, 'ghi chú **đậm**');

      await repo.saveNote(7, 'đã sửa');
      expect((await annotationOf(7)).note, 'đã sửa');

      await repo.saveNote(7, '   ');
      expect((await annotationOf(7)).note, isNull);

      await repo.saveNote(7, 'quay lại');
      expect((await annotationOf(7)).note, 'quay lại');

      final rows = await db.select(db.notes).get();
      expect(rows.length, 1); // luôn 1 dòng / Ayah
    });
  });

  group('Trạng thái học', () {
    test('đặt -> đổi -> none = xóa', () async {
      await repo.setStatus(7, AyahStatus.learning);
      expect((await annotationOf(7)).status, AyahStatus.learning);

      await repo.setStatus(7, AyahStatus.review);
      expect((await annotationOf(7)).status, AyahStatus.review);

      await repo.setStatus(7, AyahStatus.none);
      expect((await annotationOf(7)).status, AyahStatus.none);
    });
  });

  group('watch', () {
    test('chỉ trả về Ayah được hỏi; Ayah sạch không có key', () async {
      await repo.toggleBookmark(1);
      await repo.toggleBookmark(99); // ngoài phạm vi hỏi

      final map = await repo.watchAnnotationsForAyahs([1, 2]).first;
      expect(map.containsKey(1), isTrue);
      expect(map.containsKey(2), isFalse);
      expect(map.containsKey(99), isFalse);
    });

    test('stream phát lại khi dữ liệu đổi (reactive)', () async {
      final stream = repo.watchAnnotationsForAyahs([5]);
      final futureSecond = stream
          .firstWhere((m) => m[5]?.bookmarked ?? false)
          .timeout(const Duration(seconds: 5));

      await repo.toggleBookmark(5);
      final emitted = await futureSecond;
      expect(emitted[5]!.bookmarked, isTrue);
    });
  });

  test('UUID sinh mới cho mỗi bản ghi, không trùng', () async {
    await repo.toggleBookmark(1);
    await repo.toggleHighlight(1, 'blue');
    await repo.saveNote(1, 'x');
    await repo.setStatus(1, AyahStatus.learned);

    final ids = <String>{
      ...(await db.select(db.bookmarks).get()).map((r) => r.id),
      ...(await db.select(db.highlights).get()).map((r) => r.id),
      ...(await db.select(db.notes).get()).map((r) => r.id),
      ...(await db.select(db.ayahStatuses).get()).map((r) => r.id),
    };
    expect(ids.length, 4);
  });

  group('Thư viện của tôi: watchAll*', () {
    test('bookmarks mới nhất trước, bỏ bản đã xóa', () async {
      fakeNow = 1000;
      await repo.toggleBookmark(10);
      fakeNow = 2000;
      await repo.toggleBookmark(20);
      fakeNow = 3000;
      await repo.toggleBookmark(30);
      // Xóa (soft-delete) ayah 20.
      fakeNow = 4000;
      await repo.toggleBookmark(20);

      final rows = await repo.watchAllBookmarks().first;
      expect(rows.map((r) => r.ayahId), [30, 10]); // 20 đã xóa
      expect(rows.first.savedAt, 3000);
    });

    test('favorites mới nhất trước', () async {
      fakeNow = 1000;
      await repo.toggleFavorite(5);
      fakeNow = 2000;
      await repo.toggleFavorite(9);

      final rows = await repo.watchAllFavorites().first;
      expect(rows.map((r) => r.ayahId), [9, 5]);
    });

    test('notes kèm nội dung, bỏ note rỗng (đã xóa)', () async {
      fakeNow = 1000;
      await repo.saveNote(7, 'ghi chú A');
      fakeNow = 2000;
      await repo.saveNote(8, 'ghi chú B');
      fakeNow = 3000;
      await repo.saveNote(7, ''); // xóa note của ayah 7

      final rows = await repo.watchAllNotes().first;
      expect(rows.map((r) => r.ayahId), [8]);
      expect(rows.single.note, 'ghi chú B');
    });

    test('highlights gộp nhiều màu theo từng Ayah', () async {
      fakeNow = 1000;
      await repo.toggleHighlight(3, 'green');
      fakeNow = 1500;
      await repo.toggleHighlight(3, 'amber');
      fakeNow = 2000;
      await repo.toggleHighlight(4, 'blue');

      final rows = await repo.watchAllHighlights().first;
      // Ayah 4 cập nhật gần nhất -> đứng trước.
      expect(rows.map((r) => r.ayahId), [4, 3]);
      final ayah3 = rows.firstWhere((r) => r.ayahId == 3);
      expect(ayah3.colors, {'green', 'amber'});
    });

    test('realtime: thêm bookmark -> stream phát lại', () async {
      final emissions = <int>[];
      final sub =
          repo.watchAllBookmarks().listen((rows) => emissions.add(rows.length));
      await Future<void>.delayed(Duration.zero);
      await repo.toggleBookmark(99);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(emissions.last, greaterThan(emissions.first));
    });
  });
}
