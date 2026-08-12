import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/database/user/user_database.dart';
import 'package:quran_companion/core/database/user/user_database_providers.dart';
import 'package:quran_companion/core/logging/logger.dart';
import 'package:quran_companion/features/hifz/data/hifz_plan_repository_impl.dart';
import 'package:quran_companion/features/hifz/data/hifz_providers.dart';
import 'package:quran_companion/features/learning/data/scheduler_providers.dart';
import 'package:quran_companion/features/learning/domain/entities/srs_card.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';

/// Logger im lặng — cùng mẫu hifz_foundation_test.dart.
class _SilentLogger implements Logger {
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

/// Repo Qur'an giả tối giản — chỉ cần giải quyết Arabic/dịch cho vài
/// Ayah để currentHifzReviewItemProvider có nội dung hiển thị.
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
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => [
        for (final id in ids)
          AyahSearchResult(
            ayahId: id,
            surahId: 1,
            ayahNumber: id,
            surahNameLatin: 'Al-Fatihah',
            arabic: 'nội dung $id',
            translation: 'dịch $id',
          ),
      ];
}

/// Sprint 7.7b-i — currentHifzReviewItemProvider: đúng chuỗi
/// dueHifzCardsProvider -> hifzSchedulerRepositoryProvider ->
/// watchAllCards(LearningItemType.hifz), KHÔNG chạm
/// schedulerRepositoryProvider/dueReviewCardsProvider/
/// LearningItemType.ayah.
void main() {
  late UserDatabase db;
  late HifzPlanRepositoryImpl hifzRepo;
  var idCounter = 0;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        userDatabaseProvider.overrideWithValue(db),
        quranRepositoryProvider.overrideWithValue(_FakeQuranRepo()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    idCounter = 0;
    db = UserDatabase(NativeDatabase.memory());
    hifzRepo = HifzPlanRepositoryImpl(
      db,
      _SilentLogger(),
      newId: () => 'plan-${++idCounter}',
      nowMs: () => 1000,
    );
  });

  tearDown(() => db.close());

  test('không có thẻ Hifz nào đến hạn -> null', () async {
    final container = makeContainer();

    expect(await container.read(currentHifzReviewItemProvider.future), isNull);
  });

  test('có một thẻ Hifz đến hạn -> đúng mục, đúng loại thẻ', () async {
    await hifzRepo.createPlan(ayahFrom: 3, ayahTo: 3);
    final container = makeContainer();
    await container.read(hifzSchedulerSyncProvider.future);

    final item = await container.read(currentHifzReviewItemProvider.future);

    expect(item, isNotNull);
    expect(item!.card.itemId, 3);
    expect(
      item.card.itemType,
      LearningItemType.hifz,
      reason: 'Mục ôn phải đến từ thẻ HIFZ, không phải thẻ nào khác',
    );
    expect(item.ayah.ayahId, 3);
  });

  test(
      'Ayah có CẢ thẻ ayah (thường) lẫn thẻ hifz đến hạn -> provider chỉ '
      'chọn thẻ hifz, không bao giờ chọn thẻ ayah', () async {
    await hifzRepo.createPlan(ayahFrom: 5, ayahTo: 5);
    final container = makeContainer();
    await container.read(hifzSchedulerSyncProvider.future);

    // Cùng Ayah 5 cũng có thẻ ôn tập THƯỜNG đến hạn.
    await container
        .read(schedulerRepositoryProvider)
        .syncItemsForType(LearningItemType.ayah, [5]);

    final item = await container.read(currentHifzReviewItemProvider.future);

    expect(item, isNotNull);
    expect(item!.card.itemId, 5);
    expect(item.card.itemType, LearningItemType.hifz);
  });

  test(
      'CHỈ thẻ ayah đến hạn (không có kế hoạch Hifz nào) -> vẫn null, '
      'thẻ ayah không bao giờ lọt qua provider Hifz', () async {
    final container = makeContainer();

    await container
        .read(schedulerRepositoryProvider)
        .syncItemsForType(LearningItemType.ayah, [9]);

    expect(await container.read(currentHifzReviewItemProvider.future), isNull);
  });

  test(
      'nhiều thẻ Hifz đến hạn -> đi theo ĐÚNG thứ tự '
      'selectDueCardsOrdered đã có (không tự bịa thứ tự mới)', () async {
    await hifzRepo.createPlan(ayahFrom: 10, ayahTo: 12);
    final container = makeContainer();
    await container.read(hifzSchedulerSyncProvider.future);

    final allCards = await container
        .read(hifzSchedulerRepositoryProvider)
        .watchAllCards(LearningItemType.hifz)
        .first;
    final expectedFirst = selectDueCardsOrdered(allCards, DateTime.now()).first;

    final item = await container.read(currentHifzReviewItemProvider.future);

    expect(item, isNotNull);
    expect(item!.card.id, expectedFirst.id);
    expect(item.card.itemId, expectedFirst.itemId);
  });
}
