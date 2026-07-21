import 'package:flutter/material.dart';

/// Thẻ 1 gợi ý AI Tutor (Sprint 15 Phase 2 mục 3, thêm hành động điều
/// hướng ở Phase 3 mục 1) — thuần trình bày, KHÔNG đọc provider/biết
/// gì về TutorSuggestionKind/TutorAction (nhận sẵn icon + chuỗi đã
/// dịch + callback từ nơi gọi) — cùng nguyên tắc GoalCard/AchievementCard.
///
/// [onAction]/[actionLabel] TUỲ CHỌN — null nghĩa là gợi ý này không
/// có hành động điều hướng nào (vd maintainStreak, chỉ mang tính
/// khích lệ). "Trạng thái vô hiệu" (Phase 3 mục 5, yêu cầu test) nghĩa
/// là KHÔNG hiện nút hành động nào — không phải 1 nút mờ vô dụng
/// (dead affordance), cùng nguyên tắc UI hiện có: chỉ hiện điều khiển
/// khi nó thật sự làm được gì (vd AchievementCard không hiện nút bấm
/// khi khoá).
class TutorSuggestionCard extends StatelessWidget {
  const TutorSuggestionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.priorityLabel,
    required this.isUrgent,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String priorityLabel;

  /// true cho gợi ý mức "high" — chỉ đổi màu icon/badge, KHÔNG đổi bố
  /// cục, tránh phân cấp thị giác quá mạnh cho 1 gợi ý so với các
  /// gợi ý khác.
  final bool isUrgent;

  /// Nhãn nút hành động (vd "Review now") — chỉ hiện khi CẢ
  /// [actionLabel] LẪN [onAction] đều khác null.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = isUrgent ? scheme.error : scheme.primary;
    final hasAction = actionLabel != null && onAction != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần thông tin gộp thành MỘT nhãn accessibility duy nhất
          // (không đổi so với Phase 2) — nút hành động (nếu có) nằm
          // NGOÀI ExcludeSemantics bên dưới, để trình đọc màn hình vẫn
          // tiếp cận/kích hoạt được nó như 1 nút bấm độc lập, thay vì
          // bị nuốt chung vào 1 nhãn tĩnh không bấm được.
          Semantics(
            label: '$title. $detail. $priorityLabel',
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            priorityLabel,
                            style:
                                textTheme.labelSmall?.copyWith(color: accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasAction) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
