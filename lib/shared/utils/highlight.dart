/// Tô đậm phần khớp trong kết quả tìm kiếm — hỗ trợ khớp không
/// phân biệt dấu (Việt/Latin) và bỏ-harakat (Ả Rập) bằng cách fold
/// CÓ BẢN ĐỒ CHỈ SỐ: mỗi ký tự sau khi fold nhớ vị trí gốc, nên
/// vùng khớp ánh xạ ngược về đúng đoạn văn bản gốc (kể cả tashkeel).
library;

import 'package:flutter/widgets.dart';

import '../../features/quran/data/fts_query.dart';
import 'text_folding.dart';

class _FoldedText {
  _FoldedText(this.folded, this.map);

  /// Chuỗi đã fold (chữ thường, bỏ dấu/harakat).
  final String folded;

  /// map[i] = chỉ số trong chuỗi GỐC của ký tự folded thứ i.
  final List<int> map;
}

final RegExp _arabicChar = RegExp(r'[؀-ۿ]');

_FoldedText _foldWithMap(String original) {
  final buffer = StringBuffer();
  final map = <int>[];
  final lower = original.toLowerCase();
  var i = 0;
  for (final rune in lower.runes) {
    final ch = String.fromCharCode(rune);
    final isArabicCh = _arabicChar.hasMatch(ch);
    String out;
    if (isArabicCh) {
      // Bỏ harakat, quy ٱ về ا để khớp query gõ thường.
      out = arabicMarks.hasMatch(ch) ? '' : (ch == 'ٱ' ? 'ا' : ch);
    } else {
      out = foldDiacritics(ch);
    }
    for (var k = 0; k < out.length; k++) {
      buffer.write(out[k]);
      map.add(i);
    }
    i += ch.length;
  }
  return _FoldedText(buffer.toString(), map);
}

/// Các khoảng [start, end) trong chuỗi GỐC khớp với [query]
/// (mỗi từ của query tìm độc lập, không phân biệt dấu).
List<(int, int)> matchRanges(String text, String query) {
  final folded = _foldWithMap(text);
  final isArabic = _arabicChar.hasMatch(query);
  final foldedQuery = isArabic
      ? foldArabic(query).replaceAll('ٱ', 'ا')
      : foldDiacritics(query);
  final tokens = foldedQuery
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return const [];

  final ranges = <(int, int)>[];
  for (final token in tokens) {
    var from = 0;
    while (true) {
      final at = folded.folded.indexOf(token, from);
      if (at < 0) break;
      final endFolded = at + token.length - 1;
      final startOrig = folded.map[at];
      // Kéo dài hết ký tự gốc cuối (gồm cả harakat theo sau).
      final endOrig = endFolded + 1 < folded.map.length
          ? folded.map[endFolded + 1]
          : text.length;
      ranges.add((startOrig, endOrig));
      from = at + token.length;
    }
  }
  if (ranges.isEmpty) return const [];

  // Gộp khoảng chồng lấn.
  ranges.sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <(int, int)>[ranges.first];
  for (final r in ranges.skip(1)) {
    final last = merged.last;
    if (r.$1 <= last.$2) {
      if (r.$2 > last.$2) merged[merged.length - 1] = (last.$1, r.$2);
    } else {
      merged.add(r);
    }
  }
  return merged;
}

/// Cắt [text] thành spans, phần khớp [query] mang [highlightStyle].
List<TextSpan> highlightSpans(
  String text,
  String query, {
  TextStyle? highlightStyle,
}) {
  final ranges = matchRanges(text, query);
  if (ranges.isEmpty) return [TextSpan(text: text)];

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final (start, end) in ranges) {
    if (start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, start)));
    }
    spans.add(
      TextSpan(text: text.substring(start, end), style: highlightStyle),
    );
    cursor = end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  return spans;
}
