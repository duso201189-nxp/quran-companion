import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/shared/widgets/full_empty_state.dart';

import 'fixtures/search_test_harness.dart';

/// Sprint 27.0 — [FullEmptyState] gộp hai bản `_EmptyState` giống hệt
/// nhau (Thư viện của tôi + danh sách Surah). Test khoá lại hình dạng
/// hiển thị VÀ mức ngữ nghĩa, vì widget dùng chung không được phép tụt
/// xuống mức thấp hơn bản gốc nào (repository_engineering_standard.md).
void main() {
  group('FullEmptyState (Sprint 27.0)', () {
    testWidgets('hiển thị icon + thông điệp', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const FullEmptyState(
            icon: Icons.bookmark_border_rounded,
            message: 'Chưa có Ayah nào được lưu.',
          ),
        ),
      );

      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
      expect(find.text('Chưa có Ayah nào được lưu.'), findsOneWidget);
    });

    testWidgets('giữ nguyên công thức hình ảnh của hai bản gốc (icon 56)',
        (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const FullEmptyState(
            icon: Icons.search_off_outlined,
            message: 'Không tìm thấy Surah nào phù hợp.',
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 56);
    });

    testWidgets(
        'gộp MỘT nhãn accessibility + liveRegion (tự thông báo khi '
        'danh sách chuyển sang trống)', (tester) async {
      await tester.pumpWidget(
        localizedTestApp(
          const FullEmptyState(
            icon: Icons.note_outlined,
            message: 'Chưa có ghi chú nào.',
          ),
        ),
      );

      final label = find.bySemanticsLabel('Chưa có ghi chú nào.');
      expect(label, findsOneWidget);
      expect(tester.getSemantics(label).flagsCollection.isLiveRegion, isTrue);
    });
  });
}
