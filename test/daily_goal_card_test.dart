import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/locale/locale_controller.dart';
import 'package:quran_companion/features/home/presentation/home_screen.dart';
import 'package:quran_companion/features/stats/data/daily_goal_store.dart';
import 'package:quran_companion/features/stats/data/study_session_providers.dart';
import 'package:quran_companion/features/stats/presentation/stats_screen.dart';
import 'package:quran_companion/features/stats/presentation/widgets/daily_goal_card.dart';

import 'fixtures/app_harness.dart';

/// Sprint 6.3 — Daily Goal First-Run Experience.
///
/// `DailyGoalCard` (trước đây `_DailyGoalCard`, riêng của Trang chủ)
/// giờ là widget dùng chung, đặt thêm ở màn Thống kê (xem doc comment
/// tại định nghĩa widget). Thẻ nằm khá xa trong danh sách cuộn của cả
/// hai màn — dùng viewport ảo CAO thay vì tự cuộn (cùng mẫu
/// `setViewSize`/`tester.view.physicalSize` đã dùng ở
/// search_responsive_test.dart/app_test.dart): mọi nội dung vừa trong
/// MỘT khung hình.
///
/// `dailyGoalProgressProvider` phụ thuộc `todayStudySummaryProvider`
/// — một truy vấn Drift THẬT qua `NativeDatabase.memory()`. Nhóm test
/// này chỉ quan tâm hành vi của `DailyGoalCard`/`dailyGoalStoreProvider`
/// (chỉ tiêu đặt/đọc qua SharedPreferences), không quan tâm dữ liệu
/// phiên đọc — ghi đè `todayStudySummaryProvider` về một giá trị cố
/// định (0 phút hôm nay) qua [makeApp]'s `extraOverrides` để tránh
/// phụ thuộc thời gian THỰC của lần mở database đầu tiên trong tiến
/// trình test (không phải đồng hồ ảo mà `tester.pump` điều khiển —
/// từng gây "pumpAndSettle timed out"/"0 widget tìm thấy" không ổn
/// định giữa các lần chạy).
List<Override> _fixedStudySummary() => [
      todayStudySummaryProvider.overrideWith(
        (ref) async => const (totalDurationSec: 0, sessionCount: 0),
      ),
    ];

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _goToStats(
  WidgetTester tester, {
  String tabLabel = 'Thống kê',
}) async {
  await tester.tap(find.text(tabLabel).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'máy mới cài -> cả Trang chủ và Thống kê đều hiện "Chưa đặt mục '
      'tiêu — chạm để đặt."', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      await makeApp(extraOverrides: _fixedStudySummary()),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(HomeScreen),
        matching: find.text('Chưa đặt mục tiêu — chạm để đặt.'),
      ),
      findsOneWidget,
    );

    await _goToStats(tester);
    expect(
      find.descendant(
        of: find.byType(StatsScreen),
        matching: find.text('Chưa đặt mục tiêu — chạm để đặt.'),
      ),
      findsOneWidget,
    );

    await flushPendingDriftTimers(tester);
  });

  testWidgets(
      'đã có mục tiêu -> cả Trang chủ và Thống kê đều hiện đúng tiến '
      'độ', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      await makeApp(
        prefs: {DailyGoalStore.minutesKey: 20},
        extraOverrides: _fixedStudySummary(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(HomeScreen),
        matching: find.text('0 / 20 phút hôm nay'),
      ),
      findsOneWidget,
    );

    await _goToStats(tester);
    expect(
      find.descendant(
        of: find.byType(StatsScreen),
        matching: find.text('0 / 20 phút hôm nay'),
      ),
      findsOneWidget,
    );

    await flushPendingDriftTimers(tester);
  });

  testWidgets(
      'đổi mục tiêu từ thẻ trên Thống kê -> thẻ trên Trang chủ cũng '
      'cập nhật ngay (một nguồn sự thật)', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      await makeApp(
        prefs: {DailyGoalStore.minutesKey: 20},
        extraOverrides: _fixedStudySummary(),
      ),
    );
    await tester.pumpAndSettle();

    await _goToStats(tester);
    expect(
      find.descendant(
        of: find.byType(StatsScreen),
        matching: find.text('0 / 20 phút hôm nay'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(StatsScreen),
        matching: find.text('Mục tiêu học'),
      ),
    );
    await tester.pumpAndSettle();

    final minutesField = find.byType(TextField).first;
    await tester.enterText(minutesField, '30');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(StatsScreen),
        matching: find.text('0 / 30 phút hôm nay'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Trang chủ').last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(HomeScreen),
        matching: find.text('0 / 30 phút hôm nay'),
      ),
      findsOneWidget,
    );

    await flushPendingDriftTimers(tester);
  });

  testWidgets(
      'ngôn ngữ Ả Rập (RTL) -> thẻ Mục tiêu học trên Thống kê vẽ đúng '
      'hướng, không lỗi layout', (tester) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      await makeApp(
        prefs: {LocaleController.prefsKey: 'ar'},
        extraOverrides: _fixedStudySummary(),
      ),
    );
    await tester.pumpAndSettle();

    await _goToStats(tester, tabLabel: 'الإحصائيات');

    expect(tester.takeException(), isNull);
    final cardFinder = find.descendant(
      of: find.byType(StatsScreen),
      matching: find.byType(DailyGoalCard),
    );
    expect(cardFinder, findsOneWidget);

    final directionality = Directionality.of(tester.element(cardFinder));
    expect(directionality, TextDirection.rtl);

    await flushPendingDriftTimers(tester);
  });
}
