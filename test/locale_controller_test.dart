import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/app/locale/locale_controller.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint 5.1 (Finding 1) — LocaleController lúc chưa từng chọn ngôn
/// ngữ phải thử ngôn ngữ thiết bị trước khi rơi về tiếng Việt, và
/// KHÔNG BAO GIỜ ghi đè một lựa chọn người dùng đã có.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer({
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sp = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
    );
    addTearDown(container.dispose);
    return container;
  }

  tearDown(binding.platformDispatcher.clearLocaleTestValue);

  test(
      'chưa từng chọn + thiết bị dùng ngôn ngữ được hỗ trợ -> dùng '
      'ngôn ngữ thiết bị', () async {
    binding.platformDispatcher.localeTestValue = const Locale('en');
    final container = await makeContainer();

    expect(container.read(localeControllerProvider), const Locale('en'));
  });

  test(
      'chưa từng chọn + thiết bị dùng ngôn ngữ KHÔNG được hỗ trợ (vd '
      'tiếng Pháp) -> về tiếng Việt', () async {
    binding.platformDispatcher.localeTestValue = const Locale('fr');
    final container = await makeContainer();

    expect(container.read(localeControllerProvider), const Locale('vi'));
  });

  test(
      'đã từng chọn -> giữ nguyên lựa chọn đó, KHÔNG đọc ngôn ngữ '
      'thiết bị dù thiết bị dùng ngôn ngữ khác', () async {
    // Thiết bị "nói" tiếng Anh, nhưng người dùng đã chọn tiếng Ả Rập.
    binding.platformDispatcher.localeTestValue = const Locale('en');
    final container = await makeContainer(
      prefs: {LocaleController.prefsKey: 'ar'},
    );

    expect(container.read(localeControllerProvider), const Locale('ar'));
  });

  test(
      'giá trị đã lưu không hợp lệ (ngoài supportedCodes) -> vẫn thử '
      'ngôn ngữ thiết bị trước khi về tiếng Việt', () async {
    binding.platformDispatcher.localeTestValue = const Locale('ar');
    final container = await makeContainer(
      prefs: {LocaleController.prefsKey: 'fr'},
    );

    expect(container.read(localeControllerProvider), const Locale('ar'));
  });

  test('setLanguage vẫn lưu bền và có hiệu lực ngay (hành vi cũ không đổi)',
      () async {
    final container = await makeContainer();

    await container.read(localeControllerProvider.notifier).setLanguage('ar');

    expect(container.read(localeControllerProvider), const Locale('ar'));
  });
}
