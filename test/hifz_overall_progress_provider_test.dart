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

/// Sprint D6.4 — hifzOverallProgressProvider: gộp ảnh chụp tiến độ mọi
/// kế hoạch Hifz active, tái dùng hifzActiveAyahIdsProvider/
/// hifzSchedulerRepositoryProvider đã có sẵn (Sprint 7.7a), KHÔNG đổi
/// hành vi của bên nào.
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

  test('không có kế hoạch nào -> ảnh chụp rỗng, mọi bộ đếm = 0', () async {
    final container = makeContainer();

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(progress.activePlanCount, 0);
    expect(progress.totalPlannedAyahs, 0);
    expect(progress.trackedCardCount, 0);
    expect(progress.dueNowCount, 0);
    expect(progress.nextDueAtMs, isNull);
    expect(progress.reviewedCardCount, 0);
    expect(progress.averageEaseFactor, isNull);
    expect(progress.averageIntervalDays, isNull);
  });

  test('không có kế hoạch ACTIVE nào (chỉ paused) -> ảnh chụp rỗng', () async {
    final id = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 3);
    await hifzRepo.setStatus(id, HifzPlanStatus.paused);
    final container = makeContainer();

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(progress.activePlanCount, 0);
    expect(progress.totalPlannedAyahs, 0);
  });

  test('một kế hoạch active -> ảnh chụp gồm đúng Ayah/thẻ của nó', () async {
    await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    final container = makeContainer();

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(progress.activePlanCount, 1);
    expect(progress.totalPlannedAyahs, 3);
    expect(progress.trackedCardCount, 3);
    expect(progress.stateCounts[SrsCardState.newCard], 3);
    // Mọi thẻ mới đều đến hạn ngay khi tạo (due_date = lúc đồng bộ).
    expect(progress.dueNowCount, 3);
  });

  test(
      'kế hoạch paused KHÔNG góp vào ảnh chụp dù thẻ SRS của nó vẫn còn '
      'sống trong srs_cards', () async {
    final activeId = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 2);
    final pausedId = await hifzRepo.createPlan(ayahFrom: 50, ayahTo: 52);
    await hifzRepo.setStatus(pausedId, HifzPlanStatus.paused);
    final container = makeContainer();

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(activeId, isNotEmpty);
    expect(progress.activePlanCount, 1);
    expect(progress.totalPlannedAyahs, 2);
    expect(progress.trackedCardCount, 2);
  });

  test('kế hoạch completed KHÔNG góp vào ảnh chụp', () async {
    final activeId = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 2);
    final completedId = await hifzRepo.createPlan(ayahFrom: 60, ayahTo: 60);
    await hifzRepo.setStatus(completedId, HifzPlanStatus.completed);
    final container = makeContainer();

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(activeId, isNotEmpty);
    expect(progress.activePlanCount, 1);
    expect(progress.totalPlannedAyahs, 2);
    expect(progress.trackedCardCount, 2);
  });

  test(
      'hai kế hoạch active CHỒNG LẤN -> Ayah/thẻ chung chỉ đếm MỘT lần, '
      'không double-count', () async {
    // p1: 1..5 (5 Ayah), p2: 3..7 (5 Ayah) — chồng lấn 3..5.
    // Hợp (union) = 1..7 = 7 Ayah DUY NHẤT, KHÔNG phải 10.
    await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 5);
    await hifzRepo.createPlan(ayahFrom: 3, ayahTo: 7);
    final container = makeContainer();

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(progress.activePlanCount, 2);
    expect(progress.totalPlannedAyahs, 7);
    expect(progress.trackedCardCount, 7);
  });

  test(
      'provider phản ứng đúng khi trạng thái kế hoạch đổi (active -> '
      'paused) -> ảnh chụp giảm tương ứng', () async {
    final id = await hifzRepo.createPlan(ayahFrom: 1, ayahTo: 3);
    final container = makeContainer();

    final before = await container.read(hifzOverallProgressProvider.future);
    expect(before.activePlanCount, 1);
    expect(before.totalPlannedAyahs, 3);

    await hifzRepo.setStatus(id, HifzPlanStatus.paused);
    // Container MỚI — buộc mọi provider tính lại từ đầu, đúng mẫu
    // hifz_progress_provider_test.dart (không ăn theo cache cũ).
    final container2 = makeContainer();
    final after = await container2.read(hifzOverallProgressProvider.future);

    expect(after.activePlanCount, 0);
    expect(after.totalPlannedAyahs, 0);
  });

  test(
      'đồng bộ TRƯỚC khi đọc thẻ: kế hoạch vừa tạo (chưa có thẻ SRS nào '
      'trước khi provider chạy) vẫn cho ra trackedCardCount đúng nhờ '
      'hifzSchedulerSyncProvider chạy trước watchAllCards', () async {
    await hifzRepo.createPlan(ayahFrom: 20, ayahTo: 21);
    final container = makeContainer();

    // KHÔNG tự gọi hifzSchedulerSyncProvider trước — nếu provider tổng
    // quan không tự đồng bộ, trackedCardCount sẽ sai (0 thay vì 2).
    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(progress.trackedCardCount, 2);
  });

  test(
      'sau khi chấm điểm một thẻ active -> stateCounts/reviewedCardCount '
      'phản ánh đúng, dùng ĐÚNG nguồn thẻ Hifz (item_type=hifz), không '
      'lẫn nguồn nào khác', () async {
    await hifzRepo.createPlan(ayahFrom: 7, ayahTo: 7);
    final container = makeContainer();
    await container.read(hifzSchedulerSyncProvider.future);
    final cardBefore = await container
        .read(hifzSchedulerRepositoryProvider)
        .watchAllCards(LearningItemType.hifz)
        .first;
    await container
        .read(hifzSchedulerRepositoryProvider)
        .applyReview(cardBefore.single.id, ReviewGrade.good);

    final progress = await container.read(hifzOverallProgressProvider.future);

    expect(progress.stateCounts[SrsCardState.review], 1);
    expect(progress.stateCounts[SrsCardState.newCard], 0);
    expect(progress.reviewedCardCount, 1);
    expect(progress.averageEaseFactor, isNotNull);
    expect(progress.averageIntervalDays, 1);
  });
}
