import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../shared/widgets/empty_state_banner.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../quran/domain/entities/surah.dart';
import '../../quran/presentation/surah_list_controller.dart'
    show surahListProvider;
import '../data/hifz_progress_providers.dart';
import '../data/hifz_providers.dart';
import '../domain/entities/hifz_plan.dart';

enum _PlanAction { viewProgress, pause, resume, complete, delete }

/// Danh sách + quản lý kế hoạch Hifz — Sprint 7.7b-ii. Cùng khuôn
/// FlashcardDecksScreen (Sprint 13 Phase 3): danh sách qua
/// [hifzPlansProvider] (KHÔNG đổi, Sprint 7.7a), FAB tạo mới, menu
/// vòng đời trên mỗi dòng.
///
/// Không mở màn hình ôn Hifz ở đây — đó là Sprint 7.7b-iii, chưa xây.
class HifzPlansScreen extends ConsumerWidget {
  const HifzPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plansAsync = ref.watch(hifzPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.hifzPlansTitle),
        actions: [
          IconButton(
            tooltip: l10n.hifzReviewTooltip,
            icon: const Icon(Icons.menu_book_rounded),
            onPressed: () => context.push(AppRoutes.hifzReview),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _HifzOverallSummaryCard(),
            Expanded(
              child: plansAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(child: Text(l10n.errorLoadData)),
                data: (plans) {
                  if (plans.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.hifzPlansEmpty,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: plans.length,
                    itemBuilder: (context, i) => _PlanTile(plan: plans[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.hifzPlanForm),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.hifzPlanCreate),
      ),
    );
  }
}

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan});

  final HifzPlan plan;

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

  /// "{Tên Surah} {từ}–{đến}" khi hai đầu cùng Surah (mọi kế hoạch do
  /// HifzPlanFormScreen tạo — Sprint 7.7b-ii chỉ tạo đoạn trong một
  /// Surah); nếu khác Surah (dữ liệu từ nguồn khác, phòng thủ) thì nêu
  /// cả hai. Ordinal không quy đổi được (phòng thủ, không nên xảy ra
  /// với dữ liệu hợp lệ) -> rơi về hiện ordinal thô, không giấu lỗi.
  String _rangeLabel(AppLocalizations l10n, List<Surah> surahs) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final surahs = ref.watch(surahListProvider).valueOrNull ?? const [];
    final visual = _statusVisual(plan.status);
    final statusLabel = visual.label(l10n);
    final rangeLabel = _rangeLabel(l10n, surahs);

    return Semantics(
      label: '$rangeLabel — $statusLabel',
      excludeSemantics: true,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(visual.icon, color: scheme.onSecondaryContainer),
        ),
        title: Text(rangeLabel),
        // Trạng thái nêu bằng CHỮ + biểu tượng riêng ở leading — không
        // chỉ dựa vào màu sắc để truyền đạt (yêu cầu khả năng tiếp cận).
        subtitle: Text(statusLabel),
        trailing: PopupMenuButton<_PlanAction>(
          tooltip: l10n.hifzPlanActionsTooltip,
          onSelected: (action) => _handle(context, ref, action),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _PlanAction.viewProgress,
              child: Text(l10n.hifzPlanActionViewProgress),
            ),
            if (plan.status == HifzPlanStatus.active)
              PopupMenuItem(
                value: _PlanAction.pause,
                child: Text(l10n.hifzActionPause),
              ),
            if (plan.status == HifzPlanStatus.paused)
              PopupMenuItem(
                value: _PlanAction.resume,
                child: Text(l10n.hifzActionResume),
              ),
            if (plan.status != HifzPlanStatus.completed)
              PopupMenuItem(
                value: _PlanAction.complete,
                child: Text(l10n.hifzActionComplete),
              ),
            PopupMenuItem(
              value: _PlanAction.delete,
              child: Text(l10n.hifzActionDelete),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _PlanAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(hifzPlanRepositoryProvider);
    switch (action) {
      case _PlanAction.viewProgress:
        await context.push(AppRoutes.hifzProgress(plan.id));
      case _PlanAction.pause:
        await repo.setStatus(plan.id, HifzPlanStatus.paused);
      case _PlanAction.resume:
        await repo.setStatus(plan.id, HifzPlanStatus.active);
      case _PlanAction.complete:
        await repo.setStatus(plan.id, HifzPlanStatus.completed);
      case _PlanAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(l10n.hifzPlanDeleteConfirmTitle),
            content: Text(l10n.hifzPlanDeleteConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.hifzActionDelete),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await repo.deletePlan(plan.id);
        }
    }
  }
}

/// Ảnh chụp Hifz TỔNG QUAN — gộp mọi kế hoạch active — Sprint D6.4.
///
/// CHỦ ĐÍCH KHÔNG CÓ: điểm số/% hoàn thành/chuỗi ngày gộp thành 1 con
/// số duy nhất — cùng lý do đã nêu ở `HifzProgressScreen` (Hiến pháp
/// Study §10, checkpoint "Worship First"). Thẻ này chỉ hiện các sự
/// kiện đếm được (số kế hoạch/Ayah/thẻ đến hạn/đã ôn) — một mô tả
/// trung thực tại thời điểm xem, KHÔNG phải một thành tích hay xu
/// hướng theo thời gian (xem [HifzOverallProgress] doc comment).
class _HifzOverallSummaryCard extends ConsumerWidget {
  const _HifzOverallSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progressAsync = ref.watch(hifzOverallProgressProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: progressAsync.when(
        loading: () =>
            LoadingState(semanticsLabel: l10n.hifzProgressLoading, height: 72),
        error: (_, __) => Text(
          l10n.errorLoadData,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        data: (progress) {
          if (progress.activePlanCount == 0) {
            return EmptyStateBanner(text: l10n.hifzOverallNoActivePlans);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.hifzOverallSectionTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              // CÙNG luật lưới đáp ứng của HifzProgressScreen's
              // _OverviewGrid (Sprint 7.7c-A) — 2 cột trên điện thoại
              // hẹp, 3 cột khi đủ rộng, KHÔNG ép 4 cột luôn khiến nhãn
              // dài (vd "Ayahs planned"/"Ayah đã lên kế hoạch") bị cắt
              // trên màn hình hẹp.
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 560 ? 3 : 2;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columns,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: [
                      StatCard(
                        icon: Icons.fact_check_rounded,
                        value: '${progress.activePlanCount}',
                        label: l10n.hifzOverallPlansLabel,
                      ),
                      StatCard(
                        icon: Icons.menu_book_rounded,
                        value: '${progress.totalPlannedAyahs}',
                        label: l10n.hifzOverallAyahsLabel,
                      ),
                      StatCard(
                        icon: Icons.schedule_rounded,
                        value: '${progress.dueNowCount}',
                        label: l10n.hifzOverallDueNowLabel,
                      ),
                      StatCard(
                        icon: Icons.track_changes_rounded,
                        value: '${progress.reviewedCardCount}',
                        label: l10n.hifzOverallReviewedLabel,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                // Cùng chuỗi l10n đã dùng ở HifzProgressScreen — cùng ý
                // nghĩa (ảnh chụp hiện tại, không phải lịch sử ôn tập),
                // tái dùng thay vì thêm khoá l10n trùng lặp.
                l10n.hifzProgressSnapshotNote,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
