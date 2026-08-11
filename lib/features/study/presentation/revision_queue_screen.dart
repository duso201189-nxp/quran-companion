import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../library/domain/library_item.dart';
import '../../library/domain/library_kind.dart';
import '../../library/presentation/widgets/library_tab_view.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import '../data/surah_revision_target_providers.dart';

/// Màn hình "Ôn tập hằng ngày" (Revision Queue) — danh sách Ayah có
/// trạng thái 'review'. Tái dùng nguyên vẹn LibraryTabView (đã tự xử
/// lý loading/empty/error/data + LibraryAyahTile) — không có
/// list/tile implementation riêng (DR-2026-0004 mục 3).
///
/// Sprint 7.4 (DR-2026-0023 mục 9): [surahId] khác `null` thì đây là
/// LẦN ÔN GOM sau khi đọc trọn một Surah — vẫn đúng màn hình này, vẫn
/// đúng nguồn dữ liệu này, chỉ thu hẹp phạm vi hiển thị. Không có màn
/// hình ôn tập thứ hai, không có bộ lập lịch thứ hai.
///
/// Phạm vi thu hẹp lấy từ [surahRevisionTargetProvider] — **một nguồn
/// sự thật duy nhất**. Bản đầu của sprint này tự so `item.ayah.surahId
/// == surahId` ngay tại đây; kiểm toán cuối chỉ ra đó là nguồn sự thật
/// THỨ HAI chạy song song với provider, hai chỗ có thể trôi khỏi nhau
/// mà không ai phát hiện. Giờ màn hình chỉ hỏi provider "những Ayah
/// nào thuộc lần ôn gom này" rồi hiển thị đúng chúng.
class RevisionQueueScreen extends ConsumerWidget {
  const RevisionQueueScreen({super.key, this.surahId});

  /// `null` = hàng đợi đầy đủ (hành vi từ Sprint 9, không đổi).
  final int? surahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scopedSurahId = surahId;

    return Scaffold(
      appBar: AppBar(
        title: scopedSurahId == null
            ? Text(l10n.studyDailyReview)
            : _ScopedTitle(surahId: scopedSurahId),
      ),
      body: SafeArea(
        child: scopedSurahId == null
            ? _queue(context, ref, l10n)
            : _scopedQueue(context, ref, l10n, scopedSurahId),
      ),
    );
  }

  /// Hàng đợi đầy đủ — không lọc, đúng hành vi Sprint 9.
  Widget _queue(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return LibraryTabView(
      kind: LibraryKind.review,
      emptyIcon: Icons.rate_review_outlined,
      emptyMessage: l10n.revisionQueueEmpty,
      onOpen: (item) => _open(context, ref, item),
    );
  }

  /// Hàng đợi thu hẹp về một Surah, do [surahRevisionTargetProvider]
  /// quyết định thành phần.
  Widget _scopedQueue(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    int scopedSurahId,
  ) {
    return ref.watch(surahRevisionTargetProvider(scopedSurahId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // Phạm vi không giải quyết được -> KHÔNG âm thầm hiện cả hàng
          // đợi đầy đủ: đó là hiển thị sai phạm vi người dùng vừa chọn.
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.errorLoadData, textAlign: TextAlign.center),
            ),
          ),
          data: (targetAyahIds) {
            final target = targetAyahIds.toSet();
            return LibraryTabView(
              kind: LibraryKind.review,
              emptyIcon: Icons.rate_review_outlined,
              emptyMessage: l10n.revisionQueueEmpty,
              filter: (item) => target.contains(item.ayah.ayahId),
              onOpen: (item) => _open(context, ref, item),
            );
          },
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

/// Tiêu đề khi giới hạn trong một Surah — tên Surah lấy từ nhóm A;
/// chưa có tên thì hiện tiêu đề chung, không để trống tiêu đề.
class _ScopedTitle extends ConsumerWidget {
  const _ScopedTitle({required this.surahId});

  final int surahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(surahLatinNameProvider(surahId)).valueOrNull;
    return Text(
      name == null ? l10n.studyDailyReview : l10n.revisionQueueSurahTitle(name),
    );
  }
}
