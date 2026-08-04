/// Basmalah — Surah MỞ ĐẦU thế nào, và điều đó có nghĩa gì khi vẽ.
///
/// BỐI CẢNH DỮ LIỆU (kiểm chứng lại trên chính `quran.sqlite` ở Sprint
/// F2, không chép lại từ tài liệu):
/// - 112 Surah có Basmalah là 4 token đầu của Ayah 1, và Ayah 1 luôn
///   còn ít nhất một token nữa (ngắn nhất là 5 token).
/// - Surah 1 (Al-Fatihah): Ayah 1 CHÍNH LÀ Basmalah — đúng 4 token,
///   không có gì thêm.
/// - Surah 9 (At-Tawbah): không có Basmalah.
/// - Surah 95 & 97 viết biến thể `بِّسْمِ` (thêm shadda). Vẫn 4 token,
///   nên phép tách theo token không bị ảnh hưởng.
///
/// Vì Basmalah là văn bản kinh CHÍNH THỐNG của Ayah 1, KHÔNG sửa dữ
/// liệu. Ở chế độ Danh sách ta tách phần Basmalah ra header trang trí
/// và hiển thị phần còn lại trong thẻ Ayah 1 — đúng một Basmalah. Chế
/// độ Mushaf / Focus giữ nguyên văn bản liền mạch.
///
/// ## Sprint F2 — vì sao có [SurahOpening]
///
/// Trước F2, mọi đường vẽ đều hỏi `surahHasLeadingBasmalah(id)`, một
/// hàm trả `false` cho CẢ Surah 1 lẫn Surah 9 — vì hai lý do ngược
/// nhau. Surah 1 CÓ Basmalah (nó là Ayah 1); Surah 9 KHÔNG có. Một
/// `false` mang hai nghĩa là thứ chạy đúng hôm nay và sai lặng lẽ ngay
/// khi có ai hỏi "Surah này có phần mở đầu để phát / tô / tính tiến độ
/// không?" — tức đúng câu hỏi Basmalah 2.0 sẽ hỏi.
///
/// [SurahOpening] tách hai nghĩa đó thành hai nhánh khác nhau của một
/// kiểu `sealed`, và đó là toàn bộ giá trị của F2.
library;

import '../../../core/quran/quran_address.dart';

/// Số "từ" (token cách nhau bởi space) của Basmalah dẫn đầu.
const int _basmalahWordCount = 4;

/// Cách MỘT Surah mở đầu — khai báo, không phải nhánh `if`.
///
/// `DR-2026-0017` §10.3 gọi đây là "opening range" và biểu diễn nó bằng
/// `Range`; F2 dừng ở mức Ayah vì mức Word chưa tồn tại (và xem ghi chú
/// về `_basmalahWordCount` bên dưới). Hình dạng ba nhánh thì giống hệt,
/// nên khi mức Word có thật, [OpeningPrefixesFirstAyah] nhận thêm phạm
/// vi của nó mà không nhánh nào khác phải đổi.
///
/// **Tiến độ không cần cờ riêng.** `DR-2026-0017` §10.3 bác bỏ một
/// thuộc tính `countsTowardProgress`, và kiểu này cho thấy vì sao:
/// [OpeningIsFirstAyah] hoàn thành đúng một Ayah vì phần mở đầu CHÍNH
/// LÀ Ayah đó; [OpeningPrefixesFirstAyah] không hoàn thành Ayah nào vì
/// nó chỉ là một phần của Ayah 1. Con số rơi ra từ chính nhánh, không
/// cần ai khai báo. Không thêm phương thức tính ở đây: chưa có nơi tiêu
/// thụ (tiền lệ `DR-2026-0006` D4 / `DR-2026-0007` D5).
sealed class SurahOpening {
  const SurahOpening();
}

/// Surah không có Basmalah mở đầu. Chỉ At-Tawbah (9).
final class NoOpening extends SurahOpening {
  const NoOpening();
}

/// Basmalah CHÍNH LÀ Ayah 1 — nó có địa chỉ thật, đọc được, tô được,
/// tính tiến độ được như mọi Ayah khác. Chỉ Al-Fatihah (1).
///
/// Đây KHÔNG phải một sự thật về Qur'an mà là một sự thật về ẤN BẢN:
/// bản này đếm Ayah theo lối Kufi (Hafs). Theo lối đếm khác, Basmalah
/// của Al-Fatihah không phải một Ayah riêng (`DR-2026-0017` §10.2).
final class OpeningIsFirstAyah extends SurahOpening {
  const OpeningIsFirstAyah(this.address);

  /// Luôn là `1:1` với ấn bản hiện tại.
  final QuranAddress address;

  @override
  bool operator ==(Object other) =>
      other is OpeningIsFirstAyah && other.address == address;

  @override
  int get hashCode => address.hashCode;

  @override
  String toString() => 'OpeningIsFirstAyah($address)';
}

/// Basmalah nằm ở ĐẦU văn bản Ayah 1 nhưng không phải một Ayah.
/// 112 Surah còn lại.
final class OpeningPrefixesFirstAyah extends SurahOpening {
  const OpeningPrefixesFirstAyah({
    required this.containingAyah,
    required this.text,
    required this.remainder,
  });

  /// Ayah CHỨA phần mở đầu này — luôn là `s:1`. Không phải địa chỉ của
  /// chính phần mở đầu: nó là một đoạn con, và mức Word chưa tồn tại để
  /// nói chính xác đoạn nào.
  final QuranAddress containingAyah;

