/// Trang trí của MỘT Ayah trong màn hình đọc — Sprint F1 (Phase 4).
///
/// `DR-2026-0019` §6.3 tách **cấu trúc** (Ayah nào có mặt ở đó) khỏi
/// **trang trí** (Ayah nào đang được đánh dấu, và vì lý do gì). Tệp này
/// là nửa sau, và nó cố ý KHÔNG biết màu: một `AyahDecoration` nói "đang
/// phát" hoặc "người dùng đã tô màu tên X"; màu đó trông ra sao là việc
/// của tầng trình bày.
///
/// Vì sao đáng tách khỏi `AyahCard`:
///
/// - Luật ưu tiên trước F1 nằm trong một biểu thức ba ngôi lồng nhau
///   giữa `build()`, nên chỉ kiểm chứng được bằng widget test — tức là
///   phải dựng cả database, cả provider, cả khung hình, để trả lời một
///   câu hỏi thuần logic.
/// - `sealed` khiến việc thêm một loại trang trí mới (dấu chiêm nghiệm,
///   trích dẫn của AI Tutor, kết quả tìm kiếm — `DR-2026-0019` §6.3)
///   thành LỖI BIÊN DỊCH ở mọi nơi đang phân nhánh, thay vì một nhánh
///   bị quên âm thầm.
sealed class AyahDecoration {
  const AyahDecoration();
}

/// Không có gì đánh dấu Ayah này.
final class NoDecoration extends AyahDecoration {
  const NoDecoration();
}

/// Ayah đang được trình phát audio đọc.
final class PlayingDecoration extends AyahDecoration {
  const PlayingDecoration();
}

/// Người dùng đã tô màu Ayah này.
///
/// Mang TÊN màu — khoá trong bảng màu của tầng trình bày — chứ không
/// mang `Color`: tầng domain không nhìn thấy `dart:ui`. Tên không có
/// trong bảng vẫn hợp lệ ở đây; xử lý nó là việc của bên đổi tên thành
/// màu.
final class UserHighlightDecoration extends AyahDecoration {
  const UserHighlightDecoration(this.colorName);

  final String colorName;

  @override
  bool operator ==(Object other) =>
      other is UserHighlightDecoration && other.colorName == colorName;

  @override
  int get hashCode => colorName.hashCode;

  @override
  String toString() => 'UserHighlightDecoration($colorName)';
}

/// Luật ưu tiên trang trí — đúng MỘT nơi trong toàn ứng dụng.
///
/// Thứ tự: đang phát > người dùng tô màu > không gì.
///
/// Đang phát thắng màu người dùng vì khi audio đang chạy, người đọc cần
/// biết mình đang ở đâu hơn là cần thấy màu mình tô hôm trước. Màu tô
/// không mất: nó vẫn nguyên trong dữ liệu và hiện lại ngay khi audio đi
/// qua Ayah đó.
///
/// [highlightColors] là tập, không phải danh sách — khi người dùng tô
/// nhiều màu lên cùng một Ayah, phần tử đầu (theo thứ tự thêm vào) được
/// dùng. Đây là hành vi có từ trước F1, giữ nguyên.
AyahDecoration resolveAyahDecoration({
  required bool isPlaying,
  required Set<String> highlightColors,
}) {
  if (isPlaying) return const PlayingDecoration();
  if (highlightColors.isEmpty) return const NoDecoration();
  return UserHighlightDecoration(highlightColors.first);
}
