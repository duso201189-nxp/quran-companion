import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/learning_session/data/learning_planner_providers.dart';
import 'package:quran_companion/features/learning_session/domain/learning_planner.dart';
import 'package:quran_companion/features/learning_session/domain/sequential_learning_planner.dart';

LearningPlanContext _context({
  int dueReviewCount = 0,
  bool quizAvailable = false,
  int? dueFlashcardCount,
  Set<LearningActivityType> completedThisSession = const {},
}) =>
    (
      dueReviewCount: dueReviewCount,
      quizAvailable: quizAvailable,
      dueFlashcardCount: dueFlashcardCount,
      completedThisSession: completedThisSession,
    );

void main() {
  group('SequentialLearningPlanner — Review', () {
    const planner = SequentialLearningPlanner();

    test('Review sẵn có (dueReviewCount > 0) -> trả về review trước tiên', () {
      final context = _context(dueReviewCount: 5, quizAvailable: true);
      expect(planner.next(context), LearningActivityType.review);
    });

    test('Review không sẵn có (dueReviewCount = 0) -> bỏ qua, sang Quiz', () {
      final context = _context(dueReviewCount: 0, quizAvailable: true);
      expect(planner.next(context), LearningActivityType.quiz);
    });
  });

  group('SequentialLearningPlanner — Quiz', () {
    const planner = SequentialLearningPlanner();

    test('Quiz sẵn có, Review không -> trả về quiz', () {
      final context = _context(dueReviewCount: 0, quizAvailable: true);
      expect(planner.next(context), LearningActivityType.quiz);
    });

    test(
        'Quiz không sẵn có, Review không, Flashcard sẵn có -> trả về '
        'flashcard (bỏ qua cả Review lẫn Quiz)', () {
      final context = _context(
        dueReviewCount: 0,
        quizAvailable: false,
        dueFlashcardCount: 3,
      );
      expect(planner.next(context), LearningActivityType.flashcard);
    });
  });

  group('SequentialLearningPlanner — Flashcard', () {
    const planner = SequentialLearningPlanner();

    test(
        'Flashcard không sẵn có (dueFlashcardCount = null, module chưa '
        'cài) -> luôn bị bỏ qua', () {
      final context = _context(
        dueReviewCount: 0,
        quizAvailable: false,
      );
      expect(context.dueFlashcardCount, isNull);
      expect(planner.next(context), isNull);
    });

    test(
        'Flashcard không sẵn có (dueFlashcardCount = 0, module đã cài '
        'nhưng không có thẻ đến hạn) -> vẫn bị bỏ qua', () {
      final context = _context(
        dueReviewCount: 0,
        quizAvailable: false,
        dueFlashcardCount: 0,
      );
      expect(planner.next(context), isNull);
    });

    test(
        'Flashcard sẵn có (dueFlashcardCount > 0) và là hoạt động duy '
        'nhất còn lại -> trả về flashcard', () {
      final context = _context(
        dueReviewCount: 0,
        quizAvailable: false,
        dueFlashcardCount: 7,
        completedThisSession: {},
      );
      expect(planner.next(context), LearningActivityType.flashcard);
    });
  });

  group('SequentialLearningPlanner — nhiều hoạt động đã hoàn thành', () {
    const planner = SequentialLearningPlanner();

    test(
        'Review + Quiz đã hoàn thành, Flashcard sẵn có -> trả về '
        'flashcard', () {
      final context = _context(
        dueReviewCount: 5, // vẫn còn "sẵn có" về mặt số liệu
        quizAvailable: true,
        dueFlashcardCount: 2,
        completedThisSession: {
          LearningActivityType.review,
          LearningActivityType.quiz,
        },
      );
      expect(planner.next(context), LearningActivityType.flashcard);
    });

    test('Review + Quiz đã hoàn thành, Flashcard cũng không sẵn có -> null',
        () {
      final context = _context(
        dueReviewCount: 5,
        quizAvailable: true,
        completedThisSession: {
          LearningActivityType.review,
          LearningActivityType.quiz,
        },
      );
      expect(planner.next(context), isNull);
    });
  });

  group('SequentialLearningPlanner — phiên rỗng / kết thúc', () {
    const planner = SequentialLearningPlanner();

    test('Phiên rỗng: không có gì sẵn có, chưa hoàn thành gì -> null', () {
      final context = _context();
      expect(planner.next(context), isNull);
    });

    test(
        'Mọi hoạt động đã hoàn thành (kể cả khi số liệu vẫn "sẵn có") '
        '-> null, ưu tiên completedThisSession trên số liệu', () {
      final context = _context(
        dueReviewCount: 10,
        quizAvailable: true,
        dueFlashcardCount: 4,
        completedThisSession: {
          LearningActivityType.review,
          LearningActivityType.quiz,
          LearningActivityType.flashcard,
        },
      );
      expect(planner.next(context), isNull);
    });
  });

  group('SequentialLearningPlanner — bỏ qua hoạt động không sẵn có', () {
    const planner = SequentialLearningPlanner();

    test(
        'Review VÀ Quiz đều không sẵn có, Flashcard sẵn có -> bỏ qua liên '
        'tiếp 2 hoạt động, trả về flashcard', () {
      final context = _context(
        dueReviewCount: 0,
        quizAvailable: false,
        dueFlashcardCount: 1,
      );
      expect(planner.next(context), LearningActivityType.flashcard);
    });

    test(
        'Không hoạt động nào sẵn có -> trả về null đúng cách (không '
        'throw, không mặc định về hoạt động đầu tiên)', () {
      final context = _context(
        dueReviewCount: 0,
        quizAvailable: false,
        dueFlashcardCount: 0,
      );
      expect(planner.next(context), isNull);
    });
  });

  group('SequentialLearningPlanner — tất định', () {
    const planner = SequentialLearningPlanner();

    test(
        'Gọi next() nhiều lần với cùng context -> luôn cùng kết quả '
        '(không có state nội bộ, không side effect)', () {
      final context = _context(dueReviewCount: 3, quizAvailable: true);
      final first = planner.next(context);
      final second = planner.next(context);
      final third = planner.next(context);
      expect(first, LearningActivityType.review);
      expect(second, first);
      expect(third, first);
    });
  });

  group('SequentialLearningPlanner — order tuỳ chỉnh', () {
    test('order tuỳ chỉnh được tôn trọng (không hardcode Review trước)', () {
      const planner = SequentialLearningPlanner(
        order: [
          LearningActivityType.quiz,
          LearningActivityType.review,
          LearningActivityType.flashcard,
        ],
      );
      final context = _context(dueReviewCount: 5, quizAvailable: true);
      expect(planner.next(context), LearningActivityType.quiz);
    });

    test('order mặc định là Review -> Quiz -> Flashcard', () {
      const planner = SequentialLearningPlanner();
      expect(planner.order, [
        LearningActivityType.review,
        LearningActivityType.quiz,
        LearningActivityType.flashcard,
      ]);
    });
  });

  group('learningPlannerProvider', () {
    test('mặc định trả về SequentialLearningPlanner', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(learningPlannerProvider),
        isA<SequentialLearningPlanner>(),
      );
    });

    test(
        'override được để chuẩn bị cho AI Tutor sau này (giao diện '
        'LearningPlanner, không phải class cụ thể)', () {
      final fake = _FakePlanner();
      final container = ProviderContainer(
        overrides: [learningPlannerProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);

      expect(container.read(learningPlannerProvider), same(fake));
    });
  });
}

class _FakePlanner implements LearningPlanner {
  @override
  LearningActivityType? next(LearningPlanContext context) =>
      LearningActivityType.quiz;
}
