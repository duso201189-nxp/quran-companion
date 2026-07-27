import 'package:flutter/material.dart';

/// Banner rỗng dùng chung — hàng Icon + văn bản trên nền
/// secondaryContainer nhạt (Sprint 15 Phase 2 — trích ra từ
/// `_SectionEmptyState` trước đó riêng của progress_dashboard_screen.dart,
/// Sprint 14 Phase 2.1, để AI Tutor dùng lại thay vì tạo bản sao thứ
/// 2 — `stats_screen.dart` cũng có 1 widget gần như giống hệt
/// (`_EmptyHint`, Sprint 8, chưa gộp ở phase này — xem Return Phase 2
/// mục "Remaining backlog").
///
/// Sprint 20 Phase 2 — thêm `Semantics(liveRegion: true, label: text)`
/// bao quanh, ĐÚNG mẫu đã có sẵn ở `LoadingState`/`SearchErrorState`
/// (2 widget trạng thái dùng chung còn lại — trước phase này,
/// `EmptyStateBanner` là ngoại lệ DUY NHẤT thiếu `liveRegion`, xem
/// accessibility_audit.md mục 2.2). Khi 1 phần chuyển từ loading sang
/// rỗng, trình đọc màn hình giờ được chủ động thông báo, không cần
/// người dùng tự dò tìm. Giao diện KHÔNG đổi — `ExcludeSemantics` chỉ
/// gộp Icon+Text (vốn không mang thêm thông tin ngoài [text]) thành 1
/// nút duy nhất, cùng lý do `SearchErrorState` làm với Icon+Text lỗi
/// của nó.
class EmptyStateBanner extends StatelessWidget {
  const EmptyStateBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: text,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: scheme.onSecondaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
