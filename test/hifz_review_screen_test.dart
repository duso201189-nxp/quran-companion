import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/hifz/data/hifz_plan_repository_impl.dart';
import 'package:quran_companion/features/hifz/data/hifz_providers.dart';
import 'package:quran_companion/features/hifz/presentation/hifz_review_screen.dart';
import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/learning/domain/repositories/scheduler_repository.dart';
import 'package:quran_companion/features/learning/domain/scheduling_algorithm.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/l10n/app_localizations.dart';

import 'fixtures/app_harness.dart' show flushPendingDriftTimers;

/// Sprint 7.7b-iii — HifzReviewScreen: đọc [currentHifzReviewItemProvider]/
/// chấm điểm qua [hifzSchedulerRepositoryProvider] — KHÔNG bao giờ
/// [dueReviewCardsProvider]/[schedulerRepositoryProvider] (bộ máy ôn
/// thường). Mỗi test đăng ký MỘT `_SpyCasualSchedulerRepository` riêng
/// cho `schedulerRepositoryProvider` để CHỨNG MINH trực tiếp — không chỉ
/// giả định — rằng màn hình này không bao giờ chạm tới engine ôn thường.

class _NoopLogger implements Logger {
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

SrsCard _hifzCard(String id, int ayahId) => SrsCard(
      id: id,
      itemType: LearningItemType.hifz,
      itemId: ayahId,
      easeFactor: 2.5,
      intervalDays: 0,
      repetitions: 0,
      dueDate: 0,
      state: SrsCardState.newCard,
      updatedAtMs: 0,
    );

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

