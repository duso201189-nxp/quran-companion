# Font chữ Ả Rập

## Font chính: KFGQPC Uthmanic Script HAFS

Font chuẩn Mushal Madinah, do King Fahd Glorious Qur'an Printing
Complex phát hành, miễn phí cho ứng dụng Qur'an.

1. Tải từ trang chính thức: https://fonts.qurancomplex.gov.sa
   (chọn "Uthmanic Script HAFS" — file UthmanicHafs...ttf)
2. Đặt vào `assets/fonts/UthmanicHafs.ttf`
3. Bỏ comment khối `fonts:` trong pubspec.yaml
4. `flutter pub get`

Code đã tham chiếu `fontFamily: 'UthmanicHafs'` với fallback
(`Amiri`, `Scheherazade New`, rồi font hệ thống) — CHƯA có font,
chữ Ả Rập vẫn hiển thị đúng bằng font hệ thống, chỉ kém đẹp.

Bước 4 (trang đọc) sẽ dùng font này làm mặc định với cỡ chữ
điều chỉnh được.
