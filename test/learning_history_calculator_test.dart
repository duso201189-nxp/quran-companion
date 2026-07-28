import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/analytics/domain/entities/history_bucket.dart';
import 'package:quran_companion/features/analytics/domain/learning_history_calculator.dart';
import 'package:quran_companion/features/stats/domain/entities/study_session.dart';

StudySession _session(String date, int durationSec, {int id = 0}) =>
    StudySession(
      id: 's-$date-$id',
      date: date,
      surahId: 1,
      ayahFrom: 0,
      ayahTo: 1,
      durationSec: durationSec,
      createdAt: 0,
    );

void main() {
  // Thứ 3 (weekday=2) — cố định để test chuỗi tuần/tháng dự đoán được.
  final now = DateTime(2026, 7, 21);

  group('daily', () {
    test('trả đúng [count] mốc, mốc gần nhất là hôm nay, cũ nhất đứng đầu', () {
      final sessions = [
        _session('2026-07-21', 600), // hôm nay, 10 phút
        _session('2026-07-20', 300), // hôm qua, 5 phút
      ];
      final buckets = computeLearningHistory(
        sessions,
        HistoryGranularity.daily,
        count: 3,
        now: now,
      );
      expect(buckets, hasLength(3));
      expect(buckets.last.periodStart, DateTime(2026, 7, 21));
      expect(buckets.last.minutesStudied, 10);
      expect(buckets[1].minutesStudied, 5);
      expect(buckets.first.minutesStudied, 0); // 2026-07-19, không đọc
    });

    test('nhiều phiên cùng 1 ngày -> cộng dồn phút + đếm đủ số phiên', () {
      final sessions = [
        _session('2026-07-21', 60, id: 1),
        _session('2026-07-21', 120, id: 2),
      ];
      final buckets = computeLearningHistory(
        sessions,
        HistoryGranularity.daily,
        count: 1,
        now: now,
      );
      expect(buckets.single.minutesStudied, 3);
      expect(buckets.single.sessionCount, 2);
    });

    test('không có phiên nào -> mọi mốc đều 0, không throw', () {
      final buckets = computeLearningHistory(
        const [],
        HistoryGranularity.daily,
        count: 5,
        now: now,
      );
      expect(buckets, hasLength(5));
      expect(buckets.every((b) => b.minutesStudied == 0), isTrue);
    });
  });

  group('weekly', () {
    test('gộp đủ 7 ngày mỗi tuần, đúng tuần chứa phiên đọc', () {
      final sessions = [
        _session('2026-07-20', 600), // tuần này (T2 20/7 - CN 26/7)
        _session('2026-07-13', 300), // tuần trước (T2 13/7 - CN 19/7)
      ];
      final buckets = computeLearningHistory(
        sessions,
        HistoryGranularity.weekly,
        count: 2,
        now: now,
      );
      expect(buckets, hasLength(2));
      expect(buckets.first.minutesStudied, 5); // tuần trước
      expect(buckets.last.minutesStudied, 10); // tuần này
      expect(buckets.last.periodStart, DateTime(2026, 7, 20)); // Thứ 2
    });
  });

  group('monthly', () {
    test('gộp đúng theo tháng, kể cả khi lùi qua năm trước', () {
      final sessions = [
        _session('2026-07-05', 600),
        _session('2025-12-15', 300), // tháng 12 năm trước
      ];
      final buckets = computeLearningHistory(
        sessions,
        HistoryGranularity.monthly,
        count: 8,
        now: now,
      );
      expect(buckets, hasLength(8));
      expect(buckets.last.periodStart, DateTime(2026, 7, 1));
      expect(buckets.last.minutesStudied, 10);
      final decBucket =
          buckets.firstWhere((b) => b.periodStart == DateTime(2025, 12, 1));
      expect(decBucket.minutesStudied, 5);
    });
  });
}
