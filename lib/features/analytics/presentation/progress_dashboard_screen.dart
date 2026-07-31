import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../flashcards/domain/resolved_flashcard.dart';
import '../../flashcards/presentation/widgets/flashcard_tile.dart';
import '../../search/presentation/widgets/search_error_state.dart';
import '../data/analytics_providers.dart';
import '../domain/entities/achievement.dart';
import '../domain/entities/history_bucket.dart';
import '../domain/entities/learning_goal.dart';
import 'widgets/achievement_card.dart';
import 'widgets/goal_card.dart';

/// Bảng điều khiển Tiến độ học tập (Sprint 14 Phase 1 mục 3, đánh
/// bóng ở Phase 2.1, thêm Goals & Achievements ở Phase 2.2) — gộp cả
/// Statistics/History/Performance Insights/Goals/Achievements thành 1
/// màn hình duy nhất, đúng vai trò "Dashboard" là mặt trình bày tổng
/// hợp, không phải nhiều tính năng riêng lẻ.
///
/// Phase 2.2 CHỈ thêm 1 lớp trình bày mới (mục tiêu/thành tựu) XÂY
/// HOÀN TOÀN trên AnalyticsRepository đã có — KHÔNG thêm số liệu mới,
/// KHÔNG đổi Scheduler/Flashcard/Lexicon/Provider Architecture.
class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Làm mới mọi nguồn — invalidate cả family learningHistoryProvider
    // (không truyền tham số) huỷ MỌI granularity đang cache, đúng ngữ
    // nghĩa "kéo để tải lại toàn bộ Dashboard" thay vì chỉ granularity
    // hiện tại. learningGoalsProvider/achievementsProvider cũng cần
    // invalidate riêng — chúng KHÔNG watch lại 3 provider trên (mỗi
    // provider tự gọi AnalyticsRepository qua Future độc lập, không
    // có quan hệ watch/dependency Riverpod nào giữa chúng).
    ref.invalidate(learningStatisticsProvider);
    ref.invalidate(learningHistoryProvider);
    ref.invalidate(performanceInsightsProvider);
    ref.invalidate(learningGoalsProvider);
    ref.invalidate(achievementsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressDashboardTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 900
                ? (constraints.maxWidth - 860) / 2
                : 16.0;
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
                children: [
                  SectionHeader(text: l10n.progressDashboardOverview),
                  const SizedBox(height: 12),
                  const _StatisticsSection(),
                  const SizedBox(height: 20),
                  SectionHeader(text: l10n.progressDashboardGoals),
                  const SizedBox(height: 12),
                  const _GoalsSection(),
                  const SizedBox(height: 20),
                  SectionHeader(text: l10n.progressDashboardAchievements),
                  const SizedBox(height: 12),
                  const _AchievementsSection(),
                  const SizedBox(height: 20),
                  const _HistorySection(),
                  const SizedBox(height: 20),
                  const _InsightsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatisticsSection extends ConsumerWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(learningStatisticsProvider);

    return statsAsync.when(
      loading: () =>
          LoadingState(semanticsLabel: l10n.progressDashboardLoading),
      error: (_, __) => SearchErrorState(
        onRetry: () => ref.invalidate(learningStatisticsProvider),
      ),
      data: (stats) {
        if (stats.cardsStudied == 0) {
          return EmptyStateBanner(text: l10n.progressDashboardEmpty);
        }

        // 4 thẻ "tóm tắt trực quan" nêu rõ trong yêu cầu Task 2 — tô
        // nổi bật bằng primaryContainer để tách biệt khỏi 2 thẻ chi
        // tiết (Average Ease/Interval) bên dưới, KHÔNG phải số liệu
        // mới, chỉ đổi cách trình bày của đúng 4 giá trị đã có.
        final highlights = <Widget>[
          StatCard(
            icon: Icons.style_rounded,
            value: '${stats.cardsStudied}',
            label: l10n.statCardsStudied,
            accented: true,
          ),
          StatCard(
            icon: Icons.today_rounded,
            value: '${stats.reviewsToday}',
            label: l10n.statReviewsToday,
            accented: true,
          ),
          _AccuracyMetricCard(
            value: stats.accuracy,
            label: l10n.statAccuracy,
          ),
          StatCard(
            icon: Icons.local_fire_department_rounded,
            value: l10n.streakDays(stats.readingStreakDays),
            label: l10n.statsCurrentStreak,
            accented: true,
          ),
        ];
        final details = <Widget>[
          StatCard(
            icon: Icons.speed_rounded,
            value: stats.averageEase.toStringAsFixed(2),
            label: l10n.statAverageEase,
          ),
          StatCard(
            icon: Icons.calendar_view_day_rounded,
            value: stats.averageInterval.toStringAsFixed(1),
            label: l10n.statAverageInterval,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 560 ? 3 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: [...highlights, ...details],
            );
          },
        );
      },
    );
  }
}

