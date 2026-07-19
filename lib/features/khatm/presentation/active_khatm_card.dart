import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../quran/data/quran_providers.dart';
import '../../quran/presentation/reading/reading_position_store.dart';
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
    final cycleAsync = ref.watch(activeKhatmCycleProvider);

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
            data: (cycle) => cycle == null
                ? _EmptyKhatm(l10n: l10n)
                : _ActiveKhatm(l10n: l10n, cycle: cycle),
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

  Future<void> _continueReading(BuildContext context, WidgetRef ref) async {
    final results = await ref
        .read(quranRepositoryProvider)
        .getAyahsByIds([cycle.currentAyahId]);
    if (results.isEmpty) return;
    final target = results.first;
    await ref.read(readingPositionStoreProvider).save(
          surahId: target.surahId,
          ayahIndex: target.ayahNumber - 1,
        );
    if (context.mounted) {
      unawaited(context.push(AppRoutes.read(target.surahId)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // KhatmCycle.progressPercent đã có sẵn ở domain model (Phase
    // 2/3) — đọc thẳng từ khatmProgressProvider, không tính lại.
    final progress = ref.watch(khatmProgressProvider) ?? 0;

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
