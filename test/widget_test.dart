// Smoke test: app phải dựng, pump và ổn định KHÔNG lỗi/exception.
// Các bài test hành vi chi tiết (điều hướng, theme, ngôn ngữ) nằm ở
// app_test.dart; file này chỉ trả lời "app có khởi động được không".

import 'package:flutter_test/flutter_test.dart';

import 'fixtures/app_harness.dart';

void main() {
  testWidgets('QuranCompanionApp khởi động không lỗi, vào thẳng Trang chủ',
      (tester) async {
    await tester.pumpWidget(await makeApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Trang chủ'), findsWidgets);
  });
}
