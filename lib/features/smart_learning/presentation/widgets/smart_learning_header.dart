import 'package:flutter/material.dart';

/// Khối mở đầu màn hình Smart Learning (Sprint 17 Phase 2 mục 3) —
/// thuần trình bày, KHÔNG đọc provider (nhận sẵn [title]/[subtitle]
/// đã dịch từ nơi gọi) — cùng nguyên tắc JourneyHeader/TutorHeader.
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
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
