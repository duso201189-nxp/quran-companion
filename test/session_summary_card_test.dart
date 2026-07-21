import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/smart_learning/presentation/widgets/session_summary_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('SessionSummaryCard (Sprint 17 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị đủ tiêu đề, chiến lược, thời lượng, số bước',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const SessionSummaryCard(
            title: 'Recommended session',
            icon: Icons.today_rounded,
            strategyLabel: 'Short review',
            estimatedTimeLabel: '10 min',
            relatedStepsLabel: '2 related steps',
          ),
        ),
      );

      expect(find.text('Recommended session'), findsOneWidget);
      expect(find.text('Short review'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('2 related steps'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const SessionSummaryCard(
            title: 'Recommended session',
            icon: Icons.today_rounded,
            strategyLabel: 'Short review',
            estimatedTimeLabel: '10 min',
            relatedStepsLabel: '2 related steps',
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Recommended session: Short review. 10 min. 2 related steps',
        ),
        findsOneWidget,
      );
    });
  });
}
