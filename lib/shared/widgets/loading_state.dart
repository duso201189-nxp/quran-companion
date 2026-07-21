import 'package:flutter/material.dart';

/// Khung chờ dùng chung khi 1 khu vực đang tải dữ liệu bất đồng bộ
/// (Sprint 15 Phase 2 — trích ra từ `_LoadingState` trước đó riêng
/// của progress_dashboard_screen.dart, Sprint 14 Phase 2.1, để AI
/// Tutor dùng lại thay vì tạo bản sao thứ 2). Chiều cao cố định tránh
/// giật bố cục khi chuyển từ loading sang dữ liệu thật;
/// [semanticsLabel] bắt buộc truyền vào (không tự đọc AppLocalizations
/// ở đây) để mỗi màn hình tự chọn câu chữ phù hợp ngữ cảnh của mình,
/// giữ widget này thuần trình bày, không phụ thuộc bộ khoá l10n cụ
/// thể nào.
///
/// Sprint 20 Phase 2 — rà soát lại theo accessibility_audit.md: widget
/// này đã đạt chuẩn `Semantics(liveRegion: true, label:)` từ trước,
/// không cần sửa (đối chiếu `EmptyStateBanner`, vốn thiếu đúng phần
/// này và đã được bổ sung cùng phase). Không có "retry affordance" vì
/// loading không phải trạng thái lỗi — không có gì để thử lại.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    required this.semanticsLabel,
    this.height = 96,
  });

  final String semanticsLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: semanticsLabel,
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
