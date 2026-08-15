import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/hifz/data/hifz_plan_repository_impl.dart';
import 'package:quran_companion/features/hifz/data/hifz_progress_providers.dart';
import 'package:quran_companion/features/hifz/data/hifz_providers.dart';
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';

/// Logger im lặng — cùng mẫu các test Hifz khác.
class _SilentLogger implements Logger {
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

/// Sprint 7.7c-A — hifzPlanProgressProvider: cầu nối tầng Provider
/// giữa HifzPlanRepository và SchedulerRepository (đọc qua
/// hifzSchedulerRepositoryProvider), KHÔNG đổi hành vi của bên nào.
void main() {
  late UserDatabase db;
  late HifzPlanRepositoryImpl hifzRepo;
  var idCounter = 0;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    idCounter = 0;
    db = UserDatabase(NativeDatabase.memory());
    hifzRepo = HifzPlanRepositoryImpl(
      db,
      _SilentLogger(),
      newId: () => 'plan-${++idCounter}',
      nowMs: () => 1000,
    );
  });

  tearDown(() => db.close());

  test('planId không khớp kế hoạch còn sống nào -> null', () async {
    final container = makeContainer();

    final progress =
        await container.read(hifzPlanProgressProvider('không-tồn-tại').future);

    expect(progress, isNull);
  });

  test('kế hoạch đã xoá mềm -> null (không còn "còn sống")', () async {
    final id = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 3);
    await hifzRepo.deletePlan(id);
    final container = makeContainer();

    final progress = await container.read(hifzPlanProgressProvider(id).future);

    expect(progress, isNull);
  });

  test(
      'một kế hoạch active, chưa ôn lần nào -> tổng đúng, mọi thẻ ở '
      'trạng thái newCard, không có trung bình', () async {
    final id = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    final container = makeContainer();

    final progress = await container.read(hifzPlanProgressProvider(id).future);

    expect(progress, isNotNull);
    expect(progress!.plan.id, id);
    expect(progress.totalAyahCount, 3);
    expect(progress.trackedCardCount, 3);
    expect(progress.stateCounts[SrsCardState.newCard], 3);
    expect(progress.reviewedCardCount, 0);
    expect(progress.averageEaseFactor, isNull);
    expect(progress.averageIntervalDays, isNull);
    // Mọi thẻ mới đều đến hạn ngay khi tạo (due_date = lúc đồng bộ).
    expect(progress.dueNowCount, 3);
  });

  test(
      'nhiều kế hoạch cùng tồn tại -> progress của kế hoạch A không lẫn '
      'thẻ của kế hoạch B', () async {
    final idA = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 2);
    final idB = await hifzRepo.createPlan(ayahFrom: 50, ayahTo: 50);
    final container = makeContainer();

    final progressA =
        await container.read(hifzPlanProgressProvider(idA).future);
    final progressB =
        await container.read(hifzPlanProgressProvider(idB).future);

    expect(progressA!.totalAyahCount, 2);
    expect(progressA.trackedCardCount, 2);
    expect(progressB!.totalAyahCount, 1);
    expect(progressB.trackedCardCount, 1);
  });

  test(
      'sau khi chấm điểm một thẻ -> stateCounts/reviewedCardCount/trung '
      'bình phản ánh đúng trạng thái đã ghi, KHÔNG bịa lịch sử', () async {
    final id = await hifzRepo.createPlan(ayahFrom: 7, ayahTo: 7);
    final container = makeContainer();
    // Đồng bộ để thẻ 'hifz' tồn tại trước khi chấm điểm.
    await container.read(hifzSchedulerSyncProvider.future);
    final cardBefore = await container
        .read(hifzSchedulerRepositoryProvider)
        .watchAllCards(LearningItemType.hifz)
        .first;
    await container
        .read(hifzSchedulerRepositoryProvider)
        .applyReview(cardBefore.single.id, ReviewGrade.good);

    final progress = await container.read(hifzPlanProgressProvider(id).future);

    expect(progress!.stateCounts[SrsCardState.review], 1);
    expect(progress.stateCounts[SrsCardState.newCard], 0);
    expect(progress.reviewedCardCount, 1);
    expect(progress.averageEaseFactor, isNotNull);
    expect(progress.averageIntervalDays, 1);
  });

  test('started_at/completed_at của progress.plan khớp dữ liệu đã lưu',
      () async {
    final id = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 1);
    await hifzRepo.setStatus(id, HifzPlanStatus.completed);
    final container = makeContainer();

    final progress = await container.read(hifzPlanProgressProvider(id).future);

    expect(progress!.plan.startedAt, 1000);
    expect(progress.plan.completedAt, 1000);
    expect(progress.plan.status, HifzPlanStatus.completed);
  });

  test(
      'BẤT BIẾN QUAN TRỌNG: tạm dừng kế hoạch KHÔNG reset tiến trình SRS '
      'đã có — thẻ vẫn giữ nguyên state/repetitions/ease sau khi pause',
      () async {
    final id = await hifzRepo.createPlan(ayahFrom: 4, ayahTo: 4);
    final container = makeContainer();
    await container.read(hifzSchedulerSyncProvider.future);
    final cardBefore = await container
        .read(hifzSchedulerRepositoryProvider)
        .watchAllCards(LearningItemType.hifz)
        .first;
    await container
        .read(hifzSchedulerRepositoryProvider)
        .applyReview(cardBefore.single.id, ReviewGrade.good);

    final progressBeforePause =
        await container.read(hifzPlanProgressProvider(id).future);
    expect(progressBeforePause!.stateCounts[SrsCardState.review], 1);
    expect(progressBeforePause.reviewedCardCount, 1);

    // Tạm dừng — theo hifzUnionAyahIdsProvider, Ayah của kế hoạch tạm
    // dừng VẪN còn trong tập hợp (chỉ active mới lọc "đến hạn"), nên
    // syncItemsForType không được xoá mềm/hồi sinh (reset) thẻ này.
    await hifzRepo.setStatus(id, HifzPlanStatus.paused);

    // Container MỚI — buộc mọi provider tính lại từ đầu, đảm bảo phép
    // kiểm không ăn theo cache cũ của container trước.
    final container2 = makeContainer();
    await container2.read(hifzSchedulerSyncProvider.future);

    final progressAfterPause =
        await container2.read(hifzPlanProgressProvider(id).future);

    expect(progressAfterPause!.plan.status, HifzPlanStatus.paused);
    // Tiến trình PHẢI giữ nguyên — không quay lại newCard, không mất
    // repetitions/ease đã tích luỹ.
    expect(progressAfterPause.stateCounts[SrsCardState.review], 1);
    expect(progressAfterPause.stateCounts[SrsCardState.newCard], 0);
    expect(progressAfterPause.reviewedCardCount, 1);
    // Lần chấm đầu (good, từ thẻ mới): SM-2 giữ ease=2.5 KHÔNG đổi —
    // xem công thức trong HifzSchedulingAlgorithm.review.
    expect(progressAfterPause.averageEaseFactor, closeTo(2.5, 0.0001));
  });

  test(
      'kế hoạch completed vẫn hiện đúng tiến trình đã có, KHÔNG bị coi là '
      '"xong 100%" một cách máy móc — dữ liệu SRS quyết định, không phải '
      'nhãn vòng đời', () async {
    final id = await hifzRepo.createPlan(ayahFrom: 8, ayahTo: 8);
    await hifzRepo.setStatus(id, HifzPlanStatus.completed);
    final container = makeContainer();

    final progress = await container.read(hifzPlanProgressProvider(id).future);

    // Đánh dấu "completed" là một cột mốc người dùng tự đặt (Sprint
    // 7.7a) — KHÔNG có nghĩa "mọi Ayah đã thuộc". Thẻ vẫn ở newCard vì
    // chưa từng được chấm điểm, đúng dữ liệu thật, không suy diễn.
    expect(progress!.plan.status, HifzPlanStatus.completed);
    expect(progress.stateCounts[SrsCardState.newCard], 1);
    expect(progress.reviewedCardCount, 0);
  });
}
