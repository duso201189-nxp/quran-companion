import 'package:flutter/material.dart';

/// Tiêu đề 1 phần nội dung trong màn hình (Sprint 20 Phase 2, Task 2)
/// — trích ra từ 6 cài đặt độc lập NHƯNG GIỐNG HỆT nhau về mặt hình
/// ảnh (`Text(text, style: textTheme.titleSmall?.copyWith(fontWeight:
/// FontWeight.w700))`), xác nhận trước khi gộp bằng cách đọc trực
/// tiếp từng nơi (xem accessibility_audit.md mục "SectionHeader"):
/// `progress_dashboard_screen.dart`'s `_SectionHeader` (5 lệnh gọi),
/// `tutor_home_screen.dart` (2 lệnh gọi inline), `learning_journey_screen.dart`,
/// `smart_learning_screen.dart`, `smart_deck_screen.dart` (Flashcards).
///
/// `home_screen.dart`'s `_SectionTitle` CỐ Ý không gộp vào đây — dùng
/// `titleMedium` (không phải `titleSmall`), khác về mặt hình ảnh, đúng
/// tinh thần "chỉ gộp khi thật sự tương đương" (Task 2) — giữ riêng,
/// tự thêm `Semantics(header: true)` tại chỗ.
///
/// Tự bọc `Semantics(header: true)` (Task 4) — mọi nơi thay
/// `_SectionHeader`/Text thủ công bằng widget này TỰ ĐỘNG có heading
/// semantics đúng chuẩn mà không cần sửa thêm gì ở nơi gọi.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
