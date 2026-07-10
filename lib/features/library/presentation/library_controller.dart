import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quran/data/quran_providers.dart';
import '../../quran/data/user_content_providers.dart';
import '../../quran/domain/entities/ayah_search_result.dart';
import '../../quran/domain/repositories/quran_repository.dart';
import '../domain/library_item.dart';
import '../domain/library_kind.dart';

/// Danh sách "Thư viện của tôi" theo nhóm — realtime.
///
/// Ghép hai kho tách biệt: bảng người dùng (bookmark/favorite/note/
/// highlight, dạng stream) + header nội dung Ayah (content DB, đọc
/// theo id). Không join SQL được vì hai database riêng nên ghép ở
/// tầng Dart; cache header trong vòng đời provider để lần phát lại
/// (vd bật/tắt một bookmark) không truy vấn lại id đã biết.
///
/// autoDispose: màn hình được push/pop, giải phóng stream + cache.
final libraryItemsProvider = StreamProvider.autoDispose
    .family<List<LibraryItem>, LibraryKind>((ref, kind) {
  final userRepo = ref.watch(userContentRepositoryProvider);
  final quranRepo = ref.watch(quranRepositoryProvider);
  final headerCache = <int, AyahSearchResult>{};

  switch (kind) {
    case LibraryKind.bookmarks:
      return userRepo.watchAllBookmarks().asyncMap(
            (rows) => _buildItems(
              quranRepo,
              headerCache,
              [
                for (final r in rows)
                  (
                    ayahId: r.ayahId,
                    savedAt: r.savedAt,
                    note: null,
                    colors: const <String>{},
                  ),
              ],
            ),
          );
    case LibraryKind.favorites:
      return userRepo.watchAllFavorites().asyncMap(
            (rows) => _buildItems(
              quranRepo,
              headerCache,
              [
                for (final r in rows)
                  (
                    ayahId: r.ayahId,
                    savedAt: r.savedAt,
                    note: null,
                    colors: const <String>{},
                  ),
              ],
            ),
          );
    case LibraryKind.notes:
      return userRepo.watchAllNotes().asyncMap(
            (rows) => _buildItems(
              quranRepo,
              headerCache,
              [
                for (final r in rows)
                  (
                    ayahId: r.ayahId,
                    savedAt: r.savedAt,
                    note: r.note,
                    colors: const <String>{},
                  ),
              ],
            ),
          );
    case LibraryKind.highlights:
      return userRepo.watchAllHighlights().asyncMap(
            (rows) => _buildItems(
              quranRepo,
              headerCache,
              [
                for (final r in rows)
                  (
                    ayahId: r.ayahId,
                    savedAt: r.savedAt,
                    note: null,
                    colors: r.colors,
                  ),
              ],
            ),
          );
  }
});

/// Ghép các dòng thô (giữ nguyên thứ tự mới→cũ) với header Ayah;
/// bỏ qua id không có header (dữ liệu lệch, không crash).
Future<List<LibraryItem>> _buildItems(
  QuranRepository quranRepo,
  Map<int, AyahSearchResult> cache,
  List<({int ayahId, int savedAt, String? note, Set<String> colors})> raw,
) async {
  if (raw.isEmpty) return const [];

  final missing = <int>{
    for (final r in raw)
      if (!cache.containsKey(r.ayahId)) r.ayahId,
  }.toList();
  if (missing.isNotEmpty) {
    for (final h in await quranRepo.getAyahsByIds(missing)) {
      cache[h.ayahId] = h;
    }
  }

  return [
    for (final r in raw)
      if (cache[r.ayahId] case final header?)
        LibraryItem(
          ayah: header,
          savedAt: r.savedAt,
          note: r.note,
          highlightColors: r.colors,
        ),
  ];
}
