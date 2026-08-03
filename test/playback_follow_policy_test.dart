import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/features/quran/domain/playback_follow_policy.dart';

/// Sprint F1 — chính sách bám theo audio (DR-2026-0019 §7.3).
///
/// Chính sách nhận thời gian làm THAM SỐ chứ không tự gọi
/// `DateTime.now()`. Nhờ vậy bộ test này không cần `fakeAsync`, không
/// cần chờ 10 giây thật, và không phập phù theo tốc độ máy chạy CI.
void main() {
  final t0 = DateTime(2026, 8, 3, 12, 0, 0);

  group('F1 — bám theo audio', () {
    test('chưa từng cuộn tay -> bám theo audio (mặc định)', () {
      expect(
        shouldFollowPlayback(now: t0, lastManualScrollAt: null),
        isTrue,
      );
    });

    test('vừa cuộn tay xong -> KHÔNG kéo màn hình về', () {
      expect(
        shouldFollowPlayback(now: t0, lastManualScrollAt: t0),
        isFalse,
      );
    });

    test('còn trong khoảng lặng -> vẫn để yên', () {
      expect(
        shouldFollowPlayback(
          now: t0.add(const Duration(seconds: 9, milliseconds: 999)),
          lastManualScrollAt: t0,
        ),
        isFalse,
      );
    });

    test('đúng lúc hết khoảng lặng -> bám theo trở lại', () {
      expect(
        shouldFollowPlayback(
          now: t0.add(kPlaybackFollowGrace),
          lastManualScrollAt: t0,
        ),
        isTrue,
      );
    });

    test('quá khoảng lặng -> bám theo trở lại', () {
      expect(
        shouldFollowPlayback(
          now: t0.add(const Duration(minutes: 5)),
          lastManualScrollAt: t0,
        ),
        isTrue,
      );
    });

    test('KHÔNG khoá vĩnh viễn — không cần nút "về chỗ đang phát"', () {
      // Tính chất quan trọng nhất của chính sách này: mọi lần cuộn tay
      // đều tự hết hạn. Người dùng không thể tự đưa mình vào trạng thái
      // kẹt mà không biết đường ra.
      var followedAgain = false;
      for (var s = 0; s <= 60; s++) {
        if (shouldFollowPlayback(
          now: t0.add(Duration(seconds: s)),
          lastManualScrollAt: t0,
        )) {
          followedAgain = true;
          break;
        }
      }
      expect(followedAgain, isTrue);
    });
  });

  group('F1 — khoảng lặng chỉnh được', () {
    test('grace tuỳ chọn được tôn trọng', () {
      final now = t0.add(const Duration(seconds: 3));

      expect(
        shouldFollowPlayback(
          now: now,
          lastManualScrollAt: t0,
          grace: const Duration(seconds: 2),
        ),
        isTrue,
      );
      expect(
        shouldFollowPlayback(
          now: now,
          lastManualScrollAt: t0,
          grace: const Duration(seconds: 30),
        ),
        isFalse,
      );
    });

    test('grace bằng 0 -> luôn bám theo, tức hành vi trước F1', () {
      expect(
        shouldFollowPlayback(
          now: t0,
          lastManualScrollAt: t0,
          grace: Duration.zero,
        ),
        isTrue,
      );
    });
  });
}
