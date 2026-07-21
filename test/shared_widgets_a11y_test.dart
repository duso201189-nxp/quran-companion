import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/shared/widgets/empty_state_banner.dart';
import 'package:quran_companion/shared/widgets/section_header.dart';
import 'package:quran_companion/shared/widgets/stat_card.dart';

import 'fixtures/search_test_harness.dart';

/// Sprint 20 Phase 2 — kiểm chứng accessibility của các widget dùng
/// chung MỚI/ĐƯỢC SỬA (xem accessibility_audit.md mục 8): SectionHeader
/// (Task 2+4), StatCard (Task 3), EmptyStateBanner (Task 1).
void main() {
  group('SectionHeader (Sprint 20 Phase 2, Task 2+4)', () {
    testWidgets('hiển thị đúng văn bản', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const SectionHeader(text: 'Tổng quan')),
      );

      expect(find.text('Tổng quan'), findsOneWidget);
    });

    testWidgets('có Semantics(header: true) — điều hướng theo heading',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const SectionHeader(text: 'Tổng quan')),
      );

      final semantics = tester.getSemantics(find.text('Tổng quan'));
      expect(
        semantics.flagsCollection.isHeader,
        isTrue,
      );
    });
  });

  group('StatCard (Sprint 20 Phase 2, Task 3)', () {
    testWidgets('hiển thị icon, giá trị, nhãn', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const StatCard(
            icon: Icons.style_rounded,
            value: '42',
            label: 'Cards studied',
          ),
        ),
      );

      expect(find.byIcon(Icons.style_rounded), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('Cards studied'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const StatCard(
            icon: Icons.style_rounded,
            value: '42',
            label: 'Cards studied',
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.bySemanticsLabel('Cards studied: 42'), findsOneWidget);
    });

    testWidgets('accented:true/false đều dựng được, không ném lỗi',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const Column(
            children: [
              StatCard(
                icon: Icons.style_rounded,
                value: '1',
                label: 'A',
              ),
              StatCard(
                icon: Icons.style_rounded,
                value: '2',
                label: 'B',
                accented: true,
              ),
            ],
          ),
        ),
      );

      expect(find.byType(StatCard), findsNWidgets(2));
    });
  });

  group('EmptyStateBanner (Sprint 20 Phase 2, Task 1)', () {
    testWidgets('hiển thị đúng văn bản', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const EmptyStateBanner(text: 'Chưa có gì ở đây')),
      );

      expect(find.text('Chưa có gì ở đây'), findsOneWidget);
    });

    testWidgets(
        'gộp thành MỘT nhãn accessibility + liveRegion (trước Phase 2 '
        'KHÔNG có — xem accessibility_audit.md mục 2.2/8.1)', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const EmptyStateBanner(text: 'Chưa có gì ở đây')),
      );

      final semantics =
          tester.getSemantics(find.text('Chưa có gì ở đây').hitTestable());
      expect(semantics.label, 'Chưa có gì ở đây');
      expect(
        semantics.flagsCollection.isLiveRegion,
        isTrue,
      );
    });
  });
}
