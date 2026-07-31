import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../search/presentation/widgets/search_error_state.dart';
import '../data/ai_tutor_providers.dart';
import '../domain/entities/tutor_suggestion.dart';
import 'tutor_action_navigator.dart';
import 'tutor_presentation.dart';
import 'widgets/tutor_header.dart';
import 'widgets/tutor_insight_card.dart';
import 'widgets/tutor_suggestion_card.dart';

/// Màn hình chính AI Tutor (Sprint 15 Phase 2, thêm hành động điều
/// hướng ở Phase 3 mục 4, thêm lối vào Learning Journey ở Sprint 16
/// Phase 2 mục 5) — CHỈ tiêu thụ aiTutorProviders
/// (tutorContextProvider/tutorSuggestionsProvider/tutorInsightsProvider
/// — Sprint 15 Phase 1), KHÔNG bao giờ đọc
/// analyticsRepositoryProvider/AnalyticsRepository/SchedulerRepository/
/// FlashcardRepository/LearningJourneyRepository trực tiếp — đúng yêu
/// cầu "Do not access AnalyticsRepository directly from UI. Only
/// consume AITutorRepository providers." / "No direct repository
/// access." (Learning Journey nhận đường dẫn qua router, KHÔNG qua
/// provider của nó ở màn hình này).
///
/// KHÔNG tính toán/định dạng gì ngoài chuyển đổi kiểu hiển thị thuần
/// tuý (vd '${(value*100).round()}%', ánh xạ TutorSuggestionKind/
/// TutorInsightKind sang icon+chuỗi l10n) — cùng kỷ luật với
/// ProgressDashboardScreen (Sprint 14): mọi SỐ LIỆU đã tính sẵn ở
/// tầng domain (AITutorRepository -> AnalyticsRepository), màn hình
/// chỉ trình bày lại.
///
/// Ánh xạ icon/chuỗi (suggestionPresentation/insightPresentation) và
/// thực thi điều hướng (executeTutorAction) đã CHUYỂN sang
/// tutor_presentation.dart/tutor_action_navigator.dart (Sprint 16
/// Phase 2) — LearningJourneyScreen (màn hình mới, Sprint 16 Phase 2)
/// dùng LẠI đúng các hàm này, KHÔNG có bản sao riêng.
class TutorHomeScreen extends ConsumerWidget {
  const TutorHomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(tutorContextProvider);
    ref.invalidate(tutorSuggestionsProvider);
    ref.invalidate(tutorInsightsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiTutorTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 900
                ? (constraints.maxWidth - 860) / 2
                : 16.0;
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
                children: const [
                  _TutorSummarySection(),
                  SizedBox(height: 20),
                  _JourneyEntryCard(),
                  SizedBox(height: 20),
                  _TutorSuggestionsSection(),
                  SizedBox(height: 20),
                  _TutorInsightsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TutorSummarySection extends ConsumerWidget {
  const _TutorSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final contextAsync = ref.watch(tutorContextProvider);

    return contextAsync.when(
      loading: () => LoadingState(semanticsLabel: l10n.aiTutorLoading),
      error: (_, __) =>
          SearchErrorState(onRetry: () => ref.invalidate(tutorContextProvider)),
      data: (tutorContext) {
        final stats = tutorContext.statistics;
        return TutorHeader(
          title: l10n.aiTutorSummaryTitle,
          stats: [
            (
              icon: Icons.style_rounded,
              value: '${stats.cardsStudied}',
              label: l10n.statCardsStudied,
            ),
            (
              icon: Icons.track_changes_rounded,
              value: '${(stats.accuracy * 100).round()}%',
              label: l10n.statAccuracy,
            ),
            (
              icon: Icons.local_fire_department_rounded,
              value: l10n.streakDays(stats.readingStreakDays),
              label: l10n.statsCurrentStreak,
            ),
          ],
        );
      },
    );
  }
}

/// Lối vào Learning Journey (Sprint 16 Phase 2 mục 5) — banner CTA
/// tĩnh, KHÔNG đọc provider nào (không cần dữ liệu để hiển thị lời
/// mời bấm), chỉ push route — cùng mẫu "thẻ CTA" đã có (vd
/// _StudyToolCard trong StudyScreen), không phát minh kiểu điều hướng
/// mới.
class _JourneyEntryCard extends StatelessWidget {
  const _JourneyEntryCard();

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
        onTap: () => context.push(AppRoutes.learningJourney),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.map_rounded, color: scheme.onSecondaryContainer),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiTutorJourneyEntryTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.aiTutorJourneyEntryDesc,
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

class _TutorSuggestionsSection extends ConsumerWidget {
  const _TutorSuggestionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final suggestionsAsync = ref.watch(tutorSuggestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(text: l10n.aiTutorSuggestionsTitle),
        const SizedBox(height: 12),
        suggestionsAsync.when(
          loading: () => LoadingState(semanticsLabel: l10n.aiTutorLoading),
          error: (_, __) => SearchErrorState(
            onRetry: () => ref.invalidate(tutorSuggestionsProvider),
          ),
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return EmptyStateBanner(text: l10n.aiTutorSuggestionsEmpty);
            }
            return Column(
              children: [
                for (final s in suggestions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Builder(
                      builder: (context) {
                        final p = suggestionPresentation(l10n, s);
                        final action = s.action;
                        return TutorSuggestionCard(
                          icon: p.icon,
                          title: p.title,
                          detail: p.detail,
                          priorityLabel: suggestionPriorityLabel(
                            l10n,
                            s.priority,
                          ),
                          isUrgent: s.priority == TutorSuggestionPriority.high,
                          actionLabel: action == null
                              ? null
                              : suggestionActionLabel(
                                  l10n,
                                  action.destination,
                                ),
                          onAction: action == null
                              ? null
                              : () => executeTutorAction(context, action),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TutorInsightsSection extends ConsumerWidget {
  const _TutorInsightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final insightsAsync = ref.watch(tutorInsightsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(text: l10n.aiTutorInsightsTitle),
        const SizedBox(height: 12),
        insightsAsync.when(
          loading: () => LoadingState(semanticsLabel: l10n.aiTutorLoading),
          error: (_, __) => SearchErrorState(
            onRetry: () => ref.invalidate(tutorInsightsProvider),
          ),
          data: (insights) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 560 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    for (final i in insights)
                      Builder(
                        builder: (context) {
                          final p = insightPresentation(l10n, i);
                          return TutorInsightCard(
                            icon: p.icon,
                            label: p.label,
                            value: p.value,
                          );
                        },
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
