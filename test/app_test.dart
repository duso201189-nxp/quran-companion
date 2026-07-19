import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/locale/locale_controller.dart';
import 'package:quran_companion/app/theme/theme_controller.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';

import 'fixtures/app_harness.dart';

void main() {
  group('ThemeController', () {
    test('mặc định là ThemeMode.system khi chưa lưu gì', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      expect(container.read(themeControllerProvider), ThemeMode.system);
    });

    test('khôi phục đúng chế độ đã lưu từ lần trước', () async {
      final container = await makeContainer(
        prefs: {ThemeController.prefsKey: 'dark'},
      );
      addTearDown(container.dispose);

      expect(container.read(themeControllerProvider), ThemeMode.dark);
    });

    test('setMode cập nhật state và lưu vào SharedPreferences', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container
          .read(themeControllerProvider.notifier)
          .setMode(ThemeMode.dark);

      expect(container.read(themeControllerProvider), ThemeMode.dark);
      expect(
        container.read(sharedPreferencesProvider).getString(
              ThemeController.prefsKey,
            ),
        'dark',
      );
    });

    test('giá trị lưu bị hỏng -> quay về system, không crash', () async {
      final container = await makeContainer(
        prefs: {ThemeController.prefsKey: 'khong_hop_le'},
      );
      addTearDown(container.dispose);

      expect(container.read(themeControllerProvider), ThemeMode.system);
    });
  });

  group('LocaleController', () {
    test('mặc định là tiếng Việt', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      expect(container.read(localeControllerProvider), const Locale('vi'));
    });

    test('khôi phục ngôn ngữ đã lưu', () async {
      final container = await makeContainer(
        prefs: {LocaleController.prefsKey: 'ar'},
      );
      addTearDown(container.dispose);

      expect(container.read(localeControllerProvider), const Locale('ar'));
    });

    test('setLanguage lưu và cập nhật state', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(localeControllerProvider.notifier).setLanguage('en');

      expect(container.read(localeControllerProvider), const Locale('en'));
      expect(
        container.read(sharedPreferencesProvider).getString(
              LocaleController.prefsKey,
            ),
        'en',
      );
    });

    test('mã ngôn ngữ không hỗ trợ -> bị bỏ qua', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      await container.read(localeControllerProvider.notifier).setLanguage('fr');

      expect(container.read(localeControllerProvider), const Locale('vi'));
    });
  });

  group('Điều hướng & Giao diện', () {
    testWidgets('hiển thị đủ 5 tab, mở đúng Trang chủ (tiếng Việt)',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      expect(find.text('Trang chủ'), findsWidgets);
      expect(find.text("Qur'an"), findsWidgets);
      expect(find.text('Học'), findsWidgets);
      expect(find.text('Thống kê'), findsWidgets);
      expect(find.text('Hồ sơ'), findsWidgets);
    });

    testWidgets('đi qua đủ 5 tab, mỗi tab hiển thị nội dung riêng',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      // Trang chủ là tab mặc định — dashboard có mục Truy cập nhanh.
      expect(find.text('Truy cập nhanh'), findsOneWidget);

      await tester.tap(find.text("Qur'an").last);
      await tester.pumpAndSettle();
      expect(find.text('Tìm Surah theo tên hoặc số...'), findsOneWidget);

      await tester.tap(find.text('Học').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Flashcard'), findsOneWidget);

      await tester.tap(find.text('Thống kê').last);
      await tester.pumpAndSettle();
      expect(find.text('Ngày đọc'), findsOneWidget);

      await tester.tap(find.text('Hồ sơ').last);
      await tester.pumpAndSettle();
      expect(find.text('Giao diện'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);

      // Tab Thống kê mở stream Drift thật (UserDatabase bộ nhớ).
      // Drift debounce việc đóng mỗi query stream bằng 1 Timer
      // duration-zero, CHỈ được tạo khi ProviderScope thật sự dispose
      // (huỷ StreamProvider) — điều này bình thường xảy ra SAU khi
      // hàm test kết thúc (dọn cây widget tự động), quá muộn để
      // pump() bên trong test bắt kịp. Chủ động thay cây bằng widget
      // rỗng NGAY TRONG test rồi pump thêm 1 nhịp để timer đó được
      // tạo VÀ chạy xong trước khi flutter_test kiểm tra
      // "không còn Timer treo" lúc kết thúc test.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });

    testWidgets('chọn chế độ Tối đổi themeMode của MaterialApp',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hồ sơ').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tối'));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('đổi ngôn ngữ sang English cập nhật toàn bộ nhãn',
        (tester) async {
      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hồ sơ').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsWidgets);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('màn hình hẹp (< 800px) dùng NavigationBar dưới đáy',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('màn hình rộng (>= 800px) dùng NavigationRail bên trái',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(await makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
