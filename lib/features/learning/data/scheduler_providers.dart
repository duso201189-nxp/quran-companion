import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../../quran/data/user_content_providers.dart';
import '../domain/entities/srs_card.dart';
import '../domain/repositories/scheduler_repository.dart';
import '../domain/scheduling_algorithm.dart';
import '../domain/sm2_scheduling_algorithm.dart';
import 'scheduler_repository_impl.dart';

/// Cài đặt thuật toán lập lịch — mặc định SM-2 (DR-2026-0005 mục 3).
/// Đổi sang FSRS sau này chỉ cần override provider này ở nơi khởi tạo
/// app; mọi tầng phía trên (repository, provider khác, UI) không đổi.
final schedulingAlgorithmProvider = Provider<SchedulingAlgorithm>(
  (ref) => const SM2SchedulingAlgorithm(),
);

final schedulerRepositoryProvider = Provider<SchedulerRepository>(
  (ref) => SchedulerRepositoryImpl(
    ref.watch(userDatabaseProvider),
    ref.watch(schedulingAlgorithmProvider),
  ),
);

/// Orchestration thuần (DR-2026-0005 mục 2/3): theo dõi Revision Queue
/// (UserContentRepository.watchAllReviewAyahs()) và gọi
/// SchedulerRepository.syncWithReviewQueue() mỗi khi Queue đổi. KHÔNG
/// tính toán lịch trình, KHÔNG chứa logic scheduling — chỉ chuyển
/// tiếp danh sách ayah_id giữa 2 repository độc lập, đúng vai trò
/// "phối hợp" của tầng Provider (Scheduler không phụ thuộc
/// UserContentRepository, xem SchedulerRepository).
///
/// autoDispose: chỉ chạy khi có provider/UI đang watch nó (vd.
/// dueReviewCardsProvider) — không tự đồng bộ nền khi không ai cần.
final schedulerSyncProvider = StreamProvider.autoDispose<void>((ref) async* {
  final reviewAyahs =
      ref.watch(userContentRepositoryProvider).watchAllReviewAyahs();
  final schedulerRepo = ref.watch(schedulerRepositoryProvider);
  await for (final items in reviewAyahs) {
    await schedulerRepo.syncWithReviewQueue(
      [for (final item in items) item.ayahId],
    );
    yield null;
  }
});

/// Lọc + sắp xếp + khử trùng lặp thẻ đến hạn — hàm thuần tách riêng
/// khỏi provider để test trực tiếp không cần ProviderContainer.
///
/// "Đến hạn" = due_date <= [now] — gồm cả thẻ quá hạn, đúng ngữ nghĩa
/// SRS chuẩn (Anki/SuperMemo: "due" là due_date đã qua, không chỉ những
/// thẻ due_date rơi đúng vào hôm nay). Sắp theo due_date tăng dần; hai
/// thẻ cùng due_date sắp theo id để thứ tự luôn ổn định giữa các lần
/// gọi. Khử trùng lặp theo id, giữ lần xuất hiện đầu (không thể xảy ra
/// từ srs_cards thật do UNIQUE(item_type, item_id), nhưng
/// SchedulerRepository là interface — không giả định cài đặt phía sau
/// luôn đảm bảo điều này).
List<SrsCard> selectDueCardsOrdered(List<SrsCard> cards, DateTime now) {
  final nowMs = now.toUtc().millisecondsSinceEpoch;
  final due = cards.where((c) => c.dueDate <= nowMs).toList()
    ..sort((a, b) {
      final byDueDate = a.dueDate.compareTo(b.dueDate);
      if (byDueDate != 0) return byDueDate;
      return a.id.compareTo(b.id);
    });

  final seenIds = <String>{};
  final result = <SrsCard>[];
  for (final card in due) {
    if (seenIds.add(card.id)) result.add(card);
  }
  return result;
}

/// Thẻ SRS (loại Ayah) đến hạn ôn tập — sắp theo hạn gần nhất trước,
/// thứ tự ổn định, không trùng lặp (DR-2026-0005 mục 2, Phase 2 task
/// 4). Watch schedulerSyncProvider để Scheduler luôn khớp Revision
/// Queue mới nhất trước khi tính due — một provider duy nhất cho nơi
/// tiêu thụ (Phase 3), không cần watch cả hai provider riêng lẻ.
final dueReviewCardsProvider =
    StreamProvider.autoDispose<List<SrsCard>>((ref) {
  ref.watch(schedulerSyncProvider);
  return ref
      .watch(schedulerRepositoryProvider)
      .watchAllCards(LearningItemType.ayah)
      .map((cards) => selectDueCardsOrdered(cards, DateTime.now()));
});
