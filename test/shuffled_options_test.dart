import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/quiz/domain/generators/shuffled_options.dart';

void main() {
  group('buildShuffledOptions (Sprint S2, D7)', () {
    test('options chứa đúng 1 đáp án đúng + toàn bộ nhiễu, không thêm bớt', () {
      final built = buildShuffledOptions(
        'correct',
        ['d1', 'd2', 'd3'],
        Random(1),
      );

      expect(built.options, hasLength(4));
      expect(built.options.toSet(), {'correct', 'd1', 'd2', 'd3'});
    });

    test('correctOptionIndex luôn trỏ đúng vị trí đáp án đúng sau khi xáo', () {
      final built = buildShuffledOptions(
        'correct',
        ['d1', 'd2', 'd3'],
        Random(42),
      );

      expect(built.options[built.correctOptionIndex], 'correct');
    });

    test(
        'cùng seed -> cùng kết quả (tất định, không phụ thuộc đồng hồ hệ '
        'thống)', () {
      final a = buildShuffledOptions('c', ['x', 'y', 'z'], Random(7));
      final b = buildShuffledOptions('c', ['x', 'y', 'z'], Random(7));

      expect(a.options, b.options);
      expect(a.correctOptionIndex, b.correctOptionIndex);
    });

    test('nhận số lượng nhiễu bất kỳ, không ép đúng 3 phần tử', () {
      final built = buildShuffledOptions('c', ['x'], Random(3));

      expect(built.options, hasLength(2));
      expect(built.options[built.correctOptionIndex], 'c');
    });
  });
}
