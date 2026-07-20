import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/features/learning/data/scheduler_repository_impl.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/sm2_scheduling_algorithm.dart';

void main() {
  late UserDatabase db;
  late SchedulerRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000000;
    repo = SchedulerRepositoryImpl(
      db,
      const SM2SchedulingAlgorithm(),
      newId: () => 'card-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  group('syncWithReviewQueue', () {
    test(
        'tạo thẻ mới cho Ayah vừa vào Queue, dùng initialState của '
        'thuật toán', () async {
      await repo.syncWithReviewQueue([10, 20]);

      final cards = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(cards, hasLength(2));
      final byAyah = {for (final c in cards) c.itemId: c};
      expect(byAyah.keys, {10, 20});
      expect(byAyah[10]!.easeFactor, 2.5);
      expect(byAyah[10]!.repetitions, 0);
      expect(byAyah[10]!.state, SrsCardState.newCard);
      expect(byAyah[10]!.itemType, LearningItemType.ayah);
    });

    test('gọi lại với cùng danh sách không tạo thẻ trùng', () async {
      await repo.syncWithReviewQueue([10]);
      await repo.syncWithReviewQueue([10]);

      final cards = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(cards, hasLength(1));
    });

    test(
        'Ayah rời Queue -> thẻ tương ứng bị xoá mềm, không còn trong '
        'watchAllCards', () async {
      await repo.syncWithReviewQueue([10, 20]);
      await repo.syncWithReviewQueue([10]); // 20 rời Queue

      final cards = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(cards, hasLength(1));
      expect(cards.single.itemId, 10);
    });

    test(
        'Ayah quay lại Queue sau khi rời -> hồi sinh thẻ cũ (giữ '
        'nguyên id, KHÔNG insert trùng — UNIQUE(item_type, item_id) '
        'không phân biệt theo deleted_at), reset về trạng thái khởi tạo',
        () async {
      await repo.syncWithReviewQueue([10]);
      final originalId =
          (await repo.watchAllCards(LearningItemType.ayah).first).single.id;

      await repo.syncWithReviewQueue([]); // rời Queue
      expect(await repo.watchAllCards(LearningItemType.ayah).first, isEmpty);

      await repo.syncWithReviewQueue([10]); // quay lại

      final cards = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(cards, hasLength(1));
      expect(cards.single.id, originalId);
      expect(cards.single.itemId, 10);
      expect(cards.single.state, SrsCardState.newCard);
    });
  });

  group('applyReview', () {
    test(
        'uỷ quyền tính toán cho SchedulingAlgorithm và ghi kết quả xuống '
        'persistence', () async {
      await repo.syncWithReviewQueue([10]);
      final before =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      fakeNow = 2000000;
      await repo.applyReview(before.id, ReviewGrade.good);

      final after =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;
      expect(after.repetitions, 1);
      expect(after.intervalDays, 1);
      expect(after.state, SrsCardState.review);
      expect(after.easeFactor, 2.5);
      // dueDate = now (2000000ms) + 1 ngày.
      expect(
        after.dueDate,
        DateTime.fromMillisecondsSinceEpoch(2000000, isUtc: true)
            .add(const Duration(days: 1))
            .millisecondsSinceEpoch,
      );
    });

    test('cardId không tồn tại -> không làm gì, không lỗi', () async {
      await repo.applyReview('khong-ton-tai', ReviewGrade.good);
      final cards = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(cards, isEmpty);
    });

    test('nhiều lần ôn liên tiếp tiến triển đúng thuật toán SM-2', () async {
      await repo.syncWithReviewQueue([10]);
      final id =
          (await repo.watchAllCards(LearningItemType.ayah).first).single.id;

      await repo.applyReview(id, ReviewGrade.good); // rep 1, interval 1
      await repo.applyReview(id, ReviewGrade.good); // rep 2, interval 6
      final after =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;
      expect(after.repetitions, 2);
      expect(after.intervalDays, 6);
    });
  });

  group('watchAllCards', () {
    test('sắp theo hạn ôn gần nhất trước', () async {
      await repo.syncWithReviewQueue([10, 20]);
      final cards = await repo.watchAllCards(LearningItemType.ayah).first;
      final id10 = cards.firstWhere((c) => c.itemId == 10).id;
      final id20 = cards.firstWhere((c) => c.itemId == 20).id;

      // Đẩy hạn ôn của thẻ 10 ra xa hơn thẻ 20.
      fakeNow = 5000;
      await repo.applyReview(id10, ReviewGrade.good); // due = 5000 + 1 ngày
      fakeNow = 1000;
      await repo.applyReview(id20, ReviewGrade.again); // due = 1000 + 1 ngày

      final sorted = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(sorted.first.itemId, 20);
      expect(sorted.last.itemId, 10);
    });
  });
}
