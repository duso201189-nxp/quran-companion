import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';
import 'package:quran_companion/features/hifz/domain/hifz_progress_calculator.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';

/// Sprint 7.7c-A — computeHifzPlanProgress: hàm THUẦN tính ảnh chụp
/// tiến độ từ [HifzPlan] + danh sách [SrsCard] đã lọc sẵn. Không DB,
/// không Riverpod — cùng kỷ luật hifz_scheduling_algorithm_test.dart.
void main() {
  final now = DateTime.utc(2026, 8, 15);
  final nowMs = now.millisecondsSinceEpoch;

  const plan = HifzPlan(
    id: 'plan-1',
    ayahFrom: 1,
    ayahTo: 5,
    status: HifzPlanStatus.active,
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

  group('không có thẻ nào được theo dõi', () {
    test(
        'trackedCardCount=0, mọi bộ đếm trạng thái=0, không có hạn kế '
        'tiếp, không có trung bình', () {
      final progress = computeHifzPlanProgress(
        plan: plan,
        cards: const [],
        now: now,
      );

      expect(progress.totalAyahCount, 5);
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

  group('phân bố trạng thái', () {
    test('đếm đúng số thẻ theo từng SrsCardState', () {
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard),
        card(itemId: 2, state: SrsCardState.newCard),
        card(itemId: 3, state: SrsCardState.learning, repetitions: 1),
        card(itemId: 4, state: SrsCardState.review, repetitions: 2),
        card(itemId: 5, state: SrsCardState.lapsed, repetitions: 3),
      ];

      final progress =
          computeHifzPlanProgress(plan: plan, cards: cards, now: now);

      expect(progress.trackedCardCount, 5);
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

  group('đến hạn ngay bây giờ', () {
    test('chỉ đếm thẻ có due_date <= now, thẻ tương lai không tính', () {
      final cards = [
        card(itemId: 1, state: SrsCardState.review, dueDate: nowMs - 1000),
        card(itemId: 2, state: SrsCardState.review, dueDate: nowMs),
        card(
          itemId: 3,
          state: SrsCardState.review,
          dueDate: nowMs + 100000000,
        ),
      ];

      final progress =
          computeHifzPlanProgress(plan: plan, cards: cards, now: now);

      expect(progress.dueNowCount, 2);
    });
  });

  group('hạn kế tiếp', () {
    test(
        'là due_date GẦN NHẤT trong số thẻ theo dõi — kể cả khi thẻ đó '
        'CHƯA đến hạn (tương lai)', () {
      final cards = [
        card(itemId: 1, state: SrsCardState.review, dueDate: nowMs + 5000),
        card(itemId: 2, state: SrsCardState.review, dueDate: nowMs + 1000),
        card(itemId: 3, state: SrsCardState.review, dueDate: nowMs + 9000),
      ];

      final progress =
          computeHifzPlanProgress(plan: plan, cards: cards, now: now);

      expect(progress.nextDueAtMs, nowMs + 1000);
    });
  });

  group('trung bình ease/interval', () {
    test(
        'CHỈ tính trên thẻ đã ôn ít nhất 1 lần (repetitions > 0) — thẻ '
        'mới (repetitions=0) không được đưa vào trung bình', () {
      final cards = [
        // Thẻ mới — ease/interval mặc định, KHÔNG được tính vào trung
        // bình dù có giá trị.
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

      final progress =
          computeHifzPlanProgress(plan: plan, cards: cards, now: now);

      expect(progress.reviewedCardCount, 2);
      expect(progress.averageEaseFactor, closeTo(2.5, 0.0001));
      expect(progress.averageIntervalDays, 11);
    });

    test('chưa thẻ nào được ôn -> trung bình null, không phải 0', () {
      final cards = [
        card(itemId: 1, state: SrsCardState.newCard, repetitions: 0),
        card(itemId: 2, state: SrsCardState.newCard, repetitions: 0),
      ];

      final progress =
          computeHifzPlanProgress(plan: plan, cards: cards, now: now);

      expect(progress.reviewedCardCount, 0);
      expect(progress.averageEaseFactor, isNull);
      expect(progress.averageIntervalDays, isNull);
    });
  });

  group('tổng số Ayah kế hoạch', () {
    test('luôn bằng plan.ayahCount, KHÔNG phụ thuộc số thẻ theo dõi', () {
      final progress = computeHifzPlanProgress(
        plan: plan,
        cards: [card(itemId: 1, state: SrsCardState.newCard)],
        now: now,
      );

      expect(progress.totalAyahCount, 5);
      expect(progress.trackedCardCount, 1);
    });
  });
}
