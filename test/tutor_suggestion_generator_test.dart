import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_action.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/ai_tutor/domain/tutor_suggestion_generator.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_goal.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/flashcards/domain/resolved_flashcard.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';

LearningStatistics _stats({
  int cardsStudied = 0,
  int dueToday = 0,
  int reviewsToday = 0,
  double accuracy = 0,
  int readingStreakDays = 0,
}) =>
    LearningStatistics(
      cardsStudied: cardsStudied,
      dueToday: dueToday,
      reviewsToday: reviewsToday,
      accuracy: accuracy,
      averageEase: 2.5,
      averageInterval: 1,
      readingStreakDays: readingStreakDays,
      longestReadingStreakDays: readingStreakDays,
    );

ResolvedFlashcard _resolvedFlashcard(String id) => (
      flashcard: Flashcard(
        id: id,
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 1,
        createdAt: 0,
      ),
      lemma: null,
    );

TutorContext _context({
  LearningStatistics? statistics,
  List<LearningGoal> goals = const [],
  PerformanceInsights? insights,
}) =>
    TutorContext(
      statistics: statistics ?? _stats(),
      goals: goals,
      achievements: const [],
      insights: insights ??
          const PerformanceInsights(
            weakRoots: [],
            difficultLemmas: [],
            frequentlyForgotten: [],
            fastestImproving: [],
          ),
    );

