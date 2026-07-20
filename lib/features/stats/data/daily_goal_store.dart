import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_provider.dart';

/// Chỉ tiêu đọc hằng ngày (Daily Goal) — null ở một trường nghĩa là
/// chưa đặt ngưỡng đó. Không có "tiến độ" ở đây (xem DR-2026-0004
/// mục 2: tiến độ dẫn xuất từ study_sessions, ở tầng provider riêng,
/// phase sau).
typedef DailyGoalTarget = ({int? minutesPerDay, int? ayahsPerDay});

/// Lưu/khôi phục chỉ tiêu đọc hằng ngày — SharedPreferences, cùng
/// kiến trúc [ThemeController]/[LocaleController] (Notifier tự đọc
/// lại lúc build(), tự lưu bền mỗi lần đổi).
class DailyGoalStore extends Notifier<DailyGoalTarget> {
  static const String minutesKey = 'settings.daily_goal.minutes';
  static const String ayahsKey = 'settings.daily_goal.ayahs';

  @override
  DailyGoalTarget build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return (
      minutesPerDay: prefs.getInt(minutesKey),
      ayahsPerDay: prefs.getInt(ayahsKey),
    );
  }

  /// Đặt lại chỉ tiêu. null = bỏ ngưỡng đó (không phải 0).
  Future<void> setTarget({int? minutesPerDay, int? ayahsPerDay}) async {
    state = (minutesPerDay: minutesPerDay, ayahsPerDay: ayahsPerDay);
    final prefs = ref.read(sharedPreferencesProvider);
    if (minutesPerDay == null) {
      await prefs.remove(minutesKey);
    } else {
      await prefs.setInt(minutesKey, minutesPerDay);
    }
    if (ayahsPerDay == null) {
      await prefs.remove(ayahsKey);
    } else {
      await prefs.setInt(ayahsKey, ayahsPerDay);
    }
  }
}

final dailyGoalStoreProvider =
    NotifierProvider<DailyGoalStore, DailyGoalTarget>(DailyGoalStore.new);
