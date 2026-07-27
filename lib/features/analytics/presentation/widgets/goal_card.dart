import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Thẻ 1 mục tiêu học tập (Sprint 14 Phase 2.2 mục 4) — thuần trình
/// bày, KHÔNG đọc provider/tính toán gì (nhận sẵn [progress] 0.0-1.0
/// và [isAchieved] từ LearningGoal ở nơi gọi) — tái dùng được ở bất
/// kỳ đâu cần hiển thị 1 mục tiêu, không chỉ ProgressDashboardScreen.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.icon,
    required this.label,
    required this.progressText,
    required this.progress,
    required this.isAchieved,
  });

  final IconData icon;
  final String label;
  final String progressText;

  /// 0.0-1.0 — nơi gọi tự kẹp giá trị (xem LearningGoal.progress).
  final double progress;
  final bool isAchieved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semanticsLabel = isAchieved
        ? '$label: $progressText. ${l10n.goalAchieved}'
        : '$label: $progressText';

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isAchieved ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: progress,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progressText,
                      style: textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isAchieved) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle_rounded, color: scheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
