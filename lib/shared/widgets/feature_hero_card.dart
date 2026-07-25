import 'package:flutter/material.dart';

/// Khung "thẻ hero" dùng chung (Sprint 21.4 Phase A, mục A1) — trước
/// đây bị viết tay lại y hệt ở 4 nơi: `TutorHeader`, `JourneyHeader`,
/// `SmartLearningHeader`, `SessionSummaryCard` (đã xác nhận
/// byte-identical qua `design_system_consolidation_plan.md` mục A1:
/// `Container(padding: all(20), decoration: BoxDecoration(color:
/// scheme.primaryContainer, borderRadius: circular(16)))`).
///
/// CHỈ bọc phần khung NGOÀI (decoration/padding) — Semantics (nếu có)
/// và nội dung BÊN TRONG vẫn do nơi gọi tự quyết định, không đổi.
class FeatureHeroCard extends StatelessWidget {
  const FeatureHeroCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
