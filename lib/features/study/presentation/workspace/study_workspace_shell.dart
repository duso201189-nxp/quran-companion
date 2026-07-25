import 'package:flutter/material.dart';

import 'study_section.dart';

/// Vỏ của Study Workspace: dựng danh sách [StudySection] theo đúng thứ
/// tự khai báo, mỗi mục một tiêu đề thống nhất.
///
/// Vỏ KHÔNG biết mục nào tồn tại và KHÔNG nạp dữ liệu cho mục nào —
/// nó chỉ nhận danh sách và dựng. Nhờ vậy thêm Tafsir hay ghi chú
/// không phải sửa file này (`DR-2026-0007` D6).
///
/// [sections] cho phép bơm từ test; mặc định là điểm đăng ký thật
/// [kStudySections].
class StudyWorkspaceShell extends StatelessWidget {
  const StudyWorkspaceShell({super.key, required this.ayahId, this.sections});

  final int ayahId;

  /// null = dùng điểm đăng ký thật [kStudySections]. Tham số này chỉ
  /// để test bơm mục giả — không phải điểm cấu hình cho sản phẩm.
  final List<StudySection>? sections;

  @override
  Widget build(BuildContext context) {
    final sections = this.sections ?? kStudySections;
    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      // min: mọi mục tự ẩn -> vỏ chiếm 0 chiều cao, kể cả khi cha cho
      // chiều cao thoải mái. Không có dòng này, một workspace chưa có
      // mục nào hiển thị vẫn đẩy nội dung phía dưới xuống.
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sections)
          KeyedSubtree(
            key: ValueKey('study-section-${section.id}'),
            // Mục tự nạp dữ liệu từ `ayahId` VÀ tự quyết định có dựng
            // gì không — vỏ chỉ xếp chỗ (xem [StudyPanel]).
            child: section.builder(context, ayahId),
          ),
      ],
    );
  }
}