/// (icon, nhãn, chuỗi tiến độ đã dịch) cho 1 LearningGoal — ánh xạ
/// [LearningGoalKind] sang chuỗi l10n ở TẦNG UI, giữ domain thuần
/// không nhúng chuỗi 1 ngôn ngữ (cùng kỷ luật HistoryBucket).
({IconData icon, String label, String progressText}) _goalPresentation(
  AppLocalizations l10n,
  LearningGoal goal,
) {
  return switch (goal.kind) {
    LearningGoalKind.dailyStudyMinutes => (
        icon: Icons.menu_book_rounded,
        label: l10n.goalDailyStudyLabel,
        progressText: l10n.dailyGoalMinutesProgress(goal.current, goal.target),
      ),
    LearningGoalKind.dailyReviews => (
        icon: Icons.style_rounded,
        label: l10n.goalDailyReviewsLabel,
        progressText: l10n.goalReviewsProgress(goal.current, goal.target),
      ),
    LearningGoalKind.weeklyStudyMinutes => (
        icon: Icons.calendar_view_week_rounded,
        label: l10n.goalWeeklyStudyLabel,
        progressText: l10n.goalWeeklyMinutesProgress(goal.current, goal.target),
      ),
  };
}

class _GoalsSection extends ConsumerWidget {
  const _GoalsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goalsAsync = ref.watch(learningGoalsProvider);

