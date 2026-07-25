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

  /// Header (tên Surah + văn bản + bản dịch) cho danh sách id Ayah
  /// bất kỳ — dùng cho Thư viện của tôi. Bỏ qua id không tồn tại;
  /// trả về theo thứ tự id tăng dần (Mushaf).
  /// Văn bản của MỘT Ayah, giới hạn theo [types].
  ///
  /// Sprint 31.2 — mở rộng trừu tượng ĐÃ CÓ thay vì thêm
  /// `TafsirRepository`: trả về đúng hình dạng `Map<mã nguồn, văn bản>`
  /// mà `AyahContent.texts` đang dùng, nên không phát sinh kiểu dữ
  /// liệu mới. Nơi gọi nêu rõ loại nguồn mình cần, nên RANH GIỚI ĐỌC
  /// (Sprint 30.2) vẫn là một tham số tường minh chứ không phải quy
  /// ước ngầm.
  ///
  /// Chỉ nguồn đang bật. Metadata nguồn (tên, ngôn ngữ, thứ tự) lấy từ
  /// `getEnabledSources()` — không lặp lại ở đây.
  Future<Map<String, String>> getAyahTexts({
    required int ayahId,
    required Set<SourceType> types,
  });

  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids);
}
