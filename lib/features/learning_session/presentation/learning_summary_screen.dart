import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../domain/learning_planner.dart';
import '../domain/learning_session_state.dart';
import '../domain/learning_session_summary.dart';

/// Màn hình tóm tắt cuối Learning Session (Sprint 11 Phase 4 — bố cục
/// đầy đủ). Chỉ hiển thị [state] đã tích luỹ sẵn từ
/// LearningSessionController — không tự tính lại số liệu, không đọc
/// provider nào (StatelessWidget thuần trình bày).
class LearningSummaryScreen extends StatelessWidget {
  const LearningSummaryScreen({super.key, required this.state});

  final LearningSessionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learningSummaryTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 64,
                color: scheme.primary,
              ),
              const SizedBox(height: 12),
              _StatusBadge(status: state.status, l10n: l10n),
              const SizedBox(height: 24),
              _SummaryStatsCard(summary: state.summary, l10n: l10n),
              const SizedBox(height: 16),
              _ActivitiesCard(
                completed: state.completedActivities,
                l10n: l10n,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.study),
                  child: Text(l10n.learningSummaryDone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Huy hiệu trạng thái phiên. LearningSummaryScreen chỉ được hiển thị
/// khi status == completed (xem LearningSessionScreen) — nhánh khác
/// chỉ để widget tự đứng vững nếu dùng lại ở nơi khác sau này.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.l10n});

  final LearningSessionStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (status != LearningSessionStatus.completed) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            l10n.learningSummaryStatusCompleted,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatsCard extends StatelessWidget {
  const _SummaryStatsCard({required this.summary, required this.l10n});

  final LearningSessionSummary summary;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasQuiz = summary.quizScore != null && summary.quizTotal != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatRow(
            icon: Icons.update_rounded,
            label: l10n.learningSummaryReviewCount(
              summary.reviewCardsCompleted,
            ),
          ),
          if (hasQuiz) ...[
            const SizedBox(height: 10),
            _StatRow(
              icon: Icons.quiz_rounded,
              label: l10n.learningSummaryQuizScore(
                summary.quizScore!,
                summary.quizTotal!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _ActivitiesCard extends StatelessWidget {
  const _ActivitiesCard({required this.completed, required this.l10n});

  final Set<LearningActivityType> completed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activities = [
      (type: LearningActivityType.review, label: l10n.studySpaced),
      (type: LearningActivityType.quiz, label: l10n.studyQuiz),
      (type: LearningActivityType.flashcard, label: l10n.studyFlashcards),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.learningSummaryActivitiesTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < activities.length; i++) ...[
            _ActivityRow(
              label: activities[i].label,
              done: completed.contains(activities[i].type),
              l10n: l10n,
            ),
            if (i < activities.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.label,
    required this.done,
    required this.l10n,
  });

  final String label;
  final bool done;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 20,
          color: done ? scheme.primary : scheme.outlineVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: done ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (!done)
          Text(
            l10n.learningSummaryNotCompleted,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
