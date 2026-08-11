import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_provider.dart';

/// Trạng thái "vừa đọc trọn một Surah" — Sprint 7.4 (DR-2026-0023
/// mục 7).
///
/// Lưu SharedPreferences, KHÔNG có bảng/schema mới, cùng kiến trúc
/// `RetentionSeedingActivation`/`ThemeController`/`DailyGoalStore`
/// (Notifier tự đọc lại lúc `build()`).
///
/// ## Hai họ khoá, hai ý nghĩa khác nhau
///
/// - [surahKey] (`boundary.surah.<id>`) — DẤU VĨNH VIỄN, ghi đúng một
///   lần: "Surah này đã từng mời ôn rồi". Nhờ nó, đọc lại một Surah đã
///   xong KHÔNG mời lại lần nữa, và đánh dấu là idempotent.
/// - [pendingKey] (`boundary.surah.pending`) — lời mời đang treo, tối
///   đa MỘT. Bỏ qua lời mời xoá khoá này nhưng GIỮ dấu vĩnh viễn: bỏ
///   qua là dứt khoát, không phải hoãn lại.
///
/// State của Notifier chính là "Surah đang có lời mời" (`null` = không
/// có) — nhờ đó màn hình Học phản ứng ngay khi đánh dấu/bỏ qua, không
/// cần `ref.invalidate` thủ công.
///
/// ## Vì sao Notifier chứ không phải store thuần
///
/// `ReadingScreen.dispose()` không được `ref.read` (ref có thể đã bị
/// huỷ) — nó bắt sẵn đối tượng ở `initState`, đúng mẫu `_statsStore`/
/// `_studySessionRepository` đang dùng. Một `Notifier` bắt được theo
/// cách đó (`ref.read(...notifier)`) mà vẫn phát trạng thái mới cho
/// mọi nơi đang xem — store thuần thì không, và màn hình Học sẽ đọc
/// phải giá trị cũ.
class BoundaryCompletionController extends Notifier<int?> {
  BoundaryCompletionController({int Function()? nowMs})
      : _nowMs = nowMs ?? _epochNow;

  /// Lời mời đang treo — giá trị là surahId.
  static const String pendingKey = 'boundary.surah.pending';

  /// Dấu vĩnh viễn cho từng Surah — giá trị là thời điểm đánh dấu.
  static String surahKey(int surahId) => 'boundary.surah.$surahId';

  final int Function() _nowMs;

  static int _epochNow() => DateTime.now().toUtc().millisecondsSinceEpoch;

  @override
  int? build() => ref.read(sharedPreferencesProvider).getInt(pendingKey);

  /// Surah này đã từng tạo lời mời chưa (dấu vĩnh viễn).
  bool wasInvitedFor(int surahId) =>
      ref.read(sharedPreferencesProvider).getInt(surahKey(surahId)) != null;

  /// Đánh dấu vừa đọc trọn [surahId] và dựng lời mời.
  ///
  /// Idempotent: Surah đã có dấu vĩnh viễn -> KHÔNG làm gì, kể cả khi
  /// lời mời cũ đã bị bỏ qua. Đọc lại một Surah đã xong không mời lại.
  ///
  /// An toàn gọi từ `dispose()`: chỉ ghi SharedPreferences (đã cache
  /// trong RAM ngay lập tức) và đặt state của một Notifier sống trong
  /// container, không chạm widget/context nào.
  Future<void> markSurahCompleted(int surahId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getInt(surahKey(surahId)) != null) return;

    await prefs.setInt(surahKey(surahId), _nowMs());
    await prefs.setInt(pendingKey, surahId);
    state = surahId;
  }

  /// Bỏ qua lời mời đang treo. Dấu vĩnh viễn GIỮ NGUYÊN.
  Future<void> dismiss() async {
    await ref.read(sharedPreferencesProvider).remove(pendingKey);
    state = null;
  }
}

final boundaryCompletionProvider =
    NotifierProvider<BoundaryCompletionController, int?>(
  BoundaryCompletionController.new,
);
