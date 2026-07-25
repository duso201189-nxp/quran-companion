import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/presentation/reading/focus_transition.dart';

/// Sprint 25.3 — nền tảng chuyển cảnh Focus Mode. Test ở mức đơn vị:
/// không cần ReadingScreen/database, chỉ cần một MediaQuery.
void main() {
  group('focusTransitionDuration (Sprint 25.3)', () {
    Future<Duration> readDuration(
      WidgetTester tester, {
      required bool disableAnimations,
    }) async {
      late Duration result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Builder(
            builder: (context) {
              result = focusTransitionDuration(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('mặc định dùng đúng thời lượng chung', (tester) async {
      expect(
        await readDuration(tester, disableAnimations: false),
        kFocusTransitionDuration,
      );
    });

    testWidgets('bật "giảm chuyển động" -> chuyển cảnh tức thì',
        (tester) async {
      expect(
        await readDuration(tester, disableAnimations: true),
        Duration.zero,
      );
    });
  });

  group('FocusCollapse (Sprint 25.3)', () {
    Widget host({required bool visible}) => MaterialApp(
          home: Scaffold(
            body: FocusCollapse(
              visible: visible,
              child: const Text('vỏ'),
            ),
          ),
        );

    testWidgets('ẩn dần rồi mới THÁO child khỏi cây widget', (tester) async {
      await tester.pumpWidget(host(visible: true));
      expect(find.text('vỏ'), findsOneWidget);

      await tester.pumpWidget(host(visible: false));
      await tester.pump(const Duration(milliseconds: 80));
      // Đang thu gọn -> vẫn còn trong cây để nhìn thấy chuyển động,
      // KHÔNG biến mất đột ngột ngay khung hình đầu.
      expect(find.text('vỏ'), findsOneWidget);

      await tester.pumpAndSettle();
      // Thu xong -> tháo hẳn: không còn build, không còn nghe provider.
      expect(find.text('vỏ'), findsNothing);
    });

    testWidgets('hiện trở lại -> child quay vào cây ngay', (tester) async {
      await tester.pumpWidget(host(visible: false));
      await tester.pumpAndSettle();
      expect(find.text('vỏ'), findsNothing);

      await tester.pumpWidget(host(visible: true));
      await tester.pump();
      expect(find.text('vỏ'), findsOneWidget);
    });
  });
}
