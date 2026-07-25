import 'package:flutter/material.dart';

/// Thẻ "điều hướng chéo tính năng" dùng chung (Sprint 21.4 Phase A,
/// mục A2) — trước đây bị viết tay lại y hệt ở 2 nơi:
/// `TutorHomeScreen._JourneyEntryCard`,
/// `LearningJourneyScreen._SmartLearningEntryCard` (đã xác nhận
/// byte-identical qua `design_system_consolidation_plan.md` mục A2:
/// `Material(color: scheme.secondaryContainer.withValues(alpha:0.6),
/// borderRadius: circular(16), child: InkWell(borderRadius:
/// circular(16), onTap:, child: Padding(padding: all(16), child:)))`.
class CrossFeatureEntryCard extends StatelessWidget {
  const CrossFeatureEntryCard({
    super.key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.secondaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
