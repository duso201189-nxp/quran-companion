import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_companion/features/quran/presentation/surah_list_controller.dart';
import 'package:quran_companion/features/search/data/search_providers.dart';

/// Fake đếm số lần [searchAyahs] được gọi + trả về danh sách cố định
/// — đủ cho test provider wiring, không cần database thật (Sprint
/// R1.1, xem `docs/release/PHASE3_SPRINT_R1_DESIGN_REVIEW.md` mục 11).
/// Method không dùng tới `throw UnimplementedError()` (quy ước
/// `TESTING_GUIDE.md` §3.5) để gọi nhầm báo lỗi ngay thay vì trả mặc
/// định sai.
class _FakeQuranRepository implements QuranRepository {
  _FakeQuranRepository(this._results);

  final List<AyahSearchResult> _results;
  int searchCallCount = 0;
  String? lastQuery;

  @override
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int limit = 40,
  }) async {
    searchCallCount++;
    lastQuery = query;
    return _results;
  }

  @override
  Future<List<Surah>> getAllSurahs() => throw UnimplementedError();

  @override
  Future<Surah?> getSurahById(int id) => throw UnimplementedError();

  @override
  Future<List<TranslationSource>> getEnabledSources() =>
      throw UnimplementedError();

  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) =>
      throw UnimplementedError();

  @override
  Future<List<Reciter>> getEnabledReciters() => throw UnimplementedError();

  @override
  Future<String?> getMetaValue(String key) => throw UnimplementedError();

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) =>
      throw UnimplementedError();
}

const _sampleResult = AyahSearchResult(
  ayahId: 1,
  surahId: 1,
  ayahNumber: 1,
  surahNameLatin: 'Al-Fatihah',
  arabic: 'بسم الله الرحمن الرحيم',
  translation: 'In the name of Allah, the Most Gracious, the Most Merciful',
);

void main() {
  group('searchResultsProvider (Sprint R1.1 — nối engine FTS5 thật)', () {
    late _FakeQuranRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = _FakeQuranRepository([_sampleResult]);
      container = ProviderContainer(
        overrides: [quranRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);
    });

    test('query rỗng -> trả rỗng ngay, KHÔNG gọi searchAyahs', () async {
      final results = await container.read(searchResultsProvider.future);

      expect(results, isEmpty);
      expect(fakeRepo.searchCallCount, 0);
    });

    test('query dưới 2 ký tự -> trả rỗng ngay, KHÔNG gọi searchAyahs',
        () async {
      container.read(searchQueryProvider.notifier).state = 'a';
      final results = await container.read(searchResultsProvider.future);

      expect(results, isEmpty);
      expect(fakeRepo.searchCallCount, 0);
    });

    test('query đủ 2 ký tự trở lên -> gọi searchAyahs, trả đúng kết quả',
        () async {
      container.read(searchQueryProvider.notifier).state = 'mercy';
      final results = await container.read(searchResultsProvider.future);

      expect(results, [_sampleResult]);
      expect(fakeRepo.searchCallCount, 1);
      expect(fakeRepo.lastQuery, 'mercy');
    });

    test(
        'ĐỘC LẬP với surahSearchQueryProvider — ghi vào provider của '
        'SurahListScreen KHÔNG làm đổi searchResultsProvider của '
        'SearchScreen', () async {
      // Giữ searchResultsProvider sống qua await bằng container.listen
      // (mẫu chuẩn cho .autoDispose, xem TESTING_GUIDE.md §1.3).
      final sub = container.listen(searchResultsProvider, (_, __) {});
      addTearDown(sub.close);

      container.read(surahSearchQueryProvider.notifier).state = 'ar-rahman';
      await container.read(searchResultsProvider.future);

      expect(fakeRepo.searchCallCount, 0);
      expect(container.read(searchQueryProvider), '');
    });

    test(
        'Sprint R1.3 — gõ nhanh (đổi query liên tục, không đợi debounce '
        'giữa các bước): chỉ query CUỐI CÙNG thật sự gọi searchAyahs, '
        'các phiên bản build cũ (đã lỗi thời) không gọi gì', () async {
      final sub = container.listen(searchResultsProvider, (_, __) {});
      addTearDown(sub.close);

      // Mô phỏng gõ nhanh hơn 250ms/từ: 5 lần ghi liên tiếp, KHÔNG await
      // giữa các bước -> 5 bản build song song, mỗi bản tự chờ debounce
      // riêng, nhưng chỉ bản khớp giá trị CUỐI CÙNG mới qua được vòng
      // kiểm tra "query != ref.read(searchQueryProvider)".
      for (final partial in ['m', 'me', 'mer', 'merc', 'mercy']) {
        container.read(searchQueryProvider.notifier).state = partial;
      }

      final results = await container.read(searchResultsProvider.future);

      expect(results, [_sampleResult]);
      expect(fakeRepo.searchCallCount, 1);
      expect(fakeRepo.lastQuery, 'mercy');
    });
  });
}
