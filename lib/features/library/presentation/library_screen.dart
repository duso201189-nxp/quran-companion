import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import '../domain/library_item.dart';
import '../domain/library_kind.dart';
import 'widgets/library_tab_view.dart';

/// "Thư viện của tôi" — bốn tab (Đã lưu / Yêu thích / Ghi chú /
/// Tô màu) tổng hợp mọi chú thích người dùng, chạm để nhảy tới Ayah.
/// Màn hình được push (không phải tab thứ 6) nên giữ nguyên vỏ 5 tab.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.libraryTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_outlined),
              tooltip: l10n.collectionsTitle,
              onPressed: () => context.push(AppRoutes.collections),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.libraryBookmarks),
              Tab(text: l10n.libraryFavorites),
              Tab(text: l10n.libraryNotes),
              Tab(text: l10n.libraryHighlights),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              LibraryTabView(
                kind: LibraryKind.bookmarks,
                emptyIcon: Icons.bookmark_border_rounded,
                emptyMessage: l10n.libraryEmptyBookmarks,
                onOpen: (item) => _open(context, ref, item),
              ),
              LibraryTabView(
                kind: LibraryKind.favorites,
                emptyIcon: Icons.favorite_border_rounded,
                emptyMessage: l10n.libraryEmptyFavorites,
                onOpen: (item) => _open(context, ref, item),
              ),
              LibraryTabView(
                kind: LibraryKind.notes,
                emptyIcon: Icons.note_outlined,
                emptyMessage: l10n.libraryEmptyNotes,
                onOpen: (item) => _open(context, ref, item),
              ),
              LibraryTabView(
                kind: LibraryKind.highlights,
                emptyIcon: Icons.brush_outlined,
                emptyMessage: l10n.libraryEmptyHighlights,
                onOpen: (item) => _open(context, ref, item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lưu vị trí đọc rồi mở trang đọc đúng tại Ayah — dùng chung
  /// [openAyahInReadingScreen] (DR-2026-0002 mục 9), cùng cơ chế
  /// với kết quả tìm kiếm và Revision Queue. Trước Sprint 9 Phase 4,
  /// hàm này tự lặp lại đúng 2 bước hàm dùng chung đã gói — thay
  /// bằng lời gọi trực tiếp, hành vi không đổi (xem DR-2026-0004
  /// mục "Consequences").
  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    LibraryItem item,
  ) {
    return openAyahInReadingScreen(
      context,
      ref,
      surahId: item.ayah.surahId,
      ayahNumber: item.ayah.ayahNumber,
    );
  }
}
