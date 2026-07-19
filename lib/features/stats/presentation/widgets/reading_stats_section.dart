import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/study_session_providers.dart';

/// Phần "Phiên đọc" — Current Streak / Longest Streak / Today's
/// Study Summary, đọc từ study_sessions (Drift, Sprint 8 Phase 3).
///
/// Tách riêng khỏi lưới chỉ số hiện có (StatsStore/SharedPreferences,
/// không đụng tới ở Phase 4) vì đây là hai nguồn dữ liệu độc lập:
/// chưa có nơi nào trong app gọi StudySessionRepository.logSession
/// từ luồng đọc thật (việc nối đó ngoài phạm vi Phase 4 — chỉ UI),
/// nên phần này thường hiển thị trạng thái rỗng cho tới khi được nối.
class ReadingStatsSection extends StatelessWidget {
  const ReadingStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statsSessionsTitle,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StreakCard(
                provider: currentStreakProvider,
                icon: Icons.local_fire_department_rounded,
                label: l10n.statsCurrentStreak,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StreakCard(
                provider: longestStreakProvider,
                icon: Icons.emoji_events_rounded,
                label: l10n.statsLongestStreak,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _TodaySummaryCard(),
      ],
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard({
    required this.provider,
    required this.icon,
    required this.label,
  });

  final ProviderListenable<AsyncValue<int>> provider;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final streak = ref.watch(provider);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 8),
          streak.when(
            data: (value) => Text(
              l10n.streakDays(value),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            loading: () => const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => Icon(
              Icons.error_outline_rounded,
              color: scheme.error,
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

class _TodaySummaryCard extends ConsumerWidget {
  const _TodaySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final summary = ref.watch(todayStudySummaryProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: summary.when(
        data: (s) {
          if (s.sessionCount == 0) {
            return Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.statsSessionsEmpty,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.statsTodayTitle,
                style:
                    textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${l10n.statsTodayMinutes(s.totalDurationSec ~/ 60)} · '
                '${l10n.statsTodaySessionsCount(s.sessionCount)}',
                style: textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (_, __) => Text(
          l10n.errorLoadData,
          style: textTheme.bodyMedium?.copyWith(color: scheme.error),
        ),
      ),
    );
  }
}
