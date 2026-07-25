import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_hero_card.dart';

/// Sprint 21.4 Phase A, mục A1 — khung NGOÀI chuyển sang dùng chung
/// `FeatureHeroCard` (xác nhận byte-identical với TutorHeader/
/// JourneyHeader/SmartLearningHeader). Semantics bọc ngoài + nội dung
/// BÊN TRONG không đổi.
///
/// Thẻ nổi bật cho "Recommended session" (Sprint 17 Phase 2 mục 2/3)
/// — hiển thị ĐÚNG 3 thứ yêu cầu: chiến lược, thời lượng ước lượng,
/// số bước liên quan — đọc thẳng từ LearningRecommendation
/// (SmartLearningRepository, Sprint 17 Phase 1), KHÔNG tính toán gì
/// mới. Thuần trình bày, KHÔNG đọc provider. Dùng primaryContainer
/// (giống SmartLearningHeader) để nổi bật hơn RecommendationCard
/// (trung tính) — đúng vai trò "đề xuất chính, hãy bắt đầu ngay".
class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.strategyLabel,
    required this.estimatedTimeLabel,
    required this.relatedStepsLabel,
  });

  final String title;
  final IconData icon;
  final String strategyLabel;
  final String estimatedTimeLabel;
  final String relatedStepsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$title: $strategyLabel. $estimatedTimeLabel. $relatedStepsLabel',
      child: ExcludeSemantics(
        child: FeatureHeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelLarge
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(icon, size: 28, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strategyLabel,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _Stat(
                    icon: Icons.schedule_rounded,
                    label: estimatedTimeLabel,
                  ),
                  _Stat(
                    icon: Icons.checklist_rounded,
                    label: relatedStepsLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: scheme.onPrimaryContainer),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
