import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/search/presentation/widgets/search_no_results_state.dart';

import 'fixtures/search_test_harness.dart';

void main() {
  group('Sprint R1.2 — SearchNoResultsState (độc lập, không provider)', () {
    // localizedTestApp KHÔNG bọc ProviderScope — widget này không phụ
    // thuộc Riverpod, giống SearchErrorState/SearchEmptyState.
    testWidgets('hiện đúng icon search_off + từ khoá trong thông điệp',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const SearchNoResultsState(query: 'xyz')),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Không tìm thấy kết quả cho "xyz"'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'đổi query khác -> thông điệp đổi theo, không phải chuỗi cố định',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(const SearchNoResultsState(query: 'الرحمن')),
      );

      expect(find.text('Không tìm thấy kết quả cho "الرحمن"'), findsOneWidget);
      expect(find.text('Không tìm thấy kết quả cho "xyz"'), findsNothing);
    });

    testWidgets(
        'khác biệt trực quan với SearchErrorState: không phải icon '
        'cloud_off_outlined, không có nút Thử lại', (tester) async {
      await tester
          .pumpWidget(localizedTestApp(const SearchNoResultsState(query: 'a')));

      expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('thông điệp + gợi ý là live region cho trình đọc màn hình',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        localizedTestApp(const SearchNoResultsState(query: 'xyz')),
      );

      expect(
        find.bySemanticsLabel(
          'Không tìm thấy kết quả cho "xyz". '
          'Thử một từ khoá khác hoặc kiểm tra chính tả.',
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
