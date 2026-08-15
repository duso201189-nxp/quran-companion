import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';
import 'package:quran_companion/features/hifz/domain/hifz_progress_calculator.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';

/// Sprint D6.4 — computeHifzOverallProgress: hàm THUẦN tính ảnh chụp
/// tiến độ gộp nhiều kế hoạch Hifz active + danh sách [SrsCard] đã lọc
/// sẵn (đã khử trùng lặp theo `hifzActiveAyahIdsProvider`). Không DB,
/// không Riverpod — cùng kỷ luật hifz_progress_calculator_test.dart.
void main() {
  final now = DateTime.utc(2026, 8, 15);
  final nowMs = now.millisecondsSinceEpoch;

  HifzPlan plan({
    required String id,
    required int from,
    required int to,
    HifzPlanStatus status = HifzPlanStatus.active,
  }) =>
      HifzPlan(
        id: id,
        ayahFrom: from,
        ayahTo: to,
        status: status,
        startedAt: 1000,
      );

  SrsCard card({
    required int itemId,
    required SrsCardState state,
    int repetitions = 0,
    double easeFactor = 2.5,
    int intervalDays = 0,
    int? dueDate,
  }) =>
      SrsCard(
        id: 'card-$itemId',
        itemType: LearningItemType.hifz,
        itemId: itemId,
        easeFactor: easeFactor,
        intervalDays: intervalDays,
        repetitions: repetitions,
        dueDate: dueDate ?? nowMs,
        state: state,
        updatedAtMs: nowMs,
      );

  group('không có kế hoạch active nào', () {
    test(
        'mọi bộ đếm = 0, không có hạn kế tiếp, không có trung bình '
        '— KHÔNG lỗi', () {
      final progress = computeHifzOverallProgress(
        activePlans: const [],
        cards: const [],
        now: now,
      );

      expect(progress.activePlanCount, 0);
      expect(progress.totalPlannedAyahs, 0);
      expect(progress.trackedCardCount, 0);
      expect(
        progress.stateCounts,
        {
          SrsCardState.newCard: 0,
          SrsCardState.learning: 0,
          SrsCardState.review: 0,
          SrsCardState.lapsed: 0,
        },
      );
      expect(progress.dueNowCount, 0);
      expect(progress.nextDueAtMs, isNull);
      expect(progress.reviewedCardCount, 0);
      expect(progress.averageEaseFactor, isNull);
      expect(progress.averageIntervalDays, isNull);
    });
  });

  group('một kế hoạch active', () {
    test(
        'kết quả khớp đúng ngữ nghĩa computeHifzPlanProgress cho '
        'CÙNG kế hoạch đó', () {
      final onlyPlan = plan(id: 'p1', from: 1, to: 3);
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard),
        card(itemId: 2, state: SrsCardState.review, repetitions: 1),
        card(itemId: 3, state: SrsCardState.lapsed, repetitions: 2),
      ];

      final overall = computeHifzOverallProgress(
        activePlans: [onlyPlan],
        cards: cards,
        now: now,
      );
      final perPlan = computeHifzPlanProgress(
        plan: onlyPlan,
        cards: cards,
        now: now,
      );

      expect(overall.activePlanCount, 1);
      expect(overall.totalPlannedAyahs, perPlan.totalAyahCount);
      expect(overall.trackedCardCount, perPlan.trackedCardCount);
      expect(overall.stateCounts, perPlan.stateCounts);
      expect(overall.dueNowCount, perPlan.dueNowCount);
      expect(overall.nextDueAtMs, perPlan.nextDueAtMs);
      expect(overall.reviewedCardCount, perPlan.reviewedCardCount);
      expect(overall.averageEaseFactor, perPlan.averageEaseFactor);
      expect(overall.averageIntervalDays, perPlan.averageIntervalDays);
    });
  });

  group('nhiều kế hoạch active KHÔNG chồng lấn', () {
    test('planCount/totalPlannedAyahs/trackedCardCount cộng đúng', () {
      final plans = [
        plan(id: 'p1', from: 1, to: 3),
        plan(id: 'p2', from: 50, to: 51),
      ];
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard),
        card(itemId: 2, state: SrsCardState.newCard),
        card(itemId: 3, state: SrsCardState.newCard),
        card(itemId: 50, state: SrsCardState.newCard),
        card(itemId: 51, state: SrsCardState.newCard),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.activePlanCount, 2);
      expect(progress.totalPlannedAyahs, 5);
      expect(progress.trackedCardCount, 5);
    });
  });

  group('kế hoạch active CHỒNG LẤN', () {
    test(
        'totalPlannedAyahs đếm Ayah chung MỘT lần, KHÔNG cộng dồn '
        'ayahCount của từng kế hoạch', () {
      // p1: 1..5 (5 Ayah), p2: 3..7 (5 Ayah) — chồng lấn 3..5 (3 Ayah).
      // Hợp (union) = 1..7 = 7 Ayah DUY NHẤT, KHÔNG phải 5+5=10.
      final plans = [
        plan(id: 'p1', from: 1, to: 5),
        plan(id: 'p2', from: 3, to: 7),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: const [],
        now: now,
      );

      expect(progress.activePlanCount, 2);
      expect(progress.totalPlannedAyahs, 7);
    });

    test(
        'Ayah chồng lấn chỉ có ĐÚNG MỘT thẻ SRS (đúng UNIQUE(item_type, '
        'item_id)) -> trackedCardCount đếm thẻ đó MỘT lần, không double-'
        'count dù thuộc cả hai kế hoạch', () {
      final plans = [
        plan(id: 'p1', from: 1, to: 5),
        plan(id: 'p2', from: 3, to: 7),
      ];
      // Nơi gọi (Provider) đã lọc theo Set ordinal active — Ayah 3..5
      // (thuộc CẢ hai plan) chỉ xuất hiện ĐÚNG MỘT LẦN trong [cards],
      // đúng cách hifzActiveAyahIdsProvider tạo Set. Mô phỏng đúng hợp
      // đồng đó ở đây: 7 thẻ cho 7 Ayah duy nhất (1..7), không phải 10.
      final cards = [
        for (var ordinal = 1; ordinal <= 7; ordinal++)
          card(itemId: ordinal, state: SrsCardState.newCard),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.trackedCardCount, 7);
      expect(progress.stateCounts[SrsCardState.newCard], 7);
    });
  });

  group('kế hoạch paused/completed bị loại trừ', () {
    test(
        'kế hoạch paused KHÔNG được truyền vào activePlans -> không '
        'góp vào totalPlannedAyahs', () {
      // Nơi gọi (hifzActiveAyahIdsProvider) đã lọc status == active
      // TRƯỚC khi gọi hàm này — mô phỏng đúng hợp đồng đó: chỉ truyền
      // kế hoạch active, kế hoạch paused không xuất hiện trong danh
      // sách activePlans dù vẫn "còn sống" ở tầng repository.
      final activeOnly = [plan(id: 'p1', from: 1, to: 3)];

      final progress = computeHifzOverallProgress(
        activePlans: activeOnly,
        cards: const [],
        now: now,
      );

      expect(progress.activePlanCount, 1);
      expect(progress.totalPlannedAyahs, 3);
    });

    test(
        'kế hoạch completed KHÔNG được truyền vào activePlans -> không '
        'góp vào totalPlannedAyahs', () {
      final activeOnly = [plan(id: 'p1', from: 10, to: 10)];

      final progress = computeHifzOverallProgress(
        activePlans: activeOnly,
        cards: const [],
        now: now,
      );

      expect(progress.activePlanCount, 1);
      expect(progress.totalPlannedAyahs, 1);
    });
  });

  group('phân bố trạng thái gộp', () {
    test('đếm đúng số thẻ theo từng SrsCardState trên toàn bộ tập hợp', () {
      final plans = [plan(id: 'p1', from: 1, to: 5)];
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard),
        card(itemId: 2, state: SrsCardState.newCard),
        card(itemId: 3, state: SrsCardState.learning, repetitions: 1),
        card(itemId: 4, state: SrsCardState.review, repetitions: 2),
        card(itemId: 5, state: SrsCardState.lapsed, repetitions: 3),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(
        progress.stateCounts,
        {
          SrsCardState.newCard: 2,
          SrsCardState.learning: 1,
          SrsCardState.review: 1,
          SrsCardState.lapsed: 1,
        },
      );
    });
  });

  group('đến hạn ngay bây giờ (gộp)', () {
    test('chỉ đếm thẻ có due_date <= now trên toàn bộ tập hợp', () {
      final plans = [plan(id: 'p1', from: 1, to: 3)];
      final cards = [
        card(itemId: 1, state: SrsCardState.review, dueDate: nowMs - 1000),
        card(itemId: 2, state: SrsCardState.review, dueDate: nowMs),
        card(
          itemId: 3,
          state: SrsCardState.review,
          dueDate: nowMs + 100000000,
        ),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.dueNowCount, 2);
    });
  });

  group('hạn kế tiếp (gộp)', () {
    test('là due_date GẦN NHẤT trong toàn bộ tập hợp active', () {
      final plans = [plan(id: 'p1', from: 1, to: 3)];
      final cards = [
        card(itemId: 1, state: SrsCardState.review, dueDate: nowMs + 5000),
        card(itemId: 2, state: SrsCardState.review, dueDate: nowMs + 1000),
        card(itemId: 3, state: SrsCardState.review, dueDate: nowMs + 9000),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.nextDueAtMs, nowMs + 1000);
    });
  });

  group('reviewedCardCount (gộp)', () {
    test('chỉ đếm thẻ có repetitions > 0 trên toàn bộ tập hợp', () {
      final plans = [plan(id: 'p1', from: 1, to: 3)];
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard, repetitions: 0),
        card(itemId: 2, state: SrsCardState.review, repetitions: 1),
        card(itemId: 3, state: SrsCardState.review, repetitions: 4),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.reviewedCardCount, 2);
    });
  });

  group('trung bình ease/interval (gộp)', () {
    test(
        'CHỈ tính trên thẻ đã ôn ít nhất 1 lần — thẻ mới (repetitions=0) '
        'KHÔNG được đưa vào trung bình dù có ease/interval mặc định', () {
      final plans = [plan(id: 'p1', from: 1, to: 3)];
      final cards = [
        // Thẻ mới — KHÔNG được tính vào trung bình dù có giá trị.
        card(
          itemId: 1,
          state: SrsCardState.newCard,
          repetitions: 0,
          easeFactor: 2.5,
          intervalDays: 0,
        ),
        card(
          itemId: 2,
          state: SrsCardState.review,
          repetitions: 1,
          easeFactor: 2.6,
          intervalDays: 6,
        ),
        card(
          itemId: 3,
          state: SrsCardState.review,
          repetitions: 2,
          easeFactor: 2.4,
          intervalDays: 15,
        ),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.reviewedCardCount, 2);
      expect(progress.averageEaseFactor, closeTo(2.5, 0.0001));
      expect(progress.averageIntervalDays, 11);
    });

    test('chưa thẻ nào được ôn -> trung bình null, không phải 0', () {
      final plans = [plan(id: 'p1', from: 1, to: 2)];
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard, repetitions: 0),
        card(itemId: 2, state: SrsCardState.newCard, repetitions: 0),
      ];

      final progress = computeHifzOverallProgress(
        activePlans: plans,
        cards: cards,
        now: now,
      );

      expect(progress.reviewedCardCount, 0);
      expect(progress.averageEaseFactor, isNull);
      expect(progress.averageIntervalDays, isNull);
    });
  });
}
