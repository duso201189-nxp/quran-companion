import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/features/analytics/data/analytics_repository_impl.dart';
import 'package:quran_companion/features/analytics/domain/entities/achievement.dart';
import 'package:quran_companion/features/analytics/domain/entities/history_bucket.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_goal.dart';
import 'package:quran_companion/features/analytics/domain/learning_goal_calculator.dart';
import 'package:quran_companion/features/flashcards/data/flashcard_repository_impl.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/learning/data/scheduler_repository_impl.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/sm2_scheduling_algorithm.dart';
import 'package:quran_companion/features/lexicon/data/lexicon_repository_impl.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';
import 'package:quran_companion/features/stats/data/study_session_repository_impl.dart';
import 'package:quran_companion/features/stats/domain/entities/study_session.dart';
import 'package:quran_companion/features/stats/domain/repositories/study_session_repository.dart';

/// Bọc 1 StudySessionRepository THẬT, đếm số lần watchAllSessions()
/// được gọi — dùng để CHỨNG MINH tối ưu Sprint 14 Phase 3 (gộp
/// _AnalyticsSnapshot trong getLearningGoals) thật sự giảm số lần
/// truy vấn, không chỉ khẳng định suông trong doc comment.
class _CountingStudySessionRepository implements StudySessionRepository {
  _CountingStudySessionRepository(this._inner);

  final StudySessionRepository _inner;
  int watchAllSessionsCallCount = 0;

  @override
  Stream<List<StudySession>> watchAllSessions() {
    watchAllSessionsCallCount++;
    return _inner.watchAllSessions();
  }

  @override
  Future<String> logSession({
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    String? note,
  }) =>
      _inner.logSession(
        date: date,
        surahId: surahId,
        ayahFrom: ayahFrom,
        ayahTo: ayahTo,
        durationSec: durationSec,
        note: note,
      );

  @override
  Stream<List<StudySession>> watchSessionsOnDate(String date) =>
      _inner.watchSessionsOnDate(date);

  @override
  Future<int> totalDurationOnDate(String date) =>
      _inner.totalDurationOnDate(date);

  @override
  Future<Set<String>> distinctReadingDates() => _inner.distinctReadingDates();

  @override
  Future<int> currentStreak({DateTime? today}) =>
      _inner.currentStreak(today: today);

  @override
  Future<int> longestStreak() => _inner.longestStreak();
}

