import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/hifz/data/hifz_plan_repository_impl.dart';
import 'package:quran_companion/features/hifz/data/hifz_providers.dart';
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';
import 'package:quran_companion/features/hifz/presentation/hifz_plans_screen.dart';
import 'package:quran_companion/features/hifz/presentation/hifz_progress_screen.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/repositories/scheduler_repository.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart' show flushPendingDriftTimers;

/// Logger im lặng — cùng mẫu các test Hifz khác.
class _SilentLogger implements Logger {
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

/// CÙNG khuôn `_RecordingSchedulerRepository` của
/// hifz_review_screen_test.dart: `syncItemsForType` là no-op có chủ
/// đích — test tự đặt [emitCards] trước khi bơm cây widget thay vì
/// dựa vào Drift THẬT (mỗi lần ôn/đồng bộ qua Drift trong test widget
/// dựng cả cây UI đã được xác nhận CHẬM/không ổn định dưới
/// `pumpAndSettle` giả lập đồng hồ — đây là lý do
/// hifz_review_screen_test.dart cũng KHÔNG dùng SchedulerRepositoryImpl
/// thật). `hifz_progress_provider_test.dart` đã kiểm phần tích hợp
/// Drift thật (ProviderContainer thuần, không dựng widget) — tệp này
/// chỉ kiểm TRÌNH BÀY, dữ liệu vào được kiểm soát trực tiếp.
class _FakeSchedulerRepository implements SchedulerRepository {
  final _controller = StreamController<List<SrsCard>>.broadcast();
  List<SrsCard> _cards = const [];

  void emitCards(List<SrsCard> cards) {
    _cards = cards;
    _controller.add(_cards);
  }

  @override
  Stream<List<SrsCard>> watchAllCards(LearningItemType itemType) async* {
    yield _cards.where((c) => c.itemType == itemType).toList();
    yield* _controller.stream
        .map((cards) => cards.where((c) => c.itemType == itemType).toList());
  }

  @override
  Future<void> applyReview(String cardId, ReviewGrade grade) async {}

  @override
  Future<void> syncWithReviewQueue(List<int> currentReviewAyahIds) async {}

  @override
  Future<void> syncItemsForType(
    LearningItemType itemType,
    List<int> currentItemIds,
  ) async {}
}

SrsCard _newHifzCard(int ayahId) => SrsCard(
      id: 'card-$ayahId',
      itemType: LearningItemType.hifz,
      itemId: ayahId,
      easeFactor: 2.5,
      intervalDays: 0,
      repetitions: 0,
      dueDate: 0,
      state: SrsCardState.newCard,
      updatedAtMs: 0,
    );

class _FakeQuranRepo implements QuranRepository {
  static const _fatihah = Surah(
    id: 1,
    nameArabic: 'الفاتحة',
    nameLatin: 'Al-Fatihah',
    nameVi: 'Khai Đề',
    nameEn: 'The Opening',
    ayahCount: 7,
    revelationPlace: RevelationPlace.mecca,
    orderRevealed: 5,
  );

