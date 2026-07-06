import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../data/stats_store.dart';

/// Màn hình Thống kê — số liệu cục bộ (không cần backend):
/// ngày đọc, Ayah đã đọc, phút học, % hoàn thành, chuỗi ngày,
/// và biểu đồ cột 7 ngày gần nhất.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Đọc lại mỗi lần build — dữ liệu prefs rẻ, luôn tươi khi mở tab.
    final stats = ref.watch(statsStoreProvider);

    final hasData = stats.readingDayCount > 0;

    final metrics = <({IconData icon, String value, String label})>[
      (
        icon: Icons.calendar_month_rounded,
        value: '${stats.readingDayCount}',
        label: l10n.statsReadingDays,
      ),
      (
        icon: Icons.auto_stories_rounded,
        value: '${stats.ayahsRead}',
        label: l10n.statsAyahsRead,
      ),
      (
        icon: Icons.timer_rounded,
        value: '${stats.totalMinutes}',
        label: l10n.statsMinutes,
      ),
      (
        icon: Icons.donut_large_rounded,
        value: '${stats.completionPercent.toStringAsFixed(1)}%',
        label: l10n.statsCompletion,
      ),
      (
        icon: Icons.local_fire_department_rounded,
        value: l10n.streakDays(stats.currentStreak),
        label: l10n.statsCurrentStreak,
      ),
      (
        icon: Icons.emoji_events_rounded,
        value: l10n.streakDays(stats.longestStreak),
        label: l10n.statsLongestStreak,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStats)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 560
                    ? 3
                    : 2;
            final horizontal = constraints.maxWidth > 900
                ? (constraints.maxWidth - 860) / 2
                : 16.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
              children: [
                if (!hasData) ...[
                  _EmptyHint(text: l10n.statsNoData),
                  const SizedBox(height: 16),
                ],
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    for (final m in metrics)
                      _MetricCard(
                        icon: m.icon,
                        value: m.value,
                        label: m.label,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _WeeklyChartCard(
                  title: l10n.statsWeeklyActivity,
                  data: stats.last7Days,
                ),
                const SizedBox(height: 20),
                _CompletionCard(
                  label: l10n.statsCompletion,
                  percent: stats.completionPercent,
                  detail: '${stats.ayahsRead} / ${StatsStore.totalAyahs}',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Biểu đồ cột 7 ngày — vẽ thuần widget, không cần package chart.
class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.title, required this.data});

  final String title;
  final List<({DateTime day, int minutes})> data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxMinutes =
        data.map((d) => d.minutes).fold<int>(0, (a, b) => a > b ? a : b);
    final dayFormat = DateFormat.E(
      Localizations.localeOf(context).toLanguageTag(),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            // 120 vừa đủ tràn 2px khi có nhãn số phút + cột cao nhất
            // (nhãn phút ~16 + spacing 4 + cột tối đa 80 + spacing 6 +
            // nhãn thứ ~16 = 122). Chừa dư để không tràn.
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in data)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (d.minutes > 0)
                            Text(
                              '${d.minutes}',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Tooltip(
                            message:
                                '${dayFormat.format(d.day)}: ${d.minutes}′',
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: maxMinutes == 0
                                  ? 4
                                  : 4 + 76 * (d.minutes / maxMinutes),
                              decoration: BoxDecoration(
                                color: d.minutes > 0
                                    ? scheme.primary
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayFormat.format(d.day),
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thanh tiến độ hoàn thành Qur'an.
class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.label,
    required this.percent,
    required this.detail,
  });

  final String label;
  final double percent;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                detail,
                style: textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: percent / 100,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
