import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_companion/app/app.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository giả tối giản dùng chung cho các test dựng cả app
/// (app_test, widget_test) — chỉ kiểm điều hướng/theme, không kiểm dữ
/// liệu; tránh mở database thật trong test harness.
class FakeQuranRepo implements QuranRepository {
  static const _surah = Surah(
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
  Future<List<Surah>> getAllSurahs() async => const [_surah];

  @override
  Future<Surah?> getSurahById(int id) async => id == 1 ? _surah : null;

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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          if (id == 1)
            const AyahSearchResult(
              ayahId: 1,
              surahId: 1,
              ayahNumber: 1,
              surahNameLatin: 'Al-Fatihah',
              arabic: 'بسم الله الرحمن الرحيم',
            ),
      ];
}

/// Tạo ProviderContainer với SharedPreferences giả cho unit test.
Future<ProviderContainer> makeContainer({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
  );
  return container;
}

/// Dựng app hoàn chỉnh cho widget test.
Future<Widget> makeApp({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      quranRepositoryProvider.overrideWithValue(FakeQuranRepo()),
      // Database bộ nhớ — tránh path_provider (kênh platform không có
      // trong môi trường test) khi các màn hình (vd Thống kê) chạm
      // tới userDatabaseProvider thật.
      userDatabaseProvider.overrideWithValue(
        UserDatabase(NativeDatabase.memory()),
      ),
    ],
    child: const QuranCompanionApp(),
  );
}