  @override
  Future<Surah?> getSurahById(int id) async => id == 1 ? _fatihah : null;
  @override
  Future<List<Surah>> getAllSurahs() async => const [_fatihah];
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [];
  @override
  Future<List<TranslationSource>> getEnabledSources() async => const [];
  @override
  Future<List<Reciter>> getEnabledReciters() async => const [];
  @override
  Future<String?> getMetaValue(String key) async => null;
  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async =>
      const [];
  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}

Widget _wrap(
  UserDatabase db,
  _FakeSchedulerRepository fakeScheduler, {
  required String initialLocation,
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.hifzPlans,
        builder: (_, __) => const HifzPlansScreen(),
      ),
      GoRoute(
        path: '/hifz/progress/:id',
        builder: (context, state) => HifzProgressScreen(
          planId: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      userDatabaseProvider.overrideWithValue(db),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      hifzSchedulerRepositoryProvider.overrideWithValue(fakeScheduler),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// Cùng vòng đời Drift-widget-test đã dùng ở hifz_plans_screen_test.dart.
void _test(
  String description,
  Future<void> Function(
    WidgetTester tester,
    UserDatabase db,
    _FakeSchedulerRepository fakeScheduler,
  ) body,
) {
  testWidgets(description, (tester) async {
    // Nội dung màn hình tiến độ (đầu trang + lưới tổng quan + phân bố
    // trạng thái + nhịp độ ôn) cao hơn khung nhìn test mặc định
    // (800×600) — phóng to khung nhìn thay vì cuộn từng phần, để mọi
    // `find` bên dưới thấy được toàn bộ cây mà không cần biết trước
    // khoảng cách cuộn.
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Cùng mẫu search_error_state_test.dart — find.bySemanticsLabel
    // cần một SemanticsHandle đang hoạt động để cây semantics thực sự
    // được tính, không chỉ dựng cây widget. Giải phóng bằng gọi trực
    // tiếp cuối bài kiểm (không qua addTearDown) — đúng mẫu tệp trên,
    // vì framework tự kiểm "còn handle nào chưa dispose" trước khi
    // các addTearDown khác kịp chạy.
    final semanticsHandle = tester.ensureSemantics();

    final db = UserDatabase(NativeDatabase.memory());
    final fakeScheduler = _FakeSchedulerRepository();
    await body(tester, db, fakeScheduler);
    await flushPendingDriftTimers(tester);
    await tester.runAsync(db.close);
    semanticsHandle.dispose();
  });
}

void main() {
  _test('kế hoạch không tồn tại -> hiện thông báo không tìm thấy', (
    tester,
    db,
    fakeScheduler,
  ) async {
    await tester.pumpWidget(
      _wrap(db, fakeScheduler, initialLocation: '/hifz/progress/không-tồn-tại'),
    );
    await tester.pumpAndSettle();

    expect(find.text('This plan could not be found.'), findsOneWidget);
  });

  _test(
      'kế hoạch active mới tạo, chưa ôn lần nào -> hiện đúng đoạn, trạng '
      'thái, tổng quan và phân bố trạng thái mới', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    fakeScheduler.emitCards([1, 2, 3].map(_newHifzCard).toList());

    await tester.pumpWidget(
      _wrap(db, fakeScheduler, initialLocation: '/hifz/progress/$id'),
    );
    await tester.pumpAndSettle();

    // Đầu trang: đoạn + trạng thái vòng đời — tái sử dụng nhãn đã có
    // (hifzStatusActive), CÙNG cách HifzPlansScreen hiện.
    expect(find.text('Al-Fatihah 1–3'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    // Tổng quan: 3 Ayah, cả 3 đều mới (chưa ôn) nên đều đến hạn ngay
    // (due_date = 0, luôn <= hiện tại), 0 đã ôn, 0 đang ổn định.
    expect(find.bySemanticsLabel('Ayahs: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Stable: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Due now: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Reviewed: 0'), findsOneWidget);

    // Phân bố trạng thái: tái sử dụng NGUYÊN VẸN nhãn Flashcard đã có
    // (flashcardFilterNew = "New").
    expect(find.bySemanticsLabel('New: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Learning: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Review: 0'), findsOneWidget);
    expect(find.bySemanticsLabel('Lapsed: 0'), findsOneWidget);

    // Ghi chú trung thực: đủ 3/3 Ayah đã có lịch ôn, và đây là ảnh
    // chụp hiện tại — không phải lịch sử.
    expect(find.text('3/3 ayahs have a review schedule.'), findsOneWidget);
    expect(
      find.text('This is a current snapshot, not a review history.'),
      findsOneWidget,
    );

    // Chưa ôn lần nào -> phần Nhịp độ ôn hiện thông báo rỗng trung
    // thực, KHÔNG hiện số liệu ease/interval bịa ra từ giá trị mặc
    // định của thẻ mới.
    expect(
      find.text('No reviews yet. Start reviewing to see your pace.'),
      findsOneWidget,
    );
  });

  _test(
      'kế hoạch paused vẫn hiện đúng phân bố trạng thái — KHÔNG hiện '
      'trạng thái rỗng chỉ vì kế hoạch bị tạm dừng', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 2);
    await repo.setStatus(id, HifzPlanStatus.paused);
    fakeScheduler.emitCards([1, 2].map(_newHifzCard).toList());

    await tester.pumpWidget(
      _wrap(db, fakeScheduler, initialLocation: '/hifz/progress/$id'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.bySemanticsLabel('Ayahs: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('New: 2'), findsOneWidget);
  });

  _test(
      'từ danh sách kế hoạch, menu "View progress" -> điều hướng đúng '
      'tới màn hình tiến độ của kế hoạch đó',
      (tester, db, fakeScheduler) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    fakeScheduler.emitCards([1, 2, 3].map(_newHifzCard).toList());

    await tester.pumpWidget(
      _wrap(db, fakeScheduler, initialLocation: AppRoutes.hifzPlans),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View progress'));
    await tester.pumpAndSettle();

    expect(find.text('Hifz progress'), findsOneWidget);
    expect(find.text('Al-Fatihah 1–3'), findsOneWidget);
  });
}
