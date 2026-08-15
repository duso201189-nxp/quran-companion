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

/// Logger im lặng — cùng mẫu các test Hifz khác (7.7a/7.7b-i).
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

/// CÙNG khuôn `_FakeSchedulerRepository` của hifz_progress_screen_test.dart
/// (Sprint D6.4 thêm `_HifzOverallSummaryCard` — HifzPlansScreen giờ CŨNG
/// đọc `hifzSchedulerRepositoryProvider` qua `hifzOverallProgressProvider`,
/// không còn chỉ dùng `HifzPlanRepository` như trước): mỗi lần ôn/đồng bộ
/// qua Drift THẬT trong test widget dựng cả cây UI đã được xác nhận CHẬM/
/// không ổn định dưới `pumpAndSettle` — dùng fake, test tự đặt [emitCards]
/// trước khi bơm cây widget thay vì dựa vào Drift thật.
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

Widget _wrap(UserDatabase db, _FakeSchedulerRepository fakeScheduler) {
  final router = GoRouter(
    initialLocation: AppRoutes.hifzPlans,
    routes: [
      GoRoute(
        path: AppRoutes.hifzPlans,
        builder: (_, __) => const HifzPlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.hifzPlanForm,
        builder: (_, __) => const Scaffold(body: Text('HIFZ_FORM')),
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

/// Cùng vòng đời Drift-widget-test đã dùng ở boundary_revision_test/
/// revision_queue_scope_test: huỷ cây rồi xả Timer(0) TRƯỚC khi đóng
/// database qua tester.runAsync — addTearDown chạy quá muộn.
void _test(
  String description,
  Future<void> Function(
    WidgetTester tester,
    UserDatabase db,
    _FakeSchedulerRepository fakeScheduler,
  ) body,
) {
  testWidgets(description, (tester) async {
    final db = UserDatabase(NativeDatabase.memory());
    final fakeScheduler = _FakeSchedulerRepository();
    await body(tester, db, fakeScheduler);
    await flushPendingDriftTimers(tester);
    await tester.runAsync(db.close);
  });
}

void main() {
  _test('không có kế hoạch nào -> hiện trạng thái rỗng', (
    tester,
    db,
    fakeScheduler,
  ) async {
    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('No Hifz plans yet.'), findsOneWidget);
    // Không có kế hoạch active nào -> banner rỗng riêng của thẻ tổng
    // quan (Sprint D6.4), KHÔNG lẫn với banner "No Hifz plans yet."
    // ở trên (hai thông điệp khác nghĩa: không có kế hoạch NÀO vs.
    // không có kế hoạch ACTIVE nào).
    expect(
      find.text('No active Hifz plans right now.'),
      findsOneWidget,
    );
  });

  _test('kế hoạch active hiện đúng đoạn + nhãn trạng thái', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    fakeScheduler.emitCards([1, 2, 3].map(_newHifzCard).toList());

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–3'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  _test('kế hoạch paused hiện đúng nhãn trạng thái', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
  });

  _test('kế hoạch completed hiện đúng nhãn trạng thái', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.completed);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
  });

  _test(
      'nhiều kế hoạch, kể cả CHỒNG LẤN đoạn -> tất cả đều hiện, không bị '
      'coi là trùng lặp/lỗi', (tester, db, fakeScheduler) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 5);
    // Chồng lấn với kế hoạch trên (Ayah 3..7) — vẫn phải là một dòng
    // riêng, hợp lệ, không báo lỗi (quyết định 24, Sprint 7.7a).
    final overlapping = await repo.createPlan(ayahFrom: 3, ayahTo: 7);
    await repo.setStatus(overlapping, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–5'), findsOneWidget);
    expect(find.text('Al-Fatihah 3–7'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
  });

  _test('bấm "New plan" -> điều hướng tới form tạo kế hoạch', (
    tester,
    db,
    fakeScheduler,
  ) async {
    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New plan'));
    await tester.pumpAndSettle();

    expect(find.text('HIFZ_FORM'), findsOneWidget);
  });

  _test('menu Pause -> gọi đúng setStatus(paused), danh sách tự cập nhật', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    // find.byType(PopupMenuButton<...>) đòi khớp CHÍNH XÁC tham số kiểu —
    // _PlanAction là private nên không viết ra được ở đây. `is
    // PopupMenuButton` xét theo hiệp biến (Dart generics covariant),
    // khớp mọi tham số kiểu.
    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
    // Đọc lại bằng truy vấn một lần, KHÔNG qua watchAllPlans()/stream:
    // một stream watch còn treo sau tương tác PopupMenuButton khiến
    // UserDatabase.close() không bao giờ hoàn tất trong flutter test.
    final row = await (db.select(db.hifzPlans)..where((t) => t.id.equals(id)))
        .getSingle();
    expect(row.status, HifzPlanStatus.paused.toDbValue());
  });

  _test('menu Resume -> gọi đúng setStatus(active), danh sách tự cập nhật', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
  });

  _test(
      'menu Mark complete -> gọi đúng setStatus(completed), danh sách tự '
      'cập nhật', (tester, db, fakeScheduler) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
  });

  _test(
      'menu Delete -> xác nhận -> gọi deletePlan, kế hoạch biến mất khỏi '
      'danh sách hiện tại', (tester, db, fakeScheduler) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this plan?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–3'), findsNothing);
    expect(find.text('No Hifz plans yet.'), findsOneWidget);
    // deletePlan() là xoá mềm (deleted_at) — lọc như watchAllPlans().
    final remaining = await (db.select(db.hifzPlans)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    expect(remaining, isEmpty);
  });

  _test('menu Delete -> Cancel -> KHÔNG xoá, kế hoạch vẫn còn', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–3'), findsOneWidget);
    final remaining = await (db.select(db.hifzPlans)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    expect(remaining, hasLength(1));
  });

  // ---------------------------------------------------------------------
  // Sprint D6.4 — _HifzOverallSummaryCard (ảnh chụp Hifz tổng quan).
  // ---------------------------------------------------------------------

  _test(
      'không có kế hoạch active nào (chỉ paused) -> thẻ tổng quan hiện '
      'banner rỗng riêng, KHÔNG hiện lưới chỉ số', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('No active Hifz plans right now.'), findsOneWidget);
    expect(find.text('Overall Hifz snapshot'), findsNothing);
  });

  _test(
      'một kế hoạch active, đã đồng bộ thẻ -> thẻ tổng quan hiện đúng số '
      'kế hoạch/Ayah/đến hạn, ghi rõ đây là ảnh chụp hiện tại', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    fakeScheduler.emitCards([1, 2, 3].map(_newHifzCard).toList());

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.text('Overall Hifz snapshot'), findsOneWidget);
    expect(find.bySemanticsLabel('Active plans: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Ayahs planned: 3'), findsOneWidget);
    // 3 thẻ mới đều due_date=0 -> luôn đến hạn ngay.
    expect(find.bySemanticsLabel('Due now: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Reviewed: 0'), findsOneWidget);
    expect(
      find.text('This is a current snapshot, not a review history.'),
      findsOneWidget,
    );
  });

  _test(
      'hai kế hoạch active CHỒNG LẤN -> thẻ tổng quan đếm Ayah chồng lấn '
      'MỘT lần (KHÔNG cộng dồn ayahCount của từng kế hoạch)', (
    tester,
    db,
    fakeScheduler,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    // p1: 1..5 (5 Ayah), p2: 3..7 (5 Ayah) — chồng lấn 3..5.
    // Hợp (union) = 1..7 = 7 Ayah DUY NHẤT, KHÔNG phải 10.
    await repo.createPlan(ayahFrom: 1, ayahTo: 5);
    await repo.createPlan(ayahFrom: 3, ayahTo: 7);
    fakeScheduler.emitCards(
      [for (var ordinal = 1; ordinal <= 7; ordinal++) ordinal]
          .map(_newHifzCard)
          .toList(),
    );

    await tester.pumpWidget(_wrap(db, fakeScheduler));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Active plans: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Ayahs planned: 7'), findsOneWidget);
  });
}
