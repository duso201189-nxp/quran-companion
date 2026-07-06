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
          {'bookmarks', 'highlights', 'notes', 'favorites',
            'ayah_statuses',},
        ),
        isTrue,
      );
      expect(db.schemaVersion, 2);
    });

    test('toggleFavorite: bật -> tắt -> bật lại giữ nguyên UUID',
        () async {
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
    test('toggle: thêm -> bỏ -> hồi sinh cùng UUID (sync là update)',
        () async {
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
    test('tạo -> sửa -> nội dung rỗng = xóa -> lưu lại = hồi sinh',
        () async {
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
}
