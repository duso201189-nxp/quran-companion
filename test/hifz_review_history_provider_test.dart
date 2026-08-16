import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/hifz/data/hifz_plan_repository_impl.dart';
import 'package:quran_companion/features/hifz/data/hifz_review_history_providers.dart';
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';

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

/// Sprint D6.11 (DR-2026-0026, đã `accepted`) — hifzPlanReviewHistoryProvider
/// nối HifzPlanRepository (phạm vi Ayah) với đường đọc `review_events`,
/// dùng Drift THẬT.
void main() {
  late UserDatabase db;
  late HifzPlanRepositoryImpl hifzRepo;
  var idCounter = 0;
  var eventCounter = 0;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> seedHifzEvent({
    required int itemId,
    required int reviewedAt,
  }) async {
    await db.into(db.reviewEvents).insert(
          ReviewEventsCompanion.insert(
            id: 'evt-${++eventCounter}',
            updatedAt: reviewedAt,
            cardId: 'card-$itemId',
            itemType: 'hifz',
            itemId: itemId,
            reviewedAt: reviewedAt,
            grade: 'good',
            algorithmId: 'hifz-sm2-capped-v1',
            beforeState: 'new',
            beforeRepetitions: 0,
            beforeIntervalDays: 0,
            beforeEaseFactor: 2.5,
            beforeDueDate: reviewedAt,
            afterState: 'review',
            afterRepetitions: 1,
            afterIntervalDays: 1,
            afterEaseFactor: 2.5,
            afterDueDate: reviewedAt,
          ),
        );
  }

  int nowMs() => DateTime.now().millisecondsSinceEpoch;

  setUp(() {
    idCounter = 0;
    eventCounter = 0;
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

    expect(
      await container.read(hifzPlanReviewHistoryProvider('không-có').future),
      isNull,
    );
  });

  test('kế hoạch đã xoá mềm -> null', () async {
    final planId = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    await seedHifzEvent(itemId: 10, reviewedAt: nowMs());
    await hifzRepo.deletePlan(planId);

    final container = makeContainer();

    expect(
      await container.read(hifzPlanReviewHistoryProvider(planId).future),
      isNull,
    );
  });

  test('phạm vi đúng bằng ayahOrdinals của kế hoạch', () async {
    final planId = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    await seedHifzEvent(itemId: 10, reviewedAt: nowMs());
    await seedHifzEvent(itemId: 12, reviewedAt: nowMs());
    await seedHifzEvent(itemId: 99, reviewedAt: nowMs()); // ngoài đoạn

    final container = makeContainer();
    final history =
        await container.read(hifzPlanReviewHistoryProvider(planId).future);

    expect(history!.totalReviewCount, 2);
  });

  test('kế hoạch chưa có lượt ôn nào -> tổng 0, vẫn đủ 7 mốc', () async {
    final planId = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);

    final container = makeContainer();
    final history =
        await container.read(hifzPlanReviewHistoryProvider(planId).future);

    expect(history!.totalReviewCount, 0);
    expect(history.recentDays, hasLength(7));
  });

  test('kế hoạch paused vẫn trả lịch sử — tạm dừng không xoá việc đã xảy ra',
      () async {
    final planId = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    await seedHifzEvent(itemId: 10, reviewedAt: nowMs());
    await hifzRepo.setStatus(planId, HifzPlanStatus.paused);

    final container = makeContainer();
    final history =
        await container.read(hifzPlanReviewHistoryProvider(planId).future);

    expect(history!.totalReviewCount, 1);
  });

  test('kế hoạch completed vẫn trả lịch sử', () async {
    final planId = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    await seedHifzEvent(itemId: 10, reviewedAt: nowMs());
    await hifzRepo.setStatus(planId, HifzPlanStatus.completed);

    final container = makeContainer();
    final history =
        await container.read(hifzPlanReviewHistoryProvider(planId).future);

    expect(history!.totalReviewCount, 1);
  });

  test(
      'kế hoạch CHỒNG LẤN: cùng một sự kiện có mặt hợp lệ trong lịch sử của '
      'CẢ HAI — phạm vi, không phải quy gán; tổng KHÔNG cộng dồn được',
      () async {
    // A = 10..11, B = 11..12; Ayah 11 dùng chung.
    final planA = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 11);
    final planB = await hifzRepo.createPlan(ayahFrom: 11, ayahTo: 12);
    await seedHifzEvent(itemId: 10, reviewedAt: nowMs());
    await seedHifzEvent(itemId: 11, reviewedAt: nowMs()); // dùng chung
    await seedHifzEvent(itemId: 12, reviewedAt: nowMs());

    final container = makeContainer();
    final a = await container.read(hifzPlanReviewHistoryProvider(planA).future);
    final b = await container.read(hifzPlanReviewHistoryProvider(planB).future);

    expect(a!.totalReviewCount, 2);
    expect(b!.totalReviewCount, 2);
    // 2 + 2 = 4 > 3 sự kiện thật: đây là kết quả ĐÚNG, không phải lỗi
    // đếm trùng — và chính là lý do giao diện không được cộng gộp.
    expect(a.totalReviewCount + b.totalReviewCount, greaterThan(3));
  });

  test(
      'sự kiện xảy ra TRƯỚC khi kế hoạch được tạo VẪN được tính — KHÔNG lọc '
      'theo plan.startedAt (cấm quy gán hồi tố, DR-2026-0026)', () async {
    // Sự kiện ở thời điểm 500; hifzRepo dựng kế hoạch với startedAt=1000.
    await seedHifzEvent(itemId: 10, reviewedAt: 500);
    final planId = await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);

    final container = makeContainer();
    final history =
        await container.read(hifzPlanReviewHistoryProvider(planId).future);

    expect(history!.totalReviewCount, 1);
  });
}
