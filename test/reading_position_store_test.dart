import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';

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
  test('chưa đọc gì -> null', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final store = c.read(readingPositionStoreProvider);

    expect(store.lastSurahId, isNull);
    expect(store.positionFor(2), isNull);
  });

  test('save lưu cả Surah cuối lẫn vị trí theo Surah', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final store = c.read(readingPositionStoreProvider);

    await store.save(surahId: 2, ayahIndex: 44);

    expect(store.lastSurahId, 2);
    expect(store.positionFor(2), 44);
  });

  test('vị trí từng Surah độc lập nhau', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final store = c.read(readingPositionStoreProvider);

    await store.save(surahId: 2, ayahIndex: 44);
    await store.save(surahId: 114, ayahIndex: 3);

    expect(store.positionFor(2), 44);
    expect(store.positionFor(114), 3);
    expect(store.lastSurahId, 114); // Surah đọc gần nhất
  });
}
