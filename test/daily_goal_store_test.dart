import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/stats/data/daily_goal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint S2, D9 — cùng mẫu test/reading_position_store_test.dart
/// (Notifier tự đọc lại lúc build(), tự lưu bền mỗi lần đổi), trước
/// đó chưa có test nào cho DailyGoalStore dù ReadingPositionStore
/// (cùng kiến trúc) đã có.
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
  test('chưa đặt chỉ tiêu nào -> cả 2 trường null', () async {
    final c = await _container();
    addTearDown(c.dispose);

    final target = c.read(dailyGoalStoreProvider);

    expect(target.minutesPerDay, isNull);
    expect(target.ayahsPerDay, isNull);
  });

  test('setTarget lưu đúng cả 2 chỉ tiêu, đọc lại từ prefs khớp state',
      () async {
    final c = await _container();
    addTearDown(c.dispose);
    final notifier = c.read(dailyGoalStoreProvider.notifier);

    await notifier.setTarget(minutesPerDay: 15, ayahsPerDay: 10);

    final target = c.read(dailyGoalStoreProvider);
    expect(target.minutesPerDay, 15);
    expect(target.ayahsPerDay, 10);
  });

  test('setTarget với null ở 1 trường -> bỏ NGƯỠNG đó (khác 0)', () async {
    final c = await _container();
    addTearDown(c.dispose);
    final notifier = c.read(dailyGoalStoreProvider.notifier);

    await notifier.setTarget(minutesPerDay: 15, ayahsPerDay: 10);
    await notifier.setTarget(minutesPerDay: null, ayahsPerDay: 10);

    final target = c.read(dailyGoalStoreProvider);
    expect(target.minutesPerDay, isNull);
    expect(target.ayahsPerDay, 10);
  });

  test(
      'chỉ tiêu đã lưu khôi phục đúng khi build() lại (container mới, '
      'cùng prefs)', () async {
    final c1 = await _container();
    await c1.read(dailyGoalStoreProvider.notifier).setTarget(
          minutesPerDay: 20,
          ayahsPerDay: 5,
        );
    c1.dispose();

    // Container thứ 2 mô phỏng app khởi động lại — đọc lại
    // SharedPreferences.getInstance() (cùng mock data, chưa reset).
    final sp = await SharedPreferences.getInstance();
    final c2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
    );
    addTearDown(c2.dispose);

    final target = c2.read(dailyGoalStoreProvider);
    expect(target.minutesPerDay, 20);
    expect(target.ayahsPerDay, 5);
  });
}
