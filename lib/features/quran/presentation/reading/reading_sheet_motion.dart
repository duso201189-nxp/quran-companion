import 'package:flutter/material.dart';

/// Nhịp mở/đóng CHUNG cho mọi bottom sheet của trang đọc (sheet thao
/// tác Ayah — Sprint 25.4, bảng Hiển thị — Sprint 25.5): mềm khi vào,
/// gọn hơn một chút khi ra, không nảy.
///
/// Một hằng số duy nhất để các sheet không bao giờ lệch nhịp nhau —
/// cùng tinh thần với [kFocusTransitionDuration] của Focus Mode.
const AnimationStyle kReadingSheetMotion = AnimationStyle(
  duration: Duration(milliseconds: 280),
  curve: Curves.easeOutCubic,
  reverseDuration: Duration(milliseconds: 220),
  reverseCurve: Curves.easeInCubic,
);

/// [kReadingSheetMotion], hoặc KHÔNG animation khi hệ điều hành bật
/// "giảm chuyển động" — cùng nguyên tắc với chuyển cảnh Focus Mode,
/// và không cần AnimationController riêng.
AnimationStyle readingSheetMotion(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
        ? AnimationStyle.noAnimation
        : kReadingSheetMotion;
