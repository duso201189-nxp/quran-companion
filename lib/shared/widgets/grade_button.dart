import 'package:flutter/material.dart';

/// Nút chấm điểm SM-2 dùng chung (Sprint 21.4 Phase A, mục A4) —
/// trước đây bị viết tay lại y hệt ở 2 nơi: `FlashcardReviewScreen`,
/// `ReviewSessionScreen` (đã xác nhận byte-identical qua
/// `design_system_consolidation_plan.md` mục A4:
/// `FilledButton.tonal(backgroundColor: color.withValues(alpha:0.15),
/// foregroundColor: color, padding: symmetric(vertical:14))`).
class GradeButton extends StatelessWidget {
  const GradeButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
