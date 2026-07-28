import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../search/presentation/widgets/search_error_state.dart';
import '../data/smart_learning_providers.dart';
import '../domain/entities/learning_recommendation.dart';
import '../domain/entities/smart_learning_session.dart';
import 'session_strategy_presentation.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/session_summary_card.dart';
import 'widgets/smart_learning_header.dart';

/// Màn hình Smart Learning (Sprint 17 Phase 2) — CHỈ tiêu thụ
/// smartLearningSessionProvider (smart_learning_providers.dart, Sprint
/// 17 Phase 1), KHÔNG bao giờ đọc SmartLearningRepository/
/// LearningJourneyRepository/AITutorRepository/AnalyticsRepository
/// trực tiếp — đúng yêu cầu "Do not access repositories directly from
/// UI."
///
/// CHỈ 1 provider cho TOÀN BỘ màn hình (cùng lý do
/// LearningJourneyScreen, Sprint 16 Phase 2): SmartLearningSession đã
/// gói SẴN mọi thứ cần hiển thị (đề xuất đã xếp hạng), nên chỉ cần 1
/// cổng loading/error DUY NHẤT.
///
/// KHÔNG tính toán/định dạng gì ngoài chuyển đổi hiển thị thuần tuý —
/// ánh xạ SessionStrategy sang icon/chuỗi qua
/// sessionStrategyPresentation (file riêng, dùng chung cho cả 2 khu
/// vực hiển thị bên dưới, không có bản sao) — mọi SỐ LIỆU (chiến
/// lược/thời lượng/số bước) đã tính sẵn ở tầng domain
/// (SmartLearningRepository -> LearningJourneyRepository ->
/// AITutorRepository -> AnalyticsRepository), màn hình chỉ trình bày
/// lại.
class SmartLearningScreen extends ConsumerWidget {
  const SmartLearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionAsync = ref.watch(smartLearningSessionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.smartLearningTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 900
                ? (constraints.maxWidth - 860) / 2
                : 16.0;
            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(smartLearningSessionProvider),
              child: ListView(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
                children: [
                  sessionAsync.when(
                    loading: () => LoadingState(
                      semanticsLabel: l10n.smartLearningLoading,
                    ),
                    error: (_, __) => SearchErrorState(
                      onRetry: () =>
                          ref.invalidate(smartLearningSessionProvider),
                    ),
                    data: (session) => _SmartLearningContent(session: session),
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

class _SmartLearningContent extends StatelessWidget {
  const _SmartLearningContent({required this.session});

  final SmartLearningSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recommendations = session.recommendations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartLearningHeader(
          title: l10n.smartLearningHeaderTitle,
          subtitle: l10n.smartLearningRecommendationCountLabel(
            recommendations.length,
          ),
        ),
        const SizedBox(height: 20),
        if (recommendations.isEmpty)
          EmptyStateBanner(text: l10n.smartLearningEmpty)
        else ...[
          Builder(
            builder: (context) {
              final top = recommendations.first;
              final p = sessionStrategyPresentation(l10n, top.strategy);
              return SessionSummaryCard(
                title: l10n.smartLearningRecommendedTitle,
                icon: p.icon,
                strategyLabel: p.label,
                estimatedTimeLabel:
                    l10n.statsTodayMinutes(top.estimatedMinutes),
                relatedStepsLabel: l10n.smartLearningRelatedStepsLabel(
                  top.relatedStepCount,
                ),
              );
            },
          ),
          if (recommendations.length > 1) ...[
            const SizedBox(height: 20),
            SectionHeader(text: l10n.smartLearningOtherRecommendationsTitle),
            const SizedBox(height: 12),
            for (final r in recommendations.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OtherRecommendation(recommendation: r),
              ),
          ],
        ],
      ],
    );
  }
}

class _OtherRecommendation extends StatelessWidget {
  const _OtherRecommendation({required this.recommendation});

  final LearningRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = sessionStrategyPresentation(l10n, recommendation.strategy);
    return RecommendationCard(
      icon: p.icon,
      strategyLabel: p.label,
      estimatedTimeLabel:
          l10n.statsTodayMinutes(recommendation.estimatedMinutes),
      relatedStepsLabel:
          l10n.smartLearningRelatedStepsLabel(recommendation.relatedStepCount),
    );
  }
}
