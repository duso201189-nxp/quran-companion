import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/audio/background_audio_support.dart';

/// Sprint B2 — nền tảng nào được gọi `AudioService.init()`.
///
/// Đây là hàm mà trả lời sai thì app chết lúc khởi động, TRƯỚC khung
/// hình đầu tiên, trên nền tảng không có phần cài đặt gốc. Nó nhận
/// tham số thay vì tự hỏi `Platform.isAndroid` chính là để bộ test này
/// duyệt được cả sáu nền tảng trên một máy Windows.
void main() {
  group('B2 — nền tảng có phát nền', () {
    test('Android và iOS -> có', () {
      expect(
        backgroundAudioSupported(
          isWeb: false,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        backgroundAudioSupported(isWeb: false, platform: TargetPlatform.iOS),
        isTrue,
      );
    });

    test('Windows và Linux -> không (audio_service không hỗ trợ)', () {
      expect(
        backgroundAudioSupported(
          isWeb: false,
          platform: TargetPlatform.windows,
        ),
        isFalse,
      );
      expect(
        backgroundAudioSupported(isWeb: false, platform: TargetPlatform.linux),
        isFalse,
      );
    });

    test('macOS -> không, vì B2 không được phép cấu hình gốc cho nó', () {
      // audio_service CÓ hỗ trợ macOS. Không bật ở đây là quyết định
      // phạm vi, không phải giới hạn kỹ thuật — bật một nền tảng mà
      // không khai báo được cấu hình của nó là phát hành lỗi lúc chạy.
      expect(
        backgroundAudioSupported(isWeb: false, platform: TargetPlatform.macOS),
        isFalse,
      );
    });

    test('web -> không, KỂ CẢ khi trình duyệt chạy trên Android/iOS', () {
      // Cái bẫy thật của hàm này: trên web `defaultTargetPlatform` trả
      // về hệ điều hành của TRÌNH DUYỆT. Chrome trên Android báo
      // TargetPlatform.android. Nếu chỉ nhìn `platform`, bản web sẽ gọi
      // init() và chết — trên một bản build đang chạy tốt.
      for (final platform in TargetPlatform.values) {
        expect(
          backgroundAudioSupported(isWeb: true, platform: platform),
          isFalse,
          reason: 'web + $platform phải là false',
        );
      }
    });

    test('mọi nền tảng đều có câu trả lời, không nền tảng nào ném lỗi', () {
      // Thêm một TargetPlatform mới trong Flutter sau này sẽ mặc định
      // rơi vào "không hỗ trợ" — hướng an toàn.
      for (final platform in TargetPlatform.values) {
        expect(
          () => backgroundAudioSupported(isWeb: false, platform: platform),
          returnsNormally,
        );
      }
    });
  });
}
