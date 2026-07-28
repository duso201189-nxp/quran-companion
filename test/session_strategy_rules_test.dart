import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/session_strategy.dart';
import 'package:quran_companion/features/smart_learning/domain/session_strategy_rules.dart';

void main() {
  group('strategyForSuggestionKind (Sprint S2, D9)', () {
    test('reviewDueCards -> shortReview', () {
      expect(
        strategyForSuggestionKind(TutorSuggestionKind.reviewDueCards),
        SessionStrategy.shortReview,
      );
    });

    test('completeDailyReviewGoal -> shortReview', () {
      expect(
        strategyForSuggestionKind(TutorSuggestionKind.completeDailyReviewGoal),
        SessionStrategy.shortReview,
      );
    });

    test('completeDailyStudyGoal -> deepStudy', () {
      expect(
        strategyForSuggestionKind(TutorSuggestionKind.completeDailyStudyGoal),
        SessionStrategy.deepStudy,
      );
    });

    test('strengthenWeakRoots -> memorization', () {
      expect(
        strategyForSuggestionKind(TutorSuggestionKind.strengthenWeakRoots),
        SessionStrategy.memorization,
      );
    });

    test('reviewFrequentlyForgotten -> recovery', () {
      expect(
        strategyForSuggestionKind(
          TutorSuggestionKind.reviewFrequentlyForgotten,
        ),
        SessionStrategy.recovery,
      );
    });

    test(
        'maintainStreak -> null (chỉ mang tính khích lệ, không có chiến '
        'lược học cụ thể)', () {
      expect(
        strategyForSuggestionKind(TutorSuggestionKind.maintainStreak),
        isNull,
      );
    });

    test('mọi TutorSuggestionKind đều được xử lý (không thiếu case nào)', () {
      for (final kind in TutorSuggestionKind.values) {
        expect(
          () => strategyForSuggestionKind(kind),
          returnsNormally,
          reason: '$kind phải có ánh xạ (kể cả null có chủ đích)',
        );
      }
    });
  });

  group('estimatedMinutesFor (Sprint S2, D9)', () {
    test('shortReview -> 10 phút', () {
      expect(estimatedMinutesFor(SessionStrategy.shortReview), 10);
    });

    test('deepStudy -> 20 phút', () {
      expect(estimatedMinutesFor(SessionStrategy.deepStudy), 20);
    });

    test('memorization -> 15 phút', () {
      expect(estimatedMinutesFor(SessionStrategy.memorization), 15);
    });

    test('recovery -> 15 phút', () {
      expect(estimatedMinutesFor(SessionStrategy.recovery), 15);
    });

    test('mọi SessionStrategy đều có ước lượng thời lượng dương', () {
      for (final strategy in SessionStrategy.values) {
        expect(estimatedMinutesFor(strategy), greaterThan(0));
      }
    });
  });
}
