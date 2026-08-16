import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../../quran/domain/entities/surah.dart';
import '../../quran/presentation/surah_list_controller.dart'
    show surahListProvider;
import '../data/hifz_progress_providers.dart';
import '../data/hifz_review_history_providers.dart';
import '../domain/entities/hifz_plan.dart';
import '../domain/entities/hifz_plan_progress.dart';
import '../domain/entities/hifz_review_history.dart';

/// Ảnh chụp tiến độ MỘT kế hoạch Hifz — Sprint 7.7c-A.
///
/// Trình bày thuần [HifzPlanProgress] đã tính sẵn ở
/// [hifzPlanProgressProvider] — màn hình không tự tính gì, chỉ đổi số
/// liệu thành icon/nhãn/định dạng ngày (đúng vai trò `presentation/`,
/// MASTER_ARCHITECTURE.md §3).
///
/// CHỦ ĐÍCH KHÔNG CÓ: một con số "% hoàn thành"/"điểm số" duy nhất
/// gộp mọi trạng thái làm một — Hiến pháp Study §10 và checkpoint
/// "Worship First" của Sprint 7.7 (MILESTONE_7_STUDY_ROADMAP.md) cấm
/// khung "leaderboard/điểm số/áp lực chuỗi ngày". Thay vào đó, màn
/// hình này hiện PHÂN BỐ trạng thái hiện tại (mới/đang học/ổn định/
/// cần ôn lại) — một mô tả trung thực, không phải một thành tích.
class HifzProgressScreen extends ConsumerWidget {
  const HifzProgressScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progressAsync = ref.watch(hifzPlanProgressProvider(planId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hifzProgressTitle)),
      body: SafeArea(
        child: progressAsync.when(
          loading: () => LoadingState(semanticsLabel: l10n.hifzProgressLoading),
          error: (_, __) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.errorLoadData,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          data: (progress) => progress == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyStateBanner(
                      text: l10n.hifzProgressPlanNotFound,
                    ),
                  ),
                )
              : _HifzProgressBody(progress: progress),
        ),
      ),
    );
  }
}

class _HifzProgressBody extends ConsumerWidget {
  const _HifzProgressBody({required this.progress});

  final HifzPlanProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final surahs = ref.watch(surahListProvider).valueOrNull ?? const [];
    final plan = progress.plan;
    final dateFormat = DateFormat.yMMMd(locale);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PlanHeaderCard(
          plan: plan,
          rangeLabel: _rangeLabel(plan, surahs),
          dateFormat: dateFormat,
        ),
        const SizedBox(height: 20),
        SectionHeader(text: l10n.hifzProgressOverviewTitle),
        const SizedBox(height: 12),
        _OverviewGrid(progress: progress, dateFormat: dateFormat),
        const SizedBox(height: 20),
        SectionHeader(text: l10n.hifzProgressStateSectionTitle),
        const SizedBox(height: 12),
        _StateDistributionCard(progress: progress),
        const SizedBox(height: 20),
        SectionHeader(text: l10n.hifzProgressPaceSectionTitle),
        const SizedBox(height: 12),
        if (progress.reviewedCardCount == 0)
          EmptyStateBanner(text: l10n.hifzProgressNoReviewsYet)
        else
          _PaceGrid(progress: progress),
        const SizedBox(height: 20),
        SectionHeader(text: l10n.hifzHistorySectionTitle),
        const SizedBox(height: 12),
        _ReviewHistorySection(planId: plan.id),
      ],
    );
  }
}

/// Lịch sử ôn tập đã ghi của kế hoạch này — Sprint D6.11 (DR-2026-0026).
///
/// Đọc [hifzPlanReviewHistoryProvider] RIÊNG, không dùng chung
/// [HifzPlanProgress] của phần còn lại màn hình: ảnh chụp hiện tại và
/// lịch sử sự kiện là hai nguồn tách biệt, gộp lại sẽ xoá mất chính
/// ranh giới mà DR-2026-0026 dựng lên.
class _ReviewHistorySection extends ConsumerWidget {
  const _ReviewHistorySection({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(hifzPlanReviewHistoryProvider(planId));

    return historyAsync.when(
      loading: () => LoadingState(semanticsLabel: l10n.hifzProgressLoading),
      error: (_, __) => EmptyStateBanner(text: l10n.errorLoadData),
      data: (history) => history == null || history.totalReviewCount == 0
          ? EmptyStateBanner(text: l10n.hifzHistoryNoReviewsYet)
          : _ReviewHistoryCard(history: history),
    );
  }
}

class _ReviewHistoryCard extends StatelessWidget {
  const _ReviewHistoryCard({required this.history});

  final HifzReviewHistory history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dayFormat = DateFormat.E(locale);

