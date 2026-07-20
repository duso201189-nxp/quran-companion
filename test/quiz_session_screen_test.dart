import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/features/quiz/presentation/quiz_session_screen.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

/// 6 Surah giả, mỗi Surah 3 Ayah kèm bản dịch — đủ dữ liệu cho cả 4
/// loại câu hỏi, cùng mẫu với test/quiz_providers_test.dart.
class _FakeQuranRepo implements QuranRepository {
  final List<Surah> surahs = [
    for (var s = 1; s <= 6; s++)
      Surah(
        id: s,
        nameArabic: 'ع$s',
        nameLatin: 'Surah-$s',
        nameVi: 'Chương $s',
        nameEn: 'Chapter $s',
        ayahCount: 3,
        revelationPlace: RevelationPlace.mecca,
        orderRevealed: s,
      ),
  ];

  @override
  Future<List<Surah>> getAllSurahs() async => surahs;
  @override
  Future<Surah?> getSurahById(int id) async => null;

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => [
        for (var n = 1; n <= 3; n++)
          AyahContent(
            ayah: Ayah(
              id: surahId * 100 + n,
              surahId: surahId,
              ayahNumber: n,
              textUthmani: 'ayah-$surahId-$n',
            ),
            texts: {'vi_main': 'dich-$surahId-$n'},
          ),
      ];

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
      const [];
}

void main() {
  late UserDatabase db;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const QuizSessionScreen(),
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

  Future<void> answerOne(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('quiz_option_0')));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'phiên bắt đầu -> hiện câu hỏi 1/10 kèm đủ 4 lựa chọn '
      '(question generation)', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Question 1/10'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(ValueKey('quiz_option_$i')), findsOneWidget);
    }
  });

  testWidgets(
      'chọn 1 đáp án -> hiện phản hồi đúng/sai và chuyển sang câu 2/10 '
      '(scoring + next-question transition)', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quiz_option_0')));
    await tester.pump(); // hiện SnackBar

    final correctSnack = find.text('Correct!');
    final incorrectSnack = find.text('Not quite.');
    expect(
      correctSnack.evaluate().isNotEmpty || incorrectSnack.evaluate().isNotEmpty,
      isTrue,
      reason: 'phải hiện đúng 1 trong 2 phản hồi',
    );

    await tester.pumpAndSettle();
    expect(find.text('Question 2/10'), findsOneWidget);
    expect(find.text('Question 1/10'), findsNothing);
  });

  testWidgets(
      'trả lời hết 10 câu -> hiện màn hình kết quả (quiz completion)',
      (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      expect(find.text('Question ${i + 1}/10'), findsOneWidget);
      await answerOne(tester);
    }

    expect(find.textContaining('You scored'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Question 1/10'), findsNothing);
  });

  testWidgets('bấm Retry sau khi hoàn thành -> phiên mới bắt đầu lại từ '
      'câu 1/10', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      await answerOne(tester);
    }
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1/10'), findsOneWidget);
    expect(find.textContaining('You scored'), findsNothing);
  });
}
