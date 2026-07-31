import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/stats/data/study_session_providers.dart';
import 'package:quran_companion/features/stats/domain/entities/study_session.dart';
import 'package:quran_companion/features/stats/domain/repositories/study_session_repository.dart';
import 'package:quran_companion/features/stats/presentation/widgets/reading_stats_section.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

class _FakeStudySessionRepository implements StudySessionRepository {
  int currentStreakValue = 0;
  int longestStreakValue = 0;
  List<StudySession> todaySessions = const [];

  @override
  Future<String> logSession({
    required String date,
    required int surahId,
    required int ayahFrom,
    required int ayahTo,
    required int durationSec,
    String? note,
  }) =>
      throw UnimplementedError();

  @override
  Stream<List<StudySession>> watchAllSessions() => throw UnimplementedError();

  @override
  Stream<List<StudySession>> watchSessionsOnDate(String date) =>
      Stream.value(todaySessions);

  @override
  Future<int> totalDurationOnDate(String date) async =>
      todaySessions.fold<int>(0, (sum, s) => sum + s.durationSec);

  @override
  Future<Set<String>> distinctReadingDates() async => {};

  @override
  Future<int> currentStreak({DateTime? today}) async => currentStreakValue;

  @override
  Future<int> longestStreak() async => longestStreakValue;
}

void main() {
  late _FakeStudySessionRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeStudySessionRepository();
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        studySessionRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ReadingStatsSection()),
      ),
    );
  }

  testWidgets(
      'chưa có phiên nào -> streak = 0 days, tóm tắt hôm nay hiện '
      'thông báo rỗng (không hiện số phút/số phiên gây hiểu lầm)',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Reading Sessions'), findsOneWidget);
    expect(find.text('0 days'), findsNWidgets(2));
    expect(find.text('No reading sessions logged yet.'), findsOneWidget);
  });

  testWidgets(
      'có dữ liệu -> hiện đúng streak hiện tại/dài nhất và tổng kết '
      'hôm nay (phút + số phiên)', (tester) async {
    fakeRepo.currentStreakValue = 5;
    fakeRepo.longestStreakValue = 12;
    fakeRepo.todaySessions = [
      const StudySession(
        id: 's1',
        date: '2026-07-19',
        surahId: 1,
        ayahFrom: 0,
        ayahTo: 6,
        durationSec: 90,
        createdAt: 0,
      ),
      const StudySession(
        id: 's2',
        date: '2026-07-19',
        surahId: 2,
        ayahFrom: 0,
        ayahTo: 3,
        durationSec: 30,
        createdAt: 0,
      ),
    ];

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('5 days'), findsOneWidget);
    expect(find.text('12 days'), findsOneWidget);
    // 90 + 30 = 120s = 2 min, 2 phiên.
    expect(find.text('2 min · 2 sessions'), findsOneWidget);
    expect(find.text('No reading sessions logged yet.'), findsNothing);
  });
}
