import '../../../core/quran/quran_address.dart';
import 'basmalah.dart';

/// Bố cục PLAYLIST audio của một Surah — Sprint BM1 (Basmalah 2.0).
///
/// Song sinh với `ReadingRows`: một bên nói "Ayah thứ i nằm ở HÀNG nào",
/// bên này nói "Ayah thứ i nằm ở MỤC PHÁT nào". Cả hai lấy số phần tử
/// dẫn đầu từ CÙNG một [SurahOpening], nên hàng và playlist không thể
/// lệch nhau.
///
/// Nằm ở `domain/` chứ không phải `presentation/` (khác `ReadingRows`)
/// vì thứ tự này là một sự thật về NỘI DUNG — người đọc Qur'an đọc phần
/// mở đầu rồi mới tới Ayah 1 — chứ không phải một quyết định trình bày.
///
/// ## Vì sao module này phải tồn tại
///
/// Trước BM1, chỉ số playlist và chỉ số Ayah là MỘT: `_items[i]` luôn là
/// Ayah thứ i. Thêm phần mở đầu vào playlist làm hai hệ đó tách đôi —
/// đúng loại mơ hồ Sprint F0 đã đi gỡ, xuất hiện lại ở chỗ khác.
///
/// Nguy hiểm ở chỗ hai nơi tiêu thụ chỉ số Ayah ghi XUỐNG ĐĨA:
/// `ReadingPositionStore` và `study_sessions`. Cột `ayah_from`/`ayah_to`
/// là 0-based và **không có cột nào ghi lại hệ số của chính nó**; ghi
/// nhầm chỉ số playlist vào đó làm sai mọi thống kê một cách âm thầm và
/// không khôi phục được (xem `docs/knowledge/quran_index_conventions.md`).
///
/// Vì thế BM1 **không** đổi gì ở tầng lưu trữ: đĩa vẫn thuần hệ Ayah,
/// và mọi phép quy đổi đi qua đúng tệp này.
abstract final class ReadingPlaylist {
  /// Số mục phát đứng TRƯỚC Ayah đầu tiên: 1 nếu Surah có phần mở đầu
  /// tách rời, ngược lại 0.
  ///
  /// `OpeningIsFirstAyah` (Al-Fatihah) trả **0** — phần mở đầu của nó
  /// CHÍNH LÀ Ayah 1, vốn đã nằm trong playlist. Thêm nữa là phát
  /// Basmalah hai lần. Cái chặn ở đây là kiểu `sealed`, không phải một
  /// `if (surahId != 1)`.
  ///
  /// Sprint BM2: điều kiện đi qua [hasSeparateOpening] để hàng và
  /// playlist dùng CHUNG một định nghĩa.
  static int leadingItemsFor(SurahOpening opening) =>
      hasSeparateOpening(opening) ? 1 : 0;

  /// Mục phát chứa Ayah thứ [ayahIndex] (0-based).
  static int itemForAyahIndex({
    required SurahOpening opening,
    required int ayahIndex,
  }) =>
      ayahIndex + leadingItemsFor(opening);

  /// Ayah 0-based mà mục phát [item] ứng với — `null` nếu đó là phần mở
  /// đầu.
  ///
  /// `null` là một CÂU TRẢ LỜI ("mục này không phải Ayah nào cả"), không
  /// phải lỗi cần kẹp về 0. Bên gọi phải xử lý nó một cách có ý thức —
  /// đó chính là chỗ trước đây một `- 1` bị quên sẽ ghi lệch xuống đĩa.
  static int? ayahIndexForItem({
    required SurahOpening opening,
    required int item,
  }) {
    final leading = leadingItemsFor(opening);
    return item < leading ? null : item - leading;
  }

  /// Mục phát để BẮT ĐẦU, cho một yêu cầu phát tại địa chỉ [from].
  ///
  /// MỨC của địa chỉ chính là ý định:
  /// - mức **Surah** (`2`) = "đọc Surah này từ đầu" -> mục 0, tức phần
  ///   mở đầu nếu Surah có;
  /// - mức **Ayah** (`2:5`) = người dùng chỉ đúng Ayah đó.
  ///
  /// ## Vì sao BM3 thay `startItemForAyahIndex`
  ///
  /// Hàm cũ nhận một chỉ số Ayah rồi ĐOÁN ý định từ `ayahIndex == 0`.
  /// Khi phần mở đầu chưa có nút riêng thì đoán vậy là đủ dùng, nhưng
  /// nó gộp hai ý khác nhau vào một con số: bấm phát trên thẻ **Ayah 1**
  /// lại nghe Basmalah trước, dù nhãn nút chỉ hứa Ayah 1.
  ///
  /// BM2 cho phần mở đầu một hàng riêng và BM3 cho nó một nút riêng,
  /// nên hai ý định giờ có hai chỗ bấm khác nhau — và bên gọi nói thẳng
  /// ý định bằng địa chỉ thay vì để hàm này suy diễn.
  static int itemForAddress({
    required SurahOpening opening,
    required QuranAddress from,
  }) {
    // `zeroBasedAyahIndex` là `null` ở mức Surah — chính là dấu hiệu
    // "chưa chỉ vào Ayah nào", tức là bắt đầu từ đầu Surah.
    final ayahIndex = from.zeroBasedAyahIndex;
    return ayahIndex == null
        ? 0
        : itemForAyahIndex(opening: opening, ayahIndex: ayahIndex);
  }
}
