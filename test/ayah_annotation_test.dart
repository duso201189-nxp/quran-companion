import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/entities/ayah_annotation.dart';

/// Sprint 25.4 — `AyahAnnotation` được so sánh THEO GIÁ TRỊ để tầng UI
/// dùng `ref.watch(provider.select(...))`: đổi chú thích của một Ayah
/// thì chỉ Ayah đó dựng lại. Nếu `==` sai, tối ưu đó âm thầm mất tác
/// dụng (hoặc tệ hơn: UI không cập nhật) — nên khoá lại bằng test.
void main() {
  group('AyahAnnotation — so sánh theo giá trị', () {
    test('cùng nội dung -> bằng nhau và cùng hashCode', () {
      const a = AyahAnnotation(
        bookmarked: true,
        note: 'ghi chú',
        status: AyahStatus.learning,
        highlightColors: {'green', 'amber'},
      );
      const b = AyahAnnotation(
        bookmarked: true,
        note: 'ghi chú',
        status: AyahStatus.learning,
        // Cùng tập hợp, khác THỨ TỰ liệt kê -> vẫn phải bằng nhau.
        highlightColors: {'amber', 'green'},
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('khác từng trường -> khác nhau', () {
      const base = AyahAnnotation();

      expect(base == const AyahAnnotation(bookmarked: true), isFalse);
      expect(base == const AyahAnnotation(favorited: true), isFalse);
      expect(base == const AyahAnnotation(note: 'x'), isFalse);
      expect(
        base == const AyahAnnotation(status: AyahStatus.learned),
        isFalse,
      );
      expect(
        base == const AyahAnnotation(highlightColors: {'blue'}),
        isFalse,
      );
    });

    test('tập màu khác nhau nhưng cùng độ dài -> khác nhau', () {
      const a = AyahAnnotation(highlightColors: {'blue'});
      const b = AyahAnnotation(highlightColors: {'pink'});

      expect(a == b, isFalse);
    });

    test('empty bằng một instance mặc định mới', () {
      expect(AyahAnnotation.empty, const AyahAnnotation());
      expect(AyahAnnotation.empty.isEmpty, isTrue);
    });
  });
}
