import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/sm2_scheduling_algorithm.dart';

void main() {
  const algorithm = SM2SchedulingAlgorithm();
  final now = DateTime.utc(2026, 7, 20);

  group('initialState', () {
    test('ease factor mặc định 2.5, chưa lặp lần nào, trạng thái newCard',
        () {
      final initial = algorithm.initialState();
      expect(initial.easeFactor, 2.5);
      expect(initial.intervalDays, 0);
      expect(initial.repetitions, 0);
      expect(initial.state, SrsCardState.newCard);
    });
  });

  group('review — chuỗi trả lời đúng (good) liên tiếp', () {
    test('lần ôn đầu tiên: interval = 1 ngày, ease không đổi', () {
      final result = algorithm.review(
        current: algorithm.initialState(),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(result.intervalDays, 1);
      expect(result.repetitions, 1);
      expect(result.easeFactor, 2.5);
      expect(result.state, SrsCardState.review);
      expect(result.dueDate, now.add(const Duration(days: 1)));
    });

    test('lần ôn thứ hai: interval = 6 ngày', () {
      final result = algorithm.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 1,
          repetitions: 1,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(result.intervalDays, 6);
      expect(result.repetitions, 2);
      expect(result.easeFactor, 2.5);
      expect(result.dueDate, now.add(const Duration(days: 6)));
    });

    test('lần ôn thứ ba trở đi: interval = round(interval * ease)', () {
      final result = algorithm.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 6,
          repetitions: 2,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(result.intervalDays, 15); // round(6 * 2.5)
      expect(result.repetitions, 3);
    });
  });

  group('review — ease factor theo mức đánh giá', () {
    test('easy (quality 5) tăng ease factor', () {
      final result = algorithm.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 1,
          repetitions: 1,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.easy,
        now: now,
      );
      expect(result.easeFactor, closeTo(2.6, 1e-9));
    });

    test('hard (quality 3) giảm ease factor', () {
      final result = algorithm.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 1,
          repetitions: 1,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.hard,
        now: now,
      );
      expect(result.easeFactor, closeTo(2.36, 1e-9));
      // hard vẫn được coi là trả lời đúng — không reset chuỗi lặp lại.
      expect(result.state, SrsCardState.review);
      expect(result.repetitions, 2);
    });

    test('ease factor không bao giờ xuống dưới sàn 1.3', () {
      var state = (
        easeFactor: 1.5,
        intervalDays: 10,
        repetitions: 3,
        state: SrsCardState.review,
      );
      final result = algorithm.review(
        current: state,
        grade: ReviewGrade.again,
        now: now,
      );
      expect(result.easeFactor, greaterThanOrEqualTo(1.3));
      state = (
        easeFactor: result.easeFactor,
        intervalDays: result.intervalDays,
        repetitions: result.repetitions,
        state: result.state,
      );
      final second = algorithm.review(
        current: state,
        grade: ReviewGrade.again,
        now: now,
      );
      expect(second.easeFactor, 1.3);
    });
  });

  group('review — trả lời sai (again) và trạng thái lapsed', () {
    test('sai khi đang học lần đầu (newCard) -> learning, không phải lapsed',
        () {
      final result = algorithm.review(
        current: algorithm.initialState(),
        grade: ReviewGrade.again,
        now: now,
      );
      expect(result.state, SrsCardState.learning);
      expect(result.repetitions, 0);
      expect(result.intervalDays, 1);
    });

    test('sai sau khi đã tốt nghiệp (review) -> lapsed, reset chuỗi lặp lại',
        () {
      final result = algorithm.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 15,
          repetitions: 3,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.again,
        now: now,
      );
      expect(result.state, SrsCardState.lapsed);
      expect(result.repetitions, 0);
      expect(result.intervalDays, 1);
      expect(result.dueDate, now.add(const Duration(days: 1)));
    });

    test('sai khi đang lapsed -> vẫn lapsed (không quay lại learning)', () {
      final result = algorithm.review(
        current: (
          easeFactor: 1.3,
          intervalDays: 1,
          repetitions: 0,
          state: SrsCardState.lapsed,
        ),
        grade: ReviewGrade.again,
        now: now,
      );
      expect(result.state, SrsCardState.lapsed);
    });
  });

  group('SrsCardStateCodec', () {
    test('mã hoá/giải mã round-trip cho cả 4 trạng thái', () {
      for (final s in SrsCardState.values) {
        expect(srsCardStateFromDbValue(s.toDbValue()), s);
      }
    });

    test('giá trị lưu database dùng đúng chuỗi kế hoạch (DATABASE.md)', () {
      expect(SrsCardState.newCard.toDbValue(), 'new');
      expect(SrsCardState.learning.toDbValue(), 'learning');
      expect(SrsCardState.review.toDbValue(), 'review');
      expect(SrsCardState.lapsed.toDbValue(), 'lapsed');
    });

    test('chuỗi không hợp lệ mặc định về newCard', () {
      expect(srsCardStateFromDbValue('garbage'), SrsCardState.newCard);
    });
  });
}
