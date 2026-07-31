import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../shared/widgets/section_header.dart';
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
          if (summary.flashcardsCompleted > 0) ...[
            const SizedBox(height: 10),
            _StatRow(
              icon: Icons.style_rounded,
              label: l10n.learningSummaryFlashcardCount(
                summary.flashcardsCompleted,
              ),
            ),
          ],
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

/// Sprint S2 (Quality & Polish, D1) — bọc `Semantics(label: label)` +
/// `ExcludeSemantics` gộp icon+text thành MỘT node duy nhất, cùng mẫu
/// đã áp dụng cho GoalCard/AchievementCard (audit phát hiện màn hình
/// này là ngoại lệ duy nhất trong các feature F4-F7 chưa làm việc
/// này). Icon ở đây thuần trang trí (label đã tự đủ nghĩa), nên không
/// cần label riêng cho icon.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
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
          // Sprint S2, D1 — SectionHeader render CÙNG style
          // (titleSmall/w700) widget này đã dùng, chỉ thêm
          // Semantics(header: true); zero thay đổi hình ảnh.
          SectionHeader(text: l10n.learningSummaryActivitiesTitle),
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

/// Sprint S2 (Quality & Polish, D1) — bọc Semantics gộp icon + nhãn
/// hoạt động + trạng thái hoàn thành thành MỘT node, cùng lý do
/// [_StatRow]. Nhãn gộp tái dùng 2 chuỗi l10n đã có sẵn
/// (`learningSummaryStatusCompleted`/`learningSummaryNotCompleted`,
/// dòng "Completed"/"Not completed" hiện tại) — không thêm chuỗi mới.
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
    final statusText = done
        ? l10n.learningSummaryStatusCompleted
        : l10n.learningSummaryNotCompleted;

    return Semantics(
      label: '$label, $statusText',
      child: ExcludeSemantics(
        child: Row(
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
        ),
      ),
    );
  }
}
