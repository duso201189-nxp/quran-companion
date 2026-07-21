import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/smart_learning/presentation/widgets/recommendation_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('RecommendationCard (Sprint 17 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị chiến lược, thời lượng, số bước', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const RecommendationCard(
            icon: Icons.menu_book_rounded,
            strategyLabel: 'Deep study',
            estimatedTimeLabel: '20 min',
            relatedStepsLabel: '1 related steps',
          ),
        ),
      );

      expect(find.text('Deep study'), findsOneWidget);
      expect(find.text('20 min · 1 related steps'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const RecommendationCard(
            icon: Icons.menu_book_rounded,
            strategyLabel: 'Deep study',
            estimatedTimeLabel: '20 min',
            relatedStepsLabel: '1 related steps',
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel('Deep study. 20 min. 1 related steps'),
        findsOneWidget,
      );
    });
  });
}
