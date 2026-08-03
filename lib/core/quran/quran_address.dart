/// Địa chỉ Qur'an phổ quát — MỨC SURAH VÀ AYAH (Sprint F0).
///
/// Cách gọi tên MỘT vị trí trong Qur'an, dùng chung cho mọi tính năng
/// (đọc, bookmark, highlight, audio, tìm kiếm, thống kê...) thay vì để
/// mỗi nơi tự chọn kiểu số riêng — xem `docs/adr/DR-2026-0017-universal-quran-address.md`
/// và `docs/knowledge/quran_index_conventions.md`.
///
/// # Vì sao tồn tại
///
/// Trước F0, "vị trí một Ayah" được biểu diễn bằng BA hệ số khác nhau
/// trong cùng một ứng dụng (xem `quran_index_conventions.md`), và việc
/// quy đổi giữa chúng nằm rải rác dưới dạng `+ 1` / `- 1` trần. Kiểu
/// này gom phép quy đổi về MỘT chỗ có tên và có test.
///
/// # THUẦN DART — cố ý
///
/// Tệp này KHÔNG import Flutter, Drift, Riverpod hay bất cứ gói nào
/// ngoài `dart:core`. Đó là ràng buộc thiết kế (DR-2026-0017 §3.5),
/// không phải sự tình cờ: một địa chỉ là một GIÁ TRỊ, không phải một
/// truy vấn — nó phải dựng/so sánh/tuần tự hoá được ở bất cứ đâu, kể
/// cả trong test không có database và không có widget.
///
/// # ĐÚNG DẠNG ≠ TỒN TẠI
///
/// Kiểu này bảo đảm địa chỉ ĐÚNG DẠNG (chỉ số ≥ 1, đúng cấp), KHÔNG
/// bảo đảm địa chỉ TỒN TẠI. `QuranAddress.ayah(2, 300)` đúng dạng và
/// không tồn tại (Al-Baqarah có 286 Ayah). Kiểm tra tồn tại cần tra
/// dữ liệu — đó là việc của tầng repository, không phải của giá trị
/// này. Tách như vậy là điều giữ cho tệp này thuần Dart.
///
/// # PHẠM VI F0 — cố ý nhỏ
///
/// CHỈ có mức Surah và Ayah. KHÔNG có mức Word/Segment, KHÔNG có
/// `Range`, KHÔNG có trục ấn bản (riwāyah/cách đếm Ayah). Cả ba đều
/// nằm trong DR-2026-0017 nhưng đều CHƯA có nơi dùng — theo đúng tiền
/// lệ `DR-2026-0006` mục D4 và `DR-2026-0007` mục D5 của dự án này
/// ("một provider không có nơi tiêu thụ là suy đoán"). Thêm sau KHÔNG
/// tốn di trú vì F0 không LƯU địa chỉ ở bất cứ đâu.
///
/// **Giả định đang có hiệu lực**: bản dựng hiện tại là Ḥafṣ ʿan ʿĀṣim,
/// đếm Ayah theo Kufi (6.236 Ayah). Khi nào có ấn bản thứ hai thật,
/// trục ấn bản mới được thêm — xem DR-2026-0017 §3.1 để biết vì sao
/// trục đó quan trọng (việc Basmalah có phải Ayah 1 hay không là thuộc
/// tính của CÁCH ĐẾM, không phải của Qur'an).
library;

/// Một vị trí trong Qur'an ở mức Surah hoặc Ayah.
///
/// Bất biến, so sánh theo giá trị, sắp xếp theo thứ tự đọc.
class QuranAddress implements Comparable<QuranAddress> {
  const QuranAddress._(this.surah, this.ayah);

  /// Địa chỉ mức Surah — cả Surah [surah] (1-based, 1..114).
  ///
  /// Ném [ArgumentError] nếu [surah] < 1. KHÔNG kiểm tra `<= 114`:
  /// đó là câu hỏi TỒN TẠI, cần dữ liệu (xem doc comment thư viện).
  factory QuranAddress.surah(int surah) {
    _requirePositive(surah, 'surah');
    return QuranAddress._(surah, null);
  }

  /// Địa chỉ mức Ayah — [ayahNumber] là SỐ Ayah **1-based**, tức đúng
  /// con số người đọc thấy trên màn hình và trong `Ayah.ayahNumber`.
  ///
  /// Nếu đang cầm CHỈ SỐ 0-based (vd. `AudioState.currentIndex`,
  /// `ReadingPositionStore`), dùng [QuranAddress.fromZeroBasedAyahIndex]
  /// thay vì tự cộng 1 tại nơi gọi.
  factory QuranAddress.ayah(int surah, int ayahNumber) {
    _requirePositive(surah, 'surah');
    _requirePositive(ayahNumber, 'ayahNumber');
    return QuranAddress._(surah, ayahNumber);
  }

