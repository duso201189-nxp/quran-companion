import 'package:flutter/material.dart';

/// Thời lượng CHUNG cho mọi chuyển cảnh vào/ra Focus Mode (Sprint
/// 25.3) — một nguồn duy nhất để nền, vỏ dưới và mọi phần khác cùng
/// một nhịp, thay vì mỗi nơi tự chọn một con số.
const Duration kFocusTransitionDuration = Duration(milliseconds: 320);

/// Đường cong CHUNG: chậm ở hai đầu, KHÔNG nảy, KHÔNG vọt quá đích —
/// chuyển cảnh nên gần như không nhận ra.
const Curve kFocusTransitionCurve = Curves.easeInOut;

/// [kFocusTransitionDuration], nhưng bằng 0 khi hệ điều hành bật
/// "giảm chuyển động": người bật tuỳ chọn đó nhận kết quả tức thì.
Duration focusTransitionDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : kFocusTransitionDuration;

/// Thu gọn chiều cao + mờ dần CÙNG LÚC — dùng cho phần "vỏ" ở đáy
/// trang đọc khi vào/ra Focus Mode, thay cho việc bật/tắt đột ngột.
///
/// Điểm quan trọng về hiệu năng: khi đã thu xong ([visible] = false và
/// animation kết thúc), [child] được THÁO HẲN khỏi cây widget — nó
/// không còn được build, nên cũng không còn đăng ký provider nào trong
/// suốt lúc đọc ở Focus Mode. Đây là lý do dùng `TweenAnimationBuilder`
/// + tham số `child` thay vì bọc `Opacity` quanh một cây luôn tồn tại.
class FocusCollapse extends StatelessWidget {
  const FocusCollapse({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: visible ? 1 : 0),
      duration: focusTransitionDuration(context),
      curve: kFocusTransitionCurve,
      // `child` dựng SẴN ở đây và truyền xuống builder -> không dựng
      // lại nó theo từng khung hình của animation.
      child: child,
      builder: (context, t, child) {
        // Tháo child CHỈ khi đã thu xong VÀ đang ở trạng thái ẩn. Lúc
        // hiện trở lại, t bắt đầu từ 0 — nếu chỉ xét `t == 0` thì child
        // sẽ trễ mất một khung hình trước khi vào lại cây.
        if (t == 0 && !visible) return const SizedBox.shrink();
        final clamped = t.clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: clamped,
            child: Opacity(opacity: clamped, child: child),
          ),
        );
      },
    );
  }
}
