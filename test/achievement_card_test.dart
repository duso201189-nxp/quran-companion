import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/analytics/presentation/widgets/achievement_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('AchievementCard (Sprint 14 Phase 2.2 mục 4) — thuần trình bày', () {
    testWidgets('khoá -> hiện icon ổ khoá, không hiện dấu tick',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const AchievementCard(
            icon: Icons.auto_awesome_rounded,
            title: 'First study',
            progressText: '0 / 1 cards',
            progress: 0.0,
            isUnlocked: false,
          ),
        ),
      );

      expect(find.text('First study'), findsOneWidget);
      expect(find.text('0 / 1 cards'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('mở khoá -> hiện dấu tick, không hiện icon ổ khoá',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const AchievementCard(
            icon: Icons.auto_awesome_rounded,
            title: 'First study',
            progressText: '1 / 1 cards',
            progress: 1.0,
            isUnlocked: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets(
        'gộp thành MỘT nhãn accessibility, đúng trạng thái Locked/Unlocked',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const AchievementCard(
            icon: Icons.auto_awesome_rounded,
            title: 'First study',
            progressText: '0 / 1 cards',
            progress: 0.0,
            isUnlocked: false,
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel('First study: Locked, 0 / 1 cards'),
        findsOneWidget,
      );
    });

    testWidgets('không lỗi khi xếp nhiều thẻ trong Wrap', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const Wrap(
            children: [
              AchievementCard(
                icon: Icons.auto_awesome_rounded,
                title: 'First study',
                progressText: '1 / 1 cards',
                progress: 1.0,
                isUnlocked: true,
              ),
              AchievementCard(
                icon: Icons.style_rounded,
                title: '10 cards studied',
                progressText: '3 / 10 cards',
                progress: 0.3,
                isUnlocked: false,
              ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
