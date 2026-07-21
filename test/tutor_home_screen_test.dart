import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/database/app_database.dart';
import 'package:quran_companion/core/database/database_providers.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/ai_tutor/presentation/tutor_home_screen.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_header.dart';
import 'package:quran_companion/features/ai_tutor/presentation/widgets/tutor_suggestion_card.dart';
import 'package:quran_companion/features/flashcards/data/flashcard_repository_impl.dart';
import 'package:quran_companion/features/flashcards/domain/entities/flashcard_type.dart';
import 'package:quran_companion/features/flashcards/domain/entities/smart_deck_type.dart';
import 'package:quran_companion/features/learning/data/scheduler_repository_impl.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/domain/sm2_scheduling_algorithm.dart';
import 'package:quran_companion/features/lexicon/domain/entities/lexicon_entry.dart';
import 'package:quran_companion/features/stats/data/study_session_repository_impl.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cùng mẫu progress_dashboard_screen_test.dart (Sprint 14 Phase 2.1)
/// — TutorHomeScreen ghép NHIỀU repository/2 database bộ nhớ CÙNG LÚC
/// qua AITutorRepository -> AnalyticsRepository, cần y hệt kỷ luật
/// runAsync + vòng lặp chờ-và-bơm đã xác lập ở đó.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  late UserDatabase userDb;
  late AppDatabase appDb;
  late SharedPreferences prefs;

  setUp(() async {
    userDb = UserDatabase(NativeDatabase.memory());
    appDb = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await userDb.close();
    await appDb.close();
  });

  // 4 route đích của TutorAction (Sprint 15 Phase 3 mục 4) — dùng màn
  // hình GIẢ LẬP tối giản (chỉ 1 Text nhận dạng) thay vì màn hình
  // thật (ReviewSessionScreen/FlashcardBrowseScreen/SmartDeckScreen/
  // LearningSessionScreen) — cô lập test điều hướng của TutorHomeScreen
  // khỏi hành vi/dữ liệu riêng của 4 màn hình đó (KHÔNG liên quan tới
  // việc _executeAction có push ĐÚNG route hay không, đúng thứ cần
  // kiểm chứng ở phase này). go_router khớp theo path, nên vẫn xác
  // nhận đúng route + đúng payload (extra) được dùng.
  Widget wrap() {
    final router = GoRouter(
      initialLocation: AppRoutes.study,
      routes: [
        GoRoute(
          path: AppRoutes.study,
          builder: (_, __) => const StudyScreen(),
        ),
        GoRoute(
          path: AppRoutes.aiTutor,
          builder: (_, __) => const TutorHomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.reviewSession,
          builder: (_, __) => const Scaffold(body: Text('DEST_REVIEW_SESSION')),
        ),
        GoRoute(
          path: AppRoutes.flashcards,
          builder: (_, __) => const Scaffold(body: Text('DEST_FLASHCARDS')),
        ),
        GoRoute(
          path: AppRoutes.smartDeck,
          builder: (_, state) => Scaffold(
            body:
                Text('DEST_SMART_DECK:${(state.extra! as SmartDeckType).name}'),
          ),
        ),
        GoRoute(
          path: AppRoutes.learningSession,
          builder: (_, __) =>
              const Scaffold(body: Text('DEST_LEARNING_SESSION')),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userDatabaseProvider.overrideWithValue(userDb),
        appDatabaseProvider.overrideWithValue(appDb),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  // BUG THẬT ĐÃ TÌM RA (không phải hẹn giờ chưa đủ): tester.pump()
  // KHÔNG tham số không tiến đồng hồ hoạt ảnh giả lập — go_router push
  // 1 route mới bằng MaterialPage mặc định có hoạt ảnh trượt vào
  // (~300ms); nếu vòng lặp chỉ gọi pump() trơn, hoạt ảnh đó KHÔNG BAO
  // GIỜ hoàn tất dù đã trôi qua bao nhiêu thời gian THẬT — vị trí vẽ
  // của toàn màn hình (và mọi nút bên trong) bị kẹt lại giữa chừng
  // trượt, lệch hẳn ra ngoài khung nhìn dù dữ liệu đã tải xong. Truyền
  // ĐÚNG Duration khớp độ trễ thật vào pump() để đồng hồ hoạt ảnh giả
  // lập tiến cùng nhịp — đã xác nhận bằng debug thực tế (rect nút lệch
  // ~216px trước khi sửa, đúng vị trí sau khi sửa).
  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    const step = Duration(milliseconds: 200);
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(step);
      await tester.pump(step);
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
    }
  }

  Future<void> pumpAndWaitForData(WidgetTester tester) {
    return tester.runAsync(() async {
      await tester.pumpWidget(wrap());
      await tester.pump();
      await tester.tap(find.text('AI Tutor'));
      await tester.pump();
      await pumpUntilLoaded(tester);
    });
  }

  /// ListView vẫn dựng theo Sliver — chỉ build phần tử trong viewport
  /// + cacheExtent mặc định (đúng bài học Progress Dashboard, Sprint
  /// 14 Phase 2.2). _TutorInsightsSection nằm CUỐI danh sách, dưới
  /// khung nhìn 600px mặc định khi phần Suggestions phía trên đủ dài
  /// (>=2 gợi ý) — cuộn xuống trước khi kiểm tra nội dung của nó.
  Future<void> scrollToBottom(WidgetTester tester) {
    // find.byType(ListView) (không phải Scrollable) — Insights dựng
    // GridView bên trong, TỰ CÓ Scrollable riêng (dù shrinkWrap +
    // NeverScrollableScrollPhysics) một khi được build; nếu tìm theo
    // Scrollable, giữa chừng vòng lặp cuộn (Insights vừa được dựng)
    // sẽ có 2 kết quả, drag() báo lỗi "ambiguously found" (đã xác
    // nhận bằng thất bại thực tế ở Phase 2.2 trước đây). ListView chỉ
    // khớp ĐÚNG 1 — danh sách ngoài cùng của TutorHomeScreen.
    final scrollable = find.descendant(
      of: find.byType(TutorHomeScreen),
      matching: find.byType(ListView),
    );
    return tester.runAsync(() async {
      for (var i = 0; i < 10; i++) {
        await tester.drag(scrollable, const Offset(0, -600));
        await tester.pump();
      }
      await pumpUntilLoaded(tester);
    });
  }

  testWidgets(
      'StudyScreen -> chạm AI Tutor -> TutorHomeScreen, hiện đủ tổng '
      'quan/gợi ý/nhận định', (tester) async {
    await pumpAndWaitForData(tester);

    expect(find.byType(TutorHomeScreen), findsOneWidget);
    expect(find.text('Your overview'), findsOneWidget);
    // Chưa học/đọc gì -> cardsStudied=0, accuracy=0%. Giới hạn tìm
    // kiếm trong TutorHeader — "0" cũng xuất hiện ở thẻ Insights
    // (cardsStudiedSummary/achievementsUnlockedSummary), tìm không
    // giới hạn sẽ khớp nhiều nơi.
    expect(
      find.descendant(of: find.byType(TutorHeader), matching: find.text('0')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(TutorHeader), matching: find.text('0%')),
      findsOneWidget,
    );

    await _disposeTree(tester);
  });

  testWidgets(
      'Người dùng hoàn toàn mới -> gợi ý hoàn thành 2 mục tiêu Ngày '
      '(chưa có due/weak roots/forgotten/streak)', (tester) async {
    await pumpAndWaitForData(tester);

    expect(find.text('Reach your daily study goal'), findsOneWidget);
    expect(find.text('Reach your daily review goal'), findsOneWidget);
    // Chưa due, chưa weak roots, chưa forgotten, chưa streak.
    expect(find.text('Review your due cards'), findsNothing);
    expect(find.text('Strengthen your weak roots'), findsNothing);
    expect(find.text('Review frequently forgotten cards'), findsNothing);
    expect(find.text('Keep your streak alive'), findsNothing);

    await _disposeTree(tester);
  });

  testWidgets(
      'Insights hiện đủ 4 thẻ (Cards studied/Accuracy/Streak/Achievements)',
      (tester) async {
    await pumpAndWaitForData(tester);
    await scrollToBottom(tester);

    expect(find.text('Insights'), findsOneWidget);
    // "Cards studied"/"Accuracy"/"Current streak" cũng là nhãn 3 chip
    // trong TutorHeader (tổng quan), render CÙNG màn hình (không cần
    // cuộn — nội dung TutorHomeScreen đủ ngắn để nằm trong vùng dựng
    // sẵn ban đầu, khác ProgressDashboardScreen nhiều mục hơn) — nên
    // dùng findsWidgets (>=1) thay vì findsOneWidget cho 3 nhãn dùng
    // chung này. "Achievements unlocked" là nhãn DUY NHẤT của
    // Insights (không xuất hiện ở TutorHeader) -> findsOneWidget để
    // khẳng định chắc chắn Insights đã render.
    expect(find.text('Cards studied'), findsWidgets);
    expect(find.text('Accuracy'), findsWidgets);
    expect(find.text('Current streak'), findsWidgets);
    expect(find.text('Achievements unlocked'), findsOneWidget);

    await _disposeTree(tester);
  });

  group('Hành động điều hướng (Sprint 15 Phase 3)', () {
    String todayKey() {
      final now = DateTime.now();
      final y = now.year.toString().padLeft(4, '0');
      final m = now.month.toString().padLeft(2, '0');
      final d = now.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    /// Tái dùng ĐÚNG kịch bản seed đã chứng minh trong
    /// analytics_repository_impl_test.dart ("giải quyết đúng Lemma cho
    /// từng Flashcard...") — 2 lần ôn "again" liên tiếp sau khi tốt
    /// nghiệp -> vừa lapsed (frequentlyForgotten) vừa weak root cùng
    /// lúc, đủ để kiểm cả 2 hành động điều hướng từ 1 lần seed.
    Future<void> seedWeakRootsAndForgotten() async {
      await appDb.batch((b) {
        b.insertAll(appDb.roots, [const RootRow(id: 100, radicals: 'ك ت ب')]);
        b.insertAll(appDb.lemmas, [
          const LemmaRow(
            id: 1,
            arabic: 'كَتَبَ',
            occurrenceCount: 10,
            rootId: 100,
          ),
        ]);
      });
      final scheduler = SchedulerRepositoryImpl(
        userDb,
        const SM2SchedulingAlgorithm(),
        const ConsoleLogger(),
        newId: () => 'card-1',
        nowMs: () => DateTime.now().millisecondsSinceEpoch,
      );
      final flashcards = FlashcardRepositoryImpl(
        userDb,
        const ConsoleLogger(),
        newId: () => 'fc-1',
        nowMs: () => DateTime.now().millisecondsSinceEpoch,
      );
      await flashcards.addFlashcard(
        type: FlashcardType.lemma,
        lexiconEntryType: LexiconEntryType.lemma,
        lexiconEntryId: 1,
      );
      await scheduler.syncItemsForType(LearningItemType.lemma, [1]);
      final card =
          (await scheduler.watchAllCards(LearningItemType.lemma).first).single;
      await scheduler.applyReview(card.id, ReviewGrade.good);
      await scheduler.applyReview(card.id, ReviewGrade.again);
    }

    testWidgets(
        'Người dùng mới -> bấm "Continue learning" -> điều hướng tới '
        'AppRoutes.learningSession', (tester) async {
      await pumpAndWaitForData(tester);

      await tester.runAsync(() async {
        await tester.tap(find.text('Continue learning'));
        await tester.pump();
        await pumpUntilLoaded(tester);
      });

      // context.push GIỮ NGUYÊN màn hình gốc trong Navigator stack
      // (không thay thế/pop) — TutorHomeScreen vẫn còn trong cây, chỉ
      // bị che phía sau, đúng ngữ nghĩa "push" (khác "pushReplacement"),
      // nên KHÔNG kiểm tra findsNothing cho nó ở đây.
      expect(find.text('DEST_LEARNING_SESSION'), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets(
        'Có weak roots -> bấm "Open weak cards" -> điều hướng tới '
        'AppRoutes.smartDeck kèm ĐÚNG SmartDeckType.weakRoots', (tester) async {
      // seedWeakRootsAndForgotten() gọi Drift THẬT (appDb.batch,
      // scheduler.syncItemsForType, applyReview...) — PHẢI bọc trong
      // tester.runAsync() dù không tương tác widget nào, y hệt lý do
      // pumpAndWaitForData/pumpUntilLoaded ở trên: gọi trực tiếp
      // ngoài runAsync trong 1 testWidgets (vùng fake-async) khiến
      // Future thật KHÔNG BAO GIỜ hoàn tất -> treo vô thời hạn (đã
      // xác nhận bằng thất bại thực tế — điểm khác biệt với
      // analytics_repository_impl_test.dart, vốn dùng test() thường,
      // không chạy trong vùng fake-async của widget test).
      await tester.runAsync(seedWeakRootsAndForgotten);
      await pumpAndWaitForData(tester);

      await tester.runAsync(() async {
        // Seed này kích hoạt NHIỀU gợi ý cùng lúc (2 mục tiêu Ngày
        // chưa đạt + weakRoots + frequentlyForgotten) -> "Open weak
        // cards" bị đẩy xuống dưới khung nhìn 600px mặc định (khác
        // "Continue learning" ở test trước, ít gợi ý hơn nên vẫn nằm
        // trong khung nhìn ban đầu) — cuộn tới nó trước khi bấm, giống
        // hệt lý do scrollToText trong progress_dashboard_screen_test.dart.
        await tester.ensureVisible(find.text('Open weak cards'));
        await tester.pump();
        await tester.tap(find.text('Open weak cards'));
        await tester.pump();
        await pumpUntilLoaded(tester);
      });

      expect(find.text('DEST_SMART_DECK:weakRoots'), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets(
        'Có thẻ hay quên -> bấm "Open flashcards" -> điều hướng tới '
        'AppRoutes.flashcards', (tester) async {
      await tester.runAsync(seedWeakRootsAndForgotten);
      await pumpAndWaitForData(tester);

      await tester.runAsync(() async {
        // Cùng lý do "Open weak cards" ở trên — cuộn tới trước khi bấm.
        await tester.ensureVisible(find.text('Open flashcards'));
        await tester.pump();
        await tester.tap(find.text('Open flashcards'));
        await tester.pump();
        await pumpUntilLoaded(tester);
      });

      expect(find.text('DEST_FLASHCARDS'), findsOneWidget);

      await _disposeTree(tester);
    });

    testWidgets(
        'maintainStreak (chỉ khích lệ) -> thẻ gợi ý render nhưng '
        'KHÔNG có nút hành động nào (trạng thái vô hiệu)', (tester) async {
      final studySessions = StudySessionRepositoryImpl(
        userDb,
        const ConsoleLogger(),
        newId: () => 'session-1',
        nowMs: () => DateTime.now().millisecondsSinceEpoch,
      );
      // Cùng lý do với seedWeakRootsAndForgotten() ở trên — logSession
      // là Drift THẬT, phải bọc trong runAsync trong 1 testWidgets.
      await tester.runAsync(
        () => studySessions.logSession(
          date: todayKey(),
          surahId: 1,
          ayahFrom: 0,
          ayahTo: 5,
          durationSec: 300,
        ),
      );

      await pumpAndWaitForData(tester);

      final streakCard = find.ancestor(
        of: find.text('Keep your streak alive'),
        matching: find.byType(TutorSuggestionCard),
      );
      expect(streakCard, findsOneWidget);
      expect(
        find.descendant(of: streakCard, matching: find.byType(TextButton)),
        findsNothing,
      );

      await _disposeTree(tester);
    });
  });
}
