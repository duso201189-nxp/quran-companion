import '../../../core/quran/ayah_ordinal.dart';

/// Một phiên đọc có ĐỌC TRỌN một Surah hay không — Sprint 7.4
/// (Boundary-Triggered Revision Moments, DR-2026-0023 mục 5/6).
///
/// ## Vì sao thuần được, và vì sao phải thuần
///
/// Số Ayah của mỗi Surah nằm sẵn trong [AyahOrdinal.ayahCounts] — 114
/// số nguyên hằng, đã có test đối chiếu với database thật. Nhờ đó câu
/// hỏi "đã đọc hết chưa" trả lời được KHÔNG cần database nội dung
/// (nhóm A), không cần repository, không cần async. Đó cũng là lý do
/// Sprint 7.4 chỉ làm được ranh giới Surah: Juz không có bảng hằng
/// tương đương (xem DR-2026-0023 mục 2).
///
/// ## [maxAyahIndex] là XA NHẤT, không phải VỊ TRÍ CUỐI
///
/// Đầu vào PHẢI là chỉ số Ayah xa nhất từng hiện ra trong phiên, chứ
/// không phải `study_sessions.ayah_to`. Hai thứ đó khác nhau:
/// `ayah_to` lưu Ayah TRÊN CÙNG đang nhìn thấy (xem
/// `ReadingScreen._onPositionsChanged`, `reduce(min)`), nên nó luôn
/// báo THIẾU so với phần thực sự đã đọc — dùng nó ở đây thì một Surah
/// đọc hết vẫn không bao giờ tính là xong. DR-2026-0023 mục 4 ghi rõ
/// vì sao KHÔNG được đổi ngữ nghĩa cột đó để chữa việc này.
abstract final class SurahCompletion {
  /// Ngưỡng "một phiên đọc có thật" — dùng LẠI đúng ngưỡng
  /// `ReadingScreen.dispose()`/`StatsStore.addSeconds` đang dùng, không
  /// đặt ra ngưỡng thứ hai cho riêng ranh giới.
  static const int minSessionSeconds = 5;

  /// Chỉ số Ayah **0-based** cuối cùng của [surahId]; `null` nếu
  /// [surahId] nằm ngoài 1…114.
  static int? lastAyahIndexOf(int surahId) {
    if (surahId < 1 || surahId > AyahOrdinal.ayahCounts.length) return null;
    return AyahOrdinal.ayahCounts[surahId - 1] - 1;
  }

  /// Phiên đọc tới [maxAyahIndex] (0-based, xa nhất) có đọc trọn
  /// [surahId] không.
  ///
  /// `>=` chứ không phải `==`, cùng lý do phòng thủ với
  /// `KhatmCycle.completesJourney`: một chỉ số vượt miền (dữ liệu lệch,
  /// ấn bản đếm khác) phải được coi là đã xong thay vì kẹt vĩnh viễn ở
  /// "chưa xong".
  ///
  /// Đầu vào sai (Surah ngoài miền, chỉ số âm) -> `false`: không đoán,
  /// không ghi.
  static bool completed({required int surahId, required int maxAyahIndex}) {
    if (maxAyahIndex < 0) return false;
    final lastIndex = lastAyahIndexOf(surahId);
    if (lastIndex == null) return false;
    return maxAyahIndex >= lastIndex;
  }
}
