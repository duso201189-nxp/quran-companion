import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/theme/app_theme.dart';
import '../../learning/domain/scheduling_algorithm.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import '../data/hifz_providers.dart';

/// Màn hình ôn Hifz — Sprint 7.7b-iii.
///
/// CÙNG khuôn ReviewSessionScreen (ôn thường, `review_session_screen.dart`)
/// về cấu trúc hiển thị (một thẻ, 4 mức chấm điểm, trạng thái hoàn tất),
/// nhưng KHÔNG dùng chung provider/engine: đọc [currentHifzReviewItemProvider]
/// (không phải `currentReviewItemProvider`), chấm điểm qua
/// [hifzSchedulerRepositoryProvider] (không phải `schedulerRepositoryProvider`).
/// Hai bề mặt ôn tập tách biệt có chủ đích (xem doc
/// [hifzSchedulerRepositoryProvider]) — màn hình này lặp lại cấu trúc trình
/// bày, không kéo theo dùng chung nguồn thẻ hay nguồn lịch trình.
///
/// An toàn loại thẻ: `item.card.id` ở đây luôn đến từ
/// `dueHifzCardsProvider` -> `hifzSchedulerRepositoryProvider
/// .watchAllCards(LearningItemType.hifz)` — không có đường nào để một thẻ
/// `item_type='ayah'` lọt vào đây.
class HifzReviewScreen extends ConsumerWidget {
  const HifzReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemAsync = ref.watch(currentHifzReviewItemProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hifzReviewTitle)),
      body: SafeArea(
        child: itemAsync.when(
          data: (item) => item == null
              ? _HifzReviewComplete(l10n: l10n)
              : _HifzReviewCard(l10n: l10n, item: item),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(
            child: Text(
              l10n.errorLoadData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}

class _HifzReviewComplete extends StatelessWidget {
  const _HifzReviewComplete({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.hifzReviewComplete,
              textAlign: TextAlign.center,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.hifzReviewCompleteSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _HifzReviewCard extends ConsumerWidget {
  const _HifzReviewCard({required this.l10n, required this.item});

  final AppLocalizations l10n;
  final HifzReviewItem item;

  /// Uỷ quyền tính toán lịch trình cho HifzSchedulingAlgorithm (qua
  /// [hifzSchedulerRepositoryProvider]) — widget chỉ chuyển tiếp lựa chọn
  /// của người dùng, không tự suy ra ease/interval/due_date. KHÔNG gọi
  /// `schedulerRepositoryProvider` (đó là engine của ôn thường).
  Future<void> _grade(WidgetRef ref, ReviewGrade grade) {
    return ref
        .read(hifzSchedulerRepositoryProvider)
        .applyReview(item.card.id, grade);
  }

  Future<void> _openInReading(BuildContext context, WidgetRef ref) {
    return openAyahInReadingScreen(
      context,
      ref,
      surahId: item.ayah.surahId,
      ayahNumber: item.ayah.ayahNumber,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ayah = item.ayah;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ayah.surahNameLatin} · ${ayah.surahId}:'
                    '${ayah.ayahNumber}',
                    style:
                        textTheme.labelMedium?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ayah.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style:
                        quranTextStyle(fontSize: 26, color: scheme.onSurface),
                  ),
                  if (ayah.translation != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      ayah.translation!,
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _openInReading(context, ref),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(l10n.reviewOpenInReading),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HifzGradeButton(
                  label: l10n.reviewGradeAgain,
                  color: scheme.error,
                  onPressed: () => _grade(ref, ReviewGrade.again),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HifzGradeButton(
                  label: l10n.reviewGradeHard,
                  color: scheme.tertiary,
                  onPressed: () => _grade(ref, ReviewGrade.hard),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HifzGradeButton(
                  label: l10n.reviewGradeGood,
                  color: scheme.primary,
                  onPressed: () => _grade(ref, ReviewGrade.good),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HifzGradeButton(
                  label: l10n.reviewGradeEasy,
                  color: scheme.secondary,
                  onPressed: () => _grade(ref, ReviewGrade.easy),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HifzGradeButton extends StatelessWidget {
  const _HifzGradeButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
