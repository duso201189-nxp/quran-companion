import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/locale/locale_controller.dart';
import 'package:quran_companion/features/home/presentation/home_screen.dart';
import 'package:quran_companion/features/khatm/data/khatm_cycle_providers.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/features/stats/data/daily_goal_store.dart';

import 'fixtures/app_harness.dart';

/// Sprint 5.1 (Finding 2) — nhãn thẻ "Đọc tiếp" trên Trang chủ phải
/// phản ánh ĐÚNG việc đã từng đọc hay chưa, không phải việc có Surah
/// gợi ý để hiển thị (hai thứ khác nhau — `lastSurah` luôn có giá trị
/// nhờ fallback gợi ý Al-Fatihah, `lastAyahIndex` mới là tín hiệu thật
/// của "đã từng đọc"). Xem doc comment tại chỗ sửa trong
/// home_screen.dart.
// HomeScreen giờ luôn dựng _GettingStartedCard (Sprint 6.2), và widget
// đó watch latestKhatmCycleProvider — một StreamProvider.autoDispose
// Drift THẬT, có trên MỌI test dựng HomeScreen qua makeApp() trong
// file này, kể cả hai test Finding 1/2 phía trên. Drift đóng stream
// query bằng Timer(0); nếu cây widget bị testWidgets tự dỡ NGAY khi
// thân test return, Timer(0) đó chưa kịp chạy và flutter_test báo lỗi
// bất biến "!timersPending". Cùng nguyên nhân, cùng cách chữa đã dùng
// ở reading_screen_test.dart/search_screen_test.dart cho
// activeKhatmCycleProvider: tự dỡ cây rồi bơm thêm khung hình có trôi
// thời gian TRƯỚC KHI thân test return.
Future<void> flushPendingDriftTimers(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets(
      'máy mới cài (chưa đọc gì) -> hiện "Bắt đầu đọc", KHÔNG phải '
      '"Đọc tiếp"', (tester) async {
    await tester.pumpWidget(await makeApp());
    await tester.pumpAndSettle();

    expect(find.text('Bắt đầu đọc'), findsOneWidget);
    expect(find.text('Đọc tiếp'), findsNothing);

    await flushPendingDriftTimers(tester);
  });

  testWidgets('đã có lịch sử đọc -> hiện "Đọc tiếp", KHÔNG phải "Bắt đầu đọc"',
      (tester) async {
    await tester.pumpWidget(
      await makeApp(
        prefs: {
          ReadingPositionStore.kLastSurah: 1,
          ReadingPositionStore.posKey(1): 0,
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đọc tiếp'), findsOneWidget);
    expect(find.text('Bắt đầu đọc'), findsNothing);

    await flushPendingDriftTimers(tester);
  });

  /// Sprint 6.2 — thẻ "Bắt đầu" trên Trang chủ. Trạng thái xong/chưa
  /// của mỗi việc phải suy THẲNG từ dữ liệu thật đang có, không có cờ
  /// "đã hoàn thành onboarding" nào được lưu riêng — các test dưới đây
  /// xác nhận đúng cả sáu kịch bản bắt buộc trong yêu cầu sprint.
  group('Sprint 6.2 — Getting Started Card', () {
    testWidgets(
        'máy mới cài -> card "Bắt đầu" hiện đủ ba việc, cả ba đều chưa xong',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      expect(find.text('Bắt đầu'), findsOneWidget);
      expect(find.text('Đọc Ayah đầu tiên'), findsOneWidget);
      expect(find.text('Đặt Mục tiêu học'), findsOneWidget);
      expect(find.text('Bắt đầu Khatm đầu tiên'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(3));

      await flushPendingDriftTimers(tester);
    });

    testWidgets('đã đọc một Ayah -> việc "Đọc Ayah đầu tiên" đánh dấu xong',
        (tester) async {
      await tester.pumpWidget(
        await makeApp(
          prefs: {
            ReadingPositionStore.kLastSurah: 1,
            ReadingPositionStore.posKey(1): 0,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bắt đầu'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));

      await flushPendingDriftTimers(tester);
    });

    testWidgets('đã đặt Mục tiêu học -> việc "Đặt Mục tiêu học" đánh dấu xong',
        (tester) async {
      await tester.pumpWidget(
        await makeApp(prefs: {DailyGoalStore.ayahsKey: 10}),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bắt đầu'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));

      await flushPendingDriftTimers(tester);
    });

    testWidgets(
        'đã bắt đầu một Khatm -> việc "Bắt đầu Khatm đầu tiên" đánh dấu xong',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container
          .read(khatmCycleRepositoryProvider)
          .startCycle(name: 'Ramadan');
      await tester.pumpAndSettle();

      expect(find.text('Bắt đầu'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsNWidgets(2));

      await flushPendingDriftTimers(tester);
    });

    testWidgets('cả ba việc đã xong -> card "Bắt đầu" tự biến mất',
        (tester) async {
      await tester.pumpWidget(
        await makeApp(
          prefs: {
            ReadingPositionStore.kLastSurah: 1,
            ReadingPositionStore.posKey(1): 0,
            DailyGoalStore.ayahsKey: 10,
          },
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
      );
      await container
          .read(khatmCycleRepositoryProvider)
          .startCycle(name: 'Ramadan');
      await tester.pumpAndSettle();

      expect(find.text('Bắt đầu'), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);

      await flushPendingDriftTimers(tester);
    });

    testWidgets(
        'ngôn ngữ Ả Rập (RTL) -> card "Bắt đầu" vẽ đúng hướng, không lỗi '
        'layout', (tester) async {
      await tester.pumpWidget(
        await makeApp(prefs: {LocaleController.prefsKey: 'ar'}),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('ابدأ الآن'), findsOneWidget);
      expect(find.text('اقرأ أول آية'), findsOneWidget);
      expect(find.text('حدد هدفًا يوميًا'), findsOneWidget);
      expect(find.text('ابدأ أول ختمة'), findsOneWidget);

      final directionality = Directionality.of(
        tester.element(find.text('ابدأ الآن')),
      );
      expect(directionality, TextDirection.rtl);

      await flushPendingDriftTimers(tester);
    });
  });
}
