# Audio — kiến trúc & cấu hình

## Kiến trúc

```
AudioBar (UI) ──> AudioController (Riverpod, business logic)
                        │
              AyahAudioPlayer (interface)
              ├─ JustAudioAyahPlayer (app thật, MỌI nền tảng)
              └─ FakeAyahAudioPlayer (test)
                        │
              QuranAudioHandler (adapter hệ điều hành, Sprint B1)
              └─ quan sát trình phát, chuyển tiếp nút thông báo
                 — KHÔNG phải một trình phát thứ hai
                        │
              CacheManager (offline)
              ├─ IoCacheManager (Android/iOS/desktop)
              └─ (web: stream trực tiếp, không cache file)
```

- URL audio dựng từ mẫu trong bảng `reciters` — thêm Qari = thêm
  dòng dữ liệu.
- Tải offline: file tạm `.part` đổi tên khi xong — không bao giờ
  nhận nhầm file tải dở; mất mạng giữ phần đã có, lần sau tải bù.
- Lặp: off -> lặp 1 Ayah -> lặp cả Surah. Tốc độ: 0.75–2.0x.

## Phát nền — Sprint B1

### Đã xong (Phase 0–1)

1. **`AyahAudioItem`** — mục playlist mang theo mô tả (địa chỉ
   `QuranAddress`, tên Surah, tên Qari). `setPlaylist` nhận
   `List<AyahAudioItem>` thay cho `List<Uri>`: một URL không trả lời
   được "người dùng đang nghe gì", mà khi màn hình đã khoá thì thông
   báo là toàn bộ giao diện còn lại.
2. **`QuranAudioHandler`** — `BaseAudioHandler` BỌC QUANH
   `AyahAudioPlayer` chứ không thay thế nó. Nhờ vậy Windows và Linux
   (audio_service không hỗ trợ) dùng `JustAudioAyahPlayer` y như cũ,
   và `AudioController` không phải đổi một dòng nào: nút trên thông
   báo gọi thẳng xuống trình phát, controller vốn đã lắng nghe stream
   của trình phát nên trạng thái tự khớp.
3. **`audio_service: ^0.18.19`** trong pubspec. Sàn Dart nâng 3.4 → 3.6
   theo yêu cầu của gói.

### Đã xong (Phase 2 — Sprint B2)

`AudioService.init()` đã được nối ở `main.dart`, **có điều kiện theo
nền tảng**.

1. **Android** — `AndroidManifest.xml`: ba quyền (`WAKE_LOCK`,
   `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`), khai báo
   `<service>` `com.ryanheise.audioservice.AudioService` với
   `foregroundServiceType="mediaPlayback"`, và `<receiver>`
   `MediaButtonReceiver` cho phím media phần cứng. `MainActivity` đổi
   sang kế thừa `AudioServiceActivity` để chạm vào thông báo mở lại
   đúng engine đang giữ phiên phát.
2. **iOS** — `Info.plist`: `UIBackgroundModes: audio`. Chỉ khai đúng
   một mode; App Review có kiểm tra mode đã khai có thực sự dùng không.
3. **`main.dart`** — `backgroundAudioSupported(isWeb:, platform:)` quyết
   định có gọi `init()` hay không. Web bị loại **kể cả khi**
   `defaultTargetPlatform` báo android/iOS: trên web nó trả về hệ điều
   hành của TRÌNH DUYỆT.
4. **Hàng đợi** — `QuranAudioHandler` publish `queue`, và đó cũng là
   nguồn duy nhất biết playlist dài bao nhiêu, nên `skipToNext` chặn
   được biên cuối.

**Nền tảng bật/tắt:**

| Nền tảng | `AudioService.init()` | Vì sao |
|---|---|---|
| Android, iOS | **có** | Mục tiêu của B2; cấu hình gốc đã khai báo |
| macOS | không | `audio_service` hỗ trợ, nhưng B2 không được phép cấu hình gốc cho macOS |
| Web | không | Không có "phát nền" theo nghĩa này; bản web đang chạy tốt mà không cần |
| Windows, Linux | không | `audio_service` không hỗ trợ; dùng `JustAudioAyahPlayer` như cũ |

### Kiểm chứng

**Đã kiểm bằng máy** (không cần thiết bị):

- Nội dung màn hình khoá, nút nào sáng, nút nối đúng xuống trình phát,
  hàng đợi, và chặn biên `skipToNext` — `quran_audio_handler_test.dart`.
- Nền tảng nào được gọi `init()` — `background_audio_support_test.dart`,
  duyệt cả sáu `TargetPlatform` × web/không-web.
- Manifest **đã hợp nhất** chứa đủ ba quyền, service kèm
  `foregroundServiceType="mediaPlayback"`, và receiver — đọc ra từ
  `build/app/intermediates/merged_manifest/` sau `flutter build apk`.
- `Info.plist` phân tích được và khai đúng `['audio']`.
- `MainActivity : AudioServiceActivity()` biên dịch được (APK debug
  build thành công).

**CHƯA kiểm được — cần thiết bị thật (roadmap B4):**

Không có máy Android/iOS nào nối vào môi trường phát triển hiện tại
(`flutter devices` chỉ thấy Windows/Chrome/Edge). Những điều dưới đây là
**giả định đã cấu hình đúng**, chưa phải sự thật đã quan sát:

| # | Cần kiểm trên máy thật | Kỳ vọng |
|---|---|---|
| 1 | Phát một Surah, khoá màn hình | Audio tiếp tục, không ngắt |
| 2 | Nhìn màn hình khoá | Hiện "Ayah N", tên Surah, tên Qari |
| 3 | Bấm Tạm dừng / Phát trên thông báo | Trạng thái đổi, và khớp với thanh phát trong app |
| 4 | Bấm Ayah kế / Ayah trước trên thông báo | Nhảy đúng Ayah |
| 5 | **Ở Ayah CUỐI, bấm Ayah kế** | Không có gì xảy ra, không văng lỗi |
| 6 | Vuốt bỏ thông báo khi đang phát | Không bỏ được (ongoing) |
| 7 | Tạm dừng rồi vuốt thông báo | Bỏ được, phát dừng hẳn |
| 8 | Chạm vào thông báo | Mở lại app đúng màn hình đang đọc, KHÔNG mất trạng thái |
| 9 | Nút pause trên tai nghe / Bluetooth xe | Dừng/phát đúng (đường `MediaButtonReceiver`) |
| 10 | Android 14+ (API 34+) | Không có `SecurityException` lúc bắt đầu phát |
| 11 | Chạy bản Windows | Phát bình thường, không có thông báo, không lỗi thiếu plugin |

## Kết nối CacheManager với trình phát (Bước 5b)

`IoCacheManager.cachedAyahUri` trả file local nếu đã tải —
AudioController sẽ ưu tiên file local trước khi stream (nối ở bước
UI tải offline trong Cài đặt, cùng màn hình quản lý dung lượng).
