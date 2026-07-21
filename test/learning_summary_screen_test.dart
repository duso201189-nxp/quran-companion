import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/features/learning_session/domain/learning_planner.dart';
import 'package:quran_companion/features/learning_session/domain/learning_session_state.dart';
import 'package:quran_companion/features/learning_session/domain/learning_session_summary.dart';
import 'package:quran_companion/features/learning_session/presentation/learning_summary_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

LearningSessionState _state({
  int reviewCardsCompleted = 0,
  int? quizScore,
  int? quizTotal,
  Set<LearningActivityType> completedActivities = const {},
  LearningSessionStatus status = LearningSessionStatus.completed,
}) =>
    (
      status: status,
      currentActivity: null,
      completedActivities: completedActivities,
      summary: LearningSessionSummary(
        reviewCardsCompleted: reviewCardsCompleted,
        quizScore: quizScore,
        quizTotal: quizTotal,
      ),
    );

Widget wrap(LearningSessionState state, {Locale locale = const Locale('en')}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => LearningSummaryScreen(state: state),
      ),
      GoRoute(
        path: AppRoutes.study,
        builder: (_, __) => const Scaffold(body: Text('STUDY_SCREEN')),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  group('summary rendering', () {
    testWidgets('dựng không lỗi, hiện tiêu đề và huy hiệu trạng thái',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          _state(
            reviewCardsCompleted: 3,
            completedActivities: {LearningActivityType.review},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session Summary'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });
  });

  group('review count', () {
    testWidgets('hiện đúng số thẻ Review đã ôn', (tester) async {
      await tester.pumpWidget(wrap(_state(reviewCardsCompleted: 7)));
      await tester.pumpAndSettle();

      expect(find.text('Reviewed 7 cards'), findsOneWidget);
    });

    testWidgets('vẫn hiện dòng Review dù = 0 (không ẩn)', (tester) async {
      await tester.pumpWidget(wrap(_state(reviewCardsCompleted: 0)));
      await tester.pumpAndSettle();

      expect(find.text('Reviewed 0 cards'), findsOneWidget);
    });
  });

  group('quiz score', () {
    testWidgets('hiện điểm Quiz khi có score/total', (tester) async {
      await tester.pumpWidget(
        wrap(_state(quizScore: 6, quizTotal: 10)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quiz: 6/10'), findsOneWidget);
    });

    testWidgets(
        'không hiện dòng Quiz khi chưa hoàn thành Quiz (score/'
        'total null)', (tester) async {
      await tester.pumpWidget(wrap(_state()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Quiz:'), findsNothing);
    });
  });

  group('completed activities', () {
    testWidgets(
        'Review + Quiz hoàn thành, Flashcard chưa -> đúng trạng '
        'thái từng dòng', (tester) async {
      await tester.pumpWidget(
        wrap(
          _state(
            completedActivities: {
              LearningActivityType.review,
              LearningActivityType.quiz,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Activities completed'), findsOneWidget);
      expect(find.text('Spaced repetition'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget);
      expect(find.text('Flashcards'), findsOneWidget);
      // Chỉ Flashcard (chưa xây, luôn bị bỏ qua) hiện nhãn "Not completed".
      expect(find.text('Not completed'), findsOneWidget);
    });

    testWidgets(
        'không hoạt động nào hoàn thành -> cả 3 dòng đều "Not '
        'completed"', (tester) async {
      await tester.pumpWidget(wrap(_state()));
      await tester.pumpAndSettle();

      expect(find.text('Not completed'), findsNWidgets(3));
    });
  });

  group('localization', () {
    testWidgets(
        'locale vi hiện đúng chuỗi tiếng Việt, không phải tiếng '
        'Anh', (tester) async {
      await tester.pumpWidget(
        wrap(
          _state(
            reviewCardsCompleted: 2,
            quizScore: 5,
            quizTotal: 10,
            completedActivities: {LearningActivityType.review},
          ),
          locale: const Locale('vi'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tóm tắt buổi học'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);
      expect(find.text('Đã ôn 2 thẻ'), findsOneWidget);
      expect(find.text('Trắc nghiệm: 5/10 điểm'), findsOneWidget);
      expect(find.text('Hoạt động đã hoàn thành'), findsOneWidget);
      expect(find.text('Xong'), findsOneWidget);
      // Không hiện chuỗi tiếng Anh.
      expect(find.text('Session Summary'), findsNothing);
      expect(find.text('Done'), findsNothing);
    });
  });

  group('done button', () {
    testWidgets('bấm Done điều hướng về StudyScreen', (tester) async {
      await tester.pumpWidget(wrap(_state(reviewCardsCompleted: 1)));
      await tester.pumpAndSettle();

      expect(find.text('STUDY_SCREEN'), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('STUDY_SCREEN'), findsOneWidget);
      expect(find.text('Session Summary'), findsNothing);
    });
  });
}
