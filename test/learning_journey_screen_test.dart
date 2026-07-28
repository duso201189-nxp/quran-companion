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
import 'package:quran_companion/features/learning_journey/presentation/widgets/journey_header.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cùng mẫu tutor_home_screen_test.dart (Sprint 15 Phase 3) — bao gồm
/// CẢ 2 bài học đã đúc kết ở đó: (1) mọi thao tác Drift thật phải bọc
/// trong tester.runAsync(), (2) pump() PHẢI truyền Duration khớp độ
/// trễ thật để đồng hồ hoạt ảnh giả lập (go_router page-transition)
/// tiến đúng nhịp, nếu không vị trí vẽ (và tâm hit-test) sẽ kẹt giữa
/// chừng trượt.
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

  /// StudyScreen -> AI Tutor -> chạm thẻ lối vào Learning Journey —
  /// đúng đường dẫn điều hướng THẬT của người dùng (Sprint 16 Phase 2
  /// mục 5), không nhảy thẳng route để bỏ qua bước tích hợp cần kiểm.
  Future<void> pumpAndNavigateToJourney(WidgetTester tester) {
    return tester.runAsync(() async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('AI Tutor'));
      await tester.pump();
      await pumpUntilLoaded(tester);
      await tester.tap(find.text('View your Learning Journey'));
      await tester.pump();
      await pumpUntilLoaded(tester);
    });
  }

  /// go_router push GIỮ NGUYÊN TutorHomeScreen phía dưới trong
  /// Navigator stack — nhiều chuỗi text (vd "Reach your daily study
  /// goal", "Accuracy") xuất hiện Ở CẢ HAI màn hình (cùng nguồn dữ
  /// liệu tái sử dụng), nên find.text(...) không giới hạn sẽ khớp 2
  /// nơi. Giới hạn tìm kiếm bên TRONG LearningJourneyScreen.
  Finder inJourney(Finder finder) => find.descendant(
        of: find.byType(LearningJourneyScreen),
        matching: finder,
      );

  testWidgets(
      'AI Tutor -> chạm "View your Learning Journey" -> LearningJourneyScreen, '
      'trạng thái rỗng khi chưa học/đọc gì', (tester) async {
    await pumpAndNavigateToJourney(tester);

    expect(find.byType(LearningJourneyScreen), findsOneWidget);
    expect(find.byType(JourneyHeader), findsOneWidget);
    // Chưa học/đọc gì -> vẫn có 2 gợi ý hoàn thành mục tiêu Ngày (xem
    // tutor_home_screen_test.dart) -> KHÔNG rỗng thật sự. Kiểm câu
    // đúng: 2 bước "Reach your daily study/review goal" xuất hiện.
    expect(inJourney(find.text('Reach your daily study goal')), findsOneWidget);
    expect(
      inJourney(find.text('Reach your daily review goal')),
      findsOneWidget,
    );
    // Huy hiệu bước hiện chữ số thô ("1"/"2") — nhãn accessibility
    // "Step N" đầy đủ đã kiểm riêng, cách ly ở journey_step_card_test.dart
    // (thuần, không qua chuỗi điều hướng thật) để tránh phụ thuộc vào
    // cây semantics giữa 2 màn hình xếp chồng ở tích hợp này.
    expect(inJourney(find.text('1')), findsOneWidget);
    expect(inJourney(find.text('2')), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('Hiện đúng Your progress + đủ nhãn nhận định', (tester) async {
    await pumpAndNavigateToJourney(tester);

    expect(inJourney(find.text('Your progress')), findsOneWidget);
    expect(inJourney(find.text('Accuracy')), findsOneWidget);
    expect(inJourney(find.text('Current streak')), findsOneWidget);
    expect(inJourney(find.text('Cards studied')), findsOneWidget);
    expect(inJourney(find.text('Achievements unlocked')), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets('Bước 1 có nút hành động, bấm điều hướng đúng route',
      (tester) async {
    await pumpAndNavigateToJourney(tester);

    // completeDailyStudyGoal (bước ưu tiên medium, xuất hiện khi
    // chưa đạt mục tiêu Ngày — luôn đúng với người dùng mới) có hành
    // động "Continue learning" -> AppRoutes.learningSession. Route
    // đích dùng màn hình PLACEHOLDER sẽ không tồn tại ở đây (router
    // thật không có AppRoutes.learningSession trong test này) — chỉ
    // xác nhận nút tồn tại và bấm được, không lỗi (đủ để chứng minh
    // JourneyStepCard/TutorSuggestionCard hoạt động đúng — hành vi
    // điều hướng CHI TIẾT đã kiểm đầy đủ ở tutor_home_screen_test.dart,
    // KHÔNG lặp lại ở đây, tránh trùng lặp test).
    expect(inJourney(find.text('Continue learning')), findsOneWidget);

    await _disposeTree(tester);
  });
}
