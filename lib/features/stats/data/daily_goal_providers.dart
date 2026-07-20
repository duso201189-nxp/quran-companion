import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_goal_store.dart';
import 'study_session_providers.dart';

/// Tiến độ mục tiêu đọc hằng ngày — ghép thuần [todayStudySummaryProvider]
/// (Sprint 8) với chỉ tiêu ở [dailyGoalStoreProvider] (Sprint 9 Phase
/// 1), không tính lại tổng thời lượng (đã có sẵn ở
/// TodayStudySummary.totalDurationSec) và không tự quyết định "đạt
/// mục tiêu hay chưa" — công thức ngày đủ điều kiện (>=5 phút HOẶC
/// >=5 Ayah) vẫn còn treo (xem TODO.md), nên chỉ ghép số liệu thô,
/// để tầng UI (phase sau) diễn giải.
typedef DailyGoalProgress = ({
  int minutesToday,
  int? minutesTarget,
  int? ayahsTarget,
});

/// null khi [todayStudySummaryProvider] chưa có dữ liệu (loading/lỗi)
/// — cùng quy ước với [khatmProgressProvider] trong
/// `khatm_cycle_providers.dart`.
final dailyGoalProgressProvider = Provider.autoDispose<DailyGoalProgress?>((
  ref,
) {
  final summary = ref.watch(todayStudySummaryProvider).valueOrNull;
  if (summary == null) return null;

  final target = ref.watch(dailyGoalStoreProvider);
  return (
    minutesToday: summary.totalDurationSec ~/ 60,
    minutesTarget: target.minutesPerDay,
    ayahsTarget: target.ayahsPerDay,
  );
});
