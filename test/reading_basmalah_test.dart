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

/// Repo giả cho một Surah id, mô phỏng ĐÚNG cách dữ liệu Uthmani lưu
/// Basmalah: nhúng vào đầu Ayah 1 (trừ Surah 9); Surah 1 = Basmalah
/// đứng riêng làm Ayah 1.
class _Repo implements QuranRepository {
  _Repo(this.surahId);

  final int surahId;

  static const _basmalah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  String get _ayah1Text {
    switch (surahId) {
      case 1:
        return _basmalah; // Basmalah CHÍNH là Ayah 1
      case 9:
        return 'بَرَآءَةٌ مِّنَ ٱللَّهِ'; // At-Tawbah: không Basmalah
      default:
        return '$_basmalah الٓمٓ'; // Basmalah nhúng đầu Ayah 1
    }
  }

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
            textUthmani: _ayah1Text,
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
    // Viewport cao để cả header (Basmalah) và thẻ Ayah 1 nằm trong
    // khung nhìn, không phải cuộn.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

  _test('Surah thường (2): ĐÚNG MỘT Basmalah (header), Ayah 1 = الٓمٓ',
      (tester) async {
    await tester.pumpWidget(await _app(2));
    await tester.pumpAndSettle();

    // Chỉ một Basmalah trên màn hình (header trang trí), KHÔNG lặp.
    expect(basmalah, findsOneWidget);
    // Thẻ Ayah 1 hiển thị phần còn lại (không kèm Basmalah).
    expect(find.textContaining('الٓمٓ'), findsOneWidget);
  });

  _test('Surah 9 (At-Tawbah): KHÔNG có Basmalah', (tester) async {
    await tester.pumpWidget(await _app(9));
    await tester.pumpAndSettle();
    expect(basmalah, findsNothing);
  });

  _test('Surah 1 (Al-Fatihah): ĐÚNG MỘT Basmalah (là Ayah 1, không header)',
      (tester) async {
    await tester.pumpWidget(await _app(1));
    await tester.pumpAndSettle();
    // Basmalah là Ayah 1 -> hiện đúng một lần trong thẻ Ayah, không
    // có bản trang trí trùng lặp ở header.
    expect(basmalah, findsOneWidget);
  });
}
