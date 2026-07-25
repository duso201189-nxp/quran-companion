import 'package:flutter/material.dart';

/// Trạng thái rỗng "toàn khu vực" — icon lớn + một dòng chữ, căn giữa
/// khoảng trống (Sprint 27.0).
///
/// Trích ra từ HAI bản `_EmptyState` giống hệt nhau từng dòng:
/// `library_tab_view.dart` (Thư viện của tôi) và `surah_list_screen.dart`
/// (danh sách Surah) — cùng `Center > Padding(24) > Column(center,
/// [Icon(56, onSurfaceVariant), SizedBox(12), Text(center)])`. Đây là
/// hạng mục C2 trong design_system_consolidation_plan.md, đã được xác
/// nhận tương đương bằng cách đọc trực tiếp cả hai.
///
/// KHÁC [EmptyStateBanner] (dải ngang có nền, nằm TRONG một khu vực đã
/// có nội dung khác): widget này chiếm trọn vùng trống khi danh sách
/// hoàn toàn không có gì.
///
/// Ngữ nghĩa lấy mức CAO NHẤT thay vì mức thấp nhất của hai bản gốc
/// (repository_engineering_standard.md, mục 3): thêm
/// `Semantics(liveRegion:)` đúng mẫu [EmptyStateBanner] — khi danh sách
/// chuyển từ "đang tải" sang "trống", trình đọc màn hình tự thông báo
/// thay vì để người dùng tự dò. Giao diện KHÔNG đổi.
class FullEmptyState extends StatelessWidget {
  const FullEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: scheme.onSurfaceVariant),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
