import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../../core/logging/logging_providers.dart';
import '../../learning/data/scheduler_providers.dart';
import '../../learning/data/scheduler_repository_impl.dart';
import '../../learning/domain/entities/srs_card.dart';
import '../../learning/domain/hifz_scheduling_algorithm.dart';
import '../../learning/domain/repositories/scheduler_repository.dart';
import '../../learning/domain/scheduling_algorithm.dart';
import '../domain/entities/hifz_plan.dart';
import '../domain/repositories/hifz_plan_repository.dart';
import 'hifz_plan_repository_impl.dart';

final hifzPlanRepositoryProvider = Provider<HifzPlanRepository>(
  (ref) => HifzPlanRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(loggerProvider),
  ),
);

/// Thuật toán lịch ôn dành riêng cho Hifz — tách provider để đổi được
/// trong test/tương lai, đúng mẫu [schedulingAlgorithmProvider].
final hifzSchedulingAlgorithmProvider = Provider<SchedulingAlgorithm>(
  (ref) => const HifzSchedulingAlgorithm(),
);

/// Bản THỨ HAI của cùng một lớp `SchedulerRepositoryImpl`, chỉ khác
/// thuật toán — Sprint 7.7a.
///
/// Vì sao cần bản riêng: `applyReview(cardId, grade)` lấy thuật toán
/// từ CHÍNH thể hiện repository (xem SchedulerRepositoryImpl), không
/// từ loại thẻ. Muốn Hifz có nhịp riêng thì thể hiện xử lý nó phải cầm
/// [HifzSchedulingAlgorithm]. Cách này KHÔNG đổi một dòng nào của
/// `SchedulerRepository`, `SchedulerRepositoryImpl` hay
/// `SchedulingAlgorithm`.
///
/// Hai thể hiện dùng chung bảng `srs_cards` là an toàn CHỈ VÌ chúng
/// thao tác trên hai `item_type` rời nhau ('ayah'/'lemma' vs 'hifz') —
/// `UNIQUE(item_type, item_id)` tách hẳn hai họ dòng.
final hifzSchedulerRepositoryProvider = Provider<SchedulerRepository>(
  (ref) => SchedulerRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(hifzSchedulingAlgorithmProvider),
    ref.watch(loggerProvider),
  ),
);

/// Mọi kế hoạch còn sống.
final hifzPlansProvider = StreamProvider.autoDispose<List<HifzPlan>>(
  (ref) => ref.watch(hifzPlanRepositoryProvider).watchAllPlans(),
);

/// Tập hợp HỢP (union) mọi ordinal Ayah được lên lịch Hifz — Sprint
/// 7.7a.
///
/// Gồm Ayah của kế hoạch active **và** paused **và** completed: chỉ
/// kế hoạch bị xoá mềm mới rời tập hợp này. Đó là điều giữ cho tạm
/// dừng và hoàn thành KHÔNG phá lịch ôn — nếu một Ayah rời tập hợp,
/// `syncItemsForType` sẽ xoá mềm thẻ của nó, và lần quay lại sau đó
/// `initialState()` sẽ RESET toàn bộ tiến trình (xem nhánh hồi sinh
/// trong SchedulerRepositoryImpl.syncItemsForType). Tạm dừng vì thế
/// được làm bằng bộ lọc "đến hạn" ở dưới, tuyệt đối không bằng cách
/// rút khỏi tập hợp này.
///
/// Khử trùng lặp: kế hoạch chồng lấn dùng chung một Ayah -> đúng một
/// thẻ Hifz cho Ayah đó.
final hifzUnionAyahIdsProvider = FutureProvider.autoDispose<List<int>>(
  (ref) async {
    final plans = await ref.watch(hifzPlansProvider.future);
    final union = <int>{};
    for (final plan in plans) {
      union.addAll(plan.ayahOrdinals);
    }
    return union.toList()..sort();
  },
);

/// Orchestration thuần — cùng vai trò `schedulerSyncProvider` của ôn
/// tập thường: đẩy tập hợp Hifz vào Scheduler mỗi khi nó đổi.
///
/// KHÔNG chạm `revisionEligibleAyahsProvider` và không chạm loại
/// 'ayah': `syncItemsForType(LearningItemType.hifz, ...)` chỉ đọc/ghi
/// dòng có `item_type='hifz'`.
final hifzSchedulerSyncProvider = FutureProvider.autoDispose<void>((ref) async {
  final union = await ref.watch(hifzUnionAyahIdsProvider.future);
  final scheduler = ref.watch(hifzSchedulerRepositoryProvider);
  await scheduler.syncItemsForType(LearningItemType.hifz, union);
});

/// Ordinal Ayah thuộc kế hoạch ĐANG HOẠT ĐỘNG — đây là chỗ tạm dừng
/// thật sự có tác dụng.
final hifzActiveAyahIdsProvider = FutureProvider.autoDispose<Set<int>>(
  (ref) async {
    final plans = await ref.watch(hifzPlansProvider.future);
    return {
      for (final plan in plans)
        if (plan.status == HifzPlanStatus.active) ...plan.ayahOrdinals,
    };
  },
);

/// Thẻ Hifz đến hạn ôn.
///
/// Hai tầng lọc, cố ý tách rời:
/// 1. [selectDueCardsOrdered] — dùng LẠI đúng hàm của ôn tập thường,
///    không viết lại luật "đến hạn".
/// 2. chỉ giữ Ayah thuộc kế hoạch đang hoạt động — tạm dừng/hoàn thành
///    vẫn còn thẻ và còn tiến trình, chỉ không hỏi tới.
final dueHifzCardsProvider =
    FutureProvider.autoDispose<List<SrsCard>>((ref) async {
  await ref.watch(hifzSchedulerSyncProvider.future);
  final activeIds = await ref.watch(hifzActiveAyahIdsProvider.future);
  final cards = await ref
      .watch(hifzSchedulerRepositoryProvider)
      .watchAllCards(LearningItemType.hifz)
      .first;
  return [
    for (final card in selectDueCardsOrdered(cards, DateTime.now()))
      if (activeIds.contains(card.itemId)) card,
  ];
});
