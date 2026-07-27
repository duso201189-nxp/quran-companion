import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_companion/core/storage/prefs_provider.dart';
import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/repositories/scheduler_repository.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/learning/presentation/review_session_screen.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/reading/reading_position_store.dart';
import 'package:quran_companion/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

SrsCard _card(String id, int ayahId) => SrsCard(
      id: id,
      itemType: LearningItemType.ayah,
      itemId: ayahId,
      easeFactor: 2.5,
      intervalDays: 0,
      repetitions: 0,
      dueDate: 0,
      state: SrsCardState.newCard,
      updatedAtMs: 0,
    );

/// Nội dung Ayah giả — chỉ getAyahsByIds được ReviewSessionScreen gọi
/// tới, cùng mẫu với _FakeQuranRepo trong active_khatm_card_test.dart.
class _FakeQuranRepo implements QuranRepository {
  final Map<int, AyahSearchResult> byId = {
    100: const AyahSearchResult(
      ayahId: 100,
      surahId: 2,
      ayahNumber: 5,
      surahNameLatin: 'Al-Baqarah',
      arabic: 'نص الآية الأولى',
      translation: 'Bản dịch Ayah thứ nhất',
    ),
    200: const AyahSearchResult(
      ayahId: 200,
      surahId: 3,
      ayahNumber: 15,
      surahNameLatin: 'Ali Imran',
      arabic: 'نص الآية الثانية',
      translation: 'Bản dịch Ayah thứ hai',
    ),
  };

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          if (byId[id] case final r?) r,
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

/// Danh sách thẻ đến hạn giả, điều khiển được qua [emitCards] — phát
/// snapshot hiện tại ngay khi subscribe rồi tiếp tục theo dõi các lần
/// emit sau, mô phỏng đúng ngữ nghĩa Drift .watch() thật.
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
    yield _cards.where((c) => c.itemType == itemType).toList();
    yield* _controller.stream
        .map((cards) => cards.where((c) => c.itemType == itemType).toList());
  }

  @override
  Future<void> applyReview(String cardId, ReviewGrade grade) async {
    appliedReviews.add((cardId: cardId, grade: grade));
    // Mô phỏng: thẻ vừa ôn có due_date tương lai -> rời danh sách
    // đến hạn (không cần SM2SchedulingAlgorithm thật cho test UI).
    _cards = [
      for (final c in _cards)
        if (c.id != cardId) c,
    ];
    _controller.add(_cards);
  }

  @override
  Future<void> syncWithReviewQueue(List<int> currentReviewAyahIds) async {}

  @override
  Future<void> syncItemsForType(
    LearningItemType itemType,
    List<int> currentItemIds,
  ) async {}
}

void main() {
  late _FakeSchedulerRepository fakeScheduler;
  late _FakeQuranRepo fakeQuran;
  late SharedPreferences prefs;

  setUp(() async {
    fakeScheduler = _FakeSchedulerRepository();
    fakeQuran = _FakeQuranRepo();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget wrap() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const ReviewSessionScreen(),
        ),
        GoRoute(
          path: '/read/:id',
          builder: (_, state) => Scaffold(
            body: Text('READ_SCREEN_${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        quranRepositoryProvider.overrideWithValue(fakeQuran),
        schedulerRepositoryProvider.overrideWithValue(fakeScheduler),
        // dueReviewCardsProvider tự watch schedulerSyncProvider để giữ
        // đồng bộ với Revision Queue (Phase 2) — trong test UI thuần
        // này không cần orchestration thật (không có UserDatabase),
        // nên bỏ qua bằng 1 stream trơ, không ảnh hưởng dữ liệu thẻ
        // (đến hoàn toàn từ schedulerRepositoryProvider ở trên).
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

  testWidgets('không có thẻ đến hạn -> hiện màn hình hoàn tất', (tester) async {
    fakeScheduler.emitCards(const []);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Session complete!'), findsOneWidget);
    expect(find.text('Again'), findsNothing);
  });

  testWidgets('có thẻ đến hạn -> hiện văn bản Ayah + bản dịch + 4 nút đánh giá',
      (tester) async {
    fakeScheduler.emitCards([_card('c1', 100)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('نص الآية الأولى'), findsOneWidget);
    expect(find.text('Bản dịch Ayah thứ nhất'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Session complete!'), findsNothing);
  });

  testWidgets(
      'bấm "Good" gọi applyReview đúng cardId + grade rồi tự chuyển '
      'sang thẻ tiếp theo (next-card transition)', (tester) async {
    fakeScheduler.emitCards([_card('c1', 100), _card('c2', 200)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    expect(find.text('نص الآية الأولى'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(fakeScheduler.appliedReviews, [
      (cardId: 'c1', grade: ReviewGrade.good),
    ]);
    expect(find.text('نص الآية الأولى'), findsNothing);
    expect(find.text('نص الآية الثانية'), findsOneWidget);
    expect(find.text('Bản dịch Ayah thứ hai'), findsOneWidget);
  });

  testWidgets('bấm "Again" gọi applyReview với đúng mức ReviewGrade.again',
      (tester) async {
    fakeScheduler.emitCards([_card('c1', 100)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Again'));
    await tester.pumpAndSettle();

    expect(fakeScheduler.appliedReviews, [
      (cardId: 'c1', grade: ReviewGrade.again),
    ]);
  });

  testWidgets(
      'ôn xong thẻ cuối cùng -> chuyển sang màn hình hoàn tất '
      '(completion state)', (tester) async {
    fakeScheduler.emitCards([_card('c1', 100)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    expect(fakeScheduler.appliedReviews, [
      (cardId: 'c1', grade: ReviewGrade.easy),
    ]);
    expect(find.text('Session complete!'), findsOneWidget);
  });

  testWidgets(
      'bấm "Open in Reading" lưu đúng vị trí (surah 2, ayahIndex 4) và '
      'điều hướng sang trang đọc qua openAyahInReadingScreen', (tester) async {
    fakeScheduler.emitCards([_card('c1', 100)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(prefs.getInt(ReadingPositionStore.posKey(2)), isNull);

    await tester.tap(find.text('Open in Reading'));
    await tester.pumpAndSettle();

    // ayahNumber 5 -> ayahIndex 4 (1-based hiển thị, 0-based lưu).
    expect(prefs.getInt(ReadingPositionStore.posKey(2)), 4);
    expect(find.text('READ_SCREEN_2'), findsOneWidget);
    // Chưa ôn -> applyReview không được gọi bởi hành động này.
    expect(fakeScheduler.appliedReviews, isEmpty);
  });
}
