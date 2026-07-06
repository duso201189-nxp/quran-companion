import 'package:flutter_test/flutter_test.dart';

import 'package:quran_companion/shared/utils/simple_markdown.dart';

void main() {
  test('văn bản thường -> 1 segment không định dạng', () {
    expect(
      parseSimpleMarkdown('xin chào'),
      [const MdSegment('xin chào')],
    );
  });

  test('**đậm** và *nghiêng* tách đúng segment', () {
    expect(parseSimpleMarkdown('a **b** c *d* e'), [
      const MdSegment('a '),
      const MdSegment('b', bold: true),
      const MdSegment(' c '),
      const MdSegment('d', italic: true),
      const MdSegment(' e'),
    ]);
  });

  test('cú pháp hỏng (thiếu dấu đóng) giữ nguyên văn', () {
    expect(
      parseSimpleMarkdown('a **b chưa đóng'),
      [const MdSegment('a **b chưa đóng')],
    );
  });

  test('tiếng Việt có dấu trong định dạng', () {
    expect(parseSimpleMarkdown('**ghi chú** quan trọng'), [
      const MdSegment('ghi chú', bold: true),
      const MdSegment(' quan trọng'),
    ]);
  });
}
