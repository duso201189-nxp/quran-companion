import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/ayah_decoration.dart';

/// Sprint F1 — tầng trang trí (DR-2026-0019 §6.3).
///
/// Trước F1, luật ưu tiên nằm trong một biểu thức ba ngôi lồng nhau giữa
/// `AyahCard.build()`, nên muốn kiểm chứng nó phải dựng cả database, cả
/// provider, cả khung hình. Bộ test này CỐ Ý không dùng widget hay
/// `ProviderContainer` — nếu một ngày phải thêm vào đây thì luật đã rơi
/// ngược trở lại tầng trình bày.
void main() {
  group('F1 — luật ưu tiên trang trí', () {
    test('không phát, không tô màu -> không trang trí', () {
      expect(
        resolveAyahDecoration(isPlaying: false, highlightColors: const {}),
        const NoDecoration(),
      );
    });

    test('đang phát -> trang trí "đang phát"', () {
      expect(
        resolveAyahDecoration(isPlaying: true, highlightColors: const {}),
        const PlayingDecoration(),
      );
    });

    test('có tô màu, không phát -> trang trí của người dùng', () {
      expect(
        resolveAyahDecoration(isPlaying: false, highlightColors: const {'sky'}),
        const UserHighlightDecoration('sky'),
      );
    });

    test('đang phát THẮNG màu người dùng — đây là luật, không phải may', () {
      // Khi audio chạy, biết mình đang ở đâu quan trọng hơn màu tô hôm
      // trước. Màu tô không mất, chỉ bị che trong lúc audio đi qua.
      expect(
        resolveAyahDecoration(isPlaying: true, highlightColors: const {'sky'}),
        const PlayingDecoration(),
      );
    });

    test('nhiều màu -> lấy màu thêm vào trước (hành vi có từ trước F1)', () {
      // LinkedHashSet: thứ tự lặp là thứ tự thêm vào.
      expect(
        resolveAyahDecoration(
          isPlaying: false,
          highlightColors: {'sky', 'rose', 'amber'},
        ),
        const UserHighlightDecoration('sky'),
      );
    });

    test('tên màu lạ vẫn dựng được — hợp lệ hoá là việc của tầng vẽ', () {
      // Tầng domain không nhìn thấy bảng màu, nên không thể và không nên
      // từ chối một tên nó không biết.
      expect(
        resolveAyahDecoration(
          isPlaying: false,
          highlightColors: const {'màu-không-tồn-tại'},
        ),
        const UserHighlightDecoration('màu-không-tồn-tại'),
      );
    });
  });

  group('F1 — trang trí là giá trị', () {
    test('hai trang trí cùng tên màu thì bằng nhau và cùng hashCode', () {
      expect(
        const UserHighlightDecoration('sky'),
        const UserHighlightDecoration('sky'),
      );
      expect(
        const UserHighlightDecoration('sky').hashCode,
        const UserHighlightDecoration('sky').hashCode,
      );
    });

    test('khác tên màu thì khác nhau', () {
      expect(
        const UserHighlightDecoration('sky'),
        isNot(const UserHighlightDecoration('rose')),
      );
    });

    test('ba loại trang trí không lẫn vào nhau', () {
      expect(const NoDecoration(), isNot(const PlayingDecoration()));
      expect(
        const PlayingDecoration(),
        isNot(const UserHighlightDecoration('sky')),
      );
    });
  });
}
