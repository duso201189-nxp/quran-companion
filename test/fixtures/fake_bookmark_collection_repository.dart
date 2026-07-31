import 'dart:async';

import 'package:quran_companion/features/library/domain/entities/bookmark_collection.dart';
import 'package:quran_companion/features/library/domain/repositories/bookmark_collection_repository.dart';

/// Fake phản ứng (reactive) cho BookmarkCollectionRepository — khác
/// với các fake "Stream.value mỗi lần subscribe" dùng cho test
/// provider thuần (đủ khi state được set TRƯỚC lần subscribe đầu),
/// fake này còn phải đẩy giá trị mới cho listener ĐANG XEM khi
/// widget test tương tác (tap -> gọi repository -> UI đang mở phải
/// tự cập nhật mà không remount) — mô phỏng đúng ngữ nghĩa Drift
/// `.watch()` (replay giá trị hiện tại cho subscriber mới, tiếp tục
/// phát mỗi khi dữ liệu đổi).
class FakeBookmarkCollectionRepository implements BookmarkCollectionRepository {
  List<BookmarkCollection> collections = [];
  final Map<String, List<int>> membership = {};
  final Set<int> bookmarkedAyahs = {};
  int idCounter = 0;

  final StreamController<void> _collectionsChanges =
      StreamController<void>.broadcast();
  final Map<String, StreamController<void>> _membershipChanges = {};

  StreamController<void> _membershipChangesFor(String collectionId) =>
      _membershipChanges.putIfAbsent(
        collectionId,
        StreamController<void>.broadcast,
      );

  void _notifyCollections() => _collectionsChanges.add(null);

  void _notifyMembership(String collectionId) =>
      _membershipChangesFor(collectionId).add(null);

  @override
  Future<String> createCollection({
    required String name,
    String? emoji,
  }) async {
    final id = 'col-${idCounter++}';
    collections = [
      ...collections,
      BookmarkCollection(
        id: id,
        name: name,
        emoji: emoji,
        displayOrder: collections.length,
      ),
    ];
    _notifyCollections();
    return id;
  }

  @override
  Future<void> renameCollection(String collectionId, String name) async {
    collections = [
      for (final c in collections)
        if (c.id == collectionId)
          BookmarkCollection(
            id: c.id,
            name: name,
            emoji: c.emoji,
            displayOrder: c.displayOrder,
          )
        else
          c,
    ];
    _notifyCollections();
  }

  @override
  Future<void> setEmoji(String collectionId, String? emoji) async {
    collections = [
      for (final c in collections)
        if (c.id == collectionId)
          BookmarkCollection(
            id: c.id,
            name: c.name,
            emoji: emoji,
            displayOrder: c.displayOrder,
          )
        else
          c,
    ];
    _notifyCollections();
  }

  @override
  Future<void> reorderCollections(List<String> orderedIds) async {
    final byId = {for (final c in collections) c.id: c};
    collections = [
      for (var i = 0; i < orderedIds.length; i++)
        if (byId[orderedIds[i]] case final c?)
          BookmarkCollection(
            id: c.id,
            name: c.name,
            emoji: c.emoji,
            displayOrder: i,
          ),
    ];
    _notifyCollections();
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    collections = collections.where((c) => c.id != collectionId).toList();
    membership.remove(collectionId);
    _notifyCollections();
    _notifyMembership(collectionId);
  }

  @override
  Stream<List<BookmarkCollection>> watchAllCollections() async* {
    yield collections;
    await for (final _ in _collectionsChanges.stream) {
      yield collections;
    }
  }

  @override
  Future<void> assignBookmark(int ayahId, String collectionId) async {
    if (!collections.any((c) => c.id == collectionId)) {
      throw ArgumentError.value(collectionId, 'collectionId');
    }
    if (!bookmarkedAyahs.contains(ayahId)) {
      throw StateError('Ayah $ayahId chưa được bookmark');
    }
    membership.putIfAbsent(collectionId, () => []).add(ayahId);
    _notifyMembership(collectionId);
  }

  @override
  Future<void> unassignBookmark(int ayahId) async {
    for (final collectionId in membership.keys.toList()) {
      if (membership[collectionId]!.remove(ayahId)) {
        _notifyMembership(collectionId);
      }
    }
  }

  @override
  Stream<List<int>> watchAyahsInCollection(String collectionId) async* {
    yield membership[collectionId] ?? const [];
    await for (final _ in _membershipChangesFor(collectionId).stream) {
      yield membership[collectionId] ?? const [];
    }
  }
}
