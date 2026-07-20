import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';

/// Màn hình Học — điểm vào chính "Bắt đầu buổi học" (Sprint 11 Phase
/// 3, Learning Session) phía trên, bốn công cụ truy cập trực tiếp
/// (Flashcard, Lặp lại ngắt quãng, Trắc nghiệm, Ôn tập hằng ngày) giữ
/// nguyên bên dưới làm lối tắt — Phase 0 Revision cố ý để cả hai cùng
/// tồn tại thay vì bỏ 4 thẻ cũ (câu hỏi sản phẩm còn mở, xem kiến
/// trúc). Chỉ Flashcard còn hoãn lại (chưa có dữ liệu từ vựng, xem
/// DR-2026-0005 mục 5).
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tools = <({
      IconData icon,
      String title,
      String subtitle,
      VoidCallback? onTap,
    })>[
      (
        icon: Icons.style_rounded,
        title: l10n.studyFlashcards,
        subtitle: l10n.studyFlashcardsDesc,
        onTap: null,
      ),
      (
        icon: Icons.update_rounded,
        title: l10n.studySpaced,
        subtitle: l10n.studySpacedDesc,
        onTap: () => context.push(AppRoutes.reviewSession),
      ),
      (
        icon: Icons.quiz_rounded,
        title: l10n.studyQuiz,
        subtitle: l10n.studyQuizDesc,
        onTap: () => context.push(AppRoutes.quizSession),
      ),
      (
        icon: Icons.today_rounded,
        title: l10n.studyDailyReview,
        subtitle: l10n.studyDailyReviewDesc,
        onTap: () => context.push(AppRoutes.revisionQueue),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStudy)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            final horizontal = constraints.maxWidth > 900
                ? (constraints.maxWidth - 860) / 2
                : 16.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.learningSession),
                    icon: const Icon(Icons.auto_stories_rounded),
                    label: Text(l10n.learningSessionStart),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: wide ? 2 : 1,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: wide ? 2.9 : 3.4,
                  children: [
                    for (final t in tools)
                      _StudyToolCard(
                        icon: t.icon,
                        title: t.title,
                        subtitle: t.subtitle,
                        comingSoonLabel: l10n.comingSoon,
                        onTap: t.onTap,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StudyToolCard extends StatelessWidget {
  const _StudyToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.comingSoonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String comingSoonLabel;

  /// null = công cụ chưa nối logic thật, hiện chip "Sắp ra mắt".
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: scheme.primary, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap == null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    comingSoonLabel,
                    style: textTheme.labelSmall
                        ?.copyWith(color: scheme.onSecondaryContainer),
                  ),
                ),
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
