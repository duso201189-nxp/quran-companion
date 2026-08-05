import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../data/daily_goal_providers.dart';
import 'daily_goal_dialog.dart';

/// Thẻ "Mục tiêu học" — CHỈ đọc từ [dailyGoalProgressProvider], không
/// tự tính gì ở tầng UI (DR-2026-0004 mục 2). Chạm để đặt/đổi chỉ
/// tiêu qua [DailyGoalDialog]. Ẩn khi provider chưa có dữ liệu, cùng
/// quy ước với `_TodaysVerseCard` (Trang chủ).
///
/// Sprint 6.3 — trước sprint này thẻ chỉ tồn tại (private) trên Trang
/// chủ; đưa ra widget dùng chung để đặt thêm ở màn Thống kê (xem
/// [DailyGoalCard] tại `stats_screen.dart`), nơi bình luận cũ trong
/// `profile_screen.dart` đã (sai) khẳng định widget này "đã có ở đó"
/// — Thống kê là nơi người dùng tự nhiên tìm tiến độ/chỉ tiêu, và đã
/// có sẵn `ActiveKhatmCard` cùng vị trí đó cho Khatm. KHÔNG có provider/
/// dialog/persistence nào mới — dùng lại nguyên `dailyGoalProgressProvider`
/// và `DailyGoalDialog` đã có, đúng MỘT nguồn sự thật cho cả hai màn
/// hình. Đọc `AppLocalizations.of(context)` thẳng (không nhận `l10n`
/// qua constructor) để nhúng được từ bất kỳ đâu bằng `const
/// DailyGoalCard()` — cùng quy ước [ActiveKhatmCard].
class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = ref.watch(dailyGoalProgressProvider);

    if (progress == null) return const SizedBox.shrink();

    final minutesTarget = progress.minutesTarget;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => DailyGoalDialog.show(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.flag_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileGoal,
                      style: textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      minutesTarget != null
                          ? l10n.dailyGoalMinutesProgress(
                              progress.minutesToday,
                              minutesTarget,
                            )
                          : l10n.dailyGoalNotSet,
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
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
