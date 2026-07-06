import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Màn hình Học — bốn công cụ (Flashcard, Lặp lại ngắt quãng,
/// Trắc nghiệm, Ôn tập hằng ngày). UI sẵn sàng, logic học sẽ
/// nối vào ở bước sau (chưa cần backend).
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tools = <({
      IconData icon,
      String title,
      String subtitle,
    })>[
      (
        icon: Icons.style_rounded,
        title: l10n.studyFlashcards,
        subtitle: l10n.studyFlashcardsDesc,
      ),
      (
        icon: Icons.update_rounded,
        title: l10n.studySpaced,
        subtitle: l10n.studySpacedDesc,
      ),
      (
        icon: Icons.quiz_rounded,
        title: l10n.studyQuiz,
        subtitle: l10n.studyQuizDesc,
      ),
      (
        icon: Icons.today_rounded,
        title: l10n.studyDailyReview,
        subtitle: l10n.studyDailyReviewDesc,
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
            return GridView.count(
              padding:
                  EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String comingSoonLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: null, // sẽ mở công cụ khi logic học hoàn thiện
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
            ],
          ),
        ),
      ),
    );
  }
}
