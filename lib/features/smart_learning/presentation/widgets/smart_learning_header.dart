import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_hero_card.dart';

/// Khối mở đầu màn hình Smart Learning (Sprint 17 Phase 2 mục 3) —
/// thuần trình bày, KHÔNG đọc provider (nhận sẵn [title]/[subtitle]
/// đã dịch từ nơi gọi) — cùng nguyên tắc JourneyHeader/TutorHeader.
///
/// Sprint 21.4 Phase A, mục A1 — khung NGOÀI chuyển sang dùng chung
/// `FeatureHeroCard` (xác nhận byte-identical với TutorHeader/
/// JourneyHeader/SessionSummaryCard). Semantics bọc ngoài + nội dung
/// BÊN TRONG không đổi.
class SmartLearningHeader extends StatelessWidget {
  const SmartLearningHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$title. $subtitle',
      child: ExcludeSemantics(
        child: FeatureHeroCard(
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: scheme.onPrimaryContainer),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
