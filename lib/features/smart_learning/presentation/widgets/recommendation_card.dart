import 'package:flutter/material.dart';

/// Thẻ 1 đề xuất (không phải đề xuất chính) trong Smart Learning
/// (Sprint 17 Phase 2 mục 3) — thuần trình bày, KHÔNG đọc provider,
/// đọc thẳng từ LearningRecommendation. Trung tính (surfaceContainerLow)
/// — khác SessionSummaryCard (primaryContainer, dành cho đề xuất
/// CHÍNH) — cùng phân cấp thị giác "chính/phụ" đã dùng ở
/// TutorHeader+_MetricCard/JourneyHeader+JourneyProgressCard.
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.icon,
    required this.strategyLabel,
    required this.estimatedTimeLabel,
    required this.relatedStepsLabel,
  });

  final IconData icon;
  final String strategyLabel;
  final String estimatedTimeLabel;
  final String relatedStepsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$strategyLabel. $estimatedTimeLabel. $relatedStepsLabel',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategyLabel,
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$estimatedTimeLabel · $relatedStepsLabel',
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
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
