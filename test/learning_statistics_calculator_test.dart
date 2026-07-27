import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/analytics/domain/learning_statistics_calculator.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';

SrsCard _card({
  required int itemId,
  LearningItemType itemType = LearningItemType.lemma,
  double ease = 2.5,
  int interval = 1,
  int repetitions = 1,
  int dueDate = 0,
  SrsCardState state = SrsCardState.review,
  required int updatedAtMs,
}) =>
    SrsCard(
      id: 'card-$itemId',
      itemType: itemType,
      itemId: itemId,
      easeFactor: ease,
      intervalDays: interval,
      repetitions: repetitions,
      dueDate: dueDate,
      state: state,
      updatedAtMs: updatedAtMs,
    );

void main() {
  final now = DateTime.utc(2026, 7, 21, 12);
  final nowMs = now.millisecondsSinceEpoch;
  final todayStartMs = DateTime.utc(2026, 7, 21).millisecondsSinceEpoch;
  final yesterdayMs = DateTime.utc(2026, 7, 20, 8).millisecondsSinceEpoch;

  group('cardsStudied', () {
    test('chỉ đếm SrsCard có repetitions > 0', () {
      final cards = [
        _card(itemId: 1, repetitions: 3, updatedAtMs: nowMs),
        _card(itemId: 2, repetitions: 0, updatedAtMs: nowMs),
      ];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.cardsStudied, 1);
    });
  });

  group('dueToday', () {
    test('đếm SrsCard có dueDate <= hiện tại (kể cả quá hạn)', () {
      final cards = [
        _card(itemId: 1, dueDate: nowMs - 1000, updatedAtMs: nowMs),
        _card(itemId: 2, dueDate: nowMs + 1000, updatedAtMs: nowMs),
      ];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.dueToday, 1);
    });
  });

  group('reviewsToday (xấp xỉ qua updatedAtMs)', () {
    test('chỉ đếm SrsCard có updatedAtMs rơi vào hôm nay', () {
      final cards = [
        _card(itemId: 1, updatedAtMs: todayStartMs + 1000),
        _card(itemId: 2, updatedAtMs: yesterdayMs),
      ];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.reviewsToday, 1);
    });

    test('không có thẻ nào cập nhật hôm nay -> 0', () {
      final cards = [_card(itemId: 1, updatedAtMs: yesterdayMs)];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.reviewsToday, 0);
    });
  });

  group('accuracy (xấp xỉ qua state hiện tại)', () {
    test('tỉ lệ thẻ ĐÃ HỌC không ở trạng thái lapsed', () {
      final cards = [
        _card(
          itemId: 1,
          repetitions: 2,
          state: SrsCardState.review,
          updatedAtMs: nowMs,
        ),
        _card(
          itemId: 2,
          repetitions: 1,
          state: SrsCardState.lapsed,
          updatedAtMs: nowMs,
        ),
        _card(
          itemId: 3,
          repetitions: 0,
          state: SrsCardState.newCard,
          updatedAtMs: nowMs,
        ),
      ];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      // 2 thẻ đã học (rep>0): 1 review, 1 lapsed -> 1/2 = 0.5.
      expect(stats.accuracy, 0.5);
    });

    test('chưa có thẻ nào được học -> 0.0, không chia cho 0', () {
      final cards = [_card(itemId: 1, repetitions: 0, updatedAtMs: nowMs)];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.accuracy, 0.0);
    });
  });

  group('averageEase / averageInterval', () {
    test('trung bình cộng trên MỌI SrsCard (kể cả chưa học)', () {
      final cards = [
        _card(itemId: 1, ease: 2.0, interval: 2, updatedAtMs: nowMs),
        _card(itemId: 2, ease: 3.0, interval: 4, updatedAtMs: nowMs),
      ];
      final stats = computeLearningStatistics(
        cards,
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.averageEase, 2.5);
      expect(stats.averageInterval, 3.0);
    });

    test('danh sách rỗng -> 0.0, không throw', () {
      final stats = computeLearningStatistics(
        const [],
        readingStreakDays: 0,
        longestReadingStreakDays: 0,
        now: now,
      );
      expect(stats.averageEase, 0.0);
      expect(stats.averageInterval, 0.0);
      expect(stats.cardsStudied, 0);
    });
  });

  test(
      'readingStreakDays/longestReadingStreakDays TÁI SỬ DỤNG nguyên vẹn '
      'giá trị truyền vào, không tự tính lại', () {
    final stats = computeLearningStatistics(
      const [],
      readingStreakDays: 7,
      longestReadingStreakDays: 30,
      now: now,
    );
    expect(stats.readingStreakDays, 7);
    expect(stats.longestReadingStreakDays, 30);
  });

  test('gộp CẢ 2 loại SrsCard (ayah + lemma) vào cùng 1 thống kê', () {
    final cards = [
      _card(
        itemId: 1,
        itemType: LearningItemType.ayah,
        repetitions: 1,
        updatedAtMs: nowMs,
      ),
      _card(
        itemId: 2,
        itemType: LearningItemType.lemma,
        repetitions: 1,
        updatedAtMs: nowMs,
      ),
    ];
    final stats = computeLearningStatistics(
      cards,
      readingStreakDays: 0,
      longestReadingStreakDays: 0,
      now: now,
    );
    expect(stats.cardsStudied, 2);
  });
}
