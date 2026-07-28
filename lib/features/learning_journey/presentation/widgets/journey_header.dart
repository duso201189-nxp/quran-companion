import 'package:flutter/material.dart';

/// Khối mở đầu màn hình Learning Journey (Sprint 16 Phase 2 mục 3) —
/// thuần trình bày, KHÔNG đọc provider (nhận sẵn [title]/[dateLabel]/
/// [stepCountLabel] đã dịch từ nơi gọi) — cùng nguyên tắc
/// GoalCard/AchievementCard/TutorHeader.
class JourneyHeader extends StatelessWidget {
  const JourneyHeader({
    super.key,
    required this.title,
    required this.dateLabel,
    required this.stepCountLabel,
  });

  final String title;
  final String dateLabel;
  final String stepCountLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: '$title. $dateLabel. $stepCountLabel',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.map_rounded, color: scheme.onPrimaryContainer),
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
                      dateLabel,
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stepCountLabel,
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
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
