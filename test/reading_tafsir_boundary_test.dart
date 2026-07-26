import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/data/quran_providers.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_content.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_search_result.dart';
import 'package:quran_companion/features/quran/domain/entities/covering_text.dart';
import 'package:quran_companion/features/quran/domain/entities/reciter.dart';
import 'package:quran_companion/features/quran/domain/entities/surah.dart';
import 'package:quran_companion/features/quran/domain/entities/translation_source.dart';
import 'package:quran_companion/features/quran/domain/repositories/quran_repository.dart';

/// Sprint 30.2 — RANH GIỚI ĐỌC ở tầng provider.
///
/// Danh mục nguồn giữ NGUYÊN VẸN (mặt hàng Tafsir tương lai cần nó);
/// khung nhìn dành cho trang đọc thì lọc bỏ Tafsir. Cả hai dùng CHUNG
/// một lần gọi repository — đó là điều kiện "không thêm truy vấn".

const _translit = TranslationSource(
  id: 1,
  code: 'translit_latin',
  name: 'Phien am',
  language: 'en',
  type: SourceType.transliteration,
  displayOrder: 1,
);
const _vi = TranslationSource(
  id: 2,
  code: 'vi_main',
  name: 'Ban dich tieng Viet',
  language: 'vi',
  type: SourceType.translation,
  displayOrder: 2,
);
const _tafsir = TranslationSource(
  id: 3,
  code: 'tafsir_muyassar',
  name: 'Tafsir Al-Muyassar',
  language: 'ar',
  type: SourceType.tafsir,
  displayOrder: 3,
);

void main() {
  late _CountingRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = _CountingRepo();
    container = ProviderContainer(
      overrides: [quranRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  test('danh mục đầy đủ GIỮ Tafsir — mặt hàng tương lai cần nó', () async {
    final all = await container.read(translationSourcesProvider.future);

    expect(all.map((s) => s.code), [
      'translit_latin',
      'vi_main',
      'tafsir_muyassar',
    ]);
  });

  test('khung nhìn đọc LOẠI BỎ Tafsir', () async {
    final reading = await container.read(readingSourcesProvider.future);

    expect(reading.map((s) => s.code), ['translit_latin', 'vi_main']);
    expect(reading.every((s) => s.isReadingLayer), isTrue);
  });

  test(
      'hai khung nhìn dùng CHUNG một lần gọi repository — không thêm '
      'truy vấn nào cho ranh giới', () async {
    await container.read(translationSourcesProvider.future);
    await container.read(readingSourcesProvider.future);
    // Đọc lại nhiều lần: provider không autoDispose nên vẫn là một lần.
    await container.read(readingSourcesProvider.future);
    await container.read(translationSourcesProvider.future);

    expect(repo.getEnabledSourcesCalls, 1);
  });

  test('nguồn loại LẠ (bộ dữ liệu mới hơn mã) vẫn được coi là lớp đọc',
      () async {
    // `_sourceFromRow` ánh xạ chuỗi lạ -> translation, và bộ lọc SQL
    // loại trừ theo danh sách loại KHÔNG-đọc, nên hai bên nhất quán:
    // nguồn lạ hiển thị được thay vì biến mất im lặng.
    expect(kNonReadingSourceTypeCodes, ['tafsir']);
    expect(kSourceTypeByCode.keys.toSet(), {
      'translation',
      'transliteration',
      'tafsir',
    });
    expect(kReadingSourceTypes, {
      SourceType.transliteration,
      SourceType.translation,
    });
  });
}

/// Đếm số lần đường dữ liệu thật sự được gọi.
class _CountingRepo implements QuranRepository {
  int getEnabledSourcesCalls = 0;

  @override
  Future<List<TranslationSource>> getEnabledSources() async {
    getEnabledSourcesCalls++;
    return const [_translit, _vi, _tafsir];
  }

  @override
  Future<List<Surah>> getAllSurahs() async => const [];
  @override
  Future<Surah?> getSurahById(int id) async => null;
  @override
  Future<List<AyahContent>> getAyahsOfSurah(int surahId) async => const [];
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
  Future<List<CoveringText>> getTextsCoveringAyah({
    required int ayahId,
    required Set<SourceType> types,
  }) async =>
      const [];

  @override
  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids) async => const [];
}
