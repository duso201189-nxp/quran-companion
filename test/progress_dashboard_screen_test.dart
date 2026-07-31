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
import 'package:quran_companion/features/analytics/presentation/progress_dashboard_screen.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cùng mẫu _disposeTree trong flashcard_ux_test.dart (Sprint 13
/// Phase 3) — buộc ProviderScope/StreamProvider Drift dispose NGAY
/// TRONG thân test, tránh lỗi giả "Timer is still pending" của
/// flutter_test khi 1 màn hình dùng nhiều database bộ nhớ cùng lúc.
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
        GoRoute(
          path: AppRoutes.study,
          builder: (_, __) => const StudyScreen(),
        ),
        GoRoute(
          path: AppRoutes.progressDashboard,
          builder: (_, __) => const ProgressDashboardScreen(),
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

  /// ProgressDashboardScreen ghép NHIỀU repository/2 database bộ nhớ
  /// CÙNG LÚC (Phase 2.2 thêm learningGoalsProvider/achievementsProvider
  /// — nay là 5 provider bất đồng bộ độc lập, không chỉ 3 như Phase 1)
  /// — NativeDatabase chạy trên isolate nền, cần vòng lặp sự kiện
  /// THẬT để hoàn tất giao tiếp liên-isolate; pumpAndSettle()/pump()
  /// đơn thuần chỉ mô phỏng thời gian (fake async), không đủ để những
  /// Future đó thật sự xong. Toàn bộ tương tác PHẢI nằm trong CÙNG 1
  /// tester.runAsync().
  ///
  /// DÙNG VÒNG LẶP CHỜ-VÀ-BƠM thay vì 1 khoảng trễ cố định — càng
  /// nhiều provider bất đồng bộ chạy song song, thời gian hoàn tất
  /// càng dao động (đã xác nhận: 1 khoảng trễ cố định 2 giây đủ cho 3
  /// provider ở Phase 2.1 nhưng KHÔNG còn đủ ổn định cho 5 provider ở
  /// Phase 2.2); bơm lặp lại tới khi ProgressDashboardScreen hết mọi
  /// CircularProgressIndicator (nghĩa là mọi khu vực đã rời trạng
  /// thái loading) đáng tin hơn 1 con số cố định đoán mò.
  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
    }
  }

  Future<void> pumpAndWaitForData(WidgetTester tester) {
    return tester.runAsync(() async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('Progress'));
      await tester.pump();
      await pumpUntilLoaded(tester);
    });
  }

  /// ListView (kể cả constructor "children:" liệt kê sẵn) vẫn dựng
  /// theo Sliver — CHỈ build phần tử trong viewport + cacheExtent mặc
  /// định (~250px), KHÔNG dựng toàn bộ danh sách ngay cả khi đã có đủ
  /// dữ liệu. Sau khi thêm Goals/Achievements (Phase 2.2), History/
  /// Insights bị đẩy xuống dưới vùng dựng sẵn đó — find.text(...) tìm
  /// không thấy KHÔNG PHẢI vì thiếu dữ liệu/còn loading, mà vì phần tử
  /// chưa từng được dựng vào cây Element. Cuộn xuống (như người dùng
  /// thật) để buộc Sliver dựng phần còn lại trước khi kiểm tra.
  Future<void> scrollToText(WidgetTester tester, String text) {
    return tester.scrollUntilVisible(
      find.text(text),
      300,
      scrollable: find.descendant(
        of: find.byType(ProgressDashboardScreen),
        matching: find.byType(Scrollable),
      ),
    );
  }

  /// _InsightsSection (khác _HistorySection) đặt CẢ tiêu đề lẫn nội
  /// dung BÊN TRONG insightsAsync.when(data:...) — không có nhãn cố
  /// định nào hiện trước khi provider xong, nên KHÔNG dùng
  /// scrollToText được (không có chữ ổn định để cuộn tới trước khi có
  /// dữ liệu). Cuộn 1 khoảng CỐ ĐỊNH xuống cuối trang trước — việc này
  /// tự kích hoạt performanceInsightsProvider lần đầu (widget vừa
  /// được dựng vào cây, ref.watch mới chạy) — rồi CHỜ THẬT
  /// (pumpUntilLoaded, trong CÙNG runAsync) để provider vừa khởi tạo
  /// đó có thời gian hoàn tất, giống hệt bước tap('Week') ở
  /// History section.
  Future<void> scrollToBottomAndWait(WidgetTester tester) {
    final scrollable = find.descendant(
      of: find.byType(ProgressDashboardScreen),
      matching: find.byType(Scrollable),
    );
    return tester.runAsync(() async {
      for (var i = 0; i < 10; i++) {
        await tester.drag(scrollable, const Offset(0, -600));
        await tester.pump();
      }
      await pumpUntilLoaded(tester);
    });
  }

  testWidgets(
      'StudyScreen -> chạm Progress -> ProgressDashboardScreen, '
      'trạng thái rỗng khi chưa học gì', (tester) async {
    await pumpAndWaitForData(tester);

    expect(find.byType(ProgressDashboardScreen), findsOneWidget);
    expect(
      find.text(
        'No flashcards studied yet — stats will show up once you start '
        'learning.',
      ),
      findsOneWidget,
    );

    await _disposeTree(tester);
  });

  testWidgets('History section hiện bộ chọn Ngày/Tuần/Tháng', (tester) async {
    await pumpAndWaitForData(tester);
    await scrollToText(tester, 'Day');

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);

    // Đổi granularity tạo 1 family instance MỚI của
    // learningHistoryProvider — cũng cần vòng sự kiện thật để
    // NativeDatabase hoàn tất truy vấn, giống pumpAndWaitForData ở
    // trên, nên dùng lại đúng pumpUntilLoaded.
    //
    // SegmentedButton bọc mỗi nhãn trong Tooltip — find.text('Week')
    // khớp cả bản sao ẩn của Tooltip (định vị ngoài khung nhìn cho
    // tới khi hiện), không phải overflow thật; tâm điểm hit-test vẫn
    // rơi đúng nút hiển thị nên tap hoạt động đúng, chỉ cảnh báo giả.
    await tester.runAsync(() async {
      await tester.tap(find.text('Week'), warnIfMissed: false);
      await tester.pump();
      await pumpUntilLoaded(tester);
    });

    // Đổi granularity không lỗi, biểu đồ vẫn hiện (rỗng vì chưa có
    // phiên đọc nào).
    expect(
      find.text('No reading activity in this period yet.'),
      findsOneWidget,
    );

    await _disposeTree(tester);
  });

  testWidgets(
      'Performance Insights hiện đủ 4 nhóm, rỗng khi chưa có '
      'Flashcard nào', (tester) async {
    await pumpAndWaitForData(tester);
    await scrollToBottomAndWait(tester);

    expect(find.text('Weak roots'), findsOneWidget);
    expect(find.text('Most difficult'), findsOneWidget);
    expect(find.text('Frequently forgotten'), findsOneWidget);
    expect(find.text('Fastest improving'), findsOneWidget);

    await _disposeTree(tester);
  });

  testWidgets(
      'Goals & Achievements (Sprint 14 Phase 2.2 mục 5) — hiện đủ 3 '
      'mục tiêu + 6 thành tựu, tất cả chưa đạt khi chưa học/đọc gì',
      (tester) async {
    await pumpAndWaitForData(tester);

    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);

    // 3 GoalCard — nhãn tái dùng đúng LearningGoalKind.
    expect(find.text('Daily study'), findsOneWidget);
    expect(find.text('Daily reviews'), findsOneWidget);
    expect(find.text('Weekly study'), findsOneWidget);
    // Chưa học/đọc gì -> current=0, chưa đạt -> không có dấu tick nào
    // của GoalCard/AchievementCard (Icons.check_circle_rounded).
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

    // 6 AchievementCard — đủ tiêu đề, đều khoá (icon ổ khoá).
    expect(find.text('First study'), findsOneWidget);
    expect(find.text('10 cards studied'), findsOneWidget);
    expect(find.text('100 cards studied'), findsOneWidget);
    expect(find.text('7-day streak'), findsOneWidget);
    expect(find.text('30-day streak'), findsOneWidget);
    expect(find.text('Sharp memory'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(6));

    await _disposeTree(tester);
  });
}
