import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../library/domain/library_item.dart';
import '../../library/domain/library_kind.dart';
import '../../library/presentation/widgets/library_tab_view.dart';
import '../../quran/presentation/reading/reading_navigation.dart';

/// Màn hình "Ôn tập hằng ngày" (Revision Queue) — danh sách Ayah có
/// trạng thái 'review'. Tái dùng nguyên vẹn LibraryTabView (đã tự xử
/// lý loading/empty/error/data + LibraryAyahTile) — không có
/// list/tile implementation riêng (DR-2026-0004 mục 3).
class RevisionQueueScreen extends ConsumerWidget {
  const RevisionQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studyDailyReview)),
      body: SafeArea(
        child: LibraryTabView(
          kind: LibraryKind.review,
          emptyIcon: Icons.rate_review_outlined,
          emptyMessage: l10n.revisionQueueEmpty,
          onOpen: (item) => _open(context, ref, item),
        ),
      ),
    );
  }

  /// Cùng cơ chế điều hướng dùng chung với Tìm kiếm (DR-2026-0002
  /// mục 9) — không tự lặp lại lưu-vị-trí-rồi-push.
  Future<void> _open(BuildContext context, WidgetRef ref, LibraryItem item) {
    return openAyahInReadingScreen(
      context,
      ref,
      surahId: item.ayah.surahId,
      ayahNumber: item.ayah.ayahNumber,
    );
  }
}
