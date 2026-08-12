import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/core/quran/ayah_ordinal.dart';
import 'package:quran_companion/features/hifz/data/hifz_plan_repository_impl.dart';
import 'package:quran_companion/features/hifz/data/hifz_providers.dart';
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';
import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';

/// Logger im lặng — repository nào cũng nhận Logger qua constructor.
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

/// Sprint 7.7a — nền tảng Hifz: bảng kế hoạch, tập hợp lên lịch, tách
/// bạch tuyệt đối với ôn tập thường ('ayah').
void main() {
  late UserDatabase db;
  late HifzPlanRepositoryImpl repo;
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
    repo = HifzPlanRepositoryImpl(
      db,
      _SilentLogger(),
      newId: () => 'plan-${++idCounter}',
      nowMs: () => 1000,
    );
  });

  tearDown(() => db.close());

  group('HifzPlan — miền đoạn', () {
    test('biên hợp lệ: 1 và 6236', () {
      expect(HifzPlan.isValidRange(1, 1), isTrue);
      expect(HifzPlan.isValidRange(1, AyahOrdinal.totalAyahs), isTrue);
      expect(
        HifzPlan.isValidRange(AyahOrdinal.totalAyahs, AyahOrdinal.totalAyahs),
        isTrue,
      );
    });

    test('ngoài miền hoặc đảo ngược -> không hợp lệ', () {
      expect(HifzPlan.isValidRange(0, 5), isFalse);
      expect(HifzPlan.isValidRange(1, AyahOrdinal.totalAyahs + 1), isFalse);
      expect(HifzPlan.isValidRange(10, 9), isFalse);
      expect(HifzPlan.isValidRange(-1, 5), isFalse);
    });

    test('ayahOrdinals trải đúng đoạn, bao gồm cả hai đầu', () {
      const plan = HifzPlan(
        id: 'p',
        ayahFrom: 6223,
        ayahTo: 6226,
        status: HifzPlanStatus.active,
        startedAt: 0,
      );
      expect(plan.ayahCount, 4);
      expect(plan.ayahOrdinals, [6223, 6224, 6225, 6226]);
    });

    test('địa chỉ suy ra thuần từ ordinal — 1 là Al-Fatihah 1:1', () {
      const plan = HifzPlan(
        id: 'p',
        ayahFrom: 1,
        ayahTo: 7,
        status: HifzPlanStatus.active,
        startedAt: 0,
      );
      expect(plan.fromAddress.toString(), '1:1');
      expect(plan.toAddress.toString(), '1:7');
    });
  });

  group('HifzPlanRepository — lưu trữ', () {
    test('tạo kế hoạch: mặc định active, chưa hoàn thành', () async {
      final id = await repo.createPlan(ayahFrom: 1, ayahTo: 7);
      final plans = await repo.watchAllPlans().first;

      expect(plans, hasLength(1));
      expect(plans.single.id, id);
      expect(plans.single.ayahFrom, 1);
      expect(plans.single.ayahTo, 7);
      expect(plans.single.status, HifzPlanStatus.active);
      expect(plans.single.completedAt, isNull);
    });

    test('đoạn không hợp lệ -> ArgumentError, không ghi dòng nào', () async {
      await expectLater(
        repo.createPlan(ayahFrom: 10, ayahTo: 9),
        throwsArgumentError,
      );
      await expectLater(
        repo.createPlan(ayahFrom: 0, ayahTo: 5),
        throwsArgumentError,
      );
      expect(await repo.watchAllPlans().first, isEmpty);
    });

    test('hoàn thành đóng dấu completed_at; rời completed xoá dấu đó',
        () async {
      final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);

      await repo.setStatus(id, HifzPlanStatus.completed);
      var plan = (await repo.watchAllPlans().first).single;
      expect(plan.status, HifzPlanStatus.completed);
      expect(plan.completedAt, 1000);

      await repo.setStatus(id, HifzPlanStatus.active);
      plan = (await repo.watchAllPlans().first).single;
      expect(plan.status, HifzPlanStatus.active);
      expect(plan.completedAt, isNull);
    });

    test('xoá mềm biến kế hoạch khỏi danh sách còn sống', () async {
      final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
      await repo.deletePlan(id);
      expect(await repo.watchAllPlans().first, isEmpty);
    });

    test('kế hoạch trùng khít và chồng lấn đều được phép', () async {
      await repo.createPlan(ayahFrom: 1, ayahTo: 7); // Al-Fatihah
      await repo.createPlan(ayahFrom: 1, ayahTo: 7); // trùng khít
      await repo.createPlan(ayahFrom: 5, ayahTo: 10); // chồng lấn
      expect(await repo.watchAllPlans().first, hasLength(3));
    });
  });

  group('Tập hợp lên lịch (union)', () {
    test('chồng lấn khử trùng lặp — mỗi Ayah đúng một lần', () async {
      await repo.createPlan(ayahFrom: 1, ayahTo: 7);
      await repo.createPlan(ayahFrom: 5, ayahTo: 10);
      final container = makeContainer();

      final union = await container.read(hifzUnionAyahIdsProvider.future);

      expect(union, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    });

    test('kế hoạch tạm dừng VÀ hoàn thành vẫn ở trong tập hợp', () async {
      final paused = await repo.createPlan(ayahFrom: 1, ayahTo: 2);
      final done = await repo.createPlan(ayahFrom: 3, ayahTo: 4);
      await repo.setStatus(paused, HifzPlanStatus.paused);
      await repo.setStatus(done, HifzPlanStatus.completed);
      final container = makeContainer();

      expect(
        await container.read(hifzUnionAyahIdsProvider.future),
        [1, 2, 3, 4],
        reason: 'Rút khỏi tập hợp sẽ xoá mềm thẻ và RESET tiến trình',
      );
    });

    test('xoá kế hoạch đưa Ayah của nó RA KHỎI tập hợp', () async {
      final a = await repo.createPlan(ayahFrom: 1, ayahTo: 2);
      await repo.createPlan(ayahFrom: 3, ayahTo: 4);
      await repo.deletePlan(a);
      final container = makeContainer();

      expect(await container.read(hifzUnionAyahIdsProvider.future), [3, 4]);
    });

    test('Ayah đang hoạt động chỉ gồm kế hoạch active', () async {
      final paused = await repo.createPlan(ayahFrom: 1, ayahTo: 2);
      final done = await repo.createPlan(ayahFrom: 3, ayahTo: 4);
      await repo.createPlan(ayahFrom: 5, ayahTo: 6);
      await repo.setStatus(paused, HifzPlanStatus.paused);
      await repo.setStatus(done, HifzPlanStatus.completed);
      final container = makeContainer();

      expect(
        await container.read(hifzActiveAyahIdsProvider.future),
        {5, 6},
      );
    });
  });

  group('Đồng bộ thẻ Hifz', () {
    test('đồng bộ tạo đúng thẻ item_type=hifz cho cả tập hợp', () async {
      await repo.createPlan(ayahFrom: 1, ayahTo: 3);
      final container = makeContainer();

      await container.read(hifzSchedulerSyncProvider.future);

      final cards = await container
          .read(hifzSchedulerRepositoryProvider)
          .watchAllCards(LearningItemType.hifz)
          .first;
      expect(cards.map((c) => c.itemId).toList()..sort(), [1, 2, 3]);
    });

    test('tạm dừng KHÔNG xoá thẻ, chỉ khiến chúng không đến hạn', () async {
      final id = await repo.createPlan(ayahFrom: 1, ayahTo: 2);
      var container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);
      expect(await container.read(dueHifzCardsProvider.future), hasLength(2));

      await repo.setStatus(id, HifzPlanStatus.paused);
      container = makeContainer();

      // Thẻ vẫn còn nguyên...
      final cards = await container
          .read(hifzSchedulerRepositoryProvider)
          .watchAllCards(LearningItemType.hifz)
          .first;
      expect(cards, hasLength(2));
      // ...nhưng không được hỏi tới.
      expect(await container.read(dueHifzCardsProvider.future), isEmpty);
    });

    test('hoàn thành GIỮ nguyên trạng thái lịch trình đã tích luỹ', () async {
      final id = await repo.createPlan(ayahFrom: 1, ayahTo: 1);
      var container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);

      final scheduler = container.read(hifzSchedulerRepositoryProvider);
      final card =
          (await scheduler.watchAllCards(LearningItemType.hifz).first).single;
      await scheduler.applyReview(card.id, ReviewGrade.good);
      final reviewed =
          (await scheduler.watchAllCards(LearningItemType.hifz).first).single;
      expect(reviewed.repetitions, 1);

      await repo.setStatus(id, HifzPlanStatus.completed);
      container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);

      final afterCompletion = (await container
              .read(hifzSchedulerRepositoryProvider)
              .watchAllCards(LearningItemType.hifz)
              .first)
          .single;
      expect(afterCompletion.repetitions, 1, reason: 'không được reset');
      expect(afterCompletion.dueDate, reviewed.dueDate);
    });

    test(
        'xoá kế hoạch xoá mềm thẻ; thêm lại RESET theo đúng ngữ nghĩa '
        'sync hiện có (KHÔNG phải "tiếp tục")', () async {
      final id = await repo.createPlan(ayahFrom: 1, ayahTo: 1);
      var container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);
      final scheduler = container.read(hifzSchedulerRepositoryProvider);
      final card =
          (await scheduler.watchAllCards(LearningItemType.hifz).first).single;
      await scheduler.applyReview(card.id, ReviewGrade.good);

      await repo.deletePlan(id);
      container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);
      expect(
        await container
            .read(hifzSchedulerRepositoryProvider)
            .watchAllCards(LearningItemType.hifz)
            .first,
        isEmpty,
      );

      await repo.createPlan(ayahFrom: 1, ayahTo: 1);
      container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);
      final revived = (await container
              .read(hifzSchedulerRepositoryProvider)
              .watchAllCards(LearningItemType.hifz)
              .first)
          .single;
      expect(revived.repetitions, 0);
      expect(revived.state, SrsCardState.newCard);
    });
  });

  group('Tách bạch với ôn tập thường (item_type=ayah)', () {
    test('đồng bộ Hifz KHÔNG tạo, đổi hay xoá thẻ ayah nào', () async {
      final container = makeContainer();

      // Ôn tập thường đã có thẻ cho Ayah 1 và 2.
      await container
          .read(schedulerRepositoryProvider)
          .syncItemsForType(LearningItemType.ayah, [1, 2]);
      final before = await container
          .read(schedulerRepositoryProvider)
          .watchAllCards(LearningItemType.ayah)
          .first;
      expect(before, hasLength(2));

      // Hifz cam kết Ayah 2 và 3 — giao nhau ở Ayah 2.
      await repo.createPlan(ayahFrom: 2, ayahTo: 3);
      await container.read(hifzSchedulerSyncProvider.future);

      final after = await container
          .read(schedulerRepositoryProvider)
          .watchAllCards(LearningItemType.ayah)
          .first;
      expect(after.map((c) => c.id).toSet(), before.map((c) => c.id).toSet());
      for (final card in after) {
        final old = before.firstWhere((c) => c.id == card.id);
        expect(card.dueDate, old.dueDate);
        expect(card.repetitions, old.repetitions);
        expect(card.easeFactor, old.easeFactor);
        expect(card.state, old.state);
      }
    });

    test(
        'đồng bộ ôn tập thường KHÔNG xoá thẻ Hifz (Ayah không nằm trong '
        'hàng đợi ôn tập)', () async {
      await repo.createPlan(ayahFrom: 5, ayahTo: 6);
      final container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);

      // Hàng đợi ôn tập thường hoàn toàn không chứa 5, 6.
      await container
          .read(schedulerRepositoryProvider)
          .syncItemsForType(LearningItemType.ayah, [1]);

      final hifzCards = await container
          .read(hifzSchedulerRepositoryProvider)
          .watchAllCards(LearningItemType.hifz)
          .first;
      expect(hifzCards.map((c) => c.itemId).toList()..sort(), [5, 6]);
    });

    test('cùng một Ayah có HAI thẻ độc lập, ôn bên này không đụng bên kia',
        () async {
      await repo.createPlan(ayahFrom: 1, ayahTo: 1);
      final container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);
      await container
          .read(schedulerRepositoryProvider)
          .syncItemsForType(LearningItemType.ayah, [1]);

      final hifzCard = (await container
              .read(hifzSchedulerRepositoryProvider)
              .watchAllCards(LearningItemType.hifz)
              .first)
          .single;
      final casualBefore = (await container
              .read(schedulerRepositoryProvider)
              .watchAllCards(LearningItemType.ayah)
              .first)
          .single;
      expect(hifzCard.id, isNot(casualBefore.id));

      // Ôn thẻ Hifz.
      await container
          .read(hifzSchedulerRepositoryProvider)
          .applyReview(hifzCard.id, ReviewGrade.good);

      final casualAfter = (await container
              .read(schedulerRepositoryProvider)
              .watchAllCards(LearningItemType.ayah)
              .first)
          .single;
      expect(casualAfter.repetitions, casualBefore.repetitions);
      expect(casualAfter.dueDate, casualBefore.dueDate);
      expect(casualAfter.state, casualBefore.state);
    });

    test(
        'thẻ Hifz dùng lịch Hifz: chặn ở 30 ngày, trong khi thẻ ayah cùng '
        'trạng thái đi tới 38', () async {
      await repo.createPlan(ayahFrom: 1, ayahTo: 1);
      final container = makeContainer();
      await container.read(hifzSchedulerSyncProvider.future);
      await container
          .read(schedulerRepositoryProvider)
          .syncItemsForType(LearningItemType.ayah, [1]);

      final hifzCard = (await container
              .read(hifzSchedulerRepositoryProvider)
              .watchAllCards(LearningItemType.hifz)
              .first)
          .single;
      final casualCard = (await container
              .read(schedulerRepositoryProvider)
              .watchAllCards(LearningItemType.ayah)
              .first)
          .single;

      // Đưa cả hai về cùng một trạng thái ngay trước bậc 38.
      for (final id in [hifzCard.id, casualCard.id]) {
        await (db.update(db.srsCards)..where((t) => t.id.equals(id))).write(
          const SrsCardsCompanion(
            easeFactor: Value(2.5),
            intervalDays: Value(15),
            repetitions: Value(3),
            state: Value('review'),
          ),
        );
      }

      await container
          .read(hifzSchedulerRepositoryProvider)
          .applyReview(hifzCard.id, ReviewGrade.good);
      await container
          .read(schedulerRepositoryProvider)
          .applyReview(casualCard.id, ReviewGrade.good);

      final hifzAfter = (await container
              .read(hifzSchedulerRepositoryProvider)
              .watchAllCards(LearningItemType.hifz)
              .first)
          .single;
      final casualAfter = (await container
              .read(schedulerRepositoryProvider)
              .watchAllCards(LearningItemType.ayah)
              .first)
          .single;

      expect(hifzAfter.intervalDays, 30);
      expect(casualAfter.intervalDays, 38);
    });
  });
}
