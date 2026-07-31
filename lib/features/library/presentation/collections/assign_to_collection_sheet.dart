import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/bookmark_collection_providers.dart';
import '../../domain/entities/bookmark_collection.dart';
import 'collection_edit_dialog.dart';

/// Sheet chọn/bỏ bộ sưu tập cho 1 Ayah đã bookmark — mở từ biểu
/// tượng "Sắp xếp" trên tile Bookmark (chỉ tab Bookmarks). Toggle
/// qua lại assignBookmark/unassignBookmark của repository — sheet
/// không tự kiểm tra tồn tại bookmark, chỉ mở được khi Ayah đã
/// bookmark từ trước (đúng như toàn vẹn repository yêu cầu).
class AssignToCollectionSheet extends ConsumerWidget {
  const AssignToCollectionSheet({super.key, required this.ayahId});

  final int ayahId;

  static Future<void> show(BuildContext context, int ayahId) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AssignToCollectionSheet(ayahId: ayahId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final collectionsAsync = ref.watch(bookmarkCollectionsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.collectionAssignTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            collectionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(l10n.errorLoadData),
              ),
              data: (collections) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final c in collections)
                    _CollectionCheckRow(ayahId: ayahId, collection: c),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.add_rounded),
              title: Text(l10n.collectionsCreate),
              onTap: () => _createAndAssign(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAndAssign(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await CollectionEditDialog.show(
      context,
      title: l10n.collectionsCreate,
    );
    if (result == null) return;
    final repo = ref.read(bookmarkCollectionRepositoryProvider);
    final id = await repo.createCollection(name: result.$1, emoji: result.$2);
    await repo.assignBookmark(ayahId, id);
  }
}

class _CollectionCheckRow extends ConsumerWidget {
  const _CollectionCheckRow({
    required this.ayahId,
    required this.collection,
  });

  final int ayahId;
  final BookmarkCollection collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch riêng theo collection.id -> chỉ dòng này rebuild khi
    // thành viên của NÓ đổi, không đụng các dòng khác trong sheet.
    final ayahsAsync = ref.watch(collectionBookmarksProvider(collection.id));
    final isIn = ayahsAsync.valueOrNull?.contains(ayahId) ?? false;
    final repo = ref.read(bookmarkCollectionRepositoryProvider);

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Text(collection.emoji ?? '📁'),
      title: Text(collection.name),
      value: isIn,
      onChanged: (checked) {
        if (checked == true) {
          repo.assignBookmark(ayahId, collection.id);
        } else {
          repo.unassignBookmark(ayahId);
        }
      },
    );
  }
}
