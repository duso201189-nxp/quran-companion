import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/learning_journey/presentation/widgets/journey_header.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('JourneyHeader (Sprint 16 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị đủ tiêu đề, ngày, số bước', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyHeader(
            title: "Today's plan",
            dateLabel: 'July 21, 2026',
            stepCountLabel: '3 steps planned',
          ),
        ),
      );

      expect(find.text("Today's plan"), findsOneWidget);
      expect(find.text('July 21, 2026'), findsOneWidget);
      expect(find.text('3 steps planned'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyHeader(
            title: "Today's plan",
            dateLabel: 'July 21, 2026',
            stepCountLabel: '3 steps planned',
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel(
          "Today's plan. July 21, 2026. 3 steps planned",
        ),
        findsOneWidget,
      );
    });

    testWidgets('stepCountLabel "0" vẫn hiển thị đúng, không lỗi',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyHeader(
            title: "Today's plan",
            dateLabel: 'July 21, 2026',
            stepCountLabel: '0 steps planned',
          ),
        ),
      );

      expect(find.text('0 steps planned'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
