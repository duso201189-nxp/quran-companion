/// Xử lý Basmalah — quy tắc trình bày Mushaf, thuần logic (test được).
///
/// BỐI CẢNH DỮ LIỆU (đã kiểm chứng trên quran.sqlite):
/// - Văn bản Uthmani (Tanzil) NHÚNG Basmalah vào đầu Ayah 1 của
///   113/114 Surah — tất cả trừ Surah 9 (At-Tawbah).
/// - Surah 1 (Al-Fatihah): Basmalah CHÍNH là Ayah 1 (đứng riêng).
/// - Surah 9: không có Basmalah.
/// - Basmalah luôn là 4 "từ" (token cách nhau bởi space) đầu tiên,
///   kể cả biến thể chính tả ở Surah 95 & 97 ('بِّسْمِ').
///
/// Vì Basmalah là văn bản kinh CHÍNH THỐNG của Ayah 1, KHÔNG sửa dữ
/// liệu. Thay vào đó, ở chế độ Danh sách ta tách phần Basmalah ra
/// header trang trí và hiển thị phần còn lại trong thẻ Ayah 1 — đúng
/// một Basmalah. Chế độ Mushaf / Focus giữ nguyên văn bản liền mạch.
library;

/// Số "từ" của Basmalah dẫn đầu (bِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ).
const int _basmalahWordCount = 4;

/// Surah có Basmalah dẫn đầu (nhúng ở đầu Ayah 1) hay không.
/// Surah 1: Basmalah là Ayah 1 -> false (không tách). Surah 9: false.
bool surahHasLeadingBasmalah(int surahId) => surahId != 1 && surahId != 9;

/// Kết quả tách Basmalah khỏi văn bản Ayah 1.
typedef BasmalahSplit = ({String basmalah, String rest});

/// Tách 4 từ Basmalah dẫn đầu khỏi [ayah1Text].
///
/// Không phụ thuộc chính tả cụ thể (bền với biến thể 95/97): chỉ cắt
/// tại dấu cách thứ 4. Nếu văn bản có < 5 token (không kỳ vọng xảy ra
/// với Surah có Basmalah), trả về toàn bộ làm basmalah, rest rỗng —
/// an toàn, không ném lỗi.
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

/// Văn bản Ayah để HIỂN THỊ trong chế độ Danh sách: Ayah 1 của Surah
/// có Basmalah dẫn đầu -> bỏ Basmalah (đã đưa lên header). Còn lại giữ
/// nguyên. KHÔNG dùng cho Mushaf/Focus (giữ văn bản liền mạch).
String ayahDisplayText({
  required int surahId,
  required int ayahNumber,
  required String textUthmani,
}) {
  if (ayahNumber == 1 && surahHasLeadingBasmalah(surahId)) {
    return splitLeadingBasmalah(textUthmani).rest;
  }
  return textUthmani;
}
