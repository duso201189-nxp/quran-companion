import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_header.dart';

/// Khung hiển thị chuẩn của MỘT mục Study Workspace: tiêu đề + thân,
/// khoảng cách thống nhất.
///
/// Sprint 31.2 — VÌ SAO tiêu đề nằm ở đây chứ không ở vỏ:
/// [StudyWorkspaceShell] bản đầu (Sprint 31.1) tự vẽ tiêu đề cho mọi
/// mục. Panel Tafsir thật cho thấy như vậy là sai — một mục chỉ biết
/// mình CÓ nội dung hay không sau khi provider của nó nạp xong, mà lúc
/// đó vỏ đã vẽ tiêu đề rồi. Kết quả là một tiêu đề "Tafsir" lơ lửng
/// bên trên khoảng trống ở mọi Ayah chưa có chú giải.
///
/// Nay mục TỰ QUYẾT ĐỊNH có dựng khung hay không (`SizedBox.shrink()`
/// khi rỗng), còn khung này giữ cho mọi mục trông như nhau. Đây là
/// điều chỉnh kiến trúc do panel đầu tiên phát hiện — đúng mục đích
/// "panel Tafsir để kiểm chứng kiến trúc".
class StudyPanel extends StatelessWidget {
  const StudyPanel({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(text: title),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