  final Map<int, AyahSearchResult> byId = {
    2: const AyahSearchResult(
      ayahId: 2,
      surahId: 1,
      ayahNumber: 2,
      surahNameLatin: 'Al-Fatihah',
      arabic: 'نص الآية الأولى',
      translation: 'Bản dịch Ayah thứ nhất',
    ),
    3: const AyahSearchResult(
      ayahId: 3,
      surahId: 1,
      ayahNumber: 3,
      surahNameLatin: 'Al-Fatihah',
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
}

/// Cùng khuôn `_FakeSchedulerRepository` của review_session_screen_test.dart
/// — điều khiển được danh sách thẻ đến hạn qua [emitCards], ghi lại mọi
/// lần applyReview để test kiểm tra đúng cardId/grade.
class _RecordingSchedulerRepository implements SchedulerRepository {
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
  late _RecordingSchedulerRepository hifzFake;
  late _RecordingSchedulerRepository casualSpy;
  late _FakeQuranRepo fakeQuran;
  late UserDatabase db;

  setUp(() async {
    hifzFake = _RecordingSchedulerRepository();
    casualSpy = _RecordingSchedulerRepository();
    fakeQuran = _FakeQuranRepo();
    db = UserDatabase(NativeDatabase.memory());
    // Kế hoạch Hifz ĐANG HOẠT ĐỘNG bao trọn ordinal 2..3 (Al-Fatihah Ayah
    // 2..3) — dueHifzCardsProvider chỉ giữ thẻ nằm trong tập hợp active
    // này, đúng luật đã kiểm ở hifz_foundation_test.dart (không lặp lại
    // ở đây, chỉ cần MỘT kế hoạch cho thẻ giả có chỗ đứng).
    await HifzPlanRepositoryImpl(db, _NoopLogger())
        .createPlan(ayahFrom: 2, ayahTo: 3);
  });

  Widget wrap() {
    return ProviderScope(
      overrides: [
        userDatabaseProvider.overrideWithValue(db),
        quranRepositoryProvider.overrideWithValue(fakeQuran),
        hifzSchedulerRepositoryProvider.overrideWithValue(hifzFake),
        // Đăng ký RIÊNG cho schedulerRepositoryProvider (ôn thường) —
        // nếu HifzReviewScreen lỡ chạm tới bộ máy này, casualSpy sẽ ghi
        // nhận được, và test khẳng định nó luôn RỖNG.
        schedulerRepositoryProvider.overrideWithValue(casualSpy),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HifzReviewScreen(),
      ),
    );
  }

  Future<void> pumpAndClose(WidgetTester tester) async {
    await flushPendingDriftTimers(tester);
    await tester.runAsync(db.close);
  }

  testWidgets('không có thẻ Hifz đến hạn -> hiện màn hình hoàn tất',
      (tester) async {
    hifzFake.emitCards(const []);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('No Hifz review due'), findsOneWidget);
    expect(find.text('Again'), findsNothing);
    await pumpAndClose(tester);
  });

  testWidgets(
      'có một thẻ Hifz đến hạn -> hiện Ayah + bản dịch + 4 nút đánh giá',
      (tester) async {
    hifzFake.emitCards([_hifzCard('h1', 2)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('نص الآية الأولى'), findsOneWidget);
    expect(find.text('Bản dịch Ayah thứ nhất'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('No Hifz review due'), findsNothing);
    await pumpAndClose(tester);
  });

  testWidgets(
      'nhiều thẻ Hifz đến hạn -> chấm thẻ đầu rồi tự chuyển sang thẻ '
      'tiếp theo (next-card transition)', (tester) async {
    hifzFake.emitCards([_hifzCard('h1', 2), _hifzCard('h2', 3)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    expect(find.text('نص الآية الأولى'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(find.text('نص الآية الأولى'), findsNothing);
    expect(find.text('نص الآية الثانية'), findsOneWidget);
    expect(find.text('Bản dịch Ayah thứ hai'), findsOneWidget);
    await pumpAndClose(tester);
  });

  testWidgets(
      'chấm điểm gọi ĐÚNG cardId + grade qua hifzSchedulerRepositoryProvider',
      (tester) async {
    hifzFake.emitCards([_hifzCard('h1', 2)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Again'));
    await tester.pumpAndSettle();

    expect(hifzFake.appliedReviews, [
      (cardId: 'h1', grade: ReviewGrade.again),
    ]);
    await pumpAndClose(tester);
  });

  testWidgets(
      'chấm điểm KHÔNG BAO GIỜ gọi schedulerRepositoryProvider (bộ máy ôn '
      'thường) -> chứng minh cách ly loại thẻ', (tester) async {
    hifzFake.emitCards([_hifzCard('h1', 2)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(hifzFake.appliedReviews, hasLength(1));
    expect(casualSpy.appliedReviews, isEmpty);
    await pumpAndClose(tester);
  });

  testWidgets(
      'thẻ item_type=ayah trên casualSpy KHÔNG BAO GIỜ lọt vào màn hình '
      'ôn Hifz', (tester) async {
    // casualSpy vẫn có thể phát thẻ 'ayah' (mô phỏng ôn thường đang có
    // thẻ đến hạn song song) — HifzReviewScreen không đọc nguồn này nên
    // nội dung của nó không bao giờ xuất hiện ở đây.
    casualSpy.emitCards([
      const SrsCard(
        id: 'ayah-1',
        itemType: LearningItemType.ayah,
        itemId: 2,
        easeFactor: 2.5,
        intervalDays: 0,
        repetitions: 0,
        dueDate: 0,
        state: SrsCardState.newCard,
        updatedAtMs: 0,
      ),
    ]);
    hifzFake.emitCards([_hifzCard('h1', 3)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Thẻ Hifz (Ayah 3) hiện đúng; casualSpy chưa từng bị applyReview gọi.
    expect(find.text('نص الآية الثانية'), findsOneWidget);
    expect(casualSpy.appliedReviews, isEmpty);
    await pumpAndClose(tester);
  });

  testWidgets('ôn xong thẻ Hifz cuối cùng -> chuyển sang màn hình hoàn tất',
      (tester) async {
    hifzFake.emitCards([_hifzCard('h1', 2)]);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    expect(hifzFake.appliedReviews, [
      (cardId: 'h1', grade: ReviewGrade.easy),
    ]);
    expect(find.text('No Hifz review due'), findsOneWidget);
    await pumpAndClose(tester);
  });
}
