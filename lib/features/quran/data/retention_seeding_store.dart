import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/prefs_provider.dart';

/// Mốc kích hoạt Automatic Retention Seeding (Sprint 7.3 —
/// DR-2026-0021, amends DR-2026-0004 mục 3).
///
/// Ghi ĐÚNG MỘT LẦN — lần đầu tiên trên thiết bị này — SharedPreferences,
/// cùng kiến trúc [ThemeController]/[LocaleController]/`DailyGoalStore`
/// (Notifier tự đọc lại lúc build(), không có khung cấu hình mới). Sau
/// lần ghi đầu, mọi lần đọc tiếp theo trả lại đúng giá trị đã lưu —
/// không ghi đè.
///
/// **Sửa lỗi kiểm chứng cuối Sprint 7.3**: trước bản sửa này, mốc chỉ
/// được ghi LƯỜI — lần đầu [retentionSeedingActivationProvider] được
/// một provider/màn hình khác `ref.watch`, tức là lần đầu người dùng
/// vào Revision Queue/Review Session/Learning Session, KHÔNG PHẢI lần
/// mở app đầu tiên. Với người dùng mới đọc vài ngày trước khi chạm tới
/// các màn hình đó, các phiên đọc trong khoảng đó bị loại VĨNH VIỄN
/// khỏi seeding tự động — sai với ý định "kích hoạt lúc mở app đầu
/// tiên" của Sprint 7.3. [ensureActivated] tách phần logic
/// đọc-hoặc-ghi-một-lần thành một hàm THUẦN, độc lập với Riverpod, để
/// `main.dart` có thể gọi CHỦ ĐỘNG ngay lúc khởi động (trước
/// `runApp`), dùng lại nguyên vẹn cùng một logic — [build] bên dưới
/// chỉ còn gọi lại nó, không có logic thứ hai.
class RetentionSeedingActivation extends Notifier<int> {
  RetentionSeedingActivation({int Function()? nowMs})
      : _nowMs = nowMs ?? _epochNow;

  static const String key = 'retention_seeding.activated_at_ms';

  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  /// Đảm bảo mốc kích hoạt đã tồn tại trong [prefs] — nếu đã có, trả
  /// lại nguyên giá trị cũ (không ghi đè); nếu chưa, ghi thời điểm
  /// hiện tại (qua [nowMs], tiêm được cho test) rồi trả lại giá trị
  /// vừa ghi. An toàn gọi nhiều lần (idempotent) — `main.dart` gọi một
  /// lần lúc khởi động, [build] có thể gọi lại về sau mà không ghi đè
  /// lần thứ hai.
  static int ensureActivated(
    SharedPreferences prefs, {
    int Function()? nowMs,
  }) {
    final existing = prefs.getInt(key);
    if (existing != null) return existing;

    final now = (nowMs ?? _epochNow)();
    // Fire-and-forget, cùng mẫu ReadingPositionStore.save/
    // DailyGoalStore.setTarget — SharedPreferences cache giá trị
    // trong RAM ngay lập tức, ghi đĩa không đồng bộ không chặn nơi gọi.
    unawaited(prefs.setInt(key, now));
    return now;
  }

  @override
  int build() =>
      ensureActivated(ref.read(sharedPreferencesProvider), nowMs: _nowMs);
}

final retentionSeedingActivationProvider =
    NotifierProvider<RetentionSeedingActivation, int>(
  RetentionSeedingActivation.new,
);
