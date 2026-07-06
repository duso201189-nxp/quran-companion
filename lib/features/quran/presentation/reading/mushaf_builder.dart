import '../../domain/entities/ayah_content.dart';

/// Chuyển số sang chữ số Ả Rập-Ấn: 114 -> ١١٤ (dấu kết Ayah Mushaf).
String toArabicDigits(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((c) => digits[int.parse(c)])
      .join();
}

/// Một trang Mushaf: các Ayah nối liền thành khối văn bản,
/// kết mỗi Ayah bằng dấu ﴿n﴾ như bản in.
class MushafPage {
  const MushafPage({
    required this.pageNumber,
    required this.text,
    required this.firstAyahIndex,
  });

  /// Số trang Mushaf Madani (từ cột `page` trong data).
  final int pageNumber;

  /// Văn bản Ả Rập liền mạch của trang (trong phạm vi Surah này).
  final String text;

  /// Chỉ số (0-based trong danh sách Ayah của Surah) của Ayah đầu
  /// trang — dùng khôi phục đúng trang khi mở lại.
  final int firstAyahIndex;
}

/// Gom Ayah theo trang Mushaf. Ayah thiếu số trang (data cũ) gom
/// vào trang 0 để không mất nội dung.
List<MushafPage> buildMushafPages(List<AyahContent> ayahs) {
  if (ayahs.isEmpty) return const [];

  final pages = <MushafPage>[];
  var currentPage = ayahs.first.ayah.page ?? 0;
  var buffer = StringBuffer();
  var firstIndex = 0;

  void flush() {
    if (buffer.isEmpty) return;
    pages.add(
      MushafPage(
        pageNumber: currentPage,
        text: buffer.toString().trim(),
        firstAyahIndex: firstIndex,
      ),
    );
  }

  for (var i = 0; i < ayahs.length; i++) {
    final ayah = ayahs[i].ayah;
    final page = ayah.page ?? 0;
    if (page != currentPage) {
      flush();
      currentPage = page;
      buffer = StringBuffer();
      firstIndex = i;
    }
    buffer
      ..write(ayah.textUthmani)
      ..write(' ﴿')
      ..write(toArabicDigits(ayah.ayahNumber))
      ..write('﴾ ');
  }
  flush();
  return pages;
}

/// Trang chứa Ayah có chỉ số [ayahIndex] — để mở đúng trang cũ.
int pageIndexForAyah(List<MushafPage> pages, int ayahIndex) {
  for (var i = pages.length - 1; i >= 0; i--) {
    if (pages[i].firstAyahIndex <= ayahIndex) return i;
  }
  return 0;
}
