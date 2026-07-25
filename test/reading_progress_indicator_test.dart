import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_progress_indicator.dart';

import 'fixtures/search_test_harness.dart';

/// Sprint 25.2 — dải tiến độ đọc. Test ở mức widget độc lập: chỉ cần
/// một ValueNotifier, không cần ReadingScreen/database — đúng bản chất
/// "thuần trình bày, nhận vị trí từ nơi gọi" của widget này.
void main() {
  group('ReadingProgressIndicator (Sprint 25.2)', () {
    testWidgets('chỉ số 0-based -> hiển thị vị trí 1-based + phần trăm',
        (tester) async {
      final index = ValueNotifier<int>(0);
      addTearDown(index.dispose);

      await tester.pumpWidget(
        localizedTestApp(
          ReadingProgressIndicator(currentAyahIndex: index, totalAyahs: 12),
        ),
      );

      expect(find.text('Ayah 1 / 12'), findsOneWidget);
      expect(find.text('8%'), findsOneWidget); // 1/12 ≈ 8,33%
    });

    testWidgets('đổi vị trí -> cập nhật cả số thứ tự lẫn phần trăm',
        (tester) async {
      final index = ValueNotifier<int>(0);
      addTearDown(index.dispose);

      await tester.pumpWidget(
        localizedTestApp(
          ReadingProgressIndicator(currentAyahIndex: index, totalAyahs: 12),
        ),
      );

      index.value = 5;
      await tester.pumpAndSettle();

      expect(find.text('Ayah 6 / 12'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets(
        'gộp MỘT nhãn accessibility, KHÔNG liveRegion (không tự đọc lên '
        'mỗi lần cuộn)', (tester) async {
      final index = ValueNotifier<int>(0);
      addTearDown(index.dispose);

      await tester.pumpWidget(
        localizedTestApp(
          ReadingProgressIndicator(currentAyahIndex: index, totalAyahs: 12),
        ),
      );

      final label = find.bySemanticsLabel('Ayah 1 trên 12, 8%');
      expect(label, findsOneWidget);
      expect(tester.getSemantics(label).flagsCollection.isLiveRegion, isFalse);
    });

    testWidgets('chỉ số vượt quá tổng -> kẹp lại, không vượt 100%',
        (tester) async {
      final index = ValueNotifier<int>(99);
      addTearDown(index.dispose);

      await tester.pumpWidget(
        localizedTestApp(
          ReadingProgressIndicator(currentAyahIndex: index, totalAyahs: 12),
        ),
      );

      expect(find.text('Ayah 12 / 12'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
