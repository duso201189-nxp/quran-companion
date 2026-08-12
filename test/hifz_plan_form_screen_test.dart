import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/hifz/presentation/hifz_plan_form_screen.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart' show flushPendingDriftTimers;

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

/// Sprint 7.7b-ii — dựng HifzPlanFormScreen qua `Navigator.push` từ một
/// màn hình chủ, ĐÚNG như sản xuất thật (luôn tới từ
/// `context.push(AppRoutes.hifzPlanForm)`, xem HifzPlansScreen).
Widget _wrap(UserDatabase db) {
  return ProviderScope(
    overrides: [
      userDatabaseProvider.overrideWithValue(db),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HifzPlanFormScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

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

Future<void> _openForm(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _selectFatihah(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<Surah>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1. Al-Fatihah').last);
  await tester.pumpAndSettle();
}

void main() {
  _test(
      'Surah + khoảng Ayah hợp lệ -> tạo đúng kế hoạch với ordinal toàn '
      'cục đúng', (tester, db) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();
    await _openForm(tester);

    await _selectFatihah(tester);
    await tester.enterText(find.byType(TextField).first, '2');
    await tester.enterText(find.byType(TextField).last, '5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Đọc lại bằng truy vấn một lần, KHÔNG qua watchAllPlans()/stream:
    // một stream watch còn treo sau khi form pop khiến
    // UserDatabase.close() không bao giờ hoàn tất trong flutter test.
    final rows = await db.select(db.hifzPlans).get();
    expect(rows, hasLength(1));
    // Al-Fatihah chiếm ordinal 1..7 -> Ayah 2..5 là ordinal 2..5.
    expect(rows.single.ayahFrom, 2);
    expect(rows.single.ayahTo, 5);
    // Form tự đóng sau khi lưu, quay lại màn hình chủ.
    expect(find.text('open'), findsOneWidget);
  });

  _test('Ayah From < 1 -> báo lỗi, KHÔNG gọi repository', (tester, db) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();
    await _openForm(tester);

    await _selectFatihah(tester);
    await tester.enterText(find.byType(TextField).first, '0');
    await tester.enterText(find.byType(TextField).last, '3');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Must be 1 or greater'), findsOneWidget);
    expect(await db.select(db.hifzPlans).get(), isEmpty);
  });

  _test('Ayah To > số Ayah của Surah -> báo lỗi, KHÔNG gọi repository', (
    tester,
    db,
  ) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();
    await _openForm(tester);

    await _selectFatihah(tester);
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.enterText(find.byType(TextField).last, '8');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('This Surah only has 7 ayahs'), findsOneWidget);
    expect(await db.select(db.hifzPlans).get(), isEmpty);
  });

  _test('Ayah From > Ayah To -> báo lỗi, KHÔNG gọi repository', (
    tester,
    db,
  ) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();
    await _openForm(tester);

    await _selectFatihah(tester);
    await tester.enterText(find.byType(TextField).first, '5');
    await tester.enterText(find.byType(TextField).last, '2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('"From" must not be after "To"'), findsOneWidget);
    expect(await db.select(db.hifzPlans).get(), isEmpty);
  });

  _test('chưa chọn Surah -> báo lỗi, KHÔNG gọi repository', (
    tester,
    db,
  ) async {
    await tester.pumpWidget(_wrap(db));
    await tester.pumpAndSettle();
    await _openForm(tester);

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.enterText(find.byType(TextField).last, '3');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a Surah first'), findsOneWidget);
    expect(await db.select(db.hifzPlans).get(), isEmpty);
  });
}
