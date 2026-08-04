import 'package:flutter/foundation.dart';

/// Nền tảng này có gọi được `AudioService.init()` không? (Sprint B2)
///
/// Câu hỏi này phải trả lời được mà KHÔNG cần thiết bị, vì trả lời sai
/// là app chết lúc khởi động: `AudioService.init()` trên nền tảng không
/// có phần cài đặt gốc sẽ ném `MissingPluginException` trước cả khung
/// hình đầu tiên. Vì thế nó là hàm thuần nhận tham số, không phải một
/// `if (Platform.isAndroid)` nằm giữa `main()`.
///
/// ## Vì sao [isWeb] là tham số RIÊNG, không suy từ [platform]
///
/// Trên web, `defaultTargetPlatform` trả về hệ điều hành của TRÌNH
/// DUYỆT: mở app bằng Chrome trên Android thì nó là
/// [TargetPlatform.android]. Nếu chỉ nhìn [platform], bản web sẽ tưởng
/// mình là Android và gọi `init()` — đúng cái lỗi mô tả ở trên, trên
/// một bản build đang chạy tốt. Hai chiều thông tin khác nhau nên phải
/// hỏi cả hai.
///
/// ## Vì sao chỉ Android và iOS
///
/// `audio_service` còn hỗ trợ macOS và web, nhưng cả hai đều CHƯA được
/// bật ở đây, có chủ ý:
///
/// - **macOS** cần cấu hình gốc riêng mà Sprint B2 không được phép động
///   tới (phạm vi chỉ có AndroidManifest và Info.plist của iOS). Bật
///   một nền tảng mà không khai báo được cấu hình của nó là phát hành
///   một lỗi lúc chạy.
/// - **Web** không có khái niệm "phát nền" theo nghĩa đang nói: tab
///   đóng là hết. `AudioService` trên web chỉ thêm MediaSession của
///   trình duyệt, không phải mục tiêu của B2, và bản web hiện đang chạy
///   tốt mà không có nó.
///
/// Windows và Linux thì `audio_service` không hỗ trợ; chúng dùng
/// `JustAudioAyahPlayer` y như trước, không nhánh nào trong trình phát.
bool backgroundAudioSupported({
  required bool isWeb,
  required TargetPlatform platform,
}) {
  if (isWeb) return false;
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
}
