import 'package:flutter/material.dart';

/// Thẻ tóm tắt nhận định AI Tutor dưới góc nhìn "tiến độ" (Sprint 16
/// Phase 2 mục 3) — thuần trình bày, KHÔNG đọc provider (nhận sẵn
/// [title] + [stats] đã định dạng từ nơi gọi, TÁI SỬ DỤNG NGUYÊN VẸN
/// giá trị TutorInsight của AI Tutor — Sprint 15, KHÔNG tính lại số
/// liệu nào). Khác TutorHeader (primaryContainer, đóng vai trò "hero"
/// mở đầu) — thẻ này dùng surfaceContainerLow trung tính, đóng vai
/// trò "chi tiết" bên dưới JourneyHeader.
///
/// Sprint 20 Phase 2, Task 3 — mục thống kê bên trong (`Wrap` con) CỐ
/// Ý KHÔNG dùng chung `StatCard` (`lib/shared/widgets/stat_card.dart`):
/// bố cục Row icon-CẠNH-text chiều rộng CỐ ĐỊNH 132 (không phải Column
/// icon-TRÊN-text co giãn theo `FittedBox` như `StatCard`), không có
/// nền/bo góc riêng cho từng mục (cả nhóm dùng chung 1 khung ngoài).
/// Cùng lý do đã ghi ở `TutorHeader` — xem accessibility_audit.md mục
/// "StatCard".
class JourneyProgressCard extends StatelessWidget {
  const JourneyProgressCard({
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              for (final s in stats)
                Semantics(
                  label: '${s.label}: ${s.value}',
                  child: ExcludeSemantics(
                    child: SizedBox(
                      width: 132,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 18, color: scheme.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.value,
                                  style: textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  s.label,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
