import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/sm2_scheduling_algorithm.dart';
import 'package:quran_companion/features/quran/data/user_content_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_annotation.dart';

SrsCard _card({
  required String id,
  required int itemId,
  required int dueDate,
}) =>
    SrsCard(
      id: id,
      itemType: LearningItemType.ayah,
      itemId: itemId,
      easeFactor: 2.5,
      intervalDays: 1,
      repetitions: 1,
      dueDate: dueDate,
      state: SrsCardState.review,
    );

/// Chờ đến khi [check] thoả [satisfies], polling với delay 0 (chỉ
/// nhường event loop, không phụ thuộc thời gian thật) — tránh phải
/// đồng bộ chính xác với thời điểm StreamProvider phát giá trị mới.
Future<T> _waitFor<T>(
  Future<T> Function() check,
  bool Function(T) satisfies, {
  int maxTries = 500,
}) async {
  for (var i = 0; i < maxTries; i++) {
    final value = await check();
    if (satisfies(value)) return value;
    await Future<void>.delayed(Duration.zero);
  }
  throw StateError('condition không thoả sau $maxTries lần thử');
}

void main() {
  group('selectDueCardsOrdered (hàm thuần)', () {
    test('chỉ giữ thẻ đến hạn (due_date <= now), bỏ thẻ chưa đến hạn', () {
      final now = DateTime.utc(2026, 7, 20);
      final nowMs = now.millisecondsSinceEpoch;
      final cards = [
        _card(id: 'a', itemId: 1, dueDate: nowMs - 1000), // quá hạn
        _card(id: 'b', itemId: 2, dueDate: nowMs), // đúng hạn
        _card(id: 'c', itemId: 3, dueDate: nowMs + 1000), // chưa đến hạn
      ];

      final result = selectDueCardsOrdered(cards, now);
      expect(result.map((c) => c.id), ['a', 'b']);
    });

    test('sắp theo due_date tăng dần', () {
      final now = DateTime.utc(2026, 7, 20);
      final nowMs = now.millisecondsSinceEpoch;
      final cards = [
        _card(id: 'late', itemId: 1, dueDate: nowMs - 100),
        _card(id: 'early', itemId: 2, dueDate: nowMs - 500),
        _card(id: 'mid', itemId: 3, dueDate: nowMs - 300),
      ];

      final result = selectDueCardsOrdered(cards, now);
      expect(result.map((c) => c.id), ['early', 'mid', 'late']);
    });

    test('thứ tự ổn định khi due_date bằng nhau (tie-break theo id)', () {
      final now = DateTime.utc(2026, 7, 20);
      final nowMs = now.millisecondsSinceEpoch;
      final cards = [
        _card(id: 'z', itemId: 1, dueDate: nowMs - 100),
        _card(id: 'a', itemId: 2, dueDate: nowMs - 100),
        _card(id: 'm', itemId: 3, dueDate: nowMs - 100),
      ];

      final first = selectDueCardsOrdered(cards, now);
      final second = selectDueCardsOrdered(List.of(cards.reversed), now);
      expect(first.map((c) => c.id), ['a', 'm', 'z']);
      // Cùng input (bất kể thứ tự đưa vào) -> luôn cùng một kết quả.
      expect(second.map((c) => c.id), first.map((c) => c.id));
    });

    test('khử trùng lặp theo id, giữ lần xuất hiện đến hạn sớm nhất', () {
      final now = DateTime.utc(2026, 7, 20);
      final nowMs = now.millisecondsSinceEpoch;
      final cards = [
        _card(id: 'dup', itemId: 1, dueDate: nowMs - 500),
        _card(id: 'dup', itemId: 1, dueDate: nowMs - 100),
        _card(id: 'unique', itemId: 2, dueDate: nowMs - 200),
      ];

      final result = selectDueCardsOrdered(cards, now);
      expect(result, hasLength(2));
      expect(result.where((c) => c.id == 'dup'), hasLength(1));
      expect(
        result.firstWhere((c) => c.id == 'dup').dueDate,
        nowMs - 500,
        reason: 'giữ bản có due_date sớm hơn (xuất hiện trước sau khi sắp)',
      );
    });

    test('danh sách rỗng -> kết quả rỗng', () {
      expect(selectDueCardsOrdered([], DateTime.now()), isEmpty);
    });
  });

  group('provider layer (ProviderContainer + UserDatabase thật in-memory)', () {
    late UserDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = UserDatabase(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [userDatabaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() {
      container.dispose();
      db.close();
    });

    test('schedulingAlgorithmProvider mặc định là SM2SchedulingAlgorithm', () {
      expect(
        container.read(schedulingAlgorithmProvider),
        isA<SM2SchedulingAlgorithm>(),
      );
    });

    test(
        'schedulerRepositoryProvider dùng chung UserDatabase với '
        'userContentRepositoryProvider (cùng 1 kết nối)', () async {
      final userRepo = container.read(userContentRepositoryProvider);
      await userRepo.setStatus(1, AyahStatus.review);

      // Đọc thẳng qua bảng ayah_statuses của CÙNG db đã override —
      // xác nhận 2 repository chia sẻ 1 UserDatabase, không phải 2 kết
      // nối độc lập (điều kiện cần để orchestration đọc thấy ghi mới).
      final rows = await db.select(db.ayahStatuses).get();
      expect(rows, hasLength(1));
      expect(rows.single.status, 'review');
    });

    test(
        'schedulerSyncProvider: Ayah vào Revision Queue -> tự tạo thẻ SRS '
        'tương ứng (orchestration, không gọi syncWithReviewQueue thủ công)',
        () async {
      // Giữ provider autoDispose sống trong suốt test.
      final sub = container.listen(schedulerSyncProvider, (_, __) {});
      addTearDown(sub.close);

      final userRepo = container.read(userContentRepositoryProvider);
      await userRepo.setStatus(10, AyahStatus.review);

      final cards = await _waitFor(
        () => container
            .read(schedulerRepositoryProvider)
            .watchAllCards(LearningItemType.ayah)
            .first,
        (cards) => cards.any((c) => c.itemId == 10),
      );
      expect(cards.map((c) => c.itemId), contains(10));
    });

    test(
        'schedulerSyncProvider: Ayah rời Revision Queue -> thẻ SRS bị xoá '
        'mềm (đồng bộ cả hai chiều)', () async {
      final sub = container.listen(schedulerSyncProvider, (_, __) {});
      addTearDown(sub.close);

      final userRepo = container.read(userContentRepositoryProvider);
      await userRepo.setStatus(10, AyahStatus.review);
      await _waitFor(
        () => container
            .read(schedulerRepositoryProvider)
            .watchAllCards(LearningItemType.ayah)
            .first,
        (cards) => cards.any((c) => c.itemId == 10),
      );

      await userRepo.setStatus(10, AyahStatus.none);
      final cards = await _waitFor(
        () => container
            .read(schedulerRepositoryProvider)
            .watchAllCards(LearningItemType.ayah)
            .first,
        (cards) => cards.isEmpty,
      );
      expect(cards, isEmpty);
    });

    test(
        'schedulerSyncProvider không tạo thẻ trùng khi Revision Queue phát '
        'lại (thao tác khác không đụng Ayah đang review) — idempotent',
        () async {
      final sub = container.listen(schedulerSyncProvider, (_, __) {});
      addTearDown(sub.close);

      final userRepo = container.read(userContentRepositoryProvider);
      await userRepo.setStatus(20, AyahStatus.review);
      await _waitFor(
        () => container
            .read(schedulerRepositoryProvider)
            .watchAllCards(LearningItemType.ayah)
            .first,
        (cards) => cards.any((c) => c.itemId == 20),
      );

      // Thao tác khác khiến watchAllReviewAyahs phát lại (cùng danh
      // sách review) -> orchestration chạy lại syncWithReviewQueue.
      await userRepo.setStatus(21, AyahStatus.learning);
      await userRepo.toggleFavorite(20);
      await Future<void>.delayed(Duration.zero);

      final cards = await container
          .read(schedulerRepositoryProvider)
          .watchAllCards(LearningItemType.ayah)
          .first;
      expect(cards.where((c) => c.itemId == 20), hasLength(1));
    });

    test(
        'dueReviewCardsProvider: thẻ mới tạo (due ngay) xuất hiện trong '
        'danh sách đến hạn; sau khi ôn "good" thì biến mất (due tương lai)',
        () async {
      final sub = container.listen(dueReviewCardsProvider, (_, __) {});
      addTearDown(sub.close);

      final userRepo = container.read(userContentRepositoryProvider);
      await userRepo.setStatus(30, AyahStatus.review);

      final beforeReview = await _waitFor<List<SrsCard>>(
        () async =>
            container.read(dueReviewCardsProvider).valueOrNull ?? const [],
        (cards) => cards.any((c) => c.itemId == 30),
      );
      final card = beforeReview.firstWhere((c) => c.itemId == 30);

      await container
          .read(schedulerRepositoryProvider)
          .applyReview(card.id, ReviewGrade.good);

      final afterReview = await _waitFor<List<SrsCard>>(
        () async =>
            container.read(dueReviewCardsProvider).valueOrNull ?? const [],
        (cards) => !cards.any((c) => c.itemId == 30),
      );
      expect(afterReview.map((c) => c.itemId), isNot(contains(30)));
    });
  });
}