    // Thang của biểu đồ là ngày BẬN NHẤT trong 7 ngày, không phải một
    // chỉ tiêu — không có mốc "nên đạt" nào ở đây.
    var busiestDay = 0;
    for (final d in history.recentDays) {
      if (d.reviewCount > busiestDay) busiestDay = d.reviewCount;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: '${l10n.hifzHistoryTotalLabel}: '
                '${history.totalReviewCount}',
            container: true,
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.hifzHistoryTotalLabel,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${history.totalReviewCount}',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.hifzHistoryLast7DaysLabel,
            style:
                textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          for (final day in history.recentDays) ...[
            _DayBucketRow(
              label: dayFormat.format(day.dayStart),
              count: day.reviewCount,
              busiestDay: busiestDay,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 2),
          Text(
            l10n.hifzHistoryScopeNote,
            style:
                textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Một ngày trong phân bố 7 ngày — nhãn ngày, thanh tỉ lệ, số lượt.
///
/// Ngày không có lượt ôn nào VẪN hiện, với thanh rỗng: khoảng trống là
/// dữ liệu thật, không phải thứ để giấu.
class _DayBucketRow extends StatelessWidget {
  const _DayBucketRow({
    required this.label,
    required this.count,
    required this.busiestDay,
  });

  final String label;
  final int count;
  final int busiestDay;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fraction = busiestDay == 0 ? 0.0 : count / busiestDay;

    return Semantics(
      label: '$label: $count',
      // Cùng lý do `_StateRow`: các dòng anh em liền kề bị Flutter gộp
      // nhãn semantics nếu không có container: true.
      container: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                label,
                style: textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(color: scheme.surfaceContainerHighest),
                      FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 24,
              child: Text(
                '$count',
                textAlign: TextAlign.end,
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "{Tên Surah} {từ}–{đến}" khi hai đầu cùng Surah; nêu cả hai nếu
/// khác Surah — CÙNG logic `HifzPlansScreen._PlanTile._rangeLabel`,
/// lặp lại có chủ đích thay vì trích xuất dùng chung: hai màn hình
/// hiện diện độc lập, trích xuất sớm sẽ khiến thay đổi UI của một bên
/// kéo theo rủi ro hồi quy ở bên kia (nguyên tắc 4 trong
/// MASTER_ARCHITECTURE.md §5 không áp dụng ở đây vì đây là quy tắc
/// TRÌNH BÀY, không phải logic domain).
String _rangeLabel(HifzPlan plan, List<Surah> surahs) {
  final from = plan.fromAddress;
  final to = plan.toAddress;
  if (from == null || to == null) {
    return '${plan.ayahFrom}–${plan.ayahTo}';
  }
  Surah? surahOf(int id) {
    for (final s in surahs) {
      if (s.id == id) return s;
    }
    return null;
  }

  final fromSurah = surahOf(from.surah);
  final fromName = fromSurah?.nameLatin ?? '${from.surah}';
  if (from.surah == to.surah) {
    return '$fromName ${from.ayah}–${to.ayah}';
  }
  final toSurah = surahOf(to.surah);
  final toName = toSurah?.nameLatin ?? '${to.surah}';
  return '$fromName ${from.ayah} – $toName ${to.ayah}';
}

({IconData icon, String Function(AppLocalizations) label}) _statusVisual(
  HifzPlanStatus status,
) =>
    switch (status) {
      HifzPlanStatus.active => (
          icon: Icons.play_circle_outline_rounded,
          label: (l10n) => l10n.hifzStatusActive,
        ),
      HifzPlanStatus.paused => (
          icon: Icons.pause_circle_outline_rounded,
          label: (l10n) => l10n.hifzStatusPaused,
        ),
      HifzPlanStatus.completed => (
          icon: Icons.check_circle_outline_rounded,
          label: (l10n) => l10n.hifzStatusCompleted,
        ),
    };

class _PlanHeaderCard extends StatelessWidget {
  const _PlanHeaderCard({
    required this.plan,
    required this.rangeLabel,
    required this.dateFormat,
  });

  final HifzPlan plan;
  final String rangeLabel;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visual = _statusVisual(plan.status);
    final statusLabel = visual.label(l10n);
    final startedDate = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(plan.startedAt, isUtc: true)
          .toLocal(),
    );
    final completedAtMs = plan.completedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: '$rangeLabel — $statusLabel',
            excludeSemantics: true,
            child: Row(
              children: [
                Icon(visual.icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rangeLabel,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        statusLabel,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateInfoColumn(
                  label: l10n.hifzProgressStartedLabel,
                  value: startedDate,
                ),
              ),
              if (completedAtMs != null)
                Expanded(
                  child: _DateInfoColumn(
                    label: l10n.hifzProgressCompletedLabel,
                    value: dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                        completedAtMs,
                        isUtc: true,
                      ).toLocal(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateInfoColumn extends StatelessWidget {
  const _DateInfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.progress, required this.dateFormat});

  final HifzPlanProgress progress;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reviewCount = progress.stateCounts[SrsCardState.review] ?? 0;
    final nextDueMs = progress.nextDueAtMs;
    final nextDueValue = nextDueMs == null
        ? l10n.hifzProgressNoScheduleYet
        : dateFormat.format(
            DateTime.fromMillisecondsSinceEpoch(nextDueMs, isUtc: true)
                .toLocal(),
          );

    final cards = <Widget>[
      StatCard(
        icon: Icons.menu_book_rounded,
        value: '${progress.totalAyahCount}',
        label: l10n.hifzProgressAyahCountLabel,
        accented: true,
      ),
      StatCard(
        icon: Icons.self_improvement_rounded,
        value: '$reviewCount',
        label: l10n.hifzProgressStableLabel,
        accented: true,
      ),
      StatCard(
        icon: Icons.schedule_rounded,
        value: '${progress.dueNowCount}',
        label: l10n.hifzProgressDueNowLabel,
        accented: true,
      ),
      StatCard(
        icon: Icons.track_changes_rounded,
        value: '${progress.reviewedCardCount}',
        label: l10n.hifzProgressReviewedLabel,
        accented: true,
      ),
      StatCard(
        icon: Icons.calendar_month_rounded,
        value: nextDueValue,
        label: l10n.hifzProgressNextDueLabel,
        accented: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: cards,
        );
      },
    );
  }
}

class _PaceGrid extends StatelessWidget {
  const _PaceGrid({required this.progress});

  final HifzPlanProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ease = progress.averageEaseFactor;
    final interval = progress.averageIntervalDays;

    final cards = <Widget>[
      StatCard(
        icon: Icons.speed_rounded,
        value: ease == null ? '—' : ease.toStringAsFixed(2),
        label: l10n.hifzProgressAverageEaseLabel,
      ),
      StatCard(
        icon: Icons.calendar_view_day_rounded,
        value: interval == null
            ? '—'
            : l10n.hifzProgressIntervalDaysValue(interval),
        label: l10n.hifzProgressAverageIntervalLabel,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: cards,
        );
      },
    );
  }
}

/// Màu theo trạng thái — CÙNG ánh xạ
/// `flashcard_tile.dart._stateColor` (4 trạng thái SRS chung một mô
/// hình, xem `SrsCardState` doc). Lặp lại có chủ đích, không trích
/// xuất dùng chung: hai widget ở hai feature độc lập
/// (`hifz`/`flashcards`), không có tiền lệ import trực tiếp
/// presentation của nhau trong dự án này.
Color _stateColor(ColorScheme scheme, SrsCardState state) => switch (state) {
      SrsCardState.newCard => scheme.outlineVariant,
      SrsCardState.learning => scheme.tertiary,
      SrsCardState.review => scheme.primary,
      SrsCardState.lapsed => scheme.error,
    };

IconData _stateIcon(SrsCardState state) => switch (state) {
      SrsCardState.newCard => Icons.circle_outlined,
      SrsCardState.learning => Icons.hourglass_empty_rounded,
      SrsCardState.review => Icons.self_improvement_rounded,
      SrsCardState.lapsed => Icons.replay_rounded,
    };

/// Nhãn trạng thái — TÁI SỬ DỤNG nguyên vẹn 4 chuỗi l10n đã có sẵn cho
/// bộ lọc Flashcard (`flashcardFilterNew/Learning/Review/Lapsed`,
/// `flashcard_tile.dart._stateLabel`) — cùng 4 trạng thái
/// [SrsCardState], chỉ khác ngữ cảnh hiển thị (nhãn bộ lọc Flashcard
/// vs nhãn phân bố tiến độ Hifz). KHÔNG thêm khoá l10n mới cho đúng 4
/// khái niệm đã dịch.
String _stateLabel(AppLocalizations l10n, SrsCardState state) =>
    switch (state) {
      SrsCardState.newCard => l10n.flashcardFilterNew,
      SrsCardState.learning => l10n.flashcardFilterLearning,
      SrsCardState.review => l10n.flashcardFilterReview,
      SrsCardState.lapsed => l10n.flashcardFilterLapsed,
    };

class _StateDistributionCard extends StatelessWidget {
  const _StateDistributionCard({required this.progress});

  final HifzPlanProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final counts = progress.stateCounts;
    final total = progress.trackedCardCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 10,
                child: total == 0
                    ? Container(color: scheme.surfaceContainerHighest)
                    : Row(
                        children: [
                          for (final state in SrsCardState.values)
                            if ((counts[state] ?? 0) > 0)
                              Expanded(
                                flex: counts[state]!,
                                child: Container(
                                  color: _stateColor(scheme, state),
                                ),
                              ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final state in SrsCardState.values) ...[
            _StateRow(
              icon: _stateIcon(state),
              color: _stateColor(scheme, state),
              label: _stateLabel(l10n, state),
              count: counts[state] ?? 0,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Text(
            l10n.hifzProgressTrackedNote(total, progress.totalAyahCount),
            style:
                textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.hifzProgressSnapshotNote,
            style:
                textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$label: $count',
      // Bốn dòng trạng thái là ANH EM (siblings) cùng cấp trong một
      // Column, không cách nhau bởi GridView/ranh giới bố cục nào —
      // không có `container: true` thì Flutter GỘP nhãn của các anh
      // em liền kề thành một node semantics duy nhất (đúng hành vi đã
      // xác nhận: journey_progress_card_test.dart chỉ kiểm
      // bySemanticsLabel khi CHỈ MỘT chip, không phải nhiều).
      container: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Text(
              '$count',
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
