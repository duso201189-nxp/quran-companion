/// Bỏ dấu ký tự Latin để tìm kiếm không phân biệt dấu:
/// 'Khai Đề' -> 'khai de', 'raḥīm' -> 'rahim'.
///
/// Dart không có sẵn Unicode normalization, nên dùng bảng ánh xạ
/// tường minh — phủ toàn bộ nguyên âm tiếng Việt (đủ 2 kiểu hoa
/// thường) và các dấu Latin phổ biến trong transliteration.
library;

const Map<String, String> _foldMap = {
  'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
  'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
  'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
  'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
  'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
  'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ī': 'i',
  'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
  'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
  'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
  'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u', 'ū': 'u',
  'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
  'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
  'đ': 'd',
  // dấu thường gặp trong transliteration Ả Rập
  'ā': 'a', 'ḥ': 'h', 'ṣ': 's', 'ḍ': 'd', 'ṭ': 't', 'ẓ': 'z',
  'ʿ': '', 'ʾ': '', '\u2018': '', '\u2019': '',
  // ký hiệu họng/thanh quản: bỏ khi fold để "bis'mi" khớp
  // khi người dùng gõ 'bismi' (khớp fold_latin pipeline).
  "'": '', 'ʼ': '',
};

/// Trả về chuỗi chữ thường, đã bỏ dấu.
String foldDiacritics(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_foldMap[ch] ?? ch);
  }
  return buffer.toString();
}
