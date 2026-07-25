import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../../shared/widgets/full_empty_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../search/presentation/widgets/search_error_state.dart';
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
      loading: () => LoadingState(semanticsLabel: l10n.libraryLoading),
      error: (_, __) => SearchErrorState(
        onRetry: () => ref.invalidate(libraryItemsProvider(kind)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return FullEmptyState(icon: emptyIcon, message: emptyMessage);
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
