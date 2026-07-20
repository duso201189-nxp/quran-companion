import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning_session/data/learning_planner_providers.dart';
import 'package:quran_companion/features/learning_session/domain/learning_planner.dart';
import 'package:quran_companion/features/learning_session/domain/learning_session_state.dart';
import 'package:quran_companion/features/learning_session/domain/sequential_learning_planner.dart';
import 'package:quran_companion/features/learning_session/presentation/learning_session_controller.dart';
import 'package:quran_companion/features/quiz/data/quiz_providers.dart';
import 'package:quran_companion/features/quiz/domain/entities/quiz_question.dart';

SrsCard _dummyCard(int i) => SrsCard(
      id: 'card-$i',
      itemType: LearningItemType.ayah,
      itemId: i,
      easeFactor: 2.5,
      intervalDays: 1,
      repetitions: 0,
      dueDate: 0,
      state: SrsCardState.review,
    );

QuizQuestion _dummyQuestion() => const QuizQuestion(
      type: QuizQuestionType.surahIdentification,
      promptText: 'x',
      promptIsArabic: true,
      options: ['a', 'b', 'c', 'd'],
      correctOptionIndex: 0,
      optionsAreArabic: false,
    );

/// Nguồn dueReviewCardsProvider giả, điều khiển được — phát số lượng
/// hiện tại ngay khi subscribe rồi tiếp tục theo dõi các lần đổi sau,
/// cùng mẫu "yield current rồi forward" đã dùng ở Sprint 10.
class _FakeReviewQueue {
  int _current;
  _FakeReviewQueue(this._current);
  final _controller = StreamController<int>.broadcast();

  void emit(int count) {
    _current = count;
    _controller.add(count);
  }

  Stream<List<SrsCard>> watch() async* {
    yield List.generate(_current, _dummyCard);
    yield* _controller.stream.map((n) => List.generate(n, _dummyCard));
  }
}

/// QuizSessionController giả — trả về trạng thái cố định ngay lập
/// tức, không chạm quizContentPoolProvider/QuranRepository thật.
class _FakeQuizSessionController extends QuizSessionController {
  _FakeQuizSessionController(this._fixed);
  final QuizSessionState _fixed;

  @override
  Future<QuizSessionState> build() async => _fixed;
}

class _FixedPlanner implements LearningPlanner {
  const _FixedPlanner(this.value);
  final LearningActivityType? value;

  @override
  LearningActivityType? next(LearningPlanContext context) => value;
}

class _CountingPlanner implements LearningPlanner {
  _CountingPlanner(this._inner);
  final LearningPlanner _inner;
  int callCount = 0;

  @override
  LearningActivityType? next(LearningPlanContext context) {
    callCount++;
    return _inner.next(context);
  }
}