  /// Văn bản Basmalah, đúng như trong dữ liệu (kể cả biến thể 95/97).
  final String text;

  /// Phần Ayah 1 còn lại sau Basmalah. Không bao giờ rỗng với dữ liệu
  /// thật — Ayah 1 ngắn nhất trong nhóm này có 5 token.
  final String remainder;

  @override
  bool operator ==(Object other) =>
      other is OpeningPrefixesFirstAyah &&
      other.containingAyah == containingAyah &&
      other.text == text &&
      other.remainder == remainder;

  @override
  int get hashCode => Object.hash(containingAyah, text, remainder);

  @override
  String toString() => 'OpeningPrefixesFirstAyah($containingAyah)';
}

/// Surah này có phần mở đầu **tách rời** — một phần tử đứng riêng,
/// không phải một Ayah — hay không?
///
/// Sprint BM2: đây là NGUỒN DUY NHẤT của câu hỏi đó. Cả playlist audio
/// (`ReadingPlaylist.leadingItemsFor`) lẫn danh sách hàng
/// (`ReadingRows.leadingRowsFor`) đều hỏi ở đây, nên hai bên không thể
/// bất đồng về việc Surah nào có phần mở đầu.
///
/// `false` cho Al-Fatihah (phần mở đầu CHÍNH LÀ Ayah 1 — đã là một phần
/// tử rồi) và cho At-Tawbah (không có). Hai lý do ngược nhau, cùng một
/// kết luận "không thêm phần tử nào" — và kiểu `sealed` giữ cho hai lý
/// do ấy vẫn phân biệt được ở mọi nơi khác.
bool hasSeparateOpening(SurahOpening opening) =>
    opening is OpeningPrefixesFirstAyah;

/// Kết quả tách Basmalah khỏi văn bản Ayah 1.
typedef BasmalahSplit = ({String basmalah, String rest});

/// Tách 4 từ Basmalah dẫn đầu khỏi [ayah1Text].
///
/// Không phụ thuộc chính tả cụ thể (bền với biến thể 95/97): chỉ cắt
/// tại dấu cách thứ 4. Nếu văn bản có < 5 token (không xảy ra với dữ
/// liệu thật), trả về toàn bộ làm basmalah, rest rỗng — an toàn, không
/// ném lỗi.
///
/// ⚠️ `_basmalahWordCount = 4` vẫn là một sự thật về ẤN BẢN nằm trong
/// LOGIC, đúng như `DR-2026-0017` §10.1 chê. F2 KHÔNG chữa được điều
/// đó: chữa thật cần một chỉ mục từ có thật trong dữ liệu, tức
/// `DR-2026-0017` M4/M5 kèm đổi schema và `PROJ-P-002`. Chuyển sang
/// `Range(s:1:1 – s:1:4)` lúc này chỉ dời con số 4 sang chỗ khác chứ
/// không xoá nó — xem báo cáo F2.
BasmalahSplit splitLeadingBasmalah(String ayah1Text) {
  var spaces = 0;
  for (var i = 0; i < ayah1Text.length; i++) {
    if (ayah1Text.codeUnitAt(i) == 0x20) {
      spaces++;
      if (spaces == _basmalahWordCount) {
        return (
          basmalah: ayah1Text.substring(0, i),
          rest: ayah1Text.substring(i + 1),
        );
      }
    }
  }
  return (basmalah: ayah1Text, rest: '');
}

/// Khai báo phần mở đầu của [surahId].
///
/// Đây là NƠI DUY NHẤT trong ứng dụng còn biết rằng Surah 1 và Surah 9
/// đặc biệt. Mọi nơi vẽ chỉ đọc kết quả và không hỏi số Surah nữa.
SurahOpening resolveSurahOpening({
  required int surahId,
  required String firstAyahText,
}) {
  // At-Tawbah: không có phần mở đầu. Nhánh rỗng, không phải ngoại lệ.
  if (surahId == 9) return const NoOpening();

  // Al-Fatihah: phần mở đầu là Ayah 1 (lối đếm Kufi — xem §10.2).
  if (surahId == 1) {
    return OpeningIsFirstAyah(QuranAddress.ayah(1, 1));
  }

  final split = splitLeadingBasmalah(firstAyahText);
  return OpeningPrefixesFirstAyah(
    containingAyah: QuranAddress.ayah(surahId, 1),
    text: split.basmalah,
    remainder: split.rest,
  );
}

/// Văn bản Ayah để HIỂN THỊ trong chế độ Danh sách: Ayah 1 của Surah
/// có Basmalah dẫn đầu -> bỏ Basmalah (đã đưa lên header). Còn lại giữ
/// nguyên. KHÔNG dùng cho Mushaf/Focus (giữ văn bản liền mạch).
String ayahDisplayText({
  required int surahId,
  required int ayahNumber,
  required String textUthmani,
}) {
  if (ayahNumber != 1) return textUthmani;
  final opening = resolveSurahOpening(
    surahId: surahId,
    firstAyahText: textUthmani,
  );
  return switch (opening) {
    // Basmalah đã lên header -> thẻ Ayah 1 chỉ còn phần sau.
    OpeningPrefixesFirstAyah(:final remainder) => remainder,
    // Ayah 1 LÀ Basmalah (Surah 1), hoặc không có Basmalah (Surah 9):
    // cả hai đều hiển thị nguyên văn.
    OpeningIsFirstAyah() || NoOpening() => textUthmani,
  };
}
