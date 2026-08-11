import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/data/user_content_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/study/data/boundary_completion_store.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nội dung giả tối thiểu — chỉ cần Al-Fatihah có tên để thẻ mời hiện
/// đúng tiêu đề.
class _FakeQuranRepo implements QuranRepository {
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
  Future<Surah?> getSurahById(int id) async => id == 1 ? _surah : null;
  @override
  Future<List<Surah>> getAllSurahs() async => const [_surah];
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

/// Sprint 7.4 — lời mời ôn gom trên màn hình Học (DR-2026-0023 mục
/// 9/10). Không dùng database: `revisionEligibleAyahsProvider` được
/// ghi đè thẳng, đúng tầng mà sprint này thật sự phụ thuộc.
Future<Widget> _app({
  Map<String, Object> prefs = const {},
  List<int> eligibleAyahIds = const [1, 2, 3],
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      revisionEligibleAyahsProvider.overrideWith(
        (ref) => Stream.value([
          for (final id in eligibleAyahIds) (ayahId: id, savedAt: 0),
        ]),
      ),
    ],
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StudyScreen(),
    ),
  );
}

void main() {
  testWidgets(
      'chưa đọc trọn Surah nào -> KHÔNG có lời mời nào trên màn '
      'hình Học', (tester) async {
    await tester.pumpWidget(await _app());
    await tester.pumpAndSettle();

    expect(find.textContaining('Revisit'), findsNothing);
    expect(find.text('Revise this Surah'), findsNothing);
  });

  testWidgets(
      'đã có dấu đọc trọn -> lời mời hiện, mời ôn chứ KHÔNG chúc '
      'mừng', (tester) async {
    await tester.pumpWidget(
      await _app(prefs: {BoundaryCompletionController.pendingKey: 1}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Revisit Al-Fatihah'), findsOneWidget);
    expect(find.text('Revise this Surah'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);

    // Worship First: không huy hiệu/điểm/chuỗi ngày/chúc mừng.
    for (final banned in [
      'Congratulations',
      'Well done',
      'Badge',
      'Streak',
      'Score',
      'points',
    ]) {
      expect(
        find.textContaining(banned),
        findsNothing,
        reason: 'Thẻ mời không được mang giọng phần thưởng: "$banned"',
      );
    }
  });

  testWidgets('lời mời nói đúng số Ayah đủ điều kiện của CHÍNH Surah đó',
      (tester) async {
    await tester.pumpWidget(
      await _app(
        prefs: {BoundaryCompletionController.pendingKey: 1},
        // 1..7 thuộc Al-Fatihah; 8 và 300 thuộc Surah khác -> không đếm.
        eligibleAyahIds: [1, 2, 7, 8, 300],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('3 of its ayahs'), findsOneWidget);
  });

  testWidgets(
      'Surah đã xong nhưng không còn Ayah nào cần ôn -> không mời '
      'vào một danh sách rỗng', (tester) async {
    await tester.pumpWidget(
      await _app(
        prefs: {BoundaryCompletionController.pendingKey: 1},
        eligibleAyahIds: const [],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Revisit'), findsNothing);
  });

  testWidgets('bấm "Để sau" -> lời mời biến mất ngay', (tester) async {
    await tester.pumpWidget(
      await _app(prefs: {BoundaryCompletionController.pendingKey: 1}),
    );
    await tester.pumpAndSettle();
    expect(find.text('Revisit Al-Fatihah'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('Revisit Al-Fatihah'), findsNothing);
    expect(find.text('Revise this Surah'), findsNothing);
  });

  testWidgets('tiêu đề lời mời có ngữ nghĩa header cho trình đọc màn hình',
      (tester) async {
    await tester.pumpWidget(
      await _app(prefs: {BoundaryCompletionController.pendingKey: 1}),
    );
    await tester.pumpAndSettle();

    final semantics = tester.getSemantics(
      find.text('Revisit Al-Fatihah'),
    );
    expect(semantics.flagsCollection.isHeader, isTrue);
  });
}
