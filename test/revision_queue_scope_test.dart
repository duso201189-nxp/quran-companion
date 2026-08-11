import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/data/user_content_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/study/data/surah_revision_target_providers.dart';
import 'package:quran_companion/features/study/presentation/revision_queue_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart' show flushPendingDriftTimers;

/// Ayah 1..7 = Al-Fatihah (Surah 1); 8..10 = Al-Baqarah (Surah 2).
AyahSearchResult _result(int ayahId) {
  final isFatihah = ayahId <= 7;
  return AyahSearchResult(
    ayahId: ayahId,
    surahId: isFatihah ? 1 : 2,
    ayahNumber: isFatihah ? ayahId : ayahId - 7,
    surahNameLatin: isFatihah ? 'Al-Fatihah' : 'Al-Baqarah',
    arabic: 'nội dung $ayahId',
    translation: 'dịch $ayahId',
  );
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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async =>
      [for (final id in ids) _result(id)];
}

/// Sprint 7.4 — phạm vi của Hàng đợi ôn tập (DR-2026-0023 mục 9).
Widget _app(
  UserDatabase db, {
  int? surahId,
  List<int> eligible = const [1, 2, 8],
  List<Override> extra = const [],
}) {
  return ProviderScope(
    overrides: [
      userDatabaseProvider.overrideWithValue(db),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      revisionEligibleAyahsProvider.overrideWith(
        (ref) => Stream.value([
          for (final id in eligible) (ayahId: id, savedAt: 0),
        ]),
      ),
      ...extra,
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RevisionQueueScreen(surahId: surahId),
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

void main() {
  _test('giới hạn theo Surah -> CHỈ Ayah của Surah đó hiện ra',
      (tester, db) async {
    await tester.pumpWidget(_app(db, surahId: 1));
    await tester.pumpAndSettle();

    expect(find.text('nội dung 1'), findsOneWidget);
    expect(find.text('nội dung 2'), findsOneWidget);
    // Ayah 8 thuộc Al-Baqarah -> không được lọt vào lần ôn gom này.
    expect(find.text('nội dung 8'), findsNothing);
  });

  _test('KHÔNG giới hạn -> hàng đợi đầy đủ giữ nguyên hành vi Sprint 9',
      (tester, db) async {
    await tester.pumpWidget(_app(db));
    await tester.pumpAndSettle();

    expect(find.text('nội dung 1'), findsOneWidget);
    expect(find.text('nội dung 2'), findsOneWidget);
    // Không lọc gì cả — Ayah của mọi Surah đều hiện.
    expect(find.text('nội dung 8'), findsOneWidget);
  });

  _test(
      'thành phần lần ôn gom do surahRevisionTargetProvider quyết định, '
      'KHÔNG phải một phép so surahId lặp lại trong màn hình',
      (tester, db) async {
    // Provider cố ý trả về TẬP CON (chỉ Ayah 2) của những Ayah thuộc
    // Surah 1. Nếu màn hình tự so `item.ayah.surahId == 1` như bản
    // trước bản sửa, Ayah 1 vẫn hiện và bài kiểm này đỏ.
    await tester.pumpWidget(
      _app(
        db,
        surahId: 1,
        extra: [
          surahRevisionTargetProvider(1).overrideWith((ref) async => [2]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('nội dung 2'), findsOneWidget);
    expect(find.text('nội dung 1'), findsNothing);
    expect(find.text('nội dung 8'), findsNothing);
  });

  _test('phạm vi rỗng -> trạng thái rỗng, không rơi về hàng đợi đầy đủ',
      (tester, db) async {
    await tester.pumpWidget(
      _app(
        db,
        surahId: 1,
        extra: [
          surahRevisionTargetProvider(1).overrideWith((ref) async => <int>[]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No ayahs need review yet.'), findsOneWidget);
    expect(find.text('nội dung 1'), findsNothing);
    expect(find.text('nội dung 8'), findsNothing);
  });
}
