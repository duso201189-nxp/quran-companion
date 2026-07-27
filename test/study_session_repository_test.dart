import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/stats/data/study_session_repository_impl.dart';

void main() {
  late UserDatabase db;
  late StudySessionRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = 1000;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = 1000;
    repo = StudySessionRepositoryImpl(
      db,
      const ConsoleLogger(),
      newId: () => 'session-${++idCounter}',
      nowMs: () => fakeNow,
    );
  });

  tearDown(() => db.close());

  group('logSession + watch', () {
    test('logSession trả về id và xuất hiện trong watchAllSessions', () async {
      final id = await repo.logSession(
        date: '2026-07-18',
        surahId: 2,
        ayahFrom: 0,
        ayahTo: 9,
        durationSec: 300,
        note: 'buổi sáng',
      );

      final sessions = await repo.watchAllSessions().first;
      expect(sessions, hasLength(1));
      expect(sessions.single.id, id);
      expect(sessions.single.date, '2026-07-18');
      expect(sessions.single.surahId, 2);
      expect(sessions.single.ayahFrom, 0);
      expect(sessions.single.ayahTo, 9);
      expect(sessions.single.durationSec, 300);
      expect(sessions.single.note, 'buổi sáng');
    });

    test('watchSessionsOnDate chỉ trả phiên đúng ngày', () async {
      await repo.logSession(
        date: '2026-07-18',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 6,
        durationSec: 120,
      );
      await repo.logSession(
        date: '2026-07-19',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 6,
        durationSec: 180,
      );

      final onDate = await repo.watchSessionsOnDate('2026-07-19').first;
      expect(onDate, hasLength(1));
      expect(onDate.single.durationSec, 180);
    });

    test('totalDurationOnDate cộng dồn nhiều phiên cùng ngày', () async {
      await repo.logSession(
        date: '2026-07-18',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 6,
        durationSec: 100,
      );
      await repo.logSession(
        date: '2026-07-18',
        surahId: 1,
        ayahFrom: 7,
        ayahTo: 10,
        durationSec: 50,
      );
      await repo.logSession(
        date: '2026-07-19',
        surahId: 2,
        ayahFrom: 0,
        ayahTo: 5,
        durationSec: 999,
      );

      expect(await repo.totalDurationOnDate('2026-07-18'), 150);
    });

    test('distinctReadingDates gộp các ngày trùng, không lặp', () async {
      await repo.logSession(
        date: '2026-07-18',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 6,
        durationSec: 60,
      );
      await repo.logSession(
        date: '2026-07-18',
        surahId: 1,
        ayahFrom: 7,
        ayahTo: 10,
        durationSec: 60,
      );
      await repo.logSession(
        date: '2026-07-17',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 6,
        durationSec: 60,
      );

      expect(
        await repo.distinctReadingDates(),
        {'2026-07-17', '2026-07-18'},
      );
    });
  });

  group('streak (derived-on-read, không có bảng streaks)', () {
    test('currentStreak = 0 khi chưa có phiên đọc nào', () async {
      expect(await repo.currentStreak(), 0);
    });

    test('currentStreak đếm chuỗi liên tiếp kết thúc hôm nay', () async {
      for (final d in ['2026-07-17', '2026-07-18', '2026-07-19']) {
        await repo.logSession(
          date: d,
          surahId: 1,
          ayahFrom: 0,
          ayahTo: 1,
          durationSec: 60,
        );
      }
      final streak = await repo.currentStreak(
        today: DateTime(2026, 7, 19),
      );
      expect(streak, 3);
    });

    test('currentStreak cho phép kết thúc hôm qua (hôm nay chưa đọc)',
        () async {
      for (final d in ['2026-07-17', '2026-07-18']) {
        await repo.logSession(
          date: d,
          surahId: 1,
          ayahFrom: 0,
          ayahTo: 1,
          durationSec: 60,
        );
      }
      final streak = await repo.currentStreak(
        today: DateTime(2026, 7, 19),
      );
      expect(streak, 2);
    });

    test('currentStreak = 0 nếu có khoảng trống trước hôm qua', () async {
      await repo.logSession(
        date: '2026-07-10',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 1,
        durationSec: 60,
      );
      final streak = await repo.currentStreak(
        today: DateTime(2026, 7, 19),
      );
      expect(streak, 0);
    });

    test('longestStreak tìm chuỗi dài nhất dù chuỗi hiện tại ngắn hơn',
        () async {
      for (final d in ['2026-07-01', '2026-07-02', '2026-07-03']) {
        await repo.logSession(
          date: d,
          surahId: 1,
          ayahFrom: 0,
          ayahTo: 1,
          durationSec: 60,
        );
      }
      // Khoảng trống, rồi 1 ngày đọc lẻ.
      await repo.logSession(
        date: '2026-07-10',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 1,
        durationSec: 60,
      );

      expect(await repo.longestStreak(), 3);
    });
  });
}