/// Test tổng hợp AnalyticsRepositoryImpl (Sprint 14 Phase 1) — dùng
/// triển khai THẬT của cả 4 repository (không fake) trên 2 database
/// bộ nhớ, đúng bản chất "tổng hợp ở tầng repository" của phase này
/// (khác các fake nhẹ dùng cho test provider/widget) — chứng minh
/// việc ghép nối THẬT hoạt động đúng, không chỉ đúng ở mức khai báo
/// kiểu.
void main() {
  late UserDatabase userDb;
  late AppDatabase appDb;
  late SchedulerRepositoryImpl scheduler;
  late FlashcardRepositoryImpl flashcards;
  late LexiconRepositoryImpl lexicon;
  late StudySessionRepositoryImpl studySessions;
  late AnalyticsRepositoryImpl repo;
  var idCounter = 0;
  var fakeNow = DateTime.utc(2026, 7, 21, 12).millisecondsSinceEpoch;

  setUp(() async {
    userDb = UserDatabase(NativeDatabase.memory());
    appDb = AppDatabase(NativeDatabase.memory());
    idCounter = 0;
    fakeNow = DateTime.utc(2026, 7, 21, 12).millisecondsSinceEpoch;

    scheduler = SchedulerRepositoryImpl(
      userDb,
      const SM2SchedulingAlgorithm(),
      const ConsoleLogger(),
      newId: () => 'card-${++idCounter}',
      nowMs: () => fakeNow,
    );
    flashcards = FlashcardRepositoryImpl(
      userDb,
      const ConsoleLogger(),
      newId: () => 'fc-${++idCounter}',
      nowMs: () => fakeNow,
    );
    lexicon = LexiconRepositoryImpl(appDb, const ConsoleLogger());
    studySessions = StudySessionRepositoryImpl(
      userDb,
      const ConsoleLogger(),
      newId: () => 'session-${++idCounter}',
      nowMs: () => fakeNow,
    );
    repo = AnalyticsRepositoryImpl(
      scheduler,
      flashcards,
      lexicon,
      studySessions,
      now: () => DateTime.fromMillisecondsSinceEpoch(fakeNow, isUtc: true),
    );

    await appDb.batch((b) {
      b.insertAll(appDb.roots, [
        const RootRow(id: 100, radicals: 'ك ت ب'),
      ]);
      b.insertAll(appDb.lemmas, [
        const LemmaRow(
          id: 1,
          arabic: 'كَتَبَ',
          occurrenceCount: 10,
          rootId: 100,
        ),
        const LemmaRow(id: 2, arabic: 'قَرَأَ', occurrenceCount: 5),
      ]);
    });
  });

  tearDown(() async {
    await userDb.close();
    await appDb.close();
  });

  group('getLearningStatistics', () {
    test('gộp SrsCard CẢ 2 loại (ayah + lemma) + tái dùng streak đọc thật',
        () async {
      await scheduler.syncItemsForType(LearningItemType.ayah, [10, 20]);
      await scheduler.syncItemsForType(LearningItemType.lemma, [1]);
      await studySessions.logSession(
        date: '2026-07-21',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 5,
        durationSec: 600,
      );

      final stats = await repo.getLearningStatistics();

      // 3 thẻ mới tạo -> repetitions=0 -> cardsStudied=0 (chưa ôn lần nào).
      expect(stats.cardsStudied, 0);
      expect(stats.dueToday, 3); // thẻ mới luôn due ngay.
      expect(stats.readingStreakDays, greaterThanOrEqualTo(1));
    });

    test('sau khi applyReview, cardsStudied/reviewsToday tăng đúng', () async {
      await scheduler.syncItemsForType(LearningItemType.lemma, [1]);
      final card =
          (await scheduler.watchAllCards(LearningItemType.lemma).first).single;
      await scheduler.applyReview(card.id, ReviewGrade.good);

      final stats = await repo.getLearningStatistics();
      expect(stats.cardsStudied, 1);
      expect(stats.reviewsToday, 1);
      expect(stats.accuracy, 1.0);
    });
  });

  group('getLearningHistory', () {
    test('tái dùng phiên đọc thật, gộp đúng theo Ngày', () async {
      await studySessions.logSession(
        date: '2026-07-21',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 5,
        durationSec: 300,
      );

      final buckets = await repo.getLearningHistory(
        HistoryGranularity.daily,
        count: 3,
      );

      expect(buckets, hasLength(3));
      expect(buckets.last.minutesStudied, 5);
    });
  });

  group('getPerformanceInsights', () {
    test('giải quyết đúng Lemma cho từng Flashcard, phân loại đúng theo state',
        () async {
      await flashcards.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 1,
      );
      await scheduler.syncItemsForType(LearningItemType.lemma, [1]);
      final card =
          (await scheduler.watchAllCards(LearningItemType.lemma).first).single;
      // 2 lần ôn "again" liên tiếp -> tốt nghiệp rồi sai -> lapsed.
      await scheduler.applyReview(card.id, ReviewGrade.good);
      await scheduler.applyReview(card.id, ReviewGrade.again);

      final insights = await repo.getPerformanceInsights();

      expect(insights.frequentlyForgotten, hasLength(1));
      expect(insights.frequentlyForgotten.single.lemma?.arabic, 'كَتَبَ');
      expect(insights.weakRoots, hasLength(1));
    });

    test('chưa có Flashcard nào -> mọi danh sách rỗng, không lỗi', () async {
      final insights = await repo.getPerformanceInsights();
      expect(insights.weakRoots, isEmpty);
      expect(insights.difficultLemmas, isEmpty);
      expect(insights.frequentlyForgotten, isEmpty);
      expect(insights.fastestImproving, isEmpty);
    });
  });

  group('getLearningGoals', () {
    test(
        'current lấy đúng minutesToday/reviewsToday/minutesThisWeek từ '
        'Statistics/History đã có (Sprint 14 Phase 2.2)', () async {
      await scheduler.syncItemsForType(LearningItemType.lemma, [1]);
      final card =
          (await scheduler.watchAllCards(LearningItemType.lemma).first).single;
      await scheduler.applyReview(card.id, ReviewGrade.good);
      await studySessions.logSession(
        date: '2026-07-21',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 5,
        durationSec: 300,
      );

      final goals = await repo.getLearningGoals();
      final byKind = {for (final g in goals) g.kind: g};

      expect(byKind[LearningGoalKind.dailyStudyMinutes]!.current, 5);
      expect(byKind[LearningGoalKind.dailyReviews]!.current, 1);
      expect(byKind[LearningGoalKind.weeklyStudyMinutes]!.current, 5);
      expect(
        byKind[LearningGoalKind.dailyStudyMinutes]!.target,
        LearningGoalDefaults.dailyStudyMinutes,
      );
    });

    test('chưa học/chưa đọc gì -> current = 0 ở cả 3 mục tiêu', () async {
      final goals = await repo.getLearningGoals();
      expect(goals.every((g) => g.current == 0), isTrue);
      expect(goals, hasLength(3));
    });

    test(
        'Sprint 14 Phase 3 — CHỈ gọi watchAllSessions() 1 LẦN (trước đây '
        '2 lần: mốc Ngày + mốc Tuần tải riêng)', () async {
      final counting = _CountingStudySessionRepository(studySessions);
      final optimized = AnalyticsRepositoryImpl(
        scheduler,
        flashcards,
        lexicon,
        counting,
        now: () => DateTime.fromMillisecondsSinceEpoch(fakeNow, isUtc: true),
      );

      await optimized.getLearningGoals();

      expect(counting.watchAllSessionsCallCount, 1);
    });
  });

  group('getAchievements', () {
    test('firstStudy/tenCardsStudied mở khoá đúng theo cardsStudied đã có',
        () async {
      await scheduler.syncItemsForType(LearningItemType.lemma, [1]);
      final card =
          (await scheduler.watchAllCards(LearningItemType.lemma).first).single;
      await scheduler.applyReview(card.id, ReviewGrade.good);

      final achievements = await repo.getAchievements();
      final byKind = {for (final a in achievements) a.kind: a};

      expect(byKind[AchievementKind.firstStudy]!.isUnlocked, isTrue);
      expect(byKind[AchievementKind.tenCardsStudied]!.isUnlocked, isFalse);
    });

    test('chưa học gì -> không thành tựu nào mở khoá', () async {
      final achievements = await repo.getAchievements();
      expect(achievements.every((a) => !a.isUnlocked), isTrue);
      expect(achievements, hasLength(6));
    });
  });
}
