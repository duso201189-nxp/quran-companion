# Font chữ Ả Rập

## Font chính: KFGQPC Uthmanic Script HAFS

Font chuẩn Mushal Madinah, do King Fahd Glorious Qur'an Printing
Complex phát hành, miễn phí cho ứng dụng Qur'an.

**ĐÃ ĐÓNG GÓI** trong `assets/fonts/UthmanicHafs.ttf` (237 KB,
version 0.18) và khai báo trong `pubspec.yaml`. Trang đọc dùng nó làm
font mặc định với cỡ chữ điều chỉnh được.

Nguồn tải lại nếu cần: https://fonts.qurancomplex.gov.sa
(chọn "Uthmanic Script HAFS").

Chuỗi fallback trong theme: `UthmanicHafs` -> `Amiri` -> font hệ
thống.

## Giấy phép — bắt buộc kèm theo

Bốn font đóng gói đều có nghĩa vụ ghi chú giấy phép, và văn bản đầy
đủ nằm trong `assets/licenses/`, đăng ký vào `LicenseRegistry` (xem
`lib/core/licenses/bundled_font_licenses.dart`), hiển thị trong app ở
Hồ sơ -> Nguồn dữ liệu -> Giấy phép phần mềm & phông chữ.

| Font | Phiên bản | Giấy phép |
|---|---|---|
| KFGQPC HAFS Uthmanic Script | 0.18 | EULA riêng — cho phép dùng/chép/phân phối miễn phí, CẤM bán và CẤM sửa font |
| Amiri | 1.002 | SIL OFL 1.1 |
| Noto Naskh Arabic | 2.021 | SIL OFL 1.1 |
| Inter | 4.001 | SIL OFL 1.1 |

OFL 1.1 buộc thông báo bản quyền + giấy phép đi kèm MỌI bản sao của
font. `test/font_licenses_test.dart` đọc `pubspec.yaml` và đối chiếu,
nên thêm font mà quên thông báo sẽ làm CI đỏ. Chi tiết điều khoản:
`docs/LICENSING.md` mục 3.
