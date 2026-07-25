import 'package:flutter/material.dart';

/// Vỏ thẻ dùng chung cho danh sách nội dung dạng thẻ — kết quả tìm
/// kiếm và "Thư viện của tôi" (Sprint 27.1).
///
/// Trích ra từ HAI cây widget giống hệt nhau từng dòng — `ResultCard`
/// (`result_card.dart`) và `LibraryAyahTile` (`library_ayah_tile.dart`):
///
///     Padding(symmetric(h: 8, v: 3))
///       └ Material(surfaceContainerLow, bo góc 14)
///           └ InkWell(bo góc 14, onTap)
///               └ Padding(all 14)
///                   └ <nội dung riêng của từng thẻ>
///
/// ĐÂY CHỈ LÀ VỎ. Nó không biết gì về nội dung, không áp đặt
/// Column/Row, và KHÔNG hợp nhất hai widget gọi nó: `ResultCard` là
/// hợp đồng hiển thị domain-agnostic có tô đậm từ khoá, còn
/// `LibraryAyahTile` mang ghi chú / chấm màu highlight / nút sắp xếp
/// vào bộ sưu tập. Trách nhiệm khác nhau -> giữ nguyên hai widget.
///
/// [semanticsLabel] tuỳ chọn và được đặt ĐÚNG vị trí cũ trong
/// `ResultCard` (bên trong [outerPadding], bọc quanh Material) để
/// vùng của node accessibility không đổi. Bên gọi không truyền thì
/// KHÔNG sinh node Semantics nào — giữ nguyên hành vi hiện tại của
/// `LibraryAyahTile`, nơi các widget con (vd nút "sắp xếp vào bộ sưu
/// tập") phải tự đọc được riêng.
class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
  });

  /// Khoảng cách NGOÀI giữa hai thẻ liền kề.
  static const EdgeInsets outerPadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 3);

  /// Khoảng cách TRONG từ mép thẻ tới nội dung.
  static const EdgeInsets innerPadding = EdgeInsets.all(14);

  /// Bán kính bo góc thẻ.
  static const double radius = 14;

  final Widget child;

  /// null = thẻ chỉ để xem, không bấm được.
  final VoidCallback? onTap;

  /// null = không gộp ngữ nghĩa, để các widget con tự đọc.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final card = Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(padding: innerPadding, child: child),
      ),
    );

    return Padding(
      padding: outerPadding,
      child: semanticsLabel == null
          ? card
          : Semantics(
              label: semanticsLabel,
              button: onTap != null,
              excludeSemantics: true,
              child: card,
            ),
    );
  }
}
