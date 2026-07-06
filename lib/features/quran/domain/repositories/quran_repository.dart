import '../entities/ayah_content.dart';
import '../entities/ayah_search_result.dart';
import '../entities/reciter.dart';
import '../entities/surah.dart';
import '../entities/translation_source.dart';

/// Cổng truy cập nội dung Qur'an (nhóm A — chỉ đọc).
/// Domain chỉ biết interface này; Drift nằm sau lớp data.
abstract interface class QuranRepository {
  /// 114 Surah theo thứ tự Mushaf.
  Future<List<Surah>> getAllSurahs();

  Future<Surah?> getSurahById(int id);

  /// Các nguồn văn bản đang bật, theo display_order.
  Future<List<TranslationSource>> getEnabledSources();

  /// Toàn bộ Ayah của một Surah kèm văn bản từ mọi nguồn đang bật.
  /// Trả về rỗng nếu surahId không tồn tại.
  Future<List<AyahContent>> getAyahsOfSurah(int surahId);

  /// Các Qari đang bật, theo display_order.
  Future<List<Reciter>> getEnabledReciters();

  /// Đọc meta của file dữ liệu (data_version, built_at...).
  Future<String?> getMetaValue(String key);

  /// Tìm toàn văn trong nội dung (Ả Rập / phiên âm / Việt / Anh)
  /// qua chỉ mục FTS5 đóng gói sẵn. Kết quả theo thứ tự Mushaf.
  Future<List<AyahSearchResult>> searchAyahs(String query, {int limit});
}
