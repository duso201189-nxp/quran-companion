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
    test('schemaVersion 5 tạo đủ 10 bảng user', () async {
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
            'study_sessions',
            'khatm_cycles',
            'bookmark_collections',
            'srs_cards',
            'quiz_results',
          },
        ),
        isTrue,
      );
      expect(db.schemaVersion, 5);
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

      // Chạm vào database lần đầu -> Drift chạy hết chuỗi onUpgrade
      // thật (1 -> 2 -> 3 -> 4 -> 5, vì schemaVersion hiện tại là 5).
      expect(v1Migrated.schemaVersion, 5);
      final tableNames = (await v1Migrated
              .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
              .get())
          .map((r) => r.data['name'])
          .toSet();
      expect(
        tableNames.containsAll(
          {
            'bookmarks',
            'highlights',
            'notes',
            'favorites',
            'ayah_statuses',
            'study_sessions',
            'khatm_cycles',
            'bookmark_collections',
            'srs_cards',
            'quiz_results',
          },
        ),
        isTrue,
        reason: 'onUpgrade phải chạy hết 1->2->3->4->5 mà không đụng 4 bảng cũ',
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

    test(
        'onUpgrade v2 -> v3: bảng cũ + dữ liệu mẫu còn nguyên, thêm '
        'study_sessions/khatm_cycles/bookmark_collections + cột '
        'collection_id trên bookmarks', () async {
      // Dựng thủ công 1 database "v2" (5 bảng hiện có, CHƯA có 3 bảng
      // Sprint 8 và CHƯA có cột collection_id) + 1 bookmark mẫu, set
      // PRAGMA user_version = 2 — mô phỏng máy đã cài app trước
      // Sprint 8. Mở qua UserDatabase thật để Drift tự chạy đúng
      // onUpgrade thật (2 -> 3) của user_database.dart.
      const seedAyahId = 99;
      const seedBookmarkId = 'seed-bookmark-v2';
      final v2Migrated = UserDatabase(
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
              CREATE TABLE favorites (
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
              "VALUES ('$seedBookmarkId', 5000, $seedAyahId, 5000, 0);",
            );
            rawDb.execute('PRAGMA user_version = 2;');
          },
        ),
      );
      addTearDown(v2Migrated.close);

      // Chạm vào database lần đầu -> Drift chạy onUpgrade thật
      // (2 -> 3 -> 4 -> 5).
      expect(v2Migrated.schemaVersion, 5);
      final tableNames = (await v2Migrated
              .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
              .get())
          .map((r) => r.data['name'])
          .toSet();
      expect(
        tableNames.containsAll(
          {
            'bookmarks',
            'highlights',
            'notes',
            'favorites',
            'ayah_statuses',
            'study_sessions',
            'khatm_cycles',
            'bookmark_collections',
            'srs_cards',
            'quiz_results',
          },
        ),
        isTrue,
        reason: 'onUpgrade phải thêm 3 bảng Sprint 8 mà không đụng 5 bảng cũ',
      );

      // Dữ liệu mẫu từ "trước khi nâng cấp" phải còn nguyên vẹn.
      final bookmarks = await v2Migrated.select(v2Migrated.bookmarks).get();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.id, seedBookmarkId);
      expect(bookmarks.single.ayahId, seedAyahId);
      // Cột mới thêm vào bảng cũ phải là NULL cho dữ liệu có từ trước
      // (ALTER TABLE ADD COLUMN không gán giá trị hồi tố).
      expect(bookmarks.single.collectionId, isNull);

      // 3 bảng mới phải dùng được ngay qua API typed bình thường.
      expect(await v2Migrated.select(v2Migrated.studySessions).get(), isEmpty);
      expect(await v2Migrated.select(v2Migrated.khatmCycles).get(), isEmpty);
      expect(
        await v2Migrated.select(v2Migrated.bookmarkCollections).get(),
        isEmpty,
      );
    });

    test(
        'onUpgrade v3 -> v4: bảng cũ + dữ liệu mẫu còn nguyên, thêm '
        'srs_cards (Sprint 10 Phase 1 — DR-2026-0005)', () async {
      // Dựng thủ công 1 database "v3" (8 bảng hiện có, CHƯA có
      // srs_cards) + 1 ayah_statuses mẫu status='review', set PRAGMA
      // user_version = 3 — mô phỏng máy đã cài app trước Sprint 10.
      // Mở qua UserDatabase thật để Drift tự chạy đúng onUpgrade thật
      // (3 -> 4) của user_database.dart.
      const seedAyahId = 77;
      const seedStatusId = 'seed-status-v3';
      final v3Migrated = UserDatabase(
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
                collection_id TEXT NULL,
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
              CREATE TABLE favorites (
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
              '''
              CREATE TABLE study_sessions (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                date TEXT NOT NULL,
                surah_id INTEGER NOT NULL,
                ayah_from INTEGER NOT NULL,
                ayah_to INTEGER NOT NULL,
                duration_sec INTEGER NOT NULL,
                note TEXT NULL,
                created_at INTEGER NOT NULL
              );
              ''',
              '''
              CREATE TABLE khatm_cycles (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                name TEXT NOT NULL,
                started_at INTEGER NOT NULL,
                target_date TEXT NULL,
                completed_at INTEGER NULL,
                current_ayah_id INTEGER NOT NULL DEFAULT 1
              );
              ''',
              '''
              CREATE TABLE bookmark_collections (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                name TEXT NOT NULL,
                emoji TEXT NULL,
                display_order INTEGER NOT NULL DEFAULT 0
              );
              ''',
            ]) {
              rawDb.execute(ddl);
            }
            rawDb.execute(
              'INSERT INTO ayah_statuses '
              '(id, updated_at, ayah_id, status, is_dirty) '
              "VALUES ('$seedStatusId', 9000, $seedAyahId, 'review', 0);",
            );
            rawDb.execute('PRAGMA user_version = 3;');
          },
        ),
      );
      addTearDown(v3Migrated.close);

      // Chạm vào database lần đầu -> Drift chạy onUpgrade thật
      // (3 -> 4 -> 5).
      expect(v3Migrated.schemaVersion, 5);
      final tableNames = (await v3Migrated
              .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
              .get())
          .map((r) => r.data['name'])
          .toSet();
      expect(
        tableNames.containsAll({'srs_cards', 'quiz_results'}),
        isTrue,
        reason: 'onUpgrade phải thêm srs_cards + quiz_results mà không đụng '
            '8 bảng cũ',
      );

      // Dữ liệu mẫu từ "trước khi nâng cấp" phải còn nguyên vẹn —
      // Revision Queue (ayah_statuses.status='review') không bị đụng
      // vào bởi migration Scheduler (DR-2026-0005 mục 1).
      final statuses = await v3Migrated.select(v3Migrated.ayahStatuses).get();
      expect(statuses, hasLength(1));
      expect(statuses.single.id, seedStatusId);
      expect(statuses.single.ayahId, seedAyahId);
      expect(statuses.single.status, 'review');

      // Bảng mới phải dùng được ngay qua API typed bình thường, KHÔNG
      // backfill hồi tố từ ayah_statuses.status='review' lúc migration
      // (tự đồng bộ khi đọc, xem SchedulerRepository.syncWithReviewQueue).
      expect(await v3Migrated.select(v3Migrated.srsCards).get(), isEmpty);
    });

    test(
        'onUpgrade v4 -> v5: bảng cũ + dữ liệu mẫu còn nguyên, thêm '
        'quiz_results (Sprint 10 Phase 4 — DR-2026-0005 mục 5)', () async {
      // Dựng thủ công 1 database "v4" (9 bảng hiện có, CHƯA có
      // quiz_results) + 1 srs_cards mẫu, set PRAGMA user_version = 4 —
      // mô phỏng máy đã cài app trước Phase 4. Mở qua UserDatabase
      // thật để Drift tự chạy đúng onUpgrade thật (4 -> 5).
      const seedCardId = 'seed-card-v4';
      final v4Migrated = UserDatabase(
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
                collection_id TEXT NULL,
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
              CREATE TABLE favorites (
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
              '''
              CREATE TABLE study_sessions (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                date TEXT NOT NULL,
                surah_id INTEGER NOT NULL,
                ayah_from INTEGER NOT NULL,
                ayah_to INTEGER NOT NULL,
                duration_sec INTEGER NOT NULL,
                note TEXT NULL,
                created_at INTEGER NOT NULL
              );
              ''',
              '''
              CREATE TABLE khatm_cycles (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                name TEXT NOT NULL,
                started_at INTEGER NOT NULL,
                target_date TEXT NULL,
                completed_at INTEGER NULL,
                current_ayah_id INTEGER NOT NULL DEFAULT 1
              );
              ''',
              '''
              CREATE TABLE bookmark_collections (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                name TEXT NOT NULL,
                emoji TEXT NULL,
                display_order INTEGER NOT NULL DEFAULT 0
              );
              ''',
              '''
              CREATE TABLE srs_cards (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER NULL,
                is_dirty INTEGER NOT NULL DEFAULT 1,
                item_type TEXT NOT NULL,
                item_id INTEGER NOT NULL,
                ease_factor REAL NOT NULL DEFAULT 2.5,
                interval_days INTEGER NOT NULL DEFAULT 0,
                repetitions INTEGER NOT NULL DEFAULT 0,
                due_date INTEGER NOT NULL,
                state TEXT NOT NULL,
                UNIQUE(item_type, item_id)
              );
              ''',
            ]) {
              rawDb.execute(ddl);
            }
            rawDb.execute(
              'INSERT INTO srs_cards '
              '(id, updated_at, item_type, item_id, due_date, state, '
              'is_dirty) '
              "VALUES ('$seedCardId', 9000, 'ayah', 42, 9000, 'new', 0);",
            );
            rawDb.execute('PRAGMA user_version = 4;');
          },
        ),
      );
      addTearDown(v4Migrated.close);

      // Chạm vào database lần đầu -> Drift chạy onUpgrade thật (4 -> 5).
      expect(v4Migrated.schemaVersion, 5);
      final tableNames = (await v4Migrated
              .customSelect("SELECT name FROM sqlite_master WHERE type='table'")
              .get())
          .map((r) => r.data['name'])
          .toSet();
      expect(
        tableNames.contains('quiz_results'),
        isTrue,
        reason: 'onUpgrade phải thêm quiz_results mà không đụng 9 bảng cũ',
      );

      // Dữ liệu mẫu từ "trước khi nâng cấp" phải còn nguyên vẹn.
      final cards = await v4Migrated.select(v4Migrated.srsCards).get();
      expect(cards, hasLength(1));
      expect(cards.single.id, seedCardId);
      expect(cards.single.itemId, 42);

      // Bảng mới phải dùng được ngay qua API typed bình thường.
      expect(await v4Migrated.select(v4Migrated.quizResults).get(), isEmpty);
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
