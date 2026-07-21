import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/search/presentation/search_screen.dart';
import 'package:quran_companion/features/search/presentation/widgets/result_card.dart';

import 'fixtures/app_harness.dart';
import 'fixtures/search_test_harness.dart';

/// Bề rộng đại diện cho từng lớp thiết bị — khớp đúng breakpoint đã
/// dùng ở `AppScaffold` (`railBreakpoint = 800`,
/// `extendedRailBreakpoint = 1100`), cộng thêm một mốc điện thoại rất
/// hẹp (320) không có trong `app_test.dart`'s existing 400px mốc, để
/// stress-test biên dưới.
const _breakpoints = <String, double>{
  'phone hẹp (320)': 320,
  'phone (400)': 400,
  'tablet / rail (900)': 900,
  'desktop / extended rail (1300)': 1300,
};

void main() {
  group('Task 7.1.17 — không tràn layout ở mọi bề rộng', () {
    for (final entry in _breakpoints.entries) {
      testWidgets('${entry.key}: mở Search, Empty State không lỗi',
          (tester) async {
        await openSearchScreen(tester, viewSize: Size(entry.value, 800));

        expect(find.byType(SearchEmptyState), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          '${entry.key}: Mode Switch + Scope Chips dựng được, '
          'không lỗi', (tester) async {
        await openSearchScreen(tester, viewSize: Size(entry.value, 800));

        expect(find.byType(SegmentedButton<SearchMode>), findsOneWidget);
        expect(find.byType(ChoiceChip), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
          '${entry.key}: Results preview (nội dung dày nhất) '
          'không lỗi', (tester) async {
        await openSearchScreen(tester, viewSize: Size(entry.value, 800));
        await pickDevPreview(tester, 'Results');

        expect(find.byType(ResultCard), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('${entry.key}: Loading + Error preview không lỗi',
          (tester) async {
        await openSearchScreen(tester, viewSize: Size(entry.value, 800));

        await pickDevPreview(tester, 'Loading');
        expect(tester.takeException(), isNull);

        await pickDevPreview(tester, 'Error');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
        'phone hẹp (320) + cỡ chữ 200% cùng lúc (trường hợp xấu nhất) '
        '— Empty State và Results đều không lỗi', (tester) async {
      setViewSize(tester, const Size(320, 800));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: await makeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await pickDevPreview(tester, 'Results');
      expect(tester.takeException(), isNull);
    });
  });

  group(
      'Task 7.1.17 — ô tìm kiếm (SearchBar) không vỡ khi gõ chuỗi dài '
      'trên màn hẹp', () {
    testWidgets(
        'phone hẹp (320): gõ chuỗi dài -> co giãn/ellipsis, '
        'không lỗi', (tester) async {
      await openSearchScreen(tester, viewSize: const Size(320, 800));

      await tester.enterText(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.byType(TextField),
        ),
        'một chuỗi từ khoá rất dài để kiểm tra tràn văn bản trên màn hình hẹp',
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Nút xoá vẫn nằm trong bề rộng màn hình (không bị đẩy tràn ra
      // ngoài viewport).
      final clearButton = tester.getRect(
        find.descendant(
          of: find.byType(SearchScreen),
          matching: find.widgetWithIcon(IconButton, Icons.clear),
        ),
      );
      expect(clearButton.right, lessThanOrEqualTo(320));
    });
  });

  group('Task 7.1.17 — ResultCard tự co giãn theo bề rộng, không tràn', () {
    for (final entry in _breakpoints.entries) {
      testWidgets(
          '${entry.key}: ResultCard rộng vừa khít viewport, '
          'không tràn', (tester) async {
        setViewSize(tester, Size(entry.value, 800));

        await tester.pumpWidget(
          localizedTestApp(ResultCard.fromAyah(sampleAyah)),
        );
        await tester.pumpAndSettle();

        final rect = tester.getRect(find.byType(ResultCard));
        expect(rect.right, lessThanOrEqualTo(entry.value));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
