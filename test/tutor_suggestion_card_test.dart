import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_suggestion_card.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('TutorSuggestionCard (Sprint 15 Phase 2 mục 3) — thuần trình bày', () {
    testWidgets('hiển thị tiêu đề, chi tiết, nhãn ưu tiên', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorSuggestionCard(
            icon: Icons.today_rounded,
            title: 'Review your due cards',
            detail: '5 cards waiting',
            priorityLabel: 'High priority',
            isUrgent: true,
          ),
        ),
      );

      expect(find.text('Review your due cards'), findsOneWidget);
      expect(find.text('5 cards waiting'), findsOneWidget);
      expect(find.text('High priority'), findsOneWidget);
    });

    testWidgets('gộp thành MỘT nhãn accessibility', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorSuggestionCard(
            icon: Icons.today_rounded,
            title: 'Review your due cards',
            detail: '5 cards waiting',
            priorityLabel: 'High priority',
            isUrgent: true,
          ),
          locale: const Locale('en'),
        ),
      );

      expect(
        find.bySemanticsLabel(
          'Review your due cards. 5 cards waiting. High priority',
        ),
        findsOneWidget,
      );
    });

    testWidgets('isUrgent=false vẫn hiển thị đúng, không lỗi', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const TutorSuggestionCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Keep your streak alive',
            detail: '3-day streak',
            priorityLabel: 'Low priority',
            isUrgent: false,
          ),
        ),
      );

      expect(find.text('Keep your streak alive'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    group('Hành động điều hướng (Sprint 15 Phase 3 mục 1)', () {
      testWidgets(
          'actionLabel + onAction đều có -> hiện nút hành động, bấm gọi '
          'đúng callback', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          localizedTestApp(
            TutorSuggestionCard(
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

        expect(find.text('Review now'), findsOneWidget);
        await tester.tap(find.text('Review now'));
        expect(tapped, isTrue);
      });

      testWidgets(
          'onAction/actionLabel null -> KHÔNG hiện nút hành động nào '
          '("trạng thái vô hiệu" = vắng mặt, không phải nút mờ)',
          (tester) async {
        await tester.pumpWidget(
          localizedTestApp(
            const TutorSuggestionCard(
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

      testWidgets(
          'nút hành động có nhãn accessibility ĐỘC LẬP với nhãn thông '
          'tin (không bị ExcludeSemantics nuốt mất, khác Phase 2)',
          (tester) async {
        await tester.pumpWidget(
          localizedTestApp(
            TutorSuggestionCard(
              icon: Icons.today_rounded,
              title: 'Review your due cards',
              detail: '5 cards waiting',
              priorityLabel: 'High priority',
              isUrgent: true,
              actionLabel: 'Review now',
              onAction: () {},
            ),
            locale: const Locale('en'),
          ),
        );

        // Nhãn thông tin gộp KHÔNG đổi (đúng yêu cầu "accessibility
        // unchanged" cho phần thông tin) — cùng chuỗi Phase 2.
        expect(
          find.bySemanticsLabel(
            'Review your due cards. 5 cards waiting. High priority',
          ),
          findsOneWidget,
        );
        // Nút hành động là 1 node semantics TÁCH BIỆT, tự công bố tên
        // "Review now" (Flutter tự gắn semantics cho TextButton) —
        // KHÔNG bị gộp/nuốt vào nhãn thông tin ở trên (2 node riêng
        // biệt cùng tồn tại).
        expect(find.bySemanticsLabel('Review now'), findsOneWidget);
      });
    });
  });
}
