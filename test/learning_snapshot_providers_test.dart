import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/read_model/data/learning_snapshot_providers.dart';
import 'package:quran_companion/features/smart_learning/data/smart_learning_providers.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/smart_learning_session.dart';
import 'package:quran_companion/features/smart_learning/domain/smart_learning_repository.dart';

class _FakeSmartLearningRepository implements SmartLearningRepository {
  _FakeSmartLearningRepository(this.session);

  final SmartLearningSession session;

  @override
  Future<SmartLearningSession> getSmartLearningSession() async => session;
}

/// Fake đếm số lần getSmartLearningSession() được gọi thật — dùng để
/// CHỨNG MINH (Sprint 18 Phase 2) learningSnapshotProvider tái dùng
/// smartLearningSessionProvider đã watch trước đó thay vì tự kích hoạt
/// 1 lượt SmartLearningRepository.getSmartLearningSession() MỚI (kéo
/// theo toàn bộ chuỗi LearningJourney → AITutor → Analytics phía dưới).
class _CountingSmartLearningRepository implements SmartLearningRepository {
  _CountingSmartLearningRepository(this.session);

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
  return SmartLearningSession(
    date: date,
    recommendations: const [],
    journey: LearningJourney(
      context: _emptyContext,
      todayPlan: DailyLearningPlan(date: date, steps: const []),
      insights: const [],
    ),
  );
}

void main() {
  late ProviderContainer container;

  tearDown(() => container.dispose());

  test(
      'learningSnapshotRepositoryProvider ghép ĐÚNG smartLearningRepositoryProvider '
      'đã override, không tạo repository riêng', () async {
    final date = DateTime(2026, 7, 21);
    container = ProviderContainer(
      overrides: [
        smartLearningRepositoryProvider.overrideWithValue(
          _FakeSmartLearningRepository(_sessionOn(date)),
        ),
      ],
    );

    final snapshot = await container.read(learningSnapshotProvider.future);

    expect(snapshot.dailyPlan.date, date);
  });

  test(
      'learningSnapshotProvider trả đủ context/insights/dailyPlan/'
      'smartSession', () async {
    final session = _sessionOn(DateTime(2026, 7, 21));
    container = ProviderContainer(
      overrides: [
        smartLearningRepositoryProvider.overrideWithValue(
          _FakeSmartLearningRepository(session),
        ),
      ],
    );

    final snapshot = await container.read(learningSnapshotProvider.future);

    expect(snapshot.context, same(_emptyContext));
    expect(snapshot.smartSession, same(session));
  });

  test(
      'learningSnapshotProvider tái dùng smartLearningSessionProvider đã '
      'có màn hình khác giữ watch — KHÔNG gọi getSmartLearningSession() '
      'thêm lần nào (Sprint 18 Phase 2)', () async {
    final fake = _CountingSmartLearningRepository(
      _sessionOn(DateTime(2026, 7, 21)),
    );
    container = ProviderContainer(
      overrides: [smartLearningRepositoryProvider.overrideWithValue(fake)],
    );

    // Mô phỏng SmartLearningScreen đang mounted bên dưới — 1
    // subscription sống thật.
    final sub = container.listen(smartLearningSessionProvider, (_, __) {});
    await container.read(smartLearningSessionProvider.future);
    expect(fake.callCount, 1);

    final snapshot = await container.read(learningSnapshotProvider.future);

    expect(fake.callCount, 1);
    expect(snapshot.dailyPlan.date, DateTime(2026, 7, 21));
    sub.close();
  });
}
