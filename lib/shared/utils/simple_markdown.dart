/// Markdown cơ bản cho ghi chú: **đậm** và *nghiêng*.
/// Parser thuần trả về segment — UI tự dựng TextSpan; test không
/// cần Flutter.
library;

class MdSegment {
  const MdSegment(this.text, {this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;

  @override
  bool operator ==(Object other) =>
      other is MdSegment &&
      other.text == text &&
      other.bold == bold &&
      other.italic == italic;

  @override
  int get hashCode => Object.hash(text, bold, italic);
}

/// Tách chuỗi thành segment theo **...** rồi *...*.
/// Cú pháp hỏng (thiếu dấu đóng) giữ nguyên văn — không bao giờ
/// nuốt nội dung của người dùng.
List<MdSegment> parseSimpleMarkdown(String input) {
  final result = <MdSegment>[];

  void parseItalic(String text, {required bool bold}) {
    final re = RegExp(r'\*([^*]+)\*');
    var last = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        result.add(MdSegment(text.substring(last, m.start), bold: bold));
      }
      result.add(MdSegment(m.group(1)!, bold: bold, italic: true));
      last = m.end;
    }
    if (last < text.length) {
      result.add(MdSegment(text.substring(last), bold: bold));
    }
  }

  final re = RegExp(r'\*\*([^*]+)\*\*');
  var last = 0;
  for (final m in re.allMatches(input)) {
    if (m.start > last) {
      parseItalic(input.substring(last, m.start), bold: false);
    }
    result.add(MdSegment(m.group(1)!, bold: true));
    last = m.end;
  }
  if (last < input.length) {
    parseItalic(input.substring(last), bold: false);
  }
  return result;
}
