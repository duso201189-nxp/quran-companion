import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learning/domain/entities/srs_card.dart';
import '../domain/entities/hifz_overall_progress.dart';
import '../domain/entities/hifz_plan.dart';
import '../domain/entities/hifz_plan_progress.dart';
import '../domain/hifz_progress_calculator.dart';
import 'hifz_providers.dart';

/// Ảnh chụp tiến độ MỘT kế hoạch Hifz cụ thể, theo `planId` — Sprint
/// 7.7c-A.
///
/// Cầu nối tầng Provider giữa [hifzPlansProvider] (đọc qua
/// `HifzPlanRepository`) và [hifzSchedulerRepositoryProvider] (đọc qua
/// `SchedulerRepository`, đã có từ Sprint 7.7a) — đúng ranh giới đã
/// lập ở `hifz_plan_repository.dart`/`scheduler_repository.dart`:
/// KHÔNG repository nào trong hai lớp đó biết về lớp còn lại, phối
/// hợp CHỈ xảy ra ở tầng Provider (MASTER_ARCHITECTURE.md §3 `data/`).
/// File RIÊNG với `hifz_providers.dart` — phạm vi hẹp, chỉ phục vụ
/// màn hình tiến độ, không đổi bất kỳ provider nào đã có ở đó.
///
/// `await ref.watch(hifzSchedulerSyncProvider.future)` TRƯỚC khi đọc
/// thẻ — cùng lý do [dueHifzCardsProvider] đã làm: đảm bảo `srs_cards`
/// khớp tập hợp Ayah mới nhất của MỌI kế hoạch còn sống trước khi lọc
/// riêng cho kế hoạch này (vd kế hoạch vừa tạo, chưa từng mở màn hình
/// ôn Hifz nên có thể chưa có thẻ nào).
///
/// Trả `null` nếu `planId` không khớp kế hoạch còn sống nào (đã xoá
/// mềm hoặc id sai) — nơi gọi (màn hình) tự quyết định hiển thị gì
/// cho `null`.
final hifzPlanProgressProvider =
    FutureProvider.autoDispose.family<HifzPlanProgress?, String>(
  (ref, planId) async {
    final plans = await ref.watch(hifzPlansProvider.future);
    HifzPlan? plan;
    for (final p in plans) {
      if (p.id == planId) {
        plan = p;
        break;
      }
    }
    if (plan == null) return null;

    await ref.watch(hifzSchedulerSyncProvider.future);

    final allCards = await ref
        .watch(hifzSchedulerRepositoryProvider)
        .watchAllCards(LearningItemType.hifz)
        .first;

    final ordinals = plan.ayahOrdinals.toSet();
    final planCards = [
      for (final c in allCards)
        if (ordinals.contains(c.itemId)) c,
    ];

    return computeHifzPlanProgress(
      plan: plan,
      cards: planCards,
      now: DateTime.now(),
    );
  },
);

/// Ảnh chụp tiến độ TOÀN CỤC — gộp mọi kế hoạch Hifz đang ACTIVE —
/// Sprint D6.4. KHÔNG phải family: chỉ một phạm vi "tổng quan", khác
/// [hifzPlanProgressProvider] (theo `planId`).
///
/// Lọc thẻ theo `hifzActiveAyahIdsProvider` (đã có sẵn, Sprint 7.7a) —
/// KHÔNG đọc trực tiếp toàn bộ `watchAllCards(hifz)` mà không lọc, vì
/// bảng `srs_cards` giữ CẢ thẻ của kế hoạch paused/completed (chỉ xoá
/// mềm mới rời tập hợp — xem `hifzUnionAyahIdsProvider`). Đây CHÍNH LÀ
/// nơi thực thi "chỉ active" của ảnh chụp tổng quan: `activeIds` là một
/// `Set<int>` (đã khử trùng lặp ordinal chồng lấn giữa các kế hoạch
/// active), nên thẻ của Ayah chồng lấn chỉ xuất hiện ĐÚNG MỘT LẦN
/// trong [cards] truyền cho [computeHifzOverallProgress] — không có
/// đường nào khiến cùng một thẻ vật lý bị đếm hai lần.
final hifzOverallProgressProvider =
    FutureProvider.autoDispose<HifzOverallProgress>((ref) async {
  final plans = await ref.watch(hifzPlansProvider.future);
  final activePlans = [
    for (final p in plans)
      if (p.status == HifzPlanStatus.active) p,
  ];

  await ref.watch(hifzSchedulerSyncProvider.future);
  final activeIds = await ref.watch(hifzActiveAyahIdsProvider.future);

  final allCards = await ref
      .watch(hifzSchedulerRepositoryProvider)
      .watchAllCards(LearningItemType.hifz)
      .first;
  final cards = [
    for (final c in allCards)
      if (activeIds.contains(c.itemId)) c,
  ];

  return computeHifzOverallProgress(
    activePlans: activePlans,
    cards: cards,
    now: DateTime.now(),
  );
});
