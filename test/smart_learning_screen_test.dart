import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/ai_tutor/presentation/tutor_home_screen.dart';
import 'package:quran_companion/features/learning_journey/presentation/learning_journey_screen.dart';
import 'package:quran_companion/features/smart_learning/presentation/smart_learning_screen.dart';
import 'package:quran_companion/features/smart_learning/presentation/widgets/session_summary_card.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cùng mẫu learning_journey_screen_test.dart (Sprint 16 Phase 2) — cả
/// 2 bài học đã đúc kết: (1) mọi thao tác Drift thật phải bọc trong
/// tester.runAsync(), (2) pump() PHẢI truyền Duration khớp độ trễ
/// thật để đồng hồ hoạt ảnh giả lập (go_router page-transition) tiến
/// đúng nhịp.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  late UserDatabase userDb;
  late AppDatabase appDb;
  late SharedPreferences prefs;

  setUp(() async {
    userDb = UserDatabase(NativeDatabase.memory());
    appDb = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await userDb.close();
    await appDb.close();
  });

  Widget wrap() {
    final router = GoRouter(
      initialLocation: AppRoutes.study,
      routes: [
        GoRoute(path: AppRoutes.study, builder: (_, __) => const StudyScreen()),
        GoRoute(
          path: AppRoutes.aiTutor,
          builder: (_, __) => const TutorHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.learningJourney,
          builder: (_, __) => const LearningJourneyScreen(),
        ),
        GoRoute(
          path: AppRoutes.smartLearning,
          builder: (_, __) => const SmartLearningScreen(),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userDatabaseProvider.overrideWithValue(userDb),
        appDatabaseProvider.overrideWithValue(appDb),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    const step = Duration(milliseconds: 200);
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(step);
      await tester.pump(step);
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
    }
  }

  /// StudyScreen -> AI Tutor -> Learning Journey -> chạm thẻ lối vào
  /// Smart Learning — đúng đường dẫn điều hướng THẬT (Sprint 17 Phase
  /// 2 mục 5), không nhảy thẳng route để bỏ qua bước tích hợp cần
  /// kiểm.
  Future<void> pumpAndNavigateToSmartLearning(WidgetTester tester) {
    return tester.runAsync(() async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('AI Tutor'));
      await tester.pump();
      await pumpUntilLoaded(tester);
      await tester.tap(find.text('View your Learning Journey'));
      await tester.pump();
      await pumpUntilLoaded(tester);
      await tester.tap(find.text('Get your Smart Session'));
      await tester.pump();
      await pumpUntilLoaded(tester);
    });
  }

  /// Nhiều màn hình trước đó vẫn còn trong Navigator stack — giới hạn
  /// tìm kiếm bên TRONG SmartLearningScreen (cùng lý do
  /// learning_journey_screen_test.dart).
  Finder inScreen(Finder finder) => find.descendant(
        of: find.byType(SmartLearningScreen),
        matching: finder,
      );

  testWidgets(
      'Learning Journey -> chạm "Get your Smart Session" -> SmartLearningScreen, '
      'hiện đề xuất chính + đề xuất khác cho người dùng mới', (tester) async {
    await pumpAndNavigateToSmartLearning(tester);

    expect(find.byType(SmartLearningScreen), findsOneWidget);
    // Người dùng mới -> 2 mục tiêu Ngày chưa đạt -> deepStudy (thứ
    // nhất, xem daily_learning_plan_generator.dart: goal Study trước
    // goal Review trong context.goals) + shortReview (thứ hai).
    expect(inScreen(find.byType(SessionSummaryCard)), findsOneWidget);
    expect(inScreen(find.text('Recommended session')), findsOneWidget);
    expect(inScreen(find.text('Deep study')), findsOneWidget);
    expect(inScreen(find.text('Other recommendations')), findsOneWidget);
    expect(inScreen(find.text('Short review')), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('Hiện đúng thời lượng ước lượng và số bước liên quan',
      (tester) async {
    await pumpAndNavigateToSmartLearning(tester);

    // deepStudy: 20 min, 1 bước liên quan (completeDailyStudyGoal).
    expect(inScreen(find.text('20 min')), findsOneWidget);
    expect(inScreen(find.text('1 related steps')), findsOneWidget);

    await _disposeTree(tester);
  });
}
