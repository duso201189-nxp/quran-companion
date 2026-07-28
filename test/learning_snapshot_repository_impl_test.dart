import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/read_model/data/learning_snapshot_repository_impl.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/smart_learning_session.dart';
import 'package:quran_companion/features/smart_learning/domain/smart_learning_repository.dart';

/// Fake THUẦN của SmartLearningRepository — KHÔNG cần
/// LearningJourneyRepository/AITutorRepository/AnalyticsRepository/
/// database nào, vì LearningSnapshotRepository (Sprint 18 Phase 1)
/// chỉ được phép biết tới ĐÚNG 1 interface này. Cùng lợi ích kiến
/// trúc đã công khai xuyên suốt Sprint 15/16/17 Phase 1: không tốn 1
/// dòng thiết lập DB nào.
class _FakeSmartLearningRepository implements SmartLearningRepository {
  _FakeSmartLearningRepository(this.session);

  final SmartLearningSession session;
  int callCount = 0;

  @override
  Future<SmartLearningSession> getSmartLearningSession() async {
    callCount++;
    return session;
  }
}

const _emptyContext = TutorContext(
  statistics: LearningStatistics(
    cardsStudied: 0,
    dueToday: 0,
    reviewsToday: 0,
    accuracy: 0,
    averageEase: 2.5,
    averageInterval: 1,
    readingStreakDays: 0,
    longestReadingStreakDays: 0,
  ),
  goals: [],
  achievements: [],
  insights: PerformanceInsights(
    weakRoots: [],
    difficultLemmas: [],
    frequentlyForgotten: [],
    fastestImproving: [],
  ),
);

SmartLearningSession _sessionOn(DateTime date) {
  final plan = DailyLearningPlan(date: date, steps: const []);
  return SmartLearningSession(
    date: date,
    recommendations: const [],
    journey: LearningJourney(
      context: _emptyContext,
      todayPlan: plan,
      insights: const [],
    ),
  );
}

void main() {
  group('getSnapshot', () {
    test(
        'gói ĐÚNG context/insights/dailyPlan/smartSession từ '
        'SmartLearningSession trả về', () async {
      final date = DateTime(2026, 7, 21);
      final fake = _FakeSmartLearningRepository(_sessionOn(date));
      final repo = LearningSnapshotRepositoryImpl(
        fake,
        now: () => DateTime(2026, 7, 21, 9),
      );

      final snapshot = await repo.getSnapshot();

      expect(snapshot.timestamp.generatedAt, DateTime(2026, 7, 21, 9));
      expect(snapshot.dailyPlan.date, date);
      expect(snapshot.smartSession, same(fake.session));
    });

    test('gọi ĐÚNG getSmartLearningSession() 1 lần', () async {
      final fake = _FakeSmartLearningRepository(
        _sessionOn(DateTime(2026, 7, 21)),
      );
      final repo = LearningSnapshotRepositoryImpl(fake);

      await repo.getSnapshot();

      expect(fake.callCount, 1);
    });

    test(
        'mỗi lệnh gọi tạo LearningSnapshot MỚI (không cache) — gọi 2 lần '
        'ra 2 đối tượng khác nhau', () async {
      final fake = _FakeSmartLearningRepository(
        _sessionOn(DateTime(2026, 7, 21)),
      );
      final repo = LearningSnapshotRepositoryImpl(fake);

      final first = await repo.getSnapshot();
      final second = await repo.getSnapshot();

      expect(identical(first, second), isFalse);
      expect(fake.callCount, 2);
    });
  });
}
