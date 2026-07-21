import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../ai_tutor/domain/entities/tutor_suggestion.dart';
import '../../ai_tutor/presentation/tutor_action_navigator.dart';
import '../../ai_tutor/presentation/tutor_presentation.dart';
import '../../search/presentation/widgets/search_error_state.dart';
import '../data/learning_journey_providers.dart';
import '../domain/entities/learning_journey.dart';
import 'widgets/journey_header.dart';
import 'widgets/journey_progress_card.dart';
import 'widgets/journey_step_card.dart';

/// Màn hình Learning Journey (Sprint 16 Phase 2) — CHỈ tiêu thụ
/// learningJourneyProvider (learning_journey_providers.dart, Sprint 16
/// Phase 1), KHÔNG bao giờ đọc AITutorRepository/AnalyticsRepository/
/// SchedulerRepository/FlashcardRepository trực tiếp — đúng yêu cầu
/// "Do not access repositories directly from UI."
///
/// CHỈ 1 provider (learningJourneyProvider) cho CẢ 3 khu vực hiển thị
/// (Header/Progress/Steps) — khác ProgressDashboardScreen/TutorHomeScreen
/// (nhiều provider độc lập, mỗi khu vực tự loading/error riêng): ở
/// đây LearningJourney đã gói SẴN context+plan+insights thành 1 đối
/// tượng (Sprint 16 Phase 1), nên chỉ cần 1 cổng loading/error DUY
/// NHẤT — tự nhiên tránh hẳn rủi ro gọi lặp cùng 1 provider (Riverpod
/// vẫn dedupe nếu gọi từ nhiều widget, nhưng 1 cổng duy nhất đơn giản
/// hơn và đúng bản chất dữ liệu đã gộp sẵn).
///
/// KHÔNG tính toán/định dạng gì ngoài chuyển đổi hiển thị thuần tuý —
/// TÁI SỬ DỤNG NGUYÊN VẸN suggestionPresentation/insightPresentation/
/// executeTutorAction từ ai_tutor/presentation (Sprint 16 Phase 2,
/// tách ra từ TutorHomeScreen), KHÔNG có bản sao logic ánh xạ/điều
/// hướng riêng nào ở đây.
class LearningJourneyScreen extends ConsumerWidget {
  const LearningJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final journeyAsync = ref.watch(learningJourneyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.learningJourneyTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 900
                ? (constraints.maxWidth - 860) / 2
                : 16.0;
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(learningJourneyProvider),
              child: ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
                children: [
                  journeyAsync.when(
                    loading: () => LoadingState(
                      semanticsLabel: l10n.learningJourneyLoading,
                    ),
                    error: (_, __) => SearchErrorState(
                      onRetry: () => ref.invalidate(learningJourneyProvider),
                    ),
                    data: (journey) => _JourneyContent(journey: journey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _JourneyContent extends StatelessWidget {
  const _JourneyContent({required this.journey});

  final LearningJourney journey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final plan = journey.todayPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneyHeader(
          title: l10n.journeyHeaderTitle,
          dateLabel: DateFormat.yMMMMd(locale).format(plan.date),
          stepCountLabel: l10n.journeyStepCountLabel(plan.steps.length),
        ),
        const SizedBox(height: 20),
        const _SmartLearningEntryCard(),
        const SizedBox(height: 20),
        JourneyProgressCard(
          title: l10n.journeyProgressTitle,
          stats: [
            for (final insight in journey.insights)
              insightPresentation(l10n, insight),
          ],
        ),
        const SizedBox(height: 20),
        SectionHeader(text: l10n.journeyStepsTitle),
        const SizedBox(height: 12),
        if (plan.steps.isEmpty)
          EmptyStateBanner(text: l10n.learningJourneyEmpty)
        else
          for (final step in plan.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Builder(
                builder: (context) {
                  final p = suggestionPresentation(l10n, step.suggestion);
                  final action = step.suggestion.action;
                  return JourneyStepCard(
                    stepNumber: step.order + 1,
                    icon: p.icon,
                    title: p.title,
                    detail: p.detail,
                    priorityLabel: suggestionPriorityLabel(
                      l10n,
                      step.suggestion.priority,
                    ),
                    isUrgent: step.suggestion.priority ==
                        TutorSuggestionPriority.high,
                    actionLabel: action == null
                        ? null
                        : suggestionActionLabel(l10n, action.destination),
                    onAction: action == null
                        ? null
                        : () => executeTutorAction(context, action),
                  );
                },
              ),
            ),
      ],
    );
  }
}

/// Lối vào Smart Learning (Sprint 17 Phase 2 mục 5) — banner CTA
/// tĩnh, KHÔNG đọc provider nào, chỉ push route — cùng mẫu
/// TutorHomeScreen._JourneyEntryCard (Sprint 16 Phase 2), không phát
/// minh kiểu điều hướng mới.
class _SmartLearningEntryCard extends StatelessWidget {
  const _SmartLearningEntryCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: scheme.secondaryContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(AppRoutes.smartLearning),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: scheme.onSecondaryContainer),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.journeyEntrySmartLearningTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.journeyEntrySmartLearningDesc,
                      style: textTheme.bodySmall
                          ?.copyWith(color: scheme.onSecondaryContainer),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