void main() {
  late _FakeReviewQueue reviewQueue;

  ProviderContainer makeContainer({
    required int initialDueReview,
    QuizSessionState? quizState,
    LearningPlanner? planner,
  }) {
    reviewQueue = _FakeReviewQueue(initialDueReview);
    final container = ProviderContainer(
      overrides: [
        dueReviewCardsProvider.overrideWith((ref) => reviewQueue.watch()),
        quizSessionControllerProvider.overrideWith(
          () => _FakeQuizSessionController(
            quizState ??
                (
                  questions: [_dummyQuestion(), _dummyQuestion()],
                  currentIndex: 2,
                  score: 1,
                  isComplete: true,
                ),
          ),
        ),
        if (planner != null) learningPlannerProvider.overrideWithValue(planner),
      ],
    );
    return container;
  }

  group('session start', () {
    test('trạng thái ban đầu là notStarted, currentActivity null', () {
      final container = makeContainer(initialDueReview: 0);
      addTearDown(container.dispose);

      final state = container.read(learningSessionControllerProvider);
      expect(state.status, LearningSessionStatus.notStarted);
      expect(state.currentActivity, isNull);
    });

    test('start() chuyển sang inProgress khi có hoạt động khả dụng', () async {
      final container = makeContainer(initialDueReview: 3);
      addTearDown(container.dispose);

      await container.read(learningSessionControllerProvider.notifier).start();

      final state = container.read(learningSessionControllerProvider);
      expect(state.status, LearningSessionStatus.inProgress);
    });
  });

  group('review selected first', () {
    test('Review đến hạn -> start() chọn review trước tiên', () async {
      final container = makeContainer(initialDueReview: 5);
      addTearDown(container.dispose);

      await container.read(learningSessionControllerProvider.notifier).start();

      expect(
        container.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.review,
      );
    });
  });

  group('quiz selected', () {
    test('Review không đến hạn -> start() chọn quiz', () async {
      final container = makeContainer(initialDueReview: 0);
      addTearDown(container.dispose);

      await container.read(learningSessionControllerProvider.notifier).start();

      expect(
        container.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.quiz,
      );
    });
  });

  group('review completed', () {
    test(
        'hoàn thành Review -> đưa vào completedActivities, tích luỹ đúng '
        'số thẻ đã ôn (chênh lệch due trước/sau), chuyển sang quiz', () async {
      final container = makeContainer(initialDueReview: 3);
      addTearDown(container.dispose);
      final notifier =
          container.read(learningSessionControllerProvider.notifier);

      await notifier.start();
      expect(
        container.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.review,
      );

      // Mô phỏng người dùng đã ôn hết 3 thẻ (Review Session thật làm
      // việc này qua SchedulerRepository.applyReview — không mô
      // phỏng lại logic đó ở đây, chỉ thay đổi số liệu due để kiểm
      // tra LearningSessionController phản ứng đúng).
      reviewQueue.emit(0);
      await Future<void>.delayed(Duration.zero);

      await notifier.completeCurrentActivity();

      final state = container.read(learningSessionControllerProvider);
      expect(state.completedActivities, contains(LearningActivityType.review));
      expect(state.summary.reviewCardsCompleted, 3);
      expect(state.currentActivity, LearningActivityType.quiz);
    });
  });

  group('planner called again', () {
    test('LearningPlanner.next() được gọi đúng 1 lần mỗi bước chuyển',
        () async {
      final counting = _CountingPlanner(const SequentialLearningPlanner());
      final container = makeContainer(
        initialDueReview: 1,
        planner: counting,
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(learningSessionControllerProvider.notifier);

      await notifier.start();
      expect(counting.callCount, 1);

      reviewQueue.emit(0);
      await Future<void>.delayed(Duration.zero);
      await notifier.completeCurrentActivity();
      expect(counting.callCount, 2);

      await notifier.completeCurrentActivity(); // hoàn thành quiz
      expect(counting.callCount, 3);
    });
  });

  group('flashcard skipped', () {
    test(
        'Flashcard luôn không sẵn có (chưa cài) -> không bao giờ được '
        'chọn, phiên kết thúc sau khi Review + Quiz xong', () async {
      final container = makeContainer(initialDueReview: 1);
      addTearDown(container.dispose);
      final notifier =
          container.read(learningSessionControllerProvider.notifier);

      await notifier.start();
      expect(
        container.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.review,
      );

      reviewQueue.emit(0);
      await Future<void>.delayed(Duration.zero);
      await notifier.completeCurrentActivity(); // review xong -> quiz
      expect(
        container.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.quiz,
      );

      await notifier.completeCurrentActivity(); // quiz xong -> hết
      final state = container.read(learningSessionControllerProvider);
      expect(state.currentActivity, isNull);
      expect(state.status, LearningSessionStatus.completed);
      expect(
        state.completedActivities,
        isNot(contains(LearningActivityType.flashcard)),
      );
    });
  });

  group('session completed / planner returns null', () {
    test(
        'Không còn hoạt động nào khả dụng -> status completed, '
        'currentActivity null', () async {
      final container = makeContainer(initialDueReview: 0);
      addTearDown(container.dispose);
      final notifier =
          container.read(learningSessionControllerProvider.notifier);

      await notifier.start(); // -> quiz (review=0, flashcard luôn null)
      await notifier.completeCurrentActivity(); // quiz xong -> hết

      final state = container.read(learningSessionControllerProvider);
      expect(state.status, LearningSessionStatus.completed);
      expect(state.currentActivity, isNull);
    });

    test(
        'completeCurrentActivity() sau khi đã kết thúc -> no-op, không '
        'lỗi, không đổi state', () async {
      final container = makeContainer(initialDueReview: 0);
      addTearDown(container.dispose);
      final notifier =
          container.read(learningSessionControllerProvider.notifier);

      await notifier.start();
      await notifier.completeCurrentActivity(); // -> completed
      final completedState = container.read(learningSessionControllerProvider);

      await notifier.completeCurrentActivity(); // gọi thêm lần nữa
      expect(
        container.read(learningSessionControllerProvider),
        equals(completedState),
      );
    });
  });

  group('summary accumulated correctly', () {
    test('tóm tắt cuối phiên có đủ số liệu Review + Quiz', () async {
      final container = makeContainer(
        initialDueReview: 4,
        quizState: (
          questions: [
            _dummyQuestion(),
            _dummyQuestion(),
            _dummyQuestion(),
          ],
          currentIndex: 3,
          score: 2,
          isComplete: true,
        ),
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(learningSessionControllerProvider.notifier);

      await notifier.start(); // -> review
      reviewQueue.emit(0);
      await Future<void>.delayed(Duration.zero);
      await notifier.completeCurrentActivity(); // review xong -> quiz
      await notifier.completeCurrentActivity(); // quiz xong -> hết

      final summary = container.read(learningSessionControllerProvider).summary;
      expect(summary.reviewCardsCompleted, 4);
      expect(summary.quizScore, 2);
      expect(summary.quizTotal, 3);
      expect(summary.flashcardsCompleted, 0);
    });
  });

  group('provider override', () {
    test(
        'override learningPlannerProvider thay đổi hoạt động được chọn, '
        'không cần đổi LearningSessionController', () async {
      final container = makeContainer(
        initialDueReview: 5, // review lẽ ra sẽ được chọn trước
        planner: const _FixedPlanner(LearningActivityType.quiz),
      );
      addTearDown(container.dispose);

      await container.read(learningSessionControllerProvider.notifier).start();

      expect(
        container.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.quiz,
        reason: 'planner giả luôn trả quiz bất kể context',
      );
    });
  });

  group('deterministic behavior', () {
    test(
        'cùng trạng thái nguồn (due count, planner) -> start() luôn cho '
        'cùng kết quả giữa các phiên container độc lập', () async {
      final containerA = makeContainer(initialDueReview: 2);
      final containerB = makeContainer(initialDueReview: 2);
      addTearDown(containerA.dispose);
      addTearDown(containerB.dispose);

      await containerA.read(learningSessionControllerProvider.notifier).start();
      await containerB.read(learningSessionControllerProvider.notifier).start();

      expect(
        containerA.read(learningSessionControllerProvider).currentActivity,
        containerB.read(learningSessionControllerProvider).currentActivity,
      );
      expect(
        containerA.read(learningSessionControllerProvider).currentActivity,
        LearningActivityType.review,
      );
    });
  });
}
