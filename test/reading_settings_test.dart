import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_settings.dart';

Future<ProviderContainer> _container({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
  );
}

void main() {
  test('mặc định: scale 1.0, translit + Việt bật, Anh tắt', () async {
    final c = await _container();
    addTearDown(c.dispose);

    final s = c.read(readingSettingsProvider);
    expect(s.arabicScale, 1.0);
    expect(s.arabicFontSize, 28);
    expect(s.showTransliteration, isTrue);
    expect(s.showVietnamese, isTrue);
    expect(s.showEnglish, isFalse);
  });

  test('setArabicScale lưu bền và clamp trong khoảng cho phép',
      () async {
    final c = await _container();
    addTearDown(c.dispose);

    final controller = c.read(readingSettingsProvider.notifier);
    await controller.setArabicScale(5.0); // vượt max
    expect(
      c.read(readingSettingsProvider).arabicScale,
      ReadingSettings.maxScale,
    );

    await controller.setArabicScale(1.2);
    expect(c.read(readingSettingsProvider).arabicScale, 1.2);
    expect(
      c.read(sharedPreferencesProvider).getDouble('reading.arabic_scale'),
      1.2,
    );
  });

  test('giá trị lưu hỏng (scale 99) -> clamp khi khởi tạo', () async {
    final c = await _container(prefs: {'reading.arabic_scale': 99.0});
    addTearDown(c.dispose);

    expect(
      c.read(readingSettingsProvider).arabicScale,
      ReadingSettings.maxScale,
    );
  });

  test('chế độ đọc (list/mushaf) lưu bền và khôi phục', () async {
    final c = await _container();
    addTearDown(c.dispose);

    expect(c.read(readingSettingsProvider).mode, ReadingMode.list);

    await c
        .read(readingSettingsProvider.notifier)
        .setMode(ReadingMode.mushaf);

    expect(c.read(readingSettingsProvider).mode, ReadingMode.mushaf);
    expect(
      c.read(sharedPreferencesProvider).getString('reading.mode'),
      'mushaf',
    );

    // container mới (mô phỏng mở lại app) đọc đúng giá trị đã lưu
    final c2 = await _container(prefs: {'reading.mode': 'mushaf'});
    addTearDown(c2.dispose);
    expect(c2.read(readingSettingsProvider).mode, ReadingMode.mushaf);
  });

  test('pinch: preview chỉ đổi state, commit mới ghi đĩa', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final controller = c.read(readingSettingsProvider.notifier);

    controller.previewArabicScale(1.4);
    expect(c.read(readingSettingsProvider).arabicScale, 1.4);
    expect(
      c.read(sharedPreferencesProvider).getDouble('reading.arabic_scale'),
      isNull, // chưa ghi
    );

    await controller.commitArabicScale();
    expect(
      c.read(sharedPreferencesProvider).getDouble('reading.arabic_scale'),
      1.4,
    );
  });

  test('preview clamp trong khoảng cho phép', () async {
    final c = await _container();
    addTearDown(c.dispose);

    c.read(readingSettingsProvider.notifier).previewArabicScale(99);
    expect(
      c.read(readingSettingsProvider).arabicScale,
      ReadingSettings.maxScale,
    );
  });

  test('bật/tắt lớp văn bản lưu bền', () async {
    final c = await _container();
    addTearDown(c.dispose);

    final controller = c.read(readingSettingsProvider.notifier);
    await controller.setShowEnglish(true);
    await controller.setShowTransliteration(false);

    final s = c.read(readingSettingsProvider);
    expect(s.showEnglish, isTrue);
    expect(s.showTransliteration, isFalse);
    final prefs = c.read(sharedPreferencesProvider);
    expect(prefs.getBool('reading.show_english'), isTrue);
    expect(prefs.getBool('reading.show_transliteration'), isFalse);
  });
}
