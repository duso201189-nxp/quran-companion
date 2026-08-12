import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/hifz_scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/sm2_scheduling_algorithm.dart';

/// Sprint 7.7a — HifzSchedulingAlgorithm là SM-2 cộng ĐÚNG một luật:
/// trần 30 ngày. Bài kiểm dưới đây vừa xác nhận luật đó, vừa ghim
/// rằng mọi hành vi CÒN LẠI trùng khít SM-2.
void main() {
  const hifz = HifzSchedulingAlgorithm();
  const sm2 = SM2SchedulingAlgorithm();
  final now = DateTime.utc(2026, 8, 11);

  group('initialState', () {
    test('giống hệt SM-2', () {
      final h = hifz.initialState();
      final s = sm2.initialState();
      expect(h.easeFactor, s.easeFactor);
      expect(h.intervalDays, s.intervalDays);
      expect(h.repetitions, s.repetitions);
      expect(h.state, s.state);
      expect(h.state, SrsCardState.newCard);
    });
  });

  group('bậc thang thành công', () {
    test('lần đầu: 1 ngày (giữ nguyên SM-2, KHÔNG rút ngắn)', () {
      final r = hifz.review(
        current: hifz.initialState(),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(r.intervalDays, 1);
      expect(r.repetitions, 1);
      expect(r.state, SrsCardState.review);
      expect(r.dueDate, now.add(const Duration(days: 1)));
    });

    test('lần hai: 6 ngày (giữ nguyên SM-2, KHÔNG rút ngắn)', () {
      final r = hifz.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 1,
          repetitions: 1,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(r.intervalDays, 6);
    });

    test('lần ba: 15 ngày — vẫn dưới trần nên bằng SM-2', () {
      final r = hifz.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 6,
          repetitions: 2,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(r.intervalDays, 15);
    });

    test('lần bốn: SM-2 cho 38, Hifz chặn ở 30', () {
      const current = (
        easeFactor: 2.5,
        intervalDays: 15,
        repetitions: 3,
        state: SrsCardState.review,
      );
      expect(
        sm2
            .review(current: current, grade: ReviewGrade.good, now: now)
            .intervalDays,
        38,
      );
      final r = hifz.review(
        current: current,
        grade: ReviewGrade.good,
        now: now,
      );
      expect(r.intervalDays, HifzSchedulingAlgorithm.maxIntervalDays);
      expect(r.intervalDays, 30);
      expect(r.dueDate, now.add(const Duration(days: 30)));
    });
  });

  group('trần 30 ngày', () {
    test('thành công lặp lại ở trần vẫn đứng yên 30, không trôi lên', () {
      var current = (
        easeFactor: 2.5,
        intervalDays: 30,
        repetitions: 5,
        state: SrsCardState.review,
      );
      for (var i = 0; i < 10; i++) {
        final r = hifz.review(
          current: current,
          grade: ReviewGrade.good,
          now: now,
        );
        expect(r.intervalDays, 30);
        current = (
          easeFactor: r.easeFactor,
          intervalDays: r.intervalDays,
          repetitions: r.repetitions,
          state: r.state,
        );
      }
    });

    test('easy ở trần cũng không vượt 30', () {
      final r = hifz.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 30,
          repetitions: 5,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.easy,
        now: now,
      );
      expect(r.intervalDays, 30);
    });

    test('khoảng cách đã vượt trần bị KÉO VỀ 30, không giữ nguyên', () {
      final r = hifz.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 400,
          repetitions: 9,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.good,
        now: now,
      );
      expect(r.intervalDays, 30);
    });
  });

  group('ease — trùng khít SM-2', () {
    test('easy tăng ease đúng như SM-2', () {
      const current = (
        easeFactor: 2.5,
        intervalDays: 1,
        repetitions: 1,
        state: SrsCardState.review,
      );
      expect(
        hifz
            .review(current: current, grade: ReviewGrade.easy, now: now)
            .easeFactor,
        closeTo(2.6, 1e-9),
      );
    });

    test('hard giảm ease đúng như SM-2 và VẪN tính là đúng', () {
      const current = (
        easeFactor: 2.5,
        intervalDays: 1,
        repetitions: 1,
        state: SrsCardState.review,
      );
      final r = hifz.review(
        current: current,
        grade: ReviewGrade.hard,
        now: now,
      );
      expect(r.easeFactor, closeTo(2.36, 1e-9));
      expect(r.state, SrsCardState.review);
      expect(r.repetitions, 2);
    });

    test('sàn ease 1.3 giữ nguyên', () {
      var current = (
        easeFactor: 1.5,
        intervalDays: 10,
        repetitions: 3,
        state: SrsCardState.review,
      );
      final first = hifz.review(
        current: current,
        grade: ReviewGrade.again,
        now: now,
      );
      expect(first.easeFactor, greaterThanOrEqualTo(1.3));
      current = (
        easeFactor: first.easeFactor,
        intervalDays: first.intervalDays,
        repetitions: first.repetitions,
        state: first.state,
      );
      expect(
        hifz
            .review(current: current, grade: ReviewGrade.again, now: now)
            .easeFactor,
        1.3,
      );
    });
  });

  group('trả lời sai — trùng khít SM-2', () {
    test('sai khi chưa tốt nghiệp -> learning, interval 1', () {
      final r = hifz.review(
        current: hifz.initialState(),
        grade: ReviewGrade.again,
        now: now,
      );
      expect(r.state, SrsCardState.learning);
      expect(r.repetitions, 0);
      expect(r.intervalDays, 1);
    });

    test('sai sau khi tốt nghiệp -> lapsed, reset về 1 ngày kể cả từ trần', () {
      final r = hifz.review(
        current: (
          easeFactor: 2.5,
          intervalDays: 30,
          repetitions: 8,
          state: SrsCardState.review,
        ),
        grade: ReviewGrade.again,
        now: now,
      );
      expect(r.state, SrsCardState.lapsed);
      expect(r.repetitions, 0);
      expect(r.intervalDays, 1);
      expect(r.dueDate, now.add(const Duration(days: 1)));
    });

    test('sai khi đang lapsed -> vẫn lapsed', () {
      final r = hifz.review(
        current: (
          easeFactor: 1.3,
          intervalDays: 1,
          repetitions: 0,
          state: SrsCardState.lapsed,
        ),
        grade: ReviewGrade.again,
        now: now,
      );
      expect(r.state, SrsCardState.lapsed);
    });
  });

  group('bất biến chéo: dưới trần, Hifz == SM-2 từng chi tiết', () {
    test(
        'mọi tổ hợp (interval, reps, state, grade) cho kết quả <= 30 đều '
        'khớp SM-2', () {
      for (final interval in [0, 1, 6, 10, 15]) {
        for (final reps in [0, 1, 2, 3]) {
          for (final state in SrsCardState.values) {
            for (final grade in ReviewGrade.values) {
              final current = (
                easeFactor: 2.5,
                intervalDays: interval,
                repetitions: reps,
                state: state,
              );
              final s = sm2.review(current: current, grade: grade, now: now);
              if (s.intervalDays > HifzSchedulingAlgorithm.maxIntervalDays) {
                continue; // chỉ so phần dưới trần
              }
              final h = hifz.review(current: current, grade: grade, now: now);
              expect(h.intervalDays, s.intervalDays);
              expect(h.easeFactor, closeTo(s.easeFactor, 1e-12));
              expect(h.repetitions, s.repetitions);
              expect(h.state, s.state);
              expect(h.dueDate, s.dueDate);
            }
          }
        }
      }
    });
  });
}
