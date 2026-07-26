import '../entities/ayah_content.dart';
import '../entities/ayah_search_result.dart';
import '../entities/covering_text.dart';
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
  /// Văn bản PHỦ một Ayah, giới hạn theo [types].
  ///
  /// Sprint 32.0 — "phủ", không phải "của". Đo trên dữ liệu thật: cả
  /// hai bộ Tafsir đã nhập đều gắn chú giải vào Ayah ĐẦU của một ĐOẠN
  /// nhiều câu, rồi để trống các câu tiếp theo:
  ///
  ///   Al-Muyassar : 5.278 mục  -> phủ 6.236/6.236 Ayah (nhịp 1..14)
  ///   Ibn Kathir  : 1.895 mục  -> phủ 6.231/6.236 Ayah (nhịp 1..20)
  ///
  /// Truy vấn khớp CHÍNH XÁC `ayah_id` vì thế bỏ sót 945 Ayah có chú
  /// giải thật. Quy tắc đúng: lấy mục GẦN NHẤT TRƯỚC ĐÓ trong CÙNG
  /// Surah — đoạn kéo dài tới ngay trước mục kế tiếp.
  ///
  /// Nguồn phủ đủ từng Ayah (mọi bản dịch — `validate()` bắt buộc)
  /// suy biến về đúng khớp chính xác, nên một quy tắc phục vụ cả hai
  /// hình dạng dữ liệu.
  Future<List<CoveringText>> getTextsCoveringAyah({
    required int ayahId,
    required Set<SourceType> types,
  });

  Future<List<AyahSearchResult>> getAyahsByIds(List<int> ids);
}
