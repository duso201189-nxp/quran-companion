import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/ayah_audio_player.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fake_audio_player.dart';

/// Repo giả cho một Surah id tùy chọn, đúng 1 Ayah có văn bản KHÔNG
/// chứa "بِسْمِ" -> nhờ vậy phát hiện được Basmalah TRANG TRÍ (nếu có)
/// bằng cách tìm chuỗi "بِسْمِ".
class _Repo implements QuranRepository {
  _Repo(this.surahId);

  final int surahId;

  Surah get _surah => Surah(
        id: surahId,
        nameArabic: 'اسم',
        nameLatin: 'Name',
        nameVi: 'Ten',
        nameEn: 'Name',
        ayahCount: 1,
        revelationPlace: RevelationPlace.mecca,
        orderRevealed: 1,
      );

  @override
  Future<Surah?> getSurahById(int id) async => id == surahId ? _surah : null;

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int s) async => [
        AyahContent(
          ayah: Ayah(
            id: 1,
            surahId: surahId,
            ayahNumber: 1,
            textUthmani: 'نص عربي',
            juz: 1,
          ),
          texts: const {'vi_main': 'việt'},
        ),
      ];

  @override
  Future<List<Surah>> getAllSurahs() async => [_surah];
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

UserDatabase? _lastDb;

Future<Widget> _app(int surahId) async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final userDb = UserDatabase(NativeDatabase.memory());
  _lastDb = userDb;
  return ProviderScope(
    overrides: [
      quranRepositoryProvider.overrideWithValue(_Repo(surahId)),
      sharedPreferencesProvider.overrideWithValue(sp),
      ayahAudioPlayerProvider.overrideWithValue(FakeAyahAudioPlayer()),
      userDatabaseProvider.overrideWithValue(userDb),
    ],
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReadingScreen(surahId: surahId),
    ),
  );
}

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

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  final basmalah = find.textContaining('بِسْمِ');

  _test('Surah thường (2): hiển thị Basmalah trang trí', (tester) async {
    await tester.pumpWidget(await _app(2));
    await tester.pumpAndSettle();
    expect(basmalah, findsOneWidget);
  });

  _test('Surah 9 (At-Tawbah): KHÔNG có Basmalah', (tester) async {
    await tester.pumpWidget(await _app(9));
    await tester.pumpAndSettle();
    expect(basmalah, findsNothing);
  });

  _test('Surah 1 (Al-Fatihah): KHÔNG lặp Basmalah trang trí', (tester) async {
    await tester.pumpWidget(await _app(1));
    await tester.pumpAndSettle();
    // Ayah văn bản là 'نص عربي' (không chứa بِسْمِ) nên nếu thấy بِسْمِ
    // tức là bản trang trí bị thêm nhầm.
    expect(basmalah, findsNothing);
  });
}
