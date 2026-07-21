import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/analytics/presentation/widgets/goal_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('GoalCard (Sprint 14 Phase 2.2 mục 4) — thuần trình bày', () {
    testWidgets('hiển thị nhãn, chuỗi tiến độ, không có dấu tick khi chưa đạt',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const GoalCard(
            icon: Icons.menu_book_rounded,
            label: 'Daily study',
            progressText: '5 / 15 min today',
            progress: 5 / 15,
            isAchieved: false,
          ),
        ),
      );

      expect(find.text('Daily study'), findsOneWidget);
      expect(find.text('5 / 15 min today'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('isAchieved=true -> hiện dấu tick', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const GoalCard(
            icon: Icons.menu_book_rounded,
            label: 'Daily study',
            progressText: '15 / 15 min today',
            progress: 1.0,
            isAchieved: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility, có nhắc "Achieved" khi đạt',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const GoalCard(
            icon: Icons.menu_book_rounded,
            label: 'Daily study',
            progressText: '15 / 15 min today',
            progress: 1.0,
            isAchieved: true,
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel('Daily study: 15 / 15 min today. Achieved'),
        findsOneWidget,
      );
    });

    testWidgets('không lỗi khi progress = 0', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const GoalCard(
            icon: Icons.style_rounded,
            label: 'Daily reviews',
            progressText: '0 / 10 reviews today',
            progress: 0.0,
            isAchieved: false,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