void main() {
  group('computeTutorSuggestions', () {
    test('không có gì đáng gợi ý -> danh sách rỗng', () {
      final suggestions = computeTutorSuggestions(_context());
      expect(suggestions, isEmpty);
    });

    test('dueToday > 0 -> gợi ý reviewDueCards mức high, đúng relatedCount',
        () {
      final suggestions = computeTutorSuggestions(
        _context(statistics: _stats(dueToday: 5)),
      );

      final s = suggestions
          .singleWhere((s) => s.kind == TutorSuggestionKind.reviewDueCards);
      expect(s.priority, TutorSuggestionPriority.high);
      expect(s.relatedCount, 5);
    });

    test(
        'LearningGoal(dailyStudyMinutes) chưa đạt -> gợi ý completeDailyStudyGoal',
        () {
      final suggestions = computeTutorSuggestions(
        _context(
          goals: const [
            LearningGoal(
              kind: LearningGoalKind.dailyStudyMinutes,
              target: 15,
              current: 5,
            ),
          ],
        ),
      );

      final s = suggestions.singleWhere(
        (s) => s.kind == TutorSuggestionKind.completeDailyStudyGoal,
      );
      expect(s.relatedCount, 10); // target - current
    });

    test('LearningGoal(dailyStudyMinutes) ĐÃ đạt -> không gợi ý', () {
      final suggestions = computeTutorSuggestions(
        _context(
          goals: const [
            LearningGoal(
              kind: LearningGoalKind.dailyStudyMinutes,
              target: 15,
              current: 15,
            ),
          ],
        ),
      );

      expect(
        suggestions
            .any((s) => s.kind == TutorSuggestionKind.completeDailyStudyGoal),
        isFalse,
      );
    });

    test('LearningGoal(dailyReviews) chưa đạt -> gợi ý completeDailyReviewGoal',
        () {
      final suggestions = computeTutorSuggestions(
        _context(
          goals: const [
            LearningGoal(
              kind: LearningGoalKind.dailyReviews,
              target: 10,
              current: 3,
            ),
          ],
        ),
      );

      expect(
        suggestions
            .any((s) => s.kind == TutorSuggestionKind.completeDailyReviewGoal),
        isTrue,
      );
    });

    test(
        'LearningGoal(weeklyStudyMinutes) chưa đạt -> KHÔNG có gợi ý tương '
        'ứng (cố ý)', () {
      final suggestions = computeTutorSuggestions(
        _context(
          goals: const [
            LearningGoal(
              kind: LearningGoalKind.weeklyStudyMinutes,
              target: 60,
              current: 10,
            ),
          ],
        ),
      );

      expect(suggestions, isEmpty);
    });

    test('frequentlyForgotten không rỗng -> gợi ý mức high, đúng số lượng', () {
      final suggestions = computeTutorSuggestions(
        _context(
          insights: PerformanceInsights(
            weakRoots: const [],
            difficultLemmas: const [],
            frequentlyForgotten: [
              _resolvedFlashcard('a'),
              _resolvedFlashcard('b'),
            ],
            fastestImproving: const [],
          ),
        ),
      );

      final s = suggestions.singleWhere(
        (s) => s.kind == TutorSuggestionKind.reviewFrequentlyForgotten,
      );
      expect(s.priority, TutorSuggestionPriority.high);
      expect(s.relatedCount, 2);
    });

    test('weakRoots không rỗng -> gợi ý strengthenWeakRoots', () {
      final suggestions = computeTutorSuggestions(
        _context(
          insights: PerformanceInsights(
            weakRoots: [_resolvedFlashcard('a')],
            difficultLemmas: const [],
            frequentlyForgotten: const [],
            fastestImproving: const [],
          ),
        ),
      );

      expect(
        suggestions
            .any((s) => s.kind == TutorSuggestionKind.strengthenWeakRoots),
        isTrue,
      );
    });

    test('readingStreakDays > 0 -> gợi ý maintainStreak mức low', () {
      final suggestions = computeTutorSuggestions(
        _context(statistics: _stats(readingStreakDays: 3)),
      );

      final s = suggestions
          .singleWhere((s) => s.kind == TutorSuggestionKind.maintainStreak);
      expect(s.priority, TutorSuggestionPriority.low);
      expect(s.relatedCount, 3);
    });

    test('readingStreakDays == 0 -> không gợi ý maintainStreak', () {
      final suggestions = computeTutorSuggestions(_context());
      expect(
        suggestions.any((s) => s.kind == TutorSuggestionKind.maintainStreak),
        isFalse,
      );
    });
  });

  group('computeTutorSuggestions — TutorAction (Sprint 15 Phase 3)', () {
    test('reviewDueCards gắn action reviewSession', () {
      final suggestions = computeTutorSuggestions(
        _context(statistics: _stats(dueToday: 5)),
      );
      final s = suggestions
          .singleWhere((s) => s.kind == TutorSuggestionKind.reviewDueCards);

      expect(s.action?.destination, TutorActionDestination.reviewSession);
    });

    test('completeDailyStudyGoal gắn action learningSession', () {
      final suggestions = computeTutorSuggestions(
        _context(
          goals: const [
            LearningGoal(
              kind: LearningGoalKind.dailyStudyMinutes,
              target: 15,
              current: 5,
            ),
          ],
        ),
      );
      final s = suggestions.singleWhere(
        (s) => s.kind == TutorSuggestionKind.completeDailyStudyGoal,
      );

      expect(s.action?.destination, TutorActionDestination.learningSession);
    });

    test('completeDailyReviewGoal gắn action reviewSession', () {
      final suggestions = computeTutorSuggestions(
        _context(
          goals: const [
            LearningGoal(
              kind: LearningGoalKind.dailyReviews,
              target: 10,
              current: 3,
            ),
          ],
        ),
      );
      final s = suggestions.singleWhere(
        (s) => s.kind == TutorSuggestionKind.completeDailyReviewGoal,
      );

      expect(s.action?.destination, TutorActionDestination.reviewSession);
    });

    test('strengthenWeakRoots gắn action weakCards', () {
      final suggestions = computeTutorSuggestions(
        _context(
          insights: PerformanceInsights(
            weakRoots: [_resolvedFlashcard('a')],
            difficultLemmas: const [],
            frequentlyForgotten: const [],
            fastestImproving: const [],
          ),
        ),
      );
      final s = suggestions.singleWhere(
        (s) => s.kind == TutorSuggestionKind.strengthenWeakRoots,
      );

      expect(s.action?.destination, TutorActionDestination.weakCards);
    });

    test('reviewFrequentlyForgotten gắn action flashcards', () {
      final suggestions = computeTutorSuggestions(
        _context(
          insights: PerformanceInsights(
            weakRoots: const [],
            difficultLemmas: const [],
            frequentlyForgotten: [_resolvedFlashcard('a')],
            fastestImproving: const [],
          ),
        ),
      );
      final s = suggestions.singleWhere(
        (s) => s.kind == TutorSuggestionKind.reviewFrequentlyForgotten,
      );

      expect(s.action?.destination, TutorActionDestination.flashcards);
    });

    test('maintainStreak KHÔNG gắn action nào (chỉ khích lệ)', () {
      final suggestions = computeTutorSuggestions(
        _context(statistics: _stats(readingStreakDays: 3)),
      );
      final s = suggestions
          .singleWhere((s) => s.kind == TutorSuggestionKind.maintainStreak);

      expect(s.action, isNull);
    });

    test('payload luôn null ở phase này (chưa destination nào cần)', () {
      final suggestions = computeTutorSuggestions(
        _context(statistics: _stats(dueToday: 5)),
      );
      final s = suggestions
          .singleWhere((s) => s.kind == TutorSuggestionKind.reviewDueCards);

      expect(s.action?.payload, isNull);
    });
  });
}
