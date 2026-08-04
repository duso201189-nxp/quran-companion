import 'quran_address.dart';

/// Quy đổi giữa **số thứ tự Ayah trong toàn bộ Mushaf** và
/// [QuranAddress] — Sprint SF2 (Tier 0).
///
/// ## Cái được quy đổi là gì
///
/// Cột `ayah_id` trong database KHÔNG phải một khoá thay thế ngẫu
/// nhiên: đo trên chính `assets/database/quran.sqlite` cho thấy nó
/// đúng bằng thứ tự chạy của Ayah theo Mushaf —
/// `id == ROW_NUMBER() OVER (ORDER BY surah_id, ayah_number)`, dày đặc
/// từ 1 tới 6236, không đứt quãng.
///
/// Vì thế tệp này gọi nó là **ordinal** chứ không phải "id". Gọi là id
/// sẽ giữ mãi cái hiểu nhầm rằng nó là một con số tuỳ tiện của lưu trữ;
/// nó không phải — nó là một địa chỉ, chỉ viết bằng một hệ khác.
///
/// ## Vì sao thuần được
///
/// Phép quy đổi chỉ cần [ayahCounts] — **114 số nguyên** — chứ không
/// cần bảng `ayahs` 6236 dòng. Nhờ đó nó là hàm thuần, đồng bộ, không
/// cần handle database: các repository sau này không phải kéo database
/// nội dung vào chỉ để gọi tên dữ liệu của chính mình.
///
/// ## Vì sao trả `null` thay vì ném
///
/// `QuranAddress.ayah()` NÉM `ArgumentError` với đầu vào sai, và giá
/// trị `ayah_id` đã lưu thì **không có ràng buộc toàn vẹn nào** — không
/// khoá ngoại, không CHECK, và không thể có, vì database người dùng và
/// database nội dung là hai tệp SQLite riêng. Một dòng hỏng vốn đang im
/// lặng sẽ thành một lần crash nếu quy đổi thẳng qua hàm dựng.
///
/// Nên mọi lối vào ở đây là `tryFrom…`/`tryTo…` trả `null`, cùng tinh
/// thần với [QuranAddress.tryParse].
///
/// ## ⚠️ Ranh giới: ordinal gắn với ẤN BẢN
///
/// [ayahCounts] là cách đếm Ayah của ấn bản đang ship (Kufi/Hafs). Một
/// ấn bản đếm khác sẽ làm mọi `ayah_id` đã lưu trỏ **lặng lẽ sang Ayah
/// khác** — sai mà không có lỗi nào bật ra. Quy đổi ở đây không chống
/// được điều đó, và [QuranAddress] cũng không: địa chỉ cũng gắn ấn bản.
/// Xem `docs/release/PHASE4_SF1V_IDENTIFIER_MAPPING_VERIFICATION.md`
/// mục R1/E9.
abstract final class AyahOrdinal {
  /// Số Ayah của từng Surah, theo thứ tự Surah 1…114.
  ///
  /// Trích thẳng từ `surahs.ayah_count` của asset đang ship, không gõ
  /// tay. Có test đối chiếu lại với database thật để bảng hằng này
  /// không bao giờ trôi khỏi dữ liệu.
  static const List<int> ayahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, // 1-10
    123, 111, 43, 52, 99, 128, 111, 110, 98, 135, // 11-20
    112, 78, 118, 64, 77, 227, 93, 88, 69, 60, // 21-30
    34, 30, 73, 54, 45, 83, 182, 88, 75, 85, // 31-40
    54, 53, 89, 59, 37, 35, 38, 29, 18, 45, // 41-50
    60, 49, 62, 55, 78, 96, 29, 22, 24, 13, // 51-60
    14, 11, 11, 18, 12, 12, 30, 52, 52, 44, // 61-70
    28, 28, 20, 56, 40, 31, 50, 40, 46, 42, // 71-80
    29, 19, 36, 25, 22, 17, 19, 26, 30, 20, // 81-90
    15, 21, 11, 8, 8, 19, 5, 8, 8, 11, // 91-100
    11, 8, 3, 9, 5, 4, 7, 3, 6, 3, // 101-110
    5, 4, 5, 6, // 111-114
  ];

  /// Tổng số Ayah — cận trên của miền ordinal (miền là 1…[totalAyahs]).
  static const int totalAyahs = 6236;

  /// Ordinal -> địa chỉ mức Ayah. `null` nếu nằm ngoài 1…[totalAyahs].
  static QuranAddress? tryFromOrdinal(int ordinal) {
    if (ordinal < 1 || ordinal > totalAyahs) return null;

    // Trừ dần qua từng Surah. Vòng lặp chắc chắn dừng trong 114 bước
    // vì cận trên đã được chặn ở trên — không có nhánh "không tới
    // được" nào phải viết thêm.
    var remaining = ordinal;
    var surah = 1;
    while (remaining > ayahCounts[surah - 1]) {
      remaining -= ayahCounts[surah - 1];
      surah++;
    }
    return QuranAddress.ayah(surah, remaining);
  }

  /// Địa chỉ -> ordinal. `null` khi địa chỉ không chỉ đúng một Ayah có
  /// thật của ấn bản này.
  ///
  /// Ba trường hợp trả `null`, và cả ba đều có nghĩa riêng:
  /// - **mức Surah** (`2`): một Surah không phải một Ayah, nên nó không
  ///   có ordinal. KHÔNG trả về Ayah đầu của Surah — đó là đổi ngữ
  ///   nghĩa một cách lặng lẽ, đúng loại lỗi Sprint BM4 vừa bắt được.
  /// - **Surah > 114**: `QuranAddress` cho phép dựng địa chỉ đúng dạng
  ///   mà không tồn tại (`QuranAddress.surah(999)`), nên nhánh này có
  ///   thật.
  /// - **số Ayah vượt số Ayah của Surah đó** (vd. `1:8`).
  ///
  /// Không kiểm `surah < 1` hay `ayah < 1`: hàm dựng của
  /// [QuranAddress] đã chặn, nên ở đây là nhánh chết.
  static int? tryToOrdinal(QuranAddress address) {
    final ayah = address.ayah;
    if (ayah == null) return null;
    if (address.surah > ayahCounts.length) return null;
    if (ayah > ayahCounts[address.surah - 1]) return null;

    var ordinal = ayah;
    for (var s = 1; s < address.surah; s++) {
      ordinal += ayahCounts[s - 1];
    }
    return ordinal;
  }
}