  /// Dựng từ CHỈ SỐ Ayah **0-based** trong Surah.
  ///
  /// Đây là điểm quy đổi DUY NHẤT có tên giữa hai hệ số đang cùng tồn
  /// tại trong ứng dụng. Mọi nơi trước đây viết `index + 1` để lấy số
  /// Ayah nên gọi hàm này để ý định hiện rõ trong mã.
  ///
  /// Ném [ArgumentError] nếu [ayahIndex] âm.
  factory QuranAddress.fromZeroBasedAyahIndex(int surah, int ayahIndex) {
    _requirePositive(surah, 'surah');
    if (ayahIndex < 0) {
      throw ArgumentError.value(
        ayahIndex,
        'ayahIndex',
        'Chỉ số Ayah 0-based không được âm',
      );
    }
    return QuranAddress._(surah, ayahIndex + 1);
  }

  /// Số Surah, 1-based (1..114 với dữ liệu thật).
  final int surah;

  /// Số Ayah, **1-based**; `null` nghĩa là địa chỉ ở mức Surah.
  final int? ayah;

  /// Địa chỉ này chỉ tới cả một Surah (không cụ thể Ayah nào).
  bool get isSurahLevel => ayah == null;

  /// Địa chỉ này chỉ tới đúng một Ayah.
  bool get isAyahLevel => ayah != null;

  /// Chỉ số Ayah **0-based** tương ứng, hoặc `null` ở mức Surah.
  ///
  /// Chiều ngược của [QuranAddress.fromZeroBasedAyahIndex]. Dùng khi
  /// phải nói chuyện với API vẫn nhận 0-based (vd. `playSurah`,
  /// `ReadingPositionStore.save`) — để phép trừ 1 nằm ở đây, có test,
  /// thay vì nằm rải rác tại nơi gọi.
  int? get zeroBasedAyahIndex {
    final a = ayah;
    return a == null ? null : a - 1;
  }

  /// Địa chỉ này có CHỨA [other] hay không.
  ///
  /// Chứa = tiền tố: một Surah chứa mọi Ayah của nó; một Ayah chỉ chứa
  /// chính nó. Quan hệ này quyết định được HOÀN TOÀN từ giá trị, không
  /// cần tra dữ liệu — đó là tính chất khiến kiểu này dùng được ở mọi
  /// tầng (DR-2026-0017 §4.1).
  bool contains(QuranAddress other) {
    if (surah != other.surah) return false;
    final a = ayah;
    if (a == null) return true; // mức Surah chứa mọi Ayah trong nó
    return a == other.ayah;
  }

  /// Thứ tự ĐỌC: theo Surah trước, rồi theo Ayah; địa chỉ mức Surah
  /// đứng TRƯỚC mọi Ayah của chính Surah đó (nó "bắt đầu" ở đó).
  @override
  int compareTo(QuranAddress other) {
    final bySurah = surah.compareTo(other.surah);
    if (bySurah != 0) return bySurah;
    final a = ayah;
    final b = other.ayah;
    if (a == null && b == null) return 0;
    if (a == null) return -1; // mức Surah đứng trước mức Ayah
    if (b == null) return 1;
    return a.compareTo(b);
  }

  /// Dạng chuỗi chuẩn: `2` (mức Surah) hoặc `2:255` (mức Ayah).
  ///
  /// Đúng dạng người đọc đã quen viết, và trùng quy ước tham chiếu
  /// `surah:ayah` phổ biến — xem DR-2026-0017 §6. Đây là dạng DUY NHẤT
  /// được sinh ra; [tryParse] rộng rãi hơn khi đọc vào.
  @override
  String toString() => ayah == null ? '$surah' : '$surah:$ayah';

  /// Đọc lại từ chuỗi; trả `null` nếu không đúng dạng.
  ///
  /// Chấp nhận `2`, `2:255`, `2.255`, và khoảng trắng thừa hai đầu —
  /// "đọc vào rộng rãi, sinh ra nghiêm ngặt", để dạng chuỗi có thể mở
  /// rộng về sau mà không làm hỏng thứ đã sinh ra trước đó.
  static QuranAddress? tryParse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(RegExp(r'[:.]'));
    if (parts.length > 2) return null;
    final surah = int.tryParse(parts[0]);
    if (surah == null || surah < 1) return null;
    if (parts.length == 1) return QuranAddress._(surah, null);
    final ayah = int.tryParse(parts[1]);
    if (ayah == null || ayah < 1) return null;
    return QuranAddress._(surah, ayah);
  }

  @override
  bool operator ==(Object other) =>
      other is QuranAddress && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  static void _requirePositive(int value, String name) {
    if (value < 1) {
      throw ArgumentError.value(value, name, 'Địa chỉ Qur\'an là 1-based');
    }
  }
}
