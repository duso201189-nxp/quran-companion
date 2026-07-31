import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/library/data/bookmark_collection_providers.dart';
import 'package:quran_companion/features/library/domain/entities/bookmark_collection.dart';
import 'package:quran_companion/features/library/domain/repositories/bookmark_collection_repository.dart';

/// Stream trả về (giống Drift `.watch()`): phát trạng thái hiện tại
/// mới mỗi lần subscribe, không cần StreamController.
class _FakeBookmarkCollectionRepository
    implements BookmarkCollectionRepository {
  List<BookmarkCollection> collections = [];
  final Map<String, List<int>> ayahsByCollection = {};

  @override
  Future<String> createCollection({required String name, String? emoji}) =>
      throw UnimplementedError();

  @override
  Future<void> renameCollection(String collectionId, String name) =>
      throw UnimplementedError();

  @override
  Future<void> setEmoji(String collectionId, String? emoji) =>
      throw UnimplementedError();

  @override
  Future<void> reorderCollections(List<String> orderedIds) =>
      throw UnimplementedError();

  @override
  Future<void> deleteCollection(String collectionId) =>
      throw UnimplementedError();

  @override
  Stream<List<BookmarkCollection>> watchAllCollections() =>
      Stream.value(collections);

  @override
  Future<void> assignBookmark(int ayahId, String collectionId) =>
      throw UnimplementedError();

  @override
  Future<void> unassignBookmark(int ayahId) => throw UnimplementedError();

  @override
  Stream<List<int>> watchAyahsInCollection(String collectionId) =>
      Stream.value(ayahsByCollection[collectionId] ?? const []);
}

void main() {
  late _FakeBookmarkCollectionRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeBookmarkCollectionRepository();
    container = ProviderContainer(
      overrides: [
        bookmarkCollectionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('bookmarkCollectionsProvider: rỗng khi chưa có bộ sưu tập nào',
      () async {
    expect(await container.read(bookmarkCollectionsProvider.future), isEmpty);
  });

  test('bookmarkCollectionsProvider phản ánh đúng danh sách repository',
      () async {
    fakeRepo.collections = const [
      BookmarkCollection(id: 'a', name: 'Yêu thích'),
      BookmarkCollection(id: 'b', name: 'Ôn tập', emoji: '📖'),
    ];

    final result = await container.read(bookmarkCollectionsProvider.future);
    expect(result.map((c) => c.id).toList(), ['a', 'b']);
    expect(result[1].emoji, '📖');
  });

  test('collectionBookmarksProvider(id): rỗng khi bộ sưu tập chưa có Ayah',
      () async {
    final result = await container.read(
      collectionBookmarksProvider('missing').future,
    );
    expect(result, isEmpty);
  });

  test('collectionBookmarksProvider(id) trả đúng Ayah của đúng collection',
      () async {
    fakeRepo.ayahsByCollection['col-1'] = [1, 2, 3];
    fakeRepo.ayahsByCollection['col-2'] = [42];

    expect(
      await container.read(collectionBookmarksProvider('col-1').future),
      [1, 2, 3],
    );
    expect(
      await container.read(collectionBookmarksProvider('col-2').future),
      [42],
    );
  });
}
