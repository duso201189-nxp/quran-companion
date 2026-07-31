import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_insight_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('TutorInsightCard (Sprint 15 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị icon, giá trị, nhãn', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorInsightCard(
            icon: Icons.track_changes_rounded,
            label: 'Accuracy',
            value: '80%',
          ),
        ),
      );

      expect(find.byIcon(Icons.track_changes_rounded), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorInsightCard(
            icon: Icons.track_changes_rounded,
            label: 'Accuracy',
            value: '80%',
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.bySemanticsLabel('Accuracy: 80%'), findsOneWidget);
    });
  });
}
