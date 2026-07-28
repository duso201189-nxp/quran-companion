import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/learning_journey/presentation/widgets/journey_step_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('JourneyStepCard (Sprint 16 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets(
        'hiển thị số bước + toàn bộ nội dung gợi ý (bọc '
        'TutorSuggestionCard)', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyStepCard(
            stepNumber: 1,
            icon: Icons.today_rounded,
            title: 'Review your due cards',
            detail: '5 cards waiting',
            priorityLabel: 'High priority',
            isUrgent: true,
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Review your due cards'), findsOneWidget);
      expect(find.text('5 cards waiting'), findsOneWidget);
      expect(find.text('High priority'), findsOneWidget);
    });

    testWidgets('huy hiệu số bước có nhãn accessibility "Step N"',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyStepCard(
            stepNumber: 2,
            icon: Icons.today_rounded,
            title: 'Review your due cards',
            detail: '5 cards waiting',
            priorityLabel: 'High priority',
            isUrgent: true,
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.bySemanticsLabel('Step 2'), findsOneWidget);
    });

    testWidgets(
        'có actionLabel/onAction -> nút hành động vẫn hoạt động '
        'đúng (tái sử dụng TutorSuggestionCard)', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        localizedTestApp(
          JourneyStepCard(
            stepNumber: 1,
            icon: Icons.today_rounded,
            title: 'Review your due cards',
            detail: '5 cards waiting',
            priorityLabel: 'High priority',
            isUrgent: true,
            actionLabel: 'Review now',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Review now'));
      expect(tapped, isTrue);
    });

    testWidgets('không có action -> không hiện nút hành động nào',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyStepCard(
            stepNumber: 3,
            icon: Icons.local_fire_department_rounded,
            title: 'Keep your streak alive',
            detail: '3-day streak',
            priorityLabel: 'Low priority',
            isUrgent: false,
          ),
        ),
      );

      expect(find.byType(TextButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
