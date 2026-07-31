import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/bookmark_collection_providers.dart';
import '../../domain/entities/bookmark_collection.dart';
import 'collection_edit_dialog.dart';

enum _CollectionAction { rename, delete }

/// Màn hình "Bộ sưu tập" — danh sách bộ sưu tập Bookmark, tạo mới
/// qua FAB, đổi tên/xóa qua menu trên mỗi dòng. Ayah-only theo
/// DR-2026-0003 mục C — không hiển thị nội dung Ayah ở đây (ngoài
/// phạm vi 5 deliverable của Phase 4), chỉ đếm số lượng.
class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collectionsAsync = ref.watch(bookmarkCollectionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.collectionsTitle)),
      body: SafeArea(
        child: collectionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.errorLoadData)),
          data: (collections) {
            if (collections.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.collectionsEmpty,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: collections.length,
              itemBuilder: (context, i) =>
                  _CollectionTile(collection: collections[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.collectionsCreate),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await CollectionEditDialog.show(
      context,
      title: l10n.collectionsCreate,
    );
    if (result == null) return;
    await ref.read(bookmarkCollectionRepositoryProvider).createCollection(
          name: result.$1,
          emoji: result.$2,
        );
  }
}

class _CollectionTile extends ConsumerWidget {
  const _CollectionTile({required this.collection});

  final BookmarkCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Watch riêng theo collection.id -> chỉ dòng này rebuild khi số
    // lượng Ayah của NÓ đổi, không đụng các dòng khác.
    final ayahsAsync = ref.watch(collectionBookmarksProvider(collection.id));

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        child: Text(collection.emoji ?? '📁'),
      ),
      title: Text(collection.name),
      subtitle: Text(
        l10n.collectionItemCount(ayahsAsync.valueOrNull?.length ?? 0),
      ),
      trailing: PopupMenuButton<_CollectionAction>(
        onSelected: (action) => _handle(context, ref, action),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _CollectionAction.rename,
            child: Text(l10n.collectionsRename),
          ),
          PopupMenuItem(
            value: _CollectionAction.delete,
            child: Text(l10n.collectionsDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _CollectionAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(bookmarkCollectionRepositoryProvider);
    switch (action) {
      case _CollectionAction.rename:
        final result = await CollectionEditDialog.show(
          context,
          title: l10n.collectionsRename,
          initialName: collection.name,
          initialEmoji: collection.emoji,
        );
        if (result == null) break;
        await repo.renameCollection(collection.id, result.$1);
        await repo.setEmoji(collection.id, result.$2);
      case _CollectionAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.collectionsDeleteConfirmTitle),
            content: Text(l10n.collectionsDeleteConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.collectionsDelete),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.deleteCollection(collection.id);
        }
    }
  }
}
