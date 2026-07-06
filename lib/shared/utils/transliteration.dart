/// Làm sạch phiên âm Tanzil (en.transliteration) trước khi hiển thị.
///
/// Dữ liệu gốc chứa thẻ HTML mang NGHĨA phiên âm học thuật:
/// - `<u>` nguyên âm  = nguyên âm dài  (a→ā, i→ī, u→ū)
/// - `<u>` phụ âm     = phụ âm nhấn    (s→ṣ, d→ḍ, t→ṭ, z→ẓ, h→ḥ)
/// - `<u>th</u>`      = ذ  → dh
/// - `<b>`            = âm đọc lướt (giữ chữ, bỏ thẻ)
/// - `AA`             = ع  → ʿ
/// - `-` giữa hai chữ = hamza → ʾ
///
/// Ví dụ: `Alla<u>a</u>hu` → `Allāhu`,
///        `naAAbudu` → `naʿbudu`,
///        `mal<u>a</u>-ikati` → `malāʾikati`.
library;

const Map<String, String> _underlineMap = {
  'a': 'ā',
  'A': 'Ā',
  'i': 'ī',
  'I': 'Ī',
  'u': 'ū',
  'U': 'Ū',
  'e': 'ē',
  'E': 'Ē',
  'o': 'ō',
  'O': 'Ō',
  's': 'ṣ',
  'S': 'Ṣ',
  'd': 'ḍ',
  'D': 'Ḍ',
  't': 'ṭ',
  'T': 'Ṭ',
  'z': 'ẓ',
  'Z': 'Ẓ',
  'h': 'ḥ',
  'H': 'Ḥ',
};

final RegExp _underlineTag =
    RegExp('<u>(.*?)</u>', caseSensitive: false, dotAll: true);
final RegExp _anyTag = RegExp('<[^>]+>');
final RegExp _hamzaHyphen = RegExp('(?<=[a-zāīūēō])-(?=[a-zāīūēō])');

/// Chuyển nội dung trong một cặp `<u>...</u>` sang Unicode.
String _convertUnderlined(String inner) {
  final out = StringBuffer();
  for (var i = 0; i < inner.length; i++) {
    // Digraph ذ: 'th' gạch chân → 'dh' (không biến đổi tiếp).
    if (i + 1 < inner.length &&
        (inner[i] == 't' || inner[i] == 'T') &&
        (inner[i + 1] == 'h' || inner[i + 1] == 'H')) {
      out.write(inner[i] == 'T' ? 'Dh' : 'dh');
      i++;
      continue;
    }
    out.write(_underlineMap[inner[i]] ?? inner[i]);
  }
  return out.toString();
}

/// Làm sạch một chuỗi phiên âm ĐỊNH DẠNG CŨ (Tanzil): bỏ hết HTML,
/// trả về Unicode chuẩn.
///
/// Chuỗi KHÔNG mang dấu hiệu định dạng cũ (`<` hoặc `AA`) được trả
/// nguyên vẹn — dataset chuẩn hiện tại (Quran.com wbw) dùng gạch nối
/// có nghĩa ('l-lāhi', 'bis'mi') nên tuyệt đối không đụng vào.
String cleanTransliteration(String raw) {
  final legacy = raw.contains('<') || raw.contains('AA');
  if (!legacy) return raw;

  var s = raw.replaceAllMapped(
    _underlineTag,
    (m) => _convertUnderlined(m.group(1)!),
  );
  // <b>/<i>... giữ nội dung, bỏ thẻ (kể cả thẻ viết hoa/đóng thiếu).
  s = s.replaceAll(_anyTag, '');
  // ع — luôn được Tanzil mã hoá là 'AA'.
  s = s.replaceAll('AA', 'ʿ');
  // Hamza giữa hai nguyên âm: 'mala-ikati' → 'malaʾikati'.
  s = s.replaceAllMapped(_hamzaHyphen, (_) => 'ʾ');
  return s;
}
