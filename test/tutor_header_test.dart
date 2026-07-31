import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_header.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('TutorHeader (Sprint 15 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị tiêu đề và toàn bộ chip số liệu', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorHeader(
            title: 'Your overview',
            stats: [
              (icon: Icons.style_rounded, value: '12', label: 'Cards studied'),
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

      expect(find.text('Your overview'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('Cards studied'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
      expect(find.text('Current streak'), findsOneWidget);
    });

    testWidgets('mỗi chip gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorHeader(
            title: 'Your overview',
            stats: [
              (icon: Icons.style_rounded, value: '12', label: 'Cards studied'),
            ],
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.bySemanticsLabel('Cards studied: 12'), findsOneWidget);
    });

    testWidgets('danh sách stats rỗng -> không lỗi', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorHeader(title: 'Your overview', stats: []),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
