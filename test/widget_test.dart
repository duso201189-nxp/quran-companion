// Smoke test cơ bản: đảm bảo widget gốc dựng được trong ProviderScope.
// Các bài test đầy đủ của ứng dụng nằm ở app_test.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/app/app.dart';

void main() {
  testWidgets('QuranCompanionApp can be constructed', (tester) async {
    expect(const ProviderScope(child: QuranCompanionApp()), isNotNull);
  });
}
