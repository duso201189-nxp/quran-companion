import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';

import 'fixtures/app_harness.dart';

/// Sprint 5.1 (Finding 2) — nhãn thẻ "Đọc tiếp" trên Trang chủ phải
/// phản ánh ĐÚNG việc đã từng đọc hay chưa, không phải việc có Surah
/// gợi ý để hiển thị (hai thứ khác nhau — `lastSurah` luôn có giá trị
/// nhờ fallback gợi ý Al-Fatihah, `lastAyahIndex` mới là tín hiệu thật
/// của "đã từng đọc"). Xem doc comment tại chỗ sửa trong
/// home_screen.dart.
void main() {
  testWidgets(
      'máy mới cài (chưa đọc gì) -> hiện "Bắt đầu đọc", KHÔNG phải '
      '"Đọc tiếp"', (tester) async {
    await tester.pumpWidget(await makeApp());
    await tester.pumpAndSettle();

    expect(find.text('Bắt đầu đọc'), findsOneWidget);
    expect(find.text('Đọc tiếp'), findsNothing);
  });

  testWidgets('đã có lịch sử đọc -> hiện "Đọc tiếp", KHÔNG phải "Bắt đầu đọc"',
      (tester) async {
    await tester.pumpWidget(
      await makeApp(
        prefs: {
          ReadingPositionStore.kLastSurah: 1,
          ReadingPositionStore.posKey(1): 0,
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Đọc tiếp'), findsOneWidget);
    expect(find.text('Bắt đầu đọc'), findsNothing);
  });
}
