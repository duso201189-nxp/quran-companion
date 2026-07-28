import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/learning_journey/presentation/widgets/journey_progress_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('JourneyProgressCard (Sprint 16 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị tiêu đề và toàn bộ chip số liệu', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyProgressCard(
            title: 'Your progress',
            stats: [
              (
                icon: Icons.track_changes_rounded,
                value: '80%',
                label: 'Accuracy'
              ),
              (
                icon: Icons.local_fire_department_rounded,
                value: '5 days',
                label: 'Current streak',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Your progress'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('Current streak'), findsOneWidget);
    });

    testWidgets('mỗi chip gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyProgressCard(
            title: 'Your progress',
            stats: [
              (
                icon: Icons.track_changes_rounded,
                value: '80%',
                label: 'Accuracy'
              ),
            ],
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.bySemanticsLabel('Accuracy: 80%'), findsOneWidget);
    });

    testWidgets('danh sách stats rỗng -> không lỗi', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const JourneyProgressCard(title: 'Your progress', stats: []),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
