import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/smart_learning/presentation/widgets/smart_learning_header.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('SmartLearningHeader (Sprint 17 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị đủ tiêu đề và phụ đề', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const SmartLearningHeader(
            title: 'Your smart session',
            subtitle: '3 recommendations today',
          ),
        ),
      );

      expect(find.text('Your smart session'), findsOneWidget);
      expect(find.text('3 recommendations today'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const SmartLearningHeader(
            title: 'Your smart session',
            subtitle: '3 recommendations today',
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel('Your smart session. 3 recommendations today'),
        findsOneWidget,
      );
    });
  });
}
