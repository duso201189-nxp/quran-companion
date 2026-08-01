import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../ai_tutor/domain/entities/tutor_insight.dart';
import '../../ai_tutor/domain/entities/tutor_suggestion.dart';
import '../../ai_tutor/presentation/tutor_presentation.dart';
import '../../ai_tutor/presentation/widgets/tutor_header.dart';
import '../../ai_tutor/presentation/widgets/tutor_insight_card.dart';
import '../../learning_journey/domain/entities/journey_step.dart';
import '../../learning_journey/presentation/widgets/journey_step_card.dart';
import '../../search/presentation/widgets/search_error_state.dart';
import '../../smart_learning/data/smart_learning_providers.dart';
import '../../smart_learning/domain/entities/learning_recommendation.dart';
import '../../smart_learning/presentation/session_strategy_presentation.dart';
import '../../smart_learning/presentation/widgets/recommendation_card.dart';
import '../../smart_learning/presentation/widgets/session_summary_card.dart';
import '../data/learning_snapshot_providers.dart';
import '../domain/entities/learning_snapshot.dart';

/// Màn hình Study Summary (Read Model, Sprint R2.1 — nền tảng; Sprint
/// R2.2 — vẽ nội dung thật) — CHỈ tiêu thụ [learningSnapshotProvider]
/// đã có sẵn (`read_model/data/learning_snapshot_providers.dart`,
/// Sprint 18 Phase 2), KHÔNG tạo provider mới, KHÔNG gọi
/// `LearningSnapshotRepository`/`SmartLearningRepository` trực tiếp —
/// đúng nguyên tắc "Do not access repositories directly from UI" đã
/// áp dụng cho mọi màn hình tầng trên (`TutorHomeScreen`/
/// `LearningJourneyScreen`/`SmartLearningScreen`).
///
/// KHÔNG "bypass" SmartLearningSession: [learningSnapshotProvider]
/// vẫn tính `LearningSnapshot` TỪ một `SmartLearningSession` thật
/// (qua `computeLearningSnapshot`) — nó chỉ tái dùng bản
/// `SmartLearningSession` ĐÃ CÓ SẴN (nếu `smartLearningSessionProvider`
/// đang được giữ sống bởi nơi khác) thay vì luôn kích hoạt 1 lượt gọi
/// `SmartLearningRepository.getSmartLearningSession()` MỚI — dữ liệu
/// vẫn luôn đi qua `SmartLearningSession`, không có đường tắt nào đọc
/// thẳng AITutor/LearningJourney/Analytics. Xem
/// `docs/release/PHASE3_SPRINT_R2_DESIGN_REVIEW.md` mục "Provider
/// Flow"/"Refresh Strategy" cho phân tích đầy đủ.
///
/// **Sprint R2.2**: `data` giờ vẽ ĐỦ 4 phần của `LearningSnapshot`
/// (context/insights/dailyPlan/smartSession), mỗi phần TÁI SỬ DỤNG
/// NGUYÊN VẸN đúng widget + hàm ánh xạ trình bày mà tầng gốc của phần
/// đó đã dùng — KHÔNG tính lại/định dạng lại số liệu nào (xem
/// `_StudySummaryContent`). KHÔNG có nút hành động nào được nối
/// (`JourneyStepCard.onAction`/tương đương) — mọi thẻ ở màn này CHỈ
/// TRÌNH BÀY, đúng phạm vi "vẽ nội dung", không phải "thêm tương
/// tác" — nhất quán với `SessionSummaryCard`/`RecommendationCard`
/// (SmartLearningScreen) vốn CŨNG không có hành động nào để bắt đầu.
///
/// **Sprint R2.3**: pull-to-refresh (`RefreshIndicator`) và nút "Thử
/// lại" (`SearchErrorState.onRetry`) đều gọi ĐÚNG MỘT lệnh:
/// `ref.invalidate(smartLearningSessionProvider)` — KHÔNG BAO GIỜ
/// invalidate [learningSnapshotProvider] trực tiếp. Lý do (xem
/// `PHASE3_SPRINT_R2_DESIGN_REVIEW.md` mục "Refresh Strategy"):
/// invalidate chỉ lan truyền THEO CHIỀU TỚI (từ dependency ra
/// dependent), không lan ngược. [learningSnapshotProvider] là bên
/// `watch(smartLearningSessionProvider.future)` (dependent) —
/// invalidate chính nó chỉ xoá cache của chính nó rồi đọc lại
/// `smartLearningSessionProvider` VẪN ĐANG CÒN CACHE cũ, không tạo
/// lượt gọi `SmartLearningRepository.getSmartLearningSession()` mới
/// nào — trả về đúng dữ liệu cũ, sai mục đích "làm mới". Invalidate
/// `smartLearningSessionProvider` (dependency) mới thật sự kích hoạt
/// lượt gọi mới VÀ tự động lan tới [learningSnapshotProvider] đang
/// watch nó — đúng 1 điểm invalidate duy nhất cho toàn chuỗi, khớp
/// mẫu `SmartLearningScreen` đã dùng sẵn.
///
/// **Sprint R3.1**: đã có lối vào — `SmartLearningScreen._StudySummaryEntryCard`
/// push tới `AppRoutes.studySummary`, nối mắt xích cuối của chuỗi
/// TutorHome -> LearningJourney -> SmartLearning -> StudySummary.
/// Trước sprint đó, route tồn tại nhưng KHÔNG có CTA nào trỏ tới.
class StudySummaryScreen extends ConsumerWidget {
  const StudySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshotAsync = ref.watch(learningSnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studySummaryTitle)),
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
                  snapshotAsync.when(
                    loading: () => LoadingState(
                      semanticsLabel: l10n.studySummaryLoading,
                    ),
                    error: (error, stackTrace) => SearchErrorState(
                      onRetry: () =>
                          ref.invalidate(smartLearningSessionProvider),
                    ),
                    data: (snapshot) {
                      final isEmpty = snapshot.insights.isEmpty &&
                          snapshot.dailyPlan.steps.isEmpty &&
                          snapshot.smartSession.recommendations.isEmpty;
                      if (isEmpty) {
                        return EmptyStateBanner(text: l10n.studySummaryEmpty);
                      }
                      return _StudySummaryContent(snapshot: snapshot);
                    },
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

/// Vẽ ĐỦ 4 phần của [LearningSnapshot] — mỗi phần đúng 1 khối, theo
/// ĐÚNG thứ tự trường đã khai báo trong `learning_snapshot.dart`
/// (context -> insights -> dailyPlan -> smartSession). KHÔNG có
/// `JourneyHeader`/`SmartLearningHeader` riêng (sẽ trùng lặp với
/// [SectionHeader] của từng khối + tiêu đề màn hình đã có) — chỉ giữ
/// [TutorHeader] vì nó mang SỐ LIỆU thật (cardsStudied/accuracy/streak),
/// không phải khối tiêu đề thuần trang trí.
///
/// **Sprint R2.3**: 4 hàm `_build*Card` thay cho `Builder(builder:
/// (context) {...})` mà R2.2 dùng cho từng thẻ — `Builder` chỉ có ý
/// nghĩa khi cần một `BuildContext` MỚI nằm dưới 1 `InheritedWidget`
/// vừa được chèn phía trên nó; không hàm trình bày nào ở đây
/// (`insightPresentation`/`suggestionPresentation`/
/// `sessionStrategyPresentation`) đọc `BuildContext` — chúng chỉ nhận
/// [AppLocalizations] (đã lấy 1 lần ở đầu `build`) và đối tượng domain
/// tương ứng. Giữ `Builder` do đó chỉ tạo thêm 1 `Element` vô ích cho
/// mỗi thẻ mà không đổi được gì — loại bỏ vừa giảm lặp lại cùng 1 khuôn
/// mẫu không cần thiết 4 lần (mục 5 Sprint R2.3), vừa bớt vài `Element`
/// không cần rebuild trong cây (mục 6).
class _StudySummaryContent extends StatelessWidget {
  const _StudySummaryContent({required this.snapshot});

  final LearningSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = snapshot.context.statistics;
    final recommendations = snapshot.smartSession.recommendations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1) context — ĐÚNG 3 chỉ số TutorHomeScreen._TutorSummarySection
        // đã dùng, không tính thêm chỉ số nào.
        TutorHeader(
          title: l10n.studySummaryContextTitle,
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
        ),
        const SizedBox(height: 20),

        // 2) insights — ĐÚNG lưới TutorHomeScreen._TutorInsightsSection
        // đã dùng (kể cả việc KHÔNG có Empty State riêng khi rỗng —
        // TutorHomeScreen cũng không có, giữ đúng tiền lệ).
        SectionHeader(text: l10n.studySummaryInsightsTitle),
        const SizedBox(height: 12),
        LayoutBuilder(
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
                for (final insight in snapshot.insights)
                  _buildInsightCard(l10n, insight),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // 3) dailyPlan — ĐÚNG danh sách LearningJourneyScreen._JourneyContent
        // đã dùng, KHÔNG có JourneyHeader/JourneyProgressCard (trùng
        // lặp SectionHeader + khối insights ở trên), KHÔNG nối
        // actionLabel/onAction (màn này chỉ trình bày, xem doc comment
        // lớp StudySummaryScreen).
        SectionHeader(text: l10n.studySummaryPlanTitle),
        const SizedBox(height: 12),
        if (snapshot.dailyPlan.steps.isEmpty)
          EmptyStateBanner(text: l10n.learningJourneyEmpty)
        else
          for (final step in snapshot.dailyPlan.steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildStepCard(l10n, step),
            ),
        const SizedBox(height: 20),

        // 4) smartSession — ĐÚNG bố cục SmartLearningScreen._SmartLearningContent
        // đã dùng (đề xuất chính nổi bật + phần còn lại trung tính),
        // KHÔNG có SmartLearningHeader riêng (trùng lặp SectionHeader).
        SectionHeader(text: l10n.studySummarySessionTitle),
        const SizedBox(height: 12),
        if (recommendations.isEmpty)
          EmptyStateBanner(text: l10n.smartLearningEmpty)
        else ...[
          _buildSessionSummaryCard(l10n, recommendations.first),
          if (recommendations.length > 1) ...[
            const SizedBox(height: 12),
            for (final r in recommendations.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildRecommendationCard(l10n, r),
              ),
          ],
        ],
      ],
    );
  }

  // Sprint R2.3: 4 hàm dựng thẻ dùng chung — xem doc comment lớp này
  // (KHÔNG cần BuildContext riêng, chỉ ánh xạ 1 đối tượng domain qua
  // đúng hàm trình bày của tầng gốc rồi trả widget).

  Widget _buildInsightCard(AppLocalizations l10n, TutorInsight insight) {
    final p = insightPresentation(l10n, insight);
    return TutorInsightCard(icon: p.icon, label: p.label, value: p.value);
  }

  Widget _buildStepCard(AppLocalizations l10n, JourneyStep step) {
    final p = suggestionPresentation(l10n, step.suggestion);
    return JourneyStepCard(
      stepNumber: step.order + 1,
      icon: p.icon,
      title: p.title,
      detail: p.detail,
      priorityLabel: suggestionPriorityLabel(l10n, step.suggestion.priority),
      isUrgent: step.suggestion.priority == TutorSuggestionPriority.high,
    );
  }

  Widget _buildSessionSummaryCard(
    AppLocalizations l10n,
    LearningRecommendation recommendation,
  ) {
    final p = sessionStrategyPresentation(l10n, recommendation.strategy);
    return SessionSummaryCard(
      title: l10n.smartLearningRecommendedTitle,
      icon: p.icon,
      strategyLabel: p.label,
      estimatedTimeLabel:
          l10n.statsTodayMinutes(recommendation.estimatedMinutes),
      relatedStepsLabel: l10n.smartLearningRelatedStepsLabel(
        recommendation.relatedStepCount,
      ),
    );
  }

  Widget _buildRecommendationCard(
    AppLocalizations l10n,
    LearningRecommendation recommendation,
  ) {
    final p = sessionStrategyPresentation(l10n, recommendation.strategy);
    return RecommendationCard(
      icon: p.icon,
      strategyLabel: p.label,
      estimatedTimeLabel:
          l10n.statsTodayMinutes(recommendation.estimatedMinutes),
      relatedStepsLabel: l10n.smartLearningRelatedStepsLabel(
        recommendation.relatedStepCount,
      ),
    );
  }
}
