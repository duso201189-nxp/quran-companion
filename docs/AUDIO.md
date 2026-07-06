# Audio — kiến trúc & cấu hình

## Kiến trúc

```
AudioBar (UI) ──> AudioController (Riverpod, business logic)
                        │
              AyahAudioPlayer (interface)
              ├─ JustAudioAyahPlayer (app thật)
              └─ FakeAyahAudioPlayer (test)
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

## Cấu hình phát nền (giai đoạn phát hành)

Phát khi tắt màn hình + nút điều khiển trên thông báo cần:
1. Package `audio_service` bọc quanh JustAudioAyahPlayer.
2. Android: service + MediaButtonReceiver trong AndroidManifest.xml.
3. iOS: `UIBackgroundModes: audio` trong Info.plist.

Chưa cấu hình: audio vẫn phát bình thường khi app mở — đủ cho
giai đoạn phát triển. Mục này nằm trong checklist phát hành TODO.md.

## Kết nối CacheManager với trình phát (Bước 5b)

`IoCacheManager.cachedAyahUri` trả file local nếu đã tải —
AudioController sẽ ưu tiên file local trước khi stream (nối ở bước
UI tải offline trong Cài đặt, cùng màn hình quản lý dung lượng).
