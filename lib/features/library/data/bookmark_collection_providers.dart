import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../domain/entities/bookmark_collection.dart';
import '../domain/repositories/bookmark_collection_repository.dart';
import 'bookmark_collection_repository_impl.dart';

final bookmarkCollectionRepositoryProvider =
    Provider<BookmarkCollectionRepository>(
  (ref) => BookmarkCollectionRepositoryImpl(ref.watch(userDatabaseProvider)),
);

/// Mọi bộ sưu tập Bookmark còn sống, theo displayOrder.
final bookmarkCollectionsProvider =
    StreamProvider.autoDispose<List<BookmarkCollection>>(
  (ref) =>
      ref.watch(bookmarkCollectionRepositoryProvider).watchAllCollections(),
);

/// Mọi Ayah trong 1 bộ sưu tập cụ thể.
final collectionBookmarksProvider =
    StreamProvider.autoDispose.family<List<int>, String>(
  (ref, collectionId) => ref
      .watch(bookmarkCollectionRepositoryProvider)
      .watchAyahsInCollection(collectionId),
);
