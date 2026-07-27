import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Thẻ huy hiệu 1 thành tựu (Sprint 14 Phase 2.2 mục 4) — thuần trình
/// bày, KHÔNG đọc provider (nhận sẵn [progress]/[isUnlocked] từ
/// Achievement ở nơi gọi). Kích thước cố định để xếp trong [Wrap] —
/// khác GoalCard (chiếm hết bề rộng hàng), huy hiệu cần cảm giác
/// "thẻ nhỏ" xếp cạnh nhau.
///
/// LƯU Ý quan trọng (công khai lại từ Achievement doc comment):
/// "unlocked" ở đây là ĐIỀU KIỆN HIỆN TẠI, không phải trạng thái lưu
/// vĩnh viễn — vd 1 thành tựu streak có thể hiện "mở khoá" hôm nay
/// rồi "khoá" lại ngày mai nếu chuỗi đứt, vì không có nơi lưu "đã
/// từng mở khoá".
class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.icon,
    required this.title,
    required this.progressText,
    required this.progress,
    required this.isUnlocked,
  });

  final IconData icon;
  final String title;
  final String progressText;

  /// 0.0-1.0 — nơi gọi tự kẹp giá trị (xem Achievement.progress).
  final double progress;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusText =
        isUnlocked ? l10n.achievementUnlocked : l10n.achievementLocked;
    final bg =
        isUnlocked ? scheme.tertiaryContainer : scheme.surfaceContainerLow;
    final fg =
        isUnlocked ? scheme.onTertiaryContainer : scheme.onSurfaceVariant;

    return Semantics(
      label: '$title: $statusText, $progressText',
      child: ExcludeSemantics(
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: fg, size: 22),
                  const Spacer(),
                  Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    color: fg,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700, color: fg),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: progress,
                  color: fg,
                  backgroundColor: fg.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                progressText,
                style: textTheme.labelSmall?.copyWith(color: fg),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
