import 'entities/srs_card.dart';
import 'scheduling_algorithm.dart';

/// Cài đặt SM-2 cổ điển (SuperMemo-2), ánh xạ 4 nút đánh giá kiểu Anki
/// sang thang chất lượng 0-5 gốc. Đã quyết định thay FSRS ở
/// ARCHITECTURE.md §10 ("đơn giản, đã kiểm chứng"); FSRS để v2+.
///
/// Thuần Dart — không import Flutter/Riverpod/Drift/SQLite.
class SM2SchedulingAlgorithm implements SchedulingAlgorithm {
  const SM2SchedulingAlgorithm();

  static const double _defaultEaseFactor = 2.5;
  static const double _minEaseFactor = 1.3;

  @override
  SchedulingInput initialState() => (
        easeFactor: _defaultEaseFactor,
        intervalDays: 0,
        repetitions: 0,
        state: SrsCardState.newCard,
      );

  @override
  SchedulingResult review({
    required SchedulingInput current,
    required ReviewGrade grade,
    required DateTime now,
  }) {
    final quality = _qualityOf(grade);

    var repetitions = current.repetitions;
    var intervalDays = current.intervalDays;

    if (quality < 3) {
      // Trả lời sai: reset chuỗi lặp lại, ôn lại sớm (1 ngày).
      repetitions = 0;
      intervalDays = 1;
    } else {
      if (repetitions == 0) {
        intervalDays = 1;
      } else if (repetitions == 1) {
        intervalDays = 6;
      } else {
        intervalDays = (intervalDays * current.easeFactor).round();
      }
      repetitions += 1;
    }

    var easeFactor = current.easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < _minEaseFactor) easeFactor = _minEaseFactor;

    // 'lapsed' chỉ áp dụng cho thẻ đã từng tốt nghiệp (review/lapsed)
    // rồi trả lời sai — thẻ đang học lần đầu sai thì vẫn là 'learning'.
    final wasGraduated = current.state == SrsCardState.review ||
        current.state == SrsCardState.lapsed;
    final nextState = quality < 3
        ? (wasGraduated ? SrsCardState.lapsed : SrsCardState.learning)
        : SrsCardState.review;

    return (
      easeFactor: easeFactor,
      intervalDays: intervalDays,
      repetitions: repetitions,
      state: nextState,
      dueDate: now.add(Duration(days: intervalDays)),
    );
  }

  static int _qualityOf(ReviewGrade grade) => switch (grade) {
        ReviewGrade.again => 0,
        ReviewGrade.hard => 3,
        ReviewGrade.good => 4,
        ReviewGrade.easy => 5,
      };
}
