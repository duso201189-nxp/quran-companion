import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/text_folding.dart';
import '../data/quran_providers.dart';
import '../domain/entities/ayah_search_result.dart';
import '../domain/entities/surah.dart';

/// Bộ lọc theo nơi mặc khải.
enum SurahFilter { all, mecca, madinah }

/// Nạp 114 Surah từ repository (AsyncValue: loading/error/data).
final surahListProvider =
    FutureProvider<List<Surah>>((ref) async {
  return ref.watch(quranRepositoryProvider).getAllSurahs();
});

/// Từ khóa tìm kiếm hiện tại.
final surahSearchQueryProvider = StateProvider<String>((ref) => '');

/// Bộ lọc hiện tại.
final surahFilterProvider =
    StateProvider<SurahFilter>((ref) => SurahFilter.all);

/// Danh sách sau khi áp tìm kiếm + lọc.
final filteredSurahsProvider = Provider<AsyncValue<List<Surah>>>((ref) {
  final surahs = ref.watch(surahListProvider);
  final query = ref.watch(surahSearchQueryProvider);
  final filter = ref.watch(surahFilterProvider);
  return surahs.whenData(
    (list) => filterSurahs(list, query: query, filter: filter),
  );
});

/// Tìm toàn văn trong nội dung Ayah (FTS5) — chạy khi query đủ dài,
/// debounce nhẹ để không truy vấn theo từng phím gõ.
final ayahSearchProvider =
    FutureProvider.autoDispose<List<AyahSearchResult>>((ref) async {
  final query = ref.watch(surahSearchQueryProvider);
  if (query.trim().length < 2) return const [];
  await Future<void>.delayed(const Duration(milliseconds: 250));
  // Query đã đổi trong lúc chờ -> phiên bản provider mới lo tiếp.
  if (query != ref.read(surahSearchQueryProvider)) return const [];
  return ref.watch(quranRepositoryProvider).searchAyahs(query);
});

/// Lọc + tìm kiếm — hàm thuần để unit test độc lập với UI/DB.
///
/// Khớp: số Surah, tên Latin/Việt/Anh (không phân biệt dấu),
/// hoặc tên Ả Rập (khớp nguyên văn).
List<Surah> filterSurahs(
  List<Surah> all, {
  required String query,
  required SurahFilter filter,
}) {
  final trimmed = query.trim();
  final folded = foldDiacritics(trimmed);
  final number = int.tryParse(trimmed);

  return all.where((s) {
    final placeOk = switch (filter) {
      SurahFilter.all => true,
      SurahFilter.mecca => s.revelationPlace == RevelationPlace.mecca,
      SurahFilter.madinah => s.revelationPlace == RevelationPlace.madinah,
    };
    if (!placeOk) return false;
    if (trimmed.isEmpty) return true;
    if (number != null) return s.id == number;
    return foldDiacritics(s.nameLatin).contains(folded) ||
        foldDiacritics(s.nameVi).contains(folded) ||
        foldDiacritics(s.nameEn).contains(folded) ||
        s.nameArabic.contains(trimmed);
  }).toList(growable: false);
}
