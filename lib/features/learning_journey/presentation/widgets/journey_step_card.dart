import 'package:flutter/material.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../ai_tutor/presentation/widgets/tutor_suggestion_card.dart';

/// Thẻ 1 bước trong Learning Journey (Sprint 16 Phase 2 mục 3) —
/// KHÔNG vẽ lại nội dung gợi ý từ đầu: BỌC [TutorSuggestionCard] đã
/// có (Sprint 15) bằng 1 huy hiệu số thứ tự, TÁI SỬ DỤNG toàn bộ giao
/// diện/khả năng truy cập của nó (kể cả nút hành động) thay vì tạo
/// bản sao — đúng tinh thần "No duplicated navigation logic"/"reuse"
/// xuyên suốt dự án. Thuần trình bày, KHÔNG đọc provider.
class JourneyStepCard extends StatelessWidget {
  const JourneyStepCard({
    super.key,
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.detail,
    required this.priorityLabel,
    required this.isUrgent,
    this.actionLabel,
    this.onAction,
  });

  /// 1-based (bước 1, 2, 3...) — chỉ dùng để hiển thị, KHÔNG phải
  /// JourneyStep.order (0-based, xem doc comment JourneyStep).
  final int stepNumber;

  final IconData icon;
  final String title;
  final String detail;
  final String priorityLabel;
  final bool isUrgent;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepBadge(number: stepNumber),
        const SizedBox(width: 10),
        Expanded(
          child: TutorSuggestionCard(
            icon: icon,
            title: title,
            detail: detail,
            priorityLabel: priorityLabel,
            isUrgent: isUrgent,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Semantics(
        label: AppLocalizations.of(context).journeyStepNumber(number),
        child: ExcludeSemantics(
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
