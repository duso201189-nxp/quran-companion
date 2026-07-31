import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_context.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_insight.dart';
import 'package:quran_companion/features/ai_tutor/domain/entities/tutor_suggestion.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_header.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_insight_card.dart';
import 'package:quran_companion/features/analytics/domain/entities/learning_statistics.dart';
import 'package:quran_companion/features/analytics/domain/entities/performance_insights.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/daily_learning_plan.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/journey_step.dart';
import 'package:quran_companion/features/learning_journey/domain/entities/learning_journey.dart';
import 'package:quran_companion/features/learning_journey/presentation/widgets/journey_step_card.dart';
import 'package:quran_companion/features/read_model/presentation/study_summary_screen.dart';
import 'package:quran_companion/features/smart_learning/data/smart_learning_providers.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/learning_recommendation.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/session_strategy.dart';
import 'package:quran_companion/features/smart_learning/domain/entities/smart_learning_session.dart';
import 'package:quran_companion/features/smart_learning/domain/smart_learning_repository.dart';
import 'package:quran_companion/features/smart_learning/presentation/widgets/recommendation_card.dart';
import 'package:quran_companion/features/smart_learning/presentation/widgets/session_summary_card.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// Fake CHỈ đủ cho tầng nền tảng Sprint R2.1 — cùng điểm ghi đè
/// (`smartLearningRepositoryProvider`) mà `test/learning_snapshot_providers_test.dart`
/// (Sprint 18 Phase 2) đã dùng, KHÔNG ghi đè `learningSnapshotProvider`
/// trực tiếp (đó là wrapper thuần, không phải nguồn dữ liệu thật —
/// xem PHASE3_SPRINT_R2_DESIGN_REVIEW.md mục "Testing Strategy").
class _FakeSmartLearningRepository implements SmartLearningRepository {
  _FakeSmartLearningRepository(this._session, {this.shouldThrow = false});

  final SmartLearningSession _session;
  final bool shouldThrow;

  @override
  Future<SmartLearningSession> getSmartLearningSession() async {
    if (shouldThrow) throw Exception('Lỗi giả lập (Sprint R2.1)');
    return _session;
  }
}

/// Fake CHỈ dùng để bắt khung hình loading — `Completer` KHÔNG bao
/// giờ hoàn tất trong bài kiểm (Future thật của fake ở trên chỉ mất 1
/// microtask, `pump()` đơn lẻ đã đủ trôi qua, không bắt được khung
/// loading) — cùng kỹ thuật `TESTING_GUIDE.md` §1.3 mô tả cho
/// `daily_goal_providers_test.dart`.
class _NeverResolvingSmartLearningRepository implements SmartLearningRepository {
  @override
  Future<SmartLearningSession> getSmartLearningSession() {
    return Completer<SmartLearningSession>().future;
  }
}

/// Fake cho các bài kiểm "làm mới" (Sprint R2.3) — đếm số lần
/// `getSmartLearningSession()` được gọi THẬT + cho phép đổi session sẽ
/// trả về ở lần gọi kế tiếp ([setNextSession]) + có thể lỗi đúng
/// [failFirstCalls] lần gọi đầu rồi thành công từ đó về sau. Dùng
/// chung để chứng minh: (a) pull-to-refresh/nút "Thử lại" thật sự kích
/// hoạt 1 lượt gọi MỚI (không chỉ đọc lại cache — đúng cơ chế đã ghi ở
/// doc comment `StudySummaryScreen`), và (b) dữ liệu mới sau khi làm
/// mới được vẽ đúng.
class _SwappableSmartLearningRepository implements SmartLearningRepository {
  _SwappableSmartLearningRepository(this._session, {this.failFirstCalls = 0});

  SmartLearningSession _session;
  final int failFirstCalls;
  int callCount = 0;

  void setNextSession(SmartLearningSession session) {
    _session = session;
  }

