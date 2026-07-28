import 'package:flutter/material.dart';

/// Khối tổng quan mở đầu màn hình AI Tutor (Sprint 15 Phase 2 mục 3)
/// — thuần trình bày, KHÔNG đọc provider (nhận sẵn [title] + [stats]
/// từ nơi gọi, cùng nguyên tắc với GoalCard/AchievementCard — Sprint
/// 14 Phase 2.2). [stats] là các giá trị ĐÃ ĐỊNH DẠNG sẵn (vd
/// "42"/"75%"/"5 days") lấy từ TutorContext.statistics, KHÔNG tính
/// toán gì mới ở đây.
///
/// Sprint 20 Phase 2, Task 3 — mục thống kê bên trong (dòng dưới) CỐ Ý
/// KHÔNG dùng chung `StatCard` (`lib/shared/widgets/stat_card.dart`):
/// bố cục Row icon-CẠNH-text (không phải Column icon-TRÊN-text như
/// `StatCard`), luôn nằm lồng trong 1 `Row` chia đều nhiều mục (dùng
/// `Expanded`, không phải thẻ độc lập có nền/bo góc riêng), và luôn
/// dùng `onPrimaryContainer` cố định (không có khái niệm accented/
/// không-accented). Gộp cưỡng ép sẽ đổi 1 trong các đặc điểm đó, vi
/// phạm "Preserve existing UI" — xem accessibility_audit.md mục
/// "StatCard" để biết lý do đầy đủ + so sánh với `TutorInsightCard`
/// (TRÙNG hoàn toàn với `StatCard`, đã gộp).
class TutorHeader extends StatelessWidget {
  const TutorHeader({
    super.key,
    required this.title,
    required this.stats,
  });

  final String title;
  final List<({IconData icon, String value, String label})> stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final s in stats) ...[
                if (s != stats.first) const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    label: '${s.label}: ${s.value}',
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            s.icon,
                            size: 18,
                            color: scheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.value,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            s.label,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
