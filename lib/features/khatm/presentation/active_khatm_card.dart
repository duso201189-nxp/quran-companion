import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../quran/data/quran_providers.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import '../data/khatm_cycle_providers.dart';
import '../domain/entities/khatm_cycle.dart';

/// Thẻ "Khatm đang đọc" — tiến độ, thanh tiến độ, tiếp tục đọc.
/// Khi chưa có chu kỳ nào, hiện nút bắt đầu tối giản (không có
/// trong danh sách deliverable gốc của Phase 4, nhưng không có nó
/// thì Progress Bar/Continue Reading không bao giờ có cách nào
/// xuất hiện thật — bổ sung tối thiểu, có chủ đích, được nêu rõ
/// trong báo cáo Phase 4).
class ActiveKhatmCard extends ConsumerWidget {
  const ActiveKhatmCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Sprint 5.1 (Finding 3) — chu kỳ GẦN ĐÂY NHẤT bất kể trạng thái,
    // không phải activeKhatmCycleProvider (provider đó cố ý loại chu
    // kỳ đã hoàn thành — dùng cho ReadingScreen ghi tiến độ, không
    // dùng để hiển thị). Xem doc comment ở khatm_cycle_providers.dart.
    final cycleAsync = ref.watch(latestKhatmCycleProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.khatmSectionTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          cycleAsync.when(
            data: (cycle) => switch (cycle) {
              null => _EmptyKhatm(l10n: l10n),
              KhatmCycle(isCompleted: true) =>
                _CompletedKhatm(l10n: l10n, cycle: cycle),
              _ => _ActiveKhatm(l10n: l10n, cycle: cycle),
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => Text(
              l10n.errorLoadData,
              style: textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyKhatm extends ConsumerWidget {
  const _EmptyKhatm({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.khatmEmpty,
            style:
                textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.tonal(
          onPressed: () => ref
              .read(khatmCycleRepositoryProvider)
              .startCycle(name: l10n.khatmDefaultName),
          child: Text(l10n.khatmStart),
        ),
      ],
    );
  }
}

class _ActiveKhatm extends ConsumerWidget {
  const _ActiveKhatm({required this.l10n, required this.cycle});

  final AppLocalizations l10n;
  final KhatmCycle cycle;

  /// Quy đổi currentAyahId (toàn cục) sang surahId/ayahNumber rồi mở
  /// đúng Ayah — dùng chung [openAyahInReadingScreen] (DR-2026-0002
  /// mục 9), cùng cơ chế với Thư viện của tôi/Tìm kiếm/Revision
  /// Queue. Trước Sprint 9 Phase 4, đoạn lưu-vị-trí-rồi-push tự lặp
  /// lại thay vì gọi hàm dùng chung — thay bằng lời gọi trực tiếp,
  /// hành vi không đổi.
  Future<void> _continueReading(BuildContext context, WidgetRef ref) async {
    final results = await ref
        .read(quranRepositoryProvider)
        .getAyahsByIds([cycle.currentAyahId]);
    if (results.isEmpty) return;
    if (!context.mounted) return;
    final target = results.first;
    await openAyahInReadingScreen(
      context,
      ref,
      surahId: target.surahId,
      ayahNumber: target.ayahNumber,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // KhatmCycle.progressPercent đã có sẵn ở domain model, và [cycle]
    // đã có sẵn ở đây — đọc thẳng, không cần provider trung gian nữa.
    // (Sprint 5.1 Finding 3 bỏ khatmProgressProvider: nó chỉ tồn tại
    // để tránh gọi lại phép tính này, nhưng giờ luôn có [cycle] trong
    // tay ngay tại nơi gọi, provider đó chỉ còn là một lớp gián tiếp
    // không cần thiết — "no duplicate state".)
    final progress = cycle.progressPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cycle.name,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.khatmAyahPosition(cycle.currentAyahId, KhatmCycle.totalAyahs),
          style:
              textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress / 100,
            backgroundColor: scheme.surfaceContainerHighest,
            semanticsLabel: l10n.khatmProgressLabel,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _continueReading(context, ref),
            icon: const Icon(Icons.menu_book_rounded),
            label: Text(l10n.khatmContinueReading),
          ),
        ),
      ],
    );
  }
}

/// Chu kỳ Khatm vừa hoàn thành — Sprint 5.1 (Finding 3).
///
/// Ở lại nguyên trạng thái này cho tới khi người dùng bắt đầu chu kỳ
/// mới: [latestKhatmCycleProvider] vẫn trả về đúng chu kỳ này (mới bắt
/// đầu nhất) chừng nào chưa có chu kỳ nào mới hơn, nên không cần cờ
/// "đã xem" hay bất kỳ trạng thái cục bộ nào — cùng database vẫn là
/// nguồn sự thật duy nhất, chỉ đọc lại cùng một dữ liệu.
class _CompletedKhatm extends ConsumerWidget {
  const _CompletedKhatm({required this.l10n, required this.cycle});

  final AppLocalizations l10n;
  final KhatmCycle cycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.khatmCompletedTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          cycle.name,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.khatmCompletedBody,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: () => ref
                .read(khatmCycleRepositoryProvider)
                .startCycle(name: l10n.khatmDefaultName),
            child: Text(l10n.khatmStart),
          ),
        ),
      ],
    );
  }
}
