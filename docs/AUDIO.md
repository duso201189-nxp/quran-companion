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

### CHƯA xong (Phase 2) — chưa nối, và cố ý

`AudioService.init()` **chưa** được gọi ở `main.dart`. Gọi nó khi
AndroidManifest chưa khai báo service là lỗi lúc CHẠY, nên nối sớm sẽ
làm hỏng app trên Android. Còn lại:

1. Android: `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
   (Android 14+), `<service>` và `<receiver>` trong AndroidManifest.xml.
2. iOS: `UIBackgroundModes: audio` trong Info.plist.
3. `main.dart`: gọi `AudioService.init` CÓ ĐIỀU KIỆN theo nền tảng.

Bộ quyền là một **cam kết với cửa hàng ứng dụng**, không phải một thay
đổi mã: gỡ ra sau khi đã phát hành là sửa hồ sơ trên store. Vì thế
Phase 2 chờ quyết định của chủ sản phẩm.

**Hiện trạng người dùng:** audio phát bình thường khi app đang mở, y
như trước B1. Không có thay đổi hành vi nào.

### Kiểm chứng

Nội dung trên màn hình khoá, nút nào sáng, và việc nút có nối đúng
xuống trình phát hay không — **đều có test** (`quran_audio_handler_test.dart`).
`BaseAudioHandler` dựng được trong test thường vì nó chỉ tạo vài
`BehaviorSubject`; chỉ `AudioService.init()` mới cần nền tảng thật.

Điều **không** kiểm được ở đây: audio có thực sự tiếp tục phát khi khoá
màn hình không. Việc đó cần thiết bị thật — roadmap B4.

## Kết nối CacheManager với trình phát (Bước 5b)

`IoCacheManager.cachedAyahUri` trả file local nếu đã tải —
AudioController sẽ ưu tiên file local trước khi stream (nối ở bước
UI tải offline trong Cài đặt, cùng màn hình quản lý dung lượng).
