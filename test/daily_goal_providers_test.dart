import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/stats/data/daily_goal_providers.dart';
import 'package:quran_companion/features/stats/data/daily_goal_store.dart';
import 'package:quran_companion/features/stats/data/study_session_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sprint S2, D9 — dailyGoalProgressProvider trước đó chưa có test
/// nào (chỉ ghép thuần todayStudySummaryProvider + dailyGoalStoreProvider,
/// không tính toán riêng, nhưng phép ghép đó tự nó chưa được xác nhận).
Future<ProviderContainer> _container({
  required Future<TodayStudySummary> Function() summary,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      todayStudySummaryProvider.overrideWith((ref) => summary()),
    ],
  );
}

/// dailyGoalProgressProvider VÀ todayStudySummaryProvider đều
/// `.autoDispose` — không có listener nào giữ sống, `container.read()`
/// lặp lại có thể dựng LẠI từ đầu (gọi [summary] lần nữa, quay về
/// AsyncLoading) thay vì phản ánh future đã resolve. `listen(...)`
/// trước khi await giữ cả chuỗi phụ thuộc sống xuyên suốt, đúng mẫu
/// chuẩn để test provider `.autoDispose` phụ thuộc 1 provider bất
/// đồng bộ khác.
Future<DailyGoalProgress?> _resolvedProgress(ProviderContainer c) async {
  final sub = c.listen(dailyGoalProgressProvider, (_, __) {});
  await c.read(todayStudySummaryProvider.future);
  final progress = c.read(dailyGoalProgressProvider);
  sub.close();
  return progress;
}

void main() {
  test(
      'todayStudySummaryProvider chưa có dữ liệu (loading) -> null (cùng '
      'quy ước khatmProgressProvider)', () async {
    // Completer không bao giờ complete trong phạm vi test -> provider
    // luôn ở AsyncLoading khi đọc ngay sau khi dựng container.
    final neverCompletes = Completer<TodayStudySummary>();
    final c = await _container(summary: () => neverCompletes.future);
    addTearDown(c.dispose);

    expect(c.read(dailyGoalProgressProvider), isNull);
  });

  test(
      'có dữ liệu hôm nay + đã đặt chỉ tiêu -> ghép đúng phút hôm nay '
      '(giây/60) + cả 2 chỉ tiêu', () async {
    final c = await _container(
      summary: () async => (totalDurationSec: 300, sessionCount: 2),
      prefs: {
        DailyGoalStore.minutesKey: 15,
        DailyGoalStore.ayahsKey: 10,
      },
    );
    addTearDown(c.dispose);

    final progress = await _resolvedProgress(c);
    expect(progress, isNotNull);
    expect(progress!.minutesToday, 5); // 300s / 60 = 5 phút
    expect(progress.minutesTarget, 15);
    expect(progress.ayahsTarget, 10);
  });

  test(
      'có dữ liệu hôm nay nhưng CHƯA đặt chỉ tiêu -> target null, '
      'minutesToday vẫn tính đúng', () async {
    final c = await _container(
      summary: () async => (totalDurationSec: 600, sessionCount: 1),
    );
    addTearDown(c.dispose);

    final progress = await _resolvedProgress(c);
    expect(progress, isNotNull);
    expect(progress!.minutesToday, 10);
    expect(progress.minutesTarget, isNull);
    expect(progress.ayahsTarget, isNull);
  });

  test(
      'totalDurationSec = 0 -> minutesToday = 0, KHÔNG trả về null (0 '
      'phút vẫn là dữ liệu hợp lệ, khác "chưa có dữ liệu")', () async {
    final c = await _container(
      summary: () async => (totalDurationSec: 0, sessionCount: 0),
    );
    addTearDown(c.dispose);

    final progress = await _resolvedProgress(c);
    expect(progress, isNotNull);
    expect(progress!.minutesToday, 0);
  });
}
