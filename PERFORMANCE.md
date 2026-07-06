# Benchmark hiệu năng — Qur'an Companion

Đo SAU MỖI BƯỚC trên: (a) máy dev, (b) 1 thiết bị Android tầm trung
thật. Số liệu điền vào bảng — không chấp nhận "cảm giác nhanh".

## Cách đo

| Chỉ số | Lệnh / cách đo | Ngưỡng |
|---|---|---|
| Startup (cold) | `flutter run --profile --trace-startup` → `timeToFirstFrameMicros` trong build/start_up_info.json | < 2.000 ms |
| Query đọc Surah | Stopwatch quanh `getAyahsOfSurah(2)` (Surah dài nhất, 286 ayah) lần 2 trở đi | < 50 ms |
| Search FTS | Stopwatch quanh truy vấn `search_index MATCH`, từ khóa 2 âm tiết | < 50 ms |
| Memory | DevTools → Memory, sau khi mở trang đọc + cuộn hết 1 Surah dài | < 250 MB |
| APK size | CI in ra mỗi lần build (`app-debug.apk`); release đo bằng `flutter build apk --release --analyze-size` | theo dõi xu hướng |
| Web bundle | `flutter build web --release` → tổng build/web | theo dõi xu hướng |

Lưu ý: bench query trên THIẾT BỊ THẬT, lần chạy thứ 2+ (bỏ chi phí
mở database lần đầu vốn thuộc về startup).

## Kết quả theo bước

### Bước 2 — Lớp dữ liệu (điền sau khi chạy trên máy)

| Chỉ số | Máy dev | Android tầm trung | Đạt? |
|---|---|---|---|
| Startup cold | _chưa đo_ | _chưa đo_ | — |
| getAyahsOfSurah(2) | _chưa đo_ | _chưa đo_ | — |
| FTS MATCH 'rahman' | _chưa đo_ | _chưa đo_ | — |
| APK debug size | _CI in ra_ | — | — |

Thiết kế phục vụ ngưỡng 50ms đã có: 9 index phủ mọi trục truy vấn
(surah+ayah_number composite, juz, hizb, page, sajdah partial,
translations theo ayah/source), join 1 truy vấn tránh N+1,
SQLite chạy isolate riêng. **Ngưỡng chỉ được coi là ĐẠT khi có số
đo thật điền vào bảng.**
