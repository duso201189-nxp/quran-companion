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

### Đã kiểm trên thiết bị (Sprint B3, 2026-08-04)

Emulator Pixel 8 (Android 17 / API 37) đã dùng được trong môi trường
này — cập nhật bảng 11 mục ở trên bằng KẾT QUẢ THẬT thay vì giả định.
Chi tiết đầy đủ, kèm lệnh `adb` và log: `docs/release/PHASE4_SPRINT_B3_REPORT.md`.

| # | Kịch bản | Kết quả | Bằng chứng |
|---|---|---|---|
| 1 | Phát một Surah, khoá màn hình | ✅ **PASS** | `mWakefulness=Asleep`, `state=PLAYING`, vị trí phát vẫn tăng |
| 2 | Nhìn màn hình khoá | ✅ **PASS** | Card hiện "Ayah N", tên Surah, tên Qari |
| 3 | Tạm dừng / Phát trên thông báo | ✅ **PASS** (qua đường phím media) | `MEDIA_PAUSE`→`PAUSED`, `MEDIA_PLAY`→`PLAYING`, khớp thanh phát trong app. Chạm tay trực tiếp vào nút không tự động hoá được trên emulator; đường phím media dùng chung một cơ chế `MediaSession` nên xác nhận cùng đường mã nguồn |
| 4 | Ayah kế / Ayah trước trên thông báo | ✅ **PASS** | Nhảy đúng Ayah qua `MEDIA_NEXT`/`MEDIA_PREVIOUS` |
| 5 | Ở Ayah CUỐI, bấm Ayah kế | ✅ **PASS** | Xác nhận trên máy: không có gì xảy ra, không crash — đúng lỗi B2 đã sửa |
| 6 | Vuốt bỏ thông báo khi đang phát | ✅ **PASS** | `flags=ONGOING_EVENT\|NO_CLEAR\|NO_DISMISS` khi đang phát — đúng thiết kế |
| 7 | Tạm dừng/hết bài rồi vuốt thông báo | ⚠️ **CÒN MỘT PHẦN** | Sau bản sửa B3, service foreground được nhả và nút đúng ("Phát"), nhưng thông báo vẫn còn `NO_DISMISS` — chưa vuốt bỏ được. Không phải lỗi tài nguyên (đã đóng), chỉ còn là thẩm mỹ. Xem R2 trong báo cáo B3 |
| 8 | Chạm vào thông báo | ✅ **PASS** | Cùng `ActivityRecord` trước/sau — mở lại đúng activity đang giữ phiên phát, không mất trạng thái |
| 9 | Nút pause trên tai nghe / Bluetooth xe | ⚠️ **MỘT PHẦN** | Đường mã nguồn (`MediaButtonReceiver`, `KEYCODE_MEDIA_*`) xác nhận được; phần cứng Bluetooth/tai nghe thật thì KHÔNG — không có thiết bị |
| 10 | Android 14+ (API 34+) | ✅ **PASS** (đo ở API 37) | `isForeground=true types=0x00000002` (MEDIA_PLAYBACK), không `SecurityException`. API 37 áp luật nghiêm hơn 34, nên PASS ở đây suy ra được cho 34 — nhưng 34 chưa đo trực tiếp |
| 11 | Chạy bản Windows | — chưa đo lại | Không đổi từ trước B2: `JustAudioAyahPlayer` không có nhánh nào cho `audio_service` |

**Một lỗi tìm thấy VÀ ĐÃ SỬA trong Sprint B3**: nghe hết một Surah để
đó, thông báo còn lại nút "Tạm dừng" cho thứ đã im, không vuốt bỏ được,
và foreground service bị giữ vô thời hạn — vì `just_audio` báo
`playing == true` ngay cả sau khi hết playlist. `AudioController` đã
tự chữa từ lâu; `playbackStateFor` (adapter thông báo) thì chưa. Đã
sửa và xác nhận lại trên máy.

**iOS: 0% kiểm chứng.** Cần macOS, không có trong môi trường này. Toàn
bộ bảng trên chỉ là Android.

### Basmalah 2.0 và hàng đợi (Sprint BM1–BM4, 2026-08-04)

Basmalah 2.0 thêm một mục MỞ ĐẦU vào đầu playlist cho 112/114 Surah
(xem `docs/release/PHASE4_BASMALAH_2_0_PLAN.md`). Ảnh hưởng tới bảng
kiểm chứng ở trên:

- **Độ dài hàng đợi đổi**: `queue size` giờ là `số Ayah + 1` cho Surah
  có phần mở đầu (đo trên máy: Al-Kahf 110 Ayah → hàng đợi 111 mục).
  Al-Fatihah và At-Tawbah không đổi (không có phần mở đầu).
- **Lỗi tìm thấy VÀ ĐÃ SỬA (BM4)**: màn hình khoá hiện đúng chữ
  **"Ayah null"** trong lúc Basmalah phát, vì `mediaItemFor` (viết ở
  B1, lúc mọi mục playlist đều là Ayah) không xử lý mục mức Surah. Đã
  sửa: mục mở đầu hiện "Bismillah".
- **Kiểm lại mục 5 (biên playlist) và mục 8 (chạm thông báo) trên
  Al-Kahf** — cả hai vẫn đúng với hàng đợi đã dài thêm một mục; xem
  `docs/release/PHASE4_SPRINT_BM4_REPORT.md`.
- Vị trí đọc lưu trên đĩa (`reading.pos.*`) xác nhận trên máy vẫn là
  chỉ số Ayah, không lệch sang chỉ số playlist — không có thay đổi nào
  tới `ReadingPositionStore` hay `study_sessions`.

## Kết nối CacheManager với trình phát (Bước 5b)

`IoCacheManager.cachedAyahUri` trả file local nếu đã tải —
AudioController sẽ ưu tiên file local trước khi stream (nối ở bước
UI tải offline trong Cài đặt, cùng màn hình quản lý dung lượng).
