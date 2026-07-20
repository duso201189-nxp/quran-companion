import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/theme/app_theme.dart';
import '../../quran/presentation/reading/reading_navigation.dart';
import '../data/scheduler_providers.dart';
import '../domain/scheduling_algorithm.dart';
import 'review_session_providers.dart';

/// Màn hình "Lặp lại ngắt quãng" (SM-2 Review Session — Sprint 10
/// Phase 3, DR-2026-0005). Trình bày từng thẻ đến hạn một, đánh giá
/// bằng 4 mức SM-2 (Again/Hard/Good/Easy) qua SchedulerRepository —
/// KHÔNG tự tính lịch trình, KHÔNG có logic nghiệp vụ trong widget
/// (chỉ đọc currentReviewItemProvider + gọi applyReview trực tiếp,
/// cùng mẫu với ActiveKhatmCard/RevisionQueueScreen). Sau khi đánh
/// giá, provider tự cập nhật phản ứng -> thẻ tiếp theo tự hiện ra,
/// không cần widget tự quản lý state hàng đợi.
class ReviewSessionScreen extends ConsumerWidget {
  const ReviewSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemAsync = ref.watch(currentReviewItemProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studySpaced)),
      body: SafeArea(
        child: itemAsync.when(
          data: (item) => item == null
              ? _ReviewSessionComplete(l10n: l10n)
              : _ReviewCard(l10n: l10n, item: item),
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

class _ReviewSessionComplete extends StatelessWidget {
  const _ReviewSessionComplete({required this.l10n});

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
              l10n.reviewSessionComplete,
              textAlign: TextAlign.center,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.reviewSessionCompleteSubtitle,
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

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.l10n, required this.item});

  final AppLocalizations l10n;
  final ReviewSessionItem item;

  /// Uỷ quyền tính toán lịch trình cho SchedulingAlgorithm (qua
  /// SchedulerRepository) — widget chỉ chuyển tiếp lựa chọn của
  /// người dùng, không tự suy ra ease/interval/due_date.
  Future<void> _grade(WidgetRef ref, ReviewGrade grade) {
    return ref
        .read(schedulerRepositoryProvider)
        .applyReview(item.card.id, grade);
  }

  /// Cùng cơ chế điều hướng dùng chung với Thư viện của tôi/Khatm/
  /// Revision Queue (DR-2026-0002 mục 9) — không tự lặp lại
  /// lưu-vị-trí-rồi-push.
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
                    style: quranTextStyle(fontSize: 26, color: scheme.onSurface),
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
                child: _GradeButton(
                  label: l10n.reviewGradeAgain,
                  color: scheme.error,
                  onPressed: () => _grade(ref, ReviewGrade.again),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GradeButton(
                  label: l10n.reviewGradeHard,
                  color: scheme.tertiary,
                  onPressed: () => _grade(ref, ReviewGrade.hard),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GradeButton(
                  label: l10n.reviewGradeGood,
                  color: scheme.primary,
                  onPressed: () => _grade(ref, ReviewGrade.good),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GradeButton(
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

class _GradeButton extends StatelessWidget {
  const _GradeButton({
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