    return goalsAsync.when(
      loading: () =>
          LoadingState(semanticsLabel: l10n.progressDashboardLoading),
      error: (_, __) => SearchErrorState(
        onRetry: () => ref.invalidate(learningGoalsProvider),
      ),
      data: (goals) => Column(
        children: [
          for (final goal in goals)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Builder(
                builder: (context) {
                  final p = _goalPresentation(l10n, goal);
                  return GoalCard(
                    icon: p.icon,
                    label: p.label,
                    progressText: p.progressText,
                    progress: goal.progress,
                    isAchieved: goal.isAchieved,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// (icon, tiêu đề, chuỗi tiến độ đã dịch) cho 1 Achievement — cùng
/// nguyên tắc với _goalPresentation ở trên. Đơn vị hiển thị (thẻ/
/// ngày/%) khác nhau theo [AchievementKind] nên chọn template l10n
/// tương ứng, KHÔNG nhúng đơn vị cố định trong domain.
({IconData icon, String title, String progressText}) _achievementPresentation(
  AppLocalizations l10n,
  Achievement achievement,
) {
  return switch (achievement.kind) {
    AchievementKind.firstStudy => (
        icon: Icons.auto_awesome_rounded,
        title: l10n.achievementFirstStudyTitle,
        progressText: l10n.achievementProgressCards(
          achievement.current,
          achievement.target,
        ),
      ),
    AchievementKind.tenCardsStudied => (
        icon: Icons.style_rounded,
        title: l10n.achievementTenCardsTitle,
        progressText: l10n.achievementProgressCards(
          achievement.current,
          achievement.target,
        ),
      ),
    AchievementKind.hundredCardsStudied => (
        icon: Icons.workspace_premium_rounded,
        title: l10n.achievementHundredCardsTitle,
        progressText: l10n.achievementProgressCards(
          achievement.current,
          achievement.target,
        ),
      ),
    AchievementKind.sevenDayStreak => (
        icon: Icons.local_fire_department_rounded,
        title: l10n.achievementSevenDayStreakTitle,
        progressText: l10n.achievementProgressDays(
          achievement.current,
          achievement.target,
        ),
      ),
    AchievementKind.thirtyDayLongestStreak => (
        icon: Icons.emoji_events_rounded,
        title: l10n.achievementThirtyDayStreakTitle,
        progressText: l10n.achievementProgressDays(
          achievement.current,
          achievement.target,
        ),
      ),
    AchievementKind.sharpMemory => (
        icon: Icons.track_changes_rounded,
        title: l10n.achievementSharpMemoryTitle,
        progressText: l10n.achievementProgressPercent(
          achievement.current,
          achievement.target,
        ),
      ),
  };
}

class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final achievementsAsync = ref.watch(achievementsProvider);

    return achievementsAsync.when(
      loading: () =>
          LoadingState(semanticsLabel: l10n.progressDashboardLoading),
      error: (_, __) =>
          SearchErrorState(onRetry: () => ref.invalidate(achievementsProvider)),
      data: (achievements) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final achievement in achievements)
            Builder(
              builder: (context) {
                final p = _achievementPresentation(l10n, achievement);
                return AchievementCard(
                  icon: p.icon,
                  title: p.title,
                  progressText: p.progressText,
                  progress: achievement.progress,
                  isUnlocked: achievement.isUnlocked,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HistorySection extends ConsumerStatefulWidget {
  const _HistorySection();

  @override
  ConsumerState<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends ConsumerState<_HistorySection> {
  HistoryGranularity _granularity = HistoryGranularity.daily;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(learningHistoryProvider(_granularity));
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap thay vì Row(spaceBetween) — ở màn hình hẹp hoặc khi
          // phóng to cỡ chữ hệ thống, SegmentedButton 3 đoạn có thể
          // rộng hơn phần còn lại của Row và bị tràn; Wrap tự động
          // xuống dòng thay vì tràn ra ngoài khung.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              SectionHeader(text: l10n.progressDashboardHistory),
              SegmentedButton<HistoryGranularity>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: HistoryGranularity.daily,
                    label: Text(l10n.historyDaily),
                  ),
                  ButtonSegment(
                    value: HistoryGranularity.weekly,
                    label: Text(l10n.historyWeekly),
                  ),
                  ButtonSegment(
                    value: HistoryGranularity.monthly,
                    label: Text(l10n.historyMonthly),
                  ),
                ],
                selected: {_granularity},
                onSelectionChanged: (s) =>
                    setState(() => _granularity = s.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            loading: () =>
                LoadingState(semanticsLabel: l10n.progressDashboardLoading),
            error: (_, __) => SearchErrorState(
              onRetry: () =>
                  ref.invalidate(learningHistoryProvider(_granularity)),
            ),
            data: (buckets) =>
                _HistoryChart(buckets: buckets, granularity: _granularity),
          ),
        ],
      ),
    );
  }
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.buckets, required this.granularity});

  final List<HistoryBucket> buckets;
  final HistoryGranularity granularity;

  String _labelFor(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return switch (granularity) {
      HistoryGranularity.daily => DateFormat.E(locale).format(d),
      HistoryGranularity.weekly => DateFormat.Md(locale).format(d),
      HistoryGranularity.monthly => DateFormat.MMM(locale).format(d),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxMinutes = buckets
        .map((b) => b.minutesStudied)
        .fold<int>(0, (a, b) => a > b ? a : b);

    if (buckets.every((b) => b.minutesStudied == 0)) {
      return EmptyStateBanner(
        text: AppLocalizations.of(context).progressDashboardHistoryEmpty,
      );
    }

    return SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final b in buckets)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Semantics(
                  label: '${_labelFor(context, b.periodStart)}: '
                      '${b.minutesStudied}',
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (b.minutesStudied > 0)
                          Text(
                            '${b.minutesStudied}',
                            style: textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        const SizedBox(height: 4),
                        Tooltip(
                          message: '${_labelFor(context, b.periodStart)}: '
                              '${b.minutesStudied}′',
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: maxMinutes == 0
                                ? 4
                                : 4 + 76 * (b.minutesStudied / maxMinutes),
                            decoration: BoxDecoration(
                              color: b.minutesStudied > 0
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _labelFor(context, b.periodStart),
                          style: textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightsSection extends ConsumerWidget {
  const _InsightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final insightsAsync = ref.watch(performanceInsightsProvider);

    return insightsAsync.when(
      loading: () =>
          LoadingState(semanticsLabel: l10n.progressDashboardLoading),
      error: (_, __) => SearchErrorState(
        onRetry: () => ref.invalidate(performanceInsightsProvider),
      ),
      data: (insights) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(text: l10n.progressDashboardInsights),
          const SizedBox(height: 8),
          _InsightGroup(
            title: l10n.insightsWeakRoots,
            items: insights.weakRoots,
          ),
          _InsightGroup(
            title: l10n.insightsDifficultLemmas,
            items: insights.difficultLemmas,
          ),
          _InsightGroup(
            title: l10n.insightsFrequentlyForgotten,
            items: insights.frequentlyForgotten,
          ),
          _InsightGroup(
            title: l10n.insightsFastestImproving,
            items: insights.fastestImproving,
          ),
        ],
      ),
    );
  }
}

class _InsightGroup extends StatelessWidget {
  const _InsightGroup({required this.title, required this.items});

  final String title;
  final List<ResolvedFlashcard> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              title,
              style:
                  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('${items.length}'),
            children: [
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    l10n.insightsEmpty,
                    style: textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                )
              else
                for (final item in items) FlashcardTile(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

/// Biểu đồ nhẹ cho Accuracy (Task 3) — vòng tròn tiến độ dựng từ
/// CircularProgressIndicator sẵn có của Flutter (không thêm gói
/// chart), hiển thị lại ĐÚNG stats.accuracy đã tính ở Phase 1, không
/// suy thêm số liệu nào.
///
/// Sprint 20 Phase 2, Task 3 — CỐ Ý KHÔNG gộp vào `StatCard`
/// (`lib/shared/widgets/stat_card.dart`): có vòng tròn tiến độ
/// (`CircularProgressIndicator` + `%` chồng lên) mà `StatCard` không
/// có khái niệm tương đương — bố cục Row (vòng tròn cạnh nhãn), không
/// phải Column icon-trên-giá-trị. Xem accessibility_audit.md mục
/// "StatCard".
class _AccuracyMetricCard extends StatelessWidget {
  const _AccuracyMetricCard({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final clamped = value.clamp(0.0, 1.0);
    final percentText = '${(value * 100).toStringAsFixed(0)}%';

    return Semantics(
      label: '$label: $percentText',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: clamped,
                      strokeWidth: 4,
                      backgroundColor:
                          scheme.onPrimaryContainer.withValues(alpha: 0.18),
                      valueColor:
                          AlwaysStoppedAnimation(scheme.onPrimaryContainer),
                    ),
                    Text(
                      percentText,
                      style: textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: textTheme.labelSmall
                      ?.copyWith(color: scheme.onPrimaryContainer),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