  @override
  Future<SmartLearningSession> getSmartLearningSession() async {
    callCount++;
    if (callCount <= failFirstCalls) {
      throw Exception('Lỗi giả lập (Sprint R2.3 — lần gọi $callCount)');
    }
    return _session;
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

/// Snapshot RỖNG: insights/dailyPlan.steps/recommendations đều rỗng —
/// đúng điều kiện Empty State trong StudySummaryScreen.
SmartLearningSession _emptySession(DateTime date) {
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

/// Snapshot CÓ nội dung (ít nhất 1 đề xuất) — dùng để khẳng định
/// nhánh "không rỗng" không crash, dù Sprint R2.1 CHƯA vẽ nội dung
/// thật (xem doc comment StudySummaryScreen).
SmartLearningSession _sessionWithContent(DateTime date) {
  return SmartLearningSession(
    date: date,
    recommendations: const [
      LearningRecommendation(
        strategy: SessionStrategy.deepStudy,
        estimatedMinutes: 20,
        relatedStepCount: 1,
      ),
    ],
    journey: LearningJourney(
      context: _emptyContext,
      todayPlan: DailyLearningPlan(date: date, steps: const []),
      insights: const [],
    ),
  );
}

/// 1 nhận định mẫu — dùng cho các bài kiểm Sprint R2.2 (vẽ nội dung
/// thật) bên dưới.
const _sampleInsight = TutorInsight(
  kind: TutorInsightKind.cardsStudiedSummary,
  value: 12,
);

/// 1 bước kế hoạch mẫu — CỐ Ý KHÔNG gắn `action` (StudySummaryScreen
/// không nối actionLabel/onAction cho bất kỳ JourneyStepCard nào, xem
/// doc comment lớp đó) — không cần action để kiểm nội dung hiển thị,
/// và việc thiếu action ở đây khớp đúng những gì màn hình thật sự vẽ.
const _sampleStep = JourneyStep(
  order: 0,
  suggestion: TutorSuggestion(
    kind: TutorSuggestionKind.reviewDueCards,
    priority: TutorSuggestionPriority.high,
    relatedCount: 3,
  ),
);

/// Snapshot ĐẦY ĐỦ cả 4 phần — dùng để kiểm Sprint R2.2 vẽ đúng từng
/// khối, tái dùng đúng widget/hàm trình bày của tầng gốc.
SmartLearningSession _fullSession(DateTime date) {
  return SmartLearningSession(
    date: date,
    recommendations: const [
      LearningRecommendation(
        strategy: SessionStrategy.deepStudy,
        estimatedMinutes: 20,
        relatedStepCount: 1,
      ),
      LearningRecommendation(
        strategy: SessionStrategy.shortReview,
        estimatedMinutes: 10,
        relatedStepCount: 2,
      ),
    ],
    journey: LearningJourney(
      context: _emptyContext,
      todayPlan: DailyLearningPlan(date: date, steps: const [_sampleStep]),
      insights: const [_sampleInsight],
    ),
  );
}

/// Kế hoạch hôm nay RỖNG nhưng nhận định + phiên đề xuất CÓ nội dung —
/// dùng để kiểm mỗi khối tự xử lý rỗng ĐỘC LẬP (Sprint R2.2), không
/// phải toàn màn hình rỗng-hoặc-không như kiểm tra Sprint R2.1.
SmartLearningSession _sessionMissingPlan(DateTime date) {
  return SmartLearningSession(
    date: date,
    recommendations: const [
      LearningRecommendation(
        strategy: SessionStrategy.deepStudy,
        estimatedMinutes: 20,
        relatedStepCount: 1,
      ),
    ],
    journey: LearningJourney(
      context: _emptyContext,
      todayPlan: DailyLearningPlan(date: date, steps: const []),
      insights: const [_sampleInsight],
    ),
  );
}

/// Phiên đề xuất RỖNG nhưng nhận định + kế hoạch hôm nay CÓ nội dung —
/// đối xứng với [_sessionMissingPlan].
SmartLearningSession _sessionMissingRecommendations(DateTime date) {
  return SmartLearningSession(
    date: date,
    recommendations: const [],
    journey: LearningJourney(
      context: _emptyContext,
      todayPlan: DailyLearningPlan(date: date, steps: const [_sampleStep]),
      insights: const [_sampleInsight],
    ),
  );
}

Widget _wrapStudySummaryScreen(SmartLearningRepository repo) {
  final router = GoRouter(
    initialLocation: AppRoutes.studySummary,
    routes: [
      GoRoute(
        path: AppRoutes.studySummary,
        builder: (_, __) => const StudySummaryScreen(),
      ),
    ],
  );
  return ProviderScope(
    overrides: [smartLearningRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  group('Sprint R2.1 — StudySummaryScreen (nền tảng)', () {
    testWidgets('trạng thái loading -> hiện LoadingState đúng nhãn',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrapStudySummaryScreen(_NeverResolvingSmartLearningRepository()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.bySemanticsLabel('Đang tải tóm tắt học tập của bạn…'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets(
        'repository lỗi -> hiện SearchErrorState CÓ nút Thử lại (nối '
        'refresh từ Sprint R2.3 — xem nhóm "Sprint R2.3" bên dưới cho '
        'hành vi khi bấm nút)', (tester) async {
      final repo = _FakeSmartLearningRepository(
        _emptySession(DateTime(2026, 7, 31)),
        shouldThrow: true,
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'snapshot rỗng (không insight/kế hoạch/đề xuất nào) -> hiện '
        'EmptyStateBanner', (tester) async {
      final repo = _FakeSmartLearningRepository(
        _emptySession(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Chưa có gì để tóm tắt — hãy học một chút rồi quay lại đây!',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'snapshot có nội dung -> KHÔNG hiện Empty State, không lỗi '
        '(bài kiểm gốc Sprint R2.1 — xem nhóm "Sprint R2.2" bên dưới '
        'cho nội dung thật sự được vẽ ra sao)', (tester) async {
      final repo = _FakeSmartLearningRepository(
        _sessionWithContent(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Chưa có gì để tóm tắt — hãy học một chút rồi quay lại đây!',
        ),
        findsNothing,
      );
      expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('route /study-summary mở đúng StudySummaryScreen',
        (tester) async {
      final repo = _FakeSmartLearningRepository(
        _emptySession(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(find.byType(StudySummaryScreen), findsOneWidget);
      expect(AppRoutes.studySummary, '/study-summary');
    });
  });

  group('Sprint R2.2 — vẽ nội dung thật từ LearningSnapshot', () {
    testWidgets(
        'snapshot đầy đủ -> vẽ đủ 4 khối (context/insights/kế hoạch/'
        'phiên đề xuất), tái dùng đúng widget của từng tầng gốc',
        (tester) async {
      final repo = _FakeSmartLearningRepository(
        _fullSession(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      // 1) context — TutorHeader (TutorHomeScreen._TutorSummarySection).
      expect(find.byType(TutorHeader), findsOneWidget);
      expect(find.text('Tổng quan học tập'), findsOneWidget);

      // 2) insights — lưới TutorInsightCard (TutorHomeScreen._TutorInsightsSection).
      expect(find.text('Nhận định'), findsOneWidget);
      expect(find.byType(TutorInsightCard), findsOneWidget);

      // 3) dailyPlan — JourneyStepCard (LearningJourneyScreen._JourneyContent).
      expect(find.text('Kế hoạch hôm nay'), findsOneWidget);
      expect(find.byType(JourneyStepCard), findsOneWidget);

      // 4) smartSession — SessionSummaryCard (đề xuất đầu) +
      // RecommendationCard (đề xuất còn lại) — SmartLearningScreen._SmartLearningContent.
      expect(find.text('Phiên học đề xuất'), findsOneWidget);
      expect(find.byType(SessionSummaryCard), findsOneWidget);
      expect(find.byType(RecommendationCard), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'bước trong kế hoạch KHÔNG có nút hành động — màn này chỉ '
        'trình bày, không nối điều hướng (Sprint R2.2 mục 7/8)',
        (tester) async {
      final repo = _FakeSmartLearningRepository(
        _fullSession(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      final card = tester.widget<JourneyStepCard>(find.byType(JourneyStepCard));
      expect(card.actionLabel, isNull);
      expect(card.onAction, isNull);
    });

    testWidgets(
        'kế hoạch hôm nay rỗng nhưng nhận định + phiên đề xuất CÓ nội '
        'dung -> chỉ khối kế hoạch hiện Empty State (tái dùng đúng '
        'chuỗi learningJourneyEmpty), các khối khác vẫn vẽ thật',
        (tester) async {
      final repo = _FakeSmartLearningRepository(
        _sessionMissingPlan(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(
        find.text('Chưa có gì cho hôm nay — bạn đã theo kịp mọi thứ!'),
        findsOneWidget,
      );
      expect(find.byType(JourneyStepCard), findsNothing);
      expect(find.byType(TutorInsightCard), findsOneWidget);
      expect(find.byType(SessionSummaryCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'phiên đề xuất rỗng nhưng nhận định + kế hoạch CÓ nội dung -> '
        'chỉ khối phiên đề xuất hiện Empty State (tái dùng đúng chuỗi '
        'smartLearningEmpty), các khối khác vẫn vẽ thật', (tester) async {
      final repo = _FakeSmartLearningRepository(
        _sessionMissingRecommendations(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Hiện chưa cần phiên học thông minh nào — bạn đã theo kịp mọi thứ!',
        ),
        findsOneWidget,
      );
      expect(find.byType(SessionSummaryCard), findsNothing);
      expect(find.byType(RecommendationCard), findsNothing);
      expect(find.byType(TutorInsightCard), findsOneWidget);
      expect(find.byType(JourneyStepCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'tiêu đề từng khối là header semantics (khớp quy ước '
        'SectionHeader hiện có)', (tester) async {
      final handle = tester.ensureSemantics();
      final repo = _FakeSmartLearningRepository(
        _fullSession(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      final node = tester.getSemantics(find.text('Nhận định'));
      expect(node.flagsCollection.isHeader, isTrue);

      handle.dispose();
    });
  });

  group('Sprint R2.3 — làm mới (refresh)', () {
    testWidgets(
        'kéo để làm mới -> gọi lại getSmartLearningSession() (đúng 1 '
        'lượt gọi mới) và vẽ dữ liệu MỚI thay cho dữ liệu cũ', (tester) async {
      final repo = _SwappableSmartLearningRepository(
        _sessionMissingRecommendations(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(repo.callCount, 1);
      expect(find.byType(SessionSummaryCard), findsNothing);

      repo.setNextSession(_fullSession(DateTime(2026, 7, 31)));
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(repo.callCount, 2);
      expect(find.byType(SessionSummaryCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'kéo để làm mới với dữ liệu mới toàn rỗng -> chuyển đúng sang '
        'EmptyStateBanner của toàn màn hình', (tester) async {
      final repo = _SwappableSmartLearningRepository(
        _sessionWithContent(DateTime(2026, 7, 31)),
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Chưa có gì để tóm tắt — hãy học một chút rồi quay lại đây!',
        ),
        findsNothing,
      );

      repo.setNextSession(_emptySession(DateTime(2026, 7, 31)));
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(repo.callCount, 2);
      expect(
        find.text(
          'Chưa có gì để tóm tắt — hãy học một chút rồi quay lại đây!',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'bấm nút Thử lại sau khi lỗi -> gọi lại getSmartLearningSession() '
        'và vẽ nội dung thật khi lần gọi kế tiếp thành công (đúng '
        'invalidate smartLearningSessionProvider, KHÔNG phải '
        'learningSnapshotProvider — xem doc comment StudySummaryScreen)',
        (tester) async {
      final repo = _SwappableSmartLearningRepository(
        _fullSession(DateTime(2026, 7, 31)),
        failFirstCalls: 1,
      );
      await tester.pumpWidget(_wrapStudySummaryScreen(repo));
      await tester.pumpAndSettle();

      expect(repo.callCount, 1);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(repo.callCount, 2);
      expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
      expect(find.byType(SessionSummaryCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
