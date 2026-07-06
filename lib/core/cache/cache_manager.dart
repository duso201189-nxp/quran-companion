/// Tiến độ tải trước một Surah.
class PrefetchProgress {
  const PrefetchProgress({required this.done, required this.total});

  final int done;
  final int total;

  double get fraction => total == 0 ? 0 : done / total;
  bool get finished => done >= total;
}

/// Quản lý cache audio offline (thiết kế tại ARCHITECTURE.md §13).
///
/// Cây thư mục: audio/<reciterCode>/<sss><aaa>.mp3
abstract interface class CacheManager {
  Future<int> totalSizeBytes();

  Future<int> sizeOfReciterBytes(String reciterCode);

  Future<void> clearAll();

  Future<void> clearReciter(String reciterCode);

  /// File đã cache của một Ayah, null nếu chưa có — trình phát dùng
  /// để ưu tiên offline trước khi stream mạng.
  Future<Uri?> cachedAyahUri({
    required String reciterCode,
    required int surahId,
    required int ayahNumber,
  });

  /// Tải trước toàn bộ Ayah của một Surah. Dừng giữa chừng hoặc mất
  /// mạng: giữ phần đã tải, Ayah lỗi bỏ qua để tải lại lần sau.
  Stream<PrefetchProgress> prefetchSurah({
    required String reciterCode,
    required String urlTemplate,
    required int surahId,
    required int ayahCount,
  });
}
