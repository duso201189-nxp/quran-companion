import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/app/router.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/repositories/scheduler_repository.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning_session/presentation/learning_session_screen.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/study/presentation/study_screen.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nội dung Qur'an giả — phục vụ CẢ Review (getAyahsByIds) lẫn Quiz
/// (getAllSurahs/getAyahsOfSurah), cùng lược đồ id = surahId*100+n để
/// hai đường resolve luôn khớp nhau.
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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          AyahSearchResult(
            ayahId: id,
            surahId: id ~/ 100,
            ayahNumber: id % 100,
            surahNameLatin: 'Surah-${id ~/ 100}',
            arabic: 'ayah-${id ~/ 100}-${id % 100}',
            translation: 'dich-${id ~/ 100}-${id % 100}',
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
}

/// SchedulerRepository giả, điều khiển được — cùng mẫu
/// review_session_screen_test.dart.
class _FakeSchedulerRepository implements SchedulerRepository {
  final _controller = StreamController<List<SrsCard>>.broadcast();
  List<SrsCard> _cards = const [];
  final List<({String cardId, ReviewGrade grade})> appliedReviews = [];

  void emitCards(List<SrsCard> cards) {
    _cards = cards;
    _controller.add(_cards);
  }

  @override
  Stream<List<SrsCard>> watchAllCards(LearningItemType itemType) async* {
    yield _cards;
    yield* _controller.stream;
  }

  @override
  Future<void> applyReview(String cardId, ReviewGrade grade) async {
    appliedReviews.add((cardId: cardId, grade: grade));
    _cards = [
      for (final c in _cards)
        if (c.id != cardId) c,
    ];
    _controller.add(_cards);
  }

  @override
  Future<void> syncWithReviewQueue(List<int> currentReviewAyahIds) async {}
}

SrsCard _dueCard(int itemId) => SrsCard(
      id: 'card-$itemId',
      itemType: LearningItemType.ayah,
      itemId: itemId,
      easeFactor: 2.5,
      intervalDays: 0,
      repetitions: 0,
      dueDate: 0,
      state: SrsCardState.newCard,
    );

void main() {
  late UserDatabase db;
  late _FakeSchedulerRepository fakeScheduler;
  late SharedPreferences prefs;

  setUp(() async {
    db = UserDatabase(NativeDatabase.memory());
    fakeScheduler = _FakeSchedulerRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() => db.close());

  Widget wrap() {
    final router = GoRouter(
      initialLocation: AppRoutes.study,
      routes: [
        GoRoute(
          path: AppRoutes.study,
          builder: (_, __) => const StudyScreen(),
        ),
        GoRoute(
          path: AppRoutes.learningSession,
          builder: (_, __) => const LearningSessionScreen(),
        ),
        GoRoute(
          path: '/read/:id',
          builder: (_, state) => Scaffold(
            body: Text('READ_${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userDatabaseProvider.overrideWithValue(db),
        quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
        schedulerRepositoryProvider.overrideWithValue(fakeScheduler),
        schedulerSyncProvider.overrideWith((ref) => const Stream.empty()),
      ],
      child: MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  Future<void> answerOneQuizQuestion(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('quiz_option_0')));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Start Learning Session: nút chính hiện trên StudyScreen, '
      'bấm vào điều hướng sang Learning Session', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Start Learning Session'), findsOneWidget);

    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    // Không còn hiện StudyScreen (nút bắt đầu biến mất khỏi cây widget).
    expect(find.text('Start Learning Session'), findsNothing);
  });

  testWidgets('Review launched first khi có thẻ đến hạn', (tester) async {
    fakeScheduler.emitCards([_dueCard(101)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    expect(find.text('ayah-1-1'), findsOneWidget); // nội dung Review
    expect(find.text('Question 1/10'), findsNothing); // chưa phải Quiz
  });

  testWidgets(
      'Review completion advances correctly: ôn xong thẻ Review '
      'duy nhất -> tự chuyển sang Quiz, không cần thao tác điều hướng '
      'thủ công', (tester) async {
    fakeScheduler.emitCards([_dueCard(101)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    expect(find.text('ayah-1-1'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(fakeScheduler.appliedReviews, hasLength(1));
    expect(find.text('Question 1/10'), findsOneWidget); // Quiz launches next
  });

  testWidgets(
      'Quiz launches next khi không có thẻ Review nào đến hạn '
      'ngay từ đầu', (tester) async {
    fakeScheduler.emitCards(const []);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1/10'), findsOneWidget);
  });

  testWidgets(
      'Flashcards skipped: sau khi Quiz xong, chuyển thẳng sang '
      'Tóm tắt, không có màn hình Flashcard nào xuất hiện', (tester) async {
    fakeScheduler.emitCards(const []); // review trống -> quiz trước

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      await answerOneQuizQuestion(tester);
    }

    expect(find.text('Session Summary'), findsOneWidget);
    expect(find.text('Question 1/10'), findsNothing);
  });

  testWidgets(
      'Summary reached: hiện đúng số liệu tích luỹ (đã ôn 1 thẻ, '
      'điểm Quiz) và nút Done', (tester) async {
    fakeScheduler.emitCards([_dueCard(101)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Good')); // review xong -> quiz
    await tester.pumpAndSettle();

    for (var i = 0; i < 10; i++) {
      await answerOneQuizQuestion(tester);
    }

    expect(find.text('Session Summary'), findsOneWidget);
    expect(find.text('Reviewed 1 cards'), findsOneWidget);
    expect(find.textContaining('Quiz:'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets(
      'Navigation flow: StudyScreen không hiện lại trong suốt '
      'phiên; bấm Done ở Tóm tắt mới quay lại StudyScreen', (tester) async {
    fakeScheduler.emitCards(const []);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Learning Session'));
    await tester.pumpAndSettle();
    expect(find.text('Start Learning Session'), findsNothing);

    for (var i = 0; i < 10; i++) {
      await answerOneQuizQuestion(tester);
      // Trong suốt phiên, StudyScreen không bao giờ xuất hiện lại.
      expect(find.text('Start Learning Session'), findsNothing);
    }

    expect(find.text('Session Summary'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Start Learning Session'), findsOneWidget);
    expect(find.text('Session Summary'), findsNothing);
  });
}
