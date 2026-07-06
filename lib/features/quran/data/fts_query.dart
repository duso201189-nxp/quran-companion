/// Dựng biểu thức MATCH cho bảng FTS5 `search_index` từ chuỗi
/// người dùng gõ — hàm thuần, unit test độc lập.
///
/// Quy tắc:
/// - Mỗi từ thành `"từ"*` (prefix match, AND ngầm định giữa các từ).
/// - Query Latin: bỏ dấu (khớp cột *_plain đã bỏ dấu sẵn).
/// - Query Ả Rập: bỏ harakat; index giữ nguyên chữ ٱ (alef wasla)
///   trong khi người dùng gõ ا thường -> sinh thêm biến thể đổi
///   ا đầu-từ thành ٱ, nối bằng OR.
library;

import '../../../shared/utils/text_folding.dart';

final RegExp _arabicChar = RegExp(r'[؀-ۿ]');

/// Harakat + ký hiệu đọc + tatweel: bỏ khi khớp cột arabic_plain.
/// (064B–065F harakat, 0670 alef trên, 06D6–06ED dấu dừng/trang trí,
/// 08D3–08FF phần mở rộng, 0640 tatweel.)
final RegExp arabicMarks = RegExp(
  r'[ـً-ٰٟۖ-ۭ࣓-ࣿ]',
);

/// Bỏ harakat khỏi chuỗi Ả Rập (giữ nguyên chữ cái).
String foldArabic(String input) => input.replaceAll(arabicMarks, '');

/// null nếu query rỗng/không có từ hợp lệ.
String? ftsMatchExpression(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  final isArabic = _arabicChar.hasMatch(trimmed);
  final source = isArabic ? foldArabic(trimmed) : foldDiacritics(trimmed);

  final tokens = source
      .split(RegExp(r'\s+'))
      .map((t) => t.replaceAll('"', '').replaceAll('*', ''))
      .where((t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return null;

  String phrase(List<String> ts) => ts.map((t) => '"$t"*').join(' ');

  if (!isArabic) return phrase(tokens);

  // Biến thể alef wasla (ٱ U+0671) cho từ bắt đầu bằng ا U+0627.
  final wasla = [
    for (final t in tokens) t.startsWith('ا') ? 'ٱ${t.substring(1)}' : t,
  ];
  final same = wasla.join(' ') == tokens.join(' ');
  return same ? phrase(tokens) : '(${phrase(tokens)}) OR (${phrase(wasla)})';
}
