import 'package:flutter/material.dart';

import 'sections/tafsir_section.dart';

/// Một MỤC của Study Workspace — hợp đồng chung cho mọi tính năng học
/// sâu sẽ được thêm sau (Tafsir, ghi chú, highlight, tham chiếu chéo,
/// phân tích từ...). Xem `DR-2026-0007` quyết định D6.
///
/// Là VALUE TYPE, không phải lớp cha để kế thừa: dự án tránh kế thừa
/// (xem `repository_engineering_standard.md`). Thêm tính năng = thêm
/// MỘT giá trị vào [kStudySections] + một provider `autoDispose.family`
/// của riêng nó; không sửa vỏ, không sửa trang đọc.
///
/// Sprint 31.2 — mục KHÔNG còn khai báo tiêu đề. Panel Tafsir đầu tiên
/// cho thấy chỉ chính mục mới biết mình có nội dung hay không (sau khi
/// provider nạp xong), nên nó phải tự quyết định có dựng tiêu đề hay
/// không. Tiêu đề chuẩn nằm ở [StudyPanel], mục nào cũng dùng.
@immutable
class StudySection {
  const StudySection({required this.id, required this.builder});

  /// Định danh ổn định — dùng cho `ValueKey` và cho test.
  final String id;

  /// Dựng thân mục cho đúng Ayah đang mở.
  ///
  /// Chỉ nhận `ayahId` — vỏ KHÔNG truyền dữ liệu đã nạp sẵn xuống.
  /// Mỗi mục tự nạp phần của mình qua provider riêng, nên một mục chậm
  /// hay lỗi không chặn các mục khác (`DR-2026-0007` luồng dữ liệu).
  /// Trả `SizedBox.shrink()` để tự ẩn hoàn toàn.
  final Widget Function(BuildContext context, int ayahId) builder;
}

/// ĐIỂM ĐĂNG KÝ duy nhất của Study Workspace.
///
/// Danh sách hằng, KHÔNG phải registry động: đăng ký lúc chạy chỉ cần
/// khi có thành phần nạp động, điều dự án không có và chưa lên kế
/// hoạch. Thêm mục = thêm một dòng ở đây.
///
/// Thứ tự trong danh sách = thứ tự hiển thị.
final List<StudySection> kStudySections = <StudySection>[
  tafsirSection,
];
