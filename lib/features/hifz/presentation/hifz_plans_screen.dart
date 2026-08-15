import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../quran/domain/entities/surah.dart';
import '../../quran/presentation/surah_list_controller.dart'
    show surahListProvider;
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
        child: plansAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.errorLoadData)),
          data: (plans) {
            if (plans.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.hifzPlansEmpty, textAlign: TextAlign.center),
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
