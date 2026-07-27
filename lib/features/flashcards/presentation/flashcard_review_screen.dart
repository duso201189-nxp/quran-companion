import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/theme/app_theme.dart';
import '../../learning/data/scheduler_providers.dart';
import '../../learning/domain/scheduling_algorithm.dart';
import 'flashcard_review_providers.dart';

/// Màn hình ôn Flashcard (Sprint 13 Phase 2 — kiến trúc đóng băng ở
/// Phase 1). Cùng khuôn ReviewSessionScreen hệt (Sprint 10 Phase 3):
/// từng thẻ đến hạn một, đánh giá bằng 4 mức SM-2 qua
/// SchedulerRepository — KHÔNG tự tính lịch trình, KHÔNG có logic
/// nghiệp vụ trong widget. Khác biệt DUY NHẤT với ReviewSessionScreen:
/// nội dung hiển thị là Lemma (Lexicon) thay vì Ayah, và không có nút
/// "Mở trong Kinh" (1 Lemma không gắn với đúng 1 Ayah cụ thể).
class FlashcardReviewScreen extends ConsumerWidget {
  const FlashcardReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemAsync = ref.watch(currentFlashcardReviewItemProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcardReviewTitle)),
      body: SafeArea(
        child: itemAsync.when(
          data: (item) => item == null
              ? _FlashcardReviewComplete(l10n: l10n)
              : _FlashcardView(l10n: l10n, item: item),
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

class _FlashcardReviewComplete extends StatelessWidget {
  const _FlashcardReviewComplete({required this.l10n});

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
            Icon(Icons.style_rounded, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.flashcardReviewComplete,
              textAlign: TextAlign.center,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.flashcardReviewCompleteSubtitle,
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

class _FlashcardView extends ConsumerWidget {
  const _FlashcardView({required this.l10n, required this.item});

  final AppLocalizations l10n;
  final FlashcardReviewItem item;

  /// Uỷ quyền tính toán lịch trình cho SchedulingAlgorithm (qua
  /// SchedulerRepository) — widget chỉ chuyển tiếp lựa chọn của
  /// người dùng, không tự suy ra ease/interval/due_date.
  Future<void> _grade(WidgetRef ref, ReviewGrade grade) {
    return ref
        .read(schedulerRepositoryProvider)
        .applyReview(item.card.id, grade);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lemma = item.lemma;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lemma.posTag != null)
                    Text(
                      lemma.posTag!,
                      style: textTheme.labelMedium
                          ?.copyWith(color: scheme.primary),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    lemma.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style:
                        quranTextStyle(fontSize: 30, color: scheme.onSurface),
                  ),
                  if (lemma.transliteration != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      lemma.transliteration!,
                      style: textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (lemma.meaningVi != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      lemma.meaningVi!,
                      style: textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ],
                  if (lemma.explanationVi != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      lemma.explanationVi!,
                      style: textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
