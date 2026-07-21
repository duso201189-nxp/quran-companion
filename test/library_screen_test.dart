import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/console_logger.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/library/presentation/library_screen.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/data/user_content_repository_impl.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repo giả: chỉ trả header cho ayah id = 1 (Al-Fatihah 1:1).
class _FakeQuranRepo implements QuranRepository {
  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          if (id == 1)
            const AyahSearchResult(
              ayahId: 1,
              surahId: 1,
              ayahNumber: 1,
              surahNameLatin: 'Al-Fatihah',
              arabic: 'نص عربي',
              translation: 'bản dịch',
            ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => const [];
  @override
  Future<Surah?> getSurahById(int id) async => null;
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
}

UserDatabase? _lastDb;

Future<Widget> _app(UserDatabase userDb, SharedPreferences sp) async {
  final router = GoRouter(
    initialLocation: '/library',
    routes: [
      GoRoute(path: '/library', builder: (_, __) => const LibraryScreen()),
      GoRoute(
        path: '/read/:id',
        builder: (context, state) => Scaffold(
          body: Text('READING ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      userDatabaseProvider.overrideWithValue(userDb),
      sharedPreferencesProvider.overrideWithValue(sp),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// Đóng UserDatabase ngay trong thân test (tránh Timer treo của Drift).
void _test(String description, Future<void> Function(WidgetTester) body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    final db = _lastDb;
    _lastDb = null;
    if (db != null) await tester.runAsync(db.close);
  });
}

Future<(UserDatabase, SharedPreferences)> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final db = UserDatabase(NativeDatabase.memory());
  _lastDb = db;
  return (db, sp);
}

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  _test('empty state khi chưa có bookmark', (tester) async {
    final (db, sp) = await _fresh();
    await tester.pumpWidget(await _app(db, sp));
    await tester.pumpAndSettle();

    // Bốn tab hiển thị.
    expect(find.text('Bookmarks'), findsOneWidget);
    expect(find.text('Highlights'), findsOneWidget);
    // Tab mặc định (Bookmarks) rỗng.
    expect(find.text('No bookmarked ayahs yet.'), findsOneWidget);
  });

  _test('bookmark hiển thị và chạm để nhảy tới Ayah', (tester) async {
    final (db, sp) = await _fresh();
    // Ghi 1 bookmark cho ayah id 1 vào DB người dùng.
    await UserContentRepositoryImpl(db, const ConsoleLogger())
        .toggleBookmark(1);

    await tester.pumpWidget(await _app(db, sp));
    await tester.pumpAndSettle();

    // Header hiển thị.
    expect(find.text('Al-Fatihah · 1:1'), findsOneWidget);

    // Chạm -> điều hướng tới trang đọc Surah 1.
    await tester.tap(find.text('Al-Fatihah · 1:1'));
    await tester.pumpAndSettle();
    expect(find.text('READING 1'), findsOneWidget);
  });

  _test('notes tab hiển thị ghi chú', (tester) async {
    final (db, sp) = await _fresh();
    await UserContentRepositoryImpl(db, const ConsoleLogger())
        .saveNote(1, 'ghi chú của tôi');

    await tester.pumpWidget(await _app(db, sp));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();

    expect(find.text('ghi chú của tôi'), findsOneWidget);
  });
}
