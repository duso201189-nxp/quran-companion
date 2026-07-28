import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../flashcards/data/flashcard_providers.dart';
import '../../flashcards/presentation/flashcard_review_screen.dart';
import '../../learning/data/scheduler_providers.dart';
import '../../learning/presentation/review_session_screen.dart';
import '../../quiz/data/quiz_providers.dart';
import '../../quiz/presentation/quiz_session_screen.dart';
import '../domain/learning_planner.dart';
import '../domain/learning_session_state.dart';
import 'learning_session_controller.dart';
import 'learning_summary_screen.dart';

/// Điểm vào duy nhất của một Learning Session (Sprint 11 Phase 3) —
/// MỘT route (`/learning-session`), thân màn hình đổi theo
/// `currentActivity` của LearningSessionController. KHÔNG có route
/// riêng cho từng hoạt động trong phiên — đây chính là cơ chế khiến
/// người dùng không quay lại StudyScreen giữa các hoạt động (không
/// có route nào để "back" tới ngoài chính StudyScreen, chỉ có 1 lần
/// push duy nhất).
///
/// Tái dùng NGUYÊN VẸN ReviewSessionScreen/QuizSessionScreen làm giá
/// trị trả về trực tiếp của build() (không bọc thêm Scaffold/AppBar
/// ở đây) — không có Scaffold lồng nhau, không sửa 2 màn hình đó.
class LearningSessionScreen extends ConsumerStatefulWidget {
  const LearningSessionScreen({super.key});

  @override
  ConsumerState<LearningSessionScreen> createState() =>
      _LearningSessionScreenState();
}

class _LearningSessionScreenState extends ConsumerState<LearningSessionScreen> {
  /// Chặn gọi completeCurrentActivity() nhiều lần cho CÙNG một lần
  /// hoàn thành (dueReviewCardsProvider/quizSessionControllerProvider
  /// có thể phát lại giá trị "đã xong" nhiều lần liên tiếp) — reset
  /// mỗi khi hoạt động hiện tại đổi. Chỉ tồn tại trong widget mới này
  /// — không đổi LearningSessionController (Phase 2 giữ nguyên).
  bool _reviewCompletionHandled = false;
  bool _quizCompletionHandled = false;
  bool _flashcardCompletionHandled = false;

  @override
  void initState() {
    super.initState();
    ref.read(learningSessionControllerProvider.notifier).start();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(learningSessionControllerProvider);

    // Chỉ lắng nghe tín hiệu hoàn thành của hoạt động ĐANG diễn ra —
    // đặc biệt: không đọc quizSessionControllerProvider khi Quiz chưa
    // phải hoạt động hiện tại, để không kích hoạt sinh câu hỏi
    // (AsyncNotifier.build()) trước khi người dùng thật sự vào Quiz
    // (cùng lý do đã áp dụng trong LearningSessionController Phase 2).
    if (session.currentActivity == LearningActivityType.review) {
      ref.listen(dueReviewCardsProvider, (previous, next) {
        final due = next.valueOrNull;
        if (due != null && due.isEmpty && !_reviewCompletionHandled) {
          _reviewCompletionHandled = true;
          ref
              .read(learningSessionControllerProvider.notifier)
              .completeCurrentActivity();
        }
      });
    } else if (_reviewCompletionHandled) {
      _reviewCompletionHandled = false;
    }

    if (session.currentActivity == LearningActivityType.quiz) {
      ref.listen(quizSessionControllerProvider, (previous, next) {
        final quiz = next.valueOrNull;
        if (quiz != null && quiz.isComplete && !_quizCompletionHandled) {
          _quizCompletionHandled = true;
          ref
              .read(learningSessionControllerProvider.notifier)
              .completeCurrentActivity();
        }
      });
    } else if (_quizCompletionHandled) {
      _quizCompletionHandled = false;
    }

    // Cùng cơ chế lắng nghe hoàn thành ở trên, cho Flashcard (Sprint
    // 13 Phase 2) — dueFlashcardCardsProvider rỗng = đã ôn hết.
    if (session.currentActivity == LearningActivityType.flashcard) {
      ref.listen(dueFlashcardCardsProvider, (previous, next) {
        final due = next.valueOrNull;
        if (due != null && due.isEmpty && !_flashcardCompletionHandled) {
          _flashcardCompletionHandled = true;
          ref
              .read(learningSessionControllerProvider.notifier)
              .completeCurrentActivity();
        }
      });
    } else if (_flashcardCompletionHandled) {
      _flashcardCompletionHandled = false;
    }

    return switch (session.status) {
      LearningSessionStatus.notStarted => const _LearningSessionLoading(),
      LearningSessionStatus.completed => LearningSummaryScreen(state: session),
      LearningSessionStatus.inProgress => switch (session.currentActivity!) {
          LearningActivityType.review => const ReviewSessionScreen(),
          LearningActivityType.quiz => const QuizSessionScreen(),
          LearningActivityType.flashcard => const FlashcardReviewScreen(),
        },
    };
  }
}

class _LearningSessionLoading extends StatelessWidget {
  const _LearningSessionLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
