import 'package:flutter/material.dart';

/// Thẻ 1 chỉ số: icon phía trên, giá trị lớn, nhãn caption bên dưới
/// (Sprint 20 Phase 2, Task 3) — trích ra sau khi đối chiếu TỪNG DÒNG
/// `progress_dashboard_screen.dart`'s `_MetricCard` (accented: false)
/// với `tutor_insight_card.dart`'s `TutorInsightCard`: xác nhận 2 cây
/// widget GIỐNG HỆT nhau (cùng padding 14, cùng bo góc 16, cùng
/// `Icon(size: 22)`, cùng `FittedBox(Text(value, titleLarge+w700))`,
/// cùng `Text(label, labelSmall, onSurfaceVariant)`, cùng
/// `Semantics(label: '$label: $value') + ExcludeSemantics`) — không
/// suy đoán từ tên, đã đọc trực tiếp cả 2 file (xem
/// accessibility_audit.md mục "StatCard").
///
/// [accented] tái tạo ĐÚNG nhánh `_MetricCard(accented: true)` (nền
/// `primaryContainer` thay vì `surfaceContainerLow`, dùng cho 1 nhóm
/// chỉ số muốn nổi bật hơn — xem `progress_dashboard_screen.dart`'s
/// `highlights` list).
///
/// KHÔNG gộp thêm `_AccuracyMetricCard` (vòng tròn tiến độ,
/// `progress_dashboard_screen.dart`), `TutorHeader`'s mục thống kê
/// (Row icon-CẠNH-text, lồng trong 1 Row nhiều mục chia đều), hay
/// `JourneyProgressCard`'s mục thống kê (Row icon-CẠNH-text, chiều
/// rộng cố định 132, lồng trong `Wrap`) — cả 3 có BỐ CỤC khác thật sự
/// (Row vs Column, có vòng tròn vs không), không phải chỉ khác màu —
/// gộp cưỡng ép sẽ phải hy sinh 1 trong các hình dạng đó, vi phạm
/// "Preserve existing UI". Xem accessibility_audit.md mục "StatCard"
/// để biết lý do đầy đủ.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accented = false,
  });

  final IconData icon;
  final String value;
  final String label;

  /// Nền `primaryContainer` (nổi bật) thay vì `surfaceContainerLow`
  /// (trung tính) — xem doc comment lớp này.
  final bool accented;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bg = accented ? scheme.primaryContainer : scheme.surfaceContainerLow;
    final fg = accented ? scheme.onPrimaryContainer : scheme.primary;
    final textColor = accented ? scheme.onPrimaryContainer : null;

    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: textColor ?? scheme.onSurfaceVariant,
                ),
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
