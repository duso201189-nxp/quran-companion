import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/stats/data/stats_store.dart';
import 'package:quran_companion/features/stats/data/study_session_providers.dart';
import 'package:quran_companion/features/stats/domain/entities/study_session.dart';
import 'package:quran_companion/features/stats/domain/repositories/study_session_repository.dart';

class _FakeStudySessionRepository implements StudySessionRepository {
  final List<StudySession> sessions = [];
  int currentStreakValue = 0;
  int longestStreakValue = 0;

  @override
  Future<String> logSession({
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    String? note,
  }) async {
    final id = 'fake-${sessions.length}';
    sessions.add(
      StudySession(
        id: id,
        date: date,
        surahId: surahId,
        ayahFrom: ayahFrom,
        ayahTo: ayahTo,
        durationSec: durationSec,
        note: note,
        createdAt: 0,
      ),
    );
    return id;
  }

  @override
  Stream<List<StudySession>> watchAllSessions() => Stream.value(sessions);

  @override
  Stream<List<StudySession>> watchSessionsOnDate(String date) =>
      Stream.value(sessions.where((s) => s.date == date).toList());

  @override
  Future<int> totalDurationOnDate(String date) async => sessions
      .where((s) => s.date == date)
      .fold<int>(0, (sum, s) => sum + s.durationSec);

  @override
  Future<Set<String>> distinctReadingDates() async =>
      {for (final s in sessions) s.date};

  @override
  Future<int> currentStreak({DateTime? today}) async => currentStreakValue;

  @override
  Future<int> longestStreak() async => longestStreakValue;
}

void main() {
  late _FakeStudySessionRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = _FakeStudySessionRepository();
    container = ProviderContainer(
      overrides: [
        studySessionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('currentStreakProvider đọc thẳng từ repository, không tự tính lại',
      () async {
    fakeRepo.currentStreakValue = 5;
    expect(await container.read(currentStreakProvider.future), 5);
  });

  test('longestStreakProvider đọc thẳng từ repository', () async {
    fakeRepo.longestStreakValue = 12;
    expect(await container.read(longestStreakProvider.future), 12);
  });

  test(
      'todayStudySummaryProvider gộp đúng tổng giây + số phiên của '
      'hôm nay, bỏ qua phiên ngày khác', () async {
    final today = StatsStore.dayKey(DateTime.now());
    await fakeRepo.logSession(
      date: today,
      surahId: 1,
      ayahFrom: 0,
      ayahTo: 5,
      durationSec: 100,
    );
    await fakeRepo.logSession(
      date: today,
      surahId: 2,
      ayahFrom: 0,
      ayahTo: 3,
      durationSec: 50,
    );
    await fakeRepo.logSession(
      date: '2000-01-01',
      surahId: 1,
      ayahFrom: 0,
      ayahTo: 1,
      durationSec: 999,
    );

    final summary = await container.read(todayStudySummaryProvider.future);
    expect(summary.totalDurationSec, 150);
    expect(summary.sessionCount, 2);
  });

  test('todayStudySummaryProvider: 0/0 khi chưa có phiên nào hôm nay',
      () async {
    final summary = await container.read(todayStudySummaryProvider.future);
    expect(summary.totalDurationSec, 0);
    expect(summary.sessionCount, 0);
  });
}
