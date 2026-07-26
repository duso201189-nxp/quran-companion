import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/feature_gate.dart';
import '../../../app/router.dart';

/// Màn hình Học — điểm vào chính "Bắt đầu buổi học" (Sprint 11 Phase
/// 3, Learning Session) phía trên, các công cụ truy cập trực tiếp bên
/// dưới làm lối tắt.
///
/// RC-1 — ô Flashcard đi qua [featureAvailabilityProvider]: nó CHỈ
/// xuất hiện khi bảng `lemmas` có dữ liệu. Trước đây nó luôn hiện và
/// luôn dẫn tới một bộ sưu tập không thể có phần tử nào (xem
/// `feature_gate.dart`). Ẩn chứ KHÔNG hiện chip "Sắp ra mắt": chip đó
/// lại là một lời hứa, và sprint này tồn tại để gỡ những lời hứa
/// không có gì bảo đảm.
class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Chưa biết thì chưa hiện: trong khoảnh khắc chờ dò dữ liệu, thà
    // thiếu một ô còn hơn hiện rồi giật mất.
    final flashcardsAvailable = ref
            .watch(featureAvailabilityProvider(GatedFeature.flashcards))
            .valueOrNull ??
        false;

    final tools = <({
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
    })>[
      if (flashcardsAvailable)
        (
          icon: Icons.style_rounded,
          title: l10n.studyFlashcards,
          subtitle: l10n.studyFlashcardsDesc,
          onTap: () => context.push(AppRoutes.flashcards),
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
      (
        icon: Icons.insights_rounded,
        title: l10n.studyProgress,
        subtitle: l10n.studyProgressDesc,
        onTap: () => context.push(AppRoutes.progressDashboard),
      ),
      (
        icon: Icons.auto_awesome_rounded,
        title: l10n.studyCoachTile,
        subtitle: l10n.studyCoachTileDesc,
        onTap: () => context.push(AppRoutes.studyCoach),
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// RC-1 — KHÔNG còn nullable. Mọi ô hiện trên màn hình đều dẫn tới
  /// một màn hình hoạt động thật; ô nào không có dữ liệu đứng sau thì
  /// bị ẩn hẳn bởi cổng tính năng, chứ không hiện ra kèm chip "Sắp ra
  /// mắt" — một chip như thế lại là lời hứa không có gì bảo đảm.
  final VoidCallback onTap;

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
