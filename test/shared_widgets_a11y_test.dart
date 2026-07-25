import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/shared/widgets/cross_feature_entry_card.dart';
import 'package:quran_companion/shared/widgets/empty_state_banner.dart';
import 'package:quran_companion/shared/widgets/feature_hero_card.dart';
import 'package:quran_companion/shared/widgets/grade_button.dart';
import 'package:quran_companion/shared/widgets/section_header.dart';
import 'package:quran_companion/shared/widgets/stat_card.dart';

import 'fixtures/search_test_harness.dart';

/// Sprint 20 Phase 2 — kiểm chứng accessibility của các widget dùng
/// chung MỚI/ĐƯỢC SỬA (xem accessibility_audit.md mục 8): SectionHeader
/// (Task 2+4), StatCard (Task 3), EmptyStateBanner (Task 1).
///
/// Sprint 21.4 Phase A, mục A1 — thêm FeatureHeroCard (khung "thẻ
/// hero" dùng chung, xem design_system_consolidation_plan.md mục A1).
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

  group('FeatureHeroCard (Sprint 21.4 Phase A, mục A1)', () {
    testWidgets('render đúng child, giữ nguyên decoration', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const FeatureHeroCard(child: Text('Hero content')),
        ),
      );

      expect(find.text('Hero content'), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Hero content'),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(container.padding, const EdgeInsets.all(20));
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });
  });

  group('CrossFeatureEntryCard (Sprint 21.4 Phase A, mục A2)', () {
    testWidgets('render đúng child và gọi onTap khi bấm', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        localizedTestApp(
          CrossFeatureEntryCard(
            onTap: () => tapped = true,
            child: const Text('Go to Journey'),
          ),
        ),
      );

      expect(find.text('Go to Journey'), findsOneWidget);

      await tester.tap(find.text('Go to Journey'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('GradeButton (Sprint 21.4 Phase A, mục A4)', () {
    testWidgets('hiển thị đúng nhãn và gọi onPressed khi bấm', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        localizedTestApp(
          Material(
            child: GradeButton(
              label: 'Good',
              color: Colors.blue,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Good'), findsOneWidget);

      await tester.tap(find.text('Good'));
      await tester.pump();
      expect(pressed, isTrue);
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
