import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_error_state.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('Task 7.1.11 — SearchErrorState (độc lập, không provider)', () {
    // localizedTestApp KHÔNG bọc ProviderScope — chứng minh trực tiếp
    // yêu cầu "độc lập với logic tìm kiếm thật / không nối provider":
    // nếu widget lỡ cần Riverpod, mọi test dưới đây sẽ crash ngay khi
    // build.
    testWidgets('mặc định: icon + thông điệp có sẵn, KHÔNG có nút Thử lại',
        (tester) async {
      await tester.pumpWidget(localizedTestApp(const SearchErrorState()));

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(
        find.text('Không tải được dữ liệu. Vui lòng thử lại.'),
        findsOneWidget,
      );
      expect(find.byType(FilledButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('message và icon tuỳ biến được', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const SearchErrorState(
            message: 'Không tìm được kết nối.',
            icon: Icons.wifi_off_outlined,
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      expect(find.text('Không tìm được kết nối.'), findsOneWidget);
      expect(
        find.text('Không tải được dữ liệu. Vui lòng thử lại.'),
        findsNothing,
      );
    });

    testWidgets('có onRetry -> hiện nút Thử lại, bấm gọi callback',
        (tester) async {
      var retried = false;
      await tester.pumpWidget(
        localizedTestApp(SearchErrorState(onRetry: () => retried = true)),
      );

      expect(find.text('Thử lại'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(retried, isTrue);
    });

    testWidgets(
        'thông điệp lỗi có nhãn live-region riêng, nút Thử lại không bị gộp '
        'chung', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedTestApp(SearchErrorState(onRetry: () {})),
      );

      expect(
        find.bySemanticsLabel('Không tải được dữ liệu. Vui lòng thử lại.'),
        findsOneWidget,
      );
      // Nút vẫn giữ ngữ nghĩa "button" riêng — không bị nuốt vào live
      // region báo lỗi ở trên.
      expect(find.bySemanticsLabel('Thử lại'), findsOneWidget);
      handle.dispose();
    });
  });
}
