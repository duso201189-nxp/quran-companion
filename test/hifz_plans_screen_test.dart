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
import 'package:quran_companion/features/hifz/domain/entities/hifz_plan.dart';
import 'package:quran_companion/features/hifz/presentation/hifz_plans_screen.dart';
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

Widget _wrap(UserDatabase db) {
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
  Future<void> Function(WidgetTester tester, UserDatabase db) body,
) {
  testWidgets(description, (tester) async {
    final db = UserDatabase(NativeDatabase.memory());
    await body(tester, db);
    await flushPendingDriftTimers(tester);
    await tester.runAsync(db.close);
  });
}

void main() {
  _test('không có kế hoạch nào -> hiện trạng thái rỗng', (tester, db) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('No Hifz plans yet.'), findsOneWidget);
  });

  _test('kế hoạch active hiện đúng đoạn + nhãn trạng thái', (tester, db) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–3'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  _test('kế hoạch paused hiện đúng nhãn trạng thái', (tester, db) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Paused'), findsOneWidget);
  });

  _test('kế hoạch completed hiện đúng nhãn trạng thái', (tester, db) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.completed);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
  });

  _test(
      'nhiều kế hoạch, kể cả CHỒNG LẤN đoạn -> tất cả đều hiện, không bị '
      'coi là trùng lặp/lỗi', (tester, db) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 5);
    // Chồng lấn với kế hoạch trên (Ayah 3..7) — vẫn phải là một dòng
    // riêng, hợp lệ, không báo lỗi (quyết định 24, Sprint 7.7a).
    final overlapping = await repo.createPlan(ayahFrom: 3, ayahTo: 7);
    await repo.setStatus(overlapping, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    expect(find.text('Al-Fatihah 1–5'), findsOneWidget);
    expect(find.text('Al-Fatihah 3–7'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
  });

  _test('bấm "New plan" -> điều hướng tới form tạo kế hoạch', (
    tester,
    db,
  ) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New plan'));
    await tester.pumpAndSettle();

    expect(find.text('HIFZ_FORM'), findsOneWidget);
  });

  _test('menu Pause -> gọi đúng setStatus(paused), danh sách tự cập nhật', (
    tester,
    db,
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db));
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
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    final id = await repo.createPlan(ayahFrom: 1, ayahTo: 3);
    await repo.setStatus(id, HifzPlanStatus.paused);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
  });

  _test(
      'menu Mark complete -> gọi đúng setStatus(completed), danh sách tự '
      'cập nhật', (tester, db) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
  });

  _test(
      'menu Delete -> xác nhận -> gọi deletePlan, kế hoạch biến mất khỏi '
      'danh sách hiện tại', (tester, db) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db));
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
  ) async {
    final repo = HifzPlanRepositoryImpl(db, _SilentLogger());
    await repo.createPlan(ayahFrom: 1, ayahTo: 3);

    await tester.pumpWidget(_wrap(db));
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
}
