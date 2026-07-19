import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/user/user_database_providers.dart';
import '../domain/repositories/study_session_repository.dart';
import 'stats_store.dart';
import 'study_session_repository_impl.dart';

final studySessionRepositoryProvider = Provider<StudySessionRepository>(
  (ref) => StudySessionRepositoryImpl(ref.watch(userDatabaseProvider)),
);

/// Chuỗi ngày đọc liên tiếp hiện tại — tính trên truy vấn từ
/// study_sessions (không có bảng streaks, xem DR-2026-0003 mục A).
final currentStreakProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(studySessionRepositoryProvider).currentStreak(),
);

/// Chuỗi ngày đọc liên tiếp dài nhất trong toàn bộ lịch sử.
final longestStreakProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(studySessionRepositoryProvider).longestStreak(),
);

/// Tổng quan phiên đọc hôm nay: tổng giây đọc + số phiên.
typedef TodayStudySummary = ({int totalDurationSec, int sessionCount});

final todayStudySummaryProvider =
    FutureProvider.autoDispose<TodayStudySummary>((ref) async {
  final repo = ref.watch(studySessionRepositoryProvider);
  final today = StatsStore.dayKey(DateTime.now());
  final sessions = await repo.watchSessionsOnDate(today).first;
  final totalDurationSec = sessions.fold<int>(
    0,
    (sum, s) => sum + s.durationSec,
  );
  return (totalDurationSec: totalDurationSec, sessionCount: sessions.length);
});
