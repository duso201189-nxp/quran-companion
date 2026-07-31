import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../domain/library_item.dart';
import '../../domain/library_kind.dart';
import '../collections/assign_to_collection_sheet.dart';
import '../library_controller.dart';
import 'library_ayah_tile.dart';

/// Nội dung một tab của "Thư viện của tôi": xử lý chung bốn trạng
/// thái loading / rỗng / lỗi / dữ liệu cho mọi nhóm.
class LibraryTabView extends ConsumerWidget {
  const LibraryTabView({
    super.key,
    required this.kind,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.onOpen,
  });

  final LibraryKind kind;
  final IconData emptyIcon;
  final String emptyMessage;
  final void Function(LibraryItem item) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemsAsync = ref.watch(libraryItemsProvider(kind));

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _ErrorState(
        l10n: l10n,
        onRetry: () => ref.invalidate(libraryItemsProvider(kind)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _EmptyState(icon: emptyIcon, message: emptyMessage);
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 720
                ? (constraints.maxWidth - 704) / 2
                : 8.0;
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 16),
              itemCount: items.length,
              itemBuilder: (context, i) => LibraryAyahTile(
                item: items[i],
                onTap: () => onOpen(items[i]),
                onOrganize: kind == LibraryKind.bookmarks
                    ? () => AssignToCollectionSheet.show(
                          context,
                          items[i].ayah.ayahId,
                        )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: scheme.error),
            const SizedBox(height: 12),
            Text(l10n.errorLoadData, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
