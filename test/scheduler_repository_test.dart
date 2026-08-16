import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/learning/data/scheduler_repository_impl.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/hifz_scheduling_algorithm.dart';
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
      const ConsoleLogger(),
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

  group('syncItemsForType (Sprint 13 Phase 2 — tổng quát hoá cho Flashcard)',
      () {
    test(
        'itemType=lemma: tạo/hồi sinh/xoá mềm hệt syncWithReviewQueue, '
        'độc lập với thẻ ayah', () async {
      await repo.syncWithReviewQueue([10]); // ayah, không liên quan
      await repo.syncItemsForType(LearningItemType.lemma, [100, 200]);

      final lemmaCards = await repo.watchAllCards(LearningItemType.lemma).first;
      expect(lemmaCards.map((c) => c.itemId).toSet(), {100, 200});
      expect(
        lemmaCards.every((c) => c.itemType == LearningItemType.lemma),
        isTrue,
      );

      // Thẻ ayah không bị đụng tới.
      final ayahCards = await repo.watchAllCards(LearningItemType.ayah).first;
      expect(ayahCards.map((c) => c.itemId).toSet(), {10});
    });

    test('lemma rời danh sách -> thẻ tương ứng bị xoá mềm', () async {
      await repo.syncItemsForType(LearningItemType.lemma, [100, 200]);
      await repo.syncItemsForType(LearningItemType.lemma, [100]);

      final cards = await repo.watchAllCards(LearningItemType.lemma).first;
      expect(cards, hasLength(1));
      expect(cards.single.itemId, 100);
    });

    test(
        'lemma quay lại sau khi rời -> hồi sinh thẻ cũ (giữ nguyên id), '
        'không insert trùng UNIQUE(item_type, item_id)', () async {
      await repo.syncItemsForType(LearningItemType.lemma, [100]);
      final originalId =
          (await repo.watchAllCards(LearningItemType.lemma).first).single.id;

      await repo.syncItemsForType(LearningItemType.lemma, []);
      await repo.syncItemsForType(LearningItemType.lemma, [100]);

      final cards = await repo.watchAllCards(LearningItemType.lemma).first;
      expect(cards, hasLength(1));
      expect(cards.single.id, originalId);
    });

    test('applyReview hoạt động bình thường trên thẻ lemma', () async {
      await repo.syncItemsForType(LearningItemType.lemma, [100]);
      final id =
          (await repo.watchAllCards(LearningItemType.lemma).first).single.id;

      await repo.applyReview(id, ReviewGrade.good);

      final after =
          (await repo.watchAllCards(LearningItemType.lemma).first).single;
      expect(after.repetitions, 1);
      expect(after.state, SrsCardState.review);
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

  group('review_events (Sprint D6.6 — DR-2026-0024, ghi sự kiện bất biến)', () {
    test('ayah: applyReview ghi ĐÚNG MỘT review_events row', () async {
      await repo.syncWithReviewQueue([10]);
      final card =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      await repo.applyReview(card.id, ReviewGrade.good);

      final rows = await db.select(db.reviewEvents).get();
      expect(rows, hasLength(1));
      expect(rows.single.itemType, 'ayah');
    });

    test(
        'hifz: applyReview ghi ĐÚNG MỘT review_events row, algorithm_id '
        '= hifz-sm2-capped-v1', () async {
      final hifzRepo = SchedulerRepositoryImpl(
        db,
        const HifzSchedulingAlgorithm(),
        const ConsoleLogger(),
        newId: () => 'hifz-card-${++idCounter}',
        nowMs: () => fakeNow,
      );
      await hifzRepo.syncItemsForType(LearningItemType.hifz, [7]);
      final card =
          (await hifzRepo.watchAllCards(LearningItemType.hifz).first).single;

      await hifzRepo.applyReview(card.id, ReviewGrade.good);

      final rows = await db.select(db.reviewEvents).get();
      expect(rows, hasLength(1));
      expect(rows.single.itemType, 'hifz');
      expect(rows.single.algorithmId, 'hifz-sm2-capped-v1');
    });

    test('lemma: applyReview KHÔNG ghi review_events nào (Quyết định 3)',
        () async {
      await repo.syncItemsForType(LearningItemType.lemma, [100]);
      final card =
          (await repo.watchAllCards(LearningItemType.lemma).first).single;

      await repo.applyReview(card.id, ReviewGrade.good);

      final rows = await db.select(db.reviewEvents).get();
      expect(rows, isEmpty);
    });

    test('cardId không tồn tại -> không ghi review_events nào', () async {
      await repo.applyReview('khong-ton-tai', ReviewGrade.good);
      final rows = await db.select(db.reviewEvents).get();
      expect(rows, isEmpty);
    });

    test(
        'nội dung sự kiện khớp đúng card_id/item_type/item_id/grade/'
        'reviewed_at/algorithm_id', () async {
      await repo.syncWithReviewQueue([10]);
      final card =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      fakeNow = 2000000;
      await repo.applyReview(card.id, ReviewGrade.good);

      final event = (await db.select(db.reviewEvents).get()).single;
      expect(event.cardId, card.id);
      expect(event.itemType, 'ayah');
      expect(event.itemId, 10);
      expect(event.grade, 'good');
      expect(event.reviewedAt, 2000000);
      expect(event.algorithmId, 'sm2-v1');
    });

    test(
        'reviewed_at == srs_cards.updated_at cho cùng lần ôn (bất biến '
        'I3, DR-2026-0024)', () async {
      await repo.syncWithReviewQueue([10]);
      final card =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      fakeNow = 3000000;
      await repo.applyReview(card.id, ReviewGrade.good);

      final event = (await db.select(db.reviewEvents).get()).single;
      final updatedCard =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;
      expect(event.reviewedAt, updatedCard.updatedAtMs);
      expect(event.reviewedAt, 3000000);
    });

    test('before_*/after_* phản ánh đúng trạng thái trước/sau lần ôn',
        () async {
      await repo.syncWithReviewQueue([10]);
      final card =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      await repo.applyReview(card.id, ReviewGrade.good);

      final event = (await db.select(db.reviewEvents).get()).single;
      expect(event.beforeState, 'new');
      expect(event.beforeRepetitions, 0);
      expect(event.beforeEaseFactor, 2.5);
      expect(event.afterState, 'review');
      expect(event.afterRepetitions, 1);
      expect(event.afterIntervalDays, 1);
    });

    test(
        'nguyên tử: PRIMARY KEY trùng ở review_events khiến CẢ update '
        'srs_cards LẪN insert review_events của lần ôn thứ hai đều '
        'KHÔNG được ghi (rollback toàn bộ transaction)', () async {
      await repo.syncWithReviewQueue([10]);
      final card =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      // newId CỐ ĐỊNH — mô phỏng một PRIMARY KEY va chạm THẬT, dùng
      // ĐÚNG điểm tiêm sẵn có (SchedulerRepositoryImpl.newId), không
      // fake executor/database nào — theo đúng hướng D6.6 đã duyệt.
      final collidingRepo = SchedulerRepositoryImpl(
        db,
        const SM2SchedulingAlgorithm(),
        const ConsoleLogger(),
        newId: () => 'fixed-review-event-id',
        nowMs: () => fakeNow,
      );

      // Lần ôn đầu — 'fixed-review-event-id' chưa tồn tại -> thành công.
      await collidingRepo.applyReview(card.id, ReviewGrade.good);
      final beforeSecondAttempt =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      // Lần ôn thứ hai — UPDATE srs_cards chạy trong transaction, rồi
      // INSERT review_events với CÙNG id -> vi phạm PRIMARY KEY thật
      // -> ném lỗi -> Drift rollback TOÀN BỘ transaction, kể cả UPDATE
      // đã chạy trước đó trong CÙNG transaction.
      await expectLater(
        collidingRepo.applyReview(card.id, ReviewGrade.good),
        throwsA(anything),
      );

      final afterFailedAttempt =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;
      // srs_cards PHẢI giữ NGUYÊN trạng thái của lần ôn đầu — UPDATE
      // của lần ôn thứ hai đã bị rollback cùng INSERT thất bại.
      expect(afterFailedAttempt.repetitions, beforeSecondAttempt.repetitions);
      expect(
        afterFailedAttempt.intervalDays,
        beforeSecondAttempt.intervalDays,
      );
      expect(afterFailedAttempt.dueDate, beforeSecondAttempt.dueDate);

      // Vẫn ĐÚNG MỘT review_events row (từ lần ôn đầu) — lần thứ hai
      // không để lại dấu vết nào, kể cả review_events lẫn srs_cards.
      final rows = await db.select(db.reviewEvents).get();
      expect(rows, hasLength(1));
    });

    test(
        'bất biến: hai lần ôn liên tiếp tạo hai sự kiện, sự kiện ĐẦU '
        'KHÔNG bị sửa bởi lần ôn thứ hai (append-only)', () async {
      await repo.syncWithReviewQueue([10]);
      final card =
          (await repo.watchAllCards(LearningItemType.ayah).first).single;

      fakeNow = 1000000;
      await repo.applyReview(card.id, ReviewGrade.good);
      final firstEventBefore = (await db.select(db.reviewEvents).get()).single;

      fakeNow = 2000000;
      await repo.applyReview(card.id, ReviewGrade.good);

      final rows = await db.select(db.reviewEvents).get();
      expect(rows, hasLength(2));

      final firstEventAfter =
          rows.firstWhere((r) => r.id == firstEventBefore.id);
      // Sự kiện đầu KHÔNG thay đổi sau lần ôn thứ hai.
      expect(firstEventAfter.reviewedAt, firstEventBefore.reviewedAt);
      expect(firstEventAfter.beforeState, firstEventBefore.beforeState);
      expect(firstEventAfter.afterState, firstEventBefore.afterState);
      expect(
        firstEventAfter.afterRepetitions,
        firstEventBefore.afterRepetitions,
      );

      // Sự kiện thứ hai's before khớp đúng sự kiện đầu's after — chuỗi
      // liên tục, không gián đoạn (chưa qua syncItemsForType revive).
      final secondEvent = rows.firstWhere((r) => r.id != firstEventBefore.id);
      expect(secondEvent.beforeState, firstEventAfter.afterState);
      expect(
        secondEvent.beforeRepetitions,
        firstEventAfter.afterRepetitions,
      );
    });
  });
}
