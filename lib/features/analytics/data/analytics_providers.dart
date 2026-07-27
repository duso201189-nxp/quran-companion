import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../flashcards/data/flashcard_providers.dart';
import '../../learning/data/scheduler_providers.dart';
import '../../lexicon/data/lexicon_providers.dart';
import '../../stats/data/study_session_providers.dart';
import '../domain/analytics_repository.dart';
import '../domain/entities/achievement.dart';
import '../domain/entities/history_bucket.dart';
import '../domain/entities/learning_goal.dart';
import '../domain/entities/learning_statistics.dart';
import '../domain/entities/performance_insights.dart';
import 'analytics_repository_impl.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(
    ref.watch(schedulerRepositoryProvider),
    ref.watch(flashcardRepositoryProvider),
    ref.watch(lexiconRepositoryProvider),
    ref.watch(studySessionRepositoryProvider),
  ),
);

/// Tính 1 lần mỗi khi màn hình Dashboard mở (autoDispose — huỷ khi
/// rời màn hình). CỐ Ý KHÔNG watch thêm allFlashcardsProvider/
/// dueFlashcardCardsProvider để "tự làm mới theo thời gian thực": 2
/// provider đó tự cầu nối sang SchedulerRepository qua
/// flashcardSchedulerSyncProvider (ghi vào srs_cards mỗi khi có emit),
/// watch chúng ở đây tạo vòng phụ thuộc khiến provider này bị huỷ/tạo
/// lại liên tục trước khi kịp resolve xong (xác nhận bằng
/// progress_dashboard_screen_test.dart — pumpAndSettle không bao giờ
/// ổn định). Dashboard là màn hình xem theo yêu cầu (mở lại để làm
/// mới), không cần phản ứng tức thời như Browse/Smart Deck.
final learningStatisticsProvider =
    FutureProvider.autoDispose<LearningStatistics>((ref) {
  return ref.watch(analyticsRepositoryProvider).getLearningStatistics();
});

final learningHistoryProvider = FutureProvider.autoDispose
    .family<List<HistoryBucket>, HistoryGranularity>((ref, granularity) {
  return ref.watch(analyticsRepositoryProvider).getLearningHistory(granularity);
});

final performanceInsightsProvider =
    FutureProvider.autoDispose<PerformanceInsights>((ref) {
  return ref.watch(analyticsRepositoryProvider).getPerformanceInsights();
});

/// Sprint 14 Phase 2.2 — dẫn xuất từ ĐÚNG repository ở trên, không
/// nguồn dữ liệu riêng.
final learningGoalsProvider =
    FutureProvider.autoDispose<List<LearningGoal>>((ref) {
  return ref.watch(analyticsRepositoryProvider).getLearningGoals();
});

final achievementsProvider =
    FutureProvider.autoDispose<List<Achievement>>((ref) {
  return ref.watch(analyticsRepositoryProvider).getAchievements();
});
